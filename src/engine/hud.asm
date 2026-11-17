; Camera window and on-screen banners (AI.OVL)
; The first bytes finish the last routine of faceoff.asm.
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkwindow                                                226F:0004  94 PC
; Camera follows the puck.
;
; Calls ImulRegs. Far routine (retf).
;-----------------------------------------------------------------------------
checkwindow:
        enter 0x8, 0x0
        push di
        push si
        mov word [bp - 0x2], 0x28
        mov word [bp - 0x4], 0xa
        mov word [bp - 0x6], 0x0
        mov ax, [yc1]
        mov [regd2], ax
        mov ax, [xc1]
        mov [regd3], ax
        test byte [gmode], 0x80
        jnz short .1
        jmp near .16
.1:
        mov ax, 0xff9c
        mov [xc1], ax
        mov [regd3], ax
        mov ax, 0xf
        mov [yc1], ax
        mov [regd2], ax
        mov word [bp - 0x4], 0x5
        sub ax, [camy]
        mov [regd0], ax
        cmp ax, strict word 0xfffb
        jnl short .2
        mov word [regd1], 0x14
        jmp short .3
.2:
        cmp [bp - 0x4], ax
        jnl short .3
        mov ax, [regd2]
        sub ax, [bp - 0x4]
        mov [regd1], ax
        cmp ax, 0xec
        jng short .3
        mov word [regd1], 0xec
