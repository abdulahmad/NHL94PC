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
g_8EFE:                                         ; used by FADES8 (to name)
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
g_91D0:                                         ; used by GAME (to name)
        resb 2
g_91D2:                                         ; used by GAME (to name)
        resb 3502
g_9F80:                                         ; used by INIT (to name)
        resb 76
g_9FCC:                                         ; used by INIT (to name)
        resb 2
g_9FCE:                                         ; used by INIT (to name)
        resb 110
g_A03C:                                         ; used by MENUS (to name)
        resb 48
g_A06C:                                         ; used by MENUS (to name)
        resb 508
g_A268:                                         ; used by INIT (to name)
        resb 744
hmroster:                                         ; used by AI, INIT, MENUS (to name)
        resb 6
g_A556:                                         ; used by AI, INIT, MENUS (to name)
        resb 1
hmrosterpos:                                         ; used by AI (to name)
        resb 1113
g_A9B0:                                         ; used by INIT (to name)
        resb 1120
g_AE10:                                         ; used by INIT (to name)
        resb 36
g_AE34:                                         ; used by INIT (to name)
        resb 1
g_AE35:                                         ; used by INIT (to name)
        resb 3
g_AE38:                                         ; used by INIT (to name)
        resb 8
g_AE40:                                         ; used by INIT (to name)
        resb 36
g_AE64:                                         ; used by INIT (to name)
        resb 1
g_AE65:                                         ; used by INIT (to name)
        resb 3
g_AE68:                                         ; used by INIT (to name)
        resb 8
g_AE70:                                         ; used by INIT (to name)
        resb 32
HeapSizeLo:                                     ; heap size, low word; not used in the EXE (overlays may use
                                                ; it)
        resb 2
HeapSizeHi:                                     ; heap size, high word; not used in the EXE (overlays may use
                                                ; it)
        resb 2
g_AE94:                                         ; used by MENUS (to name)
        resb 2
g_AE96:                                         ; used by MENUS (to name)
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
curevent:                                         ; used by AI, INIT (to name)
        resb 2
curevent_b1:                                         ; used by AI (to name)
        resb 1
curevent_b2:                                         ; used by AI (to name)
        resb 1
curevent_b3:                                         ; used by AI (to name)
        resb 1
curevent_b4:                                         ; used by AI (to name)
        resb 1
curevent_b5:                                         ; used by AI (to name)
        resb 1
curevent_b6:                                         ; used by AI (to name)
        resb 1
curevent_b7:                                         ; used by AI (to name)
        resb 1
curevent_b8:                                         ; used by AI (to name)
        resb 1
curevent_b9:                                         ; used by AI (to name)
        resb 1
curevent_b10:                                         ; used by AI (to name)
        resb 1
goalevent:                                         ; used by AI, INIT (to name)
        resb 2
g_B07A:                                         ; used by AI (to name)
        resb 1
g_B07B:                                         ; used by AI (to name)
        resb 1
g_B07C:                                         ; used by AI (to name)
        resb 1
g_B07D:                                         ; used by AI (to name)
        resb 17
HotKeyFn:                                       ; far routine for hot keys; used by ListDialog,
                                                ; MessageBoxLoop, SaveGameNameDialog ...
        resb 2
HotKeyFnSeg:                                    ; its segment; used by InputInit
        resb 2
g_B092:                                         ; used by AI, GAME, INIT, MENUS (to name)
        resb 2
g_B094:                                         ; used by AI, GAME, INIT, MENUS (to name)
        resb 2
g_B096:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_B098:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_B09A:                                         ; used by INIT (to name)
        resb 2
g_B09C:                                         ; used by GAME, INIT (to name)
        resb 2
g_B09E:                                         ; used by INIT (to name)
        resb 12
g_B0AA:                                         ; used by INIT (to name)
        resb 1
g_B0AB:                                         ; used by INIT (to name)
        resb 11
g_B0B6:                                         ; used by INIT (to name)
        resb 1
g_B0B7:                                         ; used by INIT (to name)
        resb 11
g_B0C2:                                         ; used by GAME, INIT (to name)
        resb 2
TeamPalette1:                                   ; first team palette; used by LoadTeamPalettes
        resb 67
g_B107:                                         ; used by AI, MENUS (to name)
        resb 189
TeamPalette2:                                   ; second team palette; used by LoadTeamPalettes
        resb 5
g_B1C9:                                         ; used by MENUS (to name)
        resb 2
g_B1CB:                                         ; used by MENUS (to name)
        resb 9
g_B1D4:                                         ; used by MENUS (to name)
        resb 1
g_B1D5:                                         ; used by MENUS (to name)
        resb 2
g_B1D7:                                         ; used by MENUS (to name)
        resb 1
g_B1D8:                                         ; used by MENUS (to name)
        resb 2
g_B1DA:                                         ; used by MENUS (to name)
        resb 45
g_B207:                                         ; used by AI, MENUS (to name)
        resb 6
g_B20D:                                         ; used by MENUS (to name)
        resb 7
g_B214:                                         ; used by MENUS (to name)
        resb 1
g_B215:                                         ; used by MENUS (to name)
        resb 15
g_B224:                                         ; used by MENUS (to name)
        resb 155
