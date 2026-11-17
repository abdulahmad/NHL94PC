#!/usr/bin/env python3
# label_dgroup.py: in the hand-written segments, write DGROUP operands by their labels: [0x7034] becomes [g_7034]
# (or its real name). Offsets come from tools/disasm/data_labels.json and the DGROUP files. Lines with an ES or
# CS override and BP-based operands are left alone.
#   python3 tools/label_dgroup.py seg000 seg001 ...
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
d = json.load(open(os.path.join(ROOT, 'tools', 'disasm', 'data_labels.json')))
dg = {int(k): v for k, v in d['dgroup'].items()}
RX = re.compile(r'\[((?:ss:|ds:)?)((?:(?:bx|si|di)(?: \+ (?:si|di))? ?\+ ?)?)0x([0-9a-fA-F]{2,4})\]')
for seg in sys.argv[1:]:
    p = os.path.join(ROOT, 'src', 'seg', seg + '.asm')
    out, n = [], 0
    for line in open(p).read().split('\n'):
        code, sep, com = line.partition(';')
        if not re.search(r'\b(es|cs):', code) and not code.lstrip().startswith(('db', 'dw', 'dd')):
            def sub(m):
                global n
                v = int(m.group(3), 16)
                if v < 0x40 or v not in dg:
                    return m.group(0)
                n += 1
                base = m.group(2)
                if base and not base.rstrip().endswith('+'):
                    base = base + ' + '
                base = re.sub(r'\s*\+\s*$', ' + ', base) if base else ''
                return f'[{m.group(1)}{base}{dg[v]}]'
            code = RX.sub(sub, code)
        out.append(code + sep + com)
    open(p, 'w').write('\n'.join(out))
    print(f'{seg}: {n} operands')
