; Front-end data: input set-up, save game names, text and dialog colours, team palettes, crowd,
; screen saves, the controls dialog, highlights, the title screen and the line editor.
InputInstalled:                                 ; input hooks installed; used by InputInit, InputRemove
        dw 0x0000
MouseRangeX:                                    ; mouse range in x; used by InputInit, InputRemove,
                                                ; EventToPointer
        dw 0x0000
MouseRangeY:                                    ; mouse range in y; used by InputInit, InputRemove
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
str_GsummaryDb:                                 ; string 'gsummary.db'; used by SaveGame
        db 'gsummary.db', 0x00
str_GsummaryDb_2:                               ; string 'gsummary.db'; used by SaveGame
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
str_Gsummary:                                   ; string 'gsummary'; used by SaveGame
        db 'gsummary', 0x00
        db 'A3', 0x00
str_Pointer:                                    ; string 'pointer'; used by SaveGameNameDlg
        db 'pointer', 0x00
str_Savegame:                                   ; string 'savegame'; used by SaveGameNameDlg
        db 'savegame', 0x00
str_Prmt:                                       ; string 'prmt'; used by SaveGameNameDlg
        db 'prmt', 0x00
str_Dialog:                                     ; string 'dialog'; used by SaveGameNameDlg
        db 'dialog', 0x00
str_Nhl:                                        ; string '.nhl'; used by SaveGameNameDlg
        db '.nhl', 0x00
str_Err1:                                       ; string 'err1'; used by SaveGameNameDlg
        db 'err1', 0x00
str_Dialog_2:                                   ; string 'dialog'; used by SaveGameNameDlg
        db 'dialog', 0x00
str_Nhl_2:                                      ; string '.nhl'; used by SaveGameNameDlg
        db '.nhl', 0x00
str_Prmt_2:                                     ; string 'prmt'; used by SaveGameNameDlg
        db 'prmt', 0x00
str_Dialog_3:                                   ; string 'dialog'; used by SaveGameNameDlg
        db 'dialog', 0x00
str_D:                                          ; string '%d\n'; used by SaveGameNameDlg
        db 0x25, 0x64, 0x0A, 0x00
str_Nhl_3:                                      ; string '.nhl'; used by SaveGameNameDlg
        db '.nhl', 0x00, 0x00
TextColor:                                      ; text colour for the shadow and outline text; used by
                                                ; SetTextColors, DrawShadowTextCentered, PrintShadowText ...
        dw 0x000F
ShadowColor:                                    ; shadow colour; used by SetTextColors,
                                                ; DrawShadowTextCentered, PrintShadowText ...
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
str_HomepalsBin:                                ; string 'HOMEPALS.BIN'; used by LoadTeamPalettes
        db 'HOMEPALS.BIN', 0x00
str_AwaypalsBin:                                ; string 'AWAYPALS.BIN'; used by LoadTeamPalettes
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
                                                ; SetListItemColors, DrawListRow ...
        dw 0x003F
ItemSelectColor:                                ; selected list item colour; used by NumberEntryDialog,
                                                ; SetListItemColors, DrawListRow ...
        db 0x00, 0x00, 0x00, 0x00
SaveUnderOff:                                   ; saved screen under a box, offset; used by SaveUnderBox,
                                                ; RestoreUnderBox
        dw 0x0000
SaveUnderSeg:                                   ; saved screen under a box, segment; used by SaveUnderBox,
                                                ; RestoreUnderBox
        dw 0x0000
str_Pointer_2:                                  ; string 'Pointer'; used by ListDialog
        db 'Pointer', 0x00
str_Dbox:                                       ; string 'DBOX'; used by SaveUnderBox
        db 'DBOX', 0x00
str_Pointer_3:                                  ; string 'Pointer'; used by RunMessageBox
str_Pointer_15:                                 ; string 'Pointer'; used by AI
        db 'Pointer', 0x00, 0x00
JingleHandle:                                   ; playing jingle, low word (-1 for none); used by StopJingle,
                                                ; PlayJingle, WaitJingle
        dw 0xFFFF
JingleHandleHi:                                 ; playing jingle, high word; used by StopJingle, PlayJingle,
                                                ; WaitJingle
        dw 0xFFFF
Crowdlevel:                                     ; crowd noise level the crowd update ramps; used by
                                                ; Crowd_Noise, CrowdNoiseReset
        dw 0x0000
CrowdTarget:                                    ; crowd level being faded to; used by Crowd_Noise,
                                                ; CrowdNoiseOff, CrowdNoiseReset
        dw 0x0000
CrowdFade:                                      ; crowd fade step; used by Crowd_Noise, CrowdNoiseOff,
                                                ; CrowdNoiseReset
        dw 0x0000
str_Plane0:                                     ; string 'Plane 0'; used by SaveVgaPlanes
        db 'Plane 0', 0x00
str_Plane1:                                     ; string 'Plane 1'; used by SaveVgaPlanes
        db 'Plane 1', 0x00
str_Plane2:                                     ; string 'Plane 2'; used by SaveVgaPlanes
        db 'Plane 2', 0x00
str_Plane3:                                     ; string 'Plane 3'; used by SaveVgaPlanes
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
