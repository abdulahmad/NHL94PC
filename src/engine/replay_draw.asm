; Draws one replay frame (INIT.OVL)
; The first bytes finish the last routine of replay_controls.asm.
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReplayStep                                                 26D2:000A  94 PC
; Steps the replay one frame.
;
; Takes 2 words of stack arguments. Calls PlaySoundEffect, LongSarAt, CrowdNoiseUpdate, CrowdNoiseOff.
; Far routine (retf).
;-----------------------------------------------------------------------------
ReplayStep:
        enter 0x2a, 0x0
        push si
        mov ax, [bp + 0x6]
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .1
        jmp near .12
.1:
        mov ax, [replayplay]
        mov dx, [replayplayseg]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
.2:
        cmp word [bp + 0x6], 0x1
        jl short .6
        dec word [bp + 0x6]
        mov ax, [replayptr]
        mov dx, [replayseg]
        sub ax, 0x6a00
        add word [replayplay], 0x80
        cmp ax, [replayplay]
        jnz short .3
        cmp dx, [replayplayseg]
        jnz short .3
        test byte [sflags], 0x10
        jz short .4
        mov ax, [replayptr]
        mov [replayplay], ax
.3:
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        cmp [replayplay], ax
        jnz short .7
        cmp [replayplayseg], dx
        jnz short .7
.4:
        sub word [replayplay], 0x80
.5:
        mov word [bp + 0x6], 0xffff
.6:
        mov word [bp - 0x2a], 0x0
        jmp near .16
        db 0x90
.7:
        cmp word [bp + 0x8], 0x0
        jz short .2
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        cmp [replayplay], ax
        jnz short .8
        cmp [replayplayseg], dx
        jz short .2
.8:
        les bx, [replayplay]
        mov al, [es:bx + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x2a], ax
        cmp ax, 0xff
        jz short .9
        push ax
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.9:
        les bx, [replayplay]
        mov al, [es:bx + 0x59]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x2a], ax
        cmp ax, 0xff
        jnz short .10
        jmp near .2
.10:
        push ax
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        jmp near .2
.11:
        sub word [replayplay], 0x80
.12:
        cmp word [bp + 0x6], 0x0
        jnl short .6
        inc word [bp + 0x6]
        mov ax, [replayplay]
        mov dx, [replayplayseg]
        cmp [replayptr], ax
        jnz short .14
        cmp [replayseg], dx
        jnz short .14
        test byte [sflags], 0x10
        jnz short .13
        jmp near .5
.13:
        mov ax, [replayptr]
        mov dx, [replayseg]
        sub ax, 0x6a00
        mov [replayplay], ax
        mov [replayplayseg], dx
.14:
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        cmp [replayplay], ax
        jnz short .11
        cmp [replayplayseg], dx
        jnz short .11
        jmp near .5
        db 0x90
.15:
        inc word [bp - 0x2a]
.16:
        cmp word [bp - 0x2a], 0x11
        jl short .17
        jmp near .21
.17:
        les bx, [replayplay]
        add word [replayplay], 0x4
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [regd0], ax
        mov [regd0_w2], dx
        and ah, 0x3
        mov [regd1], ax
        test ah, 0x2
        jz short .18
        or ah, 0xfc
        mov [regd1], ax
.18:
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_x], ax
        push 0xa
        push word 0xd66c
        call 0x0000:LongSarAt
        mov ax, [regd0]
        and ah, 0x3
        mov [regd1], ax
        test ah, 0x2
        jz short .19
        or ah, 0xfc
        mov [regd1], ax
.19:
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_y], ax
        push 0xa
        push word 0xd66c
        call 0x0000:LongSarAt
        mov ax, [regd0]
        and ah, 0x3
        mov [regd1], ax
        cmp ax, 0x3ff
        jnz short .20
        mov word [regd1], 0xffff
