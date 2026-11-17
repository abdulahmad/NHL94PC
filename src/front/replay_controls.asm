; Instant replay screen and its controls (INIT.OVL)
; The first bytes and FreePlayerFramesTail finish FreePlayerFrames from free_game.asm.
        mov [si + 0x2], ax
        mov [si], ax
FreePlayerFramesTail:
        sub si, 0x4
        dec di
        jns short FreePlayerFrames.1 - 0x150
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; InstantReplay                                              2581:000E  94 PC
; Replay screen.
;
; Takes 1 word of stack arguments. Calls MouseRange, MouseMove, GetPaletteFar, FadePalette,
; VgaCopyBlock, UseOffscreenCanvas, DrawLine, UseCurrentPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
InstantReplay:
        enter 0xc, 0x0
        cmp word [DbSaveMode], 0x0
        jz short .1
        cmp word [ctl1team], 0x0
        jnl short .2
        cmp word [ctl2team], 0x0
        jnl short .2
.1:
        mov word [replaysaved], 0x1
        jmp short .3
        db 0x90
.2:
        mov word [replaysaved], 0x0
.3:
        mov word [replaybutton], 0x44
        mov word [replaystep], 0x8
        mov word [replaymousex], 0x118
        mov word [replaymousey], 0xb6
        push word 0xbb
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [replaymousey]
        push word [replaymousex]
        call 0x03A3:MouseMove
        add sp, 0x4
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
        cmp word [bp + 0x6], 0x0
        jz short .4
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
.4:
        push 0x0
        push word 0xc8a0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push 0x0
        push 0x1e
        push word 0x140
        push 0x1e
        push 0x0
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x0
        push 0x1f
        push word 0x140
        push 0x1f
        push 0x0
        call 0x0FEF:DrawLine
        add sp, 0xa
        call 0x0FEF:UseCurrentPage
        push 0x12
        push 0x5
        push word 0xaa0
        push word 0x470
        call 0x0000:VgaCopyFromPitch
        add sp, 0x8
        push word [ReplayPanels]
        push word [ReplayPanelSeg]
        push word [ReplayGadgetRect2]
        push word [ReplayPanel]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
        push word [ReplayPointers]
        push word [ReplayPointerSeg]
        push word [ReplayGadgetRect3]
        push word [ReplayPointer]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
        cmp word [replaysaved], 0x0
        jz short .5
        push word [ReplayBack2]
        push word [ReplayBackSeg]
        push word [ReplayPointerRect]
        push word [ReplayBack]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
.5:
        call 0x0FEF:UseOffscreenCanvas
        push 0x1e
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        mov ax, [replaymousey]
        sub ax, 0xa8
        push ax
        push word [replaymousex]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x1
        mov [DeskRedrawPage2], ax
        mov [DeskRedrawPage], ax
        mov ax, [camx]
        mov [bp - 0x8], ax
        mov ax, [camy]
        mov [bp - 0x6], ax
        mov ax, [viewscrollx]
        mov [bp - 0x2], ax
        mov ax, [ovltimer2]
        mov [bp - 0x4], ax
        mov ax, [CrowdSound]
        mov [bp - 0xa], ax
        mov ax, 0xffff
        mov [replaymode], ax
        mov [replayfollow], ax
        mov [replayfollow2], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [replayplaying], ax
        mov [replayfwd], ax
        mov [replaydx], ax
        call 0x1B35:ReplayFirstFrameThunk
        mov [replayplay], ax
        mov [replayplayseg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xc], ax
        push ax
        push ax
        call 0x26D2:ReplayStep
        add sp, 0x4
        mov ax, [CrowdSound]
        mov [Crowdlevel], ax
        mov ax, [camx]
        add ax, strict word 0x20
        mov [viewscrollx], ax
        cmp ax, strict word 0x40
        jng short .6
        mov word [viewscrollx], 0x40
.6:
        cmp word [viewscrollx], 0x0
        jnl short .7
        mov word [viewscrollx], 0x0
.7:
        mov ax, 0xec
        sub ax, [camy]
        mov [ovltimer2], ax
        cmp ax, 0x1a8
        jng short .8
        mov word [ovltimer2], 0x1a8
.8:
        cmp word [ovltimer2], 0x0
        jnl short .9
        mov word [ovltimer2], 0x0
.9:
        push word [ovltimer2]
        push word [viewscrollx]
        call 0x1F54:FlushDirtyRects
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        mov ax, 0x140
        sub ax, [ovltimer2]
        push ax
        mov ax, [viewscrollx]
        sub ax, 0xc0
        push ax
        call 0x26D2:DrawReplayFrame
        add sp, 0x4
        call 0x0000:VgaPageFlip
        push 0x10
        push word 0x3a0b
        push strict word TeamPalette768
        push 0x0
        call 0x1E7E:FadePalette
        add sp, 0x8
        call 0x03A3:CallCountStep
        call 0x0F99:FlushInputEvents
        mov word [bp - 0xc], 0x0
        jmp near .30
        db 0x90
