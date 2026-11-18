; Player assignments, line changes, offside and the referee (AI.OVL)

;-----------------------------------------------------------------------------
; assdefo                                                    2519:0000  94 PC
; Assignment: a defenceman while his team attacks.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, skateto. Far routine
; (retf).
;-----------------------------------------------------------------------------
assdefo:
        enter 0x6, 0x0
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .19
.1:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .19
.2:
        test byte [gmode], 0x1
        jz short .3
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90
.3:
        test byte [si + 0x44], 0x8
        jz short .4
        jmp near .19
.4:
        test byte [si + 0x44], 0x2
        jz short .5
        and byte [si + 0x44], 0xfd
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
.5:
        dec byte [si + 0x27]
        jns short .13
        mov al, [si + 0x4e]
        mov [si + 0x27], al
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jz short .7
.6:
        push 0x2
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.7:
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd1], ax
        test byte [si + 0x44], 0x80
        jnz short .8
        neg word [regd1]
.8:
        cmp word [regd1], 0x53
        jl short .6
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .13
        cmp al, 0x6
        jnl short .9
        mov ax, 0x1
        jmp short .10
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        mov [bp - 0x4], ax
        cmp word [si + 0x5e], 0x6
        jnl short .11
        mov ax, 0x1
        jmp short .12
.11:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.12:
        xor ax, [bp - 0x4]
        jnz short .6
.13:
        cmp word [si + 0x1a], 0x2
        jnz short .14
        mov ax, 0x64
        jmp short .15
.14:
        mov ax, 0xff9c
.15:
        mov [regd0], ax
        mov word [regd1], 0x58
        test byte [si + 0x44], 0x80
        jnz short .16
        neg word [regd0]
        mov word [regd1], 0xffa8
.16:
        mov bx, [puckx]
        mov ax, [bx]
        mov [bp - 0x6], ax
        xor ax, [regd0]
        jl short .17
        mov ax, [bp - 0x6]
        mov [regd0], ax
        jmp short .18
        db 0x90
.17:
        mov ax, [bp - 0x6]
        sar ax, 1
        add [regd0], ax
.18:
        push word 0x1b35
        push strict word EvadePCThunk
        push si
        call 0x2425:skateto
        add sp, 0x6
.19:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assdefd                                                    2519:0114  94 PC
; Assignment: a defenceman while his team defends.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, skateto, check4check. Far
; routine (retf).
;-----------------------------------------------------------------------------
assdefd:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        test byte [di + 0x44], 0x20
        jz short .1
        jmp near .33
.1:
        push di
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .33
.2:
        test byte [gmode], 0x1
        jz short .3
        push di
        push cs
        call donothing
        jmp near .32
        db 0x90
.3:
        test byte [di + 0x44], 0x8
        jz short .4
        jmp near .33
.4:
        test byte [di + 0x44], 0x2
        jz short .5
        and byte [di + 0x44], 0xfd
        mov [di + 0x26], ax
        mov word [di + 0x28], 0x8
.5:
        dec byte [di + 0x27]
        js short .6
        jmp near .31
.6:
        mov al, [di + 0x4e]
        mov [di + 0x27], al
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd1], ax
        mov bx, [puckvy]
        mov ax, [bx]
        sar ax, byte 0x6
        mov [regd3], ax
        test byte [di + 0x44], 0x80
        jnz short .7
        neg word [regd1]
        neg word [regd3]
.7:
        cmp word [regd3], 0x0
        jnl short .8
        mov word [regd3], 0x0
.8:
        mov ax, [regd1]
        add [regd3], ax
        cmp word [regd3], 0x4e
        jl short .14
        mov bx, [di + 0x60]
        test byte [bx + 0x2a], 0x10
        jnz short .14
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .14
        test byte [gmode2], 0x20
        jz short .9
        mov al, [di + 0x44]
        xor al, [gmode2]
        test al, 0x40
        jnz short .14
.9:
        cmp byte [bp - 0x2], 0x0
        jl short .14
        cmp byte [bp - 0x2], 0x6
        jnl short .10
        mov ax, 0x1
        jmp short .11
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.11:
        mov [bp - 0x4], ax
        cmp word [di + 0x5e], 0x6
        jnl short .12
        mov ax, 0x1
        jmp short .13
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.13:
        cmp ax, [bp - 0x4]
        jnz short .14
        push 0x1
        push di
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.14:
        cmp word [di + 0x1a], 0x2
        jnz short .15
        mov ax, 0x50
        jmp short .16
        db 0x90
.15:
        mov ax, 0xffb0
.16:
        mov [di + 0x2a], ax
        cmp word [di + 0x5e], 0x6
        jl short .17
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .18
.17:
        mov si, 0x6
.18:
        shl si, byte 0x7
        add si, SortCords
        mov word [regd2], 0x6
        test byte [di + 0x44], 0x80
        jz short .23
        mov word [regd0], 0x3e8
.19:
        test byte [si + 0x45], 0x4
        jnz short .21
        cmp word [si + 0x1a], 0x0
        jl short .21
        mov ax, [si + 0xe]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .20
        mov word [regd1], 0x0
.20:
        mov ax, [regd1]
        sar ax, byte 0x4
        add ax, [si + 0x6]
        mov [regd1], ax
        mov ax, [regd0]
        cmp [regd1], ax
        jg short .21
        mov ax, [regd1]
        mov [regd0], ax
.21:
        add si, 0x80
        dec word [regd2]
        jnz short .19
        sub word [regd0], 0x32
        cmp word [regd0], 0xff56
        jg short .22
        mov word [regd0], 0xff3d
.22:
        mov ax, [regd0]
        mov [di + 0x2c], ax
        jmp short .28
.23:
        mov word [regd0], 0xfc18
.24:
        test byte [si + 0x45], 0x4
        jnz short .26
        cmp word [si + 0x1a], 0x0
        jl short .26
        mov ax, [si + 0xe]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .25
        mov word [regd1], 0x0
.25:
        mov ax, [regd1]
        sar ax, byte 0x4
        add ax, [si + 0x6]
        mov [regd1], ax
        mov ax, [regd0]
        cmp [regd1], ax
        jl short .26
        mov ax, [regd1]
        mov [regd0], ax
.26:
        add si, 0x80
        dec word [regd2]
        jnz short .24
        add word [regd0], 0x32
        cmp word [regd0], 0xaa
        jl short .27
        mov word [regd0], 0xc3
.27:
        mov ax, [regd0]
        mov [di + 0x2c], ax
        neg word [di + 0x2a]
.28:
        mov ax, [di + 0x2a]
        mov bx, [puckx]
        xor ax, [bx]
        jnl short .31
        mov word [di + 0x2a], 0x0
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xc3
        jnz short .31
        cmp word [regd0], 0x0
        jl short .29
        mov ax, 0xb6
        jmp short .30
.29:
        mov ax, 0xff4a
.30:
        mov [di + 0x2c], ax
.31:
        mov ax, [di + 0x2a]
        mov [regd0], ax
        mov ax, [di + 0x2c]
        mov [regd1], ax
        push word 0x1b35
        push strict word EvadePCThunk
        push di
        call 0x2425:skateto
        add sp, 0x6
        push di
        call 0x28BB:check4check
.32:
        add sp, 0x2
.33:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; asswingd                                                   2519:035A  94 PC
; Assignment: a winger while his team defends.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, skateto. Far routine
; (retf).
;-----------------------------------------------------------------------------
asswingd:
        enter 0x6, 0x0
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .21
.1:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .21
.2:
        test byte [gmode], 0x1
        jz short .3
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90
.3:
        test byte [si + 0x44], 0x8
        jz short .4
        jmp near .21
.4:
        test byte [si + 0x44], 0x2
        jz short .5
        and byte [si + 0x44], 0xfd
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
.5:
        dec byte [si + 0x27]
        jns short .10
        mov al, [si + 0x4d]
        mov [si + 0x27], al
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .10
        cmp al, 0x6
        jnl short .6
        mov ax, 0x1
        jmp short .7
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.7:
        mov [bp - 0x4], ax
        cmp word [si + 0x5e], 0x6
        jnl short .8
        mov ax, 0x1
        jmp short .9
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        cmp ax, [bp - 0x4]
        jnz short .10
        push 0x4
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.10:
        cmp word [si + 0x1a], 0x5
        jnz short .11
        mov ax, 0xff88
        jmp short .12
        db 0x90
.11:
        mov ax, 0x78
.12:
        cwd
        mov [regd0], ax
        mov [regd0_w2], dx
        mov word [regd1], 0x8e
        mov word [regd2], 0x44
        test byte [si + 0x44], 0x80
        jz short .17
        neg word [regd0]
        mov word [regd1], 0xff72
        mov word [regd2], 0xffbc
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jz short .14
        mov ax, [regd2]
.13:
        mov [regd1], ax
        jmp short .19
.14:
        mov ax, [regd2]
        mov bx, [pucky]
        cmp [bx], ax
        jl short .16
.15:
        mov ax, [bx]
        jmp short .13
        db 0x90
.16:
        mov word [regd2], 0xff18
        cmp word [bx], 0xff18
        jg short .19
        mov word [regd1], 0xff18
        jmp short .19
.17:
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jz short .18
        mov word [regd1], 0x44
        jmp short .19
        db 0x90
.18:
        mov bx, [pucky]
        cmp word [bx], 0x44
        jng short .15
        mov word [regd2], 0xe8
        cmp word [bx], 0xe8
        jl short .19
        mov word [regd1], 0xe8
.19:
        mov bx, [puckx]
        mov ax, [bx]
        mov [bp - 0x6], ax
        xor ax, [regd0]
        jl short .20
        mov ax, [bp - 0x6]
        mov [regd0], ax
.20:
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
.21:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; asswingo                                                   2519:04B0  94 PC
; Assignment: a winger while his team attacks.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, randomd0, skateto. Far
; routine (retf).
;-----------------------------------------------------------------------------
asswingo:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .18
.1:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .18
.2:
        test byte [gmode], 0x1
        jz short .3
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.3:
        test byte [si + 0x44], 0x8
        jz short .4
        jmp near .18
.4:
        test byte [si + 0x44], 0x2
        jz short .5
        and byte [si + 0x44], 0xfd
        mov byte [si + 0x2f], 0xff
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
.5:
        dec byte [si + 0x27]
        js short .6
        jmp near .15
.6:
        mov al, [si + 0x4d]
        mov [si + 0x27], al
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .11
        cmp al, 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
        db 0x90
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        mov [bp - 0x4], ax
        cmp word [si + 0x5e], 0x6
        jnl short .9
        mov ax, 0x1
        jmp short .10
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        xor ax, [bp - 0x4]
        jz short .11
        push 0x3
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.11:
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        mov bx, [puckvy]
        mov ax, [bx]
        sar ax, byte 0x6
        add ax, [regd0]
        mov [regd3], ax
        test byte [si + 0x44], 0x80
        jnz short .12
        neg word [regd0]
        neg word [regd3]
.12:
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp word [regd3], -0x4e
        jl short .13
        mov di, 0x4
        cmp word [regd0], 0x4e
        jl short .13
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jnz short .13
        db 0x03, 0xFF                           ; insn: add di, di
        cmp word [regd3], 0xe8
        jl short .13
        add di, 0x4
.13:
        cmp [si + 0x2e], di
        jnz short .14
        mov ax, 0x80
        call 0x0C11:randomd0
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
.14:
        mov [si + 0x2e], di
        shl di, 1
        mov ax, [di + asswingo_dedata_xrand]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        mov [bp - 0x6], cx
        call 0x0C11:randomd0
        mov cx, [di + asswingo_dedata]
        sub cx, [bp - 0x6]
        mov dl, [si + 0x4d]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x03, 0xCA                           ; insn: add cx, dx
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x2a], ax
        mov ax, [di + asswingo_dedata_yrand]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        mov [bp - 0x8], cx
        call 0x0C11:randomd0
        mov cx, [di + asswingo_dedata_y]
        sub cx, [bp - 0x8]
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x2c], ax
.15:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        cmp word [si + 0x1a], 0x5
        jz short .16
        neg word [regd0]
.16:
        mov ax, [si + 0x2c]
        mov [regd1], ax
        test byte [si + 0x44], 0x80
        jnz short .17
        neg word [regd0]
        neg word [regd1]
.17:
        push word 0x1b35
        push strict word EvadePCThunk
        push si
        call 0x2425:skateto
        add sp, 0x6
.18:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; asscenterd                                                 2519:0630  94 PC
; Assignment: the centre while his team defends.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, skateto. Far routine
; (retf).
;-----------------------------------------------------------------------------
asscenterd:
        enter 0x4, 0x0
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .14
.1:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .14
.2:
        test byte [gmode], 0x1
        jz short .3
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90
.3:
        test byte [si + 0x44], 0x8
        jz short .4
        jmp near .14
.4:
        test byte [si + 0x44], 0x2
        jz short .5
        and byte [si + 0x44], 0xfd
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
.5:
        dec byte [si + 0x27]
        jns short .10
        mov al, [si + 0x4d]
        mov [si + 0x27], al
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .10
        cmp al, 0x6
        jnl short .6
        mov ax, 0x1
        jmp short .7
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.7:
        mov [bp - 0x4], ax
        cmp word [si + 0x5e], 0x6
        jnl short .8
        mov ax, 0x1
        jmp short .9
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        cmp ax, [bp - 0x4]
        jnz short .10
        push 0x6
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.10:
        mov bx, [puckx]
        mov ax, [bx]
        sar ax, 1
        mov [regd0], ax
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd2], ax
        test byte [si + 0x44], 0x80
        jnz short .11
        neg word [regd2]
.11:
        mov word [regd1], 0xff8f
        cmp word [regd2], -0x4e
        jl short .12
        mov ax, [bx]
        sub ax, strict word 0x71
        sar ax, 1
        mov [regd1], ax
.12:
        test byte [si + 0x44], 0x80
        jnz short .13
        neg word [regd1]
.13:
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
.14:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; asscentero                                                 2519:0716  94 PC
; Assignment: the centre while his team attacks.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, assreplace, randomd0, skateto. Far
; routine (retf).
;-----------------------------------------------------------------------------
asscentero:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .17
.1:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .17
.2:
        test byte [gmode], 0x1
        jz short .3
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.3:
        test byte [si + 0x44], 0x8
        jz short .4
        jmp near .17
.4:
        test byte [si + 0x44], 0x2
        jz short .5
        and byte [si + 0x44], 0xfd
        mov byte [si + 0x2f], 0xff
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
.5:
        dec byte [si + 0x27]
        js short .6
        jmp near .15
.6:
        mov al, [si + 0x4d]
        mov [si + 0x27], al
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .11
        cmp al, 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
        db 0x90
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        mov [bp - 0x4], ax
        cmp word [si + 0x5e], 0x6
        jnl short .9
        mov ax, 0x1
        jmp short .10
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        xor ax, [bp - 0x4]
        jz short .11
        push 0x5
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.11:
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        test byte [si + 0x44], 0x80
        jnz short .12
        neg word [regd0]
