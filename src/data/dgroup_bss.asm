; DGROUP uninitialized data (BSS): no bytes in the file; the startup code clears it. Variables follow
; dgroup.asm in the same group.
MapLo:                                          ; word; used by EmitByte, Expand
        resb 2
MapHi:                                          ; word; used by EmitByte, Expand
        resb 2
OutPtr:                                         ; word; used by EmitByte, ReadVar, Expand
        resb 2
UnpackSpare1:                                   ; word before InPtr; not used in the EXE (overlays may use it)
        resb 2
InPtr:                                          ; word; used by EmitByte, ReadVar, Expand
        resb 2
UnpackSpare2:                                   ; word before MapPair; not used in the EXE (overlays may use
                                                ; it)
        resb 2
MapPair:                                        ; word; used by EmitByte, Expand
        resb 2
BitBuf:                                         ; word; used by EmitByte, ReadVar
        resb 2
UnpackSpare3:                                   ; word before BitCount; not used in the EXE (overlays may use
                                                ; it)
        resb 2
BitCount:                                       ; word; used by EmitByte, ReadVar
        resb 2
SentencePtr:                                    ; current speech sentence; used by SpeechTimerTick,
                                                ; ResetSentence, SpeechInit ...
        resb 2
SentenceSeg:                                    ; its segment; used by ResetSentence, SpeechInit,
                                                ; SpeechShutdown ...
        resb 2
PauseSampleOff:                                 ; silent sample, offset; used by MakePauseSample,
                                                ; PlayPauseSample
        resb 2
PauseSampleSeg:                                 ; silent sample, segment; used by MakePauseSample,
                                                ; PlayPauseSample
        resb 2
WantedList:                                     ; samples wanted, offset; used by ResetWantedSamples,
                                                ; SpeechInit, SpeechShutdown ...
        resb 2
WantedListSeg:                                  ; samples wanted, segment; used by ResetWantedSamples,
                                                ; SpeechInit, SpeechShutdown ...
        resb 2
SpeechBank:                                     ; speech bank, offset; used by SpeechTimerTick,
                                                ; InitSpeechBank, SpeechInit ...
        resb 2
SpeechBankSeg:                                  ; speech bank, segment; used by SpeechTimerTick,
                                                ; InitSpeechBank, SpeechInit ...
        resb 2
MoveBlockOff:                                   ; moveMemBlock target, offset; used by SpeechInit,
                                                ; MoveMemBlock
        resb 2
MoveBlockSeg:                                   ; moveMemBlock target, segment; used by SpeechInit,
                                                ; MoveMemBlock
        resb 2
RandomBlockDone:                                ; 88 flags of the blocks already drawn (FadeRandomBlocks2);
                                                ; used by FADES8
        resb 88
ShadeTableOff:                                  ; shade table being built, offset; used by ShadeColor
        resb 2
ShadeTableSeg:                                  ; shade table being built, segment; used by ShadeColor
        resb 2
ShadeFactorR:                                   ; red factor; used by ShadeColor, BuildShadeTable
        resb 2
ShadeFactorG:                                   ; green factor; used by ShadeColor, BuildShadeTable
        resb 2
ShadeFactorB:                                   ; blue factor; used by ShadeColor, BuildShadeTable
        resb 2
ShadeR:                                         ; red result; used by ShadeColor
        resb 2
ShadeG:                                         ; green result; used by ShadeColor
        resb 2
ShadeB:                                         ; blue result; used by ShadeColor
        resb 2
ShadeGrey:                                      ; grey the result; used by ShadeColor, BuildShadeTable
        resb 2
MidiMsg:                                        ; MIDI message being sent: status byte; used by SeqStepTrack,
                                                ; SendController, SendVoiceNoteOff ...
        resb 1
MidiMsg1:                                       ; first data byte; used by SendController, SendVoiceNoteOff,
                                                ; SendPitchBend ...
        resb 1
MidiMsg2:                                       ; second data byte; used by SendController, SendVoiceNoteOff,
                                                ; SendPitchBend ...
        resb 62
PatchMsg:                                       ; patch message: status byte; used by SendPatches
        resb 1
PatchMsg1:                                      ; patch message byte 1; used by SendPatches
        resb 1
PatchMsg2:                                      ; patch message byte 2; used by SendPatches
        resb 1
PatchMsg3:                                      ; patch message byte 3; used by SendPatches
        resb 1
SongFileName:                                   ; song file name; used by LoadSongMode
        resb 20
SongFileNameEnd:                                ; end of the song file name; used by LoadSongMode
        resb 2
SongBankNum:                                    ; song bank number; used by LoadSongMode
        resb 4
SfxMsg:                                         ; effect message: status byte; used by PlayPatchNote
        resb 1
SfxMsg1:                                        ; effect message byte 1; used by PlayPatchNote
        resb 1
SfxMsg2:                                        ; effect message byte 2; used by PlayPatchNote
        resb 6
DrvTableName:                                   ; driver table: name, entry -8; used by LoadSoundDriver
        resb 2
DrvTableSeg:                                    ; driver table: segment, entry -6; used by LoadSoundDriver
        resb 6
DrvTableInit:                                   ; driver table: init routine (38h-byte entries); used by
                                                ; LoadSoundDriver, DrvInit
        resb 4
DrvTableCall04:                                 ; driver table: routine +4; used by LoadSoundDriver, DrvCall04
        resb 4
DrvTableCall08:                                 ; driver table: routine +8; used by LoadSoundDriver, DrvCall08
        resb 4
DrvTableShutdown:                               ; driver table: shutdown routine; used by DrvShutdown
        resb 4
DrvTableCall10:                                 ; driver table: routine +10h; used by DrvCall10
        resb 4
DrvTableService:                                ; driver table: service routine; used by DrvService
        resb 4
DrvTableNeedsService:                           ; driver table: needs-service routine; used by
                                                ; LoadSoundDriver, DrvNeedsService
        resb 4
DrvTableLoadBank:                               ; driver table: load bank routine; used by DrvLoadBank
        resb 16
DrvTableSendMidi:                               ; driver table: send MIDI routine; used by DrvSendMidi
        resb 8
DrvTablePlaySample:                             ; driver table: play sample routine; used by DrvPlaySample,
                                                ; DrvPlayRecSample
        resb 140
StrBufPtr:                                      ; sprintf string stream: pointer; used by _sprintf
        resb 2
StrBufCnt:                                      ; sprintf string stream: space left; used by _sprintf
        resb 2
StrBufBase:                                     ; sprintf string stream: base; used by _sprintf
        resb 2
StrBufFlag:                                     ; sprintf string stream: flags; used by _sprintf
        resb 2
FloatArgPtr:                                    ; float argument being formatted; used by FloatBuf,
                                                ; FloatWidth, FormatOne
        resb 10
FltOutFlags:                                    ; float output flags; used by FpScale
        resb 1
FltOutFlags1:                                   ; float output flags, high byte; used by FpScale
        resb 1
FltOutExp:                                      ; float output exponent; used by FpScale
        resb 294
FrameTable:                                     ; frame pointer table (offset words) built by IndexPPVFrames;
                                                ; used by GAME
        resb 2
FrameTableSeg:                                  ; frame pointer table (segment words); used by GAME
        resb 3502
GameTeamRecs:                                   ; team records read by LoadGameTeams (76 bytes); used by INIT
        resb 76
