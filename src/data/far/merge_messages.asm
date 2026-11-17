; Far data, paragraph 3836h, 336 bytes: messages for merging databases. The EXE's own code does not use it
; (the overlays probably do).
        db 'The databases can only be merged'
        db 0x00, 'on the master copy of the league'
        db 0x00
msgTheDatabasesCanOnlyBe:                                    ; used by LP (to name)
        db 0x00, 0x00, '68!', 0x00
        db '68', 0x00, 0x00, 0x00, 0x00
        db 'The master controller for the league'
        db 0x00, 'must be imported first!'
        db 0x00
msgTheMasterControllerForThe:                                    ; used by LP (to name)
        db 0x4E, 0x00, 0x36, 0x38, 0x00, 0x00, 0x00, 0x00
        db 0x73, 0x00, '68Warning! Merge not completed!'
        db 0x00, 'League can not be used until'
        db 0x00, 'the merge is complete!'
        db 0x00
msgWarningMergeNotCompletedLeague:                                    ; used by LP (to name)
        db 0x97, 0x00, 0x36, 0x38, 0xB5, 0x00
        db 0x36, 0x38, 0xD2, 0x00
        db '68Error while updating'
        db 0x00, 'players databases!'
        db 0x00
msgErrorWhileUpdatingPlayersDatabases:                                    ; used by LP (to name)
        db 0xF5, 0x00, 0x36, 0x38, 0x0A, 0x01
        db '68Error while merging databases!'
        db 0x00
msgErrorWhileMergingDatabases:                                    ; used by LP (to name)
        db 0x25, 0x01, 0x36, 0x38, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
