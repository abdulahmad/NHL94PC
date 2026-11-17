; Turns keys, joysticks and the mouse into game-pad bits, and reads hot keys.

;-----------------------------------------------------------------------------
; ReadKeyEventHit                                             0969:0000  94 PC
; Tail of ReadKeyEvent in the next paragraph: return 1.
;-----------------------------------------------------------------------------
ReadKeyEventHit:
        mov ax, 0x1
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; KeysToPad                                                   0969:0006  94 PC
; Arrow and keypad scan codes through DirBitsToPad, Ins/Enter/Alt/Space to
; pad buttons.
;-----------------------------------------------------------------------------
KeysToPad:
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        push 0x48
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov si, 0x1
.1:
        push 0x50
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        or si, 0x2
.2:
        push 0x4b
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        or si, 0x8
.3:
        push 0x4d
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        or si, 0x4
.4:
        push 0x47
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        or si, 0x9
.5:
        push 0x49
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        or si, 0x5
.6:
        push 0x51
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        or si, 0x6
.7:
        push 0x4f
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        or si, 0xa
.8:
        mov al, [si + KeyPadMap]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push 0x52
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
.9:
        push 0x38
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        push 0x39
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
.10:
        or si, 0x40
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        retf
        db 0x90
.11:
        push 0x52
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        push 0x38
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .12
        push 0x39
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
.12:
        or si, 0x20
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        retf
        db 0x90
.13:
        or si, 0x10
.14:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StickToPad                                                  0969:0120  94 PC
; Stick bits (low or high byte of StickPollBits) to pad direction and
; buttons.
;-----------------------------------------------------------------------------
StickToPad:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        cmp word [bx + StickPresent], 0x0
        jnz short .1
        mov ax, 0x8
        pop si
        pop di
        leave
        retf
.1:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .2
        mov cl, 0x8
        mov si, [PadStatePtr]
        sar si, cl
        jmp short .3
.2:
        mov si, [PadStatePtr]
        and si, 0xff
.3:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        and bx, 0xf
        mov al, [bx + KeyPadMap]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        and al, 0x10
        jz short .4
        test si, 0x20
        jz short .4
        or dl, 0x40
        jmp short .6
        db 0x90
.4:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        and al, 0x10
        jz short .5
        or dl, 0x10
        jmp short .6
        db 0x90
.5:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        test al, 0x20
        jz short .6
        or dl, 0x20
.6:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MouseToPad                                                  0969:018A  94 PC
; Mouse offset from the centre (160,100) to a direction when far enough,
; buttons to pad buttons.
;-----------------------------------------------------------------------------
MouseToPad:
        push di
        push si
        call far [MousePosFn]
        mov ax, [MouseX]
        sub ax, 0xa0
        mov dx, [MouseX]
        sub dx, 0xa0
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x64
        mov bx, [MouseY]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov dx, 0x64
        mov si, [MouseY]
        db 0x2B, 0xD6                           ; insn: sub dx, si
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x03A3:ImulRegs
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jg short .2
        jl short .1
        cmp si, 0x9c4
        jnc short .2
.1:
        mov si, 0x8
        jmp short .3
        db 0x90
.2:
        mov ax, [MouseX]
        sub ax, 0xa0
        mov dx, 0x64
        mov cx, [MouseY]
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        call 0x0D5F:VectorToDir8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        test byte [MouseBtn], 0x1
        jz short .4
        test byte [MouseBtn], 0x2
        jz short .4
        or si, 0x40
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        retf
.4:
        test byte [MouseBtn], 0x1
        jz short .5
        or si, 0x10
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        retf
        db 0x90
.5:
        test byte [MouseBtn], 0x2
        jz short .6
        or si, 0x20
.6:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadPadDevice                                               0969:0224  94 PC
; Pad of one player from the device in PadDevice (8 keys, 2 stick 1, 4 stick
; 2, 1 mouse).
;-----------------------------------------------------------------------------
ReadPadDevice:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        cmp byte [si + PadStates], 0x8
        jnz short .1
        push cs
        call KeysToPad
        jmp short .6
.1:
        cmp byte [si + PadStates], 0x2
        jnz short .3
        push 0x0
.2:
        push cs
        call StickToPad
        add sp, 0x2
        jmp short .6
.3:
        cmp byte [si + PadStates], 0x4
        jnz short .4
        push 0x1
        jmp short .2
        db 0x90
.4:
        cmp byte [si + PadStates], 0x1
        jnz short .5
        push cs
        call MouseToPad
        jmp short .6
        db 0x90
