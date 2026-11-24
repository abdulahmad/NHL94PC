; In-game state: puck, pass and shot state, teams, penalties, the clock, asstab, the sprite
; animation tables (frames.asm), priolist and the line change and overlay timers.
replayptr:                                      ; replay record pointer (offset); used by AI, GAME, INIT
        dw hilightrec_frames + 2
replayseg:                                      ; replay record pointer (segment); used by AI, GAME, INIT
        dw 0x3A0B
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
dirtab:                                         ; direction table: x, y word pairs for the 8 directions (x
                                                ; column; dirtab_y is the y column); used by AI
        db 0x00, 0x00
dirtab_y:                                       ; y components of the direction table (dirtab+2); used by AI
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
%include "data/frames.asm"
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
CoachRotateFour:                                ; coach line table rows: four-line rotation
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x03, 0x02, 0x01, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
CoachRotateThree:                               ; coach line table rows: three-line rotation with the
                                                ; power-play rows after it
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x00, 0x03, 0xFF, 0x00, 0x01, 0x03, 0xFF, 0x00, 0x01, 0x02, 0xFF
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x00, 0x03, 0xFF, 0x03, 0x00, 0x01, 0xFF, 0x00, 0x01, 0x02, 0xFF
CoachRotateThreeTop:                            ; coach line table rows: three lines with the top line first
        db 0x02, 0x01, 0x00, 0xFF, 0x00, 0x02, 0x01, 0xFF, 0x01, 0x02, 0x00, 0xFF, 0x01, 0x00, 0x02, 0xFF
CoachRotateFourEven:                            ; coach line table rows: four lines in even rotation
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x01, 0x02, 0x03, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
CoachRotateFourMixed:                           ; coach line table rows: four lines in mixed rotation
        db 0x02, 0x01, 0x00, 0x03, 0x00, 0x01, 0x03, 0x02, 0x03, 0x02, 0x01, 0x00, 0x01, 0x00, 0x03, 0x02
CoachRotateThreeEven:                           ; coach line table rows: three lines in even rotation
        db 0x02, 0x01, 0x00, 0xFF, 0x00, 0x01, 0x02, 0xFF, 0x02, 0x01, 0x00, 0xFF, 0x01, 0x00, 0x02, 0xFF
CoachSpecialUnits:                              ; coach line table rows: special team units only
        db 0x05, 0x04, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF, 0x04, 0x05, 0xFF, 0xFF
CoachRotateTwo:                                 ; coach line table rows: two lines only
        db 0x01, 0x00, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF
CoachRotateTwoDeep:                             ; coach line table rows: two lines with the third line as
                                                ; backup
        db 0x01, 0x02, 0xFF, 0xFF, 0x02, 0x00, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0xFF
CoachRotateFourShort:                           ; coach line table rows: four lines with short shifts
        db 0x01, 0x02, 0x03, 0xFF, 0x02, 0x03, 0x00, 0xFF, 0x03, 0x00, 0x01, 0xFF, 0x00, 0x01, 0x02, 0xFF
CoachRotateThreeShort:                          ; coach line table rows: three lines with short shifts
        db 0x01, 0x02, 0xFF, 0xFF, 0x00, 0x02, 0xFF, 0xFF, 0x00, 0x01, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0xFF
coachlinetab:                                   ; CompLine: row table of each coach mode (tmcoachmode); used
                                                ; by AI
        dw CoachRotateFour
        dw CoachRotateThree
        dw CoachRotateThreeTop
        dw CoachRotateFourEven
        dw CoachRotateFourMixed
        dw CoachRotateThreeEven
        dw CoachSpecialUnits
        dw CoachRotateTwo
        dw CoachRotateTwoDeep
        dw CoachRotateFourShort
        dw CoachRotateThreeShort
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
ovlartnames:                                    ; .QPP art file name of each text overlay sequence (ovlseq);
                                                ; used by AI, INIT
        dw str_Fanom
        dw str_Goal
        dw str_Clap
        dw str_Uflag
        dw str_Cflag
ovlscripts:                                     ; far pointer to the step script of each text overlay sequence
                                                ; (ovlseq); used by AI, INIT
        dw OvlScriptFanom, 0x3863
        dw OvlScriptGoal, 0x3863
        dw OvlScriptClap, 0x3863
        dw OvlScriptUflag, 0x3863
        dw OvlScriptCflag, 0x3863
ovlseqtimed:                                    ; set for the overlay sequences that get the 258h ovltimer;
                                                ; used by AI
        db 0x01, 0x00, 0x01, 0x01, 0x01
        db 0x00
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
CrowdSound:                                     ; crowd sound handle; used by Crowd_Noise, CrowdFadeOut,
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
