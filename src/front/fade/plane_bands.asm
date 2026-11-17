; Plane by plane band fade (FADES3.OVL)

;-----------------------------------------------------------------------------
; FadePlaneBands                                             3358:0000  94 PC
; Plane-by-plane bands from a pattern table.
;
; Takes 2 words of stack arguments. Calls UseCurrentPage, WaitDeadlineNoEoi. Far routine (retf).
;-----------------------------------------------------------------------------
FadePlaneBands:
        enter 0x46, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        mov es, [segDgroup16]
        mov ax, [es:ClipBottomY]
        mov [bp - 0x3c], ax
        mov di, [es:CanvasRowBytes]
        mov es, [segDgroup17]
        cmp word [CurPage], 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        neg bx
        shl bx, byte 0x2
        les bx, [es:bx + PageTable]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x40], ax
        mov [bp - 0x3e], dx
        mov es, [segDgroup17]
        mov bx, [CurPage]
        shl bx, byte 0x2
        les bx, [es:bx + PageTable]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x44], ax
        mov [bp - 0x42], dx
        cmp word [bp + 0x6], 0x4
        jnz short .1
        mov dx, 0x4
        mov cx, 0x3
        mov bx, 0x62dc
        mov word [bp - 0x2c], 0x62e0
        jmp short .2
.1:
        mov dx, 0x8
        mov cx, 0x7
        mov bx, 0x62cc
        mov word [bp - 0x2c], 0x62d4
.2:
        mov [bp - 0x2a], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jg short .3
        jmp near .14
.3:
        mov [bp - 0x32], bx
        mov [bp - 0x30], cx
        mov [bp - 0x20], di
.4:
        mov ax, [bp + 0x8]
        cwd
        call 0x03A3:SetDeadline.regs
        mov ax, [bp - 0x2a]
        mov [bp - 0x24], ax
        mov word [bp - 0x22], 0xb
.5:
        mov bx, [bp - 0x22]
        mov al, [bx + PlaneBandPattern]
        cbw
        mov [bp - 0x28], ax
        imul word [bp - 0x20]
        mov [bp - 0x26], ax
        mov ax, [bp - 0x24]
        mov [bp - 0x1c], ax
        mov word [bp - 0x1e], 0x3
.6:
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x1e]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, 0x3cf
        out dx, al
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov ax, 0x1
        shl ax, cl
        mov dx, 0x3c5
        out dx, al
        mov ax, [bp - 0x26]
        mov [bp - 0x18], ax
        mov bx, [bp - 0x28]
        mov di, [bp - 0x3c]
        db 0x3B, 0xDF                           ; insn: cmp bx, di
        jl short .7
        jmp near .11
.7:
        mov ax, [bp - 0x20]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        mov [bp - 0x46], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        add ax, strict word 0xb
        mov cx, 0xc
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        mov [bp - 0x1a], ax
.8:
        mov ax, [bp - 0x40]
        mov dx, [bp - 0x3e]
        add ax, [bp - 0x18]
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        mov ax, [bp - 0x44]
        mov dx, [bp - 0x42]
        add ax, [bp - 0x18]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, [bp - 0x20]
        mov [bp - 0xa], ax
        mov cx, [bp - 0x1c]
        mov [bp - 0xc], cx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .10
.9:
        mov ax, [bp - 0x30]
        and [bp - 0xc], ax
        mov bx, [bp - 0xc]
        mov si, [bp - 0x32]
        mov al, [bx + si]
        cbw
        sub [bp - 0xa], ax
        cmp word [bp - 0xa], 0x0
        jng short .10
        add [bp - 0x10], ax
        les bx, [bp - 0x10]
        mov cl, [es:bx]
        add [bp - 0x14], ax
        les si, [bp - 0x14]
        mov [es:si], cl
        mov bx, [bp - 0xc]
        mov di, [bp - 0x2c]
        mov al, [bx + di]
        cbw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [bp - 0x10]
        mov dx, [bp - 0xe]
        mov [bp - 0x10], ax
        db 0x03, 0xF1                           ; insn: add si, cx
        mov [bp - 0x14], si
        mov [bp - 0x12], es
        sub [bp - 0xa], cx
        inc word [bp - 0xc]
        cmp word [bp - 0xa], 0x0
        jg short .9
.10:
        mov ax, [bp - 0x46]
        add [bp - 0x18], ax
        inc word [bp - 0x1c]
        dec word [bp - 0x1a]
        jz short .11
        jmp near .8
.11:
        dec word [bp - 0x1e]
        js short .12
        jmp near .6
.12:
        inc word [bp - 0x24]
        dec word [bp - 0x22]
        js short .13
        jmp near .5
.13:
        call 0x03A3:WaitDeadlineNoEoi
        dec word [bp - 0x2a]
        jz short .14
        jmp near .4
.14:
        pop si
        pop di
        leave
        retf
        db 0x90
