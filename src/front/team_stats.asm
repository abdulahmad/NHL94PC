; Team stats screen and its sort comparators (STATS.OVL)
; The first bytes finish the last routine of standings.asm.
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpTeamScoring                                             25E5:0002  94 PC
; Team comparator: goals for (+4)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpTeamScoring:
        enter 0xe, 0x0
        push di
        push si
        cmp word [ss:statscontext], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x28
        jmp short .2
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x3a
.2:
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        cmp word [ss:statscontext], 0x0
        jnz short .3
        mov bx, [bp + 0x8]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        add ax, strict word 0x28
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov bx, [bp + 0x8]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x3a
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
.4:
        les bx, [bp - 0xc]
        mov ax, [es:bx + 0x4]
        mov es, [bp - 0x2]
        cmp [es:si + 0x4], ax
        jz short .5
        mov ax, [es:si + 0x4]
        mov es, [bp - 0xa]
        sub ax, [es:bx + 0x4]
        jmp short .10
        db 0x90, 0x90
.5:
        mov es, [bp - 0xa]
        mov al, [es:bx]
        mov es, [bp - 0x2]
        cmp [es:si], al
        jz short .7
        mov es, [bp - 0xa]
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0x2]
        mov cl, [es:si]
.6:
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        jmp short .10
.7:
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        shl ax, 1
        mov cl, [es:si + 0x3]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, [bp - 0xa]
        mov cl, [es:bx + 0x3]
        mov dl, [es:bx + 0x1]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        shl dx, 1
        db 0x03, 0xD1                           ; insn: add dx, cx
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jz short .8
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        jmp short .10
        db 0x90
.8:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov al, [es:di + 0x1]
        mov es, [bp - 0x2]
        cmp [es:si + 0x1], al
        jz short .9
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0xa]
        mov cl, [es:di + 0x1]
        jmp short .6
.9:
        mov bx, [bp + 0x6]
        mov ax, [ss:bx]
        mov bx, [bp + 0x8]
        sub ax, [ss:bx]
.10:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpTeamDefense                                             25E5:011A  94 PC
; Team comparator: goals against (+6)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpTeamDefense:
        enter 0xe, 0x0
        push di
        push si
        cmp word [ss:statscontext], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x28
        jmp short .2
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x3a
.2:
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        cmp word [ss:statscontext], 0x0
        jnz short .3
        mov bx, [bp + 0x8]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        add ax, strict word 0x28
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov bx, [bp + 0x8]
        imul ax, [ss:bx], 0x4c
        add ax, [ss:statscmpsum]
        mov dx, [ss:statscmpsum2]
        add ax, strict word 0x3a
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
.4:
        les bx, [bp - 0xc]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x2]
        cmp [es:si + 0x6], ax
        jz short .5
        mov es, [bp - 0xa]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x2]
        sub ax, [es:si + 0x6]
        jmp short .10
        db 0x90
.5:
        mov es, [bp - 0xa]
        mov al, [es:bx]
        mov es, [bp - 0x2]
        cmp [es:si], al
        jz short .7
        mov al, [es:si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0xa]
        mov cl, [es:bx]
.6:
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        jmp short .10
        db 0x90
.7:
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        shl ax, 1
        mov cl, [es:si + 0x3]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, [bp - 0xa]
        mov cl, [es:bx + 0x3]
        mov dl, [es:bx + 0x1]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        shl dx, 1
        db 0x03, 0xD1                           ; insn: add dx, cx
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jz short .8
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        jmp short .10
        db 0x90
.8:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov al, [es:di + 0x1]
        mov es, [bp - 0x2]
        cmp [es:si + 0x1], al
        jz short .9
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0xa]
        mov cl, [es:di + 0x1]
        jmp short .6
.9:
        mov bx, [bp + 0x6]
        mov ax, [ss:bx]
        mov bx, [bp + 0x8]
        sub ax, [ss:bx]
.10:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpTeamPP                                                  25E5:0232  94 PC
; Team comparator: power play (+8/+0Ah)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpTeamPP:
        enter 0x1c, 0x0
        push di
        push si
        mov bx, [bp + 0x8]
        mov si, [bp + 0x6]
        mov si, [si]
        mov [bp - 0x18], si
        shl si, 1
        add si, [statsrecs]
        mov es, [statsrecsseg]
        mov ax, [es:si]
        mov [bp - 0x16], ax
        mov si, [bx]
        mov [bp - 0x1c], si
        shl si, 1
        add si, [statsrecs]
        mov cx, [es:si]
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .1
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [bp - 0x16]
        jmp near .14
        db 0x90
