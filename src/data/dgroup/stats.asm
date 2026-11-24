; The statistics screens: stats menus, standings, player cards, rosters, team stats and leaders.
str_Pnt2_6:                                     ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pointer_7:                                  ; string 'Pointer'; used by STATS
        db 'Pointer', 0x00
str_Pntr_9:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Pnt2_5:                                     ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pntr_8:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Menubuff_3:                                 ; string 'menubuff'; used by STATS
        db 'menubuff', 0x00
str_Pnt2_4:                                     ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pointer_6:                                  ; string 'Pointer'; used by STATS
        db 'Pointer', 0x00
str_Pntr_7:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Pnt2_3:                                     ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pntr_6:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Menubuff_2:                                 ; string 'menubuff'; used by STATS
        db 'menubuff', 0x00
str_Pntr_5:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Pnt2_2:                                     ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pointer_5:                                  ; string 'Pointer'; used by STATS
        db 'Pointer', 0x00
str_Pntr_4:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Pnt2:                                       ; string 'pnt2'; used by STATS
        db 'pnt2', 0x00
str_Pntr_3:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00
str_Menubuff:                                   ; string 'menubuff'; used by STATS
        db 'menubuff', 0x00
str_Pntr_2:                                     ; string 'pntr'; used by STATS
        db 'pntr', 0x00, 0x00
str_SmytheDivision:                             ; string 'Smythe Division'
        db 'Smythe Division', 0x00
str_NorrisDivision:                             ; string 'Norris Division'
        db 'Norris Division', 0x00
str_AdamsDivision:                              ; string 'Adams Division'
        db 'Adams Division', 0x00
str_PatrickDivision:                            ; string 'Patrick Division'
        db 'Patrick Division', 0x00
str_Season_4:                                   ; string 'Season:'
        db 'Season:', 0x00
str_Playoff_2:                                  ; string 'Playoff:'; used by LP
        db 'Playoff:', 0x00
str_RegSeason:                                  ; string 'reg. season'
        db 'reg. season', 0x00
str_Playoff_4:                                  ; string 'playoff    '
        db 'playoff    ', 0x00
str_Actual:                                     ; string 'actual     '
        db 'actual     ', 0x00
str_Accumulated:                                ; string 'accumulated'
        db 'accumulated', 0x00
str_Embnhl_5:                                   ; string 'embnhl'
        db 'embnhl', 0x00
str_Embscup_5:                                  ; string 'embscup'
        db 'embscup', 0x00
str_CareerDb:                                   ; string 'career.db'
        db 'career.db', 0x00
str_SeasonDb:                                   ; string 'season.db'
        db 'season.db', 0x00
str_CarteamsDb:                                 ; string 'carteams.db'
        db 'carteams.db', 0x00
str_TeamsDb_2:                                  ; string 'teams.db'
        db 'teams.db', 0x00, 0x00
StandingsHeadPtrs:                              ; column heading pointers of the standings screen; used by
                                                ; STATS
        dw str_SmytheDivision
        dw str_NorrisDivision
        dw str_AdamsDivision
        dw str_PatrickDivision
        dw str_Season_4
        dw str_Playoff_2
        dw str_RegSeason
        dw str_Playoff_4
        dw str_Actual
        dw str_Accumulated
StatsDbNames:                                   ; database file name pointers of the stats screens
                                                ; (BuildPathFar); used by STATS
        dw str_Embnhl_5
        dw str_Embscup_5
StatsDbNames2:                                  ; second set of database file name pointers (roster and stats
                                                ; cards); used by STATS
        dw str_CareerDb
        dw str_SeasonDb
StatsDbNames3:                                  ; database file name pointers of the leaders and team stats
                                                ; screens; used by STATS
        dw str_CarteamsDb
StatsDbName4:                                   ; database file name pointer of the roster screen; used by
                                                ; STATS
        dw str_TeamsDb_2
str_AttDb:                                      ; string 'att.db'; used by STATS
        dw str_Empty
        db 't.db', 0x00, 0x00
str_2d:                                         ; string '%2d'; used by STATS
        db '%2d', 0x00
str_3d:                                         ; string '%3d'; used by STATS
        db '%3d', 0x00
str_4d:                                         ; string '%4d'; used by STATS
        db '%4d', 0x00
str_5d:                                         ; string '%5d'; used by STATS
        db '%5d', 0x00
str_3d1d:                                       ; string '%3d.%1d'; used by STATS
        db '%3d.%1d', 0x00
str_1d03d:                                      ; string '%1d.%03d'; used by STATS
        db '%1d.%03d', 0x00, 0x00
str_03d:                                        ; string ' .%03d'; used by STATS
        db ' .%03d', 0x00, 0x00
