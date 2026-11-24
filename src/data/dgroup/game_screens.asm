; The screens around a game: fades, matchup, lineups, arena jingles, period titles, game and team
; summaries, title movies, team database names, rink tiles, the scoreboard and the replay controls.
FadeSteps:                                      ; fade step table (FadePalette); used by GAME
        db 0x01
FadeStep:                                       ; current fade step; used by GAME
        db 0x0F
FadeSteps2:                                     ; second fade step table; used by GAME
        db 0x01, 0xFF
FadeCount:                                      ; fade step count; used by GAME
        db 0x11, 0xFF, 0x5C, 0x00
str_GameSav_2:                                  ; string 'game.sav'; used by GAME
        db 'game.sav', 0x00, 0x00
DirtyRects:                                     ; dirty rectangle list (20 per page); used by GAME
        db 0x00, 0x00, 0x00, 0x00
DeskRedrawPage:                                 ; page redraw flags; used by AI, GAME, INIT, MENUS
        db 0x00, 0x00
DeskRedrawPage2:                                ; second page redraw flag; used by AI, GAME, INIT, MENUS
        db 0x00, 0x00
SpriteBlitFns:                                  ; far routine table of the sprite blitters
                                                ; (DrawSpriteClipped); used by GAME
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw DrawRleTransFastAt, 0x0FEF
        dw DrawRleTransAt, 0x0FEF
        dw DrawRleTransRemapAt, 0x0FEF
        dw DrawRleTransRemapFastAt, 0x0FEF
        dw DrawRleFlipAt, 0x0FEF
        dw DrawRleFlipTransAt, 0x0FEF
        dw DrawRleFlipRemapAt, 0x0FEF
        dw DrawRleFlipTransRemapAt, 0x0FEF
        db '%04d', 0x00
str_FD50D99:                                    ; string 'f%d50_%d99'; used by INIT
        db 'f%d50_%d99', 0x00
str_FD00D49:                                    ; string 'f%d00_%d49'; used by INIT
        db 'f%d00_%d49', 0x00
str_04d_3:                                      ; string '%04d'; used by INIT
        db '%04d', 0x00
str_D50D99:                                     ; string '%d50_%d99'; used by INIT
        db '%d50_%d99', 0x00
str_D00D49:                                     ; string '%d00_%d49'; used by INIT
        db '%d00_%d49', 0x00
str_Trinknd:                                    ; string 'trinknd'; used by INIT
        db 'trinknd', 0x00
str_0000_2:                                     ; string '0000'; used by INIT
        db '0000', 0x00
str_Numshp:                                     ; string 'numshp'; used by INIT
        db 'numshp', 0x00
str_04d_2:                                      ; string '%04d'; used by INIT
        db '%04d', 0x00
str_000g000d000d000l000c000r000x:               ; string '000G000D000D000L000C000R000X'; used by INIT
        db '000G000D000D000L000C000R000X'
        db 0x00
MatchupOrder:                                   ; order bytes of the matchup screen; used by INIT
        db 0x00, 0x01, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A
        db 0x0B, 'apal', 0x00
str_Pal_11:                                     ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_S1Fnt_4:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Wittle06Fnt_3:                              ; string 'wittle06.fnt'; used by INIT
        db 'wittle06.fnt', 0x00
str_Arena:                                      ; string 'arena'; used by INIT
        db 'arena', 0x00
str_Pal_10:                                     ; string '!pal'; used by INIT
        db '!pal', 0x00
str_Rink:                                       ; string 'rink'; used by INIT
        db 'rink', 0x00
str_SAtS:                                       ; string '%s at %s'; used by INIT
        db '%s at %s', 0x00
        db '%d', 0x00, '%d', 0x00
str_Pointer_4:                                  ; string 'Pointer'; used by INIT
        db 'Pointer', 0x00
str_Pal_9:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_8:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00, 0x00
str_Crests4_4:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Summary_3:                                  ; string 'summary'; used by INIT
        db 'summary', 0x00
