; Starts a highlight game (AI.OVL)
; The first bytes finish the last routine of setup_controllers.asm.
        call 0x03A3:HookKbd
        mov word [PadRepeatOn], 0x0
        retf

;-----------------------------------------------------------------------------
; StartHL2                                                   1FAA:000E  94 PC
; (home, vis, &hsc, &asc, period): the highlight game the INIT overlay runs after
; AnnounceHighlightMatchup.
;
; Takes 6 words of stack arguments. Calls GetPaletteFar, FadePalette, FlushGSumQueue,
; LoadGameTeamsThunk, LoadTeamPalette, LoadRinkTilesThunk, LoadScoreboardArtThunk, LoadRinkEndArtThunk
; and others.
;-----------------------------------------------------------------------------
StartHL2:
        enter 0xfc, 0x0
        push di
        push si
        mov ax, [gameover]
        mov [bp - 0x66], ax
        mov ax, [HomeTeamNum]
        mov [bp - 0xee], ax
        mov ax, [VisTeamNum]
        mov [bp - 0xec], ax
        mov ax, [hmtmgoalie]
        mov [bp - 0xea], ax
        mov ax, [awtmgoalie]
        mov [bp - 0xe8], ax
        mov ax, [cont1team]
        mov [bp - 0xe6], ax
        mov ax, [cont2team]
        mov [bp - 0xe4], ax
        mov ax, [curperiod]
        mov [bp - 0xe2], ax
        mov ax, [gsp]
        mov [bp - 0xe0], ax
        mov ax, [hmtmap]
        mov [bp - 0xde], ax
        mov ax, [awtmap]
        mov [bp - 0xdc], ax
        mov ax, [hmscore]
        mov [bp - 0xda], ax
        mov ax, [awscore]
        mov [bp - 0xd8], ax
        lea ax, [bp - 0xd6]
        mov [bp - 0xfa], ax
        mov word [bp - 0xf0], 0x0
        jmp short .4
.1:
        inc word [bp - 0xf2]
.2:
        cmp word [bp - 0xf2], 0x1c
        jnl short .3
        mov bx, [bp - 0xf4]
        add word [bp - 0xf4], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xfa]
        add word [bp - 0xfa], 0x2
        mov [bx], ax
        jmp short .1
        db 0x90
.3:
        inc word [bp - 0xf0]
.4:
        cmp word [bp - 0xf0], 0x2
        jnl short .5
        imul ax, [bp - 0xf0], word 0xd6
        add ax, 0xb3c6
        mov [bp - 0xf4], ax
        mov word [bp - 0xf2], 0x0
        jmp short .2
.5:
        mov ax, [CrowdState]
        mov [bp - 0xf8], ax
        lea di, [bp - 0x62]
        mov si, 0xae10
        mov ax, ss
        mov es, ax
        mov cx, 0x18
        rep movsw
        lea di, [bp - 0x30]
        mov si, 0xae40
        mov cx, 0x18
        rep movsw
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        call 0x2352:FlushGSumQueue
        and byte [CrowdState], 0xe4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [gameover], ax
        mov [g_D6C4], ax
        mov ax, [bp + 0x6]
        mov [HomeTeamNum], ax
        mov ax, [bp + 0x8]
        mov [VisTeamNum], ax
        push 0x2
        call 0x1B35:LoadGameTeamsThunk
        add sp, 0x2
        push word 0x3a0b
        push strict word TeamPalette768
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x1E64:LoadTeamPalette
        add sp, 0x8
        cmp word [HomeTeamNum], 0x18
        jl short .6
        mov ax, 0xe
        jmp short .7
.6:
        mov ax, [HomeTeamNum]
.7:
        push ax
        call 0x1B35:LoadRinkTilesThunk
        add sp, 0x2
        call 0x1B35:LoadScoreboardArtThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadPPVFilesThunk
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [awtmgoalie], ax
        mov [hmtmgoalie], ax
        call 0x2E42:restoreteams
        mov ax, 0xffff
        mov [c2playernum], ax
        mov [c1playernum], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [cont2team], ax
        mov [cont1team], ax
        mov ax, 0x78
        call 0x0C11:randomd0
        add ax, strict word 0x3c
        mov [gameclock], ax
        mov cx, 0x3c
        cwd
        idiv cx
        mov [hudclockmin], ax
        mov ax, [gameclock]
        cwd
        idiv cx
        mov [hudclocksec], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [clockticks], ax
        mov [hudclockhund], ax
        mov ax, [bp + 0xe]
        mov [curperiod], ax
        dec ax
        mov [gsp], ax
        mov bx, [bp + 0xa]
        mov ax, [bx]
        mov [hmscore], ax
        mov bx, [bp + 0xc]
        mov ax, [bx]
        mov [awscore], ax
        mov ax, 0x7
        call 0x0C11:randomd0
        mov cx, 0x4
        cwd
        idiv cx
        mov [hmtmline], dx
        mov ax, 0x7
        call 0x0C11:randomd0
        mov cx, 0x4
        cwd
        idiv cx
        mov [awtmline], dx
        call 0x0FEF:UseOffscreenCanvas
        push 0x0
        push word [curperiod]
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x2083:DrawHudPanel
        add sp, 0x8
        mov byte [gmode], 0x0
        mov byte [gmode], 0x10
        test byte [gsp], 0x1
        jz short .8
        mov byte [gmode], 0x12