str_2d22d:                                      ; string '%2d.%2.2d'; used by STATS
        db '%2d.%2.2d', 0x00
str_EmbS:                                       ; string 'emb%s'; used by STATS
        db 'emb%s', 0x00
str_Bkgd:                                       ; string 'bkgd'; used by MENUS, STATS
        db 'bkgd', 0x00, 0x00
str_EasnFnt:                                    ; string 'EASN.fnt'; used by STATS
        db 'EASN.fnt', 0x00, 0x00
str_Wittle06Fnt_2:                              ; string 'wittle06.fnt'; not used by the EXE or the overlays
str_Wittle06Fnt_4:                              ; string 'wittle06.fnt'; used by AI
        db 'wittle06.fnt', 0x00, 0x00
statscontext:                                   ; stats context: which season or playoff data the stats
                                                ; screens show (0..5); used by STATS
        db 0x00, 0x00
statsseason:                                    ; stats season choice; used by STATS
        db 0x00, 0x00
str_Sfh:                                        ; string 'sfh'; used by STATS
        db 'sfh', 0x00
str_Shape:                                      ; string 'shape'; used by STATS
        db 'shape', 0x00
str_Crests3Bin:                                 ; string 'CRESTS3.BIN'; used by STATS
        db 'CRESTS3.BIN', 0x00
str_Pal_30:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00, 0x00
str_GloveLeft:                                  ; string 'Glove Left'
        db 'Glove Left', 0x00
str_GloveRight:                                 ; string 'Glove Right'
        db 'Glove Right', 0x00
str_StickLeft:                                  ; string 'Stick Left'
        db 'Stick Left', 0x00
str_StickRight:                                 ; string 'Stick Right'
        db 'Stick Right', 0x00
str_PuckControl:                                ; string 'Puck Control'
        db 'Puck Control', 0x00
str_Speed:                                      ; string 'Speed'
        db 'Speed', 0x00
str_Agility:                                    ; string 'Agility'
        db 'Agility', 0x00
str_Weight:                                     ; string 'Weight'
        db 'Weight', 0x00
str_OffensiveAwareness:                         ; string 'Offensive Awareness'
        db 'Offensive Awareness', 0x00
str_DefensiveAwareness:                         ; string 'Defensive Awareness'
        db 'Defensive Awareness', 0x00
str_Portrait_2:                                 ; string 'portrait'; used by STATS
        db 'portrait', 0x00
str_Pal_29:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_SS_4:                                       ; string '%s %s'; used by STATS
        db '%s %s', 0x00
str_DGoalie:                                    ; string '%d Goalie'; used by STATS
        db '%d Goalie', 0x00
str_Gp_7:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_Min_2:                                      ; string ' Min'; used by STATS
        db ' Min', 0x00
str_Gaa_2:                                      ; string '  GAA'; used by STATS
        db '  GAA', 0x00
str_W_3:                                        ; string ' W'; used by STATS
        db 0x20, 0x57, 0x00
str_L_5:                                        ; string ' L'; used by STATS
        db 0x20, 0x4C, 0x00
str_T_3:                                        ; string ' T'; used by STATS
        db 0x20, 0x54, 0x00
str_So:                                         ; string 'SO'; used by STATS
        db 0x53, 0x4F, 0x00
str_En:                                         ; string 'EN'; used by STATS
        db 0x45, 0x4E, 0x00
str_Sa_2:                                       ; string '   SA'; used by STATS
        db '   SA', 0x00
str_Pct_4:                                      ; string '  Pct'; used by STATS
        db '  Pct', 0x00
str_Ratings_2:                                  ; string 'Ratings:'; used by STATS
        db 'Ratings:', 0x00
str_GloveHand:                                  ; string 'Glove_Hand'; used by STATS
        db 'Glove_Hand', 0x00
str_L_4:                                        ; string '  L'; used by STATS
        db '  L', 0x00
str_R_2:                                        ; string '  R'; used by STATS
        db '  R', 0x00, 0x00
        dw str_GloveLeft
        dw str_GloveRight
        dw str_StickLeft
        dw str_StickRight
        dw str_PuckControl
        dw str_Speed
        dw str_Agility
        dw str_Weight
        dw str_OffensiveAwareness
        dw str_DefensiveAwareness
GoalieCardCols:                                 ; column order bytes of the goalie stats card; used by STATS
        db 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08
        db 0x0A, 0x0B, 'Plane 0'
        db 0x00
str_Plane1_3:                                   ; string 'Plane 1'; used by STATS
        db 'Plane 1', 0x00
str_Plane2_3:                                   ; string 'Plane 2'; used by STATS
        db 'Plane 2', 0x00
str_Plane3_3:                                   ; string 'Plane 3'; used by STATS
        db 'Plane 3', 0x00