g_B2BF:                                         ; used by MENUS (to name)
        resb 1
g_B2C0:                                         ; used by MENUS (to name)
        resb 1
g_B2C1:                                         ; used by MENUS (to name)
        resb 1
g_B2C2:                                         ; used by MENUS (to name)
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
g_B2F2:                                         ; used by INIT (to name)
        resb 2
g_B2F4:                                         ; used by INIT (to name)
        resb 2
g_B2F6:                                         ; used by INIT (to name)
        resb 2
g_B2F8:                                         ; used by INIT (to name)
        resb 2
ArenaJingleB:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleBSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 2
g_B2FE:                                         ; used by INIT (to name)
        resb 2
g_B300:                                         ; used by INIT (to name)
        resb 2
g_B302:                                         ; used by INIT (to name)
        resb 2
g_B304:                                         ; used by INIT (to name)
        resb 2
g_B306:                                         ; used by INIT (to name)
        resb 2
g_B308:                                         ; used by INIT (to name)
        resb 10
g_B312:                                         ; used by INIT (to name)
        resb 2
g_B314:                                         ; used by INIT (to name)
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
g_B35E:                                         ; used by MENUS (to name)
        resb 1
g_B35F:                                         ; used by MENUS (to name)
        resb 1
g_B360:                                         ; used by MENUS (to name)
        resb 2
g_B362:                                         ; used by INIT (to name)
        resb 2
g_B364:                                         ; used by INIT, LP (to name)
        resb 2
g_B366:                                         ; used by INIT, LP (to name)
        resb 2
g_B368:                                         ; used by INIT (to name)
        resb 2
g_B36A:                                         ; used by INIT, LP (to name)
        resb 2
g_B36C:                                         ; used by INIT (to name)
        resb 2
hmscore:                                         ; used by AI, INIT, LP, MENUS (to name)
        resb 2
g_B370:                                         ; used by INIT (to name)
        resb 2
g_B372:                                         ; used by INIT (to name)
        resb 2
g_B374:                                         ; used by INIT (to name)
        resb 2
g_B376:                                         ; used by INIT (to name)
        resb 2
hmtmline:                                         ; used by AI (to name)
        resb 2
hmtmlcnt:                                         ; used by AI (to name)
        resb 2
hmtmextra:                                         ; used by AI (to name)
        resb 2
g_B37E:                                         ; used by AI (to name)
        resb 2
g_B380:                                         ; used by AI (to name)
        resb 2
g_B382:                                         ; used by AI (to name)
        resb 2
hmtmap:                                         ; used by AI, INIT, MENUS (to name)
        resb 2
hmtmgoalie:                                         ; used by AI, INIT, LP (to name)
        resb 1
g_B387:                                         ; used by AI (to name)
        resb 5
hmtmflags:                                         ; used by AI, MENUS (to name)
        resb 2
g_B38E:                                         ; used by AI (to name)
        resb 56
g_B3C6:                                         ; used by AI (to name)
        resb 56
g_B3FE:                                         ; used by AI (to name)
        resb 28
hmtmcoach_d2:                                         ; used by AI (to name)
        resb 1
hmtmcoach_d3:                                         ; used by AI (to name)
        resb 1
hmtmcoachflags:                                         ; used by AI (to name)
        resb 1
hmtmcoachmode:                                         ; used by AI (to name)
        resb 1
hmtmcoachenergy:                                         ; used by AI (to name)
        resb 2
hmtmlines:                                         ; used by AI, INIT, LP (to name)
        resb 2
hmtmsort:                                         ; used by AI, INIT (to name)
        resb 2
hmtmplattr:                                         ; used by AI, INIT (to name)
        resb 2
g_B426:                                         ; used by AI, INIT (to name)
        resb 2
g_B428:                                         ; used by AI, INIT (to name)
        resb 2
g_B42A:                                         ; used by AI, INIT (to name)
        resb 2
g_B42C:                                         ; used by AI, INIT (to name)
        resb 2
hmtmglstats:                                         ; used by AI, INIT (to name)
        resb 2
hmtmroster:                                         ; used by AI, INIT (to name)
        resb 2
g_B432:                                         ; used by AI, INIT (to name)
        resb 2
hmtmptrF2:                                         ; used by AI, INIT (to name)
        resb 2
g_B436:                                         ; used by AI, INIT (to name)
        resb 14
awscore:                                         ; used by AI, LP, MENUS (to name)
        resb 10
awtmline:                                         ; used by AI (to name)
        resb 2
awtmlcnt:                                         ; used by AI (to name)
        resb 2
g_B452:                                         ; used by AI (to name)
        resb 2
g_B454:                                         ; used by AI (to name)
        resb 2
g_B456:                                         ; used by AI (to name)
        resb 2
g_B458:                                         ; used by AI (to name)
        resb 2
awtmap:                                         ; used by AI, INIT (to name)
        resb 2
awtmgoalie:                                         ; used by AI, INIT, LP (to name)
        resb 6
awtmflags:                                         ; used by AI, MENUS (to name)
        resb 114
g_B4D4:                                         ; used by AI (to name)
        resb 28
awtmcoach_d2:                                         ; used by AI (to name)
        resb 1
