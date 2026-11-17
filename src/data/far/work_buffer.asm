; Far data, paragraph 3A0Bh, 48096 bytes: a 48096-byte work buffer (zeros). Used by LoadTeamPalettes,
; SeqStepTrack.
HomeSortObjs:                                    ; used by AI, INIT (to name)
        times 500 db 0
AwaySortObjs:                                    ; used by AI, INIT (to name)
        times 500 db 0
HomeGlAttr:                                    ; used by AI, INIT (to name)
        times 48 db 0
AwayGlAttr:                                    ; used by AI, INIT (to name)
        times 48 db 0
HomePlStats:                                    ; used by AI, INIT (to name)
        times 2 db 0
HomePlStats_w2:                                    ; used by AI (to name)
        times 398 db 0
AwayPlStats:                                    ; used by AI, INIT (to name)
        times 400 db 0
HomeGlStats:                                    ; used by AI, INIT (to name)
        times 2 db 0
HomeGlStats_w2:                                    ; used by INIT (to name)
        times 2 db 0
HomeGlStats_w4:                                    ; used by INIT (to name)
        times 14 db 0
AwayGlStats:                                    ; used by AI, INIT (to name)
        times 788 db 0
TeamPalette768:                                    ; used by AI, GAME, INIT (to name)
        times 768 db 0
hilightrec:                                    ; used by AI, INIT, MENUS (to name)
        db 0x00
hilightrec_b1:                                    ; used by AI, INIT (to name)
        db 0x00
hilightrec_b2:                                    ; used by AI, INIT (to name)
        db 0x00
hilightrec_home:                                    ; used by AI, INIT (to name)
        times 28 db 0
hilightrec_b1F:                                    ; used by AI, INIT (to name)
        db 0x00
hilightrec_away:                                    ; used by AI, INIT (to name)
        times 28 db 0
hilightrec_w3C:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_w3E:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_w40:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_w42:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_w44:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_w46:                                    ; used by AI, INIT (to name)
        times 2 db 0
hilightrec_frames:                                    ; used by AI, INIT (to name)
        times 38402 db 0
StatsPalette:                                    ; used by MENUS (to name)
        times 768 db 0
SavedGameNames:                                    ; used by MENUS (to name)
        times 864 db 0
LeagueTeamNames:                                    ; used by LP, STATS (to name)
        times 504 db 0
POTeamName1:                                    ; used by MENUS, STATS (to name)
        times 21 db 0
POTeamName2:                                    ; used by MENUS (to name)
        times 21 db 0
leagueinfo:                                    ; used by LP (to name)
        times 2 db 0
leagueinfo_w2:                                    ; used by LP (to name)
        times 2 db 0
leagueinfo_w4:                                    ; used by LP (to name)
        times 2 db 0
leagueinfo_w6:                                    ; used by LP (to name)
        times 2 db 0
leagueinfo_teams:                                    ; used by LP (to name)
        times 720 db 0
leagueinfo_password:                                    ; used by LP (to name)
        times 12 db 0
leagueinfo_tail:                                    ; used by LP (to name)
        times 14 db 0
MenuRemap:                                    ; used by INIT, LP, STATS (to name)
        times 128 db 0
MenuRemap2:                                    ; used by STATS (to name)
        times 128 db 0
dlgJerseyConflict:                                    ; used by LP (to name)
        times 6 db 0
StatsScreenPalette:                                    ; used by STATS (to name)
        times 204 db 0
StatsCardBuf:                                    ; used by STATS (to name)
        times 384 db 0
StatsCardBuf2:                                    ; used by STATS (to name)
        times 180 db 0
GamePalette:                                    ; used by AI, GAME, INIT (to name)
        times 768 db 0
GameTeamName1:                                    ; used by INIT (to name)
        times 6 db 0
GameTeamName2:                                    ; used by INIT (to name)
        times 6 db 0
GameTeamWord0:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord1:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord2:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord3:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord4:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord5:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord6:                                    ; used by INIT (to name)
        times 2 db 0
GameTeamWord7:                                    ; used by INIT (to name)
        times 2 db 0
MoviePalette:                                    ; used by INIT (to name)
        times 120 db 0
MovieState:                                    ; used by INIT (to name)
        times 1274 db 0
