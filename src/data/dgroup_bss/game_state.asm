; In-game state: crowd, replay, sprite frames, object lists, faceoffs, game variables, the HUD
; panel, the replay controls and the line tables.
lastgoaly:                                      ; last goal position y; used by AI
        resb 2
crowdcount:                                     ; crowd counter; used by AI, INIT
        resb 2
cleared1:                                       ; game variable cleared by cleargamevars; used by AI
        resb 2
cleared2:                                       ; game variable cleared by cleargamevars; used by AI
        resb 2
crowdsum:                                       ; crowd excitement sum (low); used by AI, INIT
        resb 2
crowdsumhi:                                     ; crowd excitement sum (high); used by AI, INIT
        resb 2
replayrecptr:                                   ; replay record pointer (offset); used by AI, GAME, INIT
        resb 2
replayrecseg:                                   ; replay record pointer (segment); used by AI, GAME, INIT
        resb 2
replayplay:                                     ; replay play pointer (offset); used by INIT
        resb 2
replayplayseg:                                  ; replay play pointer (segment); used by INIT
        resb 2
plstatsoff:                                     ; player stats offsets; used by AI
        resb 2
plstatsoff2:                                    ; player stats offsets, second word; used by AI
        resb 2
plstatsoff3:                                    ; player stats offsets, third word; used by AI
        resb 2
plstatsrecs:                                    ; player stats offset table (394 bytes); used by AI
        resb 394
gameclock2:                                     ; game clock copy; used by AI, INIT
        resb 2
rinkobjs:                                       ; rink object slots; used by AI, INIT
        resb 2
rinkobjs_w2:                                    ; rink object slots word +2; used by INIT
        resb 278
SpriteFrames:                                   ; sprite frame pointers (offset); used by AI, INIT
        resb 2
SpriteFramesSeg:                                ; sprite frame pointers; used by AI, INIT
        resb 382
NumberFrames:                                   ; number sprite frames; used by AI, INIT
        resb 2
NumberFramesSeg:                                ; number sprite frames; used by AI, INIT
        resb 14
NumberFrames2:                                  ; second number sprite frames; used by AI, INIT
        resb 2
NumberFrames2Seg:                               ; second number sprite frames; used by AI, INIT
        resb 18
gameframe:                                      ; game frame counter; used by AI, GAME, INIT
        resb 2
lcrequest:                                      ; per team: line change requested by number (F1-F4, F5-F8 in
                                                ; HandleHotKey); doinput hands it to lcselect, then clears it;
                                                ; used by AI, GAME, INIT
        resb 2
        resb 2
lcreqchoice:                                    ; per team: the requested line choice passed to lcselect; used
                                                ; by AI, GAME, INIT
        resb 2
        resb 2
objxlist:                                       ; object x list (34 bytes); used by AI
        resb 34
objylist:                                       ; object y list (34 bytes); used by AI, INIT
        resb 34
textline3:                                      ; text line 3; used by AI, INIT
        resb 59
OOlist_m1:                                      ; byte before OOlist; used by AI
        resb 1
OOlist:                                         ; sorted object order list; OOlist_m1 and OOlist_b1 are its
                                                ; neighbours; used by AI, INIT
        resb 1
OOlist_b1:                                      ; OOlist from +1; used by AI
        resb 17
textline1:                                      ; text line 1; used by AI, INIT
        resb 60
textline2:                                      ; text line 2; used by AI, INIT
        resb 60
textline4:                                      ; text line 4; used by AI, INIT
        resb 60
textline5:                                      ; text line 5; used by AI, INIT
        resb 60
PlList:                                         ; player list; used by AI, INIT
        resb 6
LinePlayersAway:                                ; away line players; used by AI
        resb 6
fofdata2:                                       ; faceoff data; used by AI, INIT
        resb 2
fofdata:                                        ; faceoff data word; used by AI
        resb 2
fofdata_w2:                                     ; faceoff data word +2; used by AI
        resb 2
fofdata_w4:                                     ; faceoff data word +4; used by AI
        resb 2
fofdata_w6:                                     ; faceoff data word +6; used by AI
        resb 2
fofdata_w8:                                     ; faceoff data word +8; used by AI
        resb 2
mousex:                                         ; mouse x; used by GAME, INIT
        resb 2
mousey:                                         ; mouse y; used by GAME, INIT
        resb 2
savedword1:                                     ; game variable saved with the game; used by INIT
        resb 2
savedword2:                                     ; game variable saved with the game; used by INIT
        resb 2
