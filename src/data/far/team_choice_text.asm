; Far data, paragraph 3701h, 4608 bytes: team choice and option text. Used by AskYesNo, FitNameToWidth,
; SaveGame, SaveGameNameDialog ....
str_Yes_2:                                      ; string 'Yes'
        db 'Yes', 0x00
str_No_5:                                       ; string 'No'
        db 'No', 0x00
str_DoYouWishToUse:                             ; string 'Do you wish to use your'
        db 'Do you wish to use your', 0x00
str_CustomNhlTeamsOrThe:                        ; string 'custom NHL teams or the'
        db 'custom NHL teams or the', 0x00
str_OriginalNhlTeams:                           ; string 'original NHL teams?'
        db 'original NHL teams?', 0x00
str_Custom:                                     ; string 'Custom'
        db 'Custom', 0x00
str_Original:                                   ; string 'Original'
        db 'Original', 0x00
        dw str_DoYouWishToUse, 0x3701
        dw str_CustomNhlTeamsOrThe, 0x3701
        dw str_OriginalNhlTeams, 0x3701
        db 0x08, 0x00, 0x28, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Custom, 0x3701
        db 0xF8, 0xFF, 0x28, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_Original, 0x3701
str_AllTheTeamsAreAlready:                      ; string 'All the teams are already human'
        db 'All the teams are already human', 0x00
msgAllTheTeamsAreAlready:                       ; message list of 1 far string pointer: 'All the teams are
                                                ; already human'; used by LP
        dw str_AllTheTeamsAreAlready, 0x3701
str_ThereIsOnlyOneHuman:                        ; string 'There is only one human'
        db 'There is only one human', 0x00
str_ControlledTeam:                             ; string 'controlled team!'
        db 'controlled team!', 0x00
msgThereIsOnlyOneHuman:                         ; message list of 2 far string pointers: 'There is only one
                                                ; human / controlled team!'; used by LP
        dw str_ThereIsOnlyOneHuman, 0x3701
        dw str_ControlledTeam, 0x3701
str_CanNotReadDatabasesIn:                      ; string 'Can not read databases in the league'
        db 'Can not read databases in the league', 0x00
msgCanNotReadDatabasesIn:                       ; message list of 1 far string pointer: 'Can not read
                                                ; databases in the league'; used by LP
        dw str_CanNotReadDatabasesIn, 0x3701
        db 0x00, 0x00, 0x00, 0x00
str_ThatNameHasAlreadyBeen:                     ; string 'That name has already been used!'
        db 'That name has already been used!', 0x00
msgThatNameHasAlreadyBeen:                      ; message list of 1 far string pointer: 'That name has already
                                                ; been used!'; used by LP
        dw str_ThatNameHasAlreadyBeen, 0x3701
str_DiskError:                                  ; string 'Disk Error'
        db 'Disk Error', 0x00
str_AbortRetryOrIgnore:                         ; string 'Abort, Retry or Ignore'
        db 'Abort, Retry or Ignore', 0x00
        dw str_DiskError, 0x3701
        dw str_AbortRetryOrIgnore, 0x3701
str_ThatFloppyDiskIsNot:                        ; string 'That floppy disk is not for'
        db 'That floppy disk is not for', 0x00
str_InsertDiskFor:                              ; string 'Insert disk for'
        db 'Insert disk for', 0x00
str_InAnyDrive:                                 ; string 'in any drive.'
        db 'in any drive.', 0x00
msgThatFloppyDiskIsNot:                         ; message list of 1 far string pointer: 'That floppy disk is
                                                ; not for'; used by LP
        dw str_ThatFloppyDiskIsNot, 0x3701
        db 0x00, 0x00, 0x00, 0x00
msgInsertDiskFor:                               ; message list of 1 far string pointer: 'Insert disk for';
                                                ; used by LP
        dw str_InsertDiskFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_InAnyDrive, 0x3701
str_ThatDiskIsFor:                              ; string 'That disk is for'
        db 'That disk is for', 0x00
str_FromTheLeague:                              ; string ' from the league '; used by LP
        db ' from the league ', 0x00
str_AreYouSureYouWant:                          ; string 'Are you sure you want to overwrite it?'
        db 'Are you sure you want to overwrite it?', 0x00
msgThatDiskIsFor:                               ; message list of 1 far string pointer: 'That disk is for';
                                                ; used by LP
        dw str_ThatDiskIsFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_AreYouSureYouWant, 0x3701