.20:
        mov ax, [regd1]
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_frame], ax
        mov ah, [regd0_b1]
        and ax, 0x400
        cmp ax, strict word 0x1
        db 0x1A, 0xC0                           ; insn: sbb al, al
        inc al
        mov bx, [bp - 0x2a]
        mov [bx + rpl_flags], al
        jmp near .15
.21:
        mov word [bp - 0x2a], 0x0
        mov es, [replayplayseg]
.22:
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        mov bx, [bp - 0x2a]
        mov [bx + rpl_jerseys], al
        inc word [bp - 0x2a]
        cmp word [bp - 0x2a], 0xc
        jl short .22
        mov word [bp - 0x2a], 0x0
        jmp short .27
        db 0x90
.23:
        mov al, [regd1]
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_puckowner], al
.24:
        mov al, [regd0]
        sar al, byte 0x4
        and al, 0xf
        mov [regd1], al
        cmp al, 0xf
        jnz short .25
        mov al, 0xff
        jmp short .26
        db 0x90
.25:
        mov al, [regd1]
.26:
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_bytes], al
        inc word [bp - 0x2a]
.27:
        cmp word [bp - 0x2a], 0x6
        jnl short .28
        les bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        mov [regd0], al
        and al, 0xf
        mov [regd1], al
        cmp al, 0xf
        jnz short .23
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov byte [bx + rpl_puckowner], 0xff
        jmp short .24
.28:
        les bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        cbw
        mov [rpl_camx], ax
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        cbw
        mov [rpl_word], ax
        add word [replayplay], 0x2
        mov bx, [replayplay]
        mov al, [es:bx]
        mov [regd0], al
        lea ax, [bx + 0x1]
        mov [replayplay], ax
        mov al, [regd0]
        and al, 0xf
        mov [regd1], al
        cmp al, 0xf
        jnz short .29
        mov al, 0xff
        jmp short .30
        db 0x90
.29:
        mov al, [regd1]
.30:
        mov [rpl_b1], al
        mov al, [regd0]
        sar al, byte 0x4
        and al, 0xf
        mov [regd1], al
        cmp al, 0xf
        jnz short .31
        mov al, 0xff
        jmp short .32
        db 0x90
.31:
        mov al, [regd1]
.32:
        mov [rpl_b2], al
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        mov [rpl_b3], al
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        mov [regd0], al
        and al, 0xf
        mov [rpl_b4], al
        mov al, [regd0]
        sar al, byte 0x4
        and al, 0xf
        mov [rpl_b5], al
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        cbw
        mov [rpl_w1], ax
        mov [camx], ax
        mov bx, [replayplay]
        mov ax, [es:bx]
        mov [rpl_w2], ax
        mov [camy], ax
        add word [replayplay], 0x2
        mov bx, [replayplay]
        mov ax, [es:bx]
        mov [CrowdSound], ax
        lea ax, [bx + 0x2]
        mov [replayplay], ax
        mov word [bp - 0x2a], 0x0
        mov es, [replayplayseg]
.33:
        mov bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        mov [regd0], al
        shr al, byte 0x4
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_b6], al
        mov al, [regd0]
        and al, 0xf
        mov [bx + rpl_b7], al
        inc word [bp - 0x2a]
        cmp word [bp - 0x2a], 0xa
        jl short .33
        mov word [bp - 0x2a], 0x0
.34:
        les bx, [replayplay]
        inc word [replayplay]
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [regd0], ax
        cmp ax, 0xff
        jnz short .35
        mov word [regd0], 0xffff
.35:
        mov ax, [regd0]
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov [bx + rpl_words], ax
        inc word [bp - 0x2a]
        cmp word [bp - 0x2a], 0x14
        jl short .34
        cmp word [bp + 0x8], 0x0
        jz short .37
        mov ax, [replayrecptr]
        mov dx, [replayrecseg]
        cmp [replayplay], ax
        jnz short .36
        cmp [replayplayseg], dx
        jz short .37
