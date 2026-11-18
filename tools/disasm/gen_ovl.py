#!/usr/bin/env python3
# gen_ovl.py: turn an RTLink overlay (.OVL) into NASM source that rebuilds the same bytes.
#   python3 tools/disasm/gen_ovl.py MENUS [LP ...]        (names from ovlmap.json)
# An overlay file is a list of relocation entries (offset, segment), zero fill to the next paragraph, then the image.
# The image holds several linker segments; their paragraphs come from the relocations and the resident thunks
# (ovlmap.json). Code is found by recursive descent from every far call or far pointer into the overlay (its own
# relocations, the resident thunks, other overlays), plus function prologues in what is left. Everything else is db.
# Instruction text comes from ndisasm; any line whose encoding NASM would change is written as db with the text as
# a comment. Writes src/ovl/<name>/<segment>.asm and src/ovl/<name>.asm (the relocation table and the sections).
import json, os, re, struct, subprocess, sys, tempfile
import capstone
from capstone import x86

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
OVLMAP = json.load(open(os.path.join(ROOT, 'ovlmap.json')))
SEGMAP = json.load(open(os.path.join(ROOT, 'segmap.json')))
SEGMAP_FILE = {x['name']: x.get('file', '') for x in SEGMAP['segments']}
ROOTSEGS = {s['para']: s['name'] for s in SEGMAP['segments'] if 'para' in s}
DGROUP_PARA = 0x45C9

IMG = b''
SEGS = []
RELOC = set()
OV = None
DATA_LIN, CODE_LIN, TABLE_LIN, TABLE_BYTES = set(), [], {}, set()
OVERRIDES = {}      # overlay name -> {'data': [(lin0, lin1)], 'code': [lin], 'tables': {lin: n}}


def ovl_bytes(o):
    return open(os.path.join(ROOT, o['file']), 'rb').read()


def setup(name):
    global IMG, OV
    OV = next(o for o in OVLMAP['overlays'] if o['name'] == name)
    d = ovl_bytes(OV)
    IMG = d[OV['image']:]
    SEGS[:] = []
    for s in OV['segments']:
        s = dict(s)
        s['base'] = s['lin'] = (s['para'] - OV['para']) * 16      # base: offset 0 of the frame; lin: first byte
        s['end'] = s['lin'] + s['size']
        SEGS.append(s)
    RELOC.clear()
    for k in range(OV['relocs']):
        off, f = struct.unpack_from('<HH', d, 4 * k)
        RELOC.add((f - OV['para']) * 16 + off)
    o = OVERRIDES.get(name, {})
    DATA_LIN.clear(); CODE_LIN[:] = []; TABLE_LIN.clear(); TABLE_BYTES.clear()
    for a, b in o.get('data', []):
        DATA_LIN.update(range(a, b))
    for a in o.get('code', []):
        s = seg_at(a)
        CODE_LIN.append((a, s['para']))
    TABLE_LIN.update(o.get('tables', {}))
    prescan_tables()


def prescan_tables():
    """switch tables (jmp [cs:bx+disp] after a cmp bound): their words are data before any decoding starts, so a
    linear pass or a gap entry can never decode them as instructions"""
    for s in SEGS:
        for j in range(s['lin'], s['end'] - 5):
            if IMG[j] == 0x2E and IMG[j + 1] == 0xFF and IMG[j + 2] == 0xA7:
                lim = switch_limit(j)
                tlin = s['base'] + (IMG[j + 3] | IMG[j + 4] << 8)
                if lim and s['lin'] <= tlin and tlin + 2 * lim <= s['end'] and tlin not in TABLE_LIN:
                    TABLE_LIN[tlin] = lim
                    TABLE_BYTES.update(range(tlin, tlin + 2 * lim))


def CSB(cs):
    """image offset of paragraph cs"""
    return (cs - OV['para']) * 16


def seg_at(lin):
    for s in SEGS:
        if s['lin'] <= lin < s['end']:
            return s
    return None


def far_targets():
    """(para, off) of far calls/jumps and far pointers into this overlay: its own relocated words, the resident
    thunks, and far calls of other overlays that can be resident with it"""
    calls, ptrs = set(), set()
    lo, hi = OV['para'], OV['para'] + (len(IMG) + 15) // 16
    for r in RELOC:
        if r < 2 or r + 2 > len(IMG):
            continue
        segv = struct.unpack_from('<H', IMG, r)[0]
        offv = struct.unpack_from('<H', IMG, r - 2)[0]
        if not lo <= segv < hi:
            continue
        if r >= 3 and IMG[r - 3] in (0x9A, 0xEA):
            calls.add((segv, offv))
        else:
            ptrs.add((segv, offv))
    for t in OV.get('entries', []):
        calls.add((t[0], t[1]))
    return calls, ptrs


md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_16)
md.detail = True


class EmuIns:
    # an INT 34h..3Bh with the coprocessor instruction bytes that follow it (Microsoft C floating-point emulator)
    def __init__(self, lin, cs, fpu):
        self.size = 1 + fpu.size
        self.id = x86.X86_INS_INT
        self.groups = []
        self.operands = []
        self.mnemonic = 'int'
        self.bytes = IMG[lin:lin + self.size]
        self.fpu = fpu


def fpu_text(fpu):
    t = (fpu.mnemonic + ' ' + fpu.op_str).strip()
    return t.replace(' ptr ', ' ')


def decode(lin, cs):
    ip = lin - CSB(cs)
    code = IMG[lin:lin + 16]
    if len(code) >= 3 and code[0] == 0xCD and 0x34 <= code[1] <= 0x3B:
        fb = bytes([0xD8 + code[1] - 0x34]) + code[2:]
        for f in md.disasm(fb, 0, 1):
            return EmuIns(lin, cs, f)
    for ins in md.disasm(code, ip, 1):
        return ins
    return None


