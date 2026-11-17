; Far data, paragraph 3836h, 336 bytes: messages for merging databases. Used by LP.
str_TheDatabasesCanOnlyBe:                      ; string 'The databases can only be merged'
        db 'The databases can only be merged', 0x00
str_OnTheMasterCopyOf:                          ; string 'on the master copy of the league'
        db 'on the master copy of the league', 0x00
msgTheDatabasesCanOnlyBe:                       ; message list of 2 far string pointers: 'The databases can
                                                ; only be merged / on the master copy of the league'; used by
                                                ; LP
        dw str_TheDatabasesCanOnlyBe, 0x3836
        dw str_OnTheMasterCopyOf, 0x3836
        db 0x00, 0x00, 0x00, 0x00
str_TheMasterControllerForThe:                  ; string 'The master controller for the league'
        db 'The master controller for the league', 0x00
str_MustBeImportedFirst:                        ; string 'must be imported first!'
        db 'must be imported first!', 0x00
msgTheMasterControllerForThe:                   ; message list of 1 far string pointer: 'The master controller
                                                ; for the league'; used by LP
        dw str_TheMasterControllerForThe, 0x3836
        db 0x00, 0x00, 0x00, 0x00
        dw str_MustBeImportedFirst, 0x3836
str_WarningMergeNotCompleted:                   ; string 'Warning! Merge not completed!'
        db 'Warning! Merge not completed!', 0x00
str_LeagueCanNotBeUsed:                         ; string 'League can not be used until'
        db 'League can not be used until', 0x00
str_TheMergeIsComplete:                         ; string 'the merge is complete!'
        db 'the merge is complete!', 0x00
msgWarningMergeNotCompletedLeague:              ; message list of 3 far string pointers: 'Warning! Merge not
                                                ; completed! / League can not be used until / the merge is
                                                ; complete!'; used by LP
        dw str_WarningMergeNotCompleted, 0x3836
        dw str_LeagueCanNotBeUsed, 0x3836
        dw str_TheMergeIsComplete, 0x3836
str_ErrorWhileUpdating:                         ; string 'Error while updating'
        db 'Error while updating', 0x00
str_PlayersDatabases:                           ; string 'players databases!'
        db 'players databases!', 0x00
msgErrorWhileUpdatingPlayersDatabases:          ; message list of 2 far string pointers: 'Error while updating
                                                ; / players databases!'; used by LP
        dw str_ErrorWhileUpdating, 0x3836
        dw str_PlayersDatabases, 0x3836
str_ErrorWhileMergingDatabases:                 ; string 'Error while merging databases!'
        db 'Error while merging databases!', 0x00
msgErrorWhileMergingDatabases:                  ; message list of 1 far string pointer: 'Error while merging
                                                ; databases!'; used by LP
        dw str_ErrorWhileMergingDatabases, 0x3836
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
