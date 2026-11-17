; Venetian blind fade (FADES1.OVL)

;-----------------------------------------------------------------------------
; FadeVenetian                                               3358:0000  94 PC
; Copies every eighth row, eight passes.
;
; Takes 1 word of stack arguments. Calls UseCurrentPage, CopyPageRect, WaitDeadlineNoEoi. Far routine
; (retf).
;-----------------------------------------------------------------------------
FadeVenetian:
        enter 0x30, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        cmp word [bp + 0x6], 0x0
        jz short .1
        jmp near .6
.1:
        mov ax, DGROUP
        mov es, ax
        mov ax, [es:VenetianRowBytes]
        mov [bp - 0xa], ax
        mov bx, [es:ClipBottomY]
        lea ax, [bx + 0x7]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x8], 0x0
        mov [bp - 0x1e], bx
        mov [bp - 0xc], si
.2:
        mov di, [bp - 0xc]
        mov ax, 0x3
        cwd
        call 0x03A3:SetDeadline.regs
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .5
        mov dx, [bp - 0x8]
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov [bp - 0x4], cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
.3:
        db 0x8B, 0xCE                           ; insn: mov cx, si
        cmp cx, [bp - 0x1e]
        jnl short .4
        push 0x0
        push 0x1
        push word [bp - 0xa]
        push cx
        push 0x0
        cmp word [CurPage], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        push ax
        call 0x0FEF:CopyPageRect
        add sp, 0xc
.4:
        add si, 0x8
        dec di
        jnz short .3
.5:
        call 0x03A3:WaitDeadlineNoEoi
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x8
        jl short .2
        pop si
        pop di
        leave
        retf
.6:
        mov es, [segDgroup12]
        mov ax, [es:ClipTopY]
        mov [bp - 0x28], ax
        mov ax, [es:ClipBottomY]
        mov [bp - 0x1e], ax
        mov cx, [es:CanvasRowBytes]
        mov [bp - 0x4], cx
        mov es, [segDgroup13]
        cmp word [CurPage], 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        neg bx
        shl bx, byte 0x2
        les bx, [es:bx + 0x7570]
        mov cx, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x2c], cx
        mov [bp - 0x2a], dx
        mov es, [segDgroup13]
        mov bx, [CurPage]
        shl bx, byte 0x2
        les bx, [es:bx + 0x7570]
        mov cx, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x30], cx
        mov [bp - 0x2e], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
.7:
        mov ax, 0x1
        cwd
        call 0x03A3:SetDeadline.regs
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        idiv cx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov dx, 0x3cf
        out dx, al
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov ax, 0x1
        db 0x8A, 0xCB                           ; insn: mov cl, bl
        shl ax, cl
        mov dx, 0x3c5
        out dx, al
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [bp - 0x2c]
        mov dx, [bp - 0x2a]
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        add cx, [bp - 0x30]
        mov ax, [bp - 0x2e]
        mov [bp - 0x1a], cx
        mov [bp - 0x18], ax
        mov di, [bp - 0x28]
        cmp di, [bp - 0x1e]
        jnl short .12
        mov [bp - 0x8], si
        mov ax, [bp - 0x1e]
        db 0x2B, 0xC7                           ; insn: sub ax, di
        mov [bp - 0x12], ax
        mov si, [bp - 0x16]
.8:
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        cmp [bp - 0x4], cx
        jng short .11
        mov di, [bp - 0x1a]
        mov ds, [bp - 0x14]
.9:
        mov al, [si]
        mov es, [bp - 0x18]
        mov [es:di], al
        mov ax, [bp - 0x4]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cmp ax, strict word 0x4
        jng short .10
        mov ax, 0x4
.10:
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x03, 0xF8                           ; insn: add di, ax
        mov dx, [bp - 0x18]
        db 0x03, 0xC8                           ; insn: add cx, ax
        cmp cx, [bp - 0x4]
        jl short .9
        mov [bp - 0x1a], di
        mov ax, DGROUP
        mov ds, ax
.11:
        dec word [bp - 0x12]
        jnz short .8
        mov si, [bp - 0x8]
.12:
        call 0x03A3:WaitDeadlineNoEoi
        inc si
        cmp si, 0x10
        jnl short .13
        jmp near .7
.13:
        pop si
        pop di
        leave
        retf