.8:
        mov ax, [gmode2]
        mov [bp - 0x32], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [sflags3], ax
        mov [gmode2], ax
        mov [sflags], ax
        mov word [gmode2], 0x4
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [g_D62B], al
        mov [iflags], al
        mov ax, 0xffff
        mov [passplayer], ax
        mov [RefStep], ax
        mov [PenCntDwn], ax
        mov [penaltysc], ax
        mov [ovltimer], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [refsignal], ax
        mov [RefPen], ax
        mov [SortPending], ax
        cmp word [ovlseq], -0x1
        jz short .9
        push word [g_D62E]
        push word [g_D62C]
        call 0x06E1:FindUnlink
        add sp, 0x4
.9:
        mov ax, 0xffff
        mov [bannermsg], ax
        mov [ovlstep], ax
        mov [ovlseq], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bannertimer], ax
        mov [injurystop], ax
        mov ax, 0xc8
        call 0x0C11:randomd0
        add ax, strict word 0x64
        mov [CrowdSound], ax
        mov [Crowdlevel], ax
        mov ax, 0xffff
        mov [g_D61C], ax
        mov [g_D618], ax
        call 0x2E42:setupice
        call 0x2E42:SprSortVert
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [camy], ax
        mov [camx], ax
        mov [yleader], ax
        mov [yc1], ax
        mov [xc1], ax
        call 0x2E42:ResetBench
        push word 0xb362
        call 0x2E42:reenergizeteam
        add sp, 0x2
        push word 0xb362
        call 0x2E42:setpersonel
        add sp, 0x2
        push word 0xb362
        call 0x2E42:forcepldata
        add sp, 0x2
        mov ax, 0xffff
        mov [hmtmtouch3], ax
        mov [hmtmtouch2], ax
        mov [hmtmtouch1], ax
        push word 0xb438
        call 0x2E42:reenergizeteam
        add sp, 0x2
        push word 0xb438
        call 0x2E42:setpersonel
        add sp, 0x2
        push word 0xb438
        call 0x2E42:forcepldata
        add sp, 0x2
        mov ax, 0xffff
        mov [awtmtouch3], ax
        mov [awtmtouch2], ax
        mov [awtmtouch1], ax
        call 0x2E42:resetplstuff
        mov word [bp - 0xf6], 0xb50e
        mov word [bp - 0xf0], 0x0
        jmp short .12
        db 0x90
.10:
        mov ax, 0xa
.11:
        mov bx, [bp - 0xf2]
        shl bx, 1
        add ax, [bx + HL2Offsets2]
        mov bx, [bp - 0xf6]
        mov [bx + 0x6], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0xe], ax
        mov [bx + 0xc], ax
        mov si, [puckx]
        mov ax, [si]
        sub ax, [bx + 0x2]
        mov si, [pucky]
        mov dx, [si]
        sub dx, [bx + 0x6]
        call 0x0D5F:VectorToDir8
        mov bx, [bp - 0xf6]
        mov [bx + 0x36], ax
        inc word [bp - 0xf0]
        add word [bp - 0xf6], 0x80
