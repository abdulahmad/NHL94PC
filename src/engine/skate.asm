; Skating: acceleration, steering and stopping (AI.OVL)

;-----------------------------------------------------------------------------
; doplayeracc                                                2425:0000  94 PC
; Player accelerates toward a direction.
;
; Takes 2 words of stack arguments. Calls goalieacc, dostop, SetSPA, VectorToDir8, noturn0, ImulRegs,
; playeracc. Far routine (retf).
;-----------------------------------------------------------------------------
doplayeracc:
        enter 0xe, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0x1a], 0x0
        jnz short .1
        push word [bp + 0x8]
        push si
        push cs
        call goalieacc
        jmp near .33
.1:
        mov al, [si + 0x44]
        and al, 0x10
        jz short .2
        mov cx, 0x529
        jmp short .6
.2:
        cmp word [si + 0x5e], 0x10
        jnz short .5
        cmp word [refsignal], 0x0
        jnz short .4
        test byte [gmode], 0x1
        jnz short .3
        test byte [gmode2], 0x80
        jnz short .4
        test byte [gmode], 0x8
        jnz short .4
.3:
        mov cx, 0xa5b
        jmp short .6
        db 0x90
.4:
        mov cx, 0xb4b
        jmp short .6
        db 0x90
.5:
        mov cx, 0x289
.6:
        and word [bp + 0x8], 0xf
        cmp word [bp + 0x8], 0x7
        jng short .9
        cmp word [bp + 0x8], 0x9
        jnz short .7
        mov ax, [si + 0xc]
        or ax, [si + 0xe]
        jz short .7
        push si
        push cs
        call dostop
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        test byte [si + 0x45], 0x2
        jz short .8
        jmp near .34
.8:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        pop si
        pop di
        leave
        retf
.9:
        mov [bp - 0x8], cx
        mov di, [bp + 0x8]
        mov [bp - 0x6], di
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .12
        mov bx, [puckx]
        mov ax, [bx]
        sub ax, [si + 0x2]
        mov [bp - 0x2], ax
        mov dx, [si + 0x6]
        mov bx, [puckvy]
        mov al, [bx + 0x1]
        cbw
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov bx, [pucky]
        add ax, [bx]
        mov [bp - 0x4], ax
        test byte [si + 0x44], 0x80
        jnz short .10
        neg word [bp - 0x2]
        neg dx
        neg word [bp - 0x4]
        xor di, 0x4
.10:
        mov al, [si + 0x44]
        and al, 0x10
        jnz short .11
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .12
        cmp di, 0x4
        jnz short .12
        mov ax, [bp - 0x2]
        mov dx, [bp - 0x4]
        call 0x0D5F:VectorToDir8
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .12
.11:
        test byte [si + 0x44], 0x10
        jz short .14
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub al, 0x3
        and ax, strict word 0x7
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0x2
        jg short .12
        mov ax, [bp - 0x2]
        mov dx, [bp - 0x4]
        call 0x0D5F:VectorToDir8
        add al, 0x2
        and al, 0x7
        cmp al, 0x4
        jng short .14
.12:
        and byte [si + 0x44], 0xef
.13:
        mov di, [bp - 0x6]
        sub di, [si + 0x36]
        and di, 0x7
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        cmp word [bx + doplayeracc_ftab], 0x0
        jnz short .16
        push word [si + 0x36]
        push di
        push si
        push cs
        call noturn0
        add sp, 0x6
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90
.14:
        test byte [si + 0x44], 0x10
        jnz short .13
        cmp word [si + 0x5e], 0x10
        jz short .13
        test byte [gmode], 0x1
        jnz short .13
        mov ax, [si + 0xc]
        or ax, [si + 0xe]
        jz short .15
        mov ax, [si + 0xc]
        mov dx, [si + 0xe]
        call 0x0D5F:VectorToDir8
        sub al, [bp - 0x6]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .13
.15:
        or byte [si + 0x44], 0x10
        jmp short .13
        db 0x90
.16:
        mov ax, [si + 0xe]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0xc]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov [bp - 0xc], cx
        mov [bp - 0xa], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xc]
        adc dx, [bp - 0xa]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        cwd
        mov [regd3], ax
        mov [regd3_w2], dx
        mov ax, 0x300
        sub ax, [regd3]
        mov [regd4], ax
        cmp ax, 0x180
        jnl short .17
        mov word [regd4], 0x180
