; The playoff round names, the locker room text and the playoff mode screens.
str_SmytheDivisionalSemiFinals:                 ; string 'Smythe Divisional Semi-Finals'
        db 'Smythe Divisional Semi-Finals', 0x00
str_NorrisDivisionalSemiFinals:                 ; string 'Norris Divisional Semi-Finals'
        db 'Norris Divisional Semi-Finals', 0x00
str_PatrickDivisionalSemiFinals:                ; string 'Patrick Divisional Semi-Finals'
        db 'Patrick Divisional Semi-Finals', 0x00
str_AdamsDivisionalSemiFinals:                  ; string 'Adams Divisional Semi-Finals'
        db 'Adams Divisional Semi-Finals', 0x00
str_CampbellConferenceFinals:                   ; string 'Campbell Conference Finals'
        db 'Campbell Conference Finals', 0x00
str_WalesConferenceFinals:                      ; string 'Wales Conference Finals'
        db 'Wales Conference Finals', 0x00
str_StanleyCupFinals:                           ; string 'Stanley Cup Finals'
        db 'Stanley Cup Finals', 0x00
LockerTextPtrs:                                 ; text pointers of the locker room screen; used by MENUS
        dw str_SmytheDivisionalSemiFinals
        dw str_NorrisDivisionalSemiFinals
        dw str_PatrickDivisionalSemiFinals
        dw str_AdamsDivisionalSemiFinals
        dw str_CampbellConferenceFinals
        dw str_WalesConferenceFinals
        dw str_StanleyCupFinals
LockerItemTable:                                ; item table of the locker room screen; used by MENUS
        db 0xFF
        db 0xFF, 0x00, 0x00, 0x01, 0x00, 0x04, 0x00, 0x03, 0x00, 0x06, 0x00, 0x06, 0x00, 0xFF, 0xFF, 0x02
        db 0x00, 0x06, 0x00, 0x06, 0x00, 0xFF, 0xFF, 0x05
        db 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
str_Lockrm:                                     ; string 'lockrm'; used by MENUS
        db 'lockrm'
        db 0x00
str_P01_4:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_6:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_Exhgame2:                                   ; string 'exhgame2'; used by MENUS
        db 'exhgame2', 0x00
str_Botm:                                       ; string 'botm'; used by MENUS
        db 'botm', 0x00
str_Top:                                        ; string 'top '; used by MENUS
        db 'top ', 0x00
str_Head:                                       ; string 'head'; used by MENUS
        db 'head', 0x00
str_JerSh_2:                                    ; string 'JER%sH'; used by MENUS
        db 'JER%sH', 0x00
str_P01_3:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_5:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_JerSv_2:                                    ; string 'JER%sV'; used by MENUS
        db 'JER%sV', 0x00
str_P01_2:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_4:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_JerSv:                                      ; string 'JER%sV'; used by MENUS
        db 'JER%sV', 0x00
str_JerSh:                                      ; string 'JER%sH'; used by MENUS
        db 'JER%sH', 0x00
str_P01:                                        ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_3:                                     ; string '0000'; used by MENUS
        db '0000', 0x00, 0x00
str_POResult:                                   ; string '%s %d - %d'
        db '%s %d - %d', 0x00, 0x00
POResultFmt:                                    ; pointer to the playoff result format string; used by MENUS
        dw str_POResult
LeagueSetChoice:                                ; league settings choice (-1 none), also read by the playoff
                                                ; loop; used by MENUS
        db 0xFF, 0xFF
str_Easndesk_20:                                ; string 'easndesk'; used by MENUS
        db 'easndesk'
        db 0x00
str_Desk_17:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_66:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Embscup_4:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Bkgd_7:                                     ; string 'bkgd'; used by MENUS
        db 'bkgd', 0x00
str_Playoffs:                                   ; string 'playoffs'; used by MENUS
        db 'playoffs', 0x00
str_Palette_8:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Embpal_21:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_65:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_PleaseEnterNewPlayOffName:                  ; string 'Please Enter New Play-Off Name'; used by MENUS
        db 0x50
SpeechFileNames:                                ; speech file names; used by OpenSpeechFile
        db 'lease Enter New Play-Off Name'
        db 0x00
