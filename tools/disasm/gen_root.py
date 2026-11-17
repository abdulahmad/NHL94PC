#!/usr/bin/env python3
# gen_root.py: turn incbin segments of the root (load image) into NASM source that rebuilds the same bytes.
#   python3 tools/disasm/gen_root.py seg006 [seg007 ...]
# Code is found by recursive descent from every far call and relocated far pointer in the EXE, plus function
# prologues in what is left. Everything else is emitted as db. Instruction text comes from ndisasm; any line whose
# encoding NASM would change is written as db with the text as a comment. The caller rebuilds and checks MATCH.
import json, os, re, struct, subprocess, sys, tempfile
import capstone
from capstone import x86

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SEGMAP = json.load(open(os.path.join(ROOT, 'segmap.json')))
EXE = open(os.path.join(ROOT, 'lst', 'HOCKEY.EXE'), 'rb').read()
HDR = 0x1C00
IMG_END = 0x20047
IMG = EXE[HDR:IMG_END]
SEGS = [s for s in SEGMAP['segments'] if 'para' in s and s['name'].startswith('seg')]
for s in SEGS:
    s['lin'] = s['para'] * 16
    s['end'] = s['lin'] + s['size']


def seg_at(lin):
    for s in SEGS:
        if s['lin'] <= lin < s['end']:
            return s
    return None


def relocs():
    n = struct.unpack_from('<H', EXE, 6)[0]
    t = struct.unpack_from('<H', EXE, 0x18)[0]
    out = set()
    for i in range(n):
        o, sg = struct.unpack_from('<HH', EXE, t + 4 * i)
        out.add(sg * 16 + o)
    return out


RELOC = relocs()


def dyn_far_refs():
    # Relocation entries of the in-EXE dynamic segment (file 0x20050, 1156 entries). Return far (seg, off) words found.
    base_file = 0x20050
    n = 1156
    img_file = base_file + n * 4
    load_lin = 0x3415 * 16
    refs = []
    for i in range(n):
        o, sg = struct.unpack_from('<HH', EXE, base_file + 4 * i)
        lin = sg * 16 + o
        f = img_file + (lin - load_lin)
        if f < img_file + 2 or f + 2 > len(EXE):
            continue
        segv = struct.unpack_from('<H', EXE, f)[0]
        offv = struct.unpack_from('<H', EXE, f - 2)[0]
        op = EXE[f - 3] if f >= 3 else 0
        refs.append((segv, offv, op == 0x9A))
    return refs


def far_targets():
    calls, ptrs = set(), set()
    for r in RELOC:
        if r < 2 or r + 2 > len(IMG):
            continue
        segv = struct.unpack_from('<H', IMG, r)[0]
        offv = struct.unpack_from('<H', IMG, r - 2)[0]
        if r >= 3 and IMG[r - 3] in (0x9A, 0xEA):
            calls.add((segv, offv))
        else:
            ptrs.add((segv, offv))
    for segv, offv, iscall in dyn_far_refs():
        (calls if iscall else ptrs).add((segv, offv))
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
    ip = lin - cs * 16
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
                if lin in self.ins or lin in self.bad:
                    break
                if not (0 <= lin < len(IMG)):
                    break
                ins = decode(lin, cs)
                if ins is None:
                    self.bad.add(lin)
                    break
                # overlap with existing instruction?
                if any((lin + k) in self.ins for k in range(1, ins.size)):
                    self.bad.add(lin)
                    break
                self.ins[lin] = (ins.size, cs)
                g = set(ins.groups)
                nxt = lin + ins.size
                m = ins.mnemonic
                if ins.id in (x86.X86_INS_JMP, x86.X86_INS_CALL) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and ins.bytes[0] in (0xE8, 0xE9, 0xEB):
                    t = cs * 16 + (ins.operands[0].imm & 0xFFFF)
                    self.labels.setdefault(t, 'func' if ins.bytes[0] == 0xE8 else 'loc')
                    if ins.bytes[0] == 0xE8:
                        self.labels[t] = 'func'
                    work.append((t, cs))
                    if ins.bytes[0] != 0xE8:
                        break
                elif (capstone.CS_GRP_JUMP in g or ins.bytes[0] in (0xE0, 0xE1, 0xE2, 0xE3)) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and ins.id != x86.X86_INS_LJMP:
                    t = cs * 16 + (ins.operands[0].imm & 0xFFFF)
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
            tlin = cs * 16 + disp
            self.labels[tlin] = 'tab'
            n = 0
            seg = seg_at(lin)
            while True:
                p = tlin + 2 * n
                if p + 2 > len(IMG) or p in self.ins:
                    break
                v = struct.unpack_from('<H', IMG, p)[0]
                tl = cs * 16 + v
                if not (seg['lin'] <= tl < seg['end'] + 16) or (tlin <= tl < tlin + 2 * (n + 1)):
                    break
                n += 1
                if n > 256:
                    break
            # cap at the nearest following code
            self.tables[tlin] = max(n, 0)
            for k in range(n):
                v = struct.unpack_from('<H', IMG, tlin + 2 * k)[0]
                t = cs * 16 + v
                self.labels.setdefault(t, 'loc')
                work.append((t, cs))


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
    if p >= g1 or p in flow.bad or (looks_text(IMG[p:min(g1, p + 24)]) and not prologue_at(p)):
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


