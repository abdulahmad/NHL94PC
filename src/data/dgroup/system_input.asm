; EMS, heap and unpacker state, the start-up messages, and the input queue, mouse and pad state.
EmsMapCache:                                    ; four words. Each is the logical page last mapped on that
                                                ; physical page. The high bit marks it stale; used by EmsMap,
                                                ; EmsMapRange, EmsMarkStale ...
        dw 0xFFFF
EmsMapCache2:                                   ; second EMS map cache word; not used by the EXE or the
                                                ; overlays
        dw 0xFFFF
EmsMapCache3:                                   ; third EMS map cache word; not used by the EXE or the
                                                ; overlays
        dw 0xFFFF
EmsMapCache4:                                   ; fourth EMS map cache word; not used by the EXE or the
                                                ; overlays
        dw 0xFFFF
EmsWindowOff:                                   ; added to the offset within the page when EmsMapRange returns
                                                ; a pointer; used by EmsMapRange
        db 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0xC0
EmsOutPtr:                                      ; far pointer EmsInit writes the allocated size through; used
                                                ; by MakeChain, EmsInit
        dw 0x0000
EmsFramePrev:                                   ; word before EmsFrame; not used by the EXE or the overlays
        dw 0x0000
EmsFrame:                                       ; page-frame segment from INT 67h AH=41h; used by EmsMapRange,
                                                ; EmsInit, EmsMapFrame
        dw 0x0000
EmsHandle:                                      ; EMS handle from INT 67h AH=43h. -1 means none; used by
                                                ; EmsMap, EmsInit, EmsFree
        dw 0xFFFF
EmmName:                                        ; eight bytes compared with the device name at offset 10 of
                                                ; the INT 67h vector; used by EmsInit
        db 'EMMXXXX0initmemman - INSUFFICIENT ROW TABLE SPACE'
        db 0x0A, 0x00
str_LowMem:                                     ; string 'LOW MEM'; not used by the EXE or the overlays
        db 'LOW MEM', 0x00
str_HighMem:                                    ; string 'HIGH MEM'; not used by the EXE or the overlays
        db 'HIGH MEM', 0x00
str_LowEmm:                                     ; string 'LOW EMM'; not used by the EXE or the overlays
        db 'LOW EMM', 0x00
str_HighEmm:                                    ; string 'HIGH EMM'; not used by the EXE or the overlays
        db 'HIGH EMM', 0x00, 0x00
BufCount:                                       ; word; used by MakeChain
        dw 0x03E8
BufPtr:                                         ; word; used by MakeChain, AllocLinearCanvas, AllocCanvas ...
        dw 0x0000
RecSeq:                                         ; word; used by MakeChain, DropOldest
        dw 0x0000
str_ReservememOutOfMemoryRequested:             ; string 'reservemem - OUT OF MEMORY\nrequested: %ld
                                                ; available: %ld\n'; not used by the EXE or the overlays
        db 'reservemem - OUT OF MEMORY'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememOutOfMemoryRequested_2:           ; string 'reservemem - OUT OF MEMORY\nrequested: %ld
                                                ; available: %ld\n'; not used by the EXE or the overlays
        db 'reservemem - OUT OF MEMORY'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememOutOfEmsRequested:                ; string 'reservemem - OUT OF EMS\nrequested: %ld available:
                                                ; %ld\n'; not used by the EXE or the overlays
        db 'reservemem - OUT OF EMS'
        db 0x0A, 'requested: %ld available: %ld'
        db 0x0A, 0x00
str_ReservememInvalidTypeFlags04x:              ; string 'reservemem - INVALID TYPE FLAGS (%04x)\n'; not used
                                                ; by the EXE or the overlays
        db 'reservemem - INVALID TYPE FLAGS (%04x)'
        db 0x0A, 0x00
str_ResizememblockNoRoomToResize:               ; string 'resizememblock - NO ROOM TO RESIZE\n'; not used by
                                                ; the EXE or the overlays
        db 'resizememblock - NO ROOM TO RESIZE'
        db 0x0A, 0x00, 'findmemblock - BLOCK NOT FOUND (%Fp)'
        db 0x0A, 0x00
str_GetmemblockNoMemoryBlocksLeft:              ; string 'getmemblock - NO MEMORY BLOCKS LEFT\n'; not used by
                                                ; the EXE or the overlays
        db 'getmemblock - NO MEMORY BLOCKS LEFT'
        db 0x0A, 0x00
