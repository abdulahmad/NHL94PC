; Far data, paragraph 36F5h, 192 bytes: "returning to" messages. The EXE's own code does not use it
; (the overlays probably do).
        db 'Returning to sports central', 0x00, 'Returning to the league calendar', 0x00
        db 'Returning to the playoff tree', 0x00, 'Exiting the game', 0x00
str_MayLoseThisGameS:                           ; string 'may lose this game's data.'
        db 'may lose this game', 0x27, 's data.', 0x00, 'Do you wish to return?', 0x00
        db 'Do you wish to exit?', 0x00
dlgReturnMessages:                              ; MessageBox definition with the 'returning to' messages; used
                                                ; by MENUS
        db 0x00, 0x00, 0x00, 0x00
        dw str_MayLoseThisGameS, 0x36F5
        db 0x00, 0x00, 0x00, 0x00, 0x00
