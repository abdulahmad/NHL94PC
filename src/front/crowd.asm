; Crowd noise and the announcer: the crowd level that rises and falls with play, sound effects, and
; the calls that queue spoken lines (goals, penalties, lineups, period and game summaries).

;-----------------------------------------------------------------------------
; MessageBoxResetTail                                         0EDC:0000  94 PC
; End of MessageBoxReset.
;-----------------------------------------------------------------------------
MessageBoxResetTail:                            ; end of MessageBoxReset
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Crowd_Noise                                            0EDC:0002  94 PC
; Eases the crowd level toward CrowdTarget and drives the MIDI crowd notes
; (volume, pitch).
;-----------------------------------------------------------------------------
Crowd_Noise:
        enter 0x2, 0x0
        push di
        push si
        test byte [CrowdState], 0x80
        jnz short .1
        jmp near .23
.1:
        test byte [SoundOptions], 0xa
        jnz short .2
        jmp near .23
.2:
        mov di, [CrowdSound]
        sub di, [Crowdlevel]
        imul bx, [bp + 0x6], 0x1e
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jng short .4
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .3
        add [Crowdlevel], bx
        jmp short .5
        db 0x90
.3:
        sub [Crowdlevel], bx
        jmp short .5
.4:
        mov ax, [CrowdSound]
        mov [Crowdlevel], ax
.5:
        cmp word [Crowdlevel], 0x200
        jnl short .6
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .9
.6:
        cmp word [Crowdlevel], 0x390
        jnl short .7
        mov ax, [Crowdlevel]
        sub ax, 0x200
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .8
.7:
        mov si, [Crowdlevel]
        sub si, 0x390
        sar si, byte 0x2
        add si, 0x28
.8:
        test byte [SoundOptions], 0x8
        jz short .9
        add si, 0x20
.9:
        cmp si, 0x7f
        jng short .10
        mov si, 0x7f
.10:
        mov ax, [Crowdlevel]
        mov cx, 0xc
        cwd
        idiv cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        add di, 0xa
        test byte [SoundOptions], 0x8
        jz short .11
        add di, 0x32
.11:
        cmp di, 0x7f
        jng short .12
        mov di, 0x7f
.12:
        cmp di, 0xa
        jnl short .13
        mov di, 0xa
.13:
        cmp word [CrowdTarget], 0x0
        jng short .14
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .14
        push si
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiControl
        add sp, 0x6
        push 0x24
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiNoteOff
        jmp short .15
        db 0x90
.14:
        cmp word [CrowdTarget], 0x0
        jnz short .16
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .16
        push 0x7d
        push 0x24
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiProgramNoteOn
        add sp, 0x8
        push 0x40
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiPitchBend
.15:
        add sp, 0x6
.16:
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .20
        push si
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiControl
        add sp, 0x6
        cmp si, 0x7f
        jnl short .17
        cmp word [CrowdTarget], 0x7f
        jl short .20
.17:
        cmp si, 0x7f
        jl short .18
        mov ax, 0x6
        call 0x0C11:randomd0
        jmp short .19
        db 0x90
.18:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.19:
        mov [bp - 0x2], ax
        mov ax, 0x40
        sub ax, [bp - 0x2]
        push ax
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiPitchBend
        add sp, 0x6
.20:
        mov [CrowdTarget], si
        cmp word [CrowdFade], 0x0
        jnz short .21
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .21
        push 0x7e
        push 0x24
        push 0x7
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiProgramNoteOn
        add sp, 0x8
.21:
        push di
        push 0x7
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiControl
        add sp, 0x6
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        add si, 0x20
        mov al, [SoundOptions]
        and ax, strict word 0x8
        cmp ax, strict word 0x1
        cmc
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x32
        db 0x2B, 0xC7                           ; insn: sub ax, di
        cmp ax, strict word 0xfff6
        jnz short .22
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x03, 0xF0                           ; insn: add si, ax
.22:
        push si
        push 0x7
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiPitchBend
        add sp, 0x6
        mov [CrowdFade], di
