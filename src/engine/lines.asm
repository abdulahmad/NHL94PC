; Default lines and line slots (AI.OVL)
; The first bytes finish the last routine of rink_objects.asm.
        jmp near DrawRinkObjects.5 - 0x440

;-----------------------------------------------------------------------------
; DrawRinkObjectsTail                                        317A:0003  94 PC
; The rest of DrawRinkObjects, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
DrawRinkObjectsTail:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SortPlayersByPos                                           317A:0008  94 PC
; Sorts the 25 roster players of one position (SortPairs)
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
SortPlayersByPos:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        db 0x2B, 0xF6                           ; insn: sub si, si
        imul ax, [bp + 0x6], word 0x460
        add ax, 0xa557
        mov [bp - 0x8], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov cx, [bp - 0x8]
.1:
        mov [si + possort], dx
        mov al, [di]
        cmp [bp + 0xc], al
        jz short .2
        mov ax, 0xffff
        jmp short .3
        db 0x90
.2:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov ax, [bx]
.3:
        mov [si + lineslotmark], ax
        inc cx
        inc cx
        add di, 0x28
        inc dx
        inc si
        inc si
        cmp si, 0x32
        jl short .1
        push word possort
        push word 0xdf00
        push 0x19
        call 0x14F6:SortPairs - 0x90
        add sp, 0x6
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov dx, [bp + 0x8]
.4:
        cmp word [di + lineslotmark], 0x0
        jl short .5
        mov al, [di + possort]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov [bx + si], al
        jmp short .6
        db 0x90
.5:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov byte [bx + si], 0xff
.6:
        inc si
        inc di
        inc di
        cmp di, 0x32
        jl short .4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SortNonDefPlayers                                          317A:0086  94 PC
; Sorts the 25 roster players that are not defencemen.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
SortNonDefPlayers:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        db 0x2B, 0xF6                           ; insn: sub si, si
        imul ax, [bp + 0x6], word 0x460
        add ax, 0xa557
        mov [bp - 0x8], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov cx, [bp - 0x8]
.1:
        mov [si + possort], dx
        cmp byte [di], 0x44
        jnz short .2
        mov ax, 0xffff
        jmp short .3
        db 0x90
.2:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov ax, [bx]
.3:
        mov [si + lineslotmark], ax
        inc cx
        inc cx
        add di, 0x28
        inc dx
        inc si
        inc si
        cmp si, 0x32
        jl short .1
        push word possort
        push word 0xdf00
        push 0x19
        call 0x14F6:SortPairs - 0x90
        add sp, 0x6
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov dx, [bp + 0x8]
.4:
        cmp word [di + lineslotmark], 0x0
        jl short .5
        mov al, [di + possort]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov [bx + si], al
        jmp short .6
        db 0x90
.5:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov byte [bx + si], 0xff
.6:
        inc si
        inc di
        inc di
        cmp di, 0x32
        jl short .4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; BuildDefaultLines                                          317A:0102  94 PC
; Ranks each team's players by position and fills the default line tables.
;
; Calls SortPlayersByPos, SortNonDefPlayers. Far routine (retf).
;-----------------------------------------------------------------------------
BuildDefaultLines:
        enter 0x106, 0x0
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov [bp - 0xa], dx
        mov cx, 0xa550
        mov si, 0x0
.1:
        mov [bp - 0x2], di
        mov [bp - 0x4], cx
        mov word [bp - 0x8], 0x19
        mov [bp - 0xe], cx
        mov [bp - 0x10], di
        mov [bp - 0xc], dx
        mov ax, 0x3a0b
        mov es, ax
.2:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        cmp byte [bx], 0x0
        jnz short .3
        jmp near .5
.3:
        cmp byte [bx], 0x1
        jnz short .4
        jmp near .5
