; Controller set-up dialog: the side each player controls in exhibition, playoff and league games (MENUS.OVL)

;-----------------------------------------------------------------------------
; MenuP1ControlsExh                                          1E45:0000  94 PC
; Controls dialog for player 1 (exhibition)
;
; Calls ControlsDlgExh. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP1ControlsExh:
        push 0x0
        push cs
        call ControlsDlgExh
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuP2ControlsExh                                          1E45:000A  94 PC
; Controls dialog for player 2 (exhibition)
;
; Calls ControlsDlgExh. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP2ControlsExh:
        push 0x1
        push cs
        call ControlsDlgExh
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; ControlsDlgExh                                             1E45:0014  94 PC
; Exhibition controls dialog.
;
; Takes 1 word of stack arguments. Calls GetPage, VgaCopyBytes, CopyPlane, DrawControlsDlg,
; DrawControlsOpts, ControlsDlgLoop, UseCurrentPage. Far routine (retf).
;-----------------------------------------------------------------------------
ControlsDlgExh:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [DbSaveMode], 0x2
        jnz short .2
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        call 0x0FEF:CopyPlane
        jmp short .4
.1:
        push word 0x3f00
        push word 0xbd00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        jmp short .3
        db 0x90
.2:
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
.3:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
.4:
        cmp word [DbSaveMode], 0x2
        jnz short .5
        mov ax, 0x1
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        push ax
        push cs
        call DrawControlsDlg
        add sp, 0x2
        push word [bp + 0x6]
        push cs
        call DrawControlsOpts
        add sp, 0x2
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push word [bp + 0x6]
        push cs
        call ControlsDlgLoop
        add sp, 0x2
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        cmp word [DbSaveMode], 0x2
        jnz short .7
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuP1ControlsInGame                                       1E45:00FE  94 PC
; In-game controls dialog, player 1.
;
; Calls ControlsDlgInGame. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP1ControlsInGame:
        push 0x0
        push cs
        call ControlsDlgInGame
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuP2ControlsInGame                                       1E45:0108  94 PC
; In-game controls dialog, player 2.
;
; Calls ControlsDlgInGame. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP2ControlsInGame:
        push 0x1
        push cs
        call ControlsDlgInGame
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; CtlSwapScoreFix                                            1E45:0112  94 PC
; Swaps the scoring side when a player changes team.
;
; Takes 1 word of stack arguments. Calls setpersonelThunk. Far routine (retf).
;-----------------------------------------------------------------------------
CtlSwapScoreFix:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        imul si, di, word 0xd6
        add si, 0xb362
        cmp word [si + 0x24], 0x0
        jl short .1
        jmp near .7
.1:
        test byte [si + 0x24], 0xf0
        jnz short .2
        jmp near .7
.2:
        and byte [si + 0x24], 0xf
        cmp di, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        imul bx, ax, word 0xd6
        mov ax, [bx + hmscore]
        sub ax, [si + 0xc]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .3
        cmp ax, strict word 0x2
        jg short .3
        cmp word [gsp], 0x2
        jnz short .3
        cmp word [gameclock], 0x3c
        jng short .7
.3:
        test byte [gmode], 0x1
        jnz short .6
        mov bx, [puckc]
        mov al, [bx]
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .6
        cmp al, 0x6
        jnl short .4
        mov ax, 0x1
        jmp short .5
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.5:
        db 0x33, 0xC7                           ; insn: xor ax, di
        jz short .6
        test byte [gmode], 0x8
        jnz short .7
.6:
        mov byte [si + 0x25], 0x0
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl di, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        shl di, byte 0x2
        les bx, [di + goaliemenuflags_e02]
        mov byte [es:bx], 0x2
        mov bl, [si + 0x24]
        and bx, 0xf
        shl bx, byte 0x2
        les bx, [bx + di + goaliemenuflags]
        mov byte [es:bx], 0x1
        push si
        call 0x1B35:setpersonelThunk
        add sp, 0x2
.7:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CtlSwapTeamFlag                                            1E45:01BC  94 PC
; Flips a player's team flag.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CtlSwapTeamFlag:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        imul si, di, word 0xd6
        add si, 0xb362
        cmp word [si + 0x24], 0x0
        jnl short .4
        test byte [si + 0x24], 0xf0
        jnz short .4
        test byte [gmode], 0x1
        jnz short .3
        mov bx, [puckc]
        mov al, [bx]
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .3
        cmp al, 0x6
        jnl short .1
        mov ax, 0x1
        jmp short .2
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        db 0x33, 0xC7                           ; insn: xor ax, di
        jz short .3
        test byte [gmode], 0x8
        jnz short .4
