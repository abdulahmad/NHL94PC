; EA sound library sequencer, the timer side: the tick that steps each track and sends its MIDI
; events (notes, controllers, voice changes). The first bytes finish MergeRemapTables.
        db 0x00

;-----------------------------------------------------------------------------
; MergeRemapTablesTail                                       1630:0001  EACLIB
; End of MergeRemapTables, which starts in the file before.
;-----------------------------------------------------------------------------
MergeRemapTablesTail:
        add [si - 0x2d], di
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SeqTimerTick                                               1630:0008  EACLIB
; Timer hook: runs SeqService unless busy, re-entered or no driver is loaded.
;-----------------------------------------------------------------------------
SeqTimerTick:
        push ds
        mov ax, DGROUP
        mov ds, ax
        call 0x03A3:SsIsDs
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        cmp word [SeqBusy], 0x0
        jnz short .1
        cmp word [SeqLock], 0x0
        jnz short .1
        cmp word [DriverCount], 0x0
        jz short .1
        inc word [SeqBusy]
        call 0x1630:SeqService
        dec word [SeqBusy]
.1:
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SeqService                                                 1630:003C  EACLIB
; Services the driver (EMS map saved) and steps every playing track.
;-----------------------------------------------------------------------------
SeqService:
        enter 0xa, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        inc byte [SeqTickCount]
        cmp byte [DriverServiceIdx], 0xff
        jz short .1
        push 0x8
        mov al, [DriverServiceIdx]
        push ax
        call 0x1844:DrvNeedsService
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x8f74
        call 0x03A3:EmsSaveMap
        pop bx
        mov al, [DriverServiceIdx]
        push ax
        call 0x1844:DrvService
        pop bx
        push word 0x8f74
        call 0x03A3:EmsRestoreMap
        pop bx
.1:
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .4
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cmp al, [DriverServiceIdx]
        jz short .3
        push ax
        call 0x1844:DrvService
        pop bx
.3:
        inc si
.4:
        cmp [DriverCount], si
        ja short .2
        call 0x1630:FlushMidiQueue
        cmp word [TracksMuted], 0x0
        jz short .5
        jmp near .13
.5:
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4], dx
        db 0x33, 0xFF                           ; insn: xor di, di
.6:
        mov es, [bp - 0x4]
        cmp byte [es:si + 0x56], 0x0
        jnz short .7
        jmp near .9
.7:
        test byte [es:si + 0x56], 0x8
        jz short .8
        mov al, [SeqTickCount]
        les bx, [es:si + 0x4]
        cmp [es:bx + 0x15], al
        jz short .8
        mov es, [bp - 0x4]
        les bx, [es:si + 0x4]
        mov [es:bx + 0x15], al
        mov es, [bp - 0x4]
        les bx, [es:si + 0x4]
        cmp word [es:bx + 0xe], 0x0
        jz short .8
        mov es, [bp - 0x4]
        les bx, [es:si + 0x4]
        mov ax, [es:bx + 0xe]
        dec word [es:bx + 0xe]
        mov [bp - 0x2], ax
        mov es, [bp - 0x4]
        les bx, [es:si + 0x4]
        mov ax, [es:bx + 0xc]
        cwd
        push dx
        push ax
        push word [bp - 0x2]
        mov [bp - 0xa], bx
        mov [bp - 0x8], es
        call 0x0000:_abs
        pop bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        les bx, [bp - 0xa]
        mov al, [es:bx + 0x10]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul cx
        push dx
        push ax
        call 0x0000:__aFldiv
        les bx, [bp - 0xa]
        mov [es:bx + 0x11], al
.8:
        push word [bp - 0x4]
        push si
        call 0x1630:SeqStepTrack
        add sp, 0x4
.9:
        add si, 0x58
        inc di
        cmp di, 0x18
        jnc short .10
        jmp near .6
