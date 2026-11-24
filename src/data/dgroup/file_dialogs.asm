; The save and load file dialogs: file names, messages and list state.
str_GsummaryDb_4:                               ; string 'gsummary.db'; used by MENUS
        db 'gsummary.db', 0x00
        db 'k2', 0x00, 'k3', 0x00
        db 'k4', 0x00, 'k5', 0x00
        db 'k6', 0x00, 'k7', 0x00
        db 'k8', 0x00, 'h7', 0x00
str_Db_6:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Sav_5:                                      ; string '.sav'; used by MENUS
        db '.sav', 0x00
str_Gsummary_5:                                 ; string 'gsummary'; used by MENUS
        db 'gsummary', 0x00
        db 0x41, 0x31, 0x00
str_PoGameSav:                                  ; string '.po\game.sav'; used by MENUS
        db '.po\game.sav', 0x00
        db 0x6C, 0x31, 0x00
str_Db_5:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Sav_4:                                      ; string '.sav'; used by MENUS
        db '.sav', 0x00
str_Gsummary_4:                                 ; string 'gsummary'; used by MENUS
        db 'gsummary', 0x00
        db 0x41, 0x32, 0x00
str_LpGameSav:                                  ; string '.lp\game.sav'; used by MENUS
        db '.lp\game.sav', 0x00
        db 0x6C, 0x32, 0x00
FileDlgSpecs:                                   ; file dialog table: pointer to the saved game list state
                                                ; (count, selection, top, rows) of each dialog; used by MENUS
        dw savedcount2
FileDlgSpec2:                                   ; list state of the second dialog; used by MENUS
        dw savedcount3
FileDlgSpec3:                                   ; list state of the third dialog; used by MENUS
        dw savedcount1
str_Lp_4:                                       ; string '*.lp'; used by ScanSavedGames
        db '*.lp', 0x00
str_Po_3:                                       ; string '*.po'; used by MENUS
        db '*.po', 0x00
str_Nhl_6:                                      ; string '*.nhl'; used by MENUS
        db '*.nhl', 0x00
str_Dialogbx:                                   ; string 'dialogbx'; used by MENUS
        db 'dialogbx', 0x00
str_Dbox_9:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Nhl_4:                                      ; string '.NHL'; not used by the EXE or the overlays
        db '.NHL', 0x00
        db '.PO', 0x00
        db '.LP', 0x00
        db 0x63, 0x32, 0x00
str_AllFiles:                                   ; string '*.*'; used by MENUS
        db '*.*', 0x00
        db 'c3', 0x00, '..', 0x00
        db 'c4', 0x00, 'c5', 0x00
        db 0x63, 0x36, 0x00, 0x00
msgConfirmDeletionOfThe:                        ; message list of 1 far string pointer: 'Confirm Deletion of
                                                ; the'; used by MENUS
        dw str_ConfirmDeletionOfThe, 0x369A
DelFileName:                                    ; far pointer (offset) to the saved game DeleteSavedGame
                                                ; removes; used by MENUS
        db 0x00, 0x00
DelFileNameSeg:                                 ; its segment; used by MENUS
        db 0x00, 0x00
DelFileName2:                                   ; far pointer (offset) to the second file DeleteSavedGame
                                                ; removes; used by MENUS
        db 0x00, 0x00
DelFileName2Seg:                                ; its segment; used by MENUS
        db 0x00, 0x00
str_Nhl_5:                                      ; string '.nhl'; used by MENUS
        db '.nhl', 0x00
str_Po_2:                                       ; string '.po'; used by MENUS
        db '.po', 0x00
str_Lp_2:                                       ; string '.lp'; used by MENUS
        db '.lp', 0x00
        db 0x64, 0x31, 0x00
str_GameSet_3:                                  ; string 'game.set'; used by MENUS
        db 'game.set', 0x00
        db 0x64, 0x32, 0x00
str_Dd2:                                        ; string 'dd2'; used by MENUS
        db 'dd2', 0x00
        db 'd3', 0x00, 'd4', 0x00
str_GameSav_7:                                  ; string 'game.sav'; used by MENUS
        db 'game.sav', 0x00
        db 0x2E, 0x2E, 0x00, 0x64, 0x35, 0x00, 0x00