GamePlayerNames:                                ; player name pointers (offset) of the game summary and
                                                ; lineups; used by INIT
        resb 2
GamePlayerNamesSeg:                             ; player name pointers (segment); used by INIT
        resb 110
HomeLinesRec:                                   ; home line record written by WriteTeamLines; used by MENUS
        resb 48
TeamLinesRecs:                                  ; line records written by WriteTeamLines; used by MENUS
        resb 508
GameRosterRecs:                                 ; roster records read by LoadGameTeams (744 bytes); used by
                                                ; INIT
        resb 744
hmroster:                                       ; home roster records; used by AI, INIT, MENUS
        resb 6
hmrosterjersey:                                 ; jersey byte of the home roster records; used by AI, INIT,
                                                ; MENUS
        resb 1
hmrosterpos:                                    ; position byte of the home roster records; used by AI
        resb 1113
GamePlayerFlags:                                ; player flags filled by LoadGameTeams; used by INIT
        resb 1120
HomeTeamRec:                                    ; home team record saved with the game (36 bytes); used by
                                                ; INIT
        resb 36
HomeTeamAbbr:                                   ; first byte of the home team abbreviation; used by INIT
        resb 1
HomeTeamAbbr_b1:                                ; rest of the home team abbreviation; used by INIT
        resb 3
HomeTeamColours:                                ; home team colour bytes (LoadGameTeams); used by INIT
        resb 8
AwayTeamRec:                                    ; away team record saved with the game (36 bytes); used by
                                                ; INIT
        resb 36
AwayTeamAbbr:                                   ; first byte of the away team abbreviation; used by INIT
        resb 1
AwayTeamAbbr_b1:                                ; rest of the away team abbreviation; used by INIT
        resb 3
AwayTeamColours:                                ; away team colour bytes; used by INIT
        resb 8
gsummarypath:                                   ; path of gsummary.db (GSummaryPath); used by INIT
        resb 32
HeapSizeLo:                                     ; heap size, low word; not used in the EXE (overlays may use
                                                ; it)
        resb 2
HeapSizeHi:                                     ; heap size, high word; not used in the EXE (overlays may use
                                                ; it)
        resb 2
POTreeBuf:                                      ; far pointer (offset) to the playoff tree buffer; used by
                                                ; MENUS
        resb 2
POTreeBufSeg:                                   ; its segment; used by MENUS
        resb 2
DialogData:                                     ; dialog data, offset; used by ListDialog, SaveUnderBox,
                                                ; MessageBoxLoop ...
        resb 2
DialogDataSeg:                                  ; dialog data, segment; used by ListDialog, SaveUnderBox,
                                                ; MessageBoxLoop ...
        resb 2
ChainIdx:                                       ; word; used by MakeChain, AllocLinearCanvas, AllocCanvas ...
        resb 2
ChainPtr:                                       ; word; used by MakeChain, DropOldest, FindName ...
        resb 2
HeapVar0:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapList:                                       ; far heap list; used by LargestFreeBlock
        resb 2
HeapVar1:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar2:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar3:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar4:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar5:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar6:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
HeapVar7:                                       ; heap variable; not used in the EXE (overlays may use it)
        resb 2
MemBlock1Off:                                   ; memory block 1, offset; not used in the EXE (overlays may
                                                ; use it)
        resb 2
MemBlock1Seg:                                   ; memory block 1, segment; not used in the EXE (overlays may
                                                ; use it)
        resb 2
MemBlock2Off:                                   ; memory block 2, offset; not used in the EXE (overlays may
                                                ; use it)
        resb 2
MemBlock2Seg:                                   ; memory block 2, segment; not used in the EXE (overlays may
                                                ; use it)
        resb 2
MemBlock3Off:                                   ; memory block 3, offset; not used in the EXE (overlays may
                                                ; use it)
        resb 2
MemBlock3Seg:                                   ; memory block 3, segment; not used in the EXE (overlays may
                                                ; use it)
        resb 18
InputFlags:                                     ; input device flags; used by PollInputEvents
        resb 2
InputQueue:                                     ; input event queue; used by PollInputEvents
        resb 256
CursorX:                                        ; cursor x; used by PollInputEvents
        resb 2
CursorY:                                        ; cursor y; used by EventToCursor, PollInputEvents
        resb 152
PadStatePtr:                                    ; pad state being updated; used by StickToPad, PadTimerTick
        resb 2
curevent:                                       ; current game summary event record; used by AI, INIT
        resb 2
curevent_b1:                                    ; current event byte +1; used by AI
        resb 1
curevent_b2:                                    ; current event byte +2; used by AI
        resb 1
curevent_b3:                                    ; current event byte +3; used by AI
        resb 1
curevent_b4:                                    ; current event byte +4; used by AI
        resb 1
curevent_b5:                                    ; current event byte +5; used by AI
        resb 1
curevent_b6:                                    ; current event byte +6; used by AI
        resb 1
curevent_b7:                                    ; current event byte +7; used by AI
        resb 1
curevent_b8:                                    ; current event byte +8; used by AI
        resb 1
curevent_b9:                                    ; current event byte +9; used by AI
        resb 1
curevent_b10:                                   ; current event byte +10; used by AI
        resb 1
goalevent:                                      ; goal event pending (1); used by AI, INIT
        resb 2
goalevent_b1:                                   ; scorer jersey of the goal event; used by AI
        resb 1
goalevent_b2:                                   ; first assist jersey; used by AI
        resb 1
goalevent_b3:                                   ; second assist jersey; used by AI
        resb 1
goalevent_text:                                 ; team abbreviation of the goal event; used by AI
        resb 17
HotKeyFn:                                       ; far routine for hot keys; used by ListDialog,
                                                ; MessageBoxLoop, SaveGameNameDialog ...
        resb 2
HotKeyFnSeg:                                    ; its segment; used by InputInit
        resb 2
TextOverlayPtr:                                 ; text overlay string pointer (offset); used by AI, GAME,
                                                ; INIT, MENUS
        resb 2
TextOverlaySeg:                                 ; its segment; used by AI, GAME, INIT, MENUS
        resb 2
viewcellx:                                      ; scroll position in 8-pixel cells, x; used by AI, GAME, INIT
        resb 2
viewcelly:                                      ; scroll position in 8-pixel cells, y; used by AI, GAME, INIT
        resb 2
RinkMapWidth:                                   ; rink map width in cells; used by INIT
        resb 2
RinkRowBytes:                                   ; bytes per rink row; used by GAME, INIT
        resb 2
otherscoresb:                                   ; other games: scores (12 bytes); used by INIT
        resb 12
otherscorehome:                                 ; other games: home team bytes; used by INIT
        resb 1
otherscorehome_b1:                              ; other games: home team bytes from +1; used by INIT
        resb 11
otherscoreaway:                                 ; other games: away team bytes; used by INIT
        resb 1
otherscores:                                    ; other games: away team bytes from +1; used by INIT
        resb 11
scrolldelay:                                    ; scroll redraw countdown; used by GAME, INIT
        resb 2
TeamPalette1:                                   ; first team palette; used by LoadTeamPalettes
        resb 67
PanelText:                                      ; panel text bytes (DrawHudPanel); used by AI, MENUS
        resb 189
TeamPalette2:                                   ; second team palette; used by LoadTeamPalettes
        resb 5