.17:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        add bx, 0x58fa
        mov [bp - 0xe], bx
        mov dx, [bx]
        mov ax, [regd4]
        call 0x03A3:ImulRegs
        mov [regd4], ax
        mov [regd4_w2], dx
        test byte [si + 0x44], 0x10
        jz short .18
        neg word [regd4]
        adc word [regd4_w2], 0x0
        neg word [regd4_w2]
.18:
        mov ax, [regd4]
        mov dx, [regd4_w2]
        add [si + 0x34], ax
        adc [si + 0x36], dx
        and word [si + 0x36], 0x7
        cmp word [regd3], 0x14
        jna short .19
        mov bx, [bp - 0xe]
        cmp word [bx], 0x0
        jnl short .20
        mov ax, 0x1
        jmp short .21
        db 0x90
.19:
        mov cx, [bp - 0x8]
        jmp short .30
        db 0x90
.20:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.21:
        mov ch, [si + 0x49]
        and cx, 0x800
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .25
        cmp word [si + 0x5e], 0x10
        jnz short .24
        cmp word [refsignal], 0x0
        jnz short .23
        test byte [gmode], 0x1
        jnz short .22
        test byte [gmode2], 0x80
        jnz short .23
        test byte [gmode], 0x8
        jnz short .23
.22:
        mov cx, 0xabb
        jmp short .29
.23:
        mov cx, 0xbab
        jmp short .29
        db 0x90
.24:
        mov cx, 0x331
        jmp short .29
        db 0x90
.25:
        cmp word [si + 0x5e], 0x10
        jnz short .28
        cmp word [refsignal], 0x0
        jnz short .27
        test byte [gmode], 0x1
        jnz short .26
        test byte [gmode2], 0x80
        jnz short .27
        test byte [gmode], 0x8
        jnz short .27
.26:
        mov cx, 0xad3
        jmp short .29
        db 0x90
.27:
        mov cx, 0xbc3
        jmp short .29
        db 0x90
.28:
        mov cx, 0x349
.29:
        or byte [si + 0x45], 0x2
.30:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        cmp word [regd3], 0x2
        jna short .34
        test byte [si + 0x44], 0x10
        jz short .31
        mov cx, [si + 0x36]
        xor cl, 0x4
        jmp short .32
        db 0x90
.31:
        mov cx, [si + 0x36]
.32:
        push cx
        push si
        push cs
        call playeracc
.33:
        add sp, 0x4
.34:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; EvadePlayers                                               2425:02CE  94 PC
; Skateto collision routine.
;
; Takes 1 word of stack arguments. Calls VectorToDir8. Far routine (retf).
;-----------------------------------------------------------------------------
EvadePlayers:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x45], 0x20
        jz short .1
        jmp near .33
.1:
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp bx, 0xa2
        jng short .10
        cmp bx, 0xf2
        jng short .10
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x32
        jnl short .10
        cmp word [si + 0x6], 0x0
        jng short .6
        cmp word [si + 0xe], 0x0
        jng short .4
        cmp word [si + 0x2], 0x0
        jl short .2
        mov ax, 0x1
        jmp short .3
        db 0x90, 0x90
.2:
        mov ax, 0x7
.3:
        mov [regd0], ax
        pop si
        pop di
        leave
        retf
.4:
        cmp word [si + 0x2], 0x0
        jnl short .9
.5:
        mov ax, 0x6
        jmp short .3
        db 0x90
.6:
        cmp word [si + 0xe], 0x0
        jnl short .8
        cmp word [si + 0x2], 0x0
        jl short .7
        mov ax, 0x3
        jmp short .3
        db 0x90
.7:
        mov ax, 0x5
        jmp short .3
        db 0x90
.8:
        cmp word [si + 0x2], 0x0
        jl short .5
.9:
        mov ax, 0x2
        jmp short .3
        db 0x90
.10:
        mov word [bp - 0x6], 0x64
        mov di, 0xb50e
        mov word [bp - 0x2], 0x0
.11:
        cmp word [bp - 0x2], 0xc
        jnz short .12
        jmp near .32
.12:
        cmp word [bp - 0x2], 0xd
        jnz short .13
        jmp near .32