str_City_3:                                     ; string 'city'; used by INIT
        db 'city', 0x00
str_Summary2_2:                                 ; string 'summary2'; used by INIT
        db 'summary2', 0x00
str_Defnforwlineootspairscrasummtoni_2:         ; string 'defnforwlineootspairscrasummtoni'; used by INIT
        db 'defnforwlineootspairscrasummtoni'
        db 0x00
str_Crests2Bin_3:                               ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt_3:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Gipk:                                       ; string 'GIPK'; used by INIT
        db 'GIPK', 0x00
str_Injured_2:                                  ; string 'Injured'; used by INIT
        db 'Injured', 0x00, 0x00
str_Mtrocku_2:                                  ; string 'MTROCKU'; used by INIT
        db 'MTROCKU', 0x00
str_Sbrocku_2:                                  ; string 'SBROCKU'; used by INIT
        db 'SBROCKU', 0x00
str_Adrocku_2:                                  ; string 'ADROCKU'; used by INIT
        db 'ADROCKU', 0x00
str_Mtrocku:                                    ; string 'MTROCKU'; used by INIT
        db 'MTROCKU', 0x00
str_Sbrocku:                                    ; string 'SBROCKU'; used by INIT
        db 'SBROCKU', 0x00
str_Adrocku:                                    ; string 'ADROCKU'; used by INIT
        db 'ADROCKU', 0x00
str_Rockditi_2:                                 ; string 'ROCKDITI'; used by INIT
        db 'ROCKDITI', 0x00
str_Rockditi:                                   ; string 'ROCKDITI'; used by INIT
        db 'ROCKDITI', 0x00
str_FirstPeriod:                                ; string 'First Period'; used by INIT
        db 'First Period', 0x00
str_SecondPeriod:                               ; string 'Second Period'; used by INIT
        db 'Second Period', 0x00
str_ThirdPeriod:                                ; string 'Third Period'; used by INIT
        db 'Third Period', 0x00
str_OvertimePeriodD:                            ; string 'Overtime Period %d'; used by INIT
        db 'Overtime Period %d'
        db 0x00
str_Overtime:                                   ; string 'Overtime'; used by INIT
        db 'Overtime', 0x00
str_MtsumKms_2:                                 ; string 'mtsum.kms'; used by INIT
        db 'mtsum.kms', 0x00
str_MtsumCfg_2:                                 ; string 'mtsum.cfg'; used by INIT
        db 'mtsum.cfg', 0x00
str_AdsumKms_2:                                 ; string 'adsum.kms'; used by INIT
        db 'adsum.kms', 0x00
str_AdsumCfg_2:                                 ; string 'adsum.cfg'; used by INIT
        db 'adsum.cfg', 0x00
str_Crests4_3:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Summary_2:                                  ; string 'summary'; used by INIT
        db 'summary', 0x00
str_City_2:                                     ; string 'city'; used by INIT
        db 'city', 0x00
str_Summary2:                                   ; string 'summary2'; used by INIT
        db 'summary2', 0x00
str_Defnforwlineootspairscrasummtoni:           ; string 'defnforwlineootspairscrasummtoni'; used by INIT
        db 'defnforwlineootspairscrasummtoni'
        db 0x00
str_Crests2Bin_2:                               ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt_2:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Gsummary_2:                                 ; string 'gsummary'; used by INIT
        db 'gsummary', 0x00
        db '%d', 0x00, '%d', 0x00
str_1st:                                        ; string '1st'; used by INIT
        db '1st', 0x00
str_2nd:                                        ; string '2nd'; used by INIT
        db '2nd', 0x00
str_3rd:                                        ; string '3rd'; used by INIT
        db '3rd', 0x00
        db 0x4F, 0x54, 0x00
str_FinalOt:                                    ; string 'Final (OT)'; used by INIT
        db 'Final (OT)', 0x00
str_Final:                                      ; string 'Final'; used by INIT
        db 'Final', 0x00
str_Period:                                     ; string ' period'; used by INIT
        db ' period', 0x00
