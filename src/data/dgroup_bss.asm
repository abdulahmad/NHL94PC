; DGROUP uninitialized data (BSS): no bytes in the file; the startup code clears it. Variables follow
; dgroup.asm in the same group.
MapLo:                                          ; word; used by EmitByte, Expand
        resb 2
MapHi:                                          ; word; used by EmitByte, Expand
        resb 2
OutPtr:                                         ; word; used by EmitByte, ReadVar, Expand
        resb 2
UnpackSpare1:                                   ; word before InPtr; not used by the EXE or the overlays
        resb 2
InPtr:                                          ; word; used by EmitByte, ReadVar, Expand
        resb 2
UnpackSpare2:                                   ; word before MapPair; not used by the EXE or the overlays
        resb 2
MapPair:                                        ; word; used by EmitByte, Expand
        resb 2
BitBuf:                                         ; word; used by EmitByte, ReadVar
        resb 2
UnpackSpare3:                                   ; word before BitCount; not used by the EXE or the overlays
        resb 2
BitCount:                                       ; word; used by EmitByte, ReadVar
        resb 2
SentencePtr:                                    ; current speech sentence; used by SpeechTimerTick,
                                                ; ResetSentence, SpeechInit ...
        resb 2
SentenceSeg:                                    ; its segment; used by ResetSentence, SpeechInit,
                                                ; ShutdownSpeech ...
        resb 2
PauseSampleOff:                                 ; silent sample, offset; used by MakePauseSample,
                                                ; PlayPauseSample
        resb 2
PauseSampleSeg:                                 ; silent sample, segment; used by MakePauseSample,
                                                ; PlayPauseSample
        resb 2
WantedList:                                     ; samples wanted, offset; used by ResetWantedSamples,
                                                ; SpeechInit, ShutdownSpeech ...
        resb 2
WantedListSeg:                                  ; samples wanted, segment; used by ResetWantedSamples,
                                                ; SpeechInit, ShutdownSpeech ...
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
        resb 10
SeqEmsMap:                                      ; EMS mapping saved around the driver service call in
                                                ; SeqService
        resb 8
MidiEvent:                                      ; event ParseMidiEvent reads for SeqStepTrack: delta time
                                                ; (dword)
        resb 4
MidiEvCmd:                                      ; MidiEvent: command (D9h and up are sequencer commands) or
                                                ; note
        resb 1
MidiEvData:                                     ; MidiEvent: first data byte (velocity or command argument)
        resb 1
MidiEvValue:                                    ; MidiEvent: value (dword: controller value, bend, duration)
        resb 4
MidiEvLength:                                   ; MidiEvent: bytes the event takes in the track
        resb 2
MidiNextEvent:                                  ; the following event, parsed for its delta time only
        resb 12
PatchFileName:                                  ; 'bank%d.pat' name built by LoadBankNumber
        resb 20
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
        resb 60
DriverFileName:                                 ; 'c:\eaclib\' path of the sound driver built by
                                                ; LoadSoundDriver
        resb 80
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
        resb 2
FloatAccum:                                     ; the double atof returns (its address in AX)
        resb 8
FltOutFlags:                                    ; FLT block of _fltin: flags; used by _fltin
        resb 1
FltOutFlags1:                                   ; FLT block of _fltin: flags, high byte
        resb 1
FltOutExp:                                      ; FLT block of _fltin: characters converted
        resb 6
FltInValue:                                     ; FLT block of _fltin: the double
        resb 8
AtexitTable:                                    ; atexit and onexit functions (32 far pointers), run by
                                                ; ExitCommon
        resb 128
AtexitTableEnd:                                 ; end of AtexitTable; atexit compares AtexitPtr with it
        resb 8
PPVFiles:                                       ; far pointers to the 18 loaded PPV files (LoadPlayerFrames);
                                                ; the 72 bytes after them are not used
        resb 144
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
gsummarypath:                                   ; path of gsummary.db (MakeGSummaryPath); used by INIT
        resb 32
HeapSizeLo:                                     ; heap size, low word; used by AI, GAME, INIT, LP, MENUS
        resb 2
HeapSizeHi:                                     ; heap size, high word; used by AI, GAME, INIT, LP, MENUS
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
HeapVar0:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapList:                                       ; far heap list; used by LargestFreeBlock
        resb 2
HeapVar1:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar2:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar3:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar4:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar5:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar6:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar7:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
MemBlock1Off:                                   ; memory block 1, offset; used by LP, MENUS, STATS
        resb 2
MemBlock1Seg:                                   ; memory block 1, segment; used by LP, MENUS, STATS
        resb 2
MemBlock2Off:                                   ; memory block 2, offset; used by DrawCallBanner,
                                                ; DrawTextOverlay, FormatPlayerName
        resb 2
MemBlock2Seg:                                   ; memory block 2, segment; used by DrawCallBanner,
                                                ; DrawTextOverlay, FormatPlayerName
        resb 2
MemBlock3Off:                                   ; memory block 3, offset; used by DrawCallBanner,
                                                ; DrawTextOverlay
        resb 2
MemBlock3Seg:                                   ; memory block 3, segment; used by DrawCallBanner,
                                                ; DrawTextOverlay
        resb 18