.13:
        cmp word [bp - 0x2], 0xe
        jnz short .14
        cmp word [bp - 0x6], 0x50
        jg short .14
        jmp near .32
.14:
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov [bp - 0x4], ax
        mov [regd2], ax
        mov al, [di + 0xd]
        cbw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [si + 0xd]
        cbw
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add [regd2], ax
        mov ax, [regd2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [regd2], ax
        cmp ax, strict word 0x28
        jng short .15
        jmp near .32
.15:
        mov ax, [si + 0x6]
        sub ax, [di + 0x6]
        mov [bp - 0x8], ax
        mov [regd1], ax
        mov al, [di + 0xf]
        cbw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [si + 0xf]
        cbw
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [regd1], ax
        cmp ax, strict word 0x28
        jng short .16
        jmp near .32
.16:
        mov ax, [regd2]
        add ax, [regd1]
        cmp ax, [bp - 0x6]
        jl short .17
        jmp near .32
.17:
        mov ax, [regd2]
        add ax, [regd1]
        mov [bp - 0x6], ax
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x8]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        cmp word [si + 0x2], 0xff7e
        jnl short .19
        cmp ax, strict word 0x4
        jg short .18
        jmp near .32
.18:
        cmp ax, strict word 0x8
        jmp short .21
        db 0x90
.19:
        cmp word [si + 0x2], 0x82
        jng short .23
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .20
        jmp near .32
.20:
        cmp ax, strict word 0x4
.21:
        jl short .22
        jmp near .32
.22:
        cmp word [di + 0xe], 0x1
        cmc
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x4
        jmp near .31
        db 0x90
.23:
        cmp word [si + 0x2], -0x64
        jng short .26
        cmp word [si + 0x2], 0x0
        jnl short .26
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .24
        jmp near .32
