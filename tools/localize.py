#!/usr/bin/env python3
# localize.py: in a hand-written segment file, turn numeric branch targets (je short 0x13FF) and address-named
# labels (L0D10) into local labels .N of the routine they sit in. A target in another routine is written Scope.N.
# Offsets come from a NASM listing of the segment's stub build. The build must still MATCH afterwards.
#   python3 tools/localize.py seg001 [seg002 ...]
import os, re, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BR = re.compile(r'^(\s+)(j[a-z]+|loop[a-z]*|jcxz|call)(\s+)(short |near )?(0x[0-9A-Fa-f]+)\b(?!:)(.*)$')
GLOBAL = re.compile(r'^([A-Za-z_]\w*):')
LOCAL = re.compile(r'^(\.[A-Za-z0-9_]+):')
LNAME = re.compile(r'^L[0-9A-F]{4}$')


BYTES = set()


def offsets(seg, path):
    stub = os.path.join('src', 'stubinc', seg + '_stub.asm')
    org = int(re.search(r'org\s+(0x[0-9A-Fa-f]+|\d+)', open(os.path.join(ROOT, stub)).read()).group(1), 0)
    d = tempfile.mkdtemp()
    lst = os.path.join(d, 'l.lst')
    r = subprocess.run(['nasm', '-f', 'bin', '-I', 'src/', '-l', lst, '-o', os.path.join(d, 'o'), stub], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr)
    off = {}      # file line number (1-based) -> offset of the first byte at or after it
    pending = []
    for line in open(lst, errors='replace'):
        m = re.match(r'^\s*(\d+)\s(?:([0-9A-F]{8})\s+([0-9A-F()\[\]]+)\s+)?\s*<1>', line)
        if not m:
            continue
        n = int(m.group(1))
        if m.group(2):
            o = int(m.group(2), 16) + org
            for p in pending:
                off[p] = o
            pending = []
            off.setdefault(n, o)
            BYTES.add(n)
        else:
            pending.append(n)
    return off


def main(seg):
    BYTES.clear()
    path = os.path.join(ROOT, 'src', 'seg', seg + '.asm')
    lines = open(path).read().split('\n')
    off = offsets(seg, path)
    # scopes: each line's enclosing global label; L-labels are not scopes
    scope_of, scope = {}, None
    at = {}        # offset -> first line index starting there (code lines with bytes)
    for i, l in enumerate(lines):
        m = GLOBAL.match(l)
        if m and not LNAME.match(m.group(1)):
            scope = m.group(1)
        scope_of[i] = scope
        if (i + 1) in BYTES:
            at.setdefault(off[i + 1], i)
    # wanted labels: L-label definitions and numeric targets
    want = {}      # line index -> new local name
    used = {}
    for i, l in enumerate(lines):
        m = LOCAL.match(l)
        if m:
            used.setdefault(scope_of[i], set()).add(m.group(1))
    targets = set()
    for i, l in enumerate(lines):
        m = BR.match(l.split(';')[0]) if not l.lstrip().startswith(';') else None
        if m:
            t = int(m.group(5), 16)
            if t in at:
                targets.add(at[t])
    llines = {i for i, l in enumerate(lines) if GLOBAL.match(l) and LNAME.match(GLOBAL.match(l).group(1))}
    # a numeric target on the first instruction of a routine uses the routine's own name
    gl = {}
    for i in list(targets - llines):
        k = i - 1
        while k >= 0 and (not lines[k].strip() or lines[k].lstrip().startswith(';') or LOCAL.match(lines[k])):
            k -= 1
        if k >= 0 and GLOBAL.match(lines[k]) and not LNAME.match(GLOBAL.match(lines[k]).group(1)):
            gl[off[i + 1]] = (GLOBAL.match(lines[k]).group(1), '')
            targets.discard(i)
    counter = {}
    for i in sorted(targets | llines):
        sc = scope_of[i]
        n = counter.get(sc, 0)
        while True:
            n += 1
            if f'.{n}' not in used.get(sc, set()):
                break
        counter[sc] = n
        want[i] = f'.{n}'
    # L-label definitions become the local; numeric targets get a local line inserted
    lname = {}
    for i in llines:
        lname[GLOBAL.match(lines[i]).group(1)] = (scope_of[i], want[i])
    tline = dict(gl)     # offset -> (scope, local)
    for i in targets:
        o = off[i + 1]
        if i in llines:
            tline[o] = lname[GLOBAL.match(lines[i]).group(1)]
        else:
            # a label line directly above with the same offset can carry it
            tline[o] = (scope_of[i], want[i])

    def ref(sc, cur):
        if not sc[1]:
            return sc[0]
        return sc[1] if sc[0] == cur else f'{sc[0]}{sc[1]}'
    out = []
    for i, l in enumerate(lines):
        cur = scope_of[i]
        if i in llines:
            rest = l[len(GLOBAL.match(l).group(0)):]
            out.append(want[i] + ':' + rest)
            continue
        if i in targets:
            out.append(want[i] + ':')
        m = BR.match(l)
        if m and not l.lstrip().startswith(';'):
            t = int(m.group(5), 16)
            if t in tline and m.group(2) != 'call':
                l = f'{m.group(1)}{m.group(2)}{m.group(3)}{m.group(4) or ""}{ref(tline[t], cur)}{m.group(6)}'
            elif t in tline and m.group(2) == 'call':
                l = f'{m.group(1)}{m.group(2)}{m.group(3)}{m.group(4) or ""}{ref(tline[t], cur)}{m.group(6)}'
        # references to L-labels
        def sub(mm):
            return ref(lname[mm.group(0)], cur) if mm.group(0) in lname else mm.group(0)
        code, sep, com = l.partition(';')
        code = re.sub(r'(?<![\w.])L[0-9A-F]{4}\b', sub, code)
        out.append(code + sep + com)
    open(path, 'w').write('\n'.join(out))
    print(f'{seg}: {len(llines)} L-labels and {len(targets - llines)} numeric targets made local')


for a in sys.argv[1:]:
    main(a)