.4:
        mov al, [es:si + HomeSortObjs + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dl, [es:si + HomeSortObjs + 0xD]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        mov bl, [es:si + HomeSortObjs + 0xA]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov [bp - 0xdc], ax
        mov al, [es:si + HomeSortObjs + 0x9]
        mov [bp - 0xde], ax
        mov al, [es:si + HomeSortObjs + 0x6]
        mov [bp - 0xe0], ax
        mov al, [es:si + HomeSortObjs + 0x4]
        mov [bp - 0xe2], ax
        mov al, [es:si + HomeSortObjs + 0x3]
        mov [bp - 0xe4], ax
        mov al, [es:si + HomeSortObjs + 0x2]
        mov [bp - 0xe6], ax
        mov al, [bp - 0xe4]
        add ax, [bp - 0xe6]
        mov [bp - 0xe8], ax
        mov al, [bp - 0xe2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0xe8]
        mov [bp - 0xea], ax
        mov al, [bp - 0xe0]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0xea]
        mov [bp - 0xec], ax
        mov al, [bp - 0xde]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0xec]
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x03, 0xC2                           ; insn: add ax, dx
        add ax, [bp - 0xdc]
        mov [bp + di - 0x76], ax
        mov al, [es:si + HomeSortObjs + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dl, [es:si + HomeSortObjs + 0xD]
        mov bl, [es:si + HomeSortObjs + 0xC]
        mov [bp - 0xee], ax
        mov al, [es:si + HomeSortObjs + 0xB]
        mov [bp - 0xf0], ax
        mov al, [es:si + HomeSortObjs + 0x9]
        mov [bp - 0xf2], ax
        mov al, [es:si + HomeSortObjs + 0x6]
        mov [bp - 0xf4], ax
        mov al, [es:si + HomeSortObjs + 0x5]
        mov [bp - 0xf6], ax
        mov al, [es:si + HomeSortObjs + 0x4]
        mov [bp - 0xf8], ax
        mov al, [es:si + HomeSortObjs + 0x3]
        mov [bp - 0xfa], ax
        mov al, [es:si + HomeSortObjs + 0x2]
        mov [bp - 0xfc], ax
        mov al, [bp - 0xfa]
        add ax, [bp - 0xfc]
        mov [bp - 0xfe], ax
        mov al, [bp - 0xf8]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0xfe]
        mov [bp - 0x100], ax
        mov al, [bp - 0xf6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x100]
        mov [bp - 0x102], ax
        mov al, [bp - 0xf4]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x102]
        mov [bp - 0x104], ax
        mov al, [bp - 0xf2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x104]
        mov [bp - 0x106], ax
        mov al, [bp - 0xf0]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, [bp - 0x106]
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x03, 0xC2                           ; insn: add ax, dx
        add ax, [bp - 0xee]
        mov [bp + di - 0xda], ax
        jmp short .6
        db 0x90
.5:
        mov ax, 0xffff
        mov [bp + di - 0xda], ax
        mov [bp + di - 0x76], ax
.6:
        inc di
        inc di
        add si, 0x14
        add cx, 0x28
        dec word [bp - 0x8]
        jz short .7
        jmp near .2
.7:
        mov [bp - 0x12], si
        mov di, [bp - 0x10]
        mov si, [bp - 0xa]
        push 0x44
        lea ax, [bp + di - 0x76]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdcda
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x52
        lea ax, [bp + di - 0x76]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xddd4
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x4c
        lea ax, [bp + di - 0x76]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xde06
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x43
        lea ax, [bp + di - 0x76]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdda2
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x44
        lea ax, [bp + di - 0xda]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdd3e
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x52
        lea ax, [bp + di - 0xda]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xde6a
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x4c
        lea ax, [bp + di - 0xda]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xde9c
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        push 0x43
        lea ax, [bp + di - 0xda]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xde38
        push ax
        push word [bp - 0xc]
        push cs
        call SortPlayersByPos
        add sp, 0x8
        lea ax, [bp + di - 0x76]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdd0c
        push ax
        push word [bp - 0xc]
        push cs
        call SortNonDefPlayers
        add sp, 0x6
        lea ax, [bp + di - 0xda]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add ax, 0xdd70
        push ax
        push word [bp - 0xc]
        push cs
        call SortNonDefPlayers
        add sp, 0x6
        mov word [bp - 0x6], 0x0
        mov ax, [bp - 0xe]
        mov [bp - 0x2], ax
        mov di, [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
.8:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        add dx, 0x28
        mov bl, [bx]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov al, [bx + dressbystatus]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bx + dressflags], al
        inc di
        cmp di, 0x19
        jl short .8
        cmp word [bp - 0xc], 0x0
        jz short .9
        mov di, AwayTeamRec
        jmp short .10
.9:
        mov di, HomeTeamRec
.10:
        mov dx, 0x12
        mov si, [bp - 0xa]
.11:
        mov al, [di]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov byte [bx + si + dressflags], 0x0
        inc di
        dec dx
        jnz short .11
        add si, 0x19
        mov di, [bp - 0x10]
        add di, 0x32
        mov dx, [bp - 0xc]
        inc dx
        mov cx, [bp - 0xe]
        mov [bp - 0xa], si
        add cx, 0x460
        cmp cx, 0xae10
        jnc short .12
        mov si, [bp - 0x12]
        jmp near .1
.12:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CanFillLineSlot                                            317A:03D6  94 PC
; Returns 1 when a roster player can fill a line slot, else 0.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CanFillLineSlot:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        mov ax, 0xae40
        jmp short .2