.3:
        or word [si + 0x24], -0x10
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReassignCtlPlayer                                          1E45:020A  94 PC
; Gives the controlled skater to the new side.
;
; Takes 1 word of stack arguments. Calls restoreplThunk, ImulRegs. Far routine (retf).
;-----------------------------------------------------------------------------
ReassignCtlPlayer:
        enter 0x16, 0x0
        push di
        push si
        cmp word [bp + 0x6], 0x0
        jz short .1
        mov bx, 0x29c8
        mov dx, 0x29c4
        jmp short .2
.1:
        mov bx, 0x29c6
        mov dx, 0x29c2
.2:
        cmp word [bx], 0x0
        jnz short .7
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cmp word [bx], -0x1
        jnz short .3
        jmp near .22
.3:
        mov si, 0xffff
.4:
        cmp word [bp + 0x6], 0x0
        jz short .5
        jmp near .21
.5:
        cmp [c1playernum], si
        jnz short .6
        jmp near .22
.6:
        push word [c1playernum]
        push si
        call 0x1B35:restoreplThunk
        add sp, 0x4
        mov [c1playernum], ax
        pop si
        pop di
        leave
        retf
.7:
        cmp word [bx], 0x1
        jnz short .8
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp word [si], 0x0
        jl short .8
        cmp word [si], 0x5
        jg short .8
        jmp near .22
.8:
        cmp word [bx], 0x2
        jnz short .9
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp word [si], 0x6
        jl short .9
        cmp word [si], 0xb
        jg short .9
        jmp near .22
.9:
        mov cl, 0x8
        mov si, [puckvx]
        mov di, [si]
        sar di, cl
        mov si, [puckx]
        add di, [si]
        mov si, [puckvy]
        mov ax, [si]
        sar ax, cl
        mov si, [pucky]
        add ax, [si]
        mov [bp - 0xc], ax
        mov word [bp - 0xa], 0x0
        mov word [bp - 0x8], 0x1000
        cmp word [bx], 0x1
        jnz short .10
        mov ax, 0xb50e
        jmp short .11
        db 0x90
.10:
        mov ax, 0xb80e
.11:
        mov word [bp - 0xe], 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
.12:
        cmp word [si + 0x1a], 0x0
        jnl short .13
        jmp near .19
.13:
        test byte [si + 0x45], 0x4
        jz short .14
        jmp near .19
.14:
        test byte [si + 0x44], 0x20
        jnz short .19
        db 0x8B, 0xD7                           ; insn: mov dx, di
        sub dx, [si + 0x2]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0xc]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [si + 0x6]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov [bp - 0x16], cx
        mov [bp - 0x14], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0x16]
        adc dx, [bp - 0x14]
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp [si + 0x5e], ax
        jnz short .15
        mov word [bp - 0x6], 0xffff
        mov word [bp - 0x4], 0xffff
.15:
        mov ax, [bp - 0x6]
        mov dx, [bp - 0x4]
        cmp [bp - 0x8], dx
        jl short .19
        jg short .16
        cmp [bp - 0xa], ax
        jc short .19
.16:
        mov cx, [si + 0x5e]
        cmp word [bp + 0x6], 0x0
        jz short .17
        mov ax, [c1playernum]
        jmp short .18
        db 0x90
.17:
        mov ax, [c2playernum]
.18:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .19
        mov ax, [bp - 0x6]
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        mov [bp - 0x12], cx
.19:
        add si, 0x80
        dec word [bp - 0xe]
        jz short .20
        jmp near .12
.20:
        mov si, [bp - 0x12]
        jmp near .4
        db 0x90
.21:
        cmp [c2playernum], si
        jz short .22
        push word [c2playernum]
        push si
        call 0x1B35:restoreplThunk
        add sp, 0x4
        mov [c2playernum], ax
.22:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ClearCtlBlink                                              1E45:0384  94 PC
; Clears the controller blink flags.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ClearCtlBlink:
        enter 0x8, 0x0
        push si
        mov word [bp - 0x8], 0xb378
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x4], ax
.1:
        cmp word [bp - 0x6], 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        inc bx
        inc bx
        cmp bx, [cont1team]
        jz short .3
        cmp bx, [cont2team]
        jz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x4]
        mov [bx + lcsel], ax
        mov bx, [bp - 0x4]
        mov [bx + lcboxon], ax
        cmp [bp - 0x4], ax
        jz short .4
        mov bx, 0xb853
.2:
        and byte [bx], 0xf7
        add bx, 0x80
        cmp bx, 0xbb53
        jc short .2
        jmp short .6
        db 0x90
.3:
        mov bx, [bp - 0x8]
        jmp short .10
        db 0x90
.4:
        mov bx, 0xb553
