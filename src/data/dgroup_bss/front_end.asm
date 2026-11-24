; Front-end state: playoff tree, dialogs, heap chain, memory blocks, cursor and pad, the current
; event, hot keys, the rink map, other scores, the locker room text, arena jingles and screen saves.
POTreeBuf:                                      ; far pointer (offset) to the playoff tree buffer; used by
                                                ; MENUS
        resb 2
POTreeBufSeg:                                   ; its segment; used by MENUS
        resb 2
DialogData:                                     ; dialog data, offset; used by ListDialog, SaveUnderBox,
                                                ; RunMessageBox ...
        resb 2
DialogDataSeg:                                  ; dialog data, segment; used by ListDialog, SaveUnderBox,
                                                ; RunMessageBox ...
        resb 2
ChainIdx:                                       ; word; used by MakeChain, AllocLinearCanvas, AllocCanvas ...
        resb 2
ChainPtr:                                       ; word; used by MakeChain, DropOldest, FindName ...
        resb 2
HeapVar0:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapList:                                       ; far heap list; used by LargestFreeBlock
        resb 2
HeapVar1:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar2:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar3:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar4:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar5:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar6:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
HeapVar7:                                       ; heap variable; not used by the EXE or the overlays
        resb 2
MemBlock1Off:                                   ; memory block 1, offset; used by LP, MENUS, STATS
        resb 2
MemBlock1Seg:                                   ; memory block 1, segment; used by LP, MENUS, STATS
        resb 2
MemBlock2Off:                                   ; memory block 2, offset; used by DrawCallBanner,
                                                ; DrawTextOverlay, FormatPlayerName
        resb 2
MemBlock2Seg:                                   ; memory block 2, segment; used by DrawCallBanner,
                                                ; DrawTextOverlay, FormatPlayerName
        resb 2
MemBlock3Off:                                   ; memory block 3, offset; used by DrawCallBanner,
                                                ; DrawTextOverlay
        resb 2
MemBlock3Seg:                                   ; memory block 3, segment; used by DrawCallBanner,
                                                ; DrawTextOverlay
        resb 18
InputFlags:                                     ; input device flags; used by InputPollTick
        resb 2
InputQueue:                                     ; input event queue; used by InputPollTick
        resb 256
CursorX:                                        ; cursor x; used by InputPollTick
        resb 2
CursorY:                                        ; cursor y; used by EventToPointer, InputPollTick
        resb 2
PadReadings:                                    ; 3 bytes a pad (stick, buttons, hot key) filled by
                                                ; ReadControllerPad
        resb 150
PadStatePtr:                                    ; pad state being updated; used by ReadJoyPad, SampleInputTick
        resb 2
curevent:                                       ; current game summary event record; used by AI, INIT
        resb 2
curevent_b1:                                    ; current event byte +1; used by AI
        resb 1
curevent_b2:                                    ; current event byte +2; used by AI
        resb 1
curevent_b3:                                    ; current event byte +3; used by AI
        resb 1
curevent_b4:                                    ; current event byte +4; used by AI
        resb 1
curevent_b5:                                    ; current event byte +5; used by AI
        resb 1
curevent_b6:                                    ; current event byte +6; used by AI
        resb 1
curevent_b7:                                    ; current event byte +7; used by AI
        resb 1
curevent_b8:                                    ; current event byte +8; used by AI
        resb 1
curevent_b9:                                    ; current event byte +9; used by AI
        resb 1
curevent_b10:                                   ; current event byte +10; used by AI
        resb 1
goalevent:                                      ; goal event pending (1); used by AI, INIT
        resb 2
goalevent_b1:                                   ; scorer jersey of the goal event; used by AI
        resb 1
goalevent_b2:                                   ; first assist jersey; used by AI
        resb 1
goalevent_b3:                                   ; second assist jersey; used by AI
        resb 1
goalevent_text:                                 ; team abbreviation of the goal event; used by AI
        resb 17
HotKeyFn:                                       ; far routine for hot keys; used by ListDialog,
                                                ; RunMessageBox, SaveGameNameDlg ...
        resb 2
HotKeyFnSeg:                                    ; its segment; used by InputInit
        resb 2
TextOverlayPtr:                                 ; text overlay string pointer (offset); used by AI, GAME,
                                                ; INIT, MENUS
        resb 2
TextOverlaySeg:                                 ; its segment; used by AI, GAME, INIT, MENUS
        resb 2
viewcellx:                                      ; scroll position in 8-pixel cells, x; used by AI, GAME, INIT
        resb 2
viewcelly:                                      ; scroll position in 8-pixel cells, y; used by AI, GAME, INIT
        resb 2
RinkMapWidth:                                   ; rink map width in cells; used by INIT
        resb 2
RinkRowBytes:                                   ; bytes per rink row; used by GAME, INIT
        resb 2
otherscoresb:                                   ; other games: scores (12 bytes); used by INIT
        resb 12
otherscorehome:                                 ; other games: home team bytes; used by INIT
        resb 1
otherscorehome_b1:                              ; other games: home team bytes from +1; used by INIT
        resb 11
otherscoreaway:                                 ; other games: away team bytes; used by INIT
        resb 1
otherscores:                                    ; other games: away team bytes from +1; used by INIT
        resb 11