.36:
        mov ax, [bp - 0x6]
        shl ax, 1
        push ax
        call 0x0EDC:CrowdNoiseUpdate
        add sp, 0x2
        jmp short .38
        db 0x90
.37:
        call 0x0EDC:CrowdNoiseOff
.38:
        sub word [replayplay], 0x80
        mov word [bp - 0x2a], 0x0
.39:
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov ax, [bx + rpl_y]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x28], ax
        mov ax, [bp - 0x2a]
        mov [bx + rpl_words2], ax
        inc word [bp - 0x2a]
        cmp word [bp - 0x2a], 0x11
        jl short .39
        push word 0xdc08
        lea ax, [bp - 0x28]
        push ax
        push 0x11
        call 0x14F6:SortPairs - 0x90
        add sp, 0x6
        mov ax, [bp + 0x6]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawReplayFrame                                            26D2:03F2  94 PC
; Draws the sorted sprites, numbers and rink end art of a replay frame.
;
; Takes 3 words of stack arguments. Calls DrawFrameSprite, DrawSpriteClipped, SetClipRectRegs,
; JoyNibble, DrawSpriteNumber, DrawRinkEndArt.
;-----------------------------------------------------------------------------
DrawReplayFrame:
        enter 0x28, 0x0
        push si
        cmp word [camx], -0x10
        jg short .1
        jmp near .8
.1:
        cmp word [camy], 0x50
        jnl short .4
        cmp word [camy], 0xff6c
        jng short .4
        mov word [bp - 0x1e], 0x0
        jmp short .3
        db 0x90
.2:
        cmp word [bp - 0x1e], 0x3
        jnl short .4
        push 0x0
        push 0x0
        mov ax, 0xfffd
        sub ax, [bp - 0x1e]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push word 0xb3
        push word 0x17e
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        inc word [bp - 0x1e]
.3:
        mov al, [rpl_b4]
        cbw
        cmp ax, [bp - 0x1e]
        jg short .2
.4:
        cmp word [camy], -0x4b
        jng short .8
        cmp word [camy], 0xb1
        jnl short .8
        mov al, [rpl_b5]
        cbw
        dec ax
        cmp ax, strict word 0x2
        jng short .5
        mov ax, 0x2
.5:
        mov [bp - 0x1e], ax
        jmp short .7
        db 0x90
.6:
        push 0x1
        push 0x0
        mov ax, [bp - 0x1e]
        add ax, strict word 0x3
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push word 0xb3
        push word 0x17e
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
        dec word [bp - 0x1e]
.7:
        cmp word [bp - 0x1e], 0x0
        jnl short .6
.8:
        mov word [bp - 0x1e], 0x0
        jmp short .12
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        push ax
        mov ax, [viewcelly]
        shl ax, byte 0x3
        sub ax, [bp - 0x28]
        neg ax
        push ax
        mov ax, [viewcellx]
        shl ax, byte 0x3
        sub ax, [bp - 0x26]
        neg ax
        push ax
        mov bx, [bp - 0x24]
        shl bx, byte 0x2
        push word [bx + SpriteFramesSeg]
        push word [bx + SpriteFrames]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
.11:
        inc word [bp - 0x1e]
.12:
        cmp word [bp - 0x1e], 0x12
        jnl short .14
        mov bx, [bp - 0x1e]
        shl bx, 1
        mov ax, [bx + rpl_words]
        mov [bp - 0x20], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .11
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        mov es, [segAnimSequences1]
        mov cx, [es:bx + 0xf8]
        mov [bp - 0x10], cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        inc bx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        mov dx, [es:bx + 0xf8]
        mov [bp - 0x1c], dx
        inc ax
        mov [bp - 0x20], ax
        mov bx, [bp - 0x1e]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [bx + rpl_b6]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl si, 1
        add bx, [es:si + 0xf8]
        mov es, [segAnimSequences2]
        db 0x26, 0x8A, 0x87, 0x00, 0x00         ; insn: mov al, [es:bx + 0x0]
        cbw
        mov [bp - 0x2], ax
        push 0x0
        push -0x1
        mov [bp - 0x24], ax
        mov [bp - 0x26], cx
        mov [bp - 0x28], dx
        cmp cx, 0xc0
        jg short .13
        jmp near .9
