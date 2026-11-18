; Game core: sprites, teams, clock, periods and the frame loop (AI.OVL)
; The first bytes and assbenchsideTail finish assbenchside from intro.asm.
        call 0x2E42:SetSPA
assbenchsideTail:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ToFixed                                                    2E42:000A  94 PC
; DX:AX words swapped: a value in AX comes back as AX << 16; passtoa0 uses it.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ToFixed:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push dx
        push ax
        xchg ax, dx
        leave
        retf

;-----------------------------------------------------------------------------
; SetSPA                                                     2E42:0012  94 PC
; New animation in AX for the player in BX: SPAnum 0, SPAcnt -1.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
SetSPA:
        cmp [bx + 0x38], ax
        jz short .1
        mov word [bx + 0x3a], 0x0
        mov [bx + 0x38], ax
        mov word [bx + 0x3c], 0xffff
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SprSort                                                    2E42:0026  94 PC
; Copies each sort object's y (x when the flag is set) and bubble sorts.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
SprSort:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
        push di
        push si
        mov bx, objxlist
        mov di, SortCords
        mov dx, 0x11
.1:
        test byte [sflags], 0x80
        jz short .2
        mov ax, [di + 0x2]
        jmp short .3
.2:
        mov ax, [di + 0x6]
.3:
        inc bx
        inc bx
        mov [bx - 0x2], ax
        add di, 0x80
        dec dx
        jnz short .1
.4:
        mov byte [bp - 0x5], 0x0
        mov si, OOlist
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov word [bp - 0x4], 0x10
.5:
        lodsb
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        inc dx
        mov al, [si]
        cbw
        mov [bp - 0x2], ax
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov cx, [bx + objxlist]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp [bx + objxlist], cx
        jnl short .6
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov [si], al
        mov al, [bp - 0x2]
        mov [si - 0x1], al
        shl di, 1
        mov [di + objylist], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        dec ax
        mov bx, [bp - 0x2]
        shl bx, 1
        mov [bx + objylist], ax
        mov byte [bp - 0x5], 0x1
.6:
        dec word [bp - 0x4]
        jnz short .5
        cmp byte [bp - 0x5], 0x0
        jnz short .4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; changeplayer                                               2E42:00B2  94 PC
; Human control moves to the teammate nearest the puck; restorepl for the old one.
;
; Takes 2 words of stack arguments. Calls __chkstk, ImulRegs, Sweepcheck, restorepl. Far routine
; (retf).
;-----------------------------------------------------------------------------
changeplayer:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x14
        call 0x0000:__chkstk
        push di
        push si
        mov cl, 0x8
        mov bx, [puckvx]
        mov di, [bx]
        sar di, cl
        mov bx, [puckx]
        add di, [bx]
        mov bx, [puckvy]
        mov ax, [bx]
        sar ax, cl
        mov bx, [pucky]
        add ax, [bx]
        mov [bp - 0xa], ax
        mov word [bp - 0x8], 0xffff
        mov word [bp - 0x6], 0xffff
        cmp word [bp + 0x8], 0x0
        jz short .1
        mov ax, [cont2team]
        jmp short .2
        db 0x90
.1:
        mov ax, [cont1team]
.2:
        dec ax
        jz short .3
        mov si, SortCords + 6 * 0x80
        jmp short .4
        db 0x90
.3:
        mov si, SortCords
.4:
        mov word [bp - 0xc], 0x6
.5:
        cmp word [si + 0x1a], 0x0
        jng short .9
        test byte [si + 0x45], 0x4
        jnz short .9
        test byte [si + 0x44], 0x20
        jnz short .9
        mov ax, [bp - 0xa]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [si + 0x6]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [si + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov [bp - 0x14], cx
        mov [bp - 0x12], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0x14]
        adc dx, [bp - 0x12]
        mov [bp - 0x4], ax
        cmp dx, [bp - 0x6]
        ja short .9
        jc short .6
        cmp ax, [bp - 0x8]
        ja short .9
.6:
        mov cx, [si + 0x5e]
        cmp word [bp + 0x8], 0x0
        jz short .7
        mov ax, [c1playernum]
        jmp short .8
.7:
        mov ax, [c2playernum]
.8:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .9
        mov ax, [bp - 0x4]
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov [bp - 0x10], cx
.9:
        add si, 0x80
        dec word [bp - 0xc]
        jnz short .5
        mov si, [bp - 0x10]
        mov dx, [bp + 0x8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .10
        mov ax, [c2playernum]
        jmp short .11
        db 0x90
.10:
        mov ax, [c1playernum]
.11:
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jnz short .12
        push word [bp + 0x6]
        call 0x28BB:Sweepcheck
        add sp, 0x2
        pop si
        pop di
        leave
        retf
.12:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .13
        cmp [c1playernum], si
        jz short .14
        push word [c1playernum]
        push si
        push cs
        call restorepl
        add sp, 0x4
        mov [c1playernum], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.13:
        cmp [c2playernum], si
        jz short .14
        push word [c2playernum]
        push si
        push cs
        call restorepl
        add sp, 0x4
        mov [c2playernum], ax
.14:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; restorepl                                                  2E42:01DE  94 PC
; (new, old): the old player gets his assignment back.
;
; Takes 2 words of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
restorepl:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push di
        push si
        mov bx, [bp + 0x8]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jl short .1
        cmp bx, 0xb
        jg short .1
        db 0x8B, 0xFB                           ; insn: mov di, bx
        shl di, byte 0x7
        add di, SortCords
        test byte [di + 0x45], 0x8
        jnz short .2
        and byte [di + 0x44], 0xf7
        or byte [di + 0x44], 0x2
.1:
        mov bx, [bp + 0x6]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jl short .2
        cmp bx, 0xb
        jg short .2
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x7
        or byte [si + CwdExciteLvl], 0x8
.2:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AvgCline                                                   2E42:022A  94 PC
; Average energy of the current line's skaters.
;
; Takes 1 word of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
AvgCline:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        push si
        mov bx, [bp + 0x6]
        mov si, [bx + 0xd4]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [regd0_w2], ax
        mov [regd0], ax
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov cx, 0x6
        db 0x8B, 0xD1                           ; insn: mov dx, cx
.1:
        cmp word [si + 0x1a], 0x0
        jng short .2
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [bp + 0x6]
        mov ax, [bx + 0x2c]
        add [regd0], ax
        inc di
.2:
        add si, 0x80
        dec dx
        jnz short .1
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .3
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov ax, [regd0]
        mov dx, [regd0_w2]
        call 0x03A3:DivWords.regs
        mov [regd0], ax
.3:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CompLine                                                   2E42:0286  94 PC
; The computer's line choice by the strength difference; calls getlinee.
;
; Takes 2 words of stack arguments. Calls __chkstk, getlinee, DrawPanelLine, AvgCline. Far routine
; (retf).
;-----------------------------------------------------------------------------
CompLine:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xc
        call 0x0000:__chkstk
        push di
        push si
        mov bx, [bp + 0x6]
        mov di, [bp + 0x8]
        mov ax, [di + 0x22]
        sub ax, [bx + 0x22]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        mov si, 0x4
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .1
        mov si, 0x6
.1:
        push si
        push di
        push cs
        call getlinee
        add sp, 0x4
        mov [bp - 0x2], ax
        cmp ax, 0xf33
        jnl short .2
        lea ax, [si + 0x1]
        push ax
        push di
        push cs
        call getlinee
        add sp, 0x4
        cmp ax, [bp - 0x2]
        jng short .2
        lea ax, [si + 0x1]
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        mov [di + 0x16], si
        push si
        cmp di, awshots
        jnz short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        push ax
        call 0x2083:DrawPanelLine
        add sp, 0x4
        and byte [di + 0xba], 0xbf
        pop si
        pop di
        leave
        retf
.5:
        test byte [di + 0xba], 0x1
        jz short .11
        mov si, [di + 0x16]
        test byte [gmode], 0x1
        jz short .8
        cmp si, 0x4
        jnl short .8
        test byte [di + 0xba], 0x40
        jnz short .8
        push di
        push cs
        call AvgCline
        add sp, 0x2
        mov ax, [di + 0x22]
        mov bx, [bp + 0x6]
        cmp [bx + 0x22], ax
        jnz short .6
        mov dx, [di + 0xbc]
        jmp short .7
.6:
        mov dx, 0xf33
.7:
        cmp dx, [regd0]
        jnc short .8
        jmp near .23
.8:
        cmp si, 0x3
        jng short .9
        mov si, 0x3
.9:
        cmp byte [di + 0xbb], 0x6
        jnz short .13
        cmp si, 0x4
        jl short .10
        cmp si, 0x5
        jng short .13
.10:
        mov si, 0x3
        jmp short .13
.11:
        mov si, [bx + 0x16]
        cmp si, 0x6
        jl short .12
        sub si, 0x6
        jmp short .13
        db 0x90
.12:
        cmp si, 0x4
        jl short .13
        sub si, 0x4
.13:
        cmp byte [di + 0xbb], 0x1
        jnz short .14
        test byte [di + 0xba], 0x80
        jz short .14
        add si, 0x4
.14:
        mov al, [di + 0xbb]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        shl si, byte 0x2
        add si, [bx + coachlinetab]
        mov [bp - 0x6], si
        mov ax, [di + 0x16]
        mov [bp - 0xa], ax
        push ax
        push di
        push cs
        call getlinee
        add sp, 0x4
        mov [bp - 0x8], ax
        mov word [bp - 0x4], 0x0
.15:
        mov bx, [bp - 0x6]
        inc word [bp - 0x6]
        mov al, [bx]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .17
        push si
        push word [bp + 0x8]
        push cs
        call getlinee
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov bx, [bp + 0x8]
        cmp [bx + 0xbc], di
        jc short .17
        cmp [bp - 0x8], di
        jnl short .16
        mov [bp - 0x8], di
        mov [bp - 0xa], si
.16:
        mov si, 0xffff
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x4
        jl short .15
.17:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .18
        mov si, [bp - 0xa]
.18:
        mov di, [bp + 0x8]
        cmp [di + 0x16], si
        jz short .20
        mov [di + 0x16], si
        cmp byte [di + 0xbb], 0x1
        jnz short .19
        cmp si, 0x2
        jnz short .19
        xor byte [di + 0xba], 0x80
.19:
        cmp si, 0x4
        jnl short .20
        inc word [di + 0x18]
        cmp word [di + 0x18], 0x3
        jl short .20
        sub word [di + 0x18], 0x3
.20:
        push si
        mov [bp - 0xc], di
        cmp di, awshots
        jnz short .21
        mov ax, 0x1
        jmp short .22
        db 0x90
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        push ax
        call 0x2083:DrawPanelLine
        add sp, 0x4
        mov bx, [bp - 0xc]
        and byte [bx + 0xba], 0xbf
.23:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; getlinee                                                   2E42:0444  94 PC
; Compares line energies for CompLine.
;
; Takes 2 words of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
getlinee:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x8]
        cmp di, 0x4
        jnl short .1
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl ax, 1
        db 0x03, 0xC7                           ; insn: add ax, di
        mov bx, [bp + 0x6]
        add ax, [bx + 0xbe]
        mov [bp - 0x2], ax
        mov bx, 0x3
        jmp short .3
.1:
        cmp di, 0x6
        jnl short .2
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl ax, byte 0x2
        db 0x03, 0xC7                           ; insn: add ax, di
        mov bx, [bp + 0x6]
        add ax, [bx + 0xbe]
        dec ax
        dec ax
        mov [bp - 0x2], ax
        mov bx, 0x5
        jmp short .3
        db 0x90
.2:
        shl di, byte 0x2
        mov bx, [bp + 0x6]
        add di, [bx + 0xbe]
        add di, 0x4
        mov [bp - 0x2], di
        mov bx, 0x4
.3:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .5
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov si, [bp - 0x2]
        mov [bp - 0x4], bx
.4:
        inc si
        mov bl, [si - 0x1]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        add bx, [bp + 0x6]
        add di, [bx + 0x2c]
        dec dx
        jnz short .4
        mov bx, [bp - 0x4]
.5:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        idiv bx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TeamLineEnergy                                             2E42:04CA  94 PC
; GetLineEnergies calls it per line.
;
; Takes 2 words of stack arguments. Calls __chkstk, getlinee. Far routine (retf).
;-----------------------------------------------------------------------------
TeamLineEnergy:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push di
        push word [bp + 0x8]
        cmp word [bp + 0x6], 0x0
        jng short .1
        mov di, awshots
        jmp short .2
        db 0x90
.1:
        mov di, hmshots
.2:
        push di
        push cs
        call getlinee
        add sp, 0x4
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; findpc                                                     2E42:04F2  94 PC
; Where the puck crosses each goal line; pucknorm calls it.
;
; Calls __chkstk, __aFldiv, ImulRegs. Far routine (retf).
;-----------------------------------------------------------------------------
findpc:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xc
        call 0x0000:__chkstk
        push di
        push si
        mov di, puckcross
        mov word [bp - 0x4], 0xe8
        mov si, 0xa0
        mov word [bp - 0x6], 0x2
.1:
        mov ax, [bp - 0x4]
        mov bx, [pucky]
        sub ax, [bx]
        mov [bp - 0x2], ax
        cwd
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        mov bx, [puckvy]
        mov ax, [bx]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        jmp near .5
.2:
        cwd
        push dx
        push ax
        mov ax, [bp - 0xa]
        mov dx, [bp - 0x8]
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .5
        cmp dx, 0x1
        jg short .5
        jnl short .5
        mov [di + 0x2], ax
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        push dx
        push ax
        mov bx, [puckvx]
        mov dx, [bx]
        mov ax, [bp - 0x2]
        call 0x03A3:ImulRegs
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        cmp dx, 0x1
        jg short .5
        jnl short .5
        mov bx, [puckx]
        mov ax, [bx]
        add [bp - 0xa], ax
        cmp word [bp - 0xa], 0xa0
        jl short .3
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, 1
        sub ax, [bp - 0xa]
        mov [bp - 0xa], ax