dlgInsertDisk:                                  ; MessageBox definition used by ExportTeamToFloppy and
                                                ; CopyHumanTeamDBs; used by LP
        db 0x08, 0x00, 0x28, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x28, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
        db ' from the ', 0x00
str_ThereAreNoLeagues:                          ; string 'There are no leagues!'
        db 'There are no leagues!', 0x00
        dw str_ThereAreNoLeagues, 0x3701
str_ThereIsAlreadyALeague:                      ; string 'There is already a league with that name!'
        db 'There is already a league with that name!', 0x00
str_DoYouWantToReplace_2:                       ; string 'Do you want to replace it with a new league?'
        db 'Do you want to replace it with a new league?', 0x00
msgThereIsAlreadyALeague:                       ; message list of 2 far string pointers: 'There is already a
                                                ; league with that name! / Do you want to replace it with a
                                                ; new league?'; used by LP
        dw str_ThereIsAlreadyALeague, 0x3701
        dw str_DoYouWantToReplace_2, 0x3701
dlgReplaceLeague:                               ; MessageBox definition used by CreateNewLeague and
                                                ; CreatePlayoffs; used by LP, MENUS
        db 0x08, 0x00, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_WhichScheduleDoYouWant:                     ; string '  Which schedule do you want to use?  '
        db '  Which schedule do you want to use?  ', 0x00
str_N9293Season:                                ; string ''92 - '93 Season'
        db 0x27, '92 - ', 0x27, '93 Season', 0x00
str_Random:                                     ; string 'Random'
        db 'Random', 0x00
msgWhichScheduleDoYouWant:                      ; message list of 1 far string pointer: '  Which schedule do
                                                ; you want to use?  '; used by LP
        dw str_WhichScheduleDoYouWant, 0x3701
dlgWhichSchedule:                               ; MessageBox definition asking which schedule to use
                                                ; (CreateNewLeague); used by LP
        db 0x08, 0x00, 0x18, 0x00, 0x50, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_N9293Season, 0x3701
        db 0xF8, 0xFF, 0x18, 0x00, 0x50, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_Random, 0x3701
str_ErrorWhileUpdatingDatabase:                 ; string 'Error while updating database!'
        db 'Error while updating database!', 0x00
msgErrorWhileUpdatingDatabase:                  ; message list of 1 far string pointer: 'Error while updating
                                                ; database!'; used by LP
        dw str_ErrorWhileUpdatingDatabase, 0x3701
str_ErrorWhileCreatingLeague:                   ; string 'Error while creating league!'
        db 'Error while creating league!', 0x00
msgErrorWhileCreatingLeague:                    ; message list of 1 far string pointer: 'Error while creating
                                                ; league!'; used by LP
        dw str_ErrorWhileCreatingLeague, 0x3701
str_ErrorWhileTradingPlayers:                   ; string 'Error while trading players!'
        db 'Error while trading players!', 0x00
msgErrorWhileTradingPlayers:                    ; message list of 1 far string pointer: 'Error while trading
                                                ; players!'; used by LP
        dw str_ErrorWhileTradingPlayers, 0x3701
str_DoYouReallyWantTo:                          ; string 'Do you really want to remove'
        db 'Do you really want to remove', 0x00
        dw str_DoYouReallyWantTo, 0x3701
        db 0x00, 0x00, 0x00, 0x00
dlgLeagueTeamSelect:                            ; MessageBox definition used by LeagueTeamSelect; used by LP
        db 0x08, 0x00, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_SelectATeamToPlay:                          ; string 'Select a team to play.'; used by LP
        db 'Select a team to play.'
        db 0x00
str_SelectATeamToExport:                        ; string 'Select a team to export.'; used by LP
        db 'Select a team to export.', 0x00
str_PutDiskWithLeagueTo:                        ; string 'Put disk with league to'
        db 'Put disk with league to', 0x00
str_ImportInAnyDrive:                           ; string 'import in any drive.'
        db 'import in any drive.', 0x00
msgPutDiskWithLeagueTo:                         ; message list of 2 far string pointers: 'Put disk with league
                                                ; to / import in any drive.'; used by LP
        dw str_PutDiskWithLeagueTo, 0x3701
        dw str_ImportInAnyDrive, 0x3701
str_ErrorWhileImportingLeague:                  ; string 'Error while importing league!'
        db 'Error while importing league!', 0x00
msgErrorWhileImportingLeague:                   ; message list of 1 far string pointer: 'Error while importing
                                                ; league!'; used by LP
        dw str_ErrorWhileImportingLeague, 0x3701
str_ErrorWhileExportingLeague:                  ; string 'Error while exporting league!'
        db 'Error while exporting league!', 0x00
        dw str_ErrorWhileExportingLeague, 0x3701