.24:
        cmp ax, strict word 0x4
        jnl short .32
        mov ax, 0x8
        sub ax, [regd0]
        mov [regd0], ax
        cmp ax, strict word 0x6
        jnz short .25
        cmp word [di + 0xe], 0x0
        jz short .25
        mov dx, [bp - 0x8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .27
        mov ax, 0x5
        jmp short .31
        db 0x90
.25:
        mov dx, [bp - 0x8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .30
        mov ax, 0x7
        jmp short .31
.26:
        mov dx, [bp - 0x8]
        cmp word [si + 0x2], 0x64
        jnl short .32
        cmp word [si + 0x2], 0x0
        jl short .32
        cmp ax, strict word 0x4
        jng short .32
        cmp ax, strict word 0x8
        jnl short .32
        mov ax, 0x8
        sub ax, [regd0]
        mov [regd0], ax
        cmp ax, strict word 0x2
        jnz short .29
        cmp word [di + 0xe], 0x0
        jz short .29
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .28
.27:
        mov ax, 0x4
        jmp short .31
        db 0x90
.28:
        mov ax, 0x3
        jmp short .31
        db 0x90
.29:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .30
        mov ax, 0x1
        jmp short .31
        db 0x90
.30:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.31:
        mov [regd0], ax
.32:
        add di, 0x80
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0xf
        jnl short .33
        jmp near .11
.33:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; EvadePC                                                    2425:04EA  94 PC
; Avoid the puck carrier.
;
; Takes 1 word of stack arguments. Calls VectorToDir8. Far routine (retf).
;-----------------------------------------------------------------------------
EvadePC:
        enter 0x4, 0x0
        push di
        push si
        mov bx, [puckc]
        mov al, [bx]
        db 0x0A, 0xC0                           ; insn: or al, al
        jnl short .1
        jmp near .6
.1:
        mov si, [bp + 0x6]
        cbw
        shl ax, byte 0x7
        add ax, 0xb50e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov cx, [si + 0x2]
        sub cx, [bx + 0x2]
        mov [bp - 0x2], cx
        mov al, [bx + 0xd]
        cbw
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov al, [si + 0xd]
        cbw
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [regd2], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jg short .6
        mov ax, [si + 0x6]
        sub ax, [di + 0x6]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov al, [di + 0xf]
        cbw
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        mov al, [si + 0xf]
        cbw
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jg short .6
        mov [regd1], cx
        mov ax, [bp - 0x2]
        mov [regd0], ax
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        test byte [CrowdState], 0x2
        jz short .6
        test byte [si + 0x44], 0x80
        jnz short .2
        mov dx, [si + 0x6]
        neg dx
        jmp short .3
        db 0x90, 0x90
.2:
        mov dx, [si + 0x6]
.3:
        sub dx, 0x4e
        mov [regd1], dx
        cmp dx, 0xa
        jg short .6
        cmp dx, -0x32
        jl short .6
        mov ax, [si + 0x2]
        mov [regd1], ax
        cmp [di + 0x2], ax
        jnl short .4
        mov ax, 0x2
        jmp short .5
.4:
        mov ax, 0x6
.5:
        mov [regd0], ax
.6:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; skateto                                                    2425:05A8  94 PC
; Skates a player toward a target point, steering round the goals and calling an optional collision
; routine, then accelerates.
;
; Takes 3 words of stack arguments. Calls avdgoal, VectorToDir8, doplayeracc. Far routine (retf).
;-----------------------------------------------------------------------------
skateto:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        dec byte [si + 0x29]
        js short .1
        jmp near .8
.1:
        add byte [si + 0x29], 0xc
        test byte [si + 0x44], 0x8
        jnz short .2
        push si
        push cs
        call avdgoal
        add sp, 0x2
.2:
        mov al, [si + 0xd]
        cbw
        add ax, [si + 0x2]
        sub [regd0], ax
        mov al, [si + 0xf]
        cbw
        add ax, [si + 0x6]
        sub [regd1], ax
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jg short .3
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jg short .3
        mov word [regd0], 0x9
        jmp short .4
        db 0x90
.3:
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
.4:
        mov ax, [bp + 0xa]
        or ax, [bp + 0x8]
        jz short .5
        push si
        call far [bp + 0x8]
        add sp, 0x2
.5:
        mov al, [regd0]
        mov [si + 0x28], al
        cmp word [regd0], 0x7
        jng short .8
        mov ax, [si + 0xc]
        or ax, [si + 0xe]
        jnz short .8
        test byte [puckpflags2], 0x1
        jz short .6
        mov ax, [xc1]
        mov [regd0], ax
        mov ax, [yc1]
        jmp short .7
        db 0x90
.6:
        mov bx, [puckx]
        mov ax, [bx]
        mov [regd0], ax
        mov bx, [pucky]
        mov ax, [bx]
.7:
        mov [regd1], ax
        mov ax, [si + 0x2]
        sub [regd0], ax
        mov ax, [si + 0x6]
        sub [regd1], ax
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        sub ax, [si + 0x36]
        neg ax
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        mov al, [regd0]
        and ax, strict word 0x4
        sar ax, 1
        add al, [si + 0x36]
        dec al
        and ax, strict word 0x7
        mov [si + 0x36], ax
.8:
        mov al, [si + 0x28]
        cbw
        push ax
        push si
        push cs
        call doplayeracc
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; skatetopuck                                                2425:06A4  94 PC
; Skates a player toward the puck (leading its motion), with a sweep check when close.
;
; Takes 1 word of stack arguments. Calls avdgoal, GetHot, VectorToDir8, randomd0, ImulRegs,
; Sweepcheck, doplayeracc. Far routine (retf).
;-----------------------------------------------------------------------------
skatetopuck:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov bx, [puckvx]
        mov al, [bx + 0x1]
        sar al, 1
        cbw
        mov bx, [puckx]
        add ax, [bx]
        mov [regd0], ax
        mov bx, [puckvy]
        mov al, [bx + 0x1]
        sar al, 1
        cbw
        mov bx, [pucky]
        add ax, [bx]
        mov [regd1], ax
        dec byte [si + 0x29]
        js short .1
        jmp near .6
.1:
        add byte [si + 0x29], 0xa
        push si
        push cs
        call avdgoal
        add sp, 0x2
        mov di, [regd0]
        mov ax, [regd1]
        mov [bp - 0x2], ax
        push si
        call 0x2E42:GetHot
        add sp, 0x2
        mov al, [si + 0xd]
        cbw
        db 0x2B, 0xF8                           ; insn: sub di, ax
        sub di, [si + 0x2]
        mov al, [regd0]
        cbw
        db 0x2B, 0xF8                           ; insn: sub di, ax
        mov [regd0], di
        mov al, [si + 0xf]
        cbw
        sub ax, [bp - 0x2]
        neg ax
        sub ax, [si + 0x6]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [regd1]
        cbw
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov [regd1], cx
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov al, [regd0]
        mov [si + 0x28], al
        cmp word [si + 0x1a], 0x0
        jnz short .2
        jmp near .6
.2:
        mov bx, [puckvx]
        mov ax, [bx]
        mov bx, [puckvy]
        mov dx, [bx]
        call 0x0D5F:VectorToDir8
        xor al, 0x4
        mov [regd0], ax
        cmp [si + 0x36], ax
        jnz short .4
        mov bx, [puckvx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xfa0
        jnl short .3
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xfa0
        jl short .4
.3:
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
.4:
        mov bx, [puckx]
        mov ax, [bx]
        sub ax, [si + 0x2]
        mov [regd0], ax
        mov bx, [pucky]
        mov ax, [bx]
        sub ax, [si + 0x6]
        mov [regd1], ax
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        cmp ax, [si + 0x36]
        jnz short .6
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd1]
        mov [bp - 0x6], di
        mov [bp - 0x4], dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x6]
        adc dx, [bp - 0x4]
        mov [regd0], ax
        mov [regd0_w2], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .5
        cmp ax, 0x384
        jna short .6
.5:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .6
        cmp ax, 0x5a4
        ja short .6
        push si
        call 0x28BB:Sweepcheck
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90
.6:
        mov al, [si + 0x28]
        cbw
        push ax
        push si
        push cs
        call doplayeracc
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; playeracc                                                  2425:080C  94 PC
; Accelerates a player in a direction, limited by his speed and weight, and drains energy when fatigue
; is on.
;
; Takes 2 words of stack arguments. Calls ImulRegs, MulRegs, LongSarAt, randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
playeracc:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov cl, [si + 0x4b]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        add cx, 0x30
        mov bx, [bp + 0x8]
        shl bx, byte 0x2
        mov ax, [bx + dirtab0]
        imul cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x6
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x2], ax
        mov ax, [bx + dirtab_x]
        imul cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x6
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x4], ax
        cmp word [si + 0x32], 0x0
        jz short .1
        mov ax, [si + 0x32]
        xor ax, [bp - 0x2]
        jnl short .1
        mov word [bp - 0x2], 0x0
