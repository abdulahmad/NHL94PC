; The front-end screens: title, line editor, file dialogs, playoffs, standings, text fields, league,
; trades, awards and statistics.
TitleJingle:                                    ; title jingle buffer pointer (offset); used by MENUS
        resb 2
TitleJingleSeg:                                 ; its segment; used by MENUS
        resb 2
TitleJingle2:                                   ; second title jingle buffer pointer (offset); used by MENUS
        resb 2
TitleJingle2Seg:                                ; its segment; used by MENUS
        resb 2
gmrosterpos:                                    ; roster position letter (C, L, R, D, G) of the game roster
                                                ; entries; used by MENUS
        resb 1
gmrosterjersey:                                 ; game roster jersey; used by MENUS
        resb 1
gmrosterslot:                                   ; game roster slot; used by MENUS
        resb 1
gmrosterjersey_b2:                              ; game roster entry byte +3; used by MENUS
        resb 1
gmrosterdot:                                    ; game roster entry: the '.' after the initial; used by MENUS
        resb 1
gmrosterspace:                                  ; game roster entry: the space before the name; used by MENUS
        resb 1
gmrostername:                                   ; game roster entry names; used by MENUS
        resb 544
gmroster2pos:                                   ; second game roster: first byte; used by MENUS
        resb 1
gmroster2jersey:                                ; second game roster: jersey bytes; used by MENUS
        resb 2
gmroster2init:                                  ; second game roster: initial; used by MENUS
        resb 1
gmroster2dot:                                   ; second game roster: the '.'; used by MENUS
        resb 1
gmroster2space:                                 ; second game roster: the space; used by MENUS
        resb 1
gmroster2name:                                  ; second game roster: names; used by MENUS
        resb 60
curperiod:                                      ; current period; used by AI, GAME, INIT, LP, MENUS
        resb 2
HomeTeamDbName:                                 ; home team database name (32 bytes); used by LP
        resb 32
AwayTeamDbName:                                 ; away team database name (32 bytes); used by LP
        resb 32
statsgoaliebufseg:                              ; segment of statsgoaliebuf; used by LP, MENUS, STATS
        resb 2
statsgoaliebuf:                                 ; goalie stats buffer; used by LP, MENUS, STATS
        resb 2
statsskaterbufseg:                              ; segment of statsskaterbuf; used by LP, MENUS, STATS
        resb 2
statsskaterbuf:                                 ; skater stats buffer; used by LP, MENUS, STATS
        resb 2
statsplayerbufseg:                              ; segment of statsplayerbuf; used by LP, MENUS, STATS
        resb 2
statsplayerbuf:                                 ; player stats buffer; used by LP, MENUS, STATS
        resb 2
statsteambufseg:                                ; segment of statsteambuf; used by LP, MENUS, STATS
        resb 2
statsteambuf:                                   ; team stats buffer; used by LP, MENUS, STATS
        resb 2
statsrosterteam:                                ; team shown on the roster screen; used by MENUS, STATS
        resb 2
leaguestatsmode:                                ; league stats mode; used by LP, MENUS, STATS
        resb 2
savedcount1:                                    ; number of saved games of the first kind (ScanSavedGames);
                                                ; used by MENUS
        resb 2
savedsel1:                                      ; selected saved game of the first kind; used by MENUS
        resb 2
savedtop1:                                      ; first saved game shown, first kind; used by MENUS
        resb 2
savedrows1:                                     ; rows of the first saved game list; used by MENUS
        resb 2
savednames1:                                    ; name pointers (offset) of the first saved game list; used by
                                                ; MENUS
        resb 2
savednames1seg:                                 ; further name pointers of the first list; used by MENUS
        resb 126
savedcount2:                                    ; number of saved games of the second kind; used by MENUS
        resb 2
lgfiles:                                        ; league file handles; used by MENUS
        resb 2
savedtop2:                                      ; first saved game shown, second kind; used by MENUS
        resb 2
savedrows2:                                     ; rows of the second list; used by MENUS
        resb 2
savednames2:                                    ; name pointers of the second list; used by MENUS
        resb 2
lgfilenames:                                    ; league file names; used by MENUS
        resb 126
savedcount3:                                    ; number of saved games of the third kind; used by MENUS
        resb 2
savedsel3:                                      ; selected saved game of the third kind; used by MENUS
        resb 2
savedtop3:                                      ; first saved game shown, third kind; used by MENUS
        resb 2
savedrows3:                                     ; rows of the third list; used by MENUS
        resb 2
savednames3:                                    ; name pointers of the third list; used by MENUS
        resb 2
