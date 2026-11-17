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
        resb 90
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
        resb 7654
HeapSizeLo:                                     ; heap size, low word; not used in the EXE (overlays may use
                                                ; it)
        resb 2
HeapSizeHi:                                     ; heap size, high word; not used in the EXE (overlays may use
                                                ; it)
        resb 6
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
        resb 36
HotKeyFn:                                       ; far routine for hot keys; used by ListDialog,
                                                ; MessageBoxLoop, SaveGameNameDialog ...
        resb 2
HotKeyFnSeg:                                    ; its segment; used by InputInit
        resb 52
TeamPalette1:                                   ; first team palette; used by LoadTeamPalettes
        resb 256
TeamPalette2:                                   ; second team palette; used by LoadTeamPalettes
        resb 262
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
        resb 10
ArenaJingleB:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleBSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 34
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
        resb 11286
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
        resb 6736