class Flow:
    def __init__(self):
        self.ins = {}          # lin -> (size, cs)
        self.labels = {}       # lin -> kind ('func', 'loc', 'data', 'tab')
        self.tables = {}       # lin -> count (jump tables of words)
        self.bad = set()

    def run(self, entries):
        work = list(entries)
        while work:
            lin, cs = work.pop()
            while True:
                if lin in self.ins or lin in self.bad or lin in DATA_LIN or lin in TABLE_BYTES:
                    break
                if not (0 <= lin < len(IMG)):
                    break
                ins = decode(lin, cs)
                if ins is None:
                    self.bad.add(lin)
                    break
                # overlap with existing instruction?
                if any((lin + k) in self.ins or (lin + k) in TABLE_BYTES for k in range(1, ins.size)) or \
                        any((lin - k) in self.ins and self.ins[lin - k][0] > k for k in range(1, 8)):
                    self.bad.add(lin)
                    break
                self.ins[lin] = (ins.size, cs)
                g = set(ins.groups)
                nxt = lin + ins.size
                m = ins.mnemonic
                if ins.id in (x86.X86_INS_JMP, x86.X86_INS_CALL) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and ins.bytes[0] in (0xE8, 0xE9, 0xEB):
                    t = CSB(cs) + (ins.operands[0].imm & 0xFFFF)
                    self.labels.setdefault(t, 'func' if ins.bytes[0] == 0xE8 else 'loc')
                    if ins.bytes[0] == 0xE8:
                        self.labels[t] = 'func'
                    work.append((t, cs))
                    if ins.bytes[0] != 0xE8:
                        break
                elif (capstone.CS_GRP_JUMP in g or ins.bytes[0] in (0xE0, 0xE1, 0xE2, 0xE3)) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and ins.id != x86.X86_INS_LJMP:
                    t = CSB(cs) + (ins.operands[0].imm & 0xFFFF)
                    self.labels.setdefault(t, 'loc')
                    work.append((t, cs))
                elif ins.id == x86.X86_INS_JMP:
                    # indirect: jump table jmp word [cs:bx+disp]?
                    self.jumptable(ins, lin, cs, work)
                    break
                elif ins.id in (x86.X86_INS_LJMP,):
                    if ins.bytes[0] == 0xEA:
                        pass
                    break
                if ins.id in (x86.X86_INS_RET, x86.X86_INS_RETF, x86.X86_INS_IRET, x86.X86_INS_HLT) and ins.id != x86.X86_INS_HLT:
                    break
                lin = nxt

    def jumptable(self, ins, lin, cs, work):
        b = ins.bytes
        # 2E FF A7 disp16  jmp [cs:bx+disp]   or  2E FF 67 d8
        if len(b) >= 5 and b[0] == 0x2E and b[1] == 0xFF and b[2] in (0xA7, 0xA6, 0xA4, 0xA5, 0xA0, 0xA1, 0xA2, 0xA3):
            disp = b[3] | (b[4] << 8)
            tlin = CSB(cs) + disp
            self.labels[tlin] = 'tab'
            n = 0
            seg = seg_at(lin)
            while tlin not in TABLE_LIN:
                p = tlin + 2 * n
                if p + 2 > len(IMG) or p in self.ins:
                    break
                v = struct.unpack_from('<H', IMG, p)[0]
                tl = CSB(cs) + v
                if not (seg['lin'] <= tl < seg['end'] + 16) or (tlin <= tl < tlin + 2 * (n + 1)):
                    break
                n += 1
                if n > 256:
                    break
            lim = switch_limit(lin)
            if lim is not None and lim < n:
                n = lim
            n = TABLE_LIN.get(tlin, n)
            self.tables[tlin] = max(n, 0)
            for k in range(n):
                v = struct.unpack_from('<H', IMG, tlin + 2 * k)[0]
                t = CSB(cs) + v
                self.labels.setdefault(t, 'loc')
                work.append((t, cs))


def switch_limit(jlin):
    """entries of a C switch table: the compiler bounds the index with cmp ax/bx, N then ja/jna to the default just
    before the indexed jump, so the table has N + 1 words"""
    b = IMG[max(jlin - 24, 0):jlin]
    best = None
    for k in range(len(b) - 2):
        if b[k] == 0x3D and k + 3 <= len(b):                       # cmp ax, imm16
            best = b[k + 1] | b[k + 2] << 8
        elif b[k] == 0x83 and b[k + 1] in (0xF8, 0xFB) and k + 3 <= len(b):   # cmp ax/bx, imm8
            best = b[k + 2]
        elif b[k] == 0x81 and b[k + 1] == 0xFB and k + 4 <= len(b):           # cmp bx, imm16
            best = b[k + 2] | b[k + 3] << 8
    return best + 1 if best is not None and best < 256 else None


def prologue_at(lin):
    b = IMG[lin:lin + 4]
    if len(b) >= 4 and b[0] == 0xC8 and b[3] == 0:
        return True
    if b[:3] in (b'\x55\x8b\xec', b'\x55\x89\xe5'):
        return True
    return False


def looks_text(b):
    pr = sum(1 for c in b if 32 <= c < 127 or c in (0, 10, 13, 36))
    return len(b) >= 6 and pr >= 0.9 * len(b)


def try_gap(flow, s, p, g1, cov):
    if p >= g1 or p in flow.bad or p in DATA_LIN or p in TABLE_BYTES or (looks_text(IMG[p:min(g1, p + 24)]) and not prologue_at(p)):
        return False
    if prologue_at(p):
        return True
    q, sus, term = p, 0, False
    while q < g1:
        ins = decode(q, s['para'])
        if ins is None or ins.mnemonic in ('db', '(bad)'):
            break
        if IMG[q:q + 2] == b'\x00\x00' or ins.mnemonic in ('hlt', 'into', 'aaa', 'aas', 'daa', 'das', 'lock', 'arpl', 'bound') and q != p:
            sus += 1
        if ins.mnemonic in ('in', 'out', 'insb', 'outsb', 'insw', 'outsw') and IMG[q] not in (0xE4, 0xE5, 0xE6, 0xE7, 0xEC, 0xED, 0xEE, 0xEF):
            sus += 1
        q += ins.size
        if ins.id in (x86.X86_INS_RET, x86.X86_INS_RETF, x86.X86_INS_IRET, x86.X86_INS_JMP, x86.X86_INS_LJMP):
            term = True
            break
    ok = term or (q == g1 and q in cov)
    return ok and sus <= 1 and q > p