.3:
        neg si
        cmp si, [bp - 0xa]
        jl short .4
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, 1
        sub ax, [bp - 0xa]
        mov [bp - 0xa], ax
.4:
        neg si
        mov ax, [bp - 0xa]
        mov [di], ax
        jmp short .6
.5:
        mov word [di + 0x2], 0xffff
.6:
        add di, 0x4
        neg word [bp - 0x4]
        dec word [bp - 0x6]
        jz short .7
        jmp near .1
.7:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; forcepldata                                                2E42:05E2  94 PC
; Forceteams calls it per team after setpersonel.
;
; Takes 1 word of stack arguments. Calls __chkstk, Setplass, assinsert, setplayer. Far routine (retf).
;-----------------------------------------------------------------------------
forcepldata:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [di + 0xd4]
        mov word [bp - 0x2], 0x6
.1:
        mov al, [si + 0x42]
        cbw
        mov [si + 0x1a], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .3
        push si
        push cs
        call Setplass
        add sp, 0x2
        cmp word [si + 0x1a], 0x4
        jnz short .2
        push 0x11
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.2:
        mov al, [si + 0x43]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov word [bx + di + 0x64], 0xffff
        mov al, [si + 0x43]
        cbw
        imul bx, ax, 0x28
        add bx, [di + 0xd0]
        mov byte [bx], 0x4
        mov al, [si + 0x43]
        cbw
        push ax
        push si
        push cs
        call setplayer
        add sp, 0x4
.3:
        mov al, 0xff
        mov [si + 0x43], al
        mov [si + 0x42], al
        add si, 0x80
        dec word [bp - 0x2]
        jnz short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; GetHot                                                     2E42:065C  94 PC
; Hot spot of the player's frame from the HotList table, mirrored by the facing flags.
;
; Takes 1 word of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
GetHot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [regd1], ax
        mov [regd0], ax
        mov si, [di + 0x12]
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .4
        cmp si, 0x288
        jg short .1
        shl si, 1
        mov al, [si + HotList_m1]
        cbw
        mov [regd0], ax
        mov al, [si + HotList]
        cbw
        mov [regd1], ax
.1:
        test byte [di + 0x49], 0x8
        jz short .2
        neg word [regd0]
.2:
        test byte [di + 0x49], 0x10
        jnz short .3
        neg word [regd1]
.3:
        test byte [sflags], 0x80
        jz short .4
        mov dx, [regd0]
        mov ax, [regd1]
        mov [regd0], ax
        mov [regd1], dx
        neg dx
        mov [regd1], dx
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetCoachMode                                               2E42:06C6  94 PC
; Sets a team's coach mode.
;
; Takes 1 word of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
SetCoachMode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov dx, [hmscore]
        sub dx, [awscore]
        cmp word [bp + 0x6], 0x0
        jnz short .3
        cmp dx, -0x1
        jnl short .1
        and byte [hmtmcoachflags], 0xfe
        mov byte [hmtmcoachmode], 0x5
        leave
        retf
        db 0x90
.1:
        cmp dx, 0x3
        jng short .2
        mov word [hmtmcoachenergy], 0xd9a
        and byte [hmtmcoachflags], 0xfe
        mov byte [hmtmcoachmode], 0x4
        mov byte [hmtmcoach_d2], 0x3
        mov byte [hmtmcoach_d3], 0x2
        leave
        retf
        db 0x90
.2:
        mov word [hmtmcoachenergy], 0xccc
        mov byte [hmtmcoachmode], 0x0
        and byte [hmtmcoachflags], 0xfe
        leave
        retf
.3:
        cmp dx, 0x1
        jng short .4
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0x8
        leave
        retf
        db 0x90
.4:
        cmp dx, -0x3
        jnl short .5
        mov word [awtmcoachenergy], 0xd9a
        mov byte [awtmcoach_d2], 0x3
        mov byte [awtmcoach_d3], 0x2
        jmp short .6
        db 0x90
.5:
        mov word [awtmcoachenergy], 0xccc
.6:
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; InitCoachModes                                             2E42:0760  94 PC
; Resets both teams' coach modes at period start.
;
; Calls __chkstk, SetCoachMode. Far routine (retf).
;-----------------------------------------------------------------------------
InitCoachModes:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [awtmcoachflags], al
        mov [hmtmcoachflags], al
        mov al, 0x3
        mov [hmtmcoach_d2], al
        mov [awtmcoach_d2], al
        mov al, 0x2
        mov [hmtmcoach_d3], al
        mov [awtmcoach_d3], al
        cmp word [curperiod], 0x3
        jng short .1
        mov [hmtmcoachmode], al
        mov byte [hmtmcoachflags], 0x0
        mov ax, 0xd9a
        mov [hmtmcoachenergy], ax
        mov [awtmcoachenergy], ax
        mov byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0x8
        jmp short .3
        db 0x90
.1:
        cmp word [curperiod], 0x3
        jnz short .2
        push 0x0
        push cs
        call SetCoachMode
        add sp, 0x2
        push 0x1
        push cs
        call SetCoachMode
        add sp, 0x2
        jmp short .3
        db 0x90
.2:
        mov byte [hmtmcoachmode], 0x0
        mov byte [hmtmcoachflags], 0x0
        mov ax, 0xccc
        mov [hmtmcoachenergy], ax
        mov [awtmcoachenergy], ax
        mov byte [awtmcoachflags], 0x1
        or byte [awtmcoachflags], 0x80
        mov byte [awtmcoachmode], 0x1
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [awtmlcnt], ax
        mov [awtmline], ax
        mov [hmtmlcnt], ax
        mov [hmtmline], ax
        test byte [CrowdState], 0x4
        jz short .5
        cmp word [cont1team], 0x1
        jz short .4
        cmp word [cont2team], 0x1
        jz short .4
        mov word [hmtmlcnt], 0x2
.4:
        cmp word [cont1team], 0x2
        jz short .5
        cmp word [cont2team], 0x2
        jz short .5
        mov word [awtmline], 0x3
        mov word [awtmlcnt], 0x2
.5:
        retf

;-----------------------------------------------------------------------------
; UpdateCoachModes                                           2E42:0826  94 PC
; Once a second, picks each team's coach mode from the score, the time left and penalties.
;
; Calls __chkstk, SetCoachMode. Far routine (retf).
;-----------------------------------------------------------------------------
UpdateCoachModes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        test byte [gmode], 0x10
        jz short .1
        jmp near .39
.1:
        mov si, [hmscore]
        sub si, [awscore]
        cmp word [curperiod], 0x2
        jz short .2
        jmp near .12
.2:
        cmp word [gameclock], 0x258
        jng short .3
        jmp near .12
.3:
        mov al, [hmtmcoachmode]
        mov [bp - 0x1], al
        push 0x0
        push cs
        call SetCoachMode
        add sp, 0x2
        mov al, [bp - 0x1]
        cmp [hmtmcoachmode], al
        jz short .4
        or byte [hmtmcoachflags], 0x40
.4:
        mov al, [awtmcoachmode]
        mov [bp - 0x1], al
        push 0x1
        push cs
        call SetCoachMode
        add sp, 0x2
        mov al, [bp - 0x1]
        cmp [awtmcoachmode], al
        jz short .5
        or byte [awtmcoachflags], 0x40
.5:
        cmp word [gameclock], 0x258
        jz short .6
        jmp near .39
.6:
        cmp si, -0x1
        jnl short .8
        cmp byte [hmtmcoach_d2], 0x4
        jnc short .7
        inc byte [hmtmcoach_d2]
.7:
        cmp byte [hmtmcoach_d3], 0x1
        jna short .8
        dec byte [hmtmcoach_d3]
.8:
        cmp si, 0x1
        jg short .9
        jmp near .39
.9:
        cmp byte [awtmcoach_d2], 0x4
        jnc short .10
        inc byte [awtmcoach_d2]
.10:
        cmp byte [awtmcoach_d3], 0x1
        ja short .11
        jmp near .39
.11:
        dec byte [awtmcoach_d3]
        pop si
        leave
        retf
        db 0x90
.12:
        cmp word [curperiod], 0x3
        jz short .13
        jmp near .39
.13:
        mov al, [hmtmcoachmode]
        mov [bp - 0x1], al
        cmp word [gameclock], 0x3c
        jg short .16
        cmp si, -0x1
        jg short .16
.14:
        mov word [hmtmcoachenergy], 0xb33
        or byte [hmtmcoachflags], 0x1
        mov byte [hmtmcoachmode], 0x6
.15:
        mov byte [hmtmcoach_d2], 0x4
        mov byte [hmtmcoach_d3], 0x1
        jmp near .25
        db 0x90
.16:
        cmp word [gameclock], 0x78
        jg short .17
        cmp si, -0x1
        jl short .14
.17:
        cmp word [gameclock], 0xb4
        jg short .19
        cmp si, -0x1
        jg short .19
.18:
        mov word [hmtmcoachenergy], 0xb33
        or byte [hmtmcoachflags], 0x1
        mov byte [hmtmcoachmode], 0x7
        jmp short .15
        db 0x90
.19:
        cmp word [gameclock], 0x12c
        jg short .20
        cmp si, -0x1
        jl short .18
.20:
        cmp word [gameclock], 0x258
        jg short .24
        cmp si, -0x1
        jnl short .21
        mov word [hmtmcoachenergy], 0xb33
        or byte [hmtmcoachflags], 0x1
        mov byte [hmtmcoachmode], 0xa
        jmp short .15
.21:
        cmp si, 0x2
        jng short .22
        mov ax, 0xccc
        jmp short .23
.22:
        mov ax, 0xd9a
.23:
        mov [hmtmcoachenergy], ax
        and byte [hmtmcoachflags], 0xfe
        mov byte [hmtmcoachmode], 0x3
        mov byte [hmtmcoach_d2], 0x3
        mov byte [hmtmcoach_d3], 0x2
        jmp short .25
.24:
        push 0x0
        push cs
        call SetCoachMode
        add sp, 0x2
.25:
        mov al, [bp - 0x1]
        cmp [hmtmcoachmode], al
        jz short .26
        or byte [hmtmcoachflags], 0x40
.26:
        mov al, [awtmcoachmode]
        mov [bp - 0x1], al
        cmp word [gameclock], 0x3c
        jg short .29
        cmp si, 0x1
        jl short .29
.27:
        mov word [awtmcoachenergy], 0xb33
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0x6
.28:
        mov byte [awtmcoach_d2], 0x4
        mov byte [awtmcoach_d3], 0x1
        jmp near .38
.29:
        cmp word [gameclock], 0x78
        jg short .30
        cmp si, 0x1
        jg short .27
.30:
        cmp word [gameclock], 0xb4
        jg short .32
        cmp si, 0x1
        jng short .32
.31:
        mov word [awtmcoachenergy], 0xb33
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0x7
        jmp short .28
        db 0x90
.32:
        cmp word [gameclock], 0x12c
        jg short .33
        cmp si, 0x1
        jg short .31
.33:
        cmp word [gameclock], 0x258
        jg short .37
        cmp si, 0x1
        jng short .34
        mov word [awtmcoachenergy], 0xb33
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoachmode], 0xa
        jmp short .28
.34:
        cmp si, -0x2
        jnl short .35
        mov word [awtmcoachenergy], 0xccc
        mov byte [awtmcoachmode], 0x9
        jmp short .36
.35:
        mov word [awtmcoachenergy], 0xd9a
        mov byte [awtmcoachmode], 0x8
.36:
        or byte [awtmcoachflags], 0x1
        mov byte [awtmcoach_d2], 0x3
        mov byte [awtmcoach_d3], 0x2
        jmp short .38
.37:
        push 0x1
        push cs
        call SetCoachMode
        add sp, 0x2
.38:
        mov al, [bp - 0x1]
        cmp [awtmcoachmode], al
        jz short .39
        or byte [awtmcoachflags], 0x40
.39:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; PenTeamScored                                              2E42:0A7C  94 PC
; Returns 1 when the scoring team has a skater who caused the delayed penalty (the goal is then
; disallowed).
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
PenTeamScored:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        test byte [gmode], 0x8
        jz short .8
        mov bx, [pucky]
        cmp word [bx], 0x0
        jnl short .1
        mov ax, 0x1
        jmp short .2
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        mov cl, [gmode]
        and cl, 0x2
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0x2], cx
        cmp word [lasttouch], 0x6
        jnl short .3
        mov ax, 0x1
        jmp short .4
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .8
        cmp di, 0x1
        cmc
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        and bx, 0x6
        shl bx, byte 0x7
        add bx, SortCords
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.5:
        cmp word [bx + 0x1a], 0x0
        jl short .6
        test byte [bx + 0x45], 0x10
        jnz short .7
.6:
        add bx, 0x80
        inc dx
        cmp dx, 0x6
        jl short .5
        jmp short .8
.7:
        mov ax, 0x1
        pop di
        leave
        retf
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Goal                                                       2E42:0AFC  94 PC
; The puck is in a goal: stops it in the net, then the goal, offside or disallowed goal bookkeeping.
;
; Takes 1 word of stack arguments. Calls __chkstk, PenTeamScored, assreplace, AddPenalty2,
; ChkShotStat, PlaySoundEffect, freezewindow, SetBoxDoorObject and others. Far routine (retf).
;-----------------------------------------------------------------------------
Goal:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x12
        call 0x0000:__chkstk
        push si
        mov word [bp - 0xc], puckstruct
        cmp word [puckYpos2], 0x0
        jnl short .1
        mov ax, 0x1
        jmp short .2
        db 0x90
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        mov cl, [gmode]
        and cl, 0x2
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        mov [bp - 0x2], cx
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .3
        mov ax, awshots
        jmp short .4
        db 0x90
.3:
        mov ax, hmshots
.4:
        mov [bp - 0x10], ax
        cmp cx, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .5
        mov ax, awshots
        jmp short .6
.5:
        mov ax, hmshots
