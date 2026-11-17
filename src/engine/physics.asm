; Checking, passing, shooting and puck and wall collisions (AI.OVL)

;-----------------------------------------------------------------------------
; Sweepcheck                                                 28BB:0000  94 PC
; Starts a sweep check by a player.
;
; Takes 1 word of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
Sweepcheck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x589
        call 0x2E42:SetSPA
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; burst                                                      28BB:0018  94 PC
; Gives a player a burst of speed in his direction at an energy cost.
;
; Takes 1 word of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
burst:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        mov [regd0], ax
        test byte [CrowdState], 0x4
        jz short .2
        sub word [regd0], 0xcc
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [regd0]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.1:
        mov [bx + di + 0x2c], ax
        cmp word [regd0], 0x0
        jnl short .2
        mov word [regd0], 0x0
.2:
        sar word [regd0], byte 0x7
        mov bx, [si + 0x36]
        shl bx, byte 0x2
        mov ax, [bx + dirtab0]
        imul word [regd0]
        add [si + 0xc], ax
        mov bx, [si + 0x36]
        shl bx, byte 0x2
        mov ax, [bx + dirtab_x]
        imul word [regd0]
        add [si + 0xe], ax
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x621
        call 0x2E42:SetSPA
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; check4check                                                28BB:009C  94 PC
; Looks for a chance to check an opponent ahead of the player, with odds from his checking rating; may
; try to block a shot instead.
;
; Takes 1 word of stack arguments. Calls randomd0, VectorToDir8, burst, Acheck. Far routine (retf).
;-----------------------------------------------------------------------------
check4check:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        mov al, [di + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x14
        neg ax
        mov [regd0], ax
        test byte [CrowdState], 0x1
        jz short .1
        sar ax, 1
        add [regd0], ax
.1:
        mov ax, [regd0]
        shl ax, 1
        call 0x0C11:randomd0
        cmp ax, strict word 0x8
        jng short .2
        jmp near .9
.2:
        cmp word [di + 0x5e], 0x6
        jl short .3
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .4
.3:
        mov si, 0x6
.4:
        shl si, byte 0x7
        add si, 0xb50e
        mov word [regd2], 0x6
.5:
        cmp word [si + 0x1a], 0x0
        jz short .6
        test byte [si + 0x44], 0x20
        jnz short .6
        test byte [si + 0x45], 0x1
        jnz short .6
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x1e
        jg short .6
        mov ax, [si + 0x6]
        sub ax, [di + 0x6]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x1e
        jg short .6
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        cmp ax, [di + 0x36]
        jz short .7
.6:
        add si, 0x80
        dec word [regd2]
        jnz short .5
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push di
        push cs
        call burst
        add sp, 0x2
        pop si
        pop di
        leave
        retf
.8:
        push si
        push di
        call 0x2C24:Acheck
        add sp, 0x4
.9:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; checkagr                                                   28BB:0168  94 PC
; Random roll for an aggressive act by a player, with odds from his aggression, position and the
; period.
;
; Takes 1 word of stack arguments. Calls randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
checkagr:
        enter 0x6, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov al, [di + 0x56]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov si, 0x14
        db 0x2B, 0xF0                           ; insn: sub si, ax
        shl si, byte 0x4
        test byte [di + 0x44], 0x8
        jz short .1
        shl si, 1
.1:
        mov ax, [di + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jg short .2
        mov ax, [di + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jg short .2
        sar si, 1
.2:
        cmp word [gsp], 0x2
        jng short .3
        shl si, byte 0x2
.3:
        mov bx, [di + 0x62]
        mov ax, [bx + 0x22]
        mov bx, [di + 0x60]
        sub ax, [bx + 0x22]
        cmp ax, strict word 0x1
        jl short .4
        shl si, byte 0x2
.4:
        cmp ax, strict word 0x2
        jl short .5
        shl si, byte 0x2
.5:
        test byte [gmode], 0x8
        jz short .10
        mov bx, [puckc]
        mov al, [bx]
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .10
        cmp al, 0x6
        jnl short .6
        mov ax, 0x1
        jmp short .7
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.7:
        mov [bp - 0x6], ax
        cmp word [di + 0x5e], 0x6
        jnl short .8
        mov ax, 0x1
        jmp short .9
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        xor ax, [bp - 0x6]
        jz short .10
        shl si, byte 0x2
.10:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        call 0x0C11:randomd0
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FacingBoards                                               28BB:0214  94 PC
; Returns 1 when the player is near the side or end boards and facing them.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
FacingBoards:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov bx, [bp + 0x6]
        mov di, [bx + 0x2]
        mov cx, [bx + 0x6]
        mov dx, [bx + 0x36]
        cmp di, -0x78
        jnl short .4
        cmp dx, 0x6
        jz short .3
        cmp cx, 0xe8
        jng short .1
        cmp dx, 0x7
        jz short .3
.1:
        cmp cx, 0xff18
        jnl short .8
        cmp dx, 0x5
.2:
        jnz short .8
.3:
        mov ax, 0x1
        pop di
        leave
        retf
.4:
        cmp di, 0x78
        jng short .6
        cmp dx, 0x2
        jz short .3
        cmp cx, 0xe8
        jng short .5
        cmp dx, 0x1
        jz short .3
.5:
        cmp cx, 0xff18
        jnl short .8
        cmp dx, 0x3
        jmp short .2
.6:
        cmp cx, 0xf2
        jng short .7
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .3
.7:
        cmp cx, 0xff0e
        jnl short .8
        cmp dx, 0x4
        jz short .3
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; checkcheck                                                 28BB:0284  94 PC
; Two players in contact: hold, body check, hits into the boards, penalties and falls.
;
; Takes 3 words of stack arguments. Calls Bcheck, VectorToDir8, SetSPA, randomd0, checkagr,
; AddPenalty, FacingBoards, FallDown and others. Far routine (retf).
;-----------------------------------------------------------------------------
checkcheck:
        enter 0x6, 0x0
        push di
        push si
        mov word [bp - 0x4], 0x2
        mov si, [bp + 0x6]
        mov di, [bp + 0x8]
.1:
        cmp word [di + 0x38], 0x639
        jnz short .2
        jmp near .22
.2:
        cmp word [di + 0x38], 0x873
        jnz short .3
        jmp near .22
.3:
        cmp word [di + 0x38], 0x589
        jnz short .4
        push di
        push si
        push cs
        call Bcheck
        jmp near .23
        db 0x90
.4:
        cmp word [si + 0x38], 0x621
        jz short .5
        jmp near .24
.5:
        test byte [gmode], 0x1
        jz short .6
        mov ax, 0x100
        mov [si + 0x18], ax
        mov [di + 0x18], ax
.6:
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov dx, [di + 0x6]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [bp - 0x6], ax
        mov al, [bp - 0x6]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [bp - 0x2], ax
        test byte [si + 0x49], 0x8
        jz short .7
        neg ax
        and ax, strict word 0x7
        mov [bp - 0x2], ax
.7:
        or byte [si + 0x44], 0x20
        mov bx, [bp - 0x2]
        shl bx, 1
        mov ax, [bx + g_5A2C]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        cmp word [di + 0x1a], 0x0
        jnz short .8
        jmp near .24
.8:
        cmp word [bp + 0xa], 0x14
        jnl short .9
        jmp near .24
.9:
        mov al, [si + 0x44]
        and al, 0x8
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xc4
        add ax, 0xa0
        mov [bp - 0x2], ax
        cmp ax, 0xa0
        jnz short .10
        mov ax, 0x1
        jmp short .11
        db 0x90
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.11:
        mov cl, [di + 0x44]
        and cl, 0x8
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .12
        mov word [bp - 0x2], 0x78
.12:
        mov al, [di + 0x4a]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, [si + 0x4a]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add ax, [bp - 0x2]
        sar ax, 1
        sub ax, [di + 0x18]
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .16
        call 0x0C11:randomd0
        mov [bp - 0x2], ax
        mov al, [si + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp - 0x2]
        jnl short .16
        cmp word [di + 0x5e], 0x10
        jnz short .13
        jmp near .24
.13:
        push si
        push cs
        call checkagr
        add sp, 0x2
        cmp ax, strict word 0x4
        jng short .14
        jmp near .24
.14:
        test byte [gmode], 0x10
        jz short .15
        jmp near .24
.15:
        mov ax, 0x2
        call 0x0C11:randomd0
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        add ax, strict word 0xc
        push ax
        push si
        call 0x327B:AddPenalty
        jmp near .23
        db 0x90
.16:
        cmp word [di + 0x5e], 0x10
        jnz short .18
        test byte [si + 0x44], 0x8
        jnz short .17
        jmp near .24
.17:
        inc word [refhitcount]
        cmp word [refhitcount], 0x3
        jl short .21
        mov word [refhitcount], 0x0
        push 0x13
        jmp short .20
        db 0x90, 0x90
.18:
        test byte [gmode], 0x10
        jnz short .21
        cmp word [di + 0x18], 0x23
        jng short .19
        mov al, [bp - 0x6]
        sub al, [si + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .19
        mov al, [di + 0x36]
        sub al, [si + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .19
        push di
        push cs
        call FacingBoards
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        push si
        push cs
        call checkagr
        add sp, 0x2
        cmp ax, strict word 0x14
        jnl short .19
        push 0x14
        jmp short .20
.19:
        push si
        push cs
        call checkagr
        add sp, 0x2
        cmp ax, strict word 0x3
        jg short .21
        mov ax, 0x2
        call 0x0C11:randomd0
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        add ax, strict word 0xe
        push ax
.20:
        push si
        call 0x327B:AddPenalty
        add sp, 0x4
.21:
        push di
        push si
        push cs
        call FallDown
        jmp short .23
        db 0x90
.22:
        push di
        push si
        push cs
        call holdcheck
.23:
        add sp, 0x4
.24:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x8B, 0xFE                           ; insn: mov di, si
        db 0x8B, 0xF2                           ; insn: mov si, dx
        dec word [bp - 0x4]
        jz short .25
        jmp near .1
.25:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkgoalp                                                 28BB:047E  94 PC
; Collision of a player with a goal net.
;
; Takes 4 words of stack arguments. Calls ImulRegs, CheckBump, FoldScale, wallcoll. Far routine
; (retf).
;-----------------------------------------------------------------------------
checkgoalp:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        cmp word [di + 0xa], 0xa
        jng short .1
        jmp near .4
.1:
        cmp word [di + 0x5e], 0xb
        jng short .2
        cmp word [di + 0x5e], 0x10
        jz short .2
        jmp near .4
.2:
        mov si, [bp + 0xc]
        mov bx, [bp + 0x8]
        sub si, [bx + 0x6]
        mov ax, [bx + 0x2]
        sub [bp + 0xa], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        neg ax
        mov [regd0], ax
        mov ax, [bp + 0xa]
        mov [regd1], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, byte 0x4
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        call 0x03A3:ImulRegs
        mov bx, 0x400
        call 0x03A3:DivWords.regs
        mov [bp - 0x2], ax
        cmp ax, 0x100
        ja short .4
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, byte 0x4
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov bx, 0x79
        call 0x03A3:DivWords.regs
        add ax, [bp - 0x2]
        cmp ax, 0x100
        ja short .4
        cmp word [di + 0x5e], 0x10
        jz short .3
        push word [bp + 0x8]
        push di
        push cs
        call CheckBump
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
.3:
        push word [regd1]
        push word [regd0]
        call 0x03A3:FoldScale
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc si
        mov ax, [regd0]
        cwd
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x03A3:IdivWords.regs
        mov [regd0], ax
        mov ax, [regd1]
        cwd
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x03A3:IdivWords.regs
        mov [regd1], ax
        mov word [nethit], 0x1
        push di
        push cs
        call wallcoll
        add sp, 0x2
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkint                                                   28BB:055A  94 PC
; Interference roll between two players: may call a penalty and knock the player down.
;
; Takes 2 words of stack arguments. Calls FallDown, randomd0, AddPenalty. Far routine (retf).
;-----------------------------------------------------------------------------
checkint:
        enter 0x2, 0x0
        push di
        push si
        mov word [bp - 0x2], 0x2
        mov si, [bp + 0x6]
        mov di, [bp + 0x8]
.1:
        cmp word [di + 0x1a], 0x0
        jz short .2
        jmp near .6
.2:
        test byte [gmode], 0x1
        jz short .3
        jmp near .6
.3:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .4
        cmp word [si + 0x18], 0x19
        jng short .6
.4:
        cmp word [si + 0x18], 0x2
        jng short .6
        push si
        push di
        push cs
        call FallDown
        add sp, 0x4
        cmp word [lastimpact], 0x8
        jl short .6
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .5
        cmp word [lastimpact], 0xa
        jl short .6
.5:
        mov ax, [di + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xa0
        jl short .6
        cmp word [si + 0x5e], 0x10
        jz short .6
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [si + 0x60]
        cmp word [bx + 0x64], -0x3
        jng short .6
        cmp word [di + 0x18], 0x1e
        jng short .6
        test byte [si + 0x45], 0x10
        jnz short .6
        mov ax, 0x14
        mov cl, [si + 0x56]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        call 0x0C11:randomd0
        cmp ax, strict word 0x2
        jg short .6
        test byte [gmode], 0x10
        jnz short .6
        push 0x11
        push si
        call 0x327B:AddPenalty
        add sp, 0x4
.6:
        db 0x8B, 0xD6                           ; insn: mov dx, si
        db 0x8B, 0xF7                           ; insn: mov si, di
        db 0x8B, 0xFA                           ; insn: mov di, dx
        dec word [bp - 0x2]
        jz short .7
        jmp near .1
.7:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkob                                                    28BB:0622  94 PC
; Shows the warning referee when a teammate is over the blue line ahead of the puck.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
checkob:
        enter 0x6, 0x0
        push di
        push si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        test byte [CrowdState], 0x2
        jnz short .1
        jmp near .12
.1:
        mov di, [bp + 0x6]
        mov [bp - 0x6], di
        cmp word [di + 0x5e], 0x6
        jl short .2
        mov si, 0x6
        jmp short .3
        db 0x90
.2:
        db 0x2B, 0xF6                           ; insn: sub si, si
.3:
        shl si, byte 0x7
        add si, 0xb50e
        mov bx, [bp - 0x6]
        test byte [bx + 0x44], 0x80
        jnz short .8
        mov bx, [pucky]
        cmp word [bx], -0x52
        jl short .7
        mov byte [bp - 0x1], 0x0
.4:
        cmp word [si + 0x1a], 0x0
        jl short .5
        cmp word [si + 0x6], -0x52
        jl short .6
.5:
        add si, 0x80
        inc byte [bp - 0x1]
        cmp byte [bp - 0x1], 0x6
        jl short .4
        jmp short .7
.6:
        mov dx, 0x1
.7:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .11
        test byte [gmode2], 0x80
        jnz short .12
        or byte [gmode2], 0x80
        cmp word [bannermsg], 0x4
        jnl short .12
        mov word [bannermsg], 0x4
        mov word [bannertimer], 0x0
        pop si
        pop di
        leave
        retf
.8:
        mov bx, [pucky]
        cmp word [bx], 0x52
        jg short .7
        mov byte [bp - 0x1], 0x0
.9:
        cmp word [si + 0x1a], 0x0
        jl short .10
        cmp word [si + 0x6], 0x52
        jg short .6
.10:
        add si, 0x80
        inc byte [bp - 0x1]
        cmp byte [bp - 0x1], 0x6
        jl short .9
        jmp short .7
.11:
        test byte [gmode2], 0x80
        jz short .12
        and byte [gmode2], 0x7f
        cmp word [bannermsg], 0x4
        jnz short .12
        cmp word [bannertimer], 0x0
        jnz short .12
        mov word [bannermsg], 0xffff
.12:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; checkpuckcoll_ccx                                          28BB:06F6  94 PC
; Puck test for one object near the puck: stick, body or goalie.
;
; Takes 2 words of stack arguments. Calls GetHot, ImulRegs, puckstick, puckgoalie, puckbody. Far
; routine (retf).
;-----------------------------------------------------------------------------
checkpuckcoll_ccx:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        mov bx, [puckc]
        mov al, [bx]
        cbw
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jnz short .1
        jmp near .18
.1:
        cmp si, 0xb
        jng short .2
        cmp si, 0x10
        jz short .2
        jmp near .18
.2:
        db 0x8B, 0xFE                           ; insn: mov di, si
        shl di, byte 0x7
        add di, 0xb50e
        test byte [di + 0x44], 0x4
        jz short .3
        jmp near .18
.3:
        cmp word [di + 0x3e], 0x0
        jz short .4
        jmp near .18
.4:
        test byte [di + 0x45], 0x4
        jz short .5
        jmp near .12
.5:
        cmp si, 0x10
        jnz short .6
        jmp near .12
.6:
        mov si, [bp + 0x6]
        cmp word [si + 0xa], 0x5
        jng short .7
        jmp near .13
.7:
        cmp word [si + 0x10], 0x200
        jng short .8
        jmp near .13
.8:
        push di
        call 0x2E42:GetHot
        add sp, 0x2
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        add [regd0], ax
        mov ax, [regd0]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xe
        jng short .9
        jmp near .13
.9:
        mov ax, [di + 0x6]
        sub ax, [si + 0x6]
        add [regd1], ax
        mov ax, [regd1]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xe
        jg short .13
        mov ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [regd1], ax
        mov [g_D674], dx
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [regd0], ax
        mov [g_D66E], dx
        mov ax, [regd1]
        mov dx, [g_D674]
        add [regd0], ax
        adc [g_D66E], dx
        mov word [regd1], 0xc4
        mov word [g_D674], 0x0
        cmp word [si + 0x3e], 0x0
        jng short .10
        sar word [regd1], byte 0x2
.10:
        mov ax, [regd0]
        mov dx, [g_D66E]
        cmp [g_D674], dx
        jc short .13
        ja short .11
        cmp [regd1], ax
        jc short .13
.11:
        push di
        push si
        push cs
        call puckstick
        jmp near .17
.12:
        mov si, [bp + 0x6]
.13:
        cmp word [di + 0x1a], 0x0
        jnz short .16
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .14
        jmp near .18
.14:
        mov ax, [di + 0x6]
        sub ax, [si + 0x6]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0xc
        jng short .15
        jmp near .18
.15:
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x4]
        adc dx, [bp - 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .18
        cmp ax, 0x90
        ja short .18
        push di
        push si
        push cs
        call puckgoalie
        jmp short .17
.16:
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov [regd0], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x8
        jg short .18
        mov ax, [di + 0x6]
        sub ax, [si + 0x6]
        mov [regd1], ax
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x8
        jg short .18
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x8]
        adc dx, [bp - 0x6]
        mov [regd0], ax
        mov [g_D66E], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .18
        cmp ax, strict word 0x40
        ja short .18
        push di
        push si
        push cs
        call puckbody
.17:
        add sp, 0x4
.18:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkpuckcoll                                              28BB:08C6  94 PC
; Tests the puck against the objects near it, walking the sorted object list both ways.
;
; Takes 1 word of stack arguments. Calls checkpuckcoll_ccx. Far routine (retf).
;-----------------------------------------------------------------------------
checkpuckcoll:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, [di + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x190
        jng short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [di + 0xe], ax
        mov [di + 0xc], ax
.1:
        cmp word [di + 0xa], 0x10
        jg short .5
        mov bx, [di + 0x5e]
        shl bx, 1
        mov si, [bx + g_D496]
        cmp si, 0x10
        jz short .3
.2:
        mov al, [si + g_D4F5]
        cbw
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + g_D474]
        sub ax, [di + 0x6]
        cmp ax, strict word 0x16
        jg short .3
        push word [bp - 0x2]
        push di
        push cs
        call checkpuckcoll_ccx
        add sp, 0x4
        inc si
        cmp si, 0x10
        jnz short .2
.3:
        mov bx, [di + 0x5e]
        shl bx, 1
        mov si, [bx + g_D496]
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .5
.4:
        mov al, [si + g_D4F3]
        cbw
        mov [bp - 0x2], ax
        mov cx, [di + 0x6]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        sub cx, [bx + g_D474]
        cmp cx, 0x16
        jg short .5
        push ax
        push di
        push cs
        call checkpuckcoll_ccx
        add sp, 0x4
        dec si
        jnz short .4
.5:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CheckBump                                                  28BB:0956  94 PC
; Now and then a player running into the puck carrier passes on part of his speed.
;
; Takes 2 words of stack arguments. Calls randomd0, AddPenalty2. Far routine (retf).
;-----------------------------------------------------------------------------
CheckBump:
        enter 0x4, 0x0
        push di
        push si
        mov ax, 0x20
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.2:
        mov bx, [pucky]
        mov ax, [bx]
        mov bx, [bp + 0x8]
        sub ax, [bx + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jg short .1
        mov si, [bp + 0x6]
        mov di, [si + 0xc]
        mov ax, [si + 0xe]
        mov [bp - 0x2], ax
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x2000
        jg short .3
        mov ax, [bp - 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0x2000
        jng short .1
.3:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        sar dx, byte 0x2
        mov [bx + 0xc], dx
        mov ax, [bp - 0x2]
        sar ax, byte 0x2
        mov [bx + 0xe], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xc], ax
        mov [si + 0xe], ax
        or byte [sflags], 0x40
        test byte [gmode], 0x1
        jnz short .4
        push 0x18
        push si
        call 0x327B:AddPenalty2
        add sp, 0x4
.4:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GetLowestPen                                               28BB:09E2  94 PC
; Returns the lowest penalty time left for the shorthanded team.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
GetLowestPen:
        enter 0xa, 0x0
        push di
        push si
        mov dx, [hmtmap]
        sub dx, [awtmap]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .1
        mov dx, 0xb362
        mov bx, 0xb438
        jmp short .3
.1:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .2
        jmp near .10
.2:
        mov dx, 0xb438
        mov bx, 0xb362
.3:
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x6], cx
        lea di, [bx + 0x9c]
        mov [bp - 0x8], dx
        mov [bp - 0x4], bx
        mov [bp - 0xa], cx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        jmp short .5
        db 0x90
.4:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        add bx, [bp - 0x4]
        mov si, [bx + 0x64]
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .5
        and si, 0x3fff
        db 0x2B, 0xF2                           ; insn: sub si, dx
        add [bp - 0x6], si
        db 0x8B, 0xD6                           ; insn: mov dx, si
.5:
        mov al, [di]
        inc di
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .4
        mov [bp - 0xa], dx
        mov dx, [bp - 0x8]
        mov cx, [bp - 0xa]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cmp word [bx + 0x22], 0x6
        jnz short .7
.6:
        mov ax, [bp - 0x6]
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        sub [bp - 0x6], cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        add si, 0x9c
        db 0x8B, 0xFE                           ; insn: mov di, si
.8:
        mov al, [di]
        inc di
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .6
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov si, [bx + 0x64]
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .8
        mov dx, [bp - 0x6]
        and si, 0x3fff
        db 0x3B, 0xF2                           ; insn: cmp si, dx
        jng short .9
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        pop si
        pop di
        leave
        retf
        db 0x90
.9:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0xa]
        pop si
        pop di
        leave
        retf
        db 0x90
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; chk4lc                                                     28BB:0AA0  94 PC
; Decides whether the computer team should change lines.
;
; Takes 1 word of stack arguments. Calls randomd0, GetLowestPen, AvgCline, CompLine, setpersonel,
; CompShoot. Far routine (retf).
;-----------------------------------------------------------------------------
chk4lc:
        enter 0x4, 0x0
        push di
        push si
        test byte [CrowdState], 0x4
        jnz short .1
        jmp near .12
.1:
        mov si, [bp + 0x6]
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        test byte [si + 0x44], 0x80
        jnz short .2
        neg word [regd0]
.2:
        cmp word [regd0], 0x0
        jnl short .3
        jmp near .12
.3:
        cmp word [regd0], 0x4e
        jng short .4
        jmp near .12
.4:
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        jmp near .12
.5:
        test byte [si + 0x45], 0x8
        jz short .6
        jmp near .12
.6:
        mov di, [si + 0x60]
        mov ax, [si + 0x62]
        mov [bp - 0x4], ax
        mov bx, [si + 0x60]
        mov dx, [bx + 0x22]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        sub dx, [bx + 0x22]
        mov bx, [si + 0x60]
        test byte [bx + 0xba], 0x40
        jz short .7
        cmp word [gameclock], 0xf
        jl short .12
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .11
        push cs
        call GetLowestPen
        cmp ax, strict word 0xf
        jnl short .11
        jmp short .12
        db 0x90, 0x90
.7:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        push di
        call 0x2E42:AvgCline
        add sp, 0x2
        cmp word [gameclock], 0xf
        jl short .12
        cmp word [gameclock], 0x1e
        jnl short .8
        cmp word [regd0], 0x800
        ja short .12
.8:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .9
        mov dx, 0xf33
        jmp short .10
.9:
        mov dx, [di + 0xbc]
.10:
        cmp dx, [regd0]
        jc short .12
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .11
        push cs
        call GetLowestPen
        cmp ax, strict word 0xf
        jl short .12
.11:
        push di
        push word [bp - 0x4]
        call 0x2E42:CompLine
        add sp, 0x4
        push di
        call 0x2E42:setpersonel
        add sp, 0x2
        push word [bp + 0x6]
        push cs
        call CompShoot
        add sp, 0x2
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; dopass                                                     28BB:0B96  94 PC
; Passes the puck in the pass direction, to the best teammate there if any.
;
; Takes 1 word of stack arguments. Calls VectorToDir8, ImulRegs, passtoa0, randomd0, Findhittype,
; SetSPA, PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
dopass:
        enter 0x1a, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov word [onetimerflag], 0x0
        and byte [sflags], 0xfb
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov word [si + 0x3e], 0x10
        mov ax, [si + 0x5e]
        mov [lastplayer], ax
        cmp word [si + 0x1a], 0x0
        jnz short .1
        mov bx, 0x8
        jmp short .2
        db 0x90
.1:
        mov bl, [si + 0x51]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
.2:
        lea ax, [bx + 0x28]
        shl ax, byte 0x2
        mov [passspeed], ax
        cmp word [si + 0x5e], 0x6
        jl short .3
        mov ax, 0x6
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        shl ax, byte 0x7
        add ax, 0xb50e
        mov word [bp - 0xe], 0xffff
        mov word [bp - 0xc], 0xffff
        mov bx, 0x6
        mov [bp - 0x10], bx
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        cmp [bp + 0x6], si
        jnz short .6
        jmp near .13
.6:
        cmp word [si + 0x1a], 0x0
        jnz short .7
        jmp near .13
.7:
        test byte [si + 0x45], 0x4
        jz short .8
        jmp near .13
.8:
        mov ax, [si + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        mov [bp - 0x8], ax
        mov cx, [si + 0x6]
        mov bx, [pucky]
        sub cx, [bx]
        mov [bp - 0xa], cx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        call 0x0D5F:VectorToDir8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        sub di, [passdir]
        and di, 0x7
        cmp di, 0x1
        jng short .9
        cmp di, 0x7
        jnz short .13
.9:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .10
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        jmp short .11
        db 0x90
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x1
.11:
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov ax, [bp - 0x8]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [bp - 0x1a], ax
        mov [bp - 0x18], dx
        mov ax, [bp - 0xa]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x1a]
        adc dx, [bp - 0x18]
        add ax, [bp - 0x16]
        adc dx, [bp - 0x14]
        cmp dx, [bp - 0xc]
        ja short .13
        jc short .12
        cmp ax, [bp - 0xe]
        ja short .13
.12:
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        mov [bp - 0x12], si
.13:
        add si, 0x80
        dec word [bp - 0x10]
        jz short .14
        jmp near .5
.14:
        cmp word [bp - 0xc], 0x0
        jl short .15
        push word [bp - 0x12]
        push cs
        call passtoa0
        add sp, 0x2
        mov si, [bp + 0x6]
        jmp short .16
        db 0x90
.15:
        mov si, [bp + 0x6]
        mov bx, [passdir]
        shl bx, byte 0x2
        mov dx, [bx + dirtab_x]
        mov ax, [passspeed]
        call 0x03A3:ImulRegs
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        mov bx, 0xbb8
        call 0x03A3:IdivWords.regs
        add ax, [si + 0xe]
        mov bx, [puckvy]
        mov [bx], ax
        mov bx, [passdir]
        shl bx, byte 0x2
        mov dx, [bx + dirtab0]
        mov ax, [passspeed]
        call 0x03A3:ImulRegs
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        mov bx, 0xbb8
        call 0x03A3:IdivWords.regs
        add ax, [si + 0xc]
        mov bx, [puckvx]
        mov [bx], ax
        mov ax, 0x1000
        call 0x0C11:randomd0
        mov bx, [puckvz]
        mov [bx], ax
.16:
        cmp word [si + 0x1a], 0x0
        jnz short .20
        mov bx, [puckvy]
        cmp word [bx], 0x0
        jnl short .17
        mov ax, 0x1
        jmp short .18
        db 0x90
.17:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.18:
        mov cl, [si + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .19
        neg word [bx]
.19:
        mov di, 0x1b9
        jmp short .21
.20:
        mov bx, [puckvx]
        mov ax, [bx]
        mov bx, [puckvy]
        mov dx, [bx]
        call 0x0D5F:VectorToDir8
        push ax
        push si
        push cs
        call Findhittype
        add sp, 0x4
        cmp ax, strict word 0x1
        db 0x1B, 0xFF                           ; insn: sbb di, di
        and di, -0x38
        add di, 0x3c1
.21:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x20
        mov bx, [puckvz]
        cmp byte [bx + 0x1], 0x6
        jl short .22
        mov ax, 0x99
        jmp short .23
.22:
        mov ax, 0x98
.23:
        push ax
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; passmode                                                   28BB:0DB4  94 PC
; Pass mode input: the pass button passes, the pad sets the pass direction.
;
; Takes 1 word of stack arguments. Calls dopass. Far routine (retf).
;-----------------------------------------------------------------------------
passmode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        test byte [regd2], 0x10
        jz short .1
        push word [bp + 0x6]
        jmp short .5
.1:
        test byte [regd0], 0x8
        jnz short .6
        mov al, [regd0]
        and ax, strict word 0x7
        mov [passdir], ax
        or byte [regd0], 0x8
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x8
        jz short .4
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jnz short .2
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        jmp short .3
.2:
        mov bx, 0x1
.3:
        cmp byte [bx + PadStates], 0x1
        jz short .6
.4:
        push si
.5:
        push cs
        call dopass
        add sp, 0x2
.6:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; setpassmode                                                28BB:0E04  94 PC
; Starts pass mode.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
setpassmode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        mov al, [bx + 0x36]
        and ax, strict word 0x7
        mov [passdir], ax
        or byte [sflags], 0x4
        leave
        retf

;-----------------------------------------------------------------------------
; passtoa0                                                   28BB:0E1A  94 PC
; Passes the puck to a given player.
;
; Takes 1 word of stack arguments. Calls assinsert, GetHot, ImulRegs, SqrtLong, randomd0, ToFixed. Far
; routine (retf).
;-----------------------------------------------------------------------------
passtoa0:
        enter 0x26, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [gmode], 0x10
        jnz short .1
        mov bx, [si + 0x60]
        inc word [bx + 0x12]
.1:
        mov ax, [si + 0x5e]
        mov [passplayer], ax
        push 0x13
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
        push si
        call 0x2E42:GetHot
        add sp, 0x2
        mov ax, [si + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        add ax, [regd0]
        mov [bp - 0x1a], ax
        sar ax, byte 0x2
        mov [bp - 0x8], ax
        mov ax, [si + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        add ax, [regd1]
        mov [bp - 0x1c], ax
        sar ax, byte 0x2
        mov [bp - 0xa], ax
        mov ax, [si + 0xc]
        mov dx, 0xf0
        call 0x03A3:ImulRegs
        mov [bp - 0x18], dx
        mov ax, [si + 0xe]
        mov dx, 0xf0
        call 0x03A3:ImulRegs
        mov [bp - 0x16], dx
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x18]
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [bp - 0xa]
        mov dx, [bp - 0x16]
        call 0x03A3:ImulRegs
        db 0x03, 0xF8                           ; insn: add di, ax
        shl di, 1
        mov [bp - 0x6], di
        mov ax, [bp - 0x18]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [passspeed]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sar dx, byte 0x2
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0x20], di
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [bp - 0x16]
        mov [bp - 0x24], di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        sub ax, [bp - 0x24]
        add ax, [bp - 0x20]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [bp - 0x8]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        mov [bp - 0x26], ax
        mov ax, [bp - 0xa]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        add dx, [bp - 0x26]
        db 0x8B, 0xC7                           ; insn: mov ax, di
        call 0x03A3:ImulRegs
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        mov ax, [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        sub ax, [bp - 0xe]
        sbb dx, [bp - 0xc]
        call 0x0D5F:SqrtLong
        sar di, byte 0x2
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .2
        mov di, 0x1
.2:
        mov word [bp - 0x4], 0x0
        mov [bp - 0x14], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
.3:
        db 0x8B, 0xF7                           ; insn: mov si, di
        db 0x8B, 0xC7                           ; insn: mov ax, di
        neg ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [bp - 0x6]
        cwd
        mov bx, [bp - 0x14]
        call 0x03A3:IdivWords.regs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .4
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x2
        jl short .3
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jg short .5
        mov si, 0x1
.5:
        cmp si, 0x18
        jng short .6
        mov si, 0x18
.6:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cmp ax, strict word 0xc
        jng short .7
        mov ax, 0xc
.7:
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0x6
        jng short .8
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        lea ax, [di + 0x1]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
.8:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov bx, [puckvz]
        mov [bx + 0x1], al
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl al, byte 0x3
        sub al, 0xa
        mov bx, [bp + 0x6]
        mov [bx + 0x27], al
        cbw
        sub ax, strict word 0x6
        mov [pucknopuck], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0x18]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x1a]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov [regd0], ax
        mov [g_D66E], dx
        mov bx, [puckx]
        mov ax, [bx]
        add ax, [regd0]
        mov bx, [bp + 0x6]
        mov [bx + 0x2a], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0x16]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x1c]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov [regd1], ax
        mov [g_D674], dx
        mov bx, [pucky]
        mov ax, [bx]
        add ax, [regd0]
        mov bx, [bp + 0x6]
        mov [bx + 0x2c], ax
        mov ax, [regd0]
        mov dx, [g_D66E]
        call 0x2E42:ToFixed
        imul bx, si, 0x78
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x03A3:IdivWords.regs
        mov bx, [puckvx]
        mov [bx], ax
        mov ax, [regd1]
        mov dx, [g_D674]
        call 0x2E42:ToFixed
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x03A3:IdivWords.regs
        mov bx, [puckvy]
        mov [bx], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; chk4pass                                                   28BB:105A  94 PC
; Computer pass check: looks for an open teammate and passes.
;
; Takes 1 word of stack arguments. Calls randomd0, VectorToDir8, ImulRegs, dopass, assexit. Far
; routine (retf).
;-----------------------------------------------------------------------------
chk4pass:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        cmp word [threat], 0x0
        jnz short .1
        mov al, [di + 0x53]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x10
        call 0x0C11:randomd0
        cmp ax, strict word 0x9
        jng short .1
        jmp near .20
.1:
        mov ax, 0x6
        call 0x0C11:randomd0
        mov [regd0], ax
        cmp word [di + 0x5e], 0x6
        jl short .2
        add word [regd0], 0x6
.2:
        cmp word [di + 0x1a], 0x0
        jz short .3
        mov bx, [puckx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x32
        jg short .3
        mov bx, [pucky]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xac
        jng short .3
        jmp near .20
.3:
        mov ax, [regd0]
        cmp [di + 0x5e], ax
        jnz short .4
        jmp near .20
.4:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x7
        add si, 0xb50e
        cmp word [si + 0x1a], 0x0
        jg short .5
        jmp near .20
.5:
        test byte [si + 0x45], 0x4
        jz short .6
        jmp near .20
.6:
        test byte [si + 0x44], 0x20
        jz short .7
        jmp near .20
.7:
        mov ax, [si + 0x6]
        mov [regd0], ax
        mov ax, [di + 0x6]
        mov [regd1], ax
        test byte [di + 0x44], 0x80
        jnz short .8
        neg word [regd0]
        neg word [regd1]
.8:
        test byte [CrowdState], 0x2
        jz short .9
        mov ax, [regd1]
        sub ax, strict word 0x4e
        mov cx, [regd0]
        sub cx, 0x4e
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jnl short .9
        jmp near .20
.9:
        test byte [CrowdState], 0x8
        jz short .10
        test byte [si + 0x45], 0x80
        jz short .10
        cmp word [regd1], -0x4e
        jnl short .10
        cmp word [regd0], 0x0
        jng short .10
        jmp near .20
.10:
        cmp word [regd0], 0x4e
        jg short .11
        mov ax, [regd1]
        sub [regd0], ax
        cmp word [regd0], -0xf
        jnl short .11
        jmp near .20
.11:
        mov ax, [si + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        mov [regd1], ax
        mov ax, [si + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        mov [regd2], ax
        mov ax, [regd1]
        mov dx, [regd2]
        call 0x0D5F:VectorToDir8
        mov [passdir], ax
        mov ax, [regd2]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [regd1]
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xFA                           ; insn: adc di, dx
        mov [regd2], si
        mov [g_D6BA], di
        mov bx, [bp + 0x6]
        cmp word [bx + 0x5e], 0x6
        jl short .12
        db 0x2B, 0xFF                           ; insn: sub di, di
        jmp short .13
.12:
        mov di, 0x6
.13:
        shl di, byte 0x7
        add di, 0xb50e
        mov word [regd3], 0x6
.14:
        mov ax, [di + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        mov [regd0], ax
        mov ax, [di + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        mov [regd1], ax
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [regd1]
        mov [bp - 0x8], si
        mov [bp - 0x6], dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x8]
        adc dx, [bp - 0x6]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov ax, [regd2]
        mov dx, [g_D6BA]
        cmp [bp - 0x2], dx
        jg short .18
        jl short .15
        cmp [bp - 0x4], ax
        ja short .18
.15:
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov si, [passdir]
        db 0x2B, 0xF0                           ; insn: sub si, ax
        inc si
        and si, 0x7
        cmp si, 0x1
        jz short .20
        mov bx, [bp + 0x6]
        cmp word [bx + 0x1a], 0x0
        jnz short .18
        cmp si, 0x2
        jg short .16
        cmp word [bp - 0x2], 0x0
        jl short .20
        jg short .16
        cmp word [bp - 0x4], 0xe10
        jc short .20
.16:
        cmp si, 0x3
        jz short .17
        cmp si, 0x7
        jnz short .18
.17:
        cmp word [bp - 0x2], 0x0
        jl short .20
        jg short .18
        cmp word [bp - 0x4], 0x640
        jc short .20
.18:
        add di, 0x80
        dec word [regd3]
        jz short .19
        jmp near .14
.19:
        mov di, [bp + 0x6]
        push di
        push cs
        call dopass
        add sp, 0x2
        cmp word [di + 0x1a], 0x0
        jz short .20
        push di
        call 0x2519:assexit
        add sp, 0x2
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90
.20:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; chk4shot                                                   28BB:129A  94 PC
; Computer shot check: shoots when the shot lane is open.
;
; Takes 1 word of stack arguments. Calls randomd0, ImulRegs, VectorToDir8, CompShoot. Far routine
; (retf).
;-----------------------------------------------------------------------------
chk4shot:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        test byte [gmode2], 0x20
        jz short .1
        mov al, [di + 0x44]
        xor al, [gmode2]
        test al, 0x40
        jz short .1
        cmp word [threat], 0x0
        jz short .1
        mov ax, 0x4
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near .17
.1:
        cmp word [gameclock], 0x4
        jnl short .2
        mov bx, [di + 0x62]
        mov ax, [bx + 0xc]
        mov bx, [di + 0x60]
        cmp [bx + 0xc], ax
        jnl short .2
        jmp near .17
.2:
        mov al, [di + 0x53]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x20
        neg ax
        mov [regd4], ax
        mov al, [di + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfe30
        add ax, 0xe8
        mov [regd1], ax
        mov bx, [pucky]
        mov ax, [bx]
        sub [regd1], ax
        mov bx, [puckx]
        mov ax, [bx]
        neg ax
        mov [regd0], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [regd1]
        mov [bp - 0x4], si
        mov [bp - 0x2], dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x4]
        adc dx, [bp - 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .3
        jmp near .12
.3:
        cmp ax, 0x2710
        jna short .4
        jmp near .12
.4:
        mov bx, [di + 0x62]
        cmp [bx + 0x24], dx
        jnl short .6
.5:
        mov word [regd4], 0x1
        jmp short .13
        db 0x90
.6:
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov [regd5], ax
        cmp word [di + 0x5e], 0x6
        jl short .7
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .8
        db 0x90
.7:
        mov si, 0x6
.8:
        shl si, byte 0x7
        add si, 0xb50e
        mov word [regd3], 0x6
.9:
        cmp word [si + 0x1a], 0x0
        jnz short .10
        test byte [si + 0x45], 0x2
        jz short .11
        jmp short .5
.10:
        mov ax, [si + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        mov [regd0], ax
        mov ax, [si + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        mov [regd1], ax
        mov ax, [regd0]
        mov dx, [regd1]
        call 0x0D5F:VectorToDir8
        cmp ax, [regd5]
        jnz short .11
        shl word [regd4], 1
.11:
        add si, 0x80
        dec word [regd3]
        jnz short .9
        jmp short .13
.12:
        shl word [regd4], byte 0x4
.13:
        mov ax, [regd4]
        call 0x0C11:randomd0
        cmp ax, strict word 0x8
        jng short .15
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.15:
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        test byte [di + 0x44], 0x80
        jnz short .16
        neg word [regd0]
.16:
        cmp word [regd0], 0x0
        jl short .14
        mov ax, 0xe8
        sub ax, [regd0]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .14
        test byte [gmode2], 0x80
        jnz short .14
.17:
        push di
        push cs
        call CompShoot
        add sp, 0x2
        mov ax, 0x1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CompShoot                                                  28BB:141E  94 PC
; Starts a computer shot with a swing time from the distance to the goal.
;
; Takes 1 word of stack arguments. Calls assreplace. Far routine (retf).
;-----------------------------------------------------------------------------
CompShoot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov bx, [pucky]
        mov ax, [bx]
        mov [regd0], ax
        test byte [si + 0x44], 0x80
        jnz short .1
        neg word [regd0]
.1:
        mov ax, 0xe8
        sub ax, [regd0]
        shr ax, byte 0x3
        mov [regd1], ax
        cmp ax, strict word 0x14
        jng short .2
        mov ax, 0x14
.2:
        mov [si + 0x28], ax
        push 0x12
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ChkOffsides                                                28BB:145E  94 PC
; Clears a team's offside flag once none of its skaters is past the blue line.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
ChkOffsides:
        enter 0x8, 0x0
        push di
        push si
        test byte [CrowdState], 0x2
        jnz short .1
        jmp near .27
.1:
        mov di, 0xb362
        mov cx, 0x2
.2:
        test byte [di + 0x2a], 0x10
        jz short .7
        mov bx, [di + 0xd4]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.3:
        cmp word [bx + 0x1a], 0x0
        jl short .5
        mov ax, [bx + 0x6]
        mov [regd0], ax
        test byte [bx + 0x44], 0x80
        jnz short .4
        neg word [regd0]
.4:
        cmp word [regd0], 0x4e
        jg short .6
.5:
        add bx, 0x80
        inc dx
        cmp dx, 0x6
        jl short .3
.6:
        cmp dx, 0x6
        jl short .7
        and byte [di + 0x2a], 0xef
.7:
        mov di, 0xb438
        loop .2
        mov word [regd0], 0x4a
        mov bx, [bp + 0x6]
        cmp word [bx + 0x6], 0x4a
        jl short .18
        cmp word [bx + 0x6a], 0x4a
        jl short .8
        jmp near .27
.8:
        mov word [regd0], 0x54
        test byte [gmode], 0x2
        jnz short .9
        mov di, 0xb362
.9:
        mov si, [di + 0xd4]
        cmp word [lasttouch], 0x6
        jnl short .10
        mov ax, 0x1
        jmp short .11
        db 0x90
.10:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.11:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov [bp - 0x6], ax
        cmp word [bx + 0x5e], 0x6
        jnl short .12
        mov ax, 0x1
        jmp short .13
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.13:
        xor ax, [bp - 0x6]
        jz short .15
.14:
        and byte [di + 0x2a], 0xef
        pop si
        pop di
        leave
        retf
        db 0x90
.15:
        mov dx, 0x6
.16:
        cmp word [si + 0x1a], 0x0
        jl short .17
        mov ax, [regd0]
        cmp [si + 0x6], ax
        jng short .17
        or byte [di + 0x2a], 0x10
.17:
        add si, 0x80
        dec dx
        jnz short .16
        pop si
        pop di
        leave
        retf
.18:
        mov word [regd0], 0xffb6
        mov ax, [regd0]
        cmp [bx + 0x6], ax
        jg short .27
        cmp [bx + 0x6a], ax
        jng short .27
        sub word [regd0], 0xa
        test byte [gmode], 0x2
        jnz short .19
        mov di, 0xb438
        jmp short .20
.19:
        mov di, 0xb362
.20:
        mov si, [di + 0xd4]
        cmp word [lasttouch], 0x6
        jnl short .21
        mov ax, 0x1
        jmp short .22
        db 0x90
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov [bp - 0x8], ax
        cmp word [bx + 0x5e], 0x6
        jnl short .23
        mov ax, 0x1
        jmp short .24
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        xor ax, [bp - 0x8]
        jnz short .14
        mov dx, 0x6
.25:
        cmp word [si + 0x1a], 0x0
        jl short .26
        mov ax, [regd0]
        cmp [si + 0x6], ax
        jnl short .26
        or byte [di + 0x2a], 0x10
.26:
        add si, 0x80
        dec dx
        jnz short .25
.27:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MarkTwoLinePlayers                                         28BB:15A2  94 PC
; Marks the skaters past the red line for the two-line pass check.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
MarkTwoLinePlayers:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [CrowdState], 0x8
        jnz short .1
        jmp near .11
.1:
        test byte [gmode], 0x2
        jz short .2
        mov di, 0xb80e
        mov bx, 0xb50e
        jmp short .3
.2:
        mov di, 0xb50e
        mov bx, 0xb80e
.3:
        mov dx, [bp + 0x6]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp word [si + 0x6], 0x0
        jl short .7
        cmp word [si + 0x6a], 0x0
        jnl short .11
        mov dx, 0x6
.4:
        cmp word [di + 0x1a], 0x0
        jl short .5
        cmp word [di + 0x6], 0x0
        jng short .5
        or byte [di + 0x45], 0x80
        jmp short .6
.5:
        and byte [di + 0x45], 0x7f
.6:
        and byte [bx + 0x45], 0x7f
        add di, 0x80
        add bx, 0x80
        dec dx
        jnz short .4
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        cmp word [si + 0x6a], 0x0
        jl short .11
        mov dx, 0x6
.8:
        cmp word [bx + 0x1a], 0x0
        jl short .9
        cmp word [bx + 0x6], 0x0
        jnl short .9
        or byte [bx + 0x45], 0x80
        jmp short .10
        db 0x90
.9:
        and byte [bx + 0x45], 0x7f
.10:
        and byte [di + 0x45], 0x7f
        add di, 0x80
        add bx, 0x80
        dec dx
        jnz short .8
.11:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ChkShotStat                                                28BB:1638  94 PC
; After a shot, raises the crowd level and counts the shot for the shooter and the goalie.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ChkShotStat:
        enter 0x4, 0x0
        push di
        push si
        test byte [gmode2], 0x10
        jnz short .1
        jmp near .10
.1:
        and byte [gmode2], 0xef
        test byte [gmode], 0x1
        jz short .2
        jmp near .10
.2:
        mov ax, [shotplayer]
        shl ax, byte 0x7
        add ax, 0xb50e
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov bx, [pucky]
        mov [bp - 0x4], ax
        cmp word [bx], 0x0
        jng short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        mov bx, [bp - 0x4]
        mov cl, [bx + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .5
        jmp near .10
.5:
        cmp word [CrowdSound], 0x3e8
        jg short .6
        add word [CrowdSound], 0x64
        cmp word [CrowdSound], 0x3e8
        jng short .6
        mov word [CrowdSound], 0x3e8
.6:
        add word [g_D6C4], 0xa
        test byte [gmode], 0x10
        jnz short .10
        mov ax, [si + 0x60]
        mov [bp - 0x2], ax
        mov di, [si + 0x62]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        inc word [bx]
        test byte [si + 0x44], 0x40
        jnz short .7
        inc byte [gsumtail_shots1]
        jmp short .8
.7:
        inc byte [gsumtail_shots2]
.8:
        cmp byte [si + 0x47], 0x19
        jnl short .9
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x4
        mov bx, [bp - 0x2]
        les bx, [bx + 0xc8]
        inc word [es:bx + si + 0xe]
.9:
        cmp word [di + 0x24], 0x0
        jl short .10
        mov bx, [di + 0x24]
        add bx, [di + 0xbe]
        mov al, [bx + 0x24]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, strict word 0x19
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .10
        cmp si, 0x3
        jnl short .10
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        les si, [di + 0xcc]
        inc word [es:bx + si + 0x2]
.10:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; setInjuryType                                              28BB:171E  94 PC
; Takes an injured player out of play, raises the crowd and locks the camera on him.
;
; Takes 1 word of stack arguments. Calls PlaySoundEffect, randomd0, PostInjuryEvent, RemoveFromLines.
; Far routine (retf).
;-----------------------------------------------------------------------------
setInjuryType:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        or byte [si + 0x45], 0x4
        cmp word [CrowdSound], 0x3e8
        jg short .1
        add word [CrowdSound], 0x12c
        cmp word [CrowdSound], 0x3e8
        jng short .1
        mov word [CrowdSound], 0x3e8
.1:
        add word [g_D6C4], 0x1e
        push word 0xa1
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        mov ax, [si + 0x2]
        mov [xc1], ax
        mov ax, [si + 0x6]
        mov [yc1], ax
        mov ax, [camx]
        cmp [si + 0x2], ax
        jnl short .2
        add word [yc1], 0x32
.2:
        or byte [sflags], 0x40
        mov di, [si + 0x60]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov al, [si + 0x47]
        cbw
        mov cx, [bx + 0xc0]
        mov dx, [bx + 0xc2]
        imul bx, ax, 0x14
        db 0x03, 0xD9                           ; insn: add bx, cx
        mov es, dx
        mov al, [es:bx + 0xf]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x8
        call 0x0C11:randomd0
        cmp ax, strict word 0x6
        jng short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .5
        cmp word [lastimpact], 0x2d
        jng short .5
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov word [bx + di + 0x64], 0xfffc
        mov al, [si + 0x47]
        cbw
        imul bx, ax, 0x28
        add bx, [di + 0xd0]
        mov byte [bx], 0x1
        jmp short .6
        db 0x90
.5:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov word [bx + di + 0x64], 0xfffd
        mov al, [si + 0x47]
        cbw
        imul bx, ax, 0x28
        mov di, [di + 0xd0]
        mov byte [bx + di], 0x6
        mov word [bp - 0x2], 0xffff
.6:
        mov word [injurystop], 0x1
        mov ax, [g_D1AC]
        sub ax, [gameclock]
        mov cx, 0x3c
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push word [bp - 0x2]
        mov al, [si + 0x47]
        cbw
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2352:PostInjuryEvent
        add sp, 0xa
        mov al, [si + 0x47]
        cbw
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x317A:RemoveFromLines
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FallDown                                                   28BB:1848  94 PC
; A player falls after a hit: fall animation, check sound, injury and penalty rolls.
;
; Takes 2 words of stack arguments. Calls SetSPA, newcheck, randomd0, VectorToDir8, SetBoxDoorObject,
; assexit, CanRemovePlayer, setInjuryType and others. Far routine (retf).
;-----------------------------------------------------------------------------
FallDown:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        cmp word [si + 0x5e], 0xb
        jng short .1
        cmp word [si + 0x5e], 0x10
        jz short .1
        jmp near .42
.1:
        test byte [si + 0x45], 0x1
        jz short .2
        jmp near .42
.2:
        mov dx, [si + 0x38]
        cmp dx, 0xa0b
        jnz short .3
        jmp near .42
.3:
        cmp dx, 0x8d3
        jnz short .4
        jmp near .42
.4:
        cmp dx, 0x681
        jnz short .5
        jmp near .42
.5:
        cmp dx, 0x6d9
        jnz short .6
        jmp near .42
.6:
        cmp dx, 0x993
        jnz short .7
        jmp near .42
.7:
        cmp word [si + 0x5e], 0x10
        jnz short .10
        cmp dx, 0xb13
        jnz short .8
        jmp near .42
.8:
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xb13
        call 0x2E42:SetSPA
        cmp word [CrowdSound], 0x3e8
        jg short .9
        add word [CrowdSound], 0x1f4
        cmp word [CrowdSound], 0x3e8
        jng short .9
        mov word [CrowdSound], 0x3e8
.9:
        add word [g_D6C4], 0xf
        push 0x1
        push cs
        call newcheck
        add sp, 0x2
        jmp near .37
        db 0x90
.10:
        cmp byte [si + 0x54], 0xc
        jc short .11
        mov ax, 0x10
        call 0x0C11:randomd0
        add ax, strict word 0x10
        cmp ax, [si + 0x18]
        jng short .11
        mov word [si + 0x40], 0x3c
        mov cx, 0x8d3
        mov di, [bp + 0x6]
        jmp near .16
.11:
        mov di, [bp + 0x6]
        cmp word [di + 0x1a], 0x0
        jz short .12
        mov dx, [di + 0x60]
        test byte [gmode], 0x11
        jnz short .12
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        inc word [bx + 0x10]
.12:
        mov word [si + 0x3e], 0x78
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov dx, [di + 0x6]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [bp - 0x2], ax
        mov al, [bp - 0x2]
        sub al, [si + 0x36]
        inc al
        and ax, strict word 0x7
        mov [bp - 0x2], ax
        cmp ax, strict word 0x2
        jna short .15
        cmp word [di + 0x5e], 0xe
        jnz short .13
        cmp ax, strict word 0x3
        jz short .15
        cmp ax, strict word 0x7
        jz short .15
.13:
        test byte [si + 0x36], 0x3
        jnz short .14
        cmp byte [di + 0x58], 0xa
        jc short .14
        cmp word [di + 0x5e], 0xb
        jg short .14
        mov word [bp - 0x2], 0x993
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x3136:SetBoxDoorObject
        add sp, 0x2
        mov cx, [bp - 0x2]
        jmp short .16
        db 0x90
.14:
        mov cx, 0x681
        jmp short .16
        db 0x90
.15:
        mov cx, 0x6d9
.16:
        or byte [si + 0x44], 0x20
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        mov bx, [si + 0x1c]
        cmp byte [bx + si + 0x1e], 0x12
        jnz short .17
        push si
        call 0x2519:assexit
        add sp, 0x2
.17:
        cmp word [CrowdSound], 0x3e8
        jg short .18
        add word [CrowdSound], 0x1f4
        cmp word [CrowdSound], 0x3e8
        jng short .18
        mov word [CrowdSound], 0x3e8
.18:
        add word [g_D6C4], 0xf
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .19
        jmp near .40
.19:
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .20
        jmp near .40
.20:
        mov byte [bx], 0xff
        test byte [gmode], 0x10
        jz short .21
        jmp near .36
.21:
        mov al, [CrowdState]
        and al, 0x10
        cmp al, 0x10
        jz short .22
        jmp near .36
.22:
        cmp word [si + 0x38], 0x6d9
        jz short .23
        jmp near .36
.23:
        test byte [si + 0x36], 0x3
        jz short .24
        jmp near .36
.24:
        test byte [si + 0x45], 0x10
        jz short .25
        jmp near .36
.25:
        mov al, [si + 0x44]
        and al, 0x8
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xd8
        add ax, 0xc8
        call 0x0C11:randomd0
        cmp ax, [si + 0x18]
        jng short .26
        jmp near .36
.26:
        test byte [gmode], 0x1
        jz short .27
        jmp near .36
.27:
        push si
        call 0x317A:CanRemovePlayer
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .28
        jmp near .36
.28:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xa0b
        call 0x2E42:SetSPA
        push si
        push cs
        call setInjuryType
        add sp, 0x2
        cmp word [di + 0x1a], 0x0
        jnz short .29
        jmp near .35
.29:
        test byte [CrowdState], 0x1
        jnz short .30
        jmp near .35
.30:
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        inc bx
        cmp byte [bx + PBnum], 0x8
        jnl short .35
        push di
        call 0x317A:CanRemovePlayer
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .35
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov dx, [si + 0x6]
        sub dx, [di + 0x6]
        call 0x0D5F:VectorToDir8
        mov [bp - 0x2], ax
        mov al, [bp - 0x2]
        sub al, [di + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .31
        mov al, [si + 0x36]
        sub al, [di + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .31
        push 0x14
        jmp short .32
        db 0x90
.31:
        push 0x9
.32:
        push di
        call 0x327B:AddPenalty2
        add sp, 0x4
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov di, 0xd676
        db 0x8B, 0xF2                           ; insn: mov si, dx
.33:
        cmp byte [di], 0x0
        jnz short .34
        lea ax, [si - 0x1]
        push ax
        call 0x327B:Stop4Pen
        add sp, 0x2
.34:
        inc si
        inc di
        inc di
        cmp di, 0xd6b6
        jc short .33
        jmp short .36
.35:
        push 0xa
        push di
        call 0x327B:AddPenalty2
        add sp, 0x4
.36:
        mov bx, [bp + 0x8]
        test byte [bx + 0x44], 0x40
        jz short .38
.37:
        push 0x7d
        jmp short .39
.38:
        push word 0xa0
.39:
        call 0x0EDC:PlaySoundEffect
        jmp short .41
.40:
        push 0x1
        push cs
        call newcheck
.41:
        add sp, 0x2
.42:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Bcheck                                                     28BB:1B2C  94 PC
; A player in the body check animation hits the other player.
;
; Takes 2 words of stack arguments. Calls randomd0, VectorToDir8, FallDown, checkagr, AddPenalty. Far
; routine (retf).
;-----------------------------------------------------------------------------
Bcheck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .3
        cmp word [si + 0x5e], 0x10
        jz short .3
        cmp word [si + 0x1a], 0x0
        jz short .3
        test byte [si + 0x45], 0x1
        jnz short .3
        mov di, [bp + 0x8]
        test byte [CrowdState], 0x1
        jnz short .1
        test byte [di + 0x44], 0x8
        jz short .1
        mov al, [di + 0x58]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, [si + 0x4b]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add ax, strict word 0x10
        call 0x0C11:randomd0
        cmp ax, strict word 0xc
        jl short .3
.1:
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov dx, [si + 0x6]
        sub dx, [di + 0x6]
        call 0x0D5F:VectorToDir8
        sub al, [di + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jg short .3
        push si
        push di
        push cs
        call FallDown
        add sp, 0x4
        push di
        push cs
        call checkagr
        add sp, 0x2
        cmp ax, strict word 0x4
        jg short .2
        push 0x10
        push di
        call 0x327B:AddPenalty
        add sp, 0x4
.2:
        mov byte [collflag], 0xff
.3:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; holdcheck                                                  28BB:1BBC  94 PC
; One player grabs another when the other faces him and neither is already held.
;
; Takes 2 words of stack arguments. Calls VectorToDir8, SetSPA, checkagr, AddPenalty. Far routine
; (retf).
;-----------------------------------------------------------------------------
holdcheck:
        enter 0x2, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .12
.1:
        cmp word [si + 0x5e], 0x10
        jnz short .2
        jmp near .12
.2:
        cmp word [si + 0x1a], 0x0
        jnz short .3
        jmp near .12
.3:
        test byte [si + 0x45], 0x1
        jz short .4
        jmp near .12
.4:
        mov di, [bp + 0x8]
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov dx, [si + 0x6]
        sub dx, [di + 0x6]
        call 0x0D5F:VectorToDir8
        sub al, [di + 0x36]
        inc al
        and al, 0x7
        cmp al, 0x2
        jng short .5
        jmp near .12
.5:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .6
        and byte [sflags], 0xf7
.6:
        mov ax, [si + 0xc]
        add ax, [di + 0xc]
        sar ax, 1
        mov [bp - 0x2], ax
        mov [si + 0xc], ax
        mov ax, [bp - 0x2]
        mov [di + 0xc], ax
        mov ax, [si + 0xe]
        add ax, [di + 0xe]
        sar ax, 1
        mov [bp - 0x2], ax
        mov [si + 0xe], ax
        mov ax, [bp - 0x2]
        mov [di + 0xe], ax
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x669
        call 0x2E42:SetSPA
        or byte [di + 0x44], 0x20
        cmp word [di + 0x38], 0x639
        jnz short .7
        mov ax, 0x651
        jmp short .8
.7:
        mov ax, 0x88b
.8:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        call 0x2E42:SetSPA
        push di
        push cs
        call checkagr
        add sp, 0x2
        cmp ax, strict word 0x6
        jg short .11
        cmp word [di + 0x38], 0x651
        jnz short .9
        mov ax, 0x12
        jmp short .10
        db 0x90
.9:
        mov ax, 0xf
.10:
        push ax
        push di
        call 0x327B:AddPenalty
        add sp, 0x4
.11:
        mov byte [collflag], 0xff
.12:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; puckbody                                                   28BB:1C9C  94 PC
; The puck hits a player's body.
;
; Takes 2 words of stack arguments. Calls a2touchpuck, GetHot, puckflip, PlaySoundEffect, ImulRegs,
; FallDown, SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
puckbody:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0xa], 0x8
        jg short .1
        mov al, [regd0]
        and ax, strict word 0xf
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .9
.1:
        mov di, [bp + 0x8]
        cmp word [di + 0x5e], 0x10
        jz short .2
        push di
        call 0x2519:a2touchpuck
        add sp, 0x2
.2:
        mov word [si + 0x10], 0x0
        mov word [di + 0x3e], 0x8
        mov ax, [si + 0x2]
        sub ax, [di + 0x2]
        mov [regd0], ax
        mov ax, [si + 0x6]
        sub ax, [di + 0x6]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push di
        call 0x2E42:GetHot
        add sp, 0x2
.3:
        mov ax, [si + 0xc]
        mov [bp - 0x6], ax
        mov ax, [si + 0xe]
        mov [bp - 0x4], ax
        mov al, [regd0]
        mov [si + 0xd], al
        mov al, [regd1]
        mov [si + 0xf], al
        push si
        call 0x2519:puckflip
        add sp, 0x2
        cmp word [si + 0xa], 0x8
        jg short .5
        cmp word [di + 0x38], 0x84b
        jnz short .4
        jmp near .9
.4:
        push word 0xa3
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        pop si
        pop di
        leave
        retf
.5:
        mov si, [bp - 0x6]
        mov word [bp - 0x2], 0xa3
        mov ax, [bp - 0x4]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [bp - 0xa], si
        mov [bp - 0x8], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xa]
        adc dx, [bp - 0x8]
        cmp dx, 0x89
        jl short .7
        jg short .6
        cmp ax, 0x5440
        jna short .7
.6:
        mov bx, [bp + 0x6]
        cmp word [bx + 0xa], 0xc
        jng short .7
        mov word [bp - 0x2], 0xa2
        push di
        push bx
        push cs
        call FallDown
        add sp, 0x4
.7:
        cmp word [di + 0x38], 0x84b
        jz short .8
        push word [bp - 0x2]
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.8:
        test byte [di + 0x44], 0x20
        jnz short .9
        cmp word [di + 0x5e], 0x10
        jz short .9
        or byte [di + 0x44], 0x20
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov ax, 0x84b
        call 0x2E42:SetSPA
.9:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PuckIChk                                                   28BB:1DB8  94 PC
; Icing check: a loose puck past the goal line.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
PuckIChk:
        test byte [iflags], 0x4
        jz short .4
        test byte [iflags], 0x1
        jnz short .4
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .4
        test byte [iflags], 0x2
        jnz short .1
        mov bx, [pucky]
        cmp word [bx], 0xff18
        jl short .2
        retf
        db 0x90
.1:
        mov bx, [pucky]
        cmp word [bx], 0xe8
        jl short .4
.2:
        mov bx, [puckx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x2c
        jg short .3
        and byte [iflags], 0xfb
        retf
.3:
        or byte [iflags], 0x1
.4:
        retf

;-----------------------------------------------------------------------------
; puckshadow                                                 28BB:1E08  94 PC
; Puck shadow assignment.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
puckshadow:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov bx, [bp + 0x6]
        cmp word [bx + 0x12], 0x189
        jnz short .2
        mov si, [puckx]
        mov ax, [si]
        mov [bx + 0x2], ax
        mov si, [pucky]
        mov ax, [si]
        mov [bx + 0x6], ax
        mov word [bx + 0xa], 0x0
        test byte [sflags], 0x80
        jz short .1
        inc word [bx + 0x2]
        pop si
        leave
        retf
.1:
        inc word [bx + 0x6]
        pop si
        leave
        retf
.2:
        cmp word [bx + 0x12], -0x1
        jz short .3
        cmp word [bx + 0x38], 0x7fd
        jnz short .3
        mov word [bx + 0x2], 0x0
        mov word [bx + 0x6], 0x122
        mov word [bx + 0xa], 0xe
        mov si, [pucky]
        cmp word [si], 0x0
        jnl short .3
        mov word [bx + 0x48], 0x8000
        mov word [bx + 0x6], 0xfef6
        dec word [bx + 0xa]
.3:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; puckglue                                                   28BB:1E76  94 PC
; A player takes the puck; a live penalty shot ends when the shooter's team takes it.
;
; Takes 1 word of stack arguments. Calls PlaySoundEffect, PassCompleted, ChkShotStat, GiveControl. Far
; routine (retf).
;-----------------------------------------------------------------------------
puckglue:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        mov ax, [si + 0x5e]
        mov [regd0], ax
        mov al, [regd0]
        mov bx, [puckc]
        mov [bx], al
        mov dx, [si + 0x60]
        mov di, [si + 0x62]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov byte [bx + 0x1f], 0xff
        mov byte [di + 0x21], 0xff
        or byte [di + 0x2a], 0x8
        test byte [sflags3], 0x10
        jz short .3
        and byte [sflags3], 0xef
        test byte [gmode], 0x10
        jnz short .1
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        inc word [bx + 0xe]
.1:
        cmp word [CrowdSound], 0x3e8
        jg short .2
        add word [CrowdSound], 0xc8
        cmp word [CrowdSound], 0x3e8
        jng short .2
        mov word [CrowdSound], 0x3e8
.2:
        test byte [si + 0x44], 0x40
        jnz short .4
        add word [g_D6C4], 0xa
        jmp short .4
.3:
        push word 0x9b
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.4:
        push si
        call 0x2C24:PassCompleted
        add sp, 0x2
        and byte [sflags], 0xf3
        cmp word [si + 0x1a], 0x0
        jnz short .6
        push cs
        call ChkShotStat
        cmp word [si + 0x38], 0x181
        jnz short .5
        mov word [si + 0x2e], 0x5
        jmp short .6
        db 0x90
.5:
        mov word [si + 0x2e], 0x8c
.6:
        push word [regd0]
        call 0x2E42:GiveControl
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; puckgoalie                                                 28BB:1F2A  94 PC
; The puck hits a goalie: picks the save side and the save or rebound.
;
; Takes 2 words of stack arguments. Calls VectorToDir8, randomd0, MulRegs, ChkShotStat, a2touchpuck,
; PlaySoundEffect, puckglue, GetHot and others. Far routine (retf).
;-----------------------------------------------------------------------------
puckgoalie:
        enter 0x4, 0x0
        push di
        push si
        test byte [gmode], 0x10
        jz short .1
        jmp near .19
.1:
        mov di, [bp + 0x6]
        mov word [regd2], 0x0
        cmp word [di + 0xa], 0x8
        jg short .2
        mov word [regd2], 0x2
.2:
        mov si, [bp + 0x8]
        mov ax, [regd0]
        neg ax
        mov dx, [regd1]
        neg dx
        call 0x0D5F:VectorToDir8
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd0], ax
        test byte [regd0], 0x3
        jnz short .3
        mov ax, 0x100
        call 0x0C11:randomd0
        mov [regd0], ax
.3:
        sar ax, byte 0x2
        not ax
        and ax, strict word 0x1
        add [regd2], ax
        test byte [regd2], 0x1
        jz short .4
        mov al, [si + 0x55]
        jmp short .5
        db 0x90
.4:
        mov al, [si + 0x53]
.5:
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0xf
        mov [bp - 0x4], ax
        shl word [regd2], 1
        test byte [si + 0x49], 0x8
        jz short .6
        xor byte [regd2], 0x2
.6:
        mov cl, [regd2]
        mov bx, [si + 0x12]
        mov al, [bx + g_58A6]
        shr al, cl
        db 0x8A, 0xD0                           ; insn: mov dl, al
        and dx, 0x3
        mov ax, [bp - 0x4]
        call 0x03A3:MulRegs
        mov [regd0], ax
        mov [g_D66E], dx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        jmp near .19
.7:
        call 0x0C11:randomd0
        cmp ax, strict word 0x8
        jnl short .8
        jmp near .19
.8:
        push cs
        call ChkShotStat
        push si
        call 0x2519:a2touchpuck
        add sp, 0x2
        test byte [gmode], 0x1
        jnz short .11
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xfa0
        jng short .11
        test byte [si + 0x44], 0x40
        jnz short .9
        push 0x7d
        jmp short .10
        db 0x90
.9:
        push word 0xa1
.10:
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.11:
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, 0xbb8
        jng short .12
        push word 0x9d
        jmp short .13
.12:
        push word 0xa3
.13:
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .15
        cmp word [si + 0x38], 0x181
        jnz short .14
        jmp near .16
.14:
        mov al, [si + 0x4f]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8A, 0xE0                           ; insn: mov ah, al
        add ah, 0x2
        shl ah, 1
        db 0x2A, 0xC0                           ; insn: sub al, al
        call 0x0C11:randomd0
        add ah, 0xc
        mov [regd0], ax
        mov bx, [puckvx]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, [regd0]
        jg short .16
        mov bx, [puckvy]
        mov ax, [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, [regd0]
        jg short .16
        test byte [si + 0x45], 0x4
        jnz short .16
        mov word [di + 0x10], 0x0
        push si
        push cs
        call puckglue
        jmp short .18
.15:
        mov al, [bx]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, byte 0x7
        add dx, 0xb50e
        mov byte [bx], 0xff
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov word [bx + 0x3e], 0x14
        mov ax, [bx + 0x5e]
        mov [lastplayer], ax
        and byte [sflags], 0xf3
.16:
        mov word [di + 0x10], 0x0
        mov word [si + 0x3e], 0xa
        mov word [si + 0x2c], 0x4
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov [regd0], ax
        mov ax, [di + 0x6]
        sub ax, [si + 0x6]
        mov [regd1], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .17
        push si
        call 0x2E42:GetHot
        add sp, 0x2
.17:
        mov al, [regd0]
        mov [di + 0xd], al
        mov al, [regd1]
        mov [di + 0xf], al
        push di
        call 0x2519:puckflip
.18:
        add sp, 0x2
.19:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; puckstick                                                  28BB:211A  94 PC
; The puck touches a player's stick: goalie save flag, shot statistics, then the player may take the
; puck.
;
; Takes 2 words of stack arguments. Calls ChkShotStat, ImulRegs, randomd0, MulRegs, PlaySoundEffect,
; a2touchpuck, deflect, puckglue. Far routine (retf).
;-----------------------------------------------------------------------------
puckstick:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        cmp word [si + 0x1a], 0x0
        jnz short .2
        test byte [gmode], 0x10
        jz short .1
        jmp near .20
.1:
        push cs
        call ChkShotStat
.2:
        and byte [si + 0x44], 0xfe
        mov bx, [puckc]
        mov al, [bx]
        db 0x0A, 0xC0                           ; insn: or al, al
        jnl short .3
        jmp near .11
.3:
        cbw
        shl ax, byte 0x7
        add ax, 0xb50e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov al, [bx + 0x44]
        xor al, [si + 0x44]
        test al, 0x40
        jnz short .4
        jmp near .20
.4:
        cmp word [g_D66E], 0x0
        jz short .5
        jmp near .20
.5:
        cmp word [regd0], 0x24
        jna short .6
        jmp near .20
.6:
        cmp word [si + 0x1a], 0x0
        jnz short .7
        jmp near .10
.7:
        cmp word [di + 0x1a], 0x0
        jnz short .8
        jmp near .20
.8:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [si + 0x60]
        mov ax, [bx + 0x2c]
        mov dl, [si + 0x54]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        call 0x03A3:ImulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [di + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [di + 0x60]
        mov ax, [bx + 0x2c]
        mov dl, [di + 0x54]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        mov [bp - 0x4], cx
        call 0x03A3:ImulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sub ax, [bp - 0x4]
        add ax, strict word 0x20
        mov [regd0], ax
        test byte [di + 0x44], 0x8
        jz short .9
        test byte [si + 0x44], 0x8
        jnz short .9
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x3
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        add [regd0], ax
.9:
        mov ax, [regd0]
        call 0x0C11:randomd0
        cmp ax, strict word 0x2
        jng short .10
        jmp near .20
.10:
        mov dl, [di + 0x54]
        mov al, [di + 0x47]
        cbw
        db 0x8B, 0xCF                           ; insn: mov cx, di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov bx, [bx + 0x60]
        mov ax, [bx + di + 0x2c]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x03A3:ImulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add ax, strict word 0x14
        mov [di + 0x3e], ax
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xCF                           ; insn: mov cx, di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        mov dl, [si + 0x54]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x03A3:ImulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add ax, strict word 0x14
        mov [si + 0x3e], ax
        mov ax, [di + 0x5e]
        mov [lastplayer], ax
        and byte [sflags], 0xf3
        jmp near .17
.11:
        cmp word [si + 0x1a], 0x0
        jnz short .13
        cmp word [g_D66E], 0x0
        jz short .12
        jmp near .20
.12:
        cmp word [regd0], 0x40
        jna short .13
        jmp near .20
.13:
        mov bx, [puckvx]
        mov ax, [bx]
        mov [regd0], ax
        mov bx, [puckvy]
        mov ax, [bx]
        mov [regd1], ax
        mov ax, [regd0]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd1]
        mov [bp - 0x8], di
        mov [bp - 0x6], dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        add ax, [bp - 0x8]
        adc dx, [bp - 0x6]
        mov [regd0], ax
        mov [g_D66E], dx
        mov word [regd1], 0x0
        test byte [gmode2], 0x10
        jnz short .14
        mov al, [si + 0x54]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul ax, ax, word 0x2bc
        mov [regd1], ax
.14:
        add word [regd1], 0x32c8
        mov ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:MulRegs
        mov [regd1], ax
        mov [g_D674], dx
        mov ax, [regd0]
        mov dx, [g_D66E]
        cmp [g_D674], dx
        ja short .18
        jc short .15
        cmp [regd1], ax
        jnc short .18
.15:
        mov ax, [passplayer]
        cmp [si + 0x5e], ax
        jnz short .16
        mov ax, 0x2
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
.16:
        mov word [si + 0x3e], 0x8
.17:
        push word 0x99
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        push si
        call 0x2519:a2touchpuck
        add sp, 0x2
        push word [bp + 0x6]
        push cs
        call deflect
        jmp short .19
.18:
        push si
        push cs
        call puckglue
.19:
        add sp, 0x2
.20:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetShotMode                                                28BB:2388  94 PC
; A player winds up a shot toward the attacked goal: slap or wrist shot animation.
;
; Takes 1 word of stack arguments. Calls VectorToDir8, Findhittype, SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
SetShotMode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov ax, 0x8
        mov [passdir], ax
        or [sflags], ax
        mov word [regd0], 0x0
        mov al, [si + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfe20
        add ax, 0xf0
        mov [regd1], ax
        mov ax, [si + 0x2]
        neg ax
        mov dx, [regd1]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [regd0], ax
        mov word [passspeed], 0xf
        push ax
        push si
        push cs
        call Findhittype
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x491
        jmp short .2
        db 0x90
.1:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x3f9
.2:
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ShotMode                                                   28BB:23EE  94 PC
; Shot wind-up: shoots at the release frame, or ends the wind-up early when the button is let go.
;
; Takes 1 word of stack arguments. Calls doshot. Far routine (retf).
;-----------------------------------------------------------------------------
ShotMode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0x3a], 0xe
        jl short .1
        push si
        push cs
        call doshot
        add sp, 0x2
        pop si
        leave
        retf
.1:
        test byte [regd0], 0x8
        jnz short .2
        and word [regd0], 0x7
        mov ax, [regd0]
        mov [passdir], ax
.2:
        cmp word [si + 0x3a], 0x8
        jnl short .5
        inc word [passspeed]
        cmp byte [si + 0x4f], 0xa
        jnc short .3
        cmp word [si + 0x3a], 0x4
        jg short .4
.3:
        test byte [regd2], 0x20
        jz short .5
.4:
        mov ax, 0xe
        sub ax, [si + 0x3a]
        mov [si + 0x3a], ax
.5:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Findhittype                                                28BB:2442  94 PC
; Returns 1 for a backhand when the shot direction is on the player's backhand side, else 0.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
Findhittype:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov al, [bx + 0x36]
        db 0x2A, 0xC2                           ; insn: sub al, dl
        and ax, strict word 0x7
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        test byte [bx + 0x49], 0x8
        jz short .1
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov ax, 0x1
        shl ax, cl
        and ax, 0xf0
        jmp short .2
        db 0x90
.1:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x1
        shl ax, cl
        and ax, strict word 0x1e
.2:
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        leave
        retf

;-----------------------------------------------------------------------------
; deflect                                                    28BB:247A  94 PC
; Deflects the puck with a random velocity, then flips it.
;
; Takes 1 word of stack arguments. Calls randomd0, puckflip. Far routine (retf).
;-----------------------------------------------------------------------------
deflect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov ax, 0x2000
        call 0x0C11:randomd0
        sub ax, 0x1000
        mov [si + 0xe], ax
        mov ax, 0x2000
        call 0x0C11:randomd0
        sub ax, 0x1000
        mov [si + 0xc], ax
        mov ax, 0x1000
        call 0x0C11:randomd0
        mov [si + 0x10], ax
        mov [regd0], ax
        push si
        call 0x2519:puckflip
        add sp, 0x2
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; shotdiradj                                                 28BB:24BE  94 PC
; Picks where a computer player or a one-timer shoots, from the goalie's side.
;
; Takes 1 word of stack arguments. Calls FoldScale, __aFlmul. Far routine (retf).
;-----------------------------------------------------------------------------
shotdiradj:
        enter 0x1a, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x8
        jz short .1
        jmp near .13
.1:
        cmp word [bx + 0x5e], 0x6
        jl short .2
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .3
.2:
        mov si, 0x6
.3:
        shl si, byte 0x7
        add si, 0xb50e
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.4:
        cmp word [si + 0x1a], 0x0
        jz short .5
        add si, 0x80
        inc dx
        cmp dx, 0x6
        jl short .4
.5:
        cmp dx, 0x6
        jnz short .6
        mov word [passdir], 0x8
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        mov al, [si + 0xd]
        cbw
        sar ax, 1
        add ax, [si + 0x2]
        mov bx, [puckx]
        sub ax, [bx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        cwd
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov al, [si + 0xf]
        cbw
        sar ax, 1
        add ax, [si + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        push bx
        push cx
        call 0x03A3:FoldScale
        add sp, 0x4
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        inc word [bp - 0x2]
.7:
        mov word [bp - 0xc], 0x12
        mov di, 0xe8
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x80
        jnz short .8
        mov di, 0xff18
.8:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov bx, [pucky]
        sub ax, [bx]
        cwd
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        push word [bp - 0x8]
        push word [bp - 0xa]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x12
        mov bx, [puckx]
        sub ax, [bx]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        push dx
        push ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0x12], di
        mov [bp - 0x10], bx
        call 0x0000:__aFlmul
        push word [bp - 0x4]
        push word [bp - 0x6]
        push word [bp - 0x10]
        push word [bp - 0x12]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x16], di
        mov [bp - 0x14], dx
        call 0x0000:__aFlmul
        sub ax, [bp - 0x16]
        sbb dx, [bp - 0x14]
        mov bx, [bp - 0x2]
        call 0x03A3:IdivWords.regs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word [bp - 0x8]
        push word [bp - 0xa]
        mov ax, 0xffee
        mov bx, [puckx]
        sub ax, [bx]
        cwd
        push dx
        push ax
        call 0x0000:__aFlmul
        push word [bp - 0x4]
        push word [bp - 0x6]
        push word [bp - 0xc]
        push word [bp - 0xe]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1a], di
        mov [bp - 0x18], dx
        call 0x0000:__aFlmul
        sub ax, [bp - 0x1a]
        sbb dx, [bp - 0x18]
        mov bx, [bp - 0x2]
        call 0x03A3:IdivWords.regs
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x2c
        jng short .9
        mov word [passdir], 0x0
        pop si
        pop di
        leave
        retf
        db 0x90
.9:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x80
        jz short .10
        neg si
.10:
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .11
        mov ax, 0x2
        jmp short .12
.11:
        mov ax, 0x6
.12:
        mov [passdir], ax
.13:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; doshot                                                     28BB:2630  94 PC
; The stick is at the puck: launches it toward the goal with the shot speed and sound.
;
; Takes 1 word of stack arguments. Calls shotdiradj, ImulRegs, MulRegs, FoldScale, randomd0,
; PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
doshot:
        enter 0xe, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        push si
        push cs
        call shotdiradj
        add sp, 0x2
        mov ax, [si + 0x5e]
        mov [shotplayer], ax
        and byte [sflags], 0xf7
        or byte [si + 0x44], 0x20
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jz short .1
        cmp word [si + 0x38], 0xdd3
        jz short .1
        cmp word [si + 0x38], 0xe2b
        jz short .1
        push word 0x99
        jmp near .27
.1:
        or byte [gmode2], 0x10
        cmp word [si + 0x38], 0x491
        jz short .2
        cmp word [si + 0x38], 0xe2b
        jz short .2
        mov word [bp - 0x8], 0xaa
        jmp short .3
.2:
        mov word [bp - 0x8], 0xaa
        mov ax, [passspeed]
        sar ax, byte 0x2
        sub [passspeed], ax
.3:
        mov al, [si + 0x4f]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0xc
        jng short .4
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x03, 0xC8                           ; insn: add cx, ax
        cmp cx, 0x1f4
        jnl short .4
        inc di
        inc di
.4:
        cmp di, 0xe
        jng short .5
        inc di
.5:
        cmp di, 0xd
        jng short .6
        inc di
.6:
        cmp di, 0xa
        jng short .7
        inc di
.7:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        call 0x03A3:ImulRegs
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add ax, strict word 0x14
        imul word [passspeed]
        mov [passspeed], ax
        mov dx, 0x5249
        call 0x03A3:MulRegs
        mov [passspeed], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        sar ax, byte 0x4
        sub ax, strict word 0x3
        neg ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .8
        mov word [bp - 0x8], 0x9a
.8:
        mov bx, [puckc]
        mov byte [bx], 0xff
        mov word [si + 0x3e], 0x10
        mov ax, [si + 0x5e]
        mov [lastplayer], ax
        mov di, 0xe8
        test byte [si + 0x44], 0x80
        jnz short .9
        mov di, 0xff18
.9:
        mov bx, [passdir]
        shl bx, byte 0x2
        mov ax, [bx + g_5AD0]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov bx, [puckx]
        sub ax, [bx]
        mov [bp - 0xe], ax
        mov bx, [pucky]
        sub di, [bx]
        mov [bp - 0xc], di
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov cx, [bx + shotsetz]
        mov [bp - 0x6], cx
        push di
        push ax
        call 0x03A3:FoldScale
        add sp, 0x4
        mov [bp - 0x4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
        inc word [bp - 0x4]
.10:
        test byte [gmode], 0x10
        jz short .11
        jmp near .23
.11:
        mov al, [si + 0x50]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0xe
        jng short .12
        inc di
.12:
        cmp di, 0xd
        jng short .13
        inc di
.13:
        cmp word [bp - 0x4], 0xc8
        jg short .14
        mov al, [si + 0x50]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x10
        call 0x0C11:randomd0
        cmp ax, strict word 0xe
        jng short .14
        jmp near .23
.14:
        mov ax, [passspeed]
        sar ax, byte 0x4
        db 0x2B, 0xC7                           ; insn: sub ax, di
        add ax, strict word 0x10
        imul word [bp - 0x4]
        shr ax, byte 0x6
        mov [bp - 0xa], ax
        cmp word [bp - 0x4], 0xfa
        jnl short .15
        sar word [bp - 0xa], 1
.15:
        cmp word [bp - 0xa], 0xa0
        jng short .18
        mov si, 0xa0
.16:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, 1
        call 0x0C11:randomd0
        db 0x2B, 0xC6                           ; insn: sub ax, si
        add [bp - 0xe], ax
        cmp si, 0x3c
        jng short .17
        mov si, 0x3c
.17:
        cmp word [bp - 0xc], 0x0
        jl short .19
        mov [bp - 0x2], si
        jmp short .20
        db 0x90
.18:
        mov si, [bp - 0xa]
        jmp short .16
        db 0x90
.19:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sar ax, 1
        mov [bp - 0x2], ax
.20:
        mov ax, [bp - 0x2]
        shl ax, 1
        call 0x0C11:randomd0
        sub ax, [bp - 0x2]
        add [bp - 0xc], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sar ax, 1
        cmp word [bp - 0x4], 0xa0
        jnl short .21
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x3
        cwd
        idiv cx
.21:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp word [bp - 0x4], 0x50
        jnl short .22
        db 0x8B, 0xFE                           ; insn: mov di, si
        sar di, byte 0x2
.22:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        call 0x0C11:randomd0
        add [bp - 0x6], ax
.23:
        imul ax, [passspeed], 0x3b
        mov dx, [bp - 0xe]
        call 0x03A3:ImulRegs
        mov bx, [bp - 0x4]
        call 0x03A3:IdivWords.regs
        mov bx, [puckvx]
        mov [bx], ax
        imul ax, [passspeed], 0x3b
        mov dx, [bp - 0xc]
        call 0x03A3:ImulRegs
        mov bx, [bp - 0x4]
        call 0x03A3:IdivWords.regs
        mov bx, [puckvy]
        mov [bx], ax
        cmp word [bp - 0x6], 0x0
        jz short .26
        mov ax, [bp - 0x6]
        mov dx, 0x44
        call 0x03A3:MulRegs
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [passspeed]
        call 0x03A3:MulRegs
        mov bx, [bp - 0x4]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x03A3:DivWords.regs
        mov [bp - 0x6], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, 0xb33
        call 0x03A3:MulRegs
        mov bx, [passspeed]
        call 0x03A3:DivWords.regs
        add [bp - 0x6], ax
        cmp word [bp - 0x6], 0x1800
        ja short .24
        mov dx, [bp - 0x6]
        jmp short .25
        db 0x90
.24:
        mov dx, 0x1800
.25:
        mov bx, [puckvz]
        mov [bx], dx
.26:
        push word [bp - 0x8]
.27:
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; newcheck                                                   28BB:28E8  94 PC
; Plays a random check sound.
;
; Takes 1 word of stack arguments. Calls randomd0, PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
newcheck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [bp + 0x6], 0x0
        jz short .1
        cmp word [lastimpact], 0x20
        jng short .1
        mov ax, 0x2
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov cx, 0x93
        jmp short .2
        db 0x90
.1:
        cmp word [ltack], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        mov [ltack], ax
        cmp ax, strict word 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x2
        add cx, 0xb0
.2:
        push cx
        call 0x0EDC:PlaySoundEffect
        leave
        retf

;-----------------------------------------------------------------------------
; checkcoll                                                  28BB:292A  94 PC
; Wall collision at the hot spot and stick end, then collisions with other players.
;
; Takes 3 words of stack arguments. Calls checkwallcoll, GetHot, checkplcoll. Far routine (retf).
;-----------------------------------------------------------------------------
checkcoll:
        enter 0x4, 0x0
        push di
        push si
        mov byte [collflag], 0x0
        mov si, [bp + 0x8]
        test byte [sflags], 0x80
        jz short .1
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov si, [bp + 0xa]
        mov [bp + 0xa], dx
.1:
        mov di, [bp + 0x6]
        test byte [di + 0x44], 0x4
        jnz short .3
        mov ax, [di + 0x5a]
        mov [wcradiusx], ax
        mov ax, [di + 0x5c]
        mov [wcradiusy], ax
        push word [di + 0x6]
        push word [di + 0x2]
        push di
        push cs
        call checkwallcoll
        add sp, 0x6
        mov ax, [di + 0x30]
        or ax, [di + 0x32]
        jnz short .2
        cmp word [di + 0x5e], 0xb
        jg short .2
        push di
        call 0x2E42:GetHot
        add sp, 0x2
        mov ax, 0x1
        mov [wcradiusx], ax
        mov [wcradiusy], ax
        mov ax, [di + 0x6]
        add ax, [regd1]
        push ax
        mov ax, [di + 0x2]
        add ax, [regd0]
        push ax
        push di
        push cs
        call checkwallcoll
        add sp, 0x6
.2:
        push word [bp + 0xa]
        push si
        push di
        push cs
        call checkplcoll
        add sp, 0x6
.3:
        cmp byte [collflag], 0x0
        jz short .4
        mov ax, [di + 0x66]
        mov [di + 0x2], ax
        mov ax, [di + 0x6a]
        mov [di + 0x6], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.4:
        mov dx, [di + 0x5e]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        mov si, [bx + g_D496]
        cmp si, 0x10
        jz short .6
.5:
        mov al, [si + g_D4F5]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov ax, [bp + 0xa]
        cmp [bx + g_D474], ax
        jnl short .6
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        inc word [bx + g_D496]
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl di, 1
        dec word [di + g_D496]
        mov [si + g_D4F4], al
        mov [si + g_D4F5], dl
        inc si
        cmp si, 0x10
        jnz short .5
.6:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        mov [bp - 0x4], bx
        mov si, [bx + g_D496]
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .8
.7:
        mov al, [si + g_D4F3]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov ax, [bp + 0xa]
        cmp [bx + g_D474], ax
        jng short .8
        mov bx, [bp - 0x4]
        dec word [bx + g_D496]
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl di, 1
        inc word [di + g_D496]
        mov [si + g_D4F4], al
        mov [si + g_D4F3], dl
        dec si
        jnz short .7
.8:
        mov ax, [bp + 0xa]
        mov bx, [bp - 0x4]
        mov [bx + g_D474], ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; checkwallcoll                                              28BB:2A54  94 PC
; Wall and corner collision of an object, then the goal check.
;
; Takes 3 words of stack arguments. Calls checkgoal, FoldScale, wallcollb. Far routine (retf).
;-----------------------------------------------------------------------------
checkwallcoll:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0xa]
        mov ax, 0x108
        sub ax, [wcradiusy]
        mov [bp - 0x2], ax
        mov cx, 0xa0
        sub cx, [wcradiusx]
        mov [bp - 0x6], cx
        sub cx, 0x40
        neg cx
        mov [regd4], cx
        sub ax, strict word 0x40
        neg ax
        mov [regd5], ax
        mov [bp - 0x4], ax
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jnl short .1
        mov di, [bp + 0x8]
        neg ax
        mov [regd5], ax
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jng short .1
        jmp near .5
.1:
        mov di, [bp + 0x8]
        db 0x3B, 0xCF                           ; insn: cmp cx, di
        jg short .4
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        neg ax
        mov [regd4], ax
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .4
        push si
        push di
        mov ax, [regd5]
        cmp [bp - 0x4], ax
        jnz short .2
        mov ax, 0xd
        jmp short .3
        db 0x90
.2:
        mov ax, 0xc
.3:
        shl ax, byte 0x7
        add ax, 0xb50e
        push ax
        push word [bp + 0x6]
        push cs
        call checkgoal
        add sp, 0x8
        jmp short .5
.4:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        sub ax, [regd5]
        mov [regd0], ax
        db 0x8B, 0xCF                           ; insn: mov cx, di
        sub cx, [regd4]
        mov [regd1], cx
        push cx
        push ax
        call 0x03A3:FoldScale
        add sp, 0x4
        mov [regd3], ax
        neg word [regd1]
        cmp ax, strict word 0x40
        jl short .5
        mov ax, [regd0]
        cwd
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov bx, [regd3]
        call 0x03A3:IdivWords.regs
        mov [regd0], ax
        mov ax, [regd1]
        cwd
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov bx, [regd3]
        call 0x03A3:IdivWords.regs
        mov [regd1], ax
        push word [bp + 0x6]
        push cs
        call wallcollb
        add sp, 0x2
.5:
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x30]
        or ax, [bx + 0x32]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        mov word [regd0], 0x100
        mov [regd1], ax
        cmp [bp - 0x2], si
        jng short .6
        mov word [regd0], 0xff00
        mov dx, [bp - 0x2]
        neg dx
        db 0x3B, 0xD6                           ; insn: cmp dx, si
        jnl short .6
        mov bx, [regd0]
        mov [regd0], ax
        mov [regd1], bx
        mov dx, [bp - 0x6]
        db 0x3B, 0xD7                           ; insn: cmp dx, di
        jng short .6
        neg word [regd1]
        neg dx
        db 0x3B, 0xD7                           ; insn: cmp dx, di
        jl short .7
.6:
        push word [bp + 0x6]
        push cs
        call wallcollb
        add sp, 0x2
.7:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; checkgoal                                                  28BB:2B8A  94 PC
; Collision with a goal net: the player check for players, Goal for the puck.
;
; Takes 4 words of stack arguments. Calls checkgoalp, ImulRegs, __aFldiv, Goal, PlaySoundEffect,
; randomd0, puckflip, wallcoll. Far routine (retf).
;-----------------------------------------------------------------------------
checkgoal:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0xa], 0xd
        jng short .1
        jmp near .27
.1:
        cmp word [si + 0x5e], 0xe
        jz short .2
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push si
        push cs
        call checkgoalp
        add sp, 0x8
        pop si
        pop di
        leave
        retf
.2:
        mov dx, [bp + 0xa]
        mov cx, [bp + 0x8]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        sub dx, [bx + 0x2]
        mov ax, [wcradiusx]
        add ax, strict word 0x10
        mov [regd4], ax
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jnl short .3
        jmp near .27
.3:
        neg ax
        mov [regd4], ax
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jng short .4
        jmp near .27
.4:
        mov bx, [bp + 0xc]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        sub bx, [di + 0x6]
        mov ax, [wcradiusy]
        inc ax
        inc ax
        mov [regd5], ax
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jnl short .5
        jmp near .27
.5:
        neg ax
        mov [regd5], ax
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jng short .6
        jmp near .27
.6:
        mov [bp + 0xc], bx
        cmp word [si + 0x6e], 0xd
        jl short .8
        mov ax, [si + 0x6e]
        mov [si + 0xa], ax
        cmp word [si + 0x10], 0x0
        jl short .7
        jmp near .27
.7:
        neg word [si + 0x10]
        sar word [si + 0x10], 1
        pop si
        pop di
        leave
        retf
.8:
        mov [bp + 0xa], dx
        db 0x8B, 0xFA                           ; insn: mov di, dx
        mov byte [collflag], 0xff
        and byte [si + 0x44], 0x7f
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jl short .10
        mov al, [bx]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, byte 0x7
        add dx, 0xb50e
        mov byte [bx], 0xff
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov word [bx + 0x3e], 0x8
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov bx, [pucky]
        mov cx, [bx]
        mov [regd1], cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        test byte [bx + 0x44], 0x80
        jnz short .9
        neg word [regd1]
.9:
        cmp word [regd1], 0x0
        jnl short .10
        or byte [si + 0x44], 0x80
.10:
        mov word [regd0], 0xff00
        mov ax, [si + 0x4]
        mov dx, [si + 0x6]
        sub ax, [si + 0x68]
        sbb dx, [si + 0x6a]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [regd1], ax
        mov [g_D674], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .11
        jmp near .24
.11:
        cmp word [g_D674], 0x0
        jl short .13
        jg short .12
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
.12:
        mov word [regd0], 0x100
        neg word [regd5]
.13:
        mov ax, [bp + 0xc]
        add [regd5], ax
        mov ax, [si]
        mov dx, [si + 0x2]
        sub ax, [si + 0x64]
        sbb dx, [si + 0x66]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [regd3], ax
        mov [g_D6C2], dx
        mov ax, [regd1]
        cwd
        push dx
        push ax
        mov ax, [regd5]
        mov dx, [regd3]
        call 0x03A3:ImulRegs
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [regd5], ax
        mov [g_D002], dx
        cmp dx, 0x1
        jna short .14
        jmp near .24
.14:
        jc short .15
        jmp near .24
.15:
        db 0x2B, 0xF8                           ; insn: sub di, ax
        cmp di, [regd4]
        jnl short .16
        jmp near .24
.16:
        mov ax, [regd4]
        neg ax
        mov [regd4], ax
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jnl short .17
        jmp near .24
.17:
        mov word [regd1], 0x0
        mov ax, [si + 0x6]
        xor ax, [regd0]
        mov [regd3], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .18
        jmp near .25
.18:
        neg word [regd0]
        test byte [si + 0x44], 0x80
        jz short .19
        jmp near .25
.19:
        mov [bp + 0xa], di
        db 0x8B, 0xD7                           ; insn: mov dx, di
        cmp word [si + 0xa], 0xd
        jz short .20
        dec word [regd4]
        cmp [regd4], dx
        jl short .20
        mov ax, [regd4]
        neg ax
        mov [regd4], ax
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jg short .20
        push word [bp + 0x8]
        call 0x2E42:Goal
        jmp near .26
        db 0x90
.20:
        and byte [gmode2], 0xef
        test byte [gmode], 0x1
        jnz short .22
        cmp word [CrowdSound], 0x4b0
        jg short .21
        add word [CrowdSound], 0x1f4
        cmp word [CrowdSound], 0x4b0
        jng short .21
        mov word [CrowdSound], 0x4b0
.21:
        add word [g_D6C4], 0x28
.22:
        push word 0xac
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        mov ax, 0x1000
        call 0x0C11:randomd0
        mov [regd0], ax
        cmp word [si + 0x6], 0x0
        jl short .23
        neg word [regd0]
.23:
        mov ax, [regd0]
        mov [si + 0xe], ax
        mov ax, 0x2000
        call 0x0C11:randomd0
        sub ax, 0x1000
        mov [si + 0xc], ax
        mov ax, 0x2000
        call 0x0C11:randomd0
        sub ax, 0x1000
        mov [si + 0x10], ax
        push si
        call 0x2519:puckflip
        jmp short .26
        db 0x90
.24:
        mov word [regd0], 0x0
        mov word [regd1], 0x100
        mov ax, [si + 0x2]
        sub ax, [si + 0x66]
        js short .25
        mov word [regd1], 0xff00
.25:
        mov word [nethit], 0x1
        push si
        push cs
        call wallcoll
.26:
        add sp, 0x2
.27:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; wallcoll                                                   28BB:2E12  94 PC
; Bounces an object off a wall.
;
; Takes 1 word of stack arguments. Calls ImulRegs, randomd0, puckflip, PlaySoundEffect. Far routine
; (retf).
;-----------------------------------------------------------------------------
wallcoll:
        enter 0x10, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov ax, [regd0]
        mov [si + 0x30], ax
        mov ax, [regd1]
        mov [si + 0x32], ax
        mov dx, [si + 0xc]
        mov ax, [regd1]
        call 0x03A3:ImulRegs
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [si + 0xe]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd0]
        mov [bp - 0x4], di
        mov [bp - 0x2], cx
        call 0x03A3:ImulRegs
        sub ax, [bp - 0x4]
        sbb dx, [bp - 0x2]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [regd2], ax
        mov dx, [si + 0xc]
        mov ax, [regd0]
        call 0x03A3:ImulRegs
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [si + 0xe]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd1]
        mov [bp - 0x8], di
        mov [bp - 0x6], cx
        call 0x03A3:ImulRegs
        add ax, [bp - 0x8]
        adc dx, [bp - 0x6]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [regd3], ax
        neg word [regd2]
        cmp word [si + 0x5e], 0xe
        jz short .1
        jmp near .13
.1:
        and byte [gmode2], 0xef
        mov word [passplayer], 0xffff
        cmp word [regd2], 0x0
        jl short .3
.2:
        mov word [nethit], 0x0
        pop si
        pop di
        leave
        retf
.3:
        sar word [regd2], byte 0x2
        cmp word [regd2], 0xfc00
        jng short .4
        jmp near .12
.4:
        mov ax, 0x800
        call 0x0C11:randomd0
        neg ax
        mov [si + 0x10], ax
        push si
        call 0x2519:puckflip
        add sp, 0x2
        cmp word [nethit], 0x0
        jnz short .12
        mov cl, 0x8
        mov di, [regd2]
        sar di, cl
        sar di, byte 0x2
        add di, 0x4
        jns short .5
        db 0x2B, 0xFF                           ; insn: sub di, di
.5:
        cmp word [si + 0xa], 0xa
        ja short .8
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .12
        mov cx, 0x3
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        idiv cx
        db 0x8B, 0xFA                           ; insn: mov di, dx
        cmp dx, 0x2
        jnz short .6
        mov ax, 0x95
        jmp short .11
        db 0x90, 0x90
.6:
        cmp di, 0x1
        jnz short .7
        mov ax, 0x7b
        jmp short .11
.7:
        mov ax, 0xad
        jmp short .11
        db 0x90
.8:
        mov ax, 0x3
        call 0x0C11:randomd0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .9
        mov ax, 0xaf
        jmp short .11
        db 0x90
.9:
        cmp di, 0x1
        jnz short .10
        mov ax, 0xa5
        jmp short .11
.10:
        mov ax, 0xa7
.11:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push di
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.12:
        mov dx, [regd3]
        sar dx, byte 0x6
        sub [regd3], dx
        sar dx, 1
        sub [regd3], dx
        jmp short .16
        db 0x90
.13:
        cmp word [regd2], 0x3e8
        jng short .14
        jmp near .2
.14:
        cmp word [regd2], 0xf000
        jg short .15
        cmp word [si + 0x18], 0xa
        jl short .15
        cmp word [nethit], 0x0
        jnz short .15
        push word 0xb1
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.15:
        sar word [regd2], byte 0x2
        cmp word [regd2], 0xfc7c
        jl short .16
        mov word [regd2], 0xfc18
.16:
        mov word [nethit], 0x0
        mov ax, [regd1]
        mov dx, [regd2]
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd0]
        mov [bp - 0xc], di
        mov [bp - 0xa], dx
        mov dx, [regd3]
        call 0x03A3:ImulRegs
        sub ax, [bp - 0xc]
        sbb dx, [bp - 0xa]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [si + 0xc], ax
        mov ax, [regd2]
        mov dx, [regd0]
        call 0x03A3:ImulRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [regd3]
        mov [bp - 0x10], di
        mov [bp - 0xe], dx
        mov dx, [regd1]
        call 0x03A3:ImulRegs
        add ax, [bp - 0x10]
        adc dx, [bp - 0xe]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        shl dh, 1
        db 0x1A, 0xF6                           ; insn: sbb dh, dh
        mov [si + 0xe], ax
        cmp word [si + 0x10], 0x0
        jng short .17
        mov word [si + 0x10], 0x0
.17:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; wallcollb                                                  28BB:3024  94 PC
; Checks whether the puck flew over the boards: a low puck bounces, a high one is out of play.
;
; Takes 1 word of stack arguments. Calls wallcoll, SetSPA, PlaySoundEffect, AddPenalty2. Far routine
; (retf).
;-----------------------------------------------------------------------------
wallcollb:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        cmp word [si + 0x5e], 0xe
        jz short .2
.1:
        push si
        push cs
        call wallcoll
        add sp, 0x2
        pop si
        leave
        retf
.2:
        cmp word [si + 0xa], 0x1d
        jng short .3
        jmp near .7
.3:
        cmp word [si + 0xa], 0x12
        jna short .1
        cmp word [si + 0x6], 0xf8
        jl short .7
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x28
        jl short .1
        mov ax, [si + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x38
        jg short .1
        cmp word [si + 0xe], 0xfa0
        jl short .1
        cmp word [lty], 0x26
        jl short .1
        sar word [si + 0xe], 1
        lea bx, [si + 0x80]
        mov ax, 0x821
        call 0x2E42:SetSPA
        cmp word [si + 0x2], 0x0
        jl short .4
        mov ax, 0x3f
        jmp short .5
        db 0x90, 0x90
.4:
        mov ax, 0xffc0
.5:
        mov [si + 0x82], ax
        mov word [si + 0x86], 0x10b
        push word 0xae
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        cmp word [CrowdSound], 0x5dc
        jg short .6
        add word [CrowdSound], 0x4b0
        cmp word [CrowdSound], 0x5dc
        jng short .6
        mov word [CrowdSound], 0x5dc
.6:
        add word [g_D6C4], 0xf
.7:
        or byte [sflags], 0x40
        or byte [si + 0x44], 0x4
        cmp word [si + 0x6], 0x0
        jnl short .8
        or byte [si + 0x49], 0x80
.8:
        mov word [si + 0x92], 0xffff
        test byte [gmode], 0x1
        jnz short .9
        push 0x3
        mov ax, [lasttouch]
        shl ax, byte 0x7
        add ax, 0xb50e
        push ax
        call 0x327B:AddPenalty2
        add sp, 0x4
.9:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; checkplcoll                                                28BB:3106  94 PC
; Checks collisions with the other players near the object.
;
; Takes 3 words of stack arguments. Calls checkcx. Far routine (retf).
;-----------------------------------------------------------------------------
checkplcoll:
        enter 0x2, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        test byte [bx + 0x45], 0x20
        jnz short .5
        cmp word [bx + 0x5e], 0xb
        jng short .1
        cmp word [bx + 0x5e], 0x10
        jnz short .5
.1:
        mov si, [bx + 0x5e]
        shl si, 1
        mov di, [si + g_D496]
        cmp di, 0x10
        jz short .3
.2:
        mov al, [di + g_D4F5]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + g_D474]
        sub ax, [bp + 0xa]
        cmp ax, strict word 0x10
        jg short .3
        push si
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call checkcx
        add sp, 0x8
        inc di
        cmp di, 0x10
        jnz short .2
.3:
        mov bx, [bp + 0x6]
        mov bx, [bx + 0x5e]
        shl bx, 1
        mov di, [bx + g_D496]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .5
.4:
        mov al, [di + g_D4F3]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bp + 0xa]
        sub ax, [bx + g_D474]
        cmp ax, strict word 0x10
        jg short .5
        push si
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call checkcx
        add sp, 0x8
        dec di
        jnz short .4
.5:
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90

;-----------------------------------------------------------------------------
; checkcx                                                    28BB:319A  94 PC
; Possible collision with one neighbour: impact, check sound, interference and contact events.
;
; Takes 4 words of stack arguments. Calls ImulRegs, LongSarAt, newcheck, checkint, checkcheck,
; VectorToDir8, doplayeracc. Far routine (retf).
;-----------------------------------------------------------------------------
checkcx:
        enter 0x20, 0x0
        push di
        push si
        mov di, [bp + 0xc]
        shl di, byte 0x7
        add di, 0xb50e
        test byte [di + 0x44], 0x4
        jz short .1
        jmp near .19
.1:
        test byte [di + 0x45], 0x20
        jz short .2
        jmp near .19
.2:
        cmp word [di + 0x5e], 0xb
        jng short .3
        cmp word [di + 0x5e], 0x10
        jz short .3
        jmp near .19
.3:
        mov si, [di + 0x2]
        test byte [sflags], 0x80
        jz short .4
        mov si, [di + 0x6]
.4:
        sub si, [bp + 0x8]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jng short .5
        jmp near .19
.5:
        mov ax, [bp + 0xa]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [bp - 0xa], si
        mov [bp - 0x8], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xa]
        adc dx, [bp - 0x8]
        mov [regd0], ax
        mov [g_D66E], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .6
        jmp near .19
.6:
        jl short .7
        cmp ax, 0x100
        jna short .7
        jmp near .19
.7:
        mov si, [bp + 0x6]
        mov ax, [si + 0xc]
        sub ax, [di + 0xc]
        mov [bp - 0x4], ax
        mov cx, [si + 0xe]
        sub cx, [di + 0xe]
        mov [bp - 0x6], cx
        mov dx, [di + 0x2]
        sub dx, [si + 0x2]
        mov [bp - 0x2], dx
        mov bx, [di + 0x6]
        sub bx, [si + 0x6]
        mov [bp + 0xa], bx
        mov [bp - 0xc], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov [bp - 0xe], bx
        call 0x03A3:ImulRegs
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov ax, [bp - 0xe]
        mov dx, [bp - 0xc]
        call 0x03A3:ImulRegs
        add ax, [bp - 0x12]
        adc dx, [bp - 0x10]
        mov [regd1], ax
        mov [g_D674], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .8
        jmp near .19
.8:
        push 0x4
        push word 0xd672
        call 0x0000:LongSarAt
        cmp word [si + 0x5e], 0x10
        jz short .9
        cmp word [di + 0x5e], 0x10
        jz short .9
        mov al, [si + 0x44]
        xor al, [di + 0x44]
        test al, 0x40
        jz short .15
.9:
        mov al, [g_D673]
        cbw
        mov [regd4], ax
        cmp ax, strict word 0x5
        jg short .10
        mov word [regd4], 0x5
        mov word [g_D6CA], 0x0
.10:
        mov ax, [regd4]
        mov [lastimpact], ax
        add [si + 0x18], ax
        mov ax, [regd4]
        add [di + 0x18], ax
        test byte [di + 0x45], 0x1
        jnz short .11
        mov ax, [si + 0x5e]
        mov [di + 0x14], ax
.11:
        test byte [si + 0x45], 0x1
        jnz short .12
        mov ax, [di + 0x5e]
        mov [si + 0x14], ax
.12:
        cmp word [regd4], 0x14
        jl short .14
        mov bx, [puckc]
        mov al, [bx]
        cbw
        mov [bp - 0x14], ax
        cmp ax, [si + 0x5e]
        jz short .13
        mov ax, [di + 0x5e]
        cmp [bp - 0x14], ax
        jnz short .14
.13:
        push 0x0
        push cs
        call newcheck
        add sp, 0x2
.14:
        push di
        push si
        push cs
        call checkint
        add sp, 0x4
        push word [regd4]
        push di
        push si
        push cs
        call checkcheck
        add sp, 0x6
.15:
        mov ax, [regd1]
        mov [regd4], ax
        cmp byte [collflag], 0x0
        jnl short .16
        jmp near .19
.16:
        mov ax, [bp - 0x2]
        mov dx, [bp - 0x6]
        call 0x03A3:ImulRegs
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        mov ax, [bp + 0xa]
        mov dx, [bp - 0x4]
        call 0x03A3:ImulRegs
        sub ax, [bp - 0x18]
        sbb dx, [bp - 0x16]
        mov [regd0], ax
        mov [g_D66E], dx
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        mov [regd5], ax
        mov al, [si + 0x4a]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, 0x8c
        mov [regd0], ax
        mov al, [di + 0x4a]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, 0x8c
        mov [regd1], ax
        mov word [LastShooterTeam], 0x0
        mov ax, [regd0]
        add [regd1], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [regd4]
        call 0x03A3:ImulRegs
        mov bx, [regd1]
        call 0x03A3:IdivWords.regs
        mov [regd0], ax
        mov [regd1], ax
        mov dx, [bp - 0x2]
        call 0x03A3:ImulRegs
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        mov ax, [regd5]
        mov dx, [bp + 0xa]
        call 0x03A3:ImulRegs
        add ax, [bp - 0x1c]
        adc dx, [bp - 0x1a]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add ax, [di + 0xc]
        mov [si + 0xc], ax
        mov ax, [regd5]
        mov dx, [bp - 0x2]
        call 0x03A3:ImulRegs
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        mov ax, [regd0]
        mov dx, [bp + 0xa]
        call 0x03A3:ImulRegs
        sub ax, [bp - 0x20]
        sbb dx, [bp - 0x1e]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add ax, [di + 0xe]
        mov [si + 0xe], ax
        mov ax, [regd1]
        mov dx, [bp - 0x2]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add [di + 0xc], ax
        mov ax, [regd1]
        mov dx, [bp + 0xa]
        call 0x03A3:ImulRegs
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        add [di + 0xe], ax
        mov byte [collflag], 0xff
        test byte [gmode], 0x1
        jz short .17
        jmp near .19
.17:
        mov al, [si + 0x44]
        xor al, [di + 0x44]
        test al, 0x40
        jnz short .19
        mov ax, [di + 0x2]
        sub ax, [si + 0x2]
        mov dx, [di + 0x6]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        mov [bp - 0x2], ax
        test byte [si + 0x44], 0x8
        jnz short .18
        mov ax, [si + 0x2a]
        sub ax, [si + 0x2]
        mov dx, [si + 0x2c]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        cmp ax, [bp - 0x2]
        jnz short .18
        mov al, [bp - 0x2]
        add al, 0x2
        and ax, strict word 0x7
        push ax
        push si
        call 0x2425:doplayeracc
        add sp, 0x4
.18:
        test byte [di + 0x44], 0x8
        jnz short .19
        mov ax, [di + 0x2a]
        sub ax, [di + 0x2]
        mov dx, [di + 0x2c]
        sub dx, [di + 0x6]
        call 0x0D5F:VectorToDir8
        mov cl, [bp - 0x2]
        sub cl, 0xfc
        and cx, 0x7
        mov [bp - 0x2], cx
        db 0x3B, 0xC8                           ; insn: cmp cx, ax
        jnz short .19
        mov al, [bp - 0x2]
        add al, 0x2
        and ax, strict word 0x7
        push ax
        push di
        call 0x2425:doplayeracc
        add sp, 0x4
.19:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CPgoalie                                                   28BB:34EA  94 PC
; A computer team pulls its goalie late in the third period when it trails by one or two.
;
; Takes 3 words of stack arguments. Calls setpersonel. Far routine (retf).
;-----------------------------------------------------------------------------
CPgoalie:
        enter 0x2, 0x0
        push di
        push si
        cmp word [gsp], 0x2
        jnz short .4
        mov si, [bp + 0x6]
        mov bx, [bp + 0x8]
        mov ax, [bx + 0xc]
        sub ax, [si + 0xc]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .4
        cmp dx, 0x2
        jg short .4
        cmp word [gameclock], 0x3c
        jg short .4
        mov dx, [bp + 0xa]
        mov bx, [si + 0xd4]
        test byte [bx + 0x44], 0x80
        jnz short .1
        neg dx
.1:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .4
        mov byte [si + 0x25], 0xff
        cmp si, 0xb438
        jnz short .2
        mov bx, 0x1
        jmp short .3
        db 0x90
.2:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.3:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        mov di, [si + 0x24]
        and di, 0xf
        shl di, byte 0x2
        les di, [bx + di + goaliemenuflags]
        mov byte [es:di], 0x2
        les bx, [bx + goaliemenuflags_e02]
        mov byte [es:bx], 0x1
        push si
        call 0x2E42:setpersonel
        add sp, 0x2
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ChkGoalies                                                 28BB:356A  94 PC
; Computer goalie pull on a delayed penalty, once a second.
;
; Calls setpersonel, CPgoalie. Far routine (retf).
;-----------------------------------------------------------------------------
ChkGoalies:
        enter 0x4, 0x0
        push di
        push si
        test byte [gmode], 0x1
        jz short .1
        jmp near .7
.1:
        mov si, 0xb362
        mov cx, 0xb438
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x2], di
.2:
        cmp word [si + 0x24], 0x0
        jl short .6
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x4], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .6
        cmp al, 0x6
        jnl short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        cmp di, 0x1
        db 0x1B, 0xD2                           ; insn: sbb dx, dx
        neg dx
        db 0x33, 0xC2                           ; insn: xor ax, dx
        jnz short .6
        test byte [gmode], 0x8
        jz short .5
        mov byte [si + 0x25], 0xff
        mov bl, [si + 0x24]
        and bx, 0xf
        shl bx, byte 0x2
        add bx, [bp - 0x2]
        les bx, [bx + goaliemenuflags]
        mov byte [es:bx], 0x2
        mov bx, [bp - 0x2]
        les bx, [bx + goaliemenuflags_e02]
        mov byte [es:bx], 0x1
        push si
        call 0x2E42:setpersonel
        add sp, 0x2
        jmp short .6
.5:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [cont1team]
        inc ax
        jz short .6
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [cont2team]
        inc ax
        jz short .6
        mov bx, [pucky]
        push word [bx]
        push cx
        push si
        push cs
        call CPgoalie
        add sp, 0x6
.6:
        inc di
        mov si, 0xb438
        mov cx, 0xb362
        add word [bp - 0x2], 0xc
        cmp word [bp - 0x2], 0x18
        jnl short .7
        jmp near .2
.7:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReturnGoalies                                              28BB:361E  94 PC
; Puts a pulled computer goalie back in net.
;
; Calls CPgoalie.
;-----------------------------------------------------------------------------
ReturnGoalies:
        enter 0x4, 0x0
        push di
        push si
        mov si, 0xb362
        mov word [bp - 0x4], 0xb438
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x2], di
.1:
        test byte [si + 0x24], 0xf0
        jnz short .2
        mov byte [si + 0x25], 0x0
        mov bx, [bp - 0x2]
        les bx, [bx + goaliemenuflags_e02]
        mov byte [es:bx], 0x2
        mov bl, [si + 0x24]
        and bx, 0xf
        shl bx, byte 0x2
        add bx, [bp - 0x2]
        les bx, [bx + goaliemenuflags]
        mov byte [es:bx], 0x1
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [cont1team]
        inc ax
        jz short .2
        db 0x8B, 0xC7                           ; insn: mov ax, di
        sub ax, [cont2team]
        inc ax
        jz short .2
        push word [foy]
        push word [bp - 0x4]
        push si
        push cs
        call CPgoalie
        add sp, 0x6
.2:
        inc di
        mov si, 0xb438
        mov word [bp - 0x4], 0xb362
        add word [bp - 0x2], 0xc
        cmp word [bp - 0x2], 0x18
        jl short .1
        pop si
        pop di