def linear_gaps(flow, targets, final=False):
    # A gap that decodes cleanly up to a ret/jmp (or into known code) is taken as code. A gap that opens a frame
    # right after undecoded bytes waits for the final round: the instruction before it may run into the frame.
    new = []
    cov = set()
    for a, (sz, _) in flow.ins.items():
        cov.update(range(a, a + sz))
    for s in targets:
        lin = s['lin']
        while lin < s['end']:
            if lin in cov:
                lin += 1
                continue
            g0 = lin
            while lin < s['end'] and lin not in cov:
                lin += 1
            g1 = lin
            p = g0
            # skip padding nops/zeros at the start
            while p < g1 and IMG[p] in (0x90, 0x00, 0xCC):
                p += 1
            cands = [p] + [k for k in range(p + 1, g1) if IMG[k - 1] in (0xC3, 0xCB, 0xCF, 0x90) or
                           (k >= 3 and IMG[k - 3] in (0xC2, 0xCA))]
            for c in cands:
                if c == s['base'] and not final and (c - 1) not in cov and seg_at(c - 1) is not None:
                    break
                if try_gap(flow, s, c, g1, cov):
                    new.append((c, s['para']))
                    break
    return new


def nasm_map(top, wrap_include):
    d = tempfile.mkdtemp()
    w = os.path.join(d, 'wrap.asm')
    mp = os.path.join(d, 'map.txt')
    open(w, 'w').write(f'[map symbols {mp}]\n{wrap_include}\n')
    r = subprocess.run(['nasm', '-f', 'bin', '-I', os.path.join(ROOT, 'src') + '/', '-o', os.path.join(d, 'o.bin'), w],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode:
        return None
    out, sec = {}, None
    for line in open(mp):
        m = re.match(r'---- Section (\S+)', line)
        if m:
            sec = m.group(1)
            out.setdefault(sec, {})
            continue
        if line.startswith('---- No Section'):
            sec = None
            continue
        m = re.match(r'^([0-9A-F]+)\s+([0-9A-F]+)\s+(\S+)$', line.strip()) if sec else None
        if m and re.fullmatch(r'[A-Za-z_]\w*(\.[A-Za-z]\w*)?', m.group(3)):    # globals and named entries (Foo.regs)
            out[sec].setdefault(int(m.group(2), 16), m.group(3))
    return out


def read_map():
    """labels already given: {para: {offset: name}} for the root segments (full build) and this overlay's segments
    (its current source, when it assembles)"""
    rm = nasm_map(None, '%include "hockey94pc.asm"')
    if rm is None:
        sys.exit('the root build does not assemble')
    names = {s['name']: s['para'] for s in SEGMAP['segments'] if 'para' in s}
    out = {names[sec]: v for sec, v in rm.items() if sec in names}
    # overlays loaded beside this one (AI and INIT call into GAME, FADESn into FADES)
    host = {'AI': 'GAME', 'INIT': 'GAME'}.get(OV['name'], 'FADES' if OV['name'].startswith('FADES') and OV['name'] != 'FADES' else None)
    if host:
        hm = nasm_map(None, f'%include "ovl/{host.lower()}_build.asm"')
        hov = next(o for o in OVLMAP['overlays'] if o['name'] == host)
        for hs in hov['segments']:
            if hm and hs['name'] in hm:
                out[hs['para']] = hm[hs['name']]
    top = os.path.join(ROOT, 'src', 'ovl', OV['name'].lower() + '.asm')
    if os.path.exists(top):
        om = nasm_map(None, f'%include "ovl/{OV["name"].lower()}_build.asm"')
        if om:
            for s in SEGS:
                if s['name'] in om:
                    out[s['para']] = om[s['name']]
    return out


def ndis(seg_bytes, starts, skips):
    d = tempfile.mkdtemp()
    p = os.path.join(d, 'b.bin')
    open(p, 'wb').write(seg_bytes + bytes(16))     # ndisasm gives up on an instruction near the end of the file
    args = ['ndisasm', '-b', '16']
    for s in starts:
        args += ['-s', str(s)]
    for a, n in skips:
        args += ['-k', f'{a},{n}']
    args.append(p)
    r = subprocess.run(args, capture_output=True, text=True)
    out = {}
    cur = None
    for line in r.stdout.splitlines():
        m = re.match(r'^([0-9A-F]{8})\s+([0-9A-F]+)\s+(.*)$', line)
        if m:
            cur = int(m.group(1), 16)
            out[cur] = [m.group(2), m.group(3)]
        else:
            m = re.match(r'^\s+-([0-9A-F]+)', line)
            if m and cur is not None:
                out[cur][0] += m.group(1)
    return out


def nasm_bytes(lines):
    # Assemble each text line on its own (listing) and return the bytes of each.
    d = tempfile.mkdtemp()
    src = os.path.join(d, 't.asm')
    lst = os.path.join(d, 't.lst')
    with open(src, 'w') as f:
        f.write('\tbits 16\n')
        for l in lines:
            f.write('\t' + l + '\n')
    r = subprocess.run(['nasm', '-f', 'bin', '-o', os.path.join(d, 't.bin'), '-l', lst, src], capture_output=True, text=True)
    res = [None] * len(lines)
    if r.returncode:
        # find failing lines and retry without them
        badl = set()
        for m in re.finditer(r't\.asm:(\d+): error', r.stderr):
            badl.add(int(m.group(1)) - 2)
        if not badl:
            return res
        keep = [i for i in range(len(lines)) if i not in badl]
        sub = nasm_bytes([lines[i] for i in keep])
        for i, b in zip(keep, sub):
            res[i] = b
        return res
    cur = -1
    for line in open(lst):
        m = re.match(r'^\s*(\d+)\s+([0-9A-F]{8})\s+([0-9A-F]+)(-?)\s', line)
        if m:
            ln = int(m.group(1)) - 2
            if 0 <= ln < len(lines):
                res[ln] = (res[ln] or '') + m.group(3)
                cur = ln
            continue
        m = re.match(r'^\s*(\d+)\s+([0-9A-F]{8})\s+([0-9A-F]+)-?\s*$', line)
        if m and cur >= 0:
            res[cur] += m.group(3)
    return res


def h(v, w=0):
    return f'0x{v:0{w}X}'


def dbtext(bs):
    # bytes with runs of 4+ printable characters written as a quoted string
    parts, i = [], 0
    while i < len(bs):
        j = i
        while j < len(bs) and 32 <= bs[j] < 127 and bs[j] not in (39, 92):
            j += 1
        if j - i >= 4 or (j - i >= 2 and (j == len(bs) or bs[j] == 0) and (i == 0 or bs[i - 1] == 0)):
            parts.append("'" + bs[i:j].decode('ascii') + "'")
            i = j
        else:
            parts.append(h(bs[i], 2))
            i += 1
    return 'db\t' + ', '.join(parts)


def dbline(bs):
    return 'db\t' + ', '.join(h(b, 2) for b in bs)


def main(names):
    for n in names:
        setup(n)
        load_data()
        flow, funcs, targets = analyze()
        SEGST.clear()
        SEGST.update(seg_states(flow, funcs))
        known = read_map()
        for s in targets:
            emit(s, flow, funcs, known)
        write_top()
    if os.environ.get('GEN_OVL_MISS'):
        json.dump({f'{sg:04X}:{k:04X}': sorted(v) for (sg, k), v in sorted(MISS.items())},
                  open(os.environ['GEN_OVL_MISS'], 'w'), indent=0)


DG = 0x45C9
REG16 = {'ax': ('ax', 'al', 'ah', 'eax'), 'bx': ('bx', 'bl', 'bh', 'ebx'), 'cx': ('cx', 'cl', 'ch', 'ecx'),
         'dx': ('dx', 'dl', 'dh', 'edx'), 'si': ('si', 'esi'), 'di': ('di', 'edi')}


def seg_states(flow, funcs):
    """lin -> (ds, es) for each instruction: the paragraph each register is known to hold, or None. Every routine
    starts with DS = DGROUP (medium model) and ES unknown. Forward data flow over each routine's branches; a
    constant reaches DS or ES through mov reg,imm then mov sreg,reg, or push imm / pop sreg. Calls leave ES unknown."""
    import bisect
    starts = sorted(funcs)
    states = {}
    work = [(f, (DG, None, (), ())) for f in starts if f in flow.ins]
    seen = {}
    while work:
        lin, st = work.pop()
        while lin in flow.ins:
            old = seen.get(lin)
            if old is not None:
                merged = tuple(a if a == b else None for a, b in zip(old[:2], st[:2])) + \
                    (tuple(x for x in old[2] if x in st[2]), ())
                if merged == old:
                    break
                st = merged
            seen[lin] = st
            ds, es, regs, stack = st
            regs = dict(regs)
            sz, cs = flow.ins[lin]
            b = IMG[lin:lin + sz]
            ins = decode(lin, cs)
            if ins is None:
                break
            mn, ops = ins.mnemonic, ins.op_str
            dst = ops.split(',')[0].strip()
            stack = list(stack)
            if mn == 'mov' and dst in ('ds', 'es'):
                src = ops.split(',')[1].strip()
                v = regs.get(src) if src in REG16 else (ds if src == 'ds' else es if src == 'es' else
                                                        DG if src == 'ss' else None)
                if dst == 'ds':
                    ds = v
                else:
                    es = v
            elif mn == 'mov' and dst in REG16 and re.fullmatch(r'0x[0-9a-f]+|\d+', ops.split(',')[1].strip()):
                regs[dst] = int(ops.split(',')[1].strip(), 0)
            elif mn == 'mov' and dst in REG16 and ops.split(',')[1].strip() in ('ds', 'es', 'ss'):
                src = ops.split(',')[1].strip()
                regs[dst] = ds if src == 'ds' else es if src == 'es' else DG
            elif mn == 'push':
                v = None
                if re.fullmatch(r'0x[0-9a-f]+|\d+', dst):
                    v = int(dst, 0)
                elif dst in ('ds', 'ss', 'es'):
                    v = ds if dst == 'ds' else DG if dst == 'ss' else es
                elif dst in REG16:
                    v = regs.get(dst)
                stack = (stack + [v])[-4:]
            elif mn == 'pop':
                v = stack.pop() if stack else None
                if dst == 'ds':
                    ds = v if v is not None or b'\x1f' != b[:1] else DG     # a lone pop ds restores the caller's DS
                    if v is None and not stack:
                        ds = DG
                elif dst == 'es':
                    es = v
                elif dst in REG16:
                    regs.pop(dst, None)
            elif mn in ('les', 'lds'):
                if mn == 'les':
                    es = None
                else:
                    ds = None
                regs.pop(dst, None)
            elif mn in ('call', 'lcall'):
                es = None
                regs = {}
                stack = []
            else:
                for r, al in REG16.items():
                    if dst in al:
                        regs.pop(r, None)
                if mn in ('xchg',) and ',' in ops:
                    s2 = ops.split(',')[1].strip()
                    for r, al in REG16.items():
                        if s2 in al:
                            regs.pop(r, None)
            if mn in ('enter', 'leave') or dst in ('sp',):
                pass
            states[lin] = (seen[lin][0], seen[lin][1])
            nst = (ds, es, tuple(sorted(regs.items())), tuple(stack))
            nxt = lin + sz
            g = set(ins.groups)
            if ins.id in (x86.X86_INS_RET, x86.X86_INS_RETF, x86.X86_INS_IRET, x86.X86_INS_LJMP):
                break
            if ins.id == x86.X86_INS_JMP:
                if ins.operands and ins.operands[0].type == x86.X86_OP_IMM:
                    work.append((CSB(cs) + (ins.operands[0].imm & 0xFFFF), nst))
                break
            if (capstone.CS_GRP_JUMP in g or b[0] in (0xE0, 0xE1, 0xE2, 0xE3)) and ins.operands and \
                    ins.operands[0].type == x86.X86_OP_IMM:
                work.append((CSB(cs) + (ins.operands[0].imm & 0xFFFF), nst))
            lin, st = nxt, nst
    # jump table targets and anything else reached only indirectly keep the routine-start assumption
    for lin in flow.ins:
        states.setdefault(lin, (DG, None))
    return states


SEGST = {}       # lin -> (DS, ES) paragraphs known at that instruction
MISS = {}        # DGROUP offsets the overlays use that have no label yet (offset -> overlays)


def analyze():
    calls, ptrs = far_targets()
    flow = Flow()
    entries = []
    funcs = set()
    for segv, offv in calls | ptrs:
        s = next((x for x in SEGS if x['para'] == segv), None)
        if s is None:
            continue
        lin = s['base'] + offv
        if seg_at(lin) is None:
            continue
        if (segv, offv) in ptrs and (segv, offv) not in calls and not prologue_at(lin):
            continue
        entries.append((lin, segv))
        funcs.add(lin)
    for lin, segv in CODE_LIN:
        entries.append((lin, segv))
        funcs.add(lin)
    flow.run(entries)
    for a, _ in OVERRIDES.get(OV['name'], {}).get('data', []):
        if a not in TABLE_LIN:
            flow.labels.setdefault(a, 'data')
            funcs.add(a)
    targets = list(SEGS)
    GEN[:] = targets
    while True:
        new = linear_gaps(flow, targets)
        if not new:
            new = linear_gaps(flow, targets, final=True)
        for l, _ in new:
            funcs.add(l)
        if not new:
            break
        flow.run(sorted(new, reverse=True))     # lowest first: an instruction running into the next frame wins
    for l in list(funcs):
        if l in flow.bad and l not in flow.ins:
            funcs.discard(l)      # a gap start that turned out to be inside an instruction
            flow.labels.pop(l, None)
    for l in funcs:
        flow.labels[l] = 'func'
    for l, k in list(flow.labels.items()):
        if k == 'func':
            funcs.add(l)
    modules(flow)
    return flow, funcs, targets


def modules(flow):
    """A frame paragraph is where the linker's segment for the next module is numbered from, not where its first
    byte is: the last instruction of the module before can run into that paragraph. Each section starts after it."""
    for k in range(1, len(SEGS)):
        b = SEGS[k]['base']
        for a in range(b - 1, max(b - 16, 0), -1):
            if a in flow.ins and a + flow.ins[a][0] > b:
                SEGS[k]['lin'] = a + flow.ins[a][0]
                SEGS[k - 1]['end'] = SEGS[k]['lin']
                break


def lname(lin, flow, funcs, known, owner=None):
    s = seg_at(lin)
    if GEN and lin not in funcs and TOK:
        return f'@{lin}@'
    off = lin - s['base']
    k = known.get(s['para'], {})
    if off in k:
        return k[off]
    return f'{OV["name"].capitalize()}_{s["para"]:04X}_{off:04X}'


def far_name(sg, off, known):
    """the label of a far target outside this overlay (a root routine), or None. A root module can be called
    through a frame paragraph other than its own, so a miss is looked up by linear address."""
    n = known.get(sg, {}).get(off)
    if n or any(x['para'] == sg for x in SEGS):
        return n
    lin = sg * 16 + off
    for r in SEGMAP['segments']:
        if 'para' in r and r['para'] * 16 <= lin < r['para'] * 16 + r['size']:
            n = known.get(r['para'], {}).get(lin - r['para'] * 16)
            d = (sg - r['para']) * 16       # the label counts from its own module's paragraph
            return n and (f'{n} - 0x{d:X}' if d > 0 else f'{n} + 0x{-d:X}')
    return None


GEN = []
TOK = [1]
BR_SHORT = set(range(0x70, 0x80)) | {0xEB, 0xE0, 0xE1, 0xE2, 0xE3}


def branch_text(ins_bytes, text, target_name):
    b0 = ins_bytes[0]
    mn = text.split()[0]
    if b0 in BR_SHORT and len(ins_bytes) == 2:
        if b0 in (0xE0, 0xE1, 0xE2, 0xE3):
            return f'{mn}\t{target_name}'
        return f'{mn}\tshort {target_name}'
    if b0 == 0xE9 and len(ins_bytes) == 3:
        return f'jmp\tnear {target_name}'
    if b0 == 0xE8 and len(ins_bytes) == 3:
        return f'call\t{target_name}'
    if b0 == 0x0F and len(ins_bytes) == 4 and 0x80 <= ins_bytes[1] <= 0x8F:
        return f'{mn}\tnear {target_name}'
    return None


def strict_variant(t):
    # push word 0xa -> push strict word 0xa ; add ax, 0x5 -> add ax, strict word 0x5 ; byte +0x2 -> strict byte 0x2
    if re.search(r'\bbyte \+?(-?0x[0-9a-f]+)', t):
        return None
    m = re.match(r'^(\w+)\t(word|dword) (-?0x[0-9a-f]+|\d+)$', t)
    if m:
        return f'{m.group(1)}\tstrict {m.group(2)} {m.group(3)}'
    m = re.match(r'^(\w+)\t(.*), (word |byte )?(-?0x[0-9a-f]+|\d+)$', t)
    if m and '[' not in m.group(4):
        dst = m.group(2)
        w = 'byte' if re.fullmatch(r'[abcd][lh]', dst) or dst.startswith('byte') else 'word'
        return f'{m.group(1)}\t{dst}, strict {w} {m.group(4)}'
    return None


def fmt(text):
    p = text.split(None, 1)
    if len(p) == 1:
        return p[0]
    ops = p[1].replace(',', ', ')
    # ndisasm writes "word [bp+0x6]"; keep it, add spaces around + and - inside brackets
    ops = re.sub(r'\[([^\]]*)\]', lambda m: '[' + re.sub(r'(?<=\w)([+-])(?=\w)', r' \1 ', m.group(1)) + ']', ops)
    return f'{p[0]}\t{ops}'


DATA = {}


def load_data():
    """DGROUP labels of the root build: offset -> name"""
    m = nasm_map(None, '%include "hockey94pc.asm"') or {}
    dg = {}
    for sec in ('dgroup', 'dgroup_bss'):
        for off, nm in m.get(sec, {}).items():
            dg.setdefault(off, nm)
    DATA['dg'] = dg
    names = {x['name']: x['para'] for x in SEGMAP['segments'] if 'para' in x}
    DATA['far'] = {p: dict(m.get(sec, {})) for sec, p in names.items() if SEGMAP_FILE.get(sec, '').startswith('data/far/')}
    DATA['strings'] = {o for o, n in dg.items() if n.startswith('str_')}


def farptr_pairs(items, has_reloc):
    """A far pointer into a far data segment built from immediates: push SEG / push OFF, or mov word [m + 2], SEG
    next to mov word [m], OFF. The offset is written by its label in that segment."""
    def imm16(it):
        bs = it[3]
        if it[0] != 'ins':
            return None
        if bs[0] == 0x68 and len(bs) == 3:
            return 'push', None, bs[1] | bs[2] << 8
        m = re.fullmatch(r'mov\s+word \[([^\]]+)\], (?:strict word )?0x([0-9a-f]+)', it[2])
        if m and bs[0] == 0xC7:
            return 'mov', m.group(1), int(m.group(2), 16)
        return None

    def name(segv, off, it):
        t = DATA['far'][segv]
        if off in t:
            return t[off]
        MISS.setdefault((segv, off), set()).add(OV['name'] + ':ptr')
        return None

    def addr(text):
        m = re.fullmatch(r'(?:(bp) ([+-]) )?0x([0-9a-f]+)', text)
        if not m:
            return None
        v = int(m.group(3), 16) * (-1 if m.group(2) == '-' else 1)
        return (m.group(1), v)
    for k, it in enumerate(items):
        if it[0] == 'ins' and it[3] == b'\x1e' and SEGST.get(it[1], (DG, None))[0] == DG and k + 1 < len(items):
            b = imm16(items[k + 1])                     # push ds / push OFF: a far pointer into DGROUP
            if b and b[0] == 'push' and not has_reloc(k + 1) and b[2] >= 0x40:
                if b[2] in DATA['dg']:
                    items[k + 1][2] = f'push\tstrict word {DATA["dg"][b[2]]}'
                else:
                    MISS.setdefault((DG, b[2]), set()).add(OV['name'] + ':ptr')
            continue
        a = imm16(it)
        if not a or a[2] not in DATA['far'] or not has_reloc(k):
            continue
        segv = a[2]
        if a[0] == 'push':
            if k + 1 < len(items):
                b = imm16(items[k + 1])
                if b and b[0] == 'push' and not has_reloc(k + 1):
                    nm = name(segv, b[2], items[k + 1])
                    if nm:
                        items[k + 1][2] = f'push\tstrict word {nm}'
            continue
        hi = addr(a[1])
        if hi is None:
            continue
        for j in range(max(0, k - 3), min(len(items), k + 4)):
            b = imm16(items[j]) if j != k else None
            if b and b[0] == 'mov' and not has_reloc(j) and addr(b[1]) == (hi[0], hi[1] - 2):
                nm = name(segv, b[2], items[j])
                if nm:
                    items[j][2] = re.sub(r', (?:strict word )?0x[0-9a-f]+$', f', {nm}', items[j][2])
                break


def subst_data(items, s, funcs):
    # near operands that name DGROUP variables; immediates that are DGROUP strings; the DGROUP paragraph
    if not DATA or s['name'] in ('seg054', 'seg056', 'seg058'):
        return
    import bisect
    starts = sorted(funcs)
    dg = DATA['dg']

    def has_reloc(k):
        if k < 0 or k >= len(items) or items[k][0] in ('data', 'dw'):
            return False
        a = items[k][1]
        return any((a + j) in RELOC for j in range(len(items[k][3])))
    farptr_pairs(items, has_reloc)
    for idx, it in enumerate(items):
        if it[0] not in ('ins',):
            continue
        lin = it[1]
        t = it[2]
        if (lin + 1) in RELOC and re.search(r'\b0x45c9\b', t):
            it[2] = re.sub(r'\b0x45c9\b', 'DGROUP', t)
            continue
        dsv, esv = SEGST.get(lin, (DG, None))
        if re.search(r'\bcs:', t):
            continue

        def table(segv):
            return dg if segv == DG else DATA['far'].get(segv)

        def mem(m):
            inner = m.group(1)
            mm = re.fullmatch(r'(?:(ds|ss|es):)?((?:(?:bx|si|di|bp)(?: \+ (?:si|di))?) [+-] )?0x([0-9a-f]+)', inner)
            if not mm:
                return m.group(0)
            ov, base = mm.group(1), mm.group(2)
            if base and 'bp' in base and ov is None:
                return m.group(0)                       # [bp + n] is the stack frame
            segv = DG if ov == 'ss' else esv if ov == 'es' else dsv
            v = int(mm.group(3), 16)
            if base and base.endswith('- '):
                v = (-v) & 0xFFFF
            t = table(segv) if segv is not None else None
            if t is None:
                return m.group(0)
            lo = 0x40 if not base else (0x100 if segv == DG else 0x40)
            pre = (ov + ':') if ov else ''
            if v >= lo and v in t:
                return f'[{pre}{base[:-2] + "+ " if base else ""}{t[v]}]'
            if v >= lo:
                MISS.setdefault((segv, v), set()).add(OV['name'] + (':indexed' if base else ''))
            return m.group(0)
        t2 = re.sub(r'\[([^\]]+)\]', mem, t)
        mm = None       # immediates stay numbers: a value equal to a DGROUP address is often a constant
        near_reloc = has_reloc(idx) or has_reloc(idx - 1) or has_reloc(idx + 1) or \
            (idx > 0 and items[idx - 1][3] == b'\x0e')
        if mm and len(it[3]) >= 3 and not near_reloc:
            v = int(mm.group(3), 16)
            if v in DATA['strings'] and v in dg:
                t2 = f'{mm.group(1)}\t{mm.group(2) or ""}{dg[v]}'
        it[2] = t2


def resolve(lines, flow):
    # @lin@ tokens: local labels .N numbered inside the scope of the last global label; a jump table is
    # <Scope>JumpTable. A reference from another scope is written Scope.N.
    scope = base = None
    defs = {}
    count = {}
    for i, l in enumerate(lines):
        m = re.match(r'^@(\d+)@:$', l)
        if m:
            lin = int(m.group(1))
            if flow.labels.get(lin) == 'tab' and scope:
                n = count.get((base, 'T'), 0) + 1
                count[(base, 'T')] = n
                defs[lin] = (None, f'{base}JumpTable' + ('' if n == 1 else str(n)))
                scope = defs[lin][1]
                continue
            if scope is None:
                defs[lin] = (None, f'SegStart_{lin:05X}')
                scope = base = defs[lin][1]
                continue
            n = count.get(scope, 0) + 1
            count[scope] = n
            defs[lin] = (scope, f'.{n}')
            continue
        m = re.match(r'^([A-Za-z_][\w]*):$', l)
        if m:
            scope = base = m.group(1)
    out = []
    scope = None
    for l in lines:
        m = re.match(r'^@(\d+)@:$', l)
        if m:
            sc, nm = defs[int(m.group(1))]
            if sc is None:
                scope = nm
            out.append(nm + ':')
            continue
        m = re.match(r'^([A-Za-z_][\w]*):$', l)
        if m:
            scope = m.group(1)

        def rep(mm):
            sc, nm = defs[int(mm.group(1))]
            if sc is None or sc == scope:
                return nm
            return sc + nm
        out.append(re.sub(r'@(\d+)@', rep, l))
    return out


def emit(s, flow, funcs, known):
    lo, hi = s['lin'], s['end']
    sb = IMG[lo:hi]
    s_para = s['para']
    # instruction starts inside the segment that fit entirely
    starts, inside = [], {}
    for lin in range(lo, hi):
        if lin in flow.ins:
            sz = flow.ins[lin][0]
            if lin + sz <= hi:
                starts.append(lin - lo)
                inside[lin] = sz
    # bytes covered
    cov = bytearray(hi - lo)
    for lin, sz in inside.items():
        for k in range(sz):
            cov[lin - lo + k] = 1
    skips = []
    i = 0
    while i < len(cov):
        if not cov[i]:
            j = i
            while j < len(cov) and not cov[j]:
                j += 1
            skips.append((i, j - i))
            i = j
        else:
            i += 1
    nd = ndis(sb, starts, skips)
    # first pass: candidate lines
    items = []   # (kind, lin, text, bytes)
    lin = lo
    tabs = {t: n for t, n in flow.tables.items() if lo <= t < hi}
    while lin < hi:
        if lin in inside:
            sz = inside[lin]
            hx, txt = nd.get(lin - lo, (None, None))
            bs = IMG[lin:lin + sz]
            e = decode(lin, s['para'])
            if isinstance(e, EmuIns) and e.size == sz:
                items.append(['emu', lin, f'int\t0x{bs[1]:02x}\n\t{dbline(bs[2:])}\t\t; emulated {fpu_text(e.fpu)}', bs, None])
                lin += sz
                continue
            if hx is None or bytes.fromhex(hx) != bs:
                items.append(['db', lin, f'{dbline(bs)}', bs, txt])
            else:
                items.append(['ins', lin, txt, bs, txt])
            lin += sz
            continue
        if lin in tabs and tabs[lin] > 0:
            n = tabs[lin]
            cs = s['para']
            ok = all(not cov[lin - lo + k] for k in range(2 * n)) and lin + 2 * n <= hi
            if ok:
                for k in range(n):
                    v = struct.unpack_from('<H', IMG, lin + 2 * k)[0]
                    items.append(['dw', lin + 2 * k, v, IMG[lin + 2 * k:lin + 2 * k + 2], None])
                lin += 2 * n
                continue
        # data run until next instruction/label/table
        j = lin + 1
        while j < hi and j not in inside and j not in flow.labels and j not in tabs and ((j - lin) < 16 or (32 <= IMG[j] < 127 and (j - lin) < 64)):
            j += 1
        items.append(['data', lin, None, IMG[lin:j], None])
        lin = j
    starts_set = {it[1] for it in items}
    gen = {x['name'] for x in GEN}

    def can_label(t):
        ts = seg_at(t)
        if ts is None:
            return False
        return t in starts_set if ts is s else (t in funcs)
    # verify ndisasm text for non-branch instructions
    chk = []
    for it in items:
        if it[0] != 'ins':
            continue
        bs = it[3]
        ins = decode(it[1], s['para'])
        tgt = None
        if ins is not None and (capstone.CS_GRP_JUMP in ins.groups or ins.id == x86.X86_INS_CALL or bs[0] in (0xE0, 0xE1, 0xE2, 0xE3)) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and bs[0] not in (0x9A, 0xEA):
            tgt = s['base'] + (ins.operands[0].imm & 0xFFFF)
            tname = lname(tgt, flow, funcs, known) if (seg_at(tgt) is s and can_label(tgt)) else None
            t = branch_text(bs, it[2], tname) if tname else None
            if t is None:
                it[0] = 'db'; it[2] = dbline(bs)
            else:
                it[2] = t; it[0] = 'br'
            continue
        if bs[0] in (0x9A, 0xEA) and len(bs) == 5:
            off = bs[1] | bs[2] << 8
            sg = bs[3] | bs[4] << 8
            mn = 'call' if bs[0] == 0x9A else 'jmp'
            nm = None
            if (it[1] + 3) in RELOC:
                own = next((x for x in SEGS if x['para'] == sg), None)
                if own is not None:
                    tl = own['base'] + off
                    ts = seg_at(tl)
                    nm = lname(tl, flow, funcs, known) if (tl in funcs or tl in starts_set) and ts and \
                        ts['base'] == own['base'] else None
                else:
                    nm = far_name(sg, off, known)
            it[2] = f'{mn}\t{h(sg, 4)}:{nm}' if nm else f'{mn}\t{h(sg, 4)}:{h(off)}'
            it[0] = 'far'
            continue
        raw = fmt(it[2])
        it[2] = re.sub(r'\bbyte ([+-])0x', lambda m: ('-' if m.group(1) == '-' else '') + '0x', raw)
        it.append(raw)
        chk.append(it)
    got = nasm_bytes([it[2] for it in chk])
    retry = []
    for it, g in zip(chk, got):
        if g is None or bytes.fromhex(g) != it[3]:
            alt = it[5] if len(it) > 5 and it[5] != it[2] else strict_variant(it[2])
            if alt:
                retry.append((it, alt))
    got2 = nasm_bytes([a for _, a in retry])
    for (it, alt), g in zip(retry, got2):
        if g is not None and bytes.fromhex(g) == it[3]:
            it[2] = alt
    for it, g in zip(chk, got):
        if (g is None or bytes.fromhex(g) != it[3]) and not any(r[0] is it and r[1] == it[2] for r in retry):
            it[4] = it[2].replace('\t', ' ')
            it[2] = dbline(it[3])
            it[0] = 'db'
    subst_data(items, s, funcs)
    # write
    out = [f'; {OV["name"]}.OVL segment {s["name"]}: generated by tools/disasm/gen_ovl.py; names and comments still to do.']
    for it in items:
        lin = it[1]
        if lin in flow.labels or lin in funcs or lin in tabs:
            if lin != lo or lin in funcs or lin in flow.labels:
                nm = lname(lin, flow, funcs, known)
                if lin in funcs:
                    out.append('')
                out.append(f'{nm}:')
        if it[0] in ('ins', 'br', 'far', 'emu'):
            out.append('\t' + it[2])
        elif it[0] == 'db':
            c = it[4]
            out.append('\t' + it[2] + (f'\t\t; {c}' if c else ''))
        elif it[0] == 'dw':
            v = it[2]
            t = s['base'] + v
            if seg_at(t) is s and t in starts_set:
                out.append(f'\tdw\t{lname(t, flow, funcs, known)}')
            else:
                out.append(f'\tdw\t{h(v, 4)}')
        else:
            out.append('\t' + dbtext(it[3]))
    out = resolve(out, flow)
    path = os.path.join(ROOT, 'src', s['file'])
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w').write('\n'.join(out) + '\n')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    nins = sum(1 for it in items if it[0] in ('ins', 'br', 'far'))
    ndb = sum(len(it[3]) for it in items if it[0] == 'data')
    print(f'{s["name"]}: {nins} instructions, {sum(1 for it in items if it[0]=="db")} db-instructions, {ndb} data bytes of {s["size"]}')




def write_top():
    """src/ovl/<name>.asm: the relocation table, then one section per segment; src/ovl/<name>_build.asm wraps it
    with the outside labels it uses (src/ovl/<name>_syms.inc, tools/make_ovl_syms.py)"""
    lo = OV['name'].lower()
    d = ovl_bytes(OV)
    out = [f'; {OV["name"]}.OVL: RTLink overlay, loaded at paragraph {OV["para"]:04X}h. Files: docs/cleanup/files_94pc_ovl.txt.',
           f'; {OV["relocs"]} relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.',
           f'section {lo}_relocs start=0']
    for k in range(0, OV['relocs'], 4):
        ent = [struct.unpack_from('<HH', d, 4 * j) for j in range(k, min(k + 4, OV['relocs']))]
        out.append('        dw ' + ', '.join(f'0x{a:04X}, 0x{b:04X}' for a, b in ent))
    prev = f'{lo}_relocs'
    for k, s in enumerate(SEGS):
        al = 16 if k == 0 else 1
        out.append(f'section {s["name"]} follows={prev} align={al} vstart=0x{s["lin"] - s["base"]:X}')
        out.append(f'%include "{s["file"]}"')
        prev = s['name']
    open(os.path.join(ROOT, 'src', 'ovl', lo + '.asm'), 'w').write('\n'.join(out) + '\n')
    b = os.path.join(ROOT, 'src', 'ovl', lo + '_build.asm')
    syms = os.path.join(ROOT, 'src', 'ovl', lo + '_syms.inc')
    if not os.path.exists(syms):
        open(syms, 'w').write('')
    open(b, 'w').write(f'; Builds {OV["name"]}.OVL on its own: the outside labels it uses (from tools/make_ovl_syms.py), then the overlay.\n'
                       f'        bits 16\n%include "spa94.inc"\n%include "ovl/{lo}_syms.inc"\n%include "ovl/{lo}.asm"\n')


if __name__ == '__main__':
    main(sys.argv[1:])
