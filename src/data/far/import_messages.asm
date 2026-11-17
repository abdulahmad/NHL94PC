; Far data, paragraph 3821h, 96 bytes: messages for importing databases. The EXE's own code does not use it
; (the overlays probably do).
str_ImportingMasterDatabases:                   ; string 'Importing Master Databases.'
        db 'Importing Master Databases.', 0x00
msgImportingMasterDatabases:                    ; message list of 1 far string pointer: 'Importing Master
                                                ; Databases.'; used by LP
        dw str_ImportingMasterDatabases, 0x3821
str_ErrorWhileExportingPlayer:                  ; string 'Error while exporting player!'
        db 'Error while exporting player!', 0x00
str_PlayerNotExported:                          ; string 'Player not exported!'
        db 'Player not exported!', 0x00
msgErrorWhileExportingPlayerPlayer:             ; message list of 2 far string pointers: 'Error while
                                                ; exporting player! / Player not exported!'; used by LP
        dw str_ErrorWhileExportingPlayer, 0x3821
        dw str_PlayerNotExported, 0x3821
        db 0x00, 0x00, 0x00, 0x00, 0x00
