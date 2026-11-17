#!/usr/bin/env python3
# gen_data.py: write the source for the bytes after the DOS load module: the relocation table of the RTLink segment
# stored in HOCKEY.EXE, its far data segments, and DGROUP (initialized data, then the BSS as a nobits section).
# Labels go where the code refers to an address; names come from the hand segments' equates, from string text, or a
# placeholder until the naming pass. Writes tools/disasm/data_labels.json for gen_root.py (operand names).
#   python3 tools/disasm/gen_data.py
import collections, json, os, re, struct, sys
sys.path.insert(0, os.path.dirname(__file__))
import gen_root as g
from capstone import x86

ROOT = g.ROOT
EXE = g.EXE
RELOC_FILE = 0x20050
NREL = 1156
IMG_FILE = RELOC_FILE + NREL * 4
LOAD = 0x3415
DGROUP = 0x45C9
DG_FILE = IMG_FILE + (DGROUP - LOAD) * 16
DG_INIT = len(EXE) - DG_FILE            # bytes of DGROUP stored in the file
DG_SIZE = 8555 * 16 - (DGROUP - LOAD) * 16   # memory the record reserves from DGROUP on
HAND = ['seg000', 'seg001', 'seg002', 'seg004']
NOT_DG = {'VgaGc', 'VgaGcData', 'VgaSeq', 'VgaSeqData', 'VgaAttr', 'VgaCrtc', 'VgaStatus', 'VgaMem', 'DGROUP', 'GamePort'}
SKIP_SEGS = {'seg054', 'seg056', 'seg058'}


def existing_labels():
    # names already in src/data/dgroup*.asm (kept when this is run again)
    out = collections.OrderedDict()
    try:
        known = g.read_map()
    except SystemExit:
        return out
    cm = {}
    for f in ('dgroup.asm', 'dgroup_bss.asm'):
        p = os.path.join(ROOT, 'src', 'data', f)
        if os.path.exists(p):
            for line in open(p):
                m = re.match(r'^(\w+):\s*;\s*(.*)$', line.rstrip())
                if m:
                    cm[m.group(1)] = m.group(2)
    for sec in ('dgroup', 'dgroup_bss'):
        for off, name in known.get(sec, {}).items():
            if name != 'exe_end' and not re.match(r'^(g_[0-9A-F]{4}|str_\w+)$', name):
                out.setdefault(off, []).append((name, cm.get(name, '')))
    return out


def hand_equs():
    out = existing_labels()
    for sname in HAND:
        path = os.path.join(ROOT, 'src', 'seg', sname + '.asm')
        for line in open(path):
            m = re.match(r'^(\w+)\s+equ\s+(0x[0-9A-Fa-f]+|\d+)\s*(;.*)?$', line.rstrip('\n'))
            if m and m.group(1) not in NOT_DG:
                v = int(m.group(2), 0)
                out.setdefault(v, [])
                if m.group(1) not in [n for n, _ in out[v]]:
                    out[v].append((m.group(1), (m.group(3) or '').lstrip('; ').strip()))
    return out


def writes_ds(ins):
    if ins.id == x86.X86_INS_LDS:
        return True
    if ins.id == x86.X86_INS_POP and ins.operands and ins.operands[0].type == x86.X86_OP_REG and ins.operands[0].reg == x86.X86_REG_DS:
        return True
    if ins.id == x86.X86_INS_MOV and ins.operands and ins.operands[0].type == x86.X86_OP_REG and ins.operands[0].reg == x86.X86_REG_DS:
        return True
    return False


def unsafe_routines(flow, funcs):
    # routines (from one func label to the next) that load DS themselves; their near operands are not DGROUP names
    starts = sorted(funcs)
    bad = set()
    import bisect
    for lin, (sz, cs) in flow.ins.items():
        ins = g.decode(lin, cs)
        if ins is not None and writes_ds(ins):
            i = bisect.bisect_right(starts, lin) - 1
            if i >= 0:
                bad.add(starts[i])
    return starts, bad


def routine_of(starts, lin):
    import bisect
    i = bisect.bisect_right(starts, lin) - 1
    return starts[i] if i >= 0 else None


def dg_byte(o):
    return EXE[DG_FILE + o] if o < DG_INIT else None


def is_string_start(o):
    if o >= DG_INIT or o == 0:
        return False
    if EXE[DG_FILE + o - 1] not in (0, 10, 13):
        return False
    n = 0
    while o + n < DG_INIT and 32 <= EXE[DG_FILE + o + n] < 127 or (o + n < DG_INIT and EXE[DG_FILE + o + n] in (9, 10, 13)):
        n += 1
    return n >= 3 and o + n < DG_INIT and EXE[DG_FILE + o + n] == 0


def string_name(o, used):
    n = 0
    s = b''
    while EXE[DG_FILE + o + n] != 0:
        s += bytes([EXE[DG_FILE + o + n]])
        n += 1
    words = re.findall(rb'[A-Za-z0-9]+', s)
    base = 'str_' + (''.join(w.decode().capitalize() if not w.isdigit() else w.decode() for w in words[:5]) or 'Sym')
    base = base[:40]
    nm, k = base, 2
    while nm in used:
        nm = f'{base}_{k}'
        k += 1
    used.add(nm)
    return nm