.1:
        cmp word [statscontext], 0x0
        jnz short .2
        imul ax, [bp - 0x18], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x28
        jmp short .3
.2:
        imul ax, [bp - 0x18], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.3:
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        cmp word [statscontext], 0x0
        jnz short .4
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        add ax, strict word 0x28
        jmp short .5
.4:
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.5:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xe], dx
        mov es, dx
        mov ax, [es:di + 0xa]
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        les bx, [bp - 0x8]
        mul word [es:bx + 0x8]
        mov es, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:di + 0x8]
        mov es, [bp - 0x6]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mul word [es:bx + 0xa]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        db 0x1B, 0xD6                           ; insn: sbb dx, si
        mov [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .8
        cmp word [bp - 0x12], 0x0
        jl short .7
        jg short .6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
.6:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.8:
        mov [bp - 0x10], di
        db 0x8B, 0xF3                           ; insn: mov si, bx
        les bx, [bp - 0x10]
        mov ax, [es:bx + 0xa]
        mov es, [bp - 0x6]
        cmp [es:si + 0xa], ax
        jz short .9
        mov es, [bp - 0xe]
        mov ax, [es:bx + 0xa]
        mov es, [bp - 0x6]
        sub ax, [es:si + 0xa]
        pop si
        pop di
        leave
        retf
        db 0x90
.9:
        mov es, [bp - 0xe]
        mov al, [es:bx]
        mov es, [bp - 0x6]
        cmp [es:si], al
        jz short .11
        mov es, [bp - 0xe]
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0x6]
        mov cl, [es:si]
.10:
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        pop si
        pop di
        leave
        retf
.11:
        mov es, [bp - 0xe]
        mov al, [es:bx + 0x3]
        mov cl, [es:bx + 0x1]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        shl cx, 1
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov es, [bp - 0x6]
        mov al, [es:si + 0x1]
        shl ax, 1
        mov dl, [es:si + 0x3]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov [bp - 0x12], ax
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .12
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [bp - 0x12]
        pop si
        pop di
        leave
        retf
.12:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov es, [bp - 0xe]
        mov al, [es:di + 0x1]
        mov es, [bp - 0x6]
        cmp [es:si + 0x1], al
        jz short .13
        mov es, [bp - 0xe]
        mov al, [es:di + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0x6]
        mov cl, [es:si + 0x1]
        jmp short .10
.13:
        mov ax, [bp - 0x18]
        sub ax, [bp - 0x1c]
.14:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpTeamPK                                                  25E5:03B6  94 PC
; Team comparator: penalty killing (+0Ch/+0Eh)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpTeamPK:
        enter 0x1c, 0x0
        push di
        push si
        mov bx, [bp + 0x8]
        mov si, [bp + 0x6]
        mov si, [si]
        mov [bp - 0x18], si
        shl si, 1
        add si, [statsrecs]
        mov es, [statsrecsseg]
        mov ax, [es:si]
        mov [bp - 0x16], ax
        mov si, [bx]
        mov [bp - 0x1c], si
        shl si, 1
        add si, [statsrecs]
        mov cx, [es:si]
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .1
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [bp - 0x16]
        jmp near .13
        db 0x90
.1:
        cmp word [statscontext], 0x0
        jnz short .2
        imul ax, [bp - 0x18], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x28
        jmp short .3
.2:
        imul ax, [bp - 0x18], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.3:
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        cmp word [statscontext], 0x0
        jnz short .4
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        add ax, strict word 0x28
        jmp short .5
