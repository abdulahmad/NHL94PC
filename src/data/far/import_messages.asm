; Far data, paragraph 3821h, 96 bytes: messages for importing databases. The EXE's own code does not use it
; (the overlays probably do).
        db 'Importing Master Databases.'
        db 0x00, 0x00, 0x00, '!8Error while exporting player!'
        db 0x00, 'Player not exported!'
        db 0x00, 0x20, 0x00, '!8>', 0x00
        db '!8', 0x00, 0x00, 0x00, 0x00, 0x00
