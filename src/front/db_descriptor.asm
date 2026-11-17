; UseDbDescriptor: points the record routines at one database file description.

;-----------------------------------------------------------------------------
; UseDbDescriptor                                             0F97:0000  94 PC
; Pushes the far descriptor of the database set (0, 1 or 2) for the overlay
; call that follows.
;-----------------------------------------------------------------------------
UseDbDescriptor:
        mov ax, [DbSaveMode]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        dec ax
        jz short .2
        dec ax
        jz short .3
        retf
.1:
        push word 0x3415                        ; segment of the db files far data
        push strict word 0x0
        db 0xEB, 0x0E                           ; insn: jmp short 0x24
.2:
        push word 0x3415                        ; segment of the db files far data
        push strict word 0x62
        db 0xEB, 0x06                           ; insn: jmp short 0x24
.3:
        db 0x68, 0x15
