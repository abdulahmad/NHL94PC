; Far data, paragraph 384Bh, 384 bytes: season titles. The EXE's own code does not use it
; (the overlays probably do).
titleSeason:                                    ; flag byte and ' 92 - 93 Season' title of the statistics menu
        db 0x01, 0x20, 0x27, '92 - ', 0x27, '93 Season', 0x00
titlePlayoffs:                                  ; flag byte and ' 92 - 93 Play-Offs' title of the statistics
                                                ; menu
        db 0x02, 0x20, 0x27, '92 - ', 0x27, '93 Play-Offs', 0x00
titleLeagueSeason:                              ; flag byte and league season title of the statistics menu
        db 0x02, 0x20, 0x22
str_WwwwwwwwSeason:                             ; string 'WWWWWWWW" Season'; used by STATS
        db 'WWWWWWWW" Season', 0x00
titleLeagueSeasonPlayoffs:                      ; flag byte and league season play-offs title
        db 0x02, 0x20, 0x22
str_WwwwwwwwSeasonPlayOffs:                     ; string 'WWWWWWWW" Season Play-Offs'; used by STATS
        db 'WWWWWWWW" Season Play-Offs', 0x00
titleLeaguePlayoffs:                            ; flag byte and league play-offs title
        db 0x02, 0x20, 0x22
str_WwwwwwwwPlayOffs:                           ; string 'WWWWWWWW" Play-Offs'; used by STATS
        db 'WWWWWWWW" Play-Offs', 0x00
str_Separator_5:                                ; string '-----------------------------'
        db '-----------------------------', 0x00
itemNhlSeason:                                  ; menu item record (box, text, handler) of the ''92 - '93
                                                ; Season' entry of the season menu
        db 0x00, 0x00, 0x00, 0x00
SeasonMenuRight:                                ; right edge of the first season menu item; SetupStatsMenus
                                                ; copies it to the others; used by STATS
        db 0x9B, 0x00, 0x08, 0x00
        dw titleSeason, 0x384B
        dw StatsSelNhlSeasonThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemNhlPlayoffs:                                ; menu item record (box, text, handler) of the ''92 - '93
                                                ; Play-Offs' entry of the season menu
        db 0x00, 0x00, 0x09, 0x00, 0x9B, 0x00, 0x10, 0x00
        dw titlePlayoffs, 0x384B
        dw StatsSelNhlPlayoffsThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemSeasonSeparator:                            ; menu item record (box, text, handler) of the 'separator'
                                                ; entry of the season menu
        db 0x00, 0x00, 0x11, 0x00, 0x9B, 0x00, 0x18, 0x00
        dw str_Separator_5, 0x384B
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemLeagueSeason:                               ; menu item record (box, text, handler) of the 'league season'
                                                ; entry of the season menu
        db 0x00, 0x00, 0x19, 0x00, 0x9B, 0x00, 0x20, 0x00
        dw titleLeagueSeason, 0x384B
        dw StatsSelLeagueThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemLeagueSeasonPlayoffs:                       ; menu item record (box, text, handler) of the 'league season
                                                ; play-offs' entry of the season menu
        db 0x00, 0x00, 0x21, 0x00, 0x9B, 0x00, 0x28, 0x00
        dw titleLeagueSeasonPlayoffs, 0x384B
        dw StatsSelLeaguePlayoffsThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemSeasonSeparator_2:                          ; menu item record (box, text, handler) of the 'second
                                                ; separator' entry of the season menu
        db 0x00, 0x00, 0x29, 0x00, 0x9B, 0x00, 0x30, 0x00
        dw str_Separator_5, 0x384B
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
itemLeaguePlayoffs:                             ; menu item record (box, text, handler) of the 'league play-
                                                ; offs' entry of the season menu
        db 0x00, 0x00, 0x31, 0x00, 0x9B, 0x00, 0x39, 0x00
        dw titleLeaguePlayoffs, 0x384B
        dw StatsSelPlayoffModeThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Season:                                     ; string '" Season'; used by STATS
        db '" Season', 0x00
str_SeasonPlayOffs:                             ; string '" Season Play-Offs'; used by STATS
        db '" Season Play-Offs'
        db 0x00
str_PlayOffs:                                   ; string '" Play-Offs'; used by STATS
        db '" Play-Offs', 0x00, 0x00, 0x00, 0x00
        times 43 db 0