.1:
        mov ax, 0xae10
.2:
        mov [bp - 0x6], ax
        imul ax, di, 0x1c
        add ax, [bp + 0xa]
        imul bx, ax, 0x28
        mov [bp - 0x8], bx
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov al, [bx + dressbystatus]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.4:
        cmp si, 0x2
        jnz short .5
        imul si, di, 0x19
        mov bx, [bp + 0xa]
        cmp byte [bx + si + dressflags], 0x2
        jnz short .3
.5:
        mov bx, [bp - 0x8]
        mov bl, [bx + hmrosterpos]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp word [bp + 0x8], 0xc
        jnl short .10
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x4], si
        mov di, [bp + 0x8]
.6:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jnz short .7
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jnl short .8
.7:
        mov bx, [bp - 0x6]
        mov al, [bx + si]
        cbw
        cmp ax, [bp + 0xa]
        jnz short .8
        inc word [bp - 0x4]
.8:
        inc si
        cmp si, 0xc
        jl short .6
        cmp word [bp - 0x4], 0x2
        jl short .9
        cmp word [dressedfwds], 0x6
        jg short .3
.9:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        lea ax, [bx + 0x2]
        mov [bp - 0x4], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp near .25
.10:
        mov di, [bp + 0x8]
        cmp di, 0x12
        jnl short .15
        cmp word [dresseddefs], 0x3
        jl short .14
        mov word [bp - 0x4], 0x0
        mov si, 0xc
.11:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x2
        cwd
        idiv cx
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jnz short .12
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jnl short .13
.12:
        mov bx, [bp - 0x6]
        mov al, [bx + si]
        cbw
        cmp ax, [bp + 0xa]
        jnz short .13
        inc word [bp - 0x4]
.13:
        inc si
        cmp si, 0x12
        jl short .11
        cmp word [bp - 0x4], 0x2
        jl short .14
        jmp near .3
.14:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        and bl, 0xfe
        lea dx, [bx + 0x1]
        jmp short .25
        db 0x90
.15:
        cmp di, 0x1c
        jnl short .21
        cmp bx, 0x44
        jnz short .16
        cmp word [dresseddefs], 0x4
        jl short .17
.16:
        cmp bx, 0x44
        jz short .20
        cmp word [dressedfwds], 0x6
        jnl short .20
.17:
        cmp di, 0x17
        jl short .18
        mov bx, 0x17
        jmp short .19
        db 0x90
.18:
        mov bx, 0x12
.19:
        lea dx, [bx + 0x4]
        jmp short .25
.20:
        mov bx, 0x12
        mov dx, 0x1b
        jmp short .25
.21:
        cmp bx, 0x44
        jnz short .24
        cmp word [dresseddefs], 0x4
        jnl short .24
        cmp di, 0x20
        jl short .22
        mov bx, 0x20
        jmp short .23
.22:
        mov bx, 0x1c
.23:
        lea dx, [bx + 0x3]
        jmp short .25
.24:
        mov bx, 0x1c
        mov dx, 0x23
.25:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jg short .30
        mov [bp - 0x4], dx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov cx, [bp + 0xa]
.26:
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jz short .29
        cmp di, 0x1c
        jl short .27
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC6                           ; insn: sub ax, si
        cmp ax, strict word 0xfffc
        jnz short .28
        jmp short .29
.27:
        cmp di, 0x12
        jl short .28
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC6                           ; insn: sub ax, si
        cmp ax, strict word 0xfffb
        jz short .29
.28:
        mov bx, [bp - 0x6]
        mov al, [bx + si]
        cbw
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnz short .29
        jmp near .3
.29:
        inc si
        db 0x3B, 0xF2                           ; insn: cmp si, dx
        jng short .26
.30:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FillDressedSlots                                           317A:0588  94 PC
; Puts each dressed player of a team into a line slot.
;
; Takes 3 words of stack arguments. Calls CanFillLineSlot. Far routine (retf).
;-----------------------------------------------------------------------------
FillDressedSlots:
        enter 0xa, 0x0
        push di
        push si
        mov word [bp - 0x4], 0x0
        mov si, [bp + 0x8]
.1:
        mov bx, [bp + 0x6]
        add bx, [bp - 0x4]
        mov al, [bx]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .2
        jmp near .12
.2:
        imul bx, si, 0x19
        db 0x03, 0xDF                           ; insn: add bx, di
        add bx, 0xdece
        mov [bp - 0x8], bx
        cmp byte [bx], 0x0
        jz short .4
        push di
        push word [bp + 0xa]
        push si
        push cs
        call CanFillLineSlot
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        mov bx, [bp - 0x8]
        cmp byte [bx], 0x2
        jz short .3
        jmp near .11