str_Copyright:                                  ; string 'Copyright'; used by NullInputHookWrap
        db 'Copyright', 0x00
str_UnpackaInvalidPackCodeX:                    ; string 'unpacka - INVALID PACK CODE (%x)'; used by AddCopy
        db 'unpacka - INVALID PACK CODE (%x)'
        db 0x00, 0x00
str_InsufficientConventionalMemoryAvaila:       ; string 'Insufficient conventional memory available. Requires
                                                ; an addi...'; not used by the EXE or the overlays
        db 'Insufficient conventional memory available. Requires an additional %ld K'
        db ' bytes', 0x0A, 0x00
str_InsufficientEmsAvailableRequiresAn:         ; string 'Insufficient EMS available. Requires an additional
                                                ; %ld K byt...'; not used by the EXE or the overlays
        db 'Insufficient EMS available. Requires an additional %ld K bytes'
        db 0x0A, 0x00
str_Pointer3:                                   ; string 'pointer3'; not used by the EXE or the overlays
        db 'pointer3', 0x00
str_Pntr:                                       ; string 'pntr'; not used by the EXE or the overlays
        db 'pntr', 0x00
str_Wittle06Fnt:                                ; string 'wittle06.fnt'; not used by the EXE or the overlays
        db 'wittle06.fnt', 0x00
str_Scor2bFnt:                                  ; string 'scor2b.fnt'; not used by the EXE or the overlays
        db 'scor2b.fnt', 0x00
str_Scor3bFnt:                                  ; string 'scor3b.fnt'; not used by the EXE or the overlays
        db 'scor3b.fnt', 0x00
str_GameSet:                                    ; string 'game.set'; not used by the EXE or the overlays
        db 'game.set', 0x00
        db 'd3', 0x00, 'd4', 0x00
str_Temp:                                       ; string 'temp'; not used by the EXE or the overlays
        db 'temp', 0x00
str_Temp_2:                                     ; string 'temp'; not used by the EXE or the overlays
        db 'temp', 0x00
InputQueueCount:                                ; events waiting (at most 32); used by GetInputEvent,
                                                ; InputPollTick
        dw 0x0000
InputQueueHead:                                 ; next event to read; used by GetInputEvent, FlushInputEvents
        dw 0x001F
InputQueueTail:                                 ; next free event slot; used by InputPollTick
        dw 0x0000
PollCountdown:                                  ; polls until the next device read (reset to 5); used by
                                                ; InputPollTick
        dw 0x000A
MouseEnabled:                                   ; mouse read when non-zero; used by PollMouseEvent
        dw 0x0000
StickEnabled:                                   ; joysticks read when non-zero; used by PollJoystickEvent
        dw 0x0000
KeysEnabled:                                    ; keyboard read when non-zero; used by PollKeyboardEvent
        dw 0x0000
MousePosX:                                      ; last mouse x; used by EventToPointer, PollMouseEvent
        dw 0x0000
MousePosY:                                      ; last mouse y; used by EventToPointer, PollMouseEvent
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
StickPresent:                                   ; joystick 1 present; used by ReadJoyPad
        dw 0x0000
StickPresent2:                                  ; joystick 2 present; not used by the EXE or the overlays
        dw 0x0000
PadTickCount:                                   ; timer ticks counted by SampleInputTick (wraps at 1000);
                                                ; used by
                                                ; SampleInputTick
        dw 0x0000
PadRepeatOn:                                    ; key repeat active; used by SampleInputTick
        dw 0x0000
PadRepeatStep:                                  ; repeat interval; used by SampleInputTick
        dw 0x0000
PadRepeatDelay:                                 ; first repeat delay; used by SampleInputTick,
                                                ; PadTimerTickTail
        dw 0x0000
PadRepeatTimer:                                 ; ticks left before the next repeat; used by SampleInputTick
        dw 0x0000
PadStates:                                      ; state byte per pad; used by ReadControllerPad,
                                                ; SampleInputTick
        db 0x08
PadStates2:                                     ; second pad's state byte; used by SampleInputTick
        db 0x02
HotKeyPending:                                  ; hot key waiting to be read; used by ReadHotKeys
        db 0x00, 0x00
KeyPadMap:                                      ; keys to pad bits; used by ReadKeyboardPad, ReadJoyPad
        db 0x08, 0x00, 0x04, 0x08, 0x02, 0x01, 0x03, 0x02, 0x06, 0x07, 0x05, 0x06, 0x08, 0x00, 0x04, 0x08, 'pause.msc'
        db 0x00
