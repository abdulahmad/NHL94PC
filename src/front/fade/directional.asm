; Directional sweep fade (FADES11.OVL)

;-----------------------------------------------------------------------------
; FadeDirectional                                            3358:0000  94 PC
; Sweep in one of eight directions.
;
; Takes 1 word of stack arguments. Calls UseCurrentPage, CopyFadeRect, WaitDeadlineNoEoi. Far routine
; (retf).
;-----------------------------------------------------------------------------
FadeDirectional:
        enter 0x20, 0x0
        push di
        push si
        cmp word [bp + 0x6], 0x0
        jnl short .1
        jmp near .26
.1:
        cmp word [bp + 0x6], 0x7
        jng short .2
        jmp near .26
.2:
        call 0x0FEF:UseCurrentPage
        mov es, [segDgroup25]
        mov ax, [es:ClipLeftX]
        mov [fadex], ax
        mov ax, [es:ClipRightX]
        mov [fadey], ax
        mov ax, [es:ClipTopY]
        mov [fadew], ax
        mov cx, [es:ClipBottomY]
        mov [fadeh], cx
        mov dx, [es:VenetianRowBytes]
        mov [bp - 0x1e], dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x2B, 0xF8                           ; insn: sub di, ax
        cmp word [bp + 0x6], 0x0
        jnz short .3
        mov ax, [fadex]
        mov [bp - 0xc], ax
        mov [bp - 0x4], ax
        mov ax, [fadey]
        mov [bp - 0xe], ax
        mov [bp - 0x8], ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov word [bp - 0x12], 0xfffb
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x14], ax
        jmp short .4
        db 0x90
.3:
        cmp word [bp + 0x6], 0x1
        jnz short .5
        mov ax, [fadex]
        mov [bp - 0xc], ax
        mov [bp - 0x4], ax
        mov ax, [fadey]
        mov [bp - 0xe], ax
        mov [bp - 0x8], ax
        mov ax, [fadew]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov word [bp - 0x14], 0x5
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x12], ax
.4:
        mov [bp - 0x18], ax
        mov [bp - 0x1a], ax
        lea ax, [di + 0x4]
        jmp near .13
        db 0x90
.5:
        cmp word [bp + 0x6], 0x2
        jnz short .7
        mov bx, [fadey]
        mov [bp - 0x8], bx
        mov [bp - 0xc], bx
        mov [bp - 0x4], bx
        mov ax, [fadew]
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov ax, [fadeh]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov word [bp - 0x1a], 0xfff8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        mov [bp - 0x18], ax
.6:
        mov ax, [bp - 0x1e]
        add ax, strict word 0x7
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x1c], ax
        mov [bp - 0xe], bx
        jmp near .15
.7:
        cmp word [bp + 0x6], 0x3
        jnz short .8
        mov bx, [fadex]
        mov [bp - 0x8], bx
        mov [bp - 0xc], bx
        mov [bp - 0x4], bx
        mov ax, [fadew]
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov ax, [fadeh]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov word [bp - 0x18], 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        mov [bp - 0x1a], ax
        jmp short .6
        db 0x90
.8:
        cmp word [bp + 0x6], 0x4
        jnz short .9
        mov ax, [fadey]
        add ax, [fadex]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        and bl, 0xf8
        mov [bp - 0x4], bx
        mov [bp - 0xe], bx
        mov [bp - 0x8], bx
        mov ax, [fadew]
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov ax, [fadeh]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov word [bp - 0x1a], 0xfff8
        mov word [bp - 0x18], 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        mov ax, [bp - 0x1e]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x7
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0x1c], ax
        mov [bp - 0xc], bx
        jmp near .15
.9:
        cmp word [bp + 0x6], 0x5
        jnz short .10
        mov ax, [fadey]
        mov [bp - 0xc], ax
        mov [bp - 0x4], ax
        mov ax, [fadex]
        mov [bp - 0xe], ax
        mov [bp - 0x8], ax
        mov ax, [fadew]
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov ax, [fadeh]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov word [bp - 0x1a], 0xfff8
        mov word [bp - 0x18], 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        mov ax, [bp - 0x1e]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x7
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        jmp short .14
        db 0x90
