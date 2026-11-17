; End-of-season awards: picks the winners and runs the ceremony (LP.OVL)
; The first bytes and LoadLeagueGameRefTail finish LoadLeagueGameRef from league_game_ref.asm.
        push di
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
LoadLeagueGameRefTail:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PickAwardWinners                                           2E46:000E  94 PC
; Trophy winners from the dbs.
;
; Calls BuildPathFar, ReadTeamNames, OpenReadShared, ReadRecord52, ReadRecord48, ReadGoalieSeasonRec,
; ReadEntry744, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
PickAwardWinners:
        enter 0x402, 0x0
        push di
        push si
        mov ax, 0xffff
        mov [bp - 0x60], ax
        mov [bp - 0x3ca], ax
        mov [bp - 0x3a], ax
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText47]
        push word [es:msgThereAreNoHilights + 0xB67]
        push word [es:msgThereAreNoHilights + 0xB65]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x5a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x1
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x5a]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        mov [bp - 0x3c6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText47]
        push word [es:msgThereAreNoHilights + 0xB67]
        push word [es:msgThereAreNoHilights + 0xB65]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x5a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x60]
        push ax
        lea ax, [bp - 0x5a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x3c6], ax
.1:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText47]
        push word [es:msgThereAreNoHilights + 0xB57]
        push word [es:msgThereAreNoHilights + 0xB55]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x5a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3ca]
        push ax
        lea ax, [bp - 0x5a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x3c6], ax
.2:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText47]
        push word [es:msgThereAreNoHilights + 0xB6B]
        push word [es:msgThereAreNoHilights + 0xB69]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x5a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3a]
        push ax
        lea ax, [bp - 0x5a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x3c6], ax
.3:
        mov word [bp - 0x3c4], 0x0
.4:
        mov si, [bp - 0x3c4]
        mov byte [bp + si - 0x38a], 0x0
        inc word [bp - 0x3c4]
        cmp word [bp - 0x3c4], 0xa
        jl short .4
        mov word [bp - 0x3c4], 0x0
        jmp near .49
        db 0x90
.5:
        mov al, [bp - 0x357]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov dl, [bp - 0x356]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x03, 0xCA                           ; insn: add cx, dx
        imul ax, ax, 0x64
        cwd
        idiv cx
        mov [bp - 0x38], ax
.6:
        cmp byte [bp - 0x383], 0x0
        jz short .8
        mov ax, [bp - 0x36]
        cmp [bp - 0x38c], ax
        jl short .8
        jnz short .7
        mov ax, [bp - 0x38]
        cmp [bp - 0x3c2], ax
        jl short .8
.7:
        mov ax, [bp - 0x36]
        cmp [bp - 0x38c], ax
        jnz short .9
        mov ax, [bp - 0x38]
        cmp [bp - 0x3c2], ax
        jnz short .9
        mov al, [bp - 0x357]
        cmp [AwardCandidates], al
        jnc short .9
.8:
        mov ax, 0xcc00
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x380]
        push ds
        pop es
        mov cx, 0x174
        rep movsw
        mov ax, [bp - 0x36]
        mov [bp - 0x38c], ax
        mov ax, [bp - 0x38]
        mov [bp - 0x3c2], ax
        mov byte [bp - 0x383], 0xff
.9:
        mov word [bp - 0x3c8], 0x0
        jmp short .14
        db 0x90
.10:
        mov ax, [AwardWinner9]
        mov [bp - 0x3d0], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov cx, [di + 0x30]
        add cx, [si + 0x34]
        add cx, [bx + 0x32]
.11:
        mov [bp - 0x5e], cx
        mov cx, [bx]
        mov [bp - 0x5c], cx
        mov ax, [bp - 0x3d8]
        add ax, [bp - 0x3d6]
        add ax, [bp - 0x3da]
        mov [bp - 0x3d2], ax
        cmp byte [bp - 0x381], 0x0
        jz short .12
        cmp ax, [bp - 0x5e]
        jg short .12
        jnz short .13
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        cmp [bp - 0x402], ax
        jnc short .13
.12:
        mov ax, 0xc9da
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        mov ax, 0xcb9a
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x402]
        mov cx, 0x18
        rep movsw
        mov [AwardWinner9], ax
        mov byte [AwardsPending], 0x1
        mov byte [bp - 0x381], 0xff
.13:
        inc word [bp - 0x3c8]