.13:
        mov ax, 0x1
        jmp near .10
        db 0x90
.14:
        mov word [bp - 0x1e], 0x13
        jmp near .30
.15:
        mov ax, 0x3
        imul word [bp - 0x20]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov es, [segAnimSequences1]
        mov cx, [viewcellx]
        shl cx, byte 0x3
        sub cx, [es:bx + 0xf8]
        neg cx
        mov [bp - 0x10], cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        inc bx
        mov [bp - 0x20], bx
        shl bx, 1
        mov ax, [viewcelly]
        shl ax, byte 0x3
        sub ax, [es:bx + 0xf8]
        neg ax
        mov [bp - 0x1c], ax
        mov bx, [bp - 0x1e]
        mov al, [bx + rpl_b6]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov si, [bp - 0x20]
        inc si
        mov [bp - 0x20], si
        shl si, 1
        add bx, [es:si + 0xf8]
        mov es, [segAnimSequences2]
        db 0x26, 0x8A, 0x87, 0x00, 0x00         ; insn: mov al, [es:bx + 0x0]
        cbw
        mov [bp - 0x2], ax
.16:
        cmp word [bp - 0x2], 0x64
        jg short .17
        cmp word [bp - 0x20], 0x0
        jnl short .22
.17:
        push 0x0
        cmp word [bp - 0x1e], 0x13
        jnz short .18
        mov ax, 0x1
        jmp short .19
        db 0x90
.18:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.19:
        push ax
        push 0x0
        cmp word [bp - 0x1e], 0x12
        jnz short .20
        mov ax, 0x1a5
        jmp short .21
.20:
        mov ax, 0x12d
.21:
        mov cx, [viewcelly]
        shl cx, byte 0x3
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        push ax
        mov ax, [viewcellx]
        shl ax, byte 0x3
        sub ax, strict word 0x4
        neg ax
        push ax
        push word [NumberFramesSeg]
        push word [NumberFrames]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
.22:
        cmp word [bp - 0x2], 0x0
        jl short .25
        push 0x0
        cmp word [bp - 0x1e], 0x13
        jnz short .23
        mov ax, 0x1
        jmp short .24
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        push ax
        push 0x0
        push word [bp - 0x1c]
        push word [bp - 0x10]
        mov bx, [bp - 0x2]
        shl bx, byte 0x2
        push word [bx + SpriteFramesSeg]
        push word [bx + SpriteFrames]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
.25:
        cmp word [bp - 0x1e], 0x12
        jnz short .28
        push 0x0
        push -0x1
        push 0x0
        cmp word [bp - 0x1e], 0x12
        jnz short .26
        mov ax, 0x1a5
        jmp short .27
.26:
        mov ax, 0x12d
.27:
        mov cx, [viewcelly]
        shl cx, byte 0x3
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        push ax
        mov ax, [viewcellx]
        shl ax, byte 0x3
        sub ax, strict word 0x4
        neg ax
        push ax
        push word [NumberFrames2Seg]
        push word [NumberFrames2]
        call 0x1F54:DrawSpriteClipped
        add sp, 0xe
        jmp short .29
        db 0x90
.28:
        mov ax, [rpl_door]
        mov [bp - 0x2], ax
        cmp ax, 0x362
        jl short .29
        push 0x0
        push 0x0
        push word [rpl_shadow]
        push word [rpl_puckframe]
        push ax
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.29:
        dec word [bp - 0x1e]