LockerText1:                                    ; locker room text byte 1; used by MENUS
        resb 2
LockerText2:                                    ; locker room text from +2; used by MENUS
        resb 9
LockerText3:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText4:                                    ; locker room text bytes; used by MENUS
        resb 2
LockerText5:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText6:                                    ; locker room text bytes; used by MENUS
        resb 2
LockerText7:                                    ; locker room text block; used by MENUS
        resb 45
PanelText2:                                     ; panel text bytes; used by AI, MENUS
        resb 6
LockerText8:                                    ; locker room text block; used by MENUS
        resb 7
LockerText9:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText10:                                   ; locker room text block; used by MENUS
        resb 15
LockerText11:                                   ; locker room text block; used by MENUS
        resb 155
LockerText12:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText13:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText14:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText15:                                   ; locker room text block; used by MENUS
        resb 8
ArenaJingleSet:                                 ; arena jingle per team; used by PlayArenaJingle
        resb 2
BoxSaveX:                                       ; box save x; used by PlayArenaJingle, SaveUnderBox,
                                                ; RestoreUnderBox
        resb 2
BoxSaveY:                                       ; box save y; used by SaveUnderBox, RestoreUnderBox
        resb 2
YesNoText:                                      ; askYesNo text, offset; used by AskYesNo
        resb 2
YesNoTextSeg:                                   ; askYesNo text, segment; used by AskYesNo
        resb 2
MessageBoxSel:                                  ; message box selection (FFFFh for none); used by
                                                ; MessageBoxReset
        resb 2
ArenaJingleArg1:                                ; arena jingle argument; used by PlayArenaJingle
        resb 2
ArenaJingleArg2:                                ; arena jingle argument; used by PlayArenaJingle
        resb 2
JingleSongOff:                                  ; jingle song, offset; used by PlayJingle
        resb 2
JingleSongSeg:                                  ; jingle song, segment; used by PlayJingle
        resb 2
JingleBufOff:                                   ; jingle buffer, offset; used by PlayJingle
        resb 2
JingleBufSeg:                                   ; jingle buffer, segment; used by PlayJingle
        resb 2
JingleTempo:                                    ; jingle tempo (14h); used by PlayJingle
        resb 5
JingleChannel:                                  ; jingle channel (FFh); used by PlayJingle
        resb 1
JingleVolume:                                   ; jingle volume (3Fh); used by PlayJingle
        resb 1
JinglePan:                                      ; jingle pan; used by PlayJingle
        resb 5
ArenaJingleA:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleASeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 2
JingleBuf1:                                     ; jingle buffer pointer 1 (offset); used by INIT
        resb 2
JingleBuf1Seg:                                  ; its segment; used by INIT
        resb 2
JingleBuf2:                                     ; jingle buffer pointer 2 (offset); used by INIT
        resb 2
JingleBuf2Seg:                                  ; its segment; used by INIT
        resb 2
ArenaJingleB:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleBSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 2
JingleBuf3:                                     ; jingle buffer pointer 3 (offset); used by INIT
        resb 2
JingleBuf3Seg:                                  ; its segment; used by INIT
        resb 2
JingleBuf4:                                     ; jingle buffer pointer 4 (offset); used by INIT
        resb 2
JingleBuf4Seg:                                  ; its segment; used by INIT
        resb 2
JingleCfgBufs:                                  ; jingle config buffer pointers (offset); used by INIT
        resb 2
JingleCfgBufsSeg:                               ; their segments; used by INIT
        resb 10
JingleKmsBufs:                                  ; jingle song buffer pointers (offset); used by INIT
        resb 2
JingleKmsBufsSeg:                               ; their segments; used by INIT
        resb 10
ArenaJingleC:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleCSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 22
ArenaJingleD:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleDSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 22
VgaSave0Off:                                    ; saved plane 0, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave0Seg:                                    ; saved plane 0, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave1Off:                                    ; saved plane 1, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave1Seg:                                    ; saved plane 1, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave2Off:                                    ; saved plane 2, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave2Seg:                                    ; saved plane 2, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave3Off:                                    ; saved plane 3, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave3Seg:                                    ; saved plane 3, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
editopts:                                       ; option bits being edited by the settings dialogs; used by
                                                ; MENUS
        resb 1
editopts_b1:                                    ; high byte of editopts; used by MENUS
        resb 1
editctlopts:                                    ; controller option bits being edited; used by MENUS
        resb 2
hmshots:                                        ; home shots; used by INIT
        resb 2
hmppgoals:                                      ; home power play goals; used by INIT, LP
        resb 2
hmppchances:                                    ; home power play chances; used by INIT, LP
        resb 2
hmpenalties:                                    ; home penalty count; used by INIT
        resb 2
hmpenmins:                                      ; home penalty minutes; used by INIT, LP
        resb 2
hmattacktime:                                   ; home attack zone time; used by INIT
        resb 2
hmscore:                                        ; home score; used by AI, INIT, LP, MENUS
        resb 2
hmfaceoffs:                                     ; home faceoffs won; used by INIT
        resb 2
hmchecks:                                       ; home body checks; used by INIT
        resb 2
hmpassatt:                                      ; home pass attempts; used by INIT
        resb 2
hmpasscmp:                                      ; home passes completed; used by INIT
        resb 2
hmtmline:                                       ; home current line; used by AI
        resb 2
hmtmlcnt:                                       ; home line count; used by AI
        resb 2
hmtmextra:                                      ; home extra skater; used by AI
        resb 2
hmtmtouch1:                                     ; home last touch 1; used by AI
        resb 2
hmtmtouch2:                                     ; home last touch 2; used by AI
        resb 2
hmtmtouch3:                                     ; home last touch 3; used by AI
        resb 2
hmtmap:                                         ; home skaters on the ice; used by AI, INIT, MENUS
        resb 2
hmtmgoalie:                                     ; home goalie (negative = pulled); used by AI, INIT, LP
        resb 1
hmtmgoalie_b1:                                  ; home goalie, high byte; used by AI
        resb 5
hmtmflags:                                      ; home team flags (line change mode, offside ...); used by AI,
                                                ; MENUS
        resb 2
hmtmpde:                                        ; home player energy (56 bytes); used by AI
        resb 56
hmtmpdst:                                       ; home player status per roster slot (56 bytes); used by AI
        resb 56
hmtmpbox_m1:                                    ; home team bytes before hmtmpbox (28 bytes); used by AI
        resb 28
hmtmcoach_d2:                                   ; home coach data byte; used by AI
        resb 1
hmtmcoach_d3:                                   ; home coach data byte; used by AI
        resb 1
hmtmcoachflags:                                 ; home coach flags; used by AI
        resb 1
hmtmcoachmode:                                  ; home coach mode; used by AI
        resb 1
hmtmcoachenergy:                                ; home coach energy setting; used by AI
        resb 2
hmtmlines:                                      ; home line table pointer; used by AI, INIT, LP
        resb 2
hmtmsort:                                       ; home sort objects pointer; used by AI, INIT
        resb 2
hmtmplattr:                                     ; home player attributes pointer; used by AI, INIT
        resb 2
hmtmglattr:                                     ; home goalie attributes pointer; used by AI, INIT
        resb 2
hmtmglattrseg:                                  ; its segment; used by AI, INIT
        resb 2
