; The BSS of each module, in link order: the unpacker, speech, the fades, the shade table, the
; sequencer, the sound driver and the C run-time.
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
WantedList:                                     ; samples wanted, offset; used by ResetSampleReq,
                                                ; SpeechInit, ShutdownSpeech ...
        resb 2
WantedListSeg:                                  ; samples wanted, segment; used by ResetSampleReq,
                                                ; SpeechInit, ShutdownSpeech ...
        resb 2
SpeechBank:                                     ; speech bank, offset; used by SpeechTimerTick,
                                                ; InitSpeechSlots, SpeechInit ...
        resb 2
SpeechBankSeg:                                  ; speech bank, segment; used by SpeechTimerTick,
                                                ; InitSpeechSlots, SpeechInit ...
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
