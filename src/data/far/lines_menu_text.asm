; Far data, paragraph 38AFh, 224 bytes: the lines menu text. The EXE's own code does not use it
; (the overlays probably do).
str_AwayLines:                                  ; string 'Away lines'
        db 'Away lines', 0x00
str_Play:                                       ; string 'Play'
        db 'Play', 0x00
str_Cancel:                                     ; string 'Cancel'
        db 'Cancel', 0x00
str_HomeLines:                                  ; string 'Home lines'
        db 'Home lines', 0x00
MatchupMenu:                                    ; menu record ShowMatchupScreen keeps in a local; used by INIT
        db 0x18, 0x00, 0xB9, 0x00, 0x32, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_AwayLines, 0x38AF
        db 0x62, 0x00, 0xB9, 0x00, 0x32, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Play, 0x38AF
        db 0xAC, 0x00, 0xB9, 0x00, 0x32, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_Cancel, 0x38AF
        db 0xF6, 0x00, 0xB9, 0x00, 0x32, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00
        dw str_HomeLines, 0x38AF
str_PenaltyKilling:                             ; string 'Penalty Killing'
        db 'Penalty Killing', 0x00
str_PowerPlay:                                  ; string 'Power Play'
        db 'Power Play', 0x00
str_Shooting:                                   ; string 'Shooting'
        db 'Shooting', 0x00
str_Skating:                                    ; string 'Skating'
        db 'Skating', 0x00
str_Passing:                                    ; string 'Passing'
        db 'Passing', 0x00
str_Defense_5:                                  ; string 'Defense'
        db 'Defense', 0x00
str_Checking:                                   ; string 'Checking'
        db 'Checking', 0x00
str_Goaltending:                                ; string 'Goaltending'
        db 'Goaltending', 0x00
str_OverAll:                                    ; string 'Over all'
        db 'Over all', 0x00
        dw str_PenaltyKilling, 0x38AF
        dw str_PowerPlay, 0x38AF
        dw str_Shooting, 0x38AF
        dw str_Skating, 0x38AF
        dw str_Passing, 0x38AF
        dw str_Defense_5, 0x38AF
        dw str_Checking, 0x38AF
        dw str_Goaltending, 0x38AF
        dw str_OverAll, 0x38AF