.10:
        mov ax, [Voices]
        mov dx, [VoicesSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x33, 0xFF                           ; insn: xor di, di
.11:
        cmp di, 0x20
        jnc short .13
        mov es, [bp - 0x2]
        cmp byte [es:si + 0x5], 0xff
        jnz short .12
        sub word [es:si + 0x8], 0x1
        sbb word [es:si + 0xa], 0x0
        mov ax, [es:si + 0xa]
        or ax, [es:si + 0x8]
        jnz short .12
        push word [bp - 0x2]
        push si
        call 0x1630:SendVoiceNoteOff
        add sp, 0x4
.12:
        add si, 0xc
        inc di
        jmp short .11
.13:
        cmp byte [DriverServiceIdx], 0xff
        jz short .14
        push 0x8
        mov al, [DriverServiceIdx]
        push ax
        call 0x1844:DrvNeedsService
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        push word 0x8f74
        call 0x03A3:EmsSaveMap
        pop bx
        mov al, [DriverServiceIdx]
        push ax
        call 0x1844:DrvService
        pop bx
        push word 0x8f74
        call 0x03A3:EmsRestoreMap
        pop bx
.14:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SeqStepTrack                                               1630:01D2  EACLIB
; Advances one track slot and handles its pending events.
;-----------------------------------------------------------------------------
SeqStepTrack:
        enter 0xe, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov ax, [es:si + 0xc]
        or ax, [es:si + 0xa]
        jnz short .1
        jmp near SeqStepTrackJumpTable.30
.1:
        mov byte [MidiMsg], 0x80
        test byte [es:si + 0x56], 0x8
        jnz short .2
        jmp near .8
.2:
        les bx, [es:si + 0x4]
        cmp word [es:bx + 0xe], 0x0
        jnz short .6
        mov ax, [Voices]
        mov dx, [VoicesSeg]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x4], dx
        db 0x33, 0xC9                           ; insn: xor cx, cx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        jmp short .5
.3:
        mov es, [bp - 0x4]
        mov ax, [es:di]
        mov dx, [es:di + 0x2]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jnz short .4
        cmp [es:bx + 0x2], dx
        jnz short .4
        mov es, [bp - 0x4]
        mov al, [es:di + 0x5]
        mov es, [bp + 0x8]
        cmp [es:bx + 0x8], al
        jnz short .4
        push word [bp - 0x4]
        push di
        call 0x1630:SendVoiceNoteOff
        add sp, 0x4
.4:
        add di, 0xc
        inc si
.5:
        cmp si, 0x20
        jl short .3
        mov si, [bp + 0x6]
        mov ds, [bp + 0x8]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xc], ax
        mov [si + 0xa], ax
        mov [si + 0x56], al
        jmp near SeqStepTrackJumpTable.30
.6:
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        push word [es:bx + 0xe]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov [bp - 0xa], di
        mov [bp - 0x8], es
        call 0x0000:_abs
        pop bx
        les bx, [bp - 0xa]
        cmp [es:bx + 0xc], ax
        jnz short .7
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        mov al, [es:bx + 0x10]
        mov [es:bx + 0x11], al
        mov es, [bp + 0x8]
        and byte [es:si + 0x56], 0xf7
        jmp short .8
.7:
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        cmp word [es:bx + 0xe], 0x0
        jz short .8
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        push word [es:bx + 0xe]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov [bp - 0xe], di
        mov [bp - 0xc], es
        call 0x0000:_abs
        pop bx
        les bx, [bp - 0xe]
        cmp [es:bx + 0xc], ax
        jz short .8
        mov es, [bp + 0x8]
        mov al, [es:si + 0x4c]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x7
        mov es, [0x8d10]
        mov al, [es:bx - 0x4491]
        push ax
        push 0x7
        push word [bp + 0x8]
        push si
        call 0x1630:SendController
        add sp, 0x8
.8:
        mov es, [bp + 0x8]
        add word [es:si + 0x4e], 0x80
.9:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x50]
        cmp [es:si + 0x4e], ax
        jnl short .10
        jmp near SeqStepTrackJumpTable.30
.10:
        mov ax, [es:si + 0xc]
        or ax, [es:si + 0xa]
        jnz short .11
        jmp near SeqStepTrackJumpTable.30
.11:
        mov ax, [0x84cc]
        mov dx, [0x84ce]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x4], dx
        db 0x33, 0xC9                           ; insn: xor cx, cx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        jmp short .14