.5:
        and byte [bx], 0xf7
        add bx, 0x80
        cmp bx, 0xb853
        jc short .5
.6:
        mov bx, [bp - 0x8]
        and byte [bx + 0x14], 0xfd
        cmp word [bp - 0x6], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        imul si, ax, word 0xd6
        mov ax, [si + hmtmap]
        sub ax, [bx + 0xc]
        mov [bp - 0x2], ax
        mov si, [bx]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .7
        cmp si, 0x6
        jnl short .7
        mov word [bx], 0x6
.7:
        cmp word [bp - 0x2], 0x0
        jnl short .9
        cmp si, 0x5
        jg short .8
        cmp si, 0x4
        jnl short .9
.8:
        mov word [bx], 0x4
.9:
        cmp word [bp - 0x2], 0x0
        jnz short .10
        cmp si, 0x3
        jl short .10
        mov word [bx], 0x0
.10:
        add bx, 0xd6
        inc word [bp - 0x6]
        mov [bp - 0x8], bx
        add word [bp - 0x4], 0x2
        cmp word [bp - 0x4], 0x4
        jnl short .11
        jmp near .1
.11:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ControlsDlgInGame                                          1E45:0452  94 PC
; In-game controls dialog ('BKGD' saved under it)
;
; Takes 1 word of stack arguments. Calls GetPage, CopyPlane, UseOtherPage, AllocRecData, GetBlockAt,
; DrawControlsDlg, DrawControlsOpts, VgaCopyBytes and others. Far routine (retf).
;-----------------------------------------------------------------------------
ControlsDlgInGame:
        enter 0xa, 0x0
        push di
        push si
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseOtherPage
        push 0x0
        push 0x0
        push word 0x39c2
        push strict word str_Bkgd_10
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x8]
        mov cx, 0x9
        rep movsw
        pop ds
        mov bx, [bp - 0x8]
        mov word [es:bx], 0x1a
        les bx, [bp - 0x8]
        mov word [es:bx + 0x2], 0x8e
        push 0xa
        push 0xa
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x0
        push cs
        call DrawControlsDlg
        add sp, 0x2
        push word [bp + 0x6]
        push cs
        call DrawControlsOpts
        add sp, 0x2
        call 0x0FEF:CopyPlane
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push word [bp + 0x6]
        push cs
        call ControlsDlgLoop
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push 0xa
        push 0xa
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        call 0x0FEF:CopyPlane
.2:
        mov bx, [bp + 0x6]
        shl bx, 1
        cmp word [bx + ctl1team], 0x0
        jnl short .3
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        jmp short .4
.3:
        cmp word [bx + ctl1side], 0x1
        db 0x1B, 0xD2                           ; insn: sbb dx, dx
        inc dx
        inc dx
.4:
        mov di, [cont1team]
        mov ax, [cont2team]
        mov [bp - 0x4], ax
        cmp word [bp + 0x6], 0x0
        jz short .5
        mov [cont2team], dx
        jmp short .6
        db 0x90
.5:
        mov [cont1team], dx
.6:
        cmp word [ctl1team], 0x0
        jl short .7
        cmp word [ctl2team], 0x0
        jl short .7
        mov ax, [ctl1side]
        cmp [ctl2side], ax
        jnz short .7
        mov word [samesideflag], 0x1
        jmp short .8
        db 0x90
.7:
        mov word [samesideflag], 0x0
.8:
        mov ax, [bx + ctl1dev]
        cmp ax, strict word 0x10
        jz short .13
        ja short .14
        dec al
        jz short .9
        dec al
        jz short .10
        sub al, 0x2
        jz short .11
        sub al, 0x4
        jz short .12
        jmp short .14
        db 0x90
.9:
        mov bx, [bp + 0x6]
        mov byte [bx + PadStates], 0x1
        jmp short .14
.10:
        mov bx, [bp + 0x6]
        mov byte [bx + PadStates], 0x2
        jmp short .14
.11:
        mov bx, [bp + 0x6]
        mov byte [bx + PadStates], 0x4
        jmp short .14
.12:
        mov bx, [bp + 0x6]
        mov byte [bx + PadStates], 0x8
        jmp short .14
.13:
        mov bx, [bp + 0x6]
        mov byte [bx + PadStates], 0x0
.14:
        push word [bp + 0x6]
        push cs
        call ReassignCtlPlayer
        add sp, 0x2
        push cs
        call ClearCtlBlink
        mov si, 0x1
.15:
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jz short .16
        cmp [bp - 0x4], si
        jnz short .19
.16:
        cmp [cont1team], si
        jz short .19
        cmp [cont2team], si
        jz short .19
        cmp si, 0x2
        jnz short .17
        mov ax, 0x1
        jmp short .18