.30:
        cmp word [bp - 0x1e], 0x12
        jl short .32
        mov bx, [bp - 0x1e]
        shl bx, 1
        mov ax, [bx + rpl_words]
        mov [bp - 0x20], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .31
        jmp near .15
.31:
        mov word [bp - 0x2], 0xffff
        jmp near .16
.32:
        cmp word [camy], 0xff50
        jnl short .33
        mov es, [segDgroup9]
        mov ax, [es:ClipBottomY]
        mov [bp - 0x22], ax
        mov ax, [viewcelly]
        shl ax, byte 0x3
        sub ax, 0x244
        neg ax
        push ax
        mov ax, [es:ClipLeftX]
        mov bx, [es:ClipTopY]
        mov dx, [es:ClipRightX]
        call 0x0FEF:SetClipRectRegs
.33:
        mov word [bp - 0x1e], 0x0
.34:
        mov si, [bp - 0x1e]
        shl si, 1
        mov word [bp + si - 0xe], 0x0
        mov ax, [bp - 0x1e]
        mov [bp + si - 0x8], ax
        inc word [bp - 0x1e]
        cmp word [bp - 0x1e], 0x3
        jl short .34
        cmp byte [rpl_b3], 0xff
        jz short .35
        mov al, [rpl_b3]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + rpl_y]
        mov [bp - 0xa], ax
.35:
        cmp byte [rpl_b1], 0x0
        jl short .36
        mov al, [rpl_b1]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + rpl_y]
        mov [bp - 0xe], ax
.36:
        cmp byte [rpl_b2], 0x0
        jl short .37
        mov al, [rpl_b2]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + rpl_y]
        mov [bp - 0xc], ax
.37:
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0xe]
        push ax
        push 0x3
        call 0x14F6:SortPairs - 0x90
        add sp, 0x6
        mov word [bp - 0x20], 0x0
        jmp near .52
.38:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .39
        mov al, [rpl_b2]
        jmp short .40
        db 0x90
.39:
        mov al, [rpl_b1]
.40:
        cbw
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .41
        jmp near .51
.41:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + rpl_frame], -0x1
        jnz short .42
        jmp near .51
.42:
        mov ax, [bx + rpl_x]
        mov [bp - 0x10], ax
        mov ax, [bx + rpl_y]
        mov [bp - 0x1c], ax
        mov word [bp - 0x2], 0x0
        mov ax, [bp + 0x8]
        cmp [bp - 0x1c], ax
        jng short .43
        mov [bp - 0x1c], ax
        mov word [bp - 0x2], 0x1
        jmp short .44
        db 0x90
.43:
        sub ax, 0xa8
        cmp ax, [bp - 0x1c]
        jl short .44
        mov ax, [bp + 0x8]
        sub ax, 0xa7
        mov [bp - 0x1c], ax
        mov word [bp - 0x2], 0x2
.44:
        cmp word [bp - 0x2], 0x0
        jz short .46
        mov ax, [bp + 0x6]
        add ax, 0x134
        cmp ax, [bp - 0x10]
        jg short .45
        mov ax, [bp + 0x6]
        add ax, 0x133
        mov [bp - 0x10], ax
        or byte [bp - 0x2], 0x4
        jmp short .48
.45:
        mov ax, [bp + 0x6]
        add ax, strict word 0xc
        cmp ax, [bp - 0x10]
        jng short .48
        mov [bp - 0x10], ax
        or byte [bp - 0x2], 0x8
        jmp short .48
.46:
        mov ax, [bp + 0x6]
        add ax, 0x140
        cmp ax, [bp - 0x10]
        jg short .47
        mov ax, [bp + 0x6]
        add ax, 0x13f
        mov [bp - 0x10], ax
        mov word [bp - 0x2], 0x4
        jmp short .48
        db 0x90
.47:
        mov ax, [bp + 0x6]
        cmp [bp - 0x10], ax
        jnl short .48
        mov [bp - 0x10], ax
        mov word [bp - 0x2], 0x8