.12:
        mov es, [bp - 0x4]
        mov al, [es:di + 0x5]
        les bx, [bp + 0x6]
        cmp [es:bx + 0x8], al
        jnz short .13
        mov es, [bp - 0x4]
        sub word [es:di + 0x8], 0x1
        sbb word [es:di + 0xa], 0x0
        mov ax, [es:di + 0xa]
        or ax, [es:di + 0x8]
        jnz short .13
        push word [bp - 0x4]
        push di
        call 0x1630:SendVoiceNoteOff
        add sp, 0x4
.13:
        add di, 0xc
        inc si
.14:
        cmp si, 0x20
        jl short .12
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x10]
        or ax, [es:si + 0xe]
        jz short .17
.15:
        sub word [es:si + 0xe], 0x1
        sbb word [es:si + 0x10], 0x0
.16:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x50]
        sub [es:si + 0x4e], ax
        jmp near .9
.17:
        mov ax, [es:si + 0xc]
        or ax, [es:si + 0xa]
        jz short .16
.18:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x10]
        or ax, [es:si + 0xe]
        jnz short .15
        mov ax, [es:si + 0xc]
        or ax, [es:si + 0xa]
        jz short .15
        push word [es:si + 0xc]
        push word [es:si + 0xa]
        push word 0x8f7c
        call 0x1630:ParseMidiEvent
        add sp, 0x6
        mov al, [0x8f86]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp + 0x8]
        add [es:si + 0xa], ax
        cmp byte [0x8f80], 0xd9
        jnc short .19
        jmp near SeqStepTrackJumpTable.23
.19:
        mov al, [0x8f81]
        mov [bp - 0x5], al
        mov al, [0x8f80]
        sub ax, 0xd9
        cmp ax, strict word 0x11
        jna short .20
        jmp near SeqStepTrackJumpTable.28
.20:
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x3ff]
SeqStepTrackJumpTable:                          ; word; used by SeqStepTrack
        dw .1
        dw .1
        dw .3
        dw .5
        dw .10
        dw .28
        dw .12
        dw .28
        dw .28
        dw .14
        dw .15
        dw .18
        dw .19
        dw .20
        dw .28
        dw .21
        dw .28
        dw .22
.1:
        mov es, [bp + 0x8]
        cmp byte [es:si + 0x31], 0x0
        jz short .2
        mov bl, [es:si + 0x31]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov ax, [es:bx + si + 0x32]
        mov dx, [es:bx + si + 0x34]
        mov [es:si + 0xa], ax
        mov [es:si + 0xc], dx
        dec byte [es:si + 0x31]
        jmp near .28
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0xc], ax
        mov [es:si + 0xa], ax
        mov [es:si + 0x2], ax
        mov [es:si], ax
        mov [es:si + 0x56], al
        jmp near .28
.3:
        db 0x32, 0xC0                           ; insn: xor al, al
        mov es, [bp + 0x8]
        mov [es:si + 0x31], al
        mov [es:si + 0x30], al
        mov ax, [es:si + 0x32]
        mov dx, [es:si + 0x34]
.4:
        mov [es:si + 0xa], ax
        mov [es:si + 0xc], dx
        jmp near .28
.5:
        mov al, [bp - 0x5]
        mov es, [bp + 0x8]
        mov [es:si + 0x4b], al
        mov cl, [es:si + 0x4c]
        or cl, 0xc0
        mov [0x8f68], cl
        mov [0x8f69], al
        push ax
        call 0x16F2:GetPatch
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        test byte [es:bx + 0xf], 0x80
        jz short .6
        mov al, [es:di + 0xf]
        and al, 0x7f
        jmp short .7
.6:
        mov al, 0x7f
.7:
        mov es, [bp + 0x8]
        mov [es:si + 0x4d], al
        push ds
        push word MidiMsg
        push 0x2
.8:
        mov es, [bp + 0x8]
        mov al, [es:si + 0x4d]
        push ax
        call 0x1844:DrvSendMidi
.9:
        add sp, 0x8
        jmp near .28
.10:
        mov al, [bp - 0x5]
        push ax
        mov es, [bp + 0x8]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x1630:SetSongTempo
.11:
        add sp, 0x6
        jmp near .28
.12:
        mov es, [bp + 0x8]
        test byte [es:si + 0x56], 0x8
        jz short .13
        jmp near .28
.13:
        mov al, [0x8f82]
        push ax
        mov al, [bp - 0x5]
        push ax
        push es
        push si
        call 0x1630:SendController
        jmp short .9
