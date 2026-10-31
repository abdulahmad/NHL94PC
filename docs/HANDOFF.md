# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `d94450ddff26528bddac6646c234277076fd36cb`, 244,854 bytes).
- seg056 is source: the resident RTLink/Plus manager and the overlay thunks (10,992 bytes). The old seg057 was the tail of that
  segment and is not a segment of its own. Everything else is still incbin except the MZ header fields. Next in file order: seg000.

## Known facts

- 16-bit real-mode MZ: header 0x1C00 bytes (1727 relocations), load image 123,975 bytes, then 113,711 bytes after the
  load module. Entry 1B35:082F (segment seg056); stack segment past the image.
- Microsoft C large model: "MS Run-Time Library - Copyright (c) 1990, Microsoft Corp", R6000-R6009 messages, "This program requires an
  80286". Linked with RTLink/Plus ("Internal error in .RTLink(R)/Plus run-time code"); overlays `AI.OVL`, `GAME.OVL`, `INIT.OVL`, `LP.OVL`,
  `MENUS.OVL`, `MOVIE.OVL`, `STATS.OVL`, `FADES*.OVL` are separate files.
- EACLIB error strings (`initmemman`, `reservemem`, `findmemblock`, `getmemblock`, `unpacka`) are in this EXE too: anchors for names.
- seg056 paragraph 0x1B35. DOS enters at `__astart` (offset 0x082F). That saves the PSP, sets up the overlay manager, and jumps far to
  seg000:0x04CA, the Microsoft C startup. The thunks call `LoadFromThunk` at 0x05F8. There are 21 section records of 18 bytes at 0x0D33
  (one per overlay file, then `HOCKEY.EXE`). No `_malloc` or `__chkstk` in this segment.
- NHL 95 PC was checked for names. It is Watcom C/386 (`cstart`, `__STK`, `__GETDS`) and has no RTLink manager and no `__astart`, so it
  did not supply names here.

## From NHL94PCDemo

- Its HANDOFF/PLAN: MSC large model, cdecl far calls (`call far` / `add sp,n`), prologue `enter n,0; push di; push si`, `_main`-style
  names, EACLIB names from error-string xrefs, the naming order and clash/casing rules (adapted here with 93S first, as Abdul set for 94PC).
- Its `tools/rebuild_exe.py` (MZ split/rebuild) idea is what `segmap.json` + `tools/extract.py` + the NASM header source do here.
- Not taken: its plan's compiler identification and C matching steps (this repo is disassembly only), and the committed `.lst`.

## Unsure / open

- The 113,711 bytes after the load module: RTLink overlay table or internal overlays? (`ovl_*` files.)
- The game's `.INT`, `.OVL` and data files are not available.
- Some segment bases from relocations may be data pointers that happen to be relocated, or two bases one compiler segment.
- seg056:0x0D00 (four zero bytes) and seg056:0x0D10 through 0x0D20 are not read by this segment. The byte at 0x0B71 is not read either.
- The seg058 routines called from seg056 (`RtlSectionHook`, `RtlWriteText`, `RtlSaveVectors`, `RtlSetHandler`, `RtlAfterFiles`,
  `RtlBeforeClose`, `RtlFindFile`, `RtlExePath`) are named from the call sites. seg058 is still incbin. Its first three bytes finish
  `OvlThunk281` (the far jump's segment high byte and the section index); `stc` / `retf` is at seg058:0003.
- The far call in `LoadSection` to 0000:0000 is a compressed-section hook and is stored as zeros.
- `ReturnBytePtr` is written from the reload return hook; what that byte represents is not pinned down.