.3:
        cmp word [dressedskaters], 0x12
        jnl short .4
        imul ax, si, 0x1c
        db 0x03, 0xC7                           ; insn: add ax, di
        imul bx, ax, 0x28
        cmp byte [bx + hmrosterpos], 0x44
        jz short .5
        cmp word [dressedfwds], 0xc
        jl short .5
.4:
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x19
        jl short .1
        jmp short .12
.5:
        imul ax, si, 0x1c
        db 0x03, 0xC7                           ; insn: add ax, di
        imul bx, ax, 0x28
        mov [bp - 0xa], bx
        mov byte [bx + hmroster], 0x3
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .6
        mov ax, 0xae40
        jmp short .7
        db 0x90
.6:
        mov ax, 0xae10
.7:
        mov word [bp - 0x4], 0x28
        mov si, [bp - 0x4]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
.8:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + si]
        cbw
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jnz short .9
        mov byte [bx + si], 0x64
.9:
        inc si
        cmp si, 0x30
        jl short .8
        mov si, [bp + 0x8]
        imul bx, si, 0x19
        mov byte [bx + di + dressflags], 0x1
        inc word [dressedskaters]
        mov bx, [bp - 0xa]
        cmp byte [bx + hmrosterpos], 0x44
        jnz short .10
        inc word [dresseddefs]
        jmp short .11
.10:
        inc word [dressedfwds]
.11:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
.12:
        mov ax, 0xffff
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PickForLineSlot                                            317A:0666  94 PC
; Returns the first ranked player for a line slot that CanFillLineSlot accepts.
;
; Takes 2 words of stack arguments. Calls CanFillLineSlot, FillDressedSlots. Far routine (retf).
;-----------------------------------------------------------------------------
PickForLineSlot:
        enter 0x10, 0x0
        push si
        cmp word [bp + 0x6], 0x0
        jz short .1
        mov ax, 0xae40
        jmp short .2
.1:
        mov ax, 0xae10
.2:
        mov [bp - 0xc], ax
        mov bx, [bp + 0x8]
        mov al, [bx + lineslotgroups]
        cbw
        mov [bp - 0x4], ax
        mov [bp - 0xa], ax
        jmp short .4
.3:
        inc word [bp - 0xa]
.4:
        mov bx, [bp - 0xa]
        mov al, [bx + lineslotgroupstart]
        cbw
        cmp ax, [bp + 0x8]
        jnz short .3
.5:
        inc word [bp - 0xa]
        mov bx, [bp - 0xa]
        cmp byte [bx + lineslotgroupstart], 0x0
        jl short .7
        mov al, [bx + lineslotgroupstart]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov si, [bp - 0xc]
        mov al, [bx + si]
        cbw
        mov [bp - 0x6], ax
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call CanFillLineSlot
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
.6:
        mov ax, [bp - 0x6]
        pop si
        leave
        retf
        db 0x90
.7:
        mov bx, [bp - 0xc]
        mov si, [bp + 0x8]
        mov al, [bx + si]
        cbw
        imul cx, [bp + 0x6], 0x1c
        db 0x03, 0xC1                           ; insn: add ax, cx
        imul bx, ax, 0x28
        mov al, [bx + hmrosterpos]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x2], ax
        cmp ax, strict word 0x44
        jnz short .12
        cmp si, 0x1c
        jnl short .8
        cmp si, 0x12
        jl short .8
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdcda
        jmp short .9
        db 0x90
.8:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd3e
.9:
        push si
.10:
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .11
        jmp near .39
.11:
        pop si
        leave
        retf
.12:
        cmp ax, strict word 0x43
        jnz short .21
        cmp si, 0x1c
        jl short .13
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde38
        jmp short .14
        db 0x90
.13:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdda2
.14:
        push si
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .15
        jmp near .57
.15:
        cmp word [bp + 0x8], 0x1c
        jl short .16
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde9c
        jmp short .17
.16:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde06
.17:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .18
        jmp near .57
.18:
        cmp word [bp + 0x8], 0x1c
        jl short .19
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde6a
        jmp short .20
.19:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xddd4
.20:
        push word [bp + 0x8]
        jmp near .10
        db 0x90
.21:
        cmp ax, strict word 0x52
        jnz short .29
        cmp si, 0x1c
        jl short .22
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde6a
        jmp short .23
        db 0x90
.22:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xddd4
.23:
        push si
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .24
        jmp near .57
.24:
        cmp word [bp + 0x8], 0x1c
        jl short .25
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde9c
        jmp short .26
.25:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde06
.26:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .27
        jmp near .57
.27:
        cmp word [bp + 0x8], 0x1c
        jl short .28
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde38
        jmp short .20
