; The game's team, roster and player records and their far pointers.
PPVFiles:                                       ; far pointers to the 18 loaded PPV files (LoadPlayerFrames);
                                                ; the 72 bytes after them are not used
        resb 144
FrameTable:                                     ; frame pointer table (offset words) built by IndexPPVFrames;
                                                ; used by GAME
        resb 2
FrameTableSeg:                                  ; frame pointer table (segment words); used by GAME
        resb 3502
GameTeamRecs:                                   ; team records read by LoadGameTeams (76 bytes); used by INIT
        resb 76
GamePlayerNames:                                ; player name pointers (offset) of the game summary and
                                                ; lineups; used by INIT
        resb 2
GamePlayerNamesSeg:                             ; player name pointers (segment); used by INIT
        resb 110
HomeLinesRec:                                   ; home line record written by WriteTeamLines; used by MENUS
        resb 48
TeamLinesRecs:                                  ; line records written by WriteTeamLines; used by MENUS
        resb 508
GameRosterRecs:                                 ; roster records read by LoadGameTeams (744 bytes); used by
                                                ; INIT
        resb 744
hmroster:                                       ; home roster records; used by AI, INIT, MENUS
        resb 6
hmrosterjersey:                                 ; jersey byte of the home roster records; used by AI, INIT,
                                                ; MENUS
        resb 1
hmrosterpos:                                    ; position byte of the home roster records; used by AI
        resb 1113
GamePlayerFlags:                                ; player flags filled by LoadGameTeams; used by INIT
        resb 1120
HomeTeamRec:                                    ; home team record saved with the game (36 bytes); used by
                                                ; INIT
        resb 36
HomeTeamAbbr:                                   ; first byte of the home team abbreviation; used by INIT
        resb 1
HomeTeamAbbr_b1:                                ; rest of the home team abbreviation; used by INIT
        resb 3
HomeTeamColours:                                ; home team colour bytes (LoadGameTeams); used by INIT
        resb 8
AwayTeamRec:                                    ; away team record saved with the game (36 bytes); used by
                                                ; INIT
        resb 36
AwayTeamAbbr:                                   ; first byte of the away team abbreviation; used by INIT
        resb 1
AwayTeamAbbr_b1:                                ; rest of the away team abbreviation; used by INIT
        resb 3
AwayTeamColours:                                ; away team colour bytes; used by INIT
        resb 8
gsummarypath:                                   ; path of gsummary.db (MakeGSummaryPath); used by INIT
        resb 32
HeapSizeLo:                                     ; heap size, low word; used by AI, GAME, INIT, LP, MENUS
        resb 2
HeapSizeHi:                                     ; heap size, high word; used by AI, GAME, INIT, LP, MENUS
        resb 2
