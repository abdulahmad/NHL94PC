; The C run-time's copyright, the team abbreviations and city names (TeamNameClips: the speech
; clip of each), the sound card flag and the game summary header.
DgroupStart:                                    ; offset 0 of DGROUP; code splits a label across a segment end
                                                ; with label - DgroupStart
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 'MS Run-Time Library - Copyright (c) 1990, Microsoft Corp'
        db 0x18, 0x00
str_Bos:                                        ; string 'BOS'; in TeamNameClips
        db 'BOS', 0x00
str_Buf:                                        ; string 'BUF'
        db 'BUF', 0x00
str_Cgy:                                        ; string 'CGY'
        db 'CGY', 0x00
str_Chi:                                        ; string 'CHI'; in TeamNameClips
        db 'CHI', 0x00
str_Det:                                        ; string 'DET'
        db 'DET', 0x00
str_Edm:                                        ; string 'EDM'
        db 'EDM', 0x00
str_Hfd:                                        ; string 'HFD'; in TeamNameClips
        db 'HFD', 0x00
str_La:                                         ; string 'LA'
        db 'LA', 0x00
str_Min_5:                                      ; string 'MIN'
        db 'MIN', 0x00
str_Mtl:                                        ; string 'MTL'; in TeamNameClips
        db 'MTL', 0x00
str_Nj:                                         ; string 'NJ'
        db 'NJ', 0x00
str_Nyi:                                        ; string 'NYI'; in TeamNameClips
        db 'NYI', 0x00
str_Nyr:                                        ; string 'NYR'; in TeamNameClips
        db 'NYR', 0x00
str_Ott:                                        ; string 'OTT'
        db 'OTT', 0x00
str_Phi:                                        ; string 'PHI'
        db 'PHI', 0x00
str_Pit:                                        ; string 'PIT'
        db 'PIT', 0x00
str_Que:                                        ; string 'QUE'; in TeamNameClips
        db 'QUE', 0x00
str_Stl:                                        ; string 'STL'; in TeamNameClips
        db 'STL', 0x00
str_Sj:                                         ; string 'SJ'
        db 'SJ', 0x00
str_Tb:                                         ; string 'TB'
        db 'TB', 0x00
str_Tor:                                        ; string 'TOR'
        db 'TOR', 0x00
str_Van:                                        ; string 'VAN'
        db 'VAN', 0x00
str_Wsh:                                        ; string 'WSH'
        db 'WSH', 0x00
str_Wpg:                                        ; string 'WPG'
        db 'WPG', 0x00
str_Nhl_7:                                      ; string 'NHL'
        db 'NHL', 0x00
str_Nhl_8:                                      ; string 'NHL'
        db 'NHL', 0x00
str_Asc:                                        ; string 'ASC'
        db 'ASC', 0x00
str_Asw:                                        ; string 'ASW'; in TeamNameClips
        db 'ASW', 0x00
str_Boston:                                     ; string 'BOSTON'
        db 'BOSTON', 0x00
str_Buffalo:                                    ; string 'BUFFALO'
        db 'BUFFALO', 0x00
str_Calgary:                                    ; string 'CALGARY'
        db 'CALGARY', 0x00
str_Chicago:                                    ; string 'CHICAGO'
        db 'CHICAGO', 0x00
str_Detroit:                                    ; string 'DETROIT'
        db 'DETROIT', 0x00
str_Edmonton:                                   ; string 'EDMONTON'
        db 'EDMONTON', 0x00
str_Hartford:                                   ; string 'HARTFORD'
        db 'HARTFORD', 0x00
str_LosAngeles:                                 ; string 'LOS ANGELES'
        db 'LOS ANGELES', 0x00
str_Minnesota:                                  ; string 'MINNESOTA'
        db 'MINNESOTA', 0x00
str_Montreal:                                   ; string 'MONTREAL'
        db 'MONTREAL', 0x00
str_NewJersey:                                  ; string 'NEW JERSEY'
        db 'NEW JERSEY', 0x00
str_NyIslanders:                                ; string 'NY ISLANDERS'
        db 'NY ISLANDERS', 0x00
str_NyRangers:                                  ; string 'NY RANGERS'
        db 'NY RANGERS', 0x00
str_Ottawa:                                     ; string 'OTTAWA'
        db 'OTTAWA', 0x00
str_Philadelphia:                               ; string 'PHILADELPHIA'; in TeamNameClips
        db 'PHILADELPHIA', 0x00
str_Pittsburgh:                                 ; string 'PITTSBURGH'
        db 'PITTSBURGH', 0x00
str_Quebec:                                     ; string 'QUEBEC'; in TeamNameClips
        db 'QUEBEC', 0x00
str_StLouis:                                    ; string 'ST LOUIS'
        db 'ST LOUIS', 0x00
str_SanJose:                                    ; string 'SAN JOSE'
        db 'SAN JOSE', 0x00
str_TampaBay:                                   ; string 'TAMPA BAY'
        db 'TAMPA BAY', 0x00
str_Toronto:                                    ; string 'TORONTO'
        db 'TORONTO', 0x00
