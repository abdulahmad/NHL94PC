# Contributing to NHL 94 PC

A bit-perfect disassembly (no decompilation) of NHL Hockey ('94) for DOS, assembled with NASM.

- `main` only takes byte-identical changes: `./build.sh` must print MATCH and `sh tools/verify_segment.sh <segment>` MATCH for each segment
  touched. Run `sh tools/verify_all.sh` before every push.
- Small commits; never force-push.
- Names: see SEGMENT_AGENT.md (93S, then 94G, then EACLIB/MSC runtime, then the demo's names, then behaviour). Every rename gets a row in
  `docs/name_map.csv` (`address,name,auto_name,source,confidence,evidence,file`; `source` is `93S`, `93G`, `92G`, `94G`, `94PCDemo`,
  `EACLIB`, `MSC` or `new`).
- Comments: no IDA artefacts (`sub_`, `loc_`), no hardcoded addresses in comments; every procedure gets a header comment (what, args, result).
- No macros. Labels instead of addresses wherever NASM can compute them.
- Comment layout as in NHL94SNES CONTRIBUTING.md (tabs, trailing comments at column 36, 110 columns).
- Do not commit game files other than `lst/HOCKEY.EXE` (temporary), `Extracted/`, `output/`, `*.lst` or patches.