.5:
        mov al, 0x8
.6:
        mov bx, [bp + 0x8]
        mov [bx], al
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ReadHotKey                                                  0969:026E  94 PC
; Esc, Ctrl+S, Ctrl+M, F1-F10, Tab and R with a repeat guard; bit 7 set on a
; new key.
;-----------------------------------------------------------------------------
ReadHotKey:
        enter 0x2, 0x0
        mov byte [bp - 0x1], 0x0
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov byte [bp - 0x1], 0x1
        jmp near .16
        db 0x90
.1:
        push 0x1d
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push 0x1f
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        mov byte [bp - 0x1], 0x1f
        jmp near .16
        db 0x90
.2:
        push 0x32
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        jmp near .16
.3:
        mov byte [bp - 0x1], 0x32
        jmp near .16
.4:
        push 0x3b
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        mov byte [bp - 0x1], 0x3b
        jmp near .16
        db 0x90
.5:
        push 0x3c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        mov byte [bp - 0x1], 0x3c
        jmp near .16
        db 0x90
.6:
        push 0x3d
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        mov byte [bp - 0x1], 0x3d
        jmp near .16
        db 0x90
.7:
        push 0x3e
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        mov byte [bp - 0x1], 0x3e
        jmp near .16
        db 0x90
.8:
        push 0x3f
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        mov byte [bp - 0x1], 0x3f
        jmp near .16
        db 0x90
.9:
        push 0x40
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        mov byte [bp - 0x1], 0x40
        jmp short .16
        db 0x90, 0x90
.10:
        push 0x41
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        mov byte [bp - 0x1], 0x41
        jmp short .16
.11:
        push 0x42
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .12
        mov byte [bp - 0x1], 0x42
        jmp short .16
.12:
        push 0x43
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        mov byte [bp - 0x1], 0x43
        jmp short .16
.13:
        push 0x44
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        mov byte [bp - 0x1], 0x44
        jmp short .16
.14:
        push 0xf
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        mov byte [bp - 0x1], 0xf
        jmp short .16
.15:
        push 0x13
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        mov byte [bp - 0x1], 0x13
.16:
        cmp byte [HotKeyPending], 0x0
        jz short .18
        mov al, [bp - 0x1]
        cbw
        mov cl, [HotKeyPending]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnz short .17
        mov [bp - 0x1], ch
        jmp short .19
.17:
        mov byte [HotKeyPending], 0x0
        jmp short .19
        db 0x90
.18:
        mov al, [bp - 0x1]
        mov [HotKeyPending], al
.19:
        cmp byte [bp - 0x1], 0x0
        jz short .20
        or byte [bp - 0x1], 0x80
.20:
        mov al, [bp - 0x1]
        mov bx, [bp + 0x6]
        mov [bx], al
        leave
        retf

;-----------------------------------------------------------------------------
; PadTimerTick                                                0969:03FE  94 PC
; Timer slot: every 4th tick records both players' pads into the 50-entry pad
; ring.
;-----------------------------------------------------------------------------
PadTimerTick:
        push si
        call 0x03A3:SsIsDs
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near PadTimerTickTail.1 + 0x490
.1:
        cmp word [PadRepeatOn], 0x0
        jnz short .2
        jmp near PadTimerTickTail.1 + 0x490
.2:
        cmp word [PadTickCount], 0x3e8
        jnl short .3
        inc word [PadTickCount]
.3:
        mov ax, [PadRepeatTimer]
        dec word [PadRepeatTimer]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short PadTimerTickTail.1 + 0x490
        mov word [PadRepeatTimer], 0x4
        cmp word [PadRepeatDelay], 0x32
        jnl short PadTimerTickTail.1 + 0x490
        mov ax, [PadRepeatDelay]
        add ax, [PadRepeatStep]
        mov cx, 0x32
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        test byte [PadStates], 0x6
        jnz short .4
        test byte [PadStates2], 0x6
        jz short .5
.4:
        call 0x03A3:PollSticks
        mov [PadStatePtr], ax
.5:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, PadReadings
        push si
        push 0x0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push cs
        call ReadPadDevice
        add sp, 0x4
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, PadReadings + 1
        push si
        push 0x1
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push cs
        call ReadPadDevice
        add sp, 0x4
        add si, PadReadings + 2
        push si
        push cs
        db 0xE8, (ReadHotKey - ($ + 3)) & 0xFF  ; call near ReadHotKey: the last byte is in the next segment