.14:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0xa]
        mov dx, [es:si + 0xc]
        mov bl, [es:si + 0x30]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov [es:bx + si + 0x18], ax
        mov [es:bx + si + 0x1a], dx
        mov al, [bp - 0x5]
        dec al
        mov bl, [es:si + 0x30]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov [es:bx + si + 0x12], al
        inc byte [es:si + 0x30]
        jmp near .28
.15:
        mov es, [bp + 0x8]
        cmp byte [es:si + 0x30], 0x0
        jz short .16
        mov bl, [es:si + 0x30]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov ax, [es:bx + si + 0x14]
        mov dx, [es:bx + si + 0x16]
        mov [es:si + 0xa], ax
        mov [es:si + 0xc], dx
        mov bl, [es:si + 0x30]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov al, [es:bx + si + 0x11]
        dec byte [es:bx + si + 0x11]
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .17
.16:
        jmp near .28
.17:
        mov es, [bp + 0x8]
        dec byte [es:si + 0x30]
        jmp near .28
.18:
        mov al, [bp - 0x5]
        mov es, [bp + 0x8]
        mov [es:si + 0x57], al
        jmp near .28
.19:
        push word [0x8f82]
        push word [bp + 0x8]
        push si
        call 0x1630:SendPitchBend
        jmp near .11
.20:
        mov es, [bp + 0x8]
        inc byte [es:si + 0x31]
        mov ax, [es:si + 0xa]
        mov dx, [es:si + 0xc]
        mov bl, [es:si + 0x31]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov [es:bx + si + 0x32], ax
        mov [es:bx + si + 0x34], dx
        mov ax, [0x8f82]
        mov dx, [0x8f84]
        add ax, strict word 0x4
        jmp near .4
.21:
        push word 0x3a0b                        ; segment of the work buffer far data
        push word 0xb96e
        mov al, [0x8f86]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x4
        push ax
        jmp near .8
.22:
        mov al, [bp - 0x5]
        mov es, [bp + 0x8]
        mov [es:si + 0x4a], al
        jmp near .28
.23:
        cmp byte [0x8f80], 0x80
        jnc short .24
        mov es, [bp + 0x8]
        mov al, [es:si + 0x57]
        mov [0x8f81], al
.24:
        and byte [0x8f80], 0x7f
        mov es, [bp + 0x8]
        cmp byte [es:si + 0x4c], 0x9
        jz short .25
        les bx, [es:si + 0x4]
        mov al, [es:bx + 0x13]
        add [0x8f80], al
.25:
        cmp word [0x84fe], 0x0
        jz short .28
        mov es, [bp + 0x8]
        cmp byte [es:si + 0x4c], 0x9
        jz short .26
        push word [es:si + 0x2]
        push word [es:si]
        mov al, [es:si + 0x8]
        push ax
        mov al, [es:si + 0x4d]
        push ax
        jmp short .27
.26:
        mov al, [0x8f80]
        add al, 0x5c
        push ax
        call 0x16F2:GetPatch
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, [bp + 0x8]
        push word [es:si + 0x2]
        push word [es:si]
        mov al, [es:si + 0x8]
        push ax
        mov es, dx
        mov al, [es:di + 0xf]
        and al, 0x7f
        push ax
        mov es, [bp + 0x8]
.27:
        mov al, [es:si + 0x4c]
        push ax
        push word [0x8f84]
        push word [0x8f82]
        mov al, [0x8f81]
        push ax
        mov al, [0x8f80]
        push ax
        call 0x1630:AllocVoice
        add sp, 0x12
.28:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0xc]
        or ax, [es:si + 0xa]
        jnz short .29
        jmp near SeqStepTrack.18
.29:
        push word [es:si + 0xc]
        push word [es:si + 0xa]
        push word 0x8f88
        call 0x1630:ParseMidiEvent
        add sp, 0x6
        mov ax, [0x8f88]
        mov dx, [0x8f8a]
        mov es, [bp + 0x8]
        mov [es:si + 0xe], ax
        mov [es:si + 0x10], dx
        jmp near SeqStepTrack.18
.30:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90