InputFlags:                                     ; input device flags; used by PollInputEvents
        resb 2
InputQueue:                                     ; input event queue; used by PollInputEvents
        resb 256
CursorX:                                        ; cursor x; used by PollInputEvents
        resb 2
CursorY:                                        ; cursor y; used by EventToCursor, PollInputEvents
        resb 2
PadReadings:                                    ; 3 bytes a pad (stick, buttons, hot key) filled by
                                                ; ReadPadDevice
        resb 150
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
                                                ; MessageBoxLoop, SaveGameNameDlg ...
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
hmshots:                                        ; home shots; the home team stats start here; used by INIT
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
hmtmptrs:                                       ; home team pointer; used by AI, INIT
        resb 2
awshots:                                        ; away shots; the away team stats start here
        resb 2
awppgoals:                                      ; away power play goals
        resb 2
awppchances:                                    ; away power play chances
        resb 2
awpenalties:                                    ; away penalties
        resb 2
awpenmins:                                      ; away penalty minutes
        resb 2
awattacktime:                                   ; away attack time
        resb 2
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
SortCords_m2:                                   ; object address word before SortCords (clearteams stores
                                                ; sort object 6 there); used by AI, INIT
        resb 2
SortCords:                                      ; the sort objects, 80h bytes each; sort object 0 starts here
        resb 2
sortobj0_Xpos2:                                 ; sort object 0 (sortobj0), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj0_Ypos2:                                 ; sort object 0 (sortobj0), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
sortobj0_position:                              ; sort object 0 (sortobj0), field +1Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 42
CwdExciteLvl:                                   ; crowd excitement level; used by AI
        resb 1
sortobj0_pflags2:                               ; sort object 0 (sortobj0), field +45h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj0_47:                                    ; sort object 0 (sortobj0), field +47h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1467
sortobj12_Xpos2:                                ; sort object 12 (sortobj12), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj12_Ypos2:                                ; sort object 12 (sortobj12), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 6
sortobj12_Xvel:                                 ; sort object 12 (sortobj12), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj12_Yvel:                                 ; sort object 12 (sortobj12), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 116
sortobj13_Xpos2:                                ; sort object 13 (sortobj13), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj13_Ypos2:                                ; sort object 13 (sortobj13), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 6
sortobj13_Xvel:                                 ; sort object 13 (sortobj13), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj13_Yvel:                                 ; sort object 13 (sortobj13), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 114
puckstruct:                                     ; sort object 14 (puck), field +00h
        resb 2
puckXpos2:                                      ; sort object 14 (puck), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
puckYpos2:                                      ; puck sort object field +06h (the object starts 6 bytes
                                                ; before); used by AI
        resb 4
puckZpos2:                                      ; sort object 14 (puck), field +0Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckXvel:                                       ; sort object 14 (puck), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckYvel:                                       ; sort object 14 (puck), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
puckframe:                                      ; sort object 14 (puck), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 10
puck_1C:                                        ; sort object 14 (puck), field +1Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckasslist:                                    ; sort object 14 (puck), field +1Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
pucktemp1:                                      ; puck sort object temp1; used by AI
        resb 2
pucktemp2:                                      ; sort object 14 (puck), field +28h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 22
pucknopuck:                                     ; puck sort object nopuck field; used by AI
        resb 7
puckpflags2:                                    ; puck sort object pflags2; used by AI
        resb 3
puck_48:                                        ; sort object 14 (puck), field +48h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 56
doorstruct:                                     ; sort object 15 (door), field +00h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorXpos2:                                      ; sort object 15 (door), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorYpos2:                                      ; sort object 15 (door), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorZpos2:                                      ; sort object 15 (door), field +0Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorXvel:                                       ; sort object 15 (door), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorYvel:                                       ; sort object 15 (door), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorframe:                                      ; sort object 15 (door), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
doortemp1:                                      ; sort object 15 (door), field +26h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doortemp2:                                      ; sort object 15 (door), field +28h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 16
door_38:                                        ; sort object 15 (door), field +38h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 12
doorpflags:                                     ; sort object 15 (door), field +44h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorpflags3:                                    ; sort object 15 (door), field +46h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
door_48:                                        ; sort object 15 (door), field +48h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 56
refstruct:                                      ; sort object 16 (ref), field +00h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
refXpos2:                                       ; sort object 16 (ref), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
refYpos2:                                       ; referee sort object field +06h; used by AI
        resb 6
refXvel:                                        ; referee x velocity; used by AI
        resb 2
refYvel:                                        ; sort object 16 (ref), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
refframe:                                       ; sort object 16 (ref), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
refposition:                                    ; sort object 16 (ref), field +1Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
ref_1C:                                         ; referee sort object field +1Ch; used by AI
        resb 2
refasslist:                                     ; referee assignment list; used by AI
        resb 8
reftemp1:                                       ; referee temp1; used by AI
        resb 4
reftemp3:                                       ; referee temp3; used by AI
        resb 2
reftemp4:                                       ; sort object 16 (ref), field +2Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
reftemp5:                                       ; sort object 16 (ref), field +2Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
ref_36:                                         ; sort object 16 (ref), field +36h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
ref_4A:                                         ; sort object 16 (ref), field +4Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1
ref_4B:                                         ; sort object 16 (ref), field +4Bh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1
ref_4C:                                         ; sort object 16 (ref), field +4Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 52
TitleJingle:                                    ; title jingle buffer pointer (offset); used by MENUS
        resb 2