str_Embpal_15:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_28:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_14:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_27:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_13:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_26:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Plane0_2:                                   ; string 'Plane 0'; used by STATS
        db 'Plane 0', 0x00
str_Plane1_2:                                   ; string 'Plane 1'; used by STATS
        db 'Plane 1', 0x00
str_Plane2_2:                                   ; string 'Plane 2'; used by STATS
        db 'Plane 2', 0x00
str_Plane3_2:                                   ; string 'Plane 3'; used by STATS
        db 'Plane 3', 0x00
str_Tstat_3:                                    ; string 'tstat'; used by STATS
        db 'tstat', 0x00
str_Keys_4:                                     ; string 'keys'; used by STATS
        db 'keys', 0x00
str_Pstat_4:                                    ; string 'pstat'; used by STATS
        db 'pstat', 0x00
str_Gstat_4:                                    ; string 'gstat'; used by STATS
        db 'gstat', 0x00
str_Embpal_12:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_25:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00, 0x00
StandingsGfx1:                                  ; far pointer (offset) to the first standings shape record;
                                                ; used by MENUS, STATS
        db 0x00, 0x00
StandingsGfx1Seg:                               ; its segment; used by MENUS, STATS
        db 0x00, 0x00
StandingsGfx2:                                  ; far pointer (offset) to the second standings shape record;
                                                ; used by MENUS, STATS
        db 0x00, 0x00
StandingsGfx2Seg:                               ; its segment; used by MENUS, STATS
        db 0x00, 0x00
statscategory:                                  ; stats screen category being shown; used by LP, MENUS, STATS
        db 0x00, 0x00
statsmenusel:                                   ; selected item of the stats menus; used by STATS
        times 2 db 0
statsredrawcb:                                  ; redraw routine of the stats screen; used by LP, MENUS, STATS
        times 2 db 0
statsmenucbseg:                                 ; segment of the stats menu callback; used by LP, MENUS, STATS
        times 2 db 0
statsmenumode:                                  ; stats menu mode (2, 3 ...); used by STATS
        times 2 db 0
teamstatscb:                                    ; team stats routine of the stats menu; used by LP, MENUS,
                                                ; STATS
        times 2 db 0
skaterstatscb:                                  ; skater stats routine of the stats menu; used by LP, MENUS
        times 2 db 0
goaliestatscb:                                  ; goalie stats routine of the stats menu; used by LP, MENUS,
                                                ; STATS
        times 2 db 0
standingscb:                                    ; standings routine of the stats menu; used by LP, MENUS
        times 2 db 0
standingsmenucb:                                ; standings menu routine; used by LP, MENUS, STATS
        times 2 db 0
gameopts:                                       ; game option bits (penalties, offsides, line changes, two-
                                                ; line pass ...); used by LP, MENUS
        times 2 db 0
VisTeam:                                        ; visiting team number; used by LP, MENUS, STATS
        times 2 db 0
HomeTeam:                                       ; home team number; used by LP, MENUS, STATS
        times 2 db 0
menucbfn:                                       ; far routine offset of the current menu callback; used by LP,
                                                ; MENUS
        times 2 db 0
menucbseg:                                      ; far routine segment of the current menu callback; used by
                                                ; LP, MENUS
        times 2 db 0
str_Embpal_11:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_24:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Easndesk_3:                                 ; string 'easndesk'; used by STATS
        db 'easndesk', 0x00
str_Embpal_10:                                  ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_23:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_9:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_22:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Easndesk_2:                                 ; string 'easndesk'; used by STATS
        db 'easndesk', 0x00
str_Embpal_8:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_21:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_7:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_20:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Easndesk:                                   ; string 'easndesk'; used by STATS
        db 'easndesk', 0x00
str_Embpal_6:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_19:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Tstat_2:                                    ; string 'tstat'; used by STATS
        db 'tstat', 0x00
str_Keys_3:                                     ; string 'keys'; used by STATS
        db 'keys', 0x00
str_Pstat_3:                                    ; string 'pstat'; used by STATS
        db 'pstat', 0x00
str_Gstat_3:                                    ; string 'gstat'; used by STATS
        db 'gstat', 0x00
str_Embpal_5:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_18:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_4:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_17:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_3:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_16:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Embpal_2:                                   ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_15:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_Tstat:                                      ; string 'tstat'; used by STATS
        db 'tstat', 0x00
str_Keys_2:                                     ; string 'keys'; used by STATS
        db 'keys', 0x00
str_Pstat_2:                                    ; string 'pstat'; used by STATS
        db 'pstat', 0x00
str_Gstat_2:                                    ; string 'gstat'; used by STATS
        db 'gstat', 0x00
