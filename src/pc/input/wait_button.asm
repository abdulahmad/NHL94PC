; WaitButtonTimed: waits for a button or a time-out.

;-----------------------------------------------------------------------------
; WaitButtonTimed                                             0C16:0000  94 PC
; Reads events through CursorHandler until a click, a double click or the
; time runs out.
;-----------------------------------------------------------------------------
WaitButtonTimed:
        enter 0x14, 0x0
        push di
        push si
        call 0x03A3:ReadCallCount
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0xc], si
.1:
        mov [bp - 0x6], si
        call 0x0F99:GetInputEvent
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .2
        jmp near .9
.2:
        lea ax, [bp - 0x12]
        push ax
        lea ax, [bp - 0x14]
        push ax
        push di
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x2], ax
        test al, 0x2
        jz short .5
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        call 0x03A3:ReadCallCount
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        jmp short .4
        db 0x90
.3:
        mov word [bp - 0xc], 0xffff
.4:
        inc si
.5:
        mov [bp - 0x6], si
        test byte [bp - 0x2], 0x4
        jz short .9
        mov di, 0x3
        mov word [bp - 0xc], 0xffff
.6:
        call 0x03A3:ReadCallCount
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .8
        sub ax, [bp - 0x10]
        sbb dx, [bp - 0xe]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .8
        jg short .7
        cmp ax, strict word 0x14
        jna short .8
.7:
        mov word [bp - 0xc], 0xffff
.8:
        cmp word [bp - 0xc], 0x0
        jnz short WaitButtonTimedTail + 0xC0
        mov [bp - 0x6], di
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        sub ax, [bp - 0xa]
        sbb dx, [bp - 0x8]
        cmp dx, [bp + 0x8]
        jl short .10
        jg short WaitButtonTimedTail + 0xC0
        cmp ax, [bp + 0x6]
        jc short .10
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        db 0x90
.9:
        mov di, [bp - 0x6]
        jmp short .6
        db 0x90
.10:
        db 0x8B, 0xF7                           ; insn: mov si, di
        jmp near .1
        db 0x90