TitleJingleSeg:                                 ; its segment; used by MENUS
        resb 2
TitleJingle2:                                   ; second title jingle buffer pointer (offset); used by MENUS
        resb 2
TitleJingle2Seg:                                ; its segment; used by MENUS
        resb 2
gmrosterpos:                                    ; roster position letter (C, L, R, D, G) of the game roster
                                                ; entries; used by MENUS
        resb 1
gmrosterjersey:                                 ; game roster jersey; used by MENUS
        resb 1
gmrosterslot:                                   ; game roster slot; used by MENUS
        resb 1
gmrosterjersey_b2:                              ; game roster entry byte +3; used by MENUS
        resb 1
gmrosterdot:                                    ; game roster entry: the '.' after the initial; used by MENUS
        resb 1
gmrosterspace:                                  ; game roster entry: the space before the name; used by MENUS
        resb 1
gmrostername:                                   ; game roster entry names; used by MENUS
        resb 544
gmroster2pos:                                   ; second game roster: first byte; used by MENUS
        resb 1
gmroster2jersey:                                ; second game roster: jersey bytes; used by MENUS
        resb 2
gmroster2init:                                  ; second game roster: initial; used by MENUS
        resb 1
gmroster2dot:                                   ; second game roster: the '.'; used by MENUS
        resb 1
gmroster2space:                                 ; second game roster: the space; used by MENUS
        resb 1
gmroster2name:                                  ; second game roster: names; used by MENUS
        resb 60
curperiod:                                      ; current period; used by AI, GAME, INIT, LP, MENUS
        resb 2
HomeTeamDbName:                                 ; home team database name (32 bytes); used by LP
        resb 32
AwayTeamDbName:                                 ; away team database name (32 bytes); used by LP
        resb 32
statsgoaliebufseg:                              ; segment of statsgoaliebuf; used by LP, MENUS, STATS
        resb 2
statsgoaliebuf:                                 ; goalie stats buffer; used by LP, MENUS, STATS
        resb 2
statsskaterbufseg:                              ; segment of statsskaterbuf; used by LP, MENUS, STATS
        resb 2
statsskaterbuf:                                 ; skater stats buffer; used by LP, MENUS, STATS
        resb 2
statsplayerbufseg:                              ; segment of statsplayerbuf; used by LP, MENUS, STATS
        resb 2
statsplayerbuf:                                 ; player stats buffer; used by LP, MENUS, STATS
        resb 2
statsteambufseg:                                ; segment of statsteambuf; used by LP, MENUS, STATS
        resb 2
statsteambuf:                                   ; team stats buffer; used by LP, MENUS, STATS
        resb 2
statsrosterteam:                                ; team shown on the roster screen; used by MENUS, STATS
        resb 2
leaguestatsmode:                                ; league stats mode; used by LP, MENUS, STATS
        resb 2
savedcount1:                                    ; number of saved games of the first kind (ScanSavedGames);
                                                ; used by MENUS
        resb 2
savedsel1:                                      ; selected saved game of the first kind; used by MENUS
        resb 2
savedtop1:                                      ; first saved game shown, first kind; used by MENUS
        resb 2
savedrows1:                                     ; rows of the first saved game list; used by MENUS
        resb 2
savednames1:                                    ; name pointers (offset) of the first saved game list; used by
                                                ; MENUS
        resb 2
savednames1seg:                                 ; further name pointers of the first list; used by MENUS
        resb 126
savedcount2:                                    ; number of saved games of the second kind; used by MENUS
        resb 2
lgfiles:                                        ; league file handles; used by MENUS
        resb 2
savedtop2:                                      ; first saved game shown, second kind; used by MENUS
        resb 2
savedrows2:                                     ; rows of the second list; used by MENUS
        resb 2
savednames2:                                    ; name pointers of the second list; used by MENUS
        resb 2
lgfilenames:                                    ; league file names; used by MENUS
        resb 126
savedcount3:                                    ; number of saved games of the third kind; used by MENUS
        resb 2
savedsel3:                                      ; selected saved game of the third kind; used by MENUS
        resb 2
savedtop3:                                      ; first saved game shown, third kind; used by MENUS
        resb 2
savedrows3:                                     ; rows of the third list; used by MENUS
        resb 2
savednames3:                                    ; name pointers of the third list; used by MENUS
        resb 2
savednames3seg:                                 ; further name pointers of the third list; used by MENUS
        resb 126
fdlgtab:                                        ; file dialog table; used by MENUS
        resb 2
fdlgflags:                                      ; file dialog flag bits (80h, 40h, 20h); used by MENUS
        resb 1
fdlgflags2:                                     ; file dialog flag bits, second byte; used by MENUS
        resb 1
SoundDrvBuf:                                    ; sound driver buffer pointer (offset); used by MENUS
        resb 2
SoundDrvBufSeg:                                 ; its segment; used by MENUS
        resb 2
POTitleText:                                    ; playoff title text (16 bytes); used by MENUS
        resb 16