.4:
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.5:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xe], dx
        mov es, dx
        mov ax, [es:di + 0xe]
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        les bx, [bp - 0x8]
        mul word [es:bx + 0xc]
        mov es, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:di + 0xc]
        mov es, [bp - 0x6]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mul word [es:bx + 0xe]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        db 0x1B, 0xD6                           ; insn: sbb dx, si
        mov [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .7
        cmp word [bp - 0x12], 0x0
        jnl short .6
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.7:
        mov [bp - 0x10], di
        db 0x8B, 0xF3                           ; insn: mov si, bx
        les bx, [bp - 0x10]
        mov ax, [es:bx + 0xe]
        mov es, [bp - 0x6]
        cmp [es:si + 0xe], ax
        jz short .8
        mov es, [bp - 0xe]
        mov ax, [es:bx + 0xe]
        mov es, [bp - 0x6]
        sub ax, [es:si + 0xe]
        pop si
        pop di
        leave
        retf
        db 0x90
.8:
        mov es, [bp - 0xe]
        mov al, [es:bx]
        mov es, [bp - 0x6]
        cmp [es:si], al
        jz short .10
        mov es, [bp - 0xe]
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0x6]
        mov cl, [es:si]
.9:
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        pop si
        pop di
        leave
        retf
.10:
        mov es, [bp - 0xe]
        mov al, [es:bx + 0x3]
        mov cl, [es:bx + 0x1]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        shl cx, 1
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov es, [bp - 0x6]
        mov al, [es:si + 0x1]
        shl ax, 1
        mov dl, [es:si + 0x3]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov [bp - 0x12], ax
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .11
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [bp - 0x12]
        pop si
        pop di
        leave
        retf
.11:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov al, [es:si + 0x1]
        mov es, [bp - 0xe]
        cmp [es:di + 0x1], al
        jz short .12
        mov al, [es:di + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0x6]
        mov cl, [es:si + 0x1]
        jmp short .9
.12:
        mov ax, [bp - 0x18]
        sub ax, [bp - 0x1c]
.13:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpTeamPenalties                                           25E5:052E  94 PC
; Team comparator: penalty minutes (+10h)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpTeamPenalties:
        enter 0x16, 0x0
        push di
        push si
        mov bx, [bp + 0x8]
        mov si, [bp + 0x6]
        mov si, [si]
        mov [bp - 0x12], si
        shl si, 1
        add si, [statsrecs]
        mov es, [statsrecsseg]
        mov ax, [es:si]
        mov si, [bx]
        mov [bp - 0x16], si
        shl si, 1
        add si, [statsrecs]
        mov cx, [es:si]
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .2
.1:
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        pop si
        pop di
        leave
        retf
.2:
        cmp word [statscontext], 0x0
        jnz short .3
        imul ax, [bp - 0x12], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x28
        jmp short .4
.3:
        imul ax, [bp - 0x12], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.4:
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        cmp word [statscontext], 0x0
        jnz short .5
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        add ax, strict word 0x28
        jmp short .6
.5:
        imul ax, [bx], 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        add ax, strict word 0x3a
.6:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        les bx, [bp - 0xc]
        mov al, [es:bx]
        mov es, dx
        cmp [es:si], al
        jz short .8
        mov al, [es:si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0xa]
        mov cl, [es:bx]
.7:
        db 0x2A, 0xED                           ; insn: sub ch, ch
        jmp short .1
        db 0x90
.8:
        mov es, [bp - 0xa]
        mov ax, [es:bx + 0x10]
        mov es, dx
        cmp [es:si + 0x10], ax
        jz short .9
        mov es, [bp - 0xa]
        mov ax, [es:bx + 0x10]
        mov es, dx
        sub ax, [es:si + 0x10]
        pop si
        pop di
        leave
        retf
.9:
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        shl ax, 1
        mov cl, [es:si + 0x3]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, [bp - 0xa]
        mov cl, [es:bx + 0x3]
        mov dl, [es:bx + 0x1]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        shl dx, 1
        db 0x03, 0xD1                           ; insn: add dx, cx
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jz short .10
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        pop si
        pop di
        leave
        retf
        db 0x90
.10:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov al, [es:di + 0x1]
        mov es, [bp - 0x2]
        cmp [es:si + 0x1], al
        jz short .11
        mov al, [es:si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [bp - 0xa]
        mov cl, [es:di + 0x1]
        jmp short .7
.11:
        mov ax, [bp - 0x12]
        sub ax, [bp - 0x16]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TeamStatsScreen                                            25E5:064A  94 PC
; Team stats table ('Stats Unavailable')
;
; Takes 2 words of stack arguments. Calls AllocRecData, BuildPathFar, _open, LoadLeagueSchedule,
; _fstrcmp, FindUnlink, __aFlmul, __aFldiv and others.
;-----------------------------------------------------------------------------
TeamStatsScreen:
        enter 0x15e, 0x0
        push di
        push si
        push 0x0
        push 0x0
        push word 0x720
        push strict word str_Teams_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statscmpsum], ax
        mov [statscmpsum2], dx
        cmp word [bp + 0x6], 0x1
        jng short .1
        push 0x0
        push 0x0
        push 0x30
        push strict word str_Addsort_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsrecs], ax
        mov [statsrecsseg], dx