str_IncorrectPassword:                          ; string 'Incorrect password!'
        db 'Incorrect password!', 0x00
msgIncorrectPassword:                           ; message list of 1 far string pointer: 'Incorrect password!';
                                                ; used by LP
        dw str_IncorrectPassword, 0x3701
str_WhoWillControlTheLeague:                    ; string 'Who will control the league?'; used by LP
        db 'Who will control the league?', 0x00
str_HasNotBeenImportedFor:                      ; string 'has not been imported for'
        db 'has not been imported for', 0x00
str_DoYouWantToForce:                           ; string 'Do you want to force an export?'
        db 'Do you want to force an export?', 0x00
dlgExportButtons:                               ; button list of the export dialogs (ExportTeamToFloppy,
                                                ; ExportDbs); used by LP
        db 0x00, 0x00, 0x00, 0x00
        dw str_HasNotBeenImportedFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_DoYouWantToForce, 0x3701
dlgExportToFloppy:                              ; MessageBox definition 'Do you want to export to a floppy
                                                ; disk?'; used by LP
        db 0x08, 0x00, 0x3C, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x3C, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_DoYouWantToExport:                          ; string 'Do you want to export'
        db 'Do you want to export', 0x00
str_ToAFloppyDisk:                              ; string 'to a floppy disk?'
        db 'to a floppy disk?', 0x00
        dw str_DoYouWantToExport, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_ToAFloppyDisk, 0x3701
dlgAskExport:                                   ; MessageBox definition used by AskExportToFloppy; used by LP
        db 0x08, 0x00, 0x22, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x22, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_TheLeague:                                  ; string 'The league'
        db 'The league', 0x00
str_BeforeAGameCanBe:                           ; string 'before a game can be played!'
        db 'before a game can be played!', 0x00, 'must be imported from the disk for', 0x00
        db 'must be exported to the disk for', 0x00
msgTheLeague:                                   ; message list of 1 far string pointer: 'The league'; used by
                                                ; LP
        dw str_TheLeague, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        dw str_BeforeAGameCanBe, 0x3701
str_TheLeague_2:                                ; string 'The league'
        db 'The league', 0x00
str_AlreadyExistsFor:                           ; string 'already exists for'
        db 'already exists for', 0x00
msgTheLeague2:                                  ; message list of 1 far string pointer: 'The league'; used by
                                                ; LP
        dw str_TheLeague_2, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_AlreadyExistsFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
str_HasNotBeenExportedFor:                      ; string 'has not been exported for the league'
        db 'has not been exported for the league', 0x00
dlgImportTeam:                                  ; dialog record used by ImportPlayerTeam; used by LP
        db 0x00, 0x00, 0x00, 0x00
        dw str_HasNotBeenExportedFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
str_IsInASaveGame:                              ; string 'is in a save game in the league'
        db 'is in a save game in the league', 0x00
str_AndCanNotBeImported:                        ; string 'and can not be imported until'
        db 'and can not be imported until', 0x00
str_TheGameIsFinished:                          ; string 'the game is finished!'
        db 'the game is finished!', 0x00
dlgImportTeam2:                                 ; MessageBox definition used by ImportPlayerTeam; used by LP
        db 0x00, 0x00, 0x00, 0x00
        dw str_IsInASaveGame, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_AndCanNotBeImported, 0x3701
        dw str_TheGameIsFinished, 0x3701
str_CopyingDatabasesFor:                        ; string 'Copying databases for'
        db 'Copying databases for', 0x00
        dw str_CopyingDatabasesFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
str_CreatingLeague:                             ; string 'Creating league.'
        db 'Creating league.', 0x00
msgCreatingLeague:                              ; message list of 1 far string pointer: 'Creating league.';
                                                ; used by LP
        dw str_CreatingLeague, 0x3701
str_ThatFloppyDiskHasAn:                        ; string 'That floppy disk has an'
        db 'That floppy disk has an', 0x00
str_OldCopyOfTheLeague:                         ; string 'old copy of the league'
        db 'old copy of the league', 0x00
msgThatFloppyDiskHasAn:                         ; message list of 2 far string pointers: 'That floppy disk has
                                                ; an / old copy of the league'; used by LP
        dw str_ThatFloppyDiskHasAn, 0x3701
        dw str_OldCopyOfTheLeague, 0x3701
        db 0x00, 0x00, 0x00, 0x00
str_AreYouSureYouWant_2:                        ; string 'Are you sure you want to'
        db 'Are you sure you want to', 0x00