.12:
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp word [regd0], -0x4e
        jl short .13
        mov di, 0x4
        cmp word [regd0], 0x4e
        jl short .13
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jnz short .13
        db 0x03, 0xFF                           ; insn: add di, di
        cmp word [regd0], 0xe8
        jl short .13
        add di, 0x4
.13:
        cmp [si + 0x2e], di
        jnz short .14
        mov ax, 0x80
        call 0x0C11:randomd0
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
.14:
        mov [si + 0x2e], di
        shl di, 1
        mov ax, [di + asscentero_dedata_xrand]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        mov [bp - 0x6], cx
        call 0x0C11:randomd0
        mov cx, [di + asscentero_dedata]
        sub cx, [bp - 0x6]
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x2a], ax
        mov ax, [di + asscentero_dedata_yrand]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        mov [bp - 0x8], cx
        call 0x0C11:randomd0
        mov cx, [di + asscentero_dedata_y]
        sub cx, [bp - 0x8]
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x2c], ax
.15:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        test byte [si + 0x44], 0x80
        jnz short .16
        neg word [regd1]
.16:
        push word 0x1b35
        push strict word EvadePCThunk
        push si
        call 0x2425:skateto
        add sp, 0x6
.17:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; donothing                                                  2519:086C  94 PC
; Assignment: stands still unless the animation is locked or a controller drives the player.
;
; Takes 1 word of stack arguments. Calls doplayeracc. Far routine (retf).
;-----------------------------------------------------------------------------
donothing:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x28
        jnz short .1
        push 0x8
        push si
        call 0x2425:doplayeracc
        add sp, 0x4
.1:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assstanley                                                 2519:0888  94 PC
; Assignment: the Stanley Cup skate after the final.
;
; Takes 1 word of stack arguments. Calls SetSPA, VectorToDir8, playeracc. Far routine (retf).
;-----------------------------------------------------------------------------
assstanley:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .5
.1:
        test byte [si + 0x44], 0x2
        jz short .2
        and byte [si + 0x44], 0xfd
        mov word [si + 0x2a], 0xffb0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x2c], ax
        mov [si + 0x26], ax
        mov byte [si + 0x46], 0x0
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAstansk)
        call 0x2E42:SetSPA
        mov word [PenCntDwn], 0x100
.2:
        cmp word [si + 0x38], 0x0
        jnz short .3
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov word [bx + di + 0x2c], 0x300
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAstanley)
        call 0x2E42:SetSPA
.3:
        mov ax, [si + 0x2a]
        sub ax, [si + 0x2]
        mov dx, [si + 0x2c]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        cmp ax, strict word 0x7
        jg short .5
        dec word [si + 0x26]
        jns short .4
        add word [si + 0x26], 0xc
        mov ax, [regd0]
        cmp [si + 0x36], ax
        jz short .4
        mov al, [si + 0x36]
        inc al
        and ax, strict word 0x7
        mov [si + 0x36], ax
.4:
        push word [regd0]
        push si
        call 0x2425:playeracc
        add sp, 0x4
.5:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; assscore                                                   2519:092A  94 PC
; Assignment: the goal celebration skate.
;
; Takes 1 word of stack arguments. Calls assreplace, check4bench, randomd0, SetSPA, skateto. Far
; routine (retf).
;-----------------------------------------------------------------------------
assscore:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .1
        mov byte [bx], 0xff
        mov bx, [puck_1C]
        cmp byte [bx + puckasslist], 0x18
        jnz short .1
        push 0x1a
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
.1:
        test byte [si + 0x44], 0x20
        jz short .2
        jmp near .14
.2:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        jmp near .14
.3:
        test byte [si + 0x44], 0x2
        jz short .8
        and byte [si + 0x44], 0xfd
        mov ax, 0x78
        call 0x0C11:randomd0
        mov [si + 0x26], ax
        mov word [si + 0x28], 0x8
        test byte [gmode], 0x80
        jz short .4
        mov word [si + 0x2a], 0xffb0
        mov word [si + 0x2c], 0x0
        jmp short .7
        db 0x90
.4:
        cmp word [camx], 0x0
        jl short .5
        mov ax, 0x64
        jmp short .6
.5:
        mov ax, 0xff9c
.6:
        mov [si + 0x2a], ax
        mov ax, [camy]
        mov [si + 0x2c], ax
        cmp word [camx], 0x0
        jnl short .7
        sub word [si + 0x2c], 0x37
.7:
        mov ax, [shotplayer]
        cmp [si + 0x5e], ax
        jnz short .8
        mov word [assscore_dancecnt], 0x0
.8:
        dec word [si + 0x26]
        jns short .13
        or byte [si + 0x44], 0x20
        mov word [regd1], SPAno(SPAcelebrate)
        mov ax, 0x78
        call 0x0C11:randomd0
        mov [si + 0x26], ax
        mov ax, [shotplayer]
        cmp [si + 0x5e], ax
        jnz short .12
        mov word [regd1], SPAno(SPApump)
        cmp word [assscore_dancecnt], 0x0
        jz short .11
        cmp word [assscore_dancecnt], 0x3
        jnl short .9
        mov ax, 0x2
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
.9:
        mov word [assscore_dancecnt], 0x0
        mov ax, [si + 0x26]
        cmp ax, strict word 0x1e
        jnl short .10
        mov ax, 0x1e
.10:
        mov [si + 0x26], ax
        jmp short .12
        db 0x90
.11:
        mov word [si + 0x26], 0x0
        inc word [assscore_dancecnt]
.12:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [regd1]
        call 0x2E42:SetSPA
        pop si
        leave
        retf
.13:
        test byte [si + 0x44], 0x8
        jnz short .14
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
.14:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; asseben                                                    2519:0A62  94 PC
; Assignment: skates to the bench at the end of a period.
;
; Takes 1 word of stack arguments. Calls SetSPA, assexit. Far routine (retf).
;-----------------------------------------------------------------------------
asseben:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .3
        test byte [si + 0x44], 0x2
        jz short .2
        and byte [si + 0x44], 0xfd
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xc], ax
        mov [si + 0xe], ax
        mov ax, [si + 0x5e]
        sub ax, strict word 0x6
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .1
        add word [regd0], 0x2
.1:
        mov ax, [regd0]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        mov [si + 0x6], ax
        mov word [si + 0x2], 0xff60
        mov word [si + 0x36], 0x2
        and byte [si + 0x44], 0xef
        or byte [si + 0x44], 0x20
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x574
        add ax, SPAno(SPAwallright)
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90
.2:
        mov word [si + 0x36], 0x4
        and byte [si + 0x44], 0xfb
        and byte [si + 0x45], 0xdb
        mov word [si + 0x38], 0x0
        mov word [si + 0xc], 0x1000
        push si
        push cs
        call assexit
        add sp, 0x2
.3:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assleaveice                                                2519:0AF0  94 PC
; Assignment: skates to the bench gate, turns and plays the exit animation.
;
; Takes 1 word of stack arguments. Calls changeplayer, SetSPA, RemoveFromLines, skateto, assreplace.
; Far routine (retf).
;-----------------------------------------------------------------------------
assleaveice:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .18
.1:
        cmp word [si + 0x26], 0x64
        jnz short .2
        jmp near .16
.2:
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        or byte [si + 0x45], 0x4
        test byte [si + 0x44], 0x8
        jz short .5
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jnz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        jmp short .4
        db 0x90
.3:
        mov ax, 0x2
.4:
        mov [regd4], ax
        push ax
        push si
        call 0x2E42:changeplayer
        add sp, 0x4
.5:
        mov word [si + 0x28], 0x8
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xc0
        add ax, strict word 0x24
        mov [si + 0x2c], ax
        mov word [si + 0x2a], 0xff58
        mov word [si + 0x26], 0x0
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
.6:
        dec word [si + 0x26]
        js short .7
        jmp near .15
.7:
        add word [si + 0x26], 0x8
        mov bx, [si + 0x6]
        sub bx, [si + 0x2c]
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jng short .8
        jmp near .15
.8:
        cmp word [regd0], 0x20
        jng short .9
        jmp near .15
.9:
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfd78
        add ax, SPAno(SPAglide)
        mov [regd1], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x4
        cmp word [si + 0x36], 0x4
        jz short .12
        jl short .10
        mov ax, 0xffff
        jmp short .11
        db 0x90
.10:
        mov ax, 0x1
.11:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.12:
        mov word [si + 0xe], 0x0
        mov word [si + 0xc], 0xf800
        cmp word [regd0], 0x10
        jng short .13
        jmp near .18
.13:
        mov word [si + 0xc], 0x0
        cmp word [si + 0x36], 0x4
        jz short .14
        jmp near .18
.14:
        mov word [si + 0xc], 0xf800
        mov word [si + 0x36], 0x2
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x56e
        add ax, SPAno(SPAwallleft)
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x20
        mov word [si + 0x26], 0x64
        cmp word [gsp], 0x4
        jnl short .18
        test byte [gmode], 0x40
        jnz short .18
        mov al, [si + 0x47]
        cbw
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x317A:RemoveFromLines
        jmp short .17
        db 0x90
.15:
        test byte [si + 0x44], 0x4
        jnz short .18
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
        pop si
        leave
        retf
.16:
        and byte [si + 0x45], 0xef
        mov word [si + 0x12], 0xffff
        push 0x29
        push si
        call 0x1E7E:assreplace
.17:
        add sp, 0x4
.18:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; asspenalty                                                 2519:0C76  94 PC
; Assignment: the penalised player skates to the penalty box.
;
; Takes 1 word of stack arguments. Calls changeplayer, SetSPA, assreplace, skateto. Far routine
; (retf).
;-----------------------------------------------------------------------------
asspenalty:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .18
.1:
        test byte [si + 0x44], 0x2
        jnz short .2
        jmp near .9
.2:
        and byte [si + 0x44], 0xfd
        or byte [si + 0x45], 0x4
        test byte [si + 0x44], 0x8
        jz short .5
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jnz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        jmp short .4
        db 0x90
.3:
        mov ax, 0x2
.4:
        mov [regd4], ax
        push ax
        push si
        call 0x2E42:changeplayer
        add sp, 0x4
.5:
        mov word [si + 0x28], 0x8
        test byte [si + 0x44], 0x40
        jnz short .6
        mov al, [PBnum]
        cbw
        mov [regd1], ax
        mov word [regd0], 0xfff5
        mov word [regd0_w2], 0xffff
        jmp short .7
.6:
        mov al, [PBnum_b1]
        cbw
        mov [regd1], ax
        mov word [regd0], 0xb
        mov word [regd0_w2], 0x0
.7:
        and word [regd1], 0xf
        cmp word [regd1], 0x2
        jng short .8
        mov word [regd1], 0x2
        mov word [regd1_w2], 0x0
.8:
        add word [regd1], 0x3
        mov ax, [regd1]
        imul word [regd0]
        mov [si + 0x2c], ax
        mov word [si + 0x2a], 0xa0
        mov word [si + 0x26], 0x0
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
.9:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .10
        jmp near .17
.10:
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        cmp ax, strict word 0xffe8
        jnl short .11
        jmp near .17
.11:
        dec word [si + 0x26]
        js short .12
        jmp near .18
.12:
        add word [si + 0x26], 0x8
        or byte [si + 0x44], 0x4
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAglide)
        call 0x2E42:SetSPA
        mov word [regd2], 0x4
        cmp word [si + 0x36], 0x4
        jz short .15
        mov al, 0xfc
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .13
        mov ax, 0xffff
        jmp short .14
.13:
        mov ax, 0x1
.14:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.15:
        mov word [si + 0xe], 0x0
        mov word [si + 0xc], 0x1000
        cmp word [regd0], -0x8
        jl short .18
        mov word [si + 0xc], 0x0
        mov ax, [regd2]
        cmp [si + 0x36], ax
        jnz short .18
        or byte [si + 0x44], 0x20
        mov word [si + 0x36], 0x2
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAwallright)
        call 0x2E42:SetSPA
        and byte [si + 0x45], 0xef
        mov bx, [si + 0x60]
        cmp word [bx + 0x22], 0x4
        jng short .16
        dec word [bx + 0x22]
.16:
        push 0xd
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.17:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
.18:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assdopen                                                   2519:0E04  94 PC
; Assignment: the player goes into the penalty box and the team's box count goes up.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
assdopen:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x20
        jnz short .3
        test byte [bx + 0x44], 0x40
        jnz short .1
        inc byte [PBnum]
        jmp short .2
.1:
        inc byte [PBnum_b1]
.2:
        mov byte [bx + 0x1b], 0xff
        mov word [bx + 0x12], 0xffff
.3:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assepen                                                    2519:0E2C  94 PC
; Assignment: a player leaving the penalty box.
;
; Takes 1 word of stack arguments. Calls SetSPA, SprSort, assexit. Far routine (retf).
;-----------------------------------------------------------------------------
assepen:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .7
.1:
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        or byte [si + 0x44], 0x4
        or byte [si + 0x45], 0x4
        and byte [si + 0x44], 0xef
        test byte [si + 0x44], 0x40
        jnz short .3
        dec byte [PBnum]
        mov al, [PBnum]
        cmp al, 0x2
        jng short .2
        mov al, 0x2
.2:
        cbw
        sub ax, strict word 0xfffd
        neg ax
        jmp short .5
        db 0x90
.3:
        dec byte [PBnum_b1]
        mov al, [PBnum_b1]
        cmp al, 0x2
        jng short .4
        mov al, 0x2
.4:
        cbw
        add ax, strict word 0x3
.5:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x6], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xc], ax
        mov [si + 0xe], ax
        mov word [si + 0x2], 0x9e
        mov word [si + 0x36], 0x2
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAwallleft)
        call 0x2E42:SetSPA
        call 0x2E42:SprSort
        pop si
        leave
        retf
        db 0x90
.6:
        mov word [si + 0x36], 0x4
        mov al, 0xff
        mov [si + 0x43], al
        mov [si + 0x42], al
        and byte [si + 0x44], 0xf3
        and byte [si + 0x45], 0xdb
        mov word [si + 0xc], 0xf000
        push si
        push cs
        call assexit
        add sp, 0x2
.7:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assbench                                                   2519:0EDC  94 PC
; Assignment: a player going to the bench on a line change.
;
; Takes 1 word of stack arguments. Calls check4bench, donothing, Setplass, SetSPA, skateto, assinsert,
; setplayer. Far routine (retf).
;-----------------------------------------------------------------------------
assbench:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .29
.1:
        cmp word [si + 0x26], 0x64
        jnz short .2
        jmp near .23
.2:
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        jmp near .29
.3:
        test byte [si + 0x45], 0x10
        jz short .5
.4:
        push si
        push cs
        call donothing
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.5:
        test byte [gmode2], 0x1
        jnz short .4
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        mov word [si + 0x28], 0x8
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x8d
        add ax, strict word 0x41
        mov [si + 0x2c], ax
        mov word [si + 0x2a], 0xff58
        mov word [si + 0x26], 0x0
