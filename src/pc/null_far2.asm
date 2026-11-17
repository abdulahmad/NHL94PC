; NullFar2: a far return the start-up code calls.
        db 0xC4
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        pop dx
        call 0x03A3:MulRegs
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; NullFar2                                                    0C15:000E  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar2:
        retf
        db 0x90