def linear_gaps(flow, targets):
    # A gap that decodes cleanly up to a ret/jmp (or into known code) is taken as code.
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
                if try_gap(flow, s, c, g1, cov):
                    new.append((c, s['para']))
                    break
    return new


def read_map():
    # Labels the current build already has: section -> {offset: name}. Built from a NASM map of the full build.
    import shutil
    d = tempfile.mkdtemp()
    src = os.path.join(d, 'src')
    shutil.copytree(os.path.join(ROOT, 'src'), src)
    for t in GEN:
        open(os.path.join(src, t['file']), 'w').write(f'\tincbin\t"Extracted/segments/{t["name"]}.bin"\n')
    w = os.path.join(d, 'wrap.asm')
    mp = os.path.join(d, 'map.txt')
    open(w, 'w').write(f'[map symbols {mp}]\n%include "hockey94pc.asm"\n')
    r = subprocess.run(['nasm', '-f', 'bin', '-I', src + '/', '-o', os.path.join(d, 'o.bin'), w],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode:
        sys.exit(r.stderr)
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
        if m:
            name = m.group(3)
            if '.' in name:
                continue
            out[sec].setdefault(int(m.group(2), 16), name)
    return out


def ndis(seg_bytes, starts, skips):
    d = tempfile.mkdtemp()
    p = os.path.join(d, 'b.bin')
    open(p, 'wb').write(seg_bytes)
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
    load_data()
    flow, funcs, targets = analyze(names)
    known = read_map()
    for s in targets:
        emit(s, flow, funcs, known)


def analyze(names):
    calls, ptrs = far_targets()
    flow = Flow()
    entries = []
    funcs = set()
    for segv, offv in calls | ptrs:
        lin = segv * 16 + offv
        s = seg_at(lin)
        if s is None:
            continue
        if (segv, offv) in ptrs and (segv, offv) not in calls and not prologue_at(lin):
            continue
        entries.append((lin, segv))
        funcs.add(lin)
    flow.run(entries)
    targets = [s for s in SEGS if s['name'] in names]
    GEN[:] = targets
    # gaps: a gap whose first byte (after padding) is a prologue, or that decodes cleanly to a ret/jmp, is code
    while True:
        new = linear_gaps(flow, targets)
        for l, _ in new:
            funcs.add(l)
        if not new:
            break
        flow.run(new)
    for l in funcs:
        flow.labels[l] = 'func'
    for l, k in list(flow.labels.items()):
        if k == 'func':
            funcs.add(l)
    return flow, funcs, targets


def lname(lin, flow, funcs, known, owner=None):
    s = seg_at(lin)
    if GEN and s in GEN and lin not in funcs and (s['lin'] + 0) != -1 and TOK:
        return f'@{lin}@'
    off = lin - s['lin']
    k = known.get(s['name'], {})
    if off in k:
        return k[off]
    sn = s['name'][3:]
    if lin in funcs or flow.labels.get(lin) == 'data':
        return f'F{sn}_{off:04X}'
    kind = flow.labels.get(lin)
    if kind == 'tab':
        base = f'T{sn}_{off:04X}'
        return base
    return f'L{sn}_{off:04X}'


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
    p = os.path.join(ROOT, 'tools', 'disasm', 'data_labels.json')
    if not os.path.exists(p):
        return
    d = json.load(open(p))
    DATA['dg'] = {int(k): v for k, v in d['dgroup'].items()}
    DATA['strings'] = set(d['strings'])
    DATA['unsafe'] = set(d['unsafe'])


def subst_data(items, s, funcs):
    # near operands that name DGROUP variables; immediates that are DGROUP strings; the DGROUP paragraph
    if not DATA or s['name'] in ('seg054', 'seg056', 'seg058'):
        return
    import bisect
    starts = sorted(funcs)
    dg = DATA['dg']
    for it in items:
        if it[0] not in ('ins',):
            continue
        lin = it[1]
        i = bisect.bisect_right(starts, lin) - 1
        if i >= 0 and starts[i] in DATA['unsafe']:
            continue
        t = it[2]
        if (lin + 1) in RELOC and re.search(r'\b0x45c9\b', t):
            it[2] = re.sub(r'\b0x45c9\b', 'DGROUP', t)
            continue
        if re.search(r'\b(es|cs):', t):
            continue

        def mem(m):
            inner = m.group(1)
            mm = re.fullmatch(r'(?:(ds|ss):)?0x([0-9a-f]+)', inner)
            if mm:
                v = int(mm.group(2), 16)
                if v >= 0x40 and v in dg:
                    return '[' + (mm.group(1) + ':' if mm.group(1) else '') + dg[v] + ']'
                return m.group(0)
            mm = re.fullmatch(r'((?:bx|si|di)(?: \+ (?:si|di))?) \+ 0x([0-9a-f]+)', inner)
            if mm:
                v = int(mm.group(2), 16)
                if v >= 0x100 and v in dg:
                    return f'[{mm.group(1)} + {dg[v]}]'
            return m.group(0)
        t2 = re.sub(r'\[([^\]]+)\]', mem, t)
        mm = re.fullmatch(r'(push|mov)\t((?:[abcd]x|si|di|word \[[^\]]+\]), )?(?:word )?0x([0-9a-f]+)', t2)
        if mm and len(it[3]) >= 3:
            v = int(mm.group(3), 16)
            if v in DATA['strings'] and v in dg:
                t2 = f'{mm.group(1)}\t{mm.group(2) or ""}{dg[v]}'
        it[2] = t2


def resolve(lines, flow):
    # @lin@ tokens: local labels .N numbered inside the scope of the last global label; a jump table is
    # <Scope>JumpTable. A reference from another scope is written Scope.N.
    scope = None
    defs = {}
    count = {}
    for i, l in enumerate(lines):
        m = re.match(r'^@(\d+)@:$', l)
        if m:
            lin = int(m.group(1))
            if flow.labels.get(lin) == 'tab' and scope:
                n = count.get((scope, 'T'), 0) + 1
                count[(scope, 'T')] = n
                defs[lin] = (None, f'{scope}JumpTable' + ('' if n == 1 else str(n)))
                scope = defs[lin][1]
                continue
            if scope is None:
                defs[lin] = (None, f'SegStart_{lin:05X}')
                scope = defs[lin][1]
                continue
            n = count.get(scope, 0) + 1
            count[scope] = n
            defs[lin] = (scope, f'.{n}')
            continue
        m = re.match(r'^([A-Za-z_][\w]*):$', l)
        if m:
            scope = m.group(1)
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
        if ts['name'] in gen:
            return t in starts_set if ts is s else (t in funcs)
        return (t - ts['lin']) in known.get(ts['name'], {})
    # verify ndisasm text for non-branch instructions
    chk = []
    for it in items:
        if it[0] != 'ins':
            continue
        bs = it[3]
        ins = decode(it[1], s['para'])
        tgt = None
        if ins is not None and (capstone.CS_GRP_JUMP in ins.groups or ins.id == x86.X86_INS_CALL or bs[0] in (0xE0, 0xE1, 0xE2, 0xE3)) and ins.operands and ins.operands[0].type == x86.X86_OP_IMM and bs[0] not in (0x9A, 0xEA):
            tgt = s['lin'] + (ins.operands[0].imm & 0xFFFF)
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
            tl = sg * 16 + off
            ts = seg_at(tl)
            mn = 'call' if bs[0] == 0x9A else 'jmp'
            if ts is not None and (lo + (it[1] - lo) + 3) in RELOC:
                nm = lname(tl, flow, funcs, known) if can_label(tl) else None
                if nm and tl - sg * 16 == tl - ts['lin']:
                    it[2] = f'{mn}\t{h(sg, 4)}:{nm}'
                else:
                    it[2] = f'{mn}\t{h(sg, 4)}:{h(off)}'
            else:
                it[2] = f'{mn}\t{h(sg, 4)}:{h(off)}'
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
    out = [f'; Segment {s["name"]}: generated by tools/disasm/gen_root.py; names and comments still to do.']
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
            t = s['lin'] + v
            if seg_at(t) is s and t in starts_set:
                out.append(f'\tdw\t{lname(t, flow, funcs, known)}')
            else:
                out.append(f'\tdw\t{h(v, 4)}')
        else:
            out.append('\t' + dbtext(it[3]))
    out = resolve(out, flow)
    path = os.path.join(ROOT, 'src', s['file'])
    open(path, 'w').write('\n'.join(out) + '\n')
    nins = sum(1 for it in items if it[0] in ('ins', 'br', 'far'))
    ndb = sum(len(it[3]) for it in items if it[0] == 'data')
    print(f'{s["name"]}: {nins} instructions, {sum(1 for it in items if it[0]=="db")} db-instructions, {ndb} data bytes of {s["size"]}')


if __name__ == '__main__':
    main(sys.argv[1:])
