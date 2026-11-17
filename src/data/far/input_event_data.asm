; Far data, paragraph 342Eh, 16 bytes: the input event buffer.
InputEventFlag:                                 ; word; nonzero makes GetInputEvent run its reset calls and
                                                ; clear it
        dw 0
        times 14 db 0
