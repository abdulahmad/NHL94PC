; Allocates a drawing canvas (linear or planar).
        db 0x08, 0x15
        add sp, 0x8
        retf

;-----------------------------------------------------------------------------
; AllocLinearCanvas                                           152D:0006  94 PC
; Allocates w*h+30h bytes and fills a linear canvas record.
;-----------------------------------------------------------------------------
AllocLinearCanvas:
        enter 0x18, 0x0
        push bx
        push dx
        push ax
        push di
        push si
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        cwd
        push dx
        push ax
        mov si, [bp - 0x1e]
        push 0x0
        push si
        call 0x0000:__aFlmul
        add ax, strict word 0x30
        adc dx, 0x0
        push word [bp - 0x1a]
        push dx
        push ax
        push word 0x740a
        mov [bp - 0x10], ax
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bp - 0x10]
        add ax, [es:bx]
        mov dx, [es:bx + 0x2]
        sub ax, strict word 0x1e
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        push 0x0
        push 0x12
        push dx
        push word [es:bx]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov [bp - 0x18], bx
        mov [bp - 0x16], es
        call 0x03A3:FillFarZero
        add sp, 0x8
        les bx, [bp - 0x18]
        les bx, [es:bx]
        mov [es:bx], si
        mov [es:bx + 0x2], di
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, es
        les bx, [bp - 0x14]
        mov word [es:bx + 0x16], 0x0
        mov dx, [es:bx + 0x16]
        mov [es:bx + 0x10], dx
        mov [es:bx + 0x1a], dx
        mov [es:bx + 0xc], dx
        mov [es:bx + 0x18], si
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov [es:bx + 0x14], dx
        mov [es:bx + 0x1c], dx
        mov [es:bx + 0xe], dx
        mov [es:bx + 0x12], di
        mov [es:bx], ax
        mov [es:bx + 0x2], cx
        mov ax, [BufPtr]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x8], si
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov es, [bp - 0xa]
.1:
        cmp [ChainIdx], bx
        jna short .4
        mov cx, [bx]
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jl short .2
        cmp word [bx + 0x2], 0x0
        jz short .2
        cmp word [bx + 0x4], 0x10
        jnz short .2
        mov ax, [bx + 0x6]
        db 0x2B, 0xC6                           ; insn: sub ax, si
        cmp ax, strict word 0x10
        jz short .3
.2:
        inc cx
        inc cx
        shl cx, 1
        db 0x03, 0xD9                           ; insn: add bx, cx
        jmp short .1
.3:
        inc word [bx + 0x2]
        mov si, [bp - 0xc]
        lea ax, [bx + 0x4]
        mov [es:si + 0xa], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, es
        jmp near .13
.4:
        mov cx, [BufPtr]
        mov dx, [ChainIdx]
        mov di, [bp - 0x1c]
.5:
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jnc short .12
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov bx, [bx]
        db 0x3B, 0xDF                           ; insn: cmp bx, di
        jl short .6
        db 0x8B, 0xF1                           ; insn: mov si, cx
        cmp word [si + 0x2], 0x0
        jz short .7
.6:
        lea ax, [bx + 0x2]
        shl ax, 1
        db 0x03, 0xC8                           ; insn: add cx, ax
        jmp short .5
.7:
        lea ax, [di + 0x4]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jg short .8
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x2B, 0xC7                           ; insn: sub ax, di
        dec ax
        dec ax
        db 0x8B, 0xF7                           ; insn: mov si, di
        shl si, 1
        db 0x03, 0xF1                           ; insn: add si, cx
        mov [si + 0x4], ax
        mov word [si + 0x6], 0x0
        jmp short .9
.8:
        db 0x8B, 0xFB                           ; insn: mov di, bx
.9:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov [bx], di
        mov word [bx + 0x2], 0x1
        add bx, 0x4
        mov si, [bp - 0xc]
        mov [es:si + 0xa], bx
        mov si, 0x10
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov word [bp - 0x6], 0x0
        mov [bp - 0x1c], di
        mov [bp - 0x2], cx
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov bx, [bp - 0x6]
        mov di, [bp - 0x2]
        mov dx, [bp - 0x8]
        jmp short .11
.10:
        inc di
        inc di
        mov [di - 0x2], cx
        db 0x03, 0xCA                           ; insn: add cx, dx
        inc bx
.11:
        cmp [bp - 0x1c], bx
        jg short .10
        mov ax, [bp - 0xc]
        mov dx, [bp - 0xa]
        jmp short .13
.12:
        push word 0x7416
        call 0x0F4A:FatalError
        pop bx
