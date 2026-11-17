; DrawTextCenteredInWindow: draws a string centred in a window rectangle.

;-----------------------------------------------------------------------------
; NullFar7                                                    0FEC:0000  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar7:
        leave
        retf

;-----------------------------------------------------------------------------
; DrawTextCenteredInWindow                                    0FEC:0002  94 PC
; X centred between the window's left and right edges.
;-----------------------------------------------------------------------------
DrawTextCenteredInWindow:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        push di
        call 0x03A3:TextWidthAll
        pop bx
        mov es, [DgroupSegC]
        mov si, [es:ClipRightX]
        db 0x2B, 0xF0                           ; insn: sub si, ax
        sub si, [es:ClipLeftX]
        sar si, 1
        add si, [es:ClipLeftX]
        push word [bp + 0x8]
        lea ax, [si + 0x1]
        push ax
        push di
