; Top panel: score, clock, penalties and energy bars (AI.OVL)
; The first bytes finish the last routine of play_hilight.asm.
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawPanelScore                                             2083:0006  94 PC
; Score digits on the top panel.
;
; Takes 2 words of stack arguments. Calls UseOffscreenCanvas, DrawRleTransFastAt, UseOtherPage. Far
; routine (retf).
;-----------------------------------------------------------------------------
DrawPanelScore:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x8]
        cmp si, 0x64
        jl short .1
        mov cx, 0x64
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
.1:
        call 0x0FEF:UseOffscreenCanvas
        cmp word [bp + 0x6], 0x0
        jz short .4
        cmp si, 0xa
        jl short .2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        jmp short .3
        db 0x90
.2:
        mov di, 0xa
.3:
        push 0x4
        push word 0xff
        shl di, byte 0x2
        push word [di + ScoreDigitsSeg]
        push word [di + ScoreDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x4
        push word 0x109
        jmp short .7
.4:
        cmp si, 0xa
        jl short .5
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        jmp short .6
        db 0x90
.5:
        mov di, 0xa
.6:
        push 0x4
        push 0x2e
        shl di, byte 0x2
        push word [di + ScoreDigitsSeg]
        push word [di + ScoreDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x4
        push 0x38
.7:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + ScoreDigitsSeg]
        push word [bx + ScoreDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        call 0x0FEF:UseOtherPage
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawPanelLine                                              2083:00B2  94 PC
; Line indicator shape on the panel.
;
; Takes 2 words of stack arguments. Calls UseOffscreenCanvas, DrawRleTransFastAt, UseOtherPage. Far
; routine (retf).
;-----------------------------------------------------------------------------
DrawPanelLine:
        enter 0x8, 0x0
        push si
        call 0x0FEF:UseOffscreenCanvas
        cmp word [bp + 0x6], 0x0
        jz short .11
        mov si, [bp + 0x8]
        cmp si, 0x4
        jnl short .1
        mov ax, 0x1
        jmp short .2
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        mov [bp - 0x2], ax
        cmp word [hudlinehome], 0x4
        jnl short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        xor ax, [bp - 0x2]
        jnz short .9
        cmp si, 0x6
        jnl short .5
        mov ax, 0x1
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        mov [bp - 0x4], ax
        cmp word [hudlinehome], 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
        db 0x90
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        xor ax, [bp - 0x4]
        jz short .10
.9:
        mov word [hudlinegroup], 0x0
.10:
        mov [hudlinehome], si
        push 0x14
        push word 0xfb
        jmp short .22
.11:
        mov si, [bp + 0x8]
        cmp si, 0x4
        jnl short .12
        mov ax, 0x1
        jmp short .13
        db 0x90
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.13:
        mov [bp - 0x6], ax
        cmp word [hudhomeline], 0x4
        jnl short .14
        mov ax, 0x1
        jmp short .15
        db 0x90
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.15:
        xor ax, [bp - 0x6]
        jnz short .20
        cmp si, 0x6
        jnl short .16
        mov ax, 0x1
        jmp short .17
        db 0x90
.16:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.17:
        mov [bp - 0x8], ax
        cmp word [hudhomeline], 0x6
        jnl short .18
        mov ax, 0x1
        jmp short .19
        db 0x90
.18:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.19:
        xor ax, [bp - 0x8]
        jz short .21
.20:
        mov word [hudlineaway], 0x0
.21:
        mov [hudhomeline], si
        push 0x14
        push 0x2a
.22:
        shl si, byte 0x2
        push word [si + PanelShapes_b2]
        push word [si + PanelShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        call 0x0FEF:UseOtherPage
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; GetLineEnergies                                            2083:0192  94 PC
; TeamLineEnergy of the 8 lines minus 60h.
;
; Takes 2 words of stack arguments. Calls TeamLineEnergy. Far routine (retf).
;-----------------------------------------------------------------------------
GetLineEnergies:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0x8]
.1:
        push si
        push word [bp + 0x6]
        call 0x2E42:TeamLineEnergy
        add sp, 0x4
        sub ax, strict word 0x60
        inc di
        inc di
        mov [di - 0x2], ax
        inc si
        cmp si, 0x8
        jl short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PanelAddPenalty                                            2083:01BA  94 PC
; Puts a penalty (side, player, time) in the first free slot of that side's panel penalty list and
; flags the side for a redraw.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PanelAddPenalty:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov cx, [bp + 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [hudlineaway], ax
        mov [hudlinegroup], ax
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jz short .1
        mov bx, hudpenaway
        jmp short .2
        db 0x90
.1:
        mov bx, hudpenhome
.2:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.3:
        cmp word [bx], -0x1
        jz short .4
        add bx, 0x8
        inc dx
        cmp dx, 0x8
        jl short .3
        leave
        retf
        db 0x90
.4:
        mov ax, [bp + 0x8]
        mov [bx], ax
        mov ax, [bp + 0xa]
        mov [bx + 0x2], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0x6], ax
        mov [bx + 0x4], ax
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jz short .5
        mov [hudawayredraw], ax
        leave
        retf
.5:
        mov [hudhomeredraw], ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PanelRemovePenalty                                         2083:020A  94 PC
; Clears the time of a player's panel penalty entry when he leaves the box.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PanelRemovePenalty:
        enter 0x8, 0x0
        push di
        cmp word [bp + 0x6], 0x0
        jz short .1
        mov bx, hudpenaway
        jmp short .2
.1:
        mov bx, hudpenhome
.2:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cx, [bp + 0x8]
.3:
        cmp [bx], cx
        jz short .4
        add bx, 0x8
        inc dx
        cmp dx, 0x8
        jl short .3
        jmp short .5
        db 0x90
.4:
        db 0x8B, 0xFB                           ; insn: mov di, bx
.5:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [di + 0x6], ax
        mov [di + 0x4], ax
        mov [di + 0x2], ax
.6:
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; UpdateHudPanel                                             2083:0248  94 PC
; Per-frame panel redraw: clock, penalties, energy bars.
;
; Calls UseOffscreenCanvas, TickPanelClock, TickPanelPenalties, GetLineEnergies, DrawPanelClockDigits,
; DrawEnergyBar, DrawLineGroupBars, DrawRleTransFastHere and others. Far routine (retf).
;-----------------------------------------------------------------------------
UpdateHudPanel:
        call 0x0FEF:UseOffscreenCanvas
        cmp word [hudclockmin], 0x0
        jnl short .1
        jmp near .11
.1:
        mov ax, [hudhundstep]
        mov [panelhund], ax
        mov word [hudhundstep], 0x0
        push ax
        push cs
        call TickPanelClock
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        test byte [gmode], 0x10
        jnz short .2
        push word [panelhund]
        push word hudpenhome
        push cs
        call TickPanelPenalties
        add sp, 0x4
        push word [panelhund]
        push word hudpenaway
        push cs
        call TickPanelPenalties
        add sp, 0x4
.2:
        push word HudBarLevels2
        push 0x0
        push cs
        call GetLineEnergies
        add sp, 0x4
        push word HudBarLevels
        push 0x1
        push cs
        call GetLineEnergies
        add sp, 0x4
        push cs
        call DrawPanelClockDigits
        push 0x2b
        mov bx, [hudhomeline]
        shl bx, 1
        mov ax, [bx + HudBarLevels2]
        mov cx, 0x1f4
        cwd
        idiv cx
        push ax
        push cs
        call DrawEnergyBar
        add sp, 0x4
        push word 0xfc
        mov bx, [hudlinehome]
        shl bx, 1
        mov ax, [bx + HudBarLevels]
        mov cx, 0x1f4
        cwd
        idiv cx
        push ax
        push cs
        call DrawEnergyBar
        add sp, 0x4
        cmp word [lcboxon], 0x0
        jnz short .3
        cmp word [hudhomeredraw], 0x0
        jnz short .3
        test byte [gmode], 0x10
        jnz short .3
        cmp word [hudpenhome], 0x0
        jnl short .6
        mov word [hudhomeredraw], 0x1
.3:
        push 0x4a
        push word HudBarLevels2
        push word [hudhomeline]
        push word PanelScoreShapeSeg + 2
        push word hudlineaway
        push cs
        call DrawLineGroupBars
        add sp, 0xa
        mov word [hudclockredraw], 0x0
.4:
        cmp word [hudredraw], 0x0
        jz short .5
        jmp near .10
.5:
        cmp word [hudawayredraw], 0x0
        jnz short .10
        test byte [gmode], 0x10
        jnz short .10
        cmp word [hudpenaway], 0x0
        jnl short .8
        mov word [hudawayredraw], 0x1
        jmp short .10
        db 0x90, 0x90
.6:
        cmp word [hudclockredraw], 0x0
        jnz short .7
        push word [PanelClockShapeSeg]
        push word [PanelClockShape]
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        mov word [hudclockredraw], 0x1
.7:
        push 0x48
        push word hudpenhome
        push cs
        call DrawPanelPenalties
        add sp, 0x4
        mov word [hudlineaway], 0x0
        jmp short .4
        db 0x90
.8:
        cmp word [hudscoreredraw], 0x0
        jnz short .9
        push word [PanelScoreShapeSeg]
        push word [PanelScoreShape]
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        mov word [hudscoreredraw], 0x1
.9:
        push word 0xbf
        push word hudpenaway
        push cs
        call DrawPanelPenalties
        add sp, 0x4
        mov word [hudlinegroup], 0x0
        retf
        db 0x90
.10:
        push word 0xc1
        push word HudBarLevels
        push word [hudlinehome]
        push word PanelScoreShapeSeg + 0xe
        push word hudlinegroup
        push cs
        call DrawLineGroupBars
        add sp, 0xa
        mov word [hudscoreredraw], 0x0
.11:
        retf

;-----------------------------------------------------------------------------
; DrawPanelClock                                             2083:03CC  94 PC
; Clock digits and colon.
;
; Calls DrawRleTransFastAt. Far routine (retf).
;-----------------------------------------------------------------------------
DrawPanelClock:
        cmp word [hudclockmin], 0x0
        jz short .1
        jmp near .4
.1:
        push 0x3
        push word 0xaa
        push word [clockcolon]
        push word [ClockColonShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        cmp word [hudclocksec], 0xa
        jnl short .2
        push 0x3
        push word 0x8c
        push word [clockcolon]
        push word [ClockColonShape]
        jmp short .3
        db 0x90
.2:
        push 0x3
        push word 0x8c
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
.3:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x3
        push word 0x95
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x3
        push word 0xa1
        mov ax, [hudclockhund]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp near .7
        db 0x90
.4:
        cmp word [hudclockmin], 0xa
        jnl short .5
        push 0x3
        push word 0x8c
        push word [clockcolon]
        push word [ClockColonShape]
        jmp short .6
.5:
        push 0x3
        push word 0x8c
        mov ax, [hudclockmin]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
.6:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x3
        push word 0x95
        mov ax, [hudclockmin]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x3
        push word 0xa1
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x3
        push word 0xaa
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
.7:
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        mov ax, [hudclockmin]
        mov [panelprevmin], ax
        mov ax, [hudclocksec]
        mov [panelprevsec], ax
        mov ax, [hudclockhund]
        mov [panelprevhund], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawHudPanel                                               2083:0512  94 PC
; Full panel redraw: scrbrd2, srb3, crests4.
;
; Takes 4 words of stack arguments. Calls GetPeriodTime, UseOffscreenCanvas, BuildPathFar,
; LoadPackedHeader, FindFarMsg, DrawRleFastHere, DrawPanelScore, DrawPanelClock and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
DrawHudPanel:
        enter 0x12, 0x0
        push di
        push si
        cmp word [bp + 0xc], 0x0
        jz short .1
        call 0x2E42:GetPeriodTime
        mov [hudclocksec], ax
        mov [hudclockmin], ax
        mov cx, 0x3c
        cwd
        idiv cx
        mov [hudclockmin], ax
        mov ax, [hudclocksec]
        cwd
        idiv cx
        mov [hudclocksec], dx
        mov word [hudclockhund], 0x0
.1:
        mov ax, [hmtmline]
        mov [hudhomeline], ax
        mov ax, [awtmline]
        mov [hudlinehome], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [panelhund], ax
        mov [hudawayredraw], ax
        mov [hudhomeredraw], ax
        mov [hudscoreredraw], ax
        mov [hudclockredraw], ax
        mov [hudlinegroup], ax
        mov [hudlineaway], ax
        call 0x0FEF:UseOffscreenCanvas
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Scrbrd2
        push 0x0
        push 0x0
        lea ax, [bp - 0x12]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Srb3
        push 0x0
        lea ax, [bp - 0x12]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        push word [hmscore]
        push 0x0
        push cs
        call DrawPanelScore
        add sp, 0x4
        push word [awscore]
        push 0x1
        push cs
        call DrawPanelScore
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push cs
        call DrawPanelClock
        cmp word [bp + 0xa], 0x0
        jnz short .2
        push 0x16
        push word 0x98
        push word [HudShapeName]
        jmp short .3
        db 0x90
.2:
        mov di, [bp + 0xa]
        push 0x16
        push word 0x98
        mov cx, 0x64
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        idiv cx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov cx, 0xa
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        push word [di + HudShapeNames]
        push word [bp - 0x2]
        push si
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x16
        push word 0xa0
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        push word [bx + HudShapeNames]
.3:
        push word [bp - 0x2]
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push word [bp - 0x2]
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Crests4
        push 0x0
        push 0x0
        lea ax, [bp - 0x12]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x12]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov al, 0x67
        mov [PanelText2], al
        mov [PanelText], al
        push ds
        push strict word TeamPalette2
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0x4
        push 0x4
        mov bx, [bp + 0x6]
        shl bx, 1
        push word [bx + CrestShapeNames]
        mov ax, [bp - 0x2]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        push ds
        push strict word TeamPalette1
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0x4
        push word 0x11c
        mov bx, [bp + 0x8]
        shl bx, 1
        push word [bx + CrestShapeNames]
        push di
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        mov al, 0x43
        mov [PanelText2], al
        mov [PanelText], al
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x14
        push 0x2a
        mov bx, [hudhomeline]
        shl bx, byte 0x2
        push word [bx + PanelShapes_b2]
        push word [bx + PanelShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push 0x14
        push word 0xfb
        mov bx, [hudlinehome]
        shl bx, byte 0x2
        push word [bx + PanelShapes_b2]
        push word [bx + PanelShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TickPanelClock                                             2083:0738  94 PC
; Saves the drawn clock and counts it down.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
TickPanelClock:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [hudclockmin]
        mov [panelprevmin], ax
        mov ax, [hudclocksec]
        mov [panelprevsec], ax
        mov ax, [hudclockhund]
        mov [panelprevhund], ax
        mov ax, [bp + 0x6]
        sub [hudclockhund], ax
        jns short .1
        add word [hudclockhund], 0x64
        dec word [hudclocksec]
        jns short .1
        mov word [hudclocksec], 0x3b
        dec word [hudclockmin]
        jns short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [hudclockhund], ax
        mov [hudclocksec], ax
        mov [hudclockmin], ax
        leave
        retf
.1:
        mov ax, 0x1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawPanelClockDigits                                       2083:0780  94 PC
; Redraws the clock digits that changed.
;
; Calls DrawRleTransFastAt. Far routine (retf).
;-----------------------------------------------------------------------------
DrawPanelClockDigits:
        cmp word [hudclockmin], 0x0
        jz short .1
        jmp near .9
.1:
        mov ax, [hudclockmin]
        cmp [panelprevmin], ax
        jz short .2
        push 0x3
        push word 0xaa
        push word [clockcolon]
        push word [ClockColonShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.2:
        mov ax, [hudclocksec]
        cmp [panelprevsec], ax
        jnz short .3
        jmp near .7
.3:
        mov cx, 0xfff6
        cwd
        idiv cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [panelprevsec]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jz short .6
        cmp word [hudclocksec], 0xa
        jnl short .4
        push 0x3
        push word 0x8c
        push word [clockcolon]
        push word [ClockColonShape]
        jmp short .5
.4:
        push 0x3
        push word 0x8c
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
.5:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.6:
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        mov ax, [panelprevsec]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jz short .7
        push 0x3
        push word 0x95
        mov ax, [hudclocksec]
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.7:
        mov ax, [hudclockhund]
        mov cx, 0xfff6
        cwd
        idiv cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [panelprevhund]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jnz short .8
        jmp near .17
.8:
        push 0x3
        push word 0xa1
        mov ax, [hudclockhund]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp near .16
        db 0x90
.9:
        mov ax, [hudclockmin]
        cmp [panelprevmin], ax
        jnz short .10
        jmp near .14
.10:
        mov cx, 0xfff6
        cwd
        idiv cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [panelprevmin]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jz short .13
        cmp word [hudclockmin], 0xa
        jnl short .11
        push 0x3
        push word 0x8c
        push word [clockcolon]
        push word [ClockColonShape]
        jmp short .12
.11:
        push 0x3
        push word 0x8c
        mov ax, [hudclockmin]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
.12:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.13:
        mov ax, [hudclockmin]
        mov cx, 0xa
        cwd
        idiv cx
        mov ax, [panelprevmin]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jz short .14
        push 0x3
        push word 0x95
        mov ax, [hudclockmin]
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.14:
        mov ax, [hudclocksec]
        cmp [panelprevsec], ax
        jz short .17
        mov cx, 0xfff6
        cwd
        idiv cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [panelprevsec]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jz short .15
        push 0x3
        push word 0xa1
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.15:
        mov ax, [hudclocksec]
        mov cx, 0xa
        cwd
        idiv cx
        mov ax, [panelprevsec]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jz short .17
        push 0x3
        push word 0xaa
        mov ax, [hudclocksec]
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
.16:
        shl bx, byte 0x2
        push word [bx + ClockDigitsSeg]
        push word [bx + ClockDigits]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
.17:
        retf

;-----------------------------------------------------------------------------
; TickPanelPenalties                                         2083:0968  94 PC
; Counts down the first two penalty entries.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
TickPanelPenalties:
        enter 0xe, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        add bx, 0x6
        mov dx, 0x2
        mov cx, [bp + 0x8]
        mov di, [bp - 0xc]
.1:
        sub [bx], cx
        jns short .2
        add word [bx], 0x64
        dec word [bx - 0x2]
        jns short .2
        mov word [bx - 0x2], 0x3b
        dec word [bx - 0x4]
        jns short .2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx - 0x4], ax
        mov [bx - 0x2], ax
        mov [bx], ax
        mov word [bx - 0x6], 0xffff
.2:
        add bx, 0x8
        dec dx
        jnz short .1
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov ax, [bp + 0x6]
        mov [bp - 0xa], ax
.3:
        mov bx, [bp - 0xa]
        cmp word [bx], 0x0
        jnl short .6
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        inc bx
        cmp bx, 0x8
        jnl short .6
        mov [bp - 0xc], dx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, byte 0x3
        add ax, [bp + 0x6]
        mov [bp - 0x4], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, byte 0x3
        add ax, [bp + 0x6]
        mov [bp - 0x2], ax
        mov ax, 0x8
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0x6], ax
        mov dx, [bp - 0x2]
.4:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cmp word [bx], 0x0
        jl short .5
        db 0x8B, 0xF2                           ; insn: mov si, dx
        push ds
        pop es
        mov di, [bp - 0x4]
        movsw
        movsw
        movsw
        movsw
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov word [bx], 0xffff
        add word [bp - 0x4], 0x8
.5:
        add dx, 0x8
        dec word [bp - 0x6]
        jnz short .4
        mov dx, [bp - 0xc]
.6:
        add word [bp - 0xa], 0x8
        inc dx
        cmp dx, 0x7
        jl short .3
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawEnergyBar                                              2083:0A1C  94 PC
; Two-column energy bar, FillRect.
;
; Takes 2 words of stack arguments. Calls FillRect. Far routine (retf).
;-----------------------------------------------------------------------------
DrawEnergyBar:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x8]
        cmp di, 0xa0
        jng short .1
        mov bx, 0x1
        jmp short .2
.1:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.2:
        shl bx, 1
        cmp word [bx + energywarnteam], 0x0
        jz short .3
        mov si, [bp + 0x6]
        push 0x0
        push 0x3
        push si
        push 0x1a
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add ax, strict word 0x9
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        jmp short .4
        db 0x90
.3:
        mov si, [bp + 0x6]
        push 0x67
        push 0x3
        push si
        push 0x1a
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add ax, strict word 0x9
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x67
.4:
        push 0x3
        push si
        push 0x1a
        lea ax, [di + 0x10]
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x3
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub si, 0x8
        neg si
        push si
        push 0x1a
        lea cx, [di + 0x1]
        push cx
        mov [bp - 0x2], ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x3
        push si
        push 0x1a
        add di, [bp - 0x2]
        add di, 0x10
        push di
        call 0x0FEF:FillRect
        add sp, 0xa
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawLineGroupBars                                          2083:0ABE  94 PC
; Energy bars of the current line group.
;
; Takes 5 words of stack arguments. Calls DrawRleTransFastHere, FillRect. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLineGroupBars:
        enter 0x10, 0x0
        push di
        push si
        cmp word [bp + 0xe], 0xa0
        jng short .1
        mov bx, 0x1
        jmp short .2
.1:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.2:
        mov [bp - 0xa], bx
        shl bx, 1
        cmp word [bx + lcboxon], 0x0
        jz short .3
        mov bx, [bp - 0xa]
        shl bx, 1
        mov ax, [bx + lcgroup]
        jmp short .4
        db 0x90
.3:
        mov ax, [bp + 0xa]
.4:
        mov [bp - 0xc], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .5
        sub ax, strict word 0x3
        jng short .6
        dec ax
        jl short .5
        dec ax
        jng short .8
        dec ax
        jl short .5
        dec ax
        jng short .10
.5:
        mov cx, [bp - 0x4]
        mov dx, [bp - 0xe]
        mov di, [bp - 0x8]
        jmp short .12
.6:
        mov si, [bp + 0x6]
        cmp word [si], 0x0
        jnz short .7
        mov bx, [bp + 0x8]
        push word [bx + 0x2]
        push word [bx]
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        mov word [si], 0x1
.7:
        mov di, 0x8
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov dx, 0x4
        jmp short .12
.8:
        mov si, [bp + 0x6]
        cmp word [si], 0x0
        jnz short .9
        mov bx, [bp + 0x8]
        push word [bx + 0x6]
        push word [bx + 0x4]
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        mov word [si], 0x1
.9:
        mov di, 0xe
        mov cx, 0x4
        mov dx, 0x6
        jmp short .12
.10:
        mov si, [bp + 0x6]
        cmp word [si], 0x0
        jnz short .11
        mov bx, [bp + 0x8]
        push word [bx + 0xa]
        push word [bx + 0x8]
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        mov word [si], 0x1
.11:
        mov di, 0xe
        mov cx, 0x6
        mov dx, 0x8
.12:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jl short .13
        jmp near .19
.13:
        mov [bp - 0xe], dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, 1
        add ax, [bp + 0xc]
        mov [bp - 0x6], ax
        mov [bp - 0x2], bx
.14:
        mov ax, [bp - 0x2]
        cmp [bp - 0xc], ax
        jnz short .15
        mov bx, [bp - 0xa]
        shl bx, 1
        cmp word [bx + lcsel], 0x0
        jz short .15
        mov word [bp - 0x4], 0x61
        jmp short .18
.15:
        mov ax, [bp + 0xa]
        cmp [bp - 0x2], ax
        jnz short .16
        mov ax, 0x60
        jmp short .17
        db 0x90
.16:
        mov ax, 0x67
.17:
        mov [bp - 0x4], ax
.18:
        push word [bp - 0x4]
        push 0x3
        mov bx, [bp - 0x6]
        mov ax, [bx]
        mov cx, 0xc8
        cwd
        idiv cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push si
        push di
        mov ax, [bp + 0xe]
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add ax, strict word 0x15
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push word [bp - 0x4]
        push 0x3
        push si
        push di
        mov ax, [bp + 0xe]
        add ax, strict word 0x20
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x3
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub si, 0x14
        neg si
        push si
        push di
        mov cx, [bp + 0xe]
        inc cx
        push cx
        mov [bp - 0x10], ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x3
        push si
        push di
        mov ax, [bp - 0x10]
        add ax, [bp + 0xe]
        add ax, strict word 0x20
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        add word [bp - 0x6], 0x2
        add di, 0x6
        mov ax, [bp - 0xe]
        inc word [bp - 0x2]
        cmp [bp - 0x2], ax
        jnl short .19
        jmp near .14
.19:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawPanelPenalties                                         2083:0C56  94 PC
; Up to 4 penalty entries per side.
;
; Takes 3 words of stack arguments. Calls DrawRleTransFastAt.
;-----------------------------------------------------------------------------
DrawPanelPenalties:
        enter 0x4, 0x0
        push di
        push si
        mov si, 0x9
        mov di, [bp + 0x6]
        mov word [bp - 0x2], 0x4
.1:
        cmp word [di], 0x0
        jnl short .2
        jmp near .7
.2:
        cmp word [di], 0xa
        jnl short .3
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0xa
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        jmp short .4
.3:
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0xa
        push ax
        mov ax, [di]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
.4:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x10
        push ax
        mov ax, [di]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        cmp word [di + 0x2], 0xa
        jnl short .5
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x1b
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        jmp short .6
.5:
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x1b
        push ax
        mov ax, [di + 0x2]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
.6:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x21
        push ax
        mov ax, [di + 0x2]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x2a
        push ax
        mov ax, [di + 0x4]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x30
        push ax
        mov ax, [di + 0x4]
        mov cx, 0xa
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        push word [bx + PenaltyShapesSeg]
        push word [bx + PenaltyShapes]
        jmp near .8
        db 0x90
.7:
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0xa
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x10
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x1b
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x21
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x2a
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push si
        mov ax, [bp + 0x8]
        add ax, strict word 0x30
        push ax
        push word [PenaltyShapeSeg]
        push word [PenaltyShape]
.8:
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        add di, 0x8
        add si, 0x5