awtmcoach_d3:                                         ; used by AI (to name)
        resb 1
awtmcoachflags:                                         ; used by AI (to name)
        resb 1
awtmcoachmode:                                         ; used by AI (to name)
        resb 1
awtmcoachenergy:                                         ; used by AI (to name)
        resb 2
g_B4F6:                                         ; used by AI, INIT, LP (to name)
        resb 2
awtmsort:                                         ; used by AI, INIT (to name)
        resb 2
g_B4FA:                                         ; used by AI, INIT (to name)
        resb 2
awtmglattr:                                         ; used by AI, INIT (to name)
        resb 2
awtmlines:                                         ; used by AI, INIT (to name)
        resb 2
awtmplstats:                                         ; used by AI, INIT (to name)
        resb 2
awtmglstats:                                         ; used by AI, INIT (to name)
        resb 2
g_B504:                                         ; used by AI, INIT (to name)
        resb 2
g_B506:                                         ; used by AI, INIT (to name)
        resb 2
awtmptrF2:                                         ; used by AI, INIT (to name)
        resb 2
g_B50A:                                         ; used by AI, INIT (to name)
        resb 2
g_B50C:                                         ; used by AI, INIT (to name)
        resb 4
g_B510:                                         ; used by AI (to name)
        resb 4
g_B514:                                         ; used by AI (to name)
        resb 20
g_B528:                                         ; used by AI (to name)
        resb 42
CwdExciteLvl:                                         ; used by AI (to name)
        resb 1
g_B553:                                         ; used by AI (to name)
        resb 2
g_B555:                                         ; used by AI (to name)
        resb 1467
g_BB10:                                         ; used by AI (to name)
        resb 4
g_BB14:                                         ; used by AI (to name)
        resb 6
g_BB1A:                                         ; used by AI (to name)
        resb 2
g_BB1C:                                         ; used by AI (to name)
        resb 116
g_BB90:                                         ; used by AI (to name)
        resb 4
g_BB94:                                         ; used by AI (to name)
        resb 6
g_BB9A:                                         ; used by AI (to name)
        resb 2
g_BB9C:                                         ; used by AI (to name)
        resb 116
g_BC10:                                         ; used by AI (to name)
        resb 4
puckstruct:                                         ; used by AI (to name)
        resb 4
g_BC18:                                         ; used by AI (to name)
        resb 2
g_BC1A:                                         ; used by AI (to name)
        resb 2
g_BC1C:                                         ; used by AI (to name)
        resb 4
g_BC20:                                         ; used by AI (to name)
        resb 10
g_BC2A:                                         ; used by AI (to name)
        resb 2
g_BC2C:                                         ; used by AI (to name)
        resb 8
pucktemp1:                                         ; used by AI (to name)
        resb 2
g_BC36:                                         ; used by AI (to name)
        resb 22
g_BC4C:                                         ; used by AI (to name)
        resb 7
puckpflags2:                                         ; used by AI (to name)
        resb 3
g_BC56:                                         ; used by AI (to name)
        resb 56
g_BC8E:                                         ; used by AI (to name)
        resb 2
g_BC90:                                         ; used by AI (to name)
        resb 4
g_BC94:                                         ; used by AI (to name)
        resb 4
g_BC98:                                         ; used by AI (to name)
        resb 2
g_BC9A:                                         ; used by AI (to name)
        resb 2
g_BC9C:                                         ; used by AI (to name)
        resb 4
g_BCA0:                                         ; used by AI (to name)
        resb 20
g_BCB4:                                         ; used by AI (to name)
        resb 2
g_BCB6:                                         ; used by AI (to name)
        resb 16
g_BCC6:                                         ; used by AI (to name)
        resb 12
g_BCD2:                                         ; used by AI (to name)
        resb 2
g_BCD4:                                         ; used by AI (to name)
        resb 2
g_BCD6:                                         ; used by AI (to name)
        resb 56
g_BD0E:                                         ; used by AI (to name)
        resb 2
g_BD10:                                         ; used by AI (to name)
        resb 4
refYpos2:                                         ; used by AI (to name)
        resb 6
refXvel:                                         ; used by AI (to name)
        resb 2
g_BD1C:                                         ; used by AI (to name)
        resb 4
g_BD20:                                         ; used by AI (to name)
        resb 8
g_BD28:                                         ; used by AI (to name)
        resb 2
refposition:                                         ; used by AI (to name)
        resb 2
refasslist:                                         ; used by AI (to name)
        resb 8
g_BD34:                                         ; used by AI (to name)
        resb 4
reftemp3:                                         ; used by AI (to name)
        resb 2
g_BD3A:                                         ; used by AI (to name)
        resb 2
g_BD3C:                                         ; used by AI (to name)
        resb 8
g_BD44:                                         ; used by AI (to name)
        resb 20
g_BD58:                                         ; used by AI (to name)
        resb 1
g_BD59:                                         ; used by AI (to name)
        resb 1
g_BD5A:                                         ; used by AI (to name)
        resb 52
g_BD8E:                                         ; used by MENUS (to name)
        resb 2
g_BD90:                                         ; used by MENUS (to name)
        resb 2
g_BD92:                                         ; used by MENUS (to name)
        resb 2
g_BD94:                                         ; used by MENUS (to name)
        resb 2
g_BD96:                                         ; used by MENUS (to name)
        resb 1
gmrosterjersey:                                         ; used by MENUS (to name)
        resb 1
gmrosterslot:                                         ; used by MENUS (to name)
        resb 1
g_BD99:                                         ; used by MENUS (to name)
        resb 1
g_BD9A:                                         ; used by MENUS (to name)
        resb 1
g_BD9B:                                         ; used by MENUS (to name)
        resb 1
g_BD9C:                                         ; used by MENUS (to name)
        resb 544
g_BFBC:                                         ; used by MENUS (to name)
        resb 1
g_BFBD:                                         ; used by MENUS (to name)
        resb 2
g_BFBF:                                         ; used by MENUS (to name)
        resb 1
g_BFC0:                                         ; used by MENUS (to name)
        resb 1
g_BFC1:                                         ; used by MENUS (to name)
        resb 1
g_BFC2:                                         ; used by MENUS (to name)
        resb 60
curperiod:                                         ; used by AI, GAME, INIT, LP, MENUS (to name)
        resb 2
g_C000:                                         ; used by LP (to name)
        resb 32
g_C020:                                         ; used by LP (to name)
        resb 32
g_C040:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
statsgoaliebuf:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
g_C044:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
statsskaterbuf:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
g_C048:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
statsplayerbuf:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
g_C04C:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
statsteambuf:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
g_C050:                                         ; used by MENUS, STATS (to name)
        resb 2
leaguestatsmode:                                         ; used by LP, MENUS, STATS (to name)
        resb 2
g_C054:                                         ; used by MENUS (to name)
        resb 2
g_C056:                                         ; used by MENUS (to name)
        resb 2
g_C058:                                         ; used by MENUS (to name)
        resb 2
g_C05A:                                         ; used by MENUS (to name)
        resb 2
g_C05C:                                         ; used by MENUS (to name)
        resb 2
g_C05E:                                         ; used by MENUS (to name)
        resb 126
g_C0DC:                                         ; used by MENUS (to name)
        resb 2
lgfiles:                                         ; used by MENUS (to name)
        resb 2
g_C0E0:                                         ; used by MENUS (to name)
        resb 2
g_C0E2:                                         ; used by MENUS (to name)
        resb 2
g_C0E4:                                         ; used by MENUS (to name)
        resb 2
lgfilenames:                                         ; used by MENUS (to name)
        resb 126
g_C164:                                         ; used by MENUS (to name)
        resb 2
g_C166:                                         ; used by MENUS (to name)
        resb 2
g_C168:                                         ; used by MENUS (to name)
        resb 2
g_C16A:                                         ; used by MENUS (to name)
        resb 2
g_C16C:                                         ; used by MENUS (to name)
        resb 2
g_C16E:                                         ; used by MENUS (to name)
        resb 126
fdlgtab:                                         ; used by MENUS (to name)
        resb 2
g_C1EE:                                         ; used by MENUS (to name)
        resb 1
g_C1EF:                                         ; used by MENUS (to name)
        resb 1
g_C1F0:                                         ; used by MENUS (to name)
        resb 2
g_C1F2:                                         ; used by MENUS (to name)
        resb 2
g_C1F4:                                         ; used by MENUS (to name)
        resb 16
playofftree:                                         ; used by MENUS, STATS (to name)
        resb 2
g_C206:                                         ; used by MENUS (to name)
        resb 30
g_C224:                                         ; used by MENUS (to name)
        resb 20
g_C238:                                         ; used by STATS (to name)
        resb 2
g_C23A:                                         ; used by STATS (to name)
        resb 2
g_C23C:                                         ; used by STATS (to name)
        resb 2
g_C23E:                                         ; used by STATS (to name)
        resb 2
g_C240:                                         ; used by STATS (to name)
        resb 2
g_C242:                                         ; used by MENUS (to name)
        resb 22
g_C258:                                         ; used by AI, INIT, MENUS (to name)
        resb 2
g_C25A:                                         ; used by AI, INIT, MENUS (to name)
        resb 2
g_C25C:                                         ; used by AI, INIT, MENUS (to name)
        resb 2
g_C25E:                                         ; used by AI, INIT, MENUS (to name)
        resb 2
g_C260:                                         ; used by LP (to name)
        resb 2
g_C262:                                         ; used by LP (to name)
        resb 2
g_C264:                                         ; used by LP (to name)
        resb 2
g_C266:                                         ; used by LP (to name)
        resb 2
g_C268:                                         ; used by LP (to name)
        resb 2
g_C26A:                                         ; used by LP (to name)
        resb 2
g_C26C:                                         ; used by LP (to name)
        resb 2
g_C26E:                                         ; used by LP (to name)
        resb 2
g_C270:                                         ; used by LP (to name)
        resb 2
g_C272:                                         ; used by LP (to name)
        resb 2
teamselresult:                                         ; used by LP (to name)
        resb 2
g_C276:                                         ; used by LP (to name)
        resb 2
g_C278:                                         ; used by LP (to name)
        resb 2
g_C27A:                                         ; used by LP (to name)
        resb 2
g_C27C:                                         ; used by LP (to name)
        resb 2