.17:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.18:
        push ax
        push cs
        call CtlSwapScoreFix
        jmp short .23
        db 0x90
.19:
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jz short .24
        cmp [bp - 0x4], si
        jz short .24
        cmp [cont1team], si
        jz short .20
        cmp [cont2team], si
        jnz short .24
.20:
        cmp si, 0x2
        jnz short .21
        mov ax, 0x1
        jmp short .22
        db 0x90
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        push ax
        push cs
        call CtlSwapTeamFlag
.23:
        add sp, 0x2
.24:
        inc si
        cmp si, 0x2
        jng short .15
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuP1ControlsPlayoff                                      1E45:0654  94 PC
; Playoff controls dialog, player 1.
;
; Calls ControlsDlgPlayoff. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP1ControlsPlayoff:
        push 0x0
        push cs
        call ControlsDlgPlayoff
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuP2ControlsPlayoff                                      1E45:065E  94 PC
; Playoff controls dialog, player 2.
;
; Calls ControlsDlgPlayoff. Far routine (retf).
;-----------------------------------------------------------------------------
MenuP2ControlsPlayoff:
        push 0x1
        push cs
        call ControlsDlgPlayoff
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; ControlsDlgPlayoff                                         1E45:0668  94 PC
; Playoff controls dialog.
;
; Takes 1 word of stack arguments. Calls GetPage, VgaCopyBytes, CopyPlane, UseOtherPage, AllocRecData,
; GetBlockAt, DrawControlsDlg, DrawControlsOpts and others. Far routine (retf).
;-----------------------------------------------------------------------------
ControlsDlgPlayoff:
        enter 0x4, 0x0
        push di
        push si
        mov es, [segDgroup1]
        les bx, [es:0x7570]
        mov di, [es:bx]
        mov es, [segDgroup1]
        les bx, [es:0x7574]
        mov si, [es:bx]
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x3e80
        push di
        push si
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        jmp short .2
        db 0x90
.1:
        push word 0x3e80
        push si
        push di
        call 0x0000:VgaCopyBytes
        add sp, 0x6
.2:
        call 0x0FEF:UseOtherPage
        push 0x0
        push 0x0
        push word 0x39c2
        push strict word str_Bkgd_9
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x4]
        mov cx, 0x9
        rep movsw
        pop ds
        mov bx, [bp - 0x4]
        mov word [es:bx], 0x1a
        les bx, [bp - 0x4]
        mov word [es:bx + 0x2], 0x8e
        push 0xa
        push 0xa
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x1
        push cs
        call DrawControlsDlg
        add sp, 0x2
        push word [bp + 0x6]
        push cs
        call DrawControlsOpts
        add sp, 0x2
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push word [bp + 0x6]
        push cs
        call ControlsDlgLoop
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push 0xa
        push 0xa
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        call 0x0FEF:CopyPlane
.3:
        mov bx, [bp + 0x6]
        shl bx, 1
        cmp word [bx + ctl1team], 0x0
        jnl short .4
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        jmp short .5
        db 0x90
.4:
        mov bx, [bp + 0x6]
        shl bx, 1
        cmp word [bx + ctl1side], 0x1
        db 0x1B, 0xD2                           ; insn: sbb dx, dx
        inc dx
        inc dx
.5:
        cmp word [bp + 0x6], 0x0
        jz short .6
        mov [cont2team], dx
        jmp short .7
.6:
        mov [cont1team], dx
.7:
        cmp word [ctl1team], 0x0
        jl short .8
        cmp word [ctl2team], 0x0
        jl short .8
        mov ax, [ctl1side]
        cmp [ctl2side], ax
        jnz short .8
        mov word [samesideflag], 0x1
        jmp short .9
        db 0x90
.8:
        mov word [samesideflag], 0x0
.9:
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawControlsDlg                                            1E45:07E2  94 PC
; Dialog box with both teams ('teams.db', 'player', 'dbox')
;
; Takes 1 word of stack arguments. Calls SetRemapTable, _open, FatalError, _lseek, _read, _close,
; UseOtherPage, BuildPathFar and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawControlsDlg:
        enter 0x116, 0x0
        push di
        push si
        cmp word [bp + 0x6], 0x0
        jz short .2
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x116], bl
        inc bx
        cmp bx, 0x100
        jl short .1
        mov byte [bp - 0x105], 0x7d
        mov byte [bp - 0x10b], 0x7c
        mov byte [bp - 0x111], 0x7b
        lea ax, [bp - 0x116]
        push ss
        push ax
        call 0x0FEF:SetRemapTable
        add sp, 0x4
