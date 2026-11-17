; Game loop: frame drawing, hot keys, palettes, the period and game flow (GAME.OVL)
; The first bytes finish the last routine of team_palette.asm.
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; IntermissionPC                                             1E7E:0004  94 PC
; Fades the palette out, stops the crowd and the sound, then runs the end-of-game screens.
;
; Calls GetPaletteFar, FadePalette, CrowdFadeOut, PlayPauseSample, ReleaseAllVoices, StopJingle,
; UseCharSeg, EndGameScreensThunk. Far routine (retf).
;-----------------------------------------------------------------------------
IntermissionPC:
        push word 0x3a0b
        push strict word f_3A0B_B352
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word f_3A0B_B352
        push 0x1
        push cs
        call FadePalette
        add sp, 0x8
        call 0x0EDC:CrowdFadeOut
        cmp word [SoundOptions], 0x2
        jnz short .1
        call 0x09B2:PlayPauseSample
        jmp short .2
        db 0x90
.1:
        call 0x16F2:ReleaseAllVoices
.2:
        call 0x0EDC:StopJingle
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x1B35:EndGameScreensThunk
        inc word [curperiod]
        retf

;-----------------------------------------------------------------------------
; DrawSpriteNumber                                           1E7E:0060  94 PC
; Draws digits as frame sprites.
;
; Takes 4 words of stack arguments. Calls DrawSpriteClipped. Far routine (retf).
;-----------------------------------------------------------------------------
DrawSpriteNumber:
        enter 0x2, 0x0
        push di
        push si
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov si, 0x18
        sub si, [g_B096]
        shl si, byte 0x3
        add si, [bp + 0x6]
        mov di, 0x14d
        mov ax, [g_B098]
        shl ax, byte 0x3
        db 0x2B, 0xF8                           ; insn: sub di, ax
        sub di, [bp + 0x8]
        cmp word [bp + 0xc], 0x0
        jng short .1
        sub si, 0x4
.1:
        cmp word [bp + 0xc], 0x0
        jl short .2
        inc di
        inc di
.2:
        cmp word [bp + 0xa], 0xa
        jl short .3
        push 0x0
        push 0x0
        push 0x0
        push di
        sub si, 0x3
        push si
        mov ax, [bp + 0xa]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + g_D6DA]
        push word [bx + g_D6D8]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
        lea si, [si + 0x7]
        mov ax, [bp + 0xa]
        mov cx, 0xa
        cwd
        idiv cx
        mov [bp - 0x2], dx
.3:
        push 0x0
        push 0x0
        push 0x0
        push di
        push si
        mov bx, [bp - 0x2]
        shl bx, byte 0x2
        push word [bx + g_D6DA]
        push word [bx + g_D6D8]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
        cmp word [bp + 0xc], 0x0
        jng short .4
        push 0x0
        push 0x0
        push 0x0
        push di
        lea ax, [si + 0x8]
        push ax
        mov bx, [bp + 0xc]
        shl bx, byte 0x2
        push word [bx + g_D702]
        push word [bx + g_D700]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawFrameSprite                                            1E7E:0120  94 PC
; Draws one frame sprite.
;
; Takes 5 words of stack arguments. Calls DrawSpriteClipped. Far routine (retf).
;-----------------------------------------------------------------------------
DrawFrameSprite:
        enter 0x4, 0x0
        push si
        mov si, [bp + 0x6]
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .1
        cmp si, 0x36c
        jnl short .1
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        mov ax, [bx + g_91D0]
        mov dx, [bx + g_91D2]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .1
        push 0x1
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov ax, 0x28
        sub ax, [g_B098]
        shl ax, byte 0x3
        sub ax, [bp + 0xa]
        push ax
        mov ax, 0x18
        sub ax, [g_B096]
        shl ax, byte 0x3
        add ax, [bp + 0x8]
        push ax
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
.1:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; DrawRinkEndArt                                             1E7E:017E  94 PC
; Rink end-board art.
;
; Calls DrawSpriteClipped. Far routine (retf).
;-----------------------------------------------------------------------------
DrawRinkEndArt:
        push 0x0
        push -0x1
        push 0x0
        mov ax, [g_B098]
        shl ax, byte 0x3
        sub ax, 0x225
        neg ax
        push ax
        mov ax, [g_B096]
        shl ax, byte 0x3
        sub ax, strict word 0x22
        neg ax
        push ax
        push word [g_D71E]
        push word [g_D71C]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
        retf
        db 0x90

