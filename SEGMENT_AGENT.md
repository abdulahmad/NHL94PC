# NHL 94 PC segment agent

This file is the queue and the history. Do not rewrite it as a whole file. Edit it in place.
(Adapted from NHL94SNES, NHL95PC and NHL94PCDemo.)

## Current rules (Oct 2026)

This repo is a **disassembly only**: labelled 16-bit x86 assembly that reassembles byte-identical with NASM. No C decompilation and no
compiler matching.

Naming lineage: 92G -> 93G -> 93S; 94G; **94PC from 93S plus the 94G features** (and a new PC front end); 94PC demo is this code base before release.
- Name priority, matched by purpose (calls, constants, structure fields, strings, what the code does), not identical code:
  1. the **NHLPA93SNES** name (its names already carry 93G and 92G), else
  2. the **NHL94Genesis** name (one-timers, breakaways and the other 94 features), else
  3. EACLIB (`c:\eaclib\%s` library): EA's own function names from the error strings, exact spelling, lower case: `unpacka`,
     `initmemman`, `emmcopybuf`, `reservemem`, `resizememblock`, `findmemblock`, `getmemblock` (EMS via `EMMXXXX0`), given to the
     function that references the string. Microsoft C runtime routines keep their library names (`__astart`, `_malloc`, `__chkstk`, ...).
  4. a name already given in NHL94PCDemo for the same routine, else
  5. a name from what the code clearly does, with the evidence in `docs/name_map.csv`.
- Earlier games' names win. NHL95PC is a later game: use it to understand PC-only systems, not as a naming source over 93S/94G.
- Clash rule: the earliest game's meaning keeps a name; the later item gets a new one.
- Casing: keep the source game's casing exactly; names from behaviour use CamelCase. Never two names that differ only in case.
- C symbols keep their cdecl leading underscore in asm (`_main`).

Source style (same as the sibling repos):
- No rename-history, provenance or origin-tag comments ("was X", "from 93G", "renamed"). That history lives in `docs/name_map.csv` only.
- No hardcoded addresses in comments, and no hand-kept derived counts (sizes, numbers of entries, totals) the assembler can compute.
- Never write an address where a label works: pointers, table offsets and sizes are label expressions. A number is only for a
  value with no label yet (inside a still-incbin segment), or an incbin split point.