.14:
        cmp word [bp - 0x3c8], 0x19
        jl short .15
        jmp near .33
.15:
        cmp word [bp - 0x3c6], 0x0
        jz short .16
        jmp near .33
.16:
        mov si, [bp - 0x3c8]
        shl si, byte 0x2
        mov ax, [bp + si - 0x334]
        mov dx, [bp + si - 0x332]
        mov [bp - 0x3ce], ax
        mov [bp - 0x3cc], dx
        cmp ax, strict word 0xffff
        jnz short .17
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jz short .13
.17:
        push dx
        push ax
        lea ax, [bp - 0x3c0]
        push ss
        push ax
        push word [bp - 0x3ca]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0x3c6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        push word [bp - 0x392]
        push word [bp - 0x394]
        lea ax, [bp - 0x402]
        push ss
        push ax
        push word [bp - 0x3a]
        call 0x0CD1:ReadRecord48
        add sp, 0xa
        mov [bp - 0x3c6], ax
.18:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        cmp [bp - 0x402], ax
        jz short .13
        mov ax, [AwardWinner]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x38a], 0x0
        jz short .19
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x400]
        cmp [bx + 0x2], cx
        jc short .19
        jnz short .20
        mov cx, [bp - 0x402]
        cmp [bx], cx
        jna short .20
.19:
        mov ax, 0xc806
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x38a], 0xff
.20:
        mov ax, [AwardWinner2]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x389], 0x0
        jz short .21
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x3fc]
        cmp [bx + 0x6], cx
        jc short .21
        jnz short .22
        mov cx, [bp - 0x402]
        cmp [bx], cx
        jna short .22
.21:
        mov ax, 0xc83a
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x389], 0xff
.22:
        cmp byte [bp - 0x3be], 0x44
        jnz short .24
        mov ax, [AwardWinner3]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x388], 0x0
        jz short .23
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x3fc]
        cmp [bx + 0x6], cx
        jc short .23
        jnz short .24
        mov cx, [bp - 0x402]
        cmp [bx], cx
        jna short .24
.23:
        mov ax, 0xc86e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x388], 0xff
.24:
        cmp byte [bp - 0x3be], 0x4c
        jz short .25
        cmp byte [bp - 0x3be], 0x52
        jz short .25
        cmp byte [bp - 0x3be], 0x43
        jnz short .27
.25:
        mov ax, [AwardWinner4]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x387], 0x0
        jz short .26
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x3f2]
        cmp [bx + 0x10], cx
        jl short .26
        jnz short .27
        mov cx, [bp - 0x402]
        cmp [bx], cx
        jna short .27
.26:
        mov ax, 0xc8a2
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x387], 0xff
.27:
        cmp byte [bp - 0x3be], 0x47
        jz short .29
        cmp byte [bp - 0x3d4], 0x0
        jz short .29
        mov ax, [AwardWinner7]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x384], 0x0
        jz short .28
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x3fc]
        cmp [bx + 0x6], cx
        jc short .28
        jnz short .29
        mov cx, [bp - 0x402]
        cmp [bx], cx
        jna short .29
.28:
        mov ax, 0xc93e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x384], 0xff
.29:
        mov ax, [AwardWinner8]
        mov [bp - 0x98], ax
        cmp byte [bp - 0x382], 0x0
        jz short .30
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x3ea]
        cmp [bx + 0x18], cx
        jc short .30
        jnz short .31
        mov cx, [bp - 0x3f0]
        cmp [bx + 0x12], cx
        jna short .31
.30:
        mov ax, 0xc9a6
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x402]
        mov di, [bp - 0x98]
        mov cx, 0x18
        rep movsw
        mov byte [bp - 0x382], 0xff
.31:
        cmp byte [AwardsPending], 0x1
        jz short .32
        jmp near .10
.32:
        mov ax, [AwardWinner9]
        mov [bp - 0x98], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov cx, [di + 0x28]
        add cx, [si + 0x2a]
        add cx, [bx + 0x2c]
        jmp near .11
.33:
        mov word [bp - 0x3c8], 0x0
        jmp short .38
.34:
        mov ax, [AwardWinner9]
        mov [bp - 0x3d0], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov cx, [di + 0x30]
        add cx, [si + 0x34]
        add cx, [bx + 0x32]