;-----------------------------------------------------------------------------
; WaitKeyRelease                                             1E7E:01AE  94 PC
; Loops until no key is down.
;
; Takes 1 word of stack arguments. Calls KeyDown, KeyJump, FlushKeys. Far routine (retf).
;-----------------------------------------------------------------------------
WaitKeyRelease:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        push si
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
.1:
        call 0x03A3:KeyJump
        push si
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
.2:
        call 0x03A3:FlushKeys
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; HandleHotKey                                               1E7E:01DC  94 PC
; Jump table on in-game hot keys.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, FadePalette, CrowdFadeOut, PlayPauseSample,
; ReleaseAllVoices, StopSpeech, StopJingle, InputInit and others. Far routine (retf).
;-----------------------------------------------------------------------------
HandleHotKey:
        enter 0x2, 0x0
        test byte [bp + 0x6], 0x80
        jnz short .1
        jmp near HandleHotKeyJumpTable.23
.1:
        and byte [bp + 0x6], 0x7f
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x2], ax
        cmp ax, strict word 0x44
        jnz short .2
        jmp near HandleHotKeyJumpTable.21
.2:
        jna short .3
        jmp near HandleHotKeyJumpTable.23
.3:
        cmp al, 0x1f
        jnz short .4
        jmp near HandleHotKeyJumpTable.12
.4:
        jg short .5
        dec al
        jz short HandleHotKeyJumpTable.1
        sub al, 0xe
        jz short HandleHotKeyJumpTable.2
        sub al, 0x4
        jz short HandleHotKeyJumpTable.3
        jmp near HandleHotKeyJumpTable.23
.5:
        sub al, 0x32
        cmp ax, strict word 0x11
        jna short .6
        jmp near HandleHotKeyJumpTable.23
.6:
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x22c]
HandleHotKeyJumpTable:                          ; jump table of HandleHotKey: 18 case targets
        dw .16
        dw .23
        dw .23
        dw .23
        dw .23
        dw .23
        dw .23
        dw .23
        dw .23
        dw .18
        dw .18
        dw .18
        dw .18
        dw .19
        dw .19
        dw .19
        dw .19
        dw .20
.1:
        mov ax, 0x1
        mov [g_4B02], ax
        leave
        retf
.2:
        cmp word [shownumbers], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        mov [shownumbers], ax
        jmp near .23
        db 0x90
.3:
        test byte [gmode], 0x10
        jz short .4
        jmp near .23
.4:
        cmp word [curperiod], -0x1
        jnz short .5
        jmp near .23
.5:
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        mov word [PadRepeatOn], 0x0
        cmp byte [PadStates], 0x1
        jz short .6
        cmp byte [PadStates2], 0x1
        jnz short .7
.6:
        mov ax, [MouseX]
        mov [g_D60E], ax
        mov ax, [MouseY]
        mov [g_D610], ax
.7:
        push word 0x3a0b
        push strict word f_3A0B_B352
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word f_3A0B_B352
        push 0x1
        push cs
        call FadePalette
        add sp, 0x8
        call 0x0EDC:CrowdFadeOut
        cmp word [SoundOptions], 0x2
        jnz short .8
        call 0x09B2:PlayPauseSample
        jmp short .9
        db 0x90
.8:
        call 0x16F2:ReleaseAllVoices
.9:
        call 0x09B2:StopSpeech
        call 0x0EDC:StopJingle
        call 0x0BFE:InputInit
        push 0x1
        call 0x1B35:InstantReplayThunk
        add sp, 0x2
        call 0x0F99:FlushInputEvents
        call 0x0BFE:InputShutdown
        cmp byte [PadStates], 0x1
        jz short .10
        cmp byte [PadStates2], 0x1
        jnz short .11
.10:
        push word [g_D610]
        push word [g_D60E]
        call 0x03A3:MouseMove
        add sp, 0x4
.11:
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
        mov ax, 0x1
        leave
        retf
        db 0x90
.12:
        test byte [CrowdState], 0x80
        jz short .15
        call 0x0EDC:CrowdNoiseOff
        cmp word [SoundOptions], 0x2
        jnz short .13
        call 0x09B2:PlayPauseSample
        jmp short .14