.2:
        push word 0x8000
        push strict word str_TeamsDb
        call 0x0000:_open
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .3
        push word 0xa53
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0x0
        mov ax, 0x2e8
        imul word [HomeTeamNum]
        push dx
        push ax
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .4
        push word 0xa56
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push word 0x2e8
        push word 0x9f80
        push si
        call 0x0000:_read
        add sp, 0x6
        cmp ax, 0x2e8
        jz short .5
        push word 0xa59
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        push 0x0
        mov ax, 0x2e8
        imul word [VisTeamNum]
        push dx
        push ax
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .6
        push word 0xa5c
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push word 0x2e8
        push word 0xa268
        push si
        call 0x0000:_read
        add sp, 0x6
        cmp ax, 0x2e8
        jz short .7
        push word 0xa5f
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        push si
        call 0x0000:_close
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Player_3
        push 0x0
        push 0x0
        lea ax, [bp - 0x16]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x16]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        cmp word [bp + 0x6], 0x0
        jz short .8
        push 0xa
        push 0xa
        push strict word str_Dbox_12
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        jmp short .9
.8:
        push 0xa
        push 0xa
        push strict word str_Dbox_11
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransFastAt
.9:
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [bp + 0x6], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x94
        add ax, strict word 0x7d
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        mov es, [segSaveDialogRects1]
        mov ax, [es:0x2]
        add ax, strict word 0xb
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push word 0x92
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sub ax, [es:0x6]
        neg ax
        add ax, strict word 0xa
        push ax
        mov ax, [es:0x4]
        mov si, [es:0x0]
        add si, 0xb
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add ax, strict word 0xa
        push ax
        push cx
        push si
        call 0x0FEF:FillRect
        add sp, 0xa
        lea ax, [di + 0x2]
        push ax
        lea ax, [si + 0x2]
        push ax
        push word 0x9f9a
        call 0x0FEF:DrawText
        add sp, 0x6
        mov es, [segSaveDialogRects1]
        mov ax, [es:0xa]
        add ax, strict word 0xb
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push word 0x93
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sub ax, [es:0xe]
        neg ax
        add ax, strict word 0xa
        push ax
        mov ax, [es:0xc]
        mov si, [es:0x8]
        add si, 0xb
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add ax, strict word 0xa
        push ax
        push cx
        push si
        call 0x0FEF:FillRect
        add sp, 0xa
        lea ax, [di + 0x2]
        push ax
        lea ax, [si + 0x2]
        push ax
        push word 0xa282
        call 0x0FEF:DrawText
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawControlsOpts                                           1E45:09F2  94 PC
; The controller boxes.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, WaitRetraceEnd, SetPaletteFar. Far routine
; (retf).
;-----------------------------------------------------------------------------
DrawControlsOpts:
        enter 0x64, 0x0
        push si
        mov si, [bp + 0x6]
        lea ax, [bp - 0x60]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        mov al, 0x2a
        mov [bp - 0xd], al
        mov [bp - 0xe], al
        mov [bp - 0xf], al
        mov al, 0x3f
        jmp short .2
        db 0x90
.1:
        mov al, 0x3f
        mov [bp - 0xd], al
        mov [bp - 0xe], al
        mov [bp - 0xf], al
        mov al, 0x2a
.2:
        mov [bp - 0xa], al
        mov [bp - 0xb], al
        mov [bp - 0xc], al
        mov word [editopts], 0x0
        mov al, [InputFlags]
        and ax, strict word 0x8
        shr al, byte 0x3
        shl ax, 1
        mov cl, [InputFlags]
        and cx, 0x4
        shr cl, byte 0x2
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [InputFlags]
        and cx, 0x2
        shr cl, 1
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [InputFlags]
        and cx, 0x1
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, byte 0x2
        or ax, 0x1c3
        mov [editctlopts], ax
        cmp si, 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        neg bx
        shl bx, 1
        mov ax, [bx + ctl1dev]
        mov [bp - 0x62], ax
        cmp ax, strict word 0x10
        jz short .3
        shl ax, byte 0x2
        not ax
        and [editctlopts], ax
.3:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov [bp - 0x64], bx
        cmp word [bx + ctl1team], 0x0
        jnl short .5
        cmp word [bx + ctl1team], -0x1
        jnz short .4
        mov word [editopts], 0x41
        jmp short .6
        db 0x90
.4:
        cmp word [bx + ctl1team], -0x2
        jnz short .6
        mov word [editopts], 0x42
        jmp short .6
        db 0x90
.5:
        cmp word [bx + ctl1side], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        inc ax
        mov [editopts], ax
        mov ax, [bx + ctl1dev]
        shl ax, byte 0x2
        test [editctlopts], ax
        jz short .6
        mov ax, [bx + ctl1dev]
        shl ax, byte 0x2
        or [editopts], ax
