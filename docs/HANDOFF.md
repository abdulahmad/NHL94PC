# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `d94450ddff26528bddac6646c234277076fd36cb`, 244,854 bytes); `tools/verify_all.sh` MATCH.
- seg056 is source: the resident RTLink/Plus manager and the overlay thunks (10,992 bytes). seg057 was the thunk tail and is merged into seg056.
- seg000 is entirely source (`src/seg/seg000.asm`). Nothing in it is incbin. seg005 is source. seg001 is source from the start through `LineOverflow` (offset `0x2690`); the rest is incbin. Every other segment is still incbin, except the MZ header fields (`src/header/mz_header.asm`) and seg056.
- seg011 is still a false split (merge into seg010 when seg010 is disassembled). The `ovl_*` slices were not resliced.

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

**False splits:** seg057 is merged into seg056. One remains, merge it when that segment is disassembled:

- seg011, paragraph `0x0C15`, 16 bytes, into seg010. The slice is the tail of the function that starts at seg010+6 (`push bp` at file
  `0xDD16`) through `leave` / `retf`, then padding. The one far call that stores segment `0x0C15` uses offset `0xE`, the padding `retf`.
  That is the same address as seg010:`0x4E`, written normalized (offset under 16).
- seg057, paragraph `0x1D33`, 2832 bytes, is now the end of seg056. Nothing stores segment `0x1D33`. The far calls that land in these bytes store
  segment `0x1B35` and an offset past `0x1FE0`. The bytes are 15 zero bytes, then thunks of 10 bytes:
  `call LoadFromThunk`, `jmp far`, `dw` section index. The near call only reaches the loader if CS is seg056.
  The relocation entries for the `jmp far` segment words are framed at paragraph `0x1D33`, which is why the cut existed. The last thunk
  is split: its far jump continues in the first three bytes of seg058.

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

Resident code is seg056 (CS `0x1B35`), including the thunks. The dynamic-segment table is 21 records of 18
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
| 0xC | Value `LoadSection` returns in AX. `0xFFFF`, or 3 (INIT, AI), or 7 (FADES1–FADES12). If `ChainLoads` is set and this is not -1, that section is loaded next. |
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

## seg000 floating-point emulator

`FpConvert` turns a floating value into an integer, or zero when the exponent is out of range. `JmpFpConvert` jumps to it. `FpExec` is the emulator body: interrupts 34h through 3Dh stand in for the coprocessor. The long runs of zeros and `40h` bytes between those routines are the constant tables, left as data.

## seg000 number helpers

`_atol` reads a signed decimal string into a long. `fflush` flushes one FILE, or every open FILE when the pointer is null. `_memmove` and `_memset` are the near-pointer copies. `FpError` prints a floating-point error and exits. Several routines around them turn a floating value into text for `_output`; those names describe that job.

## seg000 formatted output

`_flsbuf` flushes one FILE. `_stbuf` and `_ftbuf` add and drop the temporary buffer around `_printf`. `_output` is the formatter. Its character switch is the eight words just before the routine.

## seg000 file and DOS routines

From `__chkstk` through `DosMapErr`: `_printf`, `_open` / `_sopen`, `_read`, `_write`, `_close`, `_lseek`, the `_dos_*` calls, `_strcpy`, `_strcat`, `_strlen`, `_strncpy`, `_stricmp`, `rand` / `srand`, `atexit` / `_onexit`, the long multiply and divide helpers, and the runtime messages (`__FF_MSGBANNER`, `__NMSG_TEXT`, `__NMSG_WRITE`, `__nullcheck`). `DosRet` is the shared success and error return.

## seg000 VGA copies

The bytes in front of `MscStartup` are `_outp`, `_inp`, and latched VGA copies (write mode 1, all four planes, segment `0xA000`). `VgaPageFlip` waits for the retrace and sets the CRT start address. Nothing in the retail EXE far-calls these; they are public far routines. NHL 95 PC's startup drawing (`DrawFrameSprite`, `FadePalette`, `SetScreenSize`) is not these copies.

## seg000 startup

`__astart` far-jumps to `MscStartup`. That checks for DOS 2, sets SS to DGROUP, shrinks the memory block, zeros the BSS, calls two stubs in seg005, calls `InitRuntime`, pushes three near words (environ, argv, argc) and calls `_main`, then `_exit`.

`_main` is seg005 offset 8. It is not a lone `retf`: it is `enter 0x24, 0` and the rest of that segment. `NullStartup4` (offset 4) and `NullStartup6` (offset 6) are each a single `retf`.

The `_main` call pushes three words, so the pointers are near. That is the medium model (far code, near data). The earlier "large model" note came from the far calls; medium model has those too.

## seg001 EMS and the critical-error hook

The spill at the start of seg001 finishes `test bx, 8`, then `pop bp` / `ret 0xe`. That is the tail of the seg000 routine. It is not merged back.