str_UseANewFloppyDisk:                          ; string 'use a new floppy disk?'
        db 'use a new floppy disk?', 0x00
msgAreYouSureYouWant:                           ; message list of 2 far string pointers: 'Are you sure you
                                                ; want to / use a new floppy disk?'; used by LP
        dw str_AreYouSureYouWant_2, 0x3701
        dw str_UseANewFloppyDisk, 0x3701
dlgNewFloppy:                                   ; MessageBox definition used by ExportTeamToFloppy; used by LP
        db 0x08, 0x00, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x1E, 0x00, 0x14, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_ImportMasterCopyOfLeague:                   ; string 'Import master copy of league or'
        db 'Import master copy of league or', 0x00
str_ImportForPlayerOnFloppy:                    ; string 'import for player on floppy disk?'
        db 'import for player on floppy disk?', 0x00
str_Master:                                     ; string 'Master'
        db 'Master', 0x00
str_Player_5:                                   ; string 'Player'
        db 'Player', 0x00
msgImportMasterCopyOfLeague:                    ; message list of 2 far string pointers: 'Import master copy
                                                ; of league or / import for player on floppy disk?'; used by
                                                ; LP
        dw str_ImportMasterCopyOfLeague, 0x3701
        dw str_ImportForPlayerOnFloppy, 0x3701
dlgImportChoice:                                ; MessageBox definition used by ImportDbs; used by LP
        db 0x08, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Master, 0x3701
        db 0xF8, 0xFF, 0x1E, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_Player_5, 0x3701
str_CanNotImportMasterLeague:                   ; string 'Can not import master league!'
        db 'Can not import master league!', 0x00
str_TheLeagueAlreadyExists:                     ; string 'The league already exists!'
        db 'The league already exists!', 0x00
msgCanNotImportMasterLeague:                    ; message list of 2 far string pointers: 'Can not import
                                                ; master league! / The league already exists!'; used by LP
        dw str_CanNotImportMasterLeague, 0x3701
        dw str_TheLeagueAlreadyExists, 0x3701
str_TheLeague_3:                                ; string 'The league'
        db 'The league', 0x00, 'is already merged.', 0x00, 'has not been merged.', 0x00
msgTheLeague3:                                  ; message list of 1 far string pointer: 'The league'; used by
                                                ; LP
        dw str_TheLeague_3, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_MasterDatabasesFor:                         ; string 'Master databases for'
        db 'Master databases for', 0x00
str_MustBeMergedFirst:                          ; string 'must be merged first!'
        db 'must be merged first!', 0x00
str_DoYouWantToMerge:                           ; string 'Do you want to merge?'
        db 'Do you want to merge?', 0x00
msgMasterDatabasesFor:                          ; message list of 1 far string pointer: 'Master databases
                                                ; for'; used by LP
        dw str_MasterDatabasesFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_MustBeMergedFirst, 0x3701
        dw str_DoYouWantToMerge, 0x3701
str_PlayersDatabasesFor:                        ; string 'Players databases for'
        db 'Players databases for', 0x00
str_MustBeUpdatedFirst:                         ; string 'must be updated first!'
        db 'must be updated first!', 0x00
str_DoYouWantToUpdate:                          ; string 'Do you want to update?'
        db 'Do you want to update?', 0x00
        dw str_PlayersDatabasesFor, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_MustBeUpdatedFirst, 0x3701
        dw str_DoYouWantToUpdate, 0x3701
dlgMergeFirst:                                  ; MessageBox definition 'Master databases for ... must be
                                                ; completely merged'; used by LP
        db 0x08, 0x00, 0x2E, 0x00, 0x28, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x2E, 0x00, 0x28, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_MasterDatabasesFor_2:                       ; string 'Master databases for'
        db 'Master databases for', 0x00
str_MustBeCompletelyMergedAnd:                  ; string 'must be completely merged and'
        db 'must be completely merged and', 0x00
str_PlayersDatabasesMustBeUpdated:              ; string 'players databases must be updated first!'
        db 'players databases must be updated first!', 0x00
str_DoYouWishToDo:                              ; string 'Do you wish to do merge and update?.'
        db 'Do you wish to do merge and update?.', 0x00
        dw str_MasterDatabasesFor_2, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_MustBeCompletelyMergedAnd, 0x3701
        dw str_PlayersDatabasesMustBeUpdated, 0x3701
        dw str_DoYouWishToDo, 0x3701