.6:
        mov [bp - 0x4], ax
        test byte [gmode], 0x1
        jnz short .7
        push cs
        call PenTeamScored
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        jmp near .13
.7:
        mov byte [collflag], 0x0
        mov bx, [bp - 0xc]
        mov word [bx + 0xc], 0x0
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        mov [bp - 0x12], ax
        cmp [bx + 0x2], ax
        jl short .8
        mov ax, 0x6
        jmp short .9
.8:
        mov ax, 0xfffa
.9:
        add ax, [bp - 0x12]
        mov bx, [bp - 0xc]
        mov [bx + 0x2], ax
        mov word [bx + 0xe], 0x0
        mov si, [bp + 0x6]
        cmp word [si + 0x6], 0x0
        jl short .10
        mov ax, 0x4
        jmp short .11
        db 0x90
.10:
        mov ax, 0xfffc
.11:
        add ax, [si + 0x6]
        mov bx, [bp - 0xc]
        mov [bx + 0x6], ax
        mov word [bx + 0x10], 0x600
        mov word [bx + 0xa], 0x0
        mov al, 0xff
        mov [GoalState_m5], al
        mov [GoalState_m1], al
        or byte [bx + 0x44], 0x4
        test byte [gmode], 0x1
        jz short .12
        jmp near .54
.12:
        push 0x1a
        push bx
        call 0x1E7E:assreplace
        add sp, 0x4
        push 0x15
        mov bx, [bp - 0x4]
        push word [bx + 0xd4]
        call 0x327B:AddPenalty2
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.13:
        mov bx, [bp - 0x10]
        inc word [bx + 0xc]
        cmp word [lasttouch], 0x6
        jnl short .14
        mov ax, 0x1
        jmp short .15
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.15:
        xor ax, [bp - 0x2]
        jz short .16
        or byte [gmode2], 0x10
        mov ax, [lasttouch]
        mov [shotplayer], ax
.16:
        call 0x28BB:ChkShotStat
        push word 0x9c
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        push cs
        call freezewindow
        cmp word [bp - 0x2], 0x0
        jnz short .18
        add word [CrowdSound], 0x320
        cmp word [CrowdSound], 0x7d0
        jng short .17
        mov word [CrowdSound], 0x7d0
.17:
        cmp word [CrowdSound], 0x708
        jnl short .19
        mov word [CrowdSound], 0x708
        jmp short .19
.18:
        cmp word [CrowdSound], 0x320
        jnl short .19
        mov word [CrowdSound], 0x320
.19:
        push word [bp - 0x2]
        call 0x3136:SetBoxDoorObject
        add sp, 0x2
        cmp word [bp - 0x2], 0x0
        jnz short .21
        test byte [AnnouncerFlags], 0x1
        jz short .20
        cmp word [SoundOptions], 0x2
        jz short .21
.20:
        push 0x3
        call 0x0EDC:PlayArenaJingle
        add sp, 0x2
.21:
        cmp word [bp - 0x2], 0x1
        jnz short .22
        add word [crowdheat], 0xa
        jmp short .23
.22:
        add word [crowdheat], 0x1e
.23:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x22]
        mov bx, [bp - 0x4]
        cmp [bx + 0x22], ax
        jng short .24
        mov word [GoalState], 0x2
        jmp short .26
        db 0x90
.24:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x22]
        mov bx, [bp - 0x4]
        cmp [bx + 0x22], ax
        jnl short .25
        mov word [GoalState], 0x4
        jmp short .26
.25:
        mov word [GoalState], 0x1
.26:
        cmp word [bx + 0x24], 0x0
        jnl short .27
        or byte [GoalState], 0x8
.27:
        test byte [gmode], 0x10
        jz short .28
        jmp near .40
.28:
        mov bx, [bp - 0x10]
        mov al, [bx + 0x1c]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x6], ax
        cmp ax, strict word 0x19
        jnl short .29
        les si, [bx + 0xc8]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x4
        inc word [es:bx + si]
.29:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x22]
        mov si, [bp - 0x4]
        cmp [si + 0x22], ax
        jnl short .30
        mov bx, [bp - 0x6]
        shl bx, byte 0x4
        mov si, [bp - 0x10]
        les si, [si + 0xc8]
        inc word [es:bx + si + 0x8]
        jmp short .31
.30:
        cmp [si + 0x22], ax
        jng short .31
        mov bx, [bp - 0x6]
        shl bx, byte 0x4
        mov si, [bp - 0x10]
        les si, [si + 0xc8]
        inc word [es:bx + si + 0xa]
.31:
        mov bx, [bp - 0x4]
        cmp word [bx + 0x24], 0x0
        jnl short .32
        mov bx, [bp - 0x6]
        shl bx, byte 0x4
        mov si, [bp - 0x10]
        les si, [si + 0xc8]
        inc word [es:bx + si + 0xc]
.32:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x1e]
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .34
        cmp ax, strict word 0x19
        jnl short .33
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x4
        les bx, [bx + 0xc8]
        inc word [es:bx + si + 0x2]
.33:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x20]
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .34
        cmp ax, strict word 0x19
        jnl short .34
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x4
        les bx, [bx + 0xc8]
        inc word [es:bx + si + 0x2]
.34:
        mov bx, [bp - 0x4]
        cmp word [bx + 0x24], 0x0
        jl short .35
        mov si, [bx + 0x24]
        mov bx, [bx + 0xbe]
        mov al, [bx + si + 0x24]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x19
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .35
        cmp ax, strict word 0x3
        jnl short .35
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov bx, [bp - 0x4]
        les bx, [bx + 0xcc]
        inc word [es:bx + si + 0x4]
.35:
        mov bx, [bp - 0x10]
        mov ax, [bx + 0x22]
        mov si, [bp - 0x4]
        cmp [si + 0x22], ax
        jl short .39
        mov ax, [bx + 0xd4]
        mov [bp - 0xa], ax
        mov ax, [si + 0xd4]
        mov [bp - 0xe], ax
        mov word [bp - 0x6], 0x0
.36:
        mov bx, [bp - 0xa]
        cmp word [bx + 0x1a], 0x0
        jng short .37
        mov al, [bx + 0x47]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x4
        mov bx, [bp - 0x10]
        les bx, [bx + 0xc8]
        inc word [es:bx + si + 0x6]
.37:
        mov bx, [bp - 0xe]
        cmp word [bx + 0x1a], 0x0
        jng short .38
        mov al, [bx + 0x47]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x4
        mov bx, [bp - 0x4]
        les bx, [bx + 0xc8]
        dec word [es:bx + si + 0x6]
.38:
        inc word [bp - 0x6]
        add word [bp - 0xa], 0x80
        add word [bp - 0xe], 0x80
        cmp word [bp - 0x6], 0x6
        jl short .36
.39:
        push word [bp - 0x2]
        call 0x327B:PenGoalStuff
        add sp, 0x2
.40:
        mov bx, [bp - 0x10]
        push word [bx + 0xc]
        push word [bp - 0x2]
        call 0x2083:DrawPanelScore
        add sp, 0x4
        mov bx, [bp - 0x10]
        mov ax, [bx + 0xd4]
        mov [bp - 0xa], ax
        mov word [bp - 0x6], 0x6
.41:
        mov bx, [bp - 0xa]
        cmp word [bx + 0x1a], 0x0
        jng short .42
        test byte [bx + 0x45], 0x1
        jnz short .42
        and byte [bx + 0x44], 0xfb
        push 0x7
        push bx
        call 0x1E7E:assinsert
        add sp, 0x4
.42:
        add word [bp - 0xa], 0x80
        dec word [bp - 0x6]
        jnz short .41
        mov byte [collflag], 0x0
        mov bx, [bp - 0xc]
        mov word [bx + 0xc], 0x0
        cmp word [bx + 0x2], 0x0
        jl short .43
        mov ax, 0x6
        jmp short .44
.43:
        mov ax, 0xfffa
.44:
        mov bx, [bp - 0xc]
        mov [bx + 0x2], ax
        mov word [bx + 0xe], 0x0
        mov word [bp - 0x6], 0xf0
        cmp word [bx + 0x6], 0x0
        jl short .45
        mov word [bx + 0x6], 0xf0
        jmp short .46
.45:
        mov ax, [bp - 0x6]
        neg ax
        mov bx, [bp - 0xc]
        mov [bx + 0x6], ax
.46:
        mov bx, [bp - 0xc]
        mov word [bx + 0x10], 0x600
        mov word [bx + 0xa], 0x0
        mov al, 0xff
        mov [GoalState_m5], al
        mov [GoalState_m1], al
        or byte [bx + 0x44], 0x4
        push 0x1a
        push bx
        call 0x1E7E:assreplace
        add sp, 0x4
        mov bx, [bp - 0xc]
        add bx, 0x80
        mov ax, 0x7fd
        push cs
        call SetSPA
        push 0x7
        mov bx, [bp - 0x4]
        push word [bx + 0xd4]
        call 0x327B:AddPenalty2
        add sp, 0x4
        test byte [gmode], 0x10
        jz short .47
        jmp near .54
.47:
        mov ax, [hmscore]
        sub ax, [awscore]
        mov [bp - 0x6], ax
        cmp ax, strict word 0xfffd
        jnl short .48
        cmp byte [hmtmcoach_d2], 0x1
        jna short .48
        cmp word [cont1team], 0x1
        jz short .48
        cmp word [cont2team], 0x1
        jz short .48
        test byte [hmtmgoalie], 0x1
        jnz short .48
        xor byte [hmtmgoalie], 0x1
.48:
        cmp ax, strict word 0xffff
        jnl short .49
        cmp byte [hmtmcoach_d2], 0x1
        jna short .49
        dec byte [hmtmcoach_d2]
.49:
        cmp ax, strict word 0x1
        jnl short .50
        cmp byte [hmtmcoach_d3], 0x1
        jna short .50
        dec byte [hmtmcoach_d3]
.50:
        cmp ax, strict word 0x3
        jng short .51
        cmp byte [awtmcoach_d2], 0x1
        jna short .51
        cmp word [cont1team], 0x2
        jz short .51
        cmp word [cont2team], 0x2
        jz short .51
        test byte [awtmgoalie], 0x1
        jnz short .51
        xor byte [awtmgoalie], 0x1
.51:
        cmp ax, strict word 0x1
        jng short .52
        cmp byte [awtmcoach_d2], 0x1
        jna short .52
        dec byte [awtmcoach_d2]
.52:
        cmp ax, strict word 0xffff
        jng short .53
        cmp byte [awtmcoach_d3], 0x1
        jna short .53
        dec byte [awtmcoach_d3]
.53:
        push cs
        call UpdateCoachModes
.54:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GiveControl                                                2E42:0FB6  94 PC
; Gives the human control of the player who got the puck.
;
; Takes 1 word of stack arguments. Calls __chkstk, restorepl. Far routine (retf).
;-----------------------------------------------------------------------------
GiveControl:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        mov si, [bp + 0x6]
        cmp [c1playernum], si
        jz short .6
        cmp [c2playernum], si
        jz short .6
        cmp si, 0x6
        jnl short .1
        mov ax, 0x1
        jmp short .2
        db 0x90, 0x90
.1:
        mov ax, 0x2
.2:
        mov [regd1], ax
        mov ax, [lastplayer]
        cmp [c2playernum], ax
        jz short .4
        mov ax, [regd1]
        cmp [cont1team], ax
        jz short .5
        cmp [cont2team], ax
        jnz short .6
.3:
        cmp [c2playernum], si
        jz short .6
        push word [c2playernum]
        push si
        push cs
        call restorepl
        add sp, 0x4
        mov [c2playernum], ax
        pop si
        leave
        retf
.4:
        mov ax, [regd1]
        cmp [cont2team], ax
        jz short .3
        cmp [cont1team], ax
        jnz short .6
.5:
        cmp [c1playernum], si
        jz short .6
        push word [c1playernum]
        push si
        push cs
        call restorepl
        add sp, 0x4
        mov [c1playernum], ax
.6:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Setplass                                                   2E42:103A  94 PC
; Sets a player's first assignment from his position.
;
; Takes 1 word of stack arguments. Calls __chkstk, assreplace. Far routine (retf).
;-----------------------------------------------------------------------------
Setplass:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [di + 0x1a]
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .1
        cmp si, 0x6
        jg short .1
        mov al, [si + Setplass_alist]
        cbw
        push ax
        push di
        call 0x1E7E:assreplace
        add sp, 0x4
.1:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; setplayer                                                  2E42:1068  94 PC
; Brings a roster player onto the ice and copies his attributes into the sort object.
;
; Takes 2 words of stack arguments. Calls __chkstk, assinsert. Far routine (retf).
;-----------------------------------------------------------------------------
setplayer:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x16
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x6]
        and byte [di + 0x45], 0xbf
        cmp word [di + 0x5e], 0x6
        jl short .1
        mov ax, awshots
        jmp short .2
        db 0x90
.1:
        mov ax, hmshots
.2:
        mov [bp - 0x6], ax
        mov al, [bp + 0x8]
        mov [di + 0x47], al
        mov bx, [bp + 0x8]
        shl bx, 1
        add bx, [bp - 0x6]
        add bx, 0x64
        mov [bp - 0xc], bx
        mov ax, [bx]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .3
        push 0xa
        jmp short .4
        db 0x90
.3:
        cmp ax, strict word 0xfffe
        jnz short .5
        push 0x9
.4:
        push di
        call 0x1E7E:assinsert
        add sp, 0x4
        and byte [di + 0x44], 0xdf
        mov word [di + 0x38], 0x0
.5:
        mov bx, [bp - 0xc]
        mov word [bx], 0xffff
        mov bx, [bp - 0x6]
        mov bx, [bx + 0xd0]
        imul si, [bp + 0x8], 0x28
        mov [bp - 0xe], si
        mov byte [bx + si], 0x4
        mov bx, [bp - 0x6]
        mov si, [bx + 0xd2]
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bp - 0x7], al
        mov [bp - 0xa], al
        mov [bp - 0x8], al
        mov [bp - 0x9], al
        cmp word [di + 0x1a], 0x0
        jz short .14
        test byte [gmode2], 0x20
        jz short .7
        mov al, [di + 0x44]
        xor al, [gmode2]
        test al, 0x40
        jz short .6
        mov al, [si + 0x2dc]
        neg al
        mov [bp - 0x8], al
        jmp short .7
        db 0x90