str_Embpal:                                     ; string 'embpal'; used by STATS
        db 'embpal', 0x00
str_Pal_14:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00, 0x00
str_Speed_2:                                    ; string 'Speed'
        db 'Speed', 0x00
str_Agility_2:                                  ; string 'Agility'
        db 'Agility', 0x00
str_Weight_2:                                   ; string 'Weight'
        db 'Weight', 0x00
str_ShotPower:                                  ; string 'Shot Power'
        db 'Shot Power', 0x00
str_Checking_2:                                 ; string 'Checking'
        db 'Checking', 0x00
str_Stickhandling:                              ; string 'StickHandling'
        db 'StickHandling', 0x00
str_Accuracy:                                   ; string 'Accuracy'
        db 'Accuracy', 0x00
str_Passing_3:                                  ; string 'Passing'
        db 'Passing', 0x00
str_OffensiveAwareness_2:                       ; string 'Offensive Awareness'
        db 'Offensive Awareness', 0x00
str_DefensiveAwareness_2:                       ; string 'Defensive Awareness'
        db 'Defensive Awareness', 0x00
str_Aggressiveness:                             ; string 'Aggressiveness'
        db 'Aggressiveness', 0x00
str_Endurance:                                  ; string 'Endurance'
        db 'Endurance', 0x00
str_ShootPassBias:                              ; string 'Shoot/Pass Bias'
        db 'Shoot/Pass Bias', 0x00
str_Faceoffs:                                   ; string 'Faceoffs'
        db 'Faceoffs', 0x00
str_Portrait:                                   ; string 'portrait'; used by STATS
        db 'portrait', 0x00
str_Pal_13:                                     ; string '!pal'; used by STATS
        db '!pal', 0x00
str_SS_3:                                       ; string '%s %s'; used by STATS
        db '%s %s', 0x00
str_D_4:                                        ; string '%d '; used by STATS
        db '%d ', 0x00
str_Center:                                     ; string 'Center'; used by STATS
        db 'Center', 0x00
str_Defense:                                    ; string 'Defense'; used by STATS
        db 'Defense', 0x00
str_LeftWing:                                   ; string 'Left Wing'; used by STATS
        db 'Left Wing', 0x00
str_RightWing:                                  ; string 'Right Wing'; used by STATS
        db 'Right Wing', 0x00
str_Gp_6:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_G_2:                                        ; string '  G'; used by STATS
        db '  G', 0x00
str_A_2:                                        ; string '  A'; used by STATS
        db '  A', 0x00
str_Pt_2:                                       ; string ' Pt'; used by STATS
        db ' Pt', 0x00
str_Pim_2:                                      ; string 'PIM'; used by STATS
        db 'PIM', 0x00
str_PlusMinus2:                                 ; string ' +/-' of the skater stats card; used by STATS
        db ' +/-', 0x00
str_Ppg:                                        ; string 'PPG'; used by STATS
        db 'PPG', 0x00
str_Shg:                                        ; string 'SHG'; used by STATS
        db 'SHG', 0x00
str_Shots_2:                                    ; string 'Shots'; used by STATS
        db 'Shots', 0x00
str_Pct_3:                                      ; string '  Pct'; used by STATS
        db '  Pct', 0x00
str_Career:                                     ; string 'Career:'; used by STATS
        db 'Career:', 0x00
str_Ratings:                                    ; string 'Ratings:'; used by STATS
        db 'Ratings:', 0x00
str_Shoots:                                     ; string 'Shoots'; used by STATS
        db 'Shoots', 0x00
str_L_3:                                        ; string '  L'; used by STATS
        db '  L', 0x00
str_R:                                          ; string '  R'; used by STATS
        db 0x20, 0x20
        dw str_Det
        dw str_Speed_2
        dw str_Agility_2
        dw str_Weight_2
        dw str_ShotPower
        dw str_Checking_2
        dw str_Stickhandling
        dw str_Accuracy
        dw str_Passing_3
        dw str_OffensiveAwareness_2
        dw str_DefensiveAwareness_2
        dw str_Aggressiveness
        dw str_Endurance
        dw str_ShootPassBias
        dw str_Faceoffs
SkaterCardCols:                                 ; column order bytes of the skater stats card; used by STATS
        db 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
        db 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x13
str_KeyDb_2:                                    ; string 'key.db'; used by STATS
        db 'key.db', 0x00
str_SRoster:                                    ; string '%s Roster:'; used by STATS
        db '%s Roster:', 0x00
str_Pos_3:                                      ; string 'Pos'; used by STATS
        db 'Pos', 0x00
str_No_3:                                       ; string 'No'; used by STATS
        db 0x4E, 0x6F, 0x00