.35:
        mov [bp - 0x5e], cx
        mov cx, [bx]
        mov [bp - 0x5c], cx
        mov ax, [bp - 0x66]
        add ax, [bp - 0x64]
        add ax, [bp - 0x62]
        mov [bp - 0x3d2], ax
        cmp byte [bp - 0x381], 0x0
        jz short .36
        cmp ax, [bp - 0x5e]
        jg short .36
        jnz short .37
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        cmp [bp - 0x96], ax
        jnc short .37
.36:
        mov ax, 0xc9da
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x3c0]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        mov ax, 0xcbca
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x96]
        mov cx, 0x1b
        rep movsw
        mov [AwardWinner9], ax
        mov byte [AwardsPending], 0x0
        mov byte [bp - 0x381], 0xff
.37:
        inc word [bp - 0x3c8]
.38:
        cmp word [bp - 0x3c8], 0x3
        jl short .39
        jmp near .48
.39:
        cmp word [bp - 0x3c6], 0x0
        jz short .40
        jmp near .48
.40:
        mov si, [bp - 0x3c8]
        shl si, byte 0x2
        mov ax, [bp + si - 0x2d0]
        mov dx, [bp + si - 0x2ce]
        mov [bp - 0x3ce], ax
        mov [bp - 0x3cc], dx
        cmp ax, strict word 0xffff
        jnz short .41
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jz short .37
.41:
        push dx
        push ax
        lea ax, [bp - 0x34]
        push ss
        push ax
        push word [bp - 0x3ca]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0x3c6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .42
        push word [bp - 0x6]
        push word [bp - 0x8]
        lea ax, [bp - 0x96]
        push ss
        push ax
        push word [bp - 0x3a]
        call 0x20E6:ReadGoalieSeasonRec
        add sp, 0xa
        mov [bp - 0x3c6], ax
.42:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .37
        cmp [bp - 0x96], ax
        jz short .37
        mov ax, [AwardWinner5]
        mov [bp - 0x3d0], ax
        cmp byte [bp - 0x386], 0x0
        jz short .43
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x82]
        cmp [bx + 0x14], cx
        jc short .43
        jnz short .44
        mov cx, [bp - 0x84]
        cmp [bx + 0x12], cx
        jnc short .44
.43:
        mov ax, 0xc8d6
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x34]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x96]
        mov di, [bp - 0x3d0]
        mov cx, 0x1b
        rep movsw
        mov byte [bp - 0x386], 0xff
.44:
        mov ax, [AwardWinner6]
        mov [bp - 0x3d0], ax
        cmp byte [bp - 0x385], 0x0
        jz short .45
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x86]
        cmp [bx + 0x10], cx
        ja short .45
        jnz short .46
        mov cx, [bp - 0x8a]
        cmp [bx + 0xc], cx
        jnc short .46
.45:
        mov ax, 0xc90a
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x34]
        push ds
        pop es
        mov cx, 0x1a
        rep movsw
        lea si, [bp - 0x96]
        mov di, [bp - 0x3d0]
        mov cx, 0x1b
        rep movsw
        mov byte [bp - 0x385], 0xff
.46:
        cmp byte [AwardsPending], 0x1
        jz short .47
        jmp near .34
.47:
        mov ax, [AwardWinner9]
        mov [bp - 0x98], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov cx, [di + 0x28]
        add cx, [si + 0x2a]
        add cx, [bx + 0x2c]
        jmp near .35
        db 0x90
.48:
        inc word [bp - 0x3c4]
.49:
        cmp word [bp - 0x3c4], 0x18
        jnl short .52
        cmp word [bp - 0x3c6], 0x0
        jnz short .52
        push word [bp - 0x3c4]
        lea ax, [bp - 0x380]
        push ss
        push ax
        push word [bp - 0x60]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        mov [bp - 0x3c6], ax
        mov al, [bp - 0x357]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        shl ax, 1
        mov cl, [bp - 0x355]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x36], ax
        cmp [bp - 0x357], ch
        jz short .50
        jmp near .5
.50:
        cmp [bp - 0x356], ch
        jz short .51
        jmp near .5
.51:
        mov word [bp - 0x38], 0x0
        jmp near .6
.52:
        lea ax, [bp - 0x3a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x3ca]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x60]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0x3c6]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ShowAwardScreens                                           2E46:06B4  94 PC