.28:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdda2
        jmp short .20
        db 0x90
.29:
        cmp ax, strict word 0x4c
        jz short .30
        jmp near .39
.30:
        cmp si, 0x1c
        jl short .31
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde9c
        jmp short .32
.31:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde06
.32:
        push si
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .33
        jmp near .57
.33:
        cmp word [bp + 0x8], 0x1c
        jl short .34
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde6a
        jmp short .35
.34:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xddd4
.35:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .36
        jmp near .57
.36:
        cmp word [bp + 0x8], 0x1c
        jl short .37
        imul ax, [bp + 0x6], 0x19
        add ax, 0xde38
        jmp short .38
.37:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdda2
.38:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push ax
        push cs
        call FillDressedSlots
        add sp, 0x6
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .39
        jmp near .57
.39:
        mov ax, [bp - 0x4]
        mov [bp - 0xa], ax
        jmp short .42
        db 0x90
.40:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov si, [bp - 0xc]
        mov al, [bx + si]
        cbw
        mov [bp - 0x6], ax
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call CanFillLineSlot
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .41
        jmp near .6
.41:
        inc word [bp - 0xa]
.42:
        mov bx, [bp - 0xa]
        mov al, [bx + lineslotgroupstart]
        cbw
        cmp ax, [bp + 0x8]
        jnz short .40
        cmp word [bp - 0x2], 0x44
        jnz short .44
        cmp ax, strict word 0x12
        jl short .43
        cmp ax, strict word 0x1c
        jnl short .43
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdcda
        jmp short .46
        db 0x90
.43:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd3e
        jmp short .46
        db 0x90
.44:
        cmp ax, strict word 0x1c
        jl short .45
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd70
        jmp short .46
.45:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd0c
.46:
        mov [bp - 0xe], ax
        mov word [bp - 0x8], 0x0
        jmp short .49
        db 0x90
.47:
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call CanFillLineSlot
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .48
        jmp near .6
.48:
        inc word [bp - 0x8]
.49:
        cmp word [bp - 0x8], 0x19
        jnl short .50
        mov bx, [bp - 0xe]
        mov si, [bp - 0x8]
        mov al, [bx + si]
        cbw
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .47
.50:
        cmp word [bp - 0x2], 0x44
        jnz short .52
        cmp word [bp + 0x8], 0x12
        jl short .51
        cmp word [bp + 0x8], 0x1c
        jnl short .51
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd0c
        jmp short .54
        db 0x90
.51:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd70
        jmp short .54
        db 0x90
.52:
        cmp word [bp + 0x8], 0x1c
        jl short .53
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd3e
        jmp short .54
        db 0x90
.53:
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdcda
.54:
        mov [bp - 0xe], ax
        mov word [bp - 0x8], 0x0
        jmp short .56
        db 0x90
.55:
        inc word [bp - 0x8]
.56:
        cmp word [bp - 0x8], 0x19
        jnl short .57
        mov bx, [bp - 0xe]
        mov si, [bp - 0x8]
        mov al, [bx + si]
        cbw
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .57
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call CanFillLineSlot
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .55
        jmp near .6
.57:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PickGoalie                                                 317A:09CE  94 PC
; Picks a team's starting and backup goalie.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PickGoalie:
        enter 0x6, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        mov si, AwayTeamRec
        jmp short .2
.1:
        mov si, HomeTeamRec
.2:
        cmp word [bp + 0x8], 0x24
        jnz short .3
        mov al, [si + 0x25]
        mov [si + 0x24], al
.3:
        mov word [bp - 0x4], 0x19
        imul ax, di, word 0x460
        add ax, 0xa938
        mov [bp - 0x2], ax
        mov di, [bp - 0x4]
        mov [bp - 0x6], si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov dx, [bp - 0x6]
.4:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + 0x24]
        cbw
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .5
        mov al, [bx + 0x25]
        cbw
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .5
        mov cl, [si]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        cmp byte [bx + dressbystatus], 0x1
        jz short .9
        cmp cx, 0x2
        jnz short .5
        cmp word [bp + 0xa], 0x0
        jnz short .6
.5:
        add si, 0x28
        inc di
        cmp di, 0x1c
        jl short .4
        jmp short .10
.6:
        imul ax, [bp + 0x6], 0x1c
        db 0x03, 0xC7                           ; insn: add ax, di
        imul bx, ax, 0x28
        mov byte [bx + hmroster], 0x3
        mov word [bp - 0x2], 0x28
        mov si, [bp - 0x2]
        mov dx, [bp - 0x6]
.7:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + si]
        cbw
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jnz short .8
        mov byte [bx + si], 0x64
.8:
        inc si
        cmp si, 0x30
        jl short .7
