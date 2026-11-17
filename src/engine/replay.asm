; Replay buffer: recording and stepping through frames (AI.OVL)
; The first bytes finish the last routine of highlight_game.asm.
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StartHL2Tail                                               2038:0002  94 PC
; The rest of StartHL2, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StartHL2Tail:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ReplayRecordReset                                          2038:0008  94 PC
; Replay tick counter = 1, recorded sfx word = -1.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ReplayRecordReset:
        mov word [replaytick], 0x1
        mov word [replaysfx], 0xffff
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReplayFirstFrame                                           2038:0016  94 PC
; Oldest replay frame: the record pointer when the buffer has wrapped, else the buffer start.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ReplayFirstFrame:
        test byte [sflags], 0x10
        jnz short .1
        mov ax, [replayptr]
        mov dx, [replayseg]
        retf
        db 0x90
.1:
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        retf

;-----------------------------------------------------------------------------
; ReplayPrevFrame                                            2038:002E  94 PC
; Record pointer - 80h, or the last frame of the buffer.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ReplayPrevFrame:
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        cmp [replayptr], ax
        jnz short .2
        cmp [replayseg], dx
        jnz short .2
        test byte [sflags], 0x10
        jz short .1
        mov ax, [replayptr]
        mov dx, [replayseg]
        sub ax, 0x6a80
        retf
        db 0x90
.1:
        mov ax, [replayptr]
        mov dx, [replayseg]
        retf
.2:
        sub ax, 0x80
        retf

;-----------------------------------------------------------------------------
; updatereplay                                               2038:0060  94 PC
; DoGameFrame's last call; records a frame every 2nd tick.
;
; Calls ReplayPrevFrame. Far routine (retf).
;-----------------------------------------------------------------------------
updatereplay:
        enter 0x4, 0x0
        push di
        push si
        test byte [gmode], 0x10
        jz short .1
        jmp near updatereplayTail.1 + 0x2A0
.1:
        inc word [replaytick]
        cmp word [replaytick], 0x2
        jnl short .2
        jmp near .13
.2:
        sub word [replaytick], 0x2
        test byte [gmode2], 0x4
        jz short .3
        push cs
        call ReplayPrevFrame
        mov [replayrecptr], ax
        mov [replayrecseg], dx
.3:
        mov bx, 0xb50e
        mov di, 0x11
        mov es, [replayrecseg]
.4:
        mov ax, [bx + 0x2]
        and ah, 0x3
        cwd
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bx + 0x6]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [bx + 0x12]
        and ah, 0x3
        mov [bp - 0x4], cx
        mov [bp - 0x2], dx
        cwd
        shl ax, byte 0x4
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ah, [bx + 0x49]
        and ax, 0x1800
        cwd
        shl ax, byte 0x3
        db 0x0B, 0xC1                           ; insn: or ax, cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        and ah, 0x3
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cwd
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x0B, 0xF2                           ; insn: or si, dx
        or cx, [bp - 0x4]
        or si, [bp - 0x2]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov si, [replayrecptr]
        mov [es:si], cx
        mov [es:si + 0x2], ax
        add word [replayrecptr], 0x4
        add bx, 0x80
        dec di
        jnz short .4
        mov si, 0xb50e
        mov cx, 0xc
        mov es, [replayrecseg]
.5:
        mov al, [si + 0x52]
        mov bx, [replayrecptr]
        mov [es:bx], al
        inc word [replayrecptr]
        add si, 0x80
        loop .5
        mov si, 0xb50e
        mov di, 0x6
.6:
        cmp word [si + 0x1a], 0x0
        jnl short .7
        mov word [regd0], 0xf
        jmp short .8
.7:
        mov ax, [si + 0x1a]
        mov [regd0], ax
.8:
        add si, 0x80
        cmp word [si + 0x1a], 0x0
        jnl short .9
        or byte [regd0], 0xf0
        jmp short .10
        db 0x90
.9:
        mov ax, [si + 0x1a]
        shl ax, byte 0x4
        or [regd0], ax
.10:
        add si, 0x80
        mov al, [regd0]
        les bx, [replayrecptr]
        mov [es:bx], al
        inc word [replayrecptr]
        dec di
        jnz short .6
        mov bx, [puckz]
        mov al, [bx]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov al, [doorZpos2]
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov al, [replaysfx]
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov al, [lastsfx]
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov ax, 0xffff
        mov [lastsfx], ax
        mov [replaysfx], ax
        mov al, [c2playernum]
        shl al, byte 0x4
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        xor al, [c1playernum]
        and al, 0xf
        db 0x32, 0xC8                           ; insn: xor cl, al
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], cl
        inc word [replayrecptr]
        mov bx, [puckc]
        mov al, [bx]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov al, [PBnum_b1]
        shl al, byte 0x4
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        xor al, [PBnum]
        and al, 0xf
        db 0x32, 0xC8                           ; insn: xor cl, al
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], cl
        mov al, [camx]
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], al
        mov ax, [camy]
        inc word [replayrecptr]
        les bx, [replayrecptr]
        mov [es:bx], ax
        mov ax, [CrowdSound]
        add word [replayrecptr], 0x2
        les bx, [replayrecptr]
        mov [es:bx], ax
        add word [replayrecptr], 0x2
        mov si, 0xd1b1
        mov es, [replayrecseg]
.11:
        mov al, [si]
        shl al, byte 0x4
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        xor al, [si + 0xe]
        and al, 0xf
        db 0x32, 0xC8                           ; insn: xor cl, al
        mov bx, [replayrecptr]
        mov [es:bx], cl
        inc word [replayrecptr]
        add si, 0x1c
        cmp si, 0xd2c9
        jc short .11
        mov bx, rinkobjs
        mov es, [replayrecseg]
.12:
        mov al, [bx]
        mov si, [replayrecptr]
        mov [es:si], al
        inc word [replayrecptr]
        add bx, 0xe
        cmp bx, 0xd2c6
        jc short .12
        mov ax, [replayptr]
        sub ax, 0x6a00
        cmp ax, [replayrecptr]
        ja short updatereplayTail.1 + 0x2A0
        or byte [sflags], 0x10
        mov ax, [replayptr]
        mov dx, [replayseg]
        mov [replayrecptr], ax
        mov [replayrecseg], dx
        pop si
        pop di
        leave
        retf
        db 0x90
.13:
        test byte [gmode2], 0x4
        jz short .14
        mov ax, 0xffff
        jmp short updatereplayTail + 0x2A0
.14:
        mov ax, [lastsfx]