.13:
        call 0x16F2:ReleaseAllVoices
.14:
        call 0x16F2:SfxOff
.15:
        mov al, [CrowdState]
        and ax, 0x80
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        shl al, byte 0x7
        xor al, [CrowdState]
        and ax, 0x80
        xor [CrowdState], ax
        test byte [CrowdState], 0x80
        jz short .23
        call 0x0EDC:CrowdReset
        call 0x16F2:SfxOn
        jmp short .23
.16:
        mov al, [CrowdState]
        and ax, strict word 0x40
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        shl al, byte 0x6
        xor al, [CrowdState]
        and ax, strict word 0x40
        xor [CrowdState], ax
        test byte [CrowdState], 0x40
        jz short .17
        call 0x16F2:MusicOn
        jmp short .23
        db 0x90
.17:
        call 0x0EDC:StopJingle
        call 0x16F2:MusicOff
        jmp short .23
.18:
        mov word [g_D46C], 0x1
        mov ax, [bp - 0x2]
        sub ax, strict word 0x3b
        mov [lcline], ax
        jmp short .23
        db 0x90
.19:
        mov word [g_D46E], 0x1
        mov ax, [bp - 0x2]
        sub ax, strict word 0x3f
        mov [lctimer], ax
        jmp short .23
        db 0x90
.20:
        push 0x0
        jmp short .22
.21:
        push 0x1
.22:
        call 0x1B35:ShowGoalieBannerThunk
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetInputSampling                                         1E7E:03E8  94 PC
; Clears input sample counters.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ResetInputSampling:
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        mov dx, [PadTickCount]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatOn], ax
        mov [PadTickCount], ax
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RunGameFrames                                              1E7E:0404  94 PC
; Runs pending game ticks.
;
; Takes 1 word of stack arguments. Calls joyq_peekThunk, HandleHotKey, ClockTickThunk,
; DoGameFrameThunk, joyq_popThunk, joyq_flushThunk. Far routine (retf).
;-----------------------------------------------------------------------------
RunGameFrames:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .7
.1:
        cmp word [inputframes], 0x0
        jnz short .3
        call 0x1B35:joyq_peekThunk
        mov [joyrec], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + 0x2]
        test al, 0x80
        jz short .2
        push ax
        push cs
        call HandleHotKey
        add sp, 0x2
        dec ax
        jz short .6
.2:
        mov word [inputframes], 0x3
.3:
        test byte [gmode], 0x1
        jnz short .4
        add word [hudhundaccum], 0x64
        call 0x1B35:ClockTickThunk
.4:
        call 0x1B35:DoGameFrameThunk
        dec word [inputframes]
        jnz short .5
        call 0x1B35:joyq_popThunk
.5:
        cmp word [deferpending], 0x0
        jnz short .7
        cmp word [exitgame], 0x0
        jnz short .7
        cmp word [gameover], 0x0
        jnz short .7
        inc si
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jl short .1
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        call 0x1B35:joyq_flushThunk
.7:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetFullPalette                                             1E7E:048A  94 PC
; Sends the 256-colour palette.
;
; Takes 2 words of stack arguments. Calls WaitRetrace, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
SetFullPalette:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xF7                           ; insn: mov si, di
.1:
        call 0x0FEF:WaitRetrace
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC7                           ; insn: add ax, di
        push dx
        push ax
        push word 0x80
        push si
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        add di, 0x180
        add si, 0x80
        cmp si, 0x100
        jl short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; FadePalette                                                1E7E:04C0  94 PC
; Steps the palette toward a target.
;
; Takes 4 words of stack arguments. Calls SetFullPalette. Far routine (retf).
;-----------------------------------------------------------------------------
FadePalette:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0xc]
        cmp di, 0x2
        jnl short .4
        cmp word [bp + 0x6], 0x0
        jnz short .2
        push word [bp + 0xa]
        push word [bp + 0x8]
.1:
        push cs
        call SetFullPalette
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov ax, 0x387f
        mov ds, ax
.3:
        db 0xC6, 0x87, 0x00, 0x00, 0x00         ; insn: mov byte [bx + 0x0], 0x0
        inc bx
        cmp bx, 0x300
        jl short .3
        mov ax, DGROUP
        mov ds, ax
        push word 0x387f
        push strict word 0x0
        jmp short .1