.13:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AllocCanvas                                                 152D:019C  94 PC
; Allocates a planar canvas (width/4 per plane) and fills its record.
;-----------------------------------------------------------------------------
AllocCanvas:
        enter 0x1c, 0x0
        push ax
        push di
        push si
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov [bp - 0x6], si
        push bx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        add di, 0x3
        sar di, byte 0x2
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mul si
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        neg ax
        and ax, strict word 0xf
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0xe], cx
        mov cl, 0x2
        mov [bp - 0x10], bx
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        call 0x0000:__aFlshl
        add ax, strict word 0x2e
        adc dx, 0x0
        push dx
        push ax
        push word 0x754e
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov cl, 0x2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov cl, 0x2
        mov [bp - 0x18], bx
        mov [bp - 0x16], ax
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        add ax, strict word 0x4
        adc dx, 0x0
        call 0x0000:__aFlshl
        push word [bp - 0x16]
        push word [bp - 0x18]
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        call 0x03A3:FarToLinear
        add sp, 0x4
        add ax, [bp - 0x1c]
        adc dx, [bp - 0x1a]
        call 0x03A3:LinearToFarRegs
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        push 0x0
        push 0x10
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x03A3:FillFarZero
        add sp, 0x8
        les bx, [bp - 0x18]
        mov [es:bx], di
        mov [es:bx + 0x2], si
        mov ax, [bp - 0x10]
        shl ax, byte 0xc
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        xor ax, [es:bx + 0xe]
        and ah, 0xf
        db 0x33, 0xC8                           ; insn: xor cx, ax
        mov [es:bx + 0xe], cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        les bx, [bp - 0xc]
        mov [es:bx + 0x10], ax
        mov [es:bx + 0x1a], ax
        mov [es:bx + 0xc], ax
        mov [es:bx + 0x14], di
        mov [es:bx + 0xe], di
        mov ax, [bp - 0x1e]
        mov [es:bx + 0x18], ax
        mov [es:bx + 0x1c], ax
        mov [es:bx + 0x12], si
        mov ax, [bp - 0x10]
        mov [es:bx + 0x16], ax
        mov ax, [bp - 0x18]
        mov dx, [bp - 0x16]
        mov [es:bx], ax
        mov [es:bx + 0x2], dx
        push dx
        push ax
        call 0x03A3:FarToLinear
        mov cl, 0x4
        add sp, 0x4
        call 0x0000:__aFlsar
        mov [bp - 0x4], ax
        mov ax, [bp - 0xe]
        shr ax, byte 0x4
        add [bp - 0x4], ax
        mov cx, [bp - 0x4]
        les bx, [bp - 0xc]
        mov [es:bx + 0x4], cx
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov [es:bx + 0x6], cx
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov [bp - 0x4], cx
        mov [es:bx + 0x8], cx
        mov ax, [BufPtr]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [ChainIdx]
        mov [bp - 0x8], di
.1:
        db 0x3B, 0xD9                           ; insn: cmp bx, cx
        jnc short .4
        mov dx, [bx]
        cmp dx, [bp - 0x6]
        jc short .2
        cmp word [bx + 0x2], 0x0
        jz short .2
        cmp word [bx + 0x4], 0x10
        jnz short .2
        mov ax, [bx + 0x6]
        db 0x2B, 0xC7                           ; insn: sub ax, di
        cmp ax, strict word 0x10
        jz short .3
.2:
        inc dx
        inc dx
        shl dx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        jmp short .1
.3:
        inc word [bx + 0x2]
        mov di, [bp - 0xc]
        lea ax, [bx + 0x4]
        mov [es:di + 0xa], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov dx, es
        jmp short .13
.4:
        mov bx, [BufPtr]
        mov di, [bp - 0x6]
.5:
        db 0x3B, 0xD9                           ; insn: cmp bx, cx
        jnc short .12
        mov dx, [bx]
        db 0x3B, 0xD7                           ; insn: cmp dx, di
        jc short .6
        cmp word [bx + 0x2], 0x0
        jz short .7
.6:
        inc dx
        inc dx
        shl dx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        jmp short .5
.7:
        lea ax, [di + 0x4]
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        ja short .8
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x2B, 0xC7                           ; insn: sub ax, di
        dec ax
        dec ax
        db 0x8B, 0xF7                           ; insn: mov si, di
        shl si, 1
        db 0x03, 0xF3                           ; insn: add si, bx
        mov [si + 0x4], ax
        mov word [si + 0x6], 0x0
        jmp short .9
.8:
        db 0x8B, 0xFA                           ; insn: mov di, dx
.9:
        mov [bx], di
        mov word [bx + 0x2], 0x1
        lea ax, [bx + 0x4]
        mov si, [bp - 0xc]
        mov [es:si + 0xa], ax
        mov cx, 0x10
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov word [bp - 0x4], 0x0
        mov dx, [bp - 0x4]
        mov [bp - 0x6], di
        jmp short .11
.10:
        inc bx
        inc bx
        mov [bx - 0x2], cx
        add cx, [bp - 0x8]
        inc dx
.11:
        db 0x3B, 0xFA                           ; insn: cmp di, dx
        ja short .10
        mov ax, [bp - 0xc]
        mov dx, [bp - 0xa]
        jmp short .13
.12:
        push word 0x7559
        call 0x0F4A:FatalError
        pop bx
.13:
        pop si
        pop di
        leave
        retf
