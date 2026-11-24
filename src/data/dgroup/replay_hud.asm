; Highlight and replay state, the HUD panel and scoreboard, and the event banners.
HL2Offsets:                                     ; offset table of StartHL2; used by AI
        db 0x00, 0x00
HL2Offsets2:                                    ; second offset table of StartHL2; used by AI
        db 0x24, 0xFF, 0xB0, 0xFF, 0x79, 0xFF, 0x19, 0x00, 0x9C, 0xFF, 0x92, 0xFF, 0xC9, 0xFF, 0x1E, 0x00
        db 0xDC, 0xFF, 0x50, 0x00, 0xB8, 0xFF, 0x00, 0x00, 0xDC, 0x00
        db 0x28, 0x00, 0x52, 0x00, 0xC2, 0xFF, 0x48, 0x00
        db 0x6E, 0x00, 0x24, 0x00, 0xF1, 0xFF, 0x09, 0x00
        db 0xC9, 0xFF, 0x00, 0x00
replaymode:                                     ; replay mode (-1 off); used by INIT
        db 0xFF, 0xFF
replaytick:                                     ; replay tick counter; used by AI
        db 0x01, 0x00
replaysfx:                                      ; sound recorded with the replay frame; used by AI, INIT
        db 0xFF, 0xFF, '3000', 0x00
str_N3001:                                      ; string '3001'
        db '3001', 0x00
str_N3002:                                      ; string '3002'
        db '3002', 0x00
str_N3003:                                      ; string '3003'
        db '3003', 0x00
str_N3004:                                      ; string '3004'
        db '3004', 0x00
str_N3005:                                      ; string '3005'
        db '3005', 0x00
str_N3006:                                      ; string '3006'
        db '3006', 0x00
str_N3007:                                      ; string '3007'
        db '3007', 0x00
str_N3008:                                      ; string '3008'
        db '3008', 0x00
str_N3009:                                      ; string '3009'
        db '3009', 0x00
str_N300:                                       ; string '300 '
        db '300 ', 0x00
str_Ot:                                         ; string 'OT  '
        db 'OT  ', 0x00
str_Bos_2:                                      ; string 'BOS '
        db 'BOS ', 0x00
str_Buf_2:                                      ; string 'BUF '
        db 'BUF ', 0x00
str_Cgy_2:                                      ; string 'CGY '
        db 'CGY ', 0x00
str_Chi_2:                                      ; string 'CHI '
        db 'CHI ', 0x00
str_Det_2:                                      ; string 'DET '
        db 'DET ', 0x00
str_Edm_2:                                      ; string 'EDM '
        db 'EDM ', 0x00
str_Hfd_2:                                      ; string 'HFD '
        db 'HFD ', 0x00
str_La_2:                                       ; string 'LA  '
        db 'LA  ', 0x00
str_Min_9:                                      ; string 'MIN '
        db 'MIN ', 0x00
str_Mtl_3:                                      ; string 'MTL '
        db 'MTL ', 0x00
str_Nj_2:                                       ; string 'NJ  '
        db 'NJ  ', 0x00
str_Nyi_2:                                      ; string 'NYI '
        db 'NYI ', 0x00
str_Nyr_2:                                      ; string 'NYR '
        db 'NYR ', 0x00
str_Ott_2:                                      ; string 'OTT '
        db 'OTT ', 0x00
str_Phi_2:                                      ; string 'PHI '
        db 'PHI ', 0x00
str_Pit_2:                                      ; string 'PIT '
        db 'PIT ', 0x00
str_Que_2:                                      ; string 'QUE '
        db 'QUE ', 0x00
str_Stl_2:                                      ; string 'STL '
        db 'STL ', 0x00
str_Sj_2:                                       ; string 'SJ  '
        db 'SJ  ', 0x00
str_Tb_2:                                       ; string 'TB  '
        db 'TB  ', 0x00
str_Tor_2:                                      ; string 'TOR '
        db 'TOR ', 0x00
str_Van_2:                                      ; string 'VAN '
        db 'VAN ', 0x00