.10:
        cmp word [bp + 0x6], 0x6
        jnz short .11
        mov ax, [fadex]
        mov [bp - 0xc], ax
        mov [bp - 0x4], ax
        mov ax, [fadey]
        mov [bp - 0xe], ax
        mov [bp - 0x8], ax
        mov ax, [fadeh]
        add ax, [fadew]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        jmp short .12
.11:
        cmp word [bp + 0x6], 0x7
        jnz short .15
        mov ax, [fadex]
        mov [bp - 0xc], ax
        mov [bp - 0x4], ax
        mov ax, [fadey]
        mov [bp - 0xe], ax
        mov [bp - 0x8], ax
        mov ax, [fadeh]
        mov [bp - 0x10], ax
        mov [bp - 0x6], ax
        mov ax, [fadew]
        mov [bp - 0x16], ax
        mov [bp - 0xa], ax
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x18], ax
        mov [bp - 0x1a], ax
        mov word [bp - 0x12], 0xfffb
        mov word [bp - 0x14], 0x5
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x4
.13:
        mov cx, 0x5
        cwd
        idiv cx
.14:
        mov [bp - 0x1c], ax
.15:
        mov word [bp - 0x2], 0x0
        cmp word [bp - 0x1c], 0x0
        jg short .16
        jmp near .26
.16:
        mov si, [bp - 0x4]
        mov di, [bp - 0x6]
.17:
        cmp word [bp + 0x6], 0x3
        jg short .18
        mov ax, [bp - 0x2]
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .19
.18:
        mov ax, 0x1
        cwd
        call 0x03A3:SetDeadline.regs
.19:
        cmp word [bp - 0x1a], 0x0
        jz short .20
        mov ax, [bp - 0x1a]
        add [bp - 0xc], ax
        mov ax, [bp - 0xa]
        db 0x2B, 0xC7                           ; insn: sub ax, di
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [bp - 0xc]
        push ax
        push di
        push word [bp - 0xc]
        call 0x3349:CopyFadeRect
        add sp, 0x8
        mov si, [bp - 0xc]
.20:
        cmp word [bp - 0x18], 0x0
        jz short .21
        mov ax, [bp - 0xa]
        db 0x2B, 0xC7                           ; insn: sub ax, di
        push ax
        mov ax, [bp - 0x18]
        add [bp - 0xe], ax
        mov ax, [bp - 0xe]
        sub ax, [bp - 0x8]
        push ax
        push di
        push word [bp - 0x8]
        call 0x3349:CopyFadeRect
        add sp, 0x8
        mov ax, [bp - 0xe]
        mov [bp - 0x8], ax
.21:
        cmp word [bp - 0x12], 0x0
        jz short .22
        mov ax, [bp - 0x12]
        add [bp - 0x10], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [bp - 0x10]
        push ax
        mov ax, [bp - 0x8]
        db 0x2B, 0xC6                           ; insn: sub ax, si
        push ax
        push word [bp - 0x10]
        push si
        call 0x3349:CopyFadeRect
        add sp, 0x8
        mov di, [bp - 0x10]
.22:
        cmp word [bp - 0x14], 0x0
        jz short .23
        mov ax, [bp - 0x14]
        add [bp - 0x16], ax
        mov ax, [bp - 0x16]
        sub ax, [bp - 0xa]
        push ax
        mov ax, [bp - 0x8]
        db 0x2B, 0xC6                           ; insn: sub ax, si
        push ax
        push word [bp - 0xa]
        push si
        call 0x3349:CopyFadeRect
        add sp, 0x8
        mov ax, [bp - 0x16]
        mov [bp - 0xa], ax
.23:
        cmp word [bp + 0x6], 0x3
        jg short .24
        mov ax, [bp - 0x2]
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .25
.24:
        call 0x03A3:WaitDeadlineNoEoi
.25:
        mov ax, [bp - 0x1c]
        inc word [bp - 0x2]
        cmp [bp - 0x2], ax
        jnl short .26
        jmp near .17
.26:
        pop si
        pop di
        leave
        retf
        db 0x90