g_C27E:                                         ; used by LP (to name)
        resb 14
g_C28C:                                         ; used by LP (to name)
        resb 14
g_C29A:                                         ; used by LP (to name)
        resb 1
g_C29B:                                         ; used by LP (to name)
        resb 1
g_C29C:                                         ; used by LP (to name)
        resb 1
g_C29D:                                         ; used by LP (to name)
        resb 1
lgschedrec_b4:                                         ; used by LP (to name)
        resb 1
g_C29F:                                         ; used by LP (to name)
        resb 1
statspalshape:                                         ; used by LP, STATS (to name)
        resb 2
g_C2A2:                                         ; used by LP (to name)
        resb 2
g_C2A4:                                         ; used by LP (to name)
        resb 2
g_C2A6:                                         ; used by LP (to name)
        resb 2
g_C2A8:                                         ; used by LP (to name)
        resb 2
g_C2AA:                                         ; used by LP (to name)
        resb 2
g_C2AC:                                         ; used by LP (to name)
        resb 2
g_C2AE:                                         ; used by LP (to name)
        resb 2
g_C2B0:                                         ; used by LP (to name)
        resb 2
statsbgshapes:                                         ; used by LP, STATS (to name)
        resb 2
g_C2B4:                                         ; used by LP, STATS (to name)
        resb 2
startm:                                         ; used by AI, LP (to name)
        resb 2
starpl:                                         ; used by AI, LP (to name)
        resb 10
g_C2C2:                                         ; used by LP (to name)
        resb 1
g_C2C3:                                         ; used by LP (to name)
        resb 1
g_C2C4:                                         ; used by LP (to name)
        resb 614
g_C52A:                                         ; used by LP (to name)
        resb 616
g_C792:                                         ; used by LP (to name)
        resb 2
g_C794:                                         ; used by LP (to name)
        resb 2
g_C796:                                         ; used by LP (to name)
        resb 2
g_C798:                                         ; used by LP (to name)
        resb 2
g_C79A:                                         ; used by LP (to name)
        resb 2
g_C79C:                                         ; used by LP (to name)
        resb 2
g_C79E:                                         ; used by LP (to name)
        resb 2
g_C7A0:                                         ; used by LP (to name)
        resb 2
g_C7A2:                                         ; used by LP (to name)
        resb 2
g_C7A4:                                         ; used by LP (to name)
        resb 2
g_C7A6:                                         ; used by LP (to name)
        resb 2
g_C7A8:                                         ; used by LP (to name)
        resb 2
g_C7AA:                                         ; used by LP (to name)
        resb 2
g_C7AC:                                         ; used by LP (to name)
        resb 38
g_C7D2:                                         ; used by LP (to name)
        resb 2
g_C7D4:                                         ; used by LP (to name)
        resb 38
g_C7FA:                                         ; used by LP (to name)
        resb 2
g_C7FC:                                         ; used by LP (to name)
        resb 10
g_C806:                                         ; used by LP (to name)
        resb 1023
g_CC05:                                         ; used by LP (to name)
        resb 36
g_CC29:                                         ; used by LP (to name)
        resb 703
g_CEE8:                                         ; used by STATS (to name)
        resb 48
g_CF18:                                         ; used by STATS (to name)
        resb 2
g_CF1A:                                         ; used by STATS (to name)
        resb 1
g_CF1B:                                         ; used by STATS (to name)
        resb 1
statsplayer:                                         ; used by STATS (to name)
        resb 1
g_CF1D:                                         ; used by STATS (to name)
        resb 16
g_CF2D:                                         ; used by STATS (to name)
        resb 17
g_CF3E:                                         ; used by STATS (to name)
        resb 2
g_CF40:                                         ; used by STATS (to name)
        resb 2
g_CF42:                                         ; used by STATS (to name)
        resb 2
g_CF44:                                         ; used by STATS (to name)
        resb 2
g_CF46:                                         ; used by STATS (to name)
        resb 2
g_CF48:                                         ; used by STATS (to name)
        resb 2
g_CF4A:                                         ; used by STATS (to name)
        resb 2
g_CF4C:                                         ; used by STATS (to name)
        resb 2
g_CF4E:                                         ; used by STATS (to name)
        resb 50
g_CF80:                                         ; used by STATS (to name)
        resb 50
g_CFB2:                                         ; used by STATS (to name)
        resb 10
g_CFBC:                                         ; used by STATS (to name)
        resb 10
g_CFC6:                                         ; used by STATS (to name)
        resb 2
g_CFC8:                                         ; used by STATS (to name)
        resb 2
g_CFCA:                                         ; used by STATS (to name)
        resb 2
g_CFCC:                                         ; used by STATS (to name)
        resb 2
g_CFCE:                                         ; used by STATS (to name)
        resb 2
fileoncd:                                         ; used by STATS (to name)
        resb 2
cddriveptr:                                         ; used by STATS (to name)
        resb 2
g_CFD4:                                         ; used by STATS (to name)
        resb 40
g_CFFC:                                         ; used by GAME, INIT (to name)
        resb 2
g_CFFE:                                         ; used by GAME, INIT (to name)
        resb 2
regd5:                                         ; used by AI (to name)
        resb 2
g_D002:                                         ; used by AI (to name)
        resb 2