.6:
        mov al, [si + 0x43]
        cmp [si + 0x47], al
        jnz short .10
        and byte [si + 0x45], 0xfb
        cmp byte [si + 0x43], 0x19
        jnl short .7
        mov ax, 0x1
        jmp short .8
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        cmp byte [si + 0x42], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .9
        mov al, [si + 0x42]
        cbw
        mov [si + 0x1a], ax
.9:
        push si
        call 0x2E42:Setplass
        add sp, 0x2
        mov al, 0xff
        mov [si + 0x43], al
        mov [si + 0x42], al
        pop si
        pop di
        leave
        retf
.10:
        dec word [si + 0x26]
        js short .11
        jmp near .19
.11:
        add word [si + 0x26], 0x8
        mov bx, [si + 0x6]
        sub bx, [si + 0x2c]
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jng short .12
        jmp near .19
.12:
        cmp word [regd0], 0x20
        jng short .13
        jmp near .19
.13:
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfd78
        add ax, SPAno(SPAglide)
        mov [regd1], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x4
        cmp word [si + 0x36], 0x4
        jz short .16
        jl short .14
        mov ax, 0xffff
        jmp short .15
        db 0x90
.14:
        mov ax, 0x1
.15:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.16:
        mov word [si + 0xe], 0x0
        mov word [si + 0xc], 0xf800
        cmp word [regd0], 0x10
        jng short .17
        jmp near .29
.17:
        mov word [si + 0xc], 0x0
        cmp word [si + 0x36], 0x4
        jz short .18
        jmp near .29
.18:
        mov word [si + 0xc], 0xf800
        mov word [si + 0x36], 0x2
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x56e
        add ax, SPAno(SPAwallleft)
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x20
        mov word [si + 0x26], 0x64
        pop si
        pop di
        leave
        retf
.19:
        test byte [si + 0x44], 0x4
        jz short .20
        jmp near .29
.20:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        test byte [gmode], 0x1
        jnz short .21
        cmp word [si + 0x1a], 0x0
        jz short .21
        mov ax, strict word EvadePCThunk
        mov dx, 0x1b35
        jmp short .22
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
.22:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x2], dx
        push dx
        push cx
        push si
        call 0x2425:skateto
        add sp, 0x6
        pop si
        pop di
        leave
        retf
        db 0x90
.23:
        mov word [si + 0x12], 0xffff
        mov di, [si + 0x60]
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov [bp - 0x6], bx
        add bx, [si + 0x60]
        cmp word [bx + 0x64], 0x0
        jg short .24
        mov bx, [bp - 0x6]
        cmp word [bx + di + 0x64], -0x2
        jl short .24
        mov word [bx + di + 0x64], 0xfffe
        mov al, [si + 0x47]
        cbw
        imul bx, ax, 0x28
        mov di, [di + 0xd0]
        mov byte [bx + di], 0x3
.24:
        cmp byte [si + 0x43], 0x19
        jnl short .25
        mov ax, 0x1
        jmp short .26
        db 0x90
.25:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.26:
        cmp byte [si + 0x42], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .27
        mov al, [si + 0x42]
        cbw
        mov [si + 0x1a], ax
.27:
        push si
        call 0x2E42:Setplass
        add sp, 0x2
        test byte [gmode], 0x1
        jz short .28
        mov word [si + 0x2e], 0x0
        push 0x27
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.28:
        mov al, [si + 0x43]
        cbw
        mov [regd3], ax
        mov al, 0xff
        mov [si + 0x43], al
        mov [si + 0x42], al
        push word [regd3]
        push si
        call 0x2E42:setplayer
        add sp, 0x4
.29:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assgoalietopuck                                            2519:111C  94 PC
; Assignment: the goalie skates out to a loose puck.
;
; Takes 1 word of stack arguments. Calls check4bench, skatetopuck, assexit. Far routine (retf).
;-----------------------------------------------------------------------------
assgoalietopuck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x8
        jz short .1
        jmp near .7
.1:
        test byte [gmode], 0x1
        jnz short .7
        push si
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .9
        test byte [si + 0x44], 0x2
        jz short .2
        and byte [si + 0x44], 0xfd
        mov [si + 0x26], ax