.4:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xCF                           ; insn: mov cx, di
        dec al
        mov [g_4B0B], al
        inc cl
        mov [g_4B0E], cl
        mov si, [bp + 0x6]
        mov al, [si + g_4B0A]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov al, [si + g_4B0E]
        cbw
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jz short .7
        mov [bp - 0x2], dx
.5:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0xc]
        mov ax, 0x387f
        mov ds, ax
        mov es, [bp + 0xa]
.6:
        mov bx, [bp + 0x8]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        cbw
        imul word [bp - 0x2]
        cwd
        idiv di
        db 0x88, 0x84, 0x00, 0x00               ; insn: mov [si + 0x0], al
        inc si
        cmp si, 0x300
        jl short .6
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        push word 0x387f
        push strict word 0x0
        push cs
        call SetFullPalette
        add sp, 0x4
        mov al, [si + g_4B0C]
        cbw
        add [bp - 0x2], ax
        mov al, [si + g_4B0E]
        cbw
        cmp [bp - 0x2], ax
        jnz short .5
.7:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Gameloop                                                   1E7E:057E  94 PC
; Main game loop.
;
; Calls CallCountStep, ResetInputSampling, RunGameFrames, FlushDirtyRects, UseOtherPage,
; DrawRinkOverlaysThunk, GetPaletteFar, FadePalette and others. Far routine (retf).
;-----------------------------------------------------------------------------
Gameloop:
        push si
        call 0x03A3:CallCountStep
        jmp near .25
        db 0x90
.1:
        cmp word [exitgame], 0x0
        jz short .2
        jmp near .20
.2:
        push cs
        call ResetInputSampling
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl ax, 1
        db 0x03, 0xC6                           ; insn: add ax, si
        shl ax, 1
        add [frameaccum], ax
        mov ax, [frameaccum]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [frameaccum]
        cwd
        idiv cx
        mov [frameaccum], dx
        push si
        push cs
        call RunGameFrames
        add sp, 0x2
        mov ax, [camx]
        add ax, strict word 0x20
        mov [viewscrollx], ax
        cmp ax, strict word 0x40
        jng short .3
        mov word [viewscrollx], 0x40
.3:
        cmp word [viewscrollx], 0x0
        jnl short .4
        mov word [viewscrollx], 0x0
.4:
        mov ax, 0xec
        sub ax, [camy]
        mov [g_D6CE], ax
        cmp ax, 0x1a8
        jng short .5
        mov word [g_D6CE], 0x1a8
.5:
        cmp word [g_D6CE], 0x0
        jnl short .6
        mov word [g_D6CE], 0x0
.6:
        push word [g_D6CE]
        push word [viewscrollx]
        call 0x1F54:FlushDirtyRects
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        mov ax, 0x140
        sub ax, [g_D6CE]
        push ax
        mov ax, [viewscrollx]
        sub ax, 0xc0
        push ax
        call 0x1B35:DrawRinkOverlaysThunk
        add sp, 0x4
        cmp word [fadeinpending], 0x0
        jz short .7
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        push word 0x3a0b
        push strict word f_3A0B_B352
        push word 0x100
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatOn], ax
        push ax
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word f_3A0B_B352
        push 0x1
        push cs
        call FadePalette
        add sp, 0x8
        call 0x1B35:FlushGSumQueueThunk
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
.7:
        push si
        call 0x0EDC:CrowdNoiseUpdate
        add sp, 0x2
        call 0x0000:VgaPageFlip
        mov ax, [hudhundaccum]
        mov cx, 0x18
        cwd
        idiv cx
        mov [hudhundstep], ax
        mov ax, [hudhundaccum]
        cwd
        idiv cx
        mov [hudhundaccum], dx
        cmp word [exitgame], 0x0
        jz short .8
        mov ax, [clockticks]
        or ax, [gameclock]
        jnz short .8
        imul ax, [hudclockmin], 0x3c
        add ax, [hudclocksec]
        imul ax, ax, 0x64
        add ax, [hudclockhund]
        mov [hudhundstep], ax
.8:
        call 0x1B35:UpdateHudPanelThunk
        cmp word [fadeinpending], 0x0
        jz short .9
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        push 0x10
        push word 0x3a0b
        push strict word f_3A0B_0A8E
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatOn], ax
        push ax
        push cs
        call FadePalette
        add sp, 0x8
        mov word [fadeinpending], 0x0
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
.9:
        cmp word [g_4B02], 0x0
        jnz short .10
        jmp near .18