.6:
        db 0x2B, 0xF6                           ; insn: sub si, si
.7:
        mov al, 0x3f
        mov [bp + si - 0x5e], al
        mov [bp + si - 0x5f], al
        mov [bp + si - 0x60], al
        mov al, 0x17
        mov [bp + si - 0x43], al
        mov [bp + si - 0x44], al
        mov [bp + si - 0x45], al
        mov al, 0x3f
        mov [bp + si - 0x28], al
        mov [bp + si - 0x29], al
        mov [bp + si - 0x2a], al
        add si, 0x3
        cmp si, 0x1b
        jl short .7
        mov al, 0x2a
        mov [bp - 0x25], al
        mov [bp - 0x26], al
        mov [bp - 0x27], al
        mov [bp - 0x28], al
        mov [bp - 0x29], al
        mov [bp - 0x2a], al
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        lea si, [bp - 0x5e]
.8:
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov ax, 0x1
        shl ax, cl
        test [editopts], ax
        jz short .9
        mov al, 0x17
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x3f
        mov [si + 0x1b], al
        mov [si + 0x1a], al
        mov [si + 0x19], al
.9:
        inc dx
        add si, 0x3
        lea ax, [bp - 0x43]
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        jc short .8
        mov dx, 0x2
        lea si, [bp - 0x22]
.10:
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov ax, 0x1
        shl ax, cl
        test [editctlopts], ax
        jnz short .11
        mov al, 0x17
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
.11:
        inc dx
        add si, 0x3
        lea ax, [bp - 0xd]
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        jc short .10
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x60]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CtlDlgHitTest                                              1E45:0B98  94 PC
; Box under the pointer.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CtlDlgHitTest:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov di, [bp + 0x6]
        sub di, 0xa
        sub word [bp + 0x8], 0xa
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov bx, 0x0
        mov [bp + 0x6], di
        mov ax, 0x35ee
        mov ds, ax
.1:
        cmp [bx], di
        jg short .2
        cmp [bx + 0x4], di
        jl short .2
        mov ax, [bp + 0x8]
        cmp [bx + 0x2], ax
        jg short .2
        cmp [bx + 0x6], ax
        jnl short .3
.2:
        inc cx
        add bx, 0x8
        cmp bx, strict word 0x48
        jc short .1
        mov ax, DGROUP
        mov ds, ax
        jmp short .4
.3:
        mov ax, DGROUP
        mov ds, ax
        mov bx, [bp + 0xa]
        mov [bx], cx
        mov ax, 0x1
        pop di
        leave
        retf
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawCtlBoxes                                               1E45:0BF0  94 PC
; Highlights the chosen boxes.
;
; Calls GetPaletteFar, WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
DrawCtlBoxes:
        enter 0x60, 0x0
        push di
        push si
        lea ax, [bp - 0x60]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        db 0x2B, 0xFF                           ; insn: sub di, di
        lea si, [bp - 0x5e]
.1:
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov ax, 0x1
        shl ax, cl
        test [editopts], ax
        jz short .2
        mov al, 0x17
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x3f
        jmp short .3
.2:
        mov al, 0x3f
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x17
.3:
        mov [si + 0x1b], al
        mov [si + 0x1a], al
        mov [si + 0x19], al
        inc di
        add si, 0x3
        lea ax, [bp - 0x43]
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        jc short .1
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x60]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ControlsDlgLoop                                            1E45:0C64  94 PC
; Controls dialog input loop.
;
; Takes 1 word of stack arguments. Calls MouseRead, UseCurrentPage, DrawRleTransAt, FlushInputEvents,
; GetInputEvent, VgaCopyRect, CtlDlgHitTest, DrawCtlBoxes and others. Far routine (retf).
;-----------------------------------------------------------------------------
ControlsDlgLoop:
        enter 0x16, 0x0
        push di
        push si
        mov es, [segDgroup1]
        les bx, [es:0x7570]
        mov si, [es:bx]
        mov es, [segDgroup1]
        les bx, [es:0x7574]
        mov ax, [es:bx]
        mov [bp - 0x4], ax
        cmp word [PlayoffDlgY], 0x50
        jnz short .1
        mov ax, 0xc8
        jmp short .2
        db 0x90
.1:
        mov ax, 0xb0
.2:
        mov [bp - 0x2], ax
        lea ax, [bp - 0x6]
        push ax
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0xe]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x8]
        mov [bp - 0xa], ax
        mov ax, [bp - 0x6]
        mov [bp - 0xc], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0xc]
        mov ax, [bp - 0xa]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
        mov di, [bp - 0x2]