.6:
        mov al, [si + 0x2dd]
        mov [bp - 0x9], al
.7:
        mov al, [di + 0x44]
        and al, 0x40
        jnz short .8
        mov al, [si + 0x2de]
        jmp short .9
.8:
        mov al, [si + 0x2df]
        neg al
.9:
        mov [bp - 0x7], al
        cmp word [gsp], 0x2
        jg short .10
        jnz short .14
        mov ax, [gameclock2]
        sar ax, 1
        cmp ax, [gameclock]
        jng short .14
.10:
        mov dx, [hmscore]
        sub dx, [awscore]
        jz short .13
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .11
        mov ax, 0x1
        jmp short .12
.11:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.12:
        mov cl, [di + 0x44]
        and cl, 0x40
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .14
.13:
        mov byte [bp - 0xa], 0x2
.14:
        cmp word [bp + 0x8], 0x19
        jl short .15
        jmp near .32
.15:
        mov bx, [bp - 0x6]
        mov bx, [bx + 0xd0]
        mov si, [bp - 0xe]
        mov al, [bx + si + 0x6]
        mov [di + 0x52], al
        mov bx, [bp - 0x6]
        mov ax, [bx + 0xc0]
        mov dx, [bx + 0xc2]
        imul cx, [bp + 0x8], 0x14
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [bp - 0x2], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [es:bx]
        mov [di + 0x59], al
        inc si
        mov ax, [bp - 0x2]
        and byte [di + 0x49], 0xf7
        cmp byte [di + 0x59], 0x0
        jnz short .16
        or byte [di + 0x49], 0x8
.16:
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4c], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4b], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4a], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4f], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov cl, [es:bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        mov al, [bp - 0xa]
        cbw
        mov [bp - 0x10], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        jns short .17
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.17:
        cmp cx, 0xf
        jng short .18
        mov cx, 0xf
.18:
        mov [di + 0x58], cl
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov cl, [es:bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        mov al, [bp - 0x7]
        cbw
        mov [bp - 0x12], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov al, [bp - 0x8]
        cbw
        mov [bp - 0x14], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov al, [bp - 0x9]
        cbw
        mov [bp - 0x16], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        jns short .19
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.19:
        cmp cx, 0xf
        jng short .20
        mov cx, 0xf
.20:
        mov [di + 0x54], cl
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov cl, [es:bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        add cx, [bp - 0x12]
        add cx, [bp - 0x14]
        add cx, [bp - 0x16]
        jns short .21
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.21:
        cmp cx, 0xf
        jng short .22
        mov cx, 0xf
.22:
        mov [di + 0x50], cl
        mov es, [bp - 0x2]
        inc si
        mov cl, [es:si]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        add cx, [bp - 0x12]
        add cx, [bp - 0x16]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, es
        inc ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnl short .23
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.23:
        cmp cx, 0xf
        jng short .24
        mov cx, 0xf
.24:
        mov [di + 0x51], cl
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov cl, [es:bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        add cx, [bp - 0x12]
        add cx, [bp - 0x10]
        add cx, [bp - 0x14]
        add cx, [bp - 0x16]
        jns short .25
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.25:
        mov [bp - 0x6], cx
        cmp cx, 0xf
        jng short .26
        mov word [bp - 0x6], 0xf
.26:
        mov ax, [bp - 0x6]
        xor al, 0xf
        add ax, strict word 0xf
        sar ax, 1
        mov [di + 0x4d], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x12]
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .27
        mov word [bp - 0x6], 0x0
.27:
        cmp word [bp - 0x6], 0xf
        jng short .28
        mov word [bp - 0x6], 0xf
.28:
        mov ax, [bp - 0x6]
        xor al, 0xf
        add ax, strict word 0xf
        sar ax, 1
        mov [di + 0x4e], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x56], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x55], al
        mov es, [bp - 0x2]
        mov al, [es:si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cx, [bp - 0x10]
        shl cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .31
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.29:
        cmp cx, 0xf
        jng short .30
        mov cx, 0xf
.30:
        mov [di + 0x53], cl
        pop si
        pop di
        leave
        retf
.31:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        jmp short .29
.32:
        mov bx, [bp - 0x6]
        mov bx, [bx + 0xd0]
        mov si, [bp - 0xe]
        mov al, [bx + si + 0x6]
        mov [di + 0x52], al
        mov bx, [bp - 0x6]
        mov ax, [bx + 0xc4]
        mov dx, [bx + 0xc6]
        mov cx, [bp + 0x8]
        shl cx, byte 0x4
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, 0x190
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [bp - 0x2], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [es:bx]
        mov [di + 0x59], al
        inc si
        mov ax, [bp - 0x2]
        and byte [di + 0x49], 0xf7
        cmp byte [di + 0x59], 0x0
        jnz short .33
        or byte [di + 0x49], 0x8
.33:
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x56], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x51], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x53], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x55], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4f], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4c], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4b], al
        mov es, [bp - 0x2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di + 0x4a], al
        mov es, [bp - 0x2]
        inc si
        mov cl, [es:si]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        mov al, [bp - 0x7]
        cbw
        mov [bp - 0x12], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov al, [bp - 0xa]
        cbw
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov al, [bp - 0x8]
        cbw
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov al, [bp - 0x9]
        cbw
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, es
        inc ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], cx
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnl short .36
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.34:
        mov [bp - 0x6], dx
        cmp dx, 0xf
        jng short .35
        mov word [bp - 0x6], 0xf
.35:
        mov ax, [bp - 0x6]
        xor al, 0xf
        add ax, strict word 0xf
        sar ax, 1
        mov [di + 0x4d], al
        mov es, [bp - 0x2]
        mov al, [es:si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x12]
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .37
        jmp short .38
        db 0x90
.36:
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        jmp short .34
.37:
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .39
.38:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.39:
        cmp dx, 0xf
        jng short .40
        mov dx, 0xf
.40:
        xor dl, 0xf
        add dx, 0xf
        sar dx, 1
        mov [di + 0x4e], dl
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; reenergizeteam                                             2E42:146C  94 PC
; Refills the energy of the whole roster.
;
; Takes 1 word of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
reenergizeteam:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        push si
        mov cx, [bp + 0x6]
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        add dx, 0x2c
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, 0x64
        db 0x03, 0xD9                           ; insn: add bx, cx
.1:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        inc dx
        inc dx
        mov word [si], 0x1000
        cmp word [bx], -0x3
        jnz short .2
        mov word [bx], 0xfffe
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov si, [si + 0xd0]
        db 0x03, 0xF7                           ; insn: add si, di
        mov byte [si], 0x3
.2:
        inc bx
        inc bx
        add di, 0x28
        cmp di, 0x460
        jl short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; clearteams                                                 2E42:14B4  94 PC
; Clears both team records and sets their data pointers.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
clearteams:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov bx, hmshots
        mov dx, 0x1ac
.1:
        inc bx
        mov byte [bx - 0x1], 0x0
        dec dx
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [hmtmgoalie], ax
        mov [awtmgoalie], ax
        mov ax, 0xffff
        mov [hmtmextra], ax
        mov [awtmextra], ax
        mov al, 0xff
        mov [hmtmpbox_m1], al
        mov [awtmpbox_m1], al
        mov word [hmtmptrs], SortCords
        mov word [hmtmsort], HomeSortObjs
        mov word [hmtmplattr], 0x3a0b
        mov word [hmtmglattr], HomeGlAttr
        mov word [hmtmglattrseg], 0x3a0b
        mov word [hmtmlines], HomeTeamRec
        mov word [hmtmplstats], HomePlStats
        mov word [hmtmplstatsseg], 0x3a0b
        mov word [hmtmglstats], HomeGlStats
        mov word [hmtmroster], 0x3a0b
        mov word [hmtmrosterptr], hmroster
        mov word [hmtmptrF2], GameTeamRecs
        mov word [SortCords_m2], SortCords + 6 * 0x80
        mov word [awtmsort], AwaySortObjs
        mov word [awtmglattrseg], 0x3a0b
        mov word [awtmglattr], AwayGlAttr
        mov word [awtmlines], 0x3a0b
        mov word [awtmteamrec], AwayTeamRec
        mov word [awtmplstats], AwayPlStats
        mov word [awtmglstats], 0x3a0b
        mov word [awtmglstatsptr], AwayGlStats
        mov word [awtmglstatsseg], 0x3a0b
        mov word [awtmptrF2], GamePlayerFlags
        mov word [awtmroster], GameRosterRecs
        retf
        db 0x90

;-----------------------------------------------------------------------------
; restoreteams                                               2E42:1574  94 PC
; Both teams: every player back on the bench.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
restoreteams:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push di
        push si
        mov bx, hmshots
        mov word [bp - 0x4], 0x2
.1:
        mov word [bx + 0x22], 0x6
        lea di, [bx + 0x64]
        mov cx, [bx + 0xd0]
        mov dx, 0x1c
        db 0x8B, 0xF1                           ; insn: mov si, cx
.2:
        add si, 0x28
        mov bl, [si - 0x28]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        mov ax, [bx + RestoreTeamTable]
        inc di
        inc di
        mov [di - 0x2], ax
        dec dx
        jnz short .2
        mov bx, awshots
        dec word [bp - 0x4]
        jnz short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; GetPeriodTime                                              2E42:15BC  94 PC
; Returns the period length from the options.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
GetPeriodTime:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov bl, [AnnouncerFlags]
        and bx, 0xc
        shr bl, 1
        mov dx, [bx + PerTimeTab]
        test byte [AnnouncerFlags], 0x2
        jz short .1
        cmp word [curperiod], 0x3
        jng short .1
        mov dx, [PerTimeTab]
.1:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetClock                                                 2E42:15E6  94 PC
; Resets the game clock to the period length and stops it.
;
; Calls __chkstk, GetPeriodTime, randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
ResetClock:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push cs
        call GetPeriodTime
        mov [gameclock], ax
        mov word [clockticks], 0x0
        mov [gameclock2], ax
        sar ax, 1
        call 0x0C11:randomd0
        sub ax, [gameclock]
        neg ax
        mov [stoppagetime], ax
        or byte [gmode], 0x1
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ClearSortCords                                             2E42:1614  94 PC
; Clears the sort objects.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
ClearSortCords:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push di
        mov cx, SortCords
        mov di, [bp - 0x4]
.1:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov dx, 0x80
.2:
        inc bx
        mov byte [bx - 0x1], 0x0
        dec dx
        jnz short .2
        add cx, 0x80
        cmp cx, 0xbd8e
        jc short .1
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; defaultsprites_0                                           2E42:1640  94 PC
; Clears the remaining sprite objects.
;
; Calls __chkstk, ClearSortCords, SprSort. Far routine (retf).
;-----------------------------------------------------------------------------
defaultsprites_0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xa
        call 0x0000:__chkstk
        push di
        push si
        push cs
        call ClearSortCords
        mov ax, ObjectTable
        mov cx, 0x3863
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], cx
        mov di, SortCords
        mov word [bp - 0x4], OOlist
        mov word [bp - 0x6], objylist
        mov word [bp - 0x2], 0x0
        mov cx, [bp - 0x2]
.1:
        mov [di + 0x5e], cx
        mov al, 0xff
        mov [di + 0x47], al
        mov [di + 0x42], al
        mov [di + 0x43], al
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x2], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x6], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0xa], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x12], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x48], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x5a], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov ax, [es:bx]
        mov [di + 0x5c], ax
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov al, [es:bx]
        mov [di + 0x1e], al
        mov es, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        inc si
        mov al, [es:bx]
        mov [di + 0x44], al
        test al, 0x40
        jz short .2
        mov word [di + 0x60], awshots
        jmp short .3
        db 0x90
.2:
        mov word [di + 0x60], hmshots
.3:
        test byte [di + 0x44], 0x40
        jnz short .4
        mov word [di + 0x62], awshots
        jmp short .5
.4:
        mov word [di + 0x62], hmshots
.5:
        mov word [di + 0x2e], 0x0
        mov bx, [bp - 0x4]
        inc word [bp - 0x4]
        mov [bx], cl
        mov bx, [bp - 0x6]
        add word [bp - 0x6], 0x2
        mov [bx], cx
        add di, 0x80
        inc cx
        cmp cx, 0x11
        jz short .6
        jmp near .1
.6:
        mov word [ref_36], 0x2
        mov byte [ref_4A], 0x7
        mov al, 0xf
        mov [ref_4B], al
        mov [ref_4C], al
        mov ax, 0xffff
        mov [refposition], ax
        mov [RefStep], ax
        push cs
        call SprSort
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TryAddPlayerToList                                         2E42:175E  94 PC
; Adds a roster player to the player list if he is not in it already.
;
; Takes 3 words of stack arguments. Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
TryAddPlayerToList:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        push si
        mov dx, [bp + 0x8]
        mov bx, [bp + 0x6]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        shl si, 1
        mov ax, [bx + si + 0x64]
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .3
        cmp ax, strict word 0xfffd
        jng short .3
        mov si, 0x5
        mov di, [bp + 0xa]
.1:
        db 0x3B, 0xFE                           ; insn: cmp di, si
        jz short .2
        mov al, [si + PlList]
        cbw
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jz short .3
.2:
        dec si
        jns short .1
        mov [di + PlList], dl
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetPlList                                                  2E42:17AC  94 PC
; Builds the player list for the line and stats screens.
;
; Takes 1 word of stack arguments. Calls __chkstk, TryAddPlayerToList. Far routine (retf).
;-----------------------------------------------------------------------------
SetPlList:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x10
        call 0x0000:__chkstk
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, [di + 0x16]
        mov [bp - 0xe], ax
        mov ax, [di + 0xbe]
        mov [bp - 0xc], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x8], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.1:
        mov byte [bx + PlList], 0xff
        inc bx
        cmp bx, 0x6
        jl short .1
        cmp word [di + 0x24], 0x0
        jnl short .2
        mov word [bp - 0x8], 0x1
        jmp short .3