; One screen per award ('sparkle')
;
; Calls FlushInputEvents, RawBase, LookupMsg, EmsMapFrame, AllocRecData, LoadRawHeader, SaveCharTab,
; UseCharSeg and others. Far routine (retf).
;-----------------------------------------------------------------------------
ShowAwardScreens:
        enter 0x7a, 0x0
        push di
        push si
        call 0x0F99:FlushInputEvents
        push word [AwardRawB]
        push word [AwardRawA]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        push word [AwardTitleMsg]
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        les bx, [bp - 0x1e]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        add ax, strict word 0x12
        adc dx, 0x0
        mov [bp - 0x6c], ax
        mov [bp - 0x6a], dx
        push 0x0
        push dx
        push ax
        push strict word str_Sparkle
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x24], ax
        mov [bp - 0x22], dx
        mov ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x24]
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [es:bx]
        inc cx
        les si, [bp - 0x24]
        mov [es:si], cx
        mov es, dx
        mov ax, [es:bx + 0x2]
        inc ax
        les bx, [bp - 0x24]
        mov [es:bx + 0x2], ax
        push 0x0
        push strict word str_Wittle06Fnt_6
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x60], ax
        mov [bp - 0x5e], dx
        lea ax, [bp - 0x1a]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x0
        push 0x35
        call 0x0D39:SetTextColors
        add sp, 0x4
        mov word [bp - 0x66], 0x0
        jmp near .18
        db 0x90
.1:
        imul ax, bx, 0x34
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xc819
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xc809
        push cx
        push strict word str_SS_5
        lea cx, [bp - 0x5a]
        push cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x5a]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, strict word 0x71
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x62], ax
        lea ax, [bp - 0x5a]
        push ss
        push ax
        push word [bp - 0x64]
        mov cx, [bp - 0x62]
        add cx, 0xc4
        push cx
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov al, 0x15
        mul byte [si + AwardScores]
        add ax, 0xaa38
        push word 0x3a0b
        push ax
        lea ax, [bp - 0x5a]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x5a]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, strict word 0x71
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x62], ax
        lea ax, [bp - 0x5a]
        push ss
        push ax
        add word [bp - 0x64], 0xa
        push word [bp - 0x64]
        mov ax, [bp - 0x62]
        add ax, 0xc4
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov word [bp - 0x62], 0xcc
        add word [bp - 0x64], 0x14
        mov bx, [bp - 0x66]
        cmp byte [bx + AwardKinds], 0x0
        jz short .2
        jmp near .7
.2:
        push ds
        push strict word str_Gp_9
        mov ax, [bp - 0x64]
        add ax, strict word 0x8
        push ax
        push word 0xcc
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Min_3
        mov ax, [bp - 0x64]
        add ax, strict word 0x10
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Gaa_3
        mov ax, [bp - 0x64]
        add ax, strict word 0x18
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_AwardsW
        mov ax, [bp - 0x64]
        add ax, strict word 0x20
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_AwardsL
        mov ax, [bp - 0x64]
        add ax, strict word 0x28
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_AwardsT
        mov ax, [bp - 0x64]
        add ax, strict word 0x30
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_So_2
        mov ax, [bp - 0x64]
        add ax, strict word 0x38
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_En_2
        mov ax, [bp - 0x64]
        add ax, strict word 0x40
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Shots_4
        mov ax, [bp - 0x64]
        add ax, strict word 0x48
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pct_6
        mov ax, [bp - 0x64]
        add ax, strict word 0x50
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp - 0x66]
        shl bx, 1
        mov ax, [bx + AwardWinner]
        mov [bp - 0x74], ax
        mov [bp - 0x26], ax
        mov word [bp - 0x68], 0x0
        jmp short .4
.3:
        inc word [bp - 0x68]
.4:
        cmp word [bp - 0x68], 0x2
        jl short .5
        jmp near .21
.5:
        mov bx, [bp - 0x68]
        shl bx, 1
        push ds
        push word [bx + AwardTitlePtrs]
        push word [bp - 0x64]
        add word [bp - 0x62], 0x28
        mov ax, [bp - 0x62]
        sub ax, strict word 0xe
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp - 0x26]
        push word [bx]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x8
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        push word [bx + 0xc]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x10
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        mov ax, [bx + 0x10]
        mov cx, 0x64
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push ax
        push strict word str_D02d_2
        mov ax, [bp - 0x64]
        add ax, strict word 0x18
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        mov bx, [bp - 0x26]
        push word [bx + 0x2]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x20
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        push word [bx + 0x4]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x28
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        cmp word [bp - 0x68], 0x0
        jnz short .6
        mov bx, [bp - 0x26]
        push word [bx + 0x6]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x30
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
.6:
        mov bx, [bp - 0x26]
        push word [bx + 0x8]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x38
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        push word [bx + 0xa]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x40
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        push word [bx + 0x12]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x48
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x26]
        mov ax, [bx + 0x14]
        mov cx, 0xa
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push ax
        push strict word str_D01d
        mov ax, [bp - 0x64]
        add ax, strict word 0x50
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        mov ax, [bp - 0x74]
        add ax, strict word 0x16
        mov [bp - 0x26], ax
        jmp near .3
        db 0x90