.1:
        push 0x0
        push 0x0
        mov bx, [statsseason]
        shl bx, 1
        push ds
        push word [bx + StatsDbNames3]
        push word 0x3861
        push strict word 0x0
        lea ax, [bp - 0x3e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0x3e]
        push ax
        call 0x0000:_open
        add sp, 0x4
        mov [bp - 0xca], ax
        cmp word [statsseason], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfd64
        add ax, 0x2e8
        mov [bp - 0x1e], ax
        mov word [bp - 0x1c], 0x0
        cmp word [statscontext], 0x0
        jnz short .3
        mov word [bp - 0xd4], 0x0
.2:
        mov ax, [bp - 0xd4]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov [bp + si - 0x104], ax
        inc word [bp - 0xd4]
        cmp word [bp - 0xd4], 0x18
        jl short .2
        mov word [bp - 0xd0], 0x18
        jmp near .8
.3:
        lea ax, [bp - 0x15e]
        push ax
        call 0x24E6:LoadLeagueSchedule
        add sp, 0x2
        mov ax, [bp - 0x15e]
        mov dx, [bp - 0x15c]
        add ax, 0x17a0
        mov [bp - 0x15a], ax
        mov [bp - 0x158], dx
        push word 0x3415
        push strict word postate_name
        push word 0x3861
        push strict word 0x0
        call 0x0000:_fstrcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        add word [bp - 0x15a], 0x2
.4:
        mov word [bp - 0xd4], 0x0
        mov es, [bp - 0x158]
.5:
        mov bx, [bp - 0x15a]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov si, [bp - 0xd4]
        shl si, byte 0x2
        mov [bp + si - 0x104], ax
        mov al, [es:bx + 0x3]
        mov [bp + si - 0x102], ax
        inc word [bp - 0xd4]
        add word [bp - 0x15a], 0x2a
        cmp word [bp - 0xd4], 0x8
        jl short .5
        cmp word [bp - 0x104], 0xff
        jnz short .6
        mov word [bp - 0xd0], 0x0
        jmp short .7
.6:
        mov word [bp - 0xd0], 0x10
.7:
        push word [bp - 0x15c]
        push word [bp - 0x15e]
        call 0x06E1:FindUnlink
        add sp, 0x4
.8:
        cmp word [bp - 0xd0], 0x0
        jnz short .9
        jmp near .25
.9:
        mov word [bp - 0xd4], 0x0
        jmp near .22
        db 0x90
.10:
        lea ax, [bp - 0x11a]
.11:
        mov [bp - 0xc8], ax
        mov ax, [bp + 0x6]
        dec ax
        dec ax
        jz short .13
        dec ax
        jz short .15
        dec ax
        jnz short .12
        jmp near .18
.12:
        jmp near .21
        db 0x90
.13:
        mov bx, [bp - 0xc8]
        mov ax, [bx + 0xe]
        mov [bp - 0x108], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        jmp near .19
.14:
        cwd
        push dx
        push ax
        push -0x1
        push word 0xfc18
        push 0x0
        push word [bx + 0xc]
        call 0x0000:__aFlmul
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x108]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        cwd
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        db 0x1B, 0xDA                           ; insn: sbb bx, dx
        push bx
        push cx
        call 0x0000:__aFldiv
        add ax, 0x3e8
        adc dx, 0x0
        jmp short .17
        db 0x90
.15:
        mov bx, [bp - 0xc8]
        mov ax, [bx + 0xa]
        mov [bp - 0x108], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        cwd
        push dx
        push ax
        mov ax, 0x3e8
        mul word [bx + 0x8]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x108]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        cwd
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        push bx
        push cx
.16:
        call 0x0000:__aFldiv
.17:
        mov [bp - 0xc6], ax
        mov [bp - 0xc4], dx
        jmp short .20
        db 0x90
