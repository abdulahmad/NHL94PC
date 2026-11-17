; Sliding strips fade (FADES6.OVL)

;-----------------------------------------------------------------------------
; FadeSlideStrips                                            3358:0000  94 PC
; Alternate 8-pixel strips slide in.
;
; Takes 1 word of stack arguments. Calls UseCurrentPage, CopyFadeRect, WaitDeadlineNoEoi. Far routine
; (retf).
;-----------------------------------------------------------------------------
FadeSlideStrips:
        enter 0xe, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        mov es, [segDgroup19]
        mov ax, [es:ClipLeftX]
        mov [fadex], ax
        mov ax, [es:ClipRightX]
        mov [fadey], ax
        mov ax, [es:ClipTopY]
        mov [fadew], ax
        mov ax, [es:ClipBottomY]
        mov [fadeh], ax
        cmp word [bp + 0x6], 0x0
        jz short .1
        jmp near .8
.1:
        sub ax, [fadew]
        add ax, strict word 0x4
        mov cx, 0x5
        cwd
        idiv cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [es:VenetianRowBytes]
        add ax, strict word 0x7
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl ax, byte 0x3
        add ax, [fadex]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jg short .2
        jmp near .14
.2:
        mov word [bp - 0x4], 0x0
        sub ax, strict word 0x8
        mov [bp - 0x6], ax
        mov [bp - 0x8], bx
        mov [bp - 0x2], si
.3:
        mov ax, 0x1
        cwd
        call 0x03A3:SetDeadline.regs
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [bp - 0x2], di
        jng short .7
        db 0x2B, 0xF6                           ; insn: sub si, si
.4:
        push 0x5
        push 0x8
        push si
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .5
        mov ax, [bp - 0x6]
        jmp short .6
        db 0x90
.5:
        mov ax, [bp - 0x4]
.6:
        push ax
        call 0x3349:CopyFadeRect
        add sp, 0x8
        add si, 0x5
        inc di
        cmp [bp - 0x2], di
        jg short .4
.7:
        call 0x03A3:WaitDeadlineNoEoi
        add word [bp - 0x4], 0x8
        sub word [bp - 0x6], 0x8
        dec word [bp - 0x8]
        jnz short .3
        pop si
        pop di
        leave
        retf
        db 0x90
.8:
        mov ax, [es:VenetianRowBytes]
        add ax, strict word 0x7
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [fadeh]
        sub ax, [fadew]
        add ax, strict word 0x4
        mov cx, 0x5
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl ax, byte 0x2
        db 0x03, 0xC3                           ; insn: add ax, bx
        add ax, [fadew]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .14
        mov word [bp - 0x4], 0x0
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov [bp - 0x6], ax
        mov [bp - 0x8], bx
        mov [bp - 0x2], si
.9:
        mov ax, 0x1
        cwd
        call 0x03A3:SetDeadline.regs
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [bp - 0x2], di
        jng short .13
        db 0x2B, 0xF6                           ; insn: sub si, si
.10:
        push 0x5
        push 0x8
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .11
        mov ax, [bp - 0x6]
        jmp short .12
        db 0x90
.11:
        mov ax, [bp - 0x4]
.12:
        push ax
        push si
        call 0x3349:CopyFadeRect
        add sp, 0x8
        add si, 0x8
        inc di
        cmp [bp - 0x2], di
        jg short .10
.13:
        call 0x03A3:WaitDeadlineNoEoi
        add word [bp - 0x4], 0x5
        sub word [bp - 0x6], 0x5
        dec word [bp - 0x8]
        jnz short .9
.14:
        pop si
        pop di
        leave
        retf