savednames3seg:                                 ; further name pointers of the third list; used by MENUS
        resb 126
fdlgtab:                                        ; file dialog table; used by MENUS
        resb 2
fdlgflags:                                      ; file dialog flag bits (80h, 40h, 20h); used by MENUS
        resb 1
fdlgflags2:                                     ; file dialog flag bits, second byte; used by MENUS
        resb 1
SoundDrvBuf:                                    ; sound driver buffer pointer (offset); used by MENUS
        resb 2
SoundDrvBufSeg:                                 ; its segment; used by MENUS
        resb 2
POTitleText:                                    ; playoff title text (16 bytes); used by MENUS
        resb 16
playofftree:                                    ; playoff tree; used by MENUS, STATS
        resb 2
POTreeSlots:                                    ; playoff tree slot words; used by MENUS
        resb 30
POTreeRows:                                     ; playoff tree row words (19h); used by MENUS
        resb 20
standingsteam:                                  ; team of the standings row; used by STATS
        resb 2
standingsprev:                                  ; previous standings value; used by STATS
        resb 2
standingskey:                                   ; standings sort key; used by STATS
        resb 2
standingskey2:                                  ; second standings sort key; used by STATS
        resb 2
standingsrank:                                  ; standings rank; used by STATS
        resb 2
DeskTitleText:                                  ; sports desk title text (22 bytes); used by MENUS
        resb 22
ScoreboardArt:                                  ; scoreboard art pointer (offset); used by AI, INIT, MENUS
        resb 2
ScoreboardArtSeg:                               ; its segment; used by AI, INIT, MENUS
        resb 2
RinkEndArt:                                     ; rink end art pointer (offset); used by AI, INIT, MENUS
        resb 2
RinkEndArtSeg:                                  ; its segment; used by AI, INIT, MENUS
        resb 2
editactive:                                     ; text field: editing active; used by LP
        resb 2
editcursorx:                                    ; text field: cursor x; used by LP
        resb 2
editx:                                          ; text field: x; used by LP
        resb 2
edity:                                          ; text field: y; used by LP
        resb 2
editpos:                                        ; text field: cursor position; used by LP
        resb 2
editlen:                                        ; text field: text length; used by LP
        resb 2
editmax:                                        ; text field: maximum width; used by LP
        resb 2
calresult:                                      ; calendar result (-1 none); used by LP
        resb 2
calmonth:                                       ; calendar month shown (0-11); used by LP
        resb 2
calday:                                         ; calendar day chosen (-1 none); used by LP
        resb 2
teamselresult:                                  ; team selection result; used by LP
        resb 2
floppydrive:                                    ; floppy drive chosen; used by LP
        resb 2
floppyok:                                       ; floppy drive flags; used by LP
        resb 2
floppycount:                                    ; number of floppy drives; used by LP
        resb 2
tradestate:                                     ; trade screen state (1 done, -1 cancelled, 0 running); used
                                                ; by LP
        resb 2
savleague:                                      ; league name of the game being played (14 bytes); used by LP
        resb 14
savleague2:                                     ; second league name (14 bytes); used by LP
        resb 14
lgschedrec:                                     ; schedule record of the league game; used by LP
        resb 1
lgschedrec_b1:                                  ; schedule record byte +1; used by LP
        resb 1
lgschedrec_b2:                                  ; schedule record byte +2; used by LP
        resb 1
lgschedrec_b3:                                  ; schedule record byte +3; used by LP
        resb 1
lgschedrec_b4:                                  ; schedule record byte +4; used by LP
        resb 1
lgschedrec_b5:                                  ; schedule record byte +5; used by LP
        resb 1
statspalshape:                                  ; stats palette shape; used by LP, STATS
        resb 2
calcursor:                                      ; calendar cursor day; used by LP
        resb 2
calcursor2:                                     ; calendar cursor row; used by LP
        resb 2
lghometeam:                                     ; home team of the league game; used by LP
        resb 2
lgoppteam:                                      ; other team of the league game; used by LP
        resb 2
lggamestate:                                    ; league game state (-1 none); used by LP
        resb 2
lgreadword:                                     ; word read with the league game reference; used by LP
        resb 2
lgreadword2:                                    ; second word read with the league game reference; used by LP
        resb 2
lggameidx:                                      ; index of the league game; used by LP
        resb 2
statsbgshapes:                                  ; stats background shapes; used by LP, STATS
        resb 2
statsbgseg:                                     ; stats background shape segment; used by LP, STATS
        resb 2
startm:                                         ; three stars: team of each star; used by AI, LP
        resb 2
starpl:                                         ; three stars: player of each star; used by AI, LP
        resb 10