str_Injured:                                    ; string 'Injured'; used by INIT
        db 'Injured', 0x00
str_Evnt:                                       ; string 'EVNT'; used by INIT
        db 'EVNT', 0x00
str_Prds:                                       ; string 'PRDS'; used by INIT
        db 'PRDS', 0x00
        db 0x25, 0x73, 0x00
str_D_3:                                        ; string ' (%d'; used by INIT
        db ' (%d', 0x00
str_St:                                         ; string 'st)'; used by INIT
        db 'st)', 0x00
str_Nd:                                         ; string 'nd)'; used by INIT
        db 'nd)', 0x00
str_Rd:                                         ; string 'rd)'; used by INIT
        db 'rd)', 0x00
str_Th:                                         ; string 'th)'; used by INIT
        db 'th)', 0x00
str_Sh_2:                                       ; string ' SH'; used by INIT
        db ' SH', 0x00
str_Pp_2:                                       ; string ' PP'; used by INIT
        db ' PP', 0x00
str_02d02d_2:                                   ; string '%02d:%02d'; used by INIT
        db '%02d:%02d', 0x00
str_S_2:                                        ; string '(%s'; used by INIT
        db '(%s', 0x00
        db ', ', 0x00, 0x29, 0x00
        db 0x25, 0x73, 0x00
str_SS_2:                                       ; string '%s    %s'; used by INIT
        db '%s    %s', 0x00
str_SDMinS:                                     ; string '%s %d min.: %s'; used by INIT
        db '%s %d min.: %s', 0x00
str_02d02d:                                     ; string '%02d:%02d'; used by INIT
        db '%02d:%02d', 0x00
str_ShotsOnGoal:                                ; string 'Shots on goal'; used by INIT
        db 'Shots on goal', 0x00
str_SDD_2:                                      ; string '%s %d/%d'; used by INIT
        db '%s %d/%d', 0x00
str_SDD:                                        ; string '%s %d/%d'; used by INIT
        db '%s %d/%d', 0x00, 0x00
str_MtsumKms:                                   ; string 'mtsum.kms'; used by INIT
        db 'mtsum.kms', 0x00
str_MtsumCfg:                                   ; string 'mtsum.cfg'; used by INIT
        db 'mtsum.cfg', 0x00
str_AdsumKms:                                   ; string 'adsum.kms'; used by INIT
        db 'adsum.kms', 0x00
str_AdsumCfg:                                   ; string 'adsum.cfg'; used by INIT
        db 'adsum.cfg', 0x00
str_Summary:                                    ; string 'summary'; used by INIT
        db 'summary', 0x00
str_Crests4_2:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Crests2Bin:                                 ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt:                                      ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_City:                                       ; string 'city'; used by INIT
        db 'city', 0x00
        db '%d', 0x00, '%d', 0x00
str_DD_2:                                       ; string '%d/%d'; used by INIT
        db '%d/%d', 0x00
str_DD:                                         ; string '%d/%d'; used by INIT
        db '%d/%d', 0x00
        db '%d', 0x00, '%d', 0x00
str_D02d:                                       ; string '%d:%02d'; used by INIT
        db '%d:%02d', 0x00
str_DDD:                                        ; string '%d/%d (%d%%)'; used by INIT
        db '%d/%d (%d%%)', 0x00, 0x00
TeamStatsLabels:                                ; message list of 4 far string pointers: 'Score / Shots /
                                                ; Power play / Penalties'; used by INIT
        dw str_Score