dlgPlayLeagueGame:                              ; dialog record used by PlayLeagueGame; used by LP
        db 0x08, 0x00, 0x36, 0x00, 0x28, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Yes_2, 0x3701
        db 0xF8, 0xFF, 0x36, 0x00, 0x28, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00
        dw str_No_5, 0x3701
str_MergingPlayersToMasterDatabase:             ; string 'Merging players to master database.'
        db 'Merging players to master database.', 0x00
msgMergingPlayersToMasterDatabase:              ; message list of 1 far string pointer: 'Merging players to
                                                ; master database.'; used by LP
        dw str_MergingPlayersToMasterDatabase, 0x3701
str_UpdatingSchedule:                           ; string 'Updating schedule.'
        db 'Updating schedule.', 0x00
msgUpdatingSchedule:                            ; message list of 1 far string pointer: 'Updating schedule.';
                                                ; used by LP
        dw str_UpdatingSchedule, 0x3701
str_PleasePutAFloppyDisk:                       ; string 'Please put a floppy disk in any drive.'
        db 'Please put a floppy disk in any drive.', 0x00
msgPleasePutAFloppyDisk:                        ; message list of 1 far string pointer: 'Please put a floppy
                                                ; disk in any drive.'; used by LP
        dw str_PleasePutAFloppyDisk, 0x3701
str_UseFloppyDriveAOr:                          ; string 'Use floppy drive A or B?'
        db 'Use floppy drive A or B?', 0x00
msgUseFloppyDriveAOr:                           ; message list of 1 far string pointer: 'Use floppy drive A or
                                                ; B?'; used by LP
        dw str_UseFloppyDriveAOr, 0x3701
str_TheFirstTeamSelectedTo:                     ; string 'The first team selected to'
        db 'The first team selected to', 0x00
str_PlayMustBeImported:                         ; string 'play must be imported!'
        db 'play must be imported!', 0x00
msgTheFirstTeamSelectedTo:                      ; message list of 2 far string pointers: 'The first team
                                                ; selected to / play must be imported!'; used by LP
        dw str_TheFirstTeamSelectedTo, 0x3701
        dw str_PlayMustBeImported, 0x3701
str_ThePasswordWasEnteredDifferently:           ; string 'The password was entered differently'
        db 'The password was entered differently', 0x00
str_TheSecondTimeTryAgain:                      ; string 'the second time! Try again.'
        db 'the second time! Try again.', 0x00
msgThePasswordWasEnteredDifferently:            ; message list of 2 far string pointers: 'The password was
                                                ; entered differently / the second time! Try again.'; used by
                                                ; LP
        dw str_ThePasswordWasEnteredDifferently, 0x3701
        dw str_TheSecondTimeTryAgain, 0x3701
str_ThereIsASavedGame:                          ; string 'There is a saved game in the league'
        db 'There is a saved game in the league', 0x00
str_WhichMustBePlayedFirst:                     ; string 'which must be played first!'
        db 'which must be played first!', 0x00
msgThereIsASavedGame:                           ; message list of 1 far string pointer: 'There is a saved game
                                                ; in the league'; used by LP
        dw str_ThereIsASavedGame, 0x3701
        db 0x00, 0x00, 0x00, 0x00
        dw str_WhichMustBePlayedFirst, 0x3701
str_Key_3:                                      ; string 'KEY'
        db 'KEY', 0x00
str_Career_3:                                   ; string 'CAREER'
        db 'CAREER', 0x00
str_Att_2:                                      ; string 'ATT'
        db 'ATT', 0x00
str_Carteams:                                   ; string 'CARTEAMS'
        db 'CARTEAMS', 0x00
str_Teams_8:                                    ; string 'TEAMS'
        db 'TEAMS', 0x00
str_Season_3:                                   ; string 'SEASON'
        db 'SEASON', 0x00
str_Schedule:                                   ; string 'SCHEDULE'
        db 'SCHEDULE', 0x00
        dw str_Key_3, 0x3701
        dw str_Career_3, 0x3701
        dw str_Att_2, 0x3701
        dw str_Carteams, 0x3701
        dw str_Teams_8, 0x3701
        dw str_Season_3, 0x3701
        dw str_Schedule, 0x3701
str_Pinfo:                                      ; string 'PINFO'; used by LP
        db 'PINFO'
        db 0x00
str_Player:                                     ; string 'PLAYER'; used by LP
        db 'PLAYER', 0x00
str_Lssched:                                    ; string 'LSSCHED'; used by STATS
        db 'LSSCHED', 0x00
        db 'PGS', 0x00
str_Game:                                       ; string 'GAME'; used by LP
        db 'GAME', 0x00
