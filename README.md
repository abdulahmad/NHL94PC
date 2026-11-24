# NHL Hockey (NHL '94) for DOS

> **🤝 Making a mod, hack, port or other derivative work from this repo? You must credit me and everyone credited in this repo, clearly, in your own repo and in every release. See [Credits and derivative works](#credits-and-derivative-works).**

> **📀 Game files are not included.** Copy `HOCKEY.EXE` from your own NHL 94 install to `lst/HOCKEY.EXE`, and the whole install folder (the `.OVL` overlays and data files) to `lst/game/`. Both are gitignored; the build checks them by SHA-1 and size and tells you exactly what it needs when one is missing. Patch files are never committed.

> **📀 The other game files are still needed to run the game.** This repo builds `HOCKEY.EXE` and the 20 `.OVL` overlays. The data files (`*.INT`, `*.CFG`, `*.MAP`, `*.BIN`, `*.PPV` ...) are not built here; your own copy of the game folder goes in `lst/game/` (not in the repo), and the overlay build compares against the `.OVL` files there.

## 🚧 Current Status

- `HOCKEY.EXE` and all 20 RTLink overlays (`AI.OVL`, `GAME.OVL`, `INIT.OVL`, `LP.OVL`, `MENUS.OVL`, `MOVIE.OVL`,
  `STATS.OVL`, `FADES.OVL`, `FADES1.OVL`-`FADES12.OVL`) are fully disassembled: the MZ header and its relocation table,
  the 58 load-image segments, DGROUP, the far data segments and every overlay segment are labelled source, and the
  NASM build is byte-identical to the retail EXE and to each retail overlay. Every routine and variable has a name and
  a comment, labels stand where the code uses addresses (including far pointers in data and jumps across segment
  ends), and every file is named by topic (`src/engine`, `src/front`, `src/pc`, `src/lib`, `src/data`).
- Every overlay also builds on its own from `src/ovl/<name>_build.asm`.
- This is a **disassembly only**: labelled 16-bit x86 assembly that reassembles byte-identical. There is no C decompilation.

**AI agent or new contributor: start with [START_HERE.md](START_HERE.md).**

| | |
|---|---|
| File | `lst/HOCKEY.EXE` (any name in the repo folder works) |
| Size | 244,854 bytes |
| SHA-1 | `d94450ddff26528bddac6646c234277076fd36cb` |
| CRC32 | `D2905BC2` |
| Format | 16-bit real-mode DOS MZ, large model, built with Microsoft C (runtime "MS Run-Time Library - Copyright (c) 1990"), RTLink/Plus overlay linker |

## Lineage

NHL '94 PC is based on [NHLPA93SNES](https://github.com/abdulahmad/NHLPA93SNES) and [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis). Names come from those repos, matched by purpose: the 94 Genesis (or 94 SNES) name when a routine does the same job, then the earlier lineage, then the Microsoft C, EACLIB and RTLink library names. See CONTRIBUTING.md and docs/RULES.md. [NHL94PCDemo](https://github.com/abdulahmad/NHL94PCDemo) is the same code base before release and follows the same rules.

## Layout

- `src/hockey94pc.asm` includes the whole file in order: `section header` (MZ header), one `section <name> align=16 vstart=0` per MZ segment, named after its file (labels are offsets inside the segment, as the 16-bit code uses them), then `section overlay` (bytes after the load module).
- `src/engine/` the game logic (from the overlays), `src/pc/` DOS-only code, `src/front/` the front end, `src/lib/` the Microsoft C, EACLIB and RTLink libraries, `src/data/` DGROUP and the far data. `docs/cleanup/files_94pc.txt` maps the old EXE segment numbers to files, `docs/cleanup/files_94pc_ovl.txt` the overlay segments.
- `src/ovl/<name>.asm` builds one overlay: its relocation table, then its segment files in load order. `src/ovl/<name>_syms.inc` (written by `tools/make_ovl_syms.py`) gives it the EXE labels it uses; `ovlmap.json` lists the overlays.
- `segmap.json` lists every segment: name, file offset, size, source file, and the paragraph of the MZ segment.
- `tools/prebuild.py` checks the EXE (SHA-1, CRC32, size) and runs `tools/extract.py` (cuts it into `Extracted/segments/`, gitignored).

## Build

Needs NASM 2.15 (2.15.05; 2.16 encodes `xchg reg,reg` the other way round, so the EXE no longer matches; point `NASM=` at 2.15) and Python 3. `./build.sh` ends with `MATCH output/HOCKEY.EXE and the 20 overlays` (the overlays are compared with the retail files in `lst/game/`). Run `python3 tools/make_ovl_syms.py` after changing a label that another file or an overlay uses. `sh tools/verify_all.sh` deletes `output/` and `Extracted/`, rebuilds, checks every segment and runs `tools/check_spa.py` (the overlays' SPA labels against `src/data/frames.asm`), last line MATCH.

## Running the game on a modern PC (SDL2 port)

`port/` runs the retail `HOCKEY.EXE`, its overlays and EA's sound drivers on a built-in x86 CPU core (libx86emu), with DOS, the
BIOS, EMS, the VGA, the keyboard, mouse, joystick and the sound cards answered by the host through SDL2. `src/` is untouched, so
`./build.sh` still ends with `MATCH`. Build, settings and internals: [docs/SDL2_PORT.md](docs/SDL2_PORT.md).

* **Build**: `port/build.sh` (Linux, needs `gcc git libsdl2-dev`) writes `build/hockey94`; `port/build-win.sh` cross-compiles
  `build/win/hockey94.exe` for 64-bit Windows with mingw-w64. Put the program in the game folder (beside `HOCKEY.EXE`) or set
  `NHL94_ROOT`.
* **Video**: OpenGL, 4:3, sharp scaling, CRT, MiSTer and custom looks, picture height, 60/70 Hz or VRR and a stats display, as in
  the NHL 95 port (Windows menu bar, or `hockey94.ini` next to the program); Alt+Enter for fullscreen.
* **Input**: keyboard, mouse (the glove follows the system pointer), up to two controllers on the game port, input bindings
  (Options > Input bindings...); Ctrl+F11 records the sound.
* **Sound**: PC speaker, AdLib, Sound Blaster (default, found by the game's own detection) and MT-32 through Munt (your
  `MT32_CONTROL.ROM` and `MT32_PCM.ROM` in a `roms` folder). The game's `SND.CFG` picks the card: 0 none, 1 PC speaker, 2 AdLib,
  3 Sound Blaster, 4 MT-32.

## AI assistance

This project is AI-assisted. The work is directed by a strict ruleset and curated by hand, with the aim of producing clean, correct, correctly labelled and commented code that closely matches what the original developers likely had. We can't guarantee it's perfect, and ultimately this will always be a work in progress. If you see something that needs fixing, raise an issue, or even better, raise a PR.

## Credits and derivative works

Thanks to chaos, StaticEck, McMarkis and Drezz for their help with the disassembly.

Special thanks to smozoma and kingraph, whose past contributions to the NHL modding community made this work easier.

And thank you to the original developers of the game.

The SDL2 port runs on [libx86emu](https://github.com/wfeldt/libx86emu) (the CPU core, SciTech/SUSE licence), plays FM through
[Nuked-OPL3](https://github.com/nukeykt/Nuked-OPL3) and the MT-32 through [Munt](https://github.com/munt/munt) (both LGPL 2.1+). They
are downloaded at build time, not committed. Its sound devices and OpenGL looks come from the NHL 95 PC port (`sdl2-port` branch of
[nhl95pc](https://github.com/abdulahmad/nhl95pc)).

This project is the result of my work and the work of the people credited above. If you build anything from it, including mods, ROM or EXE hacks, ports, released forks, tools, or any other derivative work, you must credit us:

- Put the credit in your repo's README, near the top and not buried in a footer, and in the notes of every release you publish, including any text file shipped inside a release archive.
- Name me and link to this repository.
- Name everyone credited here: chaos, StaticEck, McMarkis (Mhopkinsinc) and Drezz, with special thanks to smozoma and kingraph.
- If you only use part of this repo (docs, a tool, labels, a file format description), the credit still applies.
- If you are unsure, over-credit.

Credit is the condition for using this work. Please do not release a derivative without it.