puckcross:                                      ; where the puck crosses the goal lines; used by INIT
        resb 2
GoalState_m6:                                   ; home goal state byte; used by AI
        resb 1
GoalState_m5:                                   ; home goal state bytes; used by AI
        resb 3
GoalState_m2:                                   ; away goal state byte; used by AI
        resb 1
GoalState_m1:                                   ; away goal state byte; used by AI
        resb 1
GoalState:                                      ; goal state; used by AI, INIT
        resb 2
lj1:                                            ; last pad state of controller 1; used by AI, INIT
        resb 2
lj2:                                            ; last pad state of controller 2; used by AI, INIT
        resb 2
lasttouch:                                      ; last player to touch the puck; used by AI, INIT
        resb 2
ltx:                                            ; last touch x; used by AI, INIT
        resb 2
lty:                                            ; last touch y; used by AI, INIT
        resb 2
iflags:                                         ; icing flags; used by AI, INIT
        resb 1
iflags_b1:                                      ; iflags high byte; used by AI
        resb 1
OverlayGfx:                                     ; text overlay graphics pointer (offset); used by AI, INIT
        resb 2
OverlayGfxSeg:                                  ; its segment; used by AI, INIT
        resb 2
OverlayFrames:                                  ; text overlay frames; used by AI, INIT
        resb 2
OverlayFramesSeg:                               ; text overlay frames; used by AI, INIT
        resb 38
overlaytimer:                                   ; text overlay timer; used by AI, INIT
        resb 2
overlaystate:                                   ; text overlay state (1..5); used by AI, INIT
        resb 2
overlayscript:                                  ; text overlay script pointer (offset); used by AI, INIT
        resb 2
overlayscriptseg:                               ; its segment; used by AI, INIT
        resb 2
scorerflags:                                    ; scorer milestone flags; used by AI, INIT
        resb 1
scorerflags2:                                   ; second scorer milestone flags; used by AI, INIT
        resb 1
gamevar1:                                       ; game variable saved with the game; used by INIT
        resb 1
gamevar2:                                       ; game variable cleared by ResetGameVars; used by INIT
        resb 1
gamevar3:                                       ; game variable saved with the game; used by INIT
        resb 2
gamevar4:                                       ; game variable saved with the game; used by INIT
        resb 2
stoppagetime:                                   ; clock at the last stoppage; used by AI, INIT
        resb 2
gamevar5:                                       ; game variable saved with the game; used by INIT
        resb 2
regd0:                                          ; register-style work variable d0; used by AI, INIT
        resb 1
regd0_b1:                                       ; regd0 high byte; used by INIT
        resb 1
regd0_w2:                                       ; regd0 high word; used by AI, INIT
        resb 2
gamevar6:                                       ; game variable saved with the game; used by INIT
        resb 2
regd1:                                          ; register-style work variable d1; used by AI, INIT
        resb 1
regd1_b1:                                       ; regd1 byte +1; used by AI
        resb 1
regd1_w2:                                       ; regd1 high word; used by AI
        resb 2
PenBuf:                                         ; penalty buffer (penalty, player); used by AI
        resb 1
PenBuf_pl:                                      ; penalty buffer player byte; used by AI
        resb 1
PenBuf_b2:                                      ; penalty buffer from +2; used by AI
        resb 64
regd2:                                          ; register-style work variable d2; used by AI, INIT
        resb 2
regd2_w2:                                       ; regd2 high word; used by AI
        resb 2
gamevar7:                                       ; game variable saved with the game; used by INIT
        resb 2
gamevar8:                                       ; game variable saved with the game; used by INIT
        resb 2
regd3:                                          ; register-style work variable d3; used by AI
        resb 2
regd3_w2:                                       ; regd3 high word; used by AI
        resb 2
crowdheat:                                      ; crowd heat, raised by goals and shots; used by AI, INIT
        resb 2
PBnum:                                          ; home penalty box count; used by AI, INIT
        resb 1
PBnum_b1:                                       ; away penalty box count (PBnum+1); used by AI
        resb 1
regd4:                                          ; register-style work variable d4; used by AI, INIT
        resb 2
regd4_w2:                                       ; regd4 high word; used by AI
        resb 2
viewscrollx:                                    ; view scroll x; used by AI, GAME, INIT
        resb 2
ovltimer2:                                      ; frame timer of the replay and intro loops; used by AI, GAME,
                                                ; INIT
        resb 2
frameaccum:                                     ; frame accumulator; used by AI, GAME, INIT
        resb 2
