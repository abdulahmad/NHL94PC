#!/usr/bin/env python3
# make_stubs.py: rewrite src/stubinc/<seg>_stub.asm for every segment so it builds on its own. The labels a segment
# uses from other segments are set with equ to their value in the full build (read from a NASM map of the full build).
#   python3 tools/make_stubs.py          (run after a change that adds or renames a label used across segments)
import json, os, re, subprocess, sys, tempfile
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
SEGMAP = json.load(open(os.path.join(ROOT, 'segmap.json')))


def full_map():
    d = tempfile.mkdtemp()
    w, mp = os.path.join(d, 'w.asm'), os.path.join(d, 'map.txt')
    open(w, 'w').write(f'[map symbols {mp}]\n%include "hockey94pc.asm"\n')
    r = subprocess.run(['nasm', '-f', 'bin', '-I', 'src/', '-o', os.path.join(d, 'o'), w], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr)
    vals, sec = {}, None
    for line in open(mp):
        m = re.match(r'---- Section (\S+)', line)
        if m:
            sec = m.group(1); continue
        if line.startswith('---- No Section'):
            sec = 'none'; continue
        m = re.match(r'^([0-9A-F]+)\s+([0-9A-F]+)\s+(\S+)$', line.strip())
        if m and sec and sec != 'none':
            vals[m.group(3)] = (sec, int(m.group(2), 16))
        m = re.match(r'^([0-9A-F]+)\s+(\S+)$', line.strip())
        if m and sec == 'none':
            vals[m.group(2)] = ('none', int(m.group(1), 16))
    return vals


def main():
    vals = full_map()
    d = tempfile.mkdtemp()
    for s in SEGMAP['segments']:
        stub = os.path.join(ROOT, 'src', 'stubinc', s['name'] + '_stub.asm')
        org = 0
        need = {}
        for _ in range(10):
            body = [f';\tSegment build for {s["file"]}: sets its origin and the outside labels it uses (their values in the',
                    f';\tfull build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).',
                    '\tbits\t16', f'\torg\t0x{org:X}']
            for n in sorted(need, key=lambda k: need[k]):
                body.append(f'{n}\t\tequ\t0x{need[n]:X}')
            body.append(f'%include "{s["file"]}"')
            open(stub, 'w').write('\n'.join(body) + '\n')
            r = subprocess.run(['nasm', '-f', 'bin', '-I', 'src/', '-o', os.path.join(d, 'o'), stub], cwd=ROOT,
                               capture_output=True, text=True)
            miss = set(re.findall(r"symbol `([^']+)' not defined", r.stderr))
            if not r.returncode:
                break
            if not miss:
                sys.exit(f'{s["name"]}: {r.stderr}')
            for m in miss:
                if m not in vals:
                    sys.exit(f'{s["name"]}: {m} not in the full build')
                need[m] = vals[m][1]
        else:
            sys.exit(f'{s["name"]}: stub did not converge')
    print('stubs written')
    ovl_syms(vals)


def ovl_map(lo):
    """{name: value} of the labels of one overlay build, or None when it does not assemble yet"""
    d = tempfile.mkdtemp()
    w, mp = os.path.join(d, 'w.asm'), os.path.join(d, 'map.txt')
    open(w, 'w').write(f'[map symbols {mp}]\n%include "ovl/{lo}_build.asm"\n')
    r = subprocess.run(['nasm', '-f', 'bin', '-I', 'src/', '-o', os.path.join(d, 'o'), w], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        return None
    out, sec = {}, None
    for line in open(mp):
        m = re.match(r'---- Section (\S+)', line)
        if m:
            sec = m.group(1); continue
        if line.startswith('---- No Section'):
            sec = 'none'; continue
        m = re.match(r'^([0-9A-F]+)\s+([0-9A-F]+)\s+(\S+)$', line.strip())
        if m and sec and sec != 'none':
            out[m.group(3)] = int(m.group(2), 16)
    return out


def ovl_syms(vals):
    """src/ovl/<name>_syms.inc for every overlay in ovlmap.json: the outside labels it uses (root labels, labels of
    an overlay resident with it) as equates of their values"""
    p = os.path.join(ROOT, 'ovlmap.json')
    if not os.path.exists(p):
        return
    ovls = [o['name'].lower() for o in json.load(open(p))['overlays']
            if os.path.exists(os.path.join(ROOT, 'src', 'ovl', o['name'].lower() + '_build.asm'))]
    pool = {n: v for n, (s, v) in vals.items()}
    own = {}
    for _ in range(3):
        for lo in ovls:
            inc = os.path.join(ROOT, 'src', 'ovl', lo + '_syms.inc')
            need = {}
            for _ in range(10):
                open(inc, 'w').write(''.join(f'{n}\t\tequ\t0x{need[n]:X}\n' for n in sorted(need)))
                r = subprocess.run(['nasm', '-f', 'bin', '-I', 'src/', '-o', os.devnull, f'src/ovl/{lo}_build.asm'], cwd=ROOT,
                                   capture_output=True, text=True)
                miss = set(re.findall(r"symbol `([^']+)' not defined", r.stderr))
                if not r.returncode or not miss:
                    break
                for m in miss:
                    v = pool.get(m, next((own[o][m] for o in own if m in own[o]), None))
                    if v is None:
                        break
                    need[m] = v
                else:
                    continue
                break
            m = ovl_map(lo)
            if m:
                own[lo] = {k: v for k, v in m.items() if k not in need}
    print('overlay symbols written')


main()