.48:
        cmp word [bp - 0x2], 0x0
        jz short .49
        push 0x0
        mov al, [bp - 0x2]
        and ax, strict word 0x8
        push ax
        push word [bp - 0x1c]
        push word [bp - 0x10]
        push word [bp - 0x2]
        call 0x03A3:JoyNibble
        add sp, 0x2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bp - 0x1e]
        shl ax, byte 0x3
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push word [bx + RinkOverlayFrames2]
        jmp short .50
.49:
        push 0x0
        push 0x0
        push word [bp - 0x1c]
        push word [bp - 0x10]
        mov bx, [bp - 0x1e]
        shl bx, 1
        push word [bx + RinkOverlayFrames]
.50:
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.51:
        inc word [bp - 0x20]
.52:
        cmp word [bp - 0x20], 0x3
        jnl short .54
        mov si, [bp - 0x20]
        shl si, 1
        mov ax, [bp + si - 0x8]
        mov [bp - 0x1e], ax
        cmp ax, strict word 0x2
        jz short .53
        jmp near .38
.53:
        cmp byte [rpl_b3], 0xff
        jz short .51
        push 0x0
        push 0x0
        mov al, [rpl_b3]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        push word [bx + rpl_y]
        push word [bx + rpl_x]
        push word [RinkOverlayFrames2]
        jmp short .50
.54:
        mov word [bp - 0x1e], 0xf
        mov ax, [rpl_door]
        mov [bp - 0x2], ax
        cmp ax, 0x284
        jl short .57
        cmp ax, 0x288
        jg short .57
        push 0x0
        cmp word [rpl_puckframe], 0x0
        jnl short .55
        mov ax, 0x1
        jmp short .56
        db 0x90
.55:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.56:
        push ax
        push word [rpl_shadow]
        push word [rpl_puckframe]
        jmp short .60
        db 0x90
.57:
        cmp word [bp - 0x2], 0x189
        jnz short .58
        cmp word [rpl_camx], 0xff00
        jng short .58
        cmp byte [rpl_b3], 0x10
        jnz short .59
.58:
        mov bx, [bp - 0x1e]
        shl bx, 1
        cmp word [bx + rpl_y], 0x0
        jl short .61
        cmp word [bp - 0x2], 0x22a
        jl short .61
        cmp word [bp - 0x2], 0x237
        jg short .61
.59:
        push 0x0
        push 0x0
        mov bx, [bp - 0x1e]
        shl bx, 1
        push word [bx + rpl_y]
        push word [bx + rpl_x]
.60:
        push word [bp - 0x2]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.61:
        mov word [bp - 0x1e], 0xe
        cmp byte [rpl_b3], 0x10
        jz short .62
        cmp word [rpl_camx], 0x0
        jl short .62
        push 0x0
        push 0x0
        mov ax, [rpl_camx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [rpl_pucky]
        push ax
        push word [rpl_puckx]
        push word [rpl_reff]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.62:
        mov word [bp - 0x20], 0x0
        jmp short .66
        db 0x90
.63:
        push 0x0
        push 0x0
        mov ax, [rpl_camx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov bx, [bp - 0x1e]
        shl bx, 1
        add ax, [bx + rpl_y]
        push ax
.64:
        push word [bx + rpl_x]
        push word [bx + rpl_frame]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.65:
        inc word [bp - 0x20]
.66:
        cmp word [bp - 0x20], 0x11
        jl short .67
        jmp near .79
.67:
        mov bx, [bp - 0x20]
        shl bx, 1
        mov ax, [bx + rpl_words2]
        mov [bp - 0x1e], ax
        cmp ax, strict word 0xf
        jz short .65
        cmp ax, strict word 0xe
        jnz short .70
        cmp byte [rpl_b3], 0xff
        jnz short .65
        cmp word [rpl_camx], 0x0
        jng short .65
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + rpl_y], 0xe8
        jnl short .65
        cmp word [bx + rpl_y], 0xff18
        jg short .63
        cmp word [bx + rpl_y], 0xff10
        jl short .63
        mov ax, [bx + rpl_x]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jng short .68
        jmp near .63
.68:
        cmp word [rpl_camx], 0xd
        jl short .69
        jmp near .63
.69:
        jmp short .65
        db 0x90
.70:
        cmp ax, strict word 0xc
        jnl short .71
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx + rpl_puckowner], 0x0
        jl short .65
