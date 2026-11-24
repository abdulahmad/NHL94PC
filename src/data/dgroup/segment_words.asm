; The segment words: the paragraph of each far segment the code loads, in link order; then the
; run-time's floating-point zero and message table.
DgroupSegA:                                     ; DGROUP paragraph (relocated); main loads it into es
        dw 0x45C9
CentisPerSample:                                ; the double 1/110.25: a sample count at 11025 Hz to
                                                ; hundredths
                                                ; of a second; used by the speech bank loader
        db 0xA5, 0x04, 0xB8, 0x5B, 0x72, 0x93, 0x82, 0x3F
NumberWordsSeg:                                 ; paragraph of number_words; used by NumberSampleNames,
                                                ; SayScoringPeriod, SayPlayerFrom
        dw 0x342F
DbFilesSeg:                                     ; paragraph of db_files; used by SaveGame
        dw 0x3415
DbFilesSeg2:                                    ; paragraph of db_files; used by SaveGame
        dw 0x3415
DbFilesSeg3:                                    ; paragraph of db_files; used by SaveGame
        dw 0x3415
ListDialogDataSeg:                              ; paragraph of the list dialog data; used by ListDialog
        dw 0x35EC
DgroupSegB:                                     ; DGROUP paragraph (relocated); used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        dw 0x45C9
InputEventDataSeg:                              ; paragraph of the input event data; used by GetInputEvent
        db 0x2E, 0x34
segDgroup1:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; ControlsDlgLoop, ControlsDlgPlayoff; used by MENUS
        db 0xC9, 0x45
segSaveDialogRects1:                            ; segment constant 35EEh (save_dialog_rects) loaded into es by
                                                ; DrawControlsDlg; used by MENUS
        db 0xEE, 0x35
segDgroup2:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; TitleScreen; used by MENUS
        db 0xC9, 0x45
segCredits1:                                    ; segment constant 3608h (credits) loaded into es by
                                                ; GoodnightScreen; used by MENUS
        db 0x08, 0x36
segMenuText1:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetSideControls; used by MENUS
        db 0x48, 0x34
segMenuText2:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetSideControls; used by MENUS
        db 0x48, 0x34
segMenuText3:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, MenuUseDefaultLines,
                                                ; MenuUseOriginalLines; used by MENUS
        db 0x48, 0x34
segMenuText4:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segMenuText5:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segMenuText6:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segCharTable1:                                  ; segment constant 3680h (char_table) loaded into es by
                                                ; DrawGameLineJerseys, GameLineEditorLoop, LoadJerseyColours;
                                                ; used by MENUS
        db 0x80, 0x36
segDbFiles1:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuOpenSaved, SelectSavedFile; used by MENUS
        db 0x15, 0x34
segDbFiles2:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DeleteSavedGame, MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDbFiles3:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDbFiles4:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DeleteSavedGame, MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDialogRects1:                                ; segment constant 369Ah (dialog_rects) loaded into es by
                                                ; DrawFileDlg, DrawFileDlgList, RunFileDlg; used by MENUS
        db 0x9A, 0x36
segMenuText7:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeleteSavedGame, SelectSavedFile; used by MENUS
        db 0x48, 0x34
segPlayoffDialogRects1:                         ; segment constant 36A8h (playoff_dialog_rects) loaded into es
                                                ; by SetSoundDevice; used by MENUS
        db 0xA8, 0x36
segDbFiles5:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DrawLockerRoom, LockerRoomLoop; used by MENUS
        db 0x15, 0x34
segMenuText8:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; LockerRoomLoop; used by MENUS
        db 0x48, 0x34
segMenuText9:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; MenuPlayoffHilights; used by MENUS
        db 0x48, 0x34
segDbFiles6:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; CreatePlayoffs, PlayoffModeLoop; used by MENUS
        db 0x15, 0x34
segTeamChoiceText1:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CreatePlayoffs, POSimSeries, POSimSeriesTeamWins; used by
                                                ; MENUS
        db 0x01, 0x37
segMenuText10:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; CreatePlayoffs; used by MENUS
        db 0x48, 0x34
segDbFiles7:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; POCreateSchedule, POInitSchedule, POPickConfTeams; used by
                                                ; MENUS
        db 0x15, 0x34
segMenuText11:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; POAfterGame, PlayoffModeLoop; used by MENUS
        db 0x48, 0x34