`EmsMap` is the near INT 67h AH=44h loop. `EmsInit` checks the driver name at offset 10 of the INT 67h vector against `EmmName`, allocates pages, and registers `EmsFree` with `_onexit`. The call that registers it is still a numeric far call: its target, offset `0x4AE`, is in the incbin tail. `HookCrit` installs `CritHandler` as INT 24h and registers `CritRestore` the same way.

`ReadEndPtr`, `SetEndMark`, `WaitEnd`, `EndReached`, and `WaitAdd` only read and spin on the far pointer at `EndPtr`. Nothing in this chunk writes that pointer except `SetEndMark`, which stores a sum of it.

`OnexitThunk` is `jmp _onexit`. `EmsInit` and `HookCrit` call it. `ExitSavedSp` loads DGROUP and, when `SavedSp` is nonzero, makes that word SP, then calls `_exit(0)`.

`PassFlag1`, `PassFlag0`, `AddrFlag0`, and `AddrFlag1` only set SI and the byte at `[bp-9]`. `ArgSetup` stores the arguments and jumps to offset `0x29D2`, which is still incbin. No far call in the EXE names those four entries.

`FileSize`, `FileSizeMsg`, and `FileSizeArg` open a path, seek to the end, close it, and return the length. `FileSizeMsg` is the far entry. A failed open returns 0, or calls seg022 when the flag word is nonzero.

`FileHeadArg`, `FileHead`, and `FileHeadMsg` read four bytes and return the 24-bit value in bytes 1..3 divided by 16, rounded up. `FindPath` and `FindNextPath` search with attribute 6 and build a full path in `PathBuf` from the directory and the DTA name. `LargestFree` is the failing AH=48h probe. `AllocBytes` stores `SavedCs`, `SavedDs`, and `SavedSp`, then allocates the requested paragraphs or the largest block.

`FoldScale` calls `Atan2`, then folds the angle into `0..100h` and divides a shifted argument by a second result. The two routines after the angle are still incbin. `MapEsBx` maps a long and returns ES:BX. `LookupArg`, `Lookup`, and `LookupMsg` search a 4-byte key in that block. A space matches a 0 in the key. A hit returns a long built from the record.

`FillFar` writes one byte through a far pointer for a long count. Offsets stay under 16, then the fill moves 32K at a time. `FillFarZero` writes zeros. The dword path is the same test `CopyFar` uses.

`LineOpen` orders two points into the record at `[bp+0Eh]` and stores a direction byte. `LineClip` does the same after a box test: both ends outside one edge is a reject. A line with no clip bits returns 0. `ClipTop`, `ClipBottom`, `ClipLeft`, and `ClipRight` slide the crossed end onto that edge. `AfterTop`, `AfterBottom`, and `AfterLeft` run the next edge when that outcode is still set. `LineFlat` is the equal-Y path. `LineOverflow` shifts an endpoint that sits far outside the box. The next bytes are still incbin.

`FindFar` and `FindFarMsg` look up a long key in a far table and return a far pointer. `FindFarList` and `FindFarQuiet` walk a list of keys. `FarToLinear` and `LinearToFar` convert between a far pointer and the 20-bit address. `LinearToFarRegs` does that conversion with the address already in DX:AX.

`CopyBytes` calls `CopyFar` with the high half of the count forced to zero. `FormatCall` pops a far return address and two words, calls `_sprintf` with `FmtBuf`, then calls seg028 and far-returns. `ImulWords`, `MulWords`, `IdivWords`, `DivWords`, `Idiv32`, and `IdivDword` are the multiply and divide helpers. `ImulRegs` and `MulRegs` are the register entries inside the first two.

`WriteFile` creates a file and writes a far buffer in 16K pieces. A short write or a DOS error deletes the file. `WriteFile` then calls seg022 and returns 0. `WriteFileCode` returns the error instead. `TableCount`, `TableAt`, and `TableStore` read the same kind of far table `FindFar` searches. `PathTail` points just past the last separator. `CopyStrN` copies up to a count. `StrnDiff` returns 0 when the bytes match through a null.

`TextWidth` sums per-character values from the table in `CharSeg`. `SaveCharTab`, `LoadCharTab`, and `UseCharSeg` copy and select that table. `HookInt8` points INT 8 at `Int8Handler`, writes `0xB6` to port `0x43` and `0x2E9C` to port `0x40`, and registers `UnhookInt8`. `AllocSlot` fills a free pair in the eight pairs at `SlotTab`. `FreeSlot` removes a matching pair. `Int8Handler` far-calls the pairs whose second word is nonzero, keeps the BIOS tick at `0:046Ch`, and turns the floppy motors off when the BIOS motor count hits 0. `ResetText` sets mode 3 when `WantText` is set.

