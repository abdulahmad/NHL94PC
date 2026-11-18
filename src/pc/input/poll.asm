; Polls the mouse, joysticks and keyboard and queues an event for each change.
        db (_exit - MscRuntimeStart) >> 8       ; the rest of call 0x0000:_exit from the segment before
        dw 0x0000
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; InputPollTick                                             093A:0008  94 PC
; Every 5th call reads mouse, sticks and keys per the device bits and queues
; an 8-byte event (32 entries).
;-----------------------------------------------------------------------------
InputPollTick:
        enter 0x8, 0x0
        push di
        push si
        call 0x03A3:SsIsDs
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near .11
.1:
        db 0x2B, 0xF6                           ; insn: sub si, si
        dec word [PollCountdown]
        jz short .2
        jmp near .11
.2:
        mov word [PollCountdown], 0x5
        test byte [InputFlags], 0x1
        jz short .3
        lea ax, [bp - 0x8]
        push ax
        push cs
        call PollMouseEvent
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        test byte [InputFlags], 0x2
        jnz short .4
        test byte [InputFlags], 0x4
        jz short .5
.4:
        lea ax, [bp - 0x8]
        push ax
        push cs
        call PollJoystickEvent
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        test byte [InputFlags], 0x8
        jz short .6
        lea ax, [bp - 0x8]
        push ax
        push cs
        call PollKeyboardEvent
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [CursorX], ax
        mov [CursorY], ax
        pop si
        pop di
        leave
        retf
.7:
        cmp word [bp - 0x8], 0x1
        jnz short .8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [CursorX], ax
        mov [CursorY], ax
        jmp short .10
.8:
        mov al, [bp - 0x5]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [CursorX]
        jnz short .9
        inc word [CursorY]
        jmp short .10
        db 0x90
.9:
        mov word [CursorY], 0x0
        mov al, [bp - 0x5]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [CursorX], ax
.10:
        cmp word [InputQueueCount], 0x20
        jz short .11
        mov bx, [InputQueueTail]
        shl bx, byte 0x3
        lea di, [bx + InputQueue]
        lea si, [bp - 0x8]
        mov ax, ds
        mov es, ax
        movsw
        movsw
        movsw
        movsw
        mov al, [InputQueueTail]
        inc al
        and ax, strict word 0x1f
        mov [InputQueueTail], ax
        inc word [InputQueueCount]
.11:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PollMouseEvent                                              093A:00E6  94 PC
; MouseRead, compares with the last buttons and position, fills the event,
; MouseMove.
;-----------------------------------------------------------------------------
PollMouseEvent:
        enter 0x6, 0x0
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [MouseEnabled]
        cmp [bp - 0x6], ax
        jnz short .1
        mov ax, [MousePosX]
        cmp [bp - 0x4], ax
        jnz short .1
        mov ax, [MousePosY]
        cmp [bp - 0x2], ax
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.1:
        mov ax, [bp - 0x4]
        mov [MousePosX], ax
        mov ax, [bp - 0x2]
        mov [MousePosY], ax
        mov bx, [bp + 0x6]
        mov word [bx], 0x1
        cmp word [MouseEnabled], 0x0
        jz short .2
        cmp word [bp - 0x6], 0x0
        jnz short .2
        mov cx, 0x2
        jmp short .3
        db 0x90
.2:
        db 0x2B, 0xC9                           ; insn: sub cx, cx
.3:
        cmp word [bp - 0x6], 0x1
        db 0x1A, 0xC0                           ; insn: sbb al, al
        inc al
        db 0x02, 0xC1                           ; insn: add al, cl
        mov bx, [bp + 0x6]
        mov [bx + 0x2], al
        mov ax, [bp - 0x4]
        mov [bx + 0x4], ax
        mov ax, [bp - 0x2]
        mov [bx + 0x6], ax
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x03A3:MouseMove
        mov ax, [bp - 0x6]
        mov [MouseEnabled], ax
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; PollJoystickEvent                                              093A:0174  94 PC
; PollSticks bits to an event (fire edge and direction).
;-----------------------------------------------------------------------------
PollJoystickEvent:
        enter 0x2, 0x0
        push si
        call 0x03A3:PollSticks
        db 0x8B, 0xF0                           ; insn: mov si, ax
        and si, 0xff
        jnz short .1
        cmp word [StickEnabled], 0x0
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
.1:
        mov bx, [bp + 0x6]
        mov word [bx], 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        and ax, strict word 0x30
        mov [bp - 0x2], ax
        cmp ax, strict word 0x1
        db 0x1A, 0xC0                           ; insn: sbb al, al
        inc al
        mov [bx + 0x2], al
        cmp word [StickEnabled], 0x0
        jz short .2
        cmp word [bp - 0x2], 0x0
        jnz short .2
        add byte [bx + 0x2], 0x2
        mov word [StickEnabled], 0x0
        jmp short .3
.2:
        cmp word [bp - 0x2], 0x0
        jz short .3
        mov word [StickEnabled], 0x1
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        and al, 0xf
        mov [bx + 0x3], al
        mov ax, 0x1
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PollKeyboardEvent                                                093A:01DE  94 PC
; Keypad/arrow scan codes to direction bits, Space/Esc/Enter to buttons,
; KeyJump.
;-----------------------------------------------------------------------------
PollKeyboardEvent:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov word [si], 0x3
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [si + 0x3], al
        mov [si + 0x2], al
        push 0x47
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        or byte [si + 0x3], 0x9
.1:
        push 0x49
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        or byte [si + 0x3], 0x5
.2:
        push 0x4f
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        or byte [si + 0x3], 0xa
.3:
        push 0x51
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        or byte [si + 0x3], 0x6
.4:
        push 0x48
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        or byte [si + 0x3], 0x1
.5:
        push 0x4d
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        or byte [si + 0x3], 0x4
.6:
        push 0x50
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        or byte [si + 0x3], 0x2
.7:
        push 0x4b
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        or byte [si + 0x3], 0x8
.8:
        push 0x39
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        or byte [si + 0x2], 0x8
.9:
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        or byte [si + 0x2], 0x4
.10:
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        or byte [si + 0x2], 0x1
        mov word [KeysEnabled], 0x1
        jmp short .12
        db 0x90
.11:
        cmp word [KeysEnabled], 0x0
        jz short .12
        or byte [si + 0x2], 0x2
        mov word [KeysEnabled], 0x0
.12:
        call 0x03A3:KeyJump
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        or byte [si + 0x2], 0x20
.13:
        cmp byte [si + 0x2], 0x0
        jnz short ReadKeyEventHit + 0x2F0
        cmp byte [si + 0x3], 0x0
        jnz short ReadKeyEventHit + 0x2F0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90
