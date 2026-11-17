; Far data, paragraph 3821h, 96 bytes: messages for importing databases. The EXE's own code does not use it
; (the overlays probably do).
        db 'Importing Master Databases.'
        db 0x00
f_3821_001C:                                    ; used by LP (to name)
        db 0x00, 0x00, '!8Error while exporting player!'
        db 0x00, 'Player not exported!'
        db 0x00
f_3821_0053:                                    ; used by LP (to name)
        db 0x20, 0x00, '!8>', 0x00
        db '!8', 0x00, 0x00, 0x00, 0x00, 0x00