TeamStatsLabelPtrs:                             ; label pointers of the team stats summary; used by INIT
        dw 0x38EB
        dw str_Shots_5, 0x38EB
        dw str_PowerPlay_3, 0x38EB
        dw str_Penalties_2, 0x38EB
        dw str_FaceoffsWon, 0x38EB
        dw str_BodyChecks, 0x38EB
        dw str_AttackZone, 0x38EB
        dw str_Passing_2, 0x38EB
        db 'Geneva11.fnt', 0x00, '#%d   %s %s', 0x00, '#%d   %c. %s', 0x00, 'key', 0x00, 'career', 0x00
        db 'season', 0x00, 'GP', 0x00, 0x57, 0x00, 0x4C, 0x00, 0x54, 0x00, 'SO', 0x00, 'GAA', 0x00, 'Pct', 0x00
        db 'player%d', 0x00, 'Geneva11.fnt', 0x00, 'HAT  TRICK', 0x00, '1ST  NHL  GOAL', 0x00, '%dTH  ', 0x00
        db 'CAREER  ', 0x00, 'PLAYOFF  ', 0x00, 'POINT', 0x00, 'GOAL', 0x00, '%s', 0x00, '#%d   %s %s', 0x00
        db '#%d   %c. %s', 0x00, 'key', 0x00, 'career', 0x00, 'season', 0x00, 'GP', 0x00, 0x47, 0x00, 0x41, 0x00
        db 'Pt', 0x00, 'CG', 0x00, 'CA', 0x00, 'CPt', 0x00, 'PIM', 0x00, '+/-', 0x00, 'Pct', 0x00, 0x00
hilightsplayed:                                 ; bits of the highlights already shown; used by INIT
        db 0x00, 0x00
str_Pal_7:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_6:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_5:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
        db 0x41, 0x00, 0x48, 0x00
str_P1Mvi:                                      ; string 'P1.MVI'; used by INIT
        db 'P1.MVI', 0x00
        db 0x41, 0x00, 0x48, 0x00
str_G1Mvi:                                      ; string 'G1.MVI'; used by INIT
        db 'G1.MVI', 0x00
        db 0x41, 0x00, 0x48, 0x00
        db 'G2.QPP', 0x00
str_Pal_4:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_EascrnQpp:                                  ; string 'EASCRN.QPP'; used by INIT
        db 'EASCRN.QPP', 0x00
str_Scrn:                                       ; string 'scrn'; used by INIT
        db 'scrn', 0x00
str_Pal_3:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_0000:                                       ; string '0000'; used by INIT
        db '0000', 0x00
str_Stop:                                       ; string 'stop'; used by INIT
        db 'stop', 0x00
str_Qpp_2:                                      ; string '.qpp'; used by INIT
        db '.qpp', 0x00
str_Logo:                                       ; string 'logo'; used by INIT
        db 'logo', 0x00
str_Pal_2:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_Vidframe:                                   ; string 'vidframe'; used by INIT
        db 'vidframe', 0x00, 0x00
str_Teams_2:                                    ; string 'teams'; used by INIT
        db 'teams', 0x00
        db 0x31, 0x00, 0x32, 0x00
        db 0x33, 0x00, 0x34, 0x00
        db 0x35, 0x00
str_Teams:                                      ; string 'teams'; used by INIT
        db 'teams', 0x00
        db 0x31, 0x00, 0x32, 0x00
        db 0x33, 0x00, 0x37, 0x00
        db 0x38, 0x00, 'B1', 0x00
        db 'B5', 0x00, 'B8', 0x00
        db 0x44, 0x00, 0x45, 0x00
        db 0x46, 0x00, 0x47, 0x00
        db 0x48, 0x00, 0x49, 0x00
        db 0x4C, 0x00, 0x4D, 0x00
        db 0x4E, 0x00, 0x4F, 0x00
        db 0x50, 0x00, 0x51, 0x00
str_Key:                                        ; string 'key'; used by INIT
        db 'key', 0x00
        db 0x39, 0x00, 0x41, 0x00
str_Att:                                        ; string 'att'; used by INIT
        db 'att', 0x00
        db 0x42, 0x00, 0x43, 0x00
str_Season_2:                                   ; string 'season'; used by INIT
        db 'season', 0x00
        db 0x4A, 0x00, 0x4B, 0x00
str_Career_2:                                   ; string 'career'; used by INIT
        db 'career', 0x00
        db 0x4C, 0x00, 0x4D, 0x00, 0x00, 0x07, 0x00, 0x04, 0x00, 0x03, 0x00, 0x06, 0x00, 0x01, 0x00, 0x08
        db 0x00, 0x02, 0x00, 0x00, 0x00
        db 0x5C, 0x00