segWorkBuffer1:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayoffModeLoop; used by MENUS
        db 0x0B, 0x3A
segDbFiles8:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; PlayoffModeLoop; used by MENUS
        db 0x15, 0x34
segDgroup3:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawPlayoffTree, PlayoffModeLoop; used by MENUS
        db 0xC9, 0x45
segMenuText12:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetModeMenuLabels; used by MENUS
        db 0x48, 0x34
segMenuText13:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetModeMenuLabels; used by MENUS
        db 0x48, 0x34
segDgroup4:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; MenuLeagueSettingsEdit; used by MENUS
        db 0xC9, 0x45
segMenuText14:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x48, 0x34
segWorkBuffer2:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x0B, 0x3A
segDbFiles9:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x15, 0x34
segDbFiles10:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x15, 0x34
segReturnMessages1:                             ; segment constant 36F5h (return_messages) loaded into es by
                                                ; DeskExitGame, DeskReturnConfirm; used by MENUS
        db 0xF5, 0x36
segDgroup5:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DeskExitGame; used by MENUS
        db 0xC9, 0x45
segMenuText15:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeskHomeGoalie1, DeskHomeGoalie2, DeskHomeGoalieNone; used
                                                ; by MENUS
        db 0x48, 0x34
segMenuText16:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeskAwayGoalie1, DeskAwayGoalie2, DeskAwayGoalieNone; used
                                                ; by MENUS
        db 0x48, 0x34
segMenuText17:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; MainDeskLoop, MenuLeagueHilights, MenuNewExhibition; used by
                                                ; MENUS
        db 0x48, 0x34
segMenuText18:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; LoadModeState; used by MENUS
        db 0x48, 0x34
schedgameidx:                                   ; schedule game index; used by MENUS
        db 0x0B, 0x3A
musicslot:                                      ; music slot; used by MENUS
        db 0xC9, 0x45
segDbFiles11:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuNewLeague; used by MENUS
        db 0x15, 0x34
segMenuText19:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; MenuNewLeague; used by MENUS
        db 0x48, 0x34
segWorkBuffer3:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText2:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer4:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText3:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer5:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText4:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer6:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segWorkBuffer7:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawTeamGrid; used by LP
        db 0x0B, 0x3A
segWorkBuffer8:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer9:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer10:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer11:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segTeamChoiceText5:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AskExportToFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText6:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText7:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText8:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText9:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; FindLeagueFloppy, SelectFloppyDrive; used by LP
        db 0x01, 0x37
segTeamChoiceText10:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; FindLeagueFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText11:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; WaitLeagueFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText12:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportTeamToFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText13:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyLeagueFiles, ExportDbs, ExportTeamToFloppy ; used by LP
        db 0x01, 0x37
segTeamChoiceText14:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ExportTeamToFloppy; used by LP
        db 0x01, 0x37
segWorkBuffer12:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportMasterLeague; used by LP
        db 0x0B, 0x3A
segTeamChoiceText15:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer13:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText16:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer14:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText17:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer15:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText18:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segTeamChoiceText19:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segTeamChoiceText20:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segMenuText20:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ImportDbs; used by LP
        db 0x48, 0x34
segDbFiles12:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ImportDbs; used by LP
        db 0x15, 0x34
segWorkBuffer16:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs; used by LP
        db 0x0B, 0x3A
segTeamChoiceText21:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ReadLeagueInfo; used by LP
        db 0x01, 0x37
segWorkBuffer17:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x0B, 0x3A
segTeamChoiceText22:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x01, 0x37
segWorkBuffer18:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x0B, 0x3A
segTeamChoiceText23:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MsgCopyingDatabases; used by LP
        db 0x01, 0x37
segTeamChoiceText24:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText25:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText26:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText27:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; SimulateGame; used by LP
        db 0x01, 0x37
segWorkBuffer19:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawCalendarDay; used by LP
        db 0x0B, 0x3A
segTeamChoiceText28:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; DrawCalendarDay; used by LP
        db 0x01, 0x37
segWorkBuffer20:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame, SetGameSides; used by LP
        db 0x0B, 0x3A
segTeamChoiceText29:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CalendarScreen, PlayLeagueGame, PostGameToTeamDb; used by LP
        db 0x01, 0x37
segTeamChoiceText30:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CalendarScreen; used by LP
        db 0x01, 0x37