.1:
        cmp word [si + 0x30], 0x0
        jz short .2
        mov ax, [si + 0x30]
        xor ax, [bp - 0x4]
        jl short .2
        mov word [bp - 0x4], 0x0
.2:
        mov al, [si + 0x4b]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, [si + 0x4a]
        shr cl, byte 0x3
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add ax, strict word 0x20
        mov [regd2], ax
        cmp word [si + 0x1a], 0x0
        jnz short .3
        mov al, [si + 0x4b]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x8
        add [regd2], ax
.3:
        mov ax, [bp - 0x2]
        mov dx, [regd2]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        mov [regd0], ax
        mov [regd0_w2], dx
        mov ax, [bp - 0x4]
        mov dx, [regd2]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        mov [regd1], ax
        mov [regd1_w2], dx
        mov ax, [si + 0xc]
        add [regd0], ax
        mov ax, [si + 0xe]
        add [regd1], ax
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd1]
        mov [bp - 0x8], di
        mov [bp - 0x6], dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x8]
        adc dx, [bp - 0x6]
        mov [regd3], ax
        mov [regd3_w2], dx
        cmp word [si + 0x5e], 0x10
        jnz short .4
        mov word [regd2], 0xf
        mov word [regd2_w2], 0x0
        jmp short .5
        db 0x90
.4:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        mov dl, [si + 0x4c]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        call 0x03A3:MulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        mov [regd2], ax
        mov [regd2_w2], dx
.5:
        mov bx, [regd2]
        shl bx, byte 0x2
        mov ax, [bx + AccelFactors]
        mov dx, [bx + AccelFactors2]
        mov [regd2], ax
        mov [regd2_w2], dx
        test byte [si + 0x45], 0x40
        jz short .6
        push 0x3
        push word regd2
        call 0x0000:LongSarAt
.6:
        mov ax, [regd2]
        mov dx, [regd2_w2]
        cmp [regd3_w2], dx
        ja short .8
        jc short .7
        cmp [regd3], ax
        ja short .8
.7:
        mov ax, [regd0]
        mov [si + 0xc], ax
        mov ax, [regd1]
        mov [si + 0xe], ax