str_GsummaryDb_3:                               ; string 'gsummary.db'; used by INIT
        db 'gsummary.db', 0x00
str_RinkTil_2:                                  ; string 'rink.til'; used by INIT
        db 'rink.til', 0x00
str_InvalidFileRinkTilSizeS:                    ; string 'Invalid file 'RINK.TIL' size %s\n'; used by INIT
        db 'Invalid file ', 0x27, 'RINK.TIL', 0x27, ' size %s'
        db 0x0A, 0x00
str_RinkTil:                                    ; string 'rink.til'; used by INIT
        db 'rink.til', 0x00
str_STil:                                       ; string '%s.til'; used by INIT
        db '%s.til', 0x00
str_InvalidFileSSizeD:                          ; string 'Invalid file '%s' size %d\n'; used by INIT
        db 'Invalid file ', 0x27, 0x25, 0x73, 0x27, ' size %d'
        db 0x0A, 0x00
str_RinkMap:                                    ; string 'rink.map'; used by INIT
        db 'rink.map', 0x00
str_SMap:                                       ; string '%s.map'; used by INIT
        db '%s.map', 0x00, 0x00
        db 'BOS', 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x42, 0x55, 0x46, 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x43, 0x47, 0x59, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x43, 0x48, 0x49, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x44, 0x45, 0x54, 0x00, 0x15, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x45, 0x44, 0x4D, 0x00, 0x16, 0x00
        db 0x2C, 0x00, 0x19, 0x00
        db 0x23, 0x00, 'HFD', 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4C, 0x41, 0x20, 0x00
        db 0x20, 0x00, 0x2D, 0x00, 0x0F, 0x00
        db 0x22, 0x00, 'MIN', 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4D, 0x54, 0x4C, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E, 0x4A, 0x20, 0x00, 0x1E, 0x00
        db 0x2D, 0x00, 0x11, 0x00
        db 0x22, 0x00, 'NYI', 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E, 0x59, 0x52, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4F, 0x54, 0x54, 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x50, 0x48, 0x49, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x50, 0x49, 0x54, 0x00, 0x0D, 0x00, 0x1F, 0x00
        db 0x22, 0x00, 0x30, 0x00
        db 'QUE', 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x53, 0x54, 0x4C, 0x00, 0x15, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x53, 0x4A, 0x20, 0x00, 0x13, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x54, 0x42, 0x20, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x54, 0x4F, 0x52, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x56, 0x41, 0x4E, 0x00, 0x15, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x57, 0x53, 0x48, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x57, 0x50, 0x47, 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF
str_Scrbrd1:                                    ; string 'scrbrd1'; used by INIT
        db 'scrbrd1', 0x00
str_0000000100020003000400050006000700080009000: ; string '0000000100020003000400050006000700080009000 '
                                                ; used by INIT
        db '0000000100020003000400050006000700080009000 '
        db 0x00
str_1000100110021003100410051006100710081009100: ; string '1000100110021003100410051006100710081009100 '
                                                ; used by INIT
        db '1000100110021003100410051006100710081009100 '
        db 0x00
str_2000200120022003200420052006200720082009200: ; string '2000200120022003200420052006200720082009200 '
                                                ; used by INIT
        db '2000200120022003200420052006200720082009200 '
        db 0x00
str_VlinvppVpk:                                 ; string 'vlinvpp vpk '; used by INIT
        db 'vlinvpp vpk ', 0x00
str_HlinhppHpk:                                 ; string 'hlinhpp hpk '; used by INIT
        db 'hlinhpp hpk ', 0x00
str_Visp:                                       ; string 'visp'; used by INIT
        db 'visp', 0x00
str_Homp:                                       ; string 'homp'; used by INIT
        db 'homp', 0x00