hmtmplstats:                                    ; home player stats pointer; used by AI, INIT
        resb 2
hmtmplstatsseg:                                 ; its segment; used by AI, INIT
        resb 2
hmtmglstats:                                    ; home goalie stats pointer; used by AI, INIT
        resb 2
hmtmroster:                                     ; home roster pointer; used by AI, INIT
        resb 2
hmtmrosterptr:                                  ; home roster pointer; used by AI, INIT
        resb 2
hmtmptrF2:                                      ; home team pointer; used by AI, INIT
        resb 2
hmtmptrs:                                       ; further home team pointers (14 bytes); used by AI, INIT
        resb 14
awscore:                                        ; away score; used by AI, LP, MENUS
        resb 10
awtmline:                                       ; away current line; used by AI
        resb 2
awtmlcnt:                                       ; away line count; used by AI
        resb 2
awtmextra:                                      ; away extra skater; used by AI
        resb 2
awtmtouch1:                                     ; away last touch 1; used by AI
        resb 2
awtmtouch2:                                     ; away last touch 2; used by AI
        resb 2
awtmtouch3:                                     ; away last touch 3; used by AI
        resb 2
awtmap:                                         ; away skaters on the ice; used by AI, INIT
        resb 2
awtmgoalie:                                     ; away goalie (negative = pulled); used by AI, INIT, LP
        resb 6
awtmflags:                                      ; away team flags; used by AI, MENUS
        resb 114
awtmpbox_m1:                                    ; away team bytes before awtmpbox (28 bytes); used by AI
        resb 28
awtmcoach_d2:                                   ; away coach data byte; used by AI
        resb 1
awtmcoach_d3:                                   ; away coach data byte; used by AI
        resb 1
awtmcoachflags:                                 ; away coach flags; used by AI
        resb 1
awtmcoachmode:                                  ; away coach mode; used by AI
        resb 1
awtmcoachenergy:                                ; away coach energy setting; used by AI
        resb 2
awtmteamrec:                                    ; away team record pointer; used by AI, INIT, LP
        resb 2
awtmsort:                                       ; away sort objects pointer; used by AI, INIT
        resb 2
awtmglattrseg:                                  ; segment of the away goalie attributes; used by AI, INIT
        resb 2
awtmglattr:                                     ; away goalie attributes pointer; used by AI, INIT
        resb 2
awtmlines:                                      ; away line table pointer; used by AI, INIT
        resb 2
awtmplstats:                                    ; away player stats pointer; used by AI, INIT
        resb 2
awtmglstats:                                    ; away goalie stats pointer; used by AI, INIT
        resb 2
awtmglstatsptr:                                 ; away goalie stats pointer; used by AI, INIT
        resb 2
awtmglstatsseg:                                 ; its segment; used by AI, INIT
        resb 2
awtmptrF2:                                      ; away team pointer; used by AI, INIT
        resb 2
awtmroster:                                     ; away roster pointer; used by AI, INIT
        resb 2
g_B50C:                                         ; ; used by AI, INIT
        resb 4
sortobj0_Xpos2:                                 ; sort object 0 (sortobj0), field +02h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
sortobj0_Ypos2:                                 ; sort object 0 (sortobj0), field +06h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 20
sortobj0_position:                              ; sort object 0 (sortobj0), field +1Ah; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 42
CwdExciteLvl:                                   ; crowd excitement level; used by AI
        resb 1
sortobj0_pflags2:                               ; sort object 0 (sortobj0), field +45h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
sortobj0_47:                                    ; sort object 0 (sortobj0), field +47h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 1467
sortobj12_Xpos2:                                ; sort object 12 (sortobj12), field +02h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
sortobj12_Ypos2:                                ; sort object 12 (sortobj12), field +06h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 6
sortobj12_Xvel:                                 ; sort object 12 (sortobj12), field +0Ch; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
sortobj12_Yvel:                                 ; sort object 12 (sortobj12), field +0Eh; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 116
sortobj13_Xpos2:                                ; sort object 13 (sortobj13), field +02h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
sortobj13_Ypos2:                                ; sort object 13 (sortobj13), field +06h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 6
sortobj13_Xvel:                                 ; sort object 13 (sortobj13), field +0Ch; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
sortobj13_Yvel:                                 ; sort object 13 (sortobj13), field +0Eh; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 116
puckXpos2:                                      ; sort object 14 (puck), field +02h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
puckYpos2:                                      ; puck sort object field +06h (the object starts 6 bytes
                                                ; before); used by AI
        resb 4
puckZpos2:                                      ; sort object 14 (puck), field +0Ah; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
puckXvel:                                       ; sort object 14 (puck), field +0Ch; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
puckYvel:                                       ; sort object 14 (puck), field +0Eh; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
puckframe:                                      ; sort object 14 (puck), field +12h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 10
puck_1C:                                        ; sort object 14 (puck), field +1Ch; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
puckasslist:                                    ; sort object 14 (puck), field +1Eh; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 8
pucktemp1:                                      ; puck sort object temp1; used by AI
        resb 2
pucktemp2:                                      ; sort object 14 (puck), field +28h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 22
pucknopuck:                                     ; puck sort object nopuck field; used by AI
        resb 7
puckpflags2:                                    ; puck sort object pflags2; used by AI
        resb 3
puck_48:                                        ; sort object 14 (puck), field +48h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 56
doorstruct:                                     ; sort object 15 (door), field +00h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
doorXpos2:                                      ; sort object 15 (door), field +02h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
doorYpos2:                                      ; sort object 15 (door), field +06h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
doorZpos2:                                      ; sort object 15 (door), field +0Ah; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
doorXvel:                                       ; sort object 15 (door), field +0Ch; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
doorYvel:                                       ; sort object 15 (door), field +0Eh; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 4
doorframe:                                      ; sort object 15 (door), field +12h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 20
doortemp1:                                      ; sort object 15 (door), field +26h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
doortemp2:                                      ; sort object 15 (door), field +28h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 16
door_38:                                        ; sort object 15 (door), field +38h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 12
doorpflags:                                     ; sort object 15 (door), field +44h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
doorpflags3:                                    ; sort object 15 (door), field +46h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 2
door_48:                                        ; sort object 15 (door), field +48h; sort objects are 80h
                                                ; bytes from 0B50Eh; used by AI
        resb 56
refstruct:                                      ; sort object 16 (ref), field +00h; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 2
refXpos2:                                       ; sort object 16 (ref), field +02h; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 4
refYpos2:                                       ; referee sort object field +06h; used by AI
        resb 6
refXvel:                                        ; referee x velocity; used by AI
        resb 2
refYvel:                                        ; sort object 16 (ref), field +0Eh; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 4
refframe:                                       ; sort object 16 (ref), field +12h; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 8
refposition:                                    ; sort object 16 (ref), field +1Ah; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 2
ref_1C:                                         ; referee sort object field +1Ch; used by AI
        resb 2
refasslist:                                     ; referee assignment list; used by AI
        resb 8
reftemp1:                                       ; referee temp1; used by AI
        resb 4
reftemp3:                                       ; referee temp3; used by AI
        resb 2
reftemp4:                                       ; sort object 16 (ref), field +2Ch; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 2
reftemp5:                                       ; sort object 16 (ref), field +2Eh; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 8
ref_36:                                         ; sort object 16 (ref), field +36h; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 20
ref_4A:                                         ; sort object 16 (ref), field +4Ah; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 1
ref_4B:                                         ; sort object 16 (ref), field +4Bh; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 1
ref_4C:                                         ; sort object 16 (ref), field +4Ch; sort objects are 80h bytes
                                                ; from 0B50Eh; used by AI
        resb 52