traderows:                                      ; trade screen rows; used by LP
        resb 1
traderows_b1:                                   ; trade screen rows from +1; used by LP
        resb 1
traderows_b2:                                   ; trade screen row bytes from +2; used by LP
        resb 614
traderoster:                                    ; trade roster (BuildTradeRoster); used by LP
        resb 616
tradesel:                                       ; selected trade rows; used by LP
        resb 2
tradesel2:                                      ; second trade selection word; used by LP
        resb 2
tradescroll:                                    ; trade list scroll; used by LP
        resb 2
tradescroll2:                                   ; second trade scroll word; used by LP
        resb 2
tradecursor:                                    ; trade screen cursor; used by LP
        resb 2
tradecolour:                                    ; trade screen row colour; used by LP
        resb 2
tradecolour2:                                   ; second trade row colour; used by LP
        resb 2
mergestate:                                     ; merge state of the league files; used by LP
        resb 2
AwardRawA:                                      ; award art raw handle; used by LP
        resb 2
AwardRawB:                                      ; second award art raw handle; used by LP
        resb 2
AwardRawC:                                      ; third award art raw handle; used by LP
        resb 2
AwardRawD:                                      ; fourth award art raw handle; used by LP
        resb 2
AwardFrames:                                    ; award EMS frames (offset); used by LP
        resb 2
AwardFramesSeg:                                 ; award EMS frames; used by LP
        resb 38
AwardFrames2:                                   ; second award EMS frames; used by LP
        resb 2
AwardFrames2Seg:                                ; second award EMS frames; used by LP
        resb 38
AwardFrames3:                                   ; third award EMS frame; used by LP
        resb 2
AwardFrames3Seg:                                ; third award EMS frames; used by LP
        resb 10
AwardScores:                                    ; award score bytes (ShowAwardScreens); used by LP
        resb 1023
AwardText:                                      ; award text buffer; used by LP
        resb 36
AwardCandidates:                                ; award candidate bytes (PickAwardWinners); used by LP
        resb 703
standingstab:                                   ; standings table (26-byte rows); used by STATS
        resb 48
rostertop:                                      ; roster screen first row; used by STATS
        resb 2
statscardteam:                                  ; stats card team; used by STATS
        resb 1
statscardplayer:                                ; stats card player; used by STATS
        resb 1
statsplayer:                                    ; stats player; used by STATS
        resb 1
rosterfilter:                                   ; roster filter text; used by STATS
        resb 16
rosterfilter2:                                  ; second roster filter text; used by STATS
        resb 17
statsfilepos:                                   ; stats file position (low); used by STATS
        resb 2
statsfileposhi:                                 ; stats file position (high); used by STATS
        resb 2
statscardrec:                                   ; stats card record pointer; used by STATS
        resb 2
statscardrecseg:                                ; its segment; used by STATS
        resb 2
statscardrec2:                                  ; second stats card record pointer; used by STATS
        resb 2
statscardrec2seg:                               ; its segment; used by STATS
        resb 2
statscardgoalie:                                ; stats card goalie flag; used by STATS
        resb 2
statscardrec3:                                  ; third stats card record word; used by STATS
        resb 2
rosterrows:                                     ; roster screen row records; used by STATS
        resb 50
rosterrowptrs:                                  ; roster screen row pointers; used by STATS
        resb 50
rosterrows2:                                    ; second roster row records; used by STATS
        resb 10
rosterrowptrs2:                                 ; second roster row pointers; used by STATS
        resb 10
rostersel:                                      ; roster selected row; used by STATS
        resb 2
statsrecs:                                      ; stats records pointer (offset); used by STATS
        resb 2
statsrecsseg:                                   ; its segment; used by STATS
        resb 2
statscmpsum:                                    ; comparator sum; used by STATS
        resb 2
statscmpsum2:                                   ; comparator sum, high word; used by STATS
        resb 2
fileoncd:                                       ; file is on the CD; used by STATS
        resb 2
cddriveptr:                                     ; CD drive pointer; used by STATS
        resb 2
statstext:                                      ; text buffer of DrawTextFmt (40 bytes); used by STATS
        resb 40
cupseries:                                      ; cup series buffer pointer (offset); used by GAME, INIT
        resb 2
cupseriesseg:                                   ; its segment; used by GAME, INIT
        resb 2
regd5:                                          ; register-style work variable d5; used by AI
        resb 2
lastgoalx:                                      ; last goal position x; used by AI
        resb 2
crowdtimer:                                     ; crowd timer; used by AI, INIT
        resb 2
LastShooterTeam:                                ; team of the last shooter; used by AI
        resb 2