`PollJoy` times the two axes on port `0x201` and sets bits in `JoyBits` when a count falls outside the inner range. `InitJoy` turns that read on and sets the initial limits. `JoyScaleX` and `JoyScaleY` scale a count against its low limit.

`PollSticks` times up to four axes. The mask is the byte at `JoyOn` in the table at `0x7074`. Bit 0 of `JoyOn` fills `Stick1Bits`. Bit 1 fills `Stick2Bits`. `InitStick1` and `InitStick2` are what `_main` calls. `ScaleStick1X` through `ScaleStick2Y` scale each axis.

`HookKbd` points INT 9 at `KbdIrq`, INT 16h at `Int16Hook`, and INT 23h at `BreakIrq`, and registers `UnhookKbd`. `KbdIrq` records the scan code and queues a translated byte. One path stores `0x1234` at `0:0472h` and jumps to `FFFF:0000`. `KeyService` is the INT 16h body. `BiosKey` is `int 0x16` / `ret`, used while the hook is removed.

`ReadCallCount` returns `CallCount`, the dword `Int8Handler` increments. `WaitKeyUntil` and `WaitKeyAdd` compare it with `Deadline`. The monochrome console writes the B000h buffer: `ConPrint` formats through `_sprintf`, and `ScrollMono` moves one row.

`WaitDeadline` sends a specific EOI for IRQ 0 and halts until `CallCount` reaches `Deadline`. `DeadlineReached` returns 1 when that has happened. `WaitCount` spins until `CallCount` has advanced by the long argument.

`MouseOpen` resets the mouse with INT 33h AX=0 and returns 0 when no driver answers. `MouseRead` is INT 33h AX=3 and stores buttons, X, and Y. `_main` calls both. `ReadPots` times four bits on port `0x201`. `MouseShow` and `MouseHide` are INT 33h AX=1 and AX=2 with a count.

## Unsure / open

- `NullStartup6` and `NullStartup4` are each a single `retf`. The usual MSC pair in that slot is `__FPMATH` and `__fptrap`, or the null `__setargv` and `__setenvp`. The bodies do not say which.
- `InitRuntime` does the divide-handler install, the `_C_FILE_INFO` inherit, the `_osfile` device bits and `_initterm`. It is one far function. The MSC library symbol for that whole function was not confirmed.
- `_initterm` here walks the far-pointer table from the top down. Later MSC `_initterm` walks upward. The name is the job; the direction is this copy's.
- `FpFail` is `mov ax, 2` then a jump to `AmsgExit`. That is the R6002 path. The public name is not confirmed.
- `JumpAhead` is a near jump into the bytes that are still incbin. Its target is not named yet.
- `StrIndexInSet` returns an index, not a pointer, so it is not named `_strpbrk`.
- `EmulatedFloat` uses the floating-point emulator interrupts. The operation it performs is not named.
- `CallArg` calls through a pointer argument. The library symbol is not confirmed.
- seg056:0x0D00 (four zero bytes) and seg056:0x0D10 through 0x0D20 are not read by this segment. The byte at 0x0B71 is not read either.
- The seg058 routines called from seg056 (`RtlSectionHook`, `RtlWriteText`, `RtlSaveVectors`, `RtlSetHandler`, `RtlAfterFiles`,
  `RtlBeforeClose`, `RtlFindFile`, `RtlExePath`) are named from the call sites. seg058 is still incbin. Its first three bytes finish
  `OvlThunk281`; `stc` / `retf` is at seg058:0003.
- Flag bit `0x20` selects the other read path (`call 0:0` in `LoadSection`). None of these 21 records has that bit set, and the far call is stored as zeros.
- `ReturnBytePtr` is written from the reload return hook; what that byte represents is not pinned down.
- `ReadEndPtr` and the four routines around it spin on `EndPtr`. The bytes do not say what advances that pointer.
- The word `CopyFar` tests at ss:`0x763C` selects dword moves. Its symbol is not named.
- `PassFlag1`, `PassFlag0`, `AddrFlag0`, `AddrFlag1`, and `ArgSetup` are named from the flag and the pointer they set. The body they jump to (offset `0x29D2`) is still incbin, so the job is not named.
- `FoldScale` calls `Atan2`, then the routines at `0x32EA` and `0x32F1`. Those two are still incbin, so the divide that follows the angle is not named.
- `FormatCall` is not the target of a far call in the EXE. The four pops are the far return address and two words. What `_sprintf` uses as its format is the word under those on the caller's stack.
- `HaltSpin` stores `0xFBEA` under SP and halts until that word changes or the count runs out. Nothing in this chunk writes that word.
- `ExitSavedSp` loads DGROUP and, when `SavedSp` is nonzero, uses that word as SP, then calls `_exit(0)`. `AllocBytes` is what stores `SavedSp`, along with CS and DS. Nothing in the disassembled bytes reads `SavedCs` or `SavedDs` yet.