.18:
        mov bx, [bp - 0xc8]
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x108], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        cwd
        push dx
        push ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        cwd
        mov cx, [bx + 0x10]
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x8B, 0xFB                           ; insn: mov di, bx
        shl cx, 1
        rcl bx, 1
        shl cx, 1
        rcl bx, 1
        db 0x03, 0xCE                           ; insn: add cx, si
        db 0x13, 0xDF                           ; insn: adc bx, di
        shl cx, 1
        rcl bx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        push dx
        push ax
        jmp short .16
.19:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xc4], ax
        mov [bp - 0xc6], ax
.20:
        mov bx, [bp - 0xd4]
        shl bx, 1
        les si, [statsrecs]
        mov [es:bx + si], ax
.21:
        inc word [bp - 0xd4]
.22:
        mov ax, [bp - 0xd4]
        cmp [bp - 0xd0], ax
        jng short .24
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov [bp + si - 0x70], ax
        push 0x0
        push word [bp - 0x1c]
        push word [bp - 0x1e]
        mov ax, [bp + si - 0x104]
        cwd
        push dx
        push ax
        call 0x0000:__aFlmul
        push dx
        push ax
        push word [bp - 0xca]
        call 0x0000:_lseek
        add sp, 0x8
        push 0x4c
        lea ax, [bp - 0x154]
        push ax
        push word [bp - 0xca]
        call 0x0000:_read
        add sp, 0x6
        imul bx, [bp - 0xd4], 0x4c
        les si, [statscmpsum]
        lea di, [bx + si]
        lea si, [bp - 0x154]
        mov cx, 0x26
        rep movsw
        cmp word [statscontext], 0x0
        jz short .23
        jmp near .10
.23:
        lea ax, [bp - 0x12c]
        jmp near .11
.24:
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        push word [bx + TeamStatsCmpsSeg]
        push word [bx + TeamStatsCmps]
        push 0x2
        push word [bp - 0xd0]
        lea ax, [bp - 0x70]
        push ax
        call 0x0000:_qsort
        add sp, 0xa
.25:
        push word [bp - 0xca]
        call 0x0000:_close
        add sp, 0x2
        push 0x0
        push strict word str_EasnFnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0xce], ax
        mov [bp - 0xcc], dx
        mov word [bp - 0x1a], 0x7
        lea ax, [bp - 0x18]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0xcc]
        push word [bp - 0xce]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push word 0x3701
        push strict word str_Qpp
        mov bx, [statscontext]
        shl bx, 1
        push ds
        push word [bx + StatsDbNames]
        push 0x0
        push 0x0
        lea ax, [bp - 0x3e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x3e]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Bkgd
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        mov bx, 0xa
        call 0x0FEF:SetClipRectRegs
        push word [statsbgseg]
        push word [statsbgshapes]
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x43
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        mov bx, [bp + 0x6]
        shl bx, 1
        push ds
        push word [bx + TeamStatsTitles]
        lea ax, [bp - 0xc2]
        push ss
        push ax
        call 0x2095:GetSeasonTitle
        add sp, 0x8
        lea ax, [bp - 0xc2]
        push ss
        push ax
        push 0xc
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push ds
        push strict word str_Gp_2
        mov ax, 0x14
        mov [bp - 0xd2], ax
        push ax
        push word 0xaa
        call 0x0D39:PrintShadowText
        add sp, 0x8
        mov bx, [bp + 0x6]
        shl bx, byte 0x3
        push ds
        push word [bx + TeamStatsHead1]
        push 0x14
        push word 0xc3
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x0D39:PrintShadowText
        add sp, 0x8
        push ds
        push word [si + TeamStatsHead2]
        push 0x14
        push word 0xdc
        call 0x0D39:PrintShadowText
        add sp, 0x8
        cmp word [statscontext], 0x0
        jz short .26
        cmp word [bp + 0x6], 0x1
        jz short .27
        cmp word [bp + 0x6], 0x0
        jz short .27
.26:
        mov bx, [bp + 0x6]
        shl bx, byte 0x3
        push ds
        push word [bx + TeamStatsHead3]
        push word [bp - 0xd2]
        push word 0xf5
        call 0x0D39:PrintShadowText
        add sp, 0x8
.27:
        mov bx, [bp + 0x6]
        shl bx, byte 0x3
        push ds
        push word [bx + TeamStatsHeads]
        push word [bp - 0xd2]
        push word 0x10e
        call 0x0D39:PrintShadowText
        add sp, 0x8
        mov word [bp - 0x40], 0x1
        add word [bp - 0xd2], 0xa
        cmp word [bp - 0xd0], 0x0
        jnz short .28
        push ds
        push strict word str_StatsUnavailable_2
        push 0x5f
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
.28:
        mov word [bp - 0xd4], 0x0
        jmp short .32
