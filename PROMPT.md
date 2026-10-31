# Segment prompt

Paste this into a new agent session. One segment per prompt. Do not edit this prompt.

```text
Read START_HERE.md, SEGMENT_AGENT.md and CONTRIBUTING.md before you write any asm. Take the first segment in the segment map of SEGMENT_AGENT.md that is still incbin. That file is the only segment this session. This repo is a disassembly only (labelled 16-bit x86 NASM that reassembles byte-identical); do not write C.

NHL '94 PC is based on NHLPA 93 SNES and NHL 94 Genesis. Names follow the Current rules section of SEGMENT_AGENT.md: code that does the same job as NHLPA93SNES takes its name (93S names carry 93G and 92G), 94 features take the NHL94Genesis name, else a name from what the code clearly does. Match by purpose, not identical code; the earlier game's name wins. EACLIB functions keep EA's names from their error strings; Microsoft C runtime routines keep their library names.

1. Run ./build.sh first. It must print MATCH before you change anything. If it does not, stop and report.
2. Disassemble the segment as 16-bit code (objdump -D -b binary -mi8086 -M intel, or ndisasm -b 16, on Extracted/segments/<segment>.bin; offsets are from the segment start, which is what the labels mean in its vstart=0 section). Put the text into src/seg/<segment>.asm in place of its incbin.
3. Separate code from data. Far calls and far pointers need a relocation entry: every word the MZ relocation table points at holds a segment number; write it as the segment it names (keep the bytes) and note it, do not change the relocation table.
4. Name everything: procedures, locals (92 style), data. Labels this segment uses from other segments that are still incbin get an equate in its stub (src/stubinc/<segment>_stub.asm) and, in the full build, a number with a comment until that segment is source.
5. ./build.sh must print MATCH after each batch of edits, then sh tools/verify_segment.sh <segment> must print MATCH.
6. In SEGMENT_AGENT.md mark the row, add a History line, set Current segment. Update docs/HANDOFF.md and docs/name_map.csv. Commit and push to main.

Stop after 5 failed builds in a row and report the file, first differing file offset, built and retail bytes, and the line you wrote.
```
