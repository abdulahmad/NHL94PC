; The awards screens.
AwardMsgIds:                                    ; message numbers of the award names (AwardsCeremony); used by
                                                ; LP
        dw str_Hart
        dw str_Adms
        dw str_Norr
        dw str_Selk
        dw str_Vezi
        dw str_Jenn
        dw str_Cald
        dw str_Pres
        dw str_Conn
        dw str_Easn
AwardMsgIds2:                                   ; message numbers of the award descriptions; used by LP
        dw str_Tab3
        dw str_Tab3_2
        dw str_Tab2
        dw str_Tab2_2
        dw str_Tab2_3
        dw str_Tab2_4
        dw str_Tab3_3
        dw str_Tab1
        dw str_Tab2_5
        dw str_Tab3_4
        dw str_Spk1
        dw str_Spk2
AwardTitleMsg:                                  ; message number of the awards title; used by LP
        dw str_Spk3
AwardTextY:                                     ; award text row table; used by LP
        db 0x53, 0x00
AwardTextY2:                                    ; second award text row table; used by LP
        db 0x85, 0x00
        db 0x6F, 0x00, 0x3A, 0x00
        db 0x66, 0x00, 0x5A, 0x00
        db 0x77, 0x00, 0x3C, 0x00
        db 0x53, 0x00, 0x49, 0x00
        db 0x6F, 0x00, 0x61, 0x00
        db 0x52, 0x00, 0x2A, 0x00
        db 0x7C, 0x00, 0x52, 0x00
        db 0x52, 0x00, 0x80, 0x00
        db 0x76, 0x00, 0x18, 0x00
        db 0x55, 0x00, 0x63, 0x00
        db 0x35, 0x00, 0x36, 0x00
        db 0x76, 0x00, 0x57, 0x00
        db 0x53, 0x00, 0x66, 0x00
        db 0x5E, 0x00, 0x2A, 0x00
        db 0x56, 0x00, 0x55, 0x00, 0x93, 0x00
        db 0x2B, 0x00, 0x50, 0x00
        db 0x25, 0x00, 0x7A, 0x00, 0x19, 0x00
        db 0x3C, 0x00, 0x39, 0x00
        db 0x6A, 0x00, 0x2F, 0x00, 0x83, 0x00
        db 0x21, 0x00, 0x7B, 0x00, 0x91, 0x00
        db 0x5C, 0x00, 0x2C, 0x00
        db 0x3C, 0x00, 0x28, 0x00
        db 0x70, 0x00, 0x5B, 0x00
        db 0x64, 0x00, 0x34, 0x00
        db 0x6F, 0x00, 0x6C, 0x00
        db 0x62, 0x00, 0x1F, 0x00
        db 0x7E, 0x00, 0x3B, 0x00
AwardNamePtrs:                                  ; award name text pointers (ShowAwardScreens); used by LP
        dw str_Hart_2
        dw str_ArtRoss
        dw str_Norris
        dw str_Selke
        dw str_Vezina
        dw str_Jennings
        dw str_Calder
        dw str_Presidents
        dw str_ConnSmythe
        dw str_EaSportsCup
AwardKinds:                                     ; kind of each award (0 skater, 1 goalie, 2 team); used by LP
        db 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x02
        db 0x01
AwardsPending:                                  ; 1 while the awards are still to be picked; used by LP
        db 0x01
AwardWinner:                                    ; winner record pointer of the first award; used by LP
        dw AwardScores + 0x208
AwardWinner2:                                   ; winner pointer of award 2; used by LP
        dw AwardScores + 0x238
AwardWinner3:                                   ; winner pointer of award 3; used by LP
        dw AwardScores + 0x268
AwardWinner4:                                   ; winner pointer of award 4; used by LP
        dw AwardScores + 0x298
AwardWinner5:                                   ; winner pointer of award 5; used by LP
        dw AwardScores + 0x2C8
AwardWinner6:                                   ; winner pointer of award 6; used by LP
        dw AwardScores + 0x2FE
AwardWinner7:                                   ; winner pointer of award 7; used by LP
        dw AwardScores + 0x334
        db 0x00, 0x00
AwardWinner8:                                   ; winner pointer of award 8; used by LP
        dw AwardScores + 0x364
AwardWinner9:                                   ; winner pointer of award 9; used by LP
        dw AwardScores + 0x394
AwardTitlePtrs:                                 ; award title text pointers; used by LP
        dw str_SeasonTitle
        dw str_PlayoffTitle
str_D_5:                                        ; string '%d'
        db '%d', 0x00
        db 0x00
str_D02d_2:                                     ; string '%d.%02d'; used by LP
        db '%d.%02d', 0x00
str_D01d:                                       ; string '%d.%01d'; used by LP
        db '%d.%01d', 0x00
