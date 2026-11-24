#!/usr/bin/env python3
# check_spa.py: the SPA numbers other files use must come from the sequences in src/data/frames.asm. It assembles the
# full build with a NASM map, takes SPAlist and every SPA* label from it, and checks the copies that are not derived:
# the SPA* equ lines of the overlay syms files (src/ovl/*_syms.inc, written by make_ovl_syms.py). It also checks
# that every SPA label in frames.asm starts on a word (a SPA number is the byte offset / 2).
#   python3 tools/check_spa.py        (prints OK, or each value that differs; exit code 1 on a difference)
import os, re, subprocess, sys, tempfile
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
NASM = os.environ.get('NASM', 'nasm')


def full_map():
    d = tempfile.mkdtemp()
    w, mp = os.path.join(d, 'w.asm'), os.path.join(d, 'map.txt')
    open(w, 'w').write(f'[map symbols {mp}]\n%include "hockey94pc.asm"\n')
    r = subprocess.run([NASM, '-f', 'bin', '-I', 'src/', '-o', os.path.join(d, 'o'), w], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr)
    vals = {}
    for line in open(mp):
        m = re.match(r'^([0-9A-F]+)\s+([0-9A-F]+)\s+(SPA\w*)$', line.strip())
        if m:
            vals[m.group(3)] = int(m.group(2), 16)
    return vals


def main():
    vals = full_map()
    if 'SPAlist' not in vals:
        sys.exit('check_spa: SPAlist not found in the map')
    base, bad = vals['SPAlist'], []
    labels = re.findall(r'^(SPA\w+):', open(os.path.join(ROOT, 'src/data/frames.asm')).read(), re.M)
    for n in labels:
        if (vals[n] - base) & 1:
            bad.append(f'{n}: odd byte offset {vals[n] - base:#x} from SPAlist')
    for f in sorted(os.listdir(os.path.join(ROOT, 'src/ovl'))):
        if not f.endswith('_syms.inc'):
            continue
        for line in open(os.path.join(ROOT, 'src/ovl', f)):
            m = re.match(r'^(SPA\w*)\s+equ\s+(0x[0-9A-Fa-f]+|\d+)', line)
            if m and m.group(1) in vals and int(m.group(2), 0) != vals[m.group(1)]:
                bad.append(f'src/ovl/{f}: {m.group(1)} is {m.group(2)}, frames.asm gives {vals[m.group(1)]:#x}')
            elif m and m.group(1) not in vals:
                bad.append(f'src/ovl/{f}: {m.group(1)} is not a label of the build')
    for b in bad:
        print(b)
    print('check_spa: OK' if not bad else f'check_spa: {len(bad)} difference(s)')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
