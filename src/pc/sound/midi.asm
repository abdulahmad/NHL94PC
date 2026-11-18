; MIDI output: controller, pitch bend, program change with note on, and note off messages.
        dw FindUnlink, 0x06E1                   ; the rest of call 0x06E1:FindUnlink from the segment before
        add sp, 0x4
        jmp near SaveGameNameDlg.13 - 0xA20

;-----------------------------------------------------------------------------
; MidiControl                                                 0CC4:000A  94 PC
; B0h.
;-----------------------------------------------------------------------------
MidiControl:
        enter 0x4, 0x0
        mov al, [bp + 0x8]
        or al, 0xb0
        mov [bp - 0x4], al
        mov byte [bp - 0x3], 0x7
        mov al, [bp + 0xa]
        mov [bp - 0x2], al
        push 0x3
        lea ax, [bp - 0x4]
        push ax
        mov al, [bp + 0x6]
        push ax
        call 0x1630:QueueMidiBytes
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MidiPitchBend                                               0CC4:0032  94 PC
; E0h.
;-----------------------------------------------------------------------------
MidiPitchBend:
        enter 0x4, 0x0
        mov al, [bp + 0x8]
        or al, 0xe0
        mov [bp - 0x4], al
        mov byte [bp - 0x3], 0x0
        mov al, [bp + 0xa]
        mov [bp - 0x2], al
        push 0x3
        lea ax, [bp - 0x4]
        push ax
        mov al, [bp + 0x6]
        push ax
        call 0x1630:QueueMidiBytes
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MidiProgramNoteOn                                           0CC4:005A  94 PC
; C0h.
;-----------------------------------------------------------------------------
MidiProgramNoteOn:
        enter 0xa, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [bp + 0x8]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xCE                           ; insn: mov cx, si
        or al, 0xc0
        mov [bp - 0x6], al
        mov al, [bp + 0xc]
        mov [bp - 0x5], al
        push 0x2
        lea ax, [bp - 0x6]
        push ax
        db 0x8B, 0xD7                           ; insn: mov dx, di
        push dx
        mov [bp - 0x8], cx
        mov [bp - 0xa], dx
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        mov al, [bp - 0x8]
        or al, 0x90
        mov [bp - 0x6], al
        mov al, [bp + 0xa]
        mov [bp - 0x5], al
        mov byte [bp - 0x4], 0x40
        push 0x3
        lea ax, [bp - 0x6]
        push ax
        mov al, [bp - 0xa]
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MidiNoteOff                                                 0CC4:00B4  94 PC
; 80h.
;-----------------------------------------------------------------------------
MidiNoteOff:
        enter 0x4, 0x0
        mov al, [bp + 0x8]
        or al, 0x80
        mov [bp - 0x4], al
        mov al, [bp + 0xa]
        mov [bp - 0x3], al
        mov byte [bp - 0x2], 0x0
        push 0x3
        lea ax, [bp - 0x4]
        push ax