.23:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CrowdNoiseOff                                               0EDC:01DC  94 PC
; Note off and volume 0 on the two crowd channels.
;-----------------------------------------------------------------------------
CrowdNoiseOff:
        test byte [CrowdState], 0x80
        jz short .2
        test byte [SoundOptions], 0xa
        jz short .2
        cmp word [CrowdTarget], 0x0
        jng short .1
        push 0x0
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiControl
        add sp, 0x6
        push 0x24
        push 0x8
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiNoteOff
        add sp, 0x6
        mov word [CrowdTarget], 0x0
.1:
        cmp word [CrowdFade], 0x0
        jng short .2
        push 0x0
        push 0x7
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiControl
        add sp, 0x6
        push 0x24
        push 0x7
        mov al, [CrowdChannel]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0CC4:MidiNoteOff
        add sp, 0x6
        mov word [CrowdFade], 0x0
.2:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CrowdFadeOut                                                0EDC:024E  94 PC
; Lowers CrowdTarget step by step to silence.
;-----------------------------------------------------------------------------
CrowdFadeOut:
        push si
        mov si, [CrowdSound]
        test byte [CrowdState], 0x80
        jz short .4
        test byte [SoundOptions], 0xa
        jz short .4
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .3
.1:
        mov ax, 0x1
        cwd
        call 0x03A3:SetDeadline.regs
        sub word [CrowdSound], 0x32
        jns short .2
        mov word [CrowdSound], 0x0
.2:
        push 0x2
        push cs
        call Crowd_Noise
        add sp, 0x2
        call 0x03A3:WaitDeadlineNoEoi
        cmp word [CrowdSound], 0x0
        jg short .1
.3:
        push cs
        call CrowdNoiseOff
        mov [CrowdSound], si
.4:
        pop si
        retf

;-----------------------------------------------------------------------------
; CrowdReset                                                  0EDC:029A  94 PC
; Crowd level and both note states to 0.
;-----------------------------------------------------------------------------
CrowdReset:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [Crowdlevel], ax
        mov [CrowdTarget], ax
        mov [CrowdFade], ax
        retf

;-----------------------------------------------------------------------------
; AnnounceOneMinute                                           0EDC:02A6  94 PC
; Digital sound with speech on: pause, SayOneMinuteLeft.
;-----------------------------------------------------------------------------
AnnounceOneMinute:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:PlayPauseSample
        call 0x09B2:SayOneMinuteLeft
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AnnouncerBusy                                               0EDC:02C0  94 PC
; Digital sound with speech on and SpeechBusy.
;-----------------------------------------------------------------------------
AnnouncerBusy:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:SpeechBusy
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov ax, 0x1
        retf
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlaySoundEffect                                             0EDC:02E0  94 PC
; Sound effect by number; 7Dh raises the crowd; skipped while the announcer
; talks.
;-----------------------------------------------------------------------------
PlaySoundEffect:
        enter 0x18, 0x0
        push si
        mov si, [bp + 0x6]
        mov [lastsfx], si
        push cs
        call AnnouncerBusy
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        cmp si, 0x9c
        jz short .1
        jmp near .8
.1:
        cmp word [SoundOptions], 0x8
        jz short .2
        cmp word [SoundOptions], 0x4
        jnz short .3
.2:
        cmp si, 0xa0
        jz short .8
        cmp si, 0xa1
        jz short .8
.3:
        cmp si, 0x7d
        jnz short .4
        add word [CrowdSound], 0x1f4
        pop si
        leave
        retf
        db 0x90, 0x90, 0x90
.4:
        cmp word [SoundOptions], 0x4
        jnz short .5
        cmp si, 0xaa
        jnz short .5
        mov ax, [SfxBankOff]
        mov dx, [SfxBankSeg]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, [SfxBank2Off]
        mov dx, [SfxBank2Seg]
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        mov byte [bp - 0x7], 0xff
        mov byte [bp - 0x6], 0x3f
        mov word [bp - 0xc], 0x14
        mov byte [bp - 0x5], 0x0
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x16F2:StartSong
        add sp, 0x4
        pop si
        leave
        retf
.5:
        cmp si, 0x90
        jnz short .7
        cmp word [SoundOptions], 0x4
        jnz short .6
        push si
        call 0x16F2:PlaySound
        add sp, 0x2
.6:
        inc si
.7:
        push si
        call 0x16F2:PlaySound
        add sp, 0x2