.8:
        cmp word [si + 0x5e], 0x10
        jz short .11
        test byte [CrowdState], 0x4
        jz short .11
        test byte [gmode], 0x1
        jnz short .11
        mov ax, 0x80
        call 0x0C11:randomd0
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        sub ax, strict word 0x21
        mov [regd0], ax
        cmp ax, 0xc00
        jl short .9
        mov al, [si + 0x55]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add [regd0], ax
        cmp word [regd0], 0x1000
        jng short .9
        mov word [regd0], 0x1000
.9:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [regd0]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .10
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        mov [bx + di + 0x2c], ax
.11:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; avdgoal_box                                                2425:0A20  94 PC
; Returns 1 when the line from the player to his target crosses one goal's box, else 0.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
avdgoal_box:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .1
        jmp near .8
.1:
        cmp word [si + 0x6], 0x0
        jnl short .2
        mov ax, 0x1
        jmp short .3
        db 0x90
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.3:
        mov cl, [si + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .4
        jmp near .8
.4:
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jnl short .8
        cmp bx, 0xdc
        jng short .8
        cmp bx, 0xf2
        jg short .8
        cmp bx, 0xe8
        jg short .6
        mov dl, [si + 0x36]
        inc dl
        and dx, 0x7
        cmp word [si + 0x6], 0x0
        jng short .5
        cmp dx, 0x3
        jnl short .5
        mov word [regd0], 0x4
        pop si
        leave
        retf
        db 0x90, 0x90
.5:
        cmp word [si + 0x6], 0x0
        jnl short .8
        cmp dx, 0x3
        jng short .8
        cmp dx, 0x7
        jnl short .8
        mov word [regd0], 0x0
        pop si
        leave
        retf
        db 0x90
.6:
        mov dl, [si + 0x36]
        and dx, 0x7
        cmp word [si + 0x2], 0x0
        jng short .7
        cmp dx, 0x4
        jng short .7
        mov word [regd0], 0x2
        pop si
        leave
        retf
.7:
        cmp word [si + 0x6], 0x0
        jnl short .8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .8
        cmp dx, 0x4
        jnl short .8
        mov word [regd0], 0x6
.8:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; avdgoal                                                    2425:0AEA  94 PC
; Moves a skating target round the goals so the player does not skate through a net.
;
; Takes 1 word of stack arguments. Calls ImulRegs. Far routine (retf).
;-----------------------------------------------------------------------------
avdgoal:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [gmode], 0x1
        jz short .1
        cmp word [si + 0x5e], 0x10
        jnz short .1
        mov di, 0x1
        jmp short .2
        db 0x90
.1:
        db 0x2B, 0xFF                           ; insn: sub di, di
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x4], ax
        cmp [si + 0x1a], ax
        jnz short .3
        jmp near .21
.3:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .4
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jnl short .4
        mov ax, [si + 0x6]
        xor ax, [regd1]
        jl short .4
        jmp near .21
.4:
        mov bx, [si + 0x60]
        cmp word [bx + 0x24], 0x0
        jnl short .5
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xbe
        jg short .5
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xbe
        jg short .5
        jmp near .21
.5:
        mov ax, [si + 0x2]
        xor ax, [regd0]
        jl short .6
        jmp near .15
.6:
        mov ax, [regd1]
        sub ax, [si + 0x6]
        mov dx, [si + 0x2]
        call 0x03A3:ImulRegs
        mov bx, [si + 0x2]
        sub bx, [regd0]
        call 0x03A3:IdivWords.regs
        add ax, [si + 0x6]
        mov [regd2], ax
        cmp ax, 0x105
        jg short .15
        cmp ax, 0xbf
        jl short .10
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .7
        mov word [regd3], 0xae
        jmp short .14
        db 0x90
.7:
        cmp ax, 0xe2
        jl short .9
        jnz short .8
        cmp word [si + 0x6], 0xe2
        jng short .9
.8:
        mov word [regd3], 0x128
        jmp short .14
.9:
        mov word [regd3], 0x9c
        jmp short .14
.10:
        cmp ax, 0xff41
        jg short .15
        cmp ax, 0xfefb
        jl short .15
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .11
        mov word [regd3], 0xff52
        jmp short .14
.11:
        cmp ax, 0xff1e
        jl short .13
        jnz short .12
        cmp word [si + 0x6], 0xff1e
        jng short .13