str_Vancouver:                                  ; string 'VANCOUVER'
        db 'VANCOUVER', 0x00
str_Washington:                                 ; string 'WASHINGTON'
        db 'WASHINGTON', 0x00
str_Winnipeg:                                   ; string 'WINNIPEG'
        db 'WINNIPEG', 0x00
str_CampbellAllStars:                           ; string 'CAMPBELL ALL STARS'
        db 'CAMPBELL ALL STARS', 0x00
str_WalesAllStars:                              ; string 'WALES ALL STARS'
        db 'WALES ALL STARS', 0x00
DbSaveMode:                                     ; 0/2 mode checked by SaveGame and UseDbDescriptor; used by
                                                ; UseDbDescriptor, SaveGame
        dw 0x0000
CrowdState:                                     ; bit 80h tested by the crowd routines; used by
                                                ; Crowd_Noise, CrowdNoiseOff, CrowdFadeOut
        db 0xFF
AnnouncerFlags:                                 ; bit 80h set while the announcer talks; used by
                                                ; PaOneMinuteLeft, PaSpeechBusy, PaGoal ...
        db 0x7B
ctl1team:                                       ; team of controller 1 (-1 none, -2 eliminated); used by AI,
                                                ; INIT, MENUS
        db 0xFF, 0xFF
ctl2team:                                       ; team of controller 2 (-1 none, -2 eliminated); used by AI,
                                                ; INIT, MENUS
        db 0xFE, 0xFF
ctl1dev:                                        ; input device of controller 1 (10h none); used by AI, INIT,
                                                ; MENUS
        db 0x10, 0x00
ctl2dev:                                        ; input device of controller 2 (10h none); used by AI, INIT,
                                                ; MENUS
        db 0x10, 0x00
ctl1side:                                       ; side controller 1 plays (0 home, 1 away); used by AI, MENUS
        db 0x00, 0x00
ctl2side:                                       ; side controller 2 plays; used by AI, MENUS
        db 0x01, 0x00
sndcardmissing:                                 ; sound card dialog: a set bit greys out that card; used by
                                                ; MENUS
        db 0x7F, 0x00
SoundOptions:                                   ; bits 2 and 8 gate crowd and effects; used by
                                                ; Crowd_Noise, CrowdNoiseOff, CrowdFadeOut ...
        db 0x10, 0x00
gsumheader:                                     ; header of the game summary file; used by AI, INIT
        db 0x00, 0x00
gsumheader_b2:                                  ; game summary header byte +2 (CreateGSummaryDb); used by INIT
        db 0x00
gsumheader_b3:                                  ; game summary header byte +3; used by INIT
        db 0x00
gsumheader_b4:                                  ; game summary header byte +4; used by INIT
        db 0x00
gsumheader_b5:                                  ; game summary header byte +5; used by INIT
        db 0x00
gsumcount:                                      ; game summary file record count (gsumheader +6); used by AI,
                                                ; INIT
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
gsumtail:                                       ; block kept at the end of the game summary file (goals and
                                                ; shots per team); used by AI, INIT
        db 0x04, 0x00
gsumtail_goals1:                                ; game summary tail: goals of the first team (PostGoalEvent);
                                                ; used by AI, INIT
        db 0x00
gsumtail_shots1:                                ; game summary tail: shots of the first team (ChkShotStat);
                                                ; used by AI, INIT
        db 0x00
gsumtail_goals2:                                ; game summary tail: goals of the second team; used by AI,
                                                ; INIT
        db 0x00
gsumtail_shots2:                                ; game summary tail: shots of the second team; used by AI,
                                                ; INIT
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
TeamNameClips:                                  ; speech clip per team, indexed by team; used by
                                                ; PaTonightIntro, PaHighlightIntro,
                                                ; PaPlayoffResult ...
        dw str_Bos
        dw str_Buf
        dw str_Cgy
        dw str_Chi
        dw str_Det
        dw str_Edm
        dw str_Hfd
        dw str_La
        dw str_Min_5
        dw str_Mtl
        dw str_Nj
        dw str_Nyi
        dw str_Nyr
        dw str_Ott
        dw str_Phi
        dw str_Pit
        dw str_Que
        dw str_Stl
        dw str_Sj
        dw str_Tb
        dw str_Tor
        dw str_Van
        dw str_Wsh
        dw str_Wpg
        dw str_Nhl_7
        dw str_Nhl_8
        dw str_Asc
        dw str_Asw
        dw str_Boston
        dw str_Buffalo
        dw str_Calgary
        dw str_Chicago
        dw str_Detroit
        dw str_Edmonton
        dw str_Hartford
        dw str_LosAngeles
        dw str_Minnesota
        dw str_Montreal
        dw str_NewJersey
        dw str_NyIslanders
        dw str_NyRangers
        dw str_Ottawa
        dw str_Philadelphia
        dw str_Pittsburgh
        dw str_Quebec
        dw str_StLouis
        dw str_SanJose
        dw str_TampaBay
        dw str_Toronto
        dw str_Vancouver
        dw str_Washington
        dw str_Winnipeg
        dw str_CampbellAllStars
        dw str_WalesAllStars
