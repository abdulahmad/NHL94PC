; The movie player's names and the screen fade tables.
str_AMvi:                                       ; string 'A MVI'; used by MOVIE
        db 'A MVI', 0x00
str_Databuffer:                                 ; string 'DATABUFFER'; used by MOVIE
        db 'DATABUFFER', 0x00, 0x00
WipeDirX:                                       ; x step per wipe direction (FadeWipe); used by FADES2
        db 0x01, 0x00, 0xFF, 0xFF
        db 0x01, 0x00, 0xFF, 0xFF
WipeDirY:                                       ; y step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x00, 0x01, 0x00
WipeDirX2:                                      ; second x step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0x01, 0x00
        db 0xFF, 0xFF, 0x01, 0x00
WipeDirY2:                                      ; second y step per wipe direction; used by FADES2
        db 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x00, 0x01, 0x00
PlaneBandPattern:                               ; band pattern of FadePlaneBands; used by FADES3
        db 0x0B, 0x05, 0x08, 0x02
        db 0x0A, 0x04, 0x07, 0x01, 0x09, 0x03, 0x06, 0x00, 0x01, 0x03, 0x06, 0x00, 0x05, 0x07, 0x02, 0x04
        db 0x07, 0x05, 0x02, 0x08, 0x03, 0x01, 0x06, 0x04, 0x01, 0x03, 0x00, 0x02, 0x03, 0x01, 0x04, 0x02
FadeInSteps:                                    ; fade step table (FadePaletteIn); used by FADES4
        db 0x01
FadeInStep:                                     ; current fade-in step; used by FADES4
        db 0x0F
FadeInSteps2:                                   ; second fade-in step table; used by FADES4
        db 0x01, 0xFF
FadeInCount:                                    ; fade-in step count; used by FADES4
        db 0x11, 0xFF
BlockSweepDX:                                   ; x direction per sweep pattern (FadeBlockSweep); used by
                                                ; FADES5
        db 0x02, 0x00, 0x00, 0x00
BlockSweepDY:                                   ; y direction per sweep pattern; used by FADES5
        db 0xFF, 0x01, 0x01, 0x00
BlockSweepOrder:                                ; sweep order bytes; used by FADES5
        db 0xFF, 0x03
        db 0x06, 0x00