str_Space:                                      ; string ' ' appended by FixJerseyConflict; used by LP
        db 0x20, 0x00
str_Star:                                       ; string '*' used by BuildLeagueList and SelectHilight; used
                                                ; by LP, MENUS
        db 0x2A, 0x00
str_Backslash:                                  ; string '\' appended by MakeTeamDbFmt and ExecuteTrade; used
                                                ; by LP
        db 0x5C, 0x00
str_S:                                          ; string '%s'; used by LP
        db 0x25, 0x73, 0x00
str_Db_2:                                       ; string '.DB'; used by INIT, LP, MENUS, STATS
        db '.DB', 0x00
        db '.ORG', 0x00
str_Nsh:                                        ; string '.NSH'; used by STATS
        db '.NSH', 0x00
str_Mvi:                                        ; string '.MVI'; used by MENUS
        db '.MVI', 0x00
str_Hi:                                         ; string '.HI'; used by MENUS
        db '.HI', 0x00
str_Set:                                        ; string '.SET'; used by LP
        db '.SET', 0x00
str_Ppv:                                        ; string '.PPV'; used by INIT, LP
        db '.PPV', 0x00
str_Qpp:                                        ; string '.QPP'; used by AI, GAME, INIT, LP, MENUS, STATS
        db '.QPP', 0x00
        db '.VSH', 0x00
str_Kms:                                        ; string '.KMS'; used by INIT
        db '.KMS', 0x00
str_Cfg:                                        ; string '.CFG'; used by INIT
        db '.CFG', 0x00
str_Xx_2:                                       ; string '.xx'; used by LP
        db '.xx', 0x00
str_Xx:                                         ; string '.xx'; used by LP
        db '.xx', 0x00
str_Lp:                                         ; string '.LP'; used by LP
        db '.LP', 0x00
        db '.SP', 0x00
str_Dot:                                        ; string '.' searched for by the import and export code; used
                                                ; by LP, MENUS
        db 0x2E, 0x00
str_Id:                                         ; string '.ID'; used by LP
        db '.ID', 0x00
str_DriveColon:                                 ; string '?:' (drive letter is patched in) used for floppy
                                                ; paths; used by LP
        db 0x3F, 0x3A, 0x00
str_SelectHumanControlledTeams:                 ; string 'Select human controlled teams'; used by LP
        db 'Select human controlled teams'
        db 0x00
str_SelectNewHumanControlled:                   ; string 'Select new human controlled team'; used by LP
        db 'Select new human controlled team'
        db 0x00
str_SelectHumanControlledTeam:                  ; string 'Select human controlled team to remove'; used by LP
        db 'Select human controlled team to remove'
        db 0x00
str_SelectTwoTeamsForTrading:                   ; string 'Select two teams for trading players'; used by LP
        db 'Select two teams for trading players'
        db 0x00, 'Select a league'
        db 0x00
str_SelectATeam:                                ; string 'Select a team'; used by MENUS
        db 'Select a team', 0x00
str_SelectAHilight:                             ; string 'Select a hilight'; used by MENUS
        db 'Select a hilight'
        db 0x00
str_EnterNewLeagueName:                         ; string 'Enter New League Name'; used by LP
        db 'Enter New League Name'
        db 0x00, 'Enter Number of human contolled teams'
        db 0x00, 'Select first player to trade.'
        db 0x00, 'Select second player to trade.'
        db 0x00, ' vs ', 0x00
str_EnterPasswordFor:                           ; string 'Enter password for '; used by LP
        db 'Enter password for '
        db 0x00
str_VerifyPasswordFor:                          ; string 'Verify password for '; used by LP
        db 'Verify password for '
        db 0x00
str_EnterMasterPassword:                        ; string ' enter master password.'; used by LP
        db ' enter master password.'
        db 0x00
str_EnterMasterControllerPassword:              ; string 'Enter master controller password for '; used by LP
        db 'Enter master controller password for '
        db 0x00
str_VerifyMasterControllerPassword:             ; string 'Verify master controller password for '; used by LP
        db 'Verify master controller password for '
PasswordKey:                                    ; key bytes EncryptPassword mixes into the password; used by
                                                ; LP
        db 0x00
str_Nhlhockey:                                  ; string 'NHLHockey'; used by LP
        db 'NHLHockey', 0x00
str_January:                                    ; string 'January'
        db 'January', 0x00
str_February:                                   ; string 'February'
        db 'February', 0x00
str_March:                                      ; string 'March'
        db 'March', 0x00
str_April:                                      ; string 'April'
        db 'April', 0x00