.7:
        cmp byte [bx + AwardKinds], 0x1
        jz short .8
        jmp near .21
.8:
        push ds
        push strict word str_Gp_8
        mov ax, [bp - 0x64]
        add ax, strict word 0x8
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_AwardsG
        mov ax, [bp - 0x64]
        add ax, strict word 0x10
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_AwardsA
        mov ax, [bp - 0x64]
        add ax, strict word 0x18
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pt_3
        mov ax, [bp - 0x64]
        add ax, strict word 0x20
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pim_3
        mov ax, [bp - 0x64]
        add ax, strict word 0x28
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_PlusMinus
        mov ax, [bp - 0x64]
        add ax, strict word 0x30
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Ppg_2
        mov ax, [bp - 0x64]
        add ax, strict word 0x38
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Shg_2
        mov ax, [bp - 0x64]
        add ax, strict word 0x40
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Shots_3
        mov ax, [bp - 0x64]
        add ax, strict word 0x48
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pct_5
        mov ax, [bp - 0x64]
        add ax, strict word 0x50
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp - 0x66]
        shl bx, 1
        mov ax, [bx + AwardWinner]
        mov [bp - 0x2c], ax
        mov [bp - 0x70], ax
        mov word [bp - 0x68], 0x0
        jmp short .11
.9:
        mov word [bp - 0x5c], 0x0
.10:
        mov ax, [bp - 0x5c]
        mov cx, 0xa
        cwd
        idiv cx
        push dx
        mov ax, [bp - 0x5c]
        cwd
        idiv cx
        push ax
        push strict word str_D01d
        mov ax, [bp - 0x64]
        add ax, strict word 0x50
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        mov ax, [bp - 0x2c]
        add ax, strict word 0x12
        mov [bp - 0x70], ax
        inc word [bp - 0x68]
.11:
        cmp word [bp - 0x68], 0x2
        jl short .12
        jmp near .21
.12:
        mov bx, [bp - 0x68]
        shl bx, 1
        push ds
        push word [bx + AwardTitlePtrs]
        push word [bp - 0x64]
        add word [bp - 0x62], 0x28
        mov ax, [bp - 0x62]
        sub ax, strict word 0xe
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x8
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0x2]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x10
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0x4]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x18
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0x6]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x20
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0xc]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x28
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0x10]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x30
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0x8]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x38
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0xa]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x40
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        push word [bx + 0xe]
        push word 0x1d08
        mov ax, [bp - 0x64]
        add ax, strict word 0x48
        push ax
        push word [bp - 0x62]
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x70]
        cmp word [bx + 0xe], 0x0
        jnz short .13
        jmp near .9
.13:
        push 0x0
        push word [bx + 0xe]
        mov ax, 0x3e8
        mul word [bx + 0x2]
        mov cx, [bx + 0xe]
        shr cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        adc dx, 0x0
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [bp - 0x5c], ax
        jmp near .10
.14:
        call 0x0FEF:UseOtherPage
        push 0x0
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x0FEF:CopyPageToPage
        add sp, 0xa
        push word [bp - 0x72]
        push word [bp - 0x6e]
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x0FEF:PutBlock
        add sp, 0x8
        push word [bp - 0x72]
        push word [bp - 0x6e]
        mov bx, [bp - 0x2a]
        shl bx, byte 0x2
        push word [bx + AwardFrames3Seg]
        push word [bx + AwardFrames3]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        call 0x0FEF:DrawRleTrans
        add sp, 0x8
        call 0x0FEF:WaitTimerRetrace.calibrated
        call 0x0FEF:CopyPlane
        call 0x0FEF:WaitRetrace
        call 0x03A3:ReadCallCount
        sub ax, [bp - 0x7a]
        sbb dx, [bp - 0x78]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .16
        jg short .15
        cmp ax, strict word 0x5
        jna short .16