g_BD8E:                                         ; ; used by MENUS
        resb 2
g_BD90:                                         ; ; used by MENUS
        resb 2
g_BD92:                                         ; ; used by MENUS
        resb 2
g_BD94:                                         ; ; used by MENUS
        resb 2
g_BD96:                                         ; ; used by MENUS
        resb 1
gmrosterjersey:                                 ; game roster jersey; used by MENUS
        resb 1
gmrosterslot:                                   ; game roster slot; used by MENUS
        resb 1
g_BD99:                                         ; ; used by MENUS
        resb 1
g_BD9A:                                         ; ; used by MENUS
        resb 1
g_BD9B:                                         ; ; used by MENUS
        resb 1
g_BD9C:                                         ; ; used by MENUS
        resb 544
g_BFBC:                                         ; ; used by MENUS
        resb 1
g_BFBD:                                         ; ; used by MENUS
        resb 2
g_BFBF:                                         ; ; used by MENUS
        resb 1
g_BFC0:                                         ; ; used by MENUS
        resb 1
g_BFC1:                                         ; ; used by MENUS
        resb 1
g_BFC2:                                         ; ; used by MENUS
        resb 60
curperiod:                                      ; current period; used by AI, GAME, INIT, LP, MENUS
        resb 2
g_C000:                                         ; ; used by LP
        resb 32
g_C020:                                         ; ; used by LP
        resb 32
g_C040:                                         ; ; used by LP, MENUS, STATS
        resb 2
statsgoaliebuf:                                 ; goalie stats buffer; used by LP, MENUS, STATS
        resb 2
g_C044:                                         ; ; used by LP, MENUS, STATS
        resb 2
statsskaterbuf:                                 ; skater stats buffer; used by LP, MENUS, STATS
        resb 2
g_C048:                                         ; ; used by LP, MENUS, STATS
        resb 2
statsplayerbuf:                                 ; player stats buffer; used by LP, MENUS, STATS
        resb 2
g_C04C:                                         ; ; used by LP, MENUS, STATS
        resb 2
statsteambuf:                                   ; team stats buffer; used by LP, MENUS, STATS
        resb 2
g_C050:                                         ; ; used by MENUS, STATS
        resb 2
leaguestatsmode:                                ; league stats mode; used by LP, MENUS, STATS
        resb 2
g_C054:                                         ; ; used by MENUS
        resb 2
g_C056:                                         ; ; used by MENUS
        resb 2
g_C058:                                         ; ; used by MENUS
        resb 2
g_C05A:                                         ; ; used by MENUS
        resb 2
g_C05C:                                         ; ; used by MENUS
        resb 2
g_C05E:                                         ; ; used by MENUS
        resb 126
g_C0DC:                                         ; ; used by MENUS
        resb 2
lgfiles:                                        ; league file handles; used by MENUS
        resb 2
g_C0E0:                                         ; ; used by MENUS
        resb 2
g_C0E2:                                         ; ; used by MENUS
        resb 2
g_C0E4:                                         ; ; used by MENUS
        resb 2
lgfilenames:                                    ; league file names; used by MENUS
        resb 126
g_C164:                                         ; ; used by MENUS
        resb 2
g_C166:                                         ; ; used by MENUS
        resb 2
g_C168:                                         ; ; used by MENUS
        resb 2
g_C16A:                                         ; ; used by MENUS
        resb 2
g_C16C:                                         ; ; used by MENUS
        resb 2
g_C16E:                                         ; ; used by MENUS
        resb 126
fdlgtab:                                        ; file dialog table; used by MENUS
        resb 2
g_C1EE:                                         ; ; used by MENUS
        resb 1
g_C1EF:                                         ; ; used by MENUS
        resb 1
g_C1F0:                                         ; ; used by MENUS
        resb 2
g_C1F2:                                         ; ; used by MENUS
        resb 2
g_C1F4:                                         ; ; used by MENUS
        resb 16
playofftree:                                    ; playoff tree; used by MENUS, STATS
        resb 2
g_C206:                                         ; ; used by MENUS
        resb 30
g_C224:                                         ; ; used by MENUS
        resb 20
g_C238:                                         ; ; used by STATS
        resb 2
g_C23A:                                         ; ; used by STATS
        resb 2
g_C23C:                                         ; ; used by STATS
        resb 2
g_C23E:                                         ; ; used by STATS
        resb 2
g_C240:                                         ; ; used by STATS
        resb 2
g_C242:                                         ; ; used by MENUS
        resb 22
g_C258:                                         ; ; used by AI, INIT, MENUS
        resb 2
g_C25A:                                         ; ; used by AI, INIT, MENUS
        resb 2
g_C25C:                                         ; ; used by AI, INIT, MENUS
        resb 2
g_C25E:                                         ; ; used by AI, INIT, MENUS
        resb 2
g_C260:                                         ; ; used by LP
        resb 2
g_C262:                                         ; ; used by LP
        resb 2
g_C264:                                         ; ; used by LP
        resb 2
g_C266:                                         ; ; used by LP
        resb 2
g_C268:                                         ; ; used by LP
        resb 2
g_C26A:                                         ; ; used by LP
        resb 2
g_C26C:                                         ; ; used by LP
        resb 2
g_C26E:                                         ; ; used by LP
        resb 2
g_C270:                                         ; ; used by LP
        resb 2
g_C272:                                         ; ; used by LP
        resb 2
teamselresult:                                  ; team selection result; used by LP
        resb 2
g_C276:                                         ; ; used by LP
        resb 2
g_C278:                                         ; ; used by LP
        resb 2
g_C27A:                                         ; ; used by LP
        resb 2
g_C27C:                                         ; ; used by LP
        resb 2
g_C27E:                                         ; ; used by LP
        resb 14
g_C28C:                                         ; ; used by LP
        resb 14
g_C29A:                                         ; ; used by LP
        resb 1
g_C29B:                                         ; ; used by LP
        resb 1
g_C29C:                                         ; ; used by LP
        resb 1
g_C29D:                                         ; ; used by LP
        resb 1
lgschedrec_b4:                                  ; schedule record byte +4; used by LP
        resb 1
g_C29F:                                         ; ; used by LP
        resb 1
statspalshape:                                  ; stats palette shape; used by LP, STATS
        resb 2
g_C2A2:                                         ; ; used by LP
        resb 2
g_C2A4:                                         ; ; used by LP
        resb 2
g_C2A6:                                         ; ; used by LP
        resb 2
g_C2A8:                                         ; ; used by LP
        resb 2
g_C2AA:                                         ; ; used by LP
        resb 2
g_C2AC:                                         ; ; used by LP
        resb 2
g_C2AE:                                         ; ; used by LP
        resb 2
g_C2B0:                                         ; ; used by LP
        resb 2
statsbgshapes:                                  ; stats background shapes; used by LP, STATS
        resb 2
g_C2B4:                                         ; ; used by LP, STATS
        resb 2
startm:                                         ; three stars: team of each star; used by AI, LP
        resb 2
starpl:                                         ; three stars: player of each star; used by AI, LP
        resb 10