.8:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AnnounceGoal                                                0EDC:0394  94 PC
; Pause, SayGoal.
;-----------------------------------------------------------------------------
AnnounceGoal:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:PlayPauseSample
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x09B2:SayGoal
.1:
        leave
        retf

;-----------------------------------------------------------------------------
; AnnouncePlayerFrom                                          0EDC:03C0  94 PC
; Pause, SayPlayerFrom.
;-----------------------------------------------------------------------------
AnnouncePlayerFrom:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:PlayPauseSample
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x09B2:SayPlayerFrom
.1:
        leave
        retf

;-----------------------------------------------------------------------------
; AnnouncePenalty                                             0EDC:03E6  94 PC
; Pause, SayPenalty.
;-----------------------------------------------------------------------------
AnnouncePenalty:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:PlayPauseSample
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x09B2:SayPenalty
.1:
        leave
        retf

;-----------------------------------------------------------------------------
; AnnounceTonightsGame                                        0EDC:0418  94 PC
; Team names from TeamAbbrevs, SayTonightsGame.
;-----------------------------------------------------------------------------
AnnounceTonightsGame:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov [bp - 0x2], di
        cmp di, 0x18
        jl short .1
        mov word [bp - 0x2], 0x9
.1:
        cmp di, 0x18
        jl short .2
        inc di
        inc di
.2:
        mov si, [bp + 0x8]
        cmp si, 0x18
        jl short .3
        inc si
        inc si
.3:
        cmp word [SoundOptions], 0x2
        jnz short .4
        test byte [AnnouncerFlags], 0x1
        jz short .4
        shl di, 1
        push word [di + TeamNameClips]
        shl si, 1
        push word [si + TeamNameClips]
        mov bx, [bp - 0x2]
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x09B2:SayTonightsGame
        add sp, 0x6
.4:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; AnnouncePeriodSummary                                       0EDC:046E  94 PC
; SayPeriodSummary.
;-----------------------------------------------------------------------------
AnnouncePeriodSummary:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x09B2:SayPeriodSummary
.1:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AnnounceIntro                                               0EDC:0490  94 PC
; SayEaNhlIntro.
;-----------------------------------------------------------------------------
AnnounceIntro:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:SayEaNhlIntro
.1:
        retf

;-----------------------------------------------------------------------------
; AnnounceGoodnight                                           0EDC:04A4  94 PC
; SayGoodnight.
;-----------------------------------------------------------------------------
AnnounceGoodnight:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:SayGoodnight
.1:
        retf

;-----------------------------------------------------------------------------
; AnnounceLineups                                             0EDC:04B8  94 PC
; SayLineups.
;-----------------------------------------------------------------------------
AnnounceLineups:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:SayLineups
.1:
        retf

;-----------------------------------------------------------------------------
; AnnounceElseAroundNhl                                       0EDC:04CC  94 PC
; SayElseAroundNhl.
;-----------------------------------------------------------------------------
AnnounceElseAroundNhl:
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        call 0x09B2:SayElseAroundNhl
.1:
        retf

;-----------------------------------------------------------------------------
; AnnounceHighlightMatchup                                    0EDC:04E0  94 PC
; SayHighlightMatchup.
;-----------------------------------------------------------------------------
AnnounceHighlightMatchup:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        mov si, [bp + 0x6]
        shl si, 1
        push word [si + TeamNameClips]
        mov bx, [bp + 0x8]
        shl bx, 1
        push word [bx + TeamNameClips]
        push word [si + TeamNameClips]
        call 0x09B2:SayHighlightMatchup
        add sp, 0x6
.1:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AnnouncePlayoffResult                                       0EDC:0514  94 PC
; SayPlayoffResult.
;-----------------------------------------------------------------------------
AnnouncePlayoffResult:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        mov bx, [bp + 0x6]
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x09B2:SayPlayoffResult
.1:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AnnounceTonightsPlayoffGame                                 0EDC:0542  94 PC
; SayTonightsPlayoffGame.
;-----------------------------------------------------------------------------
AnnounceTonightsPlayoffGame:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        cmp word [SoundOptions], 0x2
        jnz short .1
        test byte [AnnouncerFlags], 0x1
        jz short .1
        mov si, [bp + 0x6]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        shl si, 1
        push word [si + TeamNameClips]
        mov bx, [bp + 0x8]
        shl bx, 1
        push word [bx + TeamNameClips]
        push word [si + TeamNameClips]
        call 0x09B2:SayTonightsPlayoffGame
        add sp, 0xc