;-----------------------------------------------------------------------------
; SendController                                             1630:06C2  EACLIB
; Sends controller 7 or 0Ah (volume, pan) scaled for the track.
;-----------------------------------------------------------------------------
SendController:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov al, [es:si + 0x4c]
        or al, 0xb0
        mov [MidiMsg], al
        mov al, [bp + 0xa]
        mov [MidiMsg1], al
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x7
        jz short .1
        sub ax, strict word 0x3
        jz short .2
        jmp near .5
.1:
        mov al, [bp + 0xc]
        mov cl, [es:si + 0x4c]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        imul bx, cx, 0x7
        mov es, [WorkBufferSeg]
        mov [es:bx - 0x4491], al
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        mul byte [es:bx + 0x11]
        mov cx, 0x7f
        cwd
        idiv cx
        mov [bp + 0xc], al
        db 0x3A, 0xC1                           ; insn: cmp al, cl
        jna short .5
        mov [bp + 0xc], cl
        jmp short .5
.2:
        mov al, [bp + 0xc]
        mov cl, [es:si + 0x4c]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        imul bx, cx, 0x7
        mov es, [WorkBufferSeg]
        mov [es:bx - 0x4490], al
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        cmp byte [es:bx + 0x12], 0x3f
        jna short .3
        mov cx, 0x7f
        mov al, [bp + 0xc]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jmp short .4
.3:
        mov cl, [bp + 0xc]
        db 0x2A, 0xED                           ; insn: sub ch, ch
.4:
        mov es, [bp + 0x8]
        les bx, [es:si + 0x4]
        mov al, [es:bx + 0x12]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x3f
        imul cx
        mov cx, 0x3f
        cwd
        idiv cx
        add [bp + 0xc], al
.5:
        mov al, [bp + 0xc]
        mov [MidiMsg2], al
        push ds
        push word MidiMsg
        push 0x3
        mov es, [bp + 0x8]
        mov al, [es:si + 0x4d]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        pop ds
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SendVoiceNoteOff                                           1630:0792  EACLIB
; Sends a note-off for a voice record.
;-----------------------------------------------------------------------------
SendVoiceNoteOff:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov al, [es:si + 0x6]
        or al, 0x80
        mov [MidiMsg], al
        mov al, [es:si + 0x4]
        mov [MidiMsg1], al
        mov byte [MidiMsg2], 0x0
        push ds
        push word MidiMsg
        push 0x3
        mov al, [es:si + 0x7]
        push ax
        mov di, es
        call 0x1844:DrvSendMidi
        add sp, 0x8
        mov es, di
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x2], ax
        mov [es:si], ax
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetSongTempo                                               1630:07DE  EACLIB
; Sets the tick rate (7D00h / tempo) for every slot of a song.
;-----------------------------------------------------------------------------
SetSongTempo:
        enter 0x4, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x33, 0xFF                           ; insn: xor di, di
        mov ds, dx
        jmp short .3
.1:
        mov ax, [si]
        mov dx, [si + 0x2]
        cmp [bp + 0x6], ax
        jnz short .2
        cmp [bp + 0x8], dx
        jnz short .2
        mov ax, 0x7d00
        mov cl, [bp + 0xa]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        cwd
        idiv cx
        mov [si + 0x50], ax
.2:
        add si, 0x58
        inc di
.3:
        cmp di, 0x18
        jl short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SendPitchBend                                              1630:0826  EACLIB
