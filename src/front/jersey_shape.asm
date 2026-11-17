; Builds a jersey number shape from the digit glyphs (MENUS.OVL)
; The first bytes finish the last routine of alert_box.asm.
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; BlitJerseyDigit                                            2397:0006  94 PC
; One jersey digit.
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
BlitJerseyDigit:
        enter 0x2, 0x0
        push di
        push si
        mov cx, [bp + 0xa]
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        shl ax, byte 0x4
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov [bp - 0x2], ax
        mov di, [bp + 0x6]
.1:
        mov bx, [bp - 0x2]
        cmp byte [bx + si + 0xdd0], 0x0
        jz short .2
        mov al, [bp + 0xc]
        mov es, [bp + 0x8]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
.2:
        inc si
        cmp si, 0xf
        jl short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MakeJerseyShape                                            2397:0040  94 PC
; Jersey with its number.
;
; Takes 6 words of stack arguments. Calls BlitJerseyDigit.
;-----------------------------------------------------------------------------
MakeJerseyShape:
        enter 0x4, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0x6]
        mov es, [bp + 0x8]
.1:
        mov al, [bp + 0xe]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
        inc si
        cmp si, 0x23
        jl short .1
        mov si, [bp + 0xa]
        cmp si, 0xa
        jnc short .2
        mov al, [bp + 0xe]
        push ax
        mov al, [bp + 0xc]
        push ax
        push si
        lea ax, [di + 0xa]
        push word [bp + 0x8]
        jmp short .3
        db 0x90
.2:
        mov al, [bp + 0xe]
        push ax
        mov cl, [bp + 0xc]
        push cx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov bx, 0xa
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div bx
        push ax
        mov ax, [bp + 0x8]
        push ax
        push di
        mov [bp - 0x4], di
        mov [bp - 0x2], ax
        push cs
        call BlitJerseyDigit
        add sp, 0xa
        mov al, [bp + 0xe]
        push ax
        mov al, [bp + 0xc]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0x14
        push dx
.3:
        push ax
        push cs
        call BlitJerseyDigit
        add sp, 0xa