def collect(flow, funcs):
    starts, bad = unsafe_routines(flow, funcs)
    okset = g.ds_states(flow, funcs)
    mem = collections.defaultdict(set)   # offset -> sizes
    strs = set()
    for lin, (sz, cs) in flow.ins.items():
        s = g.seg_at(lin)
        if s is None or s['name'] in SKIP_SEGS:
            continue
        dsok = lin in okset
        ins = g.decode(lin, cs)
        if ins is None:
            continue
        for op in ins.operands:
            if op.type == x86.X86_OP_MEM and (op.mem.segment == x86.X86_REG_SS or dsok and op.mem.segment in (0, x86.X86_REG_DS)):
                d = op.mem.disp & 0xFFFF
                if op.mem.base == 0 and op.mem.index == 0 and d >= 0x40:
                    mem[d].add(op.size)
                elif op.mem.base in (x86.X86_REG_BX, x86.X86_REG_SI, x86.X86_REG_DI) and d >= 0x100 and d < DG_SIZE:
                    mem[d].add(0)
            if dsok and op.type == x86.X86_OP_IMM and ins.id in (x86.X86_INS_PUSH, x86.X86_INS_MOV) and ins.size >= 3:
                v = op.imm & 0xFFFF
                if is_string_start(v):
                    strs.add(v)
    return mem, strs, starts, bad


FAR_NAMES = {
    0x3415: 'db_files',
    0x342E: 'spare_1',
    0x342F: 'number_words',
    0x3448: 'menu_text',
    0x35E8: 'save_messages',
    0x35EC: 'spare_2',
    0x35EE: 'save_dialog_rects',
    0x35F3: 'hilight_messages',
    0x3608: 'credits',
    0x3680: 'char_table',
    0x369A: 'dialog_rects',
    0x36A8: 'playoff_dialog_rects',
    0x36B8: 'playoff_messages',
    0x36F5: 'return_messages',
    0x3701: 'team_choice_text',
    0x3821: 'import_messages',
    0x3827: 'schedule_messages',
    0x382B: 'trade_messages',
    0x3836: 'merge_messages',
    0x384B: 'season_titles',
    0x3863: 'object_table',
    0x38AF: 'lines_menu_text',
    0x38BD: 'line_names',
    0x38EB: 'stat_names',
    0x38F0: 'hilight_save_messages',
    0x38F6: 'anim_sequences',
    0x3976: 'palette_flags',
    0x3996: 'runtime_state',
    0x39AD: 'font_table',
    0x3A0B: 'work_buffer',
}


def far_segments():
    # paragraphs of the far data the code and the relocations name, from the start of the segment to DGROUP
    paras = {LOAD}
    rel = []
    for i in range(NREL):
        o, sg = struct.unpack_from('<HH', EXE, RELOC_FILE + 4 * i)
        rel.append((o, sg))
        f = IMG_FILE + sg * 16 + o - LOAD * 16
        v = struct.unpack_from('<H', EXE, f)[0]
        if LOAD <= v < DGROUP:
            paras.add(v)
    for r in g.RELOC:
        v = struct.unpack_from('<H', g.IMG, r)[0]
        if LOAD <= v < DGROUP:
            paras.add(v)
    return sorted(paras), rel


def h(v, w=0):
    return f'0x{v:0{w}X}'


def render(bs):
    return g.dbtext(bs)


def emit_bytes(out, b, o0, labels, comments, sizes):
    # b: bytes, o0: offset of b[0]; labels: offset->name. Split at labels; strings and words where clear.
    keys = sorted(k for k in labels if o0 <= k < o0 + len(b))
    cuts = sorted(set(keys + [o0, o0 + len(b)]))
    for a, z in zip(cuts, cuts[1:]):
        if a in labels:
            c = comments.get(a)
            out.append(f'{labels[a]}:' + (f'\t\t\t; {c}' if c else ''))
        seg = b[a - o0:z - o0]
        sz = max(sizes.get(a, {1}) or {1})
        if sz == 2 and len(seg) % 2 == 0 and len(seg) <= 64 and not any(32 <= c < 127 for c in seg[::2]) is False and len(seg) == 2:
            out.append('\tdw\t' + h(struct.unpack('<H', seg)[0], 4))
            continue
        if sz == 2 and len(seg) == 2:
            out.append('\tdw\t' + h(struct.unpack('<H', seg)[0], 4))
            continue
        if sz == 4 and len(seg) == 4:
            out.append('\tdd\t' + h(struct.unpack('<I', seg)[0], 8))
            continue
        i = 0
        while i < len(seg):
            # zero runs
            j = i
            while j < len(seg) and seg[j] == 0:
                j += 1
            if j - i >= 16:
                out.append(f'\ttimes\t{j - i}\tdb 0')
                i = j
                continue
            j = i
            while j < len(seg) and (j - i < 16 or (32 <= seg[j] < 127 and j - i < 72)):
                if j > i and seg[j - 1] == 0 and j - i >= 4 and 32 <= seg[j] < 127:
                    break
                j += 1
            out.append('\t' + render(seg[i:j]))
            i = j