.9:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        jmp short .11
        db 0x90
.10:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + 0x24]
.11:
        mov [bx + 0x25], al
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PickExtraSkater                                            317A:0A7C  94 PC
; Picks the extra skater for a team's line slot.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PickExtraSkater:
        enter 0x8, 0x0
        push di
        push si
        cmp word [bp + 0x6], 0x0
        jz short .1
        mov ax, 0xae40
        jmp short .2
        db 0x90
.1:
        mov ax, 0xae10
.2:
        mov [bp - 0x4], ax
        imul ax, [bp + 0x6], 0x19
        add ax, 0xdd0c
        mov [bp - 0x6], ax
        mov [bp - 0x2], ax
        cmp word [bp + 0x8], 0x26
        jnz short .7
        mov bx, [bp - 0x4]
        mov al, [bx + 0x27]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        imul ax, [bp + 0x6], 0x1c
        mov [bp - 0x8], ax
        db 0x03, 0xC6                           ; insn: add ax, si
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .3
        db 0x8B, 0xC6                           ; insn: mov ax, si
        jmp short .6
        db 0x90
.3:
        db 0x2B, 0xF6                           ; insn: sub si, si
.4:
        mov bx, [bp - 0x2]
        mov al, [bx + si]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .7
        mov ax, [bp - 0x8]
        db 0x03, 0xC7                           ; insn: add ax, di
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jz short .5
        inc si
        cmp si, 0x19
        jl short .4
        jmp short .7
        db 0x90
.5:
        db 0x8B, 0xC7                           ; insn: mov ax, di
.6:
        mov bx, [bp - 0x4]
        mov [bx + 0x26], al
.7:
        mov ax, [bp - 0x6]
        mov [bp - 0x2], ax
        db 0x2B, 0xFF                           ; insn: sub di, di
.8:
        mov bx, [bp - 0x2]
        mov al, [bx + di]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .11
        imul ax, [bp + 0x6], 0x1c
        db 0x03, 0xC6                           ; insn: add ax, si
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .9
        mov bx, [bp - 0x4]
        mov al, [bx + 0x26]
        cbw
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jnz short .10
.9:
        inc di
        cmp di, 0x19
        jl short .8
        pop si
        pop di
        leave
        retf
        db 0x90
.10:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [bx + 0x27], al
.11:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RefillLineSlots                                            317A:0B4C  94 PC
; Refills a run of line slots with PickForLineSlot.
;
; Takes 5 words of stack arguments. Calls PickForLineSlot. Far routine (retf).
;-----------------------------------------------------------------------------
RefillLineSlots:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0xa]
        mov di, [bp + 0xc]
        cmp word [bp + 0x6], 0x0
        jz short .1
        mov bx, AwayTeamRec
        jmp short .2
        db 0x90
.1:
        mov bx, HomeTeamRec
.2:
        mov [bp - 0x2], bx
        add bx, [bp + 0x8]
        mov al, [bx]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        imul ax, [bp + 0x6], 0x19
        mov [bp - 0x6], ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov byte [bx + dressflags], 0x0
        db 0x3B, 0xFE                           ; insn: cmp di, si
        jng short .5
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xC6                           ; insn: sub ax, si
        mov [bp - 0x4], ax
        mov si, [bp + 0x8]
        mov di, [bp + 0x6]
.3:
        push si
        push di
        push cs
        call PickForLineSlot
        add sp, 0x4
        mov bx, [bp - 0x2]
        mov [bx + si], al
        cmp si, 0x12
        jnl short .4
        mov bx, [bp - 0x2]
        mov al, [bx + si]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        add bx, [bp - 0x6]
        mov byte [bx + dressflags], 0x0
.4:
        add si, [bp + 0xe]
        dec word [bp - 0x4]
        jnz short .3
.5:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; RemoveFromLines                                            317A:0BC0  94 PC
; Takes an injured or ejected player out of his team's lines and refills the slot.
;
; Takes 2 words of stack arguments. Calls RefillLineSlots, PickGoalie, PickExtraSkater. Far routine
; (retf).
;-----------------------------------------------------------------------------
RemoveFromLines:
        enter 0xc, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        mov di, [bp + 0x6]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        mov ax, 0xae40
        jmp short .2
        db 0x90
.1:
        mov ax, 0xae10
.2:
        mov [bp - 0x6], ax
        imul ax, di, 0x1c
        mov [bp - 0xa], ax
        db 0x03, 0xC6                           ; insn: add ax, si
        imul bx, ax, 0x28
        mov al, [bx + hmrosterpos]
        mov [bp - 0x8], al
        cmp al, 0x44
        jnz short .5
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [dresseddefs], ax
        mov [bp - 0x4], ax
        imul ax, di, 0x19
        mov [bp - 0xc], ax
        mov si, [bp - 0x4]