g_C2C2:                                         ; ; used by LP
        resb 1
g_C2C3:                                         ; ; used by LP
        resb 1
g_C2C4:                                         ; ; used by LP
        resb 614
g_C52A:                                         ; ; used by LP
        resb 616
g_C792:                                         ; ; used by LP
        resb 2
g_C794:                                         ; ; used by LP
        resb 2
g_C796:                                         ; ; used by LP
        resb 2
g_C798:                                         ; ; used by LP
        resb 2
g_C79A:                                         ; ; used by LP
        resb 2
g_C79C:                                         ; ; used by LP
        resb 2
g_C79E:                                         ; ; used by LP
        resb 2
g_C7A0:                                         ; ; used by LP
        resb 2
g_C7A2:                                         ; ; used by LP
        resb 2
g_C7A4:                                         ; ; used by LP
        resb 2
g_C7A6:                                         ; ; used by LP
        resb 2
g_C7A8:                                         ; ; used by LP
        resb 2
g_C7AA:                                         ; ; used by LP
        resb 2
g_C7AC:                                         ; ; used by LP
        resb 38
g_C7D2:                                         ; ; used by LP
        resb 2
g_C7D4:                                         ; ; used by LP
        resb 38
g_C7FA:                                         ; ; used by LP
        resb 2
g_C7FC:                                         ; ; used by LP
        resb 10
g_C806:                                         ; ; used by LP
        resb 1023
g_CC05:                                         ; ; used by LP
        resb 36
g_CC29:                                         ; ; used by LP
        resb 703
g_CEE8:                                         ; ; used by STATS
        resb 48
g_CF18:                                         ; ; used by STATS
        resb 2
g_CF1A:                                         ; ; used by STATS
        resb 1
g_CF1B:                                         ; ; used by STATS
        resb 1
statsplayer:                                    ; stats player; used by STATS
        resb 1
g_CF1D:                                         ; ; used by STATS
        resb 16
g_CF2D:                                         ; ; used by STATS
        resb 17
g_CF3E:                                         ; ; used by STATS
        resb 2
g_CF40:                                         ; ; used by STATS
        resb 2
g_CF42:                                         ; ; used by STATS
        resb 2
g_CF44:                                         ; ; used by STATS
        resb 2
g_CF46:                                         ; ; used by STATS
        resb 2
g_CF48:                                         ; ; used by STATS
        resb 2
g_CF4A:                                         ; ; used by STATS
        resb 2
g_CF4C:                                         ; ; used by STATS
        resb 2
g_CF4E:                                         ; ; used by STATS
        resb 50
g_CF80:                                         ; ; used by STATS
        resb 50
g_CFB2:                                         ; ; used by STATS
        resb 10
g_CFBC:                                         ; ; used by STATS
        resb 10
g_CFC6:                                         ; ; used by STATS
        resb 2
g_CFC8:                                         ; ; used by STATS
        resb 2
g_CFCA:                                         ; ; used by STATS
        resb 2
g_CFCC:                                         ; ; used by STATS
        resb 2
g_CFCE:                                         ; ; used by STATS
        resb 2
fileoncd:                                       ; file is on the CD; used by STATS
        resb 2
cddriveptr:                                     ; CD drive pointer; used by STATS
        resb 2
g_CFD4:                                         ; ; used by STATS
        resb 40
g_CFFC:                                         ; ; used by GAME, INIT
        resb 2
g_CFFE:                                         ; ; used by GAME, INIT
        resb 2
regd5:                                          ; register-style work variable d5; used by AI
        resb 2
g_D002:                                         ; ; used by AI
        resb 2
g_D004:                                         ; ; used by AI, INIT
        resb 2
LastShooterTeam:                                ; team of the last shooter; used by AI
        resb 2
g_D008:                                         ; ; used by AI
        resb 2
g_D00A:                                         ; ; used by AI, INIT
        resb 2
g_D00C:                                         ; ; used by AI
        resb 2
g_D00E:                                         ; ; used by AI
        resb 2
g_D010:                                         ; ; used by AI, INIT
        resb 2
g_D012:                                         ; ; used by AI, INIT
        resb 2
g_D014:                                         ; ; used by AI, GAME, INIT
        resb 2
g_D016:                                         ; ; used by AI, GAME, INIT
        resb 2
g_D018:                                         ; ; used by INIT
        resb 2
g_D01A:                                         ; ; used by INIT
        resb 2
g_D01C:                                         ; ; used by AI
        resb 2
g_D01E:                                         ; ; used by AI
        resb 2
g_D020:                                         ; ; used by AI
        resb 2
g_D022:                                         ; ; used by AI
        resb 394
g_D1AC:                                         ; ; used by AI, INIT
        resb 2
rinkobjs:                                       ; rink object slots; used by AI, INIT
        resb 2
rinkobjs_w2:                                    ; rink object slots word +2; used by INIT
        resb 278
g_D2C6:                                         ; ; used by AI, INIT
        resb 2
g_D2C8:                                         ; ; used by AI, INIT
        resb 382
g_D446:                                         ; ; used by AI, INIT
        resb 2
g_D448:                                         ; ; used by AI, INIT
        resb 14
g_D456:                                         ; ; used by AI, INIT
        resb 2
g_D458:                                         ; ; used by AI, INIT
        resb 18
g_D46A:                                         ; ; used by AI, GAME, INIT
        resb 2
g_D46C:                                         ; ; used by AI, GAME, INIT
        resb 2
g_D46E:                                         ; ; used by AI, GAME, INIT
        resb 2
lcline:                                         ; line change: line chosen; used by AI, GAME, INIT
        resb 2
lctimer:                                        ; line change box timer; used by GAME, INIT
        resb 2
g_D474:                                         ; ; used by AI
        resb 34
g_D496:                                         ; ; used by AI, INIT
        resb 34
textline3:                                      ; text line 3; used by AI, INIT
        resb 59
g_D4F3:                                         ; ; used by AI
        resb 1
g_D4F4:                                         ; ; used by AI, INIT
        resb 1
g_D4F5:                                         ; ; used by AI
        resb 17
textline1:                                      ; text line 1; used by AI, INIT
        resb 60
textline2:                                      ; text line 2; used by AI, INIT
        resb 60
textline4:                                      ; text line 4; used by AI, INIT
        resb 60
textline5:                                      ; text line 5; used by AI, INIT
        resb 60
PlList:                                         ; player list; used by AI, INIT
        resb 6
LinePlayersAway:                                ; away line players; used by AI
        resb 6
fofdata2:                                       ; faceoff data; used by AI, INIT
        resb 2
g_D604:                                         ; ; used by AI
        resb 2
g_D606:                                         ; ; used by AI
        resb 2
g_D608:                                         ; ; used by AI
        resb 2
g_D60A:                                         ; ; used by AI
        resb 2
g_D60C:                                         ; ; used by AI
        resb 2
g_D60E:                                         ; ; used by GAME, INIT
        resb 2
g_D610:                                         ; ; used by GAME, INIT
        resb 2
g_D612:                                         ; ; used by INIT
        resb 2
g_D614:                                         ; ; used by INIT
        resb 2
puckcross:                                      ; where the puck crosses the goal lines; used by INIT
        resb 2
g_D618:                                         ; ; used by AI
        resb 1
g_D619:                                         ; ; used by AI
        resb 3
g_D61C:                                         ; ; used by AI
        resb 1
