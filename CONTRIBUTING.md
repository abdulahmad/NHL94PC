# Contributing to NHL 94 PC

A bit-perfect disassembly (no decompilation) of NHL Hockey ('94) for DOS, assembled with NASM.

Read [AGENTS.md](AGENTS.md) first (gates, credit). Who decides names and folders, and learned corrections:
[docs/RULES.md](docs/RULES.md). Where this repo stands: [docs/HANDOFF.md](docs/HANDOFF.md).

Work on a branch and open a pull request to `main`. `main` is the working branch: a PR whose build still MATCHes is
merged with a merge commit.

Any port, mod or fork carries the credit in AGENTS.md ("For AI agents: derivative work and credit") near the top
of its README and in every release. Add it first.

## Gates

- MATCH: `./build.sh` must print MATCH and `sh tools/verify_all.sh` MATCH before every push. A comment-only,
  layout-only or rename-only change must not change a byte.
- After adding or renaming a label used across files, run `python3 tools/make_ovl_syms.py` (the overlay builds).
- `python3 tools/format_asm.py --check` reports nothing, and `python3 tools/check_comments.py` prints `comments OK`.
- Pairing: after a move or rename, `tools/gate.sh` in nhl-disasm-report; no count may rise.
- Small commits; never force-push.

## Names

- Order: the 94 Genesis or 94 SNES name when the routine or variable does the same job (94G spelling), then the
  earlier lineage (93S, 93G, 92G), then the library's own names (Microsoft C runtime and floating-point emulator,
  EACLIB from its error strings, RTLink/Plus), then a name from what the code does. See docs/RULES.md.
- Rename with `python3 tools/rename.py docs/cleanup/names94_<batch>.txt` (`OLD NEW | source | confidence | evidence`).
  Every rename gets a row in `docs/name_map.csv` (`address,name,auto_name,source,confidence,evidence,file`).
  Lineage lives only in that file: never write another game's name in source comments.
- No macros. Labels instead of addresses wherever NASM can compute them. A far call names its target
  (`call 0x03A3:LargestFree`); the segment stays a number because the MZ relocation table points at it.

## Folders

- `src/engine/`: the game logic from the overlays (play, AI, physics, replay, HUD, faceoffs, penalties).
- `src/pc/`: DOS-only code (system services, EMS, heap, files, input devices, sound output, video).
- `src/front/`: the front end (start-up, menus, dialogs, statistics, league and play-off modes, crowd and announcer,
  saving), from the EXE and the overlays.
- `src/lib/`: libraries: `msc_runtime.asm` and `fp_emulator.asm` (Microsoft C), `eaclib/` (EA sound library),
  `rtlink/` (the RTLink/Plus overlay manager and runtime).
- `src/data/`: DGROUP (`dgroup.asm` includes the subject files of `dgroup/` in link order; `dgroup_bss.asm`), the far data segments (`far/`), the RTLink relocations.
- `src/header/`: the MZ header. `src/hockey94pc.asm` includes every file in EXE order; `segmap.json` lists each one.
- `src/ovl/<name>.asm`: one overlay: its relocation table, then its segment files in load order
  (`docs/cleanup/files_94pc_ovl.txt`). `src/ovl/<name>_syms.inc` and `_build.asm` are written by `tools/make_ovl_syms.py`.
- Files are named by topic, never by address. One file per linker segment; the section is named after the file.
  `docs/cleanup/files_94pc.txt` maps the old segment numbers to the files.
- A label in another segment is reached with `Label + delta` (delta = the paragraph distance times 16) for a jump, or
  `(Label - SegmentStart)` bytes when an instruction is split across the segment end; `DgroupStart` and
  `MscRuntimeStart` are such segment starts.
- The generator that first wrote the files is archived in `tools/archive/`; the files are now kept by hand.

## Comments

`python3 tools/check_comments.py` checks these rules (`--summary` gives a count per rule); a file you finish must come
out clean. A comment-only change must not change a byte (MATCH).

What to write:

- **Every routine** has a header between two rule lines: `; Name <spaces> SEGM:OFFS  SOURCE`, then what it does,
  what it takes (registers, stack arguments, globals it reads) and what it returns or changes. SOURCE is `94 PC`,
  `MSC`, `EACLIB`, `RTLink`, or the 94G/94S file the name comes from.
- **Every variable declaration** has a comment on its label line: data and BSS labels, tables and strings. Say what
  it holds (units, range, flag bits, entry size and count) and which routines use it. A string says where it is used.
- **Every file** starts with a header that says what the file holds and how it relates to its neighbours (for
  example, bytes at the start that finish a routine of the file before).
- Routines read as a story when you work on them: a short comment for each step, what the registers hold, why a
  branch is taken. Anything not obvious gets a comment: magic numbers, bit tests, code kept as bytes.
- Only write what you checked in the code. If you cannot tell why something is done, describe what the instructions
  do or write "probably". Never invent names.

What not to write:

- No IDA names (`sub_`, `loc_`, `unk_` ...). No raw addresses: write the label's name. The only addresses allowed
  are the SEGM:OFFS field of a routine header and a far data file's paragraph.
- No other game's names, no segment numbers (`seg022`), no history (`was X`, `renamed from`): that is in git and
  `docs/name_map.csv`.

Layout (`tools/format_asm.py` does it):

- Labels, comment lines, `%` lines and `equ` lines start in column 0; instructions and data are indented 8 spaces,
  one space between the mnemonic and its operands.
- A comment after an instruction starts at column 48, or one space after code that reaches past it. Its
  continuation lines start at column 48 too.
- No comment line is wider than 110 columns (data lines aside).
- An instruction kept as bytes (NASM would pick another encoding) is `db ...` with `; insn: <the instruction>`.
- A header or block comment has paragraphs of at most 3 lines (the header's name line counts), separated by a `;`
  line.

## Files

- Do not commit game files (`lst/HOCKEY.EXE` and `lst/game/` are your own copies), nor `Extracted/`, `output/`, `*.lst` or patches.

## Netplay security

Everything that comes over the network is hostile. The rules and a review checklist are in Overbar's
`port/overbar/docs/NETPLAY_SECURITY.md`; read them before changing netplay, a saved state, a file route or the season code. In short:
never run, load or write code from network data; a peer never chooses an address; check every length before use
(`len > size - at`, never `at + len > size`); validate a state before it is applied and clean it after; a peer's names are text, not paths.
`sh port/overbar/tests/netsec.sh .` must print `netsec ok` (CI runs it in the `netsec` job). When a change adds a network path or a state field,
add a hostile test for it.