.15:
        call 0x03A3:ReadCallCount
        mov [bp - 0x7a], ax
        mov [bp - 0x78], dx
        inc word [bp - 0x2a]
        cmp word [bp - 0x2a], 0x3
        jnz short .16
        call 0x03A3:ReadCallCount
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x0000:_rand
        mov cx, 0x64
        and ah, 0x7f
        cwd
        idiv cx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        mov [bp - 0x7a], si
        mov [bp - 0x78], di
        call 0x0FEF:UseOtherPage
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x20], ax
        push ax
        push word 0xc8
        push word 0x140
        push ax
        push ax
        call 0x0FEF:CopyPageToPage
        add sp, 0xa
        push word [bp - 0x72]
        push word [bp - 0x6e]
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x0FEF:PutBlock
        add sp, 0x8
        call 0x0FEF:WaitTimerRetrace.calibrated
        call 0x0FEF:CopyPlane
        call 0x0FEF:WaitRetrace
.16:
        test byte [bp - 0x76], 0x2
        jnz short .17
        jmp near .22
.17:
        inc word [bp - 0x66]
.18:
        cmp word [bp - 0x66], 0xa
        jl short .19
        jmp near .27
.19:
        call 0x03A3:ReadCallCount
        mov [bp - 0x7a], ax
        mov [bp - 0x78], dx
        call 0x0FEF:UseOtherPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push strict word str_Scrn_2
        push word [AwardRawB]
        push word [AwardRawA]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        mov bx, [bp - 0x66]
        shl bx, byte 0x2
        push word [bx + AwardFrames2Seg]
        push word [bx + AwardFrames2]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word [si + AwardFramesSeg]
        push word [si + AwardFrames]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        mov bx, [bp - 0x66]
        shl bx, 1
        push word [bx + AwardNamePtrs]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, strict word 0x71
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x62], ax
        push ds
        push word [si + AwardNamePtrs]
        mov ax, 0x1e
        mov [bp - 0x64], ax
        push ax
        mov ax, [bp - 0x62]
        add ax, 0xc4
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        add word [bp - 0x64], 0xa
        mov bx, [bp - 0x66]
        cmp byte [bx + AwardKinds], 0x2
        jz short .20
        jmp near .1
.20:
        push word 0xcc05
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, strict word 0x71
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x62], ax
        push ds
        push strict word AwardText
        push word [bp - 0x64]
        add ax, 0xc4
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
.21:
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        push 0x64
        push 0x64
        push 0x0
        call 0x1B35:FadeZoomRectThunk
        add sp, 0xe
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x76], ax
        mov [bp - 0x20], ax
        call 0x03A3:ReadCallCount
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x0000:_rand
        mov cx, 0x64
        and ah, 0x7f
        cwd
        idiv cx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        mov [bp - 0x7a], si
        mov [bp - 0x78], di
.22:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .23
        lea cx, [bp - 0x64]
        push cx
        lea cx, [bp - 0x62]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x76], ax
.23:
        cmp word [bp - 0x20], 0x0
        jz short .24
        jmp near .14
.24:
        call 0x03A3:ReadCallCount
        cmp dx, [bp - 0x78]
        jnl short .25
        jmp near .16
.25:
        jg short .26
        cmp ax, [bp - 0x7a]
        ja short .26
        jmp near .16
.26:
        mov word [bp - 0x20], 0xffff
        mov word [bp - 0x2a], 0x0
        call 0x0000:_rand
        and ah, 0x7f
        mov cx, 0x3
        cwd
        idiv cx
        mov [bp - 0x28], dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov ax, [bp - 0x66]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl ax, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        mov ax, [bx + AwardTextY]
        mov [bp - 0x6e], ax
        mov ax, [bx + AwardTextY2]
        mov [bp - 0x72], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x72]
        push word [bp - 0x6e]
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x0FEF:GetBlock
        add sp, 0x8
        call 0x03A3:ReadCallCount
        mov [bp - 0x7a], ax
        mov [bp - 0x78], dx
        jmp near .16
        db 0x90, 0x90
.27:
        lea ax, [bp - 0x1a]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawAwardsSummary                                          2E46:1068  94 PC