.10:
        mov ax, [bp - 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add [replaydx], ax
        mov ax, [replaydx]
        mov cx, 0x14
        cwd
        idiv cx
        mov [bp - 0xc], ax
        mov ax, [replaydx]
        cwd
        idiv cx
        mov [replaydx], dx
        mov al, [replaybutton]
        and al, 0x3f
        cmp al, 0x10
        jnz short .11
        mov ax, 0x1
        jmp short .12
        db 0x90
.11:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.12:
        push ax
        push word [bp - 0xc]
        call 0x26D2:ReplayStep
        add sp, 0x4
        mov [bp - 0xc], ax
        cmp word [replayplaying], 0x0
        jz short .17
        mov ax, [replayend]
        mov [camy], ax
        mov ax, [replaystart]
        mov [camx], ax
        cmp ax, strict word 0x20
        jng short .13
        mov word [camx], 0x20
        jmp short .14
        db 0x90
.13:
        cmp word [camx], -0x20
        jnl short .14
        mov word [camx], 0xffe0
.14:
        cmp word [camy], 0xec
        jng short .15
        mov word [camy], 0xec
        jmp short .16
        db 0x90
.15:
        cmp word [camy], 0xff44
        jnl short .16
        mov word [camy], 0xff44
.16:
        mov ax, [camx]
        mov [replaystart], ax
        mov ax, [camy]
        mov [replayend], ax
        jmp short .21
.17:
        cmp word [replaymode], 0x0
        jl short .21
        mov bx, [replaymode]
        shl bx, 1
        mov ax, [bx + rpl_x]
        mov [camx], ax
        mov cx, [bx + rpl_y]
        mov [camy], cx
        cmp ax, strict word 0x20
        jng short .18
        mov word [camx], 0x20
        jmp short .19
        db 0x90
.18:
        cmp ax, strict word 0xffe0
        jnl short .19
        mov word [camx], 0xffe0
.19:
        cmp word [camy], 0xec
        jng short .20
        mov word [camy], 0xec
        jmp short .21
        db 0x90
.20:
        cmp word [camy], 0xff44
        jnl short .21
        mov word [camy], 0xff44
.21:
        mov ax, [camx]
        add ax, strict word 0x20
        mov [viewscrollx], ax
        cmp ax, strict word 0x40
        jng short .22
        mov word [viewscrollx], 0x40
.22:
        cmp word [viewscrollx], 0x0
        jnl short .23
        mov word [viewscrollx], 0x0
.23:
        mov ax, 0xec
        sub ax, [camy]
        mov [ovltimer2], ax
        cmp ax, 0x1a8
        jng short .24
        mov word [ovltimer2], 0x1a8
.24:
        cmp word [ovltimer2], 0x0
        jnl short .25
        mov word [ovltimer2], 0x0
.25:
        push word [ovltimer2]
        push word [viewscrollx]
        call 0x1F54:FlushDirtyRects
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        mov ax, 0x140
        sub ax, [ovltimer2]
        push ax
        mov ax, [viewscrollx]
        sub ax, 0xc0
        push ax
        call 0x26D2:DrawReplayFrame
        add sp, 0x4
        cmp word [replaymousey], 0xa8
        jl short .26
        jmp near .29
.26:
        cmp word [replayfollow], -0x1
        jnz short .27
        mov word [replayfollow2], 0xffff
        mov ax, [replaymousex]
        add ax, [camx]
        sub ax, 0xa0
        mov [replayptrx], ax
        mov cx, [camy]
        sub cx, [replaymousey]
        add cx, 0x54
        mov [replaypick], cx
        push 0x0
        push 0x0
        inc cx
        push cx
        inc ax
        push ax
        push word 0x188
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        jmp short .29
.27:
        push 0x1
        push 0x0
        mov bx, [replayfollow]
        shl bx, 1
        mov ax, [bx + rpl_y]
        inc ax
        push ax
        mov ax, [bx + rpl_x]
        inc ax
        push ax
        push word 0x188
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        mov ax, [replayfollow]
        cmp [replayfollow2], ax
        jz short .29
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + rpl_x]
        sub ax, [camx]
        add ax, 0xa0
        mov [replaymousex], ax
        mov ax, [camy]
        sub ax, [bx + rpl_y]
        add ax, strict word 0x54
        mov [replaymousey], ax
        cmp ax, 0xa7
        jng short .28
        mov word [replaymousey], 0xa7
.28:
        push word [replaymousey]
        push word [replaymousex]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [replayfollow]
        mov [replayfollow2], ax
.29:
        call 0x0000:VgaPageFlip
        call 0x03A3:CallCountStep
        mov [bp - 0xc], ax
.30:
        lea ax, [bp - 0xc]
        push ax
        push cs
        call ReplayControlLoop
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .31
        jmp near .10