.12:
        mov word [regd3], 0xff64
        jmp short .14
.13:
        mov word [regd3], 0xfed8
.14:
        mov ax, [regd3]
        sub ax, [regd2]
        mov [bp - 0x6], ax
.15:
        mov ax, [regd1]
        add ax, [bp - 0x6]
        mov [bp - 0x2], ax
        sub ax, 0xe2
        mov [regd3], ax
        mov ax, [si + 0x6]
        sub ax, 0xe2
        mov [regd2], ax
        mov di, 0x2
.16:
        mov ax, [regd3]
        xor ax, [regd2]
        jnl short .20
        mov ax, [regd0]
        sub ax, [si + 0x2]
        mov dx, [regd2]
        call 0x03A3:ImulRegs
        mov bx, [regd2]
        sub bx, [regd3]
        call 0x03A3:IdivWords.regs
        add ax, [si + 0x2]
        mov [regd4], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x50
        jg short .20
        cmp word [regd4], 0x0
        jl short .18
        jnz short .17
        cmp word [si + 0x2], 0x0
        jl short .18
.17:
        mov word [regd3], 0x50
        jmp short .19
        db 0x90
.18:
        mov word [regd3], 0xffb0
.19:
        mov ax, [regd3]
        sub ax, [regd4]
        mov [bp - 0x4], ax
.20:
        mov ax, [bp - 0x2]
        add ax, 0xe2
        mov [regd3], ax
        mov ax, [si + 0x6]
        add ax, 0xe2
        mov [regd2], ax
        dec di
        jnz short .16
        mov dx, [bp - 0x4]
        mov bx, [bp - 0x6]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x0B, 0xC2                           ; insn: or ax, dx
        jz short .21
        add [regd0], dx
        add [regd1], bx
.21:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; dostop                                                     2425:0C9E  94 PC
; Stops a player: the stop or glide animation when he moves fast, then slows him down.
;
; Takes 1 word of stack arguments. Calls SetSPA, stopna. Far routine (retf).
;-----------------------------------------------------------------------------
dostop:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1000
        jg short .1
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1000
        jng short .10
.1:
        test byte [si + 0x44], 0x10
        jnz short .5
        or byte [si + 0x45], 0x2
        cmp word [si + 0x5e], 0x10
        jnz short .4
        cmp word [refsignal], 0x0
        jnz short .3
        test byte [gmode], 0x1
        jnz short .2
        test byte [gmode2], 0x80
        jnz short .3
        test byte [gmode], 0x8
        jnz short .3
.2:
        mov cx, 0xaeb
        jmp short .9
        db 0x90, 0x90
.3:
        mov cx, 0xbdb
        jmp short .9
        db 0x90
.4:
        mov cx, 0x361
        jmp short .9
        db 0x90
.5:
        cmp word [si + 0x5e], 0x10
        jnz short .8
        cmp word [refsignal], 0x0
        jnz short .7
        test byte [gmode], 0x1
        jnz short .6
        test byte [gmode2], 0x80
        jnz short .7
        test byte [gmode], 0x8
        jnz short .7
.6:
        mov cx, 0xa5b
        jmp short .9
        db 0x90
.7:
        mov cx, 0xb4b
        jmp short .9
        db 0x90
.8:
        mov cx, 0x289
.9:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
.10:
        push si
        push cs
        call stopna
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; stopna                                                     2425:0D44  94 PC
; Slows a player by one step on each axis without changing his animation.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
stopna:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        cmp word [bx + 0xc], 0x0
        jnl short .1
        add word [bx + 0xc], 0x96
        cmp word [bx + 0xc], 0x0
        jng short .3
        jmp short .2
        db 0x90
.1:
        sub word [bx + 0xc], 0x96
        jns short .3
.2:
        mov word [bx + 0xc], 0x0
.3:
        cmp word [bx + 0xe], 0x0
        jnl short .4
        add word [bx + 0xe], 0x96
        cmp word [bx + 0xe], 0x0
        jng short .6
        jmp short .5
        db 0x90
.4:
        sub word [bx + 0xe], 0x96
        jns short .6
.5:
        mov word [bx + 0xe], 0x0
.6:
        leave
        retf

