; The start-up stack.
StackBottom:                                    ; the 1800h-byte startup stack (the EXE header puts SS here,
                                                ; SP
                                                ; 1800h); MscStartup moves it into DGROUP
        resb 0x1800