str_Wsh_2:                                      ; string 'WSH '
        db 'WSH ', 0x00
str_Wpg_2:                                      ; string 'WPG '
        db 'WPG ', 0x00
str_Asc_2:                                      ; string 'ASC '
        db 'ASC ', 0x00
str_Asw_2:                                      ; string 'ASW '
        db 'ASW ', 0x00
HudBarLevels:                                   ; energy bar level table; used by AI
        db 0xA0, 0x0F, 0xA0, 0x0F, 0xA0, 0x0F, 0xA0, 0x0F
        db 0xA0, 0x0F, 0xA0
        db 0x0F, 0xA0, 0x0F, 0xA0, 0x0F
HudBarLevels2:                                  ; second energy bar level table; used by AI
        db 0xA0, 0x0F, 0xA0, 0x0F, 0xA0, 0x0F, 0xA0, 0x0F
        db 0xA0, 0x0F, 0xA0
        db 0x0F, 0xA0, 0x0F, 0xA0, 0x0F
hudclockmin:                                    ; panel clock minutes; used by AI, GAME, INIT
        db 0x05, 0x00
hudclocksec:                                    ; panel clock seconds; used by AI, GAME, INIT
        db 0x00, 0x00
hudclockhund:                                   ; panel clock hundredths; used by AI, GAME, INIT
        db 0x00, 0x00
panelprevmin:                                   ; panel clock minutes drawn last; used by AI
        db 0x63, 0x00
panelprevsec:                                   ; panel clock seconds drawn last; used by AI
        db 0x63, 0x00
panelprevhund:                                  ; panel clock hundredths drawn last; used by AI
        db 0x63, 0x00
hudpenhome:                                     ; home panel penalty list; used by AI, INIT
        db 0xFF, 0xFF
hudpenhome_w2:                                  ; home panel penalty list word +2; used by INIT
        db 0x00, 0x00
hudpenhome_w4:                                  ; home panel penalty list word +4; used by INIT
        db 0x00, 0x00
hudpenhome_w6:                                  ; home panel penalty list word +6; used by INIT
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00
hudpenaway:                                     ; away panel penalty list; used by AI, INIT
        db 0xFF, 0xFF
hudpenaway_w2:                                  ; away panel penalty list word +2; used by INIT
        db 0x00, 0x00
hudpenaway_w4:                                  ; away panel penalty list word +4; used by INIT
        db 0x00, 0x00
hudpenaway_w6:                                  ; away panel penalty list word +6; used by INIT
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00
HudShapeNames:                                  ; panel shape message names; used by AI
        db 0x82, 0x54
        dw str_N3001
        dw str_N3002
        dw str_N3003
        dw str_N3004
        dw str_N3005
        dw str_N3006
        dw str_N3007
        dw str_N3008
        dw str_N3009
        dw str_N300
HudShapeName:                                   ; panel shape message name; used by AI
        dw str_Ot
CrestShapeNames:                                ; crest shape message names; used by AI, INIT, LP, MENUS
        dw str_Bos_2
        dw str_Buf_2
        dw str_Cgy_2
        dw str_Chi_2
        dw str_Det_2
        dw str_Edm_2
        dw str_Hfd_2
        dw str_La_2
        dw str_Min_9
        dw str_Mtl_3
        dw str_Nj_2
        dw str_Nyi_2
        dw str_Nyr_2
        dw str_Ott_2
        dw str_Phi_2
        dw str_Pit_2
        dw str_Que_2
        dw str_Stl_2
        dw str_Sj_2
        dw str_Tb_2
        dw str_Tor_2
        dw str_Van_2
        dw str_Wsh_2
        dw str_Wpg_2
        dw str_Asc_2
        dw str_Asw_2
panelhund:                                      ; panel hundredths; used by AI
        db 0x00, 0x00
deferpending:                                   ; deferred calls pending; used by AI, GAME, INIT, MENUS
        times 2 db 0
hudhomeredraw:                                  ; home panel redraw flag; used by AI
        times 2 db 0
hudawayredraw:                                  ; away panel redraw flag; used by AI
        times 2 db 0