g_D61D:                                         ; ; used by AI
        resb 1
GoalState:                                      ; goal state; used by AI, INIT
        resb 2
lj1:                                            ; last pad state of controller 1; used by AI, INIT
        resb 2
lj2:                                            ; last pad state of controller 2; used by AI, INIT
        resb 2
lasttouch:                                      ; last player to touch the puck; used by AI, INIT
        resb 2
ltx:                                            ; last touch x; used by AI, INIT
        resb 2
lty:                                            ; last touch y; used by AI, INIT
        resb 2
iflags:                                         ; icing flags; used by AI, INIT
        resb 1
g_D62B:                                         ; ; used by AI
        resb 1
g_D62C:                                         ; ; used by AI, INIT
        resb 2
g_D62E:                                         ; ; used by AI, INIT
        resb 2
g_D630:                                         ; ; used by AI, INIT
        resb 2
g_D632:                                         ; ; used by AI, INIT
        resb 38
g_D658:                                         ; ; used by AI, INIT
        resb 2
g_D65A:                                         ; ; used by AI, INIT
        resb 2
g_D65C:                                         ; ; used by AI, INIT
        resb 2
g_D65E:                                         ; ; used by AI, INIT
        resb 2
g_D660:                                         ; ; used by AI, INIT
        resb 1
g_D661:                                         ; ; used by AI, INIT
        resb 1
g_D662:                                         ; ; used by INIT
        resb 1
g_D663:                                         ; ; used by INIT
        resb 1
g_D664:                                         ; ; used by INIT
        resb 2
g_D666:                                         ; ; used by INIT
        resb 2
g_D668:                                         ; ; used by AI, INIT
        resb 2
g_D66A:                                         ; ; used by INIT
        resb 2
regd0:                                          ; register-style work variable d0; used by AI, INIT
        resb 1
g_D66D:                                         ; ; used by INIT
        resb 1
g_D66E:                                         ; ; used by AI, INIT
        resb 2
g_D670:                                         ; ; used by INIT
        resb 2
regd1:                                          ; register-style work variable d1; used by AI, INIT
        resb 1
g_D673:                                         ; ; used by AI
        resb 1
g_D674:                                         ; ; used by AI
        resb 2
PenBuf:                                         ; penalty buffer (penalty, player); used by AI
        resb 1
PenBuf_pl:                                      ; penalty buffer player byte; used by AI
        resb 1
g_D678:                                         ; ; used by AI
        resb 64
regd2:                                          ; register-style work variable d2; used by AI, INIT
        resb 2
g_D6BA:                                         ; ; used by AI
        resb 2
g_D6BC:                                         ; ; used by INIT
        resb 2
g_D6BE:                                         ; ; used by INIT
        resb 2
regd3:                                          ; register-style work variable d3; used by AI
        resb 2
g_D6C2:                                         ; ; used by AI
        resb 2
g_D6C4:                                         ; ; used by AI, INIT
        resb 2
PBnum:                                          ; home penalty box count; used by AI, INIT
        resb 1
g_D6C7:                                         ; ; used by AI
        resb 1
regd4:                                          ; register-style work variable d4; used by AI, INIT
        resb 2
g_D6CA:                                         ; ; used by AI
        resb 2
viewscrollx:                                    ; view scroll x; used by AI, GAME, INIT
        resb 2
g_D6CE:                                         ; ; used by AI, GAME, INIT
        resb 2
frameaccum:                                     ; frame accumulator; used by AI, GAME, INIT
        resb 2
hudhundaccum:                                   ; panel hundredths accumulator; used by AI, GAME, INIT
        resb 2
g_D6D4:                                         ; ; used by AI, INIT
        resb 2
g_D6D6:                                         ; ; used by AI, INIT
        resb 2
g_D6D8:                                         ; ; used by GAME
        resb 2
g_D6DA:                                         ; ; used by GAME
        resb 38
g_D700:                                         ; ; used by GAME
        resb 2
g_D702:                                         ; ; used by GAME
        resb 26
g_D71C:                                         ; ; used by GAME, INIT
        resb 2
g_D71E:                                         ; ; used by GAME, INIT
        resb 10
hudhundstep:                                    ; panel hundredths step; used by AI, GAME, INIT
        resb 686
g_D9D6:                                         ; ; used by GAME
        resb 4
g_D9DA:                                         ; ; used by AI, INIT
        resb 32
g_D9FA:                                         ; ; used by INIT
        resb 12
g_DA06:                                         ; ; used by INIT
        resb 2
g_DA08:                                         ; ; used by INIT
        resb 2
g_DA0A:                                         ; ; used by AI
        resb 2
g_DA0C:                                         ; ; used by AI
        resb 1
g_DA0D:                                         ; ; used by MENUS
        resb 29
g_DA2A:                                         ; ; used by AI, INIT
        resb 2
g_DA2C:                                         ; ; used by AI, INIT
        resb 2
g_DA2E:                                         ; ; used by AI, INIT
        resb 2
g_DA30:                                         ; ; used by AI, INIT
        resb 26
g_DA4A:                                         ; ; used by AI
        resb 2
g_DA4C:                                         ; ; used by AI
        resb 38
g_DA72:                                         ; ; used by AI
        resb 2
g_DA74:                                         ; ; used by AI
        resb 2
g_DA76:                                         ; ; used by AI
        resb 2
g_DA78:                                         ; ; used by AI
        resb 38
g_DA9E:                                         ; ; used by AI
        resb 2
clockcolon:                                     ; panel clock colon state; used by AI
        resb 2
g_DAA2:                                         ; ; used by AI
        resb 2
g_DAA4:                                         ; ; used by AI
        resb 42
g_DACE:                                         ; ; used by AI, INIT
        resb 2
g_DAD0:                                         ; ; used by AI, INIT
        resb 2
g_DAD2:                                         ; ; used by INIT
        resb 2
g_DAD4:                                         ; ; used by INIT
        resb 2
g_DAD6:                                         ; ; used by INIT
        resb 2
g_DAD8:                                         ; ; used by INIT
        resb 2
g_DADA:                                         ; ; used by INIT
        resb 2
g_DADC:                                         ; ; used by INIT
        resb 2
g_DADE:                                         ; ; used by INIT
        resb 8
g_DAE6:                                         ; ; used by INIT
        resb 2
g_DAE8:                                         ; ; used by INIT
        resb 2
g_DAEA:                                         ; ; used by INIT
        resb 20
g_DAFE:                                         ; ; used by INIT
        resb 2
g_DB00:                                         ; ; used by INIT
        resb 2
g_DB02:                                         ; ; used by INIT
        resb 14
g_DB10:                                         ; ; used by INIT
        resb 2
g_DB12:                                         ; ; used by INIT
        resb 2
g_DB14:                                         ; ; used by INIT
        resb 2
g_DB16:                                         ; ; used by INIT
        resb 2
g_DB18:                                         ; ; used by INIT
        resb 2
g_DB1A:                                         ; ; used by INIT
        resb 2
g_DB1C:                                         ; ; used by INIT
        resb 2
replayptrx:                                     ; replay pointer x; used by INIT
        resb 2
g_DB20:                                         ; ; used by INIT
        resb 2
g_DB22:                                         ; ; used by INIT
        resb 2
g_DB24:                                         ; ; used by INIT
        resb 2
