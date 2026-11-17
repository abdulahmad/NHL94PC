; Far data, paragraph 35E8h, 64 bytes: save progress messages. Used by SaveGame.
str_SavingCurrent:                              ; string 'Saving Current'
        db 'Saving Current', 0x00
str_LeagueGame:                                 ; string 'League Game.'
        db 'League Game.', 0x00
str_PlayOffGame:                                ; string 'Play-Off Game.'
        db 'Play-Off Game.', 0x00
msgSavingLeagueGame:                            ; message lines of the saving league game box
        dw str_SavingCurrent, 0x35E8
        dw str_LeagueGame, 0x35E8
msgSavingPlayoffGame:                           ; message lines of the saving play-off game box
        dw str_SavingCurrent, 0x35E8
        dw str_PlayOffGame, 0x35E8
        db 0x00, 0x00, 0x00, 0x00, 0x00