.2:
        mov word [di + 0x1a], 0xffff
.3:
        mov si, [di + 0x22]
        mov di, [bp - 0xc]
.4:
        dec si
        js short .11
        mov bx, [bp - 0x8]
        mov al, [bx + si + priolist]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov [si + LinePlayersAway], dl
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .8
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x24]
.5:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        mov bx, [bx + PlListOffsets]
        db 0x03, 0xD8                           ; insn: add bx, ax
.6:
        mov al, [bx + PlListSlots]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + di]
.7:
        mov [si + PlList], al
        jmp short .4
        db 0x90
.8:
        cmp dx, 0x6
        jnz short .9
        mov al, [di + 0x26]
        jmp short .7
.9:
        cmp word [bp - 0xe], 0x4
        jnl short .10
        cmp dx, 0x2
        jg short .10
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x18]
        jmp short .5
        db 0x90
.10:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov bx, [bx + PlListOffsets]
        add bx, [bp - 0xe]
        jmp short .6
        db 0x90
.11:
        mov word [bp - 0x6], 0x5
        mov di, [bp + 0x6]
.12:
        mov bx, [bp - 0x6]
        mov al, [bx + PlList]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .13
        jmp near .28
.13:
        mov al, [bx + LinePlayersAway]
        cbw
        mov [bp - 0xa], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov ax, [bx + di + 0x64]
        cmp ax, strict word 0xfffd
        jng short .15
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .15
        mov ax, [di + 0x22]
        dec ax
        dec ax
        cmp ax, [bp - 0x6]
        jng short .14
        jmp near .27
.14:
        push word [bp - 0x6]
        push si
        push di
        push cs
        call TryAddPlayerToList
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        jmp near .27
.15:
        mov bx, [bp - 0xa]
        shl bx, 1
        mov si, [bx + PlListOffsets]
        add si, PlListSlots
.16:
        lodsb
        mov [bp - 0x1], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .17
        push word [bp - 0x6]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        add bx, [bp - 0xc]
        mov al, [bx]
        mov [bp - 0x1], al
        cbw
        push ax
        push di
        push cs
        call TryAddPlayerToList
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        jmp near .27
        db 0x90
.17:
        cmp word [bp + 0x6], 0xb438
        jnz short .18
        mov bx, 0x1
        jmp short .19
.18:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.19:
        mov di, [bp - 0xa]
        cmp di, 0x6
        jz short .21
        cmp word [bp - 0xe], 0x6
        jl short .21
        cmp di, 0x1
        jz short .20
        cmp di, 0x2
        jz short .20
        imul ax, bx, 0x19
        add ax, defsort_d + 50
        jmp short .23
.20:
        imul ax, bx, 0x19
        add ax, defsort_d
        jmp short .23
.21:
        cmp di, 0x1
        jz short .22
        cmp di, 0x2
        jz short .22
        imul ax, bx, 0x19
        add ax, offsort_fwd
        jmp short .23
.22:
        imul ax, bx, 0x19
        add ax, offsort_fwd - 50
.23:
        mov [bp - 0x8], ax
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0x6]
.24:
        mov bx, [bp - 0x8]
        mov al, [bx + si]
        mov [bp - 0x1], al
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jnl short .26
        mov si, 0x18
.25:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [bp - 0x1], al
        dec si
        js short .27
        push word [bp - 0x6]
        cbw
        push ax
        push di
        push cs
        call TryAddPlayerToList
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .25
.26:
        mov [bp - 0x4], si
        push word [bp - 0x6]
        mov al, [bp - 0x1]
        cbw
        push ax
        push di
        push cs
        call TryAddPlayerToList
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .27
        mov si, [bp - 0x4]
        jmp short .24
        db 0x90
.27:
        cmp word [bp - 0xa], 0x6
        jnz short .28
        mov bx, [bp - 0x6]
        mov al, [bx + PlList]
        cbw
        mov [di + 0x1a], ax
.28:
        dec word [bp - 0x6]
        js short .29
        jmp near .12
.29:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; setpersonel                                                2E42:1994  94 PC
; Sets the personnel of a team: the players wanted on the ice and their new positions.
;
; Takes 1 word of stack arguments. Calls __chkstk, SetPlList, assreplace. Far routine (retf).
;-----------------------------------------------------------------------------
setpersonel:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xa
        call 0x0000:__chkstk
        push di
        push si
        mov dx, 0x6
        mov bx, [bp + 0x6]
        mov si, [bx + 0xd4]
.1:
        mov al, 0xff
        mov [si + 0x42], al
        mov [si + 0x43], al
        add si, 0x80
        dec dx
        jnz short .1
        push word [bp + 0x6]
        push cs
        call SetPlList
        add sp, 0x2
        mov di, 0x5
.2:
        mov al, [di + PlList]
        cbw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jl short .5
        mov bx, [bp + 0x6]
        mov si, [bx + 0xd4]
        sub si, 0x80
        mov word [bp - 0x4], 0x0
        mov dx, [bp - 0x4]
        mov [bp - 0x6], cx
        mov [bp - 0x8], di
.3:
        add si, 0x80
        mov al, [si + 0x47]
        cbw
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .4
        inc dx
        cmp dx, 0x6
        jl short .3
        jmp short .5
        db 0x90
.4:
        mov al, [di + LinePlayersAway]
        mov [si + 0x42], al
        mov [si + 0x43], cl
        mov byte [di + PlList], 0xff
.5:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        dec di
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .2
        mov si, 0x5
.6:
        mov al, [si + PlList]
        cbw
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .11
        mov [bp - 0x8], si
        mov bx, [bp + 0x6]
        mov di, [bx + 0xd4]
        sub di, 0x80
        mov word [bp - 0x4], 0x0
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov dx, [bp - 0x4]
        mov di, [bp - 0xa]
.7:
        add si, 0x80
        cmp byte [si + 0x43], 0x0
        jnl short .8
        db 0x8B, 0xFE                           ; insn: mov di, si
        cmp word [si + 0x1a], 0x0
        jnl short .9
.8:
        inc dx
        cmp dx, 0x6
        jl short .7
.9:
        cmp word [di + 0x1a], 0x0
        jnl short .10
        push 0x29
        push di
        call 0x1E7E:assreplace
        add sp, 0x4
        mov word [di + 0x1a], 0x5
.10:
        mov si, [bp - 0x8]
        mov al, [si + LinePlayersAway]
        mov [di + 0x42], al
        mov al, [bp - 0x6]
        mov [di + 0x43], al
        mov byte [si + PlList], 0xff
        mov [bp - 0xa], di
.11:
        db 0x8B, 0xD6                           ; insn: mov dx, si
        dec si
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .6
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StartPer                                                   2E42:1A92  94 PC
; Starts a period: rink set-up, clock, centre faceoff, coach modes, then the game frames.
;
; Calls __chkstk, InitCoachModes, setupice, ResetClock, assreplace, ReplayRecordReset, DoGameFrame.
; Far routine (retf).
;-----------------------------------------------------------------------------
StartPer:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [controlled2], ax
        mov [controlled], ax
        push cs
        call InitCoachModes
        push cs
        call setupice
        push cs
        call ResetClock
        cmp word [cont1team], 0x1
        jnz short .1
        mov word [c1playernum], 0x2
        jmp short .2
.1:
        cmp word [cont1team], 0x2
        jnz short .2
        mov word [c1playernum], 0x8
.2:
        cmp word [cont2team], 0x0
        jz short .5
        mov ax, [cont1team]
        cmp [cont2team], ax
        jnz short .3
        mov ax, [c1playernum]
        dec ax
        mov [c2playernum], ax
        jmp short .5
.3:
        cmp word [cont2team], 0x1
        jnz short .4
        mov word [c2playernum], 0x2
        jmp short .5
        db 0x90
.4:
        cmp word [cont2team], 0x2
        jnz short .5
        mov word [c2playernum], 0x8
.5:
        mov byte [goalevent], 0xff
        mov ax, 0xffff
        mov [bannermsg], ax
        mov [ovltimer], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bannertimer], ax
        mov [fox], ax
        mov [foy], ax
        push 0x1b
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
        cmp word [gsp], 0x0
        jz short .6
        mov word [CrowdSound], 0x0
.6:
        or byte [gmode2], 0x4
        and byte [sflags], 0xaf
        mov ax, [replayptr]
        mov dx, [replayseg]
        mov [replayrecptr], ax
        mov [replayrecseg], dx
        call 0x2038:ReplayRecordReset
        mov word [lastsfx], 0xffff
        push cs
        call DoGameFrame
        push cs
        call DoGameFrame
        mov word [crowdheat], 0x10
        cmp word [gsp], 0x2
        jnl short .7
        or byte [sflags3], 0x80
.7:
        mov bx, [puckc]
        mov byte [bx], 0xff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [camy], ax
        mov [camx], ax
        mov [yleader], ax
        mov [yc1], ax
        mov [xc1], ax
        mov word [fadeinpending], 0x1
        retf

;-----------------------------------------------------------------------------
; DoGameFrame                                                2E42:1B8E  94 PC
; Runs one game frame.
;
; Calls __chkstk, periodicevents, updateplayers, checkwindow, updatereplay. Far routine (retf).
;-----------------------------------------------------------------------------
DoGameFrame:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push cs
        call periodicevents
        push cs
        call updateplayers
        call 0x226F:checkwindow
        call 0x2038:updatereplay
        retf

;-----------------------------------------------------------------------------
; RestoreBenchEnergy                                         2E42:1BA8  94 PC
; Once a second with line changes on, bench players gain energy.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
RestoreBenchEnergy:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push di
        test byte [CrowdState], 0x4
        jz short .4
        mov di, hmshots
        mov cx, 0x2
.1:
        mov dx, 0x1b
        lea bx, [di + 0x62]
.2:
        cmp word [bx + 0x38], -0x2
        jnz short .3
        add word [bx], 0x9
        cmp word [bx], 0x1000
        jng short .3
        mov word [bx], 0x1000
.3:
        dec bx
        dec bx
        dec dx
        jns short .2
        mov di, awshots
        loop .1
.4:
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; updatecrowdf                                               2E42:1BE8  94 PC
; Raises or decays the crowd excitement and plays random crowd sounds.
;
; Calls __chkstk, randomd0, PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
updatecrowdf:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        mov ax, [crowdtimer]
        cmp [crowdheat], ax
        jng short .1
        mov ax, [crowdheat]
        mov [crowdtimer], ax
.1:
        mov ax, [crowdheat]
        cwd
        add [crowdsum], ax
        adc [crowdsumhi], dx
        inc word [crowdcount]
        dec word [crowdheat]
        jns short .2
        mov word [crowdheat], 0x0
.2:
        test byte [gmode], 0x1
        jz short .6
        cmp word [CrowdSound], 0x258
        jng short .6
        mov ax, 0x3e8
        sub ax, [CrowdSound]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp si, 0x19
        jnl short .3
        mov si, 0x19
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        push word 0xa6
        jmp short .5
        db 0x90
.4:
        dec si
        jnz short .6
        push word 0x96
.5:
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.6:
        pop si
        retf

;-----------------------------------------------------------------------------
; periodicevents                                             2E42:1C6A  94 PC
; End of period horn when the clock reaches 0; once a second the crowd, bench energy and stats checks.
;
; Calls __chkstk, PenaltyManager, DecayCrowdLevel, PlaySoundEffect, freezewindow, clockcont_0,
; ChkGoalies, updatecrowdf and others. Far routine (retf).
;-----------------------------------------------------------------------------
periodicevents:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push di
        call 0x327B:PenaltyManager
        call 0x3136:DecayCrowdLevel
        test byte [gmode], 0x1
        jnz short .1
        cmp word [gameclock], 0x0
        jnz short .1
        cmp word [clockticks], 0x0
        jnz short .1
        push word 0x90
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        push cs
        call freezewindow
        push cs
        call clockcont_0
.1:
        cmp word [SortPending], 0x0
        jz short .2
        jmp near .8
.2:
        dec byte [secondframes]
        jns short .8
        add byte [secondframes], 0x18
        xor byte [halfsecflag], 0x1
        call 0x28BB:ChkGoalies
        push cs
        call updatecrowdf
        push cs
        call RestoreBenchEnergy
        test byte [gmode], 0x1
        jnz short .3
        call 0x327B:UpdatePowerPlayFlags
.3:
        test byte [CrowdState], 0x4
        jz short .8
        mov word [bp - 0x2], 0x0
        mov cx, hmshots
        mov di, energywarnteam
.4:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov bx, [bx + 0xd4]
        mov dx, 0x6
.5:
        cmp word [bx + 0x1a], 0x0
        jl short .6
        cmp byte [bx + 0x43], 0x0
        jl short .6
        test byte [halfsecflag], 0x1
        jnz short .7
.6:
        add bx, 0x80
        dec dx
        jnz short .5
        inc di
        inc di
        mov word [di - 0x2], 0x0
        inc word [bp - 0x2]
        mov cx, awshots
        cmp di, lcsel
        jc short .4
        pop di
        leave
        retf
        db 0x90, 0x90
.7:
        mov bx, [bp - 0x2]
        shl bx, 1
        mov word [bx + energywarnteam], 0x1
.8:
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; updateplayers                                              2E42:1D36  94 PC
; Runs every sort object for a frame.
;
; Calls __chkstk, updateanim, ImulRegs, PlaySoundEffect, ReadJoy1, ReadJoy2, doinput, checkcoll. Far
; routine (retf).
;-----------------------------------------------------------------------------
updateplayers:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push di
        push si
        mov bx, [ref_1C]
        mov al, [bx + refasslist]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        test byte [gmode], 0x1
        jz short .2
        test byte [gmode], 0x80
        jnz short .1
        test byte [gmode2], 0x1
        jnz short .2
        cmp word [PenCntDwn], 0x0
        jnl short .2
        cmp byte [PenBuf], 0x0
        jnz short .2
        cmp dx, 0x20
        jz short .2
        cmp dx, 0x23
        jz short .2
        cmp word [ovlseq], 0x2
        jz short .1
        cmp word [ovlseq], 0x0
        jz short .1
        cmp word [ovltimer], 0x0
        jl short .1
        cmp word [ovltimer], 0x100
        jl short .2