g_D004:                                         ; used by AI, INIT (to name)
        resb 2
LastShooterTeam:                                         ; used by AI (to name)
        resb 2
g_D008:                                         ; used by AI (to name)
        resb 2
g_D00A:                                         ; used by AI, INIT (to name)
        resb 2
g_D00C:                                         ; used by AI (to name)
        resb 2
g_D00E:                                         ; used by AI (to name)
        resb 2
g_D010:                                         ; used by AI, INIT (to name)
        resb 2
g_D012:                                         ; used by AI, INIT (to name)
        resb 2
g_D014:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D016:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D018:                                         ; used by INIT (to name)
        resb 2
g_D01A:                                         ; used by INIT (to name)
        resb 2
g_D01C:                                         ; used by AI (to name)
        resb 2
g_D01E:                                         ; used by AI (to name)
        resb 2
g_D020:                                         ; used by AI (to name)
        resb 2
g_D022:                                         ; used by AI (to name)
        resb 394
g_D1AC:                                         ; used by AI, INIT (to name)
        resb 2
rinkobjs:                                         ; used by AI, INIT (to name)
        resb 2
rinkobjs_w2:                                         ; used by INIT (to name)
        resb 278
g_D2C6:                                         ; used by AI, INIT (to name)
        resb 2
g_D2C8:                                         ; used by AI, INIT (to name)
        resb 382
g_D446:                                         ; used by AI, INIT (to name)
        resb 2
g_D448:                                         ; used by AI, INIT (to name)
        resb 14
g_D456:                                         ; used by AI, INIT (to name)
        resb 2
g_D458:                                         ; used by AI, INIT (to name)
        resb 18
g_D46A:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D46C:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D46E:                                         ; used by AI, GAME, INIT (to name)
        resb 2
lcline:                                         ; used by AI, GAME, INIT (to name)
        resb 2
lctimer:                                         ; used by GAME, INIT (to name)
        resb 2
g_D474:                                         ; used by AI (to name)
        resb 34
g_D496:                                         ; used by AI, INIT (to name)
        resb 34
textline3:                                         ; used by AI, INIT (to name)
        resb 59
g_D4F3:                                         ; used by AI (to name)
        resb 1
g_D4F4:                                         ; used by AI, INIT (to name)
        resb 1
g_D4F5:                                         ; used by AI (to name)
        resb 17
textline1:                                         ; used by AI, INIT (to name)
        resb 60
textline2:                                         ; used by AI, INIT (to name)
        resb 60
textline4:                                         ; used by AI, INIT (to name)
        resb 60
textline5:                                         ; used by AI, INIT (to name)
        resb 60
PlList:                                         ; used by AI, INIT (to name)
        resb 6
g_D5FC:                                         ; used by AI (to name)
        resb 6
fofdata2:                                         ; used by AI, INIT (to name)
        resb 2
g_D604:                                         ; used by AI (to name)
        resb 2
g_D606:                                         ; used by AI (to name)
        resb 2
g_D608:                                         ; used by AI (to name)
        resb 2
g_D60A:                                         ; used by AI (to name)
        resb 2
g_D60C:                                         ; used by AI (to name)
        resb 2
g_D60E:                                         ; used by GAME, INIT (to name)
        resb 2
g_D610:                                         ; used by GAME, INIT (to name)
        resb 2
g_D612:                                         ; used by INIT (to name)
        resb 2
g_D614:                                         ; used by INIT (to name)
        resb 2
puckcross:                                         ; used by INIT (to name)
        resb 2
g_D618:                                         ; used by AI (to name)
        resb 1
g_D619:                                         ; used by AI (to name)
        resb 3
g_D61C:                                         ; used by AI (to name)
        resb 1
g_D61D:                                         ; used by AI (to name)
        resb 1
GoalState:                                         ; used by AI, INIT (to name)
        resb 2
lj1:                                         ; used by AI, INIT (to name)
        resb 2
lj2:                                         ; used by AI, INIT (to name)
        resb 2
lasttouch:                                         ; used by AI, INIT (to name)
        resb 2
ltx:                                         ; used by AI, INIT (to name)
        resb 2
lty:                                         ; used by AI, INIT (to name)
        resb 2
iflags:                                         ; used by AI, INIT (to name)
        resb 1
g_D62B:                                         ; used by AI (to name)
        resb 1
g_D62C:                                         ; used by AI, INIT (to name)
        resb 2
g_D62E:                                         ; used by AI, INIT (to name)
        resb 2
g_D630:                                         ; used by AI, INIT (to name)
        resb 2
g_D632:                                         ; used by AI, INIT (to name)
        resb 38
g_D658:                                         ; used by AI, INIT (to name)
        resb 2
g_D65A:                                         ; used by AI, INIT (to name)
        resb 2
g_D65C:                                         ; used by AI, INIT (to name)
        resb 2
g_D65E:                                         ; used by AI, INIT (to name)
        resb 2
g_D660:                                         ; used by AI, INIT (to name)
        resb 1
g_D661:                                         ; used by AI, INIT (to name)
        resb 1
g_D662:                                         ; used by INIT (to name)
        resb 1
g_D663:                                         ; used by INIT (to name)
        resb 1
