# Sound effect files: PCFFnnn.PAT / .TIM / .DIG

Notes on the sound bank files in the retail game folder (`lst/game/`), worked out from the files themselves and from the
strings in `HOCKEY.EXE` (`PCFF%03d`, `.PAT`, `.TIM`, `PCBEEP`, `SBDAC`, `ADLIB`, `MT32`, `bank%d.pat`, `timb%d.tim`,
`c:\eaclib\%s`). The sound driver code itself has not been read yet, so anything marked *(guess)* still needs to be
checked against the disassembly.

Tools:

- `python3 tools/audio/sfx.py list`: prints the banks, the patch maps and every digital sample.
- `python3 tools/audio/sfx.py export`: writes the 30 Sound Blaster samples to `output/sfx/` as WAV (plus a `_looped`
  copy of the two looping ones). `output/` is git-ignored, so no game audio is committed.
- `tools/audio/sfx_player.html`: open it in a browser, pick `PCFF001.TIM`, `PCFF001.DIG` and (optionally)
  `PCFF001.PAT`, and play each sample with its loop. It reads the files locally.

## The files

| File | Holds |
| --- | --- |
| `PCFF000.TIM` | bank 0: 144 FM (OPL2) timbres, 80 bytes each |
| `PCFF001.TIM` | bank 1: 30 Sound Blaster digital timbres, 32 bytes each, plus the name of the sample file |
| `PCFF001.DIG` | the 30 samples that bank 1 points at |
| `PCFF002.TIM` | bank 2: 31 FM timbres used in place of the digital ones on AdLib |
| `PCFF003.TIM` | bank 3: 28 PC speaker timbres, 70 bytes each |
| `PCFF001.PAT` … `PCFF005.PAT` | program maps: which bank and timbre each program number plays |

The banks are shared by the music (`.KMS`) and the sound effects. In the Sound Blaster map, programs 1 to 122 are FM
instruments and programs 123 to 179 are mostly sound effects, 33 of them digital.

The game picks the patch map from byte 1 of the card's `.SCN` file: `MENUS.OVL` builds the name with `sprintf("PCFF%03d", scn[1])`. The FM timbre layout is covered in `docs/MUSIC_FORMAT.md`.

| `.SCN` file | Byte 1 | PAT | Banks the PAT uses |
| --- | --- | --- | --- |
| `SBDAC.SCN`, `MT32SBDA.SCN` | 1 | `PCFF001.PAT` | 0 (FM) + 1 (digital) |
| `MT32.SCN` | 2 | `PCFF002.PAT` | "bank 0" only, timbres up to 173 |
| `PCBEEP.SCN` | 3 | `PCFF003.PAT` | 3 (PC speaker) |
| `ADLIB.SCN` | 4 | `PCFF004.PAT` | 0 + 2 (FM) |
| none | 5 | `PCFF005.PAT` | 0 + 2, a few programs differ from 4; no `.SCN` selects it |

The MT-32 map refers to timbres up to 173 while `PCFF000.TIM` has only 144, so on the MT-32 the record's timbre byte is
probably an MT-32 sound number rather than an entry in a `.TIM` file *(guess)*.

## Shared container (.TIM and .DIG)

All values are little-endian.

| Offset | Size | Field |
| --- | --- | --- |
| 0 | u32 | file size |
| 4 | u16 | `count` |
| 6 | 4 × count | item ids |
| 6 + 4·count | u32 × count | item offsets, relative to the data start; `ffffffff` = no data |
| 6 + 8·count | | data; each item runs to the next offset |

In a `.TIM` the ids are `80 bb 00 nn`: bank `bb`, timbre number `nn` (1-based, so timbre `nn` is slot `nn-1`). The
last slot is a terminator: id and offset `ffffffff`, or, in bank 1, id `.dig` whose data is the sample file name
`pcff001.dig\0`.

In the `.DIG` the ids are 4-byte sample ids, sorted ascending (they look like hashes), and each item is raw sample
data with no header. The header size matches the file size (323,967 bytes).

## Digital timbre (bank 1, 32 bytes)

| Offset | Size | Field |
| --- | --- | --- |
| 0x00 | u8 | type, `06` = digital (FM is `04`, PC speaker is `08`) |
| 0x01 | u8 | unknown, varies per sample |
| 0x02 | 4 | sample id in `PCFF001.DIG` |
| 0x06 | 11 | zero |
| 0x11 | u8 | 1 = looped |
| 0x12 | u16 | sample rate in Hz: 11025, or 22050 for timbre 21 |
| 0x14 | u32 | length in bytes, always equal to the DIG item size |
| 0x18 | u32 | loop start (bytes) |
| 0x1c | u32 | loop end (bytes) |

**Sample format: signed 8-bit mono PCM.** Silence is `00`, `ff`, `01`, and every sample averages close to 0 when read
as signed. The driver presumably flips the top bit before sending it to the Sound Blaster DAC, which expects unsigned
data. WAV export does the same flip.

Two timbres loop: 16 (bytes 3856 to 9971) and 28 (595 to 9041). Samples `15e431b9`, `4f1a9016` and `7e332665` hold
byte-identical data (8982 bytes): one sound stored three times under three ids.

## Patch map (.PAT)

| Offset | Size | Field |
| --- | --- | --- |
| 0x000 | u16 | version, 6 in every file |
| 0x002 | 256 × u8 | program number → record index (0 = not used) |
| 0x102 | 20 × n | records; record 0 is a default and is not referenced |

Record (20 bytes), as far as it is known:

| Offset | Field |
| --- | --- |
| 0 | bank (0 to 3) |
| 1 | timbre number in that bank |
| 7 | transpose in semitones, signed (`f4` = -12, `e8` = -24, `0b` = +11) |
| 8 | fine tune, signed *(guess)* |
| 9 | `40`/`3f`: pan, centre *(guess)* |
| 11 | `7f`: volume *(guess)* |
| 2–6, 10, 12–19 | not yet known |

For the digital programs the transpose would shift the playback rate by 2^(t/12), but the note the game plays them at
is not known yet, so the exporter writes every sample at its stored rate.

## FM and PC speaker timbres (not decoded yet)

Bank 0 and bank 2 records are 80 bytes and start with type `04`, followed by what look like the two OPL2 operator
register sets and a connection/feedback byte, then envelope or pitch-sweep parameters from about offset 0x10. Bank 3
records are 70 bytes, type `08`, with many `e8 03` (1000) words; the PC speaker map (`PCFF003.PAT`) is the only one that uses them. Playing these
needs the sound driver's code to be read and an OPL2 emulator, which is the next step for FM effects and for the
`.KMS` music.