.1:
        mov word [playsuspended], 0x1
        jmp short .3
.2:
        mov word [playsuspended], 0x0
.3:
        mov si, SortCords
        mov di, 0x11
.4:
        mov ax, [si]
        mov dx, [si + 0x2]
        mov [si + 0x64], ax
        mov [si + 0x66], dx
        mov ax, [si + 0x4]
        mov dx, [si + 0x6]
        mov [si + 0x68], ax
        mov [si + 0x6a], dx
        mov ax, [si + 0x8]
        mov dx, [si + 0xa]
        mov [si + 0x6c], ax
        mov [si + 0x6e], dx
        cmp word [si + 0x1a], 0x0
        jnl short .5
        cmp word [si + 0x5e], 0x10
        jz short .5
        jmp near .27
.5:
        push si
        push cs
        call updateanim
        add sp, 0x2
        dec word [si + 0x3e]
        jns short .6
        mov word [si + 0x3e], 0x0
.6:
        dec word [si + 0x40]
        jns short .7
        mov word [si + 0x40], 0x0
.7:
        cmp word [si + 0x5e], 0x10
        jz short .8
        test byte [sflags3], 0x40
        jz short .8
        cmp byte [si + 0x47], 0x0
        jl short .8
        mov cx, [si + 0x60]
        cmp word [si + 0x1a], 0x0
        jnz short .8
        cmp byte [si + 0x47], 0x19
        jl short .8
        test byte [gmode], 0x10
        jnz short .8
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov al, [si + 0x47]
        cbw
        mov cx, [bx + 0xcc]
        mov dx, [bx + 0xce]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        db 0x03, 0xD9                           ; insn: add bx, cx
        mov es, dx
        inc word [es:bx - 0x96]
.8:
        cmp word [si + 0x38], 0xa0b
        jnz short .9
        jmp near .20
.9:
        mov word [regd4], 0x10
        cmp word [si + 0xa], 0x0
        jnz short .15
        test byte [si + 0x44], 0x1
        jz short .10
        mov ax, 0x9
        jmp short .11
        db 0x90
.10:
        mov ax, 0x6
.11:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [regd2], ax
        mov [regd2_w2], dx
        mov ax, [si + 0xc]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        mov cl, [regd2]
        sar word [regd0], cl
        cmp [regd0], dx
        jnz short .12
        mov word [regd0], 0x1
        mov [regd0_w2], dx
.12:
        mov ax, [regd0]
        sub [si + 0xc], ax
.13:
        mov ax, [si + 0xe]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        mov cl, [regd2]
        sar word [regd0], cl
        cmp [regd0], dx
        jnz short .14
        mov word [regd0], 0x1
        mov [regd0_w2], dx
.14:
        mov ax, [regd0]
        sub [si + 0xe], ax
.15:
        mov ax, [si + 0xc]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        mov dx, [regd4]
        call 0x03A3:ImulRegs
        add [si], ax
        adc [si + 0x2], dx
.16:
        mov ax, [si + 0xe]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .17
        mov dx, [regd4]
        call 0x03A3:ImulRegs
        add [si + 0x4], ax
        adc [si + 0x6], dx
.17:
        cmp word [si + 0xa], 0x0
        jl short .20
        jnz short .18
        cmp word [si + 0x10], 0x0
        jz short .20
.18:
        mov ax, [regd4]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        sub [si + 0x10], ax
        mov dx, [si + 0x10]
        mov ax, [regd4]
        call 0x03A3:ImulRegs
        mov [regd0], ax
        mov [regd0_w2], dx
        add [si + 0x8], ax
        adc [si + 0xa], dx
        cmp word [si + 0xa], 0x0
        jnl short .20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xa], ax
        mov [si + 0x8], ax
        neg word [si + 0x10]
        sar word [si + 0x10], 1
        mov al, [si + 0x11]
        cbw
        sub ax, strict word 0x5
        neg ax
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .19
        mov word [regd0], 0x0
.19:
        cmp word [regd0], 0x3
        jg short .20
        push word 0xab
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.20:
        mov ax, [si + 0x5e]
        mov [LastShooterTeam], ax
        cmp [c1playernum], ax
        jnz short .21
        call 0x2C24:ReadJoy1
        push 0x0
        jmp short .22
.21:
        cmp [c2playernum], ax
        jnz short .23
        call 0x2C24:ReadJoy2
        push 0x2
.22:
        push si
        call 0x2C24:doinput
        add sp, 0x4
.23:
        mov bx, [si + 0x1c]
        mov al, [bx + si + 0x1e]
        cbw
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        push si
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        call far [bx + asstab]
        add sp, 0x2
.24:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
        mov ax, [si + 0x2]
        mov [regd2], ax
        mov ax, [si + 0x6]
        mov [regd3], ax
        mov ax, [regd2]
        cmp [si + 0x66], ax
        jnz short .25
        mov ax, [regd3]
        cmp [si + 0x6a], ax
        jnz short .25
        cmp word [si + 0x5e], 0xe
        jnz short .26
.25:
        push word [regd3]
        push word [regd2]
        push si
        call 0x28BB:checkcoll
        add sp, 0x6
.26:
        sub word [si + 0x18], 0x2
        jns short .27
        mov word [si + 0x18], 0x0
.27:
        mov ax, [si + 0x18]
        mov [si + 0x16], ax
        add si, 0x80
        dec di
        jz short .28
        jmp near .4
.28:
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; updateanim                                                 2E42:1FFC  94 PC
; Steps an object's animation and starts the next one when it ends.
;
; Takes 1 word of stack arguments. Calls __chkstk, PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
updateanim:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
        push di
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0x38], 0x0
        jnz short .1
        and byte [si + 0x44], 0xdf
        and byte [si + 0x45], 0xfd
        pop si
        pop di
        leave
        retf
.1:
        mov bx, [si + 0x36]
        test byte [sflags], 0x80
        jz short .3
        cmp word [si + 0x5e], 0xc
        jl short .2
        cmp word [si + 0x5e], 0x10
        jnz short .3
.2:
        db 0x8A, 0xC3                           ; insn: mov al, bl
        sub al, 0x2
        and ax, strict word 0x7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.3:
        test byte [si + 0x49], 0x8
        jz short .4
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        neg ax
        and ax, strict word 0x7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.4:
        mov dx, [si + 0x38]
        shl dx, 1
        add dx, strict word SPAlist
        db 0x8B, 0xFA                           ; insn: mov di, dx
        mov ah, [di + 0x1]
        and ax, 0x8000
        mov [bp - 0x6], ax
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jz short .5
        shl bx, 1
        mov ax, [bx + di]
        jmp short .6
.5:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov ax, [bx]
.6:
        add ax, strict word 0x8
        shl ax, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        mov bx, [si + 0x3a]
        mov [bp - 0x2], bx
        shl bx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov di, [bx]
        cmp word [si + 0x3c], 0x0
        jl short .9
        dec word [si + 0x3c]
        jns short .11
        add word [si + 0x3a], 0x2
        add word [bp - 0x2], 0x2
        mov bx, [bp - 0x2]
        shl bx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        cmp word [bx - 0x2], 0x0
        jnl short .7
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x3a], ax
        mov [bp - 0x2], ax
        and byte [si + 0x44], 0xdf
        and byte [si + 0x45], 0xfd
        cmp [bp - 0x6], ax
        jnz short .7
        mov [si + 0x38], ax
.7:
        mov bx, [bp - 0x2]
        shl bx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .8
        neg word [bp - 0x2]
.8:
        mov ax, [bp - 0x2]
        mov [si + 0x3c], ax
        jmp short .11
        db 0x90
.9:
        mov [bp - 0x4], dx
        mov dx, [bp - 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        add bx, [bp - 0x4]
        mov dx, [bx + 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .10
        neg dx
.10:
        mov [si + 0x3c], dx
.11:
        dec byte [si + 0x46]
        jns short .16
        mov byte [si + 0x46], 0x0
        cmp [si + 0x12], di
        jz short .16
        mov [si + 0x12], di
        cmp di, 0x112
        jl short .12
        cmp di, 0x14e
        jg short .12
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub al, 0xfe
        test al, 0x3
        jz short .14
.12:
        cmp di, 0x207
        jl short .13
        cmp di, 0x215
        jg short .13
        test di, 0x1
        jnz short .14
.13:
        cmp di, 0x315
        jl short .15
        cmp di, 0x32a
        jg short .15
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x3
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .15
.14:
        push word 0xb3
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.15:
        mov byte [si + 0x46], 0x4
.16:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; freezewindow                                               2E42:2152  94 PC
; Freezes the camera at its current position.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
freezewindow:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov ax, [camx]
        mov [xc1], ax
        mov ax, [camy]
        mov [yc1], ax
        or byte [sflags], 0x40
        retf
        db 0x90

;-----------------------------------------------------------------------------
; cleargamevars                                              2E42:216C  94 PC
; Clears the per-game variables before a game starts.
;
; Calls __chkstk, ClearPenaltyBuffer. Far routine (retf).
;-----------------------------------------------------------------------------
cleargamevars:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [cleared2], ax
        mov [cleared1], ax
        mov [lastgoaly], ax
        mov [LastShooterTeam], ax
        mov [lastgoalx], ax
        mov [regd5], ax
        mov [regd4_w2], ax
        mov [regd4], ax
        mov [regd3_w2], ax
        mov [regd3], ax
        mov [regd2_w2], ax
        mov [regd2], ax
        mov [regd1_w2], ax
        mov [regd1], ax
        mov [regd0_w2], ax
        mov [regd0], ax
        mov word [lastsfx], 0xffff
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [collflag], al
        mov [gmode], al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [xc1], ax
        mov [yc1], ax
        mov [yleader], ax
        mov [fox], ax
        mov [foy], ax
        mov [fodir1], ax
        mov [fodir2], ax
        mov [threat], ax
        mov [halfsecflag], ax
        mov [ltack], ax
        mov [sflags], ax
        mov [gmode2], ax
        mov [sflags3], ax
        call 0x327B:ClearPenaltyBuffer
        retf

;-----------------------------------------------------------------------------
; DrawRinkOverlays                                           2E42:21E2  94 PC
; Draws the rink overlay sprites: penalty box markers and period marks.
;
; Takes 2 words of stack arguments. Calls __chkstk, DrawFrameSprite, DrawRinkObjects, SetClipRectRegs,
; JoyNibble, DrawSpriteNumber, DrawRinkEndArt, DrawTextOverlay and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawRinkOverlays:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2c
        call 0x0000:__chkstk
        push di
        push si
        mov ax, [c1playernum]
        mov [bp - 0xa], ax
        mov ax, [c2playernum]
        mov [bp - 0xc], ax
        cmp word [playsuspended], 0x0
        jz short .1
        mov ax, 0xffff
        mov [bp - 0xc], ax
        mov [bp - 0xa], ax
.1:
        cmp word [camx], -0x10
        jg short .2
        jmp near .9
.2:
        cmp word [camy], 0x50
        jnl short .5
        cmp word [camy], 0xff6c
        jng short .5
        mov word [bp - 0x22], 0x0
        jmp short .4
        db 0x90
.3:
        cmp word [bp - 0x22], 0x3
        jnl short .5
        push 0x0
        push 0x0
        mov ax, 0xfffd
        sub ax, [bp - 0x22]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push word 0xb3
        push word 0x17e
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        inc word [bp - 0x22]
.4:
        mov al, [PBnum]
        cbw
        cmp ax, [bp - 0x22]
        jg short .3
.5:
        cmp word [camy], -0x4b
        jng short .9
        cmp word [camy], 0xb1
        jnl short .9
        mov al, [PBnum_b1]
        cbw
        dec ax
        cmp ax, strict word 0x2
        jng short .6
        mov ax, 0x2
.6:
        mov [bp - 0x22], ax
        jmp short .8
        db 0x90
.7:
        push 0x1
        push 0x0
        mov ax, [bp - 0x22]
        add ax, strict word 0x3
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push word 0xb3
        push word 0x17e
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        dec word [bp - 0x22]
.8:
        cmp word [bp - 0x22], 0x0
        jnl short .7
.9:
        call 0x3136:DrawRinkObjects
        cmp word [camy], 0xff50
        jnl short .10
        mov es, [segDgroup11]
        mov ax, [es:ClipBottomY]
        mov [bp - 0x28], ax
        mov ax, [viewcelly]
        shl ax, byte 0x3
        sub ax, 0x244
        neg ax
        push ax
        mov ax, [es:ClipLeftX]
        mov bx, [es:ClipTopY]
        mov dx, [es:ClipRightX]
        call 0x0FEF:SetClipRectRegs
.10:
        mov word [bp - 0x22], 0x0
.11:
        mov si, [bp - 0x22]
        shl si, 1
        mov word [bp + si - 0x12], 0x0
        mov ax, [bp - 0x22]
        mov [bp + si - 0x8], ax
        inc word [bp - 0x22]
        cmp word [bp - 0x22], 0x3
        jl short .11
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .12
        mov al, [bx]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        mov ax, [bx + sortobj0_Ypos2]
        mov [bp - 0xe], ax
.12:
        cmp word [bp - 0xa], 0x0
        jl short .13
        mov bx, [bp - 0xa]
        shl bx, byte 0x7
        mov ax, [bx + sortobj0_Ypos2]
        mov [bp - 0x12], ax
.13:
        cmp word [bp - 0xc], 0x0
        jl short .14
        mov bx, [bp - 0xc]
        shl bx, byte 0x7
        mov ax, [bx + sortobj0_Ypos2]
        mov [bp - 0x10], ax
.14:
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x12]
        push ax
        push 0x3
        call 0x14F6:SortPairs - 0x90
        add sp, 0x6
        mov word [bp - 0x24], 0x0
        jmp near .31
.15:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        mov ax, [bp - 0xc]
        jmp short .17
        db 0x90
.16:
        mov ax, [bp - 0xa]
.17:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .18
        jmp near .30
.18:
        cmp word [bp - 0x22], 0x0
        jz short .19
        mov ax, [bp - 0xc]
        jmp short .20
        db 0x90
.19:
        mov ax, [bp - 0xa]
.20:
        shl ax, byte 0x7
        add ax, SortCords
        mov [bp - 0x26], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp word [bx + 0x12], -0x1
        jnz short .21
        jmp near .30
.21:
        mov cx, [bx + 0x2]
        mov [bp - 0x14], cx
        mov cx, [bx + 0x6]
        mov [bp - 0x20], cx
        mov word [bp - 0x2], 0x0
        cmp cx, [bp + 0x8]
        jng short .22
        mov ax, [bp + 0x8]
        mov [bp - 0x20], ax
        mov word [bp - 0x2], 0x1
        jmp short .23
.22:
        mov ax, [bp + 0x8]
        sub ax, 0xa8
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jl short .23
        mov ax, [bp + 0x8]
        sub ax, 0xa7
        mov [bp - 0x20], ax
        mov word [bp - 0x2], 0x2
.23:
        cmp word [bp - 0x2], 0x0
        jz short .25
        mov ax, [bp + 0x6]
        add ax, 0x134
        cmp ax, [bp - 0x14]
        jg short .24
        mov ax, [bp + 0x6]
        add ax, 0x133
        mov [bp - 0x14], ax
        or byte [bp - 0x2], 0x4
        jmp short .27
.24:
        mov ax, [bp + 0x6]
        add ax, strict word 0xc
        cmp ax, [bp - 0x14]
        jng short .27
        mov [bp - 0x14], ax
        or byte [bp - 0x2], 0x8
        jmp short .27
.25:
        mov ax, [bp + 0x6]
        add ax, 0x140
        cmp ax, [bp - 0x14]
        jg short .26
        mov ax, [bp + 0x6]
        add ax, 0x13f
        mov [bp - 0x14], ax
        mov word [bp - 0x2], 0x4
        jmp short .27
        db 0x90
.26:
        mov ax, [bp - 0x14]
        cmp [bp + 0x6], ax
        jng short .27
        mov ax, [bp + 0x6]
        mov [bp - 0x14], ax
        mov word [bp - 0x2], 0x8
.27:
        cmp word [bp - 0x2], 0x0
        jz short .28
        push 0x0
        mov al, [bp - 0x2]
        and ax, strict word 0x8
        push ax
        push word [bp - 0x20]
        push word [bp - 0x14]
        push word [bp - 0x2]
        call 0x03A3:JoyNibble
        add sp, 0x2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bp - 0x22]
        shl ax, byte 0x3
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push word [bx + RinkOverlayFrames2]
        jmp short .29
        db 0x90