- No macros. Plain instructions and data directives only.
- Local labels in 92 style: `.loop`, `.next`, `.done`, `.exit`, and plain numbers for trivial jumps.
- File headers are short plain-English stories of what the file does.
- Never reuse a name for a different item (clash rule: the earliest game's meaning keeps the name; the later item gets a new one).
- No guessing: a wrong name is worse than an auto name. Unsure items go under Unsure in `docs/HANDOFF.md`.

## Current segment

seg001. <- CURRENT

## Sources

- Reference EXE: `lst/HOCKEY.EXE` (committed for now, temporary). The other game files are in `lst/game/` for now, the same way, and are
  not committed as source. Overlays used for the load path below: `AI.OVL`, `INIT.OVL`, `GAME.OVL`, `MENUS.OVL`, `STATS.OVL`, `LP.OVL`,
  `MOVIE.OVL`, `FADES.OVL`, `FADES1.OVL`–`FADES12.OVL`.
- Each segment starts as an `incbin` of its bytes from `Extracted/segments/` (cut by `tools/extract.py` from `segmap.json`).
- Segments: the MZ load image is cut at every segment base the relocations name (the segment numbers stored at the relocated words, plus
  the relocation sites' own segments and the entry segment). Two adjacent bases may belong to one compiler segment; merge them if so. A
  segment can also be split further: add a file in the same `section`, cut the incbin with `incbin "<file>", <start>, <length>`.
- Boundary check (2026-10-31), detail in `docs/HANDOFF.md`: 57 of the 59 cuts are real linker segments. Two are false splits — merge them
  into the previous segment when that segment is disassembled, do not disassemble them on their own:
  - `seg011` (paragraph `0x0C15`, 16 bytes) into `seg010`. The bytes are the tail of seg010's function plus padding. The far call that
    names `0x0C15` is that address written normalized (offset under 16).
  - `seg057` (paragraph `0x1D33`, 2832 bytes) is merged into `seg056`. It was the thunk tail. Callers use segment `0x1B35`
    with offsets past `0x1FE0`. Every thunk near-calls `LoadFromThunk`.
- A real boundary still usually has the previous function's last few bytes on the next paragraph (`leave` / `retf`, sometimes the tail of
  a near call), and the new function's `enter` or `push bp` a few bytes later. That spill is not a false split. Do not merge two segments
  whose far calls use different paragraphs.
- The 28 `ovl_*` files are arbitrary 4KB slices of one RTLink dynamic segment stored after the DOS load module (113,711 bytes). They are
  not 28 overlays. The external overlays are the `.OVL` files. How each one is loaded is in `docs/HANDOFF.md`. Reslice `ovl_*` to the
  relocation list and the image when that area becomes source; do not disassemble it before that.
- Names: NHLPA93SNES (https://github.com/abdulahmad/NHLPA93SNES), NHL94Genesis (https://github.com/abdulahmad/NHL94Genesis),
  NHL94PCDemo (https://github.com/abdulahmad/NHL94PCDemo). NHL95PC was compared for overlay loading only; it has none (see HANDOFF).

## Build and verify

- `./build.sh`: prebuild check, `nasm -f bin -I src/ src/hockey94pc.asm` -> `output/HOCKEY.EXE`, SHA-1 compare. MATCH or MISMATCH.
- `sh tools/verify_segment.sh <segment>`: assembles `src/stubinc/<segment>_stub.asm` alone (`output/seg/`) and compares with the EXE range,
  then the full build's range. `--all` for every segment.
- `sh tools/verify_all.sh`: deletes output/ and Extracted/, rebuilds, checks every segment. Last line MATCH or FAIL.

## Segment files and stubs

- A segment file has no `section` or `org`: `src/hockey94pc.asm` puts it in its section (`segNNN align=16 vstart=0`, so labels are offsets
  in the segment); its stub carries `bits 16` and the `org`.
- Outside labels a segment uses: equates in its stub (values from the EXE). A label another converted segment defines: an equate in your
  stub only (the full build has the label itself).
- NASM limits: an expression that divides or shifts an address from another section is not allowed in a bin build, so MZ fields such as
  `e_cs`, `e_cp` and `e_cblp` stay numbers with comments. Within one section, label differences work.
- Far pointers and `call far` targets: the segment part is a relocated word. Write it as a number with the target segment's name in the
  comment; do not change the relocation table.

## History

- 2026-10-31: seg001 through `FillFarZero` is source. It fills a far buffer the same way `CopyFar` copies one. The body at `0x29D2` is still incbin.
- 2026-10-31: seg001 through `CritRestore` is source (EMS map, far copies, INT 24h). The rest of seg001 is still incbin.
- 2026-10-31: seg005 is source. `NullStartup4` and `NullStartup6` are each a `retf`. `_main` at offset 8 is `enter 0x24, 0` and the rest of the segment, not a lone `retf`.
- 2026-10-31: seg000 finished. The floating-point emulator is source (`FpConvert`, `FpExec`, and the helpers after it). Nothing in seg000 is incbin.
- 2026-10-31: seg000 number helpers after `_output`: `_atol`, `fflush`, `_memmove`, `_memset`, and the float-format helpers. The emulator is still incbin.
- 2026-10-31: seg000 formatted output: `_flsbuf`, `_stbuf`, `_ftbuf`, `_output`.
- 2026-10-31: seg000 from `__chkstk` through `DosMapErr`: `_printf`, `_open`, `_read`, `_write`, `_close`, `_lseek`, the `_dos_*` calls, `_strcpy` / `_strlen` / `_strncpy`, `rand`, the long helpers, and the runtime messages.
- 2026-10-31: seg000 VGA copies in front of `MscStartup`: `_outp`, `_inp`, and the latched VGA copies (`VgaCopyWrapped`, `VgaCopyToPitch`, `VgaCopyFromPitch`, `VgaStamp8`, `VgaPageFlip`, `VgaStorePlanes`, `VgaCopyStrip`, `VgaCopyBlock`, `VgaCopyBytes`, `VgaCopyRect`).
- 2026-10-31: seg000 startup. `MscStartup` (where `__astart` jumps), `__cintDIV`, `InitRuntime`, `_exit` / `__exit` / `_cexit` / `__cexit`, `_initterm`, `__chkstk`. `_main` is the far call to seg005 offset 8 (still a `retf` in that incbin). The rest of seg000 is still incbin.
- 2026-10-31: structure map only (no segment disassembled). 57 of seg000–seg058 are real linker segments; seg011 and seg057 are false
  splits (merge into seg010 and seg056). The 113,711 bytes after the load module are one preloaded RTLink segment (relocation list, then
  image). Each `.OVL` is one dynamic segment, loaded by the thunks in seg056. Detail in `docs/HANDOFF.md`.
- 2026-10-31: bootstrap. 88 incbin segments (MZ header, 59 image segments, 28 overlay-area chunks), a stub per
  segment, prebuild EXE check, extractor, NASM build and verify (MATCH). Trial: MZ header fields as source, `reloc_table`, `image_start`,
  `__astart`.
- 2026-10-31: seg056 disassembled (resident RTLink/Plus manager, `__astart`, overlay thunks). seg057 was the thunk tail
  (15 zero bytes, then the thunks) and is merged into seg056. No `_malloc` or `__chkstk` in this segment.

## Segment map

| File | Status | File offset | Bytes | MZ paragraph |
|---|---|---|---|---|
| mz_header | incbin (MZ header fields are source) | 0x00000 | 7168 |  |
| seg000 | source | 0x01C00 | 14896 | 0x0000 |
| seg001 | source through FillFarZero, rest incbin <- CURRENT | 0x05630 | 13280 | 0x03A3 |
| seg002 | incbin | 0x08A10 | 5472 | 0x06E1 |
| seg003 | incbin | 0x09F70 | 16 | 0x0837 |
| seg004 | incbin | 0x09F80 | 3088 | 0x0838 |
| seg005 | source (_main, two retf stubs) | 0x0AB90 | 1040 | 0x08F9 |
| seg006 | incbin | 0x0AFA0 | 752 | 0x093A |
| seg007 | incbin | 0x0B290 | 1168 | 0x0969 |
| seg008 | incbin | 0x0B720 | 9408 | 0x09B2 |
| seg009 | incbin | 0x0DBE0 | 304 | 0x0BFE |
| seg010 | incbin | 0x0DD10 | 64 | 0x0C11 |
| seg011 | incbin (false split, merge into seg010) | 0x0DD50 | 16 | 0x0C15 |
| seg012 | incbin | 0x0DD60 | 192 | 0x0C16 |
| seg013 | incbin | 0x0DE20 | 2592 | 0x0C22 |
| seg014 | incbin | 0x0E840 | 208 | 0x0CC4 |
| seg015 | incbin | 0x0E910 | 1664 | 0x0CD1 |
| seg016 | incbin | 0x0EF90 | 608 | 0x0D39 |
| seg017 | incbin | 0x0F1F0 | 192 | 0x0D5F |
| seg018 | incbin | 0x0F2B0 | 144 | 0x0D6B |
| seg019 | incbin | 0x0F340 | 448 | 0x0D74 |
| seg020 | incbin | 0x0F500 | 5312 | 0x0D90 |
| seg021 | incbin | 0x109C0 | 1760 | 0x0EDC |
| seg022 | incbin | 0x110A0 | 1008 | 0x0F4A |
| seg023 | incbin | 0x11490 | 224 | 0x0F89 |
| seg024 | incbin | 0x11570 | 32 | 0x0F97 |
| seg025 | incbin | 0x11590 | 112 | 0x0F99 |
| seg026 | incbin | 0x11600 | 1216 | 0x0FA0 |
| seg027 | incbin | 0x11AC0 | 48 | 0x0FEC |
| seg028 | incbin | 0x11AF0 | 18768 | 0x0FEF |
| seg029 | incbin | 0x16440 | 112 | 0x1484 |
| seg030 | incbin | 0x164B0 | 96 | 0x148B |
| seg031 | incbin | 0x16510 | 192 | 0x1491 |
| seg032 | incbin | 0x165D0 | 432 | 0x149D |
| seg033 | incbin | 0x16780 | 560 | 0x14B8 |
| seg034 | incbin | 0x169B0 | 288 | 0x14DB |
| seg035 | incbin | 0x16AD0 | 304 | 0x14ED |
| seg036 | incbin | 0x16C00 | 128 | 0x1500 |
| seg037 | incbin | 0x16C80 | 592 | 0x1508 |
| seg038 | incbin | 0x16ED0 | 928 | 0x152D |
| seg039 | incbin | 0x17270 | 48 | 0x1567 |
| seg040 | incbin | 0x172A0 | 96 | 0x156A |
| seg041 | incbin | 0x17300 | 864 | 0x1570 |
| seg042 | incbin | 0x17660 | 1136 | 0x15A6 |
| seg043 | incbin | 0x17AD0 | 64 | 0x15ED |
| seg044 | incbin | 0x17B10 | 224 | 0x15F1 |
| seg045 | incbin | 0x17BF0 | 112 | 0x15FF |
| seg046 | incbin | 0x17C60 | 96 | 0x1606 |
| seg047 | incbin | 0x17CC0 | 32 | 0x160C |
| seg048 | incbin | 0x17CE0 | 544 | 0x160E |
| seg049 | incbin | 0x17F00 | 3104 | 0x1630 |
| seg050 | incbin | 0x18B20 | 5408 | 0x16F2 |
| seg051 | incbin | 0x1A040 | 960 | 0x1844 |
| seg052 | incbin | 0x1A400 | 656 | 0x1880 |
| seg053 | incbin | 0x1A690 | 256 | 0x18A9 |
| seg054 | incbin | 0x1A790 | 9968 | 0x18B9 |
| seg055 | incbin | 0x1CE80 | 208 | 0x1B28 |
| seg056 | source (RTLink manager, __astart, thunks) | 0x1CF50 | 10992 | 0x1B35 |
| seg058 | incbin | 0x1FA40 | 1543 | 0x1DE4 |
| ovl_00000 | incbin | 0x20047 | 4096 |  |
| ovl_01000 | incbin | 0x21047 | 4096 |  |
| ovl_02000 | incbin | 0x22047 | 4096 |  |
| ovl_03000 | incbin | 0x23047 | 4096 |  |
| ovl_04000 | incbin | 0x24047 | 4096 |  |
| ovl_05000 | incbin | 0x25047 | 4096 |  |
| ovl_06000 | incbin | 0x26047 | 4096 |  |
| ovl_07000 | incbin | 0x27047 | 4096 |  |
| ovl_08000 | incbin | 0x28047 | 4096 |  |
| ovl_09000 | incbin | 0x29047 | 4096 |  |
| ovl_0A000 | incbin | 0x2A047 | 4096 |  |
| ovl_0B000 | incbin | 0x2B047 | 4096 |  |
| ovl_0C000 | incbin | 0x2C047 | 4096 |  |
| ovl_0D000 | incbin | 0x2D047 | 4096 |  |
| ovl_0E000 | incbin | 0x2E047 | 4096 |  |
| ovl_0F000 | incbin | 0x2F047 | 4096 |  |
| ovl_10000 | incbin | 0x30047 | 4096 |  |
| ovl_11000 | incbin | 0x31047 | 4096 |  |
| ovl_12000 | incbin | 0x32047 | 4096 |  |
| ovl_13000 | incbin | 0x33047 | 4096 |  |
| ovl_14000 | incbin | 0x34047 | 4096 |  |
| ovl_15000 | incbin | 0x35047 | 4096 |  |
| ovl_16000 | incbin | 0x36047 | 4096 |  |
| ovl_17000 | incbin | 0x37047 | 4096 |  |
| ovl_18000 | incbin | 0x38047 | 4096 |  |
| ovl_19000 | incbin | 0x39047 | 4096 |  |
| ovl_1A000 | incbin | 0x3A047 | 4096 |  |
| ovl_1B000 | incbin | 0x3B047 | 3119 |  |