hudhundaccum:                                   ; panel hundredths accumulator; used by AI, GAME, INIT
        resb 2
GameGfx:                                        ; game graphics pointer (offset); used by AI, INIT
        resb 2
GameGfxSeg:                                     ; its segment; used by AI, INIT
        resb 2
NumberSprites:                                  ; jersey number sprites; used by GAME
        resb 2
NumberSpritesSeg:                               ; jersey number sprites; used by GAME
        resb 38
NumberSprites2:                                 ; second jersey number sprites; used by GAME
        resb 2
NumberSprites2Seg:                              ; second jersey number sprites; used by GAME
        resb 26
RinkEndFrames:                                  ; rink end frames pointer (offset); used by GAME, INIT
        resb 2
RinkEndFramesSeg:                               ; rink end frames; used by GAME, INIT
        resb 10
hudhundstep:                                    ; panel hundredths step; used by AI, GAME, INIT
        resb 686
dirtycount:                                     ; dirty rectangle counts per page; used by GAME
        resb 4
rinkobjused:                                    ; rink object frame bits; used by AI, INIT
        resb 32
hilightslots:                                   ; highlight slot words; used by INIT
        resb 12
MovieBuf:                                       ; movie buffer pointer (offset); used by INIT
        resb 2
MovieBufSeg:                                    ; its segment; used by INIT
        resb 2
PanelShapes:                                    ; panel shapes; used by AI
        resb 2
PanelShapes_b2:                                 ; panel shapes from +2; used by AI
        resb 1
PanelShapes_b3:                                 ; panel shapes from +3; used by MENUS
        resb 29
PanelClockShape:                                ; panel clock shape pointer; used by AI, INIT
        resb 2
PanelClockShapeSeg:                             ; its segment; used by AI, INIT
        resb 2
PanelScoreShape:                                ; panel score shape pointer; used by AI, INIT
        resb 2
PanelScoreShapeSeg:                             ; its segment; used by AI, INIT
        resb 26
PenaltyShapes:                                  ; panel penalty shapes; used by AI
        resb 2
PenaltyShapesSeg:                               ; panel penalty shapes; used by AI
        resb 38
PenaltyShape:                                   ; panel penalty shape; used by AI
        resb 2
PenaltyShapeSeg:                                ; its segment; used by AI
        resb 2
ClockDigits:                                    ; panel clock digit shapes; used by AI
        resb 2
ClockDigitsSeg:                                 ; panel clock digit shapes; used by AI
        resb 38
ClockColonShape:                                ; panel clock colon shape; used by AI
        resb 2
clockcolon:                                     ; panel clock colon state; used by AI
        resb 2
ScoreDigits:                                    ; panel score digit shapes; used by AI
        resb 2
ScoreDigitsSeg:                                 ; panel score digit shapes; used by AI
        resb 42
ReplayFont:                                     ; replay font pointer (offset); used by AI, INIT
        resb 2
ReplayFontSeg:                                  ; its segment; used by AI, INIT
        resb 2
replaymousex:                                   ; replay pointer x; used by INIT
        resb 2
replaymousey:                                   ; replay pointer y; used by INIT
        resb 2
replaydx:                                       ; replay pointer x step; used by INIT
        resb 2
replayspeed:                                    ; replay speed; used by INIT
        resb 2
ReplayGadgets:                                  ; replay gadget shapes; used by INIT
        resb 2
ReplayGadgetsSeg:                               ; replay gadget shapes; used by INIT
        resb 2
ReplayGadgets2:                                 ; further replay gadget shapes; used by INIT
        resb 8
ReplayPanel:                                    ; replay panel shape; used by INIT
        resb 2
ReplayPanelSeg:                                 ; its segment; used by INIT
        resb 2
ReplayPanels:                                   ; further replay panel shapes; used by INIT
        resb 20
ReplayPointer:                                  ; replay pointer shape; used by INIT
        resb 2
ReplayPointerSeg:                               ; its segment; used by INIT
        resb 2
ReplayPointers:                                 ; further replay pointer shapes; used by INIT
        resb 14
ReplayBack:                                     ; replay background shape; used by INIT
        resb 2
ReplayBackSeg:                                  ; its segment; used by INIT
        resb 2
ReplayBack2:                                    ; second replay background shape; used by INIT
        resb 2
replaysaved:                                    ; replay saved flag; used by INIT
        resb 2
replayplaying:                                  ; replay playing flag; used by INIT
        resb 2
replaystart:                                    ; replay start frame; used by INIT
        resb 2
