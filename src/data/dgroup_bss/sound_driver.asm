; The retrace counter, the sequencer and sound driver state, the stdin buffer, the saved game bytes
; and the league flags.
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
