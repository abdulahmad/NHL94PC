; The music sequencer and sound driver state.
SeqTickCount:                                   ; sequencer ticks; used by SeqService
        db 0x00, 0x00
SeqBusy:                                        ; seqService running; used by SeqTimerTick
        dw 0x0000
str_Track:                                      ; string 'track'; used by InitSequencer
        db 'track', 0x00
str_Parts:                                      ; string 'parts'; used by InitSequencer
        db 'parts', 0x00
str_Seqdat:                                     ; string 'seqdat'; used by InitSequencer
        db 'seqdat', 0x00
str_BankDPat:                                   ; string 'bank%d.pat'; used by LoadBankNumber
        db 'bank%d.pat', 0x00
str_TimbDTim:                                   ; string 'timb%d.tim'; used by LoadSongMode
        db 'timb%d.tim', 0x00, 0x00
SfxChannel:                                     ; effects channel; used by PlayPatchNote
        dw 0x0000
str_CEaclibS:                                   ; string 'c:\eaclib\%s'; used by LoadSoundDriver
        db 0x63, 0x3A, 0x5C, 'eaclib', 0x5C, 0x25, 0x73, 0x00, 0x00
        db 'Couldn', 0x27, 't resolve sound driver'
        db 0x00
DriverCount:                                    ; sound drivers loaded; used by LoadSoundDriver, DrvSendMidi,
                                                ; SeqTimerTick ...
        dw 0x0000
TrackSlots:                                     ; 24 track slots of 58h bytes, offset; used by SeqService,
                                                ; SetSongTempo, ResetSequencer ...
        dw 0x0000
TrackSlotsSeg:                                  ; track slots, segment; used by SeqService, SetSongTempo,
                                                ; InitSequencer ...
        dw 0x0000
Voices:                                         ; 32 voice records of 0Ch bytes, offset; used by SeqService,
                                                ; SeqStepTrack, AllocVoice ...
        dw 0x0000
VoicesSeg:                                      ; voice records, segment; used by SeqService, SeqStepTrack,
                                                ; AllocVoice ...
        dw 0x0000
ChannelMasks:                                   ; channel bit per MIDI channel; used by FindFreeChannel
        db 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00, 0x10, 0x00
        db 0x20, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00, 0x10
        db 0x00, 0x20, 0x00, 0x40, 0x00, 0x80
SongHandleLo:                                   ; last song handle, low word; used by StartSong
        dw 0x0200
SongHandleHi:                                   ; last song handle, high word; used by StartSong
        dw 0x0000
SeqLock:                                        ; sequencer locked while non-zero; used by SeqTimerTick,
                                                ; QueueMidiBytes, SendPatches ...
        dw 0x0000
MidiQueueLen:                                   ; bytes in the MIDI queue; used by QueueMidiBytes,
                                                ; FlushMidiQueue
        dw 0x0000
MidiQueueBusy:                                  ; MIDI queue in use; used by QueueMidiBytes, FlushMidiQueue
        dw 0x0000
TracksMuted:                                    ; tracks muted; used by SeqService, MuteAllTracks,
                                                ; RestoreTrackVolumes
        dw 0x0000
SfxEnabled:                                     ; effects on; used by PlayPatchNote, ReleaseAllVoices,
                                                ; StopSound ...
        dw 0x0001
MusicEnabled:                                   ; second sound flag (music); used by MusicOn, MusicOff,
                                                ; ToggleMusic ...
        dw 0x0001
DriverName:                                     ; driver file name being loaded; used by LoadSoundDriver
        dw 0x0064
DriverServiceIdx:                               ; driver that needs service (FFh for none); used by
                                                ; LoadSoundDriver, SeqService, ResetSequencer
        db 0xFF, 0x00
SongCount:                                      ; songs loaded; used by LoadSongMode, UnloadSong
        db 0x00, 0x00
SongPtrs:                                       ; song pointers, offsets; used by LoadSongMode, UnloadSong
        db 0x00, 0x00
SongPtrsSeg:                                    ; song pointers, segments; used by LoadSongMode, UnloadSong
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
