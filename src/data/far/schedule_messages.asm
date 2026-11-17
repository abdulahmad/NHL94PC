; Far data, paragraph 3827h, 64 bytes: schedule generation messages. Used by RandomizeSchedule.
str_GeneratingRandomSchedule:                   ; string 'Generating random schedule.'
        db 'Generating random schedule.', 0x00
str_PleaseWait_2:                               ; string 'Please wait.'
        db 'Please wait.', 0x00
msgGeneratingRandomSchedulePleaseWait:          ; message list of 2 far string pointers: 'Generating random
                                                ; schedule. / Please wait.'; used by LP
        dw str_GeneratingRandomSchedule, 0x3827
        dw str_PleaseWait_2, 0x3827
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