replayend:                                      ; replay end frame; used by INIT
        resb 2
replayptrx:                                     ; replay pointer x; used by INIT
        resb 2
replaypick:                                     ; player picked in the replay; used by INIT
        resb 2
replayfollow:                                   ; player the replay follows (-1 none); used by INIT
        resb 2
replayfollow2:                                  ; previous followed player; used by INIT
        resb 2
replayfwd:                                      ; replay direction; used by INIT
        resb 2
replaybutton:                                   ; replay button pressed; used by INIT
        resb 2
replaystep:                                     ; replay step; used by INIT
        resb 2
replaysavestate:                                ; replay save state; used by INIT
        resb 2
rpl_x:                                          ; replay frame: object x; used by INIT
        resb 28
rpl_puckx:                                      ; replay frame: puck x; used by INIT
        resb 2
rpl_puckframe:                                  ; replay frame: puck frame; used by INIT
        resb 4
rpl_y:                                          ; replay frame: object y; used by INIT
        resb 28
rpl_pucky:                                      ; replay frame: puck y; used by INIT
        resb 2
rpl_shadow:                                     ; replay frame: puck shadow; used by INIT
        resb 4
rpl_frame:                                      ; replay frame: object frame; used by INIT
        resb 28
rpl_reff:                                       ; replay frame: referee frame; used by INIT
        resb 2
rpl_door:                                       ; replay frame: door frame; used by INIT
        resb 4
rpl_flags:                                      ; replay frame: object flags; used by INIT
        resb 17
rpl_jerseys:                                    ; replay frame: jerseys; used by INIT
        resb 12
rpl_puckowner:                                  ; replay frame: puck owner; used by INIT
        resb 1
rpl_bytes:                                      ; replay frame bytes; used by INIT
        resb 12
rpl_camx:                                       ; replay frame: camera x; used by INIT
        resb 2
rpl_word:                                       ; replay frame word; used by INIT
        resb 2
rpl_b1:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b2:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b3:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b4:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b5:                                         ; replay frame bytes; used by INIT
        resb 2
rpl_w1:                                         ; replay frame word; used by INIT
        resb 2
rpl_w2:                                         ; replay frame word; used by INIT
        resb 2
rpl_words:                                      ; replay frame words; used by INIT
        resb 40
rpl_b6:                                         ; replay frame byte; used by INIT
        resb 1
rpl_b7:                                         ; replay frame bytes; used by INIT
        resb 19
rpl_words2:                                     ; replay frame words; used by INIT
        resb 34
defertab_a1:                                    ; deferred call argument 1; used by AI
        resb 2
defertab_a2:                                    ; deferred call argument 2; used by AI
        resb 2
defertab_a3:                                    ; deferred call argument 3; used by AI
        resb 2
defertab_a4:                                    ; deferred call argument 4; used by AI
        resb 2
defertab_a5:                                    ; deferred call argument 5; used by AI
        resb 2
defertab_a6:                                    ; deferred call argument 6; used by AI
        resb 2
defertab_a7:                                    ; deferred call argument 7; used by AI
        resb 2
defertab_fn:                                    ; deferred call routine offset; used by AI
        resb 2
defertab_seg:                                   ; deferred call routine segment; used by AI
        resb 56
gsumqueue:                                      ; queued game summary records; used by AI
        resb 96
lastimpact:                                     ; last impact; used by AI
        resb 2
gwgplayer:                                      ; game-winning goal player; used by AI
        resb 2
gwgteam:                                        ; game-winning goal team; used by AI
        resb 2
introtimers:                                    ; intro timers; used by AI
        resb 52
offsort_fwd:                                    ; forwards sorted by rating; used by AI
        resb 50
defsort_d:                                      ; defencemen sorted by rating; used by AI
        resb 400
dressflags:                                     ; home dressed flags; used by AI
        resb 25
dressflags_aw:                                  ; away dressed flags; used by AI
        resb 25
lineslotmark:                                   ; line slot marks; used by AI
        resb 50
possort:                                        ; players sorted by position; used by AI
        resb 50
dresseddefs:                                    ; dressed defencemen; used by AI
        resb 2
dressedfwds:                                    ; dressed forwards; used by AI
        resb 2
dressedskaters:                                 ; dressed skaters; used by AI
        resb 2
fadex:                                          ; fade area x; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadey:                                          ; fade area y; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadew:                                          ; fade area width; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
fadeh:                                          ; fade area height; used by FADES, FADES10, FADES11, FADES12,
                                                ; FADES5, FADES6, FADES8
        resb 2