;-----------------------------------------------------------------------------
; goalieacc                                                  2425:0D8C  94 PC
; Turns the goalie one step toward a direction and accelerates him with the goalie skate animation.
;
; Takes 2 words of stack arguments. Calls stopna, SetSPA, playeracc. Far routine (retf).
;-----------------------------------------------------------------------------
goalieacc:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov dx, [bp + 0x8]
        and dx, 0xf
        cmp dx, 0x7
        jng short .2
        mov si, [bp + 0x6]
        cmp dx, 0x9
        jnz short .1
        mov ax, [si + 0xc]
        or ax, [si + 0xe]
        jz short .1
        push si
        push cs
        call stopna
        add sp, 0x2
        pop si
        leave
        retf
.1:
        test byte [si + 0x45], 0x2
        jnz short .4
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x1
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90
.2:
        mov si, [bp + 0x6]
        sub dx, [si + 0x36]
        jz short .3
        neg dx
        and dx, 0x4
        sar dx, 1
        add dl, [si + 0x36]
        dec dl
        and dx, 0x7
        mov [si + 0x36], dx
.3:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x1f1
        call 0x2E42:SetSPA
        push word [si + 0x36]
        push si
        push cs
        call playeracc
        add sp, 0x4
.4:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; noturn0                                                    2425:0DFC  94 PC
; Accelerates a player who needs no turn: stops when skating against his motion, else picks the skate
; animation.
;
; Takes 3 words of stack arguments. Calls VectorToDir8, dostop, SetSPA, playeracc. Far routine (retf).
;-----------------------------------------------------------------------------
noturn0:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        mov word [regd4], 0x2
        test byte [si + 0x44], 0x10
        jz short .1
        mov word [regd4], 0x6
        xor word [bp + 0x8], 0x4
.1:
        cmp word [bp + 0x8], 0x0
        jnz short .2
        jmp near .11
.2:
        mov ax, [si + 0xc]
        mov dx, [si + 0xe]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        test byte [regd0], 0x8
        jnz short .3
        mov al, [regd4]
        sub al, [si + 0x36]
        add al, [regd0]
        and ax, strict word 0x7
        mov [regd0], ax
        cmp ax, strict word 0x4
        jnl short .3
        push si
        push cs
        call dostop
        add sp, 0x2
        pop si
        leave
        retf
.3:
        test byte [si + 0x49], 0x8
        jz short .4
        dec word [si + 0x36]
        jmp short .5
        db 0x90
.4:
        inc word [si + 0x36]
.5:
        and word [si + 0x36], 0x7
        test byte [si + 0x44], 0x10
        jz short .6
        mov cx, 0x529
        jmp short .10
.6:
        cmp word [si + 0x5e], 0x10
        jnz short .9
        cmp word [refsignal], 0x0
        jnz short .8
        test byte [gmode], 0x1
        jnz short .7
        test byte [gmode2], 0x80
        jnz short .8
        test byte [gmode], 0x8
        jnz short .8
.7:
        mov cx, 0xa5b
        jmp short .10
        db 0x90
.8:
        mov cx, 0xb4b
        jmp short .10
        db 0x90
.9:
        mov cx, 0x289
.10:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90
.11:
        test byte [si + 0x44], 0x10
        jnz short .16
        cmp word [si + 0x5e], 0x10
        jnz short .14
        cmp word [refsignal], 0x0
        jnz short .13
        test byte [gmode], 0x1
        jnz short .12
        test byte [gmode2], 0x80
        jnz short .13
        test byte [gmode], 0x8
        jnz short .13
.12:
        mov cx, 0xa73
        jmp short .17
        db 0x90
.13:
        mov cx, 0xb63
        jmp short .17
        db 0x90
.14:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .15
        mov cx, 0x2a1
        jmp short .17
        db 0x90
.15:
        mov al, [si + 0x45]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0xfa16
        add cx, 0x8d3
        jmp short .17
        db 0x90
.16:
        mov cx, 0x541
.17:
        test byte [si + 0x45], 0x2
        jnz short .18
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
.18:
        test byte [si + 0x44], 0x10
        jz short .19
        mov ax, [bp + 0xa]
        xor al, 0x4
        jmp short .20
        db 0x90
.19:
        mov ax, [bp + 0xa]
.20:
        mov [bp - 0x2], ax
        push ax
        push si
        push cs
        call playeracc
        add sp, 0x4
        pop si
        leave
        retf