playofftree:                                    ; playoff tree; used by MENUS, STATS
        resb 2
POTreeSlots:                                    ; playoff tree slot words; used by MENUS
        resb 30
POTreeRows:                                     ; playoff tree row words (19h); used by MENUS
        resb 20
standingsteam:                                  ; team of the standings row; used by STATS
        resb 2
standingsprev:                                  ; previous standings value; used by STATS
        resb 2
standingskey:                                   ; standings sort key; used by STATS
        resb 2
standingskey2:                                  ; second standings sort key; used by STATS
        resb 2
standingsrank:                                  ; standings rank; used by STATS
        resb 2
DeskTitleText:                                  ; sports desk title text (22 bytes); used by MENUS
        resb 22
ScoreboardArt:                                  ; scoreboard art pointer (offset); used by AI, INIT, MENUS
        resb 2
ScoreboardArtSeg:                               ; its segment; used by AI, INIT, MENUS
        resb 2
RinkEndArt:                                     ; rink end art pointer (offset); used by AI, INIT, MENUS
        resb 2
RinkEndArtSeg:                                  ; its segment; used by AI, INIT, MENUS
        resb 2
editactive:                                     ; text field: editing active; used by LP
        resb 2
editcursorx:                                    ; text field: cursor x; used by LP
        resb 2
editx:                                          ; text field: x; used by LP
        resb 2
edity:                                          ; text field: y; used by LP
        resb 2
editpos:                                        ; text field: cursor position; used by LP
        resb 2
editlen:                                        ; text field: text length; used by LP
        resb 2
editmax:                                        ; text field: maximum width; used by LP
        resb 2
calresult:                                      ; calendar result (-1 none); used by LP
        resb 2
calmonth:                                       ; calendar month shown (0-11); used by LP
        resb 2
calday:                                         ; calendar day chosen (-1 none); used by LP
        resb 2
teamselresult:                                  ; team selection result; used by LP
        resb 2
floppydrive:                                    ; floppy drive chosen; used by LP
        resb 2
floppyok:                                       ; floppy drive flags; used by LP
        resb 2
floppycount:                                    ; number of floppy drives; used by LP
        resb 2
tradestate:                                     ; trade screen state (1 done, -1 cancelled, 0 running); used
                                                ; by LP
        resb 2
savleague:                                      ; league name of the game being played (14 bytes); used by LP
        resb 14
savleague2:                                     ; second league name (14 bytes); used by LP
        resb 14
lgschedrec:                                     ; schedule record of the league game; used by LP
        resb 1
lgschedrec_b1:                                  ; schedule record byte +1; used by LP
        resb 1
lgschedrec_b2:                                  ; schedule record byte +2; used by LP
        resb 1
lgschedrec_b3:                                  ; schedule record byte +3; used by LP
        resb 1
lgschedrec_b4:                                  ; schedule record byte +4; used by LP
        resb 1
lgschedrec_b5:                                  ; schedule record byte +5; used by LP
        resb 1
statspalshape:                                  ; stats palette shape; used by LP, STATS
        resb 2
calcursor:                                      ; calendar cursor day; used by LP
        resb 2
calcursor2:                                     ; calendar cursor row; used by LP
        resb 2
lghometeam:                                     ; home team of the league game; used by LP
        resb 2
lgoppteam:                                      ; other team of the league game; used by LP
        resb 2
lggamestate:                                    ; league game state (-1 none); used by LP
        resb 2
lgreadword:                                     ; word read with the league game reference; used by LP
        resb 2
lgreadword2:                                    ; second word read with the league game reference; used by LP
        resb 2
lggameidx:                                      ; index of the league game; used by LP
        resb 2
statsbgshapes:                                  ; stats background shapes; used by LP, STATS
        resb 2
statsbgseg:                                     ; stats background shape segment; used by LP, STATS
        resb 2
startm:                                         ; three stars: team of each star; used by AI, LP
        resb 2
starpl:                                         ; three stars: player of each star; used by AI, LP
        resb 10
traderows:                                      ; trade screen rows; used by LP
        resb 1
traderows_b1:                                   ; trade screen rows from +1; used by LP
        resb 1
traderows_b2:                                   ; trade screen row bytes from +2; used by LP
        resb 614
traderoster:                                    ; trade roster (BuildTradeRoster); used by LP
        resb 616
tradesel:                                       ; selected trade rows; used by LP
        resb 2
tradesel2:                                      ; second trade selection word; used by LP
        resb 2
tradescroll:                                    ; trade list scroll; used by LP
        resb 2
tradescroll2:                                   ; second trade scroll word; used by LP
        resb 2
tradecursor:                                    ; trade screen cursor; used by LP
        resb 2
tradecolour:                                    ; trade screen row colour; used by LP
        resb 2
tradecolour2:                                   ; second trade row colour; used by LP
        resb 2
mergestate:                                     ; merge state of the league files; used by LP
        resb 2
AwardRawA:                                      ; award art raw handle; used by LP
        resb 2
AwardRawB:                                      ; second award art raw handle; used by LP
        resb 2
AwardRawC:                                      ; third award art raw handle; used by LP
        resb 2
AwardRawD:                                      ; fourth award art raw handle; used by LP
        resb 2