.2:
        dec byte [si + 0x27]
        jns short .6
        mov al, [si + 0x4e]
        shr al, byte 0x2
        mov [si + 0x27], al
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .7
        mov bx, [puckvy]
        cmp word [bx], 0x0
        jnl short .3
        mov ax, 0x1
        jmp short .4
        db 0x90, 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        mov cl, [si + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jnz short .7
        mov bx, [si + 0x60]
        cmp word [bx + 0x28], 0x0
        jl short .7
        jg short .5
        cmp word [bx + 0x26], 0xe10
        jc short .7
.5:
        mov bx, [si + 0x62]
        cmp word [bx + 0x28], 0x0
        jg short .6
        jl short .7
        cmp word [bx + 0x26], 0x640
        jc short .7
.6:
        push si
        call 0x2425:skatetopuck
        jmp short .8
.7:
        push si
        push cs
        call assexit
.8:
        add sp, 0x2
.9:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assgoalie                                                  2519:11BE  94 PC
; Assignment: the goalie in his net, following the puck.
;
; Takes 1 word of stack arguments. Calls check4bench, skateto, SetSPA, AddPenalty2, randomd0,
; chk4pass, VectorToDir8, ImulRegs and others. Far routine (retf).
;-----------------------------------------------------------------------------
assgoalie:
        enter 0x6, 0x0
        push si
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x20
        jz short .1
        jmp near .81
.1:
        push bx
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .81
.2:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x2
        jz short .3
        and byte [bx + 0x44], 0xfd
        mov [bx + 0x26], ax
        mov word [bx + 0x28], 0x8
        mov byte [bx + 0x2d], 0xff
.3:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x34
        jg short .4
        mov ax, [bx + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xee
        jg short .4
        cmp ax, 0xb2
        jg short .8
.4:
        cmp word [bx + 0x2], 0x0
        jl short .5
        mov ax, 0x4
        jmp short .6
        db 0x90
.5:
        mov ax, 0xfffc
.6:
        mov [regd0], ax
        mov word [regd1], 0xc4
        test byte [bx + 0x44], 0x80
        jz short .7
        mov word [regd1], 0xff3c
.7:
        push word 0x1b35
        push strict word avdgoal_boxThunk
        push bx
        call 0x2425:skateto
        add sp, 0x6
        pop si
        leave
        retf
.8:
        test byte [bx + 0x45], 0x2
        jz short .9
        jmp near .81
.9:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov bx, [bp + 0x6]
        cmp [bx + 0x5e], ax
        jnz short .10
        mov ax, 0x99
        jmp short .11
        db 0x90
.10:
        mov ax, 0x1
.11:
        mov [bp - 0x2], ax
        call 0x2E42:SetSPA
        test byte [gmode], 0x1
        jz short .12
        jmp near .81
.12:
        mov bx, [bp + 0x6]
        cmp word [bx + 0x2e], 0x0
        jl short .14
        mov si, [puckc]
        mov al, [si]
        cbw
        cmp [bx + 0x5e], ax
        jz short .13
        mov byte [bx + 0x2f], 0xff
        jmp short .14
.13:
        dec word [bx + 0x2e]
        jns short .14
        push 0x4
        push bx
        call 0x327B:AddPenalty2
        add sp, 0x4
.14:
        mov bx, [bp + 0x6]
        dec byte [bx + 0x27]
        js short .15
        jmp near .78
.15:
        mov al, [bx + 0x4e]
        shr al, byte 0x2
        mov [bx + 0x27], al
        test byte [bx + 0x44], 0x8
        jz short .16
        jmp near .32
.16:
        mov ax, [bx + 0x6]
        mov si, [pucky]
        xor ax, [si]
        jnl short .18
        mov word [regd0], 0x0
        mov word [regd2], 0xd4
        test byte [bx + 0x44], 0x80
        jnz short .17
        jmp near .76
.17:
        mov word [regd2], 0xff2c
        jmp near .76
.18:
        mov bx, [bp + 0x6]
        dec word [bx + 0x2c]
        jns short .19
        mov word [bx + 0x2c], 0xffff
.19:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov bx, [bp + 0x6]
        cmp [bx + 0x5e], ax
        jz short .20
        jmp near .32
.20:
        cmp word [bx + 0x2e], 0x0
        jnl short .21
        mov word [bx + 0x2e], 0x5a
.21:
        mov bx, [bp + 0x6]
        mov byte [bx + 0x2d], 0xff
        cmp word [bx + 0x2e], 0x5a
        jg short .26
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .26
        mov bx, [bp + 0x6]
        cmp word [bx + 0x5e], 0x6
        jnl short .22
        mov ax, 0x6
.22:
        shl ax, byte 0x7
        add ax, SortCords
        mov [bp - 0x4], ax
        mov word [bp - 0x2], 0x0
        jmp short .24
        db 0x90
.23:
        inc word [bp - 0x2]
        add word [bp - 0x4], 0x80
.24:
        cmp word [bp - 0x2], 0x6
        jl short .25
        jmp near .31
.25:
        mov bx, [bp - 0x4]
        test byte [bx + 0x45], 0x4
        jnz short .23
        mov si, [pucky]
        mov ax, [si]
        sub ax, [bx + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x1c
        jg short .23
        mov si, [puckx]
        mov ax, [si]
        sub ax, [bx + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x19
        jg short .23
.26:
        mov word [bp - 0x6], puckcross
        mov word [regd3], 0xe4
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x80
        jz short .27
        mov word [bp - 0x6], GoalState_m5 + 1
        mov word [regd3], 0xff1c
.27:
        mov ax, [bx + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe4
        jg short .28
        jmp near .39
.28:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [regd2], ax
        mov [regd0], ax
        mov ax, [bx + 0x2]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x2c
        jng short .29
        jmp near .76
.29:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnl short .30
        jmp near .38
.30:
        mov ax, 0xa0
        jmp near .75
.31:
        mov word [threat], 0x1
        push word [bp + 0x6]
        call 0x28BB:chk4pass
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .26
        pop si
        leave
        retf
.32:
        mov bx, [bp + 0x6]
        cmp word [bx + 0x2c], 0x0
        jnz short .26
        mov si, [puckc]
        cmp byte [si], 0x0
        jl short .33
        jmp near .26
.33:
        mov si, [puckx]
        mov ax, [si]
        sub ax, [bx + 0x2]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jng short .34
        jmp near .26
.34:
        mov si, [pucky]
        mov ax, [si]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jng short .35
        jmp near .26
.35:
        mov ax, [regd1]
        sub ax, [bx + 0x6]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x18
        jng short .36
        jmp near .26
.36:
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov bx, [bp + 0x6]
        mov [bx + 0x36], ax
        mov word [bx + 0x3e], 0x8
        mov ax, SPAno(SPAgdive)
        call 0x2E42:SetSPA
        mov bx, [bp + 0x6]
        or byte [bx + 0x45], 0x2
        cmp word [CrowdSound], 0x4b0
        jg short .37
        add word [CrowdSound], 0x96
        cmp word [CrowdSound], 0x4b0
        jng short .37
        mov word [CrowdSound], 0x4b0
.37:
        add word [crowdheat], 0xa
        pop si
        leave
        retf
        db 0x90
.38:
        mov ax, 0xff60
        jmp near .75
.39:
        mov bx, [puckx]
        mov ax, [bx]
        mov [regd0], ax
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd1], ax
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov bx, [bp + 0x6]
        cmp [bx + 0x5e], ax
        jnz short .40
        mov word [regd0], 0x0
.40:
        cmp word [regd1], 0xe3
        jng short .41
        mov word [regd1], 0xe3
.41:
        cmp word [regd1], 0xff1d
        jnl short .42
        mov word [regd1], 0xff1d
.42:
        mov ax, [regd3]
        sub [regd1], ax
        mov dx, [regd1]
        mov ax, [regd0]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x36]
        mov [regd1], ax
        sub [regd0], ax
        jz short .45
        mov cx, [regd0]
        neg cx
        and cx, 0x4
        sar cx, 1
        dec cx
        mov [regd0], cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov dx, 0x1
        shl dx, cl
        test dl, 0x42
        jnz short .43
        add ax, [regd0]
        mov [regd1], ax
        jmp short .44
        db 0x90
.43:
        mov ax, [regd0]
        add [regd1], ax
        mov cl, [bx + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x4b
        add cx, 0x38
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov cl, [regd1]
        mov bx, 0x1
        shl bx, cl
        test bx, dx
        jz short .44
        neg ax
        mov [regd0], ax
        shl ax, 1
        add [regd1], ax
.44:
        and word [regd1], 0x7
        mov ax, [regd1]
        mov bx, [bp + 0x6]
        mov [bx + 0x36], ax
.45:
        mov al, [gameclock]
        and ax, strict word 0x7
        shl ax, byte 0x4
        add ax, 0xa0
        mov [regd0], ax
        mov bx, [pucky]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xbb
        jng short .46
        sub cx, 0x40
        mov [regd0], cx
.46:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov [regd1], ax
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov bx, [puckvx]
        mov ax, [bx]
        call 0x03A3:ImulRegs
        mov bx, [puckx]
        add dx, [bx]
        mov [regd0], dx
        mov bx, [puckvy]
        mov ax, [bx]
        mov dx, [regd1]
        call 0x03A3:ImulRegs
        mov bx, [pucky]
        add dx, [bx]
        mov [regd1], dx
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov bx, [bp + 0x6]
        cmp [bx + 0x5e], ax
        jnz short .47
        mov word [regd0], 0x0
.47:
        cmp dx, 0xe3
        jng short .48
        mov word [regd1], 0xe3
.48:
        cmp word [regd1], 0xff1d
        jnl short .49
        mov word [regd1], 0xff1d
.49:
        mov ax, [regd3]
        sub [regd1], ax
        push word [regd1]
        push word [regd0]
        call 0x03A3:FoldScale
        add sp, 0x4
        inc ax
        mov [regd2], ax
        cmp ax, strict word 0x1e
        jng short .51
        mov word [regd4], 0x12
        test byte [sflags], 0x8
        jz short .50
        mov word [regd4], 0x1a
.50:
        mov ax, [regd1]
        mov dx, [regd4]
        call 0x03A3:ImulRegs
        mov bx, [regd2]
        call 0x03A3:IdivWords.regs
        mov [regd1], ax
        add word [regd4], 0x8
        mov dx, [regd4]
        mov ax, [regd0]
        call 0x03A3:ImulRegs
        mov bx, [regd2]
        call 0x03A3:IdivWords.regs
        mov [regd0], ax
.51:
        mov ax, [regd3]
        add [regd1], ax
        mov ax, [regd1]
        mov [regd2], ax
        mov bx, [bp - 0x6]
        cmp word [bx + 0x2], 0x22
        jna short .52
        jmp near .76
.52:
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x18
        jg short .53
        jmp near .65
.53:
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .54
        jmp near .76
.54:
        test byte [iflags], 0x4
        jz short .55
        jmp near .76
.55:
        mov bx, [bp + 0x6]
        mov si, [bx + 0x60]
        cmp word [si + 0x28], 0x0
        jnl short .56
        jmp near .76
.56:
        jg short .57
        cmp word [si + 0x26], 0x1324
        jnc short .57
        jmp near .76
.57:
        mov si, [bx + 0x62]
        cmp word [si + 0x28], 0x0
        jnl short .58
        jmp near .76
.58:
        jg short .59
        cmp word [si + 0x26], 0x9c4
        jnc short .59
        jmp near .76
.59:
        mov si, [pucky]
        mov ax, [si]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xc0
        jg short .60
        jmp near .76
.60:
        mov si, [puckvy]
        cmp word [si], 0x0
        jnl short .61
        mov ax, 0x1
        jmp short .62
.61:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.62:
        mov cl, [bx + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .63
        jmp near .76
.63:
        mov bx, [puckvx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .64
        jmp near .76
.64:
        push 0xf
        push word [bp + 0x6]
        call 0x1E7E:assinsert
        jmp near .79
        db 0x90
.65:
        cmp word [bx + 0x2], 0xc
        jna short .66
        jmp near .73
.66:
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jng short .67
        jmp near .73
.67:
        mov bx, [bp + 0x6]
        test byte [bx + 0x45], 0x2
        jz short .68
        jmp near .73
.68:
        or byte [bx + 0x45], 0x2
        mov bx, [bp - 0x6]
        mov ax, [bx]
        mov bx, [bp + 0x6]
        sub ax, [bx + 0x2]
        mov dx, [regd3]
        sub dx, [bx + 0x6]
        call 0x0D5F:VectorToDir8
        mov bx, [bp + 0x6]
        sub al, [bx + 0x36]
        and ax, strict word 0x7
        mov [regd3], ax
        sar ax, byte 0x2
        mov [regd0], ax
        test byte [bx + 0x49], 0x8
        jz short .69
        xor al, 0x1
        mov [regd0], ax
.69:
        mov bx, [puckz]
        cmp word [bx], 0x8
        jg short .70
        mov bx, [puckvz]
        cmp word [bx], 0x800
        jg short .70
        add word [regd0], 0x4
        mov bx, [bp - 0x6]
        cmp word [bx + 0x2], 0x8
        jna short .70
        mov bx, [bp + 0x6]
        cmp word [bx + 0x36], 0x2
        jz short .70
        cmp word [bx + 0x36], 0x6
        jz short .70
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .70
        sub word [regd0], 0x2
.70:
        mov bx, [regd0]
        shl bx, 1
        mov ax, [bx + goaliesave_saveanim_m2]
        mov [regd1], ax
        cmp ax, SPAno(SPAgglovel)
        jnz short .71
        and word [regd3], 0x3
        jz short .71
        mov bx, [bp + 0x6]
        cmp byte [bx + 0x56], 0xb
        jc short .71
        mov word [regd1], SPAno(SPAgglovel2)
.71:
        mov bx, [bp + 0x6]
        mov ax, [regd1]
        call 0x2E42:SetSPA
        cmp word [CrowdSound], 0x3e8
        jg short .72
        add word [CrowdSound], 0x96
        cmp word [CrowdSound], 0x3e8
        jng short .72
        mov word [CrowdSound], 0x3e8
.72:
        add word [crowdheat], 0xa
.73:
        mov bx, [bp - 0x6]
        mov ax, [bx]
        mov [regd0], ax
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xdc
        jng short .76
        mov bx, [puckx]
        cmp word [bx], 0x0
        jl short .74
        mov ax, 0x18
        jmp short .75
.74:
        mov ax, 0xffe8
.75:
        mov [regd0], ax
.76:
        mov ax, [regd2]
        mov [regd1], ax
        mov bx, [bp + 0x6]
        mov al, [bx + 0xd]
        cbw
        add ax, [bx + 0x2]
        sub [regd0], ax
        mov al, [bx + 0xf]
        cbw
        sub ax, [regd2]
        neg ax
        sub ax, [bx + 0x6]
        mov [regd1], ax
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x4
        jg short .77
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x4
        jg short .77
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [regd1], ax
        mov [regd0], ax
.77:
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov al, [regd0]
        mov bx, [bp + 0x6]
        mov [bx + 0x28], al
.78:
        mov bx, [bp + 0x6]
        mov al, [bx + 0x28]
        cbw
        mov [regd2], ax
        cmp ax, strict word 0x7
        jg short .80
        push ax
        push bx
        call 0x2425:playeracc
.79:
        add sp, 0x4
        pop si
        leave
        retf
.80:
        push bx
        call 0x2425:stopna
        add sp, 0x2
.81:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; CountPuckThreat                                            2519:18E6  94 PC
; Counts the opposing skaters close to the puck.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CountPuckThreat:
        enter 0x4, 0x0
        push di
        push si
        mov dx, [bp + 0x6]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + 0xd]
        cbw
        mov si, [puckx]
        add ax, [si]
        mov [bp - 0x2], ax
        mov al, [bx + 0xf]
        cbw
        mov si, [pucky]
        add ax, [si]
        mov [bp - 0x4], ax
        mov word [threat], 0x0
        cmp word [bx + 0x5e], 0x6
        jl short .1
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        jmp short .2
        db 0x90
.1:
        mov bx, 0x6
.2:
        shl bx, byte 0x7
        add bx, SortCords
        mov di, 0x6
.3:
        mov al, [bx + 0xd]
        cbw
        add ax, [bx + 0x2]
        sub ax, [bp - 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .4
        mov al, [bx + 0xf]
        cbw
        add ax, [bx + 0x6]
        sub ax, [bp - 0x4]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .4
        inc word [threat]
.4:
        add bx, 0x80
        dec di
        jnz short .3
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; asspuckc                                                   2519:1960  94 PC
; Assignment of the puck carrier: line change, shot and pass checks, then skates with asspuckc_chkdir
; as the collision routine.
;
; Takes 1 word of stack arguments. Calls assexit, donothing, randomd0, checkob, chk4lc, chk4shot,
; chk4pass, skateto. Far routine (retf).
;-----------------------------------------------------------------------------
asspuckc:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .3
.1:
        push si
        push cs
        call assexit
.2:
        add sp, 0x2
        pop si
        leave
        retf
.3:
        test byte [si + 0x44], 0x20
        jz short .4
        jmp near .14
.4:
        test byte [gmode], 0x1
        jz short .5
        push si
        push cs
        call donothing
        jmp short .2
        db 0x90
.5:
        test byte [si + 0x44], 0x8
        jnz short .1
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        mov word [si + 0x26], 0x0
        mov word [si + 0x28], 0x8
        mov ax, 0x4
        call 0x0C11:randomd0
        mov [si + 0x2a], ax
        mov word [threat], 0x0
.6:
        dec byte [si + 0x27]
        jns short .9
        mov al, [si + 0x4d]
        mov [si + 0x27], al
        push si
        call 0x28BB:checkob
        add sp, 0x2
        push si
        call 0x28BB:chk4lc
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        jmp near .14
.7:
        push si
        call 0x28BB:chk4shot
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        jmp near .14
.8:
        push si
        call 0x28BB:chk4pass
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
.9:
        test byte [gmode2], 0x80
        jz short .10
        mov ax, [si + 0x1a]
        dec ax
        jmp short .11
        db 0x90
.10:
        mov ax, [si + 0x2a]
        add ax, strict word 0x6
.11:
        mov [regd0], ax
        shl word [regd0], 1
        mov bx, [regd0]
        shl bx, 1
        mov ax, [bx + asspuckc_postab2_y]
        mov [regd1], ax
        mov ax, [bx + asspuckc_postab2]
        mov [regd0], ax
        test byte [si + 0x44], 0x80
        jnz short .12
        neg word [regd0]
        neg word [regd1]
.12:
        mov ax, [si + 0x2]
        sub ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jg short .13
        mov ax, [si + 0x6]
        sub ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jg short .13
        mov ax, 0x4
        call 0x0C11:randomd0
        mov [si + 0x2a], ax
.13:
        push word 0x1b35
        push strict word asspuckc_chkdirThunk
        push si
        call 0x2425:skateto
        add sp, 0x6
.14:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; asspuckc_chkdir                                            2519:1A7E  94 PC
; Collision routine that asspuckc passes to skateto.
;
; Takes 1 word of stack arguments. Calls VectorToDir8, randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
asspuckc_chkdir:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        mov al, [regd0]
        cbw
        mov [regd0], ax
        mov al, [di + 0xd]
        cbw
        mov bx, [puckx]
        add ax, [bx]
        mov [regd2], ax
        mov al, [di + 0xf]
        cbw
        mov bx, [pucky]
        add ax, [bx]
        mov [regd3], ax
        mov word [threat], 0x0
        mov word [regd4], 0x6
        cmp word [di + 0x5e], 0x6
        jl short .1
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .2
        db 0x90
.1:
        mov si, 0x6
.2:
        shl si, byte 0x7
        add si, SortCords
.3:
        mov al, [si + 0xd]
        cbw
        add ax, [si + 0x2]
        sub ax, [regd2]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x19
        jg short .4
        mov al, [si + 0xf]
        cbw
        add ax, [si + 0x6]
        sub ax, [regd3]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x19
        jg short .4
        inc word [threat]
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov dx, [di + 0x6]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov ax, [di + 0x36]
        xor al, 0x4
        mov [regd1], ax
        mov ax, [regd0]
        cmp [regd1], ax
        jnz short .4
        mov ax, 0x2
        call 0x0C11:randomd0
        add al, [regd0]
        and ax, strict word 0x7
        mov [regd0], ax
.4:
        add si, 0x80
        dec word [regd4]
        jnz short .3
        mov ax, [regd2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xaa
        jnl short .5
        jmp near .14
.5:
        cmp word [di + 0x6], 0x0
        jnl short .6
        mov ax, 0x1
        jmp short .7
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.7:
        mov cl, [di + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .8
        jmp near .14
.8:
        mov word [regd4], 0x6
        cmp word [di + 0x5e], 0x6
        jl short .9
        mov si, 0x6
        jmp short .10
.9:
        db 0x2B, 0xF6                           ; insn: sub si, si
.10:
        shl si, byte 0x7
        add si, SortCords
.11:
        cmp word [si + 0x1a], 0x0
        jz short .12
        add si, 0x80
        dec word [regd4]
        jnz short .11
        jmp short .13
        db 0x90
.12:
        mov al, [si + 0xd]
        cbw
        add ax, [si + 0x2]
        sub ax, [regd2]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .13
        mov al, [si + 0xf]
        cbw
        add ax, [si + 0x6]
        sub ax, [regd3]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .13
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov dx, [di + 0x6]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
.13:
        mov ax, [regd2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x1e
        jg short .14
        mov al, [di + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1b8
        add ax, 0xff24
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sub ax, [regd3]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .14
        mov ax, [di + 0x2]
        mov dx, [di + 0x6]
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
.14:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assnearest                                                 2519:1C22  94 PC
; Assignment: the player nearest the puck goes after it.
;
; Takes 1 word of stack arguments. Calls assgoalie, assinsert, GetHot, ImulRegs, assexit, randomd0,
; check4bench, donothing and others. Far routine (retf).
;-----------------------------------------------------------------------------
assnearest:
        enter 0xe, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        mov [bp - 0xa], bx
        mov ax, [bx + 0x60]
        mov [bp - 0xc], ax
        test byte [bx + 0x44], 0x2
        jz short .1
        and byte [bx + 0x44], 0xfd
        mov word [bx + 0x26], 0x0
        mov word [bx + 0x28], 0x8
        mov word [bx + 0x2a], 0x0
.1:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov bx, [bp + 0x6]
        cmp ax, [bx + 0x5e]
        jnz short .4
        cmp word [bx + 0x1a], 0x0
        jnz short .2
        push bx
        push cs
        call assgoalie
        jmp near .49
.2:
        test byte [bx + 0x44], 0x8
        jz short .3
        jmp near .50
.3:
        push 0x10
        push bx
        call 0x1E7E:assinsert
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.4:
        dec byte [bx + 0x27]
        js short .5
        jmp near .35
.5:
        mov al, [bx + 0x4d]
        mov [bx + 0x27], al
        mov si, [bp - 0xc]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x28], ax
        mov [si + 0x26], ax
        mov si, [puckc]
        cmp byte [si], 0x0
        jl short .9
        cmp byte [si], 0x6
        jnl short .6
        mov ax, 0x1
.6:
        mov bx, [bp + 0x6]
        mov [bp - 0xe], ax
        cmp word [bx + 0x5e], 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
        db 0x90
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        cmp ax, [bp - 0xe]
        jnz short .9
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov al, [bx]
        cbw
        shl ax, byte 0x7
        add ax, SortCords
        mov [bp - 0xa], ax
        jmp near .23
.9:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x5e]
        mov [bp - 0x6], ax
        mov ax, [bx + 0x6]
        mov [bp - 0x2], ax
        mov word [regd2], 0xffff
        mov word [regd2_w2], 0xffff
        mov word [regd4], 0x6
        cmp word [bx + 0x5e], 0x6
        jl short .10
        mov ax, 0x6
        jmp short .11
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.11:
        shl ax, byte 0x7
        add ax, SortCords
        mov [bp - 0x8], ax
.12:
        mov bx, [bp - 0x8]
        cmp word [bx + 0x1a], 0x0
        jg short .13
        jmp near .21
.13:
        cmp word [bx + 0x3e], 0x0
        jz short .14
        jmp near .21
.14:
        test byte [bx + 0x45], 0x4
        jz short .15
        jmp near .21
.15:
        mov si, [bx + 0x1c]
        cmp byte [bx + si + 0x1e], 0x13
        jnz short .16
        jmp near .21
.16:
        mov ax, [bx + 0x6]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jnl short .19
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x80
        jz short .17
        cmp cx, [bp - 0x2]
        jng short .18
.17:
        test byte [bx + 0x44], 0x80
        jnz short .19
        mov ax, [bp - 0x2]
        mov bx, [bp - 0x8]
        cmp [bx + 0x6], ax
        jl short .19
.18:
        mov bx, [bp - 0x8]
        mov ax, [bx + 0x5e]
        mov [bp - 0x6], ax
        mov ax, [bx + 0x6]
        mov [bp - 0x2], ax
.19:
        push word [bp - 0x8]
        call 0x2E42:GetHot
        add sp, 0x2
        mov bx, [puckvx]
        mov ax, [bx]
        sar ax, byte 0x6
        mov bx, [bp - 0x8]
        sub ax, [bx + 0x2]
        neg ax
        mov si, [puckx]
        sub ax, [si]
        add [regd0], ax
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [regd0], ax
        mov [regd0_w2], dx
        mov bx, [puckvy]
        mov ax, [bx]
        sar ax, byte 0x6
        mov bx, [bp - 0x8]
        sub ax, [bx + 0x6]
        neg ax
        mov si, [pucky]
        sub ax, [si]
        add [regd1], ax
        mov ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [regd1], ax
        mov [regd1_w2], dx
        mov ax, [regd2]
        mov dx, [regd2_w2]
        mov cx, [regd1]
        mov bx, [regd1_w2]
        add [regd0], cx
        adc [regd0_w2], bx
        cmp [regd0_w2], dx
        ja short .21
        jc short .20
        cmp [regd0], ax
        ja short .21
.20:
        mov ax, [regd0]
        mov dx, [regd0_w2]
        mov [regd2], ax
        mov [regd2_w2], dx
        mov ax, [bp - 0x8]
        mov [bp - 0xa], ax
.21:
        add word [bp - 0x8], 0x80
        dec word [regd4]
        jz short .22
        jmp near .12
.22:
        cmp word [regd2_w2], 0x0
        jl short .24
        mov ax, [regd2]
        mov dx, [regd2_w2]
        mov bx, [bp - 0xc]
        mov [bx + 0x26], ax
        mov [bx + 0x28], dx
.23:
        mov ax, [bp + 0x6]
        cmp [bp - 0xa], ax
        jz short .24
        test byte [gmode], 0x1
        jnz short .24
        mov bx, [bp - 0xa]
        test byte [bx + 0x45], 0x4
        jnz short .24
        and byte [bx + 0x44], 0xfe
        push 0x11
        push bx
        call 0x1E7E:assinsert
        add sp, 0x4
        push word [bp + 0x6]
        push cs
        call assexit
        jmp near .49
.24:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x20
        jz short .25
        jmp near .50
.25:
        mov word [regd1], 0x2
        mov word [regd1_w2], 0x0
        cmp word [regd2], 0x190
        jng short .28
        cmp word [regd2], 0xe10
        jg short .26
        mov bx, [puckvx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1f4
        jnl short .26
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1f4
        jl short .28
.26:
        mov bx, [bp + 0x6]
        cmp word [bx + 0x1a], 0x2
        jng short .30
        test byte [bx + 0x44], 0x80
        jz short .27
        cmp word [bx + 0x1a], 0x4e
        jg short .28
.27:
        test byte [bx + 0x44], 0x80
        jnz short .30
        cmp word [bx + 0x1a], -0x4e
        jnl short .30
.28:
        sub word [regd1], 0x2
        mov bx, [bp + 0x6]
        cmp word [bx + 0x1a], 0x2
        jg short .30
        mov ax, [bp - 0x6]
        cmp [bx + 0x5e], ax
        jnz short .29
        jmp near .35
.29:
        mov ax, 0x32
        mov cl, [bx + 0x56]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov cl, [bx + 0x58]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov cl, [bx + 0x4e]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .30
        jmp near .35
.30:
        mov bx, [puckvx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1f4
        jnl short .31
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x1f4
        jnl short .31
        dec word [regd1]
.31:
        test byte [gmode2], 0x20
        jz short .32
        sub word [regd1], 0x2
        mov bx, [bp + 0x6]
        mov al, [bx + 0x44]
        xor al, [gmode2]
        test al, 0x40
        jz short .32
        add word [regd1], 0x4
        adc word [regd1_w2], 0x0
.32:
        cmp word [regd1], 0x0
        jnl short .33
        mov cl, [regd1]
        neg cl
        mov bx, [bp + 0x6]
        mov al, [bx + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x14
        neg ax
        sar ax, cl
        jmp short .34
        db 0x90
.33:
        mov cl, [regd1]
        mov bx, [bp + 0x6]
        mov al, [bx + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x14
        neg ax
        shl ax, cl
.34:
        mov [regd0], ax
        call 0x0C11:randomd0
        cmp ax, strict word 0x1
        ja short .35
        mov bx, [bp + 0x6]
        mov word [bx + 0x2a], 0x12c
.35:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x20
        jz short .36
        jmp near .50
.36:
        test byte [gmode], 0x1
        jz short .38
        push bx
        call 0x2164:check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .37
        jmp near .50
.37:
        push word [bp + 0x6]
        push cs
        call donothing
        jmp near .49
        db 0x90
.38:
        test byte [bx + 0x44], 0x8
        jz short .39
        jmp near .50
.39:
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .40
        jmp near .42
.40:
        mov bx, [bp + 0x6]
        dec word [bx + 0x2a]
        js short .41
        jmp near .42
.41:
        mov word [bx + 0x2a], 0x0
        mov bx, [puckvx]
        mov al, [bx + 0x1]
        sar al, 1
        cbw
        mov bx, [puckx]
        add ax, [bx]
        mov [regd0], ax
        mov si, [puckvy]
        mov al, [si + 0x1]
        cbw
        mov si, [pucky]
        add ax, [si]
        sar ax, 1
        mov [regd1], ax
        mov ax, [regd0]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [regd0], ax
        mov di, [bp + 0x6]
        mov al, [di + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1a8
        add ax, 0xff2c
        sub ax, [regd1]
        sar ax, 1
        add [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnl short .47
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x41
        jnl short .47
        mov ax, [regd1]
        db 0x2B, 0xC6                           ; insn: sub ax, si
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jng short .47
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jnl short .44
        cmp cx, 0xc8
        jng short .47
        cmp word [regd1], 0x0
        jl short .43
        mov ax, 0xc8
        jmp short .46
.42:
        push word [bp + 0x6]
        call 0x2425:skatetopuck
        add sp, 0x2
        jmp short .48
        db 0x90
.43:
        mov ax, 0xff38
        jmp short .46
        db 0x90
.44:
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jnl short .47
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xd2
        jng short .47
        cmp word [regd1], 0x0
        jl short .45
        mov ax, 0xd2
        jmp short .46
.45:
        mov ax, 0xff2e
.46:
        mov [regd1], ax
.47:
        push 0x0
        push 0x0
        push word [bp + 0x6]
        call 0x2425:skateto
        add sp, 0x6
.48:
        push word [bp + 0x6]
        call 0x28BB:check4check
.49:
        add sp, 0x2
.50:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; assshoot                                                   2519:20F8  94 PC
; Assignment: the player taking a shot.
;
; Takes 1 word of stack arguments. Calls SetShotMode, assexit, ShotMode. Far routine (retf).
;-----------------------------------------------------------------------------
assshoot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .5
        test byte [si + 0x44], 0x2
        jz short .1
        and byte [si + 0x44], 0xfd
        push si
        call 0x28BB:SetShotMode
        jmp short .4
        db 0x90
.1:
        test byte [sflags], 0x8
        jnz short .2
        push si
        push cs
        call assexit
        jmp short .4
.2:
        mov word [regd2], 0x0
        dec word [si + 0x28]
        jns short .3
        or byte [regd2], 0x20
.3:
        push si
        call 0x28BB:ShotMode
.4:
        add sp, 0x2
.5:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assfaceoff                                                 2519:2142  94 PC
; Assignment: skates to a faceoff position.
;
; Takes 1 word of stack arguments. Calls assexit. Far routine (retf).
;-----------------------------------------------------------------------------
assfaceoff:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .1
        test byte [gmode2], 0x1
        jnz short .1
        push si
        push cs
        call assexit
        add sp, 0x2
.1:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assfaceoffpl                                               2519:2162  94 PC
; Assignment of a faceoff participant: waits for the drop, then leaves the faceoff.
;
; Takes 1 word of stack arguments. Calls assexit, SetSPA, randomd0, PlaySoundEffect. Far routine
; (retf).
;-----------------------------------------------------------------------------
assfaceoffpl:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .15
.1:
        test byte [gmode2], 0x1
        jnz short .2
        mov word [si + 0x3e], 0x14
        push si
        push cs
        call assexit
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        test byte [si + 0x44], 0x2
        jz short .4
        and byte [si + 0x44], 0xfd
        mov word [si + 0x26], 0x0
        cmp word [si + 0x36], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x5
        add ax, 0x167
        mov [si + 0x12], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        call 0x2E42:SetSPA
        test byte [si + 0x44], 0x40
        jz short .3
        mov ax, 0xa
        call 0x0C11:randomd0
        add ax, strict word 0x14
        mov [si + 0x2e], ax
        jmp short .4
        db 0x90
.3:
        mov word [si + 0x2e], 0x28
.4:
        mov di, fofdata2
        mov al, [si + 0x44]
        and al, 0x40
        jz short .5
        mov di, fofdata_w2
.5:
        cmp word [si + 0x12], 0x169
        jz short .8
        cmp word [si + 0x12], 0x16e
        jz short .8
        cmp word [si + 0x12], 0x16a
        jz short .6
        cmp word [si + 0x12], 0x16f
        jz short .6
        mov word [regd0], 0x1
        jmp short .9
.6:
        cmp word [si + 0x3c], 0x7
        jnz short .7
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        add ax, 0x9f
        push ax
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.7:
        mov word [regd0], 0x3
        jmp short .9
        db 0x90
.8:
        mov word [regd0], 0x2
.9:
        cmp byte [si + 0x59], 0x0
        jnz short .10
        add word [regd0], 0x3
.10:
        mov ax, [regd0]
        mov [di], ax
        test byte [si + 0x44], 0x8
        jnz short .15
        test byte [si + 0x45], 0x2
        jnz short .15
        or byte [si + 0x45], 0x2
        cmp word [si + 0x2e], 0x0
        jnl short .13
        cmp word [pucktemp1], 0x10
        jna short .11
        mov ax, 0x8
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
.11:
        mov word [si + 0x2e], 0xffff
        cmp word [pucktemp1], 0x11
        jnl short .12
        or byte [si + 0x44], 0x20
        mov cx, SPAno(SPAfaceoff)
        jmp short .14
.12:
        mov cx, 0xd05
        jmp short .14
        db 0x90
.13:
        dec word [si + 0x2e]
        jns short .15
        mov cx, SPAno(SPAfaceoffr)
.14:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
.15:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; pucknorm                                                   2519:2294  94 PC
; Puck assignment in normal play.
;
; Takes 1 word of stack arguments. Calls findpc, a2touchpuck, GetHot, PuckIChk, ChkOffsides,
; MarkTwoLinePlayers, AddPenalty2, puckunflip and others. Far routine (retf).
;-----------------------------------------------------------------------------
pucknorm:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x2
        jz short .1
        and byte [si + 0x44], 0xfd
        mov word [si + 0x26], 0x0
        mov word [si + 0x28], 0x78
.1:
        dec word [GoalState_m6]
        dec word [GoalState_m2]
        dec word [si + 0x26]
        jns short .2
        add word [si + 0x26], 0x5
        push si
        call 0x2E42:findpc
        add sp, 0x2
.2:
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .3
        cbw
        shl ax, byte 0x7
        add ax, SortCords
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push ax
        push cs
        call a2touchpuck
        add sp, 0x2
        push di
        call 0x2E42:GetHot
        add sp, 0x2
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        add ax, [regd0]
        sar ax, byte 0x2
        add [si + 0x2], ax
        mov ax, [di + 0x6]
        sub ax, [si + 0x6]
        add ax, [regd1]
        sar ax, byte 0x2
        add [si + 0x6], ax
        mov ax, [di + 0xc]
        mov [si + 0xc], ax
        mov ax, [di + 0xe]
        mov [si + 0xe], ax
.3:
        call 0x28BB:PuckIChk
        push si
        call 0x28BB:ChkOffsides
        add sp, 0x2
        push si
        call 0x28BB:MarkTwoLinePlayers
        add sp, 0x2
        test byte [gmode], 0x1
        jnz short .5
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .4
        mov ax, [si + 0x66]
        cmp [si + 0x2], ax
        jnz short .4
        mov ax, [si + 0x6]
        cmp [si + 0x6a], ax
        jnz short .4
        dec word [si + 0x28]
        jns short .5
        push 0x3
        push si
        call 0x327B:AddPenalty2
        add sp, 0x4
        jmp short .5
        db 0x90
.4:
        mov word [si + 0x28], 0x78
.5:
        mov ax, [si + 0x10]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x100
        jnl short .6
        cmp word [si + 0xa], 0x0
        jnz short .6
        push si
        push cs
        call puckunflip
        add sp, 0x2
.6:
        push si
        call 0x28BB:checkpuckcoll
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; pucknothing                                                2519:2396  94 PC
; Puck assignment with nothing to do.
;
; Takes 1 word of stack arguments. Calls puckunflip. Far routine (retf).
;-----------------------------------------------------------------------------
pucknothing:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x6]
        push cs
        call puckunflip
        leave
        retf

;-----------------------------------------------------------------------------
; rtss2                                                      2519:23A2  94 PC
; A second empty routine after pucknothing; nothing calls it.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
rtss2:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RequestLineChange                                          2519:23A4  94 PC
; Opens the line change box for a team with its current choice and starts the blink timers.
;
; Takes 1 word of stack arguments. Calls getlchoice. Far routine (retf).
;-----------------------------------------------------------------------------
RequestLineChange:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        inc si
        mov word [regd0], 0x1
        push di
        call 0x2C24:getlchoice
        add sp, 0x2
        cmp word [regd0], 0x0
        jnl short .3
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov [bp - 0x2], bx
        mov word [bx + lcchoice], 0x0
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .1
        mov bx, awshots
        jmp short .2
        db 0x90
.1:
        mov bx, hmshots
.2:
        mov ax, [bx + 0x16]
        mov bx, [bp - 0x2]
        jmp short .4
        db 0x90
.3:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov [bp - 0x2], bx
        mov word [bx + lcchoice], 0x1
        mov ax, [regd0]
.4:
        mov [bx + lcgroup], ax
        mov bx, [bp - 0x2]
        mov word [bx + lctime], 0x3c
        mov word [bx + lcblink], 0xc
        mov ax, 0x1
        mov [bx + lcsel], ax
        mov [bx + lcboxon], ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .5
        mov word [hudlinegroup], 0x0
        pop si
        pop di
        leave
        retf
.5:
        mov word [hudlineaway], 0x0
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetLCmode                                                  2519:2436  94 PC
; Puts a player's team into line change mode when line changes are on and it is not in it already.
;
; Takes 1 word of stack arguments. Calls RequestLineChange. Far routine (retf).
;-----------------------------------------------------------------------------
SetLCmode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [CrowdState], 0x4
        jz short .1
        mov di, [bp + 0x6]
        mov si, [di + 0x60]
        test byte [si + 0x2a], 0x2
        jnz short .1
        or byte [si + 0x2a], 0x2
        and byte [sflags], 0xf3
        or byte [di + 0x45], 0x8
        push di
        push cs
        call RequestLineChange
        add sp, 0x2
.1:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StartFaceoffLineChange                                     2519:2468  94 PC
; Starts a line change for a player's team before a faceoff.
;
; Takes 2 words of stack arguments. Calls SetLCmode. Far routine (retf).
;-----------------------------------------------------------------------------
StartFaceoffLineChange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x8]
        and byte [si + 0x45], 0xf7
        push si
        push cs
        call SetLCmode
        add sp, 0x2
        test byte [si + 0x45], 0x8
        jz short .2
        test byte [si + 0x44], 0x40
        jz short .1
        mov bx, [bp + 0x6]
        mov word [bx + 0x28], 0x168
        mov ax, [si + 0x5e]
        mov [bx + 0x2c], ax
        pop si
        leave
        retf
.1:
        mov bx, [bp + 0x6]
        mov word [bx + 0x26], 0x258
        mov ax, [si + 0x5e]
        mov [bx + 0x2a], ax
.2:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Endfaceoff                                                 2519:24AA  94 PC
; Drops the puck: picks the faceoff winner from the centres' faceoff ratings and a random roll, then
; ends the faceoff.
;
; Takes 1 word of stack arguments. Calls StopJingle, PlaySoundEffect, randomd0, assreplace. Far
; routine (retf).
;-----------------------------------------------------------------------------
Endfaceoff:
        enter 0x4, 0x0
        push di
        push si
        call 0x0EDC:StopJingle
        push word 0xab
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        and byte [gmode2], 0xfa
        and byte [gmode], 0xfe
        mov bx, [bp + 0x6]
        and byte [bx + 0x45], 0xfe
        or byte [sflags3], 0x10
        mov bx, [fofdata2]
        mov al, [bx + Endfaceoff_ftab_m1]
        cbw
        mov bx, [fofdata_w2]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [bx + Endfaceoff_ftab_m1]
        cbw
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add ax, strict word 0x10
        mov [regd2], ax
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov word [bp - 0x2], sortobj0_position
        mov bx, [bp - 0x2]
.1:
        cmp word [bx], 0x4
        jz short .2
        inc di
        add bx, 0x80
        cmp bx, SortCords + 6 * 0x80 + 0x1a
        jc short .1
.2:
        mov [bp - 0x4], di
        mov di, 0x6
        mov bx, SortCords + 6 * 0x80 + 0x1a
.3:
        cmp word [bx], 0x4
        jz short .4
        inc di
        add bx, 0x80
        cmp bx, SortCords + 12 * 0x80 + 0x1a
        jc short .3
.4:
        mov bx, [bp - 0x4]
        shl bx, byte 0x7
        mov al, [bx + sortobj0_47]
        cbw
        imul bx, ax, 0x14
        mov es, [segWorkBuffer59]
        db 0x8B, 0xF7                           ; insn: mov si, di
        shl si, byte 0x7
        mov al, [si + sortobj0_47]
        cbw
        imul si, ax, 0x14
        mov al, [es:si + AwaySortObjs + 0x13]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x26, 0x8A, 0x8F, 0x13, 0x00         ; insn: mov cl, [es:bx + 0x13]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add [regd2], ax
        mov ax, 0x21
        call 0x0C11:randomd0
        cmp ax, [regd2]
        jnl short .5
        mov dx, [fofdata_w4]
        mov [lasttouch], di
        jmp short .6
.5:
        mov dx, [fofdata]
        mov ax, [bp - 0x4]
        mov [lasttouch], ax
.6:
        test dh, 0x8
        jz short .7
        mov ax, [fodir2]
        mov [regd3], ax
        mov word [regd4], 0xf800
        jmp short .8
        db 0x90
.7:
        mov ax, [fodir1]
        mov [regd3], ax
        mov word [regd4], 0x800
.8:
        mov ax, [regd3]
        mov [regd0], ax
        test al, 0x8
        jnz short .9
        and word [regd0], 0x7
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
.9:
        mov ax, 0x5
        call 0x0C11:randomd0
        sub al, 0x2
        and ax, strict word 0x7
        mov [regd0], ax
        cmp word [regd4], 0x0
        jnl short .10
        xor byte [regd0], 0x4
.10:
        mov si, [bp + 0x6]
        shl word [regd0], 1
        mov bx, [regd0]
        shl bx, 1
        mov ax, [bx + dirtab0]
        shl ax, byte 0x5
        mov [si + 0xc], ax
        mov bx, [regd0]
        shl bx, 1
        mov ax, [bx + dirtab_x]
        shl ax, byte 0x5
        add ax, [regd4]
        mov [si + 0xe], ax
        mov ax, 0x800
        call 0x0C11:randomd0
        mov [si + 0x10], ax
        mov bx, [puckz]
        mov word [bx], 0x0
        and byte [si + 0x44], 0xfb
        push 0x18
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        push 0x1f
        push word refstruct
        call 0x1E7E:assreplace
        add sp, 0x4
        cmp word [refXpos2], 0x0
        jng short .11
        mov ax, 0x500
        jmp short .12
        db 0x90
.11:
        mov ax, 0xfb00
.12:
        mov [refXvel], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; a2offsides                                                 2519:2642  94 PC
; Offside check for a player when the option is on: whistles when he is past the blue line ahead of
; the puck.
;
; Takes 1 word of stack arguments. Calls AddPenalty. Far routine (retf).
;-----------------------------------------------------------------------------
a2offsides:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        test byte [CrowdState], 0x2
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
.2:
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x80
        jnz short .3
        neg word [regd0]
.3:
        cmp word [regd0], 0x4e
        jl short .1
        mov bx, [si + 0x60]
        test byte [bx + 0x2a], 0x10
        jz short .1
        test byte [gmode], 0x10
        jnz short .1
        push 0x8
        push si
        call 0x327B:AddPenalty
        add sp, 0x4
        mov ax, 0x1
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ChkTwoLinePass                                             2519:2690  94 PC
; Returns 1 when a pass to the receiver crossed two lines (with the option on), else 0.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
ChkTwoLinePass:
        enter 0x2, 0x0
        push si
        test byte [gmode], 0x10
        jz short .1
        jmp near .11
.1:
        test byte [CrowdState], 0x8
        jz short .11
        mov si, [bp + 0x6]
        test byte [si + 0x45], 0x80
        jnz short .4
        mov bx, [pucky]
        cmp word [bx], 0x0
        jng short .2
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
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jnz short .11
.4:
        mov ax, [lasttouch]
        cmp [si + 0x5e], ax
        jz short .11
        cmp ax, strict word 0x6
        jnl short .5
        mov ax, 0x1
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        mov [bp - 0x2], ax
        cmp word [si + 0x5e], 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        xor ax, [bp - 0x2]
        jnz short .11
        test byte [si + 0x44], 0x80
        jnz short .9
        cmp word [lty], 0x4e
        jl short .11
        cmp word [si + 0x6], 0x0
        jng short .10
        jmp short .11
.9:
        cmp word [lty], -0x4e
        jg short .11
        cmp word [si + 0x6], 0x0
        jl short .11
.10:
        mov ax, 0x1
        pop si
        leave
        retf
        db 0x90
.11:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; a2touchpuck                                                2519:272A  94 PC
; A player touched the puck: records the touch and the assist candidates unless the touch is a two-
; line pass or a stoppage.
;
; Takes 1 word of stack arguments. Calls ChkTwoLinePass, a2offsides, AddPenalty. Far routine (retf).
;-----------------------------------------------------------------------------
a2touchpuck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        push si
        push cs
        call ChkTwoLinePass
        add sp, 0x2
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .1
        test byte [gmode], 0x1
        jnz short .1
        mov ax, [si + 0x2]
        mov [ltx], ax
        mov ax, [si + 0x6]
        mov [lty], ax
        mov ax, [si + 0x5e]
        mov [lasttouch], ax
.1:
        mov dx, [si + 0x60]
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cmp [bx + 0x1c], ax
        jz short .4
        test byte [bx + 0x2a], 0x8
        jz short .2
        and byte [bx + 0x2a], 0xf7
        jmp short .3
        db 0x90
.2:
        mov ax, [bx + 0x1e]
        mov [bx + 0x20], ax
        mov ax, [bx + 0x1c]
        mov [bx + 0x1e], ax
.3:
        mov al, [si + 0x47]
        cbw
        mov [bx + 0x1c], ax
        mov ax, [bx + 0x20]
        cmp [bx + 0x1c], ax
        jnz short .5
        mov byte [bx + 0x21], 0xff
        jmp short .5
        db 0x90
.4:
        test byte [bx + 0x2a], 0x8
        jz short .5
        and byte [bx + 0x2a], 0xf7
.5:
        cmp word [si + 0x1a], 0x0
        jz short .6
        and byte [gmode2], 0xef
.6:
        push si
        push cs
        call a2offsides
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .7
        push 0x17
        push si
        call 0x327B:AddPenalty
        add sp, 0x4
.7:
        test byte [iflags], 0x4
        jz short .8
        test byte [iflags], 0x1
        jz short .8
        cmp word [si + 0x1a], 0x0
        jz short .8
        mov al, [si + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        mov cl, [iflags]
        and cl, 0x2
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .8
        push 0x6
        mov al, [iflags_b1]
        cbw
        shl ax, byte 0x7
        add ax, SortCords
        push ax
        call 0x327B:AddPenalty
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.8:
        mov byte [iflags], 0x0
        mov al, [si + 0x5e]
        mov [iflags_b1], al
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        test byte [si + 0x44], 0x80
        jz short .9
        mov byte [iflags], 0x2
        neg word [regd0]
.9:
        cmp word [regd0], 0x0
        jl short .11
        mov ax, [hmtmap]
        sub ax, [awtmap]
        mov [regd0], ax
        test byte [si + 0x44], 0x40
        jz short .10
        neg word [regd0]
.10:
        cmp word [regd0], 0x0
        jl short .11
        or byte [iflags], 0x4
.11:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; assexit                                                    2519:285C  94 PC
; Steps assnum (mod 8) and sets the new-assignment bit.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
assexit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        mov al, [bx + 0x1c]
        inc al
        and ax, strict word 0x7
        mov [bx + 0x1c], ax
        or byte [bx + 0x44], 0x2
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; puckunflip                                                 2519:2874  94 PC
; SPAnum 4..11 flips facedir bit 1 back, restarts the animation.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
puckunflip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        cmp word [bx + 0x3a], 0x4
        jl short .1
        cmp word [bx + 0x3a], 0xc
        jnl short .1
        xor byte [bx + 0x36], 0x2
.1:
        or byte [bx + 0x36], 0x4
        mov word [bx + 0x3a], 0x0
        mov word [bx + 0x3c], 0xffff
        leave
        retf

;-----------------------------------------------------------------------------
; puckflip                                                   2519:289A  94 PC
; Flips the puck's animation; a puck moving too slowly is unflipped instead.
;
; Takes 1 word of stack arguments. Calls puckunflip, SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
puckflip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov ax, [si + 0xc]
        add ax, [si + 0xe]
        cmp ax, strict word 0x14
        jnl short .1
        push si
        push cs
        call puckunflip
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90
.1:
        mov al, [si + 0x36]
        mov cl, [regd0]
        and cx, 0x1
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x3
        mov [si + 0x36], ax
        mov word [si + 0x3c], 0xffff
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPApflip)
        call 0x2E42:SetSPA
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assrefatdot                                                2519:28DC  94 PC
; Referee assignment: holds the referee at the faceoff spot while play is stopped.
;
; Takes 1 word of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
assrefatdot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .7
        cmp word [injurystop], 0x0
        jnz short .7
        cmp word [gameclock], 0x0
        jnz short .1
        cmp word [clockticks], 0x0
        jz short .7
.1:
        test byte [si + 0x44], 0x2
        jz short .4
        and byte [si + 0x44], 0xfd
        cmp word [fox], 0x0
        jng short .2
        mov ax, 0x6
        jmp short .3
        db 0x90, 0x90
.2:
        mov ax, 0x2
.3:
        mov [si + 0x36], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPAreffowait)
        call 0x2E42:SetSPA
        and byte [si + 0x44], 0xfb
        and byte [si + 0x45], 0xdf
.4:
        test byte [gmode2], 0x1
        jnz short .7
        cmp word [fox], 0x0
        jng short .5
        mov ax, [fox]
        add ax, strict word 0xf
        jmp short .6
.5:
        mov ax, [fox]
        sub ax, strict word 0xf
.6:
        mov [si + 0x2], ax
        mov ax, [foy]
        mov [si + 0x6], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
.7:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assreffollow                                               2519:295E  94 PC
; Referee assignment: picks a spot by the puck's zone and skates the referee there.
;
; Takes 1 word of stack arguments. Calls doplayeracc, SetSPA, skateto. Far routine (retf).
;-----------------------------------------------------------------------------
assreffollow:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov al, [bx]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, byte 0x7
        add di, SortCords
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .19
.1:
        cmp word [gameclock], 0x0
        jnz short .2
        cmp word [clockticks], 0x0
        jnz short .2
        push 0x8
        push si
        call 0x2425:doplayeracc
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        test byte [si + 0x44], 0x2
        jz short .3
        and byte [si + 0x44], 0xfd
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
.3:
        mov bx, [puckx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x32
        jnl short .7
        mov bx, [pucky]
        mov ax, [bx]
        mov [bp - 0x2], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xac
        jng short .7
        mov ax, [bp - 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jnl short .7
        cmp word [si + 0x2], 0x0
        jng short .4
        mov ax, 0x46
        jmp short .5
        db 0x90
.4:
        mov ax, 0xffba
.5:
        mov [si + 0x2a], ax
        mov bx, [pucky]
        cmp word [bx], 0x0
        jng short .6
        mov ax, 0xed
        jmp near .17
        db 0x90
.6:
        mov ax, 0xff13
        jmp near .17
.7:
        mov bx, [pucky]
        mov ax, [bx]
        mov [bp - 0x2], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x62
        jng short .14
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .10
        cmp word [bp - 0x2], 0x0
        jnl short .8
        mov ax, 0x1
        jmp short .9
        db 0x90
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        mov cl, [di + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .14
.10:
        cmp word [si + 0x2], 0x0
        jng short .11
        mov ax, 0x78
        jmp short .12
        db 0x90
.11:
        mov ax, 0xff88
.12:
        mov [si + 0x2a], ax
        mov bx, [pucky]
        cmp word [bx], 0x0
        jng short .13
        mov ax, 0xe8
        jmp short .17
.13:
        mov ax, 0xff18
        jmp short .17
        db 0x90
.14:
        cmp word [si + 0x2], 0x0
        jng short .15
        mov ax, 0x90
        jmp short .16
        db 0x90
.15:
        mov ax, 0xff70
.16:
        mov [si + 0x2a], ax
        mov ax, [si + 0x6]
        sub ax, [camy]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x32
        jng short .18
        mov ax, [camy]
.17:
        mov [si + 0x2c], ax
.18:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push word 0x1b35
        push strict word EvadePlayersThunk
        push si
        call 0x2425:skateto
        add sp, 0x6
.19:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SkateToSpot                                                2519:2AB2  94 PC
; Skates a player to a spot and stops him there once he is within 8 in x and y.
;
; Takes 3 words of stack arguments. Calls skateto, SetSPA, VectorToDir8. Far routine (retf).
;-----------------------------------------------------------------------------
SkateToSpot:
        enter 0xe, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov ax, [regd0]
        sub ax, [si + 0x2]
        mov [bp - 0x6], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xa], ax
        mov cx, [regd1]
        sub cx, [si + 0x6]
        mov [bp - 0x8], cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x4], ax
        cmp cx, 0x8
        jnl short .1
        cmp ax, strict word 0x8
        jnl short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        mov ax, [regd0]
        mov [si + 0x2], ax
        mov ax, [regd1]
        mov [si + 0x6], ax
        pop si
        pop di
        leave
        retf
.1:
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x2], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cmp dx, 0x1e
        jg short .11
        cmp bx, 0xf2
        jl short .11
        cmp cx, 0xf2
        jnl short .11
        cmp word [si + 0x6], 0x0
        jl short .2
        mov ax, 0xfc
        jmp short .3
        db 0x90
.2:
        mov ax, 0xff04
.3:
        mov [regd1], ax
        cmp word [regd0], 0x0
        jl short .4
        mov ax, 0x28
        jmp short .5
.4:
        mov ax, 0xffd8
.5:
        mov [regd0], ax
        cmp word [si + 0xe], 0x0
        jng short .6
        mov ax, 0x1
        jmp short .7
        db 0x90
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.7:
        mov [bp - 0xc], ax
        cmp word [si + 0x6], 0x0
        jng short .8
        mov ax, 0x1
        jmp short .9
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        xor ax, [bp - 0xc]
        jnz short .10
        jmp near .25
.10:
        mov word [si + 0xe], 0x0
        jmp near .25
.11:
        cmp dx, 0x10
        jnl short .12
        jmp near .26
.12:
        cmp dx, 0x1e
        jng short .13
        jmp near .26
.13:
        cmp bx, 0xe8
        jnl short .14
        jmp near .26
.14:
        mov ax, [si + 0x6]
        xor ax, [regd1]
        jnl short .15
        jmp near .26
.15:
        cmp cx, 0xe8
        jl short .16
        jmp near .26
.16:
        cmp cx, 0xe0
        jng short .26
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jnl short .26
        cmp word [si + 0x6], 0x0
        jl short .17
        mov ax, 0xdc
        jmp short .18
        db 0x90, 0x90
.17:
        mov ax, 0xff24
.18:
        mov [regd1], ax
        cmp word [si + 0x2], 0x0
        jl short .19
        mov ax, 0x28
        jmp short .20
        db 0x90
.19:
        mov ax, 0xffd8
.20:
        mov [regd0], ax
        cmp word [si + 0x2], 0x0
        jng short .21
        mov ax, 0x1
        jmp short .22
        db 0x90
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        mov [bp - 0xe], ax
        cmp word [si + 0xc], 0x0
        jng short .23
        mov ax, 0x1
        jmp short .24
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        xor ax, [bp - 0xe]
        jz short .25
        mov word [si + 0xc], 0x0
.25:
        mov ax, [regd0]
        sub ax, [si + 0x2]
        mov [bp - 0x6], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xa], ax
        mov ax, [regd1]
        sub ax, [si + 0x6]
        mov [bp - 0x8], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x4], ax
.26:
        push word [bp + 0xa]
        push word [bp + 0x8]
        push si
        call 0x2425:skateto
        add sp, 0x6
        cmp word [bp - 0xa], 0x19
        jnl short .28
        cmp word [bp - 0x4], 0x19
        jnl short .28
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x9c4
        jng short .27
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sub [si + 0xc], ax
.27:
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x9c4
        jng short .28
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sub [si + 0xe], ax
.28:
        cmp word [si + 0x5e], 0x10
        jnz short .29
        mov di, SPAno(SPArefglide)
        mov word [bp - 0x2], SPAno(SPArefskate)
        jmp short .31
        db 0x90
.29:
        cmp word [si + 0x1a], 0x0
        jnz short .30
        mov di, 0x99
        mov word [bp - 0x2], SPAno(SPAgskate)
        jmp short .31
.30:
        mov di, SPAno(SPAglide)
        mov word [bp - 0x2], SPAno(SPAskate)
.31:
        cmp word [bp - 0xa], 0x8
        jl short .37
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x640
        jnl short .37
        cmp word [si + 0xc], 0x0
        jnz short .32
        cmp [si + 0x38], di
        jnz short .32
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [bp - 0x2]
        jmp short .33
        db 0x90
.32:
        cmp word [si + 0x38], 0x0
        jnz short .34
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x8B, 0xC7                           ; insn: mov ax, di
.33:
        call 0x2E42:SetSPA
.34:
        cmp word [bp - 0x6], 0x0
        jng short .35
        mov ax, 0x640
        jmp short .36
.35:
        mov ax, 0xf9c0
.36:
        mov [si + 0xc], ax
.37:
        cmp word [bp - 0x4], 0x8
        jl short .43
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x640
        jnl short .43
        cmp word [si + 0xc], 0x0
        jnz short .38
        cmp [si + 0x38], di
        jnz short .38
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [bp - 0x2]
        jmp short .39
        db 0x90
.38:
        cmp word [si + 0x38], 0x0
        jnz short .40
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xDE                           ; insn: mov bx, si
.39:
        call 0x2E42:SetSPA
.40:
        cmp word [bp - 0x8], 0x0
        jng short .41
        mov ax, 0x640
        jmp short .42
.41:
        mov ax, 0xf9c0
.42:
        mov [si + 0xe], ax
.43:
        mov ax, [regd0]
        sub ax, [si + 0x2]
        mov dx, [regd1]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        sub di, [si + 0x36]
        and di, 0x7
        db 0x8B, 0xC7                           ; insn: mov ax, di
        inc al
        and al, 0x7
        cmp al, 0x2
        jng short .46
        cmp byte [si + 0x29], 0x0
        jnz short .46
        cmp di, 0x5
        jl short .44
        mov ax, 0xffff
        jmp short .45
.44:
        mov ax, 0x1
.45:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.46:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CrowdOnStoppage                                            2519:2D8E  94 PC
; On a whistle, picks the crowd and music reaction from the call and the clock.
;
; Calls randomd0, LoadTeamPPV, CloseTextOverlay, PlayArenaJingle. Far routine (retf).
;-----------------------------------------------------------------------------
CrowdOnStoppage:
        push si
        test byte [gmode], 0x10
        jz short .1
        jmp near .14
.1:
        cmp word [ovltimer], -0x1
        jz short .2
        jmp near .14
.2:
        cmp word [RefPen], 0x17
        jz short .3
        cmp word [RefPen], 0x18
        jz short .3
        cmp word [RefPen], 0x3
        jz short .3
        cmp word [RefPen], 0x4
        jz short .3
        cmp word [RefPen], 0x8
        jz short .3
        cmp word [RefPen], 0x6
        jz short .3
        jmp near .14
.3:
        mov ax, [gameclock2]
        sar ax, 1
        cmp ax, [gameclock]
        jng short .4
        cmp word [gameclock], 0x3c
        jl short .4
        test byte [sflags3], 0x80
        jz short .4
        and byte [sflags3], 0x7f
        push 0x2
        jmp near .13
        db 0x90
.4:
        cmp word [gsp], 0x2
        jnz short .5
        mov ax, [gameclock]
        cmp [stoppagetime], ax
        jl short .5
        mov word [stoppagetime], 0xffff
        push 0x5
        jmp near .13
        db 0x90
.5:
        test byte [AnnouncerFlags], 0x1
        jz short .8
        cmp word [SoundOptions], 0x2
        jnz short .8
        mov si, [awtmap]
        sub si, [hmtmap]
        jz short .8
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .8
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .6
        mov ax, 0x4
        jmp short .7
        db 0x90
.6:
        mov ax, 0x1
.7:
        push ax
        jmp short .13
        db 0x90, 0x90
.8:
        mov ax, 0x8
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp word [demoflag], 0x0
        jnz short .10
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .10
        test byte [CrowdState], 0x80
        jz short .14
        test byte [SoundOptions], 0xa
        jz short .14
        cmp word [CrowdSound], 0x2bc
        jg short .14
        push si
        call 0x226F:LoadTeamPPV
.9:
        add sp, 0x2
        call 0x226F:CloseTextOverlay
        mov ax, 0x1
        pop si
        retf
.10:
        cmp word [demoflag], 0x0
        jnz short .11
        cmp si, 0x1
        jnz short .11
        push 0x2
        call 0x226F:LoadTeamPPV
        add sp, 0x2
        push 0x9
        call 0x0EDC:PlayArenaJingle
        jmp short .9
        db 0x90
.11:
        cmp si, 0x5
        jnl short .12
        lea ax, [si + 0x4]
        jmp short .7
.12:
        cmp si, 0x5
        jnz short .14
        push 0xb
.13:
        call 0x0EDC:PlayArenaJingle
        add sp, 0x2
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assrefwhistle                                              2519:2EC2  94 PC
; Referee assignment: on a stoppage starts the whistle timer and sends the puck and referee to their
; faceoff assignments.
;
; Takes 1 word of stack arguments. Calls PenShotAssign, SetSPA, CrowdOnStoppage, assreplace,
; SkateToSpot. Far routine (retf).
;-----------------------------------------------------------------------------
assrefwhistle:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .18
.1:
        test byte [si + 0x44], 0x2
        jnz short .2
        jmp near .7
.2:
        cmp word [injurystop], 0x0
        jz short .3
        jmp near .11
.3:
        cmp word [gameclock], 0x0
        jnz short .4
        cmp word [clockticks], 0x0
        jnz short .4
        jmp near .11
.4:
        cmp word [gsp], 0x3
        jnz short .5
        mov ax, [hmscore]
        cmp [awscore], ax
        jz short .5
        jmp near .11
.5:
        mov word [RefStep], 0x1
        and byte [si + 0x44], 0xfd
        call 0x2164:PenShotAssign
        mov word [si + 0x28], 0x8
        mov word [si + 0x2c], 0x0
        mov word [si + 0x2a], 0xa0
        mov word [si + 0x26], 0x0
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        push cs
        call CrowdOnStoppage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        jmp near .18
.6:
        cmp word [ovltimer], 0x100
        jnz short .7
        mov word [ovltimer], 0x258
.7:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x6
        jng short .8
        jmp near .17
.8:
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        cmp ax, strict word 0xfff6
        jnl short .9
        jmp near .17
.9:
        dec word [si + 0x26]
        js short .10
        jmp near .18
.10:
        add word [si + 0x26], 0x8
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        mov word [regd2], 0x2
        mov word [regd2_w2], 0x0
        mov ax, [regd2]
        cmp [si + 0x36], ax
        jz short .16
        mov al, [regd2]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .14
        mov ax, 0xffff
        jmp short .15
.11:
        mov word [RefStep], 0xffff
        cmp word [ovltimer], 0x100
        jnz short .12
        mov word [ovltimer], 0x258
.12:
        push 0x1b
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
        push 0x1e
.13:
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90
.14:
        mov ax, 0x1
.15:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.16:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        mov ax, [regd2]
        cmp [si + 0x36], ax
        jnz short .18
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefpointgoa)
        call 0x2E42:SetSPA
        push 0x22
        jmp short .13
.17:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        push cs
        call SkateToSpot
        add sp, 0x6
.18:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assrefsignal                                               2519:303C  94 PC
; Referee assignment: skates to the timekeeper side and signals; after a goal posts the goal event.
;
; Takes 1 word of stack arguments. Calls PostGoalEvent, assreplace, SetSPA, skateto. Far routine
; (retf).
;-----------------------------------------------------------------------------
assrefsignal:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .22
.1:
        test byte [si + 0x44], 0x2
        jnz short .2
        jmp near .15
.2:
        and byte [si + 0x44], 0xfd
        mov bx, [RefPen]
        shl bx, 1
        cmp word [bx + refsigdir], 0x0
        jl short .3
        jmp near .14
.3:
        cmp word [RefPen], 0x7
        jz short .4
        jmp near .13
.4:
        mov bx, [pucky]
        cmp word [bx], 0x0
        jnl short .5
        mov ax, 0x1
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        mov cl, [gmode]
        and cl, 0x2
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        mov [bp - 0x8], cx
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .7
        mov di, awshots
        jmp short .8
        db 0x90
.7:
        mov di, hmshots
.8:
        mov ax, [gameclock2]
        sub ax, [gameclock]
        mov [bp - 0x2], ax
        cmp word [di + 0x20], 0x0
        jl short .9
        mov ax, [di + 0x20]
        mov [bp - 0x6], ax
        jmp short .10
        db 0x90
.9:
        mov word [bp - 0x6], 0xffff
.10:
        cmp word [di + 0x1e], 0x0
        jl short .11
        mov ax, [di + 0x1e]
        mov [bp - 0x4], ax
        jmp short .12
        db 0x90
.11:
        mov word [bp - 0x4], 0xffff
.12:
        mov ax, [bp - 0x2]
        mov cx, 0x3c
        cwd
        idiv cx
        push dx
        mov ax, [bp - 0x2]
        cwd
        idiv cx
        push ax
        push word [GoalState]
        push word [bp - 0x6]
        push word [bp - 0x4]
        push word [di + 0x1c]
        push word [bp - 0x8]
        call 0x2352:PostGoalEvent
        add sp, 0xe
.13:
        push 0x21
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90
.14:
        mov word [si + 0x28], 0x8
        mov word [si + 0x2c], 0x0
        mov word [si + 0x2a], 0xa0
        mov word [si + 0x26], 0x0
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
.15:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .16
        jmp near .21
.16:
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        cmp ax, strict word 0xffec
        jl short .21
        dec word [si + 0x26]
        js short .17
        jmp near .22
.17:
        add word [si + 0x26], 0x8
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        mov bx, [RefPen]
        shl bx, 1
        mov ax, [bx + refsigdir]
        mov [regd2], ax
        cmp ax, [si + 0x36]
        jz short .20
        mov al, [regd2]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .18
        mov ax, 0xffff
        jmp short .19
.18:
        mov ax, 0x1
.19:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
.20:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        mov ax, [regd2]
        cmp [si + 0x36], ax
        jnz short .22
        or byte [si + 0x44], 0x20
        mov bx, [RefPen]
        shl bx, 1
        mov ax, [bx + refsigspa_m2]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        jmp near .13
.21:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
.22:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; assrefgoalpa                                               2519:31E4  94 PC
; Referee assignment: after a goal, has the announcer call the scorer and assists.
;
; Takes 1 word of stack arguments. Calls SetSPA, PaGoal, assreplace, PenShotAssign,
; QueueGoalieNote, CrowdOnStoppage, ChkScorerMilestone, VectorToDir8 and others. Far routine (retf).
;-----------------------------------------------------------------------------
assrefgoalpa:
        enter 0xe, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x20
        jz short .1
        jmp near .52
.1:
        cmp word [ovlseq], 0x2
        jnz short .2
        jmp near .14
.2:
        cmp word [ovlseq], 0x0
        jnz short .3
        jmp near .14
.3:
        cmp word [ovltimer], 0x0
        jnl short .4
        jmp near .14
.4:
        cmp word [ovltimer], 0x100
        jl short .5
        jmp near .14
.5:
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        cmp word [ovltimer], 0xec
        jnl short .6
        jmp near .52
.6:
        cmp byte [goalevent], 0x1
        jz short .7
        jmp near .52
.7:
        mov al, [goalevent_b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0xa], ax
        mov al, [goalevent_b2]
        mov [bp - 0x2], ax
        mov al, [goalevent_b3]
        mov [bp - 0x4], ax
        mov cl, [goalevent_text]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        mov [bp - 0x8], cx
        mov word [bp - 0xc], 0x0
        cmp ax, 0xff
        jz short .8
        mov word [bp - 0xc], 0x1
.8:
        cmp cx, 0xff
        jz short .9
        inc word [bp - 0xc]
.9:
        cmp word [bp - 0xa], 0x0
        jz short .10
        mov ax, [VisTeamNum]
        jmp short .11
.10:
        mov ax, [HomeTeamNum]
.11:
        mov [bp - 0x6], ax
        cmp ax, strict word 0x18
        jl short .12
        inc ax
        inc ax
        mov [bp - 0x6], ax
.12:
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        imul ax, [bp - 0xa], 0x1c
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [bp - 0x8]
        imul bx, ax, 0x28
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, [bp - 0x4]
        imul bx, cx, 0x28
        mov cl, [bx + hmrosterjersey]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        push cx
        add ax, [bp - 0x2]
        imul bx, ax, 0x28
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bp - 0xc]
        mov bx, [bp - 0x6]
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0EDC:PaGoal
        add sp, 0xa
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
        mov byte [goalevent], 0xff
        cmp word [gsp], 0x3
        jnl short .13
        jmp near .52
.13:
        mov word [ovltimer], 0x38
        pop si
        pop di
        leave
        retf
.14:
        cmp byte [PenBuf], 0x0
        jz short .15
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        mov word [RefStep], 0xffff
        pop si
        pop di
        leave
        retf
        db 0x90
.15:
        mov bx, [puckx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xa0
        jg short .16
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x112
        jng short .19
.16:
        push 0x24
.17:
        push word [bp + 0x6]
.18:
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90
.19:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x2
        jnz short .20
        jmp near .27
.20:
        cmp word [injurystop], 0x0
        jnz short .22
        cmp word [gameclock], 0x0
        jnz short .21
        cmp word [clockticks], 0x0
        jz short .22
.21:
        cmp word [gsp], 0x3
        jnz short .24
        mov ax, [hmscore]
        cmp [awscore], ax
        jz short .24
.22:
        mov word [RefStep], 0xffff
        cmp word [ovltimer], 0x100
        jnz short .23
        mov word [ovltimer], 0x258
.23:
        push 0x1b
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
        push 0x1e
        jmp short .17
.24:
        mov word [RefStep], 0x1
        and byte [bx + 0x44], 0xfd
        call 0x2164:PenShotAssign
        mov bx, [bp + 0x6]
        mov word [bx + 0x28], 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0x26], ax
        mov [bx + 0x2e], ax
        or byte [bx + 0x45], 0x20
        mov [bx + 0x30], ax
        mov [bx + 0x32], ax
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        cmp word [RefPen], 0x4
        jnz short .30
        call 0x2352:QueueGoalieNote
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .26
.25:
        push cs
        call CrowdOnStoppage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .26
        jmp near .52
.26:
        cmp word [ovltimer], 0x100
        jnz short .27
        mov word [ovltimer], 0x258
.27:
        cmp word [deferpending], 0x0
        jz short .28
        jmp near .52
.28:
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .29
        mov byte [bx], 0xff
        push 0x1a
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
.29:
        mov bx, [bp + 0x6]
        cmp word [bx + 0x2e], 0x258
        jng short .32
        mov si, [puckc]
        mov byte [si], 0x10
        mov si, [puckvx]
        mov word [si], 0x0
        mov si, [puckvy]
        mov word [si], 0x0
        mov si, [puckvz]
        mov word [si], 0x0
        mov si, [puckz]
        mov word [si], 0x64
        push 0x22
        push bx
        jmp near .18
        db 0x90, 0x90
.30:
        cmp word [RefPen], 0x7
        jnz short .25
        test byte [gmode], 0x10
        jz short .31
        mov word [exitgame], 0x1
        pop si
        pop di
        leave
        retf
.31:
        call 0x2352:ChkScorerMilestone
        jmp near .26
.32:
        mov bx, [puckx]
        mov ax, [bx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x6
        jnz short .37
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xf0
        jnz short .37
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], cx
        mov si, [pucky]
        cmp word [si], 0x0
        jl short .33
        mov ax, 0xe3
        jmp short .34
.33:
        mov ax, 0xff1d
.34:
        mov bx, [bp + 0x6]
        mov [bx + 0x2c], ax
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2]
        sub ax, [bx + 0x2a]
        mov [regd0], ax
        mov si, [pucky]
        cmp word [si], 0x0
        jl short .35
        mov ax, 0xee
        jmp short .36
        db 0x90
.35:
        mov ax, 0xff12
.36:
        sub ax, [bx + 0x6]
        neg ax
        jmp near .42
        db 0x90
.37:
        mov bx, [puckvx]
        mov ax, [bx]
        sar ax, byte 0x7
        mov bx, [puckx]
        add ax, [bx]
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], ax
        mov si, [puckvy]
        mov ax, [si]
        sar ax, byte 0x7
        mov si, [pucky]
        add ax, [si]
        mov [bx + 0x2c], ax
        mov si, [puckvx]
        mov ax, [si]
        mov si, [puckvy]
        mov dx, [si]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2]
        mov si, [puckx]
        sub ax, [si]
        mov dx, [bx + 0x6]
        mov bx, [pucky]
        sub dx, [bx]
        call 0x0D5F:VectorToDir8
        mov [regd1], ax
        cmp word [regd0], 0x7
        jg short .38
        cmp ax, strict word 0x7
        jg short .38
        mov ax, [regd0]
        cmp [regd1], ax
        jnz short .39
.38:
        mov bx, [puckx]
        mov ax, [bx]
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], ax
        mov si, [pucky]
        mov ax, [si]
        mov [bx + 0x2c], ax
.39:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2c]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sub ax, 0xe8
        mov si, [pucky]
        mov dx, [si]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        sub dx, 0xe8
        db 0x33, 0xC2                           ; insn: xor ax, dx
        jnl short .40
        mov ax, 0xe8
        db 0x2B, 0xC6                           ; insn: sub ax, si
        mov dx, [bx + 0x2a]
        mov di, [puckx]
        sub dx, [di]
        mov [bp - 0xe], cx
        call 0x03A3:ImulRegs
        mov bx, [bp - 0xe]
        db 0x2B, 0xDE                           ; insn: sub bx, si
        call 0x03A3:IdivWords.regs
        add ax, [di]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x19
        jnl short .40
        mov bx, [puckx]
        mov ax, [bx]
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], ax
        mov si, [pucky]
        mov ax, [si]
        mov [bx + 0x2c], ax
.40:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2c]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xe8
        mov si, [pucky]
        mov dx, [si]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        add dx, 0xe8
        db 0x33, 0xC2                           ; insn: xor ax, dx
        jnl short .41
        mov ax, 0xff18
        db 0x2B, 0xC6                           ; insn: sub ax, si
        mov dx, [bx + 0x2a]
        mov di, [puckx]
        sub dx, [di]
        mov [bp - 0xe], cx
        call 0x03A3:ImulRegs
        mov bx, [bp - 0xe]
        db 0x2B, 0xDE                           ; insn: sub bx, si
        call 0x03A3:IdivWords.regs
        add ax, [di]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x19
        jnl short .41
        mov bx, [puckx]
        mov ax, [bx]
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], ax
        mov si, [pucky]
        mov ax, [si]
        mov [bx + 0x2c], ax