.28:
        push 0x0
        push 0x0
        push word [bp - 0x20]
        push word [bp - 0x14]
        mov bx, [bp - 0x22]
        shl bx, 1
        push word [bx + RinkOverlayFrames]
.29:
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.30:
        inc word [bp - 0x24]
.31:
        cmp word [bp - 0x24], 0x3
        jnl short .33
        mov si, [bp - 0x24]
        shl si, 1
        mov ax, [bp + si - 0x8]
        mov [bp - 0x22], ax
        cmp ax, strict word 0x2
        jz short .32
        jmp near .15
.32:
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .30
        mov al, [bx]
        cbw
        shl ax, byte 0x7
        add ax, SortCords
        mov [bp - 0x26], ax
        push 0x0
        push 0x0
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        push word [bx + 0x6]
        push word [bx + 0x2]
        push word [RinkOverlayFrames2]
        jmp short .29
.33:
        mov word [bp - 0x26], doorstruct
        cmp word [doorframe], 0x284
        jl short .36
        cmp word [doorframe], 0x288
        jg short .36
        push 0x0
        cmp word [doorXpos2], 0x0
        jnl short .34
        mov ax, 0x1
        jmp short .35
        db 0x90
.34:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.35:
        push ax
        push word [doorYpos2]
        push word [doorXpos2]
        push word [doorframe]
        jmp short .39
        db 0x90
.36:
        mov bx, [bp - 0x26]
        cmp word [bx + 0x12], 0x189
        jnz short .37
        mov bx, [puckz]
        cmp word [bx], 0x0
        jl short .37
        mov bx, [puckc]
        cmp byte [bx], 0x10
        jnz short .38
.37:
        mov bx, [bp - 0x26]
        cmp word [bx + 0x6], 0x0
        jl short .40
        cmp word [bx + 0x12], 0x22a
        jl short .40
        cmp word [bx + 0x12], 0x237
        jg short .40
.38:
        push 0x0
        push 0x0
        mov bx, [bp - 0x26]
        push word [bx + 0x6]
        push word [bx + 0x2]
        push word [bx + 0x12]
.39:
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.40:
        mov bx, [puckc]
        cmp byte [bx], 0x10
        jz short .43
        sub word [bp - 0x26], 0x80
        mov bx, [bp - 0x26]
        cmp word [bx + 0xa], 0x0
        jnz short .41
        push 0x0
        push 0x0
        push word [bx + 0x6]
        jmp short .42
        db 0x90
.41:
        cmp word [bx + 0xa], 0x0
        jng short .43
        push 0x0
        push 0x0
        mov ax, [bx + 0xa]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bx + 0x6]
        push ax
.42:
        push word [bx + 0x2]
        push word [bx + 0x12]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.43:
        mov word [bp - 0x22], 0x10
        jmp short .47
        db 0x90
.44:
        push 0x0
        push 0x0
        mov bx, [bp - 0x26]
        mov ax, [bx + 0xa]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bx + 0x6]
        push ax
.45:
        push word [bx + 0x2]
        push word [bx + 0x12]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.46:
        dec word [bp - 0x22]
.47:
        cmp word [bp - 0x22], 0x0
        jnl short .48
        jmp near .59
.48:
        mov bx, [bp - 0x22]
        mov al, [bx + OOlist]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        add bx, SortCords
        mov [bp - 0x26], bx
        cmp word [bx + 0x5e], 0xf
        jz short .46
        cmp word [bx + 0x5e], 0xe
        jnz short .51
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .46
        mov bx, [puckz]
        cmp word [bx], 0x0
        jng short .46
        mov si, [pucky]
        cmp word [si], 0xe8
        jnl short .46
        cmp word [si], 0xff18
        jg short .44
        cmp word [si], 0xff10
        jl short .44
        mov si, [puckx]
        mov ax, [si]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jng short .49
        jmp near .44
.49:
        cmp word [bx], 0xd
        jl short .50
        jmp near .44
.50:
        jmp short .46
.51:
        cmp word [bx + 0x1a], 0x0
        jnl short .52
        cmp word [bx + 0x5e], 0x10
        jnz short .46
.52:
        cmp word [bx + 0x12], -0x1
        jz short .56
        cmp word [bx + 0x5e], 0xc
        jnl short .56
        mov si, [puckc]
        mov al, [si]
        cbw
        cmp ax, [bx + 0x5e]
        jz short .53
        mov ax, [bp - 0xa]
        cmp [bx + 0x5e], ax
        jz short .53
        mov ax, [bp - 0xc]
        cmp [bx + 0x5e], ax
        jnz short .54
.53:
        push word [bx + 0x1a]
        jmp short .55
        db 0x90
.54:
        cmp word [shownumbers], 0x0
        jz short .56
        push -0x1
.55:
        mov al, [bx + 0x52]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bx + 0x6]
        push word [bx + 0x2]
        call 0x1E7E:DrawSpriteNumber
        add sp, 0x8
.56:
        mov bx, [bp - 0x26]
        cmp word [bx + 0x5e], 0x6
        jnl short .57
        push 0x0
        jmp short .58
.57:
        push 0x1
.58:
        mov ah, [bx + 0x49]
        and ax, 0x800
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        push word [bx + 0x6]
        jmp near .45
        db 0x90
.59:
        mov bx, [pucky]
        cmp word [bx], 0xff18
        jg short .60
        cmp word [bx], 0xff14
        jl short .60
        mov si, [puckx]
        mov ax, [si]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .60
        mov si, [puckz]
        cmp word [si], 0xd
        jl short .60
        push 0x0
        push 0x0
        mov ax, [si]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl ax, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bx]
        push ax
        push cx
        push word [puckframe]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.60:
        cmp word [camy], 0xff50
        jnl short .61
        push word [bp - 0x28]
        mov es, [segDgroup11]
        mov ax, [es:ClipLeftX]
        mov bx, [es:ClipTopY]
        mov dx, [es:ClipRightX]
        call 0x0FEF:SetClipRectRegs
.61:
        cmp word [camy], 0xff70
        jnl short .62
        call 0x1E7E:DrawRinkEndArt
.62:
        mov word [bp - 0x26], doorstruct
        cmp word [doorYpos2], 0x0
        jnl short .63
        cmp word [doorframe], 0x22a
        jl short .63
        cmp word [doorframe], 0x237
        jg short .63
        push 0x0
        push 0x0
        push word [doorYpos2]
        push word [doorXpos2]
        push word [doorframe]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.63:
        mov bx, [pucky]
        cmp word [bx], 0xfef8
        jnl short .66
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .66
        mov word [bp - 0x26], puckstruct
        cmp word [puckZpos2], 0x0
        jnz short .64
        push 0x0
        push 0x0
        push word [puckYpos2]
        push word [puckXpos2]
        push word [puckframe]
        jmp short .65
.64:
        mov bx, [bp - 0x26]
        cmp word [bx + 0xa], 0x0
        jng short .66
        push 0x0
        push 0x0
        mov ax, [bx + 0xa]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bx + 0x6]
        push ax
        push word [bx + 0x2]
        push word [bx + 0x12]
.65:
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.66:
        cmp word [ovltimer], 0x0
        jl short .67
        call 0x226F:DrawTextOverlay
.67:
        cmp word [bannermsg], -0x1
        jz short .68
        push word [bannermsg]
        call 0x226F:DrawCallBanner
        add sp, 0x2
        cmp word [bannertimer], 0x0
        jng short .68
        dec word [bannertimer]
        cmp word [bannertimer], 0x0
        jg short .68
        mov word [bannertimer], 0x0
        mov word [bannermsg], 0xffff
.68:
        cmp byte [PadStates], 0x1
        jz short .69
        cmp byte [PadStates2], 0x1
        jz short .69
        jmp near .80
.69:
        cmp word [curperiod], -0x1
        jnz short .70
        jmp near .80
.70:
        cmp word [playsuspended], 0x0
        jz short .71
        jmp near .80
.71:
        cmp byte [PadStates], 0x1
        jnz short .72
        mov ax, [bp - 0xa]
        jmp short .73
        db 0x90
.72:
        mov ax, [bp - 0xc]
.73:
        mov [bp - 0x22], ax
        inc ax
        jnz short .74
        jmp near .80
.74:
        mov ax, [MouseY]
        sub ax, strict word 0x64
        mov dx, [MouseY]
        sub dx, 0x64
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [MouseX]
        sub ax, 0xa0
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov dx, [MouseX]
        sub dx, 0xa0
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x03A3:ImulRegs
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jg short .76
        jl short .75
        cmp si, 0x9c4
        jnc short .76
.75:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x20], ax
        mov [bp - 0x14], ax
        mov word [bp - 0x2], 0x8
        jmp short .77
.76:
        mov ax, [MouseX]
        sub ax, 0xa0
        mov dx, 0x64
        mov cx, [MouseY]
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        call 0x0D5F:VectorToDir8
        mov [bp - 0x2], ax
        mov ax, [MouseX]
        sub ax, 0xa0
        mov [bp - 0x14], ax
        mov cx, 0x4
        cwd
        idiv cx
        mov [bp - 0x14], ax
        mov ax, 0x64
        mov dx, [MouseY]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x20], ax
.77:
        mov bx, [bp - 0x22]
        shl bx, byte 0x7
        mov ax, [bx + sortobj0_Xpos2]
        add [bp - 0x14], ax
        mov ax, [bx + sortobj0_Ypos2]
        add [bp - 0x20], ax
        cmp word [bp - 0x2], 0x4
        jng short .78
        cmp word [bp - 0x2], 0x8
        jnl short .78
        mov word [bp - 0x2c], 0x1
        jmp short .79
.78:
        mov word [bp - 0x2c], 0x0
.79:
        push 0x0
        push word [bp - 0x2c]
        push word [bp - 0x20]
        push word [bp - 0x14]
        mov bx, [bp - 0x2]
        shl bx, 1
        push word [bx + RinkOverlayFrames3]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.80:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; setupice                                                   2E42:290C  94 PC
; Per-period rink set-up: flips the attack direction and resets the sprites.
;
; Calls __chkstk, defaultsprites_0. Far routine (retf).
;-----------------------------------------------------------------------------
setupice:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        and byte [sflags], 0xfe
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [camx], ax
        mov [camy], ax
        push cs
        call defaultsprites_0
        test byte [gmode], 0x2
        jz short .2
        mov bx, SortCords
        mov dx, 0xc
.1:
        xor byte [bx + 0x44], 0x80
        add bx, 0x80
        dec dx
        jnz short .1
.2:
        mov al, 0xff
        mov [c1playernum_b1], al
        mov [c2playernum_b1], al
        retf
        db 0x90

;-----------------------------------------------------------------------------
; clockcont_0                                                2E42:2946  94 PC
; End of period: next period, overtime, shootout or game over.
;
; Calls __chkstk, assinsert, IsCupClinched, ClearPenaltyBuffer, assreplace, SetBoxDoorObject,
; ImulRegs, setplayer and others. Far routine (retf).
;-----------------------------------------------------------------------------
clockcont_0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x10
        call 0x0000:__chkstk
        push di
        push si
        push 0x18
        mov ax, puckstruct
        mov [bp - 0xa], ax
        push ax
        call 0x1E7E:assinsert
        add sp, 0x4
        cmp word [gsp], 0x2
        jnl short .1
        push 0x1
        push word puckstruct
        jmp near .32
        db 0x90