g_D664:                                         ; used by INIT (to name)
        resb 2
g_D666:                                         ; used by INIT (to name)
        resb 2
g_D668:                                         ; used by AI, INIT (to name)
        resb 2
g_D66A:                                         ; used by INIT (to name)
        resb 2
regd0:                                         ; used by AI, INIT (to name)
        resb 1
g_D66D:                                         ; used by INIT (to name)
        resb 1
g_D66E:                                         ; used by AI, INIT (to name)
        resb 2
g_D670:                                         ; used by INIT (to name)
        resb 2
regd1:                                         ; used by AI, INIT (to name)
        resb 1
g_D673:                                         ; used by AI (to name)
        resb 1
g_D674:                                         ; used by AI (to name)
        resb 2
PenBuf:                                         ; used by AI (to name)
        resb 1
PenBuf_pl:                                         ; used by AI (to name)
        resb 1
g_D678:                                         ; used by AI (to name)
        resb 64
regd2:                                         ; used by AI, INIT (to name)
        resb 2
g_D6BA:                                         ; used by AI (to name)
        resb 2
g_D6BC:                                         ; used by INIT (to name)
        resb 2
g_D6BE:                                         ; used by INIT (to name)
        resb 2
regd3:                                         ; used by AI (to name)
        resb 2
g_D6C2:                                         ; used by AI (to name)
        resb 2
g_D6C4:                                         ; used by AI, INIT (to name)
        resb 2
PBnum:                                         ; used by AI, INIT (to name)
        resb 1
g_D6C7:                                         ; used by AI (to name)
        resb 1
regd4:                                         ; used by AI, INIT (to name)
        resb 2
g_D6CA:                                         ; used by AI (to name)
        resb 2
viewscrollx:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D6CE:                                         ; used by AI, GAME, INIT (to name)
        resb 2
frameaccum:                                         ; used by AI, GAME, INIT (to name)
        resb 2
hudhundaccum:                                         ; used by AI, GAME, INIT (to name)
        resb 2
g_D6D4:                                         ; used by AI, INIT (to name)
        resb 2
g_D6D6:                                         ; used by AI, INIT (to name)
        resb 2
g_D6D8:                                         ; used by GAME (to name)
        resb 2
g_D6DA:                                         ; used by GAME (to name)
        resb 38
g_D700:                                         ; used by GAME (to name)
        resb 2
g_D702:                                         ; used by GAME (to name)
        resb 26
g_D71C:                                         ; used by GAME, INIT (to name)
        resb 2
g_D71E:                                         ; used by GAME, INIT (to name)
        resb 10
hudhundstep:                                         ; used by AI, GAME, INIT (to name)
        resb 686
g_D9D6:                                         ; used by GAME (to name)
        resb 4
g_D9DA:                                         ; used by AI, INIT (to name)
        resb 32
g_D9FA:                                         ; used by INIT (to name)
        resb 12
g_DA06:                                         ; used by INIT (to name)
        resb 2
g_DA08:                                         ; used by INIT (to name)
        resb 2
g_DA0A:                                         ; used by AI (to name)
        resb 2
g_DA0C:                                         ; used by AI (to name)
        resb 1
g_DA0D:                                         ; used by MENUS (to name)
        resb 29
g_DA2A:                                         ; used by AI, INIT (to name)
        resb 2
g_DA2C:                                         ; used by AI, INIT (to name)
        resb 2
g_DA2E:                                         ; used by AI, INIT (to name)
        resb 2
g_DA30:                                         ; used by AI, INIT (to name)
        resb 26
g_DA4A:                                         ; used by AI (to name)
        resb 2
g_DA4C:                                         ; used by AI (to name)
        resb 38
g_DA72:                                         ; used by AI (to name)
        resb 2
g_DA74:                                         ; used by AI (to name)
        resb 2
g_DA76:                                         ; used by AI (to name)
        resb 2
g_DA78:                                         ; used by AI (to name)
        resb 38
g_DA9E:                                         ; used by AI (to name)
        resb 2
clockcolon:                                         ; used by AI (to name)
        resb 2
g_DAA2:                                         ; used by AI (to name)
        resb 2
g_DAA4:                                         ; used by AI (to name)
        resb 42
g_DACE:                                         ; used by AI, INIT (to name)
        resb 2
g_DAD0:                                         ; used by AI, INIT (to name)
        resb 2
g_DAD2:                                         ; used by INIT (to name)
        resb 2
g_DAD4:                                         ; used by INIT (to name)
        resb 2
g_DAD6:                                         ; used by INIT (to name)
        resb 2
g_DAD8:                                         ; used by INIT (to name)
        resb 2
g_DADA:                                         ; used by INIT (to name)
        resb 2
g_DADC:                                         ; used by INIT (to name)
        resb 2
g_DADE:                                         ; used by INIT (to name)
        resb 8
g_DAE6:                                         ; used by INIT (to name)
        resb 2
g_DAE8:                                         ; used by INIT (to name)
        resb 2
g_DAEA:                                         ; used by INIT (to name)
        resb 20
g_DAFE:                                         ; used by INIT (to name)
        resb 2
g_DB00:                                         ; used by INIT (to name)
        resb 2