str_Name_2:                                     ; string 'Name'; used by STATS
        db 'Name', 0x00
str_Gp_5:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_G:                                          ; string '  G'; used by STATS
        db '  G', 0x00
str_A:                                          ; string '  A'; used by STATS
        db '  A', 0x00
str_Pt:                                         ; string ' PT'; used by STATS
        db ' PT', 0x00
str_Shots:                                      ; string 'Shots'; used by STATS
        db 'Shots', 0x00
str_Pim:                                        ; string 'PIM'; used by STATS
        db 'PIM', 0x00
str_PlusMinus3:                                 ; string ' +/-' of the roster screen; used by STATS
        db ' +/-', 0x00
        db 0x25, 0x63, 0x00
str_Pos_2:                                      ; string 'Pos'; used by STATS
        db 'Pos', 0x00
str_No_2:                                       ; string 'No'; used by STATS
        db 0x4E, 0x6F, 0x00
str_Name:                                       ; string 'Name'; used by STATS
        db 'Name', 0x00
str_Gp_4:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_Min:                                        ; string ' Min'; used by STATS
str_Min_4:                                      ; string ' Min'; used by STATS
        db ' Min', 0x00
str_Gaa:                                        ; string '  GAA'; used by STATS
        db '  GAA', 0x00
str_W_2:                                        ; string ' W'; used by STATS
        db 0x20, 0x57, 0x00
str_L_2:                                        ; string ' L'; used by STATS
        db 0x20, 0x4C, 0x00
str_T_2:                                        ; string ' T'; used by STATS
        db 0x20, 0x54, 0x00
str_Ga_2:                                       ; string ' GA'; used by STATS
        db ' GA', 0x00
str_Sa:                                         ; string '  SA'; used by STATS
        db '  SA', 0x00
str_Pct_2:                                      ; string '  PCT'; used by STATS
        db '  PCT', 0x00
        db '%c', 0x00, 'LSSCED.DB', 0x00
        db 'SCHEDULE.DB', 0x00
        db 'l$v$'
StandingsRowY:                                  ; y of the first standings row; used by MENUS, STATS
        db 0xB8
StandingsSlotEnd:                               ; byte before the slot table (-1 end mark); used by MENUS,
                                                ; STATS
        db 0xFF
StandingsSlots:                                 ; standings and playoff tree slot table; used by MENUS, STATS
        db 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E
        db 0x01, 0x05
        db 0x09, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x03, 0x0B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x07, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x07, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x03, 0x0B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x05
        db 0x09, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x02
        db 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E
StandingsSlotTeams:                             ; team of each standings or tree slot; used by MENUS, STATS
        db 0x00, 0x01
        db 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x10, 0x11, 0x12, 0x13, 0xFF, 0xFF, 0xFF, 0xFF, 0x18, 0x19
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1E, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1D, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1A, 0x1B
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x14, 0x15, 0x16, 0x17, 0xFF, 0xFF, 0xFF, 0xFF, 0x08, 0x09
        db 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
StandingsColX:                                  ; standings column x table; used by STATS
        db 0x05, 0x00, 0x05, 0x00, 0xA5, 0x00, 0xA5, 0x00
StandingsColW:                                  ; standings column width table; used by STATS
        db 0x23, 0x00, 0x64, 0x00
        db 0x23, 0x00, 0x64, 0x00
str_Standings_2:                                ; string ' Standings'; used by STATS
        db ' Standings', 0x00
str_CampbellConference_2:                       ; string 'Campbell Conference'; used by STATS
        db 'Campbell Conference'
        db 0x00
str_WalesConference_2:                          ; string 'Wales Conference'; used by STATS
        db 'Wales Conference'
        db 0x00
str_Team_2:                                     ; string 'Team'; used by STATS
        db 'Team', 0x00
str_Gp_3:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_W:                                          ; string ' W'; used by STATS
        db 0x20, 0x57, 0x00
str_L:                                          ; string ' L'; used by STATS
        db 0x20, 0x4C, 0x00
str_T:                                          ; string ' T'; used by STATS
        db 0x20, 0x54, 0x00
str_Gf:                                         ; string ' GF'; used by STATS
        db ' GF', 0x00
str_Ga:                                         ; string ' GA'; used by STATS
        db ' GA', 0x00
str_P:                                          ; string '  P'; used by STATS
        db '  P', 0x00
str_Pct:                                        ; string '  Pct'; used by STATS
        db '  Pct', 0x00
str_Standings:                                  ; string ' Standings'; used by STATS
        db ' Standings', 0x00
str_CampbellConference:                         ; string 'Campbell Conference'; used by STATS
        db 'Campbell Conference'
        db 0x00
