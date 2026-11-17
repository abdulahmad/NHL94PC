; Far data, paragraph 38F0h, 96 bytes: messages for saving highlights. The EXE's own code does not use it
; (the overlays probably do).
str_InsufficientDiskSpaceTo:                    ; string 'Insufficient disk space to'
        db 'Insufficient disk space to', 0x00
str_SaveHilights:                               ; string 'save hilights.'
        db 'save hilights.', 0x00
str_CurrentHilightNotSaved:                     ; string 'Current hilight not saved.'
        db 'Current hilight not saved.', 0x00
msgInsufficientDiskSpaceToSave:                 ; message list of 3 far string pointers: 'Insufficient disk
                                                ; space to / save hilights. / Current hilight not saved.';
                                                ; used by INIT
        dw str_InsufficientDiskSpaceTo, 0x38F0
        dw str_SaveHilights, 0x38F0
        dw str_CurrentHilightNotSaved, 0x38F0
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