AwardFrames:                                    ; award EMS frames (offset); used by LP
        resb 2
AwardFramesSeg:                                 ; award EMS frames; used by LP
        resb 38
AwardFrames2:                                   ; second award EMS frames; used by LP
        resb 2
AwardFrames2Seg:                                ; second award EMS frames; used by LP
        resb 38
AwardFrames3:                                   ; third award EMS frame; used by LP
        resb 2
AwardFrames3Seg:                                ; third award EMS frames; used by LP
        resb 10
AwardScores:                                    ; award score bytes (ShowAwardScreens); used by LP
        resb 1023
AwardText:                                      ; award text buffer; used by LP
        resb 36
AwardCandidates:                                ; award candidate bytes (PickAwardWinners); used by LP
        resb 703
standingstab:                                   ; standings table (26-byte rows); used by STATS
        resb 48
rostertop:                                      ; roster screen first row; used by STATS
        resb 2
statscardteam:                                  ; stats card team; used by STATS
        resb 1
statscardplayer:                                ; stats card player; used by STATS
        resb 1
statsplayer:                                    ; stats player; used by STATS
        resb 1
rosterfilter:                                   ; roster filter text; used by STATS
        resb 16
rosterfilter2:                                  ; second roster filter text; used by STATS
        resb 17
statsfilepos:                                   ; stats file position (low); used by STATS
        resb 2
statsfileposhi:                                 ; stats file position (high); used by STATS
        resb 2
statscardrec:                                   ; stats card record pointer; used by STATS
        resb 2
statscardrecseg:                                ; its segment; used by STATS
        resb 2
statscardrec2:                                  ; second stats card record pointer; used by STATS
        resb 2
statscardrec2seg:                               ; its segment; used by STATS
        resb 2
statscardgoalie:                                ; stats card goalie flag; used by STATS
        resb 2
statscardrec3:                                  ; third stats card record word; used by STATS
        resb 2
rosterrows:                                     ; roster screen row records; used by STATS
        resb 50
rosterrowptrs:                                  ; roster screen row pointers; used by STATS
        resb 50
rosterrows2:                                    ; second roster row records; used by STATS
        resb 10
rosterrowptrs2:                                 ; second roster row pointers; used by STATS
        resb 10
rostersel:                                      ; roster selected row; used by STATS
        resb 2
statsrecs:                                      ; stats records pointer (offset); used by STATS
        resb 2
statsrecsseg:                                   ; its segment; used by STATS
        resb 2
statscmpsum:                                    ; comparator sum; used by STATS
        resb 2
statscmpsum2:                                   ; comparator sum, high word; used by STATS
        resb 2
fileoncd:                                       ; file is on the CD; used by STATS
        resb 2
cddriveptr:                                     ; CD drive pointer; used by STATS
        resb 2
statstext:                                      ; text buffer of DrawTextFmt (40 bytes); used by STATS
        resb 40
cupseries:                                      ; cup series buffer pointer (offset); used by GAME, INIT
        resb 2
cupseriesseg:                                   ; its segment; used by GAME, INIT
        resb 2
regd5:                                          ; register-style work variable d5; used by AI
        resb 2
lastgoalx:                                      ; last goal position x; used by AI
        resb 2
crowdtimer:                                     ; crowd timer; used by AI, INIT
        resb 2
LastShooterTeam:                                ; team of the last shooter; used by AI
        resb 2
lastgoaly:                                      ; last goal position y; used by AI
        resb 2
crowdcount:                                     ; crowd counter; used by AI, INIT
        resb 2
cleared1:                                       ; game variable cleared by cleargamevars; used by AI
        resb 2
cleared2:                                       ; game variable cleared by cleargamevars; used by AI
        resb 2
crowdsum:                                       ; crowd excitement sum (low); used by AI, INIT
        resb 2
crowdsumhi:                                     ; crowd excitement sum (high); used by AI, INIT
        resb 2
replayrecptr:                                   ; replay record pointer (offset); used by AI, GAME, INIT
        resb 2
replayrecseg:                                   ; replay record pointer (segment); used by AI, GAME, INIT
        resb 2
replayplay:                                     ; replay play pointer (offset); used by INIT
        resb 2
replayplayseg:                                  ; replay play pointer (segment); used by INIT
        resb 2
plstatsoff:                                     ; player stats offsets; used by AI
        resb 2
plstatsoff2:                                    ; player stats offsets, second word; used by AI
        resb 2
plstatsoff3:                                    ; player stats offsets, third word; used by AI
        resb 2
plstatsrecs:                                    ; player stats offset table (394 bytes); used by AI
        resb 394
gameclock2:                                     ; game clock copy; used by AI, INIT
        resb 2
rinkobjs:                                       ; rink object slots; used by AI, INIT
        resb 2
rinkobjs_w2:                                    ; rink object slots word +2; used by INIT
        resb 278
SpriteFrames:                                   ; sprite frame pointers (offset); used by AI, INIT
        resb 2
SpriteFramesSeg:                                ; sprite frame pointers; used by AI, INIT
        resb 382
NumberFrames:                                   ; number sprite frames; used by AI, INIT
        resb 2
NumberFramesSeg:                                ; number sprite frames; used by AI, INIT
        resb 14