g_DB02:                                         ; used by INIT (to name)
        resb 14
g_DB10:                                         ; used by INIT (to name)
        resb 2
g_DB12:                                         ; used by INIT (to name)
        resb 2
g_DB14:                                         ; used by INIT (to name)
        resb 2
g_DB16:                                         ; used by INIT (to name)
        resb 2
g_DB18:                                         ; used by INIT (to name)
        resb 2
g_DB1A:                                         ; used by INIT (to name)
        resb 2
g_DB1C:                                         ; used by INIT (to name)
        resb 2
replayptrx:                                         ; used by INIT (to name)
        resb 2
g_DB20:                                         ; used by INIT (to name)
        resb 2
g_DB22:                                         ; used by INIT (to name)
        resb 2
g_DB24:                                         ; used by INIT (to name)
        resb 2
g_DB26:                                         ; used by INIT (to name)
        resb 2
g_DB28:                                         ; used by INIT (to name)
        resb 2
g_DB2A:                                         ; used by INIT (to name)
        resb 2
g_DB2C:                                         ; used by INIT (to name)
        resb 2
g_DB2E:                                         ; used by INIT (to name)
        resb 28
g_DB4A:                                         ; used by INIT (to name)
        resb 2
g_DB4C:                                         ; used by INIT (to name)
        resb 4
g_DB50:                                         ; used by INIT (to name)
        resb 28
g_DB6C:                                         ; used by INIT (to name)
        resb 2
g_DB6E:                                         ; used by INIT (to name)
        resb 4
g_DB72:                                         ; used by INIT (to name)
        resb 28
g_DB8E:                                         ; used by INIT (to name)
        resb 2
g_DB90:                                         ; used by INIT (to name)
        resb 4
g_DB94:                                         ; used by INIT (to name)
        resb 17
g_DBA5:                                         ; used by INIT (to name)
        resb 12
g_DBB1:                                         ; used by INIT (to name)
        resb 1
g_DBB2:                                         ; used by INIT (to name)
        resb 12
g_DBBE:                                         ; used by INIT (to name)
        resb 2
g_DBC0:                                         ; used by INIT (to name)
        resb 2
g_DBC2:                                         ; used by INIT (to name)
        resb 1
g_DBC3:                                         ; used by INIT (to name)
        resb 1
g_DBC4:                                         ; used by INIT (to name)
        resb 1
g_DBC5:                                         ; used by INIT (to name)
        resb 1
g_DBC6:                                         ; used by INIT (to name)
        resb 2
g_DBC8:                                         ; used by INIT (to name)
        resb 2
g_DBCA:                                         ; used by INIT (to name)
        resb 2
g_DBCC:                                         ; used by INIT (to name)
        resb 40
g_DBF4:                                         ; used by INIT (to name)
        resb 1
g_DBF5:                                         ; used by INIT (to name)
        resb 19
g_DC08:                                         ; used by INIT (to name)
        resb 34
g_DC2A:                                         ; used by AI (to name)
        resb 2
g_DC2C:                                         ; used by AI (to name)
        resb 2
g_DC2E:                                         ; used by AI (to name)
        resb 2
g_DC30:                                         ; used by AI (to name)
        resb 2
g_DC32:                                         ; used by AI (to name)
        resb 2
g_DC34:                                         ; used by AI (to name)
        resb 2
g_DC36:                                         ; used by AI (to name)
        resb 2
g_DC38:                                         ; used by AI (to name)
        resb 2
g_DC3A:                                         ; used by AI (to name)
        resb 56
g_DC72:                                         ; used by AI (to name)
        resb 96
lastimpact:                                         ; used by AI (to name)
        resb 2
gwgplayer:                                         ; used by AI (to name)
        resb 2
gwgteam:                                         ; used by AI (to name)
        resb 2
g_DCD8:                                         ; used by AI (to name)
        resb 52
offsort_fwd:                                         ; used by AI (to name)
        resb 50
defsort_d:                                         ; used by AI (to name)
        resb 400
dressflags:                                         ; used by AI (to name)
        resb 25
g_DEE7:                                         ; used by AI (to name)
        resb 25
lineslotmark:                                         ; used by AI (to name)
        resb 50
g_DF32:                                         ; used by AI (to name)
        resb 50
dresseddefs:                                         ; used by AI (to name)
        resb 2
dressedfwds:                                         ; used by AI (to name)
        resb 2
dressedskaters:                                         ; used by AI (to name)
        resb 2
g_DF6A:                                         ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6, FADES8 (to name)
        resb 2
g_DF6C:                                         ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6, FADES8 (to name)
        resb 2
g_DF6E:                                         ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6, FADES8 (to name)
        resb 2
g_DF70:                                         ; used by FADES, FADES10, FADES11, FADES12, FADES5, FADES6, FADES8 (to name)
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
g_E366:                                         ; used by AI, INIT, LP (to name)
        resb 1
g_E367:                                         ; used by AI, INIT, LP (to name)
        resb 1
g_E368:                                         ; used by INIT (to name)
        resb 1
g_E369:                                         ; used by INIT (to name)
        resb 1
g_E36A:                                         ; used by INIT (to name)
        resb 1
g_E36B:                                         ; used by LP, MENUS (to name)
        resb 6149