str_May:                                        ; string 'May'
        db 'May', 0x00
str_June:                                       ; string 'June'
        db 'June', 0x00
str_July:                                       ; string 'July'
        db 'July', 0x00
str_August:                                     ; string 'August'
        db 'August', 0x00
str_September:                                  ; string 'September'
        db 'September', 0x00
str_October:                                    ; string 'October'
        db 'October', 0x00
str_November:                                   ; string 'November'
        db 'November', 0x00
str_December:                                   ; string 'December'
        db 'December', 0x00
        dw str_January, 0x3701
        dw str_February, 0x3701
        dw str_March, 0x3701
        dw str_April, 0x3701
        dw str_May, 0x3701
        dw str_June, 0x3701
        dw str_July, 0x3701
        dw str_August, 0x3701
        dw str_September, 0x3701
        dw str_October, 0x3701
        dw str_November, 0x3701
        dw str_December, 0x3701
CurLeagueName:                                  ; name of the current league (13 bytes), read and copied by
                                                ; the league code; used by GAME, INIT, LP, MENUS
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x63, 0x00, 0x08, 0x00
        dw str_StatisticsType, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0x90, 0x00, 'K8', 0x05, 0x00, 0x00, 0x00, 0x09, 0x00, 0x63, 0x00, 0x10
        db 0x00
        dw str_Standings_3, 0x3448
        dw CalStandingsMenuThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x11, 0x00, 0x63, 0x00, 0x18, 0x00
        dw str_TeamsSortedBy, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0xA4, 0x0E, 'H4', 0x05, 0x00, 0x00, 0x00, 0x19, 0x00, 0x63, 0x00, 0x20
        db 0x00
        dw str_PlayersSortedBy, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0x12, 0x0F, 'H4', 0x08, 0x00, 0x00, 0x00, 0x21, 0x00, 0x63, 0x00, 0x29
        db 0x00
        dw str_GoaliesSortedBy, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0xC2, 0x0F, 'H4', 0x03, 0x00
str_Player1Controls_2:                          ; string 'Player 1 Controls ...'
        db 'Player 1 Controls ...', 0x00
str_Player2Controls_2:                          ; string 'Player 2 Controls ...'
        db 'Player 2 Controls ...', 0x00
str_ShowLeagueSettings:                         ; string 'Show League Settings ...'
        db 'Show League Settings ...', 0x00, 0x00, 0x00, 0x00, 0x00, 0x74, 0x00, 0x08, 0x00
        dw str_Player1Controls_2, 0x3701
        dw MenuP1ControlsExhThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x74, 0x00, 0x10, 0x00
        dw str_Player2Controls_2, 0x3701
        dw MenuP2ControlsExhThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x74, 0x00, 0x18, 0x00
        dw str_ShowLeagueSettings, 0x3701
        dw DrawLeagueSetDlgSelThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_NextMonth:                                  ; string 'Next month'
        db 'Next month', 0x00
str_PreviousMonth:                              ; string 'Previous month'
        db 'Previous month', 0x00
str_ReturnToSportsCentral_2:                    ; string 'Return to Sports Central'
        db 'Return to Sports Central', 0x00, 0x00, 0x00, 0x00, 0x00, 0x7A, 0x00, 0x08, 0x00
        dw str_NextMonth, 0x3701
CalNextMonthFn:                                 ; far routine offset of the calendar's next-month button; used
                                                ; by LP
        db 0x0D, 0x20
CalNextMonthSeg:                                ; its segment; used by LP
        db 0x35, 0x1B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x7A, 0x00, 0x10, 0x00
        dw str_PreviousMonth, 0x3701
CalPrevMonthFn:                                 ; far routine offset of the calendar's previous-month button;
                                                ; used by LP
        db 0x17, 0x20
CalPrevMonthSeg:                                ; its segment; used by LP
        db 0x35, 0x1B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x7A, 0x00, 0x19, 0x00
        dw str_ReturnToSportsCentral_2, 0x3701
        dw CalReturnThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Play_2:                                     ; string 'Play'
        db 'Play', 0x00
str_Game_12:                                    ; string 'Game'
        db 'Game', 0x00
str_Statistics_4:                               ; string 'Statistics'
        db 'Statistics', 0x00