NumberFrames2:                                  ; second number sprite frames; used by AI, INIT
        resb 2
NumberFrames2Seg:                               ; second number sprite frames; used by AI, INIT
        resb 18
gameframe:                                      ; game frame counter; used by AI, GAME, INIT
        resb 2
controlled:                                     ; controlled player per controller; used by AI, GAME, INIT
        resb 2
controlled2:                                    ; second controlled player word; used by AI, GAME, INIT
        resb 2
lcline:                                         ; line change: line chosen; used by AI, GAME, INIT
        resb 2
lctimer:                                        ; line change box timer; used by GAME, INIT
        resb 2
objxlist:                                       ; object x list (34 bytes); used by AI
        resb 34
objylist:                                       ; object y list (34 bytes); used by AI, INIT
        resb 34
textline3:                                      ; text line 3; used by AI, INIT
        resb 59
OOlist_m1:                                      ; byte before OOlist; used by AI
        resb 1
OOlist:                                         ; sorted object order list; OOlist_m1 and OOlist_b1 are its
                                                ; neighbours; used by AI, INIT
        resb 1
OOlist_b1:                                      ; OOlist from +1; used by AI
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
fofdata:                                        ; faceoff data word; used by AI
        resb 2
fofdata_w2:                                     ; faceoff data word +2; used by AI
        resb 2
fofdata_w4:                                     ; faceoff data word +4; used by AI
        resb 2
fofdata_w6:                                     ; faceoff data word +6; used by AI
        resb 2
fofdata_w8:                                     ; faceoff data word +8; used by AI
        resb 2
mousex:                                         ; mouse x; used by GAME, INIT
        resb 2
mousey:                                         ; mouse y; used by GAME, INIT
        resb 2
savedword1:                                     ; game variable saved with the game; used by INIT
        resb 2
savedword2:                                     ; game variable saved with the game; used by INIT
        resb 2
puckcross:                                      ; where the puck crosses the goal lines; used by INIT
        resb 2
GoalState_m6:                                   ; home goal state byte; used by AI
        resb 1
GoalState_m5:                                   ; home goal state bytes; used by AI
        resb 3
GoalState_m2:                                   ; away goal state byte; used by AI
        resb 1
GoalState_m1:                                   ; away goal state byte; used by AI
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
iflags_b1:                                      ; iflags high byte; used by AI
        resb 1
OverlayGfx:                                     ; text overlay graphics pointer (offset); used by AI, INIT
        resb 2
OverlayGfxSeg:                                  ; its segment; used by AI, INIT
        resb 2
OverlayFrames:                                  ; text overlay frames; used by AI, INIT
        resb 2
OverlayFramesSeg:                               ; text overlay frames; used by AI, INIT
        resb 38
overlaytimer:                                   ; text overlay timer; used by AI, INIT
        resb 2
overlaystate:                                   ; text overlay state (1..5); used by AI, INIT
        resb 2
overlayscript:                                  ; text overlay script pointer (offset); used by AI, INIT
        resb 2
overlayscriptseg:                               ; its segment; used by AI, INIT
        resb 2
scorerflags:                                    ; scorer milestone flags; used by AI, INIT
        resb 1
scorerflags2:                                   ; second scorer milestone flags; used by AI, INIT
        resb 1
gamevar1:                                       ; game variable saved with the game; used by INIT
        resb 1
gamevar2:                                       ; game variable cleared by ResetGameVars; used by INIT
        resb 1
gamevar3:                                       ; game variable saved with the game; used by INIT
        resb 2
gamevar4:                                       ; game variable saved with the game; used by INIT
        resb 2
stoppagetime:                                   ; clock at the last stoppage; used by AI, INIT
        resb 2
gamevar5:                                       ; game variable saved with the game; used by INIT
        resb 2
regd0:                                          ; register-style work variable d0; used by AI, INIT
        resb 1
regd0_b1:                                       ; regd0 high byte; used by INIT
        resb 1
regd0_w2:                                       ; regd0 high word; used by AI, INIT
        resb 2
gamevar6:                                       ; game variable saved with the game; used by INIT
        resb 2
regd1:                                          ; register-style work variable d1; used by AI, INIT
        resb 1
regd1_b1:                                       ; regd1 byte +1; used by AI
        resb 1
regd1_w2:                                       ; regd1 high word; used by AI
        resb 2
PenBuf:                                         ; penalty buffer (penalty, player); used by AI
        resb 1
PenBuf_pl:                                      ; penalty buffer player byte; used by AI
        resb 1
PenBuf_b2:                                      ; penalty buffer from +2; used by AI
        resb 64
regd2:                                          ; register-style work variable d2; used by AI, INIT
        resb 2
regd2_w2:                                       ; regd2 high word; used by AI
        resb 2
gamevar7:                                       ; game variable saved with the game; used by INIT
        resb 2
gamevar8:                                       ; game variable saved with the game; used by INIT
        resb 2
regd3:                                          ; register-style work variable d3; used by AI
        resb 2
regd3_w2:                                       ; regd3 high word; used by AI
        resb 2
crowdheat:                                      ; crowd heat, raised by goals and shots; used by AI, INIT
        resb 2
PBnum:                                          ; home penalty box count; used by AI, INIT
        resb 1