.31:
        call 0x0EDC:CrowdNoiseOff
        mov ax, 0xffff
        mov [lastsfx], ax
        mov [replaysfx], ax
        mov ax, [bp - 0x8]
        mov [camx], ax
        mov ax, [bp - 0x6]
        mov [camy], ax
        mov ax, [bp - 0x2]
        mov [viewscrollx], ax
        mov ax, [bp - 0x4]
        mov [ovltimer2], ax
        mov ax, [bp - 0xa]
        mov [CrowdSound], ax
        mov [Crowdlevel], ax
        mov ax, 0x1
        mov [DeskRedrawPage2], ax
        mov [DeskRedrawPage], ax
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
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        mov word [fadeinpending], 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; GadgetHitTest                                              2581:0510  94 PC
; Which replay button is under the mouse.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
GadgetHitTest:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov di, [bp + 0x6]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov bx, 0x5320
        mov cx, [bp + 0x8]
.1:
        cmp [bx], di
        jg short .2
        cmp [bx + 0x4], di
        jl short .2
        cmp [bx + 0x2], cx
        jg short .2
        cmp [bx + 0x6], cx
        jnl short .3
.2:
        inc dx
        add bx, 0xa
        cmp bx, 0x5384
        jc short .1
        jmp short .4
.3:
        mov bx, [bp + 0xa]
        mov [bx], dx
        mov ax, 0x1
        pop di
        leave
        retf
        db 0x90
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PickNearestPlayer                                          2581:0550  94 PC
; Nearest player to the pointer.
;
; Takes 2 words of stack arguments. Calls ImulRegs. Far routine (retf).
;-----------------------------------------------------------------------------
PickNearestPlayer:
        enter 0xe, 0x0
        push di
        push si
        mov word [bp - 0xa], 0xffff
        mov word [bp - 0x8], 0x2710
        mov word [bp - 0x6], 0x0
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov si, rpl_y
.1:
        cmp si, 0xdb68
        jc short .2
        cmp si, 0xdb6e
        jna short .5
.2:
        mov ax, [si - 0x22]
        sub ax, [bp + 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [bp + 0x8]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov [bp - 0xe], cx
        mov [bp - 0xc], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xe]
        adc dx, [bp - 0xc]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jg short .5
        jl short .3
        cmp ax, strict word 0x64
        ja short .5
.3:
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        cmp [bp - 0x2], dx
        jg short .5
        jl short .4
        cmp [bp - 0x4], ax
        jnc short .5
.4:
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov [bp - 0xa], di
.5:
        inc di
        inc si
        inc si
        cmp si, 0xdb72
        jc short .1
        mov ax, [bp - 0xa]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReplayControlLoop                                          2581:05E4  94 PC
; Replay input loop.
;
; Takes 1 word of stack arguments. Calls GetInputEvent, GadgetHitTest, MouseMove, PickNearestPlayer,
; VgaCopyBlock, VgaCopyToPitch, VgaCopyFromPitch, UseOffscreenCanvas and others. Far routine (retf).
;-----------------------------------------------------------------------------
ReplayControlLoop:
        enter 0x14, 0x0
        push si
        mov ax, [replaybutton]
        mov [bp - 0x4], ax
        mov ax, [replaymousex]
        mov [bp - 0xe], ax
        mov ax, [replaymousey]
        mov [bp - 0x10], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x12], ax
        mov [bp - 0x14], ax
.1:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word replaymousey
        push word replaymousex
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x14], ax
        test al, 0x2
        jz short .1
.2:
        test byte [bp - 0x14], 0x1
        jz short .3
        mov word [replayfwd], 0x1
        jmp short .4
.3:
        test byte [bp - 0x14], 0x2
        jz short .4
        mov word [replayfwd], 0x0
.4:
        cmp word [replayfwd], 0x0
        jz short .5
        lea ax, [bp - 0x8]
        push ax
        push word [replaymousey]
        push word [replaymousex]
        push cs
        call GadgetHitTest
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        cmp word [replaysaved], 0x0
        jz short .12
        cmp word [bp - 0x8], 0x7
        jnz short .12
.5:
        mov word [bp - 0x8], 0x0
.6:
        cmp word [replaymousey], 0xa8
        jnl short .7
        mov ax, [replaymousex]
        add ax, [camx]
        sub ax, 0xa0
        mov [replayptrx], ax
        mov ax, [camy]
        sub ax, [replaymousey]
        add ax, strict word 0x54
        mov [replaypick], ax
.7:
        mov ax, [bp - 0x8]
        cmp ax, strict word 0x10
        jz short .19
        jng short .8
        jmp near .50
.8:
        dec ax
        jnz short .9
        jmp near .21
.9:
        dec ax
        jnz short .10
        jmp near .23
.10:
        dec ax
        dec ax
        jz short .13
        sub ax, strict word 0x4
        jnz short .11
        jmp near .28
.11:
        jmp near .54
.12:
        mov cl, [bp - 0x8]
        mov ax, 0x1
        shl ax, cl
        mov [bp - 0x8], ax
        jmp short .6
        db 0x90
.13:
        mov al, [replaybutton]
        and ax, strict word 0x40
        or al, 0x4
        mov [replaybutton], ax
.14:
        mov word [bp - 0x12], 0x0