CalendarMenuBar:                                ; menu bar of the calendar screen; used by LP
        db 0x00, 0x00, 0x00, 0x00, 0x16, 0x00, 0x09, 0x00
        dw str_Play_2, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x88, 0x0F, 0x01, 0x37, 0x03, 0x00, 0x17, 0x00, 0x00, 0x00, 0x30, 0x00
        db 0x09, 0x00
        dw str_Game_12, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x13, 0x0F, 0x01, 0x37, 0x03, 0x00, 0x31, 0x00, 0x00, 0x00, 0x5C, 0x00
        db 0x09, 0x00
        dw str_Statistics_4, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x60, 0x0E, 0x01, 0x37, 0x05, 0x00
str_ShowLeagueSettings_2:                       ; string 'Show League settings'
        db 'Show League settings', 0x00, 0x00, 0x00, 0x00, 0x00, 0x6A, 0x00, 0x08, 0x00
        dw str_ShowLeagueSettings_2, 0x3701
        dw MenuShowLeagueSettings2Thunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_LeagueSettings:                             ; string 'League settings'
        db 'League settings', 0x00, 0x00, 0x00, 0x00, 0x00, 0x4C, 0x00, 0x08, 0x00
        dw str_LeagueSettings, 0x3701
        dw MenuShowLeagueSettingsThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Done:                                       ; string 'Done'
        db 'Done', 0x00
str_Cancel_3:                                   ; string 'Cancel'
        db 'Cancel', 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x00, 0x08, 0x00
        dw str_Done, 0x3701
        dw TeamSelDoneThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x1F, 0x00, 0x10, 0x00
        dw str_Cancel_3, 0x3701
        dw TeamSelCancelThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Select:                                     ; string 'Select'
        db 'Select', 0x00
str_Settings_4:                                 ; string 'Settings'
        db 'Settings', 0x00, 0x00, 0x00, 0x00, 0x00, 0x21, 0x00, 0x09, 0x00
        dw str_Select, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x7E, 0x10, 0x01, 0x37, 0x02, 0x00, 0x22, 0x00, 0x00, 0x00, 0x4A, 0x00
        db 0x09, 0x00
        dw str_Settings_4, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x5C, 0x10, 0x01, 0x37, 0x01, 0x00
str_ShowPlayerStatistics_2:                     ; string 'Show Player Statistics'
        db 'Show Player Statistics', 0x00, 0x00, 0x00, 0x00, 0x00, 0x6C, 0x00, 0x09, 0x00
        dw str_ShowPlayerStatistics_2, 0x3701
        dw TradeShowStatsThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Done_2:                                     ; string 'Done'
        db 'Done', 0x00
str_Cancel_4:                                   ; string 'Cancel'
        db 'Cancel', 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x00, 0x08, 0x00
        dw str_Done_2, 0x3701
        dw TradeDoneThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x24, 0x00, 0x10, 0x00
        dw str_Cancel_4, 0x3701
        dw TradeCancelThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Trade:                                      ; string 'Trade'
        db 'Trade', 0x00
str_PlayerStatistics_4:                         ; string 'Player Statistics'
        db 'Player Statistics', 0x00
TradeMenu:                                      ; menu record used by TradePlayers; used by LP
        db 0x60, 0x00, 0x00, 0x00, 0x83, 0x00, 0x09, 0x00
        dw str_Trade, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0x1F, 0x11, 0x01, 0x37, 0x02, 0x00, 0x84, 0x00, 0x00, 0x00, 0xDF, 0x00
        db 0x09, 0x00
        dw str_PlayerStatistics_4, 0x3701
        db 0x00, 0x00, 0x00, 0x00, 0xFD, 0x10, 0x01, 0x37, 0x01, 0x00
str_Trade_2:                                    ; string 'Trade'
        db 'Trade', 0x00, 0x00, 0x00, 0x00, 0x00, 0x32, 0x00, 0x09, 0x00
        dw str_Trade_2, 0x3701
        dw MenuReturnToLineEditorThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
TradeStatsMenuBar:                              ; menu bar of the trade stats view; used by LP
        db 0x00, 0x00, 0x00, 0x00, 0x35, 0x00, 0x09, 0x00
        dw str_ReturnTo, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0x95, 0x11, 0x01, 0x37, 0x01, 0x00, 0x36, 0x00, 0x00, 0x00, 0x7D, 0x00
        db 0x09, 0x00
        dw str_StatisticsType_9, 0x3448
        db 0x00, 0x00, 0x00, 0x00, 0x90, 0x00, 'K8', 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x08, 0x00, 0x18, 0x00, 0x20, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00, 0xD2, 0x17
        db 0xC9, 0x45, 0xF8, 0xFF, 0x18, 0x00, 0x20, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00, 0xD4, 0x17
        db 0xC9, 0x45