str_WalesConference:                            ; string 'Wales Conference'; used by STATS
        db 'Wales Conference'
        db 0x00, '..', 0x00
str_Space3:                                     ; string ' ' copied by ShowPlayoffStandings; used by STATS
        db 0x20, 0x00
TeamStatsCmps:                                  ; far comparator table of the team stats sorts (_qsort); used
                                                ; by STATS
        db 0xED, 0x26
TeamStatsCmpsSeg:                               ; its segment words; used by STATS
        db 0x35, 0x1B
        dw CmpTeamDefenseThunk, 0x1B35
        dw CmpTeamPKThunk, 0x1B35
        dw CmpTeamPPThunk, 0x1B35
        dw CmpTeamPenaltiesThunk, 0x1B35
str_TeamScoring:                                ; string ' Team Scoring'
        db ' Team Scoring', 0x00
str_TeamDefense:                                ; string ' Team Defense'
        db ' Team Defense', 0x00
str_TeamPenaltyKilling:                         ; string ' Team Penalty Killing'
        db ' Team Penalty Killing', 0x00
str_TeamPowerPlay:                              ; string ' Team Power Play'
        db ' Team Power Play', 0x00
str_TeamPenalties:                              ; string ' Team Penalties'
        db ' Team Penalties', 0x00
str_W_4:                                        ; string ' W'
        db ' W', 0x00
str_L_6:                                        ; string ' L'
        db ' L', 0x00
str_T_4:                                        ; string ' T'
        db ' T', 0x00
str_Gf_2:                                       ; string ' GF'
        db ' GF', 0x00
str_W_5:                                        ; string ' W'
        db ' W', 0x00
str_L_7:                                        ; string ' L'
        db ' L', 0x00
str_T_5:                                        ; string ' T'
        db ' T', 0x00
str_Ga_3:                                       ; string ' GA'
        db ' GA', 0x00
str_Tsh:                                        ; string 'TSH'
        db 'TSH', 0x00
str_Ppga:                                       ; string 'PPGA'
        db 'PPGA', 0x00
str_Pct_7:                                      ; string '  PCT'
        db '  PCT', 0x00
str_Empty_2:                                    ; empty string
        db 0x00
str_Adv:                                        ; string 'ADV'
        db 'ADV', 0x00
str_Ppg_3:                                      ; string 'PPG'
        db 'PPG', 0x00
str_Pct_8:                                      ; string '  PCT'
        db '  PCT', 0x00
str_Empty_3:                                    ; empty string
        db 0x00
str_Pim_4:                                      ; string ' PIM'
        db ' PIM', 0x00
str_Avg:                                        ; string '  AVG'
        db '  AVG', 0x00
str_Empty_4:                                    ; empty string
        db 0x00
str_Empty_5:                                    ; empty string
        db 0x00
str_Teams_3:                                    ; string 'teams'; used by STATS
        db 'teams', 0x00
str_Addsort_2:                                  ; string 'addsort'; used by STATS
        db 'addsort', 0x00
str_Gp_2:                                       ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_StatsUnavailable_2:                         ; string 'Stats Unavailable'; used by STATS
        db 'Stats Unavailable'
        db 0x00
TeamStatsTitles:                                ; title text pointers of the team stats screens; used by STATS
        dw str_TeamScoring
        dw str_TeamDefense
        dw str_TeamPenaltyKilling
        dw str_TeamPowerPlay
        dw str_TeamPenalties
TeamStatsHead1:                                 ; team stats column heading pointer 1; used by STATS
        dw str_W_4
TeamStatsHead2:                                 ; team stats column heading pointer 2; used by STATS
        dw str_L_6
TeamStatsHead3:                                 ; team stats column heading pointer 3; used by STATS
        dw str_T_4
TeamStatsHeads:                                 ; further team stats column heading pointers; used by STATS
        dw str_Gf_2
        dw str_W_5
        dw str_L_7
        dw str_T_5
        dw str_Ga_3
        dw str_Tsh
        dw str_Ppga
        dw str_Pct_7
        dw str_Empty_2
        dw str_Adv
        dw str_Ppg_3
        dw str_Pct_8
        dw str_Empty_3
        dw str_Pim_4
        dw str_Avg
        dw str_Empty_4
        dw str_Empty_5
LeaderCmps:                                     ; far comparator table of the leader categories (_qsort); used
                                                ; by STATS
        db 0xD9, 0x26
LeaderCmpsSeg:                                  ; its segment words; used by STATS
        db 0x35, 0x1B
        dw CmpGoalsThunk, 0x1B35
        dw CmpAssistsThunk, 0x1B35
        dw CmpPPGoalsThunk, 0x1B35
        dw CmpSHGoalsThunk, 0x1B35
        dw CmpPlusMinusThunk, 0x1B35
        dw CmpPIMThunk, 0x1B35
        dw CmpShootPctThunk, 0x1B35
        dw CmpGAAThunk, 0x1B35
        dw CmpGoalieWinsThunk, 0x1B35
        dw CmpSavePctThunk, 0x1B35