.15:
        mov ax, [replaybutton]
        cmp [bp - 0x4], ax
        jz short .16
        jmp near .62
.16:
        mov ax, [bp - 0xe]
        cmp [replaymousex], ax
        jnz short .17
        mov ax, [replaymousey]
        cmp [bp - 0x10], ax
        jnz short .17
        jmp near .66
.17:
        cmp word [bp - 0xe], 0x12c
        jg short .18
        jmp near .57
.18:
        mov word [bp - 0xe], 0x12c
        jmp near .58
        db 0x90
.19:
        mov al, [replaybutton]
        and al, 0x3f
        cmp al, 0x10
        jz short .20
        mov word [replaydx], 0x0
.20:
        mov al, [replaybutton]
        and ax, strict word 0x40
        or al, 0x10
        mov [replaybutton], ax
        jmp near .48
        db 0x90
.21:
        mov al, [replaybutton]
        and ax, strict word 0x54
        or al, 0x1
        mov [replaybutton], ax
        mov bx, [bp + 0x6]
        mov ax, [bx]
        shl ax, byte 0x2
        neg ax
        jmp near .49
.22:
        mov al, [replaybutton]
        and ax, strict word 0x54
        or al, 0x20
        mov [replaybutton], ax
        mov bx, [bp + 0x6]
        mov ax, [bx]
        shl ax, byte 0x2
        jmp near .49
.23:
        test byte [replaybutton], 0x2
        jz short .25
        mov bx, [bp + 0x6]
        mov ax, [bx]
        add [replayspeed], ax
        cmp word [replayspeed], 0x5
        jnl short .24
        mov word [bp - 0x12], 0x0
        jmp short .26
.24:
        sub word [replayspeed], 0x5
        mov word [bp - 0x12], 0xffff
        jmp short .26
.25:
        mov word [replayspeed], 0x0
        mov word [bp - 0x12], 0xffff
        mov word [replaydx], 0xfff2
.26:
        mov al, [replaybutton]
        and ax, strict word 0x40
        or al, 0x6
.27:
        mov [replaybutton], ax
        jmp near .15
        db 0x90
.28:
        test byte [replaybutton], 0x8
        jz short .30
        mov bx, [bp + 0x6]
        mov ax, [bx]
        add [replayspeed], ax
        cmp word [replayspeed], 0x5
        jnl short .29
        mov word [bp - 0x12], 0x0
        jmp short .31
.29:
        sub word [replayspeed], 0x5
        mov word [bp - 0x12], 0x1
        jmp short .31
.30:
        mov word [replayspeed], 0x0
        mov word [bp - 0x12], 0x1
        mov word [replaydx], 0xe
.31:
        mov al, [replaybutton]
        and ax, strict word 0x40
        or al, 0xc
        jmp short .27
        db 0x90
.32:
        or byte [replaybutton], 0x40
        mov ax, 0xffff
        mov [replayfollow], ax
        mov [replayfollow2], ax
        mov [replaymode], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [replayplaying], ax
        jmp near .49
        db 0x90
.33:
        mov al, [replaybutton]
        and ax, strict word 0x40
        or al, 0x84
        jmp short .27
.34:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90
.35:
        cmp word [replaymousex], -0x20
        jnl short .36
        mov word [replaymousex], 0xffe0
.36:
        cmp word [replaymousey], 0xec
        jng short .37
        mov word [replaymousey], 0xec
        jmp short .38
        db 0x90
.37:
        cmp word [replaymousey], 0xff44
        jnl short .38
        mov word [replaymousey], 0xff44
.38:
        mov ax, [replaystart]
        sub ax, [replaymousex]
        add ax, 0xa0
        mov [replaymousex], ax
        mov ax, 0x54
        sub ax, [replayend]
        add [replaymousey], ax
        cmp word [replaymousey], 0xa7
        jng short .39
        mov word [replaymousey], 0xa7
.39:
        push word [replaymousey]
        push word [replaymousex]
        call 0x03A3:MouseMove
        add sp, 0x4
        jmp near .46
        db 0x90
.40:
        mov word [replayplaying], 0x0
        mov [replaymode], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + rpl_x]
        mov [replaymousex], ax
        mov cx, [bx + rpl_y]
        mov [replaymousey], cx
        cmp ax, strict word 0x20
        jng short .41
        mov word [replaymousex], 0x20
        jmp short .42
        db 0x90
.41:
        cmp ax, strict word 0xffe0
        jnl short .42
        mov word [replaymousex], 0xffe0
.42:
        cmp word [replaymousey], 0xec
        jng short .43
        mov word [replaymousey], 0xec
        jmp short .44
        db 0x90
.43:
        cmp word [replaymousey], 0xff44
        jnl short .44
        mov word [replaymousey], 0xff44
.44:
        mov bx, [replayfollow]
        shl bx, 1
        mov ax, [bx + rpl_x]
        sub ax, [replaymousex]
        add ax, 0xa0
        mov [replaymousex], ax
        mov ax, 0x54
        sub ax, [bx + rpl_y]
        add [replaymousey], ax
        cmp word [replaymousey], 0xa7
        jng short .45
        mov word [replaymousey], 0xa7