; Sends an E0h pitch bend message.
;-----------------------------------------------------------------------------
SendPitchBend:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov al, [es:si + 0x4c]
        or al, 0xe0
        mov [MidiMsg], al
        mov byte [MidiMsg1], 0x0
        mov al, [bp + 0xb]
        and al, 0x7f
        mov [MidiMsg2], al
        push ds
        push word MidiMsg
        push 0x3
        mov al, [es:si + 0x4d]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        pop ds
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AllocVoice                                                 1630:0864  EACLIB
; Takes a free entry from the 32 voice records.
;-----------------------------------------------------------------------------
AllocVoice:
        enter 0x8, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [Voices]
        mov dx, [VoicesSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov byte [bp - 0x5], 0x0
.1:
        cmp byte [bp - 0x5], 0x20
        jc short .2
        jmp near .9
.2:
        mov es, [bp - 0x2]
        mov ax, [es:si + 0x2]
        or ax, [es:si]
        jz short .3
        add si, 0xc
        inc byte [bp - 0x5]
        jmp short .1
.3:
        cmp word [bp + 0xc], 0x0
        jnz short .4
        cmp word [bp + 0xa], 0x0
        jz short .5
.4:
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        jmp short .6
.5:
        mov ax, 0x1
        cwd
.6:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov [es:bx + 0x8], ax
        mov [es:bx + 0xa], dx
        mov ax, [bp + 0x14]
        mov dx, [bp + 0x16]
        mov es, [bp - 0x2]
        mov [es:bx], ax
        mov [es:bx + 0x2], dx
        mov al, [bp + 0x12]
        mov [es:bx + 0x5], al
        mov cl, [bp + 0x6]
        mov [es:bx + 0x4], cl
        mov dl, [bp + 0xe]
        mov [es:bx + 0x6], dl
        mov al, [bp + 0x10]
        mov [es:bx + 0x7], al
        sub dl, 0x70
        mov [MidiMsg], dl
        mov [MidiMsg1], cl
        mov al, [bp + 0x8]
        mov [MidiMsg2], al
        cmp byte [bp + 0x12], 0xff
        jz short .7
        push ds
        push word MidiMsg
        push 0x3
        mov al, [bp + 0x10]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        jmp short .8
.7:
        push 0x3
        push word MidiMsg
        mov al, [bp + 0x10]
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
.8:
        mov al, [bp - 0x5]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        jmp short .10
.9:
        mov ax, 0xffff
.10:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; QueueMidiBytes                                             1630:0934  EACLIB
; Appends a message to the 128-byte MIDI queue.
;-----------------------------------------------------------------------------
QueueMidiBytes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        cmp word [MidiQueueBusy], 0x0
        jnz short .3
        mov cx, [bp + 0xa]
        mov ax, [MidiQueueLen]
        db 0x03, 0xC1                           ; insn: add ax, cx
        cmp ax, 0x80
        jnl short .3
        inc word [SeqLock]
        inc word [MidiQueueBusy]
        mov al, [bp + 0x6]
        mov bx, [MidiQueueLen]
        mov [bx + MidiQueue], al
        inc word [MidiQueueLen]
        mov si, [bp + 0x8]
        jmp short .2
.1:
        mov al, [si]
        mov bx, [MidiQueueLen]
        mov [bx + MidiQueue], al
        inc si
        inc word [MidiQueueLen]
        dec cx
.2:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnz short .1
        dec word [MidiQueueBusy]
        dec word [SeqLock]
.3:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; FlushMidiQueue                                             1630:098E  EACLIB
; Sends every queued message to the driver.
;-----------------------------------------------------------------------------
FlushMidiQueue:
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xF6                           ; insn: xor si, si
        cmp [MidiQueueLen], si
        jz short .4
        cmp [MidiQueueBusy], si
        jnz short .4
        inc word [MidiQueueBusy]
.1:
        mov al, [si + MidiQueue1]
        and al, 0xf0
        cmp al, 0xc0
        jnz short .2
        db 0x8B, 0xFE                           ; insn: mov di, si
        inc si
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdf74
        push ds
        push ax
        push 0x2
        mov al, [di + MidiQueue]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        inc si
        inc si
        jmp short .3
.2:
        db 0x8B, 0xFE                           ; insn: mov di, si
        inc si
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdf74
        push ds
        push ax
        push 0x3
        mov al, [di + MidiQueue]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        add si, 0x3
.3:
        cmp [MidiQueueLen], si
        jg short .1
        dec word [MidiQueueBusy]
        mov word [MidiQueueLen], 0x0
.4:
        pop ds
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SendProgramChange                                          1630:0A00  EACLIB
; Sends a C0h program change.
;-----------------------------------------------------------------------------
SendProgramChange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x8]
        or al, 0xc0
        mov [MidiMsg], al
        mov al, [bp + 0xa]
        mov [MidiMsg1], al
        push ds
        push word MidiMsg
        push 0x2
        mov al, [bp + 0x6]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SendPan                                                    1630:0A2C  EACLIB
; Sends controller 0Ah.
;-----------------------------------------------------------------------------
SendPan:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x8]
        or al, 0xb0
        mov [MidiMsg], al
        mov byte [MidiMsg1], 0xa
        mov al, [bp + 0xa]
        mov [MidiMsg2], al
        push ds
        push word MidiMsg
        push 0x3
        mov al, [bp + 0x6]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SendVolume                                                 1630:0A5E  EACLIB