.10:
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        mov word [PadRepeatOn], 0x0
        cmp byte [PadStates], 0x1
        jz short .11
        cmp byte [PadStates2], 0x1
        jnz short .12
.11:
        mov ax, [MouseX]
        mov [g_D60E], ax
        mov ax, [MouseY]
        mov [g_D610], ax
.12:
        call 0x0EDC:CrowdFadeOut
        cmp word [SoundOptions], 0x2
        jnz short .13
        call 0x09B2:PlayPauseSample
        jmp short .14
        db 0x90
.13:
        call 0x16F2:ReleaseAllVoices
.14:
        call 0x0EDC:StopJingle
        call 0x09B2:StopSpeech
        call 0x1B35:FlushGSumQueueThunk
        call 0x1B35:PutGSumTailThunk
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x0
        call 0x1B35:SportsDeskThunk
        add sp, 0x2
        mov es, [g_8C8A]
        cmp word [es:0x126], 0x2
        jnz short .15
        jmp near .27
.15:
        cmp byte [PadStates], 0x1
        jz short .16
        cmp byte [PadStates2], 0x1
        jnz short .17
.16:
        push word [g_D610]
        push word [g_D60E]
        call 0x03A3:MouseMove
        add sp, 0x4
.17:
        mov word [fadeinpending], 0x1
        mov word [g_4B02], 0x0
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
        call 0x1B35:joyq_flushThunk
.18:
        cmp word [deferpending], 0x0
        jz short .19
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        mov word [PadRepeatOn], 0x0
        call 0x1B35:RunDeferredCallsThunk
        mov word [deferpending], 0x0
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
        call 0x1B35:joyq_flushThunk
.19:
        cmp word [exitgame], 0x0
        jnz short .20
        jmp near .2
.20:
        mov word [PadRepeatOn], 0x0
        call 0x1B35:PeriodOverThunk
        mov es, [g_8C8A]
        cmp word [es:0x126], 0x2
        jnz short .21
        jmp near .27
.21:
        cmp word [gameover], 0x0
        jnz short .22
        call 0x0FEF:UseOffscreenCanvas
        push 0x1
        push word [curperiod]
        push word [g_29CC]
        push word [g_29CA]
        call 0x1B35:DrawHudPanelThunk
        add sp, 0x8
        push 0x0
        call 0x0EDC:PlayArenaJingle
        add sp, 0x2
.22:
        cmp byte [PadStates], 0x1
        jz short .23
        cmp byte [PadStates2], 0x1
        jnz short .24
.23:
        push 0x64
        push word 0xa0
        call 0x03A3:MouseMove
        add sp, 0x4
.24:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_D46E], ax
        mov [g_D46C], ax
        mov [deferpending], ax
        mov [inputframes], ax
        mov [exitgame], ax
        mov [frameaccum], ax
        mov [hudhundaccum], ax
        call 0x1B35:joyq_flushThunk
.25:
        mov word [PadRepeatOn], 0x1
        cmp word [gameover], 0x0
        jnz short .26
        jmp near .1
.26:
        mov word [PadRepeatOn], 0x0
        call 0x1B35:FlushGSumQueueThunk
        call 0x1B35:StartThreeStarsThunk
        call 0x1B35:IntermissionScreensThunk
        mov es, [g_8C8A]
        mov word [es:0x126], 0x1
.27:
        call 0x1B35:FreeGameMemoryThunk
        pop si
        retf

;-----------------------------------------------------------------------------
; PlayGame                                                   1E7E:088A  94 PC
; Sets up and runs one game.
;
; Takes 1 word of stack arguments. Calls LoadRinkTilesThunk, LoadTeamPalette, LoadArenaJinglesThunk,
; LoadGameGfxThunk, LoadCupFinalSeries, LoadGameStateThunk, CloseHandlePtr, LoadPlayByPlaySpeech and
; others. Far routine (retf).
;-----------------------------------------------------------------------------
PlayGame:
        enter 0x20, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        cmp word [si], 0x0
        jnl short .3
        cmp word [g_29CA], 0x18
        jl short .1
        mov cx, 0x9
        jmp short .2
.1:
        mov cx, [g_29CA]