.45:
        push word [replaymousey]
        push word [replaymousex]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [replayfollow]
        mov [replayfollow2], ax
.46:
        and word [replaybutton], 0x14
.47:
        and word [replaybutton], 0x54
        test byte [replaybutton], 0x10
        jnz short .48
        jmp near .14
.48:
        mov bx, [bp + 0x6]
        mov ax, [bx]
.49:
        mov [bp - 0x12], ax
        jmp near .15
.50:
        sub ax, strict word 0x20
        jnz short .51
        jmp near .22
.51:
        sub ax, strict word 0x20
        jnz short .52
        jmp near .32
.52:
        sub ax, strict word 0x40
        jnz short .53
        jmp near .33
.53:
        sub ax, 0x80
        jnz short .54
        jmp near .34
.54:
        cmp word [replaymousey], 0xa8
        jnl short .47
        push word [replaypick]
        push word [replayptrx]
        push cs
        call PickNearestPlayer
        add sp, 0x4
        mov [replayfollow], ax
        test byte [bp - 0x14], 0x2
        jz short .47
        cmp ax, strict word 0xffff
        jz short .55
        jmp near .40
.55:
        mov word [replayplaying], 0x1
        mov [replayfollow2], ax
        mov [replaymode], ax
        mov ax, [replayptrx]
        mov [replaystart], ax
        mov cx, [replaypick]
        mov [replayend], cx
        mov [replaymousex], ax
        mov [replaymousey], cx
        cmp ax, strict word 0x20
        jg short .56
        jmp near .35
.56:
        mov word [replaymousex], 0x20
        jmp near .36
.57:
        cmp word [bp - 0xe], 0x0
        jnl short .58
        mov word [bp - 0xe], 0x0
.58:
        cmp word [bp - 0x10], 0x0
        jnl short .59
        mov word [bp - 0x10], 0x0
        jmp short .60
.59:
        cmp word [bp - 0x10], 0xb5
        jng short .60
        mov word [bp - 0x10], 0xb5
.60:
        cmp word [bp - 0x10], 0xa8
        jnl short .61
        jmp near .66