.3:
        mov bx, [bp - 0xc]
        mov al, [bx + si + defsort_d]
        cbw
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .8
        mov ax, [bp - 0xa]
        add ax, [bp - 0x2]
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .4
        inc word [dresseddefs]
.4:
        inc si
        cmp si, 0x19
        jl short .3
        jmp short .8
.5:
        cmp byte [bp - 0x8], 0x47
        jz short .8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [dressedfwds], ax
        mov [bp - 0x4], ax
        imul ax, di, 0x19
        mov [bp - 0xc], ax
        mov si, [bp - 0x4]
.6:
        mov bx, [bp - 0xc]
        mov al, [bx + si + offsort_fwd]
        cbw
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .8
        mov ax, [bp - 0xa]
        add ax, [bp - 0x2]
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .7
        inc word [dressedfwds]
.7:
        inc si
        cmp si, 0x19
        jl short .6
.8:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x4], si
        mov di, [bp - 0x6]
.9:
        mov word [bp - 0x2], 0x3
.10:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .11
        push 0x3
        push 0x4
        push word [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call RefillLineSlots
        add sp, 0xa
.11:
        inc si
        dec word [bp - 0x2]
        jnz short .10
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x4
        jl short .9
        mov word [bp - 0x4], 0x0
.12:
        mov word [bp - 0x2], 0x2
.13:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .14
        push 0x2
        push 0x3
        push word [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call RefillLineSlots
        add sp, 0xa
.14:
        inc si
        dec word [bp - 0x2]
        jnz short .13
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x3
        jl short .12
        mov word [bp - 0x4], 0x0
.15:
        mov word [bp - 0x2], 0x5
.16:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .17
        push 0x5
        push 0x2
        push word [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call RefillLineSlots
        add sp, 0xa
.17:
        inc si
        dec word [bp - 0x2]
        jnz short .16
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x2
        jl short .15
        mov word [bp - 0x4], 0x0
.18:
        mov word [bp - 0x2], 0x4
.19:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .20
        push 0x4
        push 0x2
        push word [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call RefillLineSlots
        add sp, 0xa
.20:
        inc si
        dec word [bp - 0x2]
        jnz short .19
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x2
        jl short .18
        mov word [bp - 0x2], 0x2
.21:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .22
        push 0x0
        push si
        push word [bp + 0x6]
        push cs
        call PickGoalie
        add sp, 0x6
.22:
        inc si
        dec word [bp - 0x2]
        jnz short .21
        mov word [bp - 0x2], 0x2
.23:
        mov al, [di]
        inc di
        cbw
        cmp ax, [bp + 0x8]
        jnz short .24
        push si
        push word [bp + 0x6]
        push cs
        call PickExtraSkater
        add sp, 0x4
.24:
        inc si
        dec word [bp - 0x2]
        jnz short .23
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetupTeamLines                                             317A:0D92  94 PC
; Counts a team's available players and fills its line table.
;
; Takes 1 word of stack arguments. Calls RemoveFromLines, PickGoalie. Far routine (retf).
;-----------------------------------------------------------------------------
SetupTeamLines:
        enter 0x10, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        mov ax, 0xae40
        jmp short .2
.1:
        mov ax, 0xae10
.2:
        mov [bp - 0xc], ax
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [dresseddefs], si
        imul ax, di, 0x19
        mov [bp - 0xe], ax
.3:
        mov bx, [bp - 0xe]
        mov al, [bx + si + defsort_d]
        cbw
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .5
        imul ax, di, 0x1c
        add ax, [bp - 0x2]
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .4
        inc word [dresseddefs]
.4:
        inc si
        cmp si, 0x19
        jl short .3
.5:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [dressedfwds], si
        imul ax, di, 0x19
        mov [bp - 0xe], ax
.6:
        mov bx, [bp - 0xe]
        mov al, [bx + si + offsort_fwd]
        cbw
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .8
        imul ax, di, 0x1c
        add ax, [bp - 0x2]
        imul bx, ax, 0x28
        mov bl, [bx + hmroster]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        cmp byte [bx + dressbystatus], 0x1
        jnz short .7
        inc word [dressedfwds]
.7:
        inc si
        cmp si, 0x19
        jl short .6
.8:
        mov ax, [dressedfwds]
        add ax, [dresseddefs]
        mov [dressedskaters], ax
        mov bx, 0xdf00
.9:
        inc bx
        inc bx
        mov word [bx - 0x2], 0x0
        cmp bx, 0xdf32
        jc short .9
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp - 0xc]
.10:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov word [bx + lineslotmark], 0x1
        inc si
        cmp si, 0x24
        jl short .10
        mov al, [di + 0x27]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov word [bx + lineslotmark], 0x1
        mov al, [di + 0x27]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov ax, [bx + lineslotmark]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [di + 0x26]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov [bx + lineslotmark], cx
        mov word [bp - 0x4], 0x0
        mov word [bp - 0xa], 0xdf00
        imul ax, [bp + 0x6], word 0x460
        add ax, 0xa550
        mov [bp - 0x8], ax
        mov si, [bp - 0x4]
        mov di, [bp - 0xa]
.11:
        mov bx, [bp - 0x8]
        mov dl, [bx]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        cmp word [di], 0x0
        jz short .13
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .12
        dec dx
        jnz short .13
.12:
        push si
        push word [bp + 0x6]
        push cs
        call RemoveFromLines
        add sp, 0x4
.13:
        add word [bp - 0x8], 0x28
        inc si
        inc di
        inc di
        cmp di, 0xdf32
        jc short .11
        mov si, 0x24
        mov di, [bp + 0x6]
        imul ax, di, 0x1c
        mov [bp - 0x10], ax
.14:
        mov bx, [bp - 0xc]
        mov al, [bx + si]
        cbw
        add ax, [bp - 0x10]
        imul bx, ax, 0x28
        mov al, [bx + hmroster]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        cmp ax, strict word 0x1
        jnz short .16
.15:
        push 0x1
        push si
        push di
        push cs
        call PickGoalie
        add sp, 0x6
.16:
        inc si
        cmp si, 0x25
        jl short .14
        db 0x2B, 0xF6                           ; insn: sub si, si
        imul ax, di, 0x19
        mov [bp - 0xe], ax
.17:
        mov bx, [bp - 0xe]
        cmp byte [bx + si + dressflags], 0x1
        jnz short .18
        mov al, 0x1
        jmp short .19
.18:
        db 0x2A, 0xC0                           ; insn: sub al, al
.19:
        mov [bx + si + dressflags], al
        inc si
        cmp si, 0x19
        jl short .17
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; NormalizeDressFlags                                        317A:0F22  94 PC
; Turns the dressed flags of both teams into 0 or 1.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
NormalizeDressFlags:
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
.1:
        cmp byte [si + dressflags], 0x1
        jnz short .2
        mov al, 0x1
        jmp short .3
.2:
        db 0x2A, 0xC0                           ; insn: sub al, al
.3:
        mov [si + dressflags], al
        cmp byte [si + dressflags_aw], 0x1
        jnz short .4
        mov al, 0x1
        jmp short .5
        db 0x90
.4:
        db 0x2A, 0xC0                           ; insn: sub al, al
.5:
        mov [si + dressflags_aw], al
        inc si
        cmp si, 0x19
        jl short .1
        pop si
        retf

;-----------------------------------------------------------------------------
; CanRemovePlayer                                            317A:0F50  94 PC
; Returns nonzero when the team has enough players left to take this one out.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CanRemovePlayer:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        mov [bp - 0x6], ax
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x8], di
        mov [bp - 0x4], di
        imul ax, ax, 0x19
        mov [bp - 0xa], ax
.1:
        mov bx, [bp - 0xa]
        mov al, [bx + di + defsort_d]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .5
        mov bx, [bp + 0x6]
        mov al, [bx + 0x47]
        cbw
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jnz short .2
        mov word [bp - 0x8], 0x1
.2:
        imul ax, [bp - 0x6], 0x1c
        db 0x03, 0xC6                           ; insn: add ax, si
        imul bx, ax, 0x28
        mov al, [bx + hmroster]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, strict word 0x4
        jz short .3
        cmp ax, strict word 0x3
        jnz short .4
.3:
        inc word [bp - 0x4]
.4:
        inc di
        cmp di, 0x19
        jl short .1
.5:
        cmp word [bp - 0x8], 0x0
        jz short .7
        cmp word [bp - 0x4], 0x2
        jng short .12
.6:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x4], si
        imul ax, [bp - 0x6], 0x19
        mov [bp - 0xa], ax
.8:
        mov bx, [bp - 0xa]
        mov al, [bx + si + offsort_fwd]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .11
        imul ax, [bp - 0x6], 0x1c
        db 0x03, 0xC7                           ; insn: add ax, di
        imul bx, ax, 0x28
        mov al, [bx + hmroster]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, strict word 0x4
        jz short .9
        cmp ax, strict word 0x3
        jnz short .10
.9:
        inc word [bp - 0x4]
.10:
        inc si
        cmp si, 0x19
        jl short .8
.11:
        cmp word [bp - 0x4], 0x4
        jg short .6
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