.29:
        lea ax, [bp - 0x11a]
.30:
        mov [bp - 0xc8], ax
        cmp word [statsseason], 0x0
        jnz short .34
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx], 0x0
        jnz short .34
.31:
        inc word [bp - 0xd4]
.32:
        mov ax, [bp - 0xd4]
        cmp [bp - 0xd0], ax
        jg short .33
        jmp near .50
.33:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov ax, [bp + si - 0x70]
        mov [bp - 0x108], ax
        imul ax, ax, 0x4c
        add ax, [statscmpsum]
        mov dx, [statscmpsum2]
        push ds
        lea di, [bp - 0x154]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push ss
        pop es
        mov ds, dx
        mov cx, 0x26
        rep movsw
        pop ds
        cmp word [statscontext], 0x0
        jnz short .29
        lea ax, [bp - 0x12c]
        jmp short .30
        db 0x90
.34:
        push word [bp - 0x40]
        inc word [bp - 0x40]
        push strict word str_2d
        push word [bp - 0xd2]
        push 0x28
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        lea ax, [bp - 0x14f]
        push ss
        push ax
        push word [bp - 0xd2]
        push 0x37
        call 0x0D39:PrintShadowText
        add sp, 0x8
        mov bx, [bp - 0xc8]
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xaa
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov ax, [bp + 0x6]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .39
        dec ax
        jnz short .35
        jmp near .43
.35:
        dec ax
        jnz short .36
        jmp near .45
.36:
        dec ax
        jnz short .37
        jmp near .48
.37:
        dec ax
        jnz short .38
        jmp near .49
.38:
        jmp short .42
        db 0x90
.39:
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xc3
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xdc
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        cmp word [statscontext], 0x0
        jnz short .40
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xf5
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
.40:
        mov bx, [bp - 0xc8]
        push word [bx + 0x4]
.41:
        push strict word str_3d
        push word [bp - 0xd2]
        push word 0x10e
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
.42:
        mov ax, [bp - 0x1a]
        add [bp - 0xd2], ax
        jmp near .31
.43:
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xc3
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xdc
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        cmp word [statscontext], 0x0
        jnz short .44
        mov bx, [bp - 0xc8]
        mov al, [bx + 0x3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0xd2]
        push word 0xf5
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
.44:
        mov bx, [bp - 0xc8]
        push word [bx + 0x6]
        jmp near .41
        db 0x90
.45:
        mov bx, [bp - 0xc8]
        push word [bx + 0xe]
        push strict word str_3d
        push word [bp - 0xd2]
        push word 0xc3
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0xc8]
        push word [bx + 0xc]
        push strict word str_4d
.46:
        push word [bp - 0xd2]
        push word 0xdc
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x108]
        shl bx, 1
        les si, [statsrecs]
        mov ax, [es:bx + si]
        mov cx, 0xa
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push strict word str_3d1d
        push word [bp - 0xd2]
        push word 0xf5
.47:
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        jmp near .42
        db 0x90
.48:
        mov bx, [bp - 0xc8]
        push word [bx + 0xa]
        push strict word str_3d
        push word [bp - 0xd2]
        push word 0xc3
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0xc8]
        push word [bx + 0x8]
        push strict word str_3d
        jmp short .46
        db 0x90
.49:
        mov bx, [bp - 0xc8]
        push word [bx + 0x10]
        push strict word str_3d
        push word [bp - 0xd2]
        push word 0xc3
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x108]
        shl bx, 1
        les si, [statsrecs]
        mov ax, [es:bx + si]
        mov cx, 0xa
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push strict word str_3d1d
        push word [bp - 0xd2]
        push word 0xdc
        jmp short .47
        db 0x90
.50:
        lea ax, [bp - 0x18]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0xcc]
        push word [bp - 0xce]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [bp + 0x6], 0x1
        jng short .51
        push word [statsrecsseg]
        push word [statsrecs]
        call 0x06E1:FindUnlink
        add sp, 0x4
.51:
        push word [statscmpsum2]
        push word [statscmpsum]
        call 0x06E1:FindUnlink
