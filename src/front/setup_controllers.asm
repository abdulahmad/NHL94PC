; Sets up the controllers for a game (AI.OVL)

;-----------------------------------------------------------------------------
; SetupControllers                                           1F9C:0000  94 PC
; Sets the pad states from the controller choices, MouseOpen 320x200.
;
; Calls MouseOpen, MouseMove.
;-----------------------------------------------------------------------------
SetupControllers:
        cmp word [ctl1team], 0x0
        jnl short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        jmp short .2
        db 0x90
.1:
        cmp word [ctl1side], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        inc ax
.2:
        mov [cont1team], ax
        cmp word [ctl2team], 0x0
        jnl short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        jmp short .4
        db 0x90
.3:
        cmp word [ctl2side], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        inc ax
.4:
        mov [cont2team], ax
        mov ax, [ctl1side]
        cmp [ctl2side], ax
        jnz short .5
        mov ax, 0x1
        jmp short .6
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        mov [samesideflag], ax
        mov ax, [ctl1dev]
        cmp ax, strict word 0x10
        jz short .11
        ja short .12
        dec al
        jz short .7
        dec al
        jz short .8
        sub al, 0x2
        jz short .9
        sub al, 0x4
        jz short .10
        jmp short .12
        db 0x90
.7:
        mov byte [PadStates], 0x1
        jmp short .12
        db 0x90
.8:
        mov byte [PadStates], 0x2
        jmp short .12
        db 0x90
.9:
        mov byte [PadStates], 0x4
        jmp short .12
        db 0x90
.10:
        mov byte [PadStates], 0x8
        jmp short .12
        db 0x90
.11:
        mov byte [PadStates], 0x0
.12:
        mov ax, [ctl2dev]
        cmp ax, strict word 0x10
        jz short .17
        ja short .18
        dec al
        jz short .13
        dec al
        jz short .14
        sub al, 0x2
        jz short .15
        sub al, 0x4
        jz short .16
        jmp short .18
        db 0x90
.13:
        mov byte [PadStates2], 0x1
        jmp short .18
        db 0x90
.14:
        mov byte [PadStates2], 0x2
        jmp short .18
        db 0x90
.15:
        mov byte [PadStates2], 0x4
        jmp short .18
        db 0x90
.16:
        mov byte [PadStates2], 0x8
        jmp short .18
        db 0x90
.17:
        mov byte [PadStates2], 0x0
.18:
        push word 0xc8
        push word 0x140
        call 0x03A3:MouseOpen
        add sp, 0x4
        push 0x64
        push word 0xa0
        call 0x03A3:MouseMove
        add sp, 0x4
