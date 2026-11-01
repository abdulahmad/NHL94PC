# SDL2 port: handoff (paused 2026-11-01)

Branch `claude/project-thread-2cux3o`, code in `port/`. `src/` is untouched, so `./build.sh` still ends with MATCH.

## Approach

NHL '94 PC is 16-bit real-mode code (MS C large model, RTLink overlays), so it cannot run natively the way the NHL 95 PC
`sdl2-port` does. The port runs the retail `HOCKEY.EXE`, its `.OVL` overlays and the EA sound drivers (`*.BGP`) on a CPU
core (libx86emu, permissive licence) and answers everything around the CPU on the host. The plan, with the reasons, is in the
project doc "NHL '94 PC SDL port: feasibility and plan".

| File | Job |
| --- | --- |
| `port/cpu.c` | libx86emu glue: flat 1 MB + HMA memory, VGA window (A0000) and EMS frame (E0000) routing, I/O, ROM stubs at F000 for every vector (`int n` / `retf 2`), IRQ delivery between slices, `NHL94_BREAK` debug hook. Replaces libx86emu's ESC (x87) opcodes with no-ops (no FPU) and its `ins`/`outs` (its `outs` read ES:SI instead of DS:SI, and word forms stepped by 1). |
| `port/dos.c` | MZ loader (PSP, environment with `C:\HOCKEY.EXE`, relocations), `int 21h` (files, MCB chain, find first/next, vectors, time), `int 2Fh`. Drive C: = the game folder, names matched ignoring case. |
| `port/bios.c` | `int 10h` (modes 03/0D/12/13, DAC), `int 16h`, `int 1Ah`, `int 15h`, BIOS int 8/9 services, `int 33h` mouse, `int 67h` EMS 4.0 (8 MB; "EMMXXXX0" at F000:000A). |
| `port/pc.c` | 8259 PIC pair, 8253 PIT (IRQ 0 follows host time and the game's divisor), keyboard controller (60h/64h), port 61h, game port stub, I/O dispatch. |
| `port/vga.c` | Register-level VGA: 4 planes, latches, write modes 0-3, read modes 0-1, chain-4 / unchained / 16-colour, CRTC start/offset, retrace from host time at 70 Hz. |
| `port/main.c` | SDL2 window (plain SDL renderer, 4:3, Alt+Enter), main loop (20 000-instruction slices), SDL scancode to XT set 1, scripted input, PPM dumps, stats. |
| `port/audio.c opl.c sb.c dma.c mpu.c speaker.c` | Taken from the NHL 95 PC port nearly unchanged (`sndhost.h` is the shim, `sound.c` the port map). GUS dropped: 94 has no GUS driver. |

## Build and run (Linux)

```
sudo apt install gcc git libsdl2-dev
port/build.sh                      # fetches libx86emu, Nuked-OPL3, Munt into port/third_party; writes build/hockey94
NHL94_NO_MUNT=1 port/build.sh      # skip the Munt download (MT-32 is not linked yet anyway)
```

Run in a **copy** of the game folder (the game writes `SND.CFG` and its databases; do not run it inside `lst/game`):

```
mkdir run && cp -r lst/game/. run/ && cp lst/HOCKEY.EXE run/
NHL94_ROOT=$PWD/run build/hockey94
```

Test variables: `NHL94_TRACE=1` (log to stderr), `NHL94_STATS=1` (MIPS and PIT rate every 2 s), `NHL94_DUMP=dir` (PPM twice a
second; use with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy`), `NHL94_WAV=file.wav`, `NHL94_KEYS="ms:Key[/hold] ms:@x,y
ms:@click[/hold]"`, `NHL94_BREAK=cs:ip,...` (print registers when reached), `NHL94_SOUND=none`.

The load segment is 0732h, so a segment with paragraph P in `segmap.json` runs at CS = 0732h + P (seg001 = 0AD5h, seg006 =
106Ch, seg025 = 16CBh).

## State

Works (checked with screenshots, headless): start-up, EMS allocation, overlays loading, the Sound Blaster found by the game's
own detection (digital sound and FM music recorded to WAV, not listened to), the EA Sports screen, the title screen with the
puck movie, the front end (Ron Barr desk) with correct colours, the File menu opened with Return, the glove pointer moved
with the arrow keys. About 20 million instructions a second.

Not yet: choosing a menu item. Return on an item and mouse clicks (`@click`, even held 4 s) do nothing.

## Where the menu problem stands

- The game reads the mouse with `MouseRead` (seg001, `int 33h` AX=3) from `seg006:00E6`, polled every 5 ticks from
  `seg006:0008`. That routine builds an event (type 1 mouse, 2 joystick, 3 keyboard) and queues it at `0xAED0` (32 entries,
  count `[0x508]`); `seg025:000E` (`GetInputEvent`-like) dequeues.
- Breakpoints showed `seg006:0025` and `seg006:0076` are reached but `seg006:0086` and `00DE` (the queueing) are not, and
  `seg025:0050` (dequeue) is never reached: no event is ever queued. So the poll's three sources all return 0. Next step: break
  in `seg006:00E6` after `MouseRead` to see the values compared with `[0x510]/[0x516]/[0x518]`, and check the byte flags at
  `[0xAECE]` (bit 0 mouse, 2/4 joystick, 8 keyboard) that pick the sources.
- The keyboard source (`seg006:01DE`) asks `seg001:16C1` per scan code, so keys reach the game through its own INT 9 handler
  (`KbdIrq`); Return did open the menu, so some input path works, possibly a different one from this queue.
- Last runs before the pause were cut short by the timeout; their output was not read.

## Next steps

1. Finish the menu input (above), then play an exhibition game with the keyboard.
2. Joystick on port 201h from SDL controllers (`joy_port` / `joy_trigger` in `main.c` are stubs); bring `input.c` and
   `bindings*.c` over from 95.
3. Sound: listen to AdLib / Sound Blaster / PC speaker; link Munt for MT-32 (`port/munt-build.sh` from 95).
4. From 95: OpenGL presentation and looks (`video_gl.c`), ini, Windows build and menu bar, intro skip.
5. `docs/SDL2_PORT.md` and a README section, credits for libx86emu, Nuked-OPL3 and Munt.
6. Speed if needed: libx86emu does per-instruction bookkeeping; a faster core can be checked against it instruction by
   instruction.

## Open questions for Abdul

- Route: built-in CPU core now (recommended, what this branch does) or wait for the full disassembly; the decision card is open.
- Branch: keep this branch, or open the PR against a new long-lived `sdl2-port` branch as in NHL95PC.
