; DrawFrame: draws a rectangular frame.

;-----------------------------------------------------------------------------
; NullFar8                                                    1484:0000  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar8:
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; DrawFrame                                                   1484:0004  94 PC
; Draws a rectangle outline with four FillRectClip calls.
;-----------------------------------------------------------------------------
DrawFrame:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        mov di, [bp + 0xc]
        db 0x2B, 0xFE                           ; insn: sub di, si
        mov ax, [bp + 0xa]
        sub ax, [bp + 0x6]
        inc ax
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .1
        push word [bp + 0xe]
        push 0x1
        push ax
        push si
        push word [bp + 0x6]
        call 0x0FEF:FillRectClip
        add sp, 0xa
        push word [bp + 0xe]
        push 0x1
        push word [bp - 0x2]
        push word [bp + 0xc]
        push word [bp + 0x6]
        call 0x0FEF:FillRectClip
        add sp, 0xa
.1:
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short DrawFrameTail + 0x70
        push word [bp + 0xe]
        push di
        push 0x1
        push si
        push word [bp + 0x6]
        call 0x0FEF:FillRectClip
        add sp, 0xa
        push word [bp + 0xe]
        push di
        push 0x1
        push si
        push word [bp + 0xa]
        call 0x0FEF:FillRectClip
        add sp, 0xa