; Sends controller 7.
;-----------------------------------------------------------------------------
SendVolume:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x8]
        or al, 0xb0
        mov [MidiMsg], al
        mov byte [MidiMsg1], 0x7
        mov al, [bp + 0xa]
        mov [MidiMsg2], al
        push ds
        push word MidiMsg
        push 0x3
        mov al, [bp + 0x6]
        push ax
        call 0x1844:DrvSendMidi
        add sp, 0x8
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ParseMidiEvent                                             1630:0A90  EACLIB
; Reads a variable-length delta and dispatches the event type through a jump
; table.
;-----------------------------------------------------------------------------
ParseMidiEvent:
        enter 0x8, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov di, [bp + 0x8]
        mov [bp - 0x8], di
        mov bx, [bp + 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0x2], ax
        mov [bx], ax
.1:
        mov bx, [bp + 0x6]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov cl, 0x7
        call 0x0000:__aFlshl
        mov es, [bp + 0xa]
        mov cl, [es:di]
        and cx, 0x7f
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov bx, [bp + 0x6]
        mov [bx], ax
        mov [bx + 0x2], dx
        db 0x8B, 0xF7                           ; insn: mov si, di
        inc di
        test byte [es:si], 0x80
        jnz short .1
        mov si, [bp + 0x6]
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        mov [si + 0x4], al
        mov [bp - 0x3], al
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, 0xdc
        cmp ax, strict word 0xe
        jna short .2
        jmp near ParseMidiEventJumpTable.9
.2:
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0xb02]
ParseMidiEventJumpTable:                        ; word; used by ParseMidiEvent
        dw .1
        dw .1
        dw .1
        dw .2
        dw .1
        dw .1
        dw .1
        dw .9
        dw .1
        dw .3
        dw .4
        dw .5
        dw .6
        dw .1
        dw .1
.1:
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        mov [si + 0x5], al
        jmp near .9
.2:
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        mov [si + 0x5], al
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [si + 0x6], ax
        mov word [si + 0x8], 0x0
        jmp short .9
.3:
        push word [bp + 0xa]
        push di
        call 0x16F2:ReadFarWord
        add sp, 0x4
        mov [si + 0x6], ax
        mov word [si + 0x8], 0x0
        inc di
        inc di
        jmp short .9
.4:
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        mov [si + 0x5], al
        push word [bp + 0xa]
        push di
        call 0x16F2:ReadFarDword
        add sp, 0x4
        mov [si + 0x6], ax
        mov [si + 0x8], dx
        add di, 0x4
        jmp short .9
.5:
        mov es, [bp + 0xa]
        mov al, [es:di]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        inc ax
        db 0x03, 0xF8                           ; insn: add di, ax
        jmp short .9
.6:
        mov [bp + 0x8], di
        db 0x33, 0xC9                           ; insn: xor cx, cx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        jmp short .8
.7:
        mov al, [es:bx + si + 0x1]
        mov es, [WorkBufferSeg2]
        mov [es:si - 0x4692], al
        inc si
.8:
        les bx, [bp + 0x8]
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jg short .7
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov al, [es:di]
        inc ax
        db 0x03, 0xF8                           ; insn: add di, ax
        mov si, [bp + 0x6]
.9:
        cmp byte [bp - 0x3], 0xd9
        jnc short .12
        cmp byte [bp - 0x3], 0x80
        jna short .10
        mov es, [bp + 0xa]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        mov al, [es:bx]
        mov [si + 0x5], al
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x8], ax
        mov [si + 0x6], ax
.11:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x6]
        mov dx, [bx + 0x8]
        mov cl, 0x7
        call 0x0000:__aFlshl
        mov es, [bp + 0xa]
        mov cl, [es:di]
        and cx, 0x7f
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov bx, [bp + 0x6]
        mov [bx + 0x6], ax
        mov [bx + 0x8], dx
        db 0x8B, 0xF7                           ; insn: mov si, di
        inc di
        test byte [es:si], 0x80
        jnz short .11
.12:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub al, [bp - 0x8]
        mov bx, [bp + 0x6]
        db 0x88
