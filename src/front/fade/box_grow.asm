; Growing box fade (FADES10.OVL)

;-----------------------------------------------------------------------------
; FadeSampleRect                                             3358:0000  94 PC
; Clips a rectangle to the fade area and samples its centre pixel.
;
; Takes 4 words of stack arguments. Calls GetPixel. Far routine (retf).
;-----------------------------------------------------------------------------
FadeSampleRect:
        enter 0x2, 0x0
        push di
        push si
        mov cx, [bp + 0x6]
        mov si, [bp + 0x8]
        mov dx, [bp + 0xa]
        db 0x03, 0xD1                           ; insn: add dx, cx
        dec dx
        mov di, [bp + 0xc]
        db 0x03, 0xFE                           ; insn: add di, si
        dec di
        cmp [fadex], cx
        jng short .1
        mov ax, [fadex]
        mov [bp + 0x6], ax
.1:
        cmp [fadew], si
        jng short .2
        mov si, [fadew]
.2:
        mov [bp - 0x2], dx
        cmp [fadey], dx
        jg short .3
        mov ax, [fadey]
        dec ax
        mov [bp - 0x2], ax
.3:
        cmp [fadeh], di
        jg short .4
        mov di, [fadeh]
        dec di
.4:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x03, 0xC6                           ; insn: add ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push si
        mov ax, [bp - 0x2]
        add ax, [bp + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp + 0x6], ax
        push ax
        call 0x0FEF:GetPixel
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; FadeBoxGrow                                                3358:0070  94 PC
; Filled boxes grow from the centre.
;
; Takes 1 word of stack arguments. Calls UseCurrentPage, FadeSampleRect, UseOtherPage, FillRectClipped,
; WaitDeadlineNoEoi, CopyPageRect. Far routine (retf).
;-----------------------------------------------------------------------------
FadeBoxGrow:
        enter 0x22, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        mov es, [segDgroup24]
        mov ax, [es:ClipRightX]
        mov [fadey], ax
        mov cx, [es:ClipTopY]
        mov [fadew], cx
        mov dx, [es:ClipBottomY]
        mov [fadeh], dx
        mov bx, [es:ClipLeftX]
        mov [fadex], bx
        db 0x03, 0xC3                           ; insn: add ax, bx
        inc ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x18], ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add ax, [fadeh]
        inc ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x1a], ax
        mov ax, [es:VenetianRowBytes]
        inc ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x1c], ax
        mov ax, [fadeh]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x1e], ax
        cmp word [bp + 0x6], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x8
        add ah, 0x1
        mov [bp - 0xe], ax
        mov word [bp - 0x16], 0x6
.1:
        mov ax, 0xa
        cwd
        call 0x03A3:SetDeadline.regs
        mov ax, [bp - 0xe]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [bp - 0x1c]
        dec ax
        cwd
        idiv cx
        shl ax, 1
        mov [bp - 0x14], ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        add ax, [bp - 0x1e]
        dec ax
        cwd
        idiv di
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        db 0x0B, 0xF6                           ; insn: or si, si
        jg short .2
        jmp near .8
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        imul di
        sub ax, [bp - 0x1a]
        neg ax
        mov [bp - 0x10], ax
        mov [bp - 0x12], si
        mov [bp - 0x8], di
.3:
        mov bx, [bp - 0x14]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .7
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        imul word [bp - 0xe]
        sub ax, [bp - 0x18]
        neg ax
        mov [bp - 0x6], ax
        mov ax, [bp - 0x10]
        mov [bp - 0x4], ax
        mov [bp - 0xa], bx
        mov si, [bp - 0xe]
.4:
        mov di, [bp - 0x6]
        cmp word [bp + 0x6], 0x0
        jnz short .5
        push word [bp - 0x8]
        push si
        push word [bp - 0x4]
        push di
        push cs
        call FadeSampleRect
        add sp, 0x8
        mov [bp - 0x2], ax
        jmp short .6
.5:
        call 0x0FEF:UseOtherPage
        push word [bp - 0x8]
        push si
        push word [bp - 0x4]
        push di
        push cs
        call FadeSampleRect
        add sp, 0x8
        mov [bp - 0x2], ax
        call 0x0FEF:UseCurrentPage
.6:
        push word [bp - 0x2]
        push word [bp - 0x8]
        push si
        push word [bp - 0x4]
        push di
        call 0x0FEF:FillRectClipped
        add sp, 0xa
        add [bp - 0x6], si
        dec word [bp - 0xa]
        jnz short .4
.7:
        mov ax, [bp - 0x8]
        add [bp - 0x10], ax
        dec word [bp - 0x12]
        jz short .8
        jmp near .3
.8:
        call 0x03A3:WaitDeadlineNoEoi
        cmp word [bp + 0x6], 0x0
        jnz short .9
        shl word [bp - 0xe], 1
        jmp short .10
        db 0x90
.9:
        mov cx, 0x2
        mov ax, [bp - 0xe]
        cwd
        idiv cx
        mov [bp - 0xe], ax
.10:
        dec word [bp - 0x16]
        jz short .11
        jmp near .1
.11:
        cmp word [bp + 0x6], 0x1
        jnz short .12
        push 0x0
        mov ax, [fadeh]
        sub ax, [fadew]
        push ax
        mov es, [segDgroup24]
        push word [es:VenetianRowBytes]
        push word [fadew]
        push word [fadex]
        cmp word [CurPage], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        push ax
        call 0x0FEF:CopyPageRect
        add sp, 0xc
.12:
        pop si
        pop di
        leave
        retf
        db 0x90