.2:
        push cx
        call 0x1B35:LoadRinkTilesThunk
        add sp, 0x2
        push word 0x3a0b
        push strict word f_3A0B_0A8E
        push word [g_29CC]
        push word [g_29CA]
        call 0x1E64:LoadTeamPalette
        add sp, 0x8
        call 0x1B35:LoadArenaJinglesThunk
        call 0x1B35:LoadGameGfxThunk
.3:
        cmp word [si], 0x0
        jnl short .4
        jmp near .8
.4:
        test byte [AnnouncerFlags], 0x2
        jnz short .5
        call 0x1E45:LoadCupFinalSeries
.5:
        push word [si]
        call 0x1B35:LoadGameStateThunk
        add sp, 0x2
        push si
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov word [si], 0xffff
        mov bx, [g_29CC]
        shl bx, 1
        push word [bx + TeamNameClips]
        mov bx, [g_29CA]
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0EDC:LoadPlayByPlaySpeech
        add sp, 0x4
        call 0x1B35:BuildDefaultLinesThunk
        call 0x1B35:NormalizeDressFlagsThunk
        push 0x0
        call 0x1B35:SetupTeamLinesThunk
        add sp, 0x2
        push 0x1
        call 0x1B35:SetupTeamLinesThunk
        add sp, 0x2
        call 0x1B35:GSummaryPathThunk
        call 0x0EDC:CrowdReset
        call 0x1B35:SetTeamNameTextThunk
        cmp word [exitgame], -0x1
        jz short .10
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov es, [g_8C8A]
        mov [es:0x126], ax
        push ax
        call 0x1B35:SportsDeskThunk
        add sp, 0x2
        mov es, [g_8C8A]
        cmp word [es:0x126], 0x2
        jnz short .6
        call 0x1B35:FreeGameMemoryThunk
        pop si
        pop di
        leave
        retf
.6:
        cmp byte [PadStates], 0x1
        jz short .7
        cmp byte [PadStates2], 0x1
        jnz short .10
.7:
        push word [g_D610]
        push word [g_D60E]
        call 0x03A3:MouseMove
        add sp, 0x4
        jmp short .10
.8:
        call 0x1B35:SetupGameThunk
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .9
        mov es, [g_8C8A]
        mov word [es:0x126], 0x2
        call 0x1B35:FreeGameMemoryThunk
        mov ax, 0xffff
        pop si
        pop di
        leave
        retf
.9:
        call 0x1B35:SetTeamNameTextThunk
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [introskipped], ax
        mov es, [g_8C8A]
        mov [es:0x126], ax
        call 0x1B35:joyq_flushThunk
        push cs
        call Gameloop
        call 0x1B35:ClearTeamNameTextThunk
        cmp word [DbSaveMode], 0x0
        jz short .11
        mov es, [g_8C8A]
        cmp word [es:0x126], 0x1
        jnz short .11
        and byte [AnnouncerFlags], 0x7f
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, 0x4b10
        lea si, [bp - 0x20]
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        mov di, str_GameSav_2
        lea si, [bp - 0x20]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
.11:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assreplace                                                 1E7E:0A5C  94 PC
; Replaces the current assignment.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
assreplace:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov al, [bp + 0x8]
        mov bx, [si + 0x1c]
        mov [bx + si + 0x1e], al
        or byte [si + 0x44], 0x2
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assinsert                                                  1E7E:0A74  94 PC
; Pushes an assignment.
;
; Takes 2 words of stack arguments. Calls assreplace. Far routine (retf).
;-----------------------------------------------------------------------------
assinsert:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov al, [si + 0x1c]
        dec al
        and ax, strict word 0x7
        mov [si + 0x1c], ax
        push word [bp + 0x8]
        push si
        push cs
        call assreplace
        add sp, 0x4
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ReplayIsEmpty                                              1E7E:0A94  94 PC
; Replay buffer has no frames.
;-----------------------------------------------------------------------------
ReplayIsEmpty:
        mov ax, [g_D014]
        mov dx, [g_D016]
        cmp [g_2986], ax
        jnz short ReturnZeroFar + 0xAB0
        cmp [g_2988], dx
        jnz short ReturnZeroFar + 0xAB0
        test byte [sflags], 0x10
        jnz short ReturnZeroFar + 0xAB0
        mov ax, 0x1
