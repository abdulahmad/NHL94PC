# NHL '94 PC: the SDL2 port

Built from [abdulahmad/nhl94pc](https://github.com/abdulahmad/nhl94pc) by abdulahmad. Credits: chaos, StaticEck, McMarkis
(Mhopkinsinc) and Drezz, with special thanks to smozoma and kingraph. The CPU core is
[libx86emu](https://github.com/wfeldt/libx86emu); FM sound is [Nuked-OPL3](https://github.com/nukeykt/Nuked-OPL3); the MT-32 is
[Munt](https://github.com/munt/munt). The sound devices and the OpenGL looks are taken from the NHL 95 PC port
([nhl95pc](https://github.com/abdulahmad/nhl95pc), branch `sdl2-port`). Ship this credit with any build you release.

## How it works

NHL '94 PC is 16-bit real-mode code (Microsoft C large model, RTLink overlays, EMS), so unlike the NHL 95 port it cannot be
compiled to run natively. The port runs the retail `HOCKEY.EXE`, its `.OVL` overlays and EA's sound drivers (`*.BGP`) on a
built-in x86 CPU core, and answers everything around the CPU on the host. Nothing of the game is changed or patched, and `src/`
is not used: `./build.sh` still ends with `MATCH`.

| File | Job |
| --- | --- |
| `port/cpu.c` | libx86emu glue: flat 1 MB + HMA memory, VGA window (A0000) and EMS frame (E0000) routing, ROM stubs at F000 for every vector (`int n` / `retf 2`), IRQ delivery between slices. Replaces libx86emu's ESC (x87) opcodes with no-ops (no FPU, so the C runtime uses its emulator) and its `ins`/`outs` (its `outs` read ES:SI, and word forms stepped by 1). Debug hooks below. |
| `port/dos.c` | MZ loader (PSP, environment with `C:\HOCKEY.EXE` and `BLASTER`, relocations), `int 21h` (files, MCB chain, find first/next, vectors, time), `int 2Fh`. Drive C: is the game folder; names match ignoring case. |
| `port/bios.c` | `int 10h` (modes 03/0D/12/13, DAC), `int 16h`, `int 1Ah`, `int 15h`, the BIOS's own int 8/9, `int 33h` mouse, `int 67h` EMS 4.0 (8 MB, "EMMXXXX0" at F000:000A). |
| `port/pc.c` | 8259 PIC pair, 8253 PIT (IRQ 0 follows host time and the game's divisor), keyboard controller, port 61h, I/O dispatch. |
| `port/vga.c` | Register-level VGA: 4 planes, latches, write modes 0-3, read modes 0-1, chain-4 / unchained / 16-colour, CRTC start, offset and line compare (the split screen of the score bar), retrace at 70 Hz from host time. |
| `port/main.c` | SDL2 window, OpenGL or SDL renderer, `hockey94.ini`, keyboard (SDL scancode to XT set 1), absolute mouse, game controllers on the game port, main loop, scripted input, test variables. |
| `port/video_gl.c` | OpenGL picture and looks (from the NHL 95 port). |
| `port/audio.c opl.c sb.c dma.c mpu.c speaker.c` | The NHL 95 port's sound devices nearly unchanged (`sndhost.h` is the shim, `sound.c` the port map). |

The main loop runs the CPU in slices of 20 000 instructions, advances the PIT from the host clock, feeds the keyboard one
scan code per interrupt, pumps the sound and presents about 70 times a second. The game waits on vertical retrace, so it runs at
its own speed: on a recent PC the core runs about 20 million instructions a second and the game shows 35 frames a second, as it
was written to.

The load segment is 0732h, so a segment with paragraph P in `segmap.json` runs at CS = 0732h + P (seg001 = 0AD5h, seg006 =
106Ch, seg025 = 16CBh).

## Build and run

Linux (macOS should work the same way):

```
sudo apt install gcc g++ git libsdl2-dev
port/build.sh                       # fetches libx86emu, Nuked-OPL3 and Munt into port/third_party; writes build/hockey94
NHL94_NO_MUNT=1 port/build.sh       # without the MT-32
```

Windows, cross-compiled from Linux or WSL (`sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64`, and SDL2's
`SDL2-devel-2.x-mingw.tar.gz` unpacked next to the repository or `SDL2_MINGW` set to its `x86_64-w64-mingw32` folder):

```
port/build-win.sh                   # build/win/hockey94.exe and SDL2.dll
```

Put the program in the game folder, beside `HOCKEY.EXE`, or set `NHL94_ROOT` to the folder. The game writes `SND.CFG` and its
databases there, so use a copy of your game folder (in this repo, never run it inside `lst/game`).

## Settings

`hockey94.ini` in the game folder, `key = value` lines; each key can also be given as an environment variable `NHL94_<KEY>`.

| Key | Values |
| --- | --- |
| `look` | `sharp` (default: 3x nearest-neighbour, then cubic to the window), `5x`, `7x`, `11x`, `crt-light`, `crt-medium`, `crt-strong` (scanlines), `crt-soft`, `crt-soft-grille` |
| `filter` | `cubic` (default), `linear`, `nearest` |
| `renderer` | `gl` (default), `sdl` (SDL's renderer, no looks) |
| `fullscreen` | `0` (default) or `1`; Alt+Enter switches at any time |

## Controls

* **Keyboard**: as on DOS. In the menus the arrows move the glove and Return clicks; in play the arrows (or keypad) skate and the
  game's own keys pass, shoot and change lines.
* **Mouse**: the glove follows the system pointer (the window maps onto the driver's 640 x 200 screen). The game's menus take a
  click to open, a click to highlight an item and another to choose it, with the mouse as with Return.
* **Joystick**: the first SDL game controller is joystick A on the game port (left stick or d-pad; A and B are buttons 1 and 2,
  X and Y buttons 3 and 4); a second controller is joystick B. The game finds it at start-up and calibrates itself as the stick
  moves to its ends.

## Sound

The game picks the card from `SND.CFG` (one byte: 0 none, 1 PC speaker, 2 AdLib, 3 Sound Blaster, 4 MT-32). With no `SND.CFG` its
own detection finds the Sound Blaster (`BLASTER=A220 I7 D1 T3`). Checked by recording: Sound Blaster music and speech, AdLib music,
PC speaker effects in play. For the MT-32 put `MT32_CONTROL.ROM` and `MT32_PCM.ROM` in a `roms` folder next to the program or the
game, or set `NHL94_MT32_ROMS`.

## Test and debug variables

| Variable | Effect |
| --- | --- |
| `NHL94_TRACE=1` | log DOS, BIOS and unknown port accesses to stderr |
| `NHL94_STATS=1` | every 2 s: MIPS, PIT rate, video mode, page flips and retrace polls a second |
| `NHL94_DUMP=dir` | a PPM of the screen twice a second (use with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy`) |
| `NHL94_SHOT=file.ppm`, `NHL94_SHOT_AT=s` | save the OpenGL window once |
| `NHL94_WAV=file.wav` | record the sound |
| `NHL94_KEYS="ms:Key[/hold] ms:@x,y ms:@click[/hold]"` | scripted keys (SDL key names) and mouse (driver units) |
| `NHL94_SOUND=none` | no sound devices |
| `NHL94_BREAK=cs:ip,...` | print registers (and `[ds:ax]`, `[bp+NHL94_BREAK_BP]` or `[es:di-8]` with `NHL94_BREAK_DI`) when reached; `NHL94_BREAK_MEM=file` dumps memory |
| `NHL94_COVER=s` | from `s` seconds on, print each code address reached for the first time |
| `NHL94_VPAD=1` | attach a virtual game controller |

## Open items

* Speed: libx86emu does per-instruction bookkeeping; it is fast enough (the game waits on retrace), and a faster core could be
  checked against it instruction by instruction if ever needed.
* Input bindings and the Windows menu bar of the NHL 95 port are not carried over; the game's own controls apply.
* When the sibling work on PPV, QPP, KMS/CFG and TIM/DIG decoding lands, it does not change the port (the game reads its own
  files), but it can feed tools around it.