.1:
        mov word [regd0], 0x7
        push word [awscore]
        push word [hmscore]
        call 0x1E45:IsCupClinched
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        mov word [regd0], 0x8
.2:
        mov word [bp - 0xa], SortCords
        mov ax, [hmscore]
        sub ax, [awscore]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        cmp word [gsp], 0x3
        jnz short .5
        test byte [AnnouncerFlags], 0x2
        jz short .5
        call 0x327B:ClearPenaltyBuffer
        cmp word [CrowdSound], 0x4b0
        jg short .3
        add word [CrowdSound], 0x384
        cmp word [CrowdSound], 0x4b0
        jng short .3
        mov word [CrowdSound], 0x4b0
.3:
        add word [crowdheat], 0x28
        or byte [gmode], 0x41
        mov word [regd2], 0x0
.4:
        mov bx, [regd2]
        shl bx, byte 0x7
        and byte [bx + CwdExciteLvl], 0xf7
        inc word [regd2]
        cmp word [regd2], 0xc
        jl short .4
        push 0x2
        jmp short .6
        db 0x90
.5:
        push 0x1
.6:
        push word SortCords
        jmp near .32
.7:
        mov ax, 0xffff
        mov [c2playernum], ax
        mov [c1playernum], ax
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov bx, [puck_1C]
        cmp byte [bx + puckasslist], 0x18
        jnz short .8
        push 0x1a
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
.8:
        mov word [regd2], 0x0
.9:
        mov bx, [regd2]
        shl bx, byte 0x7
        and byte [bx + CwdExciteLvl], 0xf7
        inc word [regd2]
        cmp word [regd2], 0xc
        jl short .9
        cmp word [regd1], 0x0
        jl short .10
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .11
.10:
        mov si, 0x6
.11:
        shl si, byte 0x7
        add si, SortCords
        cmp word [regd1], 0x0
        jnl short .12
        mov ax, 0x1
        jmp short .13
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.13:
        push ax
        call 0x3136:SetBoxDoorObject
        add sp, 0x2
        cmp word [regd0], 0x8
        jz short .14
        jmp near .18
.14:
        or byte [gmode], 0x80
        push 0x2b
        push word doorstruct
        call 0x1E7E:assinsert
        add sp, 0x4
        mov word [bp - 0x8], 0x9c40
        mov word [bp - 0x6], 0x0
        mov di, [si + 0x5e]
        mov word [regd2], 0x0
.15:
        cmp word [si + 0x1a], 0x0
        jng short .17
        mov ax, [si + 0x6]
        sub ax, strict word 0x6
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        add dx, 0x91
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov [bp - 0x10], cx
        mov [bp - 0xe], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0x10]
        adc dx, [bp - 0xe]
        mov [bp - 0x4], ax
        cmp dx, [bp - 0x6]
        jg short .17
        jl short .16
        cmp ax, [bp - 0x8]
        ja short .17
.16:
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov di, [si + 0x5e]
.17:
        add si, 0x80
        inc word [regd2]
        cmp word [regd2], 0x6
        jl short .15
        mov [bp - 0xc], di
.18:
        cmp word [regd1], 0x0
        jl short .19
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .20
.19:
        mov si, 0x6
.20:
        shl si, byte 0x7
        add si, SortCords
        mov word [shotplayer], 0xffff
        mov word [regd1], 0x0
        mov word [regd2], 0x6
.21:
        cmp word [si + 0x1a], 0x0
        jng short .27
        cmp word [regd0], 0x8
        jnz short .26
        mov ax, [bp - 0xc]
        cmp [si + 0x5e], ax
        jnz short .26
        push 0x8
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
        push 0x2a
.22:
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.23:
        add si, 0x80
        dec word [regd2]
        jnz short .21
        call 0x327B:ClearPenaltyBuffer
        mov ax, [hmscore]
        cmp [awscore], ax
        jl short .24
        jmp near .30
.24:
        cmp word [CrowdSound], 0x5dc
        jg short .25
        add word [CrowdSound], 0x3e8
        cmp word [CrowdSound], 0x5dc
        jng short .25
        mov word [CrowdSound], 0x5dc
.25:
        cmp word [regd0], 0x8
        jnz short .31
        add word [CrowdSound], 0x320
        jmp short .31
        db 0x90
.26:
        push 0x7
        jmp short .22
.27:
        cmp word [si + 0x1a], 0x0
        jnl short .23
        mov bx, [si + 0x60]
        mov [bp - 0x4], bx
        mov al, [bx + 0x9c]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .23
        cmp word [regd1], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x2
        add ax, strict word 0x3
        mov [si + 0x1a], ax
        inc word [regd1]
        push 0x7
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
        push di
        push si
        push cs
        call setplayer
        add sp, 0x4
        mov di, 0x1
        mov [bp - 0xa], si
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov di, [bp - 0x4]
        jmp short .29
.28:
        inc si
.29:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + 0x9c]
        mov [bx + 0x9b], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jnl short .28
        mov si, [bp - 0xa]
        jmp near .23
        db 0x90
.30:
        cmp word [CrowdSound], 0x320
        jnl short .31
        mov word [CrowdSound], 0x320
.31:
        add word [crowdheat], 0x28
        or byte [gmode], 0x41
        push 0x2
        push si
.32:
        call 0x327B:AddPenalty2
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ClockTick                                                  2E42:2C30  94 PC
; Counts the game clock down from the main loop: the one-minute horn and the coach modes each second.
;
; Calls __chkstk, PlaySoundEffect, AnnounceOneMinute, UpdateCoachModes. Far routine (retf).
;-----------------------------------------------------------------------------
ClockTick:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [gameclock], 0x0
        jnz short .1
        cmp word [clockticks], 0x0
        jnz short .1
        jmp near .9
.1:
        dec word [clockticks]
        js short .2
        jmp near .9
.2:
        cmp word [gameclock], 0x0
        jng short .3
        dec word [gameclock]
        add word [clockticks], 0x18
        jmp short .4
        db 0x90
.3:
        mov word [clockticks], 0x0
.4:
        cmp word [gameclock], 0x3d
        jz short .5
        cmp word [gameclock], 0x3c
        jnz short .6
.5:
        push word 0x97
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        cmp word [gameclock], 0x3c
        jnz short .6
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        call 0x0EDC:AnnounceOneMinute
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
.6:
        mov ax, [gameclock]
        mov cx, 0x3c
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .9
        cmp word [curperiod], 0x3
        jnz short .7
        cmp [gameclock], cx
        jz short .8
        cmp word [gameclock], 0x78
        jz short .8
        cmp word [gameclock], 0xb4
        jz short .8
        cmp word [gameclock], 0x12c
        jz short .8
        cmp word [gameclock], 0x258
        jz short .8
.7:
        cmp word [curperiod], 0x2
        jnz short .9
        cmp word [gameclock], 0x258
        jnz short .9
.8:
        push cs
        call UpdateCoachModes
.9:
        retf

;-----------------------------------------------------------------------------
; SprSortVert                                                2E42:2CEE  94 PC
; Clears the horizontal sort flag and falls into SprSort.
;
; Calls __chkstk, SprSort. Far routine (retf).
;-----------------------------------------------------------------------------
SprSortVert:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        and byte [sflags], 0x7f
        push cs
        call SprSort
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GameOver                                                   2E42:2D00  94 PC
; Sets the main loop's game-over request.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
GameOver:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [gameover], 0x0
        jnz short .1
        mov word [gameover], 0x1
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetExitGame                                                2E42:2D16  94 PC
; Sets the main loop's exit request.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
SetExitGame:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [exitgame], 0x0
        jnz short .1
        mov word [exitgame], 0x1
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetupTeamForIntermission                                   2E42:2D2C  94 PC
; ResetBench, reenergizeteam both teams, line by score difference.
;
; Calls __chkstk, ResetBench, reenergizeteam. Far routine (retf).
;-----------------------------------------------------------------------------
SetupTeamForIntermission:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push di
        push si
        push cs
        call ResetBench
        mov si, hmshots
        mov di, awshots
        mov word [bp - 0x2], 0x2
.1:
        push si
        push cs
        call reenergizeteam
        add sp, 0x2
        mov word [si + 0x16], 0x0
        test byte [CrowdState], 0x4
        jz short .3
        mov ax, [si + 0x22]
        sub ax, [di + 0x22]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .2
        mov word [si + 0x16], 0x4
        jmp short .3
        db 0x90
.2:
        mov word [si + 0x16], 0x6
.3:
        mov si, awshots
        mov di, hmshots
        dec word [bp - 0x2]
        jnz short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; Intermission                                               2E42:2D88  94 PC
; SetupTeamForIntermission, clears the sort entries.
;
; Calls __chkstk, SetupTeamForIntermission. Far routine (retf).
;-----------------------------------------------------------------------------
Intermission:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        push cs
        call SetupTeamForIntermission
        mov si, sortobj0_Xpos2
.1:
        add si, 0x80
        mov word [si - 0x80], 0x0
        cmp si, TitleJingleSeg
        jc short .1
        pop si
        retf

;-----------------------------------------------------------------------------
; PeriodOver_sp                                              2E42:2DA8  94 PC
; Period 4 ends the game, else Intermission, StartPer, SetPenaltyStrength.
;
; Calls __chkstk, GameOver, Intermission, IntermissionPC, StartPer, SetPenaltyStrength. Far routine
; (retf).
;-----------------------------------------------------------------------------
PeriodOver_sp:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [gsp], 0x4
        jnz short .1
        push cs
        call GameOver
        retf
        db 0x90
.1:
        push cs
        call Intermission
        cmp word [gsp], 0x0
        jng short .2
        call 0x1E7E:IntermissionPC
.2:
        push cs
        call StartPer
        call 0x2164:SetPenaltyStrength
        retf

;-----------------------------------------------------------------------------
; PeriodOver                                                 2E42:2DD6  94 PC
; Next period, overtime or game over.
;
; Calls __chkstk, PeriodOver_sp. Far routine (retf).
;-----------------------------------------------------------------------------
PeriodOver:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov ax, 0xffff
        mov [lcactive], ax
        mov [lcgroup], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [lcrequestteam], ax
        mov [energywarnteam], ax
        mov [energywarn], ax
        mov [lcsel], ax
        mov [hudredraw], ax
        mov [lcboxon], ax
        cmp word [exitgame], -0x1
        jz short .2
        xor byte [gmode], 0x2
        inc word [gsp]
        cmp word [gsp], 0x3
        jl short .2
        jng short .1
        mov word [gsp], 0x3
        test byte [AnnouncerFlags], 0x2
        jz short .1
        mov word [gsp], 0x4
.1:
        mov ax, [hmscore]
        sub ax, [awscore]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        mov word [gsp], 0x4
.2:
        push cs
        call PeriodOver_sp
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetBench                                                 2E42:2E40  94 PC
; Resets the bench between periods.
;
; Calls __chkstk. Far routine (retf).
;-----------------------------------------------------------------------------
ResetBench:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
        push di
        push si
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov bx, hmshots
.1:
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov byte [si + PBnum], 0x0
        mov dx, 0x1b
        mov di, 0x438
        lea ax, [bx + 0x9a]
        mov [bp - 0x6], bx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.2:
        cmp word [bx], 0x0
        jng short .4
        test byte [bx + 0x1], 0x10
        jz short .3
        test word [bx], 0x7ff
        jz short .5
.3:
        db 0x8B, 0xF1                           ; insn: mov si, cx
        inc byte [si + PBnum]
        jmp short .5
        db 0x90
.4:
        cmp word [bx], -0x3
        jng short .5
        mov word [bx], 0xfffe
        mov si, [bp - 0x6]
        mov si, [si + 0xd0]
        db 0x03, 0xF7                           ; insn: add si, di
        mov byte [si], 0x3
.5:
        sub di, 0x28
        dec bx
        dec bx
        dec dx
        jns short .2
        mov bx, awshots
        inc cx
        cmp cx, 0x2
        jl short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; resetplstuff                                               2E42:2EAC  94 PC
; Resets the players' flags and animations for both teams.
;
; Calls __chkstk, SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
resetplstuff:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push di
        push si
        mov bx, hmshots
        mov word [bp - 0x4], 0x2
.1:
        and byte [bx + 0x2a], 0xef
        mov cx, [bx + 0xd4]
        mov di, 0x6
        db 0x8B, 0xF1                           ; insn: mov si, cx
.2:
        mov byte [si + 0x45], 0x0
        cmp word [si + 0x1a], 0x0
        jl short .3
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x289
        push cs
        call SetSPA
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x3e], ax
        mov [si + 0x18], ax
        and byte [si + 0x44], 0xc2
.3:
        add si, 0x80
        dec di
        jnz short .2
        mov bx, awshots
        dec word [bp - 0x4]
        jnz short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; StartGame                                                  2E42:2F00  94 PC
; Cleargamevars, clearteams, period 0, restoreteams, PeriodOver_sp.
;
; Calls __chkstk, cleargamevars, clearteams, restoreteams, PeriodOver_sp. Far routine (retf).
;-----------------------------------------------------------------------------
StartGame:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push cs
        call cleargamevars
        push cs
        call clearteams
        mov word [gsp], 0x0
        push cs
        call restoreteams
        push cs
        call PeriodOver_sp
        retf

;-----------------------------------------------------------------------------
; forceteams                                                 2E42:2F1E  94 PC
; Setpersonel and forcepldata for both teams.
;
; Calls __chkstk, setpersonel, forcepldata.
;-----------------------------------------------------------------------------
forceteams:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push word hmshots
        push cs
        call setpersonel
        add sp, 0x2
        push word hmshots
        push cs
        call forcepldata
        add sp, 0x2
        push word awshots
        push cs
        call setpersonel
