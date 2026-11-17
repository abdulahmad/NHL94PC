#!/usr/bin/env python3
"""format_asm.py - lay out the .asm sources the way CONTRIBUTING.md ("Comments", Layout) asks. Text only: the bytes
NASM makes stay the same, so the build must still MATCH after a run.

  python3 tools/format_asm.py [--check] [FILE...]      (default: every .asm file under src/ but src/stubinc/)

What it does to each line:
  * labels, comment lines, % lines, bits/org/section and equ lines start in column 0
  * instructions and data are indented 8 spaces, with one space between the mnemonic and its operands
  * a trailing comment starts at column 48, or one space after code that reaches past it; a comment line that
    continues it (only spaces before the ';') lines up at column 48 too
  * an instruction kept as bytes (`db 0x8B, 0xDC ; mov bx, sp`) has its text marked `; insn: mov bx, sp`
  * it is idempotent: a formatted file comes out unchanged
--check: change nothing, list the files that would change, exit 1 if any.
"""
import glob, os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'src')
IND, COL = ' ' * 8, 48
LABEL = re.compile(r'^[A-Za-z_.][\w.$?@]*:')
COL0 = re.compile(r'^(bits|section|segment|org|cpu|default|global|extern)\b|^[A-Za-z_.][\w.$?@]*\s+equ\b', re.I)
MNEM = re.compile(r'^(mov|movs[bw]?|movzx|movsx|add|adc|sub|sbb|xor|or|and|cmp|test|not|neg|inc|dec|mul|imul|div|idiv|'
                  r'shl|shr|sal|sar|rol|ror|rcl|rcr|call|lcall|jmp|j[a-z]{1,4}|loop\w*|ret[fn]?|xchg|cbw|cwd|cdq|cwde|'
                  r'les|lds|lea|push\w*|pop\w*|rep\w*|lods[bw]|stos[bw]|cmps[bw]|scas[bw]|in|out|int|iret|cli|sti|'
                  r'cld|std|clc|stc|cmc|nop|hlt|enter|leave|wait|lahf|sahf|xlat\w*|aam|aad|daa|das|'
                  r'f(ld[z1]?|ild|st|stp|ist|istp|xch|add|addp|sub|subp|subr|mul|mulp|div|divp|divr|com|comp|compp|chs|abs|'
                  r'sqrt|rndint|n?stsw|n?init|wait|n?clex|ldcw|n?stcw|tst|xam|scale|prem|ptan|patan|2xm1|yl2x))(\s|$)')


REG = re.compile(r'\b([abcd][xlh]|[sd]i|[bs]p|[cdefgs]s|e[abcd]x|e[sd]i|st\d?|word|byte|dword|ptr|short|near|far)\b|[\d\[,]')


def looks_like_insn(text):
    """the text of an instruction: a mnemonic, then nothing or operands (a register, number, memory operand or
    comma), not an English phrase that starts with a word such as 'not' or 'in'"""
    m = MNEM.match(text)
    if not m: return False
    rest = text[m.end():].strip()
    return not rest or REG.search(rest.split(',')[0]) is not None or rest.split()[0].endswith(',')


def split(line):
    """(code, comment): the comment starts at the first ';' outside a string"""
    q = None
    for i, ch in enumerate(line):
        if q:
            if ch == q: q = None
        elif ch in "'\"`": q = ch
        elif ch == ';': return line[:i], line[i:]
    return line, None


def detab(c):
    """tabs outside strings become one space"""
    out, q = [], None
    for ch in c:
        if q:
            if ch == q: q = None
        elif ch in "'\"`": q = ch
        elif ch == '\t':
            if out and out[-1] == ' ': continue
            ch = ' '
        out.append(ch)
    return ''.join(out)


def put(code, com):
    t = IND + code
    if com is None: return t
    return t.ljust(COL) + com if len(t) < COL else t + ' ' + com


def fmt_line(l, prev_trailing):
    s = l.strip()
    if not s: return ''
    code, com = split(l)
    if not code.strip():                                 # a comment line
        if prev_trailing and re.match(r'^\s+;', l) and len(l) - len(l.lstrip()) >= 16:
            return ' ' * COL + com.rstrip()              # continues the trailing comment above
        return com.rstrip()
    c = code.strip()
    if c.startswith(('%', '[')) or COL0.match(c):
        return c.rstrip() if com is None else (c.rstrip().ljust(COL) + com.rstrip() if len(c.rstrip()) < COL
                                               else c.rstrip() + ' ' + com.rstrip())
    if LABEL.match(c):
        m = LABEL.match(c)
        lab, rest = c[:m.end()], c[m.end():].strip()
        if rest:                                         # label and code on one line: keep the label alone
            return lab + '\n' + fmt_line(IND + rest + ((' ' + com) if com else ''), False)
        return lab if com is None else lab.ljust(COL) + com.rstrip() if len(lab) < COL else lab + ' ' + com.rstrip()
    m = re.match(r'^(\S+)\s+(.*)$', c)
    c = (m.group(1) + ' ' + m.group(2)) if m else c
    c = detab(c)
    if com is not None:
        body = com[1:].strip()
        if re.match(r'^(db|dw)\b', c, re.I) and not body.startswith('insn:') and looks_like_insn(body) \
                and re.match(r'^d[bw]\s+(0x[0-9A-Fa-f]+|\d+)(\s*,\s*(0x[0-9A-Fa-f]+|\d+))*\s*$', c):
            body = 'insn: ' + re.sub(r'\s+', ' ', body.replace('\t', ' '))
        com = '; ' + body if body else ';'
    return put(c.rstrip(), com)


def fmt(text):
    out, trailing = [], False
    for l in text.split('\n'):
        n = fmt_line(l, trailing)
        code, com = split(l)
        if code.strip(): trailing = com is not None
        elif not l.strip() or not (re.match(r'^\s+;', l)): trailing = False
        out.append(n)
    return '\n'.join(out)


def files(args):
    if args: return [os.path.abspath(a) for a in args]
    return sorted(f for f in glob.glob(os.path.join(SRC, '**', '*.asm'), recursive=True)
                  if os.sep + 'stubinc' + os.sep not in f)


def main(argv):
    check = '--check' in argv
    changed = []
    for f in files([a for a in argv if a != '--check']):
        t = open(f, encoding='latin1').read()
        n = fmt(t)
        if n != t:
            changed.append(f)
            if not check: open(f, 'w', encoding='latin1').write(n)
    for f in changed: print(('would change ' if check else 'formatted ') + os.path.relpath(f, ROOT))
    if check and changed: sys.exit(1)


if __name__ == '__main__':
    main(sys.argv[1:])
