#!/usr/bin/env python3
# build_ovl.py: assemble every overlay in ovlmap.json from src/ovl/<name>_build.asm into output/ovl/<NAME>.OVL and
# compare it with the retail file (lst/game/, checked by SHA-1). Prints one line per overlay, then MATCH or MISMATCH.
#   python3 tools/build_ovl.py [NAME ...]
import hashlib, json, os, subprocess, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
NASM = os.environ.get('NASM', 'nasm')
OVLS = json.load(open(os.path.join(ROOT, 'ovlmap.json')))['overlays']


def build(o):
    lo = o['name'].lower()
    out = os.path.join('output', 'ovl', o['name'] + '.OVL')
    os.makedirs(os.path.join(ROOT, 'output', 'ovl'), exist_ok=True)
    r = subprocess.run([NASM, '-f', 'bin', '-I', 'src/', '-o', out, f'src/ovl/{lo}_build.asm'], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        return f"{o['name']}: ASSEMBLY FAILED\n{r.stderr.strip()[:2000]}"
    b = open(os.path.join(ROOT, out), 'rb').read()
    if hashlib.sha1(b).hexdigest() == o['sha1']:
        return None
    ref = open(os.path.join(ROOT, o['file']), 'rb').read()
    d = next((k for k in range(min(len(b), len(ref))) if b[k] != ref[k]), min(len(b), len(ref)))
    return f"{o['name']}: DIFFER at file offset 0x{d:X} (built {len(b)} bytes, retail {len(ref)})"


want = [a.upper() for a in sys.argv[1:]]
bad = []
for o in OVLS:
    if want and o['name'] not in want:
        continue
    r = build(o)
    print(r or f"{o['name']}: MATCH")
    if r:
        bad.append(r)
print('MISMATCH' if bad else 'MATCH')
sys.exit(1 if bad else 0)
