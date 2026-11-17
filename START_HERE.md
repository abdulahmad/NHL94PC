# START HERE (instructions for the agent)

Read this file, then `CONTRIBUTING.md` (gates, names, folders, comment rules), `docs/RULES.md` and `docs/HANDOFF.md`.

This repo is a disassembly only: labelled 16-bit x86 assembly (NASM) that reassembles to the byte-identical `HOCKEY.EXE`. No C, no compiler.

## Hard rules

- Never change an EXE byte. Every commit must build to MATCH (SHA-1 `d94450ddff26528bddac6646c234277076fd36cb`).
- `lst/HOCKEY.EXE` is committed for now (temporary). Never commit anything else from the game (`.INT`, `.OVL`, data), `Extracted/`, `output/` or patches.
- Never force-push, never rewrite pushed history, never push a commit that does not MATCH. Small commits.
- No macros. No address where a label works.

## 1. Setup

NASM 2.15+ (`apt install nasm` / `brew install nasm`) and Python 3. If the EXE is missing, `./build.sh` prints the path, SHA-1, CRC32 and size.

## 2. Build and confirm MATCH

`./build.sh` (last line `MATCH output/HOCKEY.EXE`), `sh tools/verify_all.sh` (clean check, last line `MATCH`). If not MATCH on a fresh clone, stop and report.

## 3. Work loop

Every byte of `HOCKEY.EXE` is source: every routine and variable is named and commented, in the folders described in
`CONTRIBUTING.md`. The files are kept by hand (the generator that first wrote them is in `tools/archive/`).
For a change: edit, `./build.sh` (MATCH), `python3 tools/make_stubs.py` when a label used across files changed,
`sh tools/verify_all.sh`, `python3 tools/format_asm.py --check`, `python3 tools/check_comments.py`, commit, push,
open a PR to `main`, update `docs/HANDOFF.md`. The game logic lives in the external `.OVL` files, which this repo does
not disassemble yet.

## 4. When stuck

- Something that cannot be expressed without changing bytes: leave it and list it in `docs/HANDOFF.md`.
- 5 failed builds in a row: go back to the last MATCH state and note what was tried.