.12:
        cmp word [bp - 0xf0], 0xc
        jnl short .14
        mov bx, [bp - 0xf6]
        mov al, [bx + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x6
        add ax, [bx + 0x1a]
        shl ax, 1
        mov [bp - 0xf2], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, 0x14
        call 0x0C11:randomd0
        shl si, 1
        add ax, [si + HL2Offsets]
        sub ax, strict word 0xa
        mov bx, [bp - 0xf6]
        mov [bx + 0x2], ax
        cmp word [bx + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xf0
        add ax, strict word 0x14
        call 0x0C11:randomd0
        mov bx, [bp - 0xf6]
        cmp word [bx + 0x1a], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x3B, 0xC8                           ; insn: cmp cx, ax
        jnz short .13
        jmp near .10
.13:
        mov ax, 0x4
        jmp near .11
        db 0x90
.14:
        mov word [pucktemp2], 0x78
        mov ax, 0x14
        call 0x0C11:randomd0
        sub ax, strict word 0xa
        mov [puckXpos2], ax
        mov ax, 0x14
        call 0x0C11:randomd0
        sub ax, strict word 0xa
        mov [puckYpos2], ax
        mov word [puckZpos2], 0x0
        mov ax, 0x7d0
        call 0x0C11:randomd0
        sub ax, 0x3e8
        mov [puckXvel], ax
        mov ax, 0x7d0
        call 0x0C11:randomd0
        sub ax, 0x3e8
        mov [puckYvel], ax
        mov word [puckframe], 0x18a
        mov word [puck_48], 0x0
        push 0x18
        push word 0xbc0e
        call 0x1E7E:assreplace
        add sp, 0x4
        mov word [doorframe], 0x189
        mov word [door_48], 0x0
        push 0x19
        push word 0xbc8e
        call 0x1E7E:assreplace
        add sp, 0x4
        mov word [refXpos2], 0xff88
        mov word [refYpos2], 0x0
        mov word [ref_36], 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [refYvel], ax
        mov [refXvel], ax
        push 0x1f
        mov ax, 0xbd0e
        mov [bp - 0xf6], ax
        push ax
        call 0x1E7E:assreplace
        add sp, 0x4
        call 0x2E42:DoGameFrame
        call 0x2E42:DoGameFrame
        call 0x2E42:SprSort
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x64], ax
        mov [hudhundaccum], ax
        mov [inputframes], ax
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov [PadRepeatOn], ax
        call 0x2C24:joyq_flush
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [exitgame], ax
        mov [gameover], ax
        mov word [fadeinpending], 0x1
        call 0x03A3:CallCountStep
        mov word [PadRepeatOn], 0x1
        mov word [framesync], 0x0
.15:
        cmp word [exitgame], 0x0
        jz short .16
        jmp near .24
.16:
        call 0x1E7E:ResetInputSampling
        mov [bp - 0xf2], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add [bp - 0x64], ax
        mov ax, [bp - 0x64]
        mov cx, 0xa
        cwd
        idiv cx
        mov [bp - 0xf2], ax
        mov ax, [bp - 0x64]
        cwd
        idiv cx
        mov [bp - 0x64], dx
        push word [bp - 0xf2]
        call 0x1E7E:RunGameFrames
        add sp, 0x2
        mov ax, [camx]
        add ax, strict word 0x20
        mov [viewscrollx], ax
        cmp ax, strict word 0x40
        jng short .17
        mov word [viewscrollx], 0x40
.17:
        cmp word [viewscrollx], 0x0
        jnl short .18
        mov word [viewscrollx], 0x0
.18:
        mov ax, 0xec
        sub ax, [camy]
        mov [g_D6CE], ax
        cmp ax, 0x1a8
        jng short .19
        mov word [g_D6CE], 0x1a8
.19:
        cmp word [g_D6CE], 0x0
        jnl short .20
        mov word [g_D6CE], 0x0
.20:
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
        call 0x2E42:DrawRinkOverlays
        add sp, 0x4
        cmp word [fadeinpending], 0x0
        jz short .21
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatOn], ax
        push ax
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
.21:
        push word [bp - 0xf2]
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
        jz short .22
        mov ax, [clockticks]
        or ax, [gameclock]
        jnz short .22
        imul ax, [hudclockmin], 0x3c
        add ax, [hudclocksec]
        imul ax, ax, 0x64
        add ax, [hudclockhund]
        mov [hudhundstep], ax
.22:
        call 0x2083:UpdateHudPanel
        cmp word [fadeinpending], 0x0
        jz short .23
        mov ax, [PadRepeatOn]
        mov [g_D46A], ax
        push 0x10
        push word 0x3a0b
        push strict word TeamPalette768
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatOn], ax
        push ax
        call 0x1E7E:FadePalette
        add sp, 0x8
        mov word [fadeinpending], 0x0
        mov ax, [g_D46A]
        mov [PadRepeatOn], ax
.23:
        cmp word [framesync], 0x0
        jz short .26
.24:
        mov word [PadRepeatOn], 0x0
        cmp word [ovlseq], -0x1
        jz short .25
        push word [g_D62E]
        push word [g_D62C]
        call 0x06E1:FindUnlink
        add sp, 0x4
.25:
        mov ax, 0xffff
        mov [bannermsg], ax
        mov [ovlstep], ax
        mov [ovlseq], ax
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        call 0x0EDC:CrowdFadeOut
        mov word [CrowdSound], 0x0
        cmp word [SoundOptions], 0x2
        jnz short .29
        call 0x09B2:PlayPauseSample
        jmp short .30
        db 0x90
.26:
        call 0x2C24:ReadJoy1
        test byte [regd1], 0x30
        jnz short .24
        call 0x2C24:ReadJoy2
        test byte [regd1], 0x10
        jz short .27
        jmp near .24