.61:
        push 0x12
        push 0x5
        mov ax, [bp - 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov cx, [bp - 0x10]
        sub cx, 0xa8
        imul cx, cx, 0x52
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push word 0xaa0
        jmp short .65
        db 0x90
.62:
        push 0x0
        push word 0xc8a0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov word [bp - 0x8], 0x0
.63:
        mov cl, [bp - 0x8]
        mov ax, 0x1
        shl ax, cl
        test [replaybutton], ax
        jz short .64
        mov bx, [bp - 0x8]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push word [bx + ReplayGadgets2]
        push word [bx + ReplayGadgetsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        push word [si + ReplayGadgetRects]
        push word [bx + ReplayGadgets]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
.64:
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x9
        jl short .63
        cmp word [replaysaved], 0x0
        jz short .66
        push word [ReplayBack2]
        push word [ReplayBackSeg]
        push word [ReplayPointerRect]
        push word [ReplayBack]
.65:
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
.66:
        mov ax, [bp - 0xe]
        cmp [replaymousex], ax
        jnz short .67
        mov ax, [replaymousey]
        cmp [bp - 0x10], ax
        jnz short .67
        mov ax, [replaybutton]
        cmp [bp - 0x4], ax
        jnz short .67
        jmp near .74
.67:
        cmp word [replaymousex], 0x12c
        jng short .68
        mov word [bp - 0xe], 0x12c
        jmp short .70
        db 0x90
.68:
        cmp word [replaymousex], 0x0
        jnl short .69
        mov word [bp - 0xe], 0x0
        jmp short .70
.69:
        mov ax, [replaymousex]
        mov [bp - 0xe], ax
.70:
        cmp word [replaymousey], 0x0
        jnl short .71
        mov word [bp - 0x10], 0x0
        jmp short .73
.71:
        cmp word [replaymousey], 0xb5
        jng short .72
        mov word [bp - 0x10], 0xb5
        jmp short .73
        db 0x90
.72:
        mov ax, [replaymousey]
        mov [bp - 0x10], ax
.73:
        cmp word [bp - 0x10], 0xa8
        jl short .74
        push 0x12
        push 0x5
        push word 0xaa0
        mov ax, [bp - 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov cx, [bp - 0x10]
        sub cx, 0xa8
        imul cx, cx, 0x52
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        call 0x0000:VgaCopyFromPitch
        add sp, 0x8
        call 0x0FEF:UseOffscreenCanvas
        push 0x1e
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        mov ax, [replaymousey]
        sub ax, 0xa8
        push ax
        push word [replaymousex]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
.74:
        test byte [replaybutton], 0x80
        jnz short .75
        jmp near .77
.75:
        push 0x0
        push word 0xc8a0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov word [replayfwd], 0x0
        push word [bp - 0x10]
        push word [bp - 0xe]
        push word 0xaa0
        push cs
        call ReplaySaveHilight
        add sp, 0x6
        call 0x0F99:FlushInputEvents
        mov word [replaybutton], 0x4
        call 0x0FEF:UseOffscreenCanvas
        push 0x1e
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push 0x0
        push word 0xc8a0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        push word [ReplayPanels]
        push word [ReplayPanelSeg]
        push word [ReplayGadgetRect2]
        push word [ReplayPanel]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
        push 0x12
        push 0x5
        push word 0xaa0
        mov ax, [bp - 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov cx, [bp - 0x10]
        sub cx, 0xa8
        imul cx, cx, 0x52
        db 0x03, 0xC8                           ; insn: add cx, ax
        push cx
        call 0x0000:VgaCopyFromPitch
        add sp, 0x8
        cmp word [replaysaved], 0x0
        jz short .76
        push word [ReplayBack2]
        push word [ReplayBackSeg]
        push word [ReplayPointerRect]
        push word [ReplayBack]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
.76:
        mov ax, [replaymousey]
        sub ax, 0xa8
        push ax
        push word [replaymousex]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
.77:
        mov ax, [bp - 0x12]
        mov bx, [bp + 0x6]
        mov [bx], ax
        mov ax, 0x1
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReplaySaveHilight                                          2581:0C14  94 PC
; Save-highlight dialog.
;
; Takes 3 words of stack arguments. Calls AllocRecData, VgaCopyToPitch, HilightSaveToDlg,
; UseOffscreenCanvas, SetClipRectRegs, FlushInputEvents, VgaCopyBytes, MouseRange and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
ReplaySaveHilight:
        enter 0xc, 0x0
        push di
        push si
        cmp word [ctl1team], 0x0
        jnl short .1
        jmp near .18
.1:
        cmp word [ctl2team], 0x0
        jnl short .2
        jmp near .18
.2:
        mov ax, [ctl1team]
        cmp [ctl2team], ax
        jnz short .3
        jmp near .18
.3:
        push 0x0
        les bx, [DialogData]
        mov cx, [es:bx]
        inc cx
        mov ax, [es:bx + 0x2]
        inc ax
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push word 0x5384
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0xc]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0xc]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0xc]
        mov [es:bx + 0x2], ax
        push 0x12
        push 0x5
        mov ax, [bp + 0x8]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        imul cx, [bp + 0xa], 0x52
        db 0x03, 0xC8                           ; insn: add cx, ax
        push cx
        push word [bp + 0x6]
        call 0x0000:VgaCopyToPitch
        add sp, 0x8
        push cs
        call HilightSaveToDlg
        mov word [replaysavestate], 0x3
        mov word [replaymousex], 0xa0
        mov word [replaymousey], 0x64
        call 0x0FEF:UseOffscreenCanvas
        push 0x6a
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        mov bx, 0x1e
        call 0x0FEF:SetClipRectRegs
        call 0x0F99:FlushInputEvents
        push word 0x1858
        push word OutlineDx
        push word 0x2306
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x64
        push word 0x136
        push 0x20
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push 0x64
        push word 0xa0
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x64
        push word 0xa0
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov word [bp - 0x4], 0x0
.4:
        call 0x0F99:GetInputEvent
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
        mov [bp - 0x2], si
        mov di, [replaymousex]
        mov si, [replaymousey]
        mov cx, [bp - 0x2]
        push word replaymousey
        push word replaymousex
        push cx
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x4], ax
        test al, 0x2
        jz short .9
        cmp word [replaymousex], 0x4e
        jl short .8
        cmp word [replaymousex], 0xd8
        jg short .8
        cmp word [replaymousey], 0x23
        jl short .5
        cmp word [replaymousey], 0x31
        jg short .5
        mov word [replaysavestate], 0x0
        jmp short .9
        db 0x90, 0x90
.5:
        cmp word [replaymousey], 0x34
        jl short .6
        cmp word [replaymousey], 0x42
        jg short .6
        mov word [replaysavestate], 0x1
        jmp short .9
.6:
        cmp word [replaymousey], 0x45
        jl short .7
        cmp word [replaymousey], 0x53
        jg short .7
        mov word [replaysavestate], 0x2
        jmp short .9
.7:
        cmp word [replaymousey], 0x56
        jl short .8
        cmp word [replaymousey], 0x64
        jg short .8
        mov word [replaysavestate], 0x3
        jmp short .9
.8:
        mov word [bp - 0x4], 0x0
.9:
        push si
        push di
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [replaymousey]
        push word [replaymousex]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [replaymousey]
        push word [replaymousex]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        test byte [bp - 0x4], 0x2
        jnz short .10
        jmp near .4
