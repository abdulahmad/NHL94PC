# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `d94450ddff26528bddac6646c234277076fd36cb`, 244,854 bytes); `tools/verify_all.sh` MATCH (full build and all 88 segments built on
  their own).
- Everything is incbin except the MZ header fields (`src/header/mz_header.asm`). Next: seg000.

## Known facts

- 16-bit real-mode MZ: header 0x1C00 bytes (1727 relocations), load image 123,975 bytes, then 113,711 bytes after the
  load module. Entry 1B35:082F (segment seg056); stack segment past the image.
- Microsoft C large model: "MS Run-Time Library - Copyright (c) 1990, Microsoft Corp", R6000-R6009 messages, "This program requires an
  80286". Linked with RTLink/Plus ("Internal error in .RTLink(R)/Plus run-time code"); overlays `AI.OVL`, `GAME.OVL`, `INIT.OVL`, `LP.OVL`,
  `MENUS.OVL`, `MOVIE.OVL`, `STATS.OVL`, `FADES*.OVL` are separate files.
- EACLIB error strings (`initmemman`, `reservemem`, `findmemblock`, `getmemblock`, `unpacka`) are in this EXE too: anchors for names.

## From NHL94PCDemo

- Its HANDOFF/PLAN: MSC large model, cdecl far calls (`call far` / `add sp,n`), prologue `enter n,0; push di; push si`, `_main`-style
  names, EACLIB names from error-string xrefs, the naming order and clash/casing rules (adapted here with 93S first, as Abdul set for 94PC).
- Its `tools/rebuild_exe.py` (MZ split/rebuild) idea is what `segmap.json` + `tools/extract.py` + the NASM header source do here.
- Not taken: its plan's compiler identification and C matching steps (this repo is disassembly only), and the committed `.lst`.

## Unsure / open

- The 113,711 bytes after the load module: RTLink overlay table or internal overlays? (`ovl_*` files.)
- The game's `.INT`, `.OVL` and data files are not available.
- Some segment bases from relocations may be data pointers that happen to be relocated, or two bases one compiler segment.