.3:
        mov word [bp - 0xe], 0x0
        mov [bp - 0x12], si
.4:
        call 0x0F99:GetInputEvent
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .5
        lea ax, [bp - 0xc]
        push ax
        lea ax, [bp - 0xa]
        push ax
        push si
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0xe], ax
        test byte [bp - 0xe], 0x6
        jz short .4
.5:
        mov al, [bp - 0xe]
        and al, 0x2
        jz short .6
        jmp near .12
.6:
        test byte [bp - 0xe], 0x4
        jz short .7
        jmp near .12
.7:
        mov si, [bp - 0x12]
        mov ax, [bp - 0x8]
        cmp [bp - 0xa], ax
        jnz short .8
        mov ax, [bp - 0x6]
        cmp [bp - 0xc], ax
        jz short .3
.8:
        call 0x0FEF:UseCurrentPage
        cmp [bp - 0x6], di
        jnl short .11
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x6]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .9
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [bp - 0x6]
        push ax
        jmp short .10
.9:
        push word [es:bx + 0x2]
.10:
        mov ax, [es:bx]
        inc ax
        push ax
        push word [bp - 0x6]
        mov ax, [bp - 0x8]
        sub ax, strict word 0x4
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push si
        push word [bp - 0x4]
        call 0x0000:VgaCopyRect
        add sp, 0xc
.11:
        push word [bp - 0xc]
        mov ax, [bp - 0xa]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0xa]
        mov [bp - 0x8], ax
        mov ax, [bp - 0xc]
        mov [bp - 0x6], ax
        jmp near .3
.12:
        mov si, [bp - 0x12]
        mov al, [bp - 0xe]
        and al, 0x2
        jnz short .13
        jmp near .32
.13:
        cmp [bp - 0x6], di
        jnl short .16
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x6]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .14
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [bp - 0x6]
        push ax
        jmp short .15
        db 0x90
.14:
        push word [es:bx + 0x2]
.15:
        mov ax, [es:bx]
        inc ax
        push ax
        push word [bp - 0x6]
        mov ax, [bp - 0x8]
        sub ax, strict word 0x4
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push si
        push word [bp - 0x4]
        call 0x0000:VgaCopyRect
        add sp, 0xc
.16:
        lea ax, [bp - 0x10]
        push ax
        push word [bp - 0xc]
        push word [bp - 0xa]
        push cs
        call CtlDlgHitTest
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .17
        jmp near .31
.17:
        mov cl, [bp - 0x10]
        mov ax, 0x1
        shl ax, cl
        mov [bp - 0x10], ax
        test [editopts], ax
        jz short .18
        jmp near .31
.18:
        mov ax, [editctlopts]
        test [bp - 0x10], ax
        jnz short .19
        jmp near .31
.19:
        mov ax, [bp - 0x10]
        cmp ax, strict word 0x10
        jz short .26
        jg short .20
        dec ax
        jz short .22
        dec ax
        jz short .23
        dec ax
        dec ax
        jz short .24
        sub ax, strict word 0x4
        jz short .25
        jmp short .30
        db 0x90
.20:
        sub ax, strict word 0x20
        jz short .27
        sub ax, strict word 0x20
        jz short .28
        sub ax, strict word 0x40
        jz short .34
        sub ax, 0x80
        jnz short .21
        jmp near .45
.21:
        jmp short .30
        db 0x90
.22:
        mov ax, [editopts]
        and al, 0xfd
        or al, 0x1
        jmp short .29
        db 0x90
.23:
        mov ax, [editopts]
        and al, 0xfe
        or al, 0x2
        jmp short .29
        db 0x90
.24:
        mov ax, [editopts]
        and al, 0x87
        or al, 0x4
        jmp short .29
        db 0x90
.25:
        mov ax, [editopts]
        and al, 0x8b
        or al, 0x8
        jmp short .29
        db 0x90
.26:
        mov ax, [editopts]
        and al, 0x93
        or al, 0x10
        jmp short .29
        db 0x90
.27:
        mov ax, [editopts]
        and al, 0xa3
        or al, 0x20
        jmp short .29
        db 0x90
.28:
        mov ax, [editopts]
        and al, 0xc3
        or al, 0x40
.29:
        mov [editopts], ax
.30:
        push cs
        call DrawCtlBoxes
.31:
        call 0x0FEF:UseCurrentPage
        jmp near .11
.32:
        test byte [bp - 0xe], 0x4
        jnz short .33
        jmp near .3
