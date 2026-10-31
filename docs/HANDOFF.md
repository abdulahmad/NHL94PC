# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `d94450ddff26528bddac6646c234277076fd36cb`, 244,854 bytes).
- seg000 startup is source, from `MscStartup` through `__chkstk` (`src/seg/seg000.asm`). The bytes before `MscStartup` and the bytes after `__chkstk` are still incbin. Every other segment is still incbin, except the MZ header fields (`src/header/mz_header.asm`).
- Structure pass is done. The `ovl_*` slices were not resliced. Two false splits are marked in `SEGMENT_AGENT.md` and stay as their own incbin files until the segment that owns them is disassembled.

## Known facts

- 16-bit real-mode MZ: header 0x1C00 bytes (1727 relocations), load image 123,975 bytes, then 113,711 bytes after the
  load module. Entry 1B35:082F (segment seg056, label `__astart`); stack segment past the image (`e_ss` 0x5400, `e_sp` 0x1800).
- Microsoft C medium model (far code, near data): "MS Run-Time Library - Copyright (c) 1990, Microsoft Corp", R6000-R6009 messages, "This program requires an
  80286". Linked with RTLink/Plus ("Internal error in .RTLink(R)/Plus run-time code" is in seg058).
- EACLIB error strings (`initmemman`, `reservemem`, `findmemblock`, `getmemblock`, `unpacka`) are in this EXE too: anchors for names.
- `lst/game/` has the external overlays and the data files for now (temporary, same as the EXE). Overlay files read for this map:
  `AI.OVL`, `INIT.OVL`, `GAME.OVL`, `MENUS.OVL`, `STATS.OVL`, `LP.OVL`, `MOVIE.OVL`, `FADES.OVL`, `FADES1.OVL` through `FADES12.OVL`.

## seg000–seg058 boundaries

The load image was cut at every paragraph named by a relocation (the segment value stored in a relocated word, or the segment of the
relocation entry itself) plus the entry segment. That made 59 slices. A paragraph is a real linker segment when far calls use it as CS,
or when it is the entry segment. A paragraph is a false split when the bytes belong to the previous segment and the only reason it was
cut is a normalized pointer or a relocation frame in the middle of that segment.

**Real (57):** seg000–seg010, seg012–seg056, seg058. That includes three slices that contain no relocation of their own but are still real,
because far calls name their paragraph:

- seg003, paragraph `0x0837`, 16 bytes. One far function (`push bp` … `retf`). seg002 ends on the previous paragraph with `retf`.
- seg030, paragraph `0x148B`, 96 bytes. Far calls enter at offset 4, which is the `enter` of its first function. The four bytes in front of
  that are the previous function's epilogue.
- seg047, paragraph `0x160C`, 32 bytes. Far calls enter at offset 8 (`push bp`). The bytes in front of that are the previous function's
  epilogue.

**False splits (2), merge when disassembling, do not treat as their own segment:**

- seg011, paragraph `0x0C15`, 16 bytes, into seg010. The slice is the tail of the function that starts at seg010+6 (`push bp` at file
  `0xDD16`) through `leave` / `retf`, then padding. The one far call that stores segment `0x0C15` uses offset `0xE`, the padding `retf`.
  That is the same address as seg010:`0x4E`, written normalized (offset under 16).
- seg057, paragraph `0x1D33`, 2832 bytes, into seg056. Nothing stores segment `0x1D33`. The 19 far calls in the root that land in these bytes store
  segment `0x1B35` and an offset past `0x1FE0` (the end of the seg056 slice). The bytes are 15 zero bytes, then 281 thunks of 10 bytes:
  `call` seg056:`0x05F8`, `jmp far <overlay>:<offset>`, `dw <segment index>`. The near call only reaches the loader if CS is seg056.
  The relocation entries for the `jmp far` segment words are framed at paragraph `0x1D33`, which is why the cut exists.

A real boundary is not a clean instruction boundary. The linker starts the next segment on a paragraph, and the previous function's last
instruction runs a few bytes into that paragraph. The new function (`enter` or `push bp`) starts just after the `retf`. Checked at file
`0x5630` (seg000/seg001: `pop bp` / `ret 0xe` just past the cut), `0xAB90` (seg004/seg005: a near call straddles, then `leave` / `retf`,
`enter` at `0xAB98`), `0xB720` (seg007/seg008: a near call straddles, `retf` at `0xB729`, `enter` at `0xB72A`). Do not merge those.

seg056 is the resident RTLink manager plus the DOS entry (`__astart` at offset `0x082F`). seg058 is the resident error helper: it prints
"Fatal Error" and "Internal error in .RTLink(R)/Plus run-time code." (INT 21h AH=09h, AH=46h). The manager calls it.

## The 113,711 bytes after the load module