def main():
    flow, funcs, _ = g.analyze([s['name'] for s in g.SEGS if s['name'] not in ('seg000', 'seg001', 'seg002', 'seg003', 'seg004', 'seg005', 'seg056')])
    mem, strs, starts, bad = collect(flow, funcs)
    equs = hand_equs()
    labels, comments, used = {}, {}, set()
    for v, names in equs.items():
        labels[v] = names[0][0]
        used.add(names[0][0])
        if names[0][1]:
            comments[v] = names[0][1]
    for v in sorted(strs):
        if v not in labels:
            labels[v] = string_name(v, used)
    for v in sorted(mem):
        if v >= DG_SIZE:
            continue
        if v not in labels:
            if is_string_start(v):
                labels[v] = string_name(v, used)
            else:
                labels[v] = f'g_{v:04X}'
                used.add(labels[v])
    sizes = {v: mem[v] for v in mem}
    # relocation table
    paras, rel = far_segments()
    d = os.path.join(ROOT, 'src', 'data')
    os.makedirs(os.path.join(d, 'far'), exist_ok=True)
    out = ['; Relocation table of the RTLink segment stored in HOCKEY.EXE (record 20, loaded at startup to paragraph',
           '; 3415h): 1156 entries of offset, segment. The loader adds the program load segment to the word at each',
           '; address. In front of it, 9 zero bytes finish the last paragraph of the load module.']
    out.append('\ttimes\t9\tdb 0\t\t\t; end of the last paragraph of the load module')
    for o, sg in rel:
        out.append(f'\tdw\t{h(o, 4)}, {h(sg, 4)}')
    open(os.path.join(d, 'rtl_relocs.asm'), 'w').write('\n'.join(out) + '\n')
    # far data segments
    fars = []
    bounds = paras + [DGROUP]
    for a, z in zip(bounds, bounds[1:]):
        name = FAR_NAMES.get(a, f'far{a:04X}')
        b = EXE[IMG_FILE + (a - LOAD) * 16:IMG_FILE + (z - LOAD) * 16]
        fl = {}
        fused = set()
        for k in range(len(b)):
            if (k == 0 or b[k - 1] == 0) and k < len(b) and 32 <= b[k] < 127:
                n = 0
                while k + n < len(b) and 32 <= b[k + n] < 127:
                    n += 1
                if n >= 2 and k + n < len(b) and b[k + n] == 0:
                    pass
        o = [f'; Far data segment at paragraph {h(a, 4)} ({len(b)} bytes). Generated by tools/disasm/gen_data.py.']
        emit_bytes(o, b, 0, fl, {}, {})
        open(os.path.join(d, 'far', name + '.asm'), 'w').write('\n'.join(o) + '\n')
        fars.append((name, a))
    # DGROUP initialized part
    b = EXE[DG_FILE:]
    o = ['; DGROUP initialized data (near data of the medium model, paragraph 45C9h). Generated by tools/disasm/gen_data.py;',
         '; names and comments still to do. The BSS (no bytes in the file) is in dgroup_bss.asm.']
    emit_bytes(o, b, 0, {k: v for k, v in labels.items() if k < DG_INIT}, comments, sizes)
    open(os.path.join(d, 'dgroup.asm'), 'w').write('\n'.join(o) + '\n')
    # BSS
    bl = sorted(k for k in labels if DG_INIT <= k < DG_SIZE)
    o = ['; DGROUP uninitialized data (BSS): no bytes in the file; the startup code clears it. Generated by',
         '; tools/disasm/gen_data.py; names and comments still to do.']
    pos = DG_INIT
    if bl and bl[0] > pos:
        o.append(f'\tresb\t{bl[0] - pos}')
        pos = bl[0]
    for i, k in enumerate(bl):
        nxt = bl[i + 1] if i + 1 < len(bl) else DG_SIZE
        c = comments.get(k)
        o.append(f'{labels[k]}:' + (f'\t\t\t; {c}' if c else ''))
        o.append(f'\tresb\t{nxt - k}')
    open(os.path.join(d, 'dgroup_bss.asm'), 'w').write('\n'.join(o) + '\n')
    json.dump({'dgroup': {str(k): v for k, v in labels.items()}, 'strings': sorted(strs), 'far': fars,
               'unsafe': sorted(bad), 'dg_init': DG_INIT, 'dg_size': DG_SIZE,
               'aliases': {names[i][0]: names[0][0] for v, names in equs.items() for i in range(1, len(names))}},
              open(os.path.join(ROOT, 'tools', 'disasm', 'data_labels.json'), 'w'), indent=0)
    print(f'DGROUP: {DG_INIT} bytes in the file, {DG_SIZE} reserved; {len(labels)} labels ({len(strs)} strings); '
          f'{len(fars)} far data segments')


if __name__ == '__main__':
    main()