.3:
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, [bp - 0x4]
        jng short .8
        mov ax, [camy]
        sub [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x20
        jng short .6
        cmp word [regd1], 0x0
        jl short .4
        mov ax, 0x20
        jmp short .5
.4:
        mov ax, 0xffe0
.5:
        mov [regd1], ax
.6:
        cmp word [regd1], 0x0
        jz short .8
        sar word [regd1], byte 0x5
        cmp word [regd1], 0x0
        jnz short .7
        mov word [regd1], 0x1
.7:
        mov ax, [regd1]
        add [camy], ax
.8:
        mov ax, [regd3]
        sub ax, [camx]
        mov [regd0], ax
        mov cx, [bp - 0x2]
        neg cx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .9
        mov ax, [bp - 0x2]
        add ax, [regd3]
        mov [regd1], ax
        cmp ax, strict word 0xffe0
        jnl short .11
        mov word [regd1], 0xffe0
        jmp short .11
.9:
        cmp [bp - 0x2], ax
        jl short .10
        jmp near .57
.10:
        mov ax, [regd3]
        sub ax, [bp - 0x2]
        mov [regd1], ax
        cmp ax, strict word 0x20
        jng short .11
        mov word [regd1], 0x20
.11:
        mov ax, [camx]
        sub [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x20
        jng short .14
        cmp word [regd1], 0x0
        jl short .12
        mov ax, 0x20
        jmp short .13
.12:
        mov ax, 0xffe0
.13:
        mov [regd1], ax
.14:
        cmp word [regd1], 0x0
        jnz short .15
        jmp near .57
.15:
        sar word [regd1], byte 0x5
        jmp near .55
.16:
        cmp word [gameclock], 0x0
        jnz short .17
        cmp word [clockticks], 0x0
        jnz short .17
        jmp near .40
.17:
        test byte [gmode], 0x4
        jz short .18
        cmp word [PenCntDwn], 0x0
        jl short .19
.18:
        cmp word [RefStep], 0x0
        jg short .19
        jmp near .30
.19:
        mov word [bp - 0x8], 0xbd0e
        mov ax, [refXpos2]
        mov [xc1], ax
        mov ax, [refYpos2]
        mov [yc1], ax
        mov ax, [xc1]
        sub ax, [camx]
        mov [regd2], ax
        mov cx, [reftemp3]
        sub cx, [camx]
        mov [regd3], cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jnl short .20
        mov ax, [camx]
        jmp short .21
        db 0x90
.20:
        mov ax, [regd2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [regd3]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .22
        mov bx, [bp - 0x8]
        mov ax, [bx + 0x2a]
.21:
        mov [xc1], ax
.22:
        mov ax, [yc1]
        sub ax, [camy]
        mov [regd2], ax
        mov bx, [bp - 0x8]
        mov cx, [bx + 0x2c]
        sub cx, [camy]
        mov [regd3], cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jnl short .24
        mov ax, [camy]
.23:
        mov [regd2], ax
        mov [yc1], ax
        jmp short .26
.24:
        mov ax, [regd2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [regd3]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .25
        mov ax, [bx + 0x2c]
        jmp short .23
        db 0x90
.25:
        mov ax, [yc1]
        mov [regd2], ax
.26:
        mov ax, [xc1]
        mov [regd3], ax
        mov si, [bx + 0x1c]
        cmp byte [bx + si + 0x1e], 0x22
        jz short .27
        jmp near .40
.27:
        mov ax, [bx + 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [foy]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        call 0x03A3:ImulRegs
        mov bx, [bp - 0x8]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bx + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [fox]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x03A3:ImulRegs
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .28
        jmp near .40
.28:
        jl short .29
        cmp si, 0x640
        jc short .29
        jmp near .40
.29:
        mov ax, [foy]
        mov [yc1], ax
        mov [regd2], ax
        mov ax, [fox]
        mov [xc1], ax
        mov [regd3], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0x2], ax
        jmp near .40
.30:
        test byte [sflags], 0x40
        jz short .31
        jmp near .40
.31:
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .38
        mov al, [bx]
        cbw
        shl ax, byte 0x7
        add ax, 0xb50e
        mov [bp - 0x8], ax
        mov word [regd0], 0x2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp word [bx + 0x5e], 0x10
        jnz short .32
        mov al, [bx + 0xf]
        cbw
        neg ax
        mov [yleader], ax
        jmp short .39
        db 0x90, 0x90
.32:
        test byte [bx + 0x44], 0x80
        jz short .35
        cmp word [bx + 0xe], -0x64
        jnl short .33
        mov ax, 0x1
        jmp short .34
        db 0x90
.33:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.34:
        mov [bp - 0x6], ax
        mov ax, [regd0]
        add [yleader], ax
        cmp word [yleader], 0x32
        jl short .39
        mov word [yleader], 0x32
        jmp short .39
        db 0x90
.35:
        cmp word [bx + 0xe], 0x64
        jng short .36
        mov ax, 0x1
        jmp short .37
        db 0x90
.36:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.37:
        mov [bp - 0x6], ax
        mov ax, [regd0]
        sub [yleader], ax
        cmp word [yleader], -0x32
        jg short .39
        mov word [yleader], 0xffce
        jmp short .39
        db 0x90
.38:
        mov word [bp - 0x8], 0xbc0e
.39:
        mov bx, [bp - 0x8]
        mov al, [bx + 0xf]
        cbw
        add ax, [bx + 0x6]
        add ax, [yleader]
        mov [regd2], ax
        mov [yc1], ax
        mov ax, [bx + 0x2]
        mov [regd3], ax
        mov [xc1], ax
.40:
        mov ax, [regd2]
        sub ax, [camy]
        mov [regd0], ax
        mov cx, [bp - 0x4]
        neg cx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .41
        mov ax, [bp - 0x4]
        add ax, [regd2]
        mov [regd1], ax
        cmp ax, 0xff44
        jnl short .44
        mov word [regd1], 0xff44
        jmp short .44
.41:
        cmp [bp - 0x4], ax
        jnl short .44
        cmp word [bp - 0x6], 0x0
        jz short .42
        mov ax, [regd2]
        jmp short .43
.42:
        mov ax, [regd2]
        sub ax, [bp - 0x4]
.43:
        mov [regd1], ax
        cmp ax, 0xec
        jng short .44
        mov word [regd1], 0xec
.44:
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, [bp - 0x4]
        jng short .49
        mov ax, [camy]
        sub [regd1], ax
        test byte [gmode], 0x1
        jz short .47
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x20
        jng short .47
        cmp word [regd1], 0x0
        jl short .45
        mov ax, 0x20
        jmp short .46
.45:
        mov ax, 0xffe0
.46:
        mov [regd1], ax
.47:
        cmp word [regd1], 0x0
        jz short .49
        cmp word [bp - 0x6], 0x1
        db 0x1A, 0xC9                           ; insn: sbb cl, cl
        and cl, 0x1
        add cl, 0x3
        sar word [regd1], cl
        cmp word [regd1], 0x0
        jnz short .48
        mov word [regd1], 0x1
.48:
        mov ax, [regd1]
        add [camy], ax
.49:
        mov ax, [regd3]
        sub ax, [camx]
        mov [regd0], ax
        mov cx, [bp - 0x2]
        neg cx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .50
        mov ax, [bp - 0x2]
        add ax, [regd3]
        mov [regd1], ax
        cmp ax, strict word 0xffe0
        jnl short .51
        mov word [regd1], 0xffe0
        jmp short .51
        db 0x90
.50:
        cmp [bp - 0x2], ax
        jnl short .57
        mov ax, [regd3]
        sub ax, [bp - 0x2]
        mov [regd1], ax
        cmp ax, strict word 0x20
        jng short .51
        mov word [regd1], 0x20
.51:
        mov ax, [camx]
        sub [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x20
        jng short .54
        cmp word [regd1], 0x0
        jl short .52
        mov ax, 0x20
        jmp short .53
        db 0x90
.52:
        mov ax, 0xffe0
.53:
        mov [regd1], ax
.54:
        cmp word [regd1], 0x0
        jz short .57
        sar word [regd1], byte 0x4
.55:
        cmp word [regd1], 0x0
        jnz short .56
        mov word [regd1], 0x1
.56:
        mov ax, [regd1]
        add [camx], ax
.57:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadTeamPPV                                                226F:046A  94 PC
; Loads a numbered .QPP picture file.
;
; Takes 1 word of stack arguments. Calls BuildPathFar, LoadPackedHeader, TableCount, _sprintf,
; FindFarMsg. Far routine (retf).
;-----------------------------------------------------------------------------
LoadTeamPPV:
        enter 0x12, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        push word 0x3701
        push strict word str_Qpp
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        push ds
        push word [bx + TeamPPVNames]
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
        mov [OverlayGfx], ax
        mov [OverlayGfxSeg], dx
        mov word [bp - 0x2], 0x0
        push dx
        push ax
        call 0x03A3:TableCount
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .2
        mov di, 0xd630
        mov si, [bp - 0x2]
.1:
        push si
        push strict word str_04d
        lea ax, [bp - 0x12]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x12]
        push ax
        push word [OverlayGfxSeg]
        push word [OverlayGfx]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add di, 0x4
        mov [di - 0x4], ax
        mov [di - 0x2], dx
        push word [OverlayGfxSeg]
        push word [OverlayGfx]
        call 0x03A3:TableCount
        add sp, 0x4
        inc si
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jg short .1
        mov si, [bp + 0x6]
.2:
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
        mov [ovlseq], si
        shl si, byte 0x2
        mov ax, [si + TeamPPVSizes]
        mov dx, [si + TeamPPVSizes2]
        mov [overlayscript], ax
        mov [overlayscriptseg], dx
        mov word [overlaytimer], 0xc
        mov word [overlaystate], 0x1
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [es:bx + 0x1]
        cbw
        mov [ovlstep], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawTextOverlay                                            226F:054A  94 PC
; Text overlay sliding in and out.
;
; Calls SetClipRectRegs, AddrFlag0, FillRect, DrawSpriteClipped, UseCharSeg, TextWidthAll, DrawText.
; Far routine (retf).
;-----------------------------------------------------------------------------
DrawTextOverlay:
        enter 0x14, 0x0
        push di
        push si
        mov ax, [TextOverlaySeg]
        mov cx, 0x2
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        mov ax, [TextOverlayPtr]
        cwd
        idiv cx
        db 0x03, 0xDA                           ; insn: add bx, dx
        shl bx, 1
        mov ax, [bx + BannerColours]
        mov [bp - 0x6], ax
        cmp word [ovltimer], 0x10
        jnl short .1
        mov di, [ovltimer]
        sub di, 0x10
        jmp short .3
.1:
        cmp word [ovltimer], 0x100
        jg short .2
        db 0x2B, 0xFF                           ; insn: sub di, di
        jmp short .3
.2:
        mov di, [bp - 0x2]
        cmp word [ovltimer], 0x258
        jl short .3
        mov di, 0x258
        sub di, [ovltimer]
.3:
        mov word [bannermsg], 0xffff
        mov word [bannertimer], 0x0
        mov ax, 0x1
        mov [DeskRedrawPage2], ax
        mov [DeskRedrawPage], ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .4
        jmp near .6
.4:
        lea ax, [di + 0x10]
        imul ax, ax, 0x2a
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x4
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x4], ax
        mov ax, DGROUP
        mov es, ax
        mov ax, [es:ClipLeftX]
        mov [bp - 0xc], ax
        mov ax, [es:ClipRightX]
        mov [bp - 0xe], ax
        mov ax, [es:ClipTopY]
        mov [bp - 0x10], ax
        mov ax, [es:ClipBottomY]
        mov [bp - 0x12], ax
        lea ax, [di + 0x10]
        imul ax, ax, 0x42
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x4
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xa], ax
        mov si, [TextOverlaySeg]
        db 0x2B, 0xF0                           ; insn: sub si, ax
        add si, 0x4a
        cmp word [gsp], 0x4
        jnz short .5
        add si, 0xac
.5:
        mov ax, [TextOverlayPtr]
        sub ax, [bp - 0x4]
        add ax, strict word 0x32
        mov cx, [bp - 0x4]
        shl cx, 1
        db 0x03, 0xC8                           ; insn: add cx, ax
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0xa]
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        call 0x0FEF:SetClipRectRegs
.6:
        mov si, [TextOverlaySeg]
        add si, 0xc
        cmp word [gsp], 0x4
        jnz short .7
        add si, 0xac
.7:
        lea ax, [si + 0x7b]
        mov [bp - 0x8], ax
        mov ax, [TextOverlayPtr]
        add ax, strict word 0xc
        mov [bp - 0x14], ax
        add ax, strict word 0x4b
        mov [bp - 0x4], ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .8
        cmp word [ovlseq], -0x1
        jz short .8
        cmp word [ovlstep], -0x1
        jnz short .9
.8:
        push ax
        push si
        push ax
        push word [bp - 0x8]
        push word [bp - 0x14]
        push word [bp - 0x8]
        push word [bp - 0x14]
        push si
        push 0x4
        push 0x10
        push 0x9
        push word [bp - 0x6]
        call 0x03A3:AddrFlag0
        add sp, 0x18
.9:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .10
        cmp word [bp - 0xa], 0x3e
        jl short .11
.10:
        push 0x0
        push 0x4
        push word 0x83
        mov ax, [bp - 0x14]
        sub ax, strict word 0x4
        push ax
        lea ax, [si - 0x4]
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x4b
        push 0x4
        push word [bp - 0x14]
        lea ax, [si - 0x4]
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x4b
        push 0x4
        push word [bp - 0x14]
        push word [bp - 0x8]
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x4
        push word 0x83
        push word [bp - 0x4]
        lea ax, [si - 0x4]
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
.11:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .12
        push word [bp - 0x12]
        mov ax, [bp - 0xc]
        mov dx, [bp - 0xe]
        mov bx, [bp - 0x10]
        call 0x0FEF:SetClipRectRegs
        pop si
        pop di
        leave
        retf
.12:
        cmp word [ovlseq], -0x1
        jnz short .13
        jmp near .23
.13:
        cmp word [ovlstep], -0x1
        jnz short .14
        jmp near .23
.14:
        mov di, [bp - 0x14]
        push 0x0
        push 0x0
        push 0x0
        push di
        push si
        mov bx, [ovlstep]
        shl bx, byte 0x2
        push word [bx + OverlayFramesSeg]
        push word [bx + OverlayFrames]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
        cmp word [ovlseq], 0x0
        jz short .15
        jmp near .36
.15:
        cmp word [ovlstep], 0x2
        jz short .16
        jmp near .36
.16:
        add di, 0x23
        cmp word [CrowdSound], 0x2ee
        jng short .18
        push word [bp - 0x4]
        push si
        push word [bp - 0x4]
        mov ax, [CrowdSound]
        sub ax, 0x2ee
        cmp ax, 0xc8
        jng short .17
        mov ax, 0xc8
.17:
        mov cx, 0x5
        cwd
        idiv cx
        db 0x03, 0xC6                           ; insn: add ax, si
        push ax
        push di
        push ax
        push di
        push si
        push 0x4
        push 0x10
        push 0x30
        push word [bp - 0x6]
        call 0x03A3:AddrFlag0
        add sp, 0x18
.18:
        cmp word [CrowdSound], 0x3b6
        jng short .20
        add si, 0x28
        push word [bp - 0x4]
        push si
        push word [bp - 0x4]
        mov ax, [CrowdSound]
        sub ax, 0x3b6
        cmp ax, 0xc8
        jng short .19
        mov ax, 0xc8
.19:
        mov cx, 0x5
        cwd
        idiv cx
        db 0x03, 0xC6                           ; insn: add ax, si
        push ax
        push di
        push ax
        push di
        push si
        push 0x4
        push 0x10
        push 0x27
        push word [bp - 0x6]
        call 0x03A3:AddrFlag0
        add sp, 0x18
.20:
        cmp word [CrowdSound], 0x47e
        jg short .21
        jmp near .36
.21:
        add si, 0x28
        push word [bp - 0x4]
        push si
        push word [bp - 0x4]
        mov ax, [CrowdSound]
        sub ax, 0x47e
        cmp ax, 0xd7
        jng short .22
        mov ax, 0xd7
.22:
        mov cx, 0x5
        cwd
        idiv cx
        db 0x03, 0xC6                           ; insn: add ax, si
        push ax
        push di
        push ax
        push di
        push si
        push 0x4
        push 0x10
        push 0x60
        push word [bp - 0x6]
        call 0x03A3:AddrFlag0
        add sp, 0x18
        pop si
        pop di
        leave
        retf
        db 0x90
.23:
        mov di, [bp - 0x14]
        cmp byte [textline5], 0x0
        jz short .24
        add di, 0x8
        mov word [bp - 0x4], 0xd
        jmp short .26
.24:
        cmp byte [textline4], 0x0
        jz short .25
        add di, 0xb
        mov word [bp - 0x4], 0xf
        jmp short .26
        db 0x90
.25:
        add di, 0xf
        mov word [bp - 0x4], 0x12
.26:
        add si, 0x3e
        push word [MemBlock3Seg]
        push word [MemBlock3Off]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov ax, 0x25
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        mov [bp - 0x2], di
        cmp byte [textline3], 0x0
        jz short .27
        push di
        push word 0xd4b8
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd4b8
        call 0x0FEF:DrawText
        add sp, 0x6
.27:
        cmp byte [textline1], 0x0
        jz short .28
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd506
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd506
        call 0x0FEF:DrawText
        add sp, 0x6
.28:
        cmp byte [textline2], 0x0
        jz short .29
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd542
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd542
        call 0x0FEF:DrawText
        add sp, 0x6
.29:
        cmp byte [textline4], 0x0
        jz short .30
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd57e
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd57e
        call 0x0FEF:DrawText
        add sp, 0x6
.30:
        cmp byte [textline5], 0x0
        jz short .31
        mov ax, [bp - 0x4]
        add ax, [bp - 0x2]
        push ax
        push word 0xd5ba
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd5ba
        call 0x0FEF:DrawText
        add sp, 0x6
.31:
        push word [MemBlock2Seg]
        push word [MemBlock2Off]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov ax, 0x27
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        mov [bp - 0x2], di
        cmp byte [textline3], 0x0
        jz short .32
        push di
        push word 0xd4b8
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd4b8
        call 0x0FEF:DrawText
        add sp, 0x6
.32:
        cmp byte [textline1], 0x0
        jz short .33
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd506
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd506
        call 0x0FEF:DrawText
        add sp, 0x6
.33:
        cmp byte [textline2], 0x0
        jz short .34
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd542
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd542
        call 0x0FEF:DrawText
        add sp, 0x6
.34:
        cmp byte [textline4], 0x0
        jz short .35
        mov ax, [bp - 0x4]
        add [bp - 0x2], ax
        push word [bp - 0x2]
        push word 0xd57e
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        push cx
        push word 0xd57e
        call 0x0FEF:DrawText
        add sp, 0x6
.35:
        cmp byte [textline5], 0x0
        jz short .36
        mov ax, [bp - 0x4]
        add ax, [bp - 0x2]
        push ax
        push word 0xd5ba
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x2B, 0xF0                           ; insn: sub si, ax
        push si
        push word 0xd5ba
        call 0x0FEF:DrawText
        add sp, 0x6
.36:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CloseTextOverlay                                           226F:0A56  94 PC
; Overlay timer 100h to 10h.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
CloseTextOverlay:
        cmp word [ovltimer], 0x100
        jnz short .1
        mov ax, 0x10
        mov [ovltimer], ax
        retf
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [ovltimer], ax
        retf

;-----------------------------------------------------------------------------
; UpdateTextOverlay                                          226F:0A6C  94 PC
; Steps the overlay script.
;
; Calls FindUnlink. Far routine (retf).
;-----------------------------------------------------------------------------
UpdateTextOverlay:
        push si
        cmp word [ovltimer], 0x0
        jnl short .1
        jmp near .14
.1:
        cmp word [PenCntDwn], 0x100
        jl short .2
        cmp word [PenCntDwn], 0x140
        jg short .2
        test byte [gmode], 0x40
        jnz short .2
        jmp near .14
.2:
        cmp word [ovlseq], 0x0
        jnz short .7
        cmp word [ovlstep], 0x5
        jnl short .7
        cmp word [CrowdSound], 0x5dc
        jnl short .7
        cmp word [overlaystate], 0x1
        jnz short .3
        cmp word [CrowdSound], 0x280
        jnl short .3
        mov word [CrowdSound], 0x280
.3:
        cmp word [overlaystate], 0x1
        jl short .4
        cmp word [overlaystate], 0x5
        jl short .6
.4:
        cmp word [overlaystate], 0x7
        jng short .5
        cmp word [overlaystate], 0xd
        jl short .6
.5:
        cmp word [overlaystate], 0x10
        jng short .7
.6:
        add word [CrowdSound], 0x8
.7:
        cmp word [ovltimer], 0x10
        jnz short .11
        cmp word [ovlseq], -0x1
        jz short .11
        mov ax, [overlayscriptseg]
        or ax, [overlayscript]
        jz short .11
        dec word [overlaytimer]
        js short .8
        jmp near .14
.8:
        les bx, [overlayscript]
        mov al, [es:bx]
        cbw
        cmp ax, [overlaystate]
        jnz short .10
        push word [OverlayGfxSeg]
        push word [OverlayGfx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov bx, [ovlseq]
        cmp byte [bx + OverlayScript], 0x0
        jz short .9
        mov word [ovltimer], 0x258
.9:
        mov ax, 0xffff
        mov [ovlstep], ax
        mov [ovlseq], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [overlayscriptseg], ax
        mov [overlayscript], ax
        pop si
        retf
.10:
        inc word [overlaystate]
        mov si, [overlaystate]
        mov al, [es:bx + si]
        cbw
        mov [ovlstep], ax
        mov word [overlaytimer], 0xc
        pop si
        retf
        db 0x90
.11:
        cmp word [ovltimer], 0x100
        jl short .12
        cmp word [ovltimer], 0x258
        jl short .13
.12:
        inc word [ovltimer]
.13:
        cmp word [ovltimer], 0x268
        jng short .14
        mov word [ovltimer], 0xffff
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [textline5], al
        mov [textline4], al
        mov [textline2], al
        mov [textline1], al
        mov [textline3], al
.14:
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawCallBanner                                             226F:0B94  94 PC
; Referee call banner.
;
; Takes 1 word of stack arguments. Calls TextWidthAll, AddrFlag0, FillRect, UseCharSeg, DrawText,
; AddDirtyRect. Far routine (retf).
;-----------------------------------------------------------------------------
DrawCallBanner:
        enter 0xe, 0x0
        push di
        push si
        mov ax, [TextOverlaySeg]
        mov cx, 0x2
        cwd
        idiv cx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        mov ax, [TextOverlayPtr]
        cwd
        idiv cx
        db 0x03, 0xDA                           ; insn: add bx, dx
        shl bx, 1
        mov ax, [bx + BannerColours]
        mov [bp - 0x8], ax
        mov si, [TextOverlaySeg]
        add si, 0xc
        mov ax, [TextOverlayPtr]
        add ax, 0x95
        db 0x8B, 0xF8                           ; insn: mov di, ax
        add ax, strict word 0x9
        mov [bp - 0x4], ax
        mov bx, [bp + 0x6]
        shl bx, 1
        push word [bx + CallNamePtrs]
        mov [bp - 0xa], bx
        call 0x03A3:TextWidthAll
        add sp, 0x2
        add ax, strict word 0x4
        mov [bp - 0x2], ax
        db 0x03, 0xC6                           ; insn: add ax, si
        mov [bp - 0x6], ax
        mov ax, [bp - 0x2]
        add ax, strict word 0x8
        mov [bp - 0x2], ax
        push word [bp - 0x4]
        push si
        push word [bp - 0x4]
        push word [bp - 0x6]
        push di
        push word [bp - 0x6]
        push di
        push si
        push 0x4
        push 0x10
        push 0x9
        push word [bp - 0x8]
        call 0x03A3:AddrFlag0
        add sp, 0x18
        push 0x0
        push 0x4
        push word [bp - 0x2]
        lea ax, [di - 0x4]
        push ax
        lea cx, [si - 0x4]
        push cx
        mov [bp - 0xc], ax
        mov [bp - 0xe], cx
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x9
        push 0x4
        push di
        push word [bp - 0xe]
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x9
        push 0x4
        push di
        push word [bp - 0x6]
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x0
        push 0x4
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0xe]
        call 0x0FEF:FillRect
        add sp, 0xa
        push word [MemBlock3Seg]
        push word [MemBlock3Off]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov ax, 0x25
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        lea ax, [di + 0x1]
        push ax
        lea cx, [si + 0x2]
        push cx
        mov bx, [bp - 0xa]
        push word [bx + CallNamePtrs]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x0FEF:DrawText
        add sp, 0x6
        push word [MemBlock2Seg]
        push word [MemBlock2Off]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov ax, 0x27
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        push si
        push di
        mov bx, [bp - 0xa]
        push word [bx + CallNamePtrs]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x11
        push word [bp - 0x2]
        push word [bp - 0xc]
        push word [bp - 0xe]
        call 0x1F54:AddDirtyRect
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ShowGoalieBanner                                           226F:0CE6  94 PC
; Pulled / returned goalie banner.
;
; Takes 1 word of stack arguments. Calls setpersonel. Far routine (retf).
;-----------------------------------------------------------------------------
ShowGoalieBanner:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        imul bx, si, word 0xd6
        mov [bp - 0x2], bx
        mov di, [bx + hmtmgoalie]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [cont1team]
        inc ax
        jz short .1
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [cont2team]
        inc ax
        jz short .1
        jmp near .9
.1:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        and al, 0xf0
        cmp ax, 0xff00
        jnz short .2
        jmp near .9
.2:
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .3
        mov dx, 0x1
        jmp short .4
.3:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.4:
        cmp dx, [bannermsg]
        jg short .5
        cmp word [bannermsg], 0x2
        jnl short .6
.5:
        mov [bannermsg], dx
        mov word [bannertimer], 0x50
.6:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .7
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDE                           ; insn: add bx, si
        shl bx, byte 0x2
        les bx, [bx + goaliemenuflags_e02]
        mov byte [es:bx], 0x2
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDE                           ; insn: add bx, si
        mov di, [bp - 0x2]
        and word [di + hmtmgoalie], 0xf
        add bx, [di + hmtmgoalie]
        shl bx, byte 0x2
        les bx, [bx + goaliemenuflags]
        jmp short .8
        db 0x90
.7:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        and di, 0xf
        shl di, byte 0x2
        les di, [bx + di + goaliemenuflags]
        mov byte [es:di], 0x2
        mov di, [bp - 0x2]
        or word [di + hmtmgoalie], -0x10
        les bx, [bx + goaliemenuflags_e02]
.8:
        mov byte [es:bx], 0x1
        mov ax, [bp - 0x2]
        add ax, 0xb362
        push ax
        call 0x2E42:setpersonel
        add sp, 0x2
.9:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetTeamGoalie                                              226F:0DAA  94 PC
; Sets a team's goalie from the goalie menu; a negative value pulls him.
;
; Takes 3 words of stack arguments.
;-----------------------------------------------------------------------------
SetTeamGoalie:
        enter 0x4, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        imul bx, si, word 0xd6
        mov [bp - 0x2], bx
        mov di, [bx + hmtmgoalie]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [cont1team]
        inc ax
        jz short .1
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [cont2team]
        inc ax
        jnz short SetTeamGoalieTail + 0xE30
.1:
        cmp word [bp + 0x8], 0x0
        jnl short .2
        or word [bx + hmtmgoalie], -0x10
        jmp short .5
        db 0x90
.2:
        mov ax, [bp + 0x8]
        mov [bx + hmtmgoalie], ax
        test byte [gmode], 0x1
        jnz short .5
        test byte [gmode], 0x8
        jz short .5
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x4], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .5
        cmp al, 0x6
        jnl short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        db 0x33, 0xC6                           ; insn: xor ax, si
        jz short .5
        mov bx, [bp - 0x2]
        or byte [bx + hmtmgoalie_b1], 0xff
.5:
        mov bx, [bp - 0x2]
        cmp word [bx + hmtmgoalie], 0x0
        jnl short .6
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short SetTeamGoalieTail + 0xE30
.6:
        cmp [bx + hmtmgoalie], di
        jz short SetTeamGoalieTail + 0xE30
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        add ax, 0xb362
