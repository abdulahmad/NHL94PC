; DrawTextCenteredClip: draws a string centred and clipped.
        db 0x90, 0x90

;-----------------------------------------------------------------------------
; DrawTextCenteredClip                                        1567:0002  94 PC
; Centres a string between the clip left and right.
;-----------------------------------------------------------------------------
DrawTextCenteredClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        push di
        call 0x03A3:TextWidthAll
        pop bx
        mov es, [DgroupSegE]
        mov si, [es:ClipRightX]
        db 0x2B, 0xF0                           ; insn: sub si, ax
        sub si, [es:ClipLeftX]
        sar si, 1
        add si, [es:ClipLeftX]
        push word [bp + 0x8]
        lea ax, [si + 0x1]
        push ax
        push di
