; Each team's game statistics and team state (home, then away).
hmshots:                                        ; home shots; the home team stats start here; used by INIT
        resb 2
hmppgoals:                                      ; home power play goals; used by INIT, LP
        resb 2
hmppchances:                                    ; home power play chances; used by INIT, LP
        resb 2
hmpenalties:                                    ; home penalty count; used by INIT
        resb 2
hmpenmins:                                      ; home penalty minutes; used by INIT, LP
        resb 2
hmattacktime:                                   ; home attack zone time; used by INIT
        resb 2
hmscore:                                        ; home score; used by AI, INIT, LP, MENUS
        resb 2
hmfaceoffs:                                     ; home faceoffs won; used by INIT
        resb 2
hmchecks:                                       ; home body checks; used by INIT
        resb 2
hmpassatt:                                      ; home pass attempts; used by INIT
        resb 2
hmpasscmp:                                      ; home passes completed; used by INIT
        resb 2
hmtmline:                                       ; home current line; used by AI
        resb 2
hmtmlcnt:                                       ; home line count; used by AI
        resb 2
hmtmextra:                                      ; home extra skater; used by AI
        resb 2
hmtmtouch1:                                     ; home last touch 1; used by AI
        resb 2
hmtmtouch2:                                     ; home last touch 2; used by AI
        resb 2
hmtmtouch3:                                     ; home last touch 3; used by AI
        resb 2
hmtmap:                                         ; home skaters on the ice; used by AI, INIT, MENUS
        resb 2
hmtmgoalie:                                     ; home goalie (negative = pulled); used by AI, INIT, LP
        resb 1
hmtmgoalie_b1:                                  ; home goalie, high byte; used by AI
        resb 5
hmtmflags:                                      ; home team flags (line change mode, offside ...); used by AI,
                                                ; MENUS
        resb 2
hmtmpde:                                        ; home player energy (56 bytes); used by AI
        resb 56
hmtmpdst:                                       ; home player status per roster slot (56 bytes); used by AI
        resb 56
hmtmpbox_m1:                                    ; home team bytes before hmtmpbox (28 bytes); used by AI
        resb 28
hmtmcoach_d2:                                   ; home coach data byte; used by AI
        resb 1
hmtmcoach_d3:                                   ; home coach data byte; used by AI
        resb 1
hmtmcoachflags:                                 ; home coach flags; used by AI
        resb 1
hmtmcoachmode:                                  ; home coach mode; used by AI
        resb 1
hmtmcoachenergy:                                ; home coach energy setting; used by AI
        resb 2
hmtmlines:                                      ; home line table pointer; used by AI, INIT, LP
        resb 2
hmtmsort:                                       ; home sort objects pointer; used by AI, INIT
        resb 2
hmtmplattr:                                     ; home player attributes pointer; used by AI, INIT
        resb 2
hmtmglattr:                                     ; home goalie attributes pointer; used by AI, INIT
        resb 2
hmtmglattrseg:                                  ; its segment; used by AI, INIT
        resb 2
hmtmplstats:                                    ; home player stats pointer; used by AI, INIT
        resb 2
hmtmplstatsseg:                                 ; its segment; used by AI, INIT
        resb 2
hmtmglstats:                                    ; home goalie stats pointer; used by AI, INIT
        resb 2
hmtmroster:                                     ; home roster pointer; used by AI, INIT
        resb 2
hmtmrosterptr:                                  ; home roster pointer; used by AI, INIT
        resb 2
hmtmptrF2:                                      ; home team pointer; used by AI, INIT
        resb 2
hmtmptrs:                                       ; home team pointer; used by AI, INIT
        resb 2
awshots:                                        ; away shots; the away team stats start here
        resb 2
awppgoals:                                      ; away power play goals
        resb 2
awppchances:                                    ; away power play chances
        resb 2
awpenalties:                                    ; away penalties
        resb 2
awpenmins:                                      ; away penalty minutes
        resb 2
awattacktime:                                   ; away attack time
        resb 2
awscore:                                        ; away score; used by AI, LP, MENUS
        resb 10
awtmline:                                       ; away current line; used by AI
        resb 2
awtmlcnt:                                       ; away line count; used by AI
        resb 2
awtmextra:                                      ; away extra skater; used by AI
        resb 2
awtmtouch1:                                     ; away last touch 1; used by AI
        resb 2
awtmtouch2:                                     ; away last touch 2; used by AI
        resb 2
awtmtouch3:                                     ; away last touch 3; used by AI
        resb 2
awtmap:                                         ; away skaters on the ice; used by AI, INIT
        resb 2
awtmgoalie:                                     ; away goalie (negative = pulled); used by AI, INIT, LP
        resb 6
awtmflags:                                      ; away team flags; used by AI, MENUS
        resb 114
awtmpbox_m1:                                    ; away team bytes before awtmpbox (28 bytes); used by AI
        resb 28
awtmcoach_d2:                                   ; away coach data byte; used by AI
        resb 1
awtmcoach_d3:                                   ; away coach data byte; used by AI
        resb 1
awtmcoachflags:                                 ; away coach flags; used by AI
        resb 1
awtmcoachmode:                                  ; away coach mode; used by AI
        resb 1
awtmcoachenergy:                                ; away coach energy setting; used by AI
        resb 2
awtmteamrec:                                    ; away team record pointer; used by AI, INIT, LP
        resb 2
awtmsort:                                       ; away sort objects pointer; used by AI, INIT
        resb 2
awtmglattrseg:                                  ; segment of the away goalie attributes; used by AI, INIT
        resb 2
awtmglattr:                                     ; away goalie attributes pointer; used by AI, INIT
        resb 2
awtmlines:                                      ; away line table pointer; used by AI, INIT
        resb 2
awtmplstats:                                    ; away player stats pointer; used by AI, INIT
        resb 2
awtmglstats:                                    ; away goalie stats pointer; used by AI, INIT
        resb 2
awtmglstatsptr:                                 ; away goalie stats pointer; used by AI, INIT
        resb 2
awtmglstatsseg:                                 ; its segment; used by AI, INIT
        resb 2
awtmptrF2:                                      ; away team pointer; used by AI, INIT
        resb 2
awtmroster:                                     ; away roster pointer; used by AI, INIT
        resb 2
SortCords_m2:                                   ; object address word before SortCords (clearteams stores
                                                ; sort object 6 there); used by AI, INIT
        resb 2
SortCords:                                      ; the sort objects, 80h bytes each; sort object 0 starts here
        resb 2
