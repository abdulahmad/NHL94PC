; NullFar2: a far return the start-up code calls. The first bytes finish randomd0 from the segment before.

;-----------------------------------------------------------------------------
; RandomTail                                                  0C15:0000  94 PC
; End of randomd0: the high word times the range is the result.
;-----------------------------------------------------------------------------
RandomTail:                                     ; end of randomd0
        db 0xC4                                 ; the rest of mov al, ah from the segment before
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
