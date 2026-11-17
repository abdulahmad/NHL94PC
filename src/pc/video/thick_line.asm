; DrawThickLine: draws a line several pixels wide.
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawThickLine                                               1491:0002  94 PC
; Builds a quad around a line from Atan2 and AngleTab.
;-----------------------------------------------------------------------------
DrawThickLine:
        enter 0x10, 0x0
        push di
        push si
        mov ax, [bp + 0xc]
        sub ax, [bp + 0x8]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sar ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        mov ax, [bp + 0xa]
        sub ax, [bp + 0x6]
        push ax
        call 0x03A3:Atan2
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x03A3:CosLookup.regs
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        neg dx
        mov ax, [bp + 0x10]
        call 0x03A3:Mul16k.regs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        call 0x03A3:AngleTab
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [bp + 0x10]
        call 0x03A3:Mul16k.regs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sar di, 1
        db 0x8B, 0xCF                           ; insn: mov cx, di
        add di, [bp + 0x6]
        mov [bp - 0x10], di
        db 0x8B, 0xD6                           ; insn: mov dx, si
        sar dx, byte 0x4
        db 0x8B, 0xDE                           ; insn: mov bx, si
        sar bx, byte 0x2
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        db 0x03, 0xF2                           ; insn: add si, dx
        db 0x8B, 0xD6                           ; insn: mov dx, si
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sar dx, 1
        db 0x8B, 0xF2                           ; insn: mov si, dx
        add dx, [bp + 0x8]
        mov [bp - 0xe], dx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        add cx, [bp + 0xa]
        mov [bp - 0xc], cx
        db 0x8B, 0xCE                           ; insn: mov cx, si
        add si, [bp + 0xc]
        mov [bp - 0xa], si
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub ax, [bp + 0xa]
        neg ax
        mov [bp - 0x8], ax
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        sub bx, [bp + 0xc]
        neg bx
        mov [bp - 0x6], bx
        sub dx, [bp + 0x6]
        neg dx
        mov [bp - 0x4], dx
        sub cx, [bp + 0x8]
        neg cx
        mov [bp - 0x2], cx
        lea ax, [bp - 0x10]
        push ax
        push 0x4
        push word [bp + 0xe]
        call 0x03A3:FillFlag0
        add sp, 0x6
        pop si
        pop di
