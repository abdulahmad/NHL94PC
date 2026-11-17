#!/usr/bin/env python3
# label_dgroup_ovl.py: give a label to every DGROUP offset the overlays use that has none yet, so that
# tools/disasm/gen_ovl.py writes the operand by name. The offsets come from a gen_ovl.py run with GEN_OVL_MISS set:
#   GEN_OVL_MISS=/tmp/miss.json python3 tools/disasm/gen_ovl.py GAME INIT ...
#   python3 tools/disasm/label_dgroup_ovl.py /tmp/miss.json
# A label inside a db, dw, dd, times or resb line splits that line; the bytes come from the build listing, so the
# output is the same. New labels are named g_XXXX (the offset) until they get a real name.
import json, os, re, subprocess, sys, tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
COL = 48
DG = 0x45C9


def data_files():
    """(section, file, line of its %include in hockey94pc.asm, paragraph) for DGROUP and the far data"""
    seg = {x['name']: x for x in json.load(open(os.path.join(ROOT, 'segmap.json')))['segments']}
    out, sec = [], None
    for no, line in enumerate(open(os.path.join(ROOT, 'src', 'hockey94pc.asm')), 1):
        m = re.match(r'section (\S+)', line)
        if m:
            sec = m.group(1)
        m = re.match(r'%include "(data/[^"]+)"', line)
        if m and sec and m.group(1) != 'data/rtl_relocs.asm':
            para = DG if sec.startswith('dgroup') else seg[sec]['para']
            out.append((sec, 'src/' + m.group(1), no, para))
    return out


FILES = data_files()


def listing():
    d = tempfile.mkdtemp()
    lst, mp = os.path.join(d, 'l.lst'), os.path.join(d, 'm.map')
    w = os.path.join(d, 'w.asm')
    open(w, 'w').write(f'[map all {mp}]\n%include "hockey94pc.asm"\n')
    subprocess.run(['nasm', '-f', 'bin', '-I', os.path.join(ROOT, 'src') + '/', '-l', lst, '-o', os.path.join(d, 'o'), w],
                   check=True, cwd=ROOT)
    lens = {}
    sec = None
    for line in open(mp):
        m = re.match(r'---- Section (\S+)', line)
        if m:
            sec = m.group(1)
        m = re.match(r'length:\s+([0-9A-F]+)', line)
        if m and sec:
            lens[sec] = int(m.group(1), 16)
    # per file: line number -> [address, bytes]
    out = {f: {} for _, f, _, _ in FILES}
    cur = None
    last = None
    for line in open(lst):
        m = re.match(r'^\s*(\d+)\s(.*)$', line.rstrip('\n'))
        if not m:
            continue
        no, rest = int(m.group(1)), m.group(2)
        inc = '<2>' in rest                # the wrapper includes hockey94pc.asm (<1>), which includes the data (<2>)
        if not inc:
            if '<1>' in rest:
                cur = next((f for _, f, ln, _ in FILES if ln == no), None) if '%include' in rest else None
            continue
        if cur is None:
            continue
        mm = re.match(r'^([0-9A-F]{8}) ([0-9A-F?]+<rep [0-9A-F]+h>|[0-9A-F?]+|<res [0-9A-F]+h>)(-?)\s', rest)
        if mm:
            addr, hx = int(mm.group(1), 16), mm.group(2)
            ent = out[cur].setdefault(no, [addr, b'', 0])
            if '<rep' in hx:
                one, n = hx.split('<rep ')
                ent[1] += bytes.fromhex(one) * int(n[:-2], 16)
                ent[2] += len(one) // 2 * int(n[:-2], 16)
            elif hx.startswith('<res'):
                ent[2] += int(hx[5:-2], 16)
            elif '?' in hx:
                ent[2] += len(hx) // 2
            else:
                ent[1] += bytes.fromhex(hx)
                ent[2] += len(hx) // 2
            last = ent
        else:
            mm = re.match(r'^\s{8} ([0-9A-F]+)(-?)\s', rest)   # continuation row
            if mm and last is not None and out[cur].get(no) is last:
                last[1] += bytes.fromhex(mm.group(1))
                last[2] += len(mm.group(1)) // 2
    return out, lens


