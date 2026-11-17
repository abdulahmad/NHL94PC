; DGROUP initialized data (near data of the medium model, paragraph 45C9h): the C runtime's data, strings,
; tables and the game's near variables, shared with the overlays. The BSS (no bytes in the file) is in
; dgroup_bss.asm.
DgroupStart:                                    ; offset 0 of DGROUP; code splits a label across a segment end
                                                ; with label - DgroupStart
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 'MS Run-Time Library - Copyright (c) 1990, Microsoft Corp'
        db 0x18, 0x00
str_Bos:                                        ; string 'BOS'; not used in the EXE (overlays may use it)
        db 'BOS', 0x00
str_Buf:                                        ; string 'BUF'
        db 'BUF', 0x00
str_Cgy:                                        ; string 'CGY'
        db 'CGY', 0x00
str_Chi:                                        ; string 'CHI'; not used in the EXE (overlays may use it)
        db 'CHI', 0x00
str_Det:                                        ; string 'DET'
        db 'DET', 0x00
str_Edm:                                        ; string 'EDM'
        db 'EDM', 0x00
str_Hfd:                                        ; string 'HFD'; not used in the EXE (overlays may use it)
        db 'HFD', 0x00
str_La:                                         ; string 'LA'
        db 'LA', 0x00
str_Min_5:                                      ; string 'MIN'
        db 'MIN', 0x00
str_Mtl:                                        ; string 'MTL'; not used in the EXE (overlays may use it)
        db 'MTL', 0x00
str_Nj:                                         ; string 'NJ'
        db 'NJ', 0x00
str_Nyi:                                        ; string 'NYI'; not used in the EXE (overlays may use it)
        db 'NYI', 0x00
str_Nyr:                                        ; string 'NYR'; not used in the EXE (overlays may use it)
        db 'NYR', 0x00
str_Ott:                                        ; string 'OTT'
        db 'OTT', 0x00
str_Phi:                                        ; string 'PHI'
        db 'PHI', 0x00
str_Pit:                                        ; string 'PIT'
        db 'PIT', 0x00
str_Que:                                        ; string 'QUE'; not used in the EXE (overlays may use it)
        db 'QUE', 0x00
str_Stl:                                        ; string 'STL'; not used in the EXE (overlays may use it)
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
str_Asw:                                        ; string 'ASW'; not used in the EXE (overlays may use it)
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
str_Philadelphia:                               ; string 'PHILADELPHIA'; not used in the EXE (overlays may use
                                                ; it)
        db 'PHILADELPHIA', 0x00
str_Pittsburgh:                                 ; string 'PITTSBURGH'
        db 'PITTSBURGH', 0x00
str_Quebec:                                     ; string 'QUEBEC'; not used in the EXE (overlays may use it)
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
                                                ; CrowdNoiseUpdate, CrowdNoiseOff, CrowdFadeOut
        db 0xFF
AnnouncerFlags:                                 ; bit 80h set while the announcer talks; used by
                                                ; AnnounceOneMinute, AnnouncerBusy, AnnounceGoal ...
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
                                                ; CrowdNoiseUpdate, CrowdNoiseOff, CrowdFadeOut ...
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
                                                ; AnnounceTonightsGame, AnnounceHighlightMatchup,
                                                ; AnnouncePlayoffResult ...
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
EmsMapCache:                                    ; four words. Each is the logical page last mapped on that
                                                ; physical page. The high bit marks it stale; used by EmsMap,
                                                ; EmsMapRange, EmsMarkStale ...
        dw 0xFFFF
EmsMapCache2:                                   ; second EMS map cache word; not used in the EXE (overlays may
                                                ; use it)
        dw 0xFFFF
EmsMapCache3:                                   ; third EMS map cache word; not used in the EXE (overlays may
                                                ; use it)
        dw 0xFFFF
EmsMapCache4:                                   ; fourth EMS map cache word; not used in the EXE (overlays may
                                                ; use it)
        dw 0xFFFF
EmsWindowOff:                                   ; added to the offset within the page when EmsMapRange returns
                                                ; a pointer; used by EmsMapRange
        db 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0xC0
EmsOutPtr:                                      ; far pointer EmsInit writes the allocated size through; used
                                                ; by MakeChain, EmsInit
        dw 0x0000
EmsFramePrev:                                   ; word before EmsFrame; not used in the EXE (overlays may use
                                                ; it)
        dw 0x0000
EmsFrame:                                       ; page-frame segment from INT 67h AH=41h; used by EmsMapRange,
                                                ; EmsInit, EmsMapFrame
        dw 0x0000
EmsHandle:                                      ; EMS handle from INT 67h AH=43h. -1 means none; used by
                                                ; EmsMap, EmsInit, EmsFree
        dw 0xFFFF
EmmName:                                        ; eight bytes compared with the device name at offset 10 of
                                                ; the INT 67h vector; used by EmsInit
        db 'EMMXXXX0initmemman - INSUFFICIENT ROW TABLE SPACE'
        db 0x0A, 0x00
str_LowMem:                                     ; string 'LOW MEM'; not used in the EXE (overlays may use it)
        db 'LOW MEM', 0x00
str_HighMem:                                    ; string 'HIGH MEM'; not used in the EXE (overlays may use it)
        db 'HIGH MEM', 0x00
str_LowEmm:                                     ; string 'LOW EMM'; not used in the EXE (overlays may use it)
        db 'LOW EMM', 0x00
str_HighEmm:                                    ; string 'HIGH EMM'; not used in the EXE (overlays may use it)
        db 'HIGH EMM', 0x00, 0x00
BufCount:                                       ; word; used by MakeChain
        dw 0x03E8
BufPtr:                                         ; word; used by MakeChain, AllocLinearCanvas, AllocCanvas ...
        dw 0x0000
RecSeq:                                         ; word; used by MakeChain, DropOldest
        dw 0x0000
str_ReservememOutOfMemoryRequested:             ; string 'reservemem - OUT OF MEMORY\nrequested: %ld
                                                ; available: %ld\n'; not used in the EXE (overlays may use it)
        db 'reservemem - OUT OF MEMORY'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememOutOfMemoryRequested_2:           ; string 'reservemem - OUT OF MEMORY\nrequested: %ld
                                                ; available: %ld\n'; not used in the EXE (overlays may use it)
        db 'reservemem - OUT OF MEMORY'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememOutOfEmsRequested:                ; string 'reservemem - OUT OF EMS\nrequested: %ld available:
                                                ; %ld\n'; not used in the EXE (overlays may use it)
        db 'reservemem - OUT OF EMS'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememInvalidTypeFlags04x:              ; string 'reservemem - INVALID TYPE FLAGS (%04x)\n'; not
                                                ; referenced in the root code
        db 'reservemem - INVALID TYPE FLAGS (%04x)'
        db 0x0A, 0x00
str_ResizememblockNoRoomToResize:               ; string 'resizememblock - NO ROOM TO RESIZE\n'; not
                                                ; referenced in the root code
        db 'resizememblock - NO ROOM TO RESIZE'
        db 0x0A, 0x00, 'findmemblock - BLOCK NOT FOUND (%Fp)'
        db 0x0A, 0x00
str_GetmemblockNoMemoryBlocksLeft:              ; string 'getmemblock - NO MEMORY BLOCKS LEFT\n'; not
                                                ; referenced in the root code
        db 'getmemblock - NO MEMORY BLOCKS LEFT'
        db 0x0A, 0x00
str_Copyright:                                  ; string 'Copyright'; not used in the EXE (overlays may use
                                                ; it)
        db 'Copyright', 0x00
str_UnpackaInvalidPackCodeX:                    ; string 'unpacka - INVALID PACK CODE (%x)'; not referenced in
                                                ; the root code
        db 'unpacka - INVALID PACK CODE (%x)'
        db 0x00, 0x00
str_InsufficientConventionalMemoryAvaila:       ; string 'Insufficient conventional memory available. Requires
                                                ; an addi...'; not used in the EXE (overlays may use it)
        db 'Insufficient conventional memory available. Requires an additional %ld K'
        db ' bytes', 0x0A, 0x00
str_InsufficientEmsAvailableRequiresAn:         ; string 'Insufficient EMS available. Requires an additional
                                                ; %ld K byt...'; not used in the EXE (overlays may use it)
        db 'Insufficient EMS available. Requires an additional %ld K bytes'
        db 0x0A, 0x00
str_Pointer3:                                   ; string 'pointer3'; not used in the EXE (overlays may use it)
        db 'pointer3', 0x00
str_Pntr:                                       ; string 'pntr'; not used in the EXE (overlays may use it)
        db 'pntr', 0x00
str_Wittle06Fnt:                                ; string 'wittle06.fnt'; not used in the EXE (overlays may use
                                                ; it)
        db 'wittle06.fnt', 0x00
str_Scor2bFnt:                                  ; string 'scor2b.fnt'; not used in the EXE (overlays may use
                                                ; it)
        db 'scor2b.fnt', 0x00
str_Scor3bFnt:                                  ; string 'scor3b.fnt'; not used in the EXE (overlays may use
                                                ; it)
        db 'scor3b.fnt', 0x00
str_GameSet:                                    ; string 'game.set'; not used in the EXE (overlays may use it)
        db 'game.set', 0x00
        db 'd3', 0x00, 'd4', 0x00
str_Temp:                                       ; string 'temp'; not used in the EXE (overlays may use it)
        db 'temp', 0x00
str_Temp_2:                                     ; string 'temp'; not used in the EXE (overlays may use it)
        db 'temp', 0x00
InputQueueCount:                                ; events waiting (at most 32); used by GetInputEvent,
                                                ; PollInputEvents
        dw 0x0000
InputQueueHead:                                 ; next event to read; used by GetInputEvent, FlushInputEvents
        dw 0x001F
InputQueueTail:                                 ; next free event slot; used by PollInputEvents
        dw 0x0000
PollCountdown:                                  ; polls until the next device read (reset to 5); used by
                                                ; PollInputEvents
        dw 0x000A
MouseEnabled:                                   ; mouse read when non-zero; used by ReadMouseEvent
        dw 0x0000
StickEnabled:                                   ; joysticks read when non-zero; used by ReadStickEvent
        dw 0x0000
KeysEnabled:                                    ; keyboard read when non-zero; used by ReadKeyEvent
        dw 0x0000
MousePosX:                                      ; last mouse x; used by EventToCursor, ReadMouseEvent
        dw 0x0000
MousePosY:                                      ; last mouse y; used by EventToCursor, ReadMouseEvent
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
StickPresent:                                   ; joystick 1 present; used by StickToPad
        dw 0x0000
StickPresent2:                                  ; joystick 2 present; not used in the EXE (overlays may use
                                                ; it)
        dw 0x0000
PadTickCount:                                   ; timer ticks counted by PadTimerTick (wraps at 1000); used by
                                                ; PadTimerTick
        dw 0x0000
PadRepeatOn:                                    ; key repeat active; used by PadTimerTick
        dw 0x0000
PadRepeatStep:                                  ; repeat interval; used by PadTimerTick
        dw 0x0000
PadRepeatDelay:                                 ; first repeat delay; used by PadTimerTick, PadTimerTickTail
        dw 0x0000
PadRepeatTimer:                                 ; ticks left before the next repeat; used by PadTimerTick
        dw 0x0000
PadStates:                                      ; state byte per pad; used by ReadPadDevice, PadTimerTick
        db 0x08
PadStates2:                                     ; second pad's state byte; used by PadTimerTick
        db 0x02
HotKeyPending:                                  ; hot key waiting to be read; used by ReadHotKey
        db 0x00, 0x00
KeyPadMap:                                      ; keys to pad bits; used by KeysToPad, StickToPad
        db 0x08, 0x00, 0x04, 0x08, 0x02, 0x01, 0x03, 0x02, 0x06, 0x07, 0x05, 0x06, 0x08, 0x00, 0x04, 0x08, 'pause.msc'
        db 0x00
str_SS:                                         ; string '%s.%s'; used by SayHighlightMatchup,
                                                ; SayPlayoffResult, SayPeriodSummary ...
        db '%s.%s', 0x00
str_ByMsc:                                      ; string 'by.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'by.msc', 0x00, 0x00
str_AtMsc:                                      ; string 'at.msc'; used by SayPenalty, OpenPlayByPlaySpeech
        db 'at.msc', 0x00, 0x00
str_AndMsc:                                     ; string 'and.msc'; used by SayPenalty, SayGoal,
                                                ; OpenPlayByPlaySpeech
        db 'and.msc', 0x00
str_FromtheMsc:                                 ; string 'fromthe.msc'; used by SayPlayerFrom
        db 'fromthe.msc', 0x00
str_FromMsc:                                    ; string 'from.msc'; used by SayPlayerFrom
        db 'from.msc', 0x00, 0x00
str_MinuteMsc:                                  ; string 'minute.msc'; used by SayPenalty
        db 'minute.msc', 0x00, 0x00
str_MinutesMsc:                                 ; string 'minutes.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'minutes.msc', 0x00
str_SecondMsc:                                  ; string 'second.msc'; used by SayPenalty
        db 'second.msc', 0x00, 0x00
str_SecondsMsc:                                 ; string 'seconds.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'seconds.msc', 0x00
str_PenaltyMsc:                                 ; string 'penalty.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'penalty.msc', 0x00
str_GoalsMsc:                                   ; string 'goals.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'goals.msc', 0x00
str_AssistedMsc:                                ; string 'assisted.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'assisted.msc', 0x00, 0x00
str_OneminMsc:                                  ; string 'onemin.msc'; used by SayOneMinuteLeft,
                                                ; OpenPlayByPlaySpeech
        db 'onemin.msc', 0x00, 0x00
str_2minsOff:                                   ; string '2mins.off'; used by OpenPlayByPlaySpeech
        db '2mins.off', 0x00
str_NumberMsc:                                  ; string 'number.msc'; used by SayPenalty, SayPlayerFrom,
                                                ; SayGoal ...
        db 'number.msc', 0x00, 0x00
        db 'easports.int', 0x00, 0x00
        db 'nhl.int', 0x00
        db 'of.bar', 0x00, 0x00
str_NumberBar:                                  ; string 'number.bar'; used by SayTonightsPlayoffGame
        db 'number.bar', 0x00, 0x00
str_DivisionBar:                                ; string 'division.bar'; used by SayPlayoffResult,
                                                ; SayTonightsPlayoffGame
        db 'division.bar', 0x00, 0x00
str_ConfBar:                                    ; string 'conf.bar'; used by SayPlayoffResult,
                                                ; SayTonightsPlayoffGame
        db 'conf.bar', 0x00, 0x00
str_FinalBar:                                   ; string 'final.bar'; used by SayPlayoffResult,
                                                ; SayTonightsPlayoffGame
        db 'final.bar', 0x00
str_SemiBar:                                    ; string 'semi.bar'; used by SayPlayoffResult,
                                                ; SayTonightsPlayoffGame
str_SemiBar_2:                                  ; string 'semi.bar'; used by AI
        db 'semi.bar', 0x00, 0x00
str_AndBar:                                     ; string 'and.bar'; used by SayHighlightMatchup,
                                                ; SayTonightsGame, SayTonightsPlayoffGame
        db 'and.bar', 0x00
str_BetweenBar:                                 ; string 'between.bar'; used by SayTonightsPlayoffGame
        db 'between.bar', 0x00
str_GamenumBar:                                 ; string 'gamenum.bar'; used by SayPlayoffResult,
                                                ; SayTonightsPlayoffGame
        db 'gamenum.bar', 0x00
str_EasportsBar:                                ; string 'easports.bar'; used by SayTonightsGame,
                                                ; SayTonightsPlayoffGame
        db 'easports.bar', 0x00, 0x00
str_PeriodBar:                                  ; string 'period.bar'; used by SayPeriodSummary
        db 'period.bar', 0x00, 0x00
str_TonightBar:                                 ; string 'tonight.bar'; used by SayTonightsGame,
                                                ; SayTonightsPlayoffGame
        db 'tonight.bar', 0x00
str_GamebtwnBar:                                ; string 'gamebtwn.bar'; used by SayHighlightMatchup,
                                                ; SayTonightsGame
        db 'gamebtwn.bar', 0x00, 0x00
        db 'presents.int', 0x00, 0x00
        db 'hockey.int', 0x00, 0x00
str_ImrbarrInt:                                 ; string 'imrbarr.int'; used by SayGoodnight
        db 'imrbarr.int', 0x00
str_GoodniteInt:                                ; string 'goodnite.int'; used by SayGoodnight
        db 'goodnite.int', 0x00, 0x00
str_LineupsInt:                                 ; string 'lineups.int'; used by SayLineups
        db 'lineups.int', 0x00
        db 'elsewher.int', 0x00, 0x00
        db 'tonight.int', 0x00
str_TakeynowBar:                                ; string 'takeynow.bar'; used by SayHighlightMatchup
        db 'takeynow.bar', 0x00, 0x00
str_HighliteBar:                                ; string 'highlite.bar'; used by SayHighlightMatchup
        db 'highlite.bar', 0x00, 0x00
str_OvertimeBar:                                ; string 'overtime.bar'; used by SayPlayoffResult
        db 'overtime.bar', 0x00, 0x00
str_HavewonBar:                                 ; string 'havewon.bar'; used by SayPlayoffResult
        db 'havewon.bar', 0x00
str_ScoringBar:                                 ; string 'scoring.bar'; used by SayPeriodSummary
        db 'scoring.bar', 0x00
str_ThegameBar:                                 ; string 'thegame.bar'; used by SayPeriodSummary
        db 'thegame.bar', 0x00
str_OtBar:                                      ; string 'ot.bar'; used by SayPeriodSummary
        db 'ot.bar', 0x00, 0x00
str_TheotBar:                                   ; string 'theot.bar'; used by SayPeriodSummary
        db 'theot.bar', 0x00
str_TonightMsc:                                 ; string 'tonight.msc'; used by SayPlayerFrom
        db 'tonight.msc', 0x00
SpeechTickCount:                                ; speech timer ticks; used by SpeechTimerTick, SpeechInit
        dw 0x0000
SpeechSampleBusy:                               ; a sample is playing; used by SpeechTimerTick, SpeechInit,
                                                ; SpeechShutdown ...
        db 0x00, 0x00
SpeechMemOff:                                   ; speech memory block, offset; used by SpeechInit,
                                                ; MoveMemBlock
        dw 0x0000
SpeechMemSeg:                                   ; speech memory block, segment; used by SpeechInit,
                                                ; MoveMemBlock
        dw 0x0000
SpeechOn:                                       ; speech system initialised; used by SpeechTimerTick,
                                                ; SpeechInit, SpeechShutdown ...
        dw 0x0000
str_Speechbuf:                                  ; string 'speechbuf'; not used in the EXE (overlays may use
                                                ; it)
        db 'speechbuf', 0x00
str_Sentence:                                   ; string 'sentence'; not used in the EXE (overlays may use it)
        db 'sentence', 0x00
str_SpeechBank:                                 ; string 'speech bank'; not used in the EXE (overlays may use
                                                ; it)
        db 'speech bank', 0x00
str_SampleMemMan:                               ; string 'sample mem man'; not used in the EXE (overlays may
                                                ; use it)
        db 'sample mem man', 0x00
str_Pause:                                      ; string 'pause'; not used in the EXE (overlays may use it)
        db 'pause', 0x00
str_Off:                                        ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_2minsS:                                     ; string '2mins.%s'; used by GameLengthSampleName
        db '2mins.%s', 0x00
str_Off_2:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_5minsS:                                     ; string '5mins.%s'; used by GameLengthSampleName
        db '5mins.%s', 0x00
str_Off_3:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_10minsS:                                    ; string '10mins.%s'; used by GameLengthSampleName
        db '10mins.%s', 0x00
str_Off_4:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_GamemisS:                                   ; string 'gamemis.%s'; used by GameLengthSampleName
        db 'gamemis.%s', 0x00
str_SmytheBar:                                  ; string 'smythe.bar'; used by DivisionSampleName
        db 'smythe.bar', 0x00
str_NorrisBar:                                  ; string 'norris.bar'; used by DivisionSampleName
        db 'norris.bar', 0x00
str_AdamsBar:                                   ; string 'adams.bar'; used by DivisionSampleName
        db 'adams.bar', 0x00
str_PatrickBar:                                 ; string 'patrick.bar'; used by DivisionSampleName
        db 'patrick.bar', 0x00
str_CampbellBar:                                ; string 'campbell.bar'; used by DivisionSampleName
        db 'campbell.bar', 0x00
str_WalesBar:                                   ; string 'wales.bar'; used by DivisionSampleName
        db 'wales.bar', 0x00
str_StanleyBar:                                 ; string 'stanley.bar'; used by DivisionSampleName
        db 'stanley.bar', 0x00
str_EaNhlInt:                                   ; string 'ea_nhl.int'; used by SayEaNhlIntro
        db 'ea_nhl.int', 0x00
str_EaNhlInt_2:                                 ; string 'ea_nhl.int'; used by SayEaNhlIntro
str_EaNhlInt_3:                                 ; string 'ea_nhl.int'; used by AI
        db 'ea_nhl.int', 0x00
str_ElsenhlInt:                                 ; string 'elsenhl.int'; used by SayElseAroundNhl
        db 'elsenhl.int', 0x00
str_ElsenhlInt_2:                               ; string 'elsenhl.int'; used by SayElseAroundNhl
        db 'elsenhl.int', 0x00
str_Rnk:                                        ; string 'rnk'; used by SayHighlightMatchup
        db 'rnk', 0x00
str_Awa:                                        ; string 'awa'; used by SayHighlightMatchup
        db 'awa', 0x00
str_Hom:                                        ; string 'hom'; used by SayHighlightMatchup
        db 'hom', 0x00
str_Awa_2:                                      ; string 'awa'; used by SayPlayoffResult
        db 'awa', 0x00
str_Bar:                                        ; string 'bar'; used by SayPlayoffResult
        db 'bar', 0x00
str_Bar_2:                                      ; string 'bar'; used by SayPeriodSummary
        db 'bar', 0x00
str_Rnk_2:                                      ; string 'rnk'; used by SayTonightsGame
        db 'rnk', 0x00
str_Awa_3:                                      ; string 'awa'; used by SayTonightsGame
        db 'awa', 0x00
str_Hom_2:                                      ; string 'hom'; used by SayTonightsGame
        db 'hom', 0x00
str_Rnk_3:                                      ; string 'rnk'; used by SayTonightsPlayoffGame
        db 'rnk', 0x00
str_Awa_4:                                      ; string 'awa'; used by SayTonightsPlayoffGame
        db 'awa', 0x00
str_Hom_3:                                      ; string 'hom'; used by SayTonightsPlayoffGame
        db 'hom', 0x00
str_Bar_3:                                      ; string 'bar'; used by SayTonightsPlayoffGame
        db 'bar', 0x00
str_Cty:                                        ; string 'cty'; used by SayPenalty
        db 'cty', 0x00
str_Bru:                                        ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_2:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Off_5:                                      ; string 'off'; used by SayPenalty
        db 'off', 0x00
str_Bru_3:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_4:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_5:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_6:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Cty_2:                                      ; string 'cty'; used by SayPlayerFrom
        db 'cty', 0x00
str_Msc:                                        ; string 'msc'; used by SayPlayerFrom
        db 'msc', 0x00
str_Bru_7:                                      ; string 'bru'; used by SayPlayerFrom
        db 'bru', 0x00
str_Bru_8:                                      ; string 'bru'; used by SayPlayerFrom
        db 'bru', 0x00
str_Cty_3:                                      ; string 'cty'; used by SayGoal
        db 'cty', 0x00
str_Bru_9:                                      ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_10:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_11:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_12:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_13:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_14:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Xrbarr2Viv:                                 ; string 'xrbarr2.viv'; used by OpenStudioSpeech
        db 'xrbarr2.viv', 0x00
str_Xbruce2Viv:                                 ; string 'xbruce2.viv'; used by OpenPlayByPlaySpeech
        db 'xbruce2.viv', 0x00
str_Cty_4:                                      ; string 'cty'; used by OpenPlayByPlaySpeech
        db 'cty', 0x00
str_Cty_5:                                      ; string 'cty'; used by OpenPlayByPlaySpeech
        db 'cty', 0x00
InputInstalled:                                 ; input hooks installed; used by InputInit, InputShutdown
        dw 0x0000
MouseRangeX:                                    ; mouse range in x; used by InputInit, InputShutdown,
                                                ; EventToCursor
        dw 0x0000
MouseRangeY:                                    ; mouse range in y; used by InputInit, InputShutdown
        db 0x00, 0x00
ScreenRowStride:                                ; bytes per row of the planar screen: 50h, or 52h on the wide
                                                ; screens; used by INIT, MENUS
        db 0x50, 0x00
RinkTilesPtr:                                   ; far pointer (offset) to the loaded rink tiles; used by AI,
                                                ; GAME, INIT
        db 0x00, 0x00
RinkTilesSeg:                                   ; its segment; used by AI, GAME, INIT
        db 0x00, 0x00
        db 'h2', 0x00, 'h3', 0x00
str_GsummaryDb:                                 ; string 'gsummary.db'; not used in the EXE (overlays may use
                                                ; it)
        db 'gsummary.db', 0x00
str_GsummaryDb_2:                               ; string 'gsummary.db'; not used in the EXE (overlays may use
                                                ; it)
        db 'gsummary.db', 0x00
        db 'h4', 0x00, 'h5', 0x00
        db 'h6', 0x00, 'h7', 0x00
        db 0x5C, 0x00
str_GameSav:                                    ; string 'game.sav'; used by SaveGame
        db 'game.sav', 0x00
        db 'h1', 0x00
str_Sav:                                        ; string '.sav'; used by SaveGame
        db '.sav', 0x00
str_Db:                                         ; string '.db'; used by SaveGame
        db '.db', 0x00
str_Gsummary:                                   ; string 'gsummary'; not used in the EXE (overlays may use it)
        db 'gsummary', 0x00
        db 'A3', 0x00
str_Pointer:                                    ; string 'pointer'; not used in the EXE (overlays may use it)
        db 'pointer', 0x00
str_Savegame:                                   ; string 'savegame'; used by SaveGameNameDialog
        db 'savegame', 0x00
str_Prmt:                                       ; string 'prmt'; used by SaveGameNameDialog
        db 'prmt', 0x00
str_Dialog:                                     ; string 'dialog'; not used in the EXE (overlays may use it)
        db 'dialog', 0x00
str_Nhl:                                        ; string '.nhl'; used by SaveGameNameDialog
        db '.nhl', 0x00
str_Err1:                                       ; string 'err1'; used by SaveGameNameDialog
        db 'err1', 0x00
str_Dialog_2:                                   ; string 'dialog'; not used in the EXE (overlays may use it)
        db 'dialog', 0x00
str_Nhl_2:                                      ; string '.nhl'; used by SaveGameNameDialog
        db '.nhl', 0x00
str_Prmt_2:                                     ; string 'prmt'; used by SaveGameNameDialog
        db 'prmt', 0x00
str_Dialog_3:                                   ; string 'dialog'; not used in the EXE (overlays may use it)
        db 'dialog', 0x00
str_D:                                          ; string '%d\n'; not used in the EXE (overlays may use it)
        db 0x25, 0x64, 0x0A, 0x00
str_Nhl_3:                                      ; string '.nhl'; used by SaveGameNameDialog
        db '.nhl', 0x00, 0x00
TextColor:                                      ; text colour for the shadow and outline text; used by
                                                ; SetTextColors, DrawShadowTextCentered, DrawShadowText ...
        dw 0x000F
ShadowColor:                                    ; shadow colour; used by SetTextColors,
                                                ; DrawShadowTextCentered, DrawShadowText ...
        dw 0x0000
OutlineDx:                                      ; x offsets of the outline passes; used by DrawOutlineText
        db 0xFF, 0xFF, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
OutlineDy:                                      ; y offsets of the outline passes; used by DrawOutlineText
        db 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x01, 0x00
Dir8Table:                                      ; direction for each octant; used by VectorToDir8Tail
        db 0x01, 0x07, 0x03, 0x05, 0x00, 0x00, 0x04, 0x04, 0x02, 0x06, 0x02, 0x06, 0x01, 0x07, 0x03, 0x05
OldInt0Seg:                                     ; saved divide-error vector, segment; used by HookDivideError,
                                                ; UnhookDivideError
        dw 0x0000
OldInt0Off:                                     ; saved divide-error vector, offset; used by HookDivideError,
                                                ; UnhookDivideError
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
DivideFault:                                    ; set to 1 by DivideHandler when a divide faults
        db 0x00, 0x00
str_HomepalsBin:                                ; string 'HOMEPALS.BIN'; not used in the EXE (overlays may use
                                                ; it)
        db 'HOMEPALS.BIN', 0x00
str_AwaypalsBin:                                ; string 'AWAYPALS.BIN'; not used in the EXE (overlays may use
                                                ; it)
        db 'AWAYPALS.BIN', 0x00
str_Rinkpal:                                    ; string 'rinkpal'; used by LoadTeamPalettes
        db 'rinkpal', 0x00
str_Pal:                                        ; string '!pal'; used by LoadTeamPalettes
        db '!pal', 0x00, 0x00
DialogBackColor:                                ; dialog background colour; used by NumberEntryDialog,
                                                ; DrawListRow, ListDialog ...
        dw 0x002A
DialogLightColor:                               ; dialog bevel light colour; used by NumberEntryDialog,
                                                ; ListDialog, SetDialogColors ...
        dw 0x003F
DialogDarkColor:                                ; dialog bevel dark colour; used by NumberEntryDialog,
                                                ; ListDialog, SetDialogColors ...
        dw 0x0017
ItemTextColor:                                  ; list item text colour; used by NumberEntryDialog,
                                                ; ItemColors, DrawListRow ...
        dw 0x003F
ItemSelectColor:                                ; selected list item colour; used by NumberEntryDialog,
                                                ; ItemColors, DrawListRow ...
        db 0x00, 0x00, 0x00, 0x00
SaveUnderOff:                                   ; saved screen under a box, offset; used by SaveUnderBox,
                                                ; RestoreUnderBox
        dw 0x0000
SaveUnderSeg:                                   ; saved screen under a box, segment; used by SaveUnderBox,
                                                ; RestoreUnderBox
        dw 0x0000
str_Pointer_2:                                  ; string 'Pointer'; not used in the EXE (overlays may use it)
        db 'Pointer', 0x00
str_Dbox:                                       ; string 'DBOX'; not used in the EXE (overlays may use it)
        db 'DBOX', 0x00
str_Pointer_3:                                  ; string 'Pointer'; not used in the EXE (overlays may use it)
str_Pointer_15:                                 ; string 'Pointer'; used by AI
        db 'Pointer', 0x00, 0x00
JingleHandle:                                   ; playing jingle, low word (-1 for none); used by StopJingle,
                                                ; PlayJingle, WaitJingle
        dw 0xFFFF
JingleHandleHi:                                 ; playing jingle, high word; used by StopJingle, PlayJingle,
                                                ; WaitJingle
        dw 0xFFFF
Crowdlevel:                                     ; crowd noise level the crowd update ramps; used by
                                                ; CrowdNoiseUpdate, CrowdReset
        dw 0x0000
CrowdTarget:                                    ; crowd level being faded to; used by CrowdNoiseUpdate,
                                                ; CrowdNoiseOff, CrowdReset
        dw 0x0000
CrowdFade:                                      ; crowd fade step; used by CrowdNoiseUpdate, CrowdNoiseOff,
                                                ; CrowdReset
        dw 0x0000
str_Plane0:                                     ; string 'Plane 0'; not used in the EXE (overlays may use it)
        db 'Plane 0', 0x00
str_Plane1:                                     ; string 'Plane 1'; not used in the EXE (overlays may use it)
        db 'Plane 1', 0x00
str_Plane2:                                     ; string 'Plane 2'; not used in the EXE (overlays may use it)
        db 'Plane 2', 0x00
str_Plane3:                                     ; string 'Plane 3'; not used in the EXE (overlays may use it)
        db 'Plane 3', 0x00
EventPending:                                   ; an event is held back; used by GetInputEvent
        db 0x00, 0x00
str_Bkgd_10:                                    ; string 'BKGD'; used by MENUS, STATS
        db 'BKGD', 0x00
str_Bkgd_9:                                     ; string 'BKGD'; used by MENUS
        db 'BKGD', 0x00
str_TeamsDb:                                    ; string 'teams.db'; used by MENUS
        db 'teams.db', 0x00
        db 'C1', 0x00, 'C2', 0x00
        db 'C3', 0x00, 'C5', 0x00
        db 0x43, 0x36, 0x00
str_Player_3:                                   ; string 'player'; used by MENUS
        db 'player', 0x00
str_Dbox_12:                                    ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Dbox_11:                                    ; string 'dbox'; used by MENUS
        db 'dbox', 0x00, 0x00
str_DDSVsSPeriodDTime02d02d:                    ; string '%d %d, %s vs %s, Period %d, Time %02d:%02d.'
                                                ; used by MENUS
        db '%d %d, %s vs %s, Period %d, Time %02d:%02d.'
        db 0x00, 0x2E, 0x00
str_Hltl:                                       ; string 'HLTL'; used by MENUS
        db 'HLTL', 0x00
str_Hlt:                                        ; string 'HLT'; used by MENUS
        db 'HLT', 0x00
str_Hlts:                                       ; string 'HLTS'; used by MENUS
        db 'HLTS', 0x00
str_MttitleKms_2:                               ; string 'mttitle.kms'; used by MENUS
        db 'mttitle.kms', 0x00
str_MttitleCfg_2:                               ; string 'mttitle.cfg'; used by MENUS
        db 'mttitle.cfg', 0x00
str_AdtitleKms_2:                               ; string 'adtitle.kms'; used by MENUS
        db 'adtitle.kms', 0x00
str_AdtitleCfg_2:                               ; string 'adtitle.cfg'; used by MENUS
        db 'adtitle.cfg', 0x00
str_Eaopen:                                     ; string 'eaopen'; used by MENUS
        db 'eaopen', 0x00
str_Pal_72:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Scrn_4:                                     ; string 'scrn'; used by MENUS
        db 'scrn', 0x00
str_Eascrn:                                     ; string 'eascrn'; used by MENUS
        db 'eascrn', 0x00
str_Pal_71:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Scrn_3:                                     ; string 'scrn'; used by MENUS
        db 'scrn', 0x00
str_Title2:                                     ; string 'title2'; used by MENUS
        db 'title2', 0x00
str_Pal_70:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_1111:                                       ; string '1111'; used by MENUS
        db '1111', 0x00
str_2222:                                       ; string '2222'; used by AI, MENUS
        db '2222', 0x00
str_Hock:                                       ; string 'hock'; used by MENUS
        db 'hock', 0x00
str_Copy:                                       ; string 'copy'; used by MENUS
        db 'copy', 0x00
str_Alls03:                                     ; string 'alls03'; used by MENUS
        db 'alls03', 0x00
str_Ividframe:                                  ; string 'ividframe'; used by MENUS
        db 'ividframe', 0x00
str_S1Fnt_6:                                    ; string 's1.fnt'; used by AI, MENUS
        db 's1.fnt', 0x00
str_Summary_4:                                  ; string 'summary'; used by MENUS
        db 'summary', 0x00
str_City_4:                                     ; string 'city'; used by MENUS
        db 'city', 0x00
str_Pal_69:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_MttitleKms:                                 ; string 'mttitle.kms'; used by MENUS
        db 'mttitle.kms', 0x00
str_MttitleCfg:                                 ; string 'mttitle.cfg'; used by MENUS
        db 'mttitle.cfg', 0x00
str_AdtitleKms:                                 ; string 'adtitle.kms'; used by MENUS
        db 'adtitle.kms', 0x00
str_AdtitleCfg:                                 ; string 'adtitle.cfg'; used by MENUS
        db 'adtitle.cfg', 0x00
str_RockditiKms:                                ; string 'rockditi.kms'; used by LP, MENUS
        db 'rockditi.kms', 0x00
str_RockditiCfg:                                ; string 'rockditi.cfg'; used by MENUS
        db 'rockditi.cfg', 0x00
str_LineditFnt_2:                               ; string 'linedit.fnt'; used by MENUS
        db 'linedit.fnt', 0x00
str_Lineditp_5:                                 ; string 'lineditp'; used by MENUS
        db 'lineditp', 0x00
str_Shrt_2:                                     ; string 'shrt'; used by AI, MENUS
        db 'shrt', 0x00
str_Pntr_18:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Pointer_14:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00
str_Pal_68:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Menubuff_10:                                ; string 'menubuff'; used by MENUS
        db 'menubuff', 0x00
str_C2dS_8:                                     ; string '%c %2d %s'; used by MENUS
        db '%c %2d %s', 0x00
str_C2dS_7:                                     ; string '%c %2d %s'; used by MENUS
        db '%c %2d %s', 0x00
str_Key_2:                                      ; string 'key'; used by MENUS
        db 'key', 0x00
        db 'A1', 0x00, 'A2', 0x00
        db 'A3', 0x00, 'A4', 0x00
        db 'A5', 0x00, 'A6', 0x00
        db 'A7', 0x00, 'A8', 0x00
str_C2dS_6:                                     ; string '%c %2d %s'; used by LP, MENUS
        db '%c %2d %s', 0x00
str_EmbS_2:                                     ; string 'emb%s'; used by MENUS
        db 'emb%s', 0x00
str_HomepalsBin_6:                              ; string 'HOMEPALS.BIN'; used by MENUS
        db 'HOMEPALS.BIN', 0x00
str_Bkgd_8:                                     ; string 'bkgd'; used by MENUS
        db 'bkgd', 0x00
str_Plaque_2:                                   ; string 'plaque'; used by MENUS
        db 'plaque', 0x00
str_S_4:                                        ; string '%s   '; used by MENUS
        db '%s   ', 0x00
str_Forward_4:                                  ; string 'forward'; used by MENUS
        db 'forward', 0x00
str_Line1_2:                                    ; string 'line 1'; used by MENUS
        db 'line 1', 0x00
str_Forward_3:                                  ; string 'forward'; used by MENUS
        db 'forward', 0x00
str_Line2_2:                                    ; string 'line 2'; used by MENUS
        db 'line 2', 0x00
str_Forward_2:                                  ; string 'forward'; used by MENUS
        db 'forward', 0x00
str_Line3_2:                                    ; string 'line 3'; used by MENUS
        db 'line 3', 0x00
str_Forward:                                    ; string 'forward'; used by MENUS
        db 'forward', 0x00
str_Line4:                                      ; string 'line 4'; used by MENUS
        db 'line 4', 0x00
str_Penalty_2:                                  ; string 'penalty'; used by MENUS
        db 'penalty', 0x00
str_Kill1:                                      ; string 'kill 1'; used by MENUS
        db 'kill 1', 0x00
str_Penalty:                                    ; string 'penalty'; used by MENUS
        db 'penalty', 0x00
str_Kill2:                                      ; string 'kill 2'; used by MENUS
        db 'kill 2', 0x00
str_Power_2:                                    ; string 'power'; used by MENUS
        db 'power', 0x00
str_Play1:                                      ; string 'play 1'; used by MENUS
        db 'play 1', 0x00
str_Power:                                      ; string 'power'; used by MENUS
        db 'power', 0x00
str_Play2:                                      ; string 'play 2'; used by MENUS
        db 'play 2', 0x00
str_Defense_4:                                  ; string 'defense'; used by MENUS
        db 'defense', 0x00
str_Line1:                                      ; string 'line 1'; used by MENUS
        db 'line 1', 0x00
str_Defense_3:                                  ; string 'defense'; used by MENUS
        db 'defense', 0x00
str_Line2:                                      ; string 'line 2'; used by MENUS
        db 'line 2', 0x00
str_Defense_2:                                  ; string 'defense'; used by MENUS
        db 'defense', 0x00
str_Line3:                                      ; string 'line 3'; used by MENUS
        db 'line 3', 0x00
str_Goaltenders:                                ; string 'goaltenders'; used by MENUS
        db 'goaltenders', 0x00
str_Extra:                                      ; string 'extra'; used by MENUS
        db 'extra', 0x00
str_Attackers:                                  ; string 'attackers'; used by MENUS
        db 'attackers', 0x00
str_Pal_67:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_HomepalsBin_5:                              ; string 'HOMEPALS.BIN'; used by MENUS
        db 'HOMEPALS.BIN', 0x00
str_YourRosterIsIncomplete:                     ; string 'Your Roster is incomplete.'; used by MENUS
        db 'Your Roster is incomplete.'
        db 0x00
str_Scratch:                                    ; string 'Scratch'; used by MENUS
        db 'Scratch', 0x00
str_Dress:                                      ; string 'Dress'; used by MENUS
        db 'Dress', 0x00
str_Player_4:                                   ; string 'Player'; used by MENUS
        db 'Player', 0x00
str_Goalie:                                     ; string 'Goalie'; used by MENUS
        db 'Goalie', 0x00
str_S2dSS:                                      ; string '%s %2d %s%s'; used by MENUS
        db '%s %2d %s%s', 0x00
        db 0x2E, 0x00, 's.', 0x00
        db 0x2E, 0x00, 's.', 0x00
        db 0x2E, 0x00, 's.', 0x00
        db 0x2E, 0x00, 's.', 0x00
str_Teams_7:                                    ; string 'teams'; used by MENUS
        db 'teams', 0x00
str_Teams_6:                                    ; string 'teams'; used by MENUS
        db 'teams', 0x00
str_B2:                                         ; string 'b2:'; used by MENUS
        db 'b2:', 0x00
        db 'B3', 0x00, 'B4', 0x00
        db 'B5', 0x00, 'B6', 0x00
        db 0x42, 0x37, 0x00
str_Teams_5:                                    ; string 'teams'; used by MENUS
        db 'teams', 0x00
str_Teams_4:                                    ; string 'teams'; used by MENUS
        db 'teams', 0x00
        db 'B2', 0x00, 'B3', 0x00
        db 'B4', 0x00, 'B5', 0x00
        db 'B6', 0x00, 'B7', 0x00
str_Tstat_4:                                    ; string 'tstat'; used by MENUS
        db 'tstat', 0x00
str_Keys_6:                                     ; string 'keys'; used by MENUS
        db 'keys', 0x00
str_Pstat_6:                                    ; string 'pstat'; used by AI, MENUS
        db 'pstat', 0x00
str_Gstat_6:                                    ; string 'gstat'; used by MENUS
        db 'gstat', 0x00
str_C2dS_5:                                     ; string '%c %2d %s'; used by MENUS
        db '%c %2d %s', 0x00
str_C2dS_4:                                     ; string '%c %2d %s'; used by MENUS
        db '%c %2d %s', 0x00
str_C2dS_3:                                     ; string '%c %2d %s'; used by MENUS
        db '%c %2d %s', 0x00, 0x00
str_Dbox_10:                                    ; string 'DBOX'; used by MENUS
        db 'DBOX', 0x00
str_Pointer_13:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00, 0x00
JerseyDigitGlyphsMenus:                         ; the MENUS copy of the jersey digits 0 to 9, 3 by 5 pixels
                                                ; each (15 bytes, 1 = set); used by BlitJerseyDigit
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
        db 0x00, 0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00
        db 0x00, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00
        db 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01
        db 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
        db 0x00, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01
        db 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x00
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, '.nhl', 0x00, 'k1', 0x00
str_GsummaryDb_4:                               ; string 'gsummary.db'; used by MENUS
        db 'gsummary.db', 0x00
        db 'k2', 0x00, 'k3', 0x00
        db 'k4', 0x00, 'k5', 0x00
        db 'k6', 0x00, 'k7', 0x00
        db 'k8', 0x00, 'h7', 0x00
str_Db_6:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Sav_5:                                      ; string '.sav'; used by MENUS
        db '.sav', 0x00
str_Gsummary_5:                                 ; string 'gsummary'; used by MENUS
        db 'gsummary', 0x00
        db 0x41, 0x31, 0x00
str_PoGameSav:                                  ; string '.po\game.sav'; used by MENUS
        db '.po\game.sav', 0x00
        db 0x6C, 0x31, 0x00
str_Db_5:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Sav_4:                                      ; string '.sav'; used by MENUS
        db '.sav', 0x00
str_Gsummary_4:                                 ; string 'gsummary'; used by MENUS
        db 'gsummary', 0x00
        db 0x41, 0x32, 0x00
str_LpGameSav:                                  ; string '.lp\game.sav'; used by MENUS
        db '.lp\game.sav', 0x00
        db 0x6C, 0x32, 0x00
FileDlgSpecs:                                   ; file dialog table: pointers to the file patterns per dialog;
                                                ; used by MENUS
        db 0xDC, 0xC0
FileDlgSpec2:                                   ; second file pattern pointer; used by MENUS
        db 0x64, 0xC1
FileDlgSpec3:                                   ; third file pattern pointer; used by MENUS
        db 0x54, 0xC0, '*.lp', 0x00
str_Po_3:                                       ; string '*.po'; used by MENUS
        db '*.po', 0x00
str_Nhl_6:                                      ; string '*.nhl'; used by MENUS
        db '*.nhl', 0x00
str_Dialogbx:                                   ; string 'dialogbx'; used by MENUS
        db 'dialogbx', 0x00
str_Dbox_9:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Nhl_4:                                      ; string '.NHL'; not used in the EXE (overlays may use it)
        db '.NHL', 0x00
        db '.PO', 0x00
        db '.LP', 0x00
        db 0x63, 0x32, 0x00
str_AllFiles:                                   ; string '*.*'; used by MENUS
        db '*.*', 0x00
        db 'c3', 0x00, '..', 0x00
        db 'c4', 0x00, 'c5', 0x00
        db 0x63, 0x36, 0x00, 0x00
msgConfirmDeletionOfThe:                        ; message list of 1 far string pointer: 'Confirm Deletion of
                                                ; the'; used by MENUS
        dw str_ConfirmDeletionOfThe, 0x369A
DelFileName:                                    ; far pointer (offset) to the saved game DeleteSavedGame
                                                ; removes; used by MENUS
        db 0x00, 0x00
DelFileNameSeg:                                 ; its segment; used by MENUS
        db 0x00, 0x00
DelFileName2:                                   ; far pointer (offset) to the second file DeleteSavedGame
                                                ; removes; used by MENUS
        db 0x00, 0x00
DelFileName2Seg:                                ; its segment; used by MENUS
        db 0x00, 0x00
str_Nhl_5:                                      ; string '.nhl'; used by MENUS
        db '.nhl', 0x00
str_Po_2:                                       ; string '.po'; used by MENUS
        db '.po', 0x00
str_Lp_2:                                       ; string '.lp'; used by MENUS
        db '.lp', 0x00
        db 0x64, 0x31, 0x00
str_GameSet_3:                                  ; string 'game.set'; used by MENUS
        db 'game.set', 0x00
        db 0x64, 0x32, 0x00
str_Dd2:                                        ; string 'dd2'; used by MENUS
        db 'dd2', 0x00
        db 'd3', 0x00, 'd4', 0x00
str_GameSav_7:                                  ; string 'game.sav'; used by MENUS
        db 'game.sav', 0x00
        db 0x2E, 0x2E, 0x00, 0x64, 0x35, 0x00, 0x00
SongBuf1:                                       ; far pointer (offset) to a song buffer loaded by
                                                ; SetSoundDevice; used by MENUS
        db 0x00, 0x00
SongBuf1Seg:                                    ; its segment; used by MENUS
        db 0x00, 0x00
SongBuf2:                                       ; far pointer (offset) to the second song buffer; used by
                                                ; MENUS
        db 0x00, 0x00
SongBuf2Seg:                                    ; its segment; used by MENUS
        db 0x00, 0x00
SongBuf3:                                       ; far pointer (offset) to the third song buffer; used by MENUS
        db 0x00
        db 0x00
SongBufs:                                       ; further song buffer pointer; used by MENUS
        times 2 db 0
SongSlots:                                      ; far pointers of the 16 loaded songs; sound_config unloads
                                                ; each
        times 64 db 0
SfxBankOff:                                     ; effects bank, offset; used by PlaySoundEffect
        dw 0x0000
SfxBankSeg:                                     ; effects bank, segment; used by PlaySoundEffect
        dw 0x0000
SfxBank2Off:                                    ; second effects bank, offset; used by PlaySoundEffect
        dw 0x0000
SfxBank2Seg:                                    ; second effects bank, segment; used by PlaySoundEffect
        db 0x00, 0x00
SoundDriverLoaded:                              ; -1 once SetSoundDevice has loaded a driver, else 0; used by
                                                ; MENUS
        db 0x00, 0x00
str_30Bgp:                                      ; string '30.BGP'; used by MENUS
        db '30.BGP', 0x00, 0x00
str_Scn:                                        ; string '.SCN'; used by MENUS
        db '.SCN', 0x00, 0x00
str_Pat:                                        ; string '.PAT'; used by MENUS
        db '.PAT', 0x00, 0x00
str_Tim:                                        ; string '.TIM'; used by MENUS
        db '.TIM', 0x00, 0x00
str_Pcff03d:                                    ; string 'PCFF%03d'; used by MENUS
        db 'PCFF%03d', 0x00, 0x00
        db 'PC', 0x00, 0x00
str_Pcbeep_2:                                   ; string 'PCBEEP'; used by MENUS
        db 'PCBEEP', 0x00, 0x00
        db 'SB', 0x00, 0x00
str_Sbdac:                                      ; string 'SBDAC'; used by MENUS
        db 'SBDAC', 0x00
        db 'YM', 0x00, 0x00
str_Adlib:                                      ; string 'ADLIB'; used by MENUS
        db 'ADLIB', 0x00
        db 'MT', 0x00, 0x00
str_Mt32:                                       ; string 'MT32'; used by MENUS
        db 'MT32', 0x00, 0x00
        db 'NL', 0x00, 0x00
str_Pcbeep:                                     ; string 'PCBEEP'; used by MENUS
        db 'PCBEEP', 0x00
str_Sound:                                      ; string 'sound'; used by MENUS
        db 'sound', 0x00
str_Dbox_8:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00, 0x00
str_Kms_3:                                      ; string '.KMS'; used by MENUS
        db '.KMS', 0x00
str_Slapshot_2:                                 ; string 'SLAPSHOT'; used by MENUS
        db 'SLAPSHOT', 0x00
str_Cfg_5:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Slapshot:                                   ; string 'SLAPSHOT'; used by MENUS
        db 'SLAPSHOT', 0x00
str_Kms_2:                                      ; string '.KMS'; used by MENUS
        db '.KMS', 0x00
str_Mt32hock_2:                                 ; string 'MT32HOCK'; used by MENUS
        db 'MT32HOCK', 0x00
str_Cfg_4:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Mt32hock:                                   ; string 'MT32HOCK'; used by MENUS
        db 'MT32HOCK', 0x00
str_Cfg_3:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Snd_2:                                      ; string 'SND'; used by MENUS
        db 'SND', 0x00
str_Emmcopybuf:                                 ; string 'emmcopybuf'; used by MENUS
        db 'emmcopybuf', 0x00
SoundDevChoice:                                 ; sound device byte kept by SetSoundDevice; used by MENUS
        db 0x00
CrowdChannel:                                   ; crowd noise channel; used by CrowdNoiseUpdate, CrowdNoiseOff
        db 0x00, 0x00
SoundDevTable:                                  ; sound device table (device bit, driver ...) searched by
                                                ; SetSoundDevice; used by LP, MENUS
        db 0x10, 0x00, 0x01, 0x00, 0x04, 0x00, 0x02, 0x00, 0x08, 0x00
str_SmytheDivisionalSemiFinals:                 ; string 'Smythe Divisional Semi-Finals'
        db 'Smythe Divisional Semi-Finals', 0x00
str_NorrisDivisionalSemiFinals:                 ; string 'Norris Divisional Semi-Finals'
        db 'Norris Divisional Semi-Finals', 0x00
str_PatrickDivisionalSemiFinals:                ; string 'Patrick Divisional Semi-Finals'
        db 'Patrick Divisional Semi-Finals', 0x00
str_AdamsDivisionalSemiFinals:                  ; string 'Adams Divisional Semi-Finals'
        db 'Adams Divisional Semi-Finals', 0x00
str_CampbellConferenceFinals:                   ; string 'Campbell Conference Finals'
        db 'Campbell Conference Finals', 0x00
str_WalesConferenceFinals:                      ; string 'Wales Conference Finals'
        db 'Wales Conference Finals', 0x00
str_StanleyCupFinals:                           ; string 'Stanley Cup Finals'
        db 'Stanley Cup Finals', 0x00
LockerTextPtrs:                                 ; text pointers of the locker room screen; used by MENUS
        dw str_SmytheDivisionalSemiFinals
        dw str_NorrisDivisionalSemiFinals
        dw str_PatrickDivisionalSemiFinals
        dw str_AdamsDivisionalSemiFinals
        dw str_CampbellConferenceFinals
        dw str_WalesConferenceFinals
        dw str_StanleyCupFinals
LockerItemTable:                                ; item table of the locker room screen; used by MENUS
        db 0xFF
        db 0xFF, 0x00, 0x00, 0x01, 0x00, 0x04, 0x00, 0x03, 0x00, 0x06, 0x00, 0x06, 0x00, 0xFF, 0xFF, 0x02
        db 0x00, 0x06, 0x00, 0x06, 0x00, 0xFF, 0xFF, 0x05
        db 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
str_Lockrm:                                     ; string 'lockrm'; used by MENUS
        db 'lockrm'
        db 0x00
str_P01_4:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_6:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_Exhgame2:                                   ; string 'exhgame2'; used by MENUS
        db 'exhgame2', 0x00
str_Botm:                                       ; string 'botm'; used by MENUS
        db 'botm', 0x00
str_Top:                                        ; string 'top '; used by MENUS
        db 'top ', 0x00
str_Head:                                       ; string 'head'; used by MENUS
        db 'head', 0x00
str_JerSh_2:                                    ; string 'JER%sH'; used by MENUS
        db 'JER%sH', 0x00
str_P01_3:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_5:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_JerSv_2:                                    ; string 'JER%sV'; used by MENUS
        db 'JER%sV', 0x00
str_P01_2:                                      ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_4:                                     ; string '0000'; used by MENUS
        db '0000', 0x00
str_JerSv:                                      ; string 'JER%sV'; used by MENUS
        db 'JER%sV', 0x00
str_JerSh:                                      ; string 'JER%sH'; used by MENUS
        db 'JER%sH', 0x00
str_P01:                                        ; string '!p01'; used by MENUS
        db '!p01', 0x00
str_0000_3:                                     ; string '0000'; used by MENUS
        db '0000', 0x00, 0x00
        db '%s %d - %d', 0x00, 0x00
POResultFmt:                                    ; pointer to the playoff result format string; used by MENUS
        db 0xCA, 0x11
LeagueSetChoice:                                ; league settings choice (-1 none), also read by the playoff
                                                ; loop; used by MENUS
        db 0xFF, 0xFF
str_Easndesk_20:                                ; string 'easndesk'; used by MENUS
        db 'easndesk'
        db 0x00
str_Desk_17:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_66:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Embscup_4:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Bkgd_7:                                     ; string 'bkgd'; used by MENUS
        db 'bkgd', 0x00
str_Playoffs:                                   ; string 'playoffs'; used by MENUS
        db 'playoffs', 0x00
str_Palette_8:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Embpal_21:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_65:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_PleaseEnterNewPlayOffName:                  ; string 'Please Enter New Play-Off Name'; used by MENUS
        db 0x50
SpeechFileNames:                                ; speech file names; used by OpenSpeechFile
        db 'lease Enter New Play-Off Name'
        db 0x00
str_Po:                                         ; string '.PO'; used by MENUS
        db '.PO', 0x00
str_SDb:                                        ; string '\%s.db'; used by MENUS
        db 0x5C, '%s.db', 0x00
str_Err3_3:                                     ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Pal_64:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Wait:                                       ; string 'wait'; used by MENUS
        db 'wait', 0x00
str_Err3_2:                                     ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Err3:                                       ; string 'err3'; used by MENUS
        db 'err3', 0x00
str_Temp_15:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_19:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_16:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_ScheduleDb_6:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb_5:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb_4:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db '..', 0x00, '..', 0x00, 0x00
        db 'e1', 0x00, 'e2', 0x00, 0x00
        db 'f1', 0x00, 'f2', 0x00
str_Xx1_2:                                      ; string 'xx1'; used by MENUS
        db 'xx1', 0x00
        db 0x2E, 0x2E, 0x00
msgYourTeamHasBeenEliminated:                   ; message list of 4 far string pointers: 'Your team has been
                                                ; eliminated / from the play-offs. Do you / wish to see the
                                                ; final results / of the play-offs?'; used by MENUS
        dw str_YourTeamHasBeenEliminated, 0x36B8
        dw str_FromThePlayOffsDo, 0x36B8
        dw str_WishToSeeTheFinal, 0x36B8
        dw str_OfThePlayOffs, 0x36B8
msgTeamEliminatedFromPlayoffs:                  ; message list of 4 far string pointers: 'The
                                                ; ....,....,....,....,. / have been eliminated from / the
                                                ; play-offs. / The .....................'; used by MENUS
        dw str_The, 0x36B8
        dw str_HaveBeenEliminatedFrom, 0x36B8
        dw str_ThePlayOffs, 0x36B8
        dw str_The_2, 0x36B8
        dw str_WillContinueToTheNext, 0x36B8
        dw str_Series, 0x36B8
msgGeneratingTheFinalResults:                   ; message list of 1 far string pointer: 'Generating the final
                                                ; results.'; used by MENUS
        dw str_GeneratingTheFinalResults, 0x36B8
str_Db_4:                                       ; string '.db'; used by MENUS
        db '.db'
        db 0x00
str_Db_3:                                       ; string '.db'; used by MENUS
        db '.db', 0x00
str_Xx1:                                        ; string 'xx1'; used by MENUS
        db 'xx1', 0x00
        db 0x2E, 0x2E, 0x00
str_Tied_3:                                     ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_Tied_2:                                     ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_ScheduleDb_3:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db 0x2E, 0x2E, 0x00
str_ScheduleDb_2:                               ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
str_ScheduleDb:                                 ; string 'schedule.db'; used by MENUS
        db 'schedule.db', 0x00
        db 0x2E, 0x2E, 0x00
str_GameSav_6:                                  ; string '\game.sav'; used by MENUS
        db '\game.sav', 0x00
str_Palette_7:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_GameSav_5:                                  ; string '\game.sav'; used by MENUS
        db 0x5C, 'game.sav', 0x00
str_Palette_6:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Space2:                                     ; string ' ' copied by PlayoffModeLoop; used by MENUS
        db 0x20, 0x00
str_Teeny05Fnt_3:                               ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup_3:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Palette_5:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Tied:                                       ; string 'tied'; used by MENUS
        db 'tied', 0x00
str_Embpal_20:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_63:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Palette_4:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_GameSav_4:                                  ; string '\game.sav'; used by MENUS
        db 0x5C, 'game.sav', 0x00
str_Teeny05Fnt_2:                               ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup_2:                                  ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Palette_3:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Embpal_19:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_62:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Palette_2:                                  ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Easndesk_18:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_15:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pnt2_12:                                    ; string 'pnt2'; used by MENUS
        db 'pnt2', 0x00
str_Pointer_12:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00
str_Pntr_17:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Pnt2_11:                                    ; string 'pnt2'; used by MENUS
        db 'pnt2', 0x00
str_Pointer_11:                                 ; string 'Pointer'; used by MENUS
        db 'Pointer', 0x00
str_Pntr_16:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Pntr_15:                                    ; string 'pntr'; used by MENUS
        db 'pntr', 0x00
str_Teeny05Fnt:                                 ; string 'teeny05.fnt'; used by MENUS
        db 'teeny05.fnt', 0x00
str_Embscup:                                    ; string 'embscup'; used by MENUS
        db 'embscup', 0x00
str_Embpal_18:                                  ; string 'embpal'; used by MENUS
        db 'embpal', 0x00
str_Pal_61:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Menubuff_9:                                 ; string 'menubuff'; used by MENUS
        db 'menubuff', 0x00
str_PlayoffStandings:                           ; string 'Playoff standings'; used by MENUS
        db 'Playoff standings'
        db 0x00
str_CampbellConference_3:                       ; string 'Campbell Conference'; used by MENUS
        db 'Campbell Conference'
        db 0x00
str_WalesConference_3:                          ; string 'Wales Conference'; used by MENUS
        db 'Wales Conference'
        db 0x00, 0x00
str_Exhibition:                                 ; string 'Exhibition'; used by MENUS
str_Exhibition_2:                               ; string 'Exhibition'; used by MENUS
        db 'Exhibition', 0x00, 0x00
str_Playoff:                                    ; string 'Playoff'; used by MENUS
str_Playoff_3:                                  ; string 'Playoff'; used by MENUS
        db 'Playoff', 0x00
str_League:                                     ; string 'League'; used by MENUS
        db 'League', 0x00, 0x00
str_ShowLeague:                                 ; string 'Show League'; used by MENUS
        db 'Show League', 0x00
str_Settings_2:                                 ; string ' Settings ...'; used by MENUS
        db ' Settings ...', 0x00
str_Setting5_2:                                 ; string 'setting5'; used by MENUS
        db 'setting5', 0x00
str_Dbox_7:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Embnhl_4:                                   ; string 'embnhl'; used by MENUS
        db 'embnhl', 0x00
str_Bkgd_6:                                     ; string 'bkgd'; used by MENUS
        db 'bkgd', 0x00
str_Setting5:                                   ; string 'setting5'; used by MENUS
        db 'setting5', 0x00
str_Setting3_2:                                 ; string 'setting3'; used by MENUS
        db 'setting3', 0x00
str_Dbox_6:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Setting3:                                   ; string 'setting3'; used by MENUS
        db 'setting3', 0x00
str_Dbox_2:                                     ; string 'dbox'; not used in the EXE (overlays may use it)
str_Dbox_5:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00, 0x00
str_Bkgd_5:                                     ; string 'BKGD'; used by MENUS
        db 'BKGD', 0x00
str_Setting7:                                   ; string 'setting7'; used by MENUS
        db 'setting7', 0x00
str_Setting4:                                   ; string 'setting4'; used by MENUS
        db 'setting4', 0x00
str_Dbox_4:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Setting6:                                   ; string 'setting6'; used by MENUS
        db 'setting6', 0x00
str_Dbox_3:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00
str_Eadesk1d:                                   ; string 'eadesk%1d'; used by MENUS
        db 'eadesk%1d', 0x00
str_Desk_14:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_60:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Desk_13:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_59:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Menubuff_8:                                 ; string 'menubuff'; used by MENUS
        db 'menubuff', 0x00
str_Crests4_7:                                  ; string 'crests4'; used by MENUS
        db 'crests4', 0x00
str_HomepalsBin_4:                              ; string 'HOMEPALS.BIN'; used by MENUS
        db 'HOMEPALS.BIN', 0x00
str_AwaypalsBin_3:                              ; string 'AWAYPALS.BIN'; used by MENUS
        db 'AWAYPALS.BIN', 0x00
str_Pal_58:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_57:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_56:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_55:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_54:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_53:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_52:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00
str_Pal_51:                                     ; string 'Pal'; used by MENUS
        db 'Pal', 0x00, 0x00
str_Easndesk_17:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_12:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_50:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Easndesk_16:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Pal_49:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Menubuff_7:                                 ; string 'menubuff'; used by MENUS
        db 'menubuff', 0x00
str_GameSet_2:                                  ; string 'game.set'; used by MENUS
        db 'game.set', 0x00
str_Set_5:                                      ; string '.set'; used by MENUS
        db '.set', 0x00
str_Game_6:                                     ; string 'game'; used by MENUS
        db 'game', 0x00
        db 'e2', 0x00, 'e3', 0x00
        db 0x65, 0x34, 0x00
str_Palette:                                    ; string 'palette'; used by MENUS
        db 'palette', 0x00
str_Temp_14:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_15:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_11:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_48:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Temp_13:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_14:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_10:                                    ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Temp_12:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_13:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_9:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Temp_11:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_12:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_8:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Temp_10:                                    ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_11:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_7:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Easndesk_10:                                ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Pal_47:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Temp_9:                                     ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_9:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_6:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Temp_8:                                     ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_8:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_5:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Temp_7:                                     ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_7:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_4:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_GameSav_3:                                  ; string '\game.sav'; used by MENUS
        db 0x5C, 'game.sav', 0x00
str_Temp_6:                                     ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_6:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_3:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Easndesk_5:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk_2:                                     ; string 'desk'; used by MENUS
        db 'desk', 0x00
str_Pal_46:                                     ; string '!pal'; used by MENUS
        db '!pal', 0x00
str_Temp_5:                                     ; string 'temp'; used by MENUS
        db 'temp', 0x00
str_Easndesk_4:                                 ; string 'easndesk'; used by MENUS
        db 'easndesk', 0x00
str_Desk:                                       ; string 'desk'; used by MENUS
        db 'desk', 0x00
        db 0x2E, 0x00, 0x20, 0x00
        db 0x2E, 0x00, 0x2E, 0x00
str_HomepalsBin_3:                              ; string 'HOMEPALS.BIN'; used by LP
        db 'HOMEPALS.BIN', 0x00, 0x00
str_EasndeskQpp_4:                              ; string 'easndesk.qpp'; used by LP
        db 'easndesk.qpp', 0x00
str_Pal_45:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_EasndeskQpp_3:                              ; string 'easndesk.qpp'; used by LP
        db 'easndesk.qpp', 0x00
str_Pal_44:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
SchedDivTable:                                  ; per-team division byte table used by the schedule and
                                                ; standings; used by LP
        db 0x02, 0x05, 0x07, 0x12, 0x15, 0x17, 0x03, 0x04
        db 0x08, 0x11, 0x13
        db 0x14, 0x00, 0x01, 0x06, 0x09, 0x0D, 0x10, 0x0A
        db 0x0B, 0x0C, 0x0E, 0x0F, 0x16
SchedConfTable:                                 ; per-team conference byte table used by RandomizeSchedule;
                                                ; used by LP
        db 0x02, 0x02, 0x00
        db 0x01, 0x01, 0x00, 0x02, 0x00, 0x01, 0x02, 0x03, 0x03, 0x03, 0x02, 0x03, 0x03, 0x02, 0x01, 0x00
        db 0x01, 0x01, 0x00, 0x03, 0x00
SchedTable3:                                    ; per-team byte table used by RandomizeSchedule; used by LP
        db 0x00, 0x01, 0x00, 0x00, 0x01, 0x01, 0x02, 0x02
        db 0x02, 0x03, 0x00
        db 0x01, 0x02, 0x04, 0x03, 0x04, 0x05, 0x03, 0x03
        db 0x04, 0x05, 0x04, 0x05, 0x05
POSeedOrder1:                                   ; seeding order bytes used by SeedPlayoffRound; used by LP
        db 0x00, 0x00, 0x01
        db 0x01, 0x00, 0x01, 0x00, 0x00
POSeedOrder2:                                   ; second seeding order used by SeedPlayoffRound; used by LP
        db 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00
SimDayTable:                                    ; byte table used by SimScheduleDay; used by LP
        db 0x00, 0x03, 0x01
        db 0x02
POSeriesLenArg:                                 ; series length argument per round (AdvancePlayoffs); used by
                                                ; LP
        db 0xF0, 0x03
PORoundTable:                                   ; per-round word table read by AdvancePlayoffs; used by LP
        db 0x28, 0x04, 0x44, 0x04, 0x52, 0x04
POSeriesLenArg2:                                ; series length argument of the final round; used by LP
        db 0x08, 0x00
POSeedArgs:                                     ; arguments passed to SeedPlayoffRound per round; used by LP
        db 0x04, 0x00, 0x02, 0x00, 0x01
MonthDays0:                                     ; entry before the month length table (NormalizeDate); used by
                                                ; LP
        db 0x00
MonthDays:                                      ; days per month, 12 bytes (31, 28, 31 ...); used by LP
        db 0x1F, 0x1C, 0x1F, 0x1E, 0x1F, 0x1E, 0x1F, 0x1F
        db 0x1E, 0x1F, 0x1E, 0x1F
MonthStartDay:                                  ; first weekday of each month, 12 bytes; used by LP
        db 0x05, 0x01, 0x01
        db 0x04, 0x06, 0x02, 0x04, 0x00, 0x03, 0x04, 0x00
        db 0x02
OtherGamesTable:                                ; team pairs of the other games shown between periods; used by
                                                ; INIT
        db 0x00, 0x00, 0x02, 0x01, 0x00, 0x02, 0x00
        db 0x03, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x00, 0x00, 0x03, 0x00
        db 0x01, 0x00, 0x00
str_Crests4_6:                                  ; string 'crests4'; used by LP
        db 'crests4', 0x00
str_CrestsBin:                                  ; string 'crests.bin'; used by LP
        db 'crests.bin', 0x00
str_Plst:                                       ; string 'PLST'; used by LP
        db 'PLST', 0x00
str_Ptls:                                       ; string 'PTLS'; used by LP
        db 'PTLS', 0x00
str_Pnt2_10:                                    ; string 'pnt2'; used by LP
        db 'pnt2', 0x00
str_Tpi:                                        ; string 'TPI'; used by LP
        db 'TPI', 0x00
str_Embnhl_3:                                   ; string 'embnhl'; used by LP
        db 'embnhl', 0x00
str_Bkgd_4:                                     ; string 'bkgd'; used by LP
        db 'bkgd', 0x00
str_Tspal:                                      ; string 'tspal'; used by LP
        db 'tspal', 0x00
str_Pal_43:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_Pointer_10:                                 ; string 'Pointer'; used by LP
        db 'Pointer', 0x00
str_Pntr_14:                                    ; string 'pntr'; used by LP
        db 'pntr', 0x00
str_Pnt2_9:                                     ; string 'pnt2'; used by LP
        db 'pnt2', 0x00
str_Menubuff_6:                                 ; string 'menubuff'; used by LP
        db 'menubuff', 0x00
str_WhoWillPlay:                                ; string 'Who will play '; used by LP
        db 'Who will play ', 0x00
str_Pntr_13:                                    ; string 'pntr'; used by LP
        db 'pntr', 0x00
        db 0x41, 0x00, 0x42, 0x00
        db 0x2A, 0x00, 0x2A, 0x00
        db 0x49, 0x44, 0x00
str_Set_4:                                      ; string '.SET'; used by LP
        db '.SET', 0x00
str_Set_3:                                      ; string '.SET'; used by LP
        db '.SET', 0x00
str_Game_5:                                     ; string 'GAME'; used by LP
        db 'GAME', 0x00
str_Sav_7:                                      ; string 'SAV'; used by LP
        db 'SAV', 0x00
str_Game_9:                                     ; string 'GAME'; used by LP
        db 'GAME', 0x00
str_02d_11:                                     ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Set_2:                                      ; string '.SET'; used by LP
        db '.SET', 0x00
str_Game_4:                                     ; string 'GAME'; used by LP
str_Game_8:                                     ; string 'GAME'; used by AI
        db 'GAME', 0x00
        db 'l1', 0x00, 'l2', 0x00
str_02d_10:                                     ; string '.%02d'; used by LP
        db '.%02d', 0x00, 0x00
str_Sav_3:                                      ; string '.sav'; used by LP
        db '.sav', 0x00
str_Game_3:                                     ; string 'game'; used by LP
        db 'game', 0x00
str_Cfg_2:                                      ; string '.CFG'; used by LP
        db '.CFG', 0x00
str_Snd:                                        ; string 'SND'; used by LP
        db 'SND', 0x00, 0x00
SoundCfgSpec:                                   ; sound configuration file pattern and device bytes; used by
                                                ; LP
        db 0x00, 0x17, '*?LLST', 0x00
str_Llsn:                                       ; string 'LLSN'; used by LP
        db 'LLSN', 0x00
str_02d_9:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
SimGoalOdds:                                    ; odds table used by SimulateGame; used by LP
        db 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x03, 0x00
        db 0x00, 0x00
        db 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00
        db 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00
        db 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
SimGoalOdds2:                                   ; second odds table used by SimulateGame; used by LP
        db 0x00, 0x00
        db 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00
        db 0x74, 0x00, 'at', 0x00
        db 'pk', 0x00, 'ps', 0x00
str_Pset:                                       ; string 'pset'; used by LP
        db 'pset', 0x00
str_Aps:                                        ; string 'aps'; used by LP
        db 'aps', 0x00
str_Apset:                                      ; string 'apset'; used by LP
        db 'apset', 0x00
        db 'gk', 0x00, 'gs', 0x00
str_Gset:                                       ; string 'gset'; used by LP
        db 'gset', 0x00
str_Ags:                                        ; string 'ags'; used by LP
        db 'ags', 0x00
str_Agset:                                      ; string 'agset'; used by LP
        db 'agset', 0x00, 0x00
str_Home:                                       ; string 'Home'; used by LP
        db 'Home', 0x00
str_Away:                                       ; string 'Away'; used by LP
        db 'Away', 0x00
str_199:                                        ; string ' 199'; used by LP
        db ' 199', 0x00
        db 0x32, 0x00, 0x33, 0x00
        db 0x25, 0x64, 0x00
ShapePaletteMap:                                ; colour map applied by ApplyShapePalette; used by LP
        db 0x3F, 0x19, 0x19, 0x19, 0x19, 0x3F, 0x32, 0x00
        db 0x00
        db '???', 0x00
        db 0x32, 0x00, '?4', 0x00, 0x18, 0x00, 0x00
        db 0x2A, 0x00, 0x00, 0x3B, 0x00, 0x00
        db ';;;'
str_Lineditp_4:                                 ; string 'lineditp'; used by LP
        db 'lineditp', 0x00
str_Pal_42:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_Crests4Bin_2:                               ; string 'crests4.bin'; used by LP
        db 'crests4.bin', 0x00
str_Ftimes24Fnt:                                ; string 'ftimes24.fnt'; used by LP
        db 'ftimes24.fnt', 0x00
str_Lineditp_3:                                 ; string 'lineditp'; used by LP
        db 'lineditp', 0x00
str_Pal_41:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_Crests4Bin:                                 ; string 'crests4.bin'; used by LP
        db 'crests4.bin', 0x00
str_Crests4_5:                                  ; string 'crests4'; used by LP
        db 'crests4', 0x00
str_Pointer_9:                                  ; string 'Pointer'; used by LP
        db 'Pointer', 0x00
str_Menubuff_5:                                 ; string 'menubuff'; used by LP
        db 'menubuff', 0x00
str_02d_8:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Gsummary_3:                                 ; string 'GSUMMARY'; used by LP
        db 'GSUMMARY', 0x00
str_Pnt2_8:                                     ; string 'pnt2'; used by LP
        db 'pnt2', 0x00
str_02d_7:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_02d_6:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Pntr_12:                                    ; string 'pntr'; used by LP
        db 'pntr', 0x00
str_02d_5:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_02d_4:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Temp_4:                                     ; string 'temp'; used by LP
        db 'temp', 0x00
str_EasndeskQpp_2:                              ; string 'easndesk.qpp'; used by LP
        db 'easndesk.qpp', 0x00
str_Pal_40:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_02d_3:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Temp_3:                                     ; string 'temp'; used by LP
        db 'temp', 0x00
str_Sav_2:                                      ; string '.SAV'; used by LP
        db '.SAV', 0x00
str_Game_2:                                     ; string 'GAME'; used by LP
        db 'GAME', 0x00, 0x00
str_Pnt2_7:                                     ; string 'pnt2'; used by LP
        db 'pnt2', 0x00
str_Pntr_11:                                    ; string 'pntr'; used by LP
        db 'pntr', 0x00
JerseyDigitGlyphs:                              ; jersey digit glyph bits (PaintJerseyDigit); used by LP
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
        db 0x00, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01
        db 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
        db 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00
        db 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
        db 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 'tstat'
        db 0x00
str_Keys_5:                                     ; string 'keys'; used by LP
        db 'keys', 0x00
str_Pstat_5:                                    ; string 'pstat'; used by LP
        db 'pstat', 0x00
str_Gstat_5:                                    ; string 'gstat'; used by LP
        db 'gstat', 0x00
str_Embpal_17:                                  ; string 'embpal'; used by LP
        db 'embpal', 0x00
str_Pal_39:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_Lineditp_2:                                 ; string 'lineditp'; used by LP
        db 'lineditp', 0x00
str_Pal_38:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_TheJerseyNumber2dIsAlready:                 ; string 'The jersey number %2d is already used on %Fs!'
                                                ; used by LP
        db 'The jersey number %2d is already used on %Fs!'
        db 0x00
str_EnterJerseyNumberForS:                      ; string 'Enter jersey number for %s'; used by LP
        db 'Enter jersey number for %s'
        db 0x00
str_Pal_37:                                     ; string 'Pal'; used by LP
        db 'Pal', 0x00
str_Pal_36:                                     ; string 'Pal'; used by LP
        db 'Pal', 0x00
str_C2dS_2:                                     ; string '%c %2d %s'; used by LP
        db '%c %2d %s', 0x00
str_Embnhl_2:                                   ; string 'embnhl'; used by LP
        db 'embnhl', 0x00
str_Bkgd_3:                                     ; string 'bkgd'; used by LP
        db 'bkgd', 0x00
str_Plaque:                                     ; string 'plaque'; used by LP
        db 'plaque', 0x00
str_S_3:                                        ; string '%s   '; used by LP
        db '%s   ', 0x00
str_C2dS:                                       ; string '%c %2d %s'; used by LP
        db '%c %2d %s', 0x00
str_Pntr_10:                                    ; string 'pntr'; used by LP
        db 'pntr', 0x00
str_Pointer_8:                                  ; string 'Pointer'; used by LP
        db 'Pointer', 0x00
str_Menubuff_4:                                 ; string 'menubuff'; used by LP
        db 'menubuff', 0x00
str_LineditFnt:                                 ; string 'linedit.fnt'; used by LP
        db 'linedit.fnt', 0x00
str_Lineditp:                                   ; string 'lineditp'; used by LP
        db 'lineditp', 0x00
str_Shrt:                                       ; string 'shrt'; used by LP
        db 'shrt', 0x00
str_Pal_35:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_EasndeskQpp:                                ; string 'easndesk.qpp'; used by LP
        db 'easndesk.qpp', 0x00
str_Pal_34:                                     ; string '!pal'; used by LP
        db '!pal', 0x00
str_02d_2:                                      ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_02d:                                        ; string '.%02d'; used by LP
        db '.%02d', 0x00
str_Sav_6:                                      ; string 'SAV'; used by LP
        db 'SAV', 0x00
str_Game_7:                                     ; string 'GAME'; used by LP
        db 'GAME', 0x00, 0x00
str_Saved:                                      ; string 'saved'; used by LP
        db 'saved', 0x00
str_Tropback:                                   ; string 'TROPBACK'
        db 'TROPBACK', 0x00
str_Trophies:                                   ; string 'TROPHIES'
        db 'TROPHIES', 0x00
str_Hart:                                       ; string 'hart'
        db 'hart', 0x00
str_Adms:                                       ; string 'adms'
        db 'adms', 0x00
str_Norr:                                       ; string 'norr'
        db 'norr', 0x00
str_Selk:                                       ; string 'selk'
        db 'selk', 0x00
str_Vezi:                                       ; string 'vezi'
        db 'vezi', 0x00
str_Jenn:                                       ; string 'jenn'
        db 'jenn', 0x00
str_Cald:                                       ; string 'cald'
        db 'cald', 0x00
str_Pres:                                       ; string 'pres'
        db 'pres', 0x00
str_Conn:                                       ; string 'conn'
        db 'conn', 0x00
str_Easn:                                       ; string 'easn'
        db 'easn', 0x00
str_Tab3:                                       ; string 'tab3'
        db 'tab3', 0x00
str_Tab3_2:                                     ; string 'tab3'
        db 'tab3', 0x00
str_Tab2:                                       ; string 'tab2'
        db 'tab2', 0x00
str_Tab2_2:                                     ; string 'tab2'
        db 'tab2', 0x00
str_Tab2_3:                                     ; string 'tab2'
        db 'tab2', 0x00
str_Tab2_4:                                     ; string 'tab2'
        db 'tab2', 0x00
str_Tab3_3:                                     ; string 'tab3'
        db 'tab3', 0x00
str_Tab1:                                       ; string 'tab1'
        db 'tab1', 0x00
str_Tab2_5:                                     ; string 'tab2'
        db 'tab2', 0x00
str_Tab3_4:                                     ; string 'tab3'
        db 'tab3', 0x00
str_Spk1:                                       ; string 'spk1'
        db 'spk1', 0x00
str_Spk2:                                       ; string 'spk2'
        db 'spk2', 0x00
str_Spk3:                                       ; string 'spk3'
        db 'spk3', 0x00
str_Hart_2:                                     ; string 'Hart'
        db 'Hart', 0x00
str_ArtRoss:                                    ; string 'Art Ross'
        db 'Art Ross', 0x00
str_Norris:                                     ; string 'Norris'
        db 'Norris', 0x00
str_Selke:                                      ; string 'Selke'
        db 'Selke', 0x00
str_Vezina:                                     ; string 'Vezina'
        db 'Vezina', 0x00
str_Jennings:                                   ; string 'Jennings'
        db 'Jennings', 0x00
str_Calder:                                     ; string 'Calder'
        db 'Calder', 0x00
str_Presidents:                                 ; string 'Presidents'
        db 'Presidents', 0x00
str_ConnSmythe:                                 ; string 'Conn Smythe'
        db 'Conn Smythe', 0x00
str_EaSportsCup:                                ; string 'EA Sports Cup'
        db 'EA Sports Cup', 0x00, 'Season', 0x00, 'Playoff', 0x00, 0x00
        dw str_Tropback
        dw str_Trophies
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
        db 0x0E, 0xCA
AwardWinner2:                                   ; winner pointer of award 2; used by LP
        db 0x3E, 0xCA
AwardWinner3:                                   ; winner pointer of award 3; used by LP
        db 0x6E, 0xCA
AwardWinner4:                                   ; winner pointer of award 4; used by LP
        db 0x9E, 0xCA
AwardWinner5:                                   ; winner pointer of award 5; used by LP
        db 0xCE, 0xCA
AwardWinner6:                                   ; winner pointer of award 6; used by LP
        db 0x04, 0xCB
AwardWinner7:                                   ; winner pointer of award 7; used by LP
        db 0x3A, 0xCB
        db 0x00, 0x00
AwardWinner8:                                   ; winner pointer of award 8; used by LP
        db 0x6A, 0xCB
AwardWinner9:                                   ; winner pointer of award 9; used by LP
        db 0x9A, 0xCB
AwardTitlePtrs:                                 ; award title text pointers; used by LP
        db 0x18, 0x1C, 0x1F, 0x1C, 0x25, 0x64, 0x00, 0x00
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
str_Wittle06Fnt_2:                              ; string 'wittle06.fnt'; not used in the EXE (overlays may use
                                                ; it)
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
        db 0xC4, 0x25
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
        db 0xDE, 0x26
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
replayptr:                                      ; replay record pointer (offset); used by AI, GAME, INIT
        db 0xD8, 0x0D
replayseg:                                      ; replay record pointer (segment); used by AI, GAME, INIT
        db 0x0B, 0x3A
puckx:                                          ; puck x position; used by AI, INIT, MENUS
        db 0x10, 0xBC
puckvx:                                         ; puck x velocity; used by AI, MENUS
        db 0x1A, 0xBC
pucky:                                          ; puck y position; used by AI, INIT, MENUS
        db 0x14, 0xBC
puckvy:                                         ; puck y velocity; used by AI, MENUS
        db 0x1C, 0xBC
puckz:                                          ; puck height; used by AI
        db 0x18, 0xBC
puckvz:                                         ; puck vertical velocity; used by AI
        db 0x1E, 0xBC
puckc:                                          ; player carrying the puck (-1 none); used by AI, MENUS
        db 0x50, 0xBC
camx:                                           ; camera x; used by AI, GAME, INIT
        db 0x00, 0x00
camy:                                           ; camera y; used by AI, GAME, INIT
        db 0x00, 0x00
wcradiusx:                                      ; wall corner radius, x; used by AI
        db 0x00, 0x00
wcradiusy:                                      ; wall corner radius, y; used by AI
        db 0x00, 0x00
shotplayer:                                     ; player who took the last shot; used by AI, INIT
        times 2 db 0
lastplayer:                                     ; last player to touch the puck; used by AI, INIT
        times 2 db 0
passdir:                                        ; pass direction (8 = shot); used by AI, INIT
        times 2 db 0
passspeed:                                      ; pass or shot speed; used by AI, INIT
        times 2 db 0
passplayer:                                     ; player who made the last pass (-1 none); used by AI, INIT
        times 2 db 0
threat:                                         ; number of opponents near the puck; used by AI, INIT
        times 2 db 0
xc1:                                            ; camera lock x; used by AI, INIT
        times 2 db 0
yc1:                                            ; camera lock y; used by AI, INIT
        times 2 db 0
yleader:                                        ; y of the leading skater; used by AI, INIT
        times 2 db 0
fox:                                            ; faceoff spot x; used by AI, INIT
        times 2 db 0
foy:                                            ; faceoff spot y; used by AI, INIT
        times 2 db 0
fodir1:                                         ; faceoff pull direction of the first centre; used by AI, INIT
        times 2 db 0
fodir2:                                         ; faceoff pull direction of the second centre; used by AI,
                                                ; INIT
        times 2 db 0
collflag:                                       ; collision flag; used by AI, INIT
        db 0x00
gmode:                                          ; game mode bits (clock stopped, attack direction, delayed
                                                ; penalty, stoppage ...); used by AI, GAME, INIT, MENUS
        db 0x00
sflags:                                         ; game state flags; used by AI, GAME, INIT
        times 2 db 0
gmode2:                                         ; second game mode bits (faceoff, shot, power play ...); used
                                                ; by AI, INIT
        times 2 db 0
sflags3:                                        ; third game state flags; used by AI, INIT
        times 2 db 0
c1playernum:                                    ; player controlled by controller 1; used by AI, INIT, MENUS
        db 0xFF
c1playernum_b1:                                 ; high byte of c1playernum, set by setupice; used by AI
        db 0xFF
c2playernum:                                    ; player controlled by controller 2; used by AI, INIT, MENUS
        db 0xFF
c2playernum_b1:                                 ; high byte of c2playernum, set by setupice; used by AI
        db 0xFF
cont1team:                                      ; team of controller 1 in the game; used by AI, INIT, MENUS
        db 0x00, 0x00
cont2team:                                      ; team of controller 2 in the game; used by AI, INIT, MENUS
        db 0x00, 0x00
HomeTeamNum:                                    ; home team number; used by AI, GAME, INIT, LP, MENUS
        db 0x09, 0x00
VisTeamNum:                                     ; visiting team number; used by AI, GAME, INIT, LP, MENUS
        db 0x07, 0x00
PenCntDwn:                                      ; referee penalty call countdown; used by AI, INIT
        db 0xFF, 0xFF
Penaltytimer:                                   ; penalty timer; used by AI, INIT
        db 0x00, 0x00
refsignal:                                      ; referee signal; used by AI, INIT
        db 0x00, 0x00
RefStep:                                        ; referee animation step; used by AI, INIT
        db 0xFF
refsignal_b1:                                   ; high byte of refsignal, set to -1 by chkprogress; used by AI
        db 0xFF
RefPen:                                         ; penalty the referee is calling; used by AI, INIT
        db 0x00, 0x00
penaltysc:                                      ; sort object of the penalised player; used by AI, INIT
        db 0xFF, 0xFF
gsp:                                            ; game period (0-based); used by AI, INIT, MENUS
        db 0x00, 0x00
gameclock:                                      ; game clock in seconds; used by AI, GAME, INIT, MENUS
        db 0x00, 0x00
clockticks:                                     ; ticks within the current second; used by AI, GAME, INIT
        db 0x00, 0x00
dirtab0:                                        ; entry before dirtab; used by AI
        db 0x00, 0x00
dirtab_x:                                       ; x components of the direction table; used by AI
        db 0xAF, 0x00, 0x7C, 0x00
        db 0x7C, 0x00, 0xAF, 0x00, 0x00, 0x00
        db 0x7C, 0x00, 0x84, 0xFF, 0x00, 0x00
        db 0x51, 0xFF, 0x84, 0xFF, 0x84, 0xFF, 0x51, 0xFF, 0x00, 0x00, 0x84, 0xFF, 0x7C, 0x00
seed:                                           ; the seed randomd0 steps; the high word is seed+2; used by
                                                ; randomd0
        dw 0x4321
rngseed:                                        ; random number seed; used by AI, INIT
        db 0xCD, 0xAB
pendelaytab:                                    ; delay per penalty kind; used by AI
        db 0x00, 0x0A, 0x0A, 0x03, 0x01, 0x00, 0x01, 0x01
        db 0x01, 0x0A, 0x0A, 0x04, 0x04, 0x04
        db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x01
        db 0x00, 0x01, 0x01, 0x00
penmintab:                                      ; penalty minutes per penalty kind; used by AI
        db 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0xFF
        db 0x05, 0x00, 0x00, 0x00, 0x00, 0x00
penkindtab:                                     ; penalty kind byte per penalty (checkfornewpen); used by AI
        db 0x00, 0x02, 0x02, 0x02, 0x02, 0x00, 0x02, 0x04
        db 0x02, 0x06
        db 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00, 0x02, 0x02, 0x00
asstab:                                         ; assignment routine table, far pointers (updateplayers); used
                                                ; by AI
        dw rtssThunk, 0x1B35
        dw assdefoThunk, 0x1B35
        dw assdefdThunk, 0x1B35
        dw asswingdThunk, 0x1B35
        dw asswingoThunk, 0x1B35
        dw asscenterdThunk, 0x1B35
        dw asscenteroThunk, 0x1B35
        dw assscoreThunk, 0x1B35
        dw assstanleyThunk, 0x1B35
        dw assebenThunk, 0x1B35
        dw assepenThunk, 0x1B35
        dw assbenchThunk, 0x1B35
        dw asspenaltyThunk, 0x1B35
        dw assdopenThunk, 0x1B35
        dw assgoalieThunk, 0x1B35
        dw assgoalietopuckThunk, 0x1B35
        dw asspuckcThunk, 0x1B35
        dw assnearestThunk, 0x1B35
        dw assshootThunk, 0x1B35
        dw asspassrecThunk, 0x1B35
        dw assstarskateThunk, 0x1B35
        dw assthreestarsThunk, 0x1B35
        dw assfaceoffThunk, 0x1B35
        dw assfaceoffplThunk, 0x1B35
        dw pucknormThunk, 0x1B35
        dw puckshadowThunk, 0x1B35
        dw pucknothingThunk, 0x1B35
        dw puckfaceoffThunk, 0x1B35
        dw puckfaceoff2Thunk, 0x1B35
        dw assleaveiceThunk, 0x1B35
        dw assrefatdotThunk, 0x1B35
        dw assreffollowThunk, 0x1B35
        dw assrefsignalThunk, 0x1B35
        dw assrefgoalpaThunk, 0x1B35
        dw assrefdropThunk, 0x1B35
        dw assrefgoallineThunk, 0x1B35
        dw assrefwhistleThunk, 0x1B35
        dw assintrostandThunk, 0x1B35
        dw assintrolineThunk, 0x1B35
        dw asstakepositionThunk, 0x1B35
        dw assleaveboxThunk, 0x1B35
        dw assbenchwaitThunk, 0x1B35
        dw assboxenterThunk, 0x1B35
        dw assbenchsideThunk, 0x1B35
        db 0x00, 0x00, 0x00, 0x80, 0x12, 0x00, 0x24, 0x00, 0x36, 0x00, 0x48, 0x00, 0x5A, 0x00, 0x6C, 0x00
        db 0x7E, 0x00, 0x96, 0x01, 0xB4, 0x00, 0x1A, 0x02, 0x0A, 0x00, 0x1B, 0x02, 0x0A, 0x00, 0x1A, 0x02
        db 0x0A, 0x00, 0x1B, 0x02, 0x0A, 0x00, 0x96, 0x01, 0xF0, 0x00, 0x1A, 0x02, 0x0A, 0x00, 0x1B, 0x02
        db 0x0A, 0x00, 0x1A, 0x02, 0xF6, 0xFF, 0x99, 0x01, 0x82, 0x00, 0x1C, 0x02, 0x0A, 0x00, 0x1D, 0x02
        db 0x0A, 0x00, 0x1C, 0x02, 0x0A, 0x00, 0x1D, 0x02, 0x0A, 0x00, 0x99, 0x01, 0x2C, 0x01, 0x1C, 0x02
        db 0x0A, 0x00, 0x1D, 0x02, 0x0A, 0x00, 0x1C, 0x02, 0xF6, 0xFF, 0x9C, 0x01, 0xD2, 0x00, 0x1E, 0x02
        db 0x0A, 0x00, 0x1F, 0x02, 0x0A, 0x00, 0x1E, 0x02, 0x0A, 0x00, 0x1F, 0x02, 0x0A, 0x00, 0x9C, 0x01
        db 0x78, 0x00, 0x1E, 0x02, 0x0A, 0x00, 0x1F, 0x02, 0x0A, 0x00, 0x1E, 0x02, 0xF6, 0xFF, 0x9F, 0x01
        db 0x64, 0x00, 0x20, 0x02, 0x0A, 0x00, 0x21, 0x02, 0x0A, 0x00, 0x20, 0x02, 0x0A, 0x00, 0x21, 0x02
        db 0x0A, 0x00, 0x9F, 0x01, 0xC8, 0x00, 0x20, 0x02, 0x0A, 0x00, 0x21, 0x02, 0x0A, 0x00, 0x20, 0x02
        db 0xF6, 0xFF, 0xA2, 0x01, 0xF0, 0x00, 0x22, 0x02, 0x0A, 0x00, 0x23, 0x02, 0x0A, 0x00, 0x22, 0x02
        db 0x0A, 0x00, 0x23, 0x02, 0x0A, 0x00, 0xA2, 0x01, 0x3C, 0x00, 0x22, 0x02, 0x0A, 0x00, 0x23, 0x02
        db 0x0A, 0x00, 0x22, 0x02, 0xF6, 0xFF, 0xA5, 0x01, 0xB4, 0x00, 0x24, 0x02, 0x0A, 0x00, 0x25, 0x02
        db 0x0A, 0x00, 0x24, 0x02, 0x0A, 0x00, 0x25, 0x02, 0x0A, 0x00, 0xA5, 0x01, 0xF0, 0x00, 0x24, 0x02
        db 0x0A, 0x00, 0x25, 0x02, 0x0A, 0x00, 0x24, 0x02, 0xF6, 0xFF, 0xA8, 0x01, 0x78, 0x00, 0x26, 0x02
        db 0x0A, 0x00, 0x27, 0x02, 0x0A, 0x00, 0x26, 0x02, 0x0A, 0x00, 0x27, 0x02, 0x0A, 0x00, 0xA8, 0x01
        db 0x78, 0x00, 0x26, 0x02, 0x0A, 0x00, 0x27, 0x02, 0x0A, 0x00, 0x26, 0x02, 0xF6, 0xFF, 0xAB, 0x01
        db 0xB4, 0x00, 0x28, 0x02, 0x0A, 0x00, 0x29, 0x02, 0x0A, 0x00, 0x28, 0x02, 0x0A, 0x00, 0x29, 0x02
        db 0x0A, 0x00, 0xAB, 0x01, 0xB4, 0x00, 0x28, 0x02, 0x0A, 0x00, 0x29, 0x02, 0x0A, 0x00, 0x28, 0x02
        db 0xF6, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x96, 0x01, 0xE2, 0xFF, 0x99, 0x01, 0xE2, 0xFF, 0x9C, 0x01, 0xE2, 0xFF, 0x9F, 0x01
        db 0xE2, 0xFF, 0xA2, 0x01, 0xE2, 0xFF, 0xA5, 0x01, 0xE2, 0xFF, 0xA8, 0x01, 0xE2, 0xFF, 0xAB, 0x01
        db 0xE2, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x97, 0x01, 0xE0, 0xFF, 0x9A, 0x01, 0xE0, 0xFF, 0x9D, 0x01, 0xE0, 0xFF, 0xA0, 0x01
        db 0xE0, 0xFF, 0xA3, 0x01, 0xE0, 0xFF, 0xA6, 0x01, 0xE0, 0xFF, 0xA9, 0x01, 0xE0, 0xFF, 0xAC, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x98, 0x01, 0xE0, 0xFF, 0x9B, 0x01, 0xE0, 0xFF, 0x9E, 0x01, 0xE0, 0xFF, 0xA1, 0x01
        db 0xE0, 0xFF, 0xA4, 0x01, 0xE0, 0xFF, 0xA7, 0x01, 0xE0, 0xFF, 0xAA, 0x01, 0xE0, 0xFF, 0xAD, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x14, 0x00
        db 0x16, 0x00, 0x16, 0x02, 0x04, 0x00, 0x17, 0x02, 0x08, 0x00, 0x16, 0x02, 0xFC, 0xFF, 0x9B, 0x01
        db 0xE0, 0xFF, 0x9E, 0x01, 0xE0, 0xFF, 0xA1, 0x01, 0xE0, 0xFF, 0x18, 0x02, 0x04, 0x00, 0x19, 0x02
        db 0x08, 0x00, 0x18, 0x02, 0xFC, 0xFF, 0xA7, 0x01, 0xE0, 0xFF, 0xAA, 0x01, 0xE0, 0xFF, 0xAD, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xD6, 0x01, 0xE0, 0xFF, 0xD8, 0x01, 0xE0, 0xFF, 0xDA, 0x01, 0xE0, 0xFF, 0xDC, 0x01
        db 0xE0, 0xFF, 0xDE, 0x01, 0xE0, 0xFF, 0xE0, 0x01, 0xE0, 0xFF, 0xE2, 0x01, 0xE0, 0xFF, 0xE4, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xD7, 0x01, 0xE0, 0xFF, 0xD9, 0x01, 0xE0, 0xFF, 0xDB, 0x01, 0xE0, 0xFF, 0xDD, 0x01
        db 0xE0, 0xFF, 0xDF, 0x01, 0xE0, 0xFF, 0xE1, 0x01, 0xE0, 0xFF, 0xE3, 0x01, 0xE0, 0xFF, 0xE5, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00, 0x14, 0x00, 0x18, 0x00
        db 0x1C, 0x00, 0xBE, 0x01, 0x08, 0x00, 0xBF, 0x01, 0xE0, 0xFF, 0xC0, 0x01, 0x08, 0x00, 0xC1, 0x01
        db 0xE0, 0xFF, 0xC0, 0x01, 0x08, 0x00, 0xC1, 0x01, 0xE0, 0xFF, 0xC2, 0x01, 0x08, 0x00, 0xC3, 0x01
        db 0xE0, 0xFF, 0xC4, 0x01, 0x08, 0x00, 0xC5, 0x01, 0xE0, 0xFF, 0xC6, 0x01, 0x08, 0x00, 0xC7, 0x01
        db 0xE0, 0xFF, 0xC6, 0x01, 0x08, 0x00, 0xC7, 0x01, 0xE0, 0xFF, 0xC8, 0x01, 0x08, 0x00, 0xC9, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00, 0x14, 0x00, 0x18, 0x00
        db 0x1C, 0x00, 0xCA, 0x01, 0x08, 0x00, 0xCB, 0x01, 0xE0, 0xFF, 0xCC, 0x01, 0x08, 0x00, 0xCD, 0x01
        db 0xE0, 0xFF, 0xCC, 0x01, 0x08, 0x00, 0xCD, 0x01, 0xE0, 0xFF, 0xCE, 0x01, 0x08, 0x00, 0xCF, 0x01
        db 0xE0, 0xFF, 0xD0, 0x01, 0x08, 0x00, 0xD1, 0x01, 0xE0, 0xFF, 0xD2, 0x01, 0x08, 0x00, 0xD3, 0x01
        db 0xE0, 0xFF, 0xD2, 0x01, 0x08, 0x00, 0xD3, 0x01, 0xE0, 0xFF, 0xD4, 0x01, 0x08, 0x00, 0xD5, 0x01
        db 0xE0, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0x06, 0x02, 0x08, 0x00, 0x07, 0x02, 0x30, 0x00, 0x06, 0x02, 0xF8, 0xFF, 0x08, 0x02
        db 0x08, 0x00, 0x09, 0x02, 0x30, 0x00, 0x08, 0x02, 0xF8, 0xFF, 0x0A, 0x02, 0x08, 0x00, 0x0B, 0x02
        db 0x30, 0x00, 0x0A, 0x02, 0xF8, 0xFF, 0x0C, 0x02, 0x08, 0x00, 0x0D, 0x02, 0x30, 0x00, 0x0C, 0x02
        db 0xF8, 0xFF, 0x0E, 0x02, 0x08, 0x00, 0x0F, 0x02, 0x30, 0x00, 0x0E, 0x02, 0xF8, 0xFF, 0x10, 0x02
        db 0x08, 0x00, 0x11, 0x02, 0x30, 0x00, 0x10, 0x02, 0xF8, 0xFF, 0x12, 0x02, 0x08, 0x00, 0x13, 0x02
        db 0x30, 0x00, 0x12, 0x02, 0xF8, 0xFF, 0x14, 0x02, 0x08, 0x00, 0x15, 0x02, 0x30, 0x00, 0x14, 0x02
        db 0xF8, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0xAE, 0x01, 0x05, 0x00, 0xAF, 0x01, 0x08, 0x00, 0xAE, 0x01, 0xF0, 0xFF, 0xB0, 0x01
        db 0x05, 0x00, 0xB1, 0x01, 0x08, 0x00, 0xB0, 0x01, 0xF0, 0xFF, 0xB2, 0x01, 0x05, 0x00, 0xB3, 0x01
        db 0x08, 0x00, 0xB2, 0x01, 0xF0, 0xFF, 0xB4, 0x01, 0x05, 0x00, 0xB5, 0x01, 0x08, 0x00, 0xB4, 0x01
        db 0xF0, 0xFF, 0xB6, 0x01, 0x05, 0x00, 0xB7, 0x01, 0x08, 0x00, 0xB6, 0x01, 0xF0, 0xFF, 0xB8, 0x01
        db 0x05, 0x00, 0xB9, 0x01, 0x08, 0x00, 0xB8, 0x01, 0xF0, 0xFF, 0xBA, 0x01, 0x05, 0x00, 0xBB, 0x01
        db 0x08, 0x00, 0xBA, 0x01, 0xF0, 0xFF, 0xBC, 0x01, 0x05, 0x00, 0xBD, 0x01, 0x08, 0x00, 0xBC, 0x01
        db 0xF0, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00, 0x28, 0x00, 0x30, 0x00
        db 0x38, 0x00, 0xE6, 0x01, 0x0A, 0x00, 0xE7, 0x01, 0x0A, 0x00, 0xE8, 0x01, 0x0A, 0x00, 0xE9, 0x01
        db 0xF1, 0xFF, 0xEA, 0x01, 0x0A, 0x00, 0xEB, 0x01, 0x0A, 0x00, 0xEC, 0x01, 0x0A, 0x00, 0xED, 0x01
        db 0xF1, 0xFF, 0xEE, 0x01, 0x0A, 0x00, 0xEF, 0x01, 0x0A, 0x00, 0xF0, 0x01, 0x0A, 0x00, 0xF1, 0x01
        db 0xF1, 0xFF, 0xF2, 0x01, 0x0A, 0x00, 0xF3, 0x01, 0x0A, 0x00, 0xF4, 0x01, 0x0A, 0x00, 0xF5, 0x01
        db 0xF1, 0xFF, 0xF6, 0x01, 0x0A, 0x00, 0xF7, 0x01, 0x0A, 0x00, 0xF8, 0x01, 0x0A, 0x00, 0xF9, 0x01
        db 0xF1, 0xFF, 0xFA, 0x01, 0x0A, 0x00, 0xFB, 0x01, 0x0A, 0x00, 0xFC, 0x01, 0x0A, 0x00, 0xFD, 0x01
        db 0xF1, 0xFF, 0xFE, 0x01, 0x0A, 0x00, 0xFF, 0x01, 0x0A, 0x00, 0x00, 0x02, 0x0A, 0x00, 0x01, 0x02
        db 0xF1, 0xFF, 0x02, 0x02, 0x0A, 0x00, 0x03, 0x02, 0x0A, 0x00, 0x04, 0x02, 0x0A, 0x00, 0x05, 0x02
        db 0xF1, 0xFF, 0x00, 0x80, 0x10, 0x00, 0x20, 0x00, 0x30, 0x00, 0x40, 0x00, 0x42, 0x00, 0x44, 0x00
        db 0x46, 0x00, 0x8B, 0x01, 0x04, 0x00, 0x8C, 0x01, 0x04, 0x00, 0x8D, 0x01, 0x04, 0x00, 0x8E, 0x01
        db 0x04, 0x00, 0x8F, 0x01, 0x04, 0x00, 0x8C, 0x01, 0x04, 0x00, 0x90, 0x01, 0x04, 0x00, 0x8A, 0x01
        db 0xFC, 0xFF, 0x92, 0x01, 0x02, 0x00, 0x8A, 0x01, 0x02, 0x00, 0x91, 0x01, 0x02, 0x00, 0x8E, 0x01
        db 0x02, 0x00, 0x93, 0x01, 0x02, 0x00, 0x8E, 0x01, 0x02, 0x00, 0x91, 0x01, 0x02, 0x00, 0x8A, 0x01
        db 0xFE, 0xFF, 0x8D, 0x01, 0x02, 0x00, 0x8C, 0x01, 0x02, 0x00, 0x8B, 0x01, 0x02, 0x00, 0x8A, 0x01
        db 0x02, 0x00, 0x90, 0x01, 0x02, 0x00, 0x8C, 0x01, 0x02, 0x00, 0x8F, 0x01, 0x02, 0x00, 0x8E, 0x01
        db 0xFE, 0xFF, 0x91, 0x01, 0x04, 0x00, 0x8A, 0x01, 0x04, 0x00, 0x92, 0x01, 0x04, 0x00, 0x8A, 0x01
        db 0x04, 0x00, 0x91, 0x01, 0x04, 0x00, 0x8E, 0x01, 0x04, 0x00, 0x93, 0x01, 0x04, 0x00, 0x8E, 0x01
        db 0xFC, 0xFF, 0x8A, 0x01, 0x00, 0xF0, 0x8A, 0x01, 0x00, 0xF0, 0x8E, 0x01, 0x00, 0xF0, 0x8E, 0x01
        db 0x00, 0xF0, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x00, 0x00, 0xF8, 0xFF, 0x05, 0x00, 0xF8, 0xFF, 0x0A, 0x00, 0xF8, 0xFF, 0x0F, 0x00
        db 0xF8, 0xFF, 0x14, 0x00, 0xF8, 0xFF, 0x19, 0x00, 0xF8, 0xFF, 0x1E, 0x00, 0xF8, 0xFF, 0x23, 0x00
        db 0xF8, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00, 0x28, 0x00, 0x30, 0x00
        db 0x38, 0x00, 0x01, 0x00, 0x0A, 0x00, 0x02, 0x00, 0x0A, 0x00, 0x03, 0x00, 0x0A, 0x00, 0x04, 0x00
        db 0xF6, 0xFF, 0x06, 0x00, 0x0A, 0x00, 0x07, 0x00, 0x0A, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x09, 0x00
        db 0xF6, 0xFF, 0x0B, 0x00, 0x0A, 0x00, 0x0C, 0x00, 0x0A, 0x00, 0x0D, 0x00, 0x0A, 0x00, 0x0E, 0x00
        db 0xF6, 0xFF, 0x10, 0x00, 0x0A, 0x00, 0x11, 0x00, 0x0A, 0x00, 0x12, 0x00, 0x0A, 0x00, 0x13, 0x00
        db 0xF6, 0xFF, 0x15, 0x00, 0x0A, 0x00, 0x16, 0x00, 0x0A, 0x00, 0x17, 0x00, 0x0A, 0x00, 0x18, 0x00
        db 0xF6, 0xFF, 0x1A, 0x00, 0x0A, 0x00, 0x1B, 0x00, 0x0A, 0x00, 0x1C, 0x00, 0x0A, 0x00, 0x1D, 0x00
        db 0xF6, 0xFF, 0x1F, 0x00, 0x0A, 0x00, 0x20, 0x00, 0x0A, 0x00, 0x21, 0x00, 0x0A, 0x00, 0x22, 0x00
        db 0xF6, 0xFF, 0x24, 0x00, 0x0A, 0x00, 0x25, 0x00, 0x0A, 0x00, 0x26, 0x00, 0x0A, 0x00, 0x27, 0x00
        db 0xF6, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00, 0x28, 0x00, 0x30, 0x00
        db 0x38, 0x00, 0x29, 0x00, 0x0A, 0x00, 0x2A, 0x00, 0x0A, 0x00, 0x2B, 0x00, 0x0A, 0x00, 0x2C, 0x00
        db 0xF6, 0xFF, 0x2E, 0x00, 0x0A, 0x00, 0x2F, 0x00, 0x0A, 0x00, 0x30, 0x00, 0x0A, 0x00, 0x31, 0x00
        db 0xF6, 0xFF, 0x33, 0x00, 0x0A, 0x00, 0x34, 0x00, 0x0A, 0x00, 0x35, 0x00, 0x0A, 0x00, 0x36, 0x00
        db 0xF6, 0xFF, 0x38, 0x00, 0x0A, 0x00, 0x39, 0x00, 0x0A, 0x00, 0x3A, 0x00, 0x0A, 0x00, 0x3B, 0x00
        db 0xF6, 0xFF, 0x3D, 0x00, 0x0A, 0x00, 0x3E, 0x00, 0x0A, 0x00, 0x3F, 0x00, 0x0A, 0x00, 0x40, 0x00
        db 0xF6, 0xFF, 0x42, 0x00, 0x0A, 0x00, 0x43, 0x00, 0x0A, 0x00, 0x44, 0x00, 0x0A, 0x00, 0x45, 0x00
        db 0xF6, 0xFF, 0x47, 0x00, 0x0A, 0x00, 0x48, 0x00, 0x0A, 0x00, 0x49, 0x00, 0x0A, 0x00, 0x4A, 0x00
        db 0xF6, 0xFF, 0x4C, 0x00, 0x0A, 0x00, 0x4D, 0x00, 0x0A, 0x00, 0x4E, 0x00, 0x0A, 0x00, 0x4F, 0x00
        db 0xF6, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x50, 0x00, 0xF8, 0xFF, 0x51, 0x00, 0xF8, 0xFF, 0x52, 0x00, 0xF8, 0xFF, 0x53, 0x00
        db 0xF8, 0xFF, 0x54, 0x00, 0xF8, 0xFF, 0x55, 0x00, 0xF8, 0xFF, 0x56, 0x00, 0xF8, 0xFF, 0x57, 0x00
        db 0xF8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x58, 0x00, 0xF8, 0xFF, 0x59, 0x00, 0xF8, 0xFF, 0x5A, 0x00, 0xF8, 0xFF, 0x5B, 0x00
        db 0xF8, 0xFF, 0x5C, 0x00, 0xF8, 0xFF, 0x5D, 0x00, 0xF8, 0xFF, 0x5E, 0x00, 0xF8, 0xFF, 0x5F, 0x00
        db 0xF8, 0xFF, 0x00, 0x80, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00, 0x14, 0x00, 0x18, 0x00
        db 0x1C, 0x00, 0x90, 0x00, 0x04, 0x00, 0x91, 0x00, 0xFC, 0xFF, 0x92, 0x00, 0x04, 0x00, 0x93, 0x00
        db 0xFC, 0xFF, 0x94, 0x00, 0x04, 0x00, 0x95, 0x00, 0xFC, 0xFF, 0x96, 0x00, 0x04, 0x00, 0x97, 0x00
        db 0xFC, 0xFF, 0x98, 0x00, 0x04, 0x00, 0x99, 0x00, 0xFC, 0xFF, 0x9A, 0x00, 0x04, 0x00, 0x9B, 0x00
        db 0xFC, 0xFF, 0x9C, 0x00, 0x04, 0x00, 0x9D, 0x00, 0xFC, 0xFF, 0x9E, 0x00, 0x04, 0x00, 0x9F, 0x00
        db 0xFC, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0x63, 0x00, 0x04, 0x00, 0x64, 0x00, 0x04, 0x00, 0x65, 0x00, 0xEC, 0xFF, 0x69, 0x00
        db 0x04, 0x00, 0x6A, 0x00, 0x04, 0x00, 0x6B, 0x00, 0xEC, 0xFF, 0x6F, 0x00, 0x04, 0x00, 0x70, 0x00
        db 0x04, 0x00, 0x71, 0x00, 0xEC, 0xFF, 0x75, 0x00, 0x04, 0x00, 0x76, 0x00, 0x04, 0x00, 0x77, 0x00
        db 0xEC, 0xFF, 0x7B, 0x00, 0x04, 0x00, 0x7C, 0x00, 0x04, 0x00, 0x7D, 0x00, 0xEC, 0xFF, 0x81, 0x00
        db 0x04, 0x00, 0x82, 0x00, 0x04, 0x00, 0x83, 0x00, 0xEC, 0xFF, 0x87, 0x00, 0x04, 0x00, 0x88, 0x00
        db 0x04, 0x00, 0x89, 0x00, 0xEC, 0xFF, 0x8D, 0x00, 0x04, 0x00, 0x8E, 0x00, 0x04, 0x00, 0x8F, 0x00
        db 0xEC, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0x63, 0x00, 0x04, 0x00, 0x62, 0x00, 0x04, 0x00, 0x61, 0x00, 0xEC, 0xFF, 0x69, 0x00
        db 0x04, 0x00, 0x68, 0x00, 0x04, 0x00, 0x67, 0x00, 0xEC, 0xFF, 0x6F, 0x00, 0x04, 0x00, 0x6E, 0x00
        db 0x04, 0x00, 0x6D, 0x00, 0xEC, 0xFF, 0x75, 0x00, 0x04, 0x00, 0x74, 0x00, 0x04, 0x00, 0x73, 0x00
        db 0xEC, 0xFF, 0x7B, 0x00, 0x04, 0x00, 0x7A, 0x00, 0x04, 0x00, 0x79, 0x00, 0xEC, 0xFF, 0x81, 0x00
        db 0x04, 0x00, 0x80, 0x00, 0x04, 0x00, 0x7F, 0x00, 0xEC, 0xFF, 0x87, 0x00, 0x04, 0x00, 0x86, 0x00
        db 0x04, 0x00, 0x85, 0x00, 0xEC, 0xFF, 0x8D, 0x00, 0x04, 0x00, 0x8C, 0x00, 0x04, 0x00, 0x8B, 0x00
        db 0xEC, 0xFF, 0x00, 0x00, 0x12, 0x00, 0x24, 0x00, 0x36, 0x00, 0x48, 0x00, 0x5A, 0x00, 0x6C, 0x00
        db 0x7E, 0x00, 0x63, 0x00, 0x04, 0x00, 0x62, 0x00, 0x04, 0x00, 0x61, 0x00, 0x04, 0x00, 0x60, 0x00
        db 0x04, 0x00, 0x61, 0x00, 0x04, 0x00, 0x62, 0x00, 0x04, 0x00, 0x63, 0x00, 0x04, 0x00, 0x64, 0x00
        db 0x04, 0x00, 0x65, 0x00, 0xEC, 0xFF, 0x69, 0x00, 0x04, 0x00, 0x68, 0x00, 0x04, 0x00, 0x67, 0x00
        db 0x04, 0x00, 0x66, 0x00, 0x04, 0x00, 0x67, 0x00, 0x04, 0x00, 0x68, 0x00, 0x04, 0x00, 0x69, 0x00
        db 0x04, 0x00, 0x6A, 0x00, 0x04, 0x00, 0x6B, 0x00, 0xEC, 0xFF, 0x6F, 0x00, 0x04, 0x00, 0x6E, 0x00
        db 0x04, 0x00, 0x6D, 0x00, 0x04, 0x00, 0x6C, 0x00, 0x04, 0x00, 0x6D, 0x00, 0x04, 0x00, 0x6E, 0x00
        db 0x04, 0x00, 0x6F, 0x00, 0x04, 0x00, 0x70, 0x00, 0x04, 0x00, 0x71, 0x00, 0xEC, 0xFF, 0x75, 0x00
        db 0x04, 0x00, 0x74, 0x00, 0x04, 0x00, 0x73, 0x00, 0x04, 0x00, 0x72, 0x00, 0x04, 0x00, 0x73, 0x00
        db 0x04, 0x00, 0x74, 0x00, 0x04, 0x00, 0x75, 0x00, 0x04, 0x00, 0x76, 0x00, 0x04, 0x00, 0x77, 0x00
        db 0xEC, 0xFF, 0x7B, 0x00, 0x04, 0x00, 0x7A, 0x00, 0x04, 0x00, 0x79, 0x00, 0x04, 0x00, 0x78, 0x00
        db 0x04, 0x00, 0x79, 0x00, 0x04, 0x00, 0x7A, 0x00, 0x04, 0x00, 0x7B, 0x00, 0x04, 0x00, 0x7C, 0x00
        db 0x04, 0x00, 0x7D, 0x00, 0xEC, 0xFF, 0x81, 0x00, 0x04, 0x00, 0x80, 0x00, 0x04, 0x00, 0x7F, 0x00
        db 0x04, 0x00, 0x7E, 0x00, 0x04, 0x00, 0x7F, 0x00, 0x04, 0x00, 0x80, 0x00, 0x04, 0x00, 0x81, 0x00
        db 0x04, 0x00, 0x82, 0x00, 0x04, 0x00, 0x83, 0x00, 0xEC, 0xFF, 0x87, 0x00, 0x04, 0x00, 0x86, 0x00
        db 0x04, 0x00, 0x85, 0x00, 0x04, 0x00, 0x84, 0x00, 0x04, 0x00, 0x85, 0x00, 0x04, 0x00, 0x86, 0x00
        db 0x04, 0x00, 0x87, 0x00, 0x04, 0x00, 0x88, 0x00, 0x04, 0x00, 0x89, 0x00, 0xEC, 0xFF, 0x8D, 0x00
        db 0x04, 0x00, 0x8C, 0x00, 0x04, 0x00, 0x8B, 0x00, 0x04, 0x00, 0x8A, 0x00, 0x04, 0x00, 0x8B, 0x00
        db 0x04, 0x00, 0x8C, 0x00, 0x04, 0x00, 0x8D, 0x00, 0x04, 0x00, 0x8E, 0x00, 0x04, 0x00, 0x8F, 0x00
        db 0xEC, 0xFF, 0x00, 0x00, 0x12, 0x00, 0x24, 0x00, 0x36, 0x00, 0x48, 0x00, 0x5A, 0x00, 0x6C, 0x00
        db 0x7E, 0x00, 0x63, 0x00, 0x04, 0x00, 0x64, 0x00, 0x04, 0x00, 0x65, 0x00, 0x04, 0x00, 0x65, 0x00
        db 0x04, 0x00, 0x65, 0x00, 0x04, 0x00, 0x64, 0x00, 0x04, 0x00, 0x63, 0x00, 0x04, 0x00, 0x62, 0x00
        db 0x04, 0x00, 0x61, 0x00, 0xEC, 0xFF, 0x69, 0x00, 0x04, 0x00, 0x6A, 0x00, 0x04, 0x00, 0x6B, 0x00
        db 0x04, 0x00, 0x6B, 0x00, 0x04, 0x00, 0x6B, 0x00, 0x04, 0x00, 0x6A, 0x00, 0x04, 0x00, 0x69, 0x00
        db 0x04, 0x00, 0x68, 0x00, 0x04, 0x00, 0x67, 0x00, 0xEC, 0xFF, 0x6F, 0x00, 0x04, 0x00, 0x70, 0x00
        db 0x04, 0x00, 0x71, 0x00, 0x04, 0x00, 0x71, 0x00, 0x04, 0x00, 0x71, 0x00, 0x04, 0x00, 0x70, 0x00
        db 0x04, 0x00, 0x6F, 0x00, 0x04, 0x00, 0x6E, 0x00, 0x04, 0x00, 0x6D, 0x00, 0xEC, 0xFF, 0x75, 0x00
        db 0x04, 0x00, 0x76, 0x00, 0x04, 0x00, 0x77, 0x00, 0x04, 0x00, 0x77, 0x00, 0x04, 0x00, 0x77, 0x00
        db 0x04, 0x00, 0x76, 0x00, 0x04, 0x00, 0x75, 0x00, 0x04, 0x00, 0x74, 0x00, 0x04, 0x00, 0x73, 0x00
        db 0xEC, 0xFF, 0x7B, 0x00, 0x04, 0x00, 0x7C, 0x00, 0x04, 0x00, 0x7D, 0x00, 0x04, 0x00, 0x7D, 0x00
        db 0x04, 0x00, 0x7D, 0x00, 0x04, 0x00, 0x7C, 0x00, 0x04, 0x00, 0x7B, 0x00, 0x04, 0x00, 0x7A, 0x00
        db 0x04, 0x00, 0x79, 0x00, 0xEC, 0xFF, 0x81, 0x00, 0x04, 0x00, 0x82, 0x00, 0x04, 0x00, 0x83, 0x00
        db 0x04, 0x00, 0x83, 0x00, 0x04, 0x00, 0x83, 0x00, 0x04, 0x00, 0x82, 0x00, 0x04, 0x00, 0x81, 0x00
        db 0x04, 0x00, 0x80, 0x00, 0x04, 0x00, 0x7F, 0x00, 0xEC, 0xFF, 0x87, 0x00, 0x04, 0x00, 0x88, 0x00
        db 0x04, 0x00, 0x89, 0x00, 0x04, 0x00, 0x89, 0x00, 0x04, 0x00, 0x89, 0x00, 0x04, 0x00, 0x88, 0x00
        db 0x04, 0x00, 0x87, 0x00, 0x04, 0x00, 0x86, 0x00, 0x04, 0x00, 0x85, 0x00, 0xEC, 0xFF, 0x8D, 0x00
        db 0x04, 0x00, 0x8E, 0x00, 0x04, 0x00, 0x8F, 0x00, 0x04, 0x00, 0x8F, 0x00, 0x04, 0x00, 0x8F, 0x00
        db 0x04, 0x00, 0x8E, 0x00, 0x04, 0x00, 0x8D, 0x00, 0x04, 0x00, 0x8C, 0x00, 0x04, 0x00, 0x8B, 0x00
        db 0xEC, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xA0, 0x00, 0xF8, 0xFF, 0xA3, 0x00, 0xF8, 0xFF, 0xA6, 0x00, 0xF8, 0xFF, 0xA9, 0x00
        db 0xF8, 0xFF, 0xAC, 0x00, 0xF8, 0xFF, 0xAF, 0x00, 0xF8, 0xFF, 0xB2, 0x00, 0xF8, 0xFF, 0xB5, 0x00
        db 0xF8, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00, 0x28, 0x00, 0x30, 0x00
        db 0x38, 0x00, 0xA0, 0x00, 0x0A, 0x00, 0xA1, 0x00, 0x0A, 0x00, 0xA0, 0x00, 0x0A, 0x00, 0xA2, 0x00
        db 0xF6, 0xFF, 0xA3, 0x00, 0x0A, 0x00, 0xA4, 0x00, 0x0A, 0x00, 0xA3, 0x00, 0x0A, 0x00, 0xA5, 0x00
        db 0xF6, 0xFF, 0xA6, 0x00, 0x0A, 0x00, 0xA7, 0x00, 0x0A, 0x00, 0xA6, 0x00, 0x0A, 0x00, 0xA8, 0x00
        db 0xF6, 0xFF, 0xA9, 0x00, 0x0A, 0x00, 0xAA, 0x00, 0x0A, 0x00, 0xA9, 0x00, 0x0A, 0x00, 0xAB, 0x00
        db 0xF6, 0xFF, 0xAC, 0x00, 0x0A, 0x00, 0xAD, 0x00, 0x0A, 0x00, 0xAC, 0x00, 0x0A, 0x00, 0xAE, 0x00
        db 0xF6, 0xFF, 0xAF, 0x00, 0x0A, 0x00, 0xB0, 0x00, 0x0A, 0x00, 0xAF, 0x00, 0x0A, 0x00, 0xB1, 0x00
        db 0xF6, 0xFF, 0xB2, 0x00, 0x0A, 0x00, 0xB3, 0x00, 0x0A, 0x00, 0xB2, 0x00, 0x0A, 0x00, 0xB4, 0x00
        db 0xF6, 0xFF, 0xB5, 0x00, 0x0A, 0x00, 0xB6, 0x00, 0x0A, 0x00, 0xB5, 0x00, 0x0A, 0x00, 0xB7, 0x00
        db 0xF6, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0x00, 0x01, 0x04, 0x00, 0x01, 0x01, 0x08, 0x00, 0x00, 0x01, 0xFC, 0xFF, 0x02, 0x01
        db 0x04, 0x00, 0x03, 0x01, 0x08, 0x00, 0x02, 0x01, 0xFC, 0xFF, 0x04, 0x01, 0x04, 0x00, 0x05, 0x01
        db 0x08, 0x00, 0x04, 0x01, 0xFC, 0xFF, 0x06, 0x01, 0x04, 0x00, 0x07, 0x01, 0x08, 0x00, 0x06, 0x01
        db 0xFC, 0xFF, 0x08, 0x01, 0x04, 0x00, 0x09, 0x01, 0x08, 0x00, 0x08, 0x01, 0xFC, 0xFF, 0x0A, 0x01
        db 0x04, 0x00, 0x0B, 0x01, 0x08, 0x00, 0x0A, 0x01, 0xFC, 0xFF, 0x0C, 0x01, 0x04, 0x00, 0x0D, 0x01
        db 0x08, 0x00, 0x0C, 0x01, 0xFC, 0xFF, 0x0E, 0x01, 0x04, 0x00, 0x0F, 0x01, 0x08, 0x00, 0x0E, 0x01
        db 0xFC, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xF0, 0x00, 0xE8, 0xFF, 0xF1, 0x00, 0xE8, 0xFF, 0xF2, 0x00, 0xE8, 0xFF, 0xF3, 0x00
        db 0xE8, 0xFF, 0xF4, 0x00, 0xE8, 0xFF, 0xF5, 0x00, 0xE8, 0xFF, 0xF6, 0x00, 0xE8, 0xFF, 0xF7, 0x00
        db 0xE8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xF8, 0x00, 0xE8, 0xFF, 0xF9, 0x00, 0xE8, 0xFF, 0xFA, 0x00, 0xE8, 0xFF, 0xFB, 0x00
        db 0xE8, 0xFF, 0xFC, 0x00, 0xE8, 0xFF, 0xFD, 0x00, 0xE8, 0xFF, 0xFE, 0x00, 0xE8, 0xFF, 0xFF, 0x00
        db 0xE8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xE0, 0x00, 0xE8, 0xFF, 0xE1, 0x00, 0xE8, 0xFF, 0xE2, 0x00, 0xE8, 0xFF, 0xE3, 0x00
        db 0xE8, 0xFF, 0xE4, 0x00, 0xE8, 0xFF, 0xE5, 0x00, 0xE8, 0xFF, 0xE6, 0x00, 0xE8, 0xFF, 0xE7, 0x00
        db 0xE8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0xE8, 0x00, 0xE8, 0xFF, 0xE9, 0x00, 0xE8, 0xFF, 0xEA, 0x00, 0xE8, 0xFF, 0xEB, 0x00
        db 0xE8, 0xFF, 0xEC, 0x00, 0xE8, 0xFF, 0xED, 0x00, 0xE8, 0xFF, 0xEE, 0x00, 0xE8, 0xFF, 0xEF, 0x00
        db 0xE8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x28, 0x00, 0xE8, 0xFF, 0x2D, 0x00, 0xE8, 0xFF, 0x32, 0x00, 0xE8, 0xFF, 0x37, 0x00
        db 0xE8, 0xFF, 0x3C, 0x00, 0xE8, 0xFF, 0x41, 0x00, 0xE8, 0xFF, 0x46, 0x00, 0xE8, 0xFF, 0x4B, 0x00
        db 0xE8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x58, 0x01, 0xE2, 0xFF, 0x59, 0x01, 0xE2, 0xFF, 0x5A, 0x01, 0xE2, 0xFF, 0x5B, 0x01
        db 0xE2, 0xFF, 0x5C, 0x01, 0xE2, 0xFF, 0x5D, 0x01, 0xE2, 0xFF, 0x5E, 0x01, 0xE2, 0xFF, 0x5F, 0x01
        db 0xE2, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x58, 0x01, 0xE2, 0xFF, 0x59, 0x01, 0xE2, 0xFF, 0x5A, 0x01, 0xE2, 0xFF, 0x5B, 0x01
        db 0xE2, 0xFF, 0x5C, 0x01, 0xE2, 0xFF, 0x5D, 0x01, 0xE2, 0xFF, 0x5E, 0x01, 0xE2, 0xFF, 0x5F, 0x01
        db 0xE2, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x0C, 0x00
        db 0x0E, 0x00, 0x28, 0x00, 0xE2, 0xFF, 0x2D, 0x00, 0xE2, 0xFF, 0x32, 0x00, 0xE2, 0xFF, 0x37, 0x00
        db 0xE2, 0xFF, 0x3C, 0x00, 0xE2, 0xFF, 0x41, 0x00, 0xE2, 0xFF, 0x46, 0x00, 0xE2, 0xFF, 0x4B, 0x00
        db 0xE2, 0xFF, 0x00, 0x00, 0x0A, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x28, 0x00, 0x32, 0x00, 0x3C, 0x00
        db 0x46, 0x00, 0x30, 0x01, 0x06, 0x00, 0x31, 0x01, 0x06, 0x00, 0x32, 0x01, 0x64, 0x00, 0x33, 0x01
        db 0x08, 0x00, 0x50, 0x01, 0xF8, 0xFF, 0x34, 0x01, 0x06, 0x00, 0x35, 0x01, 0x06, 0x00, 0x36, 0x01
        db 0x64, 0x00, 0x37, 0x01, 0x08, 0x00, 0x51, 0x01, 0xF8, 0xFF, 0x38, 0x01, 0x06, 0x00, 0x39, 0x01
        db 0x06, 0x00, 0x3A, 0x01, 0x64, 0x00, 0x3B, 0x01, 0x08, 0x00, 0x52, 0x01, 0xF8, 0xFF, 0x3C, 0x01
        db 0x06, 0x00, 0x3D, 0x01, 0x06, 0x00, 0x3E, 0x01, 0x64, 0x00, 0x3F, 0x01, 0x08, 0x00, 0x53, 0x01
        db 0xF8, 0xFF, 0x40, 0x01, 0x06, 0x00, 0x41, 0x01, 0x06, 0x00, 0x42, 0x01, 0x64, 0x00, 0x43, 0x01
        db 0x08, 0x00, 0x54, 0x01, 0xF8, 0xFF, 0x44, 0x01, 0x06, 0x00, 0x45, 0x01, 0x06, 0x00, 0x46, 0x01
        db 0x64, 0x00, 0x47, 0x01, 0x08, 0x00, 0x55, 0x01, 0xF8, 0xFF, 0x48, 0x01, 0x06, 0x00, 0x49, 0x01
        db 0x06, 0x00, 0x4A, 0x01, 0x64, 0x00, 0x4B, 0x01, 0x08, 0x00, 0x56, 0x01, 0xF8, 0xFF, 0x4C, 0x01
        db 0x06, 0x00, 0x4D, 0x01, 0x06, 0x00, 0x4E, 0x01, 0x64, 0x00, 0x4F, 0x01, 0x08, 0x00, 0x57, 0x01
        db 0xF8, 0xFF, 0x00, 0x00, 0x0A, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x28, 0x00, 0x32, 0x00, 0x3C, 0x00
        db 0x46, 0x00, 0x10, 0x01, 0x06, 0x00, 0x11, 0x01, 0x06, 0x00, 0x12, 0x01, 0x64, 0x00, 0x13, 0x01
        db 0x08, 0x00, 0x50, 0x01, 0xF8, 0xFF, 0x14, 0x01, 0x06, 0x00, 0x15, 0x01, 0x06, 0x00, 0x16, 0x01
        db 0x64, 0x00, 0x17, 0x01, 0x08, 0x00, 0x51, 0x01, 0xF8, 0xFF, 0x18, 0x01, 0x06, 0x00, 0x19, 0x01
        db 0x06, 0x00, 0x1A, 0x01, 0x64, 0x00, 0x1B, 0x01, 0x08, 0x00, 0x52, 0x01, 0xF8, 0xFF, 0x1C, 0x01
        db 0x06, 0x00, 0x1D, 0x01, 0x06, 0x00, 0x1E, 0x01, 0x64, 0x00, 0x1F, 0x01, 0x08, 0x00, 0x53, 0x01
        db 0xF8, 0xFF, 0x20, 0x01, 0x06, 0x00, 0x21, 0x01, 0x06, 0x00, 0x22, 0x01, 0x64, 0x00, 0x23, 0x01
        db 0x08, 0x00, 0x54, 0x01, 0xF8, 0xFF, 0x24, 0x01, 0x06, 0x00, 0x25, 0x01, 0x06, 0x00, 0x26, 0x01
        db 0x64, 0x00, 0x27, 0x01, 0x08, 0x00, 0x55, 0x01, 0xF8, 0xFF, 0x28, 0x01, 0x06, 0x00, 0x29, 0x01
        db 0x06, 0x00, 0x2A, 0x01, 0x64, 0x00, 0x2B, 0x01, 0x08, 0x00, 0x56, 0x01, 0xF8, 0xFF, 0x2C, 0x01
        db 0x06, 0x00, 0x2D, 0x01, 0x06, 0x00, 0x2E, 0x01, 0x64, 0x00, 0x2F, 0x01, 0x08, 0x00, 0x57, 0x01
        db 0xF8, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0xB8, 0x00, 0x0C, 0x00, 0xB9, 0x00, 0x28, 0x00, 0xB8, 0x00, 0xFB, 0xFF, 0xBA, 0x00
        db 0x0C, 0x00, 0xBB, 0x00, 0x28, 0x00, 0xBA, 0x00, 0xFB, 0xFF, 0xBC, 0x00, 0x0C, 0x00, 0xBD, 0x00
        db 0x28, 0x00, 0xBC, 0x00, 0xFB, 0xFF, 0xBE, 0x00, 0x0C, 0x00, 0xBF, 0x00, 0x28, 0x00, 0xBE, 0x00
        db 0xFB, 0xFF, 0xC0, 0x00, 0x0C, 0x00, 0xC1, 0x00, 0x28, 0x00, 0xC0, 0x00, 0xFB, 0xFF, 0xC2, 0x00
        db 0x0C, 0x00, 0xC3, 0x00, 0x28, 0x00, 0xC2, 0x00, 0xFB, 0xFF, 0xC4, 0x00, 0x0C, 0x00, 0xC5, 0x00
        db 0x28, 0x00, 0xC4, 0x00, 0xFB, 0xFF, 0xC6, 0x00, 0x0C, 0x00, 0xC7, 0x00, 0x28, 0x00, 0xC6, 0x00
        db 0xFB, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00, 0x1E, 0x00, 0x24, 0x00
        db 0x2A, 0x00, 0xC8, 0x00, 0x08, 0x00, 0xC9, 0x00, 0x10, 0x00, 0xC8, 0x00, 0xF8, 0xFF, 0xCA, 0x00
        db 0x08, 0x00, 0xCB, 0x00, 0x10, 0x00, 0xCA, 0x00, 0xF8, 0xFF, 0xCC, 0x00, 0x08, 0x00, 0xCD, 0x00
        db 0x10, 0x00, 0xCC, 0x00, 0xF8, 0xFF, 0xCE, 0x00, 0x08, 0x00, 0xCF, 0x00, 0x10, 0x00, 0xCE, 0x00
        db 0xF8, 0xFF, 0xD0, 0x00, 0x08, 0x00, 0xD1, 0x00, 0x10, 0x00, 0xD0, 0x00, 0xF8, 0xFF, 0xD2, 0x00
        db 0x08, 0x00, 0xD3, 0x00, 0x10, 0x00, 0xD2, 0x00, 0xF8, 0xFF, 0xD4, 0x00, 0x08, 0x00, 0xD5, 0x00
        db 0x10, 0x00, 0xD4, 0x00, 0xF8, 0xFF, 0xD6, 0x00, 0x08, 0x00, 0xD7, 0x00, 0x10, 0x00, 0xD6, 0x00
        db 0xF8, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x0E, 0x00
        db 0x0E, 0x00, 0x7C, 0x01, 0x08, 0x00, 0x7D, 0x01, 0x08, 0x00, 0x7E, 0x01, 0xF8, 0xFF, 0x78, 0x01
        db 0x08, 0x00, 0x79, 0x01, 0x08, 0x00, 0x7A, 0x01, 0x08, 0x00, 0x7B, 0x01, 0xF8, 0xFF, 0x7B, 0x01
        db 0x08, 0x00, 0x7A, 0x01, 0x08, 0x00, 0x79, 0x01, 0x08, 0x00, 0x78, 0x01, 0xF8, 0xFF, 0x00, 0x00
        db 0x06, 0x00, 0x06, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x0E, 0x00, 0x7E, 0x01
        db 0x08, 0x00, 0x7D, 0x01, 0x08, 0x00, 0x7C, 0x01, 0xF8, 0xFF, 0x7B, 0x01, 0x08, 0x00, 0x7A, 0x01
        db 0x08, 0x00, 0x79, 0x01, 0x08, 0x00, 0x78, 0x01, 0xF8, 0xFF, 0x78, 0x01, 0x08, 0x00, 0x79, 0x01
        db 0x08, 0x00, 0x7A, 0x01, 0x08, 0x00, 0x7B, 0x01, 0xF8, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00
        db 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x06, 0x00, 0x6F, 0x01
        db 0x08, 0x00, 0x70, 0x01, 0xF8, 0xFF, 0x69, 0x01, 0x06, 0x00, 0x6A, 0x01, 0x08, 0x00, 0x6B, 0x01
        db 0xF8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00
        db 0x02, 0x00, 0x6D, 0x01, 0xFB, 0xFF, 0x68, 0x01, 0xFB, 0xFF, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2A, 0x02, 0x03, 0x00, 0x2B, 0x02
        db 0x03, 0x00, 0x2C, 0x02, 0x03, 0x00, 0x2D, 0x02, 0x03, 0x00, 0x2E, 0x02, 0x03, 0x00, 0x2F, 0x02
        db 0x03, 0x00, 0x30, 0x02, 0x03, 0x00, 0x31, 0x02, 0x03, 0x00, 0x32, 0x02, 0x03, 0x00, 0x33, 0x02
        db 0x03, 0x00, 0x34, 0x02, 0x03, 0x00, 0x35, 0x02, 0x03, 0x00, 0x36, 0x02, 0x03, 0x00, 0x37, 0x02
        db 0xFD, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x84, 0x02, 0x08, 0x00, 0x85, 0x02, 0x08, 0x00, 0x86, 0x02, 0x08, 0x00, 0x87, 0x02
        db 0x08, 0x00, 0x88, 0x02, 0x18, 0xFC, 0x00, 0x80, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0xD8, 0x00, 0xE2, 0xFF, 0xD9, 0x00, 0xE2, 0xFF, 0xDA, 0x00
        db 0xE2, 0xFF, 0xDB, 0x00, 0xE2, 0xFF, 0xDC, 0x00, 0xE2, 0xFF, 0xDD, 0x00, 0xE2, 0xFF, 0xDE, 0x00
        db 0xE2, 0xFF, 0xDF, 0x00, 0xE2, 0xFF, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00
        db 0x14, 0x00, 0x18, 0x00, 0x1C, 0x00, 0x38, 0x02, 0x06, 0x00, 0x39, 0x02, 0xFA, 0xFF, 0x3A, 0x02
        db 0x06, 0x00, 0x3B, 0x02, 0xFA, 0xFF, 0x3C, 0x02, 0x06, 0x00, 0x3D, 0x02, 0xFA, 0xFF, 0x3E, 0x02
        db 0x06, 0x00, 0x3F, 0x02, 0xFA, 0xFF, 0x40, 0x02, 0x06, 0x00, 0x41, 0x02, 0xFA, 0xFF, 0x42, 0x02
        db 0x06, 0x00, 0x43, 0x02, 0xFA, 0xFF, 0x44, 0x02, 0x06, 0x00, 0x45, 0x02, 0xFA, 0xFF, 0x46, 0x02
        db 0x06, 0x00, 0x47, 0x02, 0xFA, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0x48, 0x02, 0xE2, 0xFF, 0x4A, 0x02, 0xE2, 0xFF, 0x4C, 0x02
        db 0xE2, 0xFF, 0x4E, 0x02, 0xE2, 0xFF, 0x50, 0x02, 0xE2, 0xFF, 0x52, 0x02, 0xE2, 0xFF, 0x54, 0x02
        db 0xE2, 0xFF, 0x56, 0x02, 0xE2, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00
        db 0x28, 0x00, 0x30, 0x00, 0x38, 0x00, 0x48, 0x02, 0x09, 0x00, 0x49, 0x02, 0x09, 0x00, 0x48, 0x02
        db 0x09, 0x00, 0x49, 0x02, 0xF7, 0xFF, 0x4A, 0x02, 0x09, 0x00, 0x4B, 0x02, 0x09, 0x00, 0x4A, 0x02
        db 0x09, 0x00, 0x4B, 0x02, 0xF7, 0xFF, 0x4C, 0x02, 0x09, 0x00, 0x4D, 0x02, 0x09, 0x00, 0x4C, 0x02
        db 0x09, 0x00, 0x4D, 0x02, 0xF7, 0xFF, 0x4E, 0x02, 0x09, 0x00, 0x4F, 0x02, 0x09, 0x00, 0x4E, 0x02
        db 0x09, 0x00, 0x4F, 0x02, 0xF7, 0xFF, 0x50, 0x02, 0x09, 0x00, 0x51, 0x02, 0x09, 0x00, 0x50, 0x02
        db 0x09, 0x00, 0x51, 0x02, 0xF7, 0xFF, 0x52, 0x02, 0x09, 0x00, 0x53, 0x02, 0x09, 0x00, 0x52, 0x02
        db 0x09, 0x00, 0x53, 0x02, 0xF7, 0xFF, 0x54, 0x02, 0x09, 0x00, 0x55, 0x02, 0x09, 0x00, 0x54, 0x02
        db 0x09, 0x00, 0x55, 0x02, 0xF7, 0xFF, 0x56, 0x02, 0x09, 0x00, 0x57, 0x02, 0x09, 0x00, 0x56, 0x02
        db 0x09, 0x00, 0x57, 0x02, 0xF7, 0xFF, 0x00, 0x00, 0x0A, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x28, 0x00
        db 0x32, 0x00, 0x3C, 0x00, 0x46, 0x00, 0x58, 0x02, 0x06, 0x00, 0x59, 0x02, 0x06, 0x00, 0x5A, 0x02
        db 0x08, 0x00, 0x59, 0x02, 0x06, 0x00, 0x58, 0x02, 0xFA, 0xFF, 0x5B, 0x02, 0x06, 0x00, 0x5C, 0x02
        db 0x06, 0x00, 0x5D, 0x02, 0x08, 0x00, 0x5C, 0x02, 0x06, 0x00, 0x5B, 0x02, 0xFA, 0xFF, 0x5E, 0x02
        db 0x06, 0x00, 0x5F, 0x02, 0x06, 0x00, 0x60, 0x02, 0x08, 0x00, 0x5F, 0x02, 0x06, 0x00, 0x5E, 0x02
        db 0xFA, 0xFF, 0x61, 0x02, 0x06, 0x00, 0x62, 0x02, 0x06, 0x00, 0x63, 0x02, 0x08, 0x00, 0x62, 0x02
        db 0x06, 0x00, 0x61, 0x02, 0xFA, 0xFF, 0x64, 0x02, 0x06, 0x00, 0x65, 0x02, 0x06, 0x00, 0x66, 0x02
        db 0x08, 0x00, 0x65, 0x02, 0x06, 0x00, 0x64, 0x02, 0xFA, 0xFF, 0x67, 0x02, 0x06, 0x00, 0x68, 0x02
        db 0x06, 0x00, 0x69, 0x02, 0x08, 0x00, 0x68, 0x02, 0x06, 0x00, 0x67, 0x02, 0xFA, 0xFF, 0x6A, 0x02
        db 0x06, 0x00, 0x6B, 0x02, 0x06, 0x00, 0x6C, 0x02, 0x08, 0x00, 0x6B, 0x02, 0x06, 0x00, 0x6A, 0x02
        db 0xFA, 0xFF, 0x6D, 0x02, 0x06, 0x00, 0x6E, 0x02, 0x06, 0x00, 0x6F, 0x02, 0x08, 0x00, 0x6E, 0x02
        db 0x06, 0x00, 0x6D, 0x02, 0xFA, 0xFF, 0x00, 0x00, 0x0C, 0x00, 0x18, 0x00, 0x24, 0x00, 0x30, 0x00
        db 0x3C, 0x00, 0x48, 0x00, 0x54, 0x00, 0x50, 0x00, 0x04, 0x00, 0x57, 0x00, 0x04, 0x00, 0x0C, 0x01
        db 0x14, 0x00, 0x5F, 0x00, 0x04, 0x00, 0x58, 0x00, 0x04, 0x00, 0x59, 0x00, 0xFC, 0xFF, 0x51, 0x00
        db 0x04, 0x00, 0x50, 0x00, 0x04, 0x00, 0x0E, 0x01, 0x14, 0x00, 0x58, 0x00, 0x04, 0x00, 0x59, 0x00
        db 0x04, 0x00, 0x5A, 0x00, 0xFC, 0xFF, 0x52, 0x00, 0x04, 0x00, 0x51, 0x00, 0x04, 0x00, 0x00, 0x01
        db 0x14, 0x00, 0x59, 0x00, 0x04, 0x00, 0x5A, 0x00, 0x04, 0x00, 0x5B, 0x00, 0xFC, 0xFF, 0x53, 0x00
        db 0x04, 0x00, 0x52, 0x00, 0x04, 0x00, 0x02, 0x01, 0x14, 0x00, 0x5A, 0x00, 0x04, 0x00, 0x5B, 0x00
        db 0x04, 0x00, 0x5C, 0x00, 0xFC, 0xFF, 0x54, 0x00, 0x04, 0x00, 0x53, 0x00, 0x04, 0x00, 0x04, 0x01
        db 0x14, 0x00, 0x5B, 0x00, 0x04, 0x00, 0x5C, 0x00, 0x04, 0x00, 0x5D, 0x00, 0xFC, 0xFF, 0x55, 0x00
        db 0x04, 0x00, 0x54, 0x00, 0x04, 0x00, 0x06, 0x01, 0x14, 0x00, 0x5C, 0x00, 0x04, 0x00, 0x5D, 0x00
        db 0x04, 0x00, 0x5E, 0x00, 0xFC, 0xFF, 0x56, 0x00, 0x04, 0x00, 0x55, 0x00, 0x04, 0x00, 0x08, 0x01
        db 0x14, 0x00, 0x5D, 0x00, 0x04, 0x00, 0x5E, 0x00, 0x04, 0x00, 0x5F, 0x00, 0xFC, 0xFF, 0x57, 0x00
        db 0x04, 0x00, 0x56, 0x00, 0x04, 0x00, 0x0A, 0x01, 0x14, 0x00, 0x5E, 0x00, 0x04, 0x00, 0x5F, 0x00
        db 0x04, 0x00, 0x58, 0x00, 0xFC, 0xFF, 0x00, 0x00, 0x0E, 0x00, 0x1C, 0x00, 0x2A, 0x00, 0x38, 0x00
        db 0x46, 0x00, 0x54, 0x00, 0x62, 0x00, 0x70, 0x02, 0x06, 0x00, 0x71, 0x02, 0x06, 0x00, 0x72, 0x02
        db 0x06, 0x00, 0x73, 0x02, 0x06, 0x00, 0x12, 0x01, 0x64, 0x00, 0x13, 0x01, 0x08, 0x00, 0x50, 0x01
        db 0xF8, 0xFF, 0x70, 0x02, 0x06, 0x00, 0x71, 0x02, 0x06, 0x00, 0x72, 0x02, 0x06, 0x00, 0x73, 0x02
        db 0x06, 0x00, 0x16, 0x01, 0x64, 0x00, 0x17, 0x01, 0x08, 0x00, 0x51, 0x01, 0xF8, 0xFF, 0x70, 0x02
        db 0x06, 0x00, 0x71, 0x02, 0x06, 0x00, 0x72, 0x02, 0x06, 0x00, 0x73, 0x02, 0x06, 0x00, 0x1A, 0x01
        db 0x64, 0x00, 0x1B, 0x01, 0x08, 0x00, 0x52, 0x01, 0xF8, 0xFF, 0x74, 0x02, 0x06, 0x00, 0x75, 0x02
        db 0x06, 0x00, 0x76, 0x02, 0x06, 0x00, 0x77, 0x02, 0x06, 0x00, 0x1E, 0x01, 0x64, 0x00, 0x1F, 0x01
        db 0x08, 0x00, 0x53, 0x01, 0xF8, 0xFF, 0x74, 0x02, 0x06, 0x00, 0x75, 0x02, 0x06, 0x00, 0x76, 0x02
        db 0x06, 0x00, 0x77, 0x02, 0x06, 0x00, 0x22, 0x01, 0x64, 0x00, 0x23, 0x01, 0x08, 0x00, 0x54, 0x01
        db 0xF8, 0xFF, 0x74, 0x02, 0x06, 0x00, 0x75, 0x02, 0x06, 0x00, 0x76, 0x02, 0x06, 0x00, 0x77, 0x02
        db 0x06, 0x00, 0x26, 0x01, 0x64, 0x00, 0x27, 0x01, 0x08, 0x00, 0x55, 0x01, 0xF8, 0xFF, 0x74, 0x02
        db 0x06, 0x00, 0x75, 0x02, 0x06, 0x00, 0x76, 0x02, 0x06, 0x00, 0x77, 0x02, 0x06, 0x00, 0x2A, 0x01
        db 0x64, 0x00, 0x2B, 0x01, 0x08, 0x00, 0x56, 0x01, 0xF8, 0xFF, 0x70, 0x02, 0x06, 0x00, 0x71, 0x02
        db 0x06, 0x00, 0x72, 0x02, 0x06, 0x00, 0x73, 0x02, 0x06, 0x00, 0x2E, 0x01, 0x64, 0x00, 0x2F, 0x01
        db 0x08, 0x00, 0x57, 0x01, 0xF8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x00, 0x24, 0x00
        db 0x24, 0x00, 0x24, 0x00, 0x00, 0x00, 0x10, 0x01, 0x06, 0x00, 0x11, 0x01, 0x06, 0x00, 0x12, 0x01
        db 0x1E, 0x00, 0x78, 0x02, 0x0A, 0x00, 0x79, 0x02, 0x0A, 0x00, 0x7A, 0x02, 0x0A, 0x00, 0x7B, 0x02
        db 0x08, 0x00, 0x7C, 0x02, 0x08, 0x00, 0x7D, 0x02, 0x08, 0x00, 0x7B, 0x02, 0x08, 0x00, 0x7C, 0x02
        db 0x08, 0x00, 0x7D, 0x02, 0x08, 0x00, 0x7B, 0x02, 0x08, 0x00, 0x7C, 0x02, 0x08, 0x00, 0x7D, 0x02
        db 0x08, 0x00, 0x7B, 0x02, 0x08, 0x00, 0x7C, 0x02, 0x08, 0x00, 0x7D, 0x02, 0xAC, 0xF4, 0x20, 0x01
        db 0x06, 0x00, 0x21, 0x01, 0x06, 0x00, 0x22, 0x01, 0x1E, 0x00, 0x7E, 0x02, 0x0A, 0x00, 0x7F, 0x02
        db 0x0A, 0x00, 0x80, 0x02, 0x0A, 0x00, 0x81, 0x02, 0x08, 0x00, 0x82, 0x02, 0x08, 0x00, 0x83, 0x02
        db 0x08, 0x00, 0x81, 0x02, 0x08, 0x00, 0x82, 0x02, 0x08, 0x00, 0x83, 0x02, 0x08, 0x00, 0x81, 0x02
        db 0x08, 0x00, 0x82, 0x02, 0x08, 0x00, 0x83, 0x02, 0x08, 0x00, 0x81, 0x02, 0x08, 0x00, 0x82, 0x02
        db 0x08, 0x00, 0x83, 0x02, 0xAC, 0xF4, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0x8A, 0x02, 0xF8, 0xFF, 0xAD, 0x02, 0xF8, 0xFF, 0xA8, 0x02
        db 0xF8, 0xFF, 0xA3, 0x02, 0xF8, 0xFF, 0x9E, 0x02, 0xF8, 0xFF, 0x99, 0x02, 0xF8, 0xFF, 0x94, 0x02
        db 0xF8, 0xFF, 0x8F, 0x02, 0xF8, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00
        db 0x28, 0x00, 0x30, 0x00, 0x38, 0x00, 0x8D, 0x02, 0x0A, 0x00, 0x8E, 0x02, 0x0A, 0x00, 0x8B, 0x02
        db 0x0A, 0x00, 0x8C, 0x02, 0xF6, 0xFF, 0xB0, 0x02, 0x0A, 0x00, 0xB1, 0x02, 0x0A, 0x00, 0xAE, 0x02
        db 0x0A, 0x00, 0xAF, 0x02, 0xF6, 0xFF, 0xAB, 0x02, 0x0A, 0x00, 0xAC, 0x02, 0x0A, 0x00, 0xA9, 0x02
        db 0x0A, 0x00, 0xAA, 0x02, 0xF6, 0xFF, 0xA6, 0x02, 0x0A, 0x00, 0xA7, 0x02, 0x0A, 0x00, 0xA4, 0x02
        db 0x0A, 0x00, 0xA5, 0x02, 0xF6, 0xFF, 0xA1, 0x02, 0x0A, 0x00, 0xA2, 0x02, 0x0A, 0x00, 0x9F, 0x02
        db 0x0A, 0x00, 0xA0, 0x02, 0xF6, 0xFF, 0x9C, 0x02, 0x0A, 0x00, 0x9D, 0x02, 0x0A, 0x00, 0x9A, 0x02
        db 0x0A, 0x00, 0x9B, 0x02, 0xF6, 0xFF, 0x97, 0x02, 0x0A, 0x00, 0x98, 0x02, 0x0A, 0x00, 0x95, 0x02
        db 0x0A, 0x00, 0x96, 0x02, 0xF6, 0xFF, 0x92, 0x02, 0x0A, 0x00, 0x93, 0x02, 0x0A, 0x00, 0x90, 0x02
        db 0x0A, 0x00, 0x91, 0x02, 0xF6, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0xF3, 0x02, 0xF8, 0xFF, 0xF4, 0x02, 0xF8, 0xFF, 0xF5, 0x02
        db 0xF8, 0xFF, 0xF6, 0x02, 0xF8, 0xFF, 0xF7, 0x02, 0xF8, 0xFF, 0xF8, 0x02, 0xF8, 0xFF, 0xF9, 0x02
        db 0xF8, 0xFF, 0xFA, 0x02, 0xF8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0xFB, 0x02, 0xF8, 0xFF, 0xFC, 0x02, 0xF8, 0xFF, 0xFD, 0x02
        db 0xF8, 0xFF, 0xFE, 0x02, 0xF8, 0xFF, 0xFF, 0x02, 0xF8, 0xFF, 0x00, 0x03, 0xF8, 0xFF, 0x01, 0x03
        db 0xF8, 0xFF, 0x02, 0x03, 0xF8, 0xFF, 0x00, 0x80, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00
        db 0x14, 0x00, 0x18, 0x00, 0x1C, 0x00, 0x03, 0x03, 0x04, 0x00, 0x04, 0x03, 0xFC, 0xFF, 0x05, 0x03
        db 0x04, 0x00, 0x06, 0x03, 0xFC, 0xFF, 0x07, 0x03, 0x04, 0x00, 0x08, 0x03, 0xFC, 0xFF, 0x09, 0x03
        db 0x04, 0x00, 0x0A, 0x03, 0xFC, 0xFF, 0x0B, 0x03, 0x04, 0x00, 0x0C, 0x03, 0xFC, 0xFF, 0x0D, 0x03
        db 0x04, 0x00, 0x0E, 0x03, 0xFC, 0xFF, 0x0F, 0x03, 0x04, 0x00, 0x10, 0x03, 0xFC, 0xFF, 0x11, 0x03
        db 0x04, 0x00, 0x12, 0x03, 0xFC, 0xFF, 0x00, 0x00, 0x06, 0x00, 0x0C, 0x00, 0x12, 0x00, 0x18, 0x00
        db 0x1E, 0x00, 0x24, 0x00, 0x2A, 0x00, 0x13, 0x03, 0x0A, 0x00, 0x14, 0x03, 0x1C, 0x00, 0x15, 0x03
        db 0xF6, 0xFF, 0x16, 0x03, 0x0A, 0x00, 0x17, 0x03, 0x1C, 0x00, 0x18, 0x03, 0xF6, 0xFF, 0x19, 0x03
        db 0x0A, 0x00, 0x1A, 0x03, 0x1C, 0x00, 0x1B, 0x03, 0xF6, 0xFF, 0x1C, 0x03, 0x0A, 0x00, 0x1D, 0x03
        db 0x1C, 0x00, 0x1E, 0x03, 0xF6, 0xFF, 0x1F, 0x03, 0x0A, 0x00, 0x20, 0x03, 0x1C, 0x00, 0x21, 0x03
        db 0xF6, 0xFF, 0x22, 0x03, 0x0A, 0x00, 0x23, 0x03, 0x1C, 0x00, 0x24, 0x03, 0xF6, 0xFF, 0x25, 0x03
        db 0x0A, 0x00, 0x26, 0x03, 0x1C, 0x00, 0x27, 0x03, 0xF6, 0xFF, 0x28, 0x03, 0x0A, 0x00, 0x29, 0x03
        db 0x1C, 0x00, 0x2A, 0x03, 0xF6, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0xCB, 0x02, 0xF8, 0xFF, 0xEE, 0x02, 0xF8, 0xFF, 0xE9, 0x02
        db 0xF8, 0xFF, 0xE4, 0x02, 0xF8, 0xFF, 0xE1, 0x02, 0xF8, 0xFF, 0xDA, 0x02, 0xF8, 0xFF, 0xD5, 0x02
        db 0xF8, 0xFF, 0xD0, 0x02, 0xF8, 0xFF, 0x00, 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00, 0x20, 0x00
        db 0x28, 0x00, 0x30, 0x00, 0x38, 0x00, 0xCE, 0x02, 0x0A, 0x00, 0xCF, 0x02, 0x0A, 0x00, 0xCC, 0x02
        db 0x0A, 0x00, 0xCD, 0x02, 0xF6, 0xFF, 0xF1, 0x02, 0x0A, 0x00, 0xF2, 0x02, 0x0A, 0x00, 0xF0, 0x02
        db 0x0A, 0x00, 0xEF, 0x02, 0xF6, 0xFF, 0xEC, 0x02, 0x0A, 0x00, 0xED, 0x02, 0x0A, 0x00, 0xEA, 0x02
        db 0x0A, 0x00, 0xEB, 0x02, 0xF6, 0xFF, 0xE7, 0x02, 0x0A, 0x00, 0xE8, 0x02, 0x0A, 0x00, 0xE5, 0x02
        db 0x0A, 0x00, 0xE6, 0x02, 0xF6, 0xFF, 0xE2, 0x02, 0x0A, 0x00, 0xDF, 0x02, 0x0A, 0x00, 0xE0, 0x02
        db 0x0A, 0x00, 0xE3, 0x02, 0xF6, 0xFF, 0xDD, 0x02, 0x0A, 0x00, 0xDE, 0x02, 0x0A, 0x00, 0xDB, 0x02
        db 0x0A, 0x00, 0xDC, 0x02, 0xF6, 0xFF, 0xD8, 0x02, 0x0A, 0x00, 0xD9, 0x02, 0x0A, 0x00, 0xD6, 0x02
        db 0x0A, 0x00, 0xD7, 0x02, 0xF6, 0xFF, 0xD3, 0x02, 0x0A, 0x00, 0xD4, 0x02, 0x0A, 0x00, 0xD1, 0x02
        db 0x0A, 0x00, 0xD2, 0x02, 0xF6, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0x2B, 0x03, 0xF8, 0xFF, 0x2C, 0x03, 0xF8, 0xFF, 0x2D, 0x03
        db 0xF8, 0xFF, 0x2E, 0x03, 0xF8, 0xFF, 0x2F, 0x03, 0xF8, 0xFF, 0x30, 0x03, 0xF8, 0xFF, 0x31, 0x03
        db 0xF8, 0xFF, 0x32, 0x03, 0xF8, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0x33, 0x03, 0xF8, 0xFF, 0x34, 0x03, 0xF8, 0xFF, 0x35, 0x03
        db 0xF8, 0xFF, 0x36, 0x03, 0xF8, 0xFF, 0x37, 0x03, 0xF8, 0xFF, 0x38, 0x03, 0xF8, 0xFF, 0x39, 0x03
        db 0xF8, 0xFF, 0x3A, 0x03, 0xF8, 0xFF, 0x00, 0x80, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00
        db 0x14, 0x00, 0x18, 0x00, 0x1C, 0x00, 0x3B, 0x03, 0x04, 0x00, 0x3C, 0x03, 0xFC, 0xFF, 0x3D, 0x03
        db 0x04, 0x00, 0x3E, 0x03, 0xFC, 0xFF, 0x3F, 0x03, 0x04, 0x00, 0x40, 0x03, 0xFC, 0xFF, 0x41, 0x03
        db 0x04, 0x00, 0x42, 0x03, 0xFC, 0xFF, 0x43, 0x03, 0x04, 0x00, 0x44, 0x03, 0xFC, 0xFF, 0x45, 0x03
        db 0x04, 0x00, 0x46, 0x03, 0xFC, 0xFF, 0x47, 0x03, 0x04, 0x00, 0x48, 0x03, 0xFC, 0xFF, 0x49, 0x03
        db 0x04, 0x00, 0x4A, 0x03, 0xFC, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x06, 0x00, 0x08, 0x00
        db 0x0A, 0x00, 0x0C, 0x00, 0x0E, 0x00, 0xB3, 0x02, 0xF4, 0xFF, 0xBA, 0x02, 0xF4, 0xFF, 0xB9, 0x02
        db 0xF4, 0xFF, 0xB8, 0x02, 0xF4, 0xFF, 0xB7, 0x02, 0xF4, 0xFF, 0xB6, 0x02, 0xF4, 0xFF, 0xB5, 0x02
        db 0xF4, 0xFF, 0xB4, 0x02, 0xF4, 0xFF, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x10, 0x00
        db 0x14, 0x00, 0x18, 0x00, 0x1C, 0x00, 0xBB, 0x02, 0x08, 0x00, 0xBC, 0x02, 0xE8, 0xFF, 0xBD, 0x02
        db 0x08, 0x00, 0xBE, 0x02, 0xE8, 0xFF, 0xBF, 0x02, 0x08, 0x00, 0xC0, 0x02, 0xE8, 0xFF, 0xC1, 0x02
        db 0x08, 0x00, 0xC2, 0x02, 0xE8, 0xFF, 0xC3, 0x02, 0x08, 0x00, 0xC4, 0x02, 0xE8, 0xFF, 0xC5, 0x02
        db 0x08, 0x00, 0xC6, 0x02, 0xE8, 0xFF, 0xC7, 0x02, 0x08, 0x00, 0xC8, 0x02, 0xE8, 0xFF, 0xC9, 0x02
        db 0x08, 0x00, 0xCA, 0x02, 0xE8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00
        db 0x06, 0x00, 0x06, 0x00, 0x00, 0x00, 0x4B, 0x03, 0x08, 0x00, 0x4C, 0x03, 0x08, 0x00, 0xBF, 0x02
        db 0xF8, 0xFF, 0x4D, 0x03, 0x08, 0x00, 0x4E, 0x03, 0x08, 0x00, 0xC7, 0x02, 0xF8, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0xBF, 0x02
        db 0xF8, 0xFF, 0xC7, 0x02, 0xF8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x5B, 0x03, 0x0C, 0x00, 0x5C, 0x03
        db 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x5F, 0x03, 0x0C, 0x00, 0x60, 0x03
        db 0x0C, 0x00, 0x61, 0x03, 0x0C, 0x00, 0x5F, 0x03, 0x0C, 0x00, 0x60, 0x03, 0x0C, 0x00, 0x61, 0x03
        db 0x0C, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x54, 0x03, 0x0C, 0x00, 0x55, 0x03
        db 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x56, 0x03, 0x0C, 0x00, 0x57, 0x03
        db 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x52, 0x03, 0x0C, 0x00, 0x53, 0x03
        db 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x5D, 0x03, 0x0C, 0x00, 0x5E, 0x03
        db 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x59, 0x03, 0x30, 0x00, 0x4F, 0x03
        db 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x58, 0x03, 0x30, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03
        db 0x0C, 0x00, 0x5A, 0x03, 0x30, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F, 0x03, 0x0C, 0x00, 0x50, 0x03
        db 0x0C, 0x00, 0x51, 0x03, 0x18, 0x00, 0x4F, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x04, 0x00, 0x04, 0x00
        db 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x6E, 0x01, 0x06, 0x00, 0x6F, 0x01
        db 0xF8, 0xFF, 0x69, 0x01, 0x06, 0x00, 0x6A, 0x01, 0xF8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x74, 0x01, 0x08, 0x00, 0x75, 0x01
        db 0x08, 0x00, 0x76, 0x01, 0x08, 0x00, 0x77, 0x01, 0xF8, 0xFF, 0x77, 0x01, 0x08, 0x00, 0x76, 0x01
        db 0x08, 0x00, 0x75, 0x01, 0x08, 0x00, 0x74, 0x01, 0xF8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00, 0x77, 0x01, 0x08, 0x00, 0x76, 0x01
        db 0x08, 0x00, 0x75, 0x01, 0x08, 0x00, 0x74, 0x01, 0xF8, 0xFF, 0x74, 0x01, 0x08, 0x00, 0x75, 0x01
        db 0x08, 0x00, 0x76, 0x01, 0x08, 0x00, 0x77, 0x01, 0xF8, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x01, 0x1E, 0x00, 0x72, 0x01
        db 0x1E, 0x00, 0x73, 0x01, 0x1E, 0x00, 0x72, 0x01, 0x1E, 0x00, 0x71, 0x01, 0xC4, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x01
        db 0x1E, 0x00, 0x72, 0x01, 0x1E, 0x00, 0x73, 0x01, 0x1E, 0x00, 0x71, 0x01, 0xC4, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x01
        db 0x1E, 0x00, 0x72, 0x01, 0x1E, 0x00, 0x73, 0x01, 0x1E, 0x00, 0x72, 0x01, 0x1E, 0x00, 0x73, 0x01
        db 0x1E, 0x00, 0x71, 0x01, 0xC4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x01, 0x1E, 0x00, 0x7C, 0x01, 0x2D, 0x00, 0x71, 0x01
        db 0xC4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x71, 0x01, 0x1E, 0x00, 0x7D, 0x01, 0x2D, 0x00, 0x71, 0x01, 0xC4, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0xBB, 0x02
        db 0x1E, 0x00, 0xBC, 0x02, 0x2D, 0x00, 0xBB, 0x02, 0xE2, 0xFF, 0xBD, 0x02, 0x1E, 0x00, 0xBE, 0x02
        db 0x2D, 0x00, 0xBD, 0x02, 0xE2, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x89, 0x02, 0x1E, 0x00, 0xC1, 0x02, 0x1E, 0x00, 0xC2, 0x02
        db 0x1E, 0x00, 0xC3, 0x02, 0x1E, 0x00, 0xC2, 0x02, 0x1E, 0x00, 0xC3, 0x02, 0x1E, 0x00, 0xC1, 0x02
        db 0x1E, 0x00, 0x89, 0x02, 0xE2, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x89, 0x02, 0x1E, 0x00, 0xB2, 0x02, 0x1E, 0x00, 0xC1, 0x02
        db 0x1E, 0x00, 0x89, 0x02, 0xE2, 0xFF, 0x00, 0x00, 0x0A, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x28, 0x00
        db 0x32, 0x00, 0x3C, 0x00, 0x46, 0x00, 0x61, 0x00, 0x18, 0x00, 0x62, 0x00, 0x04, 0x00, 0x63, 0x00
        db 0x04, 0x00, 0x64, 0x00, 0x04, 0x00, 0x65, 0x00, 0xEC, 0xFF, 0x67, 0x00, 0x18, 0x00, 0x68, 0x00
        db 0x04, 0x00, 0x69, 0x00, 0x04, 0x00, 0x6A, 0x00, 0x04, 0x00, 0x6B, 0x00, 0xEC, 0xFF, 0x6D, 0x00
        db 0x18, 0x00, 0x6E, 0x00, 0x04, 0x00, 0x6F, 0x00, 0x04, 0x00, 0x70, 0x00, 0x04, 0x00, 0x71, 0x00
        db 0xEC, 0xFF, 0x73, 0x00, 0x18, 0x00, 0x74, 0x00, 0x04, 0x00, 0x75, 0x00, 0x04, 0x00, 0x76, 0x00
        db 0x04, 0x00, 0x77, 0x00, 0xEC, 0xFF, 0x79, 0x00, 0x18, 0x00, 0x7A, 0x00, 0x04, 0x00, 0x7B, 0x00
        db 0x04, 0x00, 0x7C, 0x00, 0x04, 0x00, 0x7D, 0x00, 0xEC, 0xFF, 0x7F, 0x00, 0x18, 0x00, 0x80, 0x00
        db 0x04, 0x00, 0x81, 0x00, 0x04, 0x00, 0x82, 0x00, 0x04, 0x00, 0x83, 0x00, 0xEC, 0xFF, 0x85, 0x00
        db 0x18, 0x00, 0x86, 0x00, 0x04, 0x00, 0x87, 0x00, 0x04, 0x00, 0x88, 0x00, 0x04, 0x00, 0x89, 0x00
        db 0xEC, 0xFF, 0x8B, 0x00, 0x18, 0x00, 0x8C, 0x00, 0x04, 0x00, 0x8D, 0x00, 0x04, 0x00, 0x8E, 0x00
        db 0x04, 0x00, 0x8F, 0x00, 0xEC, 0xFF, 0x00, 0x00, 0x0A, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x28, 0x00
        db 0x32, 0x00, 0x3C, 0x00, 0x46, 0x00, 0x65, 0x00, 0x18, 0x00, 0x64, 0x00, 0x04, 0x00, 0x63, 0x00
        db 0x04, 0x00, 0x62, 0x00, 0x04, 0x00, 0x61, 0x00, 0xEC, 0xFF, 0x6B, 0x00, 0x18, 0x00, 0x6A, 0x00
        db 0x04, 0x00, 0x69, 0x00, 0x04, 0x00, 0x68, 0x00, 0x04, 0x00, 0x67, 0x00, 0xEC, 0xFF, 0x71, 0x00
        db 0x18, 0x00, 0x70, 0x00, 0x04, 0x00, 0x6F, 0x00, 0x04, 0x00, 0x6E, 0x00, 0x04, 0x00, 0x6D, 0x00
        db 0xEC, 0xFF, 0x77, 0x00, 0x18, 0x00, 0x76, 0x00, 0x04, 0x00, 0x75, 0x00, 0x04, 0x00, 0x74, 0x00
        db 0x04, 0x00, 0x73, 0x00, 0xEC, 0xFF, 0x7D, 0x00, 0x18, 0x00, 0x7C, 0x00, 0x04, 0x00, 0x7B, 0x00
        db 0x04, 0x00, 0x7A, 0x00, 0x04, 0x00, 0x79, 0x00, 0xEC, 0xFF, 0x83, 0x00, 0x18, 0x00, 0x82, 0x00
        db 0x04, 0x00, 0x81, 0x00, 0x04, 0x00, 0x80, 0x00, 0x04, 0x00, 0x7F, 0x00, 0xEC, 0xFF, 0x89, 0x00
        db 0x18, 0x00, 0x88, 0x00, 0x04, 0x00, 0x87, 0x00, 0x04, 0x00, 0x86, 0x00, 0x04, 0x00, 0x85, 0x00
        db 0xEC, 0xFF, 0x8F, 0x00, 0x18, 0x00, 0x8E, 0x00, 0x04, 0x00, 0x8D, 0x00, 0x04, 0x00, 0x8C, 0x00
        db 0x04, 0x00, 0x8B, 0x00, 0xEC, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x65, 0x01, 0x10, 0x00, 0x66, 0x01, 0x10, 0x00, 0x68, 0x03
        db 0x20, 0x00, 0x66, 0x01, 0x0C, 0x00, 0x69, 0x03, 0x0C, 0x00, 0xDC, 0x00, 0xE0, 0xFF, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x03
        db 0x0C, 0x00, 0x63, 0x03, 0x0C, 0x00, 0x62, 0x03, 0x0C, 0x00, 0x63, 0x03, 0x0C, 0x00, 0x64, 0x03
        db 0xFC, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x64, 0x03, 0x11, 0x00, 0x65, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x67, 0x03, 0x0C, 0x00, 0x66, 0x03
        db 0x0C, 0x00, 0x67, 0x03, 0x0C, 0x00, 0x66, 0x03, 0x0C, 0x00, 0x67, 0x03, 0x0C, 0x00, 0x66, 0x03
        db 0x0C, 0x00, 0x65, 0x03, 0xF4, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6A, 0x03, 0x0C, 0x00, 0x6B, 0x03, 0xF4
priolist_m1:                                    ; byte before priolist; used by AI
        db 0xFF
priolist:                                       ; player priority list used by SetPlList; used by AI
        db 0x00, 0x01, 0x02, 0x04, 0x03, 0x05, 0x06, 0x00
shownumbers:                                    ; show jersey numbers; used by AI, GAME, INIT
        db 0x00, 0x00, 0x00, 0x00
SortPending:                                    ; sprite sort pending; used by AI, INIT
        db 0x00, 0x00
exitgame:                                       ; set when the game is left; used by AI, GAME, INIT
        db 0x01, 0x00
gameover:                                       ; set when the game is over; used by AI, GAME, INIT
        db 0x01, 0x00
PerTimeTab:                                     ; period length table (GetPeriodTime); used by AI
        db 0x2C, 0x01, 0x58, 0x02, 0xB0, 0x04, 0xB0, 0x04
energywarnteam:                                 ; energy warning flag per team; used by AI, INIT
        db 0x00, 0x00
lcrequestteam:                                  ; team that asked for a line change; used by AI, INIT
        db 0x00, 0x00
lcsel:                                          ; selected line change choice per team; used by AI, INIT,
                                                ; MENUS
        db 0x00, 0x00
energywarn:                                     ; energy warning flag; used by AI, INIT, MENUS
        db 0x00, 0x00
lcblink:                                        ; line change box blink state; used by AI, INIT
        times 2 db 0
lcblinktime:                                    ; line change box blink timer; used by INIT
        times 2 db 0
lcchoice:                                       ; line change choice per team; used by AI, INIT
        times 2 db 0
lcstate:                                        ; line change state saved with the game; used by INIT
        times 2 db 0
lcgroup:                                        ; line group per team (3 = power play); used by AI, INIT
        times 2 db 0
lcactive:                                       ; line change box active; used by AI, INIT
        times 2 db 0
lctime:                                         ; line change box time per team; used by AI, INIT
        times 2 db 0
lcstate2:                                       ; line change state saved with the game; used by INIT
        times 2 db 0
lcboxon:                                        ; line change box shown; used by AI, INIT, MENUS
        times 2 db 0
hudredraw:                                      ; panel redraw flag; used by AI, INIT, MENUS
        times 2 db 0
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x03, 0x02, 0x01, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x00, 0x03, 0xFF, 0x00, 0x01, 0x03, 0xFF, 0x00, 0x01, 0x02, 0xFF
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x00, 0x03, 0xFF, 0x03, 0x00, 0x01, 0xFF, 0x00, 0x01, 0x02, 0xFF
        db 0x02, 0x01, 0x00, 0xFF, 0x00, 0x02, 0x01, 0xFF, 0x01, 0x02, 0x00, 0xFF, 0x01, 0x00, 0x02, 0xFF
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x01, 0x02, 0x03, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x01, 0x03, 0x02, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
        db 0x02, 0x01, 0x00, 0xFF, 0x00, 0x01, 0x02, 0xFF, 0x02, 0x01, 0x00, 0xFF, 0x01, 0x00, 0x02, 0xFF
        db 0x05, 0x04, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF
        db 0x01, 0x00, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF
        db 0x01, 0x02, 0xFF, 0xFF, 0x02, 0x00, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0xFF
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x03, 0x00, 0xFF, 0x03, 0x00, 0x01, 0xFF, 0x00, 0x01, 0x02, 0xFF
        db 0x01, 0x02, 0xFF, 0xFF, 0x00, 0x02, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0xFF
CompLineTab:                                    ; line offset table of CompLine; used by AI
        db 0xE6, 0x48, 0xF6, 0x48, 0x16, 'I&I6IFIVIfIvI'
        db 0x86, 0x49, 0x96, 0x49
puckfaceoff2_ptab:                              ; faceoff positions, x; used by AI, INIT
        db 0x00, 0x00
puckfaceoff2_ptab_y:                            ; faceoff positions, y; used by AI, INIT
        db 0x24, 0xFF, 0xDD, 0xFF, 0xD3, 0xFF, 0x23, 0x00, 0xD3, 0xFF, 0xCC, 0xFF, 0xF6, 0xFF, 0x00, 0x00
        db 0xF8, 0xFF, 0x34, 0x00, 0xF6, 0xFF, 0x00, 0x00
        db 0xC9, 0xFF
apl:                                            ; position slots of the formations; used by AI, INIT
        db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05
        db 0x06, 0x00, 0x00, 0x01, 0x05, 0x03, 0x04, 0x02, 0x00, 0x00, 0x00, 0x03, 0x05, 0x01, 0x04, 0x00
        db 0x00, 0x00
ovltimer:                                       ; stoppage and banner timer; used by AI, INIT
        db 0xFF, 0xFF
refhitcount:                                    ; referee hit counter; used by AI, INIT
        db 0x00, 0x00
fadeinpending:                                  ; palette fade-in pending; used by AI, GAME, INIT
        db 0x00, 0x00
injurystop:                                     ; play stopped for an injury; used by AI, INIT
        db 0x00, 0x00
bannermsg:                                      ; banner message; used by AI, INIT
        db 0xFF, 0xFF
bannertimer:                                    ; banner timer; used by AI, INIT
        db 0x00, 0x00
ovlseq:                                         ; text overlay sequence; used by AI, INIT
        db 0xFF, 0xFF
ovlstep:                                        ; text overlay step; used by AI, INIT
        db 0xFF, 0xFF
TeamPPVNames:                                   ; team .QPP file name pointers (LoadTeamPPV); used by AI, INIT
        dw str_Fanom
        dw str_Goal
        dw str_Clap
        dw str_Uflag
        dw str_Cflag
TeamPPVSizes:                                   ; team picture size table; used by AI, INIT
        db 0x47, 0x01
TeamPPVSizes2:                                  ; second team picture size table; used by AI, INIT
        db 'c82'
        db 0x01, 'c8:', 0x01
        db 'c8f', 0x01, 0x63, 0x38, 0x8F
        db 0x01, 0x63, 0x38
OverlayScript:                                  ; text overlay script bytes; used by AI
        db 0x01
        db 0x00, 0x01, 0x01, 0x01, 0x00
goalienotebits:                                 ; goalie note bits (3Fh all done); used by AI, INIT
        db 0x00, 0x00
PenCntDwn2:                                     ; second penalty countdown; used by AI, INIT
        db 0xFF, 0xFF
RinkOverlayFrames:                              ; frames of the rink overlay sprites; used by AI, INIT
        db 0x85, 0x01, 0x86, 0x01
RinkOverlayFrames2:                             ; further rink overlay frames; used by AI, INIT
        db 0x87, 0x01, 0x7F
        db 0x01, 0x80, 0x01, 0x81, 0x01, 0x61, 0x01, 0x60, 0x01, 0x61, 0x01, 0x81, 0x01, 0x80, 0x01, 0x82
        db 0x01, 0x83, 0x01, 0x84, 0x01, 0x63, 0x01, 0x62
        db 0x01, 0x63, 0x01, 0x84, 0x01, 0x83, 0x01
halfsecflag:                                    ; toggled each half second by periodicevents; used by AI, INIT
        db 0x00
secondframes:                                   ; frames left in the current second; used by AI
        db 0x00
ltack:                                          ; last touch for icing; used by AI, INIT
        db 0x00, 0x00
lastsfx:                                        ; last sound effect played; used by PlaySoundEffect
        dw 0xFFFF
CrowdSound:                                     ; crowd sound handle; used by CrowdNoiseUpdate, CrowdFadeOut,
                                                ; PlaySoundEffect
        times 2 db 0
photobankf:                                     ; PPV file pointer 1; used by INIT
        times 2 db 0
photobankf_w2:                                  ; PPV file pointer 2; used by INIT
        times 2 db 0
photobankf_w4:                                  ; PPV file pointer 3; used by INIT
        times 2 db 0
photobankf_w6:                                  ; PPV file pointer 4; used by INIT
        times 2 db 0
photobankf_w8:                                  ; PPV file pointer 5; used by INIT
        times 2 db 0
photobankf_wA:                                  ; PPV file pointer 6; used by INIT
        times 2 db 0
demoflag:                                       ; demo mode; used by AI, INIT
        times 2 db 0
introskipped:                                   ; pre-game intro skipped; used by AI, GAME, INIT
        times 2 db 0
onetimerflag:                                   ; one-timer pending; used by AI, INIT
        times 2 db 0
str_HomepalsBin_2:                              ; string 'HOMEPALS.BIN'; used by GAME
        db 'HOMEPALS.BIN', 0x00
str_AwaypalsBin_2:                              ; string 'AWAYPALS.BIN'; used by GAME
        db 'AWAYPALS.BIN', 0x00
str_Rinkpal_2:                                  ; string 'rinkpal'; used by GAME
        db 'rinkpal', 0x00
str_Pal_12:                                     ; string '!pal'; used by GAME
        db '!pal', 0x00, 0x00, 0xDC, 0x7B, 0xCF, 0xBD, 0xF7, 0x00, 0xC0, 0x08, 0x62, 0x04
        db 0x00, 0x00, 0xDF, 0xFF, 0xFF, 0xDF, 0xFF, 0xFF, 0x00, 0x00, 0xFE, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xFC, 0xFF, 0xFF, 0xFB, 0xFF, 0xFF, 0xFF, 0xFB, 0xFF
        db 0xFF, 0xFF, 0x1F, 0x00
        db 0x7C, 0xFE, 0x51, 0x13, 0xDB, 0xB6, 0xED, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0x00, 0x00, 0x80, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xFF, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        times 16 db 0
samesideflag:                                   ; both controllers on the same side; used by AI, MENUS
        times 2 db 0
inputframes:                                    ; input frame counter; used by AI, GAME, INIT
        times 2 db 0
framesync:                                      ; frame sync flag of the game loops; used by AI, GAME, MENUS
        times 2 db 0
joyrec:                                         ; current input queue record; used by AI, GAME
        times 6 db 0
FadeSteps:                                      ; fade step table (FadePalette); used by GAME
        db 0x01
FadeStep:                                       ; current fade step; used by GAME
        db 0x0F
FadeSteps2:                                     ; second fade step table; used by GAME
        db 0x01, 0xFF
FadeCount:                                      ; fade step count; used by GAME
        db 0x11, 0xFF, 0x5C, 0x00
str_GameSav_2:                                  ; string 'game.sav'; used by GAME
        db 'game.sav', 0x00, 0x00
DirtyRects:                                     ; dirty rectangle list (20 per page); used by GAME
        db 0x00, 0x00, 0x00, 0x00
DeskRedrawPage:                                 ; page redraw flags; used by AI, GAME, INIT, MENUS
        db 0x00, 0x00
DeskRedrawPage2:                                ; second page redraw flag; used by AI, GAME, INIT, MENUS
        db 0x00, 0x00
SpriteBlitFns:                                  ; far routine table of the sprite blitters
                                                ; (DrawSpriteClipped); used by GAME
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw NullGameHookThunk, 0x1B35
        dw DrawRleTransFastAt, 0x0FEF
        dw DrawRleTransAt, 0x0FEF
        dw DrawRleTransRemapAt, 0x0FEF
        dw DrawRleTransRemapFastAt, 0x0FEF
        dw DrawRleFlipAt, 0x0FEF
        dw DrawRleFlipTransAt, 0x0FEF
        dw DrawRleFlipRemapAt, 0x0FEF
        dw DrawRleFlipTransRemapAt, 0x0FEF
        db '%04d', 0x00
str_FD50D99:                                    ; string 'f%d50_%d99'; used by INIT
        db 'f%d50_%d99', 0x00
str_FD00D49:                                    ; string 'f%d00_%d49'; used by INIT
        db 'f%d00_%d49', 0x00
str_04d_3:                                      ; string '%04d'; used by INIT
        db '%04d', 0x00
str_D50D99:                                     ; string '%d50_%d99'; used by INIT
        db '%d50_%d99', 0x00
str_D00D49:                                     ; string '%d00_%d49'; used by INIT
        db '%d00_%d49', 0x00
str_Trinknd:                                    ; string 'trinknd'; used by INIT
        db 'trinknd', 0x00
str_0000_2:                                     ; string '0000'; used by INIT
        db '0000', 0x00
str_Numshp:                                     ; string 'numshp'; used by INIT
        db 'numshp', 0x00
str_04d_2:                                      ; string '%04d'; used by INIT
        db '%04d', 0x00
str_000g000d000d000l000c000r000x:               ; string '000G000D000D000L000C000R000X'; used by INIT
        db '000G000D000D000L000C000R000X'
        db 0x00
MatchupOrder:                                   ; order bytes of the matchup screen; used by INIT
        db 0x00, 0x01, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A
        db 0x0B, 'apal', 0x00
str_Pal_11:                                     ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_S1Fnt_4:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Wittle06Fnt_3:                              ; string 'wittle06.fnt'; used by INIT
        db 'wittle06.fnt', 0x00
str_Arena:                                      ; string 'arena'; used by INIT
        db 'arena', 0x00
str_Pal_10:                                     ; string '!pal'; used by INIT
        db '!pal', 0x00
str_Rink:                                       ; string 'rink'; used by INIT
        db 'rink', 0x00
str_SAtS:                                       ; string '%s at %s'; used by INIT
        db '%s at %s', 0x00
        db '%d', 0x00, '%d', 0x00
str_Pointer_4:                                  ; string 'Pointer'; used by INIT
        db 'Pointer', 0x00
str_Pal_9:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_8:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00, 0x00
str_Crests4_4:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Summary_3:                                  ; string 'summary'; used by INIT
        db 'summary', 0x00
str_City_3:                                     ; string 'city'; used by INIT
        db 'city', 0x00
str_Summary2_2:                                 ; string 'summary2'; used by INIT
        db 'summary2', 0x00
str_Defnforwlineootspairscrasummtoni_2:         ; string 'defnforwlineootspairscrasummtoni'; used by INIT
        db 'defnforwlineootspairscrasummtoni'
        db 0x00
str_Crests2Bin_3:                               ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt_3:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Gipk:                                       ; string 'GIPK'; used by INIT
        db 'GIPK', 0x00
str_Injured_2:                                  ; string 'Injured'; used by INIT
        db 'Injured', 0x00, 0x00
str_Mtrocku_2:                                  ; string 'MTROCKU'; used by INIT
        db 'MTROCKU', 0x00
str_Sbrocku_2:                                  ; string 'SBROCKU'; used by INIT
        db 'SBROCKU', 0x00
str_Adrocku_2:                                  ; string 'ADROCKU'; used by INIT
        db 'ADROCKU', 0x00
str_Mtrocku:                                    ; string 'MTROCKU'; used by INIT
        db 'MTROCKU', 0x00
str_Sbrocku:                                    ; string 'SBROCKU'; used by INIT
        db 'SBROCKU', 0x00
str_Adrocku:                                    ; string 'ADROCKU'; used by INIT
        db 'ADROCKU', 0x00
str_Rockditi_2:                                 ; string 'ROCKDITI'; used by INIT
        db 'ROCKDITI', 0x00
str_Rockditi:                                   ; string 'ROCKDITI'; used by INIT
        db 'ROCKDITI', 0x00
str_FirstPeriod:                                ; string 'First Period'; used by INIT
        db 'First Period', 0x00
str_SecondPeriod:                               ; string 'Second Period'; used by INIT
        db 'Second Period', 0x00
str_ThirdPeriod:                                ; string 'Third Period'; used by INIT
        db 'Third Period', 0x00
str_OvertimePeriodD:                            ; string 'Overtime Period %d'; used by INIT
        db 'Overtime Period %d'
        db 0x00
str_Overtime:                                   ; string 'Overtime'; used by INIT
        db 'Overtime', 0x00
str_MtsumKms_2:                                 ; string 'mtsum.kms'; used by INIT
        db 'mtsum.kms', 0x00
str_MtsumCfg_2:                                 ; string 'mtsum.cfg'; used by INIT
        db 'mtsum.cfg', 0x00
str_AdsumKms_2:                                 ; string 'adsum.kms'; used by INIT
        db 'adsum.kms', 0x00
str_AdsumCfg_2:                                 ; string 'adsum.cfg'; used by INIT
        db 'adsum.cfg', 0x00
str_Crests4_3:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Summary_2:                                  ; string 'summary'; used by INIT
        db 'summary', 0x00
str_City_2:                                     ; string 'city'; used by INIT
        db 'city', 0x00
str_Summary2:                                   ; string 'summary2'; used by INIT
        db 'summary2', 0x00
str_Defnforwlineootspairscrasummtoni:           ; string 'defnforwlineootspairscrasummtoni'; used by INIT
        db 'defnforwlineootspairscrasummtoni'
        db 0x00
str_Crests2Bin_2:                               ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt_2:                                    ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_Gsummary_2:                                 ; string 'gsummary'; used by INIT
        db 'gsummary', 0x00
        db '%d', 0x00, '%d', 0x00
str_1st:                                        ; string '1st'; used by INIT
        db '1st', 0x00
str_2nd:                                        ; string '2nd'; used by INIT
        db '2nd', 0x00
str_3rd:                                        ; string '3rd'; used by INIT
        db '3rd', 0x00
        db 0x4F, 0x54, 0x00
str_FinalOt:                                    ; string 'Final (OT)'; used by INIT
        db 'Final (OT)', 0x00
str_Final:                                      ; string 'Final'; used by INIT
        db 'Final', 0x00
str_Period:                                     ; string ' period'; used by INIT
        db ' period', 0x00
str_Injured:                                    ; string 'Injured'; used by INIT
        db 'Injured', 0x00
str_Evnt:                                       ; string 'EVNT'; used by INIT
        db 'EVNT', 0x00
str_Prds:                                       ; string 'PRDS'; used by INIT
        db 'PRDS', 0x00
        db 0x25, 0x73, 0x00
str_D_3:                                        ; string ' (%d'; used by INIT
        db ' (%d', 0x00
str_St:                                         ; string 'st)'; used by INIT
        db 'st)', 0x00
str_Nd:                                         ; string 'nd)'; used by INIT
        db 'nd)', 0x00
str_Rd:                                         ; string 'rd)'; used by INIT
        db 'rd)', 0x00
str_Th:                                         ; string 'th)'; used by INIT
        db 'th)', 0x00
str_Sh_2:                                       ; string ' SH'; used by INIT
        db ' SH', 0x00
str_Pp_2:                                       ; string ' PP'; used by INIT
        db ' PP', 0x00
str_02d02d_2:                                   ; string '%02d:%02d'; used by INIT
        db '%02d:%02d', 0x00
str_S_2:                                        ; string '(%s'; used by INIT
        db '(%s', 0x00
        db ', ', 0x00, 0x29, 0x00
        db 0x25, 0x73, 0x00
str_SS_2:                                       ; string '%s    %s'; used by INIT
        db '%s    %s', 0x00
str_SDMinS:                                     ; string '%s %d min.: %s'; used by INIT
        db '%s %d min.: %s', 0x00
str_02d02d:                                     ; string '%02d:%02d'; used by INIT
        db '%02d:%02d', 0x00
str_ShotsOnGoal:                                ; string 'Shots on goal'; used by INIT
        db 'Shots on goal', 0x00
str_SDD_2:                                      ; string '%s %d/%d'; used by INIT
        db '%s %d/%d', 0x00
str_SDD:                                        ; string '%s %d/%d'; used by INIT
        db '%s %d/%d', 0x00, 0x00
str_MtsumKms:                                   ; string 'mtsum.kms'; used by INIT
        db 'mtsum.kms', 0x00
str_MtsumCfg:                                   ; string 'mtsum.cfg'; used by INIT
        db 'mtsum.cfg', 0x00
str_AdsumKms:                                   ; string 'adsum.kms'; used by INIT
        db 'adsum.kms', 0x00
str_AdsumCfg:                                   ; string 'adsum.cfg'; used by INIT
        db 'adsum.cfg', 0x00
str_Summary:                                    ; string 'summary'; used by INIT
        db 'summary', 0x00
str_Crests4_2:                                  ; string 'crests4'; used by INIT
        db 'crests4', 0x00
str_Crests2Bin:                                 ; string 'crests2.bin'; used by INIT
        db 'crests2.bin', 0x00
str_S1Fnt:                                      ; string 's1.fnt'; used by INIT
        db 's1.fnt', 0x00
str_City:                                       ; string 'city'; used by INIT
        db 'city', 0x00
        db '%d', 0x00, '%d', 0x00
str_DD_2:                                       ; string '%d/%d'; used by INIT
        db '%d/%d', 0x00
str_DD:                                         ; string '%d/%d'; used by INIT
        db '%d/%d', 0x00
        db '%d', 0x00, '%d', 0x00
str_D02d:                                       ; string '%d:%02d'; used by INIT
        db '%d:%02d', 0x00
str_DDD:                                        ; string '%d/%d (%d%%)'; used by INIT
        db '%d/%d (%d%%)', 0x00, 0x00
TeamStatsLabels:                                ; message list of 4 far string pointers: 'Score / Shots /
                                                ; Power play / Penalties'; used by INIT
        db 0x00, 0x00
TeamStatsLabelPtrs:                             ; label pointers of the team stats summary; used by INIT
        db 0xEB, 0x38
        dw str_Shots_5, 0x38EB
        dw str_PowerPlay_3, 0x38EB
        dw str_Penalties_2, 0x38EB
        dw str_FaceoffsWon, 0x38EB
        dw str_BodyChecks, 0x38EB
        dw str_AttackZone, 0x38EB
        dw str_Passing_2, 0x38EB
        db 'Geneva11.fnt', 0x00, '#%d   %s %s', 0x00, '#%d   %c. %s', 0x00, 'key', 0x00, 'career', 0x00
        db 'season', 0x00, 'GP', 0x00, 0x57, 0x00, 0x4C, 0x00, 0x54, 0x00, 'SO', 0x00, 'GAA', 0x00, 'Pct', 0x00
        db 'player%d', 0x00, 'Geneva11.fnt', 0x00, 'HAT  TRICK', 0x00, '1ST  NHL  GOAL', 0x00, '%dTH  ', 0x00
        db 'CAREER  ', 0x00, 'PLAYOFF  ', 0x00, 'POINT', 0x00, 'GOAL', 0x00, '%s', 0x00, '#%d   %s %s', 0x00
        db '#%d   %c. %s', 0x00, 'key', 0x00, 'career', 0x00, 'season', 0x00, 'GP', 0x00, 0x47, 0x00, 0x41, 0x00
        db 'Pt', 0x00, 'CG', 0x00, 'CA', 0x00, 'CPt', 0x00, 'PIM', 0x00, '+/-', 0x00, 'Pct', 0x00, 0x00
hilightsplayed:                                 ; bits of the highlights already shown; used by INIT
        db 0x00, 0x00
str_Pal_7:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_6:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
str_Pal_5:                                      ; string 'Pal'; used by INIT
        db 'Pal', 0x00
        db 0x41, 0x00, 0x48, 0x00
str_P1Mvi:                                      ; string 'P1.MVI'; used by INIT
        db 'P1.MVI', 0x00
        db 0x41, 0x00, 0x48, 0x00
str_G1Mvi:                                      ; string 'G1.MVI'; used by INIT
        db 'G1.MVI', 0x00
        db 0x41, 0x00, 0x48, 0x00
        db 'G2.QPP', 0x00
str_Pal_4:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_EascrnQpp:                                  ; string 'EASCRN.QPP'; used by INIT
        db 'EASCRN.QPP', 0x00
str_Scrn:                                       ; string 'scrn'; used by INIT
        db 'scrn', 0x00
str_Pal_3:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_0000:                                       ; string '0000'; used by INIT
        db '0000', 0x00
str_Stop:                                       ; string 'stop'; used by INIT
        db 'stop', 0x00
str_Qpp_2:                                      ; string '.qpp'; used by INIT
        db '.qpp', 0x00
str_Logo:                                       ; string 'logo'; used by INIT
        db 'logo', 0x00
str_Pal_2:                                      ; string '!pal'; used by INIT
        db '!pal', 0x00
str_Vidframe:                                   ; string 'vidframe'; used by INIT
        db 'vidframe', 0x00, 0x00
str_Teams_2:                                    ; string 'teams'; used by INIT
        db 'teams', 0x00
        db 0x31, 0x00, 0x32, 0x00
        db 0x33, 0x00, 0x34, 0x00
        db 0x35, 0x00
str_Teams:                                      ; string 'teams'; used by INIT
        db 'teams', 0x00
        db 0x31, 0x00, 0x32, 0x00
        db 0x33, 0x00, 0x37, 0x00
        db 0x38, 0x00, 'B1', 0x00
        db 'B5', 0x00, 'B8', 0x00
        db 0x44, 0x00, 0x45, 0x00
        db 0x46, 0x00, 0x47, 0x00
        db 0x48, 0x00, 0x49, 0x00
        db 0x4C, 0x00, 0x4D, 0x00
        db 0x4E, 0x00, 0x4F, 0x00
        db 0x50, 0x00, 0x51, 0x00
str_Key:                                        ; string 'key'; used by INIT
        db 'key', 0x00
        db 0x39, 0x00, 0x41, 0x00
str_Att:                                        ; string 'att'; used by INIT
        db 'att', 0x00
        db 0x42, 0x00, 0x43, 0x00
str_Season_2:                                   ; string 'season'; used by INIT
        db 'season', 0x00
        db 0x4A, 0x00, 0x4B, 0x00
str_Career_2:                                   ; string 'career'; used by INIT
        db 'career', 0x00
        db 0x4C, 0x00, 0x4D, 0x00, 0x00, 0x07, 0x00, 0x04, 0x00, 0x03, 0x00, 0x06, 0x00, 0x01, 0x00, 0x08
        db 0x00, 0x02, 0x00, 0x00, 0x00
        db 0x5C, 0x00
str_GsummaryDb_3:                               ; string 'gsummary.db'; used by INIT
        db 'gsummary.db', 0x00
str_RinkTil_2:                                  ; string 'rink.til'; used by INIT
        db 'rink.til', 0x00
str_InvalidFileRinkTilSizeS:                    ; string 'Invalid file 'RINK.TIL' size %s\n'; used by INIT
        db 'Invalid file ', 0x27, 'RINK.TIL', 0x27, ' size %s'
        db 0x0A, 0x00
str_RinkTil:                                    ; string 'rink.til'; used by INIT
        db 'rink.til', 0x00
str_STil:                                       ; string '%s.til'; used by INIT
        db '%s.til', 0x00
str_InvalidFileSSizeD:                          ; string 'Invalid file '%s' size %d\n'; used by INIT
        db 'Invalid file ', 0x27, 0x25, 0x73, 0x27, ' size %d'
        db 0x0A, 0x00
str_RinkMap:                                    ; string 'rink.map'; used by INIT
        db 'rink.map', 0x00
str_SMap:                                       ; string '%s.map'; used by INIT
        db '%s.map', 0x00, 0x00
        db 'BOS', 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x42, 0x55, 0x46, 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x43, 0x47, 0x59, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x43, 0x48, 0x49, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x44, 0x45, 0x54, 0x00, 0x15, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x45, 0x44, 0x4D, 0x00, 0x16, 0x00
        db 0x2C, 0x00, 0x19, 0x00
        db 0x23, 0x00, 'HFD', 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4C, 0x41, 0x20, 0x00
        db 0x20, 0x00, 0x2D, 0x00, 0x0F, 0x00
        db 0x22, 0x00, 'MIN', 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4D, 0x54, 0x4C, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E, 0x4A, 0x20, 0x00, 0x1E, 0x00
        db 0x2D, 0x00, 0x11, 0x00
        db 0x22, 0x00, 'NYI', 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E, 0x59, 0x52, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x4F, 0x54, 0x54, 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x50, 0x48, 0x49, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x50, 0x49, 0x54, 0x00, 0x0D, 0x00, 0x1F, 0x00
        db 0x22, 0x00, 0x30, 0x00
        db 'QUE', 0x00, 0x16, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x53, 0x54, 0x4C, 0x00, 0x15, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x53, 0x4A, 0x20, 0x00, 0x13, 0x00
        db 0x24, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x54, 0x42, 0x20, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x54, 0x4F, 0x52, 0x00, 0x16, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x56, 0x41, 0x4E, 0x00, 0x15, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x57, 0x53, 0x48, 0x00, 0x16, 0x00
        db 0x25, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x57, 0x50, 0x47, 0x00, 0x15, 0x00
        db 0x26, 0x00, 0xFF, 0xFF, 0xFF, 0xFF
str_Scrbrd1:                                    ; string 'scrbrd1'; used by INIT
        db 'scrbrd1', 0x00
str_0000000100020003000400050006000700080009000: ; string '0000000100020003000400050006000700080009000 '
                                                ; used by INIT
        db '0000000100020003000400050006000700080009000 '
        db 0x00
str_1000100110021003100410051006100710081009100: ; string '1000100110021003100410051006100710081009100 '
                                                ; used by INIT
        db '1000100110021003100410051006100710081009100 '
        db 0x00
str_2000200120022003200420052006200720082009200: ; string '2000200120022003200420052006200720082009200 '
                                                ; used by INIT
        db '2000200120022003200420052006200720082009200 '
        db 0x00
str_VlinvppVpk:                                 ; string 'vlinvpp vpk '; used by INIT
        db 'vlinvpp vpk ', 0x00
str_HlinhppHpk:                                 ; string 'hlinhpp hpk '; used by INIT
        db 'hlinhpp hpk ', 0x00
str_Visp:                                       ; string 'visp'; used by INIT
        db 'visp', 0x00
str_Homp:                                       ; string 'homp'; used by INIT
        db 'homp', 0x00
str_Lin1lin2lin3lin4pp1Pp2Pk1:                  ; string 'lin1lin2lin3lin4PP1 PP2 PK1 PK2 '; used by INIT
        db 'lin1lin2lin3lin4PP1 PP2 PK1 PK2 '
        db 0x00, 0x09, 0x00, 0xB1, 0x00, 0x1C, 0x00, 0xBD
        db 0x00
ReplayGadgetRects:                              ; replay gadget rectangles; used by INIT
        db 0x92, 0x02, 0x21, 0x00, 0xB1, 0x00
        db 0x34, 0x00, 0xBD, 0x00, 0x98, 0x02, 0x39, 0x00, 0xB1, 0x00
        db 0x4C, 0x00, 0xBD, 0x00
ReplayGadgetRect2:                              ; replay gadget rectangle 2; used by INIT
        db 0x9E, 0x02, 0x51, 0x00, 0xB1, 0x00
        db 0x64, 0x00, 0xBD, 0x00, 0xA4, 0x02, 0x69, 0x00, 0xB1, 0x00
        db 0x7C, 0x00, 0xBD, 0x00, 0xAA, 0x02, 0x81, 0x00, 0xB1, 0x00, 0x94, 0x00, 0xBD, 0x00, 0xB0, 0x02
        db 0xA7, 0x00, 0xB1, 0x00, 0xD3, 0x00, 0xBD, 0x00
ReplayGadgetRect3:                              ; replay gadget rectangle 3; used by INIT
        db 0xB9, 0x02, 0xD8, 0x00, 0xB1, 0x00, 0x04, 0x01
        db 0xBD, 0x00, 0xC6, 0x02, 0x09, 0x01, 0xB1, 0x00
        db 0x35, 0x01, 0xBD, 0x00, 0xD2, 0x02, 0xD8, 0x00
        db 0xB1, 0x00, 0x04, 0x01, 0xBD, 0x00
ReplayPointerRect:                              ; replay pointer rectangle; used by INIT
        db 0xC6, 0x02, 'Pointer'
        db 0x00
str_BothTeams:                                  ; string 'Both Teams'; used by INIT
        db 'Both Teams', 0x00
str_NeitherTeams:                               ; string 'Neither Teams'; used by INIT
        db 'Neither Teams', 0x00
str_SaveTo_2:                                   ; string 'Save To'; used by INIT
        db 'Save To', 0x00
str_HilightsReel_2:                             ; string 'Hilights Reel'; used by INIT
        db 'Hilights Reel', 0x00
str_SaveTo:                                     ; string 'Save To'; used by INIT
        db 'Save To', 0x00
str_HilightsReel:                               ; string 'Hilights Reel'; used by INIT
        db 'Hilights Reel', 0x00
        db 'k1', 0x00, 0x5C, 0x00
str_Hi_2:                                       ; string '.HI'; used by INIT
        db '.HI', 0x00
        db 0x66, 0x31, 0x00
str_CanNotOpenSFile:                            ; string 'Can not open `%s' file\n'; used by INIT
        db 'Can not open `%s', 0x27
        db ' file'
        db 0x0A, 0x00, 'f3', 0x00
        db 'f4', 0x00, 0x00
str_ErrorLoadingGame:                           ; string 'Error Loading Game\n'; used by INIT
        db 'Error Loading Game'
        db 0x0A, 0x00
str_ErrorSavingGame:                            ; string 'Error Saving Game\n'; used by INIT
        db 'Error Saving Game'
        db 0x0A, 0x00, 0x00
str_Gadget5:                                    ; string 'gadget5'; used by INIT
        db 'gadget5', 0x00
str_Gad1:                                       ; string 'gad1'; used by INIT
        db 'gad1', 0x00
str_Gg02d_2:                                    ; string 'gg%02d'; used by INIT
        db 'gg%02d', 0x00
str_Gg02d:                                      ; string 'gg%02d'; used by INIT
        db 'gg%02d', 0x00
str_HilightFnt:                                 ; string 'HILIGHT.FNT'; used by INIT
        db 'HILIGHT.FNT', 0x00, 0x00
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
        db 0xDA, 0x56
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
gsumqcount:                                     ; number of queued game summary records; used by AI
        db 0x00, 0x00
defercount:                                     ; number of queued deferred calls; used by AI
        db 0x00, 0x00
        db 'B3', 0x00, 'B4', 0x00
        db 'B5', 0x00, 'B6', 0x00
        db 'B7', 0x00, 'B8', 0x00
        db 'B3', 0x00, 'B4', 0x00
        db 'B3', 0x00, 'B6', 0x00
        db 'B4', 0x00, 'B3', 0x00
        db 'B4', 0x00, 'B5', 0x00
        db 'B6', 0x00, 'B8', 0x00
str_SDSSS:                                      ; string '%s#%d %s %s%s'; used by AI
        db '%s#%d %s %s%s', 0x00
str_SDCSS:                                      ; string '%s#%d %c. %s%s'; used by AI
        db '%s#%d %c. %s%s', 0x00
str_SDSS_2:                                     ; string '%s#%d %s%s'; used by AI
        db '%s#%d %s%s', 0x00
str_SDS:                                        ; string '%s#%d %s'; used by AI
        db '%s#%d %s', 0x00
str_SDSS:                                       ; string '%s#%d %s%s'; used by AI
        db '%s#%d %s%s', 0x00
str_02d02dS:                                    ; string '%02d:%02d %s'; used by AI
        db '%02d:%02d %s', 0x00
str_Sh:                                         ; string ' SH'; used by AI
        db ' SH', 0x00
str_Pp:                                         ; string ' PP'; used by AI
        db ' PP', 0x00, 0x00
        db 0x25, 0x73, 0x00
str_D_2:                                        ; string ' (%d)'; used by AI
        db ' (%d)', 0x00, 0x00
str_Unassisted:                                 ; string 'Unassisted'; used by AI
        db 'Unassisted', 0x00
str_Assists:                                    ; string 'Assists:'; used by AI
        db 'Assists:', 0x00, 0x00, 0x00, 0x00, 0x00
str_02d02dSPenalty:                             ; string '%02d:%02d %s Penalty'; used by AI
        db '%02d:%02d %s Penalty'
        db 0x00, 0x00, 0x00
str_GameMisconduct:                             ; string 'game misconduct'; used by AI
        db 'game misconduct'
        db 0x00
str_DMinutes:                                   ; string '%d minutes'; used by AI
        db '%d minutes', 0x00
str_02d02dSInjury:                              ; string '%02d:%02d %s Injury'; used by AI
        db '%02d:%02d %s Injury'
        db 0x00, 0x00, 0x00
str_GoneForTheGame:                             ; string 'gone for the game'; used by AI
        db 'gone for the game'
        db 0x00
str_GoneFor1Period:                             ; string 'gone for 1 period'; used by AI
        db 'gone for 1 period', 0x00
str_Roughing_2:                                 ; string 'roughing'
        db 'roughing', 0x00
str_Empty_22:                                   ; empty string
        db 0x00
str_Charging_2:                                 ; string 'charging'
        db 'charging', 0x00
str_Slashing_2:                                 ; string 'slashing'
        db 'slashing', 0x00
str_Roughing_3:                                 ; string 'roughing'
        db 'roug'
GoalieSaveSides:                                ; save side bytes of puckgoalie, indexed by the hit direction;
                                                ; used by AI
        db 'hing', 0x00
str_Xcheck:                                     ; string 'xcheck'
        db 'xcheck', 0x00
str_Hooking_2:                                  ; string 'hooking'
        db 'hooking', 0x00
str_Tripping_2:                                 ; string 'tripping'
        db 'tripping', 0x00
str_Interfer:                                   ; string 'interfer'
        db 'interfer', 0x00
str_Holding_2:                                  ; string 'holding'
        db 'holding', 0x00
str_Abuse:                                      ; string 'abuse'
        db 'abuse', 0x00
str_Behind:                                     ; string 'behind'
        db 'behind', 0x00, 0x00
PenaltyNamePtrs:                                ; penalty name pointers of the game summary events
                                                ; (PostPenaltyEvent); used by AI
        dw str_Roughing_2
        dw str_Empty_22
        dw str_Charging_2
        dw str_Slashing_2
        dw str_Roughing_3
        dw str_Xcheck
        dw str_Hooking_2
        dw str_Tripping_2
        dw str_Interfer
        dw str_Holding_2
        dw str_Abuse
        dw str_Behind
doplayeracc_ftab:                               ; acceleration factor table of doplayeracc; used by AI
        db 0x00, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x00, 0x00, 0xF0, 0xFF, 0xF0, 0xFF, 0xF0, 0xFF
AccelFactors:                                   ; acceleration factor table of playeracc; used by AI
        db 0x00, 0x90
AccelFactors2:                                  ; second acceleration table of playeracc; used by AI
        db 0x5F, 0x01, 0xD9, 0x5F, 0x80, 0x01, 0x90, 0x54
        db 0xA2, 0x01, 0xF9, 0x63, 0xC5, 0x01
        db 0x00, 0x84, 0xE9, 0x01, 0xA9, 0xAA, 0x0E, 0x02, 0x10, 0xCE, 0x34, 0x02, 0x69, 0xE4, 0x5B, 0x02
        db 0x00, 0xE4, 0x83, 0x02, 0x39, 0xC3, 0xAC, 0x02, 0x90, 0x78, 0xD6, 0x02, 0x99, 0xFA, 0x00, 0x03
        db 0x00, 0x40, 0x2C, 0x03, 0x89, 0x3F, 0x58, 0x03
        db 0x10, 0xF0, 0x84, 0x03, 0x89, 0x48, 0xB2, 0x03
asswingo_dedata:                                ; winger attack spots: x; used by AI
        db 0x64
        db 0x00
asswingo_dedata_xrand:                          ; winger attack spots: random x range; used by AI
        db 0x14, 0x00
asswingo_dedata_y:                              ; winger attack spots: y; used by AI
        db 0xC0, 0xFF
asswingo_dedata_yrand:                          ; winger attack spots: random y range; used by AI
        db 0x0A, 0x00
        db 0x78, 0x00, 0x14, 0x00
        db 0x32, 0x00, 0x05, 0x00
        db 0x37, 0x00, 0x32, 0x00, 0xBE, 0x00, 0x14, 0x00
        db 0x64, 0x00, 0x1E, 0x00, 0xDA, 0x00, 0x14, 0x00
asscentero_dedata:                              ; centre attack spots: x; used by AI
        db 0x00, 0x00
asscentero_dedata_xrand:                        ; centre attack spots: random x range; used by AI
        db 0x46, 0x00
asscentero_dedata_y:                            ; centre attack spots: y; used by AI
        db 0xC0, 0xFF
asscentero_dedata_yrand:                        ; centre attack spots: random y range; used by AI
        db 0x0A, 0x00, 0x00, 0x00
        db 0x46, 0x00, 0x34, 0x00, 0x0A, 0x00, 0x00, 0x00
        db 0x3C, 0x00, 0xA0, 0x00, 0x1E, 0x00, 0x00, 0x00
        db 0x64, 0x00, 0x9B, 0x00, 0x14, 0x00
assscore_dancecnt:                              ; goal celebration counter; used by AI
        db 0x00, 0x00
goaliesave_saveanim_m2:                         ; goalie save animations, entry before the table; used by AI
        db 0xB1, 0x00, 0xC9, 0x00
        db 0x31, 0x01, 0x59, 0x01, 0x01, 0x01, 0x19, 0x01
asspuckc_postab2:                               ; puck carrier target spots, x; used by AI
        db 0x92, 0xFF
asspuckc_postab2_y:                             ; puck carrier target spots, y; used by AI
        db 0xEC, 0xFF, 0x6E, 0x00, 0xEC, 0xFF, 0x7E
        db 0xFF, 0x24, 0x00, 0x1E, 0x00
        db 0x24, 0x00, 0x82, 0x00
        db 0x24, 0x00, 0xE2, 0xFF, 0x24, 0x00, 0xCE, 0xFF, 0xCC, 0x00, 0x00, 0x00, 0xBC, 0x00, 0x1E, 0x00
        db 0xC6, 0x00, 0x28, 0x00, 0xC6
Endfaceoff_ftab_m1:                             ; faceoff stance table, entry before it; used by AI
        db 0x00, 0x00, 0x08, 0x10, 0x00, 0x08, 0x10
refsigdir:                                      ; referee signal directions; used by AI
        db 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x04, 0x00
        db 0xFF, 0xFF, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00
        db 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
refsigspa_m2:                                   ; referee signal animations, entry before the table; used by
                                                ; AI
        db 0x00, 0x00
        times 16 db 0
        db 0x63, 0x0C, 0x00, 0x00
        db 0x73, 0x0C, 0x8B, 0x0C, 0x63, 0x0C, 0x9B, 0x0C, 0xAB, 0x0C, 0xBB, 0x0C, 0xCB, 0x0C, 0xD9, 0x0C
        db 0xE7, 0x0C, 0xF5, 0x0C, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
nethit:                                         ; net hit table; used by AI
        db 0x00, 0x00
CheckAnims:                                     ; check animation table of checkcheck; used by AI
        db 0xC1, 0x05
        db 0xD9, 0x05, 0x09, 0x06, 0x09, 0x06, 0x09, 0x06, 0xF1, 0x05, 0xF1, 0x05, 0xC1, 0x05, 0x55, 0x9D, 0x67, 0x55
        db 0x9D, 0x67, 0x55, 0x9D, 0x67, 0x55, 0x9D, 0x67, 0x55, 0x9D, 0x67, 0x55, 0x9D, 0x67, 0x55, 0x9D, 0x67, 0x55
        db 0x9D, 'gUUUUUUUUUUUUUUUUU'
        db 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55
        db 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0x55, 0xF0, 0xD5, 0x75, 0xD5, 0x75, 0xD5, 0x75, 0xD5, 0x75, 0xD5, 0x75
        db 0xD5, 0x75, 0xD5, 0x75, 0xD5, 'uUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU'
        db 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 'WWWW'
        db 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5, 0xA5
ShotSpeeds:                                     ; shot speed table of doshot; used by AI
        db 0x00, 0x00
shotsetz:                                       ; shot height table; used by AI
        db 0x0C, 0x00, 0x10, 0x00, 0x0C, 0x00, 0x10, 0x00
        db 0x06, 0x00, 0x10, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF, 0x00, 0x00, 0xF0, 0xFF, 0x06, 0x00, 0xF0, 0xFF, 0x0C, 0x00
        db 0x00, 0x00, 0x06, 0x00, 0x00, 0x00
LineChoiceKeys:                                 ; line choice table of lineinput; used by AI
        db 0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00
        db 0x05, 0x00
        db 0x04, 0x00, 0x07, 0x00, 0x06, 0x00
lchoicetab_m1:                                  ; entry before lchoicetab; used by AI
        db 0x00, 0x01, 0x02, 0x03, 0x01, 0x02, 0x03, 0x00
        db 0x02, 0x03
        db 0x00, 0x01, 0x03, 0x00, 0x01, 0x02, 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, 0x02, 0x03, 0x00, 0x01
        db 0x02, 0x03, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05
        db 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x05, 0x04, 0xFF, 0xFF, 0x04, 0x05
        db 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x06, 0x07, 0xFF, 0xFF, 0x06, 0x07, 0xFF, 0xFF, 0x06, 0x07
        db 0xFF, 0xFF, 0x06, 0x07, 0xFF, 0xFF, 0x06, 0x07, 0xFF, 0xFF, 0x06, 0x07, 0xFF, 0xFF, 0x06, 0x07
        db 0xFF, 0xFF, 0x07, 0x06, 0xFF, 0xFF
OneTimerDirs:                                   ; direction offsets of assonetimer; used by AI
        db 0xFA
OneTimerDirs2:                                  ; direction table of assonetimer; used by AI
        db 0x0C, 0x0E, 0x0C, 0x13, 0xFE, 0x0F, 0xF9, 0x06
        db 0xF5
        db 0xF6, 0xF4, 0xEF, 0xF9, 0xEE, 0x04
teamrocktune:                                   ; rock tune per team; used by AI, INIT
        db 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01
        db 0x01, 0x00
        db 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
RockTuneIds:                                    ; rock tune numbers; used by AI
        db 0xFE, 0x01, 0x3A, 0x02
introstandanims_m2:                             ; intro stand animations, entry before the table; used by AI
        db 0x67, 0x0D, 0x7B, 0x0D, 0x57, 0x0D, 0x89, 0x0D
        db 0x45, 0x0D
StarPoints:                                     ; points per stat for the three stars; used by AI
        db 0x0A, 0x0F
        db 0x14, 0x00
StarPoints2:                                    ; second points table for the three stars; used by AI
        db 0x0A, 0x14, 0x28, 0x00
assstarskate_path:                              ; three stars skate path, x; used by AI
        db 0x89, 0xFF
assstarskate_path_y:                            ; three stars skate path, y; used by AI
        db 0xC9, 0xFF, 0xCA, 0xFF, 0xD3, 0xFF, 0xC5, 0xFF
        db 0x0F, 0x00, 0x84, 0xFF, 0x0A, 0x00, 0xA2, 0xFF, 0x14, 0x00, 0xD4, 0xFF, 0x05, 0x00, 0xC0, 0xFF
        db 0xCE, 0xFF, 0x8E, 0xFF, 0xEC, 0xFF, 0x31, 0x73, 0x74, 0x00
        db '2nd', 0x00
        db '3rd', 0x00
str_EaSports:                                   ; string 'EA Sports'; used by AI
        db 'EA Sports', 0x00
str_SStar_2:                                    ; string '%s Star'; used by AI
        db '%s Star', 0x00, 0x00
str_SStar:                                      ; string '%s Star'; used by AI
        db '%s Star', 0x00, 0x00
StarNamePtrs:                                   ; '1st/2nd/3rd' star text pointers (assthreestars); used by AI
        db 0xC6, 0x5B, 0xCA, 0x5B, 0xCE, 0x5B
playsuspended:                                  ; 1 while play is suspended (highlight, no replay); used by AI
        db 0x00
        db 0x00
HotList_m1:                                     ; byte before the hot spot table; used by AI
        db 0xFC
HotList:                                        ; stick blade hot spot x/y bytes per frame (GetHot); used by
                                                ; AI
        db 0xEC, 0xFF, 0xE8, 0xFE, 0xE4, 0xFF, 0xE7, 0x01, 0xE7, 0x10, 0xF8, 0x17, 0xF6, 0x13, 0xF8, 0x15
        db 0xF5, 0x0E, 0xFC, 0x11, 0x03, 0x15, 0x03, 0x15, 0x02, 0x15, 0x03, 0x12, 0x03, 0x0E, 0x06, 0x11
        db 0x0E, 0x11, 0x0A, 0x13, 0x0B, 0x11, 0x0A, 0x02, 0x10, 0x01, 0x14, 0x04, 0x0F, 0x04, 0x14, 0x00
        db 0x14, 0xF8, 0x06, 0xF3, 0x0B, 0xF2, 0x0C, 0xEF, 0x0E, 0xF1, 0x0C, 0xF3, 0x03, 0xEC, 0x01, 0xF2
        db 0x03, 0xF1, 0x02, 0xF3, 0x03, 0xF2, 0xF8, 0xF1, 0xF9, 0xF2, 0xF9, 0xF1, 0xF8, 0xF3, 0xF7, 0x01
        db 0xF3, 0x01, 0xF5, 0x01, 0xF4, 0x00, 0xF4, 0x01, 0xF3, 0x0B, 0xFA, 0x0C, 0xF9, 0x0C, 0xFA, 0x0A
        db 0xFA, 0x0A, 0xF9, 0x11, 0x00, 0x16, 0x02, 0x16, 0x01, 0x14, 0x01, 0x12, 0x01, 0x0B, 0x0C, 0x0D
        db 0x0E, 0x0C, 0x0B, 0x0A, 0x0C, 0x0B, 0x0B, 0x00, 0x0D, 0x01, 0x0F, 0x01, 0x0C, 0x00, 0x0E, 0x02
        db 0x0C, 0xF7, 0x0B, 0xF7, 0x0A, 0xF6, 0x09, 0xF3, 0x0A, 0xF5, 0x0A, 0xF0, 0x00, 0xEF, 0xFF, 0xEF
        db 0x00, 0xF0, 0x02, 0xF2, 0x02, 0xF7, 0xF6, 0xF4, 0xF8, 0xF6, 0xFA, 0xF7, 0xFB, 0xF6, 0xFA, 0xFA
        db 0xFB, 0x0E, 0xFB, 0x14, 0x00, 0x12, 0x06, 0x09, 0x06, 0xF0, 0x0B, 0xE8, 0xFC, 0xEA, 0xF9, 0x01
        db 0xF9, 0x0F, 0xF7, 0x16, 0x03, 0x0E, 0x05, 0xFE, 0x07, 0xEA, 0x06, 0xEA, 0xFA, 0xF2, 0xF2, 0xFA
        db 0xF4, 0xFA, 0xF4, 0xFA, 0xF4, 0xFA, 0xF4, 0xFA, 0xF4, 0xFA, 0xF4, 0x0E, 0xF4, 0x0E, 0xF4, 0x0E
        db 0xF4, 0x0E, 0xF4, 0x0E, 0xF4, 0x0E, 0xF4, 0x13, 0x02, 0x13, 0x02, 0x13, 0x02, 0x13, 0x02, 0x13
        db 0x02, 0x13, 0x02, 0x0F, 0x07, 0x0F, 0x07, 0x0F, 0x07, 0x0F, 0x07, 0x0F, 0x07, 0x0F, 0x07, 0x08
        db 0x0E, 0x08, 0x0E, 0x08, 0x0E, 0x06, 0x0B, 0x08, 0x0E, 0x08, 0x0E, 0xF6, 0x0C, 0xF6, 0x0C, 0xF6
        db 0x0C, 0xF6, 0x0C, 0xF6, 0x0C, 0xF6, 0x0C, 0xF0, 0x07
        dw str_AdamsBar
        dw str_AdamsBar
        dw str_AdamsBar
        dw str_AdamsBar
        dw str_AdamsBar
        db 0xEE, 0xFC, 0xEE, 0xFC, 0xEE, 0xFC, 0xEE, 0xFC, 0xEE, 0xFC, 0xEE, 0xFC, 0xFF, 0xED, 0xFF, 0xED
        db 0x10, 0xF9, 0x10, 0xF9, 0x11, 0xFF, 0x11, 0xFF, 0x0B, 0x08, 0x0B, 0x08, 0xFA, 0x08, 0xFA, 0x08
        db 0xF1, 0x07, 0xF1, 0x07, 0xF4, 0xFB, 0xF4, 0xFB, 0xF5, 0xF7, 0xF5, 0xF7, 0xFE, 0xED, 0xF6, 0xF0
        db 0xFD, 0xF0, 0x11, 0xEE, 0x0E, 0xF5, 0x06, 0xF6, 0x18, 0x01, 0x18, 0xFC, 0x12, 0xFD, 0x0B, 0x08
        db 0x0F, 0x03, 0x0E, 0x04, 0xFC, 0x09, 0x02, 0x09, 0x08, 0x08, 0xEE, 0x04, 0xF2, 0x06, 0xF8, 0x06
        db 0xE7, 0xFE, 0xEE, 0x01, 0xF1, 0xFF, 0xEB, 0xF3, 0xF1, 0xF7, 0xF2, 0xFE, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0xF6, 0x02, 0xF3
        db 0x13, 0xFD, 0x10, 0xFA, 0x12, 0x08, 0x12, 0x07, 0x09, 0x0A, 0x0A, 0x0C, 0xF2, 0x09, 0xF8, 0x0B
        db 0xEE, 0x01, 0xF1, 0x04, 0xF3, 0xFD, 0xEE, 0xFE, 0xF8, 0xF9, 0xF7, 0xF7, 0xFE, 0xFB, 0x06, 0xFB
        db 0x07, 0xFE, 0x04, 0x07, 0xFF, 0x09, 0xF7, 0x03, 0xF4, 0x01, 0xF6, 0xFB, 0xEF, 0xFF, 0xF6, 0xFB
        db 0x19, 0x02, 0x14, 0x06, 0x09, 0x0D, 0xF8, 0x0C, 0xE9, 0x04, 0xF0, 0x07, 0xEF, 0xFC, 0xF7, 0xF8
        db 0x1B, 0xFB, 0x1D, 0x02, 0x0E, 0x0E, 0x02, 0x10, 0xEA, 0x05, 0xE9, 0x04, 0xF1, 0xF6, 0x13, 0xF6
        db 0x1E, 0xF8, 0x1D, 0x08, 0x08, 0x0B, 0xE4, 0x07, 0xE3, 0x02, 0xE8, 0xF8, 0xEB, 0x00, 0xF1, 0xFF
        db 0x0F, 0xF8, 0x0C, 0xFE, 0x11, 0x00, 0x02, 0x08, 0xF4, 0x07, 0xF2, 0x05, 0xF8, 0xE8, 0xF6, 0xE4
        db 0x13, 0xF9, 0x17, 0xF3, 0x1A, 0x06, 0x21, 0x06, 0x14, 0x0D, 0x20, 0x0D, 0x09, 0x10, 0x07, 0x1A
        db 0xEF, 0x09, 0xE6, 0x11, 0xE2, 0x04, 0xDC, 0x01, 0xE9, 0xF8, 0xE8, 0xF5, 0x00, 0x00, 0x0C, 0x07
        db 0x02, 0x1F, 0x0F, 0xF3, 0x00, 0x00, 0x05, 0x03, 0xEC, 0x1A, 0x0C, 0x02, 0x0C, 0x04, 0x02, 0x03
        db 0xE0, 0xFB, 0x06, 0x08, 0xFD, 0x04, 0xF9, 0x05, 0xE6, 0xED, 0xFF, 0x08, 0x00, 0x00, 0x00, 0x00
        db 0x01, 0xE7, 0xF2, 0x05, 0xF1, 0xFD, 0xFE, 0x05, 0x12, 0xE8, 0xF0, 0xF9, 0xEE, 0xFE, 0xFB, 0x03
        db 0x1F, 0xFF, 0x03, 0xFC, 0xF7, 0xF8, 0x03, 0x03, 0x1C, 0x14, 0x02, 0xF9, 0x02, 0xEC, 0xF6, 0xEB
        db 0xF5, 0xE8, 0xF8, 0xEE, 0x0C, 0xF5, 0x11, 0xEA, 0x12, 0xE1, 0x12, 0xF1, 0x19, 0x04, 0x22, 0x02
        db 0x29, 0xF9, 0x1D, 0xFD, 0x11, 0x08, 0x1B, 0x11, 0x1F, 0x10, 0x13, 0x12, 0xFD, 0x0E, 0xFE, 0x21
        db 0x04, 0x24, 0x02, 0x1F, 0xE7, 0x0A, 0xE5, 0x15, 0xE4, 0x15, 0xEB, 0x15, 0xE0, 0x02, 0xD9, 0x04
        db 0xD7, 0x05, 0xE5, 0x06, 0xF1, 0xFC, 0xE4, 0xF4, 0xE4, 0xF1, 0xEC, 0xF0, 0x0C, 0xFC, 0x10, 0xFF
        db 0x0D, 0x07, 0x08, 0x07, 0xF2, 0x04, 0xEC, 0x00, 0xEF, 0xFF, 0xF9, 0xF5, 0x0D, 0xF9, 0x13, 0xFF
        db 0x19, 0x05, 0x0D, 0x0B, 0xF9, 0x0B, 0xEC, 0x07, 0xED, 0x00, 0xF1, 0xFA, 0x00, 0x00, 0x06, 0xFE
        db 0x07, 0x00, 0x07, 0x00, 0x07, 0x00, 0x07, 0x00, 0x07, 0xFF, 0x07, 0xFF, 0x07, 0xFF, 0x07, 0xFF
        db 0x07, 0xFF, 0x07, 0xFF, 0x07, 0xFF, 0x07, 0xFF, 0x07, 0xFF, 0xF7, 0xFE, 0xEA, 0xFF, 0xE0, 0xFC
        db 0xE8, 0xFC, 0xE8, 0xFC, 0xE8, 0xFC, 0xE8, 0xFC, 0xE8, 0xFC, 0xE8, 0xFC, 0xEC, 0x06, 0xFD, 0xFE
        db 0xFF, 0x00, 0xE3, 0x02, 0x02, 0x05, 0x02, 0x02, 0xFD, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xF9, 0x07, 0xFC, 0xFA, 0xF8, 0x01, 0xFB
        db 0x0B, 0x01, 0x01, 0xF7, 0x08, 0xFF, 0x08, 0x02, 0x0A, 0xF7, 0x08, 0x02, 0x01, 0x05, 0x03, 0x03
        db 0x01, 0x04, 0xFC, 0x01, 0x04, 0x05, 0xFD, 0x06, 0xF8, 0xFE, 0xF9, 0x08, 0xF8, 0x03, 0xF6, 0x00
        db 0xF6, 0x02, 0xF8, 0xFC, 0xFB, 0xFA, 0xF5, 0xFB, 0x02, 0xF6, 0x03, 0xF5, 0x0D, 0xF7, 0x0D, 0xF7
        db 0x17, 0xFF, 0x17, 0xFF, 0x0F, 0x05, 0x10, 0x04, 0x04, 0x0D, 0x04, 0x0E, 0xF0, 0x0A, 0xF0, 0x0A
        db 0xEA, 0x03, 0xE9, 0xFE, 0xEE, 0xF8, 0xED, 0xF7, 0x04, 0xFC, 0x07, 0xFF, 0xFF, 0xFD, 0x0A, 0x00
        db 0x05, 0x05, 0xFE, 0x08, 0x01, 0x05, 0xF6, 0xFF, 0xF4, 0x03, 0xF2, 0xFC, 0xFA, 0xFC, 0x07, 0xF8
        db 0xFF, 0xF8, 0xF6, 0xFB, 0xFF, 0xF9, 0xFF, 0xFB, 0x0B, 0x04, 0x0B, 0xF8, 0xFD, 0x06, 0x0C, 0x03
        db 0x02, 0x07, 0x02, 0x05, 0xF5, 0xFF, 0xF2, 0x00, 0x07, 0xF2, 0xF6, 0xFD, 0x13, 0xF6, 0x03, 0xF3
        db 0x15, 0xFE, 0x04, 0xF3, 0x08, 0x08, 0x0D, 0xFC, 0xF7, 0x05, 0x09, 0x02, 0xED, 0x05, 0x04, 0x05
        db 0xEE, 0xF8, 0xF8, 0x06, 0xF4, 0xF1, 0xF3, 0xFD, 0xFE, 0xF8, 0x01, 0xF9, 0x07, 0xFD, 0x02, 0xFB
        db 0x11, 0xFD, 0x0F, 0xFE, 0x11, 0xFD, 0x10, 0xFF, 0x0C, 0x00, 0x0E, 0x02, 0x13, 0x05, 0x11, 0x01
        db 0x07, 0x04, 0x05, 0x06, 0x09, 0x09, 0x0D, 0x0C, 0x02, 0x0A, 0xFF, 0x0B, 0xF5, 0x0F, 0xF8, 0x0B
        db 0xF7, 0x08, 0xFD, 0x08, 0xEF, 0x05, 0xF1, 0x07, 0xF5, 0xFE, 0xF5, 0x04, 0xEF, 0x03, 0xF0, 0x00
        db 0xF6, 0xF9, 0xF7, 0xFD, 0xF3, 0xF8, 0xF2, 0xF9, 0xFF, 0xE2, 0xFF, 0xE6, 0x12, 0xEB, 0x10, 0xEA
        db 0x22, 0xFB, 0x19, 0xF9, 0x1A, 0x06, 0x13, 0x07, 0x00, 0x1D, 0x01, 0x16, 0xEC, 0x0D, 0xED, 0x0A
        db 0xE2, 0x04, 0xE8, 0xFF, 0xEB, 0xEB, 0xEE, 0xEB, 0xEC, 0xFF, 0xEC, 0xFF, 0x14, 0x00, 0x14, 0x00
        db 0xFF, 0xF7, 0xFF, 0xF8, 0x11, 0xFE, 0x11, 0xFD, 0x0C, 0x00, 0x0D, 0xFF, 0x0E, 0x04, 0x08, 0x04
        db 0x03, 0x05, 0x03, 0x07, 0xED, 0x09, 0xF1, 0x0A, 0xEF, 0x02, 0xEF, 0x01, 0xF5, 0xFC, 0xF5, 0xFC
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF9, 0xFB, 0x06, 0xFD
        db 0xFF, 0xFD, 0x07, 0x00, 0x05, 0xFD, 0x05, 0x02, 0x06, 0xFE, 0xFD, 0x02, 0x07, 0x01, 0xFC, 0x00
        db 0x01, 0x04, 0xFA, 0xFE, 0xF9, 0x01, 0xFB, 0xFE, 0xF9, 0xFF, 0xFC, 0xFB, 0x00, 0xDD, 0x04, 0xE6
        db 0x0F, 0xFA, 0x08, 0xF5, 0x0F, 0xFF, 0x11, 0xF7, 0x0F, 0x04, 0x10, 0xFB, 0xFF, 0x08, 0x05, 0x03
        db 0xF3, 0x05, 0xEF, 0x01, 0xED, 0x01, 0xEB, 0xF6, 0xEE, 0xF4, 0xF4, 0xEF, 0x00, 0xF6, 0x00, 0xF7
        db 0x00, 0xF5, 0x08, 0xF7, 0x08, 0xF7, 0x08, 0xF8, 0x0C, 0xFE, 0x0D, 0xFD, 0x0D, 0xFD, 0x0A, 0x06
        db 0x0A, 0x06, 0x0A, 0x05, 0x00, 0x0B, 0x01, 0x0A, 0x01, 0x0A, 0xF5, 0x06, 0xF5, 0x06, 0xF5, 0x06
        db 0xF4, 0xFF, 0xF4, 0xFF, 0xEC, 0xFF, 0xF4, 0xF8, 0xF2, 0xF9, 0xF3, 0xF8, 0x03, 0xFE, 0x03, 0xFE
        db 0x03, 0xFE, 0x06, 0xFE, 0xFD, 0x03, 0xFD, 0x03, 0xFD, 0x03, 0xFD, 0x03, 0x02, 0x03, 0x02, 0x03
        db 0x02, 0x03, 0x02, 0x03, 0x02, 0x02, 0x01, 0x02, 0xE6, 0x0E, 0xE6, 0x0E, 0xE6, 0x0E, 0xE6, 0x0E
        db 0xE6, 0x0E, 0xE6, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
Setplass_alist:                                 ; first assignment per position (Setplass); used by AI
        db 0x0E, 0x02, 0x02, 0x03, 0x05, 0x03, 0x05, 0x00
RestoreTeamTable:                               ; word table of restoreteams; used by AI
        db 0xF9, 0xFF, 0xFC, 0xFF, 0xFA, 0xFF, 0xFE, 0xFF
        db 0xFE, 0xFF, 0xFE, 0xFF, 0xFE, 0xFF, 0xFE, 0xFF
        db 0xFE, 0xFF
PlListOffsets:                                  ; offsets of the player lists (SetPlList); used by AI
        db 0x00, 0x00, 0x03, 0x00, 0x14, 0x00
        db 0x25, 0x00, 0x57, 0x00
        db 0x3E, 0x00, 0x70, 0x00
PlListSlots:                                    ; slot bytes of SetPlList (-1 end); used by AI
        db 0x24, 0x25, 0xFF, 0x0C, 0x0E, 0x10, 0x0C, 0x15, 0x1A, 0x1E, 0x22, 0x0D, 0x0F, 0x11, 0x0D, 0x16
        db 0x1B, 0x1F, 0x23, 0xFF, 0x0D, 0x0F, 0x11, 0x0D, 0x16, 0x1B, 0x1F, 0x23, 0x0C, 0x0E, 0x10, 0x0C
        db 0x15, 0x1A, 0x1E, 0x22, 0xFF, 0x00, 0x03, 0x06, 0x09, 0x12, 0x17, 0x1C, 0x20, 0x02, 0x05, 0x08
        db 0x0B, 0x14, 0x19, 0x01, 0x04, 0x07, 0x0A, 0x13, 0x18, 0x1D, 0x21, 0x26, 0x27, 0xFF, 0x02, 0x05
        db 0x08, 0x0B, 0x14, 0x19, 0x26, 0x27, 0x00, 0x03, 0x06, 0x09, 0x12, 0x17, 0x1C, 0x20, 0x01, 0x04
        db 0x07, 0x0A, 0x13, 0x18, 0x1D, 0x21, 0xFF, 0x01, 0x04, 0x07, 0x0A, 0x13, 0x18, 0x1D, 0x21, 0x00
        db 0x03, 0x06, 0x09, 0x12, 0x17, 0x1C, 0x20, 0x02, 0x05, 0x08, 0x0B, 0x14, 0x19, 0x26, 0x27, 0xFF, 0x26, 0x27
        db 0x01, 0x04, 0x07, 0x0A, 0x13, 0x18, 0x1D, 0x21, 0x00, 0x03, 0x06, 0x09, 0x12, 0x17, 0x1C, 0x20
        db 0x02, 0x05, 0x08, 0x0B, 0x14, 0x19, 0xFF, 0x00
RinkOverlayFrames3:                             ; frames of the period marks (DrawRinkOverlays); used by AI
        db 0xC4, 0x02, 0xC5, 0x02, 0xC6, 0x02, 0xC9, 0x02
        db 0xCA, 0x02, 0xC9, 0x02, 0xC6, 0x02, 0xC5, 0x02
        db 0x64, 0x01
RinkObjectXOffsets:                             ; x offsets of the rink objects (DrawRinkObjects); used by AI
        db 0xA5, 0x01, 0x2D, 0x01
dressbystatus:                                  ; dressed flag per roster status; used by AI
        db 0x00, 0x00
        db 0x02, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00
lineslotgroupstart:                             ; first preference group per line slot (PickForLineSlot); used
                                                ; by AI
        db 0x00, 0x03, 0x06, 0x09, 0xFF, 0x01, 0x04, 0x07
        db 0x0A, 0xFF, 0x02, 0x05, 0x08, 0x0B, 0xFF, 0x0C, 0x0E, 0x10, 0xFF, 0x0D, 0x0F, 0x11, 0xFF, 0x12
        db 0x17, 0x00, 0x03, 0x06, 0x09, 0xFF, 0x13, 0x18, 0x01, 0x04, 0x07, 0x0A, 0xFF, 0x14, 0x19, 0x02
        db 0x05, 0x08, 0x0B, 0xFF, 0x15, 0x1A, 0x0C, 0x0E, 0x10, 0xFF, 0x16, 0x1B, 0x0D, 0x0F, 0x11, 0xFF
        db 0x1C, 0x20, 0x00, 0x03, 0x06, 0x09, 0xFF, 0x1D, 0x21, 0x01, 0x04, 0x07, 0x0A, 0xFF, 0x1E, 0x22
        db 0x0C, 0x0E, 0x10, 0xFF, 0x1F, 0x23, 0x0D, 0x0F
        db 0x11, 0xFF
lineslotgroups:                                 ; position preference groups of the line slots; used by AI
        db 0x00, 0x05, 0x0A, 0x00, 0x05, 0x0A
        db 0x00, 0x05, 0x0A, 0x00, 0x05, 0x0A, 0x0F, 0x13, 0x0F, 0x13, 0x0F, 0x13, 0x17, 0x1E, 0x25, 0x2C, 0x32
        db 0x17, 0x1E, '%,28?FL8?FL'
penshotstart:                                   ; penalty shot starting; used by AI
        db 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xFF, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x05, 0x00, 0xFF, 0xFF, 0x04, 0x00, 0x06
        db 0x00, 0xFF, 0xFF, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06
        db 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0xFF, 0xFF, 0x06, 0x00, 0x03, 0x00, 0x02, 0x00
str_ServedByD:                                  ; string 'served by #%d'; used by AI
        db 'served by #%d', 0x00
str_AMvi:                                       ; string 'A MVI'; used by MOVIE
        db 'A MVI', 0x00
str_Databuffer:                                 ; string 'DATABUFFER'; used by MOVIE
        db 'DATABUFFER', 0x00, 0x00
WipeDirX:                                       ; x step per wipe direction (FadeWipe); used by FADES2
        db 0x01, 0x00, 0xFF, 0xFF
        db 0x01, 0x00, 0xFF, 0xFF
WipeDirY:                                       ; y step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x00, 0x01, 0x00
WipeDirX2:                                      ; second x step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0x01, 0x00
        db 0xFF, 0xFF, 0x01, 0x00
WipeDirY2:                                      ; second y step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x00, 0x01, 0x00
PlaneBandPattern:                               ; band pattern of FadePlaneBands; used by FADES3
        db 0x0B, 0x05, 0x08, 0x02
        db 0x0A, 0x04, 0x07, 0x01, 0x09, 0x03, 0x06, 0x00, 0x01, 0x03, 0x06, 0x00, 0x05, 0x07, 0x02, 0x04
        db 0x07, 0x05, 0x02, 0x08, 0x03, 0x01, 0x06, 0x04, 0x01, 0x03, 0x00, 0x02, 0x03, 0x01, 0x04, 0x02
FadeInSteps:                                    ; fade step table (FadePaletteIn); used by FADES4
        db 0x01
FadeInStep:                                     ; current fade-in step; used by FADES4
        db 0x0F
FadeInSteps2:                                   ; second fade-in step table; used by FADES4
        db 0x01, 0xFF
FadeInCount:                                    ; fade-in step count; used by FADES4
        db 0x11, 0xFF
BlockSweepDX:                                   ; x direction per sweep pattern (FadeBlockSweep); used by
                                                ; FADES5
        db 0x02, 0x00, 0x00, 0x00
BlockSweepDY:                                   ; y direction per sweep pattern; used by FADES5
        db 0xFF, 0x01, 0x01, 0x00
BlockSweepOrder:                                ; sweep order bytes; used by FADES5
        db 0xFF, 0x03
        db 0x06, 0x00
EndMark:                                        ; long stored by SetEndMark. WaitEnd spins until EndPtr passes
                                                ; it; used by SetEndMark, WaitEnd, EndReached
        db 0x00, 0x00, 0x00, 0x00
CritOld:                                        ; INT 24h vector saved by HookCrit and restored by
                                                ; CritRestore; used by HookCrit, CritRestore
        dw 0x0000
CritSpare1:                                     ; word before CritRoutine; not used in the EXE (overlays may
                                                ; use it)
        dw 0x0000
CritRoutine:                                    ; far routine CritHandler calls. HookCrit stores the caller's
                                                ; pointer here; used by CritHandler, HookCrit
        dw 0x0000
CritSpare2:                                     ; word after CritRoutine; not used in the EXE (overlays may
                                                ; use it)
        dw 0x0000
str_SFileError:                                 ; string '%s FILE ERROR'; not used in the EXE (overlays may
                                                ; use it)
        db '%s FILE ERROR', 0x00
PathBuf:                                        ; findPath returns this buffer. The directory is copied here
                                                ; and the DTA name is appended; used by FileHeadMsg
        times 100 db 0
PathCut:                                        ; offset in PathBuf just past the last colon or backslash;
                                                ; used by FileHeadMsg
        db 0x00, 0x00
FindDta:                                        ; DOS DTA for FindPath and FindNextPath. Set with INT 21h
                                                ; AH=1Ah; used by FileHeadMsg, FindNextPath
        times 128 db 0
BlockSpare1:                                    ; word before BlockEnd; not used in the EXE (overlays may use
                                                ; it)
        dw 0x0000
BlockEnd:                                       ; paragraph past the block AllocBytes allocated; used by
                                                ; MakeChain, AllocBytes
        dw 0x0000
BlockSpare2:                                    ; word before BlockSeg; not used in the EXE (overlays may use
                                                ; it)
        dw 0x0000
BlockSeg:                                       ; segment AllocBytes got from INT 21h AH=48h; used by
                                                ; MakeChain, AllocBytes
        dw 0x0000
SavedCs:                                        ; CS stored by AllocBytes. Not read in the bytes disassembled
                                                ; so far; used by AllocBytes
        dw 0x0000
SavedDs:                                        ; DS stored by AllocBytes. Not read in the bytes disassembled
                                                ; so far; used by AllocBytes
        dw 0x0000
SavedSp:                                        ; exitSavedSp uses this as SP when it is nonzero. What stores
                                                ; it is not in this chunk. See HANDOFF; used by ExitSavedSp,
                                                ; AllocBytes
        dw 0x0000
PaletteMode:                                    ; DAC write mode (2 for the slow path); used by SetPaletteFar
        dw 0x0000
MouseActive:                                    ; mouse driver found; used by MouseOpen, WaitTimerRetrace
        db 0x00, 0x00, 0x01, 0x00
WantText:                                       ; resetText runs when this word is nonzero, then clears it;
                                                ; used by ResetText, InitGraphics
        dw 0x0000
MouseShowFn:                                    ; far routine: show the cursor; used by AskYesNoBox, PauseBox,
                                                ; MouseOpen
        db 0x34, 0x07
MouseShowFnSeg:                                 ; segment of MouseShowFn; used by MouseOpen
        dw 0x03A3
MouseHideFn:                                    ; far routine: hide the cursor; used by AskYesNoBox, PauseBox,
                                                ; MouseOpen
        db 0x34, 0x07
MouseHideFnSeg:                                 ; segment of MouseHideFn; used by MouseOpen
        dw 0x03A3
MouseReadFn:                                    ; far routine: read the mouse; used by AskYesNoBox, PauseBox,
                                                ; MouseOpen
        db 0x34, 0x07
MouseReadFnSeg:                                 ; segment of MouseReadFn; used by MouseOpen
        dw 0x03A3
MousePosFn:                                     ; far routine: mouse position; used by AskYesNoBox,
                                                ; MouseToPad, MouseOpen
        db 0x34, 0x07
MousePosFnSeg:                                  ; segment of MousePosFn; used by MouseOpen
        db 0xA3, 0x03
        dw RetZero, 0x03A3
MouseOn:                                        ; 0 means no mouse. 1 and 2 select which INT 33h function
                                                ; numbers are used; used by MouseRatio, MouseMove, MouseRead
                                                ; ...
        dw 0x0000
MouseX:                                         ; last X stored by MouseMove and MouseSample, before the
                                                ; shift; used by MouseToPad, MouseMove, MouseSample
        dw 0x0000
MouseY:                                         ; last Y stored by MouseMove and MouseSample, before the
                                                ; shift; used by MouseToPad, MouseMove, MouseSample
        dw 0x0000
MouseBtn:                                       ; last button word from INT 33h AX=3; used by MouseToPad,
                                                ; MouseSample
        db 0x00, 0x00
MouseXShift:                                    ; shift applied to X between screen units and mouse units. 1
                                                ; when the width is at most 320; used by MouseMove, MouseRead,
                                                ; MouseXRange ...
        dw 0x0000
MouseYShift:                                    ; shift applied to Y; used by MouseMove, MouseRead,
                                                ; MouseYRange ...
        dw 0x0000
MouseLevel:                                     ; show count. MouseShow calls AX=1 when it becomes positive.
                                                ; MouseHide calls AX=2 at 0; used by MouseShow, MouseHide
        db 0x00, 0x00
MouseRatioShift:                                ; shift applied to the mickey counts passed to INT 33h AX=0Fh;
                                                ; used by MouseRatio, MouseOpen
        db 0x00, 0x00, 'locateemmshape - ', 0x27, '%-4.4s', 0x27, ' SHAPE NOT FOUND'
        db 0x0D, 0x0A, 0x00
str_Locateshape44sShapeNot:                     ; string 'locateshape - '%-4.4s' SHAPE NOT FOUND\r\n';
                                                ; FindFarMsg passes it to FatalError
        db 'locateshape - ', 0x27, '%-4.4s', 0x27, ' SHAPE NOT FOUND'
        db 0x0D, 0x0A, 0x00
str_Locatesound44sSoundNot:                     ; string 'locatesound - '%-4.4s' SOUND NOT FOUND\r\n';
                                                ; FindFarAlt passes it to FatalError
        db 'locatesound - ', 0x27, '%-4.4s', 0x27, ' SOUND NOT FOUND'
        db 0x0D, 0x0A, 0x00
str_ThisProgramRequiresAn80286:                 ; string 'This program requires an 80286\r'; used by InitHeap
        db 'This program requires an 80286'
        db 0x0D, 0x00
FmtSave:                                        ; four words FormatCall pops: far return offset, far return
                                                ; segment, then two arguments. See HANDOFF; used by FormatCall
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
FmtBuf:                                         ; pointer passed to _sprintf as its first argument from
                                                ; FormatCall; used by FormatCall
        times 2130 db 0
str_RowSpaceCorrupted:                          ; string 'Row space corrupted\n'; not referenced in the root
                                                ; code
        db 'Row space corrupted'
        db 0x0A, 0x00, 0x00, '%s FILE ERROR'
        db 0x0D, 0x00, 0x00
FontPtr:                                        ; current 1-bpp font; used by NumberEntryDialog, ListHitTest,
                                                ; DrawListRow ...
        dw 0x0000
CharSeg:                                        ; segment of the character table. TextWidth reads it.
                                                ; UseCharSeg stores it; used by TextWidthAll, SetCharPtr,
                                                ; SetCharPtr2 ...
        dw 0x39AD
FontBits:                                       ; bit masks for the font; used by DrawTextAt
        db 0x11, 0x22, 0x44, 0x88, 0x04, 0x00, 0x02, 0x00
        db 'Copyright (C) 1989-1992 Electronic Arts.  All rights reserved.'
OldInt8Off:                                     ; saved INT 8 vector, offset; used by HookInt8, UnhookInt8
        dw 0x0000
OldInt8Seg:                                     ; saved INT 8 vector, segment; used by HookInt8, UnhookInt8
        dw 0x0000
TickHookOff:                                    ; routine the INT 8 handler calls, offset; used by HookInt8
        dw 0x0000
TickHookSeg:                                    ; routine the INT 8 handler calls, segment; used by HookInt8
        dw 0x0000
CallCount:                                      ; dword incremented once per callback walk; used by
                                                ; Int8Handler, ReadCallCount, CallCountDiff ...
        db 0x00, 0x00, 0x00, 0x00
TickTotal:                                      ; dword bumped when TickFrac carries; used by ReadEndPtr,
                                                ; SetEndMark, WaitEnd ...
        dw 0x0000
TickCountAll:                                   ; every INT 8 tick; used by Int8Handler
        dw 0x0000
TickFrac:                                       ; tickStep is added here. Carry bumps TickTotal and the BIOS
                                                ; tick; used by HookInt8, Int8Handler
        dw 0x0000
TickStep:                                       ; addend for TickFrac. HookInt8 stores 2E9Bh; used by
                                                ; HookInt8, Int8Handler
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
TickGate:                                       ; int8Handler decrements this and skips the callbacks unless
                                                ; it lands on 0; used by HookInt8, Int8Handler
        dw 0x0001
TickSkip:                                       ; byte. Nonzero makes Int8Handler skip the callbacks; used by
                                                ; CalibrateStick, AskYesNoBox, PauseBox ...
        dw 0x0000
SlotTab:                                        ; eight far-pointer pairs. AllocSlot fills one, FreeSlot
                                                ; removes one, Int8Handler calls the ones in use; used by
                                                ; HookInt8, FreeSlot, CountSlots ...
        dw 0x0000
TickSkipCount:                                  ; ticks skipped; used by HookInt8
        times 38 db 0
str_NoRoomLeftInTimer:                          ; string 'NO ROOM LEFT IN TIMER IRQ TASK LIST\r'; not
                                                ; referenced in the root code
        db 'NO ROOM LEFT IN TIMER IRQ TASK LIST'
        db 0x0D, 0x00, 0x00
Int8Stack:                                      ; the INT 8 handler's private stack, filled with 0FBh
        db 0xFB, 0x55
        times 256 db 0xFB
Int8StackTop:                                   ; top of Int8Stack; Int8Handler loads SP with it
        dw 0x6F04, 0x45C9
Int8Sp:                                         ; SS:SP saved around the callback walk on Int8Stack; used by
                                                ; Int8Handler
        db 0x00, 0x00
Int8Ss:                                         ; SS saved with Int8Sp; used by Int8Handler
        db 0x00, 0x00, 0x00, 0x00
SkipEoi:                                        ; nonzero skips the EOI write to port 20h; used by Int8Handler
        db 0x00, 0x00
CalibTargetX:                                   ; x of each calibration target; used by CalibrateStick
        db 0x86, 0x00, 0x86, 0x00, 0xAE, 0x00, 0xAE, 0x00, 0xAE, 0x00, 0x86, 0x00
        db 0x5E, 0x00, 0x5E, 0x00
        db 0x5E, 0x00
CalibTargetY:                                   ; y of each calibration target; used by CalibrateStick
        db 0x67, 0x00, 0x49, 0x00
        db 0x49, 0x00, 0x67, 0x00, 0x85, 0x00, 0x85, 0x00, 0x85, 0x00
        db 0x67, 0x00, 0x49, 0x00
str_CalibrateYourJoystickByUsing:               ; string 'Calibrate your joystick by using it'; not referenced
                                                ; in the root code
        db 'Calibrate your joystick by using it'
        db 0x00
str_ToMoveTheJoystickPosition:                  ; string 'to move the joystick position indicator'; not
                                                ; referenced in the root code
        db 'to move the joystick position indicator'
        db 0x00
str_BelowToAllSquares:                          ; string 'below, to all squares'; not referenced in the root
                                                ; code
        db 'below, to all squares'
        db 0x00
str_PressJoystickButtonWhenComplete:            ; string 'Press joystick button when complete'; not referenced
                                                ; in the root code
        db 'Press joystick button when complete'
        db 0x00
str_PressAnyKeyToIgnore:                        ; string 'Press any key to ignore joystick'; not referenced in
                                                ; the root code
        db 'Press any key to ignore joystick'
        db 0x00
str_LeftJoystick:                               ; string 'LEFT JOYSTICK'; used by CalibrateLeftStick
        db 'LEFT JOYSTICK', 0x00
str_RightJoystick:                              ; string 'RIGHT JOYSTICK'; used by CalibrateRightStick
        db 'RIGHT JOYSTICK', 0x00
JoyX:                                           ; axis count from game port bit 0; used by PollJoy, JoyScaleX
        db 0x00, 0x00
JoyY:                                           ; axis count from game port bit 1; used by PollJoy, JoyScaleY
        db 0x00, 0x00
JoyLastBtn:                                     ; button bits PollJoy last reported (game port bits 4 and 5,
                                                ; inverted)
        db 0x00
JoyBtn:                                         ; game port bits 4 and 5, sampled before the axis timing; used
                                                ; by PollJoy
        db 0x00
JoyBits:                                        ; pollJoy result. Direction bits and the button bits are ORed
                                                ; in; used by PollJoy
        db 0x00
JoyXMin:                                        ; low X limit (50h at start); PollJoy lowers it to JoyXMinSeen
                                                ; once JoyXSettle runs out
        db 0x50, 0x00
JoyXMinSeen:                                    ; lowest X reading while JoyXSettle counts down
        db 0x00, 0x00
JoyXMax:                                        ; high X limit (0 at start), raised to JoyXMaxSeen
        db 0x00, 0x00
JoyXMaxSeen:                                    ; highest X reading while JoyXSettle counts down (4E20h when
                                                ; reset)
        db 0x00, 0x00
JoyXSettle:                                     ; readings left (14h) before a new X limit is taken
        db 0x14, 0x00
JoyXLeftEdge:                                   ; X reading below which the stick counts as left
        db 0x00, 0x00
JoyXRightEdge:                                  ; X reading above which the stick counts as right
        db 0x00, 0x00
JoyYMin:                                        ; low Y limit (50h at start)
        db 0x50, 0x00
JoyYMinSeen:                                    ; lowest Y reading while JoyYSettle counts down
        db 0x00, 0x00
JoyYMax:                                        ; high Y limit (0 at start)
        db 0x00, 0x00
JoyYMaxSeen:                                    ; highest Y reading while JoyYSettle counts down
        db 0x00, 0x00
JoyYSettle:                                     ; readings left (14h) before a new Y limit is taken
        db 0x14, 0x00
JoyYUpEdge:                                     ; Y reading below which the stick counts as up
        db 0x00, 0x00
JoyYDownEdge:                                   ; Y reading above which the stick counts as down
        db 0x00, 0x00
JoyXScale:                                      ; 4000h / (JoyXMax - JoyXMin); used by JoyScaleX
        db 0x00, 0x00
JoyYScale:                                      ; 4000h / (JoyYMax - JoyYMin); used by JoyScaleY
        db 0x00, 0x00
JoyNibbleTable:                                 ; joystick nibble to direction; used by JoyNibble
        db 0x00, 0x01, 0x05, 0x00, 0x03, 0x02, 0x04, 0x03, 0x07, 0x08, 0x06, 0x07, 0x00, 0x01, 0x05, 0x00
        db 0x00
Stick2X:                                        ; third timed axis in PollSticks; used by PollSticks,
                                                ; ScaleStick2X
        dw 0x0000
Stick2Y:                                        ; fourth timed axis in PollSticks; used by PollSticks,
                                                ; ScaleStick2Y
        dw 0x0000
Stick2XMin:                                     ; joystick 2 x minimum; used by PollSticks, InitStick2,
                                                ; ScaleStick2X
        dw 0x0050
Stick2XMax:                                     ; joystick 2 x maximum; used by PollSticks, InitStick2
        dw 0x0000
Stick2XLast:                                    ; joystick 2 x last reading; used by PollSticks
        dw 0x0000
Stick2XSettle:                                  ; joystick 2 x settle count (8); used by PollSticks
        dw 0x0000
Stick2XLow:                                     ; joystick 2 x low threshold; used by PollSticks
        dw 0x0000
Stick2XHigh:                                    ; joystick 2 x high threshold; used by PollSticks
        dw 0x0000
Stick2YMin:                                     ; joystick 2 y minimum; used by PollSticks, InitStick2,
                                                ; ScaleStick2Y
        dw 0x0050
Stick2YMax:                                     ; joystick 2 y maximum; used by PollSticks, InitStick2
        dw 0x0000
Stick2YLast:                                    ; joystick 2 y last reading; used by PollSticks
        dw 0x0000
Stick2YSettle:                                  ; joystick 2 y settle count (8); used by PollSticks
        dw 0x0000
Stick2YLow:                                     ; joystick 2 y low threshold; used by PollSticks
        dw 0x0000
Stick2YHigh:                                    ; joystick 2 y high threshold; used by PollSticks
        dw 0x0000
Stick2XScale:                                   ; joystick 2 x scale; used by PollSticks, ScaleStick2X
        dw 0x0000
Stick2YScale:                                   ; joystick 2 y scale; used by PollSticks, ScaleStick2Y
        dw 0x0000
Stick1X:                                        ; first timed axis in PollSticks; used by PollSticks,
                                                ; ScaleStick1X
        dw 0x0000
Stick1Y:                                        ; second timed axis in PollSticks; used by PollSticks,
                                                ; ScaleStick1Y
        dw 0x0000
StickRaw:                                       ; port 201h sample taken before the axes are timed; used by
                                                ; PollSticks
        db 0x00
Stick1Bits:                                     ; direction and button bits for the first pair. Returned in
                                                ; AL; used by PollSticks
        db 0x00
Stick2Bits:                                     ; direction and button bits for the second pair. Returned in
                                                ; AH; used by PollSticks
        db 0x00, 0x00
Stick1XMin:                                     ; joystick 1 x minimum; used by PollSticks, InitStick1,
                                                ; ScaleStick1X
        dw 0x0050
Stick1XMax:                                     ; joystick 1 x maximum; used by PollSticks, InitStick1
        dw 0x0000
Stick1XLast:                                    ; joystick 1 x last reading; used by PollSticks
        dw 0x0000
Stick1XSettle:                                  ; joystick 1 x settle count (8); used by PollSticks
        dw 0x0000
Stick1XLow:                                     ; joystick 1 x low threshold; used by PollSticks
        dw 0x0000
Stick1XHigh:                                    ; joystick 1 x high threshold; used by PollSticks
        dw 0x0000
Stick1YMin:                                     ; joystick 1 y minimum; used by PollSticks, InitStick1,
                                                ; ScaleStick1Y
        dw 0x0050
Stick1YMax:                                     ; joystick 1 y maximum; used by PollSticks, InitStick1
        dw 0x0000
Stick1YLast:                                    ; joystick 1 y last reading; used by PollSticks
        dw 0x0000
Stick1YSettle:                                  ; joystick 1 y settle count (8); used by PollSticks
        dw 0x0000
Stick1YLow:                                     ; joystick 1 y low threshold; used by PollSticks
        dw 0x0000
Stick1YHigh:                                    ; joystick 1 y high threshold; used by PollSticks
        dw 0x0000
Stick1XScale:                                   ; joystick 1 x scale; used by PollSticks, ScaleStick1X
        dw 0x0000
Stick1YScale:                                   ; joystick 1 y scale; used by PollSticks, ScaleStick1Y
        dw 0x0000
StickDirTable:                                  ; stick bits to direction; used by PollSticks
        db 0x00, 0x03, 0x0C, 0x0F, 0x00, 0x01, 0x05, 0x00, 0x03, 0x02, 0x04, 0x03, 0x07, 0x08, 0x06, 0x07
        db 0x00, 0x01, 0x05, 0x00
KeyBuf:                                         ; key queue. KbdIrq writes it and KeyService reads it; used by
                                                ; KbdIrq, KeyService
        times 32 db 0
KeyHead:                                        ; write index of the key queue; used by KbdIrq, KeyService
        db 0x00, 0x00
KeyTail:                                        ; read index of the key queue; used by KbdIrq, KeyService
        db 0x00, 0x00
KeyMask:                                        ; mask applied to the key-queue index; used by KbdIrq,
                                                ; KeyService
        db 0x02, 0x00
KeyState:                                       ; one byte per scan code. Make sets it, break clears it; used
                                                ; by HookKbd, KbdIrq, KeyDown
        times 128 db 0
OldInt9Off:                                     ; saved INT 9 vector, offset; used by HookKbd, UnhookKbd
        dw 0x0000
OldInt9Seg:                                     ; saved INT 9 vector, segment; used by HookKbd, UnhookKbd
        dw 0x0000
OldInt16Off:                                    ; saved INT 16h vector, offset; used by HookKbd, UnhookKbd
        dw 0x0000
OldInt16Seg:                                    ; saved INT 16h vector, segment; used by HookKbd, UnhookKbd
        dw 0x0000
OldInt23Off:                                    ; saved INT 23h vector, offset; used by HookKbd, UnhookKbd
        dw 0x0000
OldInt23Seg:                                    ; saved INT 23h vector, segment; used by HookKbd, UnhookKbd
        db 0x00, 0x00
KeyMapNormal:                                   ; character for each scan code 0 to 5Ah with no shift key;
                                                ; used by the keyboard handler
        db 0x00, 0x1B, '1234567890-=', 0x08, 0x09, 'qwertyuiop[]', 0x0D, 0x00, 'asdfghjkl;', 0x27, 0x60, 0x00
        db '\zxcvbnm,./', 0x00, 0x2A, 0x00, 0x20, 0x00, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4
        db 0x00, 0x00, 0xC7, 0xC8, 0xC9, 0x2D, 0xCB, 0xCC, 0xCD, 0x2B, 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0x00
        db 0x00, 0x00, 0x87, 0x88, 0x00, 0x00
KeyMapShift:                                    ; character for each scan code with a shift key held
        db 0x00, 0x1B, '!@#$%^&*()_+', 0x08, 0x8F, 'QWERTYUIOP{}', 0x0D, 0x00, 'ASDFGHJKL:"~', 0x00
        db '|ZXCVBNM<>?', 0x00, 0x00, 0x00, 0x20, 0x00, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD
        db 0x00, 0x00, 0xC7, 0xC8, 0xC9, 0x2D, 0xCB, 0xCC, 0xCD, 0x2B, 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0x00
        db 0x00, 0x00, 0x89, 0x8A, 0x00, 0x00
KeyMapCaps:                                     ; character for each scan code with the caps lock key held
        db 0x00, 0x1B, '1234567890-=', 0x08, 0x8F, 'QWERTYUIOP[]', 0x0D, 0x00, 'ASDFGHJKL;', 0x27, 0x60, 0x00
        db '\ZXCVBNM,./', 0x00, 0x00, 0x00, 0x20, 0x00, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD
        db 0x00, 0x00, 0xC7, 0xC8, 0xC9, 0x2D, 0xCB, 0xCC, 0xCD, 0x2B, 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0x00
        db 0x00, 0x00, 0x89, 0x8A, 0x00, 0x00
KeyMapCtrl:                                     ; character for each scan code with ctrl held (scan code 1
                                                ; also calls NullFar5)
        db 0x00, 0x1B, 0x21, 0x00, '#$%', 0x1E, '&*()', 0x1F, 0xB3, 0x7F, 0x09, 0x11, 0x17, 0x05, 0x12, 0x14
        db 0x19, 0x15, 0x09, 0x0F, 0x10, 0x1B, 0x1D, 0x0D, 0x00, 0x01, 0x13, 0x04, 0x06, 0x07, 0x08, 0x0A
        db 0x0B, 0x0C, ';,`', 0x00, 0x1C, 0x1A, 0x18, 0x03, 0x16, 0x02, 0x0E, 0xB2, '<>?', 0x00, 0x00, 0x00
        db 0x20, 0x00, 0xDE, 0xDF, 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0x00, 0x00, 0xC7, 0xC8
        db 0xC9, 0x2D, 0xCB, 0xCC, 0xCD, 0x2B, 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0x00, 0x00, 0x00, 0x8B, 0x8C
        db 0x00, 0x00
KeyMapAlt:                                      ; character for each scan code with alt held
        db 0x00, 0x1B, '!@#$%^&*()_+', 0x08, 0x8F, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x7B
        db 0x7D, 0x0D, 0x00, 0x9E, 0x9F, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, ':"~', 0x00, 0x7C, 0xAC
        db 0xAD, 0xAE, 0xAF, 0xB0, 0xB1, 0xB2, '<>?', 0x00, 0x00, 0x00, 0x20, 0x00, 0xF8, 0xF9, 0xFA, 0xFB
        db 0xFC, 0xFD, 0xFE, 0xFF, 0x80, 0x81, 0x00, 0x00, 0xC7, 0xC8, 0xC9, 0x2D, 0xCB, 0xCC, 0xCD, 0x2B
        db 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0x00, 0x00, 0x00, 0x8D, 0x8E, 0x00, 0x00, 0x00
KeyHook:                                        ; far pointer KeyJump jumps through. SetKeyHook stores it;
                                                ; used by KeyJump, SetKeyHook, GetKeyHook
        dw ReadKey, 0x03A3
KeyPtr:                                         ; near pointer HookKbd sets to KeyService and UnhookKbd sets
                                                ; to BiosKey; used by HookKbd, UnhookKbd, ReadKey ...
        dw 0x16D0
JoyOn:                                          ; bit 0 selects the timed read. Clear returns JoyBits without
                                                ; touching the port; used by CalibrateStick, PollJoy, InitJoy
                                                ; ...
        dw 0x0000
RemapTable:                                     ; 256-byte colour remap table; used by DrawRawTransRemapBody,
                                                ; DrawRleTransRemapHere, DrawRleFlipTransRemapBody ...
        db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
        db 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, ' !"#$%&', 0x27, '()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVW'
        db 'XYZ[', 0x5C, ']^_`abcdefghijklmnopqrstuvwxyz{|}~'
        db 0x7F, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E
        db 0x8F, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E
        db 0x9F, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE
        db 0xAF, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE
        db 0xBF, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE
        db 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE
        db 0xDF, 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE
        db 0xEF, 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE
        db 0xFF, 'MCGA WINDOW', 0x00
str_OutOfRowSpace:                              ; string 'Out of row space\n'; not used in the EXE (overlays
                                                ; may use it)
        db 'Out of row space'
        db 0x0A, 0x00
PutBlockMasks:                                  ; plane masks for PutBlock; used by PutBlockBody
        db 0x11, 0x22, 0x44, 0x88
DrawRawMasks:                                   ; plane masks for DrawRaw; used by DrawRawBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleMasks:                                   ; plane masks for DrawRle; used by DrawRleBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleFastMasks:                               ; plane masks for DrawRleFast; used by DrawRleFastHere
        db 0x11, 0x22, 0x44, 0x88
Text2Color:                                     ; drawText2 colour; used by DrawText2
        db 0x00, 0x00
DrawCharMasks:                                  ; plane masks for DrawChar; used by DrawChar
        db 0x11, 0x22, 0x44, 0x88
CopySrcPage:                                    ; copyPlane source page; used by CopyPlane
        db 0x00
CopyDstPage:                                    ; copyPlane destination page; used by CopyPlane
        db 0x00
CopyActive:                                     ; copyPlane in progress; used by CopyPlane, AllocCanvases
        db 0x00
CopyMask:                                       ; copyPlane plane mask; used by CopyPlane
        db 0x00
CopyCount:                                      ; copyPlane byte count; used by CopyPlane
        dw 0x0000
CopyOffset:                                     ; copyPlane offset; used by CopyPlane
        dw 0x0000
TextRow:                                        ; row used by ScrollMono and as the default cursor row.
                                                ; Clamped to 0..24; used by ScrollMono, ConPrint, SetTextRow
        db 0x00
ConKeep:                                        ; nonzero makes the writer save TextPos into TextMark; used by
                                                ; ConPrint, ConPrintAt, WriteHex ...
        db 0x00
TextMark:                                       ; textPos saved when ConKeep is set, restored at the end of
                                                ; the string; used by ConPrint, WriteHex, WriteChar
        dw 0x0F00
TextPos:                                        ; byte offset of the cursor in the monochrome buffer; used by
                                                ; ConPrint, ConPrintAt, WriteHex ...
        dw 0x0000
ConCursorX:                                     ; console cursor column; used by ConPrint, ConPrintAt
        dw 0x0000
ConCursorY:                                     ; console cursor row; used by ConPrint, ConPrintAt
        dw 0x0000
ConBuf:                                         ; buffer _sprintf fills before the monochrome writer walks it;
                                                ; used by ConPrint, ConPrintAt, WriteHexAt ...
        db 0x00, 0x00, 0x00
str_Empty_20:                                   ; empty string
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_Empty:                                      ; empty string
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
HexDigits:                                      ; string '0123456789ABCDEF'; ConHexByte indexes it
        db '0123456789ABCDEF', 0x00, 0xB0
TextAttr:                                       ; attribute byte paired with each character written to the
                                                ; monochrome buffer; used by ConPrint, SetTextAttr
        db 0x07, 0x00
CurPage:                                        ; page shown; used by AskYesNoBox, PauseBox, VgaPageFlip ...
        dw 0x0000
DrawPage:                                       ; page drawn on; used by UseCurrentPage, UseOtherPage,
                                                ; GetOtherPage
        dw 0x0000
CanvasCount:                                    ; canvases allocated; used by AllocCanvases
        db 0x00, 0x00, 0x00, 0x00
CanvasSeg:                                      ; current canvas: segment (A000h for the screen); used by
                                                ; FillRect, DrawTextAt, PutBlockBody ...
        db 0x00, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
CanvasRows:                                     ; current canvas: row address table; used by FillRect,
                                                ; DrawTextAt, PutBlockBody ...
        dw 0x0000
ClipLeftPlane:                                  ; clip left in plane units; used by SetClipRect,
                                                ; SetClipRectRegs, AllocCanvases ...
        dw 0x0000
ClipRightPlane:                                 ; clip right in plane units; used by SetClipRect,
                                                ; SetClipRectRegs, AllocCanvases ...
        dw 0x0050
ClipTopY:                                       ; clip top; used by LineClip, ClipTop, ClipLeft ...
        dw 0x0000
ClipBottomY:                                    ; clip bottom; used by LineClip, ClipBottom, ClipLeft ...
        dw 0x00C8
CanvasRowBytes:                                 ; current canvas: bytes per row; used by PutBlockBody,
                                                ; DrawRawBody, DrawRleBody ...
        db 0x50, 0x00, 0x00, 0x00
VenetianRowBytes:                               ; row length in bytes read by FadeVenetian; used by FADES1
        db 0x40, 0x01
ClipLeftX:                                      ; clip left; used by LineClip, ClipLeft, AfterBottom ...
        dw 0x0000
ClipRightX:                                     ; clip right; used by LineClip, ClipRight, AfterBottom ...
        db 0x40, 0x01, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x40, 0x01, 0x00, 0x00, 0xC8, 0x00
        db 0x40, 0x01, 0x00, 0x00
        db 0x40, 0x01, 0x00, 0x00
        db 0x40, 0x01
Deadline:                                       ; long that WaitKeyUntil compares with ReadCallCount.
                                                ; SetDeadline stores it; used by WaitKeyUntil, SetDeadline,
                                                ; WaitDeadline ...
        dw 0x0000
DeadlineHi:                                     ; deadline, high word; used by WaitKeyUntil, SetDeadline,
                                                ; WaitDeadline ...
        dw 0x0000
LastCount:                                      ; previous CallCount sample. CallCountStep subtracts it; used
                                                ; by CallCountStep
        db 0x00, 0x00, 0x00, 0x00
DrawRawTransMasks:                              ; plane masks for DrawRawTrans; used by DrawRawTransBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleFlipMasks:                               ; plane masks for DrawRleFlip; used by DrawRleFlipHere
        db 0x11, 0x22, 0x44, 0x88
DrawRleTransMasks:                              ; plane masks for DrawRleTrans; used by DrawRleTransBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleTransFastMasks:                          ; plane masks for DrawRleTransFast; used by
                                                ; DrawRleTransFastHere
        db 0x11, 0x22, 0x44, 0x88
DrawRawTransRemapMasks:                         ; plane masks for DrawRawTransRemap; used by
                                                ; DrawRawTransRemapBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleTransRemapMasks:                         ; plane masks for DrawRleTransRemap; used by
                                                ; DrawRleTransRemapHere
        db 0x11, 0x22, 0x44, 0x88
DrawRleFlipTransMasks:                          ; plane masks for DrawRleFlipTrans; used by
                                                ; DrawRleFlipTransBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleFlipTransRemapMasks:                     ; plane masks for DrawRleFlipTransRemap; used by
                                                ; DrawRleFlipTransRemapBody
        db 0x11, 0x22, 0x44, 0x88
DrawRleFlipRemapMasks:                          ; plane masks for DrawRleFlipRemap; used by
                                                ; DrawRleFlipRemapHere
        db 0x11, 0x22, 0x44, 0x88
DrawRleTransRemapFastMasks:                     ; plane masks for DrawRleTransRemapFast; used by
                                                ; DrawRleTransRemapFastBody
        db 0x11, 0x22, 0x44, 0x88, 'VGA WINDOW', 0x00
str_OutOfRowSpace_2:                            ; string 'Out of row space\n'; not used in the EXE (overlays
                                                ; may use it)
        db 'Out of row space'
        db 0x0A, 0x00, 0x00
PixelMasks:                                     ; plane mask per pixel column; used by PutPixelAt
        db 0x01, 0x02, 0x04, 0x08
PageTable:                                      ; page table, offsets; used by SaveTextState, LoadTextState,
                                                ; UseCurrentPage ...
        db 0x00, 0x00
PageTableSeg:                                   ; page table, segments; used by SaveTextState, LoadTextState,
                                                ; UseCurrentPage ...
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
OffscreenOff:                                   ; off-screen canvas, offset; used by UseOffscreenCanvas
        dw 0x0000
OffscreenSeg:                                   ; off-screen canvas, segment; used by UseOffscreenCanvas
        dw 0x0000
PageBase:                                       ; start address of page 0; used by SetStartPage, AllocCanvases
        dw 0x00C8
str_TooManyVideoPages:                          ; string 'TOO MANY VIDEO PAGES'; used by AllocCanvases
        db 'TOO MANY VIDEO PAGES'
        db 0x00
str_VideoWindowoutOfRowTable:                   ; string 'VIDEO WINDOWOUT OF ROW TABLE SPACE ALLOCATING VIDEO
                                                ; PAGES'; used by AllocCanvases
        db 'VIDEO WINDOWOUT OF ROW TABLE SPACE ALLOCATING VIDEO PAGES'
        db 0x00, 0x00
Pot1X:                                          ; game port pot 1 x count; used by ReadPots
        dw 0x0000
Pot1Y:                                          ; game port pot 1 y count; used by ReadPots
        dw 0x0000
Pot2X:                                          ; game port pot 2 x count; used by ReadPots
        dw 0x0000
Pot2Y:                                          ; game port pot 2 y count; used by ReadPots
        dw 0x0000
PotBits:                                        ; game port bits read last; used by ReadPots
        db 0x00, 0x00
PotButtons:                                     ; game port buttons; used by ReadPots
        db 0x0F, 0x00
str_SFileError_2:                               ; string '%s FILE ERROR\r'; not used in the EXE (overlays may
                                                ; use it)
        db '%s FILE ERROR', 0x0D, 0x00
str_HandleDFileError:                           ; string 'HANDLE %d FILE ERROR\r'; not referenced in the root
                                                ; code
        db 'HANDLE %d FILE ERROR'
        db 0x0D, 0x00
AltPath:                                        ; used by FileOpenAlt
        times 40 db 0
AltBuf:                                         ; word; used by FileOpenAlt
        dw 0x0000
AltCallPrev:                                    ; word before AltCall; not used in the EXE (overlays may use
                                                ; it)
        dw 0x0000
AltCall:                                        ; dword; used by FileOpenAlt
        dd 0x00000000
AltSize:                                        ; byte; used by FileOpenAlt
        db 0x00, 0x00, 0x00
Cpu286:                                         ; word; used by InitHeap, CpuProbe, GetPaletteFar
        dw 0x0000
Cpu386:                                         ; word; used by CopyFar, FillFarZero, CpuProbe
        dw 0x0000
Cpu486:                                         ; word; used by CpuProbe
        dw 0x0000
CpuPe:                                          ; word; used by CpuProbe
        dw 0x0000
BeforeDialogFn:                                 ; far routine called before a dialog; used by CalibrateStick,
                                                ; AskYesNoBox
        dw FarZero, 0x03A3
AfterDialogFn:                                  ; far routine called after a dialog; used by CalibrateStick,
                                                ; AskYesNoBox
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        dw FarZero, 0x03A3
        db 0x00, 0x00
ScaleColor:                                     ; drawScaled colour; used by PassFlag0, DrawScaledColor,
                                                ; DrawScaled
        db 0x00
ScaleColorHi:                                   ; drawScaled colour, high byte; used by DrawScaled
        db 0x00
ScaleMode:                                      ; drawScaled mode; used by PassFlag0, DrawScaledColor,
                                                ; DrawScaled
        db 0x00, 0x00
ScanFn:                                         ; dword; used by PassFlag0, FillFlag0, FillAddr0 ...
        dd 0x0FEF0000
LineFn:                                         ; dword; used by PassFlag0, FillFlag0, FillAddr0 ...
        dd 0x0FEF0000
RetraceWait:                                    ; retrace wait count from CalibrateRetrace; used by
                                                ; CalibrateRetrace, WaitTimerRetrace
        dw 0x0000
HoldWord:                                       ; word; used by ClearHold, CopyPlane, WaitRetraceEnd
        dw 0x0000
ScaleMasks:                                     ; plane masks for DrawScaled; used by DrawScaled
        db 0x0F, 0x0E, 0x0C, 0x08
ScaleMasks2:                                    ; second plane mask table for DrawScaled; used by DrawScaled
        db 0x0F
ScaleEdgeMasks:                                 ; edge masks for DrawScaled; used by DrawScaled
        db 0x01, 0x03, 0x07, 0x0F
ScaleRightMasks:                                ; right edge masks for DrawScaled; used by DrawScaled
        db 0x04, 0x03, 0x02, 0x01
ScaleLeftMasks:                                 ; left edge masks for DrawScaled; used by DrawScaled
        db 0x00, 0x08, 0x04, 0x0C, 0x02, 0x0A, 0x06, 0x0E, 0x01, 0x09, 0x05, 0x0D, 0x03, 0x0B, 0x07, 0x0F
        db 0x00
LineMasks:                                      ; plane masks for DrawLineClipped; used by DrawLineClipped
        db 0x11, 0x22, 0x44, 0x88
SpanMasks:                                      ; plane masks for FillSpanVga; used by FillSpanVga
        db 0x0F, 0x0E, 0x0C, 0x08
SpanLeftMasks:                                  ; left edge masks for FillSpanVga; used by FillSpanVga
        db 0x0F
SpanLeftMasks2:                                 ; left edge masks for FillSpanVga, second table; used by
                                                ; FillSpanVga
        db 0x01, 0x03, 0x07, 0x0F
SpanRightMasks:                                 ; right edge masks for FillSpanVga; used by FillSpanVga
        db 0x04, 0x03, 0x02, 0x01, 0x00
str_ExitToDosYN:                                ; string 'EXIT TO DOS (Y/N)'; used by AskExitToDos
        db 'EXIT TO DOS (Y/N)'
        db 0x00
str_PausePressAnyKeyTo:                         ; string 'PAUSE - PRESS ANY KEY TO RESUME'; used by
                                                ; ShowPausedBox
        db 'PAUSE - PRESS ANY KEY TO RESUME'
        db 0x00
str_Vgabuf:                                     ; string 'VGABUF'; not used in the EXE (overlays may use it)
        db 'VGABUF', 0x00, 0x00
AssetExtList:                                   ; extensions LoadAssetMode tries; used by LoadAssetMode
        db 0x02, 0x77
        dw str_Pns_2
        dw str_Nsh_2
        dw str_Qvs_2
        dw str_Pvs_2
        dw str_Vsh_2
        dw str_Qes_2
        dw str_Pes_2
        dw str_Esh_2
        dw str_Empty_23
IdentityRemap:                                  ; remap table that changes nothing; not referenced in the root
                                                ; code
        db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
        db '.QNS', 0x00
str_Pns_2:                                      ; string '.PNS'
        db '.PNS', 0x00
str_Nsh_2:                                      ; string '.NSH'
        db '.NSH', 0x00
str_Qvs_2:                                      ; string '.QVS'
        db '.QVS', 0x00
str_Pvs_2:                                      ; string '.PVS'
        db '.PVS', 0x00
str_Vsh_2:                                      ; string '.VSH'
        db '.VSH', 0x00
str_Qes_2:                                      ; string '.QES'
        db '.QES', 0x00
str_Pes_2:                                      ; string '.PES'
        db '.PES', 0x00
str_Esh_2:                                      ; string '.ESH'
        db '.ESH', 0x00
str_Empty_23:                                   ; empty string
        db 0x00
str_Qns:                                        ; string '.QNS'; used by LoadAssetMode
        db '.QNS', 0x00
str_Pns:                                        ; string '.PNS'; used by LoadAssetMode
        db '.PNS', 0x00
str_Qvs:                                        ; string '.QVS'; used by LoadAssetMode
        db '.QVS', 0x00
str_Pvs:                                        ; string '.PVS'; used by LoadAssetMode
        db '.PVS', 0x00
str_Qes:                                        ; string '.QES'; used by LoadAssetMode
        db '.QES', 0x00
str_Pes:                                        ; string '.PES'; used by LoadAssetMode
        db '.PES', 0x00
str_Esh:                                        ; string '.ESH'; used by LoadAssetMode
        db '.ESH', 0x00
str_Vsh:                                        ; string '.VSH'; used by LoadAssetMode
        db '.VSH', 0x00
str_Mga:                                        ; string '!MGA'; used by LoadAssetMode
        db '!MGA', 0x00
str_LoadshapeblockaNoMemoryForMcgatovga:        ; string 'loadshapeblocka -\tNO MEMORY FOR MCGATOVGA\n'; not
                                                ; referenced in the root code
        db 'loadshapeblocka -'
        db 0x09, 'NO MEMORY FOR MCGATOVGA'
        db 0x0A, 0x00
str_LoadshapeblockaNoMemoryForMcgatovga_2:      ; string 'loadshapeblocka - NO MEMORY FOR MCGATOVGA\n'; not
                                                ; referenced in the root code
        db 'loadshapeblocka - NO MEMORY FOR MCGATOVGA'
        db 0x0A, 0x00, 0x00
RectMasks:                                      ; plane masks for RectSpanPlanes; used by RectSpanPlanes
        db 0x0F, 0x0E, 0x0C, 0x08
RectLeftMasks:                                  ; left edge masks for RectSpanPlanes; used by RectSpanPlanes
        db 0x0F
RectLeftMasks2:                                 ; left edge masks for RectSpanPlanes, second table; used by
                                                ; RectSpanPlanes
        db 0x01, 0x03, 0x07, 0x0F
RectRightMasks:                                 ; right edge masks for RectSpanPlanes; used by RectSpanPlanes
        db 0x04, 0x03, 0x02, 0x01, 0x00
VidMode:                                        ; byte; used by SaveMode, RestoreMode
        db 0x00
VidEquip:                                       ; byte; used by SaveMode, RestoreMode
        db 0x00
VidCols:                                        ; word; used by SaveMode, RestoreMode
        dw 0x0000
VidRows:                                        ; byte; used by SaveMode, RestoreMode
        db 0x00, 0x00
DrawRawFastMasks:                               ; plane masks for DrawRawFast; used by DrawRawFastBody
        db 0x11, 0x22, 0x44, 0x88
DrawRawTransFastMasks:                          ; plane masks for DrawRawTransFast; used by
                                                ; DrawRawTransFastBody
        db 0x11, 0x22, 0x44, 0x88
AtanByte:                                       ; quarter-turn bytes. Atan2 indexes them by the ratio of the
                                                ; two absolute values; used by Atan2
        db 0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x06, 0x06, 0x07, 0x08, 0x08, 0x09, 0x0A
        db 0x0A, 0x0B, 0x0B, 0x0C, 0x0D, 0x0D, 0x0E, 0x0F, 0x0F, 0x10, 0x10, 0x11, 0x12, 0x12, 0x13, 0x14
        db 0x14, 0x15, 0x16, 0x16, 0x17, 0x17, 0x18, 0x19, 0x19, 0x1A, 0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1E
        db 0x1E, 0x1F, 0x1F, ' !!""#$$%&&', 0x27, 0x27, '())**+,,--../001123344556778899::;<<==>>??@AABBCCDDEEFFG'
        db 'GHHIJJKKLLMMNNOOPPQQRRSSTTTUUVVWWXXYYZZ[[[', 0x5C, 0x5C, ']]^^__```aabbcccddeefffgghhh'
        db 'iijjjkklllmmnnnoopppqqqrrssstttuuvvvwwwxxxyyyzzz{{{|||}}}~~~'
        db 0x7F, 0x7F, 0x7F, 0x80, 0x80, 0x00
LineStepLimit:                                  ; line step limit; used by LineClip
        dw 0x0032
LineStepTable:                                  ; line step table; used by LineClip
        db '6y6y6y8y<yByJyTy`yny~y'
        db 0x90, 0x79, 0xA4, 0x79, 0xBA, 0x79, 0xD2, 0x79, 0xEC, 0x79, 0x08, 'z&zFzhz'
        db 0x8C, 0x7A, 0xB2, 0x7A, 0xDA, 0x7A, 0x04, '{0{^{', 0x8E, 0x7B, 0xC0, 0x7B
        db 0xF4, '{*|b|', 0x9C, 0x7C, 0xD8, 0x7C, 0x16, 0x7D, 0x56, 0x7D, 0x98, 0x7D
        db 0xDC, '}"~j~', 0xB4, 0x7E, 0x00, 0x7F, 0x4E, 0x7F, 0x9E, 0x7F, 0xF0, 0x7F, 0x44
        db 0x80, 0x9A, 0x80, 0xF2, 0x80, 0x4C, 0x81, 0xA8, 0x81, 0x06, 0x82, 0x00, 0x80, 0x55, 0x55, 0xAA
        db 0xAA, 0x00, 0x40, 0x00, 0x80, 0x00, 0xC0, '33ff', 0x99, 0x99, 0xCC, 0xCC, 0xAA, 0x2A, 0x55, 0x55
        db 0x00, 0x80, 0xAA, 0xAA, 0x55, 0xD5, 0x92, 0x24, 0x24, 0x49, 0xB6, 0x6D, 0x49, 0x92, 0xDB, 0xB6, 0x6D
        db 0xDB, 0x00, 0x20, 0x00
        db 0x40, 0x00, 0x60, 0x00, 0x80, 0x00, 0xA0, 0x00, 0xC0, 0x00, 0xE0, 0x71, 0x1C, 0xE3, 0x38, 0x55, 0x55
        db 0xC7, 0x71, 0x38, 0x8E, 0xAA, 0xAA, 0x1C, 0xC7, 0x8E, 0xE3, 0x99, 0x19, 0x33, 0x33, 0xCC, 0x4C, 0x66, 0x66
        db 0x00, 0x80, 0x99, 0x99, 0x33, 0xB3, 0xCC, 0xCC, 0x66, 0xE6, 0x45, 0x17, 0x8B, 0x2E, 0xD1, 0x45
        db 0x17, 0x5D, 0x5D, 0x74, 0xA2, 0x8B, 0xE8, 0xA2, 0x2E, 0xBA, 0x74, 0xD1, 0xBA, 0xE8, 0x55, 0x15
        db 0xAA, 0x2A, 0x00, 0x40, 0x55, 0x55, 0xAA, 0x6A, 0x00, 0x80, 0x55, 0x95, 0xAA, 0xAA, 0x00, 0xC0, 0x55
        db 0xD5, 0xAA, 0xEA, 0xB1, 0x13, 0x62, 0x27, 0x13, 0x3B, 0xC4, 0x4E, 0x76, 0x62, 0x27, 0x76, 0xD8
        db 0x89, 0x89, 0x9D, 0x3B, 0xB1, 0xEC, 0xC4, 0x9D, 0xD8, 0x4E, 0xEC, 0x49, 0x12, 0x92, 0x24, 0xDB, '6$Im['
        db 0xB6, 0x6D, 0x00, 0x80, 0x49, 0x92, 0x92, 0xA4, 0xDB, 0xB6, 0x24, 0xC9, 0x6D, 0xDB, 0xB6, 0xED
        db 0x11, 0x11, '""33DDUUffww', 0x88, 0x88
        db 0x99, 0x99, 0xAA, 0xAA, 0xBB, 0xBB, 0xCC, 0xCC, 0xDD, 0xDD, 0xEE, 0xEE, 0x00, 0x10, 0x00
        db 0x20, 0x00, 0x30, 0x00
        db 0x40, 0x00, 0x50, 0x00
        db 0x60, 0x00, 0x70, 0x00, 0x80, 0x00, 0x90, 0x00, 0xA0, 0x00, 0xB0, 0x00, 0xC0, 0x00, 0xD0, 0x00
        db 0xE0, 0x00, 0xF0, 0x0F, 0x0F, 0x1E, 0x1E, '--<<KKZZiixx'
        db 0x87, 0x87, 0x96, 0x96, 0xA5, 0xA5, 0xB4, 0xB4, 0xC3, 0xC3, 0xD2, 0xD2, 0xE1, 0xE1, 0xF0, 0xF0, 0x38
        db 0x0E, 0x71, 0x1C, 0xAA, 0x2A, 0xE3, 0x38, 0x1C, 0x47, 0x55, 0x55, 0x8E, 0x63, 0xC7, 0x71, 0x00
        db 0x80, 0x38, 0x8E, 0x71, 0x9C, 0xAA, 0xAA, 0xE3, 0xB8, 0x1C, 0xC7, 0x55, 0xD5, 0x8E, 0xE3, 0xC7
        db 0xF1, 0x79, 0x0D, 0xF2, 0x1A, 0x6B, 0x28, 0xE5, 0x35, 0x5E, 0x43, 0xD7, 0x50, 0x50, 0x5E, 0xCA, 0x6B, 0x43, 0x79
        db 0xBC, 0x86, 0x35, 0x94, 0xAF, 0xA1, 0x28, 0xAF, 0xA1, 0xBC, 0x1A, 0xCA, 0x94, 0xD7, 0x0D, 0xE5
        db 0x86, 0xF2, 0xCC, 0x0C, 0x99, 0x19, 'f&33', 0x00
        db 0x40, 0xCC, 0x4C, 0x99, 'Yff3s', 0x00, 0x80, 0xCC, 0x8C, 0x99, 0x99, 0x66
        db 0xA6, 0x33, 0xB3, 0x00, 0xC0, 0xCC, 0xCC, 0x99, 0xD9, 0x66, 0xE6, 0x33, 0xF3, 0x30, 0x0C, 0x61
        db 0x18, 0x92, 0x24, 0xC3, 0x30, 0xF3, '<$IUU', 0x86, 0x61, 0xB6, 0x6D, 0xE7, 0x79
        db 0x18, 0x86, 0x49, 0x92, 0x79, 0x9E, 0xAA, 0xAA, 0xDB, 0xB6, 0x0C, 0xC3, 0x3C, 0xCF, 0x6D, 0xDB
        db 0x9E, 0xE7, 0xCF, 0xF3, 0xA2, 0x0B, 0x45, 0x17, 0xE8, 0x22, 0x8B, 0x2E, 0x2E, 0x3A, 0xD1, 0x45, 0x74, 0x51
        db 0x17, 0x5D, 0xBA, 0x68, 0x5D, 0x74, 0x00, 0x80, 0xA2, 0x8B, 0x45, 0x97, 0xE8, 0xA2, 0x8B, 0xAE, 0x2E
        db 0xBA, 0xD1, 0xC5, 0x74, 0xD1, 0x17, 0xDD, 0xBA, 0xE8, 0x5D, 0xF4, 0x21, 0x0B, 0x42, 0x16, 0x64, 0x21
        db 0x85, 0x2C, 0xA6, 0x37, 0xC8, 0x42, 0xE9, 0x4D, 0x0B, 'Y,dMooz'
        db 0x90, 0x85, 0xB2, 0x90, 0xD3, 0x9B, 0xF4, 0xA6, 0x16, 0xB2, 0x37, 0xBD, 0x59, 0xC8, 0x7A, 0xD3
        db 0x9B, 0xDE, 0xBD, 0xE9, 0xDE, 0xF4, 0xAA, 0x0A, 0x55, 0x15, 0x00
        db 0x20, 0xAA, 0x2A, 0x55, 0x35, 0x00
        db 0x40, 0xAA, 0x4A, 0x55, 0x55, 0x00
        db 0x60, 0xAA, 0x6A, 0x55, 0x75, 0x00, 0x80, 0xAA, 0x8A, 0x55, 0x95, 0x00, 0xA0, 0xAA, 0xAA, 0x55
        db 0xB5, 0x00, 0xC0, 0xAA, 0xCA, 0x55, 0xD5, 0x00, 0xE0, 0xAA, 0xEA, 0x55, 0xF5, 0x3D, 0x0A, 0x7A
        db 0x14, 0xB8, 0x1E, 0xF5, '(33p=', 0xAE, 0x47, 0xEB, 0x51, 0x28, 0x5C, 0x66, 0x66
        db 0xA3, 0x70, 0xE1, 0x7A, 0x1E, 0x85, 0x5C, 0x8F, 0x99, 0x99, 0xD7, 0xA3, 0x14, 0xAE, 0x51, 0xB8
        db 0x8F, 0xC2, 0xCC, 0xCC, 0x0A, 0xD7, 0x47, 0xE1, 0x85, 0xEB, 0xC2, 0xF5, 0xD8, 0x09, 0xB1, 0x13
        db 0x89, 0x1D, 0x62, 0x27, 0x3B, 0x31, 0x13, 0x3B, 0xEC, 0x44, 0xC4, 0x4E, 0x9D, 'XvbNl', 0x27, 0x76
        db 0x00, 0x80, 0xD8, 0x89, 0xB1, 0x93, 0x89, 0x9D, 0x62, 0xA7, 0x3B, 0xB1, 0x13, 0xBB, 0xEC, 0xC4
        db 0xC4, 0xCE, 0x9D, 0xD8, 0x76, 0xE2, 0x4E, 0xEC, 0x27, 0xF6, 0x7B, 0x09, 0xF6, 0x12, 0x71, 0x1C
        db 0xED, 0x25, 0x68, 0x2F, 0xE3, 0x38, 0x5E, 0x42, 0xDA, 0x4B, 0x55, 0x55, 0xD0, 0x5E, 0x4B, 0x68
        db 0xC7, 0x71, 0x42, 0x7B, 0xBD, 0x84, 0x38, 0x8E, 0xB4, 0x97, 0x2F, 0xA1, 0xAA, 0xAA, 0x25, 0xB4
        db 0xA1, 0xBD, 0x1C, 0xC7, 0x97, 0xD0, 0x12, 0xDA, 0x8E, 0xE3, 0x09, 0xED, 0x84, 0xF6, 0x24, 0x09, 0x49
        db 0x12, 0x6D, 0x1B, 0x92, 0x24, 0xB6, 0x2D, 0xDB, 0x36, 0x00
        db '@$IIRm[', 0x92, 0x64, 0xB6, 0x6D, 0xDB, 0x76, 0x00, 0x80, 0x24
        db 0x89, 0x49, 0x92, 0x6D, 0x9B, 0x92, 0xA4, 0xB6, 0xAD, 0xDB, 0xB6, 0x00, 0xC0, 0x24, 0xC9, 0x49
        db 0xD2, 0x6D, 0xDB, 0x92, 0xE4, 0xB6, 0xED, 0xDB, 0xF6, 0xD3, 0x08, 0xA7, 0x11, 0x7B, 0x1A, 'O##,'
        db 0xF7, 0x34, 0xCB, 0x3D, 0x9E, 'FrOFX', 0x1A, 0x61, 0xEE, 0x69, 0xC2, 0x72
        db 0x96, 0x7B, 0x69, 0x84, 0x3D, 0x8D, 0x11, 0x96, 0xE5, 0x9E, 0xB9, 0xA7, 0x8D, 0xB0, 0x61, 0xB9, 0x34
        db 0xC2, 0x08, 0xCB, 0xDC, 0xD3, 0xB0, 0xDC, 0x84, 0xE5, 0x58, 0xEE, 0x2C, 0xF7, 0x88, 0x08, 0x11
        db 0x11, 0x99, 0x19, 0x22, 0x22, 0xAA, 0x2A, 0x33, 0x33, 0xBB, 0x3B, 0x44, 0x44, 0xCC, 0x4C, 0x55, 0x55
        db 0xDD, 0x5D, 0x66, 0x66, 0xEE, 0x6E, 0x77, 0x77, 0x00, 0x80, 0x88, 0x88, 0x11, 0x91, 0x99, 0x99, 0x22
        db 0xA2, 0xAA, 0xAA, 0x33, 0xB3, 0xBB, 0xBB, 0x44, 0xC4, 0xCC, 0xCC, 0x55, 0xD5, 0xDD, 0xDD, 0x66
        db 0xE6, 0xEE, 0xEE, 0x77, 0xF7, 0x42, 0x08, 0x84, 0x10, 0xC6, 0x18, 0x08, 0x21, 0x4A, 0x29, 0x8C, 0x31
        db 0xCE, 0x39, 0x10, 0x42, 0x52, 0x4A, 0x94, 0x52, 0xD6, 0x5A, 0x18, 0x63, 0x5A, 0x6B, 0x9C, 0x73
        db 0xDE, 0x7B, 0x21, 0x84, 0x63, 0x8C, 0xA5, 0x94, 0xE7, 0x9C, 0x29, 0xA5, 0x6B, 0xAD, 0xAD, 0xB5
        db 0xEF, 0xBD, 0x31, 0xC6, 0x73, 0xCE, 0xB5, 0xD6, 0xF7, 0xDE, 0x39, 0xE7, 0x7B, 0xEF, 0xBD, 0xF7
        db 0x00, 0x08, 0x00, 0x10, 0x00, 0x18, 0x00
        db 0x20, 0x00, 0x28, 0x00
        db 0x30, 0x00, 0x38, 0x00
        db 0x40, 0x00, 0x48, 0x00
        db 0x50, 0x00, 0x58, 0x00
        db 0x60, 0x00, 0x68, 0x00
        db 0x70, 0x00, 0x78, 0x00, 0x80, 0x00, 0x88, 0x00, 0x90, 0x00, 0x98, 0x00, 0xA0, 0x00, 0xA8, 0x00
        db 0xB0, 0x00, 0xB8, 0x00, 0xC0, 0x00, 0xC8, 0x00, 0xD0, 0x00, 0xD8, 0x00, 0xE0, 0x00, 0xE8, 0x00
        db 0xF0, 0x00, 0xF8, 0xC1, 0x07, 0x83, 0x0F, 0x45, 0x17, 0x07, 0x1F, 0xC9, 0x26, 0x8B, 0x2E, 0x4D, 0x36
        db 0x0F, 0x3E, 0xD1, 0x45, 0x93, 0x4D, 0x55, 0x55, 0x17, 0x5D, 0xD9, 0x64, 0x9B, 0x6C, 0x5D, 0x74
        db 0x1F, 0x7C, 0xE0, 0x83, 0xA2, 0x8B, 0x64, 0x93, 0x26, 0x9B, 0xE8, 0xA2, 0xAA, 0xAA, 0x6C, 0xB2, 0x2E
        db 0xBA, 0xF0, 0xC1, 0xB2, 0xC9, 0x74, 0xD1, 0x36, 0xD9, 0xF8, 0xE0, 0xBA, 0xE8, 0x7C, 0xF0, 0x3E
        db 0xF8, 0x87, 0x07, 0x0F, 0x0F, 0x96, 0x16, 0x1E, 0x1E, 0xA5, 0x25, 0x2D, 0x2D, 0xB4, 0x34, 0x3C, 0x3C
        db 0xC3, 0x43, 0x4B, 0x4B, 0xD2, 0x52, 0x5A, 0x5A, 0xE1, 0x61, 0x69, 0x69, 0xF0, 0x70, 0x78, 0x78
        db 0x00, 0x80, 0x87, 0x87, 0x0F, 0x8F, 0x96, 0x96, 0x1E, 0x9E, 0xA5, 0xA5, 0x2D, 0xAD, 0xB4, 0xB4, 0x3C
        db 0xBC, 0xC3, 0xC3, 0x4B, 0xCB, 0xD2, 0xD2, 0x5A, 0xDA, 0xE1, 0xE1, 0x69, 0xE9, 0xF0, 0xF0, 0x78
        db 0xF8, 0x50, 0x07, 0xA0, 0x0E, 0xF1, 0x15, 0x41, 0x1D, 0x92, 0x24, 0xE2, 0x2B, 0x33, 0x33, 0x83, 0x3A
        db 0xD4, 'A$IuP', 0xC5, 0x57, 0x15, 0x5F, 0x66, 0x66, 0xB6, 0x6D, 0x07, 0x75, 0x57, 0x7C
        db 0xA8, 0x83, 0xF8, 0x8A, 0x49, 0x92, 0x99, 0x99, 0xEA, 0xA0, 0x3A, 0xA8, 0x8A, 0xAF, 0xDB, 0xB6, 0x2B
        db 0xBE, 0x7C, 0xC5, 0xCC, 0xCC, 0x1D, 0xD4, 0x6D, 0xDB, 0xBE, 0xE2, 0x0E, 0xEA, 0x5F, 0xF1, 0xAF
        db 0xF8, 0x1C, 0x07, 0x38, 0x0E, 0x55, 0x15, 0x71, 0x1C, 0x8E, 0x23, 0xAA, 0x2A, 0xC7, 0x31, 0xE3, 0x38
        db 0x00, 0x40, 0x1C, 'G8NUUq', 0x5C, 0x8E, 0x63, 0xAA, 0x6A, 0xC7, 0x71
        db 0xE3, 0x78, 0x00, 0x80, 0x1C, 0x87, 0x38, 0x8E, 0x55, 0x95, 0x71, 0x9C, 0x8E, 0xA3, 0xAA, 0xAA
        db 0xC7, 0xB1, 0xE3, 0xB8, 0x00, 0xC0, 0x1C, 0xC7, 0x38, 0xCE, 0x55, 0xD5, 0x71, 0xDC, 0x8E, 0xE3
        db 0xAA, 0xEA, 0xC7, 0xF1, 0xE3, 0xF8, 0xEB, 0x06, 0xD6, 0x0D, 0xC1, 0x14, 0xAC, 0x1B, 0x98, 0x22
        db 0x83, ')n0Y7E>0E', 0x1B, 0x4C, 0x06, 0x53, 0xF2, 0x59
        db 0xDD, 0x60, 0xC8, 0x67, 0xB3, 0x6E, 0x9F, 0x75, 0x8A, 0x7C, 0x75, 0x83, 0x60, 0x8A, 0x4C, 0x91, 0x37
        db 0x98, 0x22, 0x9F, 0x0D, 0xA6, 0xF9, 0xAC, 0xE4, 0xB3, 0xCF, 0xBA, 0xBA, 0xC1, 0xA6, 0xC8, 0x91
        db 0xCF, 0x7C, 0xD6, 0x67, 0xDD, 0x53, 0xE4, 0x3E, 0xEB, 0x29, 0xF2, 0x14, 0xF9, 0xBC, 0x06, 0x79
        db 0x0D, 0x35, 0x14, 0xF2, 0x1A, 0xAF, '!k((/', 0xE5, 0x35, 0xA1, 0x3C, 0x5E, 0x43
        db 0x1A, 0x4A, 0xD7, 0x50, 0x94, 0x57, 0x50, 0x5E, 0x0D, 0x65, 0xCA, 0x6B, 0x86, 0x72, 0x43, 0x79
        db 0x00, 0x80, 0xBC, 0x86, 0x79, 0x8D, 0x35, 0x94, 0xF2, 0x9A, 0xAF, 0xA1, 0x6B, 0xA8, 0x28, 0xAF
        db 0xE5, 0xB5, 0xA1, 0xBC, 0x5E, 0xC3, 0x1A, 0xCA, 0xD7, 0xD0, 0x94, 0xD7, 0x50, 0xDE, 0x0D, 0xE5
        db 0xCA, 0xEB, 0x86, 0xF2, 0x43, 0xF9, 0x90, 0x06, 0x20, 0x0D, 0xB1, 0x13, 0x41, 0x1A, 0xD2, 0x20, 0x62, 0x27
        db 0xF2, 0x2D, 0x83, 0x34, 0x13, 0x3B, 0xA4, 0x41, 0x34, 0x48, 0xC4, 0x4E, 0x55, 0x55, 0xE5, 0x5B, 0x76, 0x62
        db 0x06, 0x69, 0x96, 0x6F, 0x27, 0x76, 0xB7, 0x7C, 0x48, 0x83, 0xD8, 0x89, 0x69, 0x90, 0xF9, 0x96
        db 0x89, 0x9D, 0x1A, 0xA4, 0xAA, 0xAA, 0x3B, 0xB1, 0xCB, 0xB7, 0x5B, 0xBE, 0xEC, 0xC4, 0x7C, 0xCB
        db 0x0D, 0xD2, 0x9D, 0xD8, 0x2D, 0xDF, 0xBE, 0xE5, 0x4E, 0xEC, 0xDF, 0xF2, 0x6F, 0xF9, 0x66, 0x06
        db 0xCC, 0x0C, 0x33, 0x13, 0x99, 0x19, 0x00
        db 0x20, 0x66, 0x26, 0xCC, 0x2C, 0x33, 0x33, 0x99, 0x39, 0x00
        db 0x40, 0x66, 0x46, 0xCC, 0x4C, 0x33, 0x53, 0x99, 0x59, 0x00
        db 0x60, 0x66, 0x66, 0xCC, 0x6C, 0x33, 0x73, 0x99, 0x79, 0x00, 0x80, 0x66, 0x86, 0xCC, 0x8C, 0x33
        db 0x93, 0x99, 0x99, 0x00, 0xA0, 0x66, 0xA6, 0xCC, 0xAC, 0x33, 0xB3, 0x99, 0xB9, 0x00, 0xC0, 0x66
        db 0xC6, 0xCC, 0xCC, 0x33, 0xD3, 0x99, 0xD9, 0x00, 0xE0, 0x66, 0xE6, 0xCC, 0xEC, 0x33, 0xF3, 0x99
        db 0xF9, 0x3E, 0x06, 0x7C, 0x0C, 0xBB, 0x12, 0xF9, 0x18, 0x38, 0x1F, 0x76, 0x25, 0xB5, 0x2B, 0xF3, '118p>'
        db 0xAE, 0x44, 0xED, 'J+QjW', 0xA8, 0x5D, 0xE7, 'c%jcp'
        db 0xA2, 0x76, 0xE0, 0x7C, 0x1F, 0x83, 0x5D, 0x89, 0x9C, 0x8F, 0xDA, 0x95, 0x18, 0x9C, 0x57, 0xA2
        db 0x95, 0xA8, 0xD4, 0xAE, 0x12, 0xB5, 0x51, 0xBB, 0x8F, 0xC1, 0xCE, 0xC7, 0x0C, 0xCE, 0x4A, 0xD4
        db 0x89, 0xDA, 0xC7, 0xE0, 0x06, 0xE7, 0x44, 0xED, 0x83, 0xF3, 0xC1, 0xF9, 0x18, 0x06, 0x30, 0x0C, 0x49
        db 0x12, 0x61, 0x18, 0x79, 0x1E, 0x92, 0x24, 0xAA, 0x2A, 0xC3, 0x30, 0xDB, 0x36, 0xF3, 0x3C, 0x0C, 'C$I<OUUm['
        db 0x86, 0x61, 0x9E, 0x67, 0xB6, 0x6D, 0xCF, 0x73, 0xE7, 0x79, 0x00, 0x80, 0x18, 0x86, 0x30, 0x8C, 0x49
        db 0x92, 0x61, 0x98, 0x79, 0x9E, 0x92, 0xA4, 0xAA, 0xAA, 0xC3, 0xB0, 0xDB, 0xB6, 0xF3, 0xBC, 0x0C
        db 0xC3, 0x24, 0xC9, 0x3C, 0xCF, 0x55, 0xD5, 0x6D, 0xDB, 0x86, 0xE1, 0x9E, 0xE7, 0xB6, 0xED, 0xCF
        db 0xF3, 0xE7, 0xF9, 0xF4, 0x05, 0xE8, 0x0B, 0xDC, 0x11, 0xD0, 0x17, 0xC4, 0x1D, 0xB8, 0x23, 0xAC, 0x29
        db 0xA0, 0x2F, 0x94, 0x35, 0x88, ';}AqGeMYSMYA_5e)k'
        db 0x1D, 0x71, 0x11, 0x77, 0x05, 0x7D, 0xFA, 0x82, 0xEE, 0x88, 0xE2, 0x8E, 0xD6, 0x94, 0xCA, 0x9A
        db 0xBE, 0xA0, 0xB2, 0xA6, 0xA6, 0xAC, 0x9A, 0xB2, 0x8E, 0xB8, 0x82, 0xBE, 0x77, 0xC4, 0x6B, 0xCA, 0x5F
        db 0xD0, 0x53, 0xD6, 0x47, 0xDC, 0x3B, 0xE2, 0x2F, 0xE8, 0x23, 0xEE, 0x17, 0xF4, 0x0B, 0xFA, 0xD1
        db 0x05, 0xA2, 0x0B, 0x74, 0x11, 0x45, 0x17, 0x17, 0x1D, 0xE8, 0x22, 0xBA, 0x28, 0x8B, '.]4.:'
        db 0x00, 0x40, 0xD1, 0x45, 0xA2, 'KtQEW', 0x17, 0x5D, 0xE8, 0x62
        db 0xBA, 0x68, 0x8B, 'n]t.z', 0x00, 0x80, 0xD1, 0x85, 0xA2, 0x8B, 0x74, 0x91, 0x45
        db 0x97, 0x17, 0x9D, 0xE8, 0xA2, 0xBA, 0xA8, 0x8B, 0xAE, 0x5D, 0xB4, 0x2E, 0xBA, 0x00, 0xC0, 0xD1
        db 0xC5, 0xA2, 0xCB, 0x74, 0xD1, 0x45, 0xD7, 0x17, 0xDD, 0xE8, 0xE2, 0xBA, 0xE8, 0x8B, 0xEE, 0x5D
        db 0xF4, 0x2E, 0xFA, 0xB0, 0x05, 0x60, 0x0B, 0x11, 0x11, 0xC1, 0x16, 0x71, 0x1C, 0x22, 0x22, 0xD2, 0x27
        db 0x82, 0x2D, 0x33, 0x33, 0xE3, 0x38, 0x93, 0x3E, 0x44, 0x44, 0xF4, 0x49, 0xA4, 0x4F, 0x55, 0x55
        db 0x05, 0x5B, 0xB6, 0x60, 0x66, 0x66, 0x16, 0x6C, 0xC7, 0x71, 0x77, 0x77, 0x27, 0x7D, 0xD8, 0x82
        db 0x88, 0x88, 0x38, 0x8E, 0xE9, 0x93, 0x99, 0x99, 0x49, 0x9F, 0xFA, 0xA4, 0xAA, 0xAA, 0x5B, 0xB0
        db 0x0B, 0xB6, 0xBB, 0xBB, 0x6C, 0xC1, 0x1C, 0xC7, 0xCC, 0xCC, 0x7D, 0xD2, 0x2D, 0xD8, 0xDD, 0xDD
        db 0x8E, 0xE3, 0x3E, 0xE9, 0xEE, 0xEE, 0x9F, 0xF4, 0x4F, 0xFA, 0x90, 0x05, 0x21, 0x0B, 0xB2, 0x10, 0x42
        db 0x16, 0xD3, 0x1B, 0x64, 0x21, 0xF4, 0x26, 0x85, 0x2C, 0x16, 0x32, 0xA6, 0x37, 0x37, 0x3D, 0xC8, 0x42, 0x59, 0x48
        db 0xE9, 0x4D, 0x7A, 0x53, 0x0B, 0x59, 0x9B, 0x5E, 0x2C, 0x64, 0xBD, 0x69, 0x4D, 0x6F, 0xDE, 0x74, 0x6F, 0x7A
        db 0x00, 0x80, 0x90, 0x85, 0x21, 0x8B, 0xB2, 0x90, 0x42, 0x96, 0xD3, 0x9B, 0x64, 0xA1, 0xF4, 0xA6
        db 0x85, 0xAC, 0x16, 0xB2, 0xA6, 0xB7, 0x37, 0xBD, 0xC8, 0xC2, 0x59, 0xC8, 0xE9, 0xCD, 0x7A, 0xD3
        db 0x0B, 0xD9, 0x9B, 0xDE, 0x2C, 0xE4, 0xBD, 0xE9, 0x4D, 0xEF, 0xDE, 0xF4, 0x6F, 0xFA, 0x72, 0x05
        db 0xE4, 0x0A, 0x57, 0x10, 0xC9, 0x15, 0x3B, 0x1B, 0xAE, 0x20, 0x20, 0x26, 0x93, 0x2B, 0x05, 0x31, 0x77, 0x36
        db 0xEA, 0x3B, 0x5C, 0x41, 0xCE, 0x46, 0x41, 0x4C, 0xB3, 0x51, 0x26, 0x57, 0x98, 0x5C, 0x0A, 0x62, 0x7D, 0x67
        db 0xEF, 0x6C, 0x62, 0x72, 0xD4, 0x77, 0x46, 0x7D, 0xB9, 0x82, 0x2B, 0x88, 0x9D, 0x8D, 0x10, 0x93
        db 0x82, 0x98, 0xF5, 0x9D, 0x67, 0xA3, 0xD9, 0xA8, 0x4C, 0xAE, 0xBE, 0xB3, 0x31, 0xB9, 0xA3, 0xBE
        db 0x15, 0xC4, 0x88, 0xC9, 0xFA, 0xCE, 0x6C, 0xD4, 0xDF, 0xD9, 0x51, 0xDF, 0xC4, 0xE4, 0x36, 0xEA
        db 0xA8, 0xEF, 0x1B, 0xF5, 0x8D, 0xFA, 0x55, 0x05, 0xAA, 0x0A, 0x00, 0x10, 0x55, 0x15, 0xAA, 0x1A
        db 0x00, 0x20, 0x55, 0x25, 0xAA, 0x2A, 0x00
        db 0x30, 0x55, 0x35, 0xAA, 0x3A, 0x00
        db 0x40, 0x55, 0x45, 0xAA, 0x4A, 0x00
        db 0x50, 0x55, 0x55, 0xAA, 0x5A, 0x00
        db 0x60, 0x55, 0x65, 0xAA, 0x6A, 0x00
        db 0x70, 0x55, 0x75, 0xAA, 0x7A, 0x00, 0x80, 0x55, 0x85, 0xAA, 0x8A, 0x00, 0x90, 0x55, 0x95, 0xAA
        db 0x9A, 0x00, 0xA0, 0x55, 0xA5, 0xAA, 0xAA, 0x00, 0xB0, 0x55, 0xB5, 0xAA, 0xBA, 0x00, 0xC0, 0x55
        db 0xC5, 0xAA, 0xCA, 0x00, 0xD0, 0x55, 0xD5, 0xAA, 0xDA, 0x00, 0xE0, 0x55, 0xE5, 0xAA, 0xEA, 0x00
        db 0xF0, 0x55, 0xF5, 0xAA, 0xFA, 0x39, 0x05, 0x72, 0x0A, 0xAC, 0x0F, 0xE5, 0x14, 0x1F, 0x1A, 0x58
        db 0x1F, 0x92, 0x24, 0xCB, 0x29, 0x05, '/>4x9', 0xB1, 0x3E, 0xEB, 'C$I^N'
        db 0x97, 0x53, 0xD0, 0x58, 0x0A, '^Cc}h', 0xB6, 0x6D, 0xF0, 'r)xc}'
        db 0x9C, 0x82, 0xD6, 0x87, 0x0F, 0x8D, 0x49, 0x92, 0x82, 0x97, 0xBC, 0x9C, 0xF5, 0xA1, 0x2F, 0xA7, 0x68
        db 0xAC, 0xA1, 0xB1, 0xDB, 0xB6, 0x14, 0xBC, 0x4E, 0xC1, 0x87, 0xC6, 0xC1, 0xCB, 0xFA, 0xD0, 0x34
        db 0xD6, 0x6D, 0xDB, 0xA7, 0xE0, 0xE0, 0xE5, 0x1A, 0xEB, 0x53, 0xF0, 0x8D, 0xF5, 0xC6, 0xFA
SinTable:                                       ; sine of 0 to 90 degrees in 256 steps, 257 words, 4000h =
                                                ; 1.0; read by SinLookup and CosLookup
        dw 0x0000, 0x0065, 0x00C9, 0x012E, 0x0192, 0x01F7, 0x025B, 0x02C0
        dw 0x0324, 0x0388, 0x03ED, 0x0451, 0x04B5, 0x051A, 0x057E, 0x05E2
        dw 0x0646, 0x06AA, 0x070E, 0x0772, 0x07D6, 0x0839, 0x089D, 0x0901
        dw 0x0964, 0x09C7, 0x0A2B, 0x0A8E, 0x0AF1, 0x0B54, 0x0BB7, 0x0C1A
        dw 0x0C7C, 0x0CDF, 0x0D41, 0x0DA4, 0x0E06, 0x0E68, 0x0ECA, 0x0F2B
        dw 0x0F8D, 0x0FEE, 0x1050, 0x10B1, 0x1112, 0x1173, 0x11D3, 0x1234
        dw 0x1294, 0x12F4, 0x1354, 0x13B4, 0x1413, 0x1473, 0x14D2, 0x1531
        dw 0x1590, 0x15EE, 0x164C, 0x16AB, 0x1709, 0x1766, 0x17C4, 0x1821
        dw 0x187E, 0x18DB, 0x1937, 0x1993, 0x19EF, 0x1A4B, 0x1AA7, 0x1B02
        dw 0x1B5D, 0x1BB8, 0x1C12, 0x1C6C, 0x1CC6, 0x1D20, 0x1D79, 0x1DD3
        dw 0x1E2B, 0x1E84, 0x1EDC, 0x1F34, 0x1F8C, 0x1FE3, 0x203A, 0x2091
        dw 0x20E7, 0x213D, 0x2193, 0x21E8, 0x223D, 0x2292, 0x22E7, 0x233B
        dw 0x238E, 0x23E2, 0x2435, 0x2488, 0x24DA, 0x252C, 0x257E, 0x25CF
        dw 0x2620, 0x2671, 0x26C1, 0x2711, 0x2760, 0x27AF, 0x27FE, 0x284C
        dw 0x289A, 0x28E7, 0x2935, 0x2981, 0x29CE, 0x2A1A, 0x2A65, 0x2AB0
        dw 0x2AFB, 0x2B45, 0x2B8F, 0x2BD8, 0x2C21, 0x2C6A, 0x2CB2, 0x2CFA
        dw 0x2D41, 0x2D88, 0x2DCF, 0x2E15, 0x2E5A, 0x2E9F, 0x2EE4, 0x2F28
        dw 0x2F6C, 0x2FAF, 0x2FF2, 0x3034, 0x3076, 0x30B8, 0x30F9, 0x3139
        dw 0x3179, 0x31B9, 0x31F8, 0x3236, 0x3274, 0x32B2, 0x32EF, 0x332C
        dw 0x3368, 0x33A3, 0x33DF, 0x3419, 0x3453, 0x348D, 0x34C6, 0x34FF
        dw 0x3537, 0x356E, 0x35A5, 0x35DC, 0x3612, 0x3648, 0x367D, 0x36B1
        dw 0x36E5, 0x3718, 0x374B, 0x377E, 0x37B0, 0x37E1, 0x3812, 0x3842
        dw 0x3871, 0x38A1, 0x38CF, 0x38FD, 0x392B, 0x3958, 0x3984, 0x39B0
        dw 0x39DB, 0x3A06, 0x3A30, 0x3A59, 0x3A82, 0x3AAB, 0x3AD3, 0x3AFA
        dw 0x3B21, 0x3B47, 0x3B6D, 0x3B92, 0x3BB6, 0x3BDA, 0x3BFD, 0x3C20
        dw 0x3C42, 0x3C64, 0x3C85, 0x3CA5, 0x3CC5, 0x3CE4, 0x3D03, 0x3D21
        dw 0x3D3F, 0x3D5B, 0x3D78, 0x3D93, 0x3DAF, 0x3DC9, 0x3DE3, 0x3DFC
        dw 0x3E15, 0x3E2D, 0x3E45, 0x3E5C, 0x3E72, 0x3E88, 0x3E9D, 0x3EB1
        dw 0x3EC5, 0x3ED8, 0x3EEB, 0x3EFD, 0x3F0F, 0x3F20, 0x3F30, 0x3F40
        dw 0x3F4F, 0x3F5D, 0x3F6B, 0x3F78, 0x3F85, 0x3F91, 0x3F9C, 0x3FA7
        dw 0x3FB1, 0x3FBB, 0x3FC4, 0x3FCC, 0x3FD4, 0x3FDB, 0x3FE1, 0x3FE7
        dw 0x3FEC, 0x3FF1, 0x3FF5, 0x3FF8, 0x3FFB, 0x3FFD, 0x3FFF, 0x4000
        dw 0x4000
SeqTickCount:                                   ; sequencer ticks; used by SeqService
        db 0x00, 0x00
SeqBusy:                                        ; seqService running; used by SeqTimerTick
        dw 0x0000
str_Track:                                      ; string 'track'; not used in the EXE (overlays may use it)
        db 'track', 0x00
str_Parts:                                      ; string 'parts'; not used in the EXE (overlays may use it)
        db 'parts', 0x00
str_Seqdat:                                     ; string 'seqdat'; not used in the EXE (overlays may use it)
        db 'seqdat', 0x00
str_BankDPat:                                   ; string 'bank%d.pat'; used by LoadBankNumber
        db 'bank%d.pat', 0x00
str_TimbDTim:                                   ; string 'timb%d.tim'; used by LoadSongMode
        db 'timb%d.tim', 0x00, 0x00
SfxChannel:                                     ; effects channel; used by PlayPatchNote
        dw 0x0000
str_CEaclibS:                                   ; string 'c:\eaclib\%s'; used by LoadSoundDriver
        db 0x63, 0x3A, 0x5C, 'eaclib', 0x5C, 0x25, 0x73, 0x00, 0x00
        db 'Couldn', 0x27, 't resolve sound driver'
        db 0x00
DriverCount:                                    ; sound drivers loaded; used by LoadSoundDriver, DrvSendMidi,
                                                ; SeqTimerTick ...
        dw 0x0000
TrackSlots:                                     ; 24 track slots of 58h bytes, offset; used by SeqService,
                                                ; SetSongTempo, ResetSequencer ...
        dw 0x0000
TrackSlotsSeg:                                  ; track slots, segment; used by SeqService, SetSongTempo,
                                                ; InitSequencer ...
        dw 0x0000
Voices:                                         ; 32 voice records of 0Ch bytes, offset; used by SeqService,
                                                ; SeqStepTrack, AllocVoice ...
        dw 0x0000
VoicesSeg:                                      ; voice records, segment; used by SeqService, SeqStepTrack,
                                                ; AllocVoice ...
        dw 0x0000
ChannelMasks:                                   ; channel bit per MIDI channel; used by FindFreeChannel
        db 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00, 0x10, 0x00
        db 0x20, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00, 0x10
        db 0x00, 0x20, 0x00, 0x40, 0x00, 0x80
SongHandleLo:                                   ; last song handle, low word; used by StartSong
        dw 0x0200
SongHandleHi:                                   ; last song handle, high word; used by StartSong
        dw 0x0000
SeqLock:                                        ; sequencer locked while non-zero; used by SeqTimerTick,
                                                ; QueueMidiBytes, SendPatches ...
        dw 0x0000
MidiQueueLen:                                   ; bytes in the MIDI queue; used by QueueMidiBytes,
                                                ; FlushMidiQueue
        dw 0x0000
MidiQueueBusy:                                  ; MIDI queue in use; used by QueueMidiBytes, FlushMidiQueue
        dw 0x0000
TracksMuted:                                    ; tracks muted; used by SeqService, MuteAllTracks,
                                                ; RestoreTrackVolumes
        dw 0x0000
SfxEnabled:                                     ; effects on; used by PlayPatchNote, ReleaseAllVoices,
                                                ; StopSound ...
        dw 0x0001
MusicEnabled:                                   ; second sound flag (music); used by MusicOn, MusicOff,
                                                ; ToggleMusic ...
        dw 0x0001
DriverName:                                     ; driver file name being loaded; used by LoadSoundDriver
        dw 0x0064
DriverServiceIdx:                               ; driver that needs service (FFh for none); used by
                                                ; LoadSoundDriver, SeqService, ResetSequencer
        db 0xFF, 0x00
SongCount:                                      ; songs loaded; used by LoadSongMode, UnloadSong
        db 0x00, 0x00
SongPtrs:                                       ; song pointers, offsets; used by LoadSongMode, UnloadSong
        db 0x00, 0x00
SongPtrsSeg:                                    ; song pointers, segments; used by LoadSongMode, UnloadSong
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
TopOfStack:                                     ; stack pointer at startup; used by MscStartup
        dw 0x0000
ExitRoutine:                                    ; near routine errors leave through (_exit); used by __cintDIV
        dw 0x068E
DgroupTop:                                      ; top offset of DGROUP; used by MscStartup
        db 0x00, 0x00
NearHeapDesc:                                   ; near heap descriptor (segment, flags, start, rover, end);
                                                ; used by MscStartup, _nmalloc, _nfree
        db 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_CFileInfo:                                  ; string '_C_FILE_INFO='; not used in the EXE (overlays may
                                                ; use it)
        db '_C_FILE_INFO=', 0x00
OldInt0Vec:                                     ; saved INT 0 vector; used by InitRuntime, ExitRestore
        dw 0x0000
OldInt0VecSeg:                                  ; saved INT 0 vector, segment; used by InitRuntime
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
errno:                                          ; dosMapErr stores the translated C error here; not referenced
                                                ; in the root code
        db 0x00, 0x00
_umaskval:                                      ; file permission mask applied by open; used by the open
                                                ; routine
        db 0x00, 0x00, 0x00, 0x00
__psp:                                          ; startup stores the incoming DS (the PSP) here and later
                                                ; reads the environment segment from it; used by MscStartup,
                                                ; InitRuntime, HeapGrow
        dw 0x0000
DosMajor:                                       ; DOS major version; used by _sopen, DosMapErr
        db 0x00, 0x00, 0x00
_doserrno:                                      ; dosMapErr stores the raw DOS error here; not referenced in
                                                ; the root code
        db 0x00, 0x00
_nfile:                                         ; highest C handle
        dw 0x0014
_osfile:                                        ; _C_FILE_INFO nibbles are stored here and the IOCTL loop sets
                                                ; the device bit on handles 0 to 4; used by InitRuntime
        db 0x81, 0x81, 0x81, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
ArgCount:                                       ; argc; used by MscStartup
        dw 0x0000
ArgVector:                                      ; argv; used by MscStartup
        dw 0x0000
EnvVector:                                      ; environ; used by MscStartup
        db 0x00, 0x00, 0x7D, 0x85, 0xC9, 0x45, 0x00, 0x00, 0x00
MathVecSet:                                     ; a math error vector was installed; used by ExitRestore
        db 0x00
MathVecNum:                                     ; its interrupt number; used by ExitRestore
        db 0x00
MathVecOld:                                     ; its saved vector; used by ExitRestore
        db 0x00, 0x00, 0x00, 0x00
StackOverflowFn:                                ; alternate stack-overflow handler (FFFFh for none); used by
                                                ; __chkstk
        dd 0xFFFFFFFF
StackLimit:                                     ; lowest allowed stack pointer; used by __chkstk, _stackavail
        db 0x70, 0xE4, 0x00
CharTypes:                                      ; character type table (bit 4: digit); used by
                                                ; NumberEntryDialog
        db '         (((((                  H', 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x10, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x10, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
        db 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x10, 0x10, 0x10, 0x10, 0x20
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00
str_ColonSpace:                                 ; string ': ', written by perror after the caller's text
        db ': ', 0x00
str_Newline:                                    ; string of one line feed, written by perror after the message
        db 0x0A, 0x00, 0x00
AtexitPtr:                                      ; next free atexit slot; used by atexit
        dw 0x90B8
RandSeed:                                       ; rand seed, low word; used by _srand, _rand
        dw 0x0001
RandSeedHigh:                                   ; rand seed, high word; used by _srand, _rand
        db 0x00, 0x00
FltCvtInit:                                     ; twelve words copied over FltCvtFn when floating point is
                                                ; linked in (near pointers of the float format helpers)
        db 0x98, 0x22, 0x00, 0x00, 0x8A, 0x1E, 0x00, 0x00, 0x26, 0x1F, 0x00, 0x00, 0x22, 0x1E, 0x00, 0x00
        db 0xF8, 0x1E, 0x00, 0x00, 0x90, 0x26, 0x00, 0x00
MsgBannerHook:                                  ; far routine called before a runtime message; used by
                                                ; __FF_MSGBANNER
        db 0x00, 0x00
MsgBannerHookSeg:                               ; its segment; used by __FF_MSGBANNER
        db 0x00, 0x00
DosErrnoTable:                                  ; errno value for each DOS error code 0 to 13h; used by
                                                ; DosMapErr
        db 0x00, 0x16, 0x02, 0x02, 0x18, 0x0D, 0x09, 0x0C, 0x0C, 0x0C, 0x07, 0x08, 0x16, 0x16, 0xFF, 0x02
        db 0x0D, 0x12, 0x02, 0xFF
_iob:                                           ; stream table (8 bytes each: ptr, count, base, flag, file),
                                                ; stdin first; used by FlushAll
        db 0x5E, 0xE1, 0x00, 0x00, 0x5E, 0xE1, 0x01, 0x00
_iob_stdout:                                    ; stdout entry of _iob; used by printf, _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01
_iob_stderr:                                    ; stderr entry of _iob; used by _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84, 0x03
_iob_stdprn:                                    ; stdprn entry of _iob; used by _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
StreamExtra:                                    ; extra stream records for the standard buffers; not
                                                ; referenced in the root code
        db 0x01, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        times 144 db 0
LastStream:                                     ; last stream record; used by FlushAll
        db 0x62, 0x87
StdoutBuf:                                      ; buffer pointer _stbuf gives stdout
        db 0x00, 0x00
StderrBuf:                                      ; buffer pointer _stbuf gives stderr
        db 0x00, 0x00
StdprnBuf:                                      ; buffer pointer _stbuf gives stdprn
        db 0x00, 0x00
OutputClassTable:                               ; _output state table: class of each format character from 20h
                                                ; to 78h, packed with the next state
        db 0x06, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x10, 0x00, 0x03, 0x06, 0x00, 0x06, 0x02, 0x10
        db 0x04, 'EEE', 0x05, 0x05, 0x05, 0x05, 0x05, 0x35, 0x30, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00
        db '  0PX', 0x07, 0x08, 0x00, '000WP', 0x07, 0x00, 0x00, '  ', 0x00, 0x00, 0x00, 0x00, 0x00, 0x08
        db '``````', 0x00, 0x00, 'ppxxxx', 0x08, 0x07, 0x08, 0x00, 0x00, 0x07, 0x00, 0x08, 0x08, 0x08, 0x00, 0x00
        db 0x08, 0x00, 0x08, 0x00, 0x00, 0x08
str_Null:                                       ; string '(null)', printed by _output for a null %s pointer
        db '(null)'
NullStrLen:                                     ; length of str_Null (6); used by _output
        db 0x06, 0x00, 0x00
_fmode:                                         ; default file mode; bit 15 (O_BINARY) makes open binary; used
                                                ; by the open routine
        db 0x00, 0x00
FltCvtFn:                                       ; float conversion routine; used by _output
        dd 0x0000162E
CropZerosFn:                                    ; drops trailing zeros; used by _output
        db 0x2E, 0x16, 0x00, 0x00
        db 0x2E, 0x16, 0x00, 0x00
ForceDecPtFn:                                   ; forces a decimal point; used by _output
        db 0x2E, 0x16, 0x00, 0x00
        db 0x2E, 0x16, 0x00, 0x00
PositiveFn:                                     ; checks the sign; used by _output
        db 0x2E, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
str_ErrNone:                                    ; message for errno 0: 'Error 0'
        db 'Error 0', 0x00
str_ErrBlank1:                                  ; empty message for errno 1
        db 0x00
str_ENOENT:                                     ; message for errno 2: 'No such file or directory'
        db 'No such file or directory', 0x00
str_ErrBlank3:                                  ; empty message for errno 3
        db 0x00
str_ErrBlank4:                                  ; empty message for errno 4
        db 0x00
str_ErrBlank5:                                  ; empty message for errno 5
        db 0x00
str_ErrBlank6:                                  ; empty message for errno 6
        db 0x00
str_E2BIG:                                      ; message for errno 7: 'Arg list too long'
        db 'Arg list too long', 0x00
str_ENOEXEC:                                    ; message for errno 8: 'Exec format error'
        db 'Exec format error', 0x00
str_EBADF:                                      ; message for errno 9: 'Bad file number'
        db 'Bad file number', 0x00
str_ErrBlank10:                                 ; empty message for errno 10
        db 0x00
str_ErrBlank11:                                 ; empty message for errno 11
        db 0x00
str_ENOMEM:                                     ; message for errno 12: 'Not enough core'
        db 'Not enough core', 0x00
str_EACCES:                                     ; message for errno 13: 'Permission denied'
        db 'Permission denied', 0x00
str_ErrBlank14:                                 ; empty message for errno 14
        db 0x00
str_ErrBlank15:                                 ; empty message for errno 15
        db 0x00
str_ErrBlank16:                                 ; empty message for errno 16
        db 0x00
str_EEXIST:                                     ; message for errno 17: 'File exists'
        db 'File exists', 0x00
str_EXDEV:                                      ; message for errno 18: 'Cross-device link'
        db 'Cross-device link', 0x00
str_ErrBlank19:                                 ; empty message for errno 19
        db 0x00
str_ErrBlank20:                                 ; empty message for errno 20
        db 0x00
str_ErrBlank21:                                 ; empty message for errno 21
        db 0x00
str_EINVAL:                                     ; message for errno 22: 'Invalid argument'
        db 'Invalid argument', 0x00
str_ErrBlank23:                                 ; empty message for errno 23
        db 0x00
str_EMFILE:                                     ; message for errno 24: 'Too many open files'
        db 'Too many open files', 0x00
str_ErrBlank25:                                 ; empty message for errno 25
        db 0x00
str_ErrBlank26:                                 ; empty message for errno 26
        db 0x00
str_ErrBlank27:                                 ; empty message for errno 27
        db 0x00
str_ENOSPC:                                     ; message for errno 28: 'No space left on device'
        db 'No space left on device', 0x00
str_ErrBlank29:                                 ; empty message for errno 29
        db 0x00
str_ErrBlank30:                                 ; empty message for errno 30
        db 0x00
str_ErrBlank31:                                 ; empty message for errno 31
        db 0x00
str_ErrBlank32:                                 ; empty message for errno 32
        db 0x00
str_EDOM:                                       ; message for errno 33: 'Math argument'
        db 'Math argument', 0x00
str_ERANGE:                                     ; message for errno 34: 'Result too large'
        db 'Result too large', 0x00
str_ErrBlank35:                                 ; empty message for errno 35
        db 0x00
str_EDEADLOCK:                                  ; message for errno 36: 'Resource deadlock would occur'
        db 'Resource deadlock would occur', 0x00
str_ErrUnknown:                                 ; message for errno 37: 'Unknown error'
        db 'Unknown error', 0x00
SysErrList:                                     ; sys_errlist: near pointers to the messages for errno 0 to
                                                ; 37; used by perror
        dw str_ErrNone
        dw str_ErrBlank1
        dw str_ENOENT
        dw str_ErrBlank3
        dw str_ErrBlank4
        dw str_ErrBlank5
        dw str_ErrBlank6
        dw str_E2BIG
        dw str_ENOEXEC
        dw str_EBADF
        dw str_ErrBlank10
        dw str_ErrBlank11
        dw str_ENOMEM
        dw str_EACCES
        dw str_ErrBlank14
        dw str_ErrBlank15
        dw str_ErrBlank16
        dw str_EEXIST
        dw str_EXDEV
        dw str_ErrBlank19
        dw str_ErrBlank20
        dw str_ErrBlank21
        dw str_EINVAL
        dw str_ErrBlank23
        dw str_EMFILE
        dw str_ErrBlank25
        dw str_ErrBlank26
        dw str_ErrBlank27
        dw str_ENOSPC
        dw str_ErrBlank29
        dw str_ErrBlank30
        dw str_ErrBlank31
        dw str_ErrBlank32
        dw str_EDOM
        dw str_ERANGE
        dw str_ErrBlank35
        dw str_EDEADLOCK
        dw str_ErrUnknown
SysNerr:                                        ; sys_nerr: number of messages in SysErrList (25h); used by
                                                ; perror
        db 0x25, 0x00
str_E000:                                       ; string 'e+000'; not used in the EXE (overlays may use it)
        db 'e+000', 0x00
FloatMode:                                      ; float format mode; used by FloatBuf, FloatToStr, FloatWidth
                                                ; ...
        db 0x00, 0x00
FloatPrecision:                                 ; float precision; used by FloatWidth, FormatOne
        dw 0x0000
FloatFlag:                                      ; float format flag; used by FormatOne
        db 0x00, 0x00
FpErrDigits:                                    ; two ASCII digits per floating-point error code, '01' to
                                                ; '12'; used by FpError
        db '010203040506070809101112'
FpErrMsg:                                       ; counted string 'M61xx', the xx filled from FpErrDigits; used
                                                ; by FpError
        db 0x05, 'M61xx'
FpErrCode:                                      ; floating-point error code; used by FpError
        db 0x00, 0x00, 0x00, 0x00
str_SNAN:                                       ; counted string '1#SNAN' for printf
        db 0x06, '1#SNAN'
str_QNAN:                                       ; counted string '1#QNAN' for printf
        db 0x06, '1#QNAN'
str_INF:                                        ; counted string '1#INF' for printf
        db 0x05, '1#INF'
str_IND:                                        ; counted string '1#IND' for printf
        db 0x05, '1#IND'
FltResult:                                      ; conversion result block of HexConvert (sign, exponent, flag,
                                                ; digit pointer)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
FltValue:                                       ; copy of the double HexConvert converts
        db 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
FltDigits:                                      ; digit buffer of HexConvert
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
CvtWork:                                        ; ten-byte work value of DoubleToDigits
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
CvtDigitCount:                                  ; digit count (or fixed-string flag) DoubleToDigits returns
        db 0x00
CvtDigits:                                      ; sixteen digits DoubleToDigits writes
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_CvtSNAN:                                    ; counted string '1#SNAN' DoubleToDigits returns for a
                                                ; signalling NaN
        db 0x06, '1#SNAN'
str_CvtQNAN:                                    ; counted string '1#QNAN' DoubleToDigits returns for a quiet
                                                ; NaN
        db 0x06, '1#QNAN'
str_CvtINF:                                     ; counted string '1#INF' DoubleToDigits returns for infinity
        db 0x05, '1#INF'
str_CvtIND:                                     ; counted string '1#IND' DoubleToDigits returns for indefinite
        db 0x05, '1#IND'
FpStatusWord:                                   ; coprocessor status word DoubleToDigits stores (FpStatusByte
                                                ; is its high byte)
        db 0x00
FpStatusByte:                                   ; floating-point status byte; used by _nmalloc
        db 0x00
FpSavedCw:                                      ; coprocessor control word saved by DoubleToDigits
        db 0x00, 0x00
FpRoundCw:                                      ; control word 1332h (round to nearest, 64-bit precision);
                                                ; DoubleToDigits copies the mask bits of FpSavedCw into its
                                                ; low byte
        db 0x32, 0x13, 0x00, 0x80, 0x66, 0x24, 0x00, 0x80, 0xE0, 0x37, 0x79, 0xC3, 0x41, 0x43, 0x00
AllocBlockSize:                                 ; near heap growth size in bytes (2000h), read by the heap
                                                ; allocator
        db 0x00, 0x20, 0x00, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0x43, 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xEF, 0x7F, 0x00, 0x00
InitHook:                                       ; near startup hook (0 skips); used by MscStartup
        dw 0x0000
DebugSignature:                                 ; D6D6h when a debugger hook is present; used by __cintDIV,
                                                ; __cexit, _read ...
        dw 0x0000
DebugWriteHook:                                 ; debugger write hook; used by _read, _write, _dos_write ...
        dw 0x058C
DebugExitHook:                                  ; debugger exit hook; used by __cintDIV
        dw 0x058C
DebugTermHook:                                  ; debugger termination hook; used by __cexit
        db 0x8C, 0x05, 0x00
        dw SortPairsTail, 0x1500
        db 0x34, 0x00, 0x00
FpHook:                                         ; floating-point hook; used by InitRuntime, ExitRestore
        db 0x3A, 0x00
FpHookCount:                                    ; number of floating-point hooks (0 skips); used by
                                                ; InitRuntime, ExitRestore
        dw 0x18B9
FpEnvArg1:                                      ; first floating-point hook argument; used by InitRuntime
        db 0x69, 0x01, 0x96, 0x39
FpEnvArg2:                                      ; second floating-point hook argument; used by InitRuntime
        db 0x12, 0x23, 0x00, 0x00
InitTable:                                      ; C initializer table (one far pointer), run by InitRuntime
        db 0xF8, 0x15, 0x00, 0x00
PreTermTable:                                   ; C pre-terminator table (one far pointer), run by ExitCommon
        db 0x9E, 0x27, 0x00, 0x00
TermTable:                                      ; C terminator table (empty: it ends where it starts); run by
                                                ; ExitCommon
DgroupSegA:                                     ; DGROUP paragraph (relocated); main loads it into es
        dw 0x45C9
CentisPerSample:                                ; the double 1/110.25: a sample count at 11025 Hz to
                                                ; hundredths
                                                ; of a second; used by the speech bank loader
        db 0xA5, 0x04, 0xB8, 0x5B, 0x72, 0x93, 0x82, 0x3F
NumberWordsSeg:                                 ; paragraph of number_words; used by NumberSampleNames,
                                                ; SayPeriodSummary, SayPlayerFrom
        dw 0x342F
DbFilesSeg:                                     ; paragraph of db_files; used by SaveGame
        dw 0x3415
DbFilesSeg2:                                    ; paragraph of db_files; used by SaveGame
        dw 0x3415
DbFilesSeg3:                                    ; paragraph of db_files; used by SaveGame
        dw 0x3415
ListDialogDataSeg:                              ; paragraph of the list dialog data; used by ListDialog
        dw 0x35EC
DgroupSegB:                                     ; DGROUP paragraph (relocated); used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        dw 0x45C9
InputEventDataSeg:                              ; paragraph of the input event data; used by GetInputEvent
        db 0x2E, 0x34
segDgroup1:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; ControlsDlgLoop, ControlsDlgPlayoff; used by MENUS
        db 0xC9, 0x45
segSaveDialogRects1:                            ; segment constant 35EEh (save_dialog_rects) loaded into es by
                                                ; DrawControlsDlg; used by MENUS
        db 0xEE, 0x35
segDgroup2:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; TitleScreen; used by MENUS
        db 0xC9, 0x45
segCredits1:                                    ; segment constant 3608h (credits) loaded into es by
                                                ; GoodnightScreen; used by MENUS
        db 0x08, 0x36
segMenuText1:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetSideControls; used by MENUS
        db 0x48, 0x34
segMenuText2:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetSideControls; used by MENUS
        db 0x48, 0x34
segMenuText3:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, MenuUseDefaultLines,
                                                ; MenuUseOriginalLines; used by MENUS
        db 0x48, 0x34
segMenuText4:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segMenuText5:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segMenuText6:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; GameLineEditorLoop, GameScratchPlayer, MenuUseDefaultLines ;
                                                ; used by MENUS
        db 0x48, 0x34
segCharTable1:                                  ; segment constant 3680h (char_table) loaded into es by
                                                ; DrawGameLineJerseys, GameLineEditorLoop, LoadJerseyColours;
                                                ; used by MENUS
        db 0x80, 0x36
segDbFiles1:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuOpenSaved, SelectSavedFile; used by MENUS
        db 0x15, 0x34
segDbFiles2:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DeleteSavedGame, MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDbFiles3:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDbFiles4:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DeleteSavedGame, MenuOpenSaved; used by MENUS
        db 0x15, 0x34
segDialogRects1:                                ; segment constant 369Ah (dialog_rects) loaded into es by
                                                ; DrawFileDlg, DrawFileDlgList, RunFileDlg; used by MENUS
        db 0x9A, 0x36
segMenuText7:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeleteSavedGame, SelectSavedFile; used by MENUS
        db 0x48, 0x34
segPlayoffDialogRects1:                         ; segment constant 36A8h (playoff_dialog_rects) loaded into es
                                                ; by SetSoundDevice; used by MENUS
        db 0xA8, 0x36
segDbFiles5:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; DrawLockerRoom, LockerRoomLoop; used by MENUS
        db 0x15, 0x34
segMenuText8:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; LockerRoomLoop; used by MENUS
        db 0x48, 0x34
segMenuText9:                                   ; segment constant 3448h (menu_text) loaded into es by
                                                ; MenuPlayoffHilights; used by MENUS
        db 0x48, 0x34
segDbFiles6:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; CreatePlayoffs, PlayoffModeLoop; used by MENUS
        db 0x15, 0x34
segTeamChoiceText1:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CreatePlayoffs, POSimSeries, POSimSeriesTeamWins; used by
                                                ; MENUS
        db 0x01, 0x37
segMenuText10:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; CreatePlayoffs; used by MENUS
        db 0x48, 0x34
segDbFiles7:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; POCreateSchedule, POInitSchedule, POPickConfTeams; used by
                                                ; MENUS
        db 0x15, 0x34
segMenuText11:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; POAfterGame, PlayoffModeLoop; used by MENUS
        db 0x48, 0x34
segWorkBuffer1:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayoffModeLoop; used by MENUS
        db 0x0B, 0x3A
segDbFiles8:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; PlayoffModeLoop; used by MENUS
        db 0x15, 0x34
segDgroup3:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawPlayoffTree, PlayoffModeLoop; used by MENUS
        db 0xC9, 0x45
segMenuText12:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetModeMenuLabels; used by MENUS
        db 0x48, 0x34
segMenuText13:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetModeMenuLabels; used by MENUS
        db 0x48, 0x34
segDgroup4:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; MenuLeagueSettingsEdit; used by MENUS
        db 0xC9, 0x45
segMenuText14:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x48, 0x34
segWorkBuffer2:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x0B, 0x3A
segDbFiles9:                                    ; segment constant 3415h (db_files) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x15, 0x34
segDbFiles10:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; SportsDesk; used by MENUS
        db 0x15, 0x34
segReturnMessages1:                             ; segment constant 36F5h (return_messages) loaded into es by
                                                ; DeskExitGame, DeskReturnConfirm; used by MENUS
        db 0xF5, 0x36
segDgroup5:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DeskExitGame; used by MENUS
        db 0xC9, 0x45
segMenuText15:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeskHomeGoalie1, DeskHomeGoalie2, DeskHomeGoalieNone; used
                                                ; by MENUS
        db 0x48, 0x34
segMenuText16:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; DeskAwayGoalie1, DeskAwayGoalie2, DeskAwayGoalieNone; used
                                                ; by MENUS
        db 0x48, 0x34
segMenuText17:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; MainDeskLoop, MenuLeagueHilights, MenuNewExhibition; used by
                                                ; MENUS
        db 0x48, 0x34
segMenuText18:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; LoadModeState; used by MENUS
        db 0x48, 0x34
schedgameidx:                                   ; schedule game index; used by MENUS
        db 0x0B, 0x3A
musicslot:                                      ; music slot; used by MENUS
        db 0xC9, 0x45
segDbFiles11:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; MenuNewLeague; used by MENUS
        db 0x15, 0x34
segMenuText19:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; MenuNewLeague; used by MENUS
        db 0x48, 0x34
segWorkBuffer3:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText2:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer4:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText3:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer5:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText4:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x01, 0x37
segWorkBuffer6:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; AddHumanTeam, RemoveHumanTeam; used by LP
        db 0x0B, 0x3A
segWorkBuffer7:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawTeamGrid; used by LP
        db 0x0B, 0x3A
segWorkBuffer8:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer9:                                 ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer10:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segWorkBuffer11:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ChooseLeagueController; used by LP
        db 0x0B, 0x3A
segTeamChoiceText5:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; AskExportToFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText6:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText7:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText8:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LeagueTeamSelect; used by LP
        db 0x01, 0x37
segTeamChoiceText9:                             ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; FindLeagueFloppy, SelectFloppyDrive; used by LP
        db 0x01, 0x37
segTeamChoiceText10:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; FindLeagueFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText11:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; WaitLeagueFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText12:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportTeamToFloppy; used by LP
        db 0x01, 0x37
segTeamChoiceText13:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyLeagueFiles, ExportDbs, ExportTeamToFloppy ; used by LP
        db 0x01, 0x37
segTeamChoiceText14:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ExportTeamToFloppy; used by LP
        db 0x01, 0x37
segWorkBuffer12:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportMasterLeague; used by LP
        db 0x0B, 0x3A
segTeamChoiceText15:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer13:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText16:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer14:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText17:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x01, 0x37
segWorkBuffer15:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs, ImportPlayerTeam; used by LP
        db 0x0B, 0x3A
segTeamChoiceText18:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segTeamChoiceText19:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segTeamChoiceText20:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ImportPlayerTeam; used by LP
        db 0x01, 0x37
segMenuText20:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ImportDbs; used by LP
        db 0x48, 0x34
segDbFiles12:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ImportDbs; used by LP
        db 0x15, 0x34
segWorkBuffer16:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ExportDbs; used by LP
        db 0x0B, 0x3A
segTeamChoiceText21:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ReadLeagueInfo; used by LP
        db 0x01, 0x37
segWorkBuffer17:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x0B, 0x3A
segTeamChoiceText22:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x01, 0x37
segWorkBuffer18:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CheckMasterPassword; used by LP
        db 0x0B, 0x3A
segTeamChoiceText23:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MsgCopyingDatabases; used by LP
        db 0x01, 0x37
segTeamChoiceText24:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText25:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText26:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CopyHumanTeamDBs; used by LP
        db 0x01, 0x37
segTeamChoiceText27:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; SimulateGame; used by LP
        db 0x01, 0x37
segWorkBuffer19:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawCalendarDay; used by LP
        db 0x0B, 0x3A
segTeamChoiceText28:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; DrawCalendarDay; used by LP
        db 0x01, 0x37
segWorkBuffer20:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame, SetGameSides; used by LP
        db 0x0B, 0x3A
segTeamChoiceText29:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CalendarScreen, PlayLeagueGame, PostGameToTeamDb; used by LP
        db 0x01, 0x37
segTeamChoiceText30:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CalendarScreen; used by LP
        db 0x01, 0x37
segTeamChoiceText31:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckLeagueDiskSync; used by LP
        db 0x01, 0x37
segTeamChoiceText32:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CheckLeagueDiskSync; used by LP
        db 0x01, 0x37
segWorkBuffer21:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PostGameToTeamDb; used by LP
        db 0x0B, 0x3A
segWorkBuffer22:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PostGameToTeamDb; used by LP
        db 0x0B, 0x3A
segWorkBuffer23:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segTeamChoiceText33:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x01, 0x37
segTeamChoiceText34:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x01, 0x37
segWorkBuffer24:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segWorkBuffer25:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x0B, 0x3A
segDgroup6:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0xC9, 0x45
segDbFiles13:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; PlayLeagueGame; used by LP
        db 0x15, 0x34
segTeamChoiceText35:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; RandomizeSchedule, UpdateSeasonSchedule; used by LP
        db 0x01, 0x37
segWorkBuffer26:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segTeamChoiceText36:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x01, 0x37
segWorkBuffer27:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer28:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer29:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segWorkBuffer30:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x0B, 0x3A
segDbFiles14:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; CreateNewLeague; used by LP
        db 0x15, 0x34
segTeamChoiceText37:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster, ExecuteTrade, TradePlayers; used by LP
        db 0x01, 0x37
segTeamChoiceText38:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster; used by LP
        db 0x01, 0x37
segTeamChoiceText39:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; BuildTradeRoster; used by LP
        db 0x01, 0x37
segWorkBuffer31:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; FixJerseyConflict; used by LP
        db 0x0B, 0x3A
segTradeMessages1:                              ; segment constant 382Bh (trade_messages) loaded into es by
                                                ; DrawTradeScreen, TradeScreenLoop; used by LP
        db 0x2B, 0x38
segTeamChoiceText40:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradeHitTest, TradeScreenLoop; used by LP
        db 0x01, 0x37
segMenuText21:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; TradeScreenLoop; used by LP
        db 0x48, 0x34
segCharTable2:                                  ; segment constant 3680h (char_table) loaded into es by
                                                ; TradeScreenLoop; used by LP
        db 0x80, 0x36
segWorkBuffer32:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText41:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x01, 0x37
segWorkBuffer33:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText42:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x01, 0x37
segWorkBuffer34:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; TradePlayers; used by LP
        db 0x0B, 0x3A
segTeamChoiceText43:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, MergeScheduleDb, MergeTeamDbs; used by LP
        db 0x01, 0x37
segTeamChoiceText44:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LocateTeamDbCopy; used by LP
        db 0x01, 0x37
segWorkBuffer35:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, UpdateTeamDbs; used by LP
        db 0x0B, 0x3A
segTeamChoiceText45:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, UpdateTeamDbs; used by LP
        db 0x01, 0x37
segTeamChoiceText46:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; MergeLeagueFiles, UpdateTeamDbs; used by LP
        db 0x01, 0x37
segWorkBuffer36:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, RebuildLeagueDbs; used by
                                                ; LP
        db 0x0B, 0x3A
segWorkBuffer37:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles, MergeUpdateDbs, RebuildLeagueDbs; used by
                                                ; LP
        db 0x0B, 0x3A
segMergeMessages1:                              ; segment constant 3836h (merge_messages) loaded into es by
                                                ; MergeLeagueFiles; used by LP
        db 0x36, 0x38
segWorkBuffer38:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; MergeLeagueFiles; used by LP
        db 0x0B, 0x3A
segTeamChoiceText47:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; PickAwardWinners; used by LP
        db 0x01, 0x37
segDbFiles15:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; BuildSeasonTitle, SetupStatsMenus; used by STATS
        db 0x15, 0x34
segDbFiles16:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; BuildSeasonTitle, SetupStatsMenus; used by STATS
        db 0x15, 0x34
SeasonTitleSegs:                                ; segment words of the season titles (SetupStatsMenus); used
                                                ; by STATS
        db 'K8K8K8K8K8K8K8'
segTeamChoiceText48:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x01, 0x37
segMenuText22:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText23:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText24:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText25:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText26:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText27:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText28:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText29:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText30:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText31:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetupStatsMenus; used by STATS
        db 0x48, 0x34
segMenuText32:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText33:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText34:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segMenuText35:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; SetStatsMenuText; used by STATS
        db 0x48, 0x34
segSeasonTitles1:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles2:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles3:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles4:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segSeasonTitles5:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; GetSeasonTitle; used by STATS
        db 0x4B, 0x38
segWorkBuffer39:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; GoalieStatsCard; used by STATS
        db 0x0B, 0x3A
PoStandingsMode:                                ; playoff standings mode; used by STATS
        db 0xC9, 0x45
segWorkBuffer40:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; GameStandingsMenu; used by STATS
        db 0x0B, 0x3A
segSeasonTitles6:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles7:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles8:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles9:                               ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segSeasonTitles10:                              ; segment constant 384Bh (season_titles) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x4B, 0x38
segWorkBuffer41:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; StatsSelLeague, StatsSelLeaguePlayoffs, StatsSelNhlPlayoffs
                                                ; used by STATS
        db 0x0B, 0x3A
segWorkBuffer42:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; EasnStandingsMenu; used by STATS
        db 0x0B, 0x3A
segWorkBuffer43:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CalStandingsMenu; used by STATS
        db 0x0B, 0x3A
segWorkBuffer44:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; SkaterStatsCard; used by STATS
        db 0x0B, 0x3A
segMenuText36:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ShowPlayoffStandings, StandingsScreen; used by STATS
        db 0x48, 0x34
segDgroup7:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawStandingsPage; used by STATS
        db 0xC9, 0x45
segTeamChoiceText49:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; LoadLeagueSchedule, ShowSeasonStandings; used by STATS
        db 0x01, 0x37
segDbFiles17:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; Gameloop, PlayGame; used by GAME
        db 0x15, 0x34
segDgroup8:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; LoadGameGfx; used by INIT
        db 0xC9, 0x45
segTeamChoiceText50:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x01, 0x37
segLinesMenuText1:                              ; segment constant 38AFh (lines_menu_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0xAF, 0x38
segMenuText37:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x48, 0x34
segWorkBuffer45:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x0B, 0x3A
segDbFiles18:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ShowMatchupScreen; used by INIT
        db 0x15, 0x34
segTeamChoiceText51:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowStartingLineups; used by INIT
        db 0x01, 0x37
segWorkBuffer46:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowStartingLineups; used by INIT
        db 0x0B, 0x3A
JingleSegs:                                     ; segment words of the jingle data (LoadArenaJingles); used by
                                                ; INIT
        db 0xBD, 0x38, 0xBD, 0x38, 0xBD, 0x38, 0xBD, 0x38
segWorkBuffer47:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; DrawPeriodTitle; used by INIT
        db 0x0B, 0x3A
segTeamChoiceText52:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x01, 0x37
segWorkBuffer48:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x0B, 0x3A
segDbFiles19:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x15, 0x34
segWorkBuffer49:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowGameSummary; used by INIT
        db 0x0B, 0x3A
segWorkBuffer50:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; ShowTeamStats; used by INIT
        db 0x0B, 0x3A
segDbFiles20:                                   ; segment constant 3415h (db_files) loaded into es by
                                                ; IntermissionScreens; used by INIT
        db 0x15, 0x34
segWorkBuffer51:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer52:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer53:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PlayTitleMovies; used by INIT
        db 0x0B, 0x3A
segWorkBuffer54:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; CreateGSummaryDb; used by INIT
        db 0x0B, 0x3A
segWorkBuffer55:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segWorkBuffer56:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segWorkBuffer57:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildTeamRoster; used by INIT
        db 0x0B, 0x3A
segTeamChoiceText53:                            ; segment constant 3701h (team_choice_text) loaded into es by
                                                ; GSummaryPath; used by INIT
        db 0x01, 0x37
segMenuText38:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ClearTeamNameText, SetTeamNameText; used by INIT
        db 0x48, 0x34
segMenuText39:                                  ; segment constant 3448h (menu_text) loaded into es by
                                                ; ClearTeamNameText, SetTeamNameText; used by INIT
        db 0x48, 0x34
segAnimSequences1:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xF6, 0x38
segAnimSequences2:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xF6, 0x38
segDgroup9:                                     ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawReplayFrame; used by INIT
        db 0xC9, 0x45
segAnimSequences3:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0xF6, 0x38
segAnimSequences4:                              ; segment constant 38F6h (anim_sequences) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0xF6, 0x38
hmplstats:                                      ; home player stats; used by INIT
        db 0x0B, 0x3A
hmglstats:                                      ; home goalie stats; used by INIT
        db 0x0B, 0x3A
segObjectTable1:                                ; segment constant 3863h (object_table) loaded into es by
                                                ; LoadGameState; used by INIT
        db 0x63, 0x38
segDgroup10:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; PlayHilight; used by AI
        db 0xC9, 0x45
segWorkBuffer58:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; BuildEventLines; used by AI
        db 0x0B, 0x3A
segWorkBuffer59:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; Endfaceoff; used by AI
        db 0x0B, 0x3A
segWorkBuffer60:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PickThreeStars; used by AI
        db 0x0B, 0x3A
segWorkBuffer61:                                ; segment constant 3A0Bh (work_buffer) loaded into es by
                                                ; PickThreeStars; used by AI
        db 0x0B, 0x3A
segDgroup11:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; DrawRinkOverlays; used by AI
        db 0xC9, 0x45
AnimSeqSegs:                                    ; segment words of the animation sequences (DecayCrowdLevel,
                                                ; SetRinkObject); used by AI
        db 0xF6, 0x38, 0xF6, 0x38, 0xF6, 0x38
segDgroup12:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeVenetian; used by FADES1
        db 0xC9, 0x45
segDgroup13:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeVenetian; used by FADES1
        db 0xC9, 0x45
segDgroup14:                                    ; segment constant 45C9h (dgroup) loaded into es by FadeWipe;
                                                ; used by FADES2
        db 0xC9, 0x45
segDgroup15:                                    ; segment constant 45C9h (dgroup) loaded into es by FadeWipe;
                                                ; used by FADES2
        db 0xC9, 0x45
segDgroup16:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadePlaneBands; used by FADES3
        db 0xC9, 0x45
segDgroup17:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadePlaneBands; used by FADES3
        db 0xC9, 0x45
segDgroup18:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeBlockSweep; used by FADES5
        db 0xC9, 0x45
segDgroup19:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeSlideStrips; used by FADES6
        db 0xC9, 0x45
segDgroup20:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeSplitCenter; used by FADES7
        db 0xC9, 0x45
segDgroup21:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeRandomBlocks, FadeRandomBlocks2; used by FADES8
        db 0xC9, 0x45
segDgroup22:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDissolve; used by FADES9
        db 0xC9, 0x45
segDgroup23:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDissolve; used by FADES9
        db 0xC9, 0x45
segDgroup24:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeBoxGrow; used by FADES10
        db 0xC9, 0x45
segDgroup25:                                    ; segment constant 45C9h (dgroup) loaded into es by
                                                ; FadeDirectional; used by FADES11
        db 0xC9, 0x45
DgroupSegC:                                     ; DGROUP paragraph (relocated); used by
                                                ; DrawTextCenteredInWindow
        dw 0x45C9
DgroupSegD:                                     ; DGROUP paragraph (relocated); used by CalibrateStick
        dw 0x45C9
DgroupSegE:                                     ; DGROUP paragraph (relocated); used by DrawTextCenteredClip
        dw 0x45C9
DgroupSegF:                                     ; DGROUP paragraph (relocated); used by AskYesNoBox, PauseBox
        dw 0x45C9
PaletteFlagsSeg:                                ; paragraph of palette_flags; used by ShadeColor
        dw 0x3976
PaletteFlagsSeg2:                               ; paragraph of palette_flags; used by BuildShadeTable
        dw 0x3976
WorkBufferSeg:                                  ; paragraph of work_buffer; used by SendController
        dw 0x3A0B
WorkBufferSeg2:                                 ; paragraph of work_buffer; used by ParseMidiEvent
        dw 0x3A0B
WorkBufferSeg3:                                 ; paragraph of work_buffer; used by RestoreTrackVolumes
        db 0x0B, 0x3A
FpZero:                                         ; the double 0.0; FloatLoad compares against it
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, '<<NMSG>>'
NmsgTable:                                      ; runtime message table: message number word, then the text;
                                                ; searched by the message lookup
        db 0x00, 0x00, 'R6000', 0x0D, 0x0A, '- stack overflow', 0x0D, 0x0A, 0x00, 0x03, 0x00, 'R6003', 0x0D, 0x0A
        db '- integer divide by 0', 0x0D, 0x0A, 0x00, 0x09, 0x00, 'R6009', 0x0D, 0x0A
        db '- not enough space for environment', 0x0D, 0x0A, 0x00, 0xFC, 0x00, 0x0D, 0x0A, 0x00, 0xFF, 0x00
        db 'run-time error ', 0x00, 0x02, 0x00, 'R6002', 0x0D, 0x0A
        db '- floating-point support not loaded', 0x0D, 0x0A, 0x00, 0x01, 0x00, 'R6001', 0x0D, 0x0A
        db '- null pointer assignment', 0x0D, 0x0A, 0x00, 0xFD, 0x00, ': MATH', 0x0D, 0x0A
        db '- floating-point error: ', 0x00, 0x65, 0x00, 'invalid', 0x0D, 0x0A, 0x00, 0x66, 0x00
        db 'denormal', 0x0D, 0x0A, 0x00, 0x67, 0x00, 'divide by 0', 0x0D, 0x0A, 0x00, 0x68, 0x00
        db 'overflow', 0x0D, 0x0A, 0x00, 0x69, 0x00, 'underflow', 0x0D, 0x0A, 0x00, 0x6A, 0x00, 'inexact', 0x0D, 0x0A, 0x00
        db 0x6B, 0x00, 'unemulated', 0x0D, 0x0A, 0x00, 0x6C, 0x00, 'square root', 0x0D, 0x0A, 0x00, 0x6D, 0x00, 0x0D, 0x0A
        db 0x00, 0x6E, 0x00, 'stack overflow', 0x0D, 0x0A, 0x00, 0x6F, 0x00, 'stack underflow', 0x0D, 0x0A, 0x00, 0x70, 0x00
        db 'explicitly generated', 0x0D, 0x0A, 0x00, 0xFF, 0xFF, 0xFF