segTeamChoiceText31:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckLeagueDiskSync; used by LP
        db 0x01, 0x37
segTeamChoiceText32:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckLeagueDiskSync; used by LP
        db 0x01, 0x37
segWorkBuffer21:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PostGameToTeamDb; used by LP
        db 0x0B, 0x3A
segWorkBuffer22:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PostGameToTeamDb; used by LP
        db 0x0B, 0x3A
segWorkBuffer23:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segTeamChoiceText33:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x01, 0x37
segTeamChoiceText34:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x01, 0x37
segWorkBuffer24:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segWorkBuffer25:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segDgroup6:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0xC9, 0x45
segDbFiles13:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x15, 0x34
segTeamChoiceText35:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; RandomizeSchedule, UpdateSeasonSchedule; used by LP
        db 0x01, 0x37
segWorkBuffer26:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segTeamChoiceText36:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x01, 0x37
segWorkBuffer27:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer28:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer29:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer30:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segDbFiles14:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x15, 0x34
segTeamChoiceText37:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster, ExecuteTrade, TradePlayers; used by LP
        db 0x01, 0x37
segTeamChoiceText38:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster; used by LP
        db 0x01, 0x37
segTeamChoiceText39:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster; used by LP
        db 0x01, 0x37
segWorkBuffer31:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; FixJerseyConflict; used by LP
        db 0x0B, 0x3A
segTradeMessages1:                              ; segment constant 382Bh (trade_messages) loaded into es by
                                                ; DrawTradeScreen, TradeScreenLoop; used by LP
        db 0x2B, 0x38
segTeamChoiceText40:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradeHitTest, TradeScreenLoop; used by LP
        db 0x01, 0x37
segMenuText21:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; TradeScreenLoop; used by LP
        db 0x48, 0x34
segCharTable2:                                  ; segment constant 3680h (char_table) loaded into es by
                                                ; TradeScreenLoop; used by LP
        db 0x80, 0x36
segWorkBuffer32:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText41:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x01, 0x37
segWorkBuffer33:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText42:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x01, 0x37
segWorkBuffer34:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText43:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, MergeScheduleDb, MergeTeamDbs; used by LP
        db 0x01, 0x37
segTeamChoiceText44:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LocateTeamDbCopy; used by LP
        db 0x01, 0x37
segWorkBuffer35:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, UpdateTeamDbs; used by LP
        db 0x0B, 0x3A
segTeamChoiceText45:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, UpdateTeamDbs; used by LP
        db 0x01, 0x37
segTeamChoiceText46:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, UpdateTeamDbs; used by LP
        db 0x01, 0x37
segWorkBuffer36:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, RebuildLeagueDbs; used by
                                                ; LP
        db 0x0B, 0x3A
segWorkBuffer37:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, RebuildLeagueDbs; used by
                                                ; LP
        db 0x0B, 0x3A
segMergeMessages1:                              ; segment constant 3836h (merge_messages) loaded into es by
                                                ; MergeLeagueFiles; used by LP
        db 0x36, 0x38
segWorkBuffer38:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles; used by LP
        db 0x0B, 0x3A
segTeamChoiceText47:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PickAwardWinners; used by LP
        db 0x01, 0x37
segDbFiles15:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; BuildSeasonTitle, SetupStatsMenus; used by STATS
        db 0x15, 0x34
segDbFiles16:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; BuildSeasonTitle, SetupStatsMenus; used by STATS
        db 0x15, 0x34
SeasonTitleSegs:                                ; segment words of the season titles (SetupStatsMenus); used
                                                ; by STATS
        db 'K8K8K8K8K8K8K8'
segTeamChoiceText48:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x01, 0x37
segMenuText22:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText23:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText24:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText25:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText26:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText27:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText28:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText29:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText30:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText31:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText32:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText33:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText34:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText35:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segSeasonTitles1:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles2:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles3:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles4:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles5:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segWorkBuffer39:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; GoalieStatsCard; used by STATS
        db 0x0B, 0x3A
PoStandingsMode:                                ; playoff standings mode; used by STATS
        db 0xC9, 0x45
segWorkBuffer40:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; GameStandingsMenu; used by STATS
        db 0x0B, 0x3A
