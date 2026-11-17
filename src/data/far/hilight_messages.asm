; Far data, paragraph 35F3h, 336 bytes: highlight replay messages. The EXE's own code does not use it
; (the overlays probably do).
str_ThereAreNoHilights:                         ; string 'There are no hilights!'
        db 'There are no hilights!', 0x00
msgThereAreNoHilights:                          ; message list of 1 far string pointer: 'There are no
                                                ; hilights!'; used by MENUS
        dw str_ThereAreNoHilights, 0x35F3
str_ThereIsNotEnoghSpace:                       ; string 'There is not enogh space on'
        db 'There is not enogh space on', 0x00
str_TheFloppyDiskForThe:                        ; string 'the floppy disk for the hilights!'
        db 'the floppy disk for the hilights!', 0x00
str_SelectLessHilightsOrGet:                    ; string 'Select less hilights or get another disk.'
        db 'Select less hilights or get another disk.', 0x00
        dw str_ThereIsNotEnoghSpace, 0x35F3
        dw str_TheFloppyDiskForThe, 0x35F3
        dw str_SelectLessHilightsOrGet, 0x35F3
str_ThereIsNotEnoghSpace_2:                     ; string 'There is not enogh space on'
        db 'There is not enogh space on', 0x00
str_TheHardDiskForThe:                          ; string 'the hard disk for the hilights!'
        db 'the hard disk for the hilights!', 0x00
str_TrySelectingLessHilights:                   ; string 'Try selecting less hilights.'
        db 'Try selecting less hilights.', 0x00
        dw str_ThereIsNotEnoghSpace_2, 0x35F3
        dw str_TheHardDiskForThe, 0x35F3
        dw str_TrySelectingLessHilights, 0x35F3
str_TheHilight:                                 ; string 'The hilight'
        db 'The hilight', 0x00
str_AlreadyExists:                              ; string 'already exists.'
        db 'already exists.', 0x00
        dw str_TheHilight, 0x35F3
        db 0x00, 0x00, 0x00, 0x00
        dw str_AlreadyExists, 0x35F3
str_ExportingHilights:                          ; string 'Exporting hilights'
        db 'Exporting hilights', 0x00, 'Importing hilights', 0x00
        dw str_ExportingHilights, 0x35F3
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