DOS loads only the module sized by `e_cp` / `e_cblp` (file offset 131143 = `0x20047`). The 113,711 bytes after that are not a DOS overlay
and not the external `.OVL` files. They are **one RTLink dynamic segment**, record 20 of the table below, whose file name in the table is
`HOCKEY.EXE`. The manager loads it at startup (flag bit `0x01`) to paragraph `0x3415`.

Laid out from the end of the DOS module:

| bytes | what |
|---|---|
| 9 | zeros, finishing the file paragraph the load module ended in (it ends 7 bytes into a paragraph). The segment starts at file offset 131152 = paragraph `0x2005`. |
| 4624 | 1156 relocation entries, 4 bytes each: offset, then segment. The loader adds the program load segment to the word at that address. Most entries are framed at paragraph `0x342F`. |
| 109078 | the segment image. The record asks for 6818 paragraphs (109,088 bytes); the file ends 10 bytes short of that. The last 26 bytes of the file are the linker stamp at file `0x3BC5C` ("explicitly generated" and a short trailer). |

9 + 4624 + 109078 = 113,711. The 28 `ovl_*` files are this run cut every 4KB. They are not 28 segments.

## How each .OVL is loaded

Resident code is seg056 (CS `0x1B35`), including the thunks currently sliced off as seg057. The dynamic-segment table is 21 records of 18
bytes at seg056:`0x0D33`. The count, 21, is the word at seg056:`0x0D2D`. Record `i` is segment index `i`.

Each record:

| offset | meaning |
|---|---|
| 0 | load paragraph, relative to the program image (the same kind of paragraph the MZ relocations store) |
| 2 | seg056 offset of the byte before the file name. Names are 128-byte slots. That byte is a status flag (bit 0 set means the file is open). |
| 4 | low word of the file position, in paragraphs. 0 for every external `.OVL`. `0x2005` for the segment stored in the EXE. |
| 6 | high byte of that position in the low byte; flags in the high byte |
| 8 | memory size in paragraphs (also how much the loader clears) |
| 0xA | number of relocation entries |
| 0xC | `0xFFFF`, or 3 (INIT, AI), or 7 (FADES1–FADES12). Not read on the load path traced here. |
| 0xE | section number passed to the seg058 error helper. It is the record index plus 2. |
| 0x10 | paragraphs of image to read from the file |

Flag byte (high byte of the word at +6): bit `0x01` preload at startup (the EXE segment only); bit `0x02` set when the segment is resident;
bit `0x04` set on every external `.OVL`; bit `0x08` the name pointer is indirect; bit `0x20` a different read path (a far call the manager
patches). The external files all have `0x04`. The EXE segment has `0x01`.

An external `.OVL` is one segment. It starts with `count * 4` bytes of relocation entries (offset, segment), then the image. The image in
the file is within a few bytes of the paragraph count at +0x10 (the count is the memory size; the file holds the initialized bytes). A
relocation's segment is the load paragraph, or a paragraph inside the loaded image (MOVIE's entries are all paragraph `0x3357`, 14
paragraphs into the `0x3349` load). Checked against every `.OVL` named above.

Call path:

1. A far call in the root targets a thunk. The thunk near-calls seg056:`0x05F8`, then `jmp far` to the overlay function, then a word that is
   the segment index.
2. The loader reads that index and pushes a 6-byte frame on its reload stack. The stack's index, base, segment and limit are the seg056 words at
   `0x0B72`, `0x0B74`, `0x0B76` and `0x0B78`. It then calls seg056:`0x025C`.
3. `0x025C` indexes the 18-byte table (`index * 18 + 0x0D33`). If bit `0x02` is set, the segment is already resident and it returns.
   Otherwise it drops any resident segment whose load range overlaps this one.
4. It opens the name (INT 21h AH=3Dh). If the name ends in `.exe` it uses the running EXE instead of a new file. Seek is INT 21h AH=42h,
   read is AH=3Fh. Failures use the strings "Cannot find overlay file", "Open error on overlay file", "Read error on overlay file" and
   "Commit error - section".
5. It reads the image into the load paragraph, then reads the relocation entries and adds the program load segment (PSP + `0x10`, saved at
   seg056:`0x0B98` during `__astart`) to each fixed-up word.
6. Returning from the overlay pops the reload stack (seg056:`0x07C4`) and reloads the caller's segment if it was an overlay. The strings
   "Overlay Manager Internal Reload Stack Overflow" and "Underflow" are that stack.

`__astart` (seg056:`0x082F`) saves the PSP, walks the 21 records, preloads any record with flag bit `0x01` (only the in-EXE segment), then
far-jumps to the C startup.

Segments that share a load paragraph are swapped. One resident segment per address:

| load paragraph | files | note |
|---|---|---|
| `0x1E45` | `MENUS.OVL`, `LP.OVL`, `STATS.OVL`, `GAME.OVL` | first paragraph after the DOS image. Largest is MENUS, 4681 paragraphs, through `0x308E`. |
| `0x1F9C` | `INIT.OVL`, `AI.OVL` | AI is 5037 paragraphs and ends at `0x3349`. Overlaps the tail of the `0x1E45` region. |
| `0x3349` | `MOVIE.OVL`, `FADES.OVL` | FADES is 15 paragraphs, so it ends at `0x3358`. MOVIE is 204 paragraphs and ends at `0x3415`. |
| `0x3358` | `FADES1.OVL`–`FADES12.OVL` | one at a time. Immediately after FADES, and inside MOVIE's span. |
| `0x3415` | the segment in `HOCKEY.EXE` | preloaded. 8555 paragraphs reserved, 6818 paragraphs read. |

Thunks in the resident EXE call indexes 0 MENUS (76), 1 LP (26), 2 STATS (63), 3 GAME (3), 4 INIT (26), 5 AI (81), 6 MOVIE (4), 11 FADES4 (1),
19 FADES12 (1). `FADES.OVL` and the other `FADES*.OVL` files have no resident thunk; a thunk in another overlay calls them.

## From NHL94PCDemo

- Its HANDOFF/PLAN: MSC large model, cdecl far calls (`call far` / `add sp,n`), prologue `enter n,0; push di; push si`, `_main`-style
  names, EACLIB names from error-string xrefs, the naming order and clash/casing rules (adapted here with 93S first, as Abdul set for 94PC).
- Its `tools/rebuild_exe.py` (MZ split/rebuild) idea is what `segmap.json` + `tools/extract.py` + the NASM header source do here.
- Not taken: its plan's compiler identification and C matching steps (this repo is disassembly only), and the committed `.lst`.

## From NHL95PC (overlay loading only)

NHL 95 PC does not load code overlays. Its retail EXE is one Watcom LE image bound to DOS/4GW, not an RTLink MZ. Files read:

- `/tmp/nhl95pc/README.md` — `HOCKEY.EXE` is a Watcom C/C++32 10.0 Linear Executable bound to DOS/4GW. No `.OVL`, no RTLink.
- `/tmp/nhl95pc/HANDOFF.md` — same EXE (1,179,067 bytes, SHA-1 `3961e0eba6b0338fad1613bb534efafd9406ed4a`), built as one image.
- `/tmp/nhl95pc/src/c/004_13320_asset_loading/LoadTransparentRinkEndOverlay.c` — the only "overlay" loader. It loads the graphics bank
  `TRINKND.PPV` (via `MakePath` / `str_PPV`), not code.

A search of that tree for `RTLink`, `.OVL` and an overlay manager found nothing else. Nothing there describes the 94 thunks or the `.OVL`
file layout. The 94 load path above is from this EXE and `lst/game/`.

## seg000 startup

`__astart` far-jumps to `MscStartup`. That checks for DOS 2, sets SS to DGROUP, shrinks the memory block, zeros the BSS, calls two stubs in seg005, calls `InitRuntime`, pushes three near words (environ, argv, argc) and calls `_main`, then `_exit`.

`_main` is not in seg000. The call is `seg005` offset 8, and those bytes are a single `retf`. The two calls just before `InitRuntime` are seg005 offsets 6 and 4, also each a `retf`. They are named `NullStartup6` and `NullStartup4` until the real symbols are settled.

The `_main` call pushes three words, so the pointers are near. That is the medium model (far code, near data). The earlier "large model" note came from the far calls; medium model has those too.

## Unsure / open

- `NullStartup6` and `NullStartup4` (seg005 offsets 6 and 4). Each is a `retf`. The usual MSC pair in that slot is `__FPMATH` and `__fptrap`, or the null `__setargv` and `__setenvp`. The bodies are identical, so neither pair is named yet.
- `InitRuntime` does the divide-handler install, the `_C_FILE_INFO` inherit, the `_osfile` device bits and `_initterm`. It is one far function. The MSC library symbol for that whole function was not confirmed.
- `_initterm` here walks the far-pointer table from the top down. Later MSC `_initterm` walks upward. The name is the job; the direction is this copy's.
- `FpFail` (offset `0x162E`, still incbin) is `mov ax, 2` then a jump to `AmsgExit`. That is the R6002 path. The public name is not confirmed.
- The word at record offset `0x0C` (`0xFFFF`, or 3, or 7). The load path traced does not read it.
- Flag bit `0x20` (the patched far call on the other read path) was not followed. None of these 21 records has that bit set.
- seg058's calls are the error helper and the file open/seek used by the manager. The individual functions in seg058 are not named yet.