.41:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x2]
        mov si, [puckx]
        sub ax, [si]
        mov [regd0], ax
        mov ax, [bx + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
.42:
        mov [regd1], ax
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .43
        jmp near .51
.43:
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .44
        jmp near .51
.44:
        mov bx, [puckx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x6
        jnz short .45
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xf0
        jnz short .45
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xe8
        jng short .45
        jmp near .51
.45:
        mov bx, [bp + 0x6]
        dec word [bx + 0x26]
        js short .46
        jmp near .52
.46:
        mov bx, [bp + 0x6]
        add word [bx + 0x26], 0x8
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        mov bx, [puckx]
        mov ax, [bx]
        mov bx, [bp + 0x6]
        sub ax, [bx + 0x2]
        mov si, [pucky]
        mov dx, [si]
        sub dx, [bx + 0x6]
        call 0x0D5F:VectorToDir8
        mov [regd2], ax
        cmp ax, strict word 0x8
        jnl short .49
        mov bx, [bp + 0x6]
        sub ax, [bx + 0x36]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        inc al
        and al, 0x7
        cmp al, 0x2
        jng short .49
        and cx, 0x7
        mov [regd2], cx
        cmp cx, 0x5
        jl short .47
        mov ax, 0xffff
        jmp short .48
        db 0x90
.47:
        mov ax, 0x1
.48:
        add al, [bx + 0x36]
        and ax, strict word 0x7
        mov [bx + 0x36], ax
        jmp short .51
.49:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp + 0x6]
        mov [bx + 0xe], ax
        mov [bx + 0xc], ax
        mov si, [puckc]
        mov byte [si], 0x10
        mov si, [puckvx]
        mov [si], ax
        mov si, [puckvy]
        mov [si], ax
        mov si, [puckvz]
        mov [si], ax
        mov si, [puckz]
        mov word [si], 0xff9c
        cmp word [regd2], 0x8
        jnl short .50
        mov ax, [regd2]
        mov [bx + 0x36], ax
.50:
        mov bx, [bp + 0x6]
        or byte [bx + 0x44], 0x20
        mov ax, SPAno(SPArefpickup)
        call 0x2E42:SetSPA
        push 0x22
        jmp near .17
        db 0x90
.51:
        mov bx, [bp + 0x6]
        inc word [bx + 0x2e]
        mov ax, [bx + 0x2a]
        mov [regd0], ax
        mov ax, [bx + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push bx
        push cs
        call SkateToSpot
        add sp, 0x6
.52:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; assrefdrop                                                 2519:3762  94 PC
; Referee assignment: skates to the faceoff spot and holds the puck for the drop.
;
; Takes 1 word of stack arguments. Calls SetSPA, ImulRegs, PaSpeechBusy, assreplace, SkateToSpot. Far
; routine (retf).
;-----------------------------------------------------------------------------
assrefdrop:
        enter 0x4, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .16
.1:
        test byte [si + 0x44], 0x2
        jz short .4
        and byte [si + 0x44], 0xfd
        mov word [si + 0x28], 0x8
        mov word [si + 0x26], 0x0
        cmp word [fox], 0x0
        jng short .2
        mov ax, [fox]
        add ax, strict word 0xf
        jmp short .3
        db 0x90
.2:
        mov ax, [fox]
        sub ax, strict word 0xf
.3:
        mov [si + 0x2a], ax
        mov ax, [foy]
        mov [si + 0x2c], ax
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
        mov bx, [puckc]
        mov byte [bx], 0x10
        mov bx, [puckvx]
        mov [bx], ax
        mov bx, [puckvy]
        mov [bx], ax
        mov bx, [puckvz]
        mov [bx], ax
        mov bx, [puckz]
        mov word [bx], 0xff9c
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
.4:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [si + 0x2a]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0x4], di
        mov [bp - 0x2], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0x4]
        adc dx, [bp - 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .5
        jmp near .15
.5:
        jl short .6
        cmp ax, strict word 0x40
        jc short .6
        jmp near .15
.6:
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jl short .7
        jmp near .15
.7:
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jl short .8
        jmp near .15
.8:
        mov ax, [si + 0x2a]
        mov [si + 0x2], ax
        mov ax, [si + 0x2c]
        mov [si + 0x6], ax
        dec word [si + 0x26]
        js short .9
        jmp near .16
.9:
        add word [si + 0x26], 0x8
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        cmp word [fox], 0x0
        jng short .10
        mov ax, 0x6
        jmp short .11
        db 0x90
.10:
        mov ax, 0x2
.11:
        cwd
        mov [regd2], ax
        mov [regd2_w2], dx
        cmp [si + 0x36], ax
        jz short .14
        mov al, [regd2]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .12
        mov ax, 0xffff
        jmp short .13
.12:
        mov ax, 0x1
.13:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
        pop si
        pop di
        leave
        retf
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        call 0x0EDC:PaSpeechBusy
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .16
        cmp word [ovlseq], -0x1
        jnz short .16
        mov word [RefStep], 0xffff
        push 0x1e
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90
.15:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        push cs
        call SkateToSpot
        add sp, 0x6
.16:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; assrefgoalline                                             2519:38EC  94 PC
; Referee assignment: skates beside the net on the puck's end and holds there.
;
; Takes 1 word of stack arguments. Calls SetSPA, VectorToDir8, assreplace, SkateToSpot. Far routine
; (retf).
;-----------------------------------------------------------------------------
assrefgoalline:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .14
.1:
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        mov word [si + 0x28], 0x8
        mov word [si + 0x26], 0x0
        mov bx, [pucky]
        cmp word [bx], 0x0
        jng short .2
        mov ax, 0xe6
        jmp short .3
.2:
        mov ax, 0xff1a
.3:
        mov [si + 0x2c], ax
        cmp word [si + 0x2], 0x0
        jng short .4
        mov ax, 0x32
        jmp short .5
        db 0x90
.4:
        mov ax, 0xffce
.5:
        mov [si + 0x2a], ax
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
.6:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .7
        jmp near .13
.7:
        mov ax, [si + 0x2c]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jng short .8
        jmp near .13
.8:
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jg short .13
        dec word [si + 0x26]
        js short .9
        jmp near .14
.9:
        add word [si + 0x26], 0x8
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefglide)
        call 0x2E42:SetSPA
        mov ax, [si + 0x2]
        neg ax
        mov dx, [si + 0x2c]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        cwd
        mov [regd2], ax
        mov [regd2_w2], dx
        cmp [si + 0x36], ax
        jz short .12
        mov al, [regd2]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .10
        mov ax, 0xffff
        jmp short .11
        db 0x90
.10:
        mov ax, 0x1
.11:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
        pop si
        leave
        retf
        db 0x90
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, SPAno(SPArefpointgoa)
        call 0x2E42:SetSPA
        push 0x20
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf
.13:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        push cs
        call SkateToSpot
        add sp, 0x6
.14:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; rtss                                                       2519:3A1E  94 PC
; Assignment table entry 0: the empty assignment, returns at once.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
rtss:
        retf
        db 0x90
