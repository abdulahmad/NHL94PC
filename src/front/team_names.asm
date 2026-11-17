; Puts the team names into the menu text, or blanks them (INIT.OVL)
; The first bytes finish the last routine of scoreboard_init.asm.
        push word [g_C258]
        call 0x03A3:FindFarList
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetTeamNameText                                            252F:000E  94 PC
; Team names into the menu text.
;
; Calls _fstrcpy, _strncpy, TextWidthAll. Far routine (retf).
;-----------------------------------------------------------------------------
SetTeamNameText:
        enter 0x30, 0x0
        push di
        push si
        mov word [bp - 0x8], f_3448_12F0
        mov word [bp - 0x6], 0x3448
        mov al, [g_AE34]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul si, ax, 0x28
        add si, 0xa550
        mov es, [g_8CC2]
        push word [es:0x12fa]
        push word [es:0x12f8]
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp byte [si + 0x6], 0xa
        jnc short .1
        mov al, [bp - 0x27]
        mov [bp - 0x26], al
        jmp short .2
        db 0x90
.1:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x26], al
.2:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x25], ah
        mov al, [si + 0x8]
        mov [bp - 0x23], al
        push 0x10
        lea ax, [si + 0x18]
        push ax
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strncpy
        add sp, 0x6
        lea ax, [bp - 0x28]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        add ax, strict word 0x5
        mov bx, 0x12f0
        mov es, [g_8CC2]
        mov [es:bx + 0x4], ax
        lea ax, [bp - 0x28]
        push ss
        push ax
        push word [es:bx + 0xa]
        push word [es:bx + 0x8]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov [bp - 0x2c], di
        mov [bp - 0x2a], es
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov al, [g_AE35]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul si, ax, 0x28
        add si, 0xa550
        les bx, [bp - 0x2c]
        push word [es:bx + 0x20]
        push word [es:bx + 0x1e]
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp byte [si + 0x6], 0xa
        jnc short .3
        mov al, [bp - 0x27]
        mov [bp - 0x26], al
        jmp short .4
        db 0x90
.3:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x26], al
.4:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x25], ah
        mov al, [si + 0x8]
        mov [bp - 0x23], al
        push 0x10
        lea ax, [si + 0x18]
        push ax
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strncpy
        add sp, 0x6
        lea ax, [bp - 0x28]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        add ax, strict word 0x5
        mov bx, 0x12f0
        mov es, [g_8CC2]
        mov [es:bx + 0x1a], ax
        lea ax, [bp - 0x28]
        push ss
        push ax
        push word [es:bx + 0x20]
        push word [es:bx + 0x1e]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov di, es
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, di
        mov ax, [es:si + 0x1a]
        cmp [es:si + 0x4], ax
        jng short .5
        mov ax, 0x3448
        mov es, ax
        mov bx, 0x12f0
        mov ax, [es:bx + 0x4]
        mov [es:bx + 0x30], ax
        mov [es:bx + 0x1a], ax
        jmp short .6
        db 0x90
.5:
        mov bx, 0x12f0
        mov es, [g_8CC2]
        mov ax, [es:bx + 0x1a]
        mov [es:bx + 0x30], ax
        mov [es:bx + 0x4], ax
.6:
        cmp word [hmtmgoalie], 0x0
        jnl short .7
        mov es, [g_8CC2]
        les bx, [es:0x1324]
        jmp short .8
        db 0x90
.7:
        mov es, [g_8CC2]
        imul bx, [hmtmgoalie], 0x16
        les bx, [es:bx + 0x12f8]
.8:
        mov byte [es:bx], 0x1
        mov word [bp - 0x8], f_3448_1332
        mov word [bp - 0x6], 0x3448
        mov al, [g_AE64]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul si, ax, 0x28
        add si, 0xa9b0
        mov es, [g_8CC4]
        push word [es:0x133c]
        push word [es:0x133a]
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp byte [si + 0x6], 0xa
        jnc short .9
        mov al, [bp - 0x27]
        mov [bp - 0x26], al
        jmp short .10
        db 0x90
.9:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x26], al
.10:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x25], ah
        mov al, [si + 0x8]
        mov [bp - 0x23], al
        push 0x10
        lea ax, [si + 0x18]
        push ax
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strncpy
        add sp, 0x6
        lea ax, [bp - 0x28]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        add ax, strict word 0x5
        mov bx, 0x1332
        mov es, [g_8CC4]
        mov [es:bx + 0x4], ax
        lea ax, [bp - 0x28]
        push ss
        push ax
        push word [es:bx + 0xa]
        push word [es:bx + 0x8]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov [bp - 0x30], di
        mov [bp - 0x2e], es
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov al, [g_AE65]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul si, ax, 0x28
        add si, 0xa9b0
        les bx, [bp - 0x30]
        push word [es:bx + 0x20]
        push word [es:bx + 0x1e]
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp byte [si + 0x6], 0xa
        jnc short .11
        mov al, [bp - 0x27]
        mov [bp - 0x26], al
        jmp short .12
        db 0x90
.11:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x26], al
.12:
        mov al, [si + 0x6]
        mov cl, 0xa
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div cl
        add [bp - 0x25], ah
        mov al, [si + 0x8]
        mov [bp - 0x23], al
        push 0x10
        lea ax, [si + 0x18]
        push ax
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strncpy
        add sp, 0x6
        lea ax, [bp - 0x28]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        add ax, strict word 0x5
        mov bx, 0x1332
        mov es, [g_8CC4]
        mov [es:bx + 0x1a], ax
        lea ax, [bp - 0x28]
        push ss
        push ax
        push word [es:bx + 0x20]
        push word [es:bx + 0x1e]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov di, es
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, di
        mov ax, [es:si + 0x1a]
        cmp [es:si + 0x4], ax
        jng short .13
        mov ax, 0x3448
        mov es, ax
        mov bx, 0x1332
        mov ax, [es:bx + 0x4]
        mov [es:bx + 0x30], ax
        mov [es:bx + 0x1a], ax
        jmp short .14
        db 0x90
.13:
        mov bx, 0x1332
        mov es, [g_8CC4]
        mov ax, [es:bx + 0x1a]
        mov [es:bx + 0x30], ax
        mov [es:bx + 0x4], ax
.14:
        cmp word [awtmgoalie], 0x0
        jnl short .15
        mov es, [g_8CC4]
        les bx, [es:0x1366]
        jmp short .16
        db 0x90
.15:
        mov es, [g_8CC4]
        imul bx, [awtmgoalie], 0x16
        les bx, [es:bx + 0x133a]
.16:
        mov byte [es:bx], 0x1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ClearTeamNameText                                          252F:0348  94 PC
; Blanks the team name strings.
;
; Calls _fstrcpy.
;-----------------------------------------------------------------------------
ClearTeamNameText:
        push word 0x3448
        push strict word f_3448_026B
        mov es, [g_8CC2]
        push word [es:0x12fa]
        push word [es:0x12f8]
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3448
        push strict word f_3448_026B
        mov es, [g_8CC2]
        push word [es:0x1310]
        push word [es:0x130e]
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [g_8CC2]
        les bx, [es:0x1324]
        mov byte [es:bx], 0x2
        push word 0x3448
        push strict word f_3448_026B
        mov es, [g_8CC4]
        push word [es:0x133c]
        push word [es:0x133a]
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3448
        push strict word f_3448_026B
        mov es, [g_8CC4]
        push word [es:0x1352]
        push word [es:0x1350]
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [g_8CC4]
        les bx, [es:0x1366]
        mov byte [es:bx], 0x2