.10:
        mov ax, 0x64
        cwd
        call 0x03A3:SetDeadline.regs
        push word 0x1858
        push word OutlineDx
        push word 0x2306
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:UseOffscreenCanvas
        push 0x6a
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push 0x10
        imul ax, [replaysavestate], 0x11
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, strict word 0x31
        push ax
        push 0x4e
        add cx, 0x23
        push cx
        push 0x4e
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x10
        imul ax, [replaysavestate], 0x11
        add ax, strict word 0x23
        push ax
        push word 0xd8
        push ax
        push 0x4e
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x16
        imul ax, [replaysavestate], 0x11
        add ax, strict word 0x31
        push ax
        push word 0xd8
        push ax
        push 0x4f
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x16
        imul ax, [replaysavestate], 0x11
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, strict word 0x31
        push ax
        push word 0xd8
        add cx, 0x24
        push cx
        push word 0xd8
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x13
        imul ax, [replaysavestate], 0x11
        add ax, strict word 0x23
        push ax
        push word 0xd8
        call 0x0FEF:PutPixel
        add sp, 0x6
        push 0x13
        imul ax, [replaysavestate], 0x11
        add ax, strict word 0x31
        push ax
        push 0x4e
        call 0x0FEF:PutPixel
        add sp, 0x6
        push word [replaymousey]
        push word [replaymousex]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [replaysavestate]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        dec ax
        jz short .14
        dec ax
        jz short .13
        dec ax
        jz short .15
        mov si, [bp - 0x4]
        jmp short .16
        db 0x90
.11:
        push 0x0
.12:
        push cs
        call SaveHilightFile
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .16
        db 0x90
.13:
        push 0x0
        push cs
        call SaveHilightFile
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .16
.14:
        push 0x1
        jmp short .12
        db 0x90
.15:
        db 0x2B, 0xF6                           ; insn: sub si, si
.16:
        mov di, [bp + 0xa]
        call 0x03A3:WaitDeadlineNoEoi
        push cs
        call ShowCurrentPage
        mov ax, [bp + 0x8]
        mov [replaymousex], ax
        mov [replaymousey], di
        push di
        push ax
        call 0x03A3:MouseMove
        add sp, 0x4
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .17
        mov ax, 0x1f4
        cwd
        call 0x03A3:SetDeadline.regs
        push 0x0
        push 0x59
        push 0x11
        push 0x59
        push 0x14
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x38f0
        push strict word msgInsufficientDiskSpaceToSave
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        call 0x03A3:WaitDeadlineNoEoi
        call 0x0D90:RestoreUnderBox
.17:
        call 0x0FEF:UseOffscreenCanvas
        push 0x6a
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0xc3
        push word 0x13b
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        pop si
        pop di
        leave
        retf
.18:
        mov ax, 0x64
        cwd
        call 0x03A3:SetDeadline.regs
        cmp word [ctl1team], 0x0
        jl short .20
        mov ax, [ctl1team]
        cmp [HomeTeamNum], ax
        jnz short .21
.19:
        push 0x0
        jmp short .22
        db 0x90
.20:
        mov ax, [ctl2team]
        cmp [HomeTeamNum], ax
        jz short .19
.21:
        push 0x1
.22:
        push cs
        call SaveHilightFile
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .23
        mov ax, 0x1f4
        cwd
        call 0x03A3:SetDeadline.regs
        push 0x0
        push 0x59
        push 0x11
        push 0x59
        push 0x14
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x38f0
        push strict word msgInsufficientDiskSpaceToSave
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        call 0x03A3:WaitDeadlineNoEoi
        call 0x0D90:RestoreUnderBox
.23:
        call 0x03A3:WaitDeadlineNoEoi
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; HilightSaveToDlg                                           2581:105A  94 PC
; 'Save To' 'Hilights Reel' panel.
;
; Calls SaveCharTab, UseCharSeg, VgaCopyBytes, VgaPageFlip, UseOtherPage, FillRect, DrawFrame,
; DrawLine and others. Far routine (retf).
;-----------------------------------------------------------------------------
HilightSaveToDlg:
        enter 0x1e, 0x0
        push di
        push si
        mov word [bp - 0x6], 0x538c
        mov word [bp - 0x4], 0x5397
        lea ax, [bp - 0x1e]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [ReplayFontSeg]
        push word [ReplayFont]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        cmp word [CurPage], 0x0
        jnz short .1
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0000:VgaPageFlip
.1:
        call 0x0FEF:UseOtherPage
        push 0x14
        push 0x4c
        push word 0x140
        push 0x4b
        push 0x0
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x9
        push word 0x95
        push word 0x13e
        push 0x4c
        push 0x1
        call 0x1484:DrawFrame
        add sp, 0xa
        push 0x10
        push word 0x96
        push word 0x13d
        push 0x4d
        push 0x2
        call 0x1484:DrawFrame
        add sp, 0xa
        mov word [bp - 0x2], 0x4e
        mov si, 0x50
        mov di, 0x4