str_Lin1lin2lin3lin4pp1Pp2Pk1:                  ; string 'lin1lin2lin3lin4PP1 PP2 PK1 PK2 '; used by INIT
        db 'lin1lin2lin3lin4PP1 PP2 PK1 PK2 '
        db 0x00, 0x09, 0x00, 0xB1, 0x00, 0x1C, 0x00, 0xBD
        db 0x00
ReplayGadgetRects:                              ; replay gadget rectangles; used by INIT
        db 0x92, 0x02, 0x21, 0x00, 0xB1, 0x00
        db 0x34, 0x00, 0xBD, 0x00, 0x98, 0x02, 0x39, 0x00, 0xB1, 0x00
        db 0x4C, 0x00, 0xBD, 0x00
ReplayGadgetRect2:                              ; replay gadget rectangle 2; used by INIT
        db 0x9E, 0x02, 0x51, 0x00, 0xB1, 0x00
        db 0x64, 0x00, 0xBD, 0x00, 0xA4, 0x02, 0x69, 0x00, 0xB1, 0x00
        db 0x7C, 0x00, 0xBD, 0x00, 0xAA, 0x02, 0x81, 0x00, 0xB1, 0x00, 0x94, 0x00, 0xBD, 0x00, 0xB0, 0x02
        db 0xA7, 0x00, 0xB1, 0x00, 0xD3, 0x00, 0xBD, 0x00
ReplayGadgetRect3:                              ; replay gadget rectangle 3; used by INIT
        db 0xB9, 0x02, 0xD8, 0x00, 0xB1, 0x00, 0x04, 0x01
        db 0xBD, 0x00, 0xC6, 0x02, 0x09, 0x01, 0xB1, 0x00
        db 0x35, 0x01, 0xBD, 0x00, 0xD2, 0x02, 0xD8, 0x00
        db 0xB1, 0x00, 0x04, 0x01, 0xBD, 0x00
ReplayPointerRect:                              ; replay pointer rectangle; used by INIT
        db 0xC6, 0x02, 'Pointer'
        db 0x00
str_BothTeams:                                  ; string 'Both Teams'; used by INIT
        db 'Both Teams', 0x00
str_NeitherTeams:                               ; string 'Neither Teams'; used by INIT
        db 'Neither Teams', 0x00
str_SaveTo_2:                                   ; string 'Save To'; used by INIT
        db 'Save To', 0x00
str_HilightsReel_2:                             ; string 'Hilights Reel'; used by INIT
        db 'Hilights Reel', 0x00
str_SaveTo:                                     ; string 'Save To'; used by INIT
        db 'Save To', 0x00
str_HilightsReel:                               ; string 'Hilights Reel'; used by INIT
        db 'Hilights Reel', 0x00
        db 'k1', 0x00, 0x5C, 0x00
str_Hi_2:                                       ; string '.HI'; used by INIT
        db '.HI', 0x00
        db 0x66, 0x31, 0x00
str_CanNotOpenSFile:                            ; string 'Can not open `%s' file\n'; used by INIT
        db 'Can not open `%s', 0x27
        db ' file'
        db 0x0A, 0x00, 'f3', 0x00
        db 'f4', 0x00, 0x00
str_ErrorLoadingGame:                           ; string 'Error Loading Game\n'; used by INIT
        db 'Error Loading Game'
        db 0x0A, 0x00
str_ErrorSavingGame:                            ; string 'Error Saving Game\n'; used by INIT
        db 'Error Saving Game'
        db 0x0A, 0x00, 0x00
str_Gadget5:                                    ; string 'gadget5'; used by INIT
        db 'gadget5', 0x00
str_Gad1:                                       ; string 'gad1'; used by INIT
        db 'gad1', 0x00
str_Gg02d_2:                                    ; string 'gg%02d'; used by INIT
        db 'gg%02d', 0x00
str_Gg02d:                                      ; string 'gg%02d'; used by INIT
        db 'gg%02d', 0x00
str_HilightFnt:                                 ; string 'HILIGHT.FNT'; used by INIT
        db 'HILIGHT.FNT', 0x00, 0x00
