; Takes a player out of a team's lines (LP.OVL)
; The first bytes finish the last routine of home_pals.asm.
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ClearPlayerFromLines                                       1EAE:000A  94 PC
; Removes a player from every line slot.
;
; Takes 4 words of stack arguments.
;-----------------------------------------------------------------------------
ClearPlayerFromLines:
        enter 0x2, 0x0
        push di
        push si
        mov es, [bp + 0xa]
        mov ax, [bp + 0x8]
        mov cx, es
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ds, cx
        mov cx, 0x4
        mov si, [bp - 0x2]
.1:
        mov al, [bp + 0x6]
        cmp [di], al
        jnz short .2
        mov byte [di], 0x64
        jmp short .4
.2:
        mov al, [bp + 0x6]
        cmp [di + 0x1], al
        jnz short .3
        mov byte [di + 0x1], 0x64
        jmp short .4
.3:
        mov al, [bp + 0x6]
        cmp [di + 0x2], al
        jnz short .4
        mov byte [di + 0x2], 0x64
.4:
        add di, 0x3
        loop .1
        mov ax, [bp + 0x8]
        mov dx, es
        add ax, strict word 0xc
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ds, dx
        mov cx, 0x3
        mov si, [bp - 0x2]
.5:
        mov al, [bp + 0x6]
        cmp [di], al
        jnz short .6
        mov byte [di], 0x64
        jmp short .7
        db 0x90
.6:
        mov al, [bp + 0x6]
        cmp [di + 0x1], al
        jnz short .7
        mov byte [di + 0x1], 0x64
.7:
        inc di
        inc di
        loop .5
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x8]
        mov al, [bp + 0x6]
        cmp [es:si + 0x12], al
        jnz short .8
        mov byte [es:si + 0x12], 0x64
        jmp short .12
.8:
        mov al, [bp + 0x6]
        cmp [es:si + 0x13], al
        jnz short .9
        mov byte [es:si + 0x13], 0x64
        jmp short .12
.9:
        mov al, [bp + 0x6]
        cmp [es:si + 0x14], al
        jnz short .10
        mov byte [es:si + 0x14], 0x64
        jmp short .12
.10:
        mov al, [bp + 0x6]
        cmp [es:si + 0x15], al
        jnz short .11
        mov byte [es:si + 0x15], 0x64
        jmp short .12
.11:
        mov al, [bp + 0x6]
        cmp [es:si + 0x16], al
        jnz short .12
        mov byte [es:si + 0x16], 0x64
.12:
        mov al, [bp + 0x6]
        cmp [es:si + 0x17], al
        jnz short .13
        mov byte [es:si + 0x17], 0x64
        jmp short .17
.13:
        mov al, [bp + 0x6]
        cmp [es:si + 0x18], al
        jnz short .14
        mov byte [es:si + 0x18], 0x64
        jmp short .17
.14:
        mov al, [bp + 0x6]
        cmp [es:si + 0x19], al
        jnz short .15
        mov byte [es:si + 0x19], 0x64
        jmp short .17
.15:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1a], al
        jnz short .16
        mov byte [es:si + 0x1a], 0x64
        jmp short .17
.16:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1b], al
        jnz short .17
        mov byte [es:si + 0x1b], 0x64
.17:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1c], al
        jnz short .18
        mov byte [es:si + 0x1c], 0x64
        jmp short .21
.18:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1d], al
        jnz short .19
        mov byte [es:si + 0x1d], 0x64
        jmp short .21
.19:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1e], al
        jnz short .20
        mov byte [es:si + 0x1e], 0x64
        jmp short .21
.20:
        mov al, [bp + 0x6]
        cmp [es:si + 0x1f], al
        jnz short .21
        mov byte [es:si + 0x1f], 0x64
.21:
        mov al, [bp + 0x6]
        cmp [es:si + 0x20], al
        jnz short .22
        mov byte [es:si + 0x20], 0x64
        jmp short .25
.22:
        mov al, [bp + 0x6]
        cmp [es:si + 0x21], al
        jnz short .23
        mov byte [es:si + 0x21], 0x64
        jmp short .25
.23:
        mov al, [bp + 0x6]
        cmp [es:si + 0x22], al
        jnz short .24
        mov byte [es:si + 0x22], 0x64
        jmp short .25
.24:
        mov al, [bp + 0x6]
        cmp [es:si + 0x23], al
        jnz short .25
        mov byte [es:si + 0x23], 0x64
.25:
        mov al, [bp + 0x6]
        cmp [es:si + 0x24], al
        jnz short .26
        mov byte [es:si + 0x24], 0x64
.26:
        mov al, [bp + 0x6]
        cmp [es:si + 0x25], al
        jnz short .27
        mov byte [es:si + 0x25], 0x64
.27:
        mov al, [bp + 0x6]
        cmp [es:si + 0x26], al
        jnz short .28
        mov byte [es:si + 0x26], 0x64
.28:
        mov al, [bp + 0x6]
        cmp [es:si + 0x27], al
        jnz short ClearPlayerFromLinesTail + 0x1D0
        mov byte [es:si + 0x27], 0x64
