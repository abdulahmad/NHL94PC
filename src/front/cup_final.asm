; Stanley Cup final series: loads it and finds the winner (GAME.OVL)

;-----------------------------------------------------------------------------
; LoadCupFinalSeries                                         1E45:0000  94 PC
; Allocs 0x2A-byte series record from the db file when both teams are playoff teams.
;
; Calls AllocRecData, LoadScheduleDBThunk, FindUnlink. Far routine (retf).
;-----------------------------------------------------------------------------
LoadCupFinalSeries:
        enter 0x6, 0x0
        push di
        push si
        mov ax, 0x3415
        mov es, ax
        mov si, [HomeTeamNum]
        shl si, 1
        mov ax, [es:si + POSeedTable]
        mov si, [VisTeamNum]
        shl si, 1
        or ax, [es:si + POSeedTable]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        test al, 0xc
        jnz short .1
        jmp near .6
.1:
        test bl, 0x3
        jnz short .2
        jmp near .6
.2:
        push 0x0
        push 0x0
        push 0x2a
        push word 0x2962
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_CFFC], ax
        mov [g_CFFE], dx
        lea ax, [bp - 0x6]
        push ax
        call 0x1B35:LoadScheduleDBThunk
        add sp, 0x2
        cmp word [DbSaveMode], 0x2
        jnz short .3
        mov ax, [bp - 0x6]
        inc ax
        inc ax
        mov [bp - 0x6], ax
.3:
        mov word [bp - 0x2], 0x0
        mov es, [g_CFFE]
.4:
        mov bx, [g_CFFC]
        mov si, [bp - 0x2]
        mov ax, [bp - 0x6]
        mov dx, [bp - 0x4]
        db 0x03, 0xC6                           ; insn: add ax, si
        add ax, 0x19ec
        push ds
        lea di, [bx + si]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        movsw
        movsw
        movsw
        pop ds
        add word [bp - 0x2], 0x6
        cmp word [bp - 0x2], 0x2a
        jl short .4
        cmp word [DbSaveMode], 0x2
        jnz short .5
        mov ax, [bp - 0x6]
        dec ax
        dec ax
        mov [bp - 0x6], ax
.5:
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_CFFE], ax
        mov [g_CFFC], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; IsCupClinched                                              1E45:00C2  94 PC
; Appends the game score to the series list, 1 when CupSeriesWinner decides it.
;
; Takes 2 words of stack arguments. Calls CupSeriesWinner. Far routine (retf).
;-----------------------------------------------------------------------------
IsCupClinched:
        enter 0x4, 0x0
        push di
        push si
        mov ax, [g_CFFE]
        or ax, [g_CFFC]
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        db 0x2B, 0xFF                           ; insn: sub di, di
        les bx, [g_CFFC]
        cmp byte [es:bx + 0x4], 0xff
        jz short .4
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, es
        add ax, strict word 0x4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
        mov es, [bp - 0x2]
.3:
        inc di
        add bx, 0x6
        cmp byte [es:bx], 0xff
        jnz short .3
.4:
        mov al, [bp + 0x6]
        db 0x8B, 0xCF                           ; insn: mov cx, di
        shl di, 1
        db 0x03, 0xF9                           ; insn: add di, cx
        shl di, 1
        les bx, [g_CFFC]
        mov [es:bx + di + 0x4], al
        mov al, [bp + 0x8]
        les bx, [g_CFFC]
        mov [es:bx + di + 0x5], al
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [g_CFFE]
        push word [g_CFFC]
        push cs
        call CupSeriesWinner
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        les bx, [g_CFFC]
        mov byte [es:bx + di + 0x5], 0xff
        add di, [g_CFFC]
        mov es, [g_CFFE]
        mov al, [es:di + 0x5]
        mov [es:di + 0x4], al
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .5
        jmp near .1
.5:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CupSeriesWinner                                            1E45:015E  94 PC
; Counts wins per side in the series list against games to win.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CupSeriesWinner:
        enter 0x8, 0x0
        push di
        push si
        lds si, [bp + 0x6]
        mov di, [bp + 0xa]
        mov al, [si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x2], ax
        mov al, [si + 0x3]
        mov [bp - 0x4], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x8], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shr ax, 1
        inc ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .2
.1:
        mov ax, DGROUP
        mov ds, ax
        mov ax, [bp - 0x8]
        cmp [bp - 0x6], ax
        jnl short .9
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        mov cx, [bp - 0x2]
        mov [bp + 0xa], di
.3:
        cmp [bp - 0x6], di
        jnc short .1
        cmp byte [si + 0x4], 0xff
        jz short .8
        mov al, [si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jnz short .6
        mov al, [si + 0x5]
        cmp [si + 0x4], al
        jna short .7
.4:
        inc word [bp - 0x8]
.5:
        add si, 0x6
        cmp [bp - 0x8], di
        jc short .3
        jmp short .1
        db 0x90
.6:
        mov al, [si + 0x5]
        cmp [si + 0x4], al
        jna short .4
.7:
        inc word [bp - 0x6]
        jmp short .5
        db 0x90
.8:
        mov ax, DGROUP
        mov ds, ax
        mov ax, 0xffff
        pop si
        pop di
        leave
        retf
.9:
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
