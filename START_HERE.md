# START HERE (instructions for the agent)

Read this file, then `SEGMENT_AGENT.md` (rules, queue and history), `CONTRIBUTING.md` and `docs/HANDOFF.md`.

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

Run `PROMPT.md` once per segment, in file order. After each: MATCH, `sh tools/verify_segment.sh <segment>`, commit, push, update `docs/HANDOFF.md`.
Stop after one segment group (about 8 segments or 32 KB) and report.

## 4. When stuck

- Something that cannot be expressed without changing bytes: leave it and list it in `docs/HANDOFF.md`.
- 5 failed builds in a row: go back to the last MATCH state and note what was tried.