hudhomeline:                                    ; home line shown on the panel; used by AI
        times 2 db 0
hudlinehome:                                    ; line shown on the home panel; used by AI
        times 2 db 0
hudclockredraw:                                 ; clock redraw flag; used by AI
        times 2 db 0
hudscoreredraw:                                 ; score redraw flag; used by AI
        times 2 db 0
hudlineaway:                                    ; line shown on the away panel; used by AI
        times 2 db 0
hudlinegroup:                                   ; line group shown on the panel; used by AI
        times 2 db 0
str_Scrbrd2:                                    ; string 'scrbrd2'; used by AI
        db 'scrbrd2', 0x00
str_Srb3:                                       ; string 'srb3'; used by AI
        db 'srb3', 0x00
str_Crests4:                                    ; string 'crests4'; used by AI
        db 'crests4', 0x00, 0x00
goaliemenuflags:                                ; goalie menu flags; used by AI, MENUS
        dw str_HomeGoalie1Text, 0x3448
        dw str_HomeGoalie2Text, 0x3448
goaliemenuflags_e02:                            ; goalie menu flags, second entry; used by AI, MENUS
        dw str_HomeGoalieNone, 0x3448
        dw str_AwayGoalie1Text, 0x3448
        dw str_AwayGoalie2Text, 0x3448
        dw str_AwayGoalieNone, 0x3448
BannerColours:                                  ; banner colour table; used by AI
        db 0x00, 'UU', 0x00, 0x00, 0xAA, 0xAA, 0x00
str_04d:                                        ; string '%04d'; used by AI
        db '%04d', 0x00
str_ReturnGoalie:                               ; string 'RETURN GOALIE'
        db 'RETURN GOALIE', 0x00
str_PullGoalie:                                 ; string 'PULL GOALIE'
        db 'PULL GOALIE', 0x00
str_FaceOff:                                    ; string 'FACE-OFF'
        db 'FACE-OFF', 0x00
str_N2LinePass:                                 ; string '2 LINE PASS'
        db '2 LINE PASS', 0x00
str_Offside:                                    ; string 'OFFSIDE'
        db 'OFFSIDE', 0x00
str_Icing:                                      ; string 'ICING'
        db 'ICING', 0x00
str_Penalty_3:                                  ; string 'PENALTY'
        db 'PENALTY', 0x00
CallNamePtrs:                                   ; referee call name pointers; used by AI
        dw str_ReturnGoalie
        dw str_PullGoalie
        dw str_FaceOff
        dw str_N2LinePass
        dw str_Offside
        dw str_Icing
        dw str_Penalty_3
str_CallRoughing:                               ; string 'Roughing'
        db 'Roughing', 0x00
str_Empty_21:                                   ; empty string
        db 0x00
str_Charging:                                   ; string 'Charging'
        db 'Charging', 0x00
str_Slashing:                                   ; string 'Slashing'
        db 'Slashing', 0x00
str_Roughing:                                   ; string 'Roughing'
        db 'Roughing', 0x00
str_Crosschecking:                              ; string 'CrossChecking'
        db 'CrossChecking', 0x00
str_Hooking:                                    ; string 'Hooking'
        db 'Hooking', 0x00
str_Tripping:                                   ; string 'Tripping'
        db 'Tripping', 0x00
str_Interference:                               ; string 'Interference'
        db 'Interference', 0x00
str_Holding:                                    ; string 'Holding'
        db 'Holding', 0x00
str_AbuseOfOfficial:                            ; string 'Abuse of Official'
        db 'Abuse of Official', 0x00
str_CheckingFromBehind:                         ; string 'Checking from Behind'
        db 'Checking from Behind', 0x00
EventFmtPtrs:                                   ; event line format pointers; used by AI, INIT
        dw str_CallRoughing
        dw str_Empty_21
        dw str_Charging
        dw str_Slashing
        dw str_Roughing
        dw str_Crosschecking
        dw str_Hooking
        dw str_Tripping
        dw str_Interference
        dw str_Holding
        dw str_AbuseOfOfficial
        dw str_CheckingFromBehind