str_Po:                                         ; string '.PO'; used by MENUS
        db '.PO', 0x00
str_SDb:                                        ; string '\%s.db'; used by MENUS
        db 0x5C, '%s.db', 0x00
str_Err3_3:                                     ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Pal_64:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Wait:                                       ; string 'wait'; used by MENUS
        db 'wait', 0x00
str_Err3_2:                                     ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Err3:                                       ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Temp_15:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_19:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_16:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_ScheduleDb_6:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb_5:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb_4:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db '..', 0x00, '..', 0x00, 0x00
        db 'e1', 0x00, 'e2', 0x00, 0x00
        db 'f1', 0x00, 'f2', 0x00
str_Xx1_2:                                      ; string 'xx1'; used by MENUS
        db 'xx1', 0x00
        db 0x2E, 0x2E, 0x00
msgYourTeamHasBeenEliminated:                   ; message list of 4 far string pointers: 'Your team has been
                                                ; eliminated / from the play-offs. Do you / wish to see the
                                                ; final results / of the play-offs?'; used by MENUS
        dw str_YourTeamHasBeenEliminated, 0x36B8
        dw str_FromThePlayOffsDo, 0x36B8
        dw str_WishToSeeTheFinal, 0x36B8
        dw str_OfThePlayOffs, 0x36B8
msgTeamEliminatedFromPlayoffs:                  ; message list of 4 far string pointers: 'The
                                                ; ....,....,....,....,. / have been eliminated from / the
                                                ; play-offs. / The .....................'; used by MENUS
        dw str_The, 0x36B8
        dw str_HaveBeenEliminatedFrom, 0x36B8
        dw str_ThePlayOffs, 0x36B8
        dw str_The_2, 0x36B8
        dw str_WillContinueToTheNext, 0x36B8
        dw str_Series, 0x36B8
msgGeneratingTheFinalResults:                   ; message list of 1 far string pointer: 'Generating the final
                                                ; results.'; used by MENUS
        dw str_GeneratingTheFinalResults, 0x36B8
str_Db_4:                                       ; string '.db'; used by MENUS
        db '.db'
        db 0x00
str_Db_3:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Xx1:                                        ; string 'xx1'; used by MENUS
        db 'xx1', 0x00
        db 0x2E, 0x2E, 0x00
str_Tied_3:                                     ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_Tied_2:                                     ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_ScheduleDb_3:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db 0x2E, 0x2E, 0x00
str_ScheduleDb_2:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb:                                 ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db 0x2E, 0x2E, 0x00
str_GameSav_6:                                  ; string '\game.sav'; used by MENUS
        db '\game.sav', 0x00
str_Palette_7:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_GameSav_5:                                  ; string '\game.sav'; used by MENUS
        db 0x5C, 'game.sav', 0x00
str_Palette_6:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Space2:                                     ; string ' ' copied by PlayoffModeLoop; used by MENUS
        db 0x20, 0x00
str_Teeny05Fnt_3:                               ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup_3:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Palette_5:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Tied:                                       ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_Embpal_20:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_63:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Palette_4:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_GameSav_4:                                  ; string '\game.sav'; used by MENUS
        db 0x5C, 'game.sav', 0x00
str_Teeny05Fnt_2:                               ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup_2:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Palette_3:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Embpal_19:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_62:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Palette_2:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Easndesk_18:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_15:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pnt2_12:                                    ; string 'pnt2'; used by MENUS
        db 'pnt2', 0x00
str_Pointer_12:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00
str_Pntr_17:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Pnt2_11:                                    ; string 'pnt2'; used by MENUS
        db 'pnt2', 0x00
str_Pointer_11:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00
str_Pntr_16:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Pntr_15:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Teeny05Fnt:                                 ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup:                                    ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Embpal_18:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_61:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Menubuff_9:                                 ; string 'menubuff'; used by MENUS
        db 'menubuff', 0x00
str_PlayoffStandings:                           ; string 'Playoff standings'; used by MENUS
        db 'Playoff standings'
        db 0x00
str_CampbellConference_3:                       ; string 'Campbell Conference'; used by MENUS
        db 'Campbell Conference'
        db 0x00
str_WalesConference_3:                          ; string 'Wales Conference'; used by MENUS
        db 'Wales Conference'
        db 0x00, 0x00