.1:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; LoadStudioSpeech                                            0EDC:057E  94 PC
; OpenStudioSpeech until it succeeds.
;-----------------------------------------------------------------------------
LoadStudioSpeech:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [SoundOptions], 0x2
        jnz short .2
.1:
        call 0x09B2:OpenStudioSpeech
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
.2:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadPlayByPlaySpeech                                        0EDC:0594  94 PC
; OpenPlayByPlaySpeech until it succeeds.
;-----------------------------------------------------------------------------
LoadPlayByPlaySpeech:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        cmp word [SoundOptions], 0x2
        jnz short .2
        mov si, [bp + 0x6]
        mov di, [bp + 0x8]
.1:
        push di
        push si
        call 0x09B2:OpenPlayByPlaySpeech
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
.2:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; StopJingle                                                  0EDC:05B8  94 PC
; Stops the digital sample playing in JingleHandle.
;-----------------------------------------------------------------------------
StopJingle:
        cmp word [JingleHandle], -0x1
        jnz short .1
        cmp word [JingleHandleHi], -0x1
        jz short .2
.1:
        push word [JingleHandleHi]
        push word [JingleHandle]
        call 0x16F2:SongFinished
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        push word [JingleHandleHi]
        push word [JingleHandle]
        call 0x16F2:StopSong
        add sp, 0x4
        mov word [JingleHandle], 0xffff
        mov word [JingleHandleHi], 0xffff
.2:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayJingle                                                  0EDC:05F8  94 PC
; Plays a digital sample (pointer, length) and keeps its handle.
;-----------------------------------------------------------------------------
PlayJingle:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push cs
        call StopJingle
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [JingleSongOff], ax
        mov [JingleSongSeg], dx
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        mov [JingleBufOff], ax
        mov [JingleBufSeg], dx
        mov byte [JingleChannel], 0xff
        mov byte [JingleVolume], 0x3f
        mov word [JingleTempo], 0x14
        mov byte [JinglePan], 0x0
        push ds
        push word ArenaJingleArg1
        call 0x16F2:StartSong
        mov [JingleHandle], ax
        mov [JingleHandleHi], dx
        leave
        retf

;-----------------------------------------------------------------------------
; WaitJingle                                                  0EDC:0640  94 PC
; Waits until the jingle sample has finished.
;-----------------------------------------------------------------------------
WaitJingle:
        push word [JingleHandleHi]
        push word [JingleHandle]
        call 0x16F2:SongFinished
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short WaitJingle
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayArenaJingle                                             0EDC:0656  94 PC
; The loaded clip for the event, else a random one of three, through
; PlayJingle.
;-----------------------------------------------------------------------------
PlayArenaJingle:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        cmp si, 0x6
        jnl short .2
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        mov [bp - 0x2], bx
        mov ax, [bx + ArenaJingleCSeg]
        or ax, [bx + ArenaJingleC]
        jz short .1
        push word [bx + ArenaJingleDSeg]
        push word [bx + ArenaJingleD]
        push word [bx + ArenaJingleCSeg]
        push word [bx + ArenaJingleC]
        push cs
        call PlayJingle
        add sp, 0x8
        mov si, 0xc
        jmp short .2
        db 0x90
.1:
        call 0x0000:_rand
        and ah, 0x7f
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        add si, 0x6
.2:
        cmp si, 0x9
        jnl short .3
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        push word [bx + ArenaJingleBSeg]
        push word [bx + ArenaJingleB]
        push word [bx + ArenaJingleASeg]
        push word [bx + ArenaJingleA]
        jmp short .4
        db 0x90
.3:
        cmp si, 0xc
        jnl short PlayArenaJingleTail.done + 0x6E0
        shl si, byte 0x2
        push word [si + ArenaJingleArg2]
        push word [si + ArenaJingleArg1]
        push word [si + BoxSaveX]
        push word [si + ArenaJingleSet]
.4:
        push cs
        call PlayJingle
        db 0x83, 0xC4                           ; insn: add sp, 0x8: the last byte is in the next segment