.33:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.34:
        mov bx, [bp + 0x6]
        mov ax, [editopts]
        sar ax, byte 0x2
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, 1
        mov [bp - 0x14], si
        mov [si + ctl1dev], ax
        cmp word [editopts], 0x41
        jnz short .39
        mov si, [bp - 0x14]
        mov word [si + ctl1team], 0xffff
        mov word [si + ctl1side], 0x0
        cmp bx, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        neg si
        shl si, 1
        mov [bp - 0x16], si
        cmp word [si + ctl1team], -0x1
        jnz short .37
.35:
        mov word [si + ctl1team], 0xfffe
.36:
        mov word [si + ctl1side], 0x1
        jmp near .44
.37:
        cmp word [si + ctl1side], 0x0
        jz short .38
        jmp near .44
.38:
        mov ax, [VisTeamNum]
        mov [si + ctl1team], ax
        jmp short .36
        db 0x90
.39:
        cmp word [editopts], 0x42
        jnz short .40
        mov si, [bp - 0x14]
        mov word [si + ctl1team], 0xfffe
        mov word [si + ctl1side], 0x1
        cmp bx, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        neg si
        shl si, 1
        mov [bp - 0x16], si
        cmp word [si + ctl1team], -0x2
        jz short .42
        cmp word [si + ctl1side], 0x1
        jnz short .44
        mov ax, [HomeTeamNum]
        mov [si + ctl1team], ax
        jmp short .43
        db 0x90
.40:
        test byte [editopts], 0x1
        jz short .41
        mov ax, [HomeTeamNum]
        mov si, [bp - 0x14]
        mov [si + ctl1team], ax
        mov word [si + ctl1side], 0x0
        cmp bx, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        neg si
        shl si, 1
        mov [bp - 0x16], si
        cmp word [si + ctl1team], -0x1
        jnz short .44
        jmp near .35
        db 0x90
.41:
        mov ax, [VisTeamNum]
        mov si, [bp - 0x14]
        mov [si + ctl1team], ax
        mov word [si + ctl1side], 0x1
        cmp bx, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        neg si
        shl si, 1
        mov [bp - 0x16], si
        cmp word [si + ctl1team], -0x2
        jnz short .44
.42:
        mov word [si + ctl1team], 0xffff
.43:
        mov word [si + ctl1side], 0x0
.44:
        call 0x2037:SetSideControls
        call 0x0F97:UseDbDescriptor
.45:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetCtlTeams                                                1E45:0FD2  94 PC
; Applies the chosen controllers to the teams.
;
; Takes 5 words of stack arguments.
;-----------------------------------------------------------------------------
SetCtlTeams:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov dx, [bp + 0x6]
        mov bx, [bp + 0xa]
        mov ax, [bp + 0xc]
        mov [VisTeamNum], ax
        mov [ctl1team], dx
        mov [HomeTeamNum], bx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jnz short .2
        cmp word [ctl1dev], 0x10
        jnz short .1
        mov word [ctl1team], 0xffff
.1:
        mov word [ctl1side], 0x0
        jmp short .4
.2:
        cmp word [ctl1dev], 0x10
        jnz short .3
        mov word [ctl1team], 0xfffe
.3:
        mov word [ctl1side], 0x1
.4:
        cmp word [bp + 0x8], 0x0
        jnl short .7
        cmp word [ctl1side], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        mov [ctl2side], ax
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jnz short .5
        mov ax, 0xfffe
        jmp short .6
.5:
        mov ax, 0xffff
.6:
        mov [ctl2team], ax
        mov word [ctl2dev], 0x10
        jmp short SetCtlTeamsTail.1 + 0x10A0
        db 0x90, 0x90
.7:
        mov dx, [bp + 0x8]
        mov [ctl2team], dx
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jnz short .8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        jmp short .9
        db 0x90
.8:
        mov ax, 0x1
.9:
        mov [ctl2side], ax
        cmp word [ctl2dev], 0x10
        jnz short SetCtlTeamsTail.1 + 0x10A0
        test byte [InputFlags], 0x2
        jz short .10
        cmp word [ctl1dev], 0x2
        jz short .10
        mov word [ctl2dev], 0x2
        jmp short SetCtlTeamsTail.1 + 0x10A0
        db 0x90
.10:
        test byte [InputFlags], 0x4
        jz short .11
        cmp word [ctl1dev], 0x4
        jz short .11
        mov word [ctl2dev], 0x4
        jmp short SetCtlTeamsTail.1 + 0x10A0
.11:
        test byte [InputFlags], 0x8
        jz short SetCtlTeamsTail + 0x10A0
        cmp word [ctl1dev], 0x8
        jz short SetCtlTeamsTail + 0x10A0
        mov word [ctl2dev], 0x8
        jmp short SetCtlTeamsTail.1 + 0x10A0
