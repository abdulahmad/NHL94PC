; Far data, paragraph 3A0Bh, 48096 bytes: a 48096-byte work buffer (zeros). Used by LoadTeamPalettes,
; SeqStepTrack.
HomeSortObjs:                                   ; home team sort objects (500 bytes), pointed to by hmtmsort;
                                                ; used by AI, INIT
        times 500 db 0
AwaySortObjs:                                   ; away team sort objects (500 bytes), pointed to by awtmsort;
                                                ; used by AI, INIT
        times 500 db 0
HomeGlAttr:                                     ; home goalie attributes (48 bytes); used by AI, INIT
        times 48 db 0
AwayGlAttr:                                     ; away goalie attributes (48 bytes), pointed to by awtmglattr;
                                                ; used by AI, INIT
        times 48 db 0
HomePlStats:                                    ; home player stats records, read by ChkScorerMilestone; used
                                                ; by AI, INIT
        times 2 db 0
HomePlStats_w2:                                 ; home player stats, word +2 of the first record; used by AI
        times 398 db 0
AwayPlStats:                                    ; away player stats (400 bytes), pointed to by awtmplstats;
                                                ; used by AI, INIT
        times 400 db 0
HomeGlStats:                                    ; home goalie stats, pointed to by hmtmglstats; used by AI,
                                                ; INIT
        times 2 db 0
HomeGlStats_w2:                                 ; home goalie stats word +2, written by CreateGSummaryDb; used
                                                ; by INIT
        times 2 db 0
HomeGlStats_w4:                                 ; home goalie stats from +4, written by CreateGSummaryDb; used
                                                ; by INIT
        times 14 db 0
AwayGlStats:                                    ; away goalie stats, pointed to by g_B504; used by AI, INIT
        times 788 db 0
TeamPalette768:                                 ; 768-byte palette (256 RGB triples) loaded with the team
                                                ; colours and faded in (StartHL2, ThreeStarsLoop); used by AI,
                                                ; GAME, INIT
        times 768 db 0
hilightrec:                                     ; saved highlight record: first byte, read and written with
                                                ; the .HI file; used by AI, INIT, MENUS
        db 0x00
hilightrec_b1:                                  ; highlight record byte +1; used by AI, INIT
        db 0x00
hilightrec_b2:                                  ; highlight record byte +2; used by AI, INIT
        db 0x00
hilightrec_home:                                ; highlight record +3: 28 bytes of home team data; used by AI,
                                                ; INIT
        times 28 db 0
hilightrec_b1F:                                 ; highlight record byte +1Fh; used by AI, INIT
        db 0x00
hilightrec_away:                                ; highlight record +20h: 28 bytes of away team data; used by
                                                ; AI, INIT
        times 28 db 0
hilightrec_w3C:                                 ; highlight record word +3Ch; used by AI, INIT
        times 2 db 0
hilightrec_w3E:                                 ; highlight record word +3Eh; used by AI, INIT
        times 2 db 0
hilightrec_w40:                                 ; highlight record word +40h; used by AI, INIT
        times 2 db 0
hilightrec_w42:                                 ; highlight record word +42h; used by AI, INIT
        times 2 db 0
hilightrec_w44:                                 ; highlight record word +44h; used by AI, INIT
        times 2 db 0
hilightrec_w46:                                 ; highlight record word +46h; used by AI, INIT
        times 2 db 0
hilightrec_frames:                              ; highlight record +48h: the recorded replay frames (38402
                                                ; bytes); used by AI, INIT
        times 38402 db 0
StatsPalette:                                   ; 768-byte palette saved and restored around the in-game
                                                ; player stats; used by MENUS
        times 768 db 0
SavedGameNames:                                 ; names of the saved games found by ScanSavedGames (864
                                                ; bytes); used by MENUS
        times 864 db 0
LeagueTeamNames:                                ; team names of the league (504 bytes), filled by
                                                ; ReadTeamNames; used by LP, STATS
        times 504 db 0
POTeamName1:                                    ; 21-byte team name buffer of the playoff screens; used by
                                                ; MENUS, STATS
        times 21 db 0
POTeamName2:                                    ; second 21-byte team name buffer of the playoff screens; used
                                                ; by MENUS
        times 21 db 0
leagueinfo:                                     ; league info record read by ReadLeagueInfo: first word; used
                                                ; by LP
        times 2 db 0
leagueinfo_w2:                                  ; league info record word +2; used by LP
        times 2 db 0
leagueinfo_w4:                                  ; league info record word +4; used by LP
        times 2 db 0
leagueinfo_w6:                                  ; league info record word +6; used by LP
        times 2 db 0
leagueinfo_teams:                               ; league info record +8: per-team entries (720 bytes); used by
                                                ; LP
        times 720 db 0
leagueinfo_password:                            ; league master password (12 bytes) after the team entries;
                                                ; used by LP
        times 12 db 0
leagueinfo_tail:                                ; league info record, last 14 bytes; used by LP
        times 14 db 0
MenuRemap:                                      ; 128-byte colour remap used by the menu and summary screens
                                                ; (InitMenuRemap); used by INIT, LP, STATS
        times 128 db 0
MenuRemap2:                                     ; second 128-byte colour remap built by InitMenuRemap; used by
                                                ; STATS
        times 128 db 0
dlgJerseyConflict:                              ; MessageBox definition built by FixJerseyConflict; used by LP
        times 6 db 0
StatsScreenPalette:                             ; palette buffer of the stats screens, faded in with
                                                ; FadePaletteIn; used by STATS
        times 204 db 0
StatsCardBuf:                                   ; 384-byte buffer the stats cards copy their record into; used
                                                ; by STATS
        times 384 db 0
StatsCardBuf2:                                  ; 180-byte second buffer of the stats cards; used by STATS
        times 180 db 0
GamePalette:                                    ; the game's 768-byte palette (GetPaletteFar, FadePalette);
                                                ; used by AI, GAME, INIT
        times 768 db 0
GameTeamName1:                                  ; 6-byte home team abbreviation set by LoadGameTeams; used by
                                                ; INIT
        times 6 db 0
GameTeamName2:                                  ; 6-byte away team abbreviation set by LoadGameTeams; used by
                                                ; INIT
        times 6 db 0
GameTeamWord0:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord1:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord2:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord3:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord4:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord5:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord6:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
GameTeamWord7:                                  ; word set by LoadGameTeams; used by INIT
        times 2 db 0
MoviePalette:                                   ; palette buffer PlayMovie fades with; used by INIT
        times 120 db 0
MovieState:                                     ; movie player state passed to MviOpen by PlayTitleMovies;
                                                ; used by INIT
        times 1274 db 0