def render_db(bs):
    """db lines for bytes: printable runs as strings, the rest as hex, 8 values a line"""
    parts = []
    i = 0
    while i < len(bs):
        j = i
        while j < len(bs) and 32 <= bs[j] < 127 and bs[j] != 0x27:
            j += 1
        if j - i >= 3:
            parts.append(("s", bs[i:j].decode()))
            i = j
        else:
            parts.append(("b", bs[i]))
            i += 1
    lines, cur, n = [], [], 0
    for k, v in parts:
        t = f"'{v}'" if k == 's' else f'0x{v:02X}'
        w = 1 if k == 'b' else 4
        if cur and (n + w > 8 or k == 's' and len(v) > 40):
            lines.append(cur)
            cur, n = [], 0
        cur.append(t)
        n += w
    if cur:
        lines.append(cur)
    return ['        db ' + ', '.join(c) for c in lines]


def piece(kind, line, bs, size):
    """lines for the byte range of one data line: kind is 'db' (bytes given), 'resb' or 'zero'"""
    if kind == 'resb':
        return [f'        resb {size}']
    if kind == 'zero':
        return [f'        times {size} db 0'] if size > 1 else ['        db 0x00']
    return render_db(bs)


def label_line(name, comment):
    pad = max(1, COL - len(name) - 1)
    return f'{name}:' + ' ' * pad + f'; {comment}'


def camel(text):
    words = re.findall(r'[A-Za-z0-9]+', text)
    out = ''
    for w in words:
        if len(out) >= 24:
            break
        out += w[:1].upper() + w[1:].lower()
    return out


def string_at(data, off):
    """the NUL-terminated printable text starting at off, or None"""
    j = off
    while j < len(data) and (32 <= data[j] < 127 or data[j] in (9, 10, 13)):
        j += 1
    if j < len(data) and data[j] == 0 and j - off >= 2 and camel(data[off:j].decode()):
        return data[off:j].decode()
    return None


def main():
    miss = {}
    for k, v in json.load(open(sys.argv[1])).items():
        sg, off = (k.split(':') + [None])[:2] if ':' in k else ('45C9', k)
        miss[(int(sg, 16), int(off, 16))] = v
    lst, lens = listing()
    end = lens['dgroup'] + lens['dgroup_bss']
    used = set()
    for sec, path, _, _ in FILES:
        used |= {n for n in re.findall(r'^([A-Za-z_]\w*):', open(os.path.join(ROOT, path)).read(), re.M)}
    done = 0
    for sec, path, _, para in FILES:
        base = lens['dgroup'] if sec == 'dgroup_bss' else 0
        size = end if para == DG else lens.get(sec, 0)
        want = {}
        for (sg, v), who in miss.items():
            if sg != para:
                continue
            idx = all(w.endswith(':indexed') for w in who)
            if v >= size or (idx and para == DG and v < 0x1000):     # a small displacement is a field offset
                continue
            want[v] = sorted({w.split(':')[0] for w in who})
        if not want:
            continue
        lines = open(os.path.join(ROOT, path)).read().split('\n')
        ent = lst[path]
        mem = bytearray(size + 16)
        for no, (a, bs, sz) in ent.items():
            mem[a + base:a + base + len(bs)] = bs
        starts = sorted((a + base, no, bs, sz) for no, (a, bs, sz) in ent.items() if sz)
        cuts = {}
        for addr, no, bs, sz in starts:
            for v in want:
                if addr <= v < addr + sz:
                    cuts.setdefault(no, set()).add(v - addr)

        def label(v):
            who = ', '.join(want[v])
            st = string_at(mem, v) if (sec != 'dgroup_bss') else None
            if st is not None:
                nm = 'str_' + camel(st)
                k = 2
                while nm in used:
                    nm = f'str_{camel(st)}_{k}'
                    k += 1
                shown = st.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
                com = f"string '{shown}'; used by {who}"
            else:
                nm = f'g_{v:04X}' if para == DG else f'f_{para:04X}_{v:04X}'
                com = f'used by {who} (to name)'
            used.add(nm)
            return label_line(nm, com)
        for no in sorted(cuts, reverse=True):
            a, bs, sz = ent[no]
            src = lines[no - 1]
            code = src.split(';')[0].strip()
            kind = 'resb' if code.startswith('resb') else 'zero' if code.startswith('times') else 'db'
            if kind == 'db' and len(bs) != sz:
                sys.exit(f'{path}:{no}: no bytes in the listing')
            offs = sorted(cuts[no])
            if offs == [0]:
                lines[no - 1:no] = [label(a + base), src]      # label in front, line unchanged
                done += 1
                continue
            new = []
            prev = 0
            for o in offs + [sz]:
                if o > prev:
                    new += piece(kind, src, bs[prev:o], o - prev)
                if o < sz:
                    new.append(label(a + base + o))
                    done += 1
                prev = o
            lines[no - 1:no] = new
        open(os.path.join(ROOT, path), 'w').write('\n'.join(lines))
    print(f'{done} labels added')


if __name__ == '__main__':
    main()