; 'Awards Summary'
;
; Takes 3 words of stack arguments. Calls FlushInputEvents, UseCurrentPage, FadePaletteInThunk,
; ClearClipRect, UseOtherPage, LoadRawHeader, SaveCharTab, UseCharSeg and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawAwardsSummary:
        enter 0x5e, 0x0
        push di
        push si
        call 0x0F99:FlushInputEvents
        call 0x0FEF:UseCurrentPage
        push 0x10
        push ds
        push word [bp + 0x6]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push 0x0
        push strict word str_Wittle06Fnt_5
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1a], dx
        lea ax, [bp - 0x34]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0x1a]
        push di
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_16
        push 0x0
        push 0x0
        lea ax, [bp - 0x5e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_33
        push 0x0
        lea ax, [bp - 0x5e]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov word [bp - 0x4], 0x0
        mov [bp - 0x1c], di
        mov si, [bp - 0x4]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov cx, [bp + 0x6]
        mov es, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx + 0x10]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov [bx + si], al
        inc si
        cmp si, 0x300
        jl short .1
        mov si, [bp + 0x6]
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov al, 0x3f
        mov [si + 0xc0], al
        mov [si + 0xc1], al
        mov [si + 0xc2], al
        push 0x0
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        push 0x0
        push 0x0
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x0FEF:DrawRleAt
        add sp, 0x8
        push ds
        push strict word str_AwardsSummary
        push 0xa
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        mov word [bp - 0x4], 0x0
        mov di, 0xc819
        mov word [bp - 0x6], 0x1cd2
        mov word [bp - 0x8], 0x1e
        mov [bp - 0x2], di
        db 0x8B, 0xF7                           ; insn: mov si, di
.2:
        mov bx, [bp - 0x6]
        push ds
        push word [bx]
        mov di, [bp - 0x8]
        push di
        push 0xa
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp - 0x4]
        cmp byte [bx + AwardKinds], 0x2
        jnz short .3
        push ds
        push strict word AwardText
        jmp short .4
.3:
        push 0x6e
        push ds
        push si
        lea ax, [si - 0x10]
        push ds
        push ax
        lea ax, [bp - 0x5e]
        push ss
        push ax
        call 0x0F89:FitNameToWidth
        add sp, 0xe
        lea ax, [bp - 0x5e]
        push ss
        push ax
        push di
        push 0x5a
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov al, 0x15
        mul byte [si - 0x13]
        add ax, 0xaa38
        push word 0x3a0b
        push ax
.4:
        push di
        push word 0xc8
        call 0x0D39:DrawShadowText
        add sp, 0x8
        add si, 0x34
        add word [bp - 0x6], 0x2
        inc word [bp - 0x4]
        add word [bp - 0x8], 0xf
        cmp word [bp - 0x8], 0xb4
        jl short .2
        mov si, [bp + 0x6]
        call 0x0FEF:CopyPlane
        push 0x10
        push ds
        push si
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        push word 0x2710
        call 0x0C16:WaitButtonTimed
        add sp, 0x4
        push 0x10
        push ds
        push si
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        lea ax, [bp - 0x34]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; AwardsCeremony                                             2E46:125A  94 PC
; 'Welcome to the NHL awards presentation.'
;
; Calls FlushInputEvents, LoadRawHeader, UseCurrentPage, ClearClipRect, SetPaletteFar, BuildPathFar,
; LoadPackedHeader, SaveCharTab and others. Far routine (retf).
;-----------------------------------------------------------------------------
AwardsCeremony:
        enter 0x358, 0x0
        push di
        push si
        call 0x0F99:FlushInputEvents
        cmp word [SoundOptions], 0x8
        jnz short .1
        push 0x0
        push strict word str_MtafanKms
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x28], dx
        push 0x0
        push strict word str_MtafanCfg
        jmp short .2
        db 0x90
.1:
        push 0x0
        push strict word str_AdafanKms
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x28], dx
        push 0x0
        push strict word str_AdafanCfg
.2:
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2c], dx
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bp - 0x354], al
        mov [bp - 0x353], al
        mov [bp - 0x352], al
        mov word [bp - 0x2], 0x0
        mov [bp - 0x2e], di
        mov [bp - 0x2a], si
        mov si, [bp - 0x2]