.27:
        test byte [regd1], 0x20
        jnz short .28
        jmp near .15
.28:
        jmp near .24
.29:
        call 0x16F2:ReleaseAllVoices
.30:
        call 0x0EDC:StopJingle
        mov word [exitgame], 0xffff
        mov ax, [bp - 0x66]
        mov [gameover], ax
        mov ax, [bp - 0xee]
        mov [HomeTeamNum], ax
        mov ax, [bp - 0xec]
        mov [VisTeamNum], ax
        mov ax, [bp - 0xea]
        mov [hmtmgoalie], ax
        mov ax, [bp - 0xe8]
        mov [awtmgoalie], ax
        mov ax, [bp - 0xe6]
        mov [cont1team], ax
        mov ax, [bp - 0xe4]
        mov [cont2team], ax
        mov ax, [bp - 0xe2]
        mov [curperiod], ax
        mov ax, [bp - 0xe0]
        mov [gsp], ax
        mov ax, [bp - 0xde]
        mov [hmtmap], ax
        mov ax, [bp - 0xdc]
        mov [awtmap], ax
        mov ax, [hmscore]
        mov bx, [bp + 0xa]
        mov [bx], ax
        mov ax, [awscore]
        mov bx, [bp + 0xc]
        mov [bx], ax
        mov ax, [bp - 0xda]
        mov [hmscore], ax
        mov ax, [bp - 0xd8]
        mov [awscore], ax
        lea ax, [bp - 0xd6]
        mov [bp - 0xfa], ax
        mov word [bp - 0xf0], 0x0
        jmp short .34
.31:
        inc word [bp - 0xf2]
.32:
        cmp word [bp - 0xf2], 0x1c
        jnl short .33
        mov bx, [bp - 0xfa]
        add word [bp - 0xfa], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xf4]
        add word [bp - 0xf4], 0x2
        mov [bx], ax
        jmp short .31
        db 0x90
.33:
        inc word [bp - 0xf0]
.34:
        cmp word [bp - 0xf0], 0x2
        jnl short .35
        imul ax, [bp - 0xf0], word 0xd6
        add ax, 0xb3c6
        mov [bp - 0xf4], ax
        mov word [bp - 0xf2], 0x0
        jmp short .32
.35:
        mov ax, [bp - 0xf8]
        mov [CrowdState], ax
        mov ax, 0xae10
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x62]
        push ds
        pop es
        mov cx, 0x18
        rep movsw
        mov ax, 0xae40
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x30]
        mov cx, 0x18
        rep movsw
        push 0x4
        call 0x1B35:LoadGameTeamsThunk
        add sp, 0x2
        call 0x2E42:Intermission
        mov byte [gmode], 0x0
        mov byte [gmode], 0x1
        test byte [gsp], 0x1
        jz short .36
        mov byte [gmode], 0x3
.36:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [sflags3], ax
        mov [gmode2], ax
        mov [sflags], ax
        mov ax, [bp - 0x32]
        mov [gmode2], ax
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov word [ovltimer], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [camx], ax
        mov [camy], ax
        push word 0x3a0b
        push strict word TeamPalette768
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x1E64:LoadTeamPalette
        add sp, 0x8
        call 0x1B35:FreePPVFilesThunk
        push word [g_C25E]
        push word [g_C25C]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_C25A]
        push word [g_C258]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [HomeTeamNum], 0x18
        jl short .37
        mov ax, 0x9
        jmp short .38
        db 0x90
.37:
        mov ax, [HomeTeamNum]
.38:
        push ax
        call 0x1B35:LoadRinkTilesThunk
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        call 0x1B35:LoadScoreboardArtThunk
        push 0x1
        push word [curperiod]
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x2083:DrawHudPanel
        add sp, 0x8
        push word [g_C25A]
        push word [g_C258]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [fadeinpending], 0x1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [lcrequestteam], ax
        mov [energywarnteam], ax
        mov [energywarn], ax
        mov [lcsel], ax
        mov [hudredraw], ax
        mov [lcboxon], ax
        mov [hudhundaccum], ax
        mov [refsignal], ax
        mov ax, 0xffff
        mov [lcactive], ax
        mov [lcgroup], ax
        mov [RefStep], ax
        push 0x1e
        push word 0xbd0e
        call 0x1E7E:assreplace
        add sp, 0x4
        call 0x327B:ClearPenaltyBuffer
        mov word [PenCntDwn], 0xffff
        call 0x2C24:joyq_flush
        cmp word [framesync], 0x0
        jz short StartHL2Tail + 0x8E0
        mov word [framesync], 0x0
        mov ax, 0xffff
        pop si
        pop di
        leave