segSeasonTitles6:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles7:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles8:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles9:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles10:                              ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segWorkBuffer41:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x0B, 0x3A
segWorkBuffer42:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; EasnStandingsMenu; used by STATS
        db 0x0B, 0x3A
segWorkBuffer43:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CalStandingsMenu; used by STATS
        db 0x0B, 0x3A
segWorkBuffer44:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; SkaterStatsCard; used by STATS
        db 0x0B, 0x3A
segMenuText36:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ShowPlayoffStandings, StandingsScreen; used by STATS
        db 0x48, 0x34
segDgroup7:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawStandingsPage; used by STATS
        db 0xC9, 0x45
segTeamChoiceText49:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LoadLeagueSchedule, ShowSeasonStandings; used by STATS
        db 0x01, 0x37
segDbFiles17:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; Gameloop, PlayGame; used by GAME
        db 0x15, 0x34
segDgroup8:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; LoadGameGfx; used by INIT
        db 0xC9, 0x45
segTeamChoiceText50:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x01, 0x37
segLinesMenuText1:                              ; segment constant 38AFh (lines_menu_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0xAF, 0x38
segMenuText37:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x48, 0x34
segWorkBuffer45:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x0B, 0x3A
segDbFiles18:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x15, 0x34
segTeamChoiceText51:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowStartingLineups; used by INIT
        db 0x01, 0x37
segWorkBuffer46:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowStartingLineups; used by INIT
        db 0x0B, 0x3A
JingleSegs:                                     ; segment words of the jingle data (LoadArenaJingles); used by
                                                ; INIT
        db 0xBD, 0x38, 0xBD, 0x38, 0xBD, 0x38, 0xBD, 0x38
segWorkBuffer47:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawPeriodTitle; used by INIT
        db 0x0B, 0x3A
segTeamChoiceText52:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x01, 0x37
segWorkBuffer48:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x0B, 0x3A
segDbFiles19:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x15, 0x34
segWorkBuffer49:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x0B, 0x3A
segWorkBuffer50:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowTeamStats; used by INIT
        db 0x0B, 0x3A
segDbFiles20:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; IntermissionScreens; used by INIT
        db 0x15, 0x34
segWorkBuffer51:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer52:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer53:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer54:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateGSummaryDb; used by INIT
        db 0x0B, 0x3A
segWorkBuffer55:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segWorkBuffer56:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segWorkBuffer57:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segTeamChoiceText53:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MakeGSummaryPath; used by INIT
        db 0x01, 0x37
segMenuText38:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ClearTeamNameText, SetTeamNameText; used by INIT
        db 0x48, 0x34
segMenuText39:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ClearTeamNameText, SetTeamNameText; used by INIT
        db 0x48, 0x34
segAnimSequences1:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xF6, 0x38
segAnimSequences2:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xF6, 0x38
segDgroup9:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xC9, 0x45
segAnimSequences3:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0xF6, 0x38
segAnimSequences4:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0xF6, 0x38
hmplstats:                                      ; home player stats; used by INIT
        db 0x0B, 0x3A
hmglstats:                                      ; home goalie stats; used by INIT
        db 0x0B, 0x3A
segObjectTable1:                                ; segment constant 3863h (object_table) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0x63, 0x38
segDgroup10:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; PlayHilight; used by AI
        db 0xC9, 0x45
segWorkBuffer58:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildEventLines; used by AI
        db 0x0B, 0x3A
segWorkBuffer59:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; Endfaceoff; used by AI
        db 0x0B, 0x3A
segWorkBuffer60:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PickThreeStars; used by AI
        db 0x0B, 0x3A
segWorkBuffer61:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PickThreeStars; used by AI
        db 0x0B, 0x3A
segDgroup11:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawRinkOverlays; used by AI
        db 0xC9, 0x45
AnimSeqSegs:                                    ; segment words of the animation sequences (DecayCrowdLevel,
                                                ; SetRinkObject); used by AI
        db 0xF6, 0x38, 0xF6, 0x38, 0xF6, 0x38
segDgroup12:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeVenetian; used by FADES1
        db 0xC9, 0x45
segDgroup13:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeVenetian; used by FADES1
        db 0xC9, 0x45
segDgroup14:                                    ; segment constant 45C9h (dgroup) loaded into es by FadeWipe;
                                                ; used by FADES2
        db 0xC9, 0x45
segDgroup15:                                    ; segment constant 45C9h (dgroup) loaded into es by FadeWipe;
                                                ; used by FADES2
        db 0xC9, 0x45
segDgroup16:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadePlaneBands; used by FADES3
        db 0xC9, 0x45
segDgroup17:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadePlaneBands; used by FADES3
        db 0xC9, 0x45
segDgroup18:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeBlockSweep; used by FADES5
        db 0xC9, 0x45
segDgroup19:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeSlideStrips; used by FADES6
        db 0xC9, 0x45
segDgroup20:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeSplitCenter; used by FADES7
        db 0xC9, 0x45
segDgroup21:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeRandomBlocks, FadeRandomBlocks2; used by FADES8
        db 0xC9, 0x45
segDgroup22:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDissolve; used by FADES9
        db 0xC9, 0x45
segDgroup23:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDissolve; used by FADES9
        db 0xC9, 0x45
segDgroup24:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeBoxGrow; used by FADES10
        db 0xC9, 0x45
segDgroup25:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDirectional; used by FADES11
        db 0xC9, 0x45
DgroupSegC:                                     ; DGROUP paragraph (relocated); used by
                                                ; DrawTextCenteredInWindow
        dw 0x45C9
DgroupSegD:                                     ; DGROUP paragraph (relocated); used by CalibrateStick
        dw 0x45C9
DgroupSegE:                                     ; DGROUP paragraph (relocated); used by DrawTextCenteredClip
        dw 0x45C9
DgroupSegF:                                     ; DGROUP paragraph (relocated); used by AskYesNoBox, PauseBox
        dw 0x45C9
PaletteFlagsSeg:                                ; paragraph of palette_flags; used by ShadeColor
        dw 0x3976
PaletteFlagsSeg2:                               ; paragraph of palette_flags; used by BuildShadeTable
        dw 0x3976
WorkBufferSeg:                                  ; paragraph of work_buffer; used by SendController
        dw 0x3A0B
WorkBufferSeg2:                                 ; paragraph of work_buffer; used by ParseMidiEvent
        dw 0x3A0B
WorkBufferSeg3:                                 ; paragraph of work_buffer; used by RestoreTrackVolumes
        db 0x0B, 0x3A
FpZero:                                         ; the double 0.0; FloatLoad compares against it
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, '<<NMSG>>'
NmsgTable:                                      ; runtime message table: message number word, then the text;
                                                ; searched by the message lookup
        db 0x00, 0x00, 'R6000', 0x0D, 0x0A, '- stack overflow', 0x0D, 0x0A, 0x00, 0x03, 0x00, 'R6003', 0x0D, 0x0A
        db '- integer divide by 0', 0x0D, 0x0A, 0x00, 0x09, 0x00, 'R6009', 0x0D, 0x0A
        db '- not enough space for environment', 0x0D, 0x0A, 0x00, 0xFC, 0x00, 0x0D, 0x0A, 0x00, 0xFF, 0x00
        db 'run-time error ', 0x00, 0x02, 0x00, 'R6002', 0x0D, 0x0A
        db '- floating-point support not loaded', 0x0D, 0x0A, 0x00, 0x01, 0x00, 'R6001', 0x0D, 0x0A
        db '- null pointer assignment', 0x0D, 0x0A, 0x00, 0xFD, 0x00, ': MATH', 0x0D, 0x0A
        db '- floating-point error: ', 0x00, 0x65, 0x00, 'invalid', 0x0D, 0x0A, 0x00, 0x66, 0x00
        db 'denormal', 0x0D, 0x0A, 0x00, 0x67, 0x00, 'divide by 0', 0x0D, 0x0A, 0x00, 0x68, 0x00
        db 'overflow', 0x0D, 0x0A, 0x00, 0x69, 0x00, 'underflow', 0x0D, 0x0A, 0x00, 0x6A, 0x00, 'inexact', 0x0D, 0x0A, 0x00
        db 0x6B, 0x00, 'unemulated', 0x0D, 0x0A, 0x00, 0x6C, 0x00, 'square root', 0x0D, 0x0A, 0x00, 0x6D, 0x00, 0x0D, 0x0A
        db 0x00, 0x6E, 0x00, 'stack overflow', 0x0D, 0x0A, 0x00, 0x6F, 0x00, 'stack underflow', 0x0D, 0x0A, 0x00, 0x70, 0x00
        db 'explicitly generated', 0x0D, 0x0A, 0x00, 0xFF, 0xFF, 0xFF
