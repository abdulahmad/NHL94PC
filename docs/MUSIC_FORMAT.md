# Music: .KMS songs, .CFG track setup and the sound drivers

How NHL Hockey (NHL '94 PC) plays its music, worked out from `HOCKEY.EXE` (the EA sound library in the root image) and the
AdLib driver `YM30.BGP`. Addresses are file offsets into the root load image (`HOCKEY.EXE` minus the 0x1C00-byte MZ
header, i.e. `seg:off` as `seg*16+off`), or offsets into the unpacked driver image.

Tool: `tools/audio/kms.py` (needs `pip install unicorn`, and `sh tools/audio/fetch-deps.sh` once for Nuked OPL3).

| Command | What it does |
| --- | --- |
| `kms.py list` | every song: tempo, tracks, channel and program per track, length |
| `kms.py dump BOS1 [--raw]` | the decoded events of one song (with `--raw`, the bytes of each event) |
| `kms.py wav ADTITLE` | renders the song the way an AdLib plays it, to `output/music/ADTITLE.wav` |
| `kms.py wav all` | every AdLib and team song (the `MT*` MT-32 versions are left out) |
| `kms.py play BOS1` | renders and plays it (aplay, paplay, afplay or ffplay) |
| `kms.py vgm ADTITLE` | the YM3812 register log as a `.vgm` file, for any VGM player |
| `kms.py mid ADTITLE` | a Standard MIDI File of the messages the game sends to the driver |

`wav`, `play` and `vgm` do not reimplement the synthesizer. They load the game's own `YM30.BGP` driver into an x86
emulator (unicorn), call it the way `HOCKEY.EXE` does, and record its writes to ports 388h/389h. The writes go to Nuked
OPL3 (in OPL2 mode) at the chip's native 49,716 Hz. The sequencer that reads the `.KMS` file is a Python port of the
game's routine, described below. `output/` is git-ignored, so no game audio is committed.

## Which files are used

| File | Use |
| --- | --- |
| `ADTITLE`, `ADAWARDS`, `ADSUM`, `ADAFAN`, `ADROCK`, `ADROCKU` `.KMS/.CFG` | AdLib / Sound Blaster versions of the title, awards, summary, fanfare and rock cues |
| `MTTITLE`, `MTAWARDS`, `MTSUM`, `MTAFAN`, `MTROCKU`, `MT32HOCK` | the same for the Roland MT-32 (`MT32HOCK` holds a 200-byte MT-32 sysex) |
| `TITLE.KMS` | a 13-track title version; the code loads `mttitle.kms` or `adtitle.kms`, not this one |
| `ROCKDITI`, `SBROCKU`, `SLAPSHOT` | short rock cues (`SBROCKU` uses program 124, a digital timbre on Sound Blaster) |
| `BOS1`, `CHIC2`, `TOR1`, ... `CANADA`, `USA` | the arena organ tunes, 2 or 3 tracks each (left hand, right hand, claps) |
| `*.SCN` | sound card description; byte 1 picks the patch map (`PCFF%03d.PAT`): ADLIB 4, SBDAC 1, MT32 2, MT32SBDA 1, PCBEEP 3 (read by the setup code in `MENUS.OVL`) |
| `YM30.BGP`, `SB30.BGP`, `MT30.BGP`, `PC30.BGP`, `NL30.BGP` | the drivers: AdLib, Sound Blaster, MT-32, PC speaker, none |
| `PCFF00n.PAT`, `PCFF00n.TIM` | program map and timbre banks, see [SFX_FORMAT.md](SFX_FORMAT.md) on the sound effects branch |

## .KMS

All words little-endian.

| Offset | Size | Field |
| --- | --- | --- |
| 0 | u8 | 1 (version) |
| 1 | u8 | tempo, beats per minute (96 to 230; most organ tunes 120) |
| 2 | u16 | 1 |
| 4 | u16 | 0 |
| 6 | u16 | number of tracks (1 to 15) |
| 8 | u16 × 16 | offset of each track's first event, from the start of the file |
| 0x28 | | the tracks |

Each track is stored as a chunk: a 32-bit **big-endian** length that counts the 8-byte chunk header, the tag `TRAK`,
then the events. The offset in the header points just past `TRAK`. The game only uses the offsets.

### Events

An event is a delta time, a command byte and its arguments. The delta is a MIDI-style variable-length number (7 bits per
byte, high bit = more bytes) and counts ticks between the previous event and this one. The game's decoder is
`1630:0A90` (file `0x16D90`); the command table is at `0x16E02`.

| Command | Arguments | Meaning (executor at `1630:01D2`, table at `0x166FF`) |
| --- | --- | --- |
| `81`–`D8` | velocity (u8), duration (VLQ) | note on, note = command & 7Fh |
| `00`–`80` | duration (VLQ) | note on with the velocity set by `E4` (no retail file uses this) |
| `D9`, `DA` | – | end of track; inside a call, return |
| `DB` | – | restart the track from its first event: the looping songs end with this |
| `DC` | program (u8) | program change |
| `DD` | tempo (u8) | new tempo for every track of the song |
| `DF` | controller, value (u8, u8) | controller (7 volume, 10 pan, 1 modulation) |
| `E2` | count (u8) | loop start |
| `E3` | – | loop end |
| `E4` | velocity (u8) | default velocity for `00`–`80` notes |
| `E5` | value (u16 LE) | pitch bend, 4000h = centre; the high byte is sent |
| `E6` | u8, u32 | call (not used by the retail songs) |
| `E7` | length (u8), text | track name, e.g. `left`, `kick/snar`, `sqwv (AD)` |
| `E8` | length (u8), data | system exclusive, sent as is (MT-32 only) |
| `DE`, `E0`, `E1`, `E9`, `EA` | u8 | read and ignored by the player (`EA` stores the byte in the track) |

The duration of a note is in ticks too; the note-off is scheduled, not stored. The retail songs use only `81`–`D8`,
`D9`, `DB`, `DC`, `DF`, `E5`, `E7` and `E8`.

Notes on the loop commands, as the code has them: `E2 n` keeps `n-1`; at `E3` the track always jumps back, and pops the
loop when the kept count was already 0, so the section plays `n+1` times. An `E3` with no open loop is ignored.

## .CFG

264 bytes. The game reads track `i`'s record at `cfg + 16*i`, fields from `+8` (so record 0 is at offset 8).

| Offset | Size | Field |
| --- | --- | --- |
| 0 | u8 | 3 |
| 1 | u8 | number of tracks |
| 2 | 6 | `01 00 00 00 ff ff` in every file |
| 8 + 16·i | u16 | MIDI channel mask: the lowest set bit that is free becomes the track's channel (`1630:1778`). `0002` = channel 1 … `0200` = channel 9, the drums |
| +2 | 4 | `ff ff ff ff` (passed to a library routine that does nothing in this build) |
| +6 | u8 | volume, 100 |
| +7 | u8 | pan, 64 |
| +8 | 4 | 0 |
| +12 | u8 | program, `ff` on drum tracks |
| +13 | 3 | 0 |

Several tracks can share a channel (the drum parts are split into `kick/snar`, `toms`, `hats`, ... all on channel 9).

## How the game plays a song

**Start** (`1630:17E6`, file `0x17AE6`). For each track: pick the channel, send program change (the `.CFG`
program), modulation 0, volume, pan, and pitch bend 4000h. The code sends the `.CFG` *volume* byte for the pan as
well (it reads `+6` twice); the tracks then set their own pan with `DF 0A`. The volume is scaled by the song's
master volume (`value * vol / 127`); a master pan other than 3Fh pulls the pan values toward one side.

**Timer.** The game programs the PIT with divisor `2E9Ch` (100 Hz, `0x4700`) and runs its callbacks on every
interrupt. The music callback (`1630:003C`) first calls each driver's tick function (driver function 5), then
every active track:

- add 80h to the track's accumulator; while it holds at least `32000 / tempo`, run one tick and take that off;
- a tick first counts down the track's playing notes and sends a note-off for each one that reaches 0;
- then, if the delta counter is not 0, it counts down; otherwise it runs every event that is due (events with delta 0
  run in the same tick) and loads the next event's delta.

So a song plays `100 * 128 / (32000 / tempo)` ticks a second, which is 24 ticks per beat at the stated tempo (48 ticks a
second at 120). The game keeps 32 note slots; a note that finds none is dropped.

**MIDI out.** Everything reaches the driver as MIDI bytes through driver function 11. The send routine
(`1844:022E`, file `0x1866E`) **adds 24 (18h) to the note number** of every note-on and note-off, so a KMS note byte
of `9B` is note 1Bh + 24 = 51 (D#3). With that offset the drum notes are General MIDI numbers: 36 kick, 38 snare,
41 floor tom, 49 crash.

## The drivers (*.BGP)

Each `*.BGP` is a 16-bit DOS MZ program packed with EA's BTree codec (header `46 FB`, 3-byte big-endian unpacked
size, an escape byte, a node count, then `node, left, right` triples; each node byte stands for its two bytes,
expanded recursively; escape + byte is a literal, escape + 0 ends). `btree_unpack` in `kms.py` unpacks all five to
exactly the sizes in their headers. The YM30 driver is "YM3801 Sound Driver, Copyright (C) Electronic Arts Canada Inc.
1992" (the marker strings `BRIAN` and `PLANK` are in the image).

The first four bytes of the code are a far pointer to a table of 13 far pointers (`DS:0066`, DS = image + 1A9h
paragraphs). The game copies the table (`0x8FD6` in DGROUP, 38h bytes per driver) and calls, Pascal convention:

| # | YM30 | Use |
| --- | --- | --- |
| 0 | `0312` | returns the port, 388h |
| 1 | `031E` | detect the card at a port (timer test), sets the I/O delays |
| 2 | `0338` | init: patch callback, timbre callback, port; resets the chip |
| 3, 4 | `03C2`, `03CE` | reset the chip |
| 5 | `03DA` | tick: envelopes and pitch effects of the sounding voices (called at 100 Hz) |
| 6 | `05C0` | query by number (1: 00020000h, 2: `"YM38"`, 3: 1, 6: the port, else -1) |
| 7 | `0622` | with argument 85h: mark all voices free |
| 8 | `064A` | copy the driver name |
| 10 | `06B4` | set a channel's voice mask |
| 11 | `11BA` | MIDI bytes in: 8x note off, 9x note on, Bx controller, Cx program, Ex pitch bend |
| 12 | `140C` | returns -1 |

The AdLib driver is a 9-voice synthesizer with 16 MIDI channels. On a note-on it calls the two callbacks the game passed
to function 2, with the program number (`note + 5Ch` on channel 9, which gives the drum programs 80h–BFh):

- **patch callback** (`16F2:087C`): returns `PAT + 102h + 20 * PAT[2 + program]`, the 20-byte record of the `.PAT`
  file. The driver uses `+2` (voice mask, 9 bits), `+6` (voices per channel), `+7` (transpose, added to the note),
  `+8`, `+9`, `+A`, `+C` (priority, × 16).
- **timbre callback** (`16F2:08BE`): returns the far pointer at `+10h` of the same record, which the game fills when it
  loads the banks: the timbre's data in `PCFF00b.TIM` (bank `b` = record `+0`, timbre = record `+1`).

An FM timbre (type `04`, 80 bytes) starts with the type byte, one byte not yet known, then the 13 register bytes the
driver writes: the carrier's 23h/43h/63h/83h/E3h, the modulator's 20h/40h/60h/80h/E0h, then C0h (feedback and
connection), A0h and B0h. The bytes after that drive the driver's envelope and vibrato code (tick function) and are
not decoded yet. The driver writes registers to a shadow copy and flushes only the ones that changed.

For the AdLib the game uses `PCFF004.PAT` (from `ADLIB.SCN`), which takes its timbres from banks 0 and 2.

## Not covered yet

- The Sound Blaster (`SB30.BGP`) and MT-32 (`MT30.BGP`) drivers. On a Sound Blaster the music is FM too, through
  `SB30.BGP` with `PCFF001.PAT`; only `SBROCKU` uses a digital program there. `kms.py --pat 1` uses that map with the
  AdLib driver, which cannot play the digital timbres.
- The fade-out and the master volume setting from the menus: `kms.py --vol` sets the master volume, default 127.
- The rest of the FM timbre (envelope and vibrato tables) and of the patch record.
