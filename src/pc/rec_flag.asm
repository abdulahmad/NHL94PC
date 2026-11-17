; RecFlag returns the word at offset 18h of a far
; record. NullFar is the retf _main calls. The last two bytes are
; another retf and a nop.

;-----------------------------------------------------------------------------
; RecFlag                                                     0837:0000  94 PC
; Returns the word at offset 18h of the far record.
;-----------------------------------------------------------------------------
RecFlag:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        les bx, [bp + 6]
        mov ax, es:[bx + 0x18]
        leave
        retf
;-----------------------------------------------------------------------------
; NullFar                                                     0837:000C  94 PC
; A lone retf. _main calls it.
;-----------------------------------------------------------------------------
NullFar:
        retf
        nop
        retf
        nop