g_DB26:                                         ; ; used by INIT
        resb 2
g_DB28:                                         ; ; used by INIT
        resb 2
g_DB2A:                                         ; ; used by INIT
        resb 2
g_DB2C:                                         ; ; used by INIT
        resb 2
g_DB2E:                                         ; ; used by INIT
        resb 28
g_DB4A:                                         ; ; used by INIT
        resb 2
g_DB4C:                                         ; ; used by INIT
        resb 4
g_DB50:                                         ; ; used by INIT
        resb 28
g_DB6C:                                         ; ; used by INIT
        resb 2
g_DB6E:                                         ; ; used by INIT
        resb 4
g_DB72:                                         ; ; used by INIT
        resb 28
g_DB8E:                                         ; ; used by INIT
        resb 2
g_DB90:                                         ; ; used by INIT
        resb 4
g_DB94:                                         ; ; used by INIT
        resb 17
g_DBA5:                                         ; ; used by INIT
        resb 12
g_DBB1:                                         ; ; used by INIT
        resb 1
g_DBB2:                                         ; ; used by INIT
        resb 12
g_DBBE:                                         ; ; used by INIT
        resb 2
g_DBC0:                                         ; ; used by INIT
        resb 2
g_DBC2:                                         ; ; used by INIT
        resb 1
g_DBC3:                                         ; ; used by INIT
        resb 1
g_DBC4:                                         ; ; used by INIT
        resb 1
g_DBC5:                                         ; ; used by INIT
        resb 1
g_DBC6:                                         ; ; used by INIT
        resb 2
g_DBC8:                                         ; ; used by INIT
        resb 2
g_DBCA:                                         ; ; used by INIT
        resb 2
g_DBCC:                                         ; ; used by INIT
        resb 40
g_DBF4:                                         ; ; used by INIT
        resb 1
g_DBF5:                                         ; ; used by INIT
        resb 19
g_DC08:                                         ; ; used by INIT
        resb 34
g_DC2A:                                         ; ; used by AI
        resb 2
g_DC2C:                                         ; ; used by AI
        resb 2
g_DC2E:                                         ; ; used by AI
        resb 2
g_DC30:                                         ; ; used by AI
        resb 2
g_DC32:                                         ; ; used by AI
        resb 2
g_DC34:                                         ; ; used by AI
        resb 2
g_DC36:                                         ; ; used by AI
        resb 2
g_DC38:                                         ; ; used by AI
        resb 2
g_DC3A:                                         ; ; used by AI
        resb 56
g_DC72:                                         ; ; used by AI
        resb 96
lastimpact:                                     ; last impact; used by AI
        resb 2
gwgplayer:                                      ; game-winning goal player; used by AI
        resb 2
gwgteam:                                        ; game-winning goal team; used by AI
        resb 2
g_DCD8:                                         ; ; used by AI
        resb 52
offsort_fwd:                                    ; forwards sorted by rating; used by AI
        resb 50
defsort_d:                                      ; defencemen sorted by rating; used by AI
        resb 400
dressflags:                                     ; home dressed flags; used by AI
        resb 25
g_DEE7:                                         ; ; used by AI
        resb 25
lineslotmark:                                   ; line slot marks; used by AI
        resb 50
g_DF32:                                         ; ; used by AI
        resb 50
dresseddefs:                                    ; dressed defencemen; used by AI
        resb 2
dressedfwds:                                    ; dressed forwards; used by AI
        resb 2
dressedskaters:                                 ; dressed skaters; used by AI
        resb 2
g_DF6A:                                         ; ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6,
                                                ; FADES8
        resb 2
g_DF6C:                                         ; ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6,
                                                ; FADES8
        resb 2
g_DF6E:                                         ; ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6,
                                                ; FADES8
        resb 2
g_DF70:                                         ; ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6,
                                                ; FADES8
        resb 2
RetraceCount:                                   ; retrace count measured by CalibrateRetrace; used by
                                                ; CalibrateRetrace
        resb 2
MidiQueue:                                      ; 128-byte MIDI queue; used by QueueMidiBytes, FlushMidiQueue
        resb 1
MidiQueue1:                                     ; MIDI queue, second byte; used by FlushMidiQueue
        resb 127
PatchBank:                                      ; patch bank, offset; used by ResetSequencer, LoadPatchBank,
                                                ; SendPatches ...
        resb 2
PatchBankSeg:                                   ; patch bank, segment; used by ResetSequencer, LoadPatchBank,
                                                ; SendPatches ...
        resb 2
ChannelUsed:                                    ; channel in use, per MIDI channel; used by ResetSequencer,
                                                ; FindFreeChannel
        resb 16
LoadedSongs:                                    ; 10 loaded songs, offsets; used by ResetSequencer,
                                                ; SendPatches, AddLoadedSong ...
        resb 2
LoadedSongsSeg:                                 ; loaded songs, segments; used by ResetSequencer, SendPatches,
                                                ; AddLoadedSong ...
        resb 38
SongParts:                                      ; parts tables of the loaded songs; used by ResetSequencer,
                                                ; ScanSongParts
        resb 2
SongPartsSeg:                                   ; parts tables, segments; used by ResetSequencer
        resb 38
SongSeqs:                                       ; sequence tables of the loaded songs; used by ResetSequencer,
                                                ; ScanSongSeqs
        resb 2
SongSeqsSeg:                                    ; sequence tables, segments; used by ResetSequencer
        resb 38
SeqTimerSlot:                                   ; timer slot of the sequencer; used by InitSequencer,
                                                ; ShutdownSequencer
        resb 2
SeqTimerSlotSeg:                                ; timer slot, segment; used by InitSequencer,
                                                ; ShutdownSequencer
        resb 2
DriverTypes:                                    ; driver type per driver; used by LoadSoundDriver, SendPatches
        resb 2
DriverEntrySeg:                                 ; driver entry segment; used by LoadSoundDriver
        resb 6
VoiceFreeList:                                  ; free voice list; used by InitVoiceLists, PrepareSong
        resb 2
VoiceFreeListSeg:                               ; free voice list, segment; used by InitVoiceLists,
                                                ; PrepareSong
        resb 2
VoiceListNext:                                  ; voice list links; used by InitVoiceLists
        resb 2
VoiceListNextSeg:                               ; voice list links, segment; used by InitVoiceLists
        resb 2
VoiceListPrev:                                  ; voice list back links; used by InitVoiceLists
        resb 2
VoiceListPrevSeg:                               ; voice list back links, segment; used by InitVoiceLists
        resb 7
VoiceListId:                                    ; voice list id byte; used by InitVoiceLists
        resb 127
VoiceListEnd:                                   ; end of the voice lists; used by InitVoiceLists, PrepareSong
        resb 2
VoiceListEndSeg:                                ; end of the voice lists, segment; used by InitVoiceLists,
                                                ; PrepareSong
        resb 2
VoiceListFlags:                                 ; voice list flags; used by InitVoiceLists, PrepareSong
        resb 582
g_E366:                                         ; ; used by AI, INIT, LP
        resb 1
g_E367:                                         ; ; used by AI, INIT, LP
        resb 1
g_E368:                                         ; ; used by INIT
        resb 1
g_E369:                                         ; ; used by INIT
        resb 1
g_E36A:                                         ; ; used by INIT
        resb 1
g_E36B:                                         ; ; used by LP, MENUS
        resb 6149