str_Sparkle:                                    ; string 'sparkle'; used by LP
        db 'sparkle', 0x00
str_Wittle06Fnt_6:                              ; string 'wittle06.fnt'; used by LP
        db 'wittle06.fnt', 0x00
str_Scrn_2:                                     ; string 'scrn'; used by LP
        db 'scrn', 0x00
str_SS_5:                                       ; string '%s %s'; used by LP
        db '%s %s', 0x00
str_Gp_9:                                       ; string 'GP'; used by LP
        db 0x47, 0x50, 0x00
str_Min_3:                                      ; string 'Min'; used by LP
        db 'Min', 0x00
str_Gaa_3:                                      ; string 'GAA'; used by LP
        db 'GAA', 0x00
str_AwardsW:                                    ; text 'W' (57h) drawn on the award screen; used by LP
        db 0x57, 0x00
str_AwardsL:                                    ; text 'L' (4Ch) drawn on the award screen; used by LP
        db 0x4C, 0x00
str_AwardsT:                                    ; text 'T' (54h) drawn on the award screen; used by LP
        db 0x54, 0x00
str_So_2:                                       ; string 'SO'; used by LP
        db 0x53, 0x4F, 0x00
str_En_2:                                       ; string 'EN'; used by LP
        db 0x45, 0x4E, 0x00
str_Shots_4:                                    ; string 'Shots'; used by LP
        db 'Shots', 0x00
str_Pct_6:                                      ; string 'Pct'; used by LP
        db 'Pct', 0x00
str_Gp_8:                                       ; string 'GP'; used by LP
        db 0x47, 0x50, 0x00
str_AwardsG:                                    ; text 'G' (47h) drawn on the award screen; used by LP
        db 0x47, 0x00
str_AwardsA:                                    ; text 'A' (41h) drawn on the award screen; used by LP
        db 0x41, 0x00
str_Pt_3:                                       ; string 'Pt'; used by LP
        db 0x50, 0x74, 0x00
str_Pim_3:                                      ; string 'PIM'; used by LP
        db 'PIM', 0x00
str_PlusMinus:                                  ; string '+/-' drawn on the award screen; used by LP
        db '+/-', 0x00
str_Ppg_2:                                      ; string 'PPG'; used by LP
        db 'PPG', 0x00
str_Shg_2:                                      ; string 'SHG'; used by LP
        db 'SHG', 0x00
str_Shots_3:                                    ; string 'Shots'; used by LP
        db 'Shots', 0x00
str_Pct_5:                                      ; string 'Pct'; used by LP
        db 'Pct', 0x00
str_Wittle06Fnt_5:                              ; string 'wittle06.fnt'; used by LP
        db 'wittle06.fnt', 0x00
str_Embpal_16:                                  ; string 'embpal'; used by LP
        db 'embpal', 0x00
str_Pal_33:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_AwardsSummary:                              ; string 'Awards Summary'; used by LP
        db 'Awards Summary', 0x00
str_MtafanKms:                                  ; string 'mtafan.kms'; used by LP
        db 'mtafan.kms', 0x00
str_MtafanCfg:                                  ; string 'mtafan.cfg'; used by LP
        db 'mtafan.cfg', 0x00
str_AdafanKms:                                  ; string 'adafan.kms'; used by LP
        db 'adafan.kms', 0x00
str_AdafanCfg:                                  ; string 'adafan.cfg'; used by LP
        db 'adafan.cfg', 0x00
str_Awards:                                     ; string 'awards'; used by LP
        db 'awards', 0x00
str_S1Fnt_5:                                    ; string 's1.fnt'; used by LP
        db 's1.fnt', 0x00
str_Hong:                                       ; string 'hong'; used by LP
        db 'hong', 0x00
str_Pal_32:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_WelcomeToTheNhl:                            ; string 'Welcome to the NHL'; used by LP
        db 'Welcome to the NHL'
        db 0x00
str_AwardsPresentation:                         ; string 'awards presentation.'; used by LP
        db 'awards presentation.'
        db 0x00
str_MtawardsKms:                                ; string 'mtawards.kms'; used by LP
        db 'mtawards.kms', 0x00
str_MtawardsCfg:                                ; string 'mtawards.cfg'; used by LP
        db 'mtawards.cfg', 0x00
str_AdawardsKms:                                ; string 'adawards.kms'; used by LP
        db 'adawards.kms', 0x00
str_AdawardsCfg:                                ; string 'adawards.cfg'; used by LP
        db 'adawards.cfg', 0x00
str_Embnhl:                                     ; string 'embnhl'; used by LP
        db 'embnhl', 0x00
str_Bkgd_2:                                     ; string 'bkgd'; used by LP
        db 'bkgd', 0x00
str_Pal_31:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