scrolldelay:                                    ; scroll redraw countdown; used by GAME, INIT
        resb 2
TeamPalette1:                                   ; first team palette; used by LoadTeamPalettes
        resb 67
PanelText:                                      ; panel text bytes (DrawHudPanel); used by AI, MENUS
        resb 189
TeamPalette2:                                   ; second team palette; used by LoadTeamPalettes
        resb 5
LockerText1:                                    ; locker room text byte 1; used by MENUS
        resb 2
LockerText2:                                    ; locker room text from +2; used by MENUS
        resb 9
LockerText3:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText4:                                    ; locker room text bytes; used by MENUS
        resb 2
LockerText5:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText6:                                    ; locker room text bytes; used by MENUS
        resb 2
LockerText7:                                    ; locker room text block; used by MENUS
        resb 45
PanelText2:                                     ; panel text bytes; used by AI, MENUS
        resb 6
LockerText8:                                    ; locker room text block; used by MENUS
        resb 7
LockerText9:                                    ; locker room text byte; used by MENUS
        resb 1
LockerText10:                                   ; locker room text block; used by MENUS
        resb 15
LockerText11:                                   ; locker room text block; used by MENUS
        resb 155
LockerText12:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText13:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText14:                                   ; locker room text byte; used by MENUS
        resb 1
LockerText15:                                   ; locker room text block; used by MENUS
        resb 8
ArenaJingleSet:                                 ; arena jingle per team; used by PlayArenaJingle
        resb 2
BoxSaveX:                                       ; box save x; used by PlayArenaJingle, SaveUnderBox,
                                                ; RestoreUnderBox
        resb 2
BoxSaveY:                                       ; box save y; used by SaveUnderBox, RestoreUnderBox
        resb 2
YesNoText:                                      ; askYesNo text, offset; used by AskYesNo
        resb 2
YesNoTextSeg:                                   ; askYesNo text, segment; used by AskYesNo
        resb 2
MessageBoxSel:                                  ; message box selection (FFFFh for none); used by
                                                ; MessageBoxReset
        resb 2
ArenaJingleArg1:                                ; arena jingle argument; used by PlayArenaJingle
        resb 2
ArenaJingleArg2:                                ; arena jingle argument; used by PlayArenaJingle
        resb 2
JingleSongOff:                                  ; jingle song, offset; used by PlayJingle
        resb 2
JingleSongSeg:                                  ; jingle song, segment; used by PlayJingle
        resb 2
JingleBufOff:                                   ; jingle buffer, offset; used by PlayJingle
        resb 2
JingleBufSeg:                                   ; jingle buffer, segment; used by PlayJingle
        resb 2
JingleTempo:                                    ; jingle tempo (14h); used by PlayJingle
        resb 5
JingleChannel:                                  ; jingle channel (FFh); used by PlayJingle
        resb 1
JingleVolume:                                   ; jingle volume (3Fh); used by PlayJingle
        resb 1
JinglePan:                                      ; jingle pan; used by PlayJingle
        resb 5
ArenaJingleA:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleASeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 2
JingleBuf1:                                     ; jingle buffer pointer 1 (offset); used by INIT
        resb 2
JingleBuf1Seg:                                  ; its segment; used by INIT
        resb 2
JingleBuf2:                                     ; jingle buffer pointer 2 (offset); used by INIT
        resb 2
JingleBuf2Seg:                                  ; its segment; used by INIT
        resb 2
ArenaJingleB:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleBSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 2
JingleBuf3:                                     ; jingle buffer pointer 3 (offset); used by INIT
        resb 2
JingleBuf3Seg:                                  ; its segment; used by INIT
        resb 2
JingleBuf4:                                     ; jingle buffer pointer 4 (offset); used by INIT
        resb 2
JingleBuf4Seg:                                  ; its segment; used by INIT
        resb 2
JingleCfgBufs:                                  ; jingle config buffer pointers (offset); used by INIT
        resb 2
JingleCfgBufsSeg:                               ; their segments; used by INIT
        resb 10
JingleKmsBufs:                                  ; jingle song buffer pointers (offset); used by INIT
        resb 2
JingleKmsBufsSeg:                               ; their segments; used by INIT
        resb 10
ArenaJingleC:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleCSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 22
ArenaJingleD:                                   ; arena jingle table; used by PlayArenaJingle
        resb 2
ArenaJingleDSeg:                                ; arena jingle table, segment; used by PlayArenaJingle
        resb 22
VgaSave0Off:                                    ; saved plane 0, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave0Seg:                                    ; saved plane 0, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave1Off:                                    ; saved plane 1, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave1Seg:                                    ; saved plane 1, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave2Off:                                    ; saved plane 2, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave2Seg:                                    ; saved plane 2, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave3Off:                                    ; saved plane 3, offset; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
VgaSave3Seg:                                    ; saved plane 3, segment; used by SaveVgaPlanes,
                                                ; RestoreVgaPlanes
        resb 2
editopts:                                       ; option bits being edited by the settings dialogs; used by
                                                ; MENUS
        resb 1
editopts_b1:                                    ; high byte of editopts; used by MENUS
        resb 1
editctlopts:                                    ; controller option bits being edited; used by MENUS
        resb 2