PBnum_b1:                                       ; away penalty box count (PBnum+1); used by AI
        resb 1
regd4:                                          ; register-style work variable d4; used by AI, INIT
        resb 2
regd4_w2:                                       ; regd4 high word; used by AI
        resb 2
viewscrollx:                                    ; view scroll x; used by AI, GAME, INIT
        resb 2
ovltimer2:                                      ; frame timer of the replay and intro loops; used by AI, GAME,
                                                ; INIT
        resb 2
frameaccum:                                     ; frame accumulator; used by AI, GAME, INIT
        resb 2
hudhundaccum:                                   ; panel hundredths accumulator; used by AI, GAME, INIT
        resb 2
GameGfx:                                        ; game graphics pointer (offset); used by AI, INIT
        resb 2
GameGfxSeg:                                     ; its segment; used by AI, INIT
        resb 2
NumberSprites:                                  ; jersey number sprites; used by GAME
        resb 2
NumberSpritesSeg:                               ; jersey number sprites; used by GAME
        resb 38
NumberSprites2:                                 ; second jersey number sprites; used by GAME
        resb 2
NumberSprites2Seg:                              ; second jersey number sprites; used by GAME
        resb 26
RinkEndFrames:                                  ; rink end frames pointer (offset); used by GAME, INIT
        resb 2
RinkEndFramesSeg:                               ; rink end frames; used by GAME, INIT
        resb 10
hudhundstep:                                    ; panel hundredths step; used by AI, GAME, INIT
        resb 686
dirtycount:                                     ; dirty rectangle counts per page; used by GAME
        resb 4
rinkobjused:                                    ; rink object frame bits; used by AI, INIT
        resb 32
hilightslots:                                   ; highlight slot words; used by INIT
        resb 12
MovieBuf:                                       ; movie buffer pointer (offset); used by INIT
        resb 2
MovieBufSeg:                                    ; its segment; used by INIT
        resb 2
PanelShapes:                                    ; panel shapes; used by AI
        resb 2
PanelShapes_b2:                                 ; panel shapes from +2; used by AI
        resb 1
PanelShapes_b3:                                 ; panel shapes from +3; used by MENUS
        resb 29
PanelClockShape:                                ; panel clock shape pointer; used by AI, INIT
        resb 2
PanelClockShapeSeg:                             ; its segment; used by AI, INIT
        resb 2
PanelScoreShape:                                ; panel score shape pointer; used by AI, INIT
        resb 2
PanelScoreShapeSeg:                             ; its segment; used by AI, INIT
        resb 26
PenaltyShapes:                                  ; panel penalty shapes; used by AI
        resb 2
PenaltyShapesSeg:                               ; panel penalty shapes; used by AI
        resb 38
PenaltyShape:                                   ; panel penalty shape; used by AI
        resb 2
PenaltyShapeSeg:                                ; its segment; used by AI
        resb 2
ClockDigits:                                    ; panel clock digit shapes; used by AI
        resb 2
ClockDigitsSeg:                                 ; panel clock digit shapes; used by AI
        resb 38
ClockColonShape:                                ; panel clock colon shape; used by AI
        resb 2
clockcolon:                                     ; panel clock colon state; used by AI
        resb 2
ScoreDigits:                                    ; panel score digit shapes; used by AI
        resb 2
ScoreDigitsSeg:                                 ; panel score digit shapes; used by AI
        resb 42
ReplayFont:                                     ; replay font pointer (offset); used by AI, INIT
        resb 2
ReplayFontSeg:                                  ; its segment; used by AI, INIT
        resb 2
replaymousex:                                   ; replay pointer x; used by INIT
        resb 2
replaymousey:                                   ; replay pointer y; used by INIT
        resb 2
replaydx:                                       ; replay pointer x step; used by INIT
        resb 2
replayspeed:                                    ; replay speed; used by INIT
        resb 2
ReplayGadgets:                                  ; replay gadget shapes; used by INIT
        resb 2
ReplayGadgetsSeg:                               ; replay gadget shapes; used by INIT
        resb 2
ReplayGadgets2:                                 ; further replay gadget shapes; used by INIT
        resb 8
ReplayPanel:                                    ; replay panel shape; used by INIT
        resb 2
ReplayPanelSeg:                                 ; its segment; used by INIT
        resb 2
ReplayPanels:                                   ; further replay panel shapes; used by INIT
        resb 20
ReplayPointer:                                  ; replay pointer shape; used by INIT
        resb 2
ReplayPointerSeg:                               ; its segment; used by INIT
        resb 2
ReplayPointers:                                 ; further replay pointer shapes; used by INIT
        resb 14
ReplayBack:                                     ; replay background shape; used by INIT
        resb 2
ReplayBackSeg:                                  ; its segment; used by INIT
        resb 2
ReplayBack2:                                    ; second replay background shape; used by INIT
        resb 2
replaysaved:                                    ; replay saved flag; used by INIT
        resb 2
replayplaying:                                  ; replay playing flag; used by INIT
        resb 2
replaystart:                                    ; replay start frame; used by INIT
        resb 2
replayend:                                      ; replay end frame; used by INIT
        resb 2
replayptrx:                                     ; replay pointer x; used by INIT
        resb 2