.2:
        push 0x16
        lea ax, [si + 0xe]
        push ax
        push 0x4e
        push si
        push 0x4e
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x16
        push si
        push word 0xd8
        push si
        push 0x4e
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x10
        lea ax, [si + 0xe]
        push ax
        push word 0xd8
        push ax
        push 0x4f
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x10
        lea ax, [si + 0xe]
        push ax
        push word 0xd8
        lea cx, [si + 0x1]
        push cx
        push word 0xd8
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x13
        push si
        push word 0xd8
        call 0x0FEF:PutPixel
        add sp, 0x6
        push 0x13
        lea ax, [si + 0xe]
        push ax
        push 0x4e
        call 0x0FEF:PutPixel
        add sp, 0x6
        add si, 0x11
        dec di
        jnz short .2
        les bx, [FontPtr]
        mov word [es:bx], 0x10
        push 0x6d
        push 0xe
        push strict word str_SaveTo_2
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x6d
        push word 0xdf
        push strict word str_HilightsReel_2
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x54
        push word 0x9f85
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x52
        push ax
        push word 0x9f85
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x65
        push word 0xa26d
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x52
        push ax
        push word 0xa26d
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x76
        push strict word str_BothTeams
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x52
        push ax
        push strict word str_BothTeams
        call 0x0FEF:DrawText
        add sp, 0x6
        push word 0x87
        push strict word str_NeitherTeams
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x52
        push ax
        push strict word str_NeitherTeams
        call 0x0FEF:DrawText
        add sp, 0x6
        les bx, [FontPtr]
        mov word [es:bx], 0x59
        push 0x6c
        push 0xd
        push strict word str_SaveTo
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x6c
        push word 0xde
        push strict word str_HilightsReel
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x53
        push word 0x9f85
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x51
        push ax
        push word 0x9f85
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x64
        push word 0xa26d
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x51
        push ax
        push word 0xa26d
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x75
        push strict word str_BothTeams
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x51
        push ax
        push strict word str_BothTeams
        call 0x0FEF:DrawText
        add sp, 0x6
        push word 0x86
        push strict word str_NeitherTeams
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x85
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x51
        push ax
        push strict word str_NeitherTeams
        call 0x0FEF:DrawText
        add sp, 0x6
        push word 0x1858
        push word OutlineDx
        push word 0x2306
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x5f
        call 0x0FEF:SetStartPage
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SaveHilightFile                                            2581:1304  94 PC
; Writes the .HI file.
;
; Takes 1 word of stack arguments. Calls _dos_getdiskfree, FatalError, _fstrcpy, _dos_findfirst,
; CreateFileNormal, OpenWriteShared, _lseek, WriteAtOffset and others. Far routine (retf).
;-----------------------------------------------------------------------------
SaveHilightFile:
        enter 0x56, 0x0
        push di
        push si
        lea ax, [bp - 0xa]
        push ax
        push 0x0
        call 0x0000:_dos_getdiskfree
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x53d1
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        mov ax, 0x964a
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div word [bp - 0x4]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div word [bp - 0x6]
        cmp ax, [bp - 0x8]
        jna short .2
        mov ax, 0x1
        mov [replaysaved], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        mov ax, 0x3a0b
        mov es, ax
        mov al, [savedteam1]
        mov [es:hilightrec], al
        mov al, [savedteam2]
        mov [es:hilightrec_b1], al
        mov al, [HomeTeamNum]
        mov [es:hilightrec_b2], al
        mov al, [VisTeamNum]
        mov [es:hilightrec_b1F], al
        mov ax, [curperiod]
        mov [es:hilightrec_w3C], ax
        mov ax, [hudclockmin]
        mov [es:hilightrec_w3E], ax
        mov ax, [hudclocksec]
        mov [es:hilightrec_w40], ax
        mov ax, [hudclockhund]
        mov [es:hilightrec_w42], ax
        mov ax, [sflags]
        mov [es:hilightrec_w44], ax
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        sub ax, [replayptr]
        sbb dx, [replayseg]
        mov [es:hilightrec_w46], ax
        mov [es:hilightrec_frames], dx
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov si, hmrosterjersey
.3:
        mov al, [si]
        mov [es:di + hilightrec_home], al
        mov al, [si + 0x460]
        mov [es:di + hilightrec_away], al
        inc di
        add si, 0x28
        cmp si, 0xa9b6
        jc short .3
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, 0x53d4
        lea si, [bp - 0x2a]
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
        imul bx, [bp + 0x6], word 0x2e8
        lea di, [bx + GameTeamRecs]
        lea si, [bp - 0x2a]
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
        mov di, str_Hi_2
        lea si, [bp - 0x2a]
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
        lea ax, [bp - 0x56]
        push ax
        push 0x0
        lea ax, [bp - 0x2a]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x53da
        call 0x0F4A:FatalError
        add sp, 0x2
        jmp short .5
.4:
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        lea ax, [bp - 0x2a]
        push ax
        push strict word str_CanNotOpenSFile
        call 0x0F4A:FatalError
        add sp, 0x4
.5:
        push 0x2
        push 0x0
        push 0x0
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        push word 0x964a
        push -0x1
        push -0x1
        push word 0x3a0b
        push strict word hilightrec
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0x53f5
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0x53f8
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ShowCurrentPage                                            2581:14FC  94 PC
; SetStartPage of the current page.
;
; Calls SetStartPage.
;-----------------------------------------------------------------------------
ShowCurrentPage:
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push word 0x3860
        push word 0xb00
        push word 0x4400
