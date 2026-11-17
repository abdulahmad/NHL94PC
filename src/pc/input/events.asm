; The input event queue: read the next event, flush the queue. The first bytes finish
; UseDbDescriptor.

;-----------------------------------------------------------------------------
; UseDbDescriptorTail                                         0F99:0000  94 PC
; The end of UseDbDescriptor in the next paragraph (the overlay call).
;-----------------------------------------------------------------------------
UseDbDescriptorTail:                            ; end of UseDbDescriptor
        db 0x34                                 ; last byte of push word 3415h from the segment before
        push strict word lgstate
.1:
        call 0x1B35:WriteModeStateThunk
        add sp, 0x4
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GetInputEvent                                               0F99:000E  94 PC
; Runs pending hooks, then pops the next 8-byte event from the queue, or 0.
;-----------------------------------------------------------------------------
GetInputEvent:
        cmp word [EventPending], 0x0
        jz short .1
        call 0x0C15:NullFar2
        mov word [EventPending], 0x0
.1:
        mov es, [InputEventDataSeg]
        cmp word [es:0x0], 0x0
        jz short .2
        call 0x0837:0x10                        ; NineCmp: offset past the end of RecFlag's segment, through
                                                ; that segment's base
        call 0x0837:NullFar
        call 0x0837:0x10                        ; NineCmp: offset past the end of RecFlag's segment, through
                                                ; that segment's base
        mov es, [InputEventDataSeg]
        mov word [es:0x0], 0x0
.2:
        cmp word [InputQueueCount], 0x0
        jnz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
.3:
        dec word [InputQueueCount]
        mov al, [InputQueueHead]
        inc al
        and ax, strict word 0x1f
        mov [InputQueueHead], ax
        shl ax, byte 0x3
        add ax, 0xaed0
        retf

;-----------------------------------------------------------------------------
; FlushInputEvents                                            0F99:0066  94 PC
; Empties the event queue.
;-----------------------------------------------------------------------------
FlushInputEvents:
        mov word [InputQueueHead], 0x1f
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        db 0xA3, 0x08
