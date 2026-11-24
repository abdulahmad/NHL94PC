# NHL '94 PC compared with the 93 and 94 console games

People often say NHL '94 PC (EA's DOS "NHL Hockey", 1993) is really NHLPA 93 because it has no Anaheim or Florida.
This page checks the game code instead. Each row compares a gameplay feature in this repo's disassembly
of `HOCKEY.EXE` and its overlays with the NHLPA 93 and NHL 94 console disassemblies:

- 93 consoles: [NHLPA93Genesis](https://github.com/abdulahmad/NHLPA93Genesis) and [NHLPA93SNES](https://github.com/abdulahmad/NHLPA93SNES)
- 94 consoles: [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis) and [NHL94SNES](https://github.com/abdulahmad/NHL94SNES)

Addresses are `segment:offset` from the routine headers in this repo. The labels are the repo's current names.

Confidence levels:

- **Code**: the routine or table was read and compared.
- **Data**: a string or table shows it, but the logic wasn't traced.
- **Not found**: searched for and absent. That is strong evidence but not proof.

## Feature table

| Feature | 93 consoles | 94 consoles | 94 PC | Evidence | Confidence |
|---|---|---|---|---|---|
| **Fighting** | Yes. `checkfight` starts fights; `assfight` / `assfwatch` assignments; Fighting, Fighting * and Fight Instigator penalties (93G `hockey93.asm`, `tables93.asm`) | Removed. 94G keeps `checkfight` as a bare `rts` (`collide94.asm`); the fight frames are left over and unused | **Removed (94-like).** The collision routine `checkcx` (28BB:319A) calls `newcheck`, `checkint`, `checkcheck` and nothing else, so even the `checkfight` call is gone. `asstab` has no fight assignments; the slots after `asspassrec` hold `assstarskate` / `assthreestars`. The SPA table (`SPAlist`) has no fight animation. The penalty name list has no fighting penalty | Code |
| **Fighting rating on the player card** | Shown: `[ Fighting ]` column (93G `tables93.asm` PAttribColumns, 93S `PAttribColumns.asm`) | Gone from the card; the list ends at Checking (94G `tables94.asm`, 94S `PAttribColumns.asm`) | **Gone (94-like).** The skater ratings list is Speed, Agility, Weight, Shot Power, Checking, StickHandling, Accuracy, Passing, Off./Def. Awareness, Aggressiveness, Endurance, then Shoot/Pass Bias and Faceoffs. No Fighting. (Shoot/Pass Bias isn't new: the 93 and 94 console player records already carry a shot/pass decision value, they just don't show it on the card; see Teams and rosters.) (`dgroup.asm`, `str_Speed_2` onward) | Data |
| **One-timers** | None: no one-timer code or animation in either 93 disassembly | New in 94: 94G `onetimer94.asm`; 94S `asspassrec` / `assbreakaway` with `SPAonetimerf` / `SPAonetimerb` | **Yes (94-like).** `assonetimer` (2C24:0746) plays `SPAonetimef` / `SPAonetimeb` as the pass arrives. `asspassrec` (2C24:0A1C) calls it when `onetimerflag` is set. `OneTimerChk` (2C24:096C) lets the CPU team set up one-timers too | Code |
| **Which 94 one-timer it resembles** | n/a | 94G: aimed pass to a target spot (`OneTimerPass`). 94S: the receiver swings, with forehand / backhand picked by `Findhittype` | **The 94 SNES design.** `assonetimer` follows the same steps as 94S `asspassrec`. If the player is already in the one-timer animation it releases the shot. Otherwise it builds the vector to the goal, calls `Findhittype` and sets the backhand or forehand one-timer animation | Code |
| **Goalie wall animations** | Not in either 93 game (no `SPAgwall*`) | 94 SNES only: `asseben` / `assbench` give a goalie `SPAgwallright` / `SPAgwallleft` where skaters get `SPAwallright` / `SPAwallleft` | **Yes, as in 94 SNES.** `asseben` (2519:0A62) does `cmp [si+0x1a],1 / sbb / and 0x574 / add SPAno(SPAwallright)`, so a goalie (position 0) gets SPA number +0x574. Counting the SPA table shows that +0x574 from `SPAwallright` is exactly `SPAgwallright` (and +0x56E from `SPAwallleft` is `SPAgwallleft`) | Code |
| **Board checks, bench check, cross-check animation** | No: `FallDown` picks from `SPAfallfwd`, `SPAfallback`, `SPAflip`, `SPAstumble`, `SPAinjury1` | Yes: 94G `FallDown` adds `SPAboardfront/back/left/right`, `SPAbenchcheckl/r`, `SPAcrosscheck`, `SPAinjuryfall` (94S has the same family) | **No (93-like).** `FallDown` (28BB:1848) uses only `SPAfallfwd`, `SPAfallback`, `SPAflip`, `SPAstumble`, `SPAinjury1` (plus `SPAreffallback` for the referee). None of the board, bench or cross-check animations exist in `SPAlist`. `checkcheck` (28BB:0284) uses `SPAsweepchk`, `SPAHold`, `SPAhook`, `SPAburst` and the `CheckAnims` table | Code |
| **Penalty shots** | None | Yes: `PenShotChk` turns a penalty on a breakaway into a penalty shot; there are penalty-shot forms of the penalties (`PenDatachargeps` etc.) and `BA_PS_flags` | **Not found (93-like).** `checkcheck` calls `AddPenalty` directly with no breakaway or penalty-shot check. The penalty names have no duplicate penalty-shot forms. There is no penalty-shot assignment in `asstab`. Note: routines labelled `PenShotStart` / `PenShotAssign` (2164:00E0 / 2164:0152) were named by their position in 95 PC. The code sends skaters to `asstakeposition` / `assleavebox` / `assbenchwait` after the referee's whistle and doesn't look like a penalty shot, so those labels need review | Code (absence) |
| **Shootout mode** | None | Yes: 94G `shootout94.asm`, `shootoutpath94.asm`; 94S the same | **Not found (93-like).** No shootout strings or code. The `clockcont_0` header comment mentions "shootout", but no shootout code was found to back it up, so that comment needs review | Data (absence) |
| **In-game team stats** | 8 rows: Score, Shots, Power Play, Penalties, Faceoffs Won, Body Checks, Attack Zone, Passing (93G `stats93.asm` TeamStatTextTbl) | 16 rows: adds Shooting Pct, PP Minutes, PP Shots, SH Goals, Breakaways, One-Timers, Penalty Shots, Passing Pct (94G `period94.asm`, 94S `TeamStatNames.asm`) | **The 93 list, in the same order (93-like):** Score, Shots, Power play, Penalties, Faceoffs won, Body checks, Attack zone, Passing (`data/far/stat_names.asm`). The PC league stats screens (PP / SH goal leaders etc.) are separate and PC-only | Data |
| **Players per game** | 2 | 4-way play (94G `fourway94.asm`; 94S multitap) | **2 (not 94-like).** Only `cont1team` / `cont2team` exist; `SetupControllers` (1F9C:0000) sets up two players | Code |
| **Manual goalie toggle** | No pause-menu goalie mode | 94G pause item "Manual Goalie / Auto Goalie" (`period94.asm` ManualGoalieMenu) | **Not found.** The PC menus have Home / Visiting Team Goalie, but that picks which goalie starts. The PC also has PULL GOALIE / RETURN GOALIE, like both consoles | Data |
| **Hot / cold streaks and scouting text** | 93S has a scouting report; no hot / cold | 94G hot / cold tables (`Create_HotCold_Table`, `HotColdIcon`) feed the ratings | **Not found** | Data (absence) |
| **Organ music** | Eight songs in all ($30-$37: goal, period start, power play, faceoff, title and so on); no per-team organ tunes and no organ credit | Per-team organ tunes (94G `arena94.asm` `TeamSongs`), credited "Organ Music by Dieter Ruehle" | **The 94 per-team organ set**, loaded from `.KMS` files (`LoadArenaJingles` 2137:0004, `PlayArenaJingle`), credited "Organ Music" / Dieter Ruehle. 50 of its 53 tunes match 94 SNES note for note; see Music and packaging | Code |
| **Line changes, energy, injuries, instant replay, pulling the goalie, playoffs** | Yes | Yes | Yes | Present in all of them, so they don't separate 93 from 94 | Data |
| **Referee on the ice** | No referee animations | No referee animations | **PC-only:** `SPArefglide` ... `SPArefbehind` with penalty signals, and the `assref*` assignments | Code |
| **Anthem, Stanley Cup presentation, three stars skate** | `SPAstanley` celebration only | `SPAstanley` only | **PC-only:** `SPAanthem1-5`, `SPAgetcup`, `SPAbrcup`, `SPAgvcup`, `SPAstansk`, `assstarskate`, `assthreestars` | Code |
| **Other PC-only gameplay bits** | | | Faceoff poke (`SPAfaceoffpoke`), Abuse of Official and Checking from Behind penalties, a Faceoffs rating, Shoot/Pass Bias shown on the card, league / season mode with leader boards, mouse / joystick setup | Data |

## Teams and rosters

The PC teams and players come from the game's data files: `TEAMS.DB` (26 records of 744 bytes: abbreviation, full name,
city, then 28 roster slots that point into `KEY.DB`), `KEY.DB` (710 player records of 52 bytes: jersey, position, first
and last name, pointers to ratings and stats) and `ATT.DB` (20 ratings per player, each 0-15). The console columns come
from the console team data (`teamdata93.asm` / `teamdata94.asm` and the SNES equivalents) with the player names.

| | 93 consoles | 94 consoles | 94 PC | Confidence |
|---|---|---|---|---|
| **Teams** | 24 + All Stars East / West | 26 (adds Anaheim, Florida; Minnesota becomes Dallas) + All Stars East / West | **24** + Campbell All Stars / Wales All Stars. Minnesota North Stars (shown as "Minnesota Stars"), no Dallas, Anaheim or Florida | Data |
| **Team names** | City and abbreviation only, no nicknames ("New York", "Long Island", "Minnesota"): the NHLPA-only licence | City, nickname and arena ("Boston Bruins"); team logos marked "New in 94" (`logos94.asm`) | **Full NHL names** ("Boston Bruins"), per-team crests, jerseys and logos (`EMB*.QPP`, `JER*H/V.QPP`, `CRESTS*.BIN`), i.e. NHL-licensed like 94 | Data |
| **Conference / All-Star names** | East / West | East / West | Campbell / Wales (the 1992-93 conference names) | Data |
| **Players per team** | 22-25 (Ottawa 17, Tampa Bay 18); 601 in all | 94G 25 (Washington 24, Florida 17, Anaheim 18), 684 in all; 94S 22-25, 653 in all | **26-28** of 28 slots, 3 goalies each; 659 different players on the 24 teams; the All-Star teams have 25 each | Data |
| **Roster season** | About 1991-92 (no Lindros, Selanne, Potvin, Zamuner) | The 1992-93 rosters, plus Dallas and the June 1993 expansion draft for Anaheim and Florida | **End of 1992-93**: deadline trades in, All-Star teams match the February 1993 game | Data |
| **Same player on the same team as PC** | 353 of 660 PC roster spots (53%) | 94G 561 (85%), 94S 537 (81%) | (reference) | Data |
| **1993-94 rookies** (Daigle, Pronger, Arnott, Brodeur, Renberg, Niedermayer, Yashin) | Absent | Absent | Absent | Data |

Where some well-known players are (PC / 93 Genesis / 94 Genesis / 94 SNES):

| Player | 94 PC | 93 Genesis | 94 Genesis | 94 SNES |
|---|---|---|---|---|
| Grant Fuhr | BUF | TOR | BUF | BUF |
| Paul Coffey | DET | LA | DET | DET |
| Dominik Hasek | BUF | CHI | BUF | BUF |
| Ron Hextall, Steve Duchesne | QUE | PHI | QUE | QUE |
| Bob Kudelski | OTT | LA | OTT | OTT |
| Eric Lindros, Teemu Selanne, Felix Potvin, Rob Zamuner | PHI, WPG, TOR, TB | not in the game | same as PC | same as PC |
| Mike Modano, Jon Casey | MIN | MIN | DAL | DAL |
| Scott Mellanby | EDM | EDM | EDM and FLA | FLA |
| Brian Skrudland | CGY | MTL | CGY and FLA | FLA |
| Guy Hebert | STL | STL | STL and ANH | ANH |

The PC All-Star teams carry the 1993 game's one-time picks (Campbell: Gretzky, Kisio, Falloon, Bradley; Wales: Marsh,
Sidorkiewicz, Zalapski, Duchesne), which is how the roster date was pinned. 94 Genesis lists some expansion-draft players
twice, on the old team and the new one (the "and" rows above). (Data)

