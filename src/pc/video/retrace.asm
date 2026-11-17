; CalibrateRetrace: times the vertical retrace to calibrate the frame pacing.
        call 0x0FEF:DrawChar
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CalibrateRetrace                                            156A:000C  94 PC
; Times vertical retraces and sets the retrace wait count RetraceWait.
;-----------------------------------------------------------------------------
CalibrateRetrace:
        enter 0x2, 0x0
        push di
        push si
        call 0x0000:_disable
        call 0x0FEF:WaitRetraceStart
.1:
        call 0x03A3:0x33E0                      ; BlankBit: offset past the end of WaitBlank's segment,
                                                ; through that segment's base
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov word [bp - 0x2], 0x1
        mov di, 0xa
.2:
        push word 0x2710
        call 0x0FEF:WaitRetraceCount
        pop bx
        mov si, 0x2710
        db 0x2B, 0xF0                           ; insn: sub si, ax
        cmp si, [bp - 0x2]
        jng short .3
        mov [bp - 0x2], si
.3:
        dec di
        jnz short .2
        call 0x0000:_enable
        mov ax, [bp - 0x2]
        mov [RetraceCount], ax
        imul ax, ax, 0x5
        sar ax, byte 0x2
        add ax, strict word 0x4
        mov [RetraceWait], ax
        pop si
        pop di
        leave