str_PointLeaders:                               ; string ' Point Leaders'
        db ' Point Leaders', 0x00
str_GoalLeaders:                                ; string ' Goal Leaders'
        db ' Goal Leaders', 0x00
str_AssistLeaders:                              ; string ' Assist Leaders'
        db ' Assist Leaders', 0x00
str_PowerPlayGoalLeaders:                       ; string ' Power Play Goal Leaders'
        db ' Power Play Goal Leaders', 0x00
str_ShorthandedGoalLeaders:                     ; string ' Shorthanded Goal Leaders'
        db ' Shorthanded Goal Leaders', 0x00
str_PlusMinusLeaders:                           ; string ' Plus/Minus Leaders'
        db ' Plus/Minus Leaders', 0x00
str_PenaltyMinuteLeaders:                       ; string ' Penalty Minute Leaders'
        db ' Penalty Minute Leaders', 0x00
str_ShootingPercentageLeaders:                  ; string ' Shooting Percentage Leaders'
        db ' Shooting Percentage Leaders', 0x00
str_GoalsAgainstAverageLeaders:                 ; string ' Goals Against Average Leaders'
        db ' Goals Against Average Leaders', 0x00
str_GoaltenderWinLeaders:                       ; string ' Goaltender Win Leaders'
        db ' Goaltender Win Leaders', 0x00
str_SavePercentageLeaders:                      ; string ' Save Percentage Leaders'
        db ' Save Percentage Leaders', 0x00
str_G_3:                                        ; string '  G'
        db '  G', 0x00
str_A_3:                                        ; string '  A'
        db '  A', 0x00
str_Pt_4:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Empty_6:                                    ; empty string
        db 0x00
str_Empty_7:                                    ; empty string
        db 0x00
str_G_4:                                        ; string '  G'
        db '  G', 0x00
str_A_4:                                        ; string '  A'
        db '  A', 0x00
str_Pt_5:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Empty_8:                                    ; empty string
        db 0x00
str_Empty_9:                                    ; empty string
        db 0x00
str_G_5:                                        ; string '  G'
        db '  G', 0x00
str_A_5:                                        ; string '  A'
        db '  A', 0x00
str_Pt_6:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Empty_10:                                   ; empty string
        db 0x00
str_Empty_11:                                   ; empty string
        db 0x00
str_G_6:                                        ; string '  G'
        db '  G', 0x00
str_A_6:                                        ; string '  A'
        db '  A', 0x00
str_Pt_7:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Pp_3:                                       ; string 'PP'
        db 'PP', 0x00
str_Empty_12:                                   ; empty string
        db 0x00
str_G_7:                                        ; string '  G'
        db '  G', 0x00
str_A_7:                                        ; string '  A'
        db '  A', 0x00
str_Pt_8:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Shg_3:                                      ; string 'SHG'
        db 'SHG', 0x00
str_Empty_13:                                   ; empty string
        db 0x00
str_G_8:                                        ; string '  G'
        db '  G', 0x00
str_A_8:                                        ; string '  A'
        db '  A', 0x00
str_Pt_9:                                       ; string ' Pt'
        db ' Pt', 0x00
str_Blank:                                      ; string ' +/-'
        db ' +/-', 0x00
str_Empty_14:                                   ; empty string
        db 0x00
str_G_9:                                        ; string '  G'
        db '  G', 0x00
str_A_9:                                        ; string '  A'
        db '  A', 0x00
str_Pt_10:                                      ; string ' Pt'
        db ' Pt', 0x00
str_Pim_5:                                      ; string 'PIM'
        db 'PIM', 0x00
str_Empty_15:                                   ; empty string
        db 0x00
str_G_10:                                       ; string '  G'
        db '  G', 0x00
str_A_10:                                       ; string '  A'
        db '  A', 0x00
str_Pt_11:                                      ; string ' Pt'
        db ' Pt', 0x00
str_Shots_6:                                    ; string 'Shots'
        db 'Shots', 0x00
str_Pct_9:                                      ; string '  Pct'
        db '  Pct', 0x00
str_Min_6:                                      ; string ' MIN'
        db ' MIN', 0x00
str_Ga_4:                                       ; string ' GA'
        db ' GA', 0x00
str_Avg_2:                                      ; string '  AVG'
        db '  AVG', 0x00
str_Empty_16:                                   ; empty string
        db 0x00
str_Empty_17:                                   ; empty string
        db 0x00
