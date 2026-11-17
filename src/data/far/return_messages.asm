; Far data, paragraph 36F5h, 192 bytes: "returning to" messages. The EXE's own code does not use it
; (the overlays probably do).
        db 'Returning to sports central'
        db 0x00, 'Returning to the league calendar'
        db 0x00, 'Returning to the playoff tree'
        db 0x00, 'Exiting the game'
        db 0x00, 'may lose this game', 0x27, 's data.'
        db 0x00, 'Do you wish to return?'
        db 0x00, 'Do you wish to exit?'
        db 0x00
dlgReturnMessages:                              ; MessageBox definition with the 'returning to' messages; used
                                                ; by MENUS
        db 0x00, 0x00, 0x00, 0x00
        db 0x6C, 0x00, 0xF5, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00