replaypick:                                     ; player picked in the replay; used by INIT
        resb 2
replayfollow:                                   ; player the replay follows (-1 none); used by INIT
        resb 2
replayfollow2:                                  ; previous followed player; used by INIT
        resb 2
replayfwd:                                      ; replay direction; used by INIT
        resb 2
replaybutton:                                   ; replay button pressed; used by INIT
        resb 2
replaystep:                                     ; replay step; used by INIT
        resb 2
replaysavestate:                                ; replay save state; used by INIT
        resb 2
rpl_x:                                          ; replay frame: object x; used by INIT
        resb 28
rpl_puckx:                                      ; replay frame: puck x; used by INIT
        resb 2
rpl_puckframe:                                  ; replay frame: puck frame; used by INIT
        resb 4
rpl_y:                                          ; replay frame: object y; used by INIT
        resb 28
rpl_pucky:                                      ; replay frame: puck y; used by INIT
        resb 2
rpl_shadow:                                     ; replay frame: puck shadow; used by INIT
        resb 4
rpl_frame:                                      ; replay frame: object frame; used by INIT
        resb 28
rpl_reff:                                       ; replay frame: referee frame; used by INIT
        resb 2
rpl_door:                                       ; replay frame: door frame; used by INIT
        resb 4
rpl_flags:                                      ; replay frame: object flags; used by INIT
        resb 17
rpl_jerseys:                                    ; replay frame: jerseys; used by INIT
        resb 12
rpl_puckowner:                                  ; replay frame: puck owner; used by INIT
        resb 1
rpl_bytes:                                      ; replay frame bytes; used by INIT
        resb 12
rpl_camx:                                       ; replay frame: camera x; used by INIT
        resb 2
rpl_word:                                       ; replay frame word; used by INIT
        resb 2
rpl_b1:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b2:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b3:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b4:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b5:                                         ; replay frame bytes; used by INIT
        resb 2
rpl_w1:                                         ; replay frame word; used by INIT
        resb 2
rpl_w2:                                         ; replay frame word; used by INIT
        resb 2
rpl_words:                                      ; replay frame words; used by INIT
        resb 40
rpl_b6:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b7:                                         ; replay frame bytes; used by INIT
        resb 19
rpl_words2:                                     ; replay frame words; used by INIT
        resb 34
defertab_a1:                                    ; deferred call argument 1; used by AI
        resb 2
defertab_a2:                                    ; deferred call argument 2; used by AI
        resb 2
defertab_a3:                                    ; deferred call argument 3; used by AI
        resb 2
defertab_a4:                                    ; deferred call argument 4; used by AI
        resb 2
defertab_a5:                                    ; deferred call argument 5; used by AI
        resb 2
defertab_a6:                                    ; deferred call argument 6; used by AI
        resb 2
defertab_a7:                                    ; deferred call argument 7; used by AI
        resb 2
defertab_fn:                                    ; deferred call routine offset; used by AI
        resb 2
defertab_seg:                                   ; deferred call routine segment; used by AI
        resb 56
gsumqueue:                                      ; queued game summary records; used by AI
        resb 96
lastimpact:                                     ; last impact; used by AI
        resb 2
gwgplayer:                                      ; game-winning goal player; used by AI
        resb 2
gwgteam:                                        ; game-winning goal team; used by AI
        resb 2
introtimers:                                    ; intro timers; used by AI
        resb 52
offsort_fwd:                                    ; forwards sorted by rating; used by AI
        resb 50
defsort_d:                                      ; defencemen sorted by rating; used by AI
        resb 400
dressflags:                                     ; home dressed flags; used by AI
        resb 25
dressflags_aw:                                  ; away dressed flags; used by AI
        resb 25
lineslotmark:                                   ; line slot marks; used by AI
        resb 50
possort:                                        ; players sorted by position; used by AI
        resb 50
dresseddefs:                                    ; dressed defencemen; used by AI
        resb 2
dressedfwds:                                    ; dressed forwards; used by AI
        resb 2
dressedskaters:                                 ; dressed skaters; used by AI
        resb 2
fadex:                                          ; fade area x; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadey:                                          ; fade area y; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadew:                                          ; fade area width; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadeh:                                          ; fade area height; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
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
VoiceListFlags:                                 ; voice list flags (50 bytes, the last 12 unused); used by
                                                ; InitVoiceLists, PrepareSong
        resb 0x3E
StdinBuf:                                       ; stdin buffer of _iob (512 bytes, then 8 unused bytes)
        resb 0x208
savedteam1:                                     ; saved team byte; used by AI, INIT, LP
        resb 1
savedteam2:                                     ; saved team byte; used by AI, INIT, LP
        resb 1
savedbyte3:                                     ; saved game byte; used by INIT
        resb 1
savedbyte4:                                     ; saved game byte; used by INIT
        resb 1
savedbyte5:                                     ; saved game byte; used by INIT
        resb 1
lgflags:                                        ; league flags and buffers; used by LP, MENUS
        resb 5
StackBottom:                                    ; the 1800h-byte startup stack (the EXE header puts SS here,
                                                ; SP
                                                ; 1800h); MscStartup moves it into DGROUP
        resb 0x1800