str_Min_7:                                      ; string ' MIN'
        db ' MIN', 0x00
str_W_6:                                        ; string ' W'
        db ' W', 0x00
str_L_8:                                        ; string ' L'
        db ' L', 0x00
str_T_6:                                        ; string ' T'
        db ' T', 0x00
str_Empty_18:                                   ; empty string
        db 0x00
str_Min_8:                                      ; string ' MIN'
        db ' MIN', 0x00
str_Ga_5:                                       ; string ' GA'
        db ' GA', 0x00
str_Sa_3:                                       ; string '  SA'
        db '  SA', 0x00
str_Pct_10:                                     ; string '  PCT'
        db '  PCT', 0x00
str_Empty_19:                                   ; empty string
        db 0x00
str_Keys:                                       ; string 'keys'; used by STATS
        db 'keys', 0x00
str_Pstat:                                      ; string 'pstat'; used by STATS
        db 'pstat', 0x00
str_Gstat:                                      ; string 'gstat'; used by STATS
        db 'gstat', 0x00
str_Addsort:                                    ; string 'addsort'; used by STATS
        db 'addsort', 0x00
str_KeyDb:                                      ; string 'key.db'; used by STATS
        db 'key.db', 0x00
str_Pos:                                        ; string 'POS'; used by STATS
        db 'POS', 0x00
str_No:                                         ; string 'NO'; used by STATS
        db 0x4E, 0x4F, 0x00
str_Player_2:                                   ; string 'PLAYER'; used by STATS
        db 'PLAYER', 0x00
str_Team:                                       ; string 'TEAM'; used by STATS
        db 'TEAM', 0x00
str_Gp:                                         ; string 'GP'; used by STATS
        db 0x47, 0x50, 0x00
str_StatsUnavailable:                           ; string 'Stats Unavailable'; used by STATS
        db 'Stats Unavailable'
        db 0x00, 0x25, 0x63, 0x00, 0x00
LeaderTitles:                                   ; title text pointers of the leader categories; used by STATS
        dw str_PointLeaders
        dw str_GoalLeaders
        dw str_AssistLeaders
        dw str_PowerPlayGoalLeaders
        dw str_ShorthandedGoalLeaders
        dw str_PlusMinusLeaders
        dw str_PenaltyMinuteLeaders
        dw str_ShootingPercentageLeaders
        dw str_GoalsAgainstAverageLeaders
        dw str_GoaltenderWinLeaders
        dw str_SavePercentageLeaders
LeaderHead1:                                    ; leaders column heading pointer 1; used by STATS
        dw str_G_3
LeaderHead2:                                    ; leaders column heading pointer 2; used by STATS
        dw str_A_3
LeaderHead3:                                    ; leaders column heading pointer 3; used by STATS
        dw str_Pt_4
LeaderHead4:                                    ; leaders column heading pointer 4; used by STATS
        dw str_Empty_6
LeaderHeads:                                    ; further leaders column heading pointers; used by STATS
        dw str_Empty_7
        dw str_G_4
        dw str_A_4
        dw str_Pt_5
        dw str_Empty_8
        dw str_Empty_9
        dw str_G_5
        dw str_A_5
        dw str_Pt_6
        dw str_Empty_10
        dw str_Empty_11
        dw str_G_6
        dw str_A_6
        dw str_Pt_7
        dw str_Pp_3
        dw str_Empty_12
        dw str_G_7
        dw str_A_7
        dw str_Pt_8
        dw str_Shg_3
        dw str_Empty_13
        dw str_G_8
        dw str_A_8
        dw str_Pt_9
        dw str_Blank
        dw str_Empty_14
        dw str_G_9
        dw str_A_9
        dw str_Pt_10
        dw str_Pim_5
        dw str_Empty_15
        dw str_G_10
        dw str_A_10
        dw str_Pt_11
        dw str_Shots_6
        dw str_Pct_9
        dw str_Min_6
        dw str_Ga_4
        dw str_Avg_2
        dw str_Empty_16
        dw str_Empty_17
        dw str_Min_7
        dw str_W_6
        dw str_L_8
        dw str_T_6
        dw str_Empty_18
        dw str_Min_8
        dw str_Ga_5
        dw str_Sa_3
        dw str_Pct_10
        dw str_Empty_19
        dw str_Empty_20
        db 'anley', 0x00
str_Fanom:                                      ; string 'fanom'
        db 'fanom', 0x00
str_Goal:                                       ; string 'goal'
        db 'goal', 0x00
str_Clap:                                       ; string 'clap'
        db 'clap', 0x00
str_Uflag:                                      ; string 'uflag'
        db 'uflag', 0x00
str_Cflag:                                      ; string 'cflag'
        db 'cflag', 0x00