.71:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + rpl_frame], -0x1
        jz short .76
        cmp ax, strict word 0xc
        jnl short .76
        cmp byte [rpl_b3], 0xff
        jz short .72
        mov al, [rpl_b3]
        cbw
        cmp ax, [bp - 0x1e]
        jz short .73
.72:
        mov al, [rpl_b1]
        cbw
        cmp ax, [bp - 0x1e]
        jz short .73
        mov al, [rpl_b2]
        cbw
        cmp ax, [bp - 0x1e]
        jz short .73
        mov ax, [bp - 0x1e]
        cmp [replayfollow], ax
        jz short .73
        cmp [replaymode], ax
        jnz short .74
.73:
        mov bx, [bp - 0x1e]
        mov al, [bx + rpl_puckowner]
        cbw
        push ax
        jmp short .75
.74:
        cmp word [shownumbers], 0x0
        jz short .76
        push -0x1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.75:
        mov al, [bx + rpl_jerseys]
        cbw
        push ax
        shl bx, 1
        push word [bx + rpl_y]
        push word [bx + rpl_x]
        call 0x1E7E:DrawSpriteNumber
        add sp, 0x8
.76:
        cmp word [bp - 0x1e], 0x5
        jng short .77
        mov ax, 0x1
        jmp short .78
.77:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.78:
        push ax
        mov bx, [bp - 0x1e]
        mov al, [bx + rpl_flags]
        cbw
        push ax
        shl bx, 1
        push word [bx + rpl_y]
        jmp near .64
        db 0x90
.79:
        cmp word [rpl_pucky], 0xff18
        jg short .80
        cmp word [rpl_pucky], 0xff14
        jl short .80
        mov ax, [rpl_puckx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x14
        jg short .80
        cmp word [rpl_camx], 0xd
        jl short .80
        push 0x0
        push 0x0
        mov ax, [rpl_camx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [rpl_pucky]
        push ax
        push word [rpl_puckx]
        push word [rpl_reff]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.80:
        cmp word [camy], 0xff50
        jnl short .81
        push word [bp - 0x22]
        mov es, [segDgroup9]
        mov ax, [es:ClipLeftX]
        mov bx, [es:ClipTopY]
        mov dx, [es:ClipRightX]
        call 0x0FEF:SetClipRectRegs
.81:
        cmp word [camy], 0xff70
        jnl short .82
        call 0x1E7E:DrawRinkEndArt
.82:
        mov word [bp - 0x1e], 0xf
        cmp word [rpl_shadow], 0x0
        jnl short .83
        cmp word [rpl_door], 0x22a
        jl short .83
        cmp word [rpl_door], 0x237
        jg short .83
        push 0x0
        push 0x0
        push word [rpl_shadow]
        push word [rpl_puckframe]
        push word [rpl_door]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
.83:
        mov word [bp - 0x1e], 0xe
        cmp word [rpl_pucky], 0xfef8
        jnl short DrawReplayFrameTail + 0xBA0
        cmp byte [rpl_b3], 0xff
        jnz short DrawReplayFrameTail + 0xBA0
        cmp word [rpl_camx], 0x0
        jl short DrawReplayFrameTail + 0xBA0
        push 0x0
        push 0x0
        mov ax, [rpl_camx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [rpl_pucky]
        push ax
        push word [rpl_puckx]
        push word [rpl_reff]
        call 0x1E7E:DrawFrameSprite
        add sp, 0xa