**Ratings.** All three generations store the same 16 four-bit values per player: jersey (two digits), weight, agility
(leg power), speed, offensive and defensive awareness, shot power, checking, handedness, stickhandling, shot accuracy,
endurance, shot/pass decision, passing and aggressiveness (Data). The ranges differ: 93 Genesis uses 0-15, 94 Genesis
mostly 0-6, and PC `ATT.DB` uses 0-15 like 93 (Data). Example, Ray Bourque: 93 Genesis `778FCCCFF1F6F3F5`, 94 Genesis
`77A5446560556252`, PC `ATT.DB` `01 0a 0d 08 0e 0f 0e 0d 0e 0e 0a 0f 05 0f 04 01 0a 0a 0a 07`. The PC's 20 bytes include
Faceoffs and other extras; their order wasn't fully mapped, so no field-by-field PC comparison is claimed.

**Verdict:** PC rosters are the 1992-93 rosters the 94 consoles were built from, before expansion, under the full NHL
licence. They aren't the older NHLPA 93 rosters.

## Skating and shooting physics

**How units line up.** On both platforms one game-clock second is 24 game steps. The consoles set `jps=24` and subtract
`jiffy=$10000/jps` each step (`ram93.asm`, `ram94.asm`). The PC's `ClockTick` (2E42:2C30) reloads `clockticks` with 0x18,
and `RunGameFrames` (1E7E:0404) calls `DoGameFrame` once per tick. So a per-step constant on one platform compares directly
with the other. The consoles also multiply by d7 (frames since the last step) to catch up; the PC has no such factor.
Distances are in the same rink units on all three, but the PC rink has a different shape, so the table gives a
rink-scaled figure where it matters. Everything in this section is **Code** (the routines were read), except where noted.
94 SNES wasn't traced number by number; the 94 column is 94 Genesis.

