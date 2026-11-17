; Far data, paragraph 3821h, 96 bytes: messages for importing databases. The EXE's own code does not use it
; (the overlays probably do).
        db 'Importing Master Databases.'
        db 0x00
msgImportingMasterDatabases:                    ; message list of 1 far string pointer: 'Importing Master
                                                ; Databases.'; used by LP
        db 0x00, 0x00, '!8Error while exporting player!'
        db 0x00, 'Player not exported!'
        db 0x00
msgErrorWhileExportingPlayerPlayer:             ; message list of 2 far string pointers: 'Error while
                                                ; exporting player! / Player not exported!'; used by LP
        db 0x20, 0x00, '!8>', 0x00
        db '!8', 0x00, 0x00, 0x00, 0x00, 0x00