.3:
        lea ax, [bp - 0x354]
        push ss
        push ax
        push 0x1
        push si
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        inc si
        cmp si, 0x100
        jl short .3
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Awards
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x3c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xc], dx
        push 0x0
        push strict word str_S1Fnt_5
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        lea ax, [bp - 0x54]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push strict word str_Hong
        mov ax, [bp - 0xc]
        push ax
        push di
        mov [bp - 0x358], di
        mov [bp - 0x356], ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x14], dx
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push strict word str_Pal_32
        push word [bp - 0x356]
        push word [bp - 0x358]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x14], dx
        push 0x0
        push 0xf
        call 0x0D39:SetTextColors
        add sp, 0x4
        push ds
        push strict word str_WelcomeToTheNhl
        push 0x1e
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push ds
        push strict word str_AwardsPresentation
        push 0x2a
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x0EDC:PlayJingle
        add sp, 0x8
        push 0x10
        lea ax, [si + 0x10]
        mov cx, [bp - 0x14]
        push cx
        push ax
        push 0x0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0EDC:WaitJingle
        push 0x10
        push di
        push si
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        lea ax, [bp - 0x54]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x356]
        push word [bp - 0x358]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0EDC:StopJingle
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [SoundOptions], 0x8
        jnz short .4
        push 0x0
        push strict word str_MtawardsKms
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x28], dx
        push 0x0
        push strict word str_MtawardsCfg
        jmp short .5
        db 0x90
.4:
        push 0x0
        push strict word str_AdawardsKms
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x28], dx
        push 0x0
        push strict word str_AdawardsCfg
.5:
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2c], dx
        push dx
        push si
        push word [bp - 0x28]
        push di
        call 0x0EDC:PlayJingle
        add sp, 0x8
        push cs
        call PickAwardWinners
        mov [bp - 0x10], ax
        mov word [bp - 0x4], 0xc7a2
        mov word [bp - 0x2], 0x1c28
        mov [bp - 0x2e], si
        mov [bp - 0x2a], di
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
.6:
        cmp word [bp - 0x10], 0x0
        jnz short .7
        push word 0x3701
        push strict word str_Ppv
        push ds
        push word [si]
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x80
        lea ax, [bp - 0x3c]
        push ax
        call 0x149D:LoadRaw
        add sp, 0x4
        add di, 0x4
        mov [di - 0x4], ax
        mov [di - 0x2], dx
        inc si
        inc si
        cmp si, 0x1c2c
        jc short .6
.7:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xF7                           ; insn: mov si, di
.8:
        cmp word [bp - 0x10], 0x0
        jnz short .9
        push word [AwardRawB]
        push word [AwardRawA]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        push word [si + AwardMsgIds2]
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        mov [di + AwardFrames2], ax
        mov [di + AwardFrames2Seg], dx
        push word [AwardRawD]
        push word [AwardRawC]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        push word [si + AwardMsgIds]
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        mov [di + AwardFrames], ax
        mov [di + AwardFramesSeg], dx
        inc si
        inc si
        add di, 0x4
        cmp di, 0x28
        jl short .8
.9:
        mov di, 0x1c54
        mov si, 0xc7fa
.10:
        cmp word [bp - 0x10], 0x0
        jnz short .11
        push word [AwardRawB]
        push word [AwardRawA]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        inc di
        inc di
        push word [di - 0x2]
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        add si, 0x4
        mov [si - 0x4], ax
        mov [si - 0x2], dx
        cmp si, 0xc806
        jc short .10
.11:
        cmp word [bp - 0x10], 0x0
        jz short .12
        jmp near .16
.12:
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embnhl
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Bkgd_2
        push 0x0
        lea ax, [bp - 0x3c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push strict word str_Pal_31
        push word [AwardRawB]
        push word [AwardRawA]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:LookupMsg
        add sp, 0x6
        mov [bp - 0x14], dx
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x14], dx
        mov word [bp - 0x2], 0x0
        mov si, [bp - 0x2]
        mov [bp - 0x16], di
        mov es, dx
.13:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx + 0x10]
        mov [bp + si - 0x354], al
        inc si
        cmp si, 0x300
        jl short .13
        lea ax, [bp - 0x354]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push cs
        call ShowAwardScreens
        push word [bp - 0x24]
        push word [bp - 0x26]
        lea ax, [bp - 0x354]
        push ax
        push cs
        call DrawAwardsSummary
        add sp, 0x6
        push word [bp - 0x20]
        push word [bp - 0x22]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [bp - 0x2], 0xc7a2
        mov si, [bp - 0x2]
        mov di, [bp - 0x10]
.14:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .15
        push word [si + 0x2]
        push word [si]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        add si, 0x4
        cmp si, 0xc7aa
        jc short .14
.15:
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
.16:
        call 0x0EDC:StopJingle
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf
