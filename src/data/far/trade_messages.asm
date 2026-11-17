; Far data, paragraph 382Bh, 176 bytes: trade screen messages. The EXE's own code does not use it
; (the overlays probably do).
TradeHitRects:                                  ; hit rectangles of the trade screen boxes (x1, y1, x2, y2)
        db 0x73, 0x00, 0x40, 0x00, 0x73, 0x00, 0x78, 0x00, 0xB4, 0x00, 0x40, 0x00, 0xB4, 0x00, 0x78, 0x00
str_ThereMustBeAnEqual:                         ; string 'There must be an equal'
        db 'There must be an equal', 0x00
str_NumberOfPlayersSelected:                    ; string 'number of players selected'
        db 'number of players selected', 0x00
str_OnBothTeams:                                ; string 'on both teams!'
        db 'on both teams!', 0x00
msgThereMustBeAnEqual:                          ; message list of 3 far string pointers: 'There must be an
                                                ; equal / number of players selected / on both teams!'; used
                                                ; by LP
        dw str_ThereMustBeAnEqual, 0x382B
        dw str_NumberOfPlayersSelected, 0x382B
        dw str_OnBothTeams, 0x382B
str_TheTradingDeadlineHasPassed:                ; string 'The trading deadline has passed!'
        db 'The trading deadline has passed!', 0x00
str_NoMoreTradingIsAllowed:                     ; string 'No more trading is allowed!'
        db 'No more trading is allowed!', 0x00
msgTheTradingDeadlineHasPassed:                 ; message list of 2 far string pointers: 'The trading deadline
                                                ; has passed! / No more trading is allowed!'; used by LP
        dw str_TheTradingDeadlineHasPassed, 0x382B
        dw str_NoMoreTradingIsAllowed, 0x382B
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