| | 93 Genesis | 94 Genesis | 94 PC |
|---|---|---|---|
| **Rink half-size: side boards / end boards / goal line / blue line** | 136 / 298 / 264 / 88 (`checkwallcoll` #$88, #$12A) | Same as 93 | **160 / 264 / 232 / 78** (`checkwallcoll` 28BB:2A54: 0xA0, 0x108; offside 0x4E; icing 0xE8). About 0.886 x the console length and 1.176 x the width |
| **Position update** | position += velocity x 16 x d7 | x 17 (NTSC) | **x 16, fixed** (`updateplayers` 2E42:1D36) |
| **Friction** | velocity -= max(1, velocity >> 6); >> 9 with friction off | Same | Same |
| **Puck gravity** | 96 per step | Not compared | 96 per step |
| **Acceleration** (`playeracc`) | direction step (200 straight, 141 diagonal) x (32 - weight/8 + agility) >> 5 x d7; goalies add agility + 8 | (64 - weight/4 + agility [+2 crowd boost]) [goalie + agility + 16] / 2 >> 5 x d7; a joypad-controlled puck carrier gets half | **The 93 formula** with direction steps 175 / 124, pre-scaled by (agility + 48) >> 6, then x (agility - weight/8 + 32) [goalie + agility + 8] >> 5 (2425:080C) |
| **Top speed** | table ((n + 20) x 275)², i.e. 5500-9625; index (speed x energy) >> 12 | Same table; speed 0-30 with a +2 crowd boost, halved, odd values interpolated; a goalie with the puck gets half | **Own table:** square roots exactly 4800 + 220n - n², i.e. 4800-7875; index (energy x speed) >> 12 as in 93; injured players get 1/8. Scaled to the PC rink, the console range is about 4870-8530, so the fastest PC skaters are slower |
| **Stopping** (`stopna`) | 150 per axis | 150 | 150 (2425:0D44) |
| **Turn rate** | 0x300 minus speed class, minimum 0x180, steps of 0x10 | Same | Same (`doplayeracc_ftab`) |
| **Energy drain** (1 call in 128) | -33, plus the signed endurance value above 0xC00 | -33, plus endurance/2 | -33, plus endurance (unsigned), capped at 0x1000 |
| **Shot power** (`doshot`) | speed x (shot power x energy + 20) x $5249 >> 16; backhand -25% | Shot power halved; one-timers have a minimum speed | **93 structure** (28BB:2630) plus boosts: +2 shot power above 12 when close (under 500), +1 each above 14, 13 and 10 |
| **Perfect shot** | distance <= 200 and rnd(16 + accuracy) > 14 | Uses accuracy/2; always perfect with the goalie pulled or in a shootout | Same test as 93; accuracy +1 above 14 and +1 above 13 |
| **Aim error** | ((speed/16 - accuracy + 16) x distance) >> 6, halved inside 250; x capped at 136, y at 60 | Same caps | Same formula; **x cap 160** (136 x 1.176, the rink-width ratio) |
| **Shot vector** | speed x $44 (68) x d / distance; lift $B33, capped at $1800 | Same, plus a top-shelf lift adjustment | **Multiplier 0x3B (59)**: 59/68 = 0.868, about the rink-length ratio; target y 232 (the PC goal line); lift $B33, cap $1800 |

**Verdict:** the skating and shooting code is the 93 code, retuned for a wider, shorter rink: same friction, stopping, turn
rate and gravity, the 93 acceleration and shot formulas, rink-scaled caps, a slower top-speed table and some extra
rating boosts. None of the 94 changes (halved ratings, crowd speed boost, half acceleration for the puck carrier,
one-timer speed floor, top-shelf lift) are in it.

Two labels in `dgroup.asm` look wrong (not renamed here): `ShotSpeeds` marks a table of shot x-offsets (0, $C, $10, ...,
the values of 93's `.shotsets`), and `AccelFactors` is the top-speed (speed squared) table.

## Music and packaging

**Composer.** "Organ Music" is credited to Dieter Ruehle in the PC credits (`data/far/credits.asm`: `str_OrganMusic`,
`str_DieterRuehle`) and in 94 Genesis ('Organ Music by' / 'Dieter Ruehle', `teamdata94.asm`). 93 Genesis has no organ
credit and no per-team organ tunes, only eight songs ($30-$37). (Data)

**Organ tunes.** The PC game ships 53 team organ files (`BOS1-3.KMS` ... `WINN2.KMS`, loaded by `LoadArenaJingles`). The
94 SNES game has 53 named organ tunes. The PC files use the same EA song format as the 94 SNES songs, so the notes could
be compared directly (pitch steps and timing on every track):

- 50 PC files match a 94 SNES tune note for note (for example `BUF2` = Sabre Dance, `HART1` = Brass Bonanza, `CHIC1` = Here
  Come the Hawks, `MON2` = Halte la, `SHK2` = Jaws, `PITTS2` = Defense).
- The other 3 are close but not identical: `PHIL2` vs Buildup [F], `PITTS4` vs Drunken Sailor, `SHK7` vs Hava Nagila
  (same length and tune family, different notes in places).
- Every PC file sits with the team that uses that tune in 94 SNES (`LA4` = Go Team Go [C], used by LA; `WINN2` = Gypsy
  Spain / Charge, used by Winnipeg and Ottawa).

So the whole 94 SNES organ set is in the PC game, 50 of 53 exactly (Code). 94 Genesis lists 72 organ tunes in
`sound94.asm`: the same repertoire, with more key and tempo variants and its own set for Anaheim, Florida, Ottawa and
Winnipeg. The Genesis streams use a different format and weren't compared note for note, so "every Genesis tune is on PC"
isn't claimed (Not checked). This agrees with Abdul's finding from NHL9X Studio that Ruehle's organ music is in the PC
version.

**Other songs.** Per Abdul's comparison, the PC soundtrack is generally the same as 94 SNES / Genesis:

| PC song | Per Abdul's comparison | Checked here (notes compared) |
|---|---|---|
| Awards (`ADAWARDS`) | Genesis / Sega CD main menu music | Matches the 94 Genesis title / menu song ($78) exactly, and the 94 SNES song labelled "PlayoffSong" |
| Game Summary (`ADSUM`) | Genesis / Sega CD Intermission song and the SNES main menu song | Matches the 94 Genesis end-of-period song ($79) and the 94 SNES song labelled "MenuSong" (both near-exact) |
| Intro (`ADTITLE`, `TITLE`) | Genesis Scouting Report music, the SNES Intro song and the Sega CD Intro song | Matches the 94 Genesis Scouting Report song ($7A) exactly. Against 94 SNES it is a partial match (shared phrases, not note for note) to the song labelled "TitleSong" |

Sega CD wasn't checked here.

**Packaging.** Per Abdul's comparison (not checked here): the 94 PC floppy labels and the 94 Genesis cartridge label use the
same design: EA Sports banner, NHL logo block, NHL shield and NHLPA logos, red and black layout. The PC disk says "NHL
Hockey" and the cartridge "NHL '94".

## What this means

The PC game isn't a straight NHLPA 93 port, and it isn't a straight NHL 94 port either:

- **94-like content:** full NHL licence (team names, crests), the 1992-93 rosters the 94 consoles were built from,
  Ruehle's 94 organ set (the 94 SNES tunes, 50 of 53 note for note) and the 94 menu music.
- **94-like gameplay:** fighting is gone, all the way down to the collision routine and the player card. One-timers are
  in, for the player and for the CPU, coded the way NHL 94 SNES does them (receiver swing, forehand / backhand pick). It
  has the 94 SNES goalie wall animations, which no 93 game has.
- **93-like engine:** skating and shooting are the 93 formulas, retuned for the PC rink, with none of the 94 physics
  changes. The checking and fall animations are the 93 set. No penalty shots, no shootout, the 93 eight-row team stats,
  two players.
- **PC-only:** a referee on the ice, anthems, the Stanley Cup presentation, three stars, a league mode, a Faceoffs
  rating, a different rink shape and its own top-speed table.

The missing Anaheim and Florida reflect the roster date (end of 1992-93, before expansion), not an NHLPA 93 base. The
game is a 93-generation engine carrying 94 content and the headline 94 gameplay changes, released alongside the 94
consoles.

## Limits

- A "not found" is a search of this labelled source (names, strings, animation and assignment tables). A feature hidden
  under an unrelated name could still have been missed.
- Physics compares 93 Genesis, 94 Genesis and PC. 94 SNES and goalie reactions weren't compared number by number.
- The PC `ATT.DB` rating order wasn't fully mapped.
- 94 Genesis and Sega CD music weren't compared note for note; packaging is from Abdul's comparison.
