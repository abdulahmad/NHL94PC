; Plays or simulates the day's league games and updates the calendar (LP.OVL)

;-----------------------------------------------------------------------------
; SimulateGameTail                                           25B2:0001  94 PC
; The rest of SimulateGame, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
SimulateGameTail:
        mov ax, [bp - 0x16c]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawCalendarDay                                            25B2:000A  94 PC
; One calendar day: Home/Away game.
;
; Takes 9 words of stack arguments. Calls FillRect, _fmemcpy, SetRemapTable, DrawRleTransRemapFastAt,
; DrawLine, DrawText, SaveCharTab, UseCharSeg and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawCalendarDay:
        enter 0x48, 0x0
        push di
        push si
        mov di, [bp + 0x12]
        mov byte [bp - 0x44], 0x21
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov bx, [bx + CrestShapeNames]
        mov al, [bx]
        mov [bp - 0x43], al
        mov al, [bx + 0x1]
        mov [bp - 0x42], al
        mov al, [bx + 0x2]
        mov [bp - 0x41], al
        push 0x0
        push word 0xbe
        push word 0x140
        push 0xa
        push 0x0
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x7d
        push word 0x9c
        push word 0x13b
        push 0x27
        push 0x2
        call 0x0FEF:FillRect
        add sp, 0xa
        push word 0x100
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        add ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        add ax, 0x180
        push dx
        push ax
        push word 0x3a0b
        push strict word MenuRemap
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov es, [segWorkBuffer19]
        mov byte [es:MenuRemap + 0x43], 0x79
        push word 0x3a0b
        push strict word MenuRemap
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0xf
        push 0x4
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, byte 0x2
        mov si, [bp + 0x8]
        push word [bx + si + 0x2]
        push word [bx + si]
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
        mov word [bp - 0x2], 0x27
        mov si, [bp - 0x2]
.1:
        push 0x0
        push si
        push word 0x13d
        push si
        push 0x2
        call 0x0FEF:DrawLine
        add sp, 0xa
        add si, 0x1a
        cmp si, 0xdd
        jl short .1
        mov si, 0x2
.2:
        push 0x0
        push word 0xc3
        push si
        push 0x27
        push si
        call 0x0FEF:DrawLine
        add sp, 0xa
        add si, 0x2d
        cmp si, 0x16a
        jl short .2
        mov bx, [bp + 0x6]
        cmp byte [bx + MonthStartDay], 0x0
        jz short .3
        mov word [bp - 0x2], 0x4
        mov word [bp - 0x4], 0x29
        jmp short .4
.3:
        mov word [bp - 0x2], 0x112
        mov word [bp - 0x4], 0xab
.4:
        les bx, [FontPtr]
        mov word [es:bx], 0xf5
        push word [bp - 0x4]
        push word [bp - 0x2]
        push strict word str_Home
        call 0x0FEF:DrawText
        add sp, 0x6
        les bx, [FontPtr]
        mov word [es:bx], 0xf6
        mov ax, [bp - 0x4]
        add ax, strict word 0x8
        push ax
        push word [bp - 0x2]
        push strict word str_Away
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [bp - 0x24]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp + 0x16]
        push word [bp + 0x14]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        les bx, [FontPtr]
        mov word [es:bx], 0x7d
        mov es, [segTeamChoiceText28]
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        push word [es:bx + MonthNameList + 0x2]
        push word [es:bx + MonthNameList]
        lea ax, [bp - 0x44]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_199
        lea si, [bp - 0x44]
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        cmp word [bp + 0x6], 0x9
        jl short .5
        mov di, 0x18ad
        jmp short .6
.5:
        mov di, 0x18af
.6:
        lea si, [bp - 0x44]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        push 0xf
        lea ax, [bp - 0x44]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0xdc
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, strict word 0x32
        push ax
        lea ax, [bp - 0x44]
        push ax
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [bp - 0x24]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        mov word [bp - 0xc], 0xffff
        mov word [bp - 0xa], 0x0
        cmp word [bp + 0x10], 0x0
        jg short .7
        jmp near .20
.7:
        mov si, [bp + 0xe]
        inc si
        inc si
.8:
        mov al, [si - 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [bp + 0x6]
        dec ax
        jz short .9
        jmp near .19
.9:
        mov bx, [bp + 0x6]
        mov al, [bx + MonthStartDay]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, [si - 0x1]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        dec ax
        mov cx, 0x7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        imul di, dx, 0x2d
        add di, 0x4
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        imul ax, ax, 0x1a
        add ax, strict word 0x29
        mov [bp - 0x4], ax
        mov al, [si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0x12]
        jnz short .10
        mov word [bp - 0x8], 0xf5
        mov al, [si + 0x1]
        jmp short .11
        db 0x90
.10:
        mov word [bp - 0x8], 0xf6
        mov al, [si]
.11:
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x6], ax
        push word [bp - 0x8]
        push 0x19
        push 0x2c
        mov ax, [bp - 0x4]
        dec ax
        push ax
        lea ax, [di - 0x1]
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        push word 0x100
        mov ah, [bp - 0x6]
        db 0x2A, 0xC0                           ; insn: sub al, al
        add ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        add ax, 0x180
        push dx
        push ax
        push word 0x3a0b
        push strict word MenuRemap
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov es, [segWorkBuffer19]
        mov byte [es:MenuRemap + 0x43], 0x79
        push word 0x3a0b
        push strict word MenuRemap
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push word [bp - 0x4]
        add di, 0xa
        push di
        mov bx, [bp - 0x6]
        shl bx, byte 0x2
        add bx, [bp + 0x8]
        push word [bx + 0x2]
        push word [bx]
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
        cmp byte [si + 0x2], 0xff
        jnz short .12
        cmp byte [si + 0x3], 0xff
        jz short .18
.12:
        add di, 0x6
        inc word [bp - 0x4]
        mov word [bp - 0x6], 0xf8
        mov al, [si + 0x3]
        cmp [si + 0x2], al
        jna short .14
        mov al, [bp + 0x12]
        cmp [si], al
        jz short .15
.13:
        mov ax, 0xf7
        jmp short .16
        db 0x90
.14:
        mov al, [si + 0x3]
        cmp [si + 0x2], al
        jnc short .17
        mov al, [bp + 0x12]
        cmp [si], al
        jz short .13
.15:
        mov ax, 0xf9
.16:
        mov [bp - 0x6], ax
.17:
        push 0x3
        push word [bp - 0x6]
        mov ax, [bp - 0x4]
        add ax, strict word 0x14
        push ax
        lea cx, [di + 0x14]
        push cx
        push word [bp - 0x4]
        push di
        mov [bp - 0x46], ax
        mov [bp - 0x48], cx
        call 0x1491:DrawThickLine
        add sp, 0xc
        push 0x3
        push word [bp - 0x6]
        push word [bp - 0x46]
        push di
        push word [bp - 0x4]
        push word [bp - 0x48]
        call 0x1491:DrawThickLine
        add sp, 0xc
.18:
        mov al, [si - 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [calcursor]
        jnz short .19
        mov al, [si - 0x1]
        cmp ax, [calcursor2]
        jnz short .19
        mov ax, [bp - 0xa]
        mov [bp - 0xc], ax
.19:
        add si, 0x6
        mov ax, [bp + 0x10]
        inc word [bp - 0xa]
        cmp [bp - 0xa], ax
        jnl short .20
        jmp near .8
.20:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov bx, [bp + 0x6]
        cmp byte [bx + MonthDays], 0x0
        jz short .22
        db 0x8B, 0xFB                           ; insn: mov di, bx
.21:
        mov al, [di + MonthStartDay]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x03, 0xC6                           ; insn: add ax, si
        mov cx, 0x7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        imul ax, dx, 0x2d
        add ax, strict word 0x4
        mov [bp - 0x2], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        imul ax, ax, 0x1a
        add ax, strict word 0x29
        mov [bp - 0x4], ax
        les bx, [FontPtr]
        mov word [es:bx], 0x0
        lea ax, [si + 0x1]
        push ax
        push word 0x18b1
        lea cx, [bp - 0x44]
        push cx
        call 0x0000:_sprintf
        add sp, 0x6
        push word [bp - 0x4]
        push word [bp - 0x2]
        lea ax, [bp - 0x44]
        push ax
        call 0x0FEF:DrawText
        add sp, 0x6
        mov al, [di + MonthDays]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        lea cx, [si + 0x1]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jg short .21
.22:
        mov si, [bp + 0x6]
        mov di, [bp - 0xc]
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .23
        jmp near .24
.23:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl di, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        shl di, 1
        mov bx, [bp + 0xe]
        mov al, [bx + di + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, [si + MonthStartDay]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        dec ax
        mov cx, 0x7
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        imul ax, dx, 0x2d
        inc ax
        inc ax
        mov [bp - 0x2], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        imul ax, ax, 0x1a
        add ax, strict word 0x27
        mov [bp - 0x4], ax
        lea cx, [bx + 0x2e]
        mov [bp - 0x8], cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        add ax, strict word 0x1b
        mov [bp - 0x6], ax
        push 0x1
        push word 0xfa
        push dx
        push cx
        push dx
        lea ax, [bx - 0x1]
        push ax
        call 0x1491:DrawThickLine
        add sp, 0xc
        push 0x1
        push word 0xfa
        push word [bp - 0x6]
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0x2]
        call 0x1491:DrawThickLine
        add sp, 0xc
        push 0x1
        push word 0xfa
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word [bp - 0x4]
        push word [bp - 0x8]
        call 0x1491:DrawThickLine
        add sp, 0xc
        push 0x1
        push word 0xfa
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word [bp - 0x6]
        mov ax, [bp - 0x2]
        dec ax
        push ax
        call 0x1491:DrawThickLine
        add sp, 0xc
.24:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CalNextMonth                                               25B2:04C4  94 PC
; Menu item: next month.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
CalNextMonth:
        mov ax, 0x3701
        mov es, ax
        mov word [es:CalNextMonthFn], 0x200d
        mov word [es:CalNextMonthSeg], 0x1b35
        mov word [es:CalPrevMonthFn], 0x2017
        mov word [es:CalPrevMonthSeg], 0x1b35
        inc word [calmonth]
        cmp word [calmonth], 0xc
        jnz short .1
        mov word [calmonth], 0x0
.1:
        cmp word [calmonth], 0x6
        jnz short .2
        mov word [calmonth], 0x5
.2:
        cmp word [calmonth], 0x5
        jnz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:CalNextMonthSeg], ax
        mov [es:CalNextMonthFn], ax
.3:
        mov word [calday], 0xffff
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalPrevMonth                                               25B2:051C  94 PC
; Menu item: previous month.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
CalPrevMonth:
        mov ax, 0x3701
        mov es, ax
        mov word [es:CalNextMonthFn], 0x200d
        mov word [es:CalNextMonthSeg], 0x1b35
        mov word [es:CalPrevMonthFn], 0x2017
        mov word [es:CalPrevMonthSeg], 0x1b35
        dec word [calmonth]
        cmp word [calmonth], -0x1
        jnz short .1
        mov word [calmonth], 0xb
.1:
        cmp word [calmonth], 0x8
        jnz short .2
        mov word [calmonth], 0x9
.2:
        cmp word [calmonth], 0x9
        jnz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:CalPrevMonthSeg], ax
        mov [es:CalPrevMonthFn], ax
.3:
        mov word [calday], 0xffff
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalReturn                                                  25B2:0574  94 PC
; Menu item: return.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
CalReturn:
        mov ax, 0xffff
        mov [calresult], ax
        mov [calday], ax
        retf

;-----------------------------------------------------------------------------
; ApplyShapePalette                                          25B2:057E  94 PC
; Lineditp palette and crests.
;
; Calls BuildPathFar, LoadPackedHeader, FindFarMsg, FindUnlink, LoadRawHeader, FadePaletteInThunk. Far
; routine (retf).
;-----------------------------------------------------------------------------
ApplyShapePalette:
        enter 0x330, 0x0
        push di
        push si
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Lineditp_4
        push 0x0
        push 0x0
        lea ax, [bp - 0x30]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_42
        push 0x0
        lea ax, [bp - 0x30]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov es, [statsbgseg]
.1:
        mov bx, [statsbgshapes]
        add bx, 0x10
        mov al, [es:bx + si]
        mov [bp + si - 0x330], al
        inc si
        cmp si, 0x300
        jl short .1
        push word [bp - 0xe]
        push word [bp - 0x10]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push strict word str_Crests4Bin_2
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xa], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0xc], di
        mov es, dx
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0x330], al
        inc si
        cmp si, 0x15f
        jl short .2
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov cx, [bp - 0xc]
.3:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x2], di
.4:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + ShapePaletteMap]
        lea dx, [bp - 0x51]
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov [bx], al
        inc si
        cmp si, 0x3
        jl short .4
        add di, 0x3
        cmp di, 0x1e
        jl short .3
        mov di, [bp - 0xc]
        push 0x10
        lea ax, [bp - 0x330]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0xa]
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetGameSides                                               25B2:0668  94 PC
; Home / away of the human teams.
;
; Takes 3 words of stack arguments. Calls SetCtlTeamsThunk. Far routine (retf).
;-----------------------------------------------------------------------------
SetGameSides:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0x8]
        mov si, [bp + 0xa]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDE                           ; insn: add bx, si
        shl bx, 1
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bp - 0x8], bx
        mov al, [bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x6], ax
        cmp ax, [bp + 0x6]
        jnz short .1
        mov [bp - 0x4], ax
        mov al, [bx + 0x3]
        jmp short .2
.1:
        mov al, [bx + 0x3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x4], ax
        mov ax, [bp - 0x6]
.2:
        mov [bp - 0x2], ax
        mov es, [segWorkBuffer20]
        imul bx, ax, 0x1e
        cmp byte [es:bx + leagueinfo_teams + 0x17], 0x1
        jz short .3
        mov word [bp - 0x2], 0xffff
.3:
        mov bx, [bp - 0x8]
        mov al, [bx + 0x3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bp - 0x6]
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x1B35:SetCtlTeamsThunk
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CalendarScreen                                             25B2:06D6  94 PC
; The league calendar.
;
; Takes 5 words of stack arguments. Calls UseCurrentPage, ClearClipRect, SetDialogColors,
; LoadRawHeader, BuildPathFar, LoadPackedHeader, FindFarMsg, SetPaletteFar and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
CalendarScreen:
        enter 0x48e, 0x0
        push di
        push si
        mov word [bp - 0x28], 0xffff
        call 0x0FEF:UseCurrentPage
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x5c], ax
        push ax
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        mov word [teamstatscb], 0x26a7
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x269d
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x2693
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x2689
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x267f
        mov word [menucbseg], 0x1b35
        push 0x0
        mov ax, 0x7d
        mov [bp - 0x6], ax
        push ax
        mov ax, 0x7b
        mov [bp - 0x60], ax
        push ax
        push 0x7d
        mov ax, 0x7c
        mov [bp - 0x68], ax
        push ax
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x0
        push strict word str_Ftimes24Fnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        mov word [calday], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xe4], ax
        mov [bp - 0x26], ax
        mov [calresult], ax
        mov [statspalshape], ax
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Lineditp_3
        push ax
        push ax
        lea ax, [bp - 0x4c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_41
        push 0x0
        lea ax, [bp - 0x4c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0xf0], ax
        mov [bp - 0xee], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0xea], ax
        mov [bp - 0xe8], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [bp - 0xee]
        push word [bp - 0xf0]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push strict word str_Crests4Bin
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x2c], ax
        mov [bp - 0x2a], dx
        push dx
        push ax
        push 0x75
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov word [bp - 0xde], 0x0
.1:
        mov ax, [bp - 0xde]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, ShapePaletteMap
        push ds
        push ax
        push 0x1
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add ax, 0xf5
        push ax
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        inc word [bp - 0xde]
        cmp word [bp - 0xde], 0xa
        jl short .1
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Crests4_5
        push 0x0
        push 0x0
        lea ax, [bp - 0x4c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x4c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x24], ax
        mov [bp - 0x22], dx
        mov word [bp - 0xde], 0x0
.2:
        mov bx, [bp - 0xde]
        shl bx, 1
        push word [bx + CrestShapeNames]
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0xca], ax
        mov [bp + si - 0xc8], dx
        inc word [bp - 0xde]
        cmp word [bp - 0xde], 0x18
        jl short .2
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x4c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x28]
        push ax
        lea cx, [bp - 0x4c]
        push cx
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0xe4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push 0x2
        push ax
        push ax
        lea ax, [bp - 0xdc]
        push ss
        push ax
        push word [bp - 0x28]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0xe4], ax
.3:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        jmp near .16
.4:
        mov word [bp - 0x484], 0x5
        mov ax, 0xffff
        mov [calmonth], ax
        mov [bp - 0x1e], ax
        mov [bp - 0xec], ax
        mov word [bp - 0xde], 0x0
        jmp near .11
.5:
        mov si, [bp - 0x26]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov al, [bp + si - 0x47e]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        dec ax
        mov [bp - 0x484], ax
        mov al, [bp + si - 0x478]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [calcursor], ax
.6:
        mov al, [bp + si - 0x477]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [calcursor2], ax
.7:
        mov si, [bp - 0x26]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov al, [bp + si - 0x476]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0xe]
        jz short .8
        mov al, [bp + si - 0x475]
        cmp ax, [bp + 0xe]
        jnz short .10
.8:
        mov si, [bp - 0x26]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        cmp byte [bp + si - 0x478], 0xff
        jz short .10
        cmp byte [bp + si - 0x477], 0xff
        jz short .10
        cmp byte [bp + si - 0x474], 0xff
        jnz short .9
        cmp byte [bp + si - 0x473], 0xff
        jnz short .9
        cmp word [calmonth], 0x0
        jnl short .9
        mov al, [bp + si - 0x478]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        dec ax
        mov [calmonth], ax
        mov ax, [bp - 0xde]
        mov [bp - 0x1e], ax
        mov ax, [bp - 0x26]
        mov [bp - 0xec], ax
.9:
        mov ax, [bp - 0xde]
        mov si, [bp - 0x26]
        shl si, 1
        mov [bp + si - 0x1d2], ax
        inc word [bp - 0x26]
.10:
        inc word [bp - 0xde]
.11:
        cmp word [bp - 0xde], 0x459
        jnl short .15
        cmp word [bp - 0xe4], 0x0
        jnz short .15
        push word [bp - 0xde]
        mov si, [bp - 0x26]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        lea ax, [bp + si - 0x478]
        push ss
        push ax
        push word [bp - 0x28]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x0CD1:ReadEntry6
        add sp, 0x8
        mov [bp - 0xe4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
        mov ax, [bp - 0xdc]
        cmp [bp - 0xde], ax
        jz short .12
        jmp near .7
.12:
        cmp byte [bp + si - 0x476], 0xff
        jnz short .13
        jmp near .5
.13:
        cmp byte [bp + si - 0x475], 0xff
        jnz short .14
        jmp near .5
.14:
        mov al, [di]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        dec ax
        mov [bp - 0x484], ax
        mov [calcursor], cx
        jmp near .6
        db 0x90
.15:
        cmp word [calmonth], 0x0
        jnl short .16
        mov ax, [bp - 0x484]
        mov [calmonth], ax
.16:
        lea ax, [bp - 0x28]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x1e], 0x0
        jl short .17
        cmp word [bp - 0xe4], 0x0
        jnz short .17
        push word [bp - 0xec]
        lea ax, [bp - 0x478]
        push ax
        push word [bp + 0xe]
        push cs
        call SetGameSides
        add sp, 0x6
        mov si, [bp - 0xec]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov al, [bp + si - 0x478]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [calcursor], ax
        mov al, [bp + si - 0x477]
        mov [calcursor2], ax
        mov si, [bp - 0xec]
        shl si, 1
        mov ax, [bp + si - 0x1d2]
        mov [calday], ax
.17:
        cmp word [bp - 0xe4], 0x0
        jz short .18
        jmp near .89
.18:
        cmp word [calmonth], 0x5
        jnz short .19
        mov es, [segTeamChoiceText30]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:CalNextMonthSeg], ax
        mov [es:CalNextMonthFn], ax
        jmp short .20
.19:
        mov es, [segTeamChoiceText30]
        mov word [es:CalNextMonthFn], strict word CalNextMonthThunk
        mov word [es:CalNextMonthSeg], 0x1b35
.20:
        cmp word [calmonth], 0x9
        jnz short .21
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:CalPrevMonthSeg], ax
        mov [es:CalPrevMonthFn], ax
        jmp short .22
        db 0x90
.21:
        mov word [es:CalPrevMonthFn], strict word CalPrevMonthThunk
        mov word [es:CalPrevMonthSeg], 0x1b35
.22:
        mov ax, [calmonth]
        mov [bp - 0x5e], ax
        call 0x0FEF:UseCurrentPage
        mov ax, CalendarMenuBar
        mov cx, 0x3701
        mov [bp - 0xd6], ax
        mov [bp - 0xd4], cx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0xd0], dx
        mov [bp - 0xd2], dx
        mov [bp - 0x56], dx
        mov [bp - 0x58], dx
        mov [bp - 0x52], dx
        mov [bp - 0x54], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x0FEF:UseOtherPage
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        mov ax, 0x3
        mov [bp - 0x66], ax
        push ax
        push di
        push si
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp + 0xe]
        push word [bp - 0x26]
        lea ax, [bp - 0x478]
        push ax
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        lea ax, [bp - 0xca]
        push ax
        push word [calmonth]
        push cs
        call DrawCalendarDay
        add sp, 0x12
        call 0x0FEF:CopyPlane
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0xe6], ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x47e], cx
        mov [bp - 0x47c], cx
        mov [bp - 0x16], cx
        mov [bp - 0x14], cx
        push cx
        cwd
        push dx
        push ax
        push strict word str_Pointer_9
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x1a], ax
        mov [bp - 0x18], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x1a]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x1a]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x1a]
        mov [es:bx + 0x2], ax
        lea ax, [bp - 0xd8]
        push ax
        lea cx, [bp - 0x6a]
        push cx
        lea dx, [bp - 0xde]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x6a]
        mov [bp - 0x1c], ax
        mov cx, [bp - 0xd8]
        mov [bp - 0x20], cx
        push cx
        push ax
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
.23:
        mov word [bp - 0x480], 0x0
.24:
        call 0x0F99:GetInputEvent
        mov [bp - 0x4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .25
        lea cx, [bp - 0x20]
        push cx
        lea cx, [bp - 0x1c]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x480], ax
.25:
        cmp word [bp - 0x4], 0x0
        jz short .26
        test byte [bp - 0x480], 0x2
        jz short .24
.26:
        test byte [bp - 0x480], 0x2
        jnz short .28
        mov ax, [bp - 0x6a]
        cmp [bp - 0x1c], ax
        jnz short .27
        mov ax, [bp - 0xd8]
        cmp [bp - 0x20], ax
        jnz short .27
        jmp near .88
.27:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0x20]
        push word [bp - 0x1c]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        jmp near .86
.28:
        lea ax, [bp - 0xe0]
        push ax
        lea cx, [bp - 0x5a]
        push cx
        lea dx, [bp - 0x16]
        push dx
        lea dx, [bp - 0x66]
        push dx
        push word [bp - 0x5c]
        lea dx, [bp - 0xd6]
        push dx
        push word [bp - 0x20]
        push word [bp - 0x1c]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .29
        jmp near .62
.29:
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les si, [bp + si - 0xd6]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .30
        jmp near .46
.30:
        mov ax, [bp - 0xe0]
        mov si, [bp - 0x5a]
        shl si, 1
        cmp [bp + si - 0x47e], ax
        jz short .31
        jmp near .38
.31:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x5c]
        mov [bp - 0xde], ax
        jmp short .34
.32:
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov ax, [bp + si - 0x56]
        or ax, [bp + si - 0x58]
        jz short .33
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x14], ax
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
.33:
        dec word [bp - 0xde]
.34:
        cmp word [bp - 0xde], 0x0
        jnl short .32
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les si, [bp + si - 0xd6]
        call far [es:bx + si + 0xc]
        mov [bp - 0x480], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xd0], ax
        mov [bp - 0xd2], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x47c], ax
        mov [bp - 0x64], ax
        cmp word [bp - 0x480], 0x1
        jnz short .35
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.35:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0x6a]
        mov [bp - 0x1c], ax
        mov ax, [bp - 0xd8]
        mov [bp - 0x20], ax
        call 0x0F99:FlushInputEvents
        mov ax, [calmonth]
        cmp [bp - 0x5e], ax
        jz short .36
        call 0x0FEF:UseOtherPage
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push 0x3
        push word 0x3701
        push strict word CalendarMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp + 0xe]
        push word [bp - 0x26]
        lea ax, [bp - 0x478]
        push ax
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        lea ax, [bp - 0xca]
        push ax
        push word [calmonth]
        push cs
        call DrawCalendarDay
        add sp, 0x12
        call 0x0FEF:CopyPlane
.36:
        cmp word [statspalshape], 0x0
        jz short .37
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push 0x3
        push word 0x3701
        push strict word CalendarMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp + 0xe]
        push word [bp - 0x26]
        lea ax, [bp - 0x478]
        push ax
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        lea ax, [bp - 0xca]
        push ax
        push word [calmonth]
        push cs
        call DrawCalendarDay
        add sp, 0x12
        push cs
        call ApplyShapePalette
        mov word [statspalshape], 0x0
.37:
        mov ax, [calmonth]
        mov [bp - 0x5e], ax
        jmp near .85
.38:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x5c]
        cmp [bp - 0x5a], ax
        jnz short .39
        jmp near .44
.39:
        mov [bp - 0xde], ax
        jmp short .42
.40:
        mov si, [bp - 0xde]
        shl si, 1
        mov word [bp + si - 0x47e], 0x0
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov ax, [bp + si - 0x56]
        or ax, [bp + si - 0x58]
        jz short .41
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0x14], ax
        mov [bp + si - 0x16], ax
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov si, [bp - 0xde]
        shl si, byte 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x58], ax
        mov [bp + si - 0xd4], ax
        mov [bp + si - 0xd6], ax
        mov si, [bp - 0xde]
        shl si, 1
        mov [bp + si - 0x66], ax
.41:
        dec word [bp - 0xde]
.42:
        mov ax, [bp - 0x5a]
        cmp [bp - 0xde], ax
        jg short .40
.43:
        mov [bp - 0x5c], ax
.44:
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        mov di, [bp - 0x5a]
        shl di, 1
        imul ax, [bp + di - 0x47e], 0x16
        add ax, [bp + si - 0xd6]
        mov dx, [bp + si - 0xd4]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        mov ax, [bp - 0xe0]
        mov di, [bp - 0x5a]
        shl di, 1
        mov [bp + di - 0x47e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0xd6]
        mov dx, [bp + si - 0xd4]
        push dx
        push ax
.45:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp near .85
        db 0x90
.46:
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les si, [bp + si - 0xd6]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .47
        jmp near .57
.47:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x5c]
        cmp [bp - 0x5a], ax
        jnz short .48
        jmp near .52
.48:
        mov [bp - 0xde], ax
        jmp short .51
.49:
        mov si, [bp - 0xde]
        shl si, 1
        mov word [bp + si - 0x47e], 0x0
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov ax, [bp + si - 0x56]
        or ax, [bp + si - 0x58]
        jz short .50
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x14], ax
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov si, [bp - 0xde]
        shl si, byte 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x58], ax
        mov [bp + si - 0xd4], ax
        mov [bp + si - 0xd6], ax
        mov si, [bp - 0xde]
        shl si, 1
        mov [bp + si - 0x66], ax
.50:
        dec word [bp - 0xde]
.51:
        mov ax, [bp - 0x5a]
        cmp [bp - 0xde], ax
        jg short .49
        mov [bp - 0x5c], ax
.52:
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        imul ax, [bp + di - 0x47e], 0x16
        add ax, [bp + si - 0xd6]
        mov dx, [bp + si - 0xd4]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        mov ax, [bp - 0xe0]
        mov [bp + di - 0x47e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0xd6]
        mov dx, [bp + si - 0xd4]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les di, [bp + si - 0xd6]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x5c]
        mov di, [bp - 0x5c]
        shl di, byte 0x2
        mov [bp + di - 0xd6], ax
        mov [bp + di - 0xd4], dx
        les si, [bp + si - 0xd6]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov di, [bp - 0x5c]
        shl di, 1
        mov [bp + di - 0x66], ax
        mov [bp - 0x48c], si
        mov [bp - 0x48a], es
        cmp word [bp - 0x5c], 0x1
        jz short .53
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [es:bx + 0x4]
        jmp short .54
        db 0x90
.53:
        imul si, [bp - 0xe0], 0x16
        mov di, [bp - 0x5a]
        shl di, byte 0x2
        les bx, [bp + di - 0xd6]
        mov ax, [es:bx + si]
.54:
        mov [bp - 0x486], ax
        mov si, [bp - 0x5c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x1a]
        add ax, [bp - 0x486]
        mov [bp + si - 0x16], ax
        cmp word [bp - 0x5c], 0x1
        jz short .55
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les si, [bp + si - 0xd6]
        mov ax, [es:bx + si + 0x2]
        jmp short .56
        db 0x90
.55:
        imul bx, [bp - 0xe0], 0x16
        mov si, [bp - 0x5a]
        shl si, byte 0x2
        les si, [bp + si - 0xd6]
        mov ax, [es:bx + si + 0x6]
.56:
        mov [bp - 0x488], ax
        mov si, [bp - 0x5c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x18]
        add ax, [bp - 0x488]
        mov [bp + si - 0x14], ax
        les bx, [bp + si - 0xd6]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov di, [bp - 0x5c]
        shl di, 1
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        imul bx, [bp + di - 0x66], 0x16
        db 0x03, 0xD9                           ; insn: add bx, cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [es:bx - 0x12]
        mov [bp - 0x48e], dx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sub ax, [bp - 0x48e]
        inc ax
        mov [bp - 0x2], ax
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov cx, [es:bx + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub cx, [es:bx - 0x10]
        neg cx
        inc cx
        mov [bp - 0xda], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x58], ax
        mov [bp + si - 0x56], dx
        lea ax, [bp + si - 0x58]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push si
        push di
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        pop di
        pop si
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x2]
        mov [es:bx], cx
        mov cx, [bp - 0xda]
        mov [es:bx + 0x2], cx
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push dx
        push ax
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + di - 0x66]
        push word [bp + si - 0xd4]
        push word [bp + si - 0xd6]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x47e], 0x0
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0xd4]
        push word [bp + si - 0xd6]
        jmp near .45
        db 0x90
.57:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x5c]
        cmp [bp - 0x5a], ax
        jnz short .58
        jmp near .44
.58:
        mov [bp - 0xde], ax
        jmp short .61
.59:
        mov si, [bp - 0xde]
        shl si, 1
        mov word [bp + si - 0x47e], 0x0
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov ax, [bp + si - 0x56]
        or ax, [bp + si - 0x58]
        jz short .60
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x14], ax
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov si, [bp - 0xde]
        shl si, byte 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x58], ax
        mov [bp + si - 0xd4], ax
        mov [bp + si - 0xd6], ax
        mov si, [bp - 0xde]
        shl si, 1
        mov [bp + si - 0x66], ax
.60:
        dec word [bp - 0xde]
.61:
        mov ax, [bp - 0x5a]
        cmp [bp - 0xde], ax
        jg short .59
        jmp near .43
.62:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp word [bp - 0x5c], 0x0
        jz short .66
        mov ax, [bp - 0x5c]
        mov [bp - 0xde], ax
        jmp short .65
.63:
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov ax, [bp + si - 0x56]
        or ax, [bp + si - 0x58]
        jz short .64
        push word [bp + si - 0x14]
        push word [bp + si - 0x16]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xde]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x14], ax
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
.64:
        dec word [bp - 0xde]
.65:
        cmp word [bp - 0xde], 0x0
        jnl short .63
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xd0], ax
        mov [bp - 0xd2], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x47c], ax
        mov [bp - 0x64], ax
        jmp near .85
.66:
        mov word [bp - 0xe2], 0xffff
        cmp word [bp - 0x1c], 0x2
        jnl short .67
        jmp near .84
.67:
        cmp word [bp - 0x1c], 0x13d
        jl short .68
        jmp near .84
.68:
        cmp word [bp - 0x20], 0x27
        jnl short .69
        jmp near .84
.69:
        cmp word [bp - 0x20], 0xc3
        jl short .70
        jmp near .84
.70:
        mov ax, [bp - 0x20]
        sub ax, strict word 0x27
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov bx, [calmonth]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov al, [bx + MonthStartDay]
        mov dl, 0x7
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        div dl
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov ax, [bp - 0x1c]
        dec ax
        dec ax
        mov si, 0x2d
        cwd
        idiv si
        db 0x03, 0xC8                           ; insn: add cx, ax
        mov [bp - 0x482], cx
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnl short .71
        jmp near .84
.71:
        mov al, [bx + MonthDays]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC8                           ; insn: cmp cx, ax
        jl short .72
        jmp near .84
.72:
        mov word [bp - 0xde], 0x0
        jmp near .83
.73:
        mov si, [bp - 0xde]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov al, [bp + si - 0x478]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [calmonth]
        dec ax
        jz short .74
        jmp near .82
.74:
        mov al, [bp + si - 0x477]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [bp - 0x482]
        dec ax
        jz short .75
        jmp near .82
.75:
        cmp byte [bp + si - 0x474], 0xff
        jz short .76
        jmp near .82
.76:
        cmp byte [bp + si - 0x473], 0xff
        jz short .77
        jmp near .82
.77:
        mov ax, [calday]
        mov si, [bp - 0xde]
        shl si, 1
        cmp [bp + si - 0x1d2], ax
        jnz short .78
        mov word [calresult], 0xffff
.78:
        cmp word [bp - 0xdc], 0x3f0
        jl short .79
        mov ax, [bp - 0x1e]
        mov si, [bp - 0xde]
        shl si, 1
        cmp [bp + si - 0x1d2], ax
        jnz short .80
.79:
        mov si, [bp - 0xde]
        shl si, 1
        mov ax, [bp + si - 0x1d2]
        mov [bp - 0xe2], ax
        mov ax, [bp - 0xde]
        mov [bp - 0xec], ax
        mov ax, [bp - 0x26]
        mov [bp - 0xde], ax
.80:
        mov si, [bp - 0xec]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        mov al, [bp + si - 0x478]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [calcursor], ax
        mov al, [bp + si - 0x477]
        mov [calcursor2], ax
        cmp word [calresult], 0x0
        jnz short .81
        push word [bp - 0xec]
        lea ax, [bp - 0x478]
        push ax
        push word [bp + 0xe]
        push cs
        call SetGameSides
        add sp, 0x6
.81:
        call 0x0FEF:UseOtherPage
        push word [bp - 0x60]
        push word [bp - 0x68]
        push word [bp - 0x6]
        push 0x3
        push word 0x3701
        push strict word CalendarMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp + 0xe]
        push word [bp - 0x26]
        lea ax, [bp - 0x478]
        push ax
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        lea ax, [bp - 0xca]
        push ax
        push word [calmonth]
        push cs
        call DrawCalendarDay
        add sp, 0x12
        call 0x0FEF:CopyPlane
.82:
        inc word [bp - 0xde]
.83:
        mov ax, [bp - 0x26]
        cmp [bp - 0xde], ax
        jnl short .84
        jmp near .73
.84:
        mov ax, [bp - 0xe2]
        mov [calday], ax
.85:
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xd8]
        push word [bp - 0x6a]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0x20]
        push word [bp - 0x1c]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        cmp word [calresult], 0x0
        jnz short .87
.86:
        push word [bp - 0x20]
        push word [bp - 0x1c]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
.87:
        mov ax, [bp - 0x1c]
        mov [bp - 0x6a], ax
        mov ax, [bp - 0x20]
        mov [bp - 0xd8], ax
.88:
        cmp word [calresult], 0x0
        jnz short .89
        jmp near .23
.89:
        push word [bp - 0x18]
        push word [bp - 0x1a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x8]
        push word [bp - 0xa]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [teamstatscb], 0x250d
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x2503
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24f9
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24ef
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x232d
        mov word [menucbseg], 0x1b35
        mov ax, [calday]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CheckLeagueDiskSync                                        25B2:1620  94 PC
; League id on the floppy matches.
;
; Takes 7 words of stack arguments. Calls GetLeagueId, FmtFromLeague, FindLeagueFloppy,
; WaitLeagueFloppy, BuildPathFar, OpenReadShared, ReadLeagueTeamEntry, CloseHandlePtr and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
CheckLeagueDiskSync:
        enter 0xae, 0x0
        push di
        push si
        mov word [bp - 0x4], 0xffff
        mov word [bp - 0x2], 0x0
        imul ax, [bp + 0xe], 0x1e
        add ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xc], dx
        mov bx, 0x5dd
        mov es, [segTeamChoiceText31]
        mov [bp - 0xae], bx
        mov [bp - 0xac], es
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
        lea ax, [bp - 0x12]
        push ss
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x2305:GetLeagueId
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, [bp - 0xc]
        cmp byte [es:di + 0x17], 0x1
        jnz short .5
        cmp [bp + 0xe], si
        jnz short .1
        jmp near .11
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .3
        cmp byte [es:di + 0x18], 0x1
        jnz short .2
        jmp near .11
.2:
        test byte [es:di + 0x16], 0x1
        jz short .3
        jmp near .11
.3:
        cmp word [bp + 0x10], 0x0
        jnz short .4
        jmp near .10
.4:
        cmp word [bp + 0x12], 0x0
        jz short .6
        push word [bp + 0x8]
        push word [bp + 0x6]
        push es
        push di
        lea ax, [bp - 0xaa]
        push ss
        push ax
        call 0x2305:FmtFromLeague
        add sp, 0xc
        lea ax, [bp - 0xaa]
        mov es, [segTeamChoiceText32]
        mov [es:msgInsertDiskFor + 0x4], ax
        mov [es:msgInsertDiskFor + 0x6], ss
        push -0x1
        push word [bp - 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x20F8:FindLeagueFloppy
        jmp short .7
        db 0x90
.5:
        mov si, [bp - 0x2]
        jmp near .13
.6:
        push -0x1
        push es
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x20F8:WaitLeagueFloppy
.7:
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .8
        jmp near .13
.8:
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x6a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .9
        push word [bp + 0xe]
        lea ax, [bp - 0x4a]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x20E6:ReadLeagueTeamEntry
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.9:
        lea ax, [bp - 0x4]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .13
        test byte [bp - 0x34], 0x1
        jz short .13
        les bx, [bp - 0xae]
        mov word [es:bx], str_MustBeExportedToThe
        mov word [es:bx + 0x2], 0x3701
        jmp short .12
.10:
        lea ax, [bp - 0x6]
        push ax
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0xa]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x8]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3701
        push strict word msgTheFirstTeamSelectedTo
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        jmp short .12
.11:
        mov si, [bp - 0x2]
        test byte [es:di + 0x16], 0x2
        jz short .13
        les bx, [bp - 0xae]
        mov word [es:bx], str_MustBeImportedFromThe
        mov word [es:bx + 0x2], 0x3701
.12:
        mov si, 0x4
.13:
        les bx, [bp - 0xae]
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jnz short .14
        jmp near .15
.14:
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x2c]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x2c]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lea ax, [bp - 0x2c]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov byte [bx], 0x0
        mov es, [segTeamChoiceText31]
        mov [es:msgTheLeague + 0x4], ax
        mov [es:msgTheLeague + 0x6], ss
        mov ax, [bp - 0xc]
        push ax
        push di
        lea ax, [bp - 0x1e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x1e]
        mov es, [segTeamChoiceText31]
        mov [es:msgTheLeague + 0xC], ax
        mov [es:msgTheLeague + 0xE], ss
        lea ax, [bp - 0x6]
        push ax
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0xa]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x8]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x5
        push word 0x3701
        push strict word msgTheLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.15:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MakeTeamDbFmt                                              25B2:1876  94 PC
; Dir\%s.NN for a human team.
;
; Takes 7 words of stack arguments. Calls _sprintf, _fstrcpy, _fstrcat. Far routine (retf).
;-----------------------------------------------------------------------------
MakeTeamDbFmt:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x12]
        imul si, di, 0x1e
        les bx, [bp + 0xe]
        cmp byte [es:bx + si + 0x17], 0x1
        jnz short .1
        mov si, [bp + 0x6]
        push di
        push strict word str_02d_8
        lea ax, [bp - 0x4]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov ax, [bp + 0x8]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Backslash
        push di
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x3701
        push strict word str_S
        push di
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        lea ax, [bp - 0x4]
        push ss
        push ax
        push di
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90
.1:
        les bx, [bp + 0x6]
        mov byte [es:bx], 0x0
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PostGameToTeamDb                                           25B2:18F4  94 PC
; Merges the game into the team's league db.
;
; Takes 9 words of stack arguments. Calls BuildPathFar, OpenReadWriteShared, OpenReadShared,
; ReadEntry744, ReadRecord48, WriteGoalieSeasonRec, WriteSeasonRec, ReadRecord52 and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
PostGameToTeamDb:
        enter 0x3f4, 0x0
        push di
        push si
        mov ax, 0xffff
        mov [bp - 0x3e], ax
        mov [bp - 0x3be], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x3b2], ax
        mov word [bp - 0x3bc], HomeTeamRec
        mov word [bp - 0x3ba], AwayTeamRec
        cmp word [bp + 0x12], 0x3f0
        jnl short .1
        lea ax, [bp - 0x336]
        mov [bp - 0x2], ax
        lea ax, [bp - 0x3f4]
        mov [bp - 0x3c0], ax
        lea ax, [bp - 0x76]
        jmp short .2
.1:
        lea ax, [bp - 0x324]
        mov [bp - 0x2], ax
        lea ax, [bp - 0x3e2]
        mov [bp - 0x3c0], ax
        lea ax, [bp - 0x60]
.2:
        mov [bp - 0x1a], ax
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x3b8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x2]
        push word [es:DbFileNameList]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3be]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x3b8], ax
.3:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x16]
        push word [es:DbFileNameList + 0x14]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x1c]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x3b8], ax
.4:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        push word 0x3701
        push strict word str_Db_2
        push ds
        push strict word str_Gsummary_3
        push word [bp + 0x16]
        push word [bp + 0x14]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3b2]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x3b8], ax
.5:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
        push word [bp + 0xe]
        lea ax, [bp - 0x35e]
        push ss
        push ax
        push word [bp - 0x3e]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        mov [bp - 0x3b8], ax
.6:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        jmp near .22
.7:
        mov bx, [bp - 0x2]
        inc byte [bx]
        mov ax, [hmscore]
        cmp [awscore], ax
        jnl short .10
        mov ax, [awscore]
        inc ax
        mov [bp - 0x3c2], ax
        mov word [bp - 0x8], 0x0
        cmp word [bp + 0x10], 0x0
        jnz short .9
.8:
        inc byte [bx + 0x1]
        jmp short .12
.9:
        mov bx, [bp - 0x2]
        inc byte [bx + 0x2]
        jmp short .12
.10:
        cmp [awscore], ax
        jng short .11
        inc ax
        mov [bp - 0x3c2], ax
        mov word [bp - 0x8], 0x1
        cmp word [bp + 0x10], 0x0
        jz short .9
        mov bx, [bp - 0x2]
        jmp short .8
        db 0x90
.11:
        mov bx, [bp - 0x2]
        inc byte [bx + 0x3]
        mov word [bp - 0x8], 0xffff
        mov ax, [hmscore]
        mov [bp - 0x3c2], ax
.12:
        imul bx, [bp + 0x10], word 0xd6
        mov ax, [bx + hmscore]
        mov si, [bp - 0x2]
        add [si + 0x4], ax
        mov ax, [bp + 0x10]
        xor al, 0x1
        imul di, ax, word 0xd6
        mov ax, [di + hmscore]
        add [si + 0x6], ax
        mov ax, [bx + hmppchances]
        add [si + 0xa], ax
        mov ax, [bx + hmppgoals]
        add [si + 0x8], ax
        mov ax, [di + hmppchances]
        add [si + 0xe], ax
        mov ax, [di + hmppgoals]
        add [si + 0xc], ax
        mov ax, [di + hmpenmins]
        add [si + 0x10], ax
        mov word [bp - 0x3b0], 0x0
        jmp short .19
.13:
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x3f4]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x0CD1:ReadRecord48
.14:
        add sp, 0xa
        mov [bp - 0x3b8], ax
.15:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        cmp byte [bp - 0x390], 0x47
        jnz short .16
        mov si, [bp - 0x3b0]
        shl si, 1
        inc word [bp + si - 0x46]
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x76]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:WriteGoalieSeasonRec
        jmp short .17
.16:
        mov si, [bp - 0x3b0]
        shl si, 1
        inc word [bp + si - 0x3cc]
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x3f4]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:WriteSeasonRec
.17:
        add sp, 0xa
        mov [bp - 0x3b8], ax
.18:
        inc word [bp - 0x3b0]
.19:
        cmp word [bp - 0x3b0], 0x3
        jnl short .22
        cmp word [bp - 0x3b8], 0x0
        jnz short .22
        mov ax, [bp + 0x10]
        mov bx, [bp - 0x3b0]
        shl bx, byte 0x2
        cmp [bx + startm], ax
        jnz short .18
        mov si, [bx + starpl]
        shl si, byte 0x2
        push word [bp + si - 0x310]
        push word [bp + si - 0x312]
        lea ax, [bp - 0x392]
        push ss
        push ax
        push word [bp - 0x3be]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0x3b8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .20
        jmp near .15
.20:
        cmp byte [bp - 0x390], 0x47
        jz short .21
        jmp near .13
.21:
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x76]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:ReadGoalieSeasonRec
        jmp near .14
        db 0x90
.22:
        cmp word [bp - 0x8], 0x0
        jl short .23
        jmp near .38
.23:
        mov si, [hmtmgoalie]
        and si, 0x1
        mov bx, [hmtmlines]
        mov al, [bx + si + 0x24]
        mov [bp - 0x6], al
        mov si, [awtmgoalie]
        and si, 0x1
        mov bx, [awtmteamrec]
        mov al, [bx + si + 0x24]
        mov [bp - 0x5], al
.24:
        mov word [bp - 0x3b0], 0x0
.25:
        mov si, [bp - 0x3b0]
        mov byte [bp + si - 0x3ae], 0x1
        inc word [bp - 0x3b0]
        cmp word [bp - 0x3b0], 0x19
        jl short .25
        mov word [bp - 0x3b0], 0x0
.26:
        mov si, [bp + 0x10]
        shl si, 1
        mov bx, [bp + si - 0x3bc]
        mov si, [bp - 0x3b0]
        mov al, [bx + si + 0x28]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x4], ax
        cmp ax, strict word 0x19
        jnl short .27
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp + si - 0x3ae], ah
.27:
        inc word [bp - 0x3b0]
        cmp word [bp - 0x3b0], 0x8
        jl short .26
        mov word [bp - 0x3b0], 0x0
.28:
        cmp word [bp - 0x3b8], 0x0
        jz short .29
        jmp near .34
.29:
        mov si, [bp - 0x3b0]
        shl si, byte 0x2
        cmp word [bp + si - 0x312], -0x1
        jnz short .30
        cmp word [bp + si - 0x310], -0x1
        jnz short .30
        jmp near .33
.30:
        push word [bp + si - 0x310]
        push word [bp + si - 0x312]
        lea ax, [bp - 0x392]
        push ss
        push ax
        push word [bp - 0x3be]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0x3b8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .31
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x3f4]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x0CD1:ReadRecord48
        add sp, 0xa
        mov [bp - 0x3b8], ax
.31:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .32
        jmp near .33
.32:
        mov si, [bp - 0x3b0]
        cmp byte [bp + si - 0x3ae], 0x0
        jz short .33
        mov bx, [bp - 0x3c0]
        inc word [bx]
        mov es, [segWorkBuffer21]
        imul ax, [bp + 0x10], 0x19
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, byte 0x4
        mov ax, [es:si + HomePlStats]
        add [bx + 0x2], ax
        mov ax, [es:si + HomePlStats_w2]
        add [bx + 0x4], ax
        mov ax, [es:si + HomePlStats]
        add [bx + 0x6], ax
        mov ax, [es:si + HomePlStats_w2]
        add [bx + 0x6], ax
        mov ax, [es:si + HomePlStats_w2 + 0x2]
        add [bx + 0xc], ax
        mov ax, [es:si + HomePlStats_w2 + 0x4]
        add [bx + 0x10], ax
        mov ax, [es:si + HomePlStats_w2 + 0x6]
        add [bx + 0x8], ax
        mov ax, [es:si + HomePlStats_w2 + 0x8]
        add [bx + 0xa], ax
        mov ax, [es:si + HomePlStats_w2 + 0xC]
        add [bx + 0xe], ax
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x3f4]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:WriteSeasonRec
        add sp, 0xa
        mov [bp - 0x3b8], ax
.33:
        inc word [bp - 0x3b0]
        cmp word [bp - 0x3b0], 0x19
        jnl short .34
        jmp near .28
.34:
        mov word [bp - 0x3b0], 0x0
.35:
        mov si, [bp - 0x3b0]
        mov byte [bp + si - 0x395], 0x0
        inc word [bp - 0x3b0]
        cmp word [bp - 0x3b0], 0x3
        jl short .35
        mov word [bp - 0x3b0], 0x0
.36:
        mov si, [bp + 0x10]
        shl si, 1
        mov bx, [bp + si - 0x3bc]
        mov si, [bp - 0x3b0]
        mov al, [bx + si + 0x24]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x4], ax
        cmp ax, strict word 0x1c
        jnl short .37
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc byte [bp + si - 0x3ae]
.37:
        inc word [bp - 0x3b0]
        cmp word [bp - 0x3b0], 0x2
        jl short .36
        mov word [bp - 0x3b0], 0x0
        jmp near .63
        db 0x90
.38:
        cmp word [bp - 0x3b8], 0x0
        jnz short .39
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x3b2]
        call 0x0CD1:ReadEntry12
        add sp, 0x8
        mov [bp - 0x3b8], ax
.39:
        cmp word [bp - 0x3b8], 0x0
        jz short .40
        jmp near .24
.40:
        mov al, 0xff
        mov [bp - 0x6], al
        mov [bp - 0x5], al
        lea ax, [bp - 0x12]
        mov [bp - 0x3c4], ax
        mov ax, [bp - 0xe]
        mov [bp - 0x40], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3b6], ax
        mov [bp - 0x3b4], ax
        mov [bp - 0x3b0], ax
        jmp short .46
        db 0x90
.41:
        inc word [bp - 0x3b4]
.42:
        cmp word [bp - 0x8], 0x0
        jnz short .43
        mov ax, [bp - 0x3c2]
        cmp [bp - 0x3b6], ax
        jnz short .45
        les bx, [bp - 0x18]
        mov al, [es:bx + 0x8]
        mov [bp - 0x6], al
        mov al, [es:bx + 0x9]
        jmp short .44
.43:
        mov ax, [bp - 0x3c2]
        cmp [bp - 0x3b4], ax
        jnz short .45
        les bx, [bp - 0x18]
        mov al, [es:bx + 0x9]
        mov [bp - 0x6], al
        mov al, [es:bx + 0x8]
.44:
        mov [bp - 0x5], al
.45:
        inc word [bp - 0x3b0]
.46:
        mov ax, [bp - 0x3b0]
        cmp [bp - 0x40], ax
        jnl short .47
        jmp near .24
.47:
        cmp word [bp - 0x3b8], 0x0
        jz short .48
        jmp near .24
.48:
        push ax
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x3b2]
        call 0x0CD1:ReadEntry12
        add sp, 0x8
        mov [bp - 0x3b8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .45
        cmp byte [bp - 0x14], 0x1
        jnz short .45
        lea bx, [bp - 0x12]
        mov [bp - 0x18], bx
        mov [bp - 0x16], ss
        cmp byte [bx], 0x0
        jz short .49
        jmp near .41
.49:
        inc word [bp - 0x3b6]
        jmp near .42
        db 0x90
.50:
        mov bx, [bp - 0x1a]
        inc word [bx + 0x4]
        jmp short .54
.51:
        cmp [awscore], ax
        jng short .53
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .50
        mov bx, [bp - 0x1a]
.52:
        inc word [bx + 0x2]
        jmp short .54
.53:
        mov bx, [bp - 0x1a]
        inc word [bx + 0x6]
.54:
        cmp word [awscore], 0x0
        jnz short .55
        cmp word [bp + 0x10], 0x0
        jz short .56
.55:
        cmp word [hmscore], 0x0
        jnz short .57
        cmp word [bp + 0x10], 0x1
        jnz short .57
.56:
        mov bx, [bp - 0x1a]
        inc word [bx + 0x8]
.57:
        mov bx, [bp - 0x1a]
        cmp word [bx], 0x0
        jz short .58
        push 0x0
        push word [bx]
        mov ax, 0x64
        mul word [bx + 0xe]
        push dx
        push ax
        call 0x0000:__aFldiv
        mov bx, [bp - 0x1a]
        mov [bx + 0x10], ax
        jmp short .59
        db 0x90
.58:
        mov word [bx + 0x10], 0x0
.59:
        mov bx, [bp - 0x1a]
        cmp word [bx + 0x12], 0x0
        jz short .60
        push 0x0
        push word [bx + 0x12]
        mov ax, [bx + 0x12]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shr ax, 1
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [bx + 0xe]
        mov cx, 0x3e8
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mul cx
        db 0x03, 0xC6                           ; insn: add ax, si
        adc dx, 0x0
        push dx
        push ax
        call 0x0000:__aFldiv
        mov bx, [bp - 0x1a]
        mov [bx + 0x14], ax
        jmp short .61
.60:
        mov word [bx + 0x14], 0x0
.61:
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x76]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:WriteGoalieSeasonRec
        add sp, 0xa
        mov [bp - 0x3b8], ax
.62:
        inc word [bp - 0x3b0]
.63:
        cmp word [bp - 0x3b0], 0x3
        jl short .64
        jmp near .72
.64:
        cmp word [bp - 0x3b8], 0x0
        jz short .65
        jmp near .72
.65:
        mov si, [bp - 0x3b0]
        shl si, byte 0x2
        cmp word [bp + si - 0x2ae], -0x1
        jnz short .66
        cmp word [bp + si - 0x2ac], -0x1
        jz short .62
.66:
        push word [bp + si - 0x2ac]
        push word [bp + si - 0x2ae]
        lea ax, [bp - 0x392]
        push ss
        push ax
        push word [bp - 0x3be]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0x3b8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .67
        push word [bp - 0x364]
        push word [bp - 0x366]
        lea ax, [bp - 0x76]
        push ss
        push ax
        push word [bp - 0x1c]
        call 0x20E6:ReadGoalieSeasonRec
        add sp, 0xa
        mov [bp - 0x3b8], ax
.67:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .62
        mov si, [bp - 0x3b0]
        cmp byte [bp + si - 0x395], 0x0
        jz short .62
        mov es, [segWorkBuffer22]
        mov ax, [bp + 0x10]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        cmp word [es:si + HomeGlStats], 0x0
        jnz short .68
        jmp near .62
.68:
        mov bx, [bp - 0x1a]
        inc word [bx]
        mov ax, [es:si + HomeGlStats]
        mov cx, 0x3c
        cwd
        idiv cx
        add [bx + 0xc], ax
        mov ax, [es:si + HomeGlStats_w2]
        add [bx + 0x12], ax
        mov ax, [es:si + HomeGlStats_w4]
        add [bx + 0xe], ax
        mov si, [bp + 0x10]
        mov al, [bp + si - 0x6]
        sub al, [bp - 0x3b0]
        cmp al, 0x19
        jz short .69
        jmp near .57
.69:
        mov ax, [hmscore]
        cmp [awscore], ax
        jl short .70
        jmp near .51
.70:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .71
        jmp near .50
.71:
        jmp near .52
        db 0x90
.72:
        cmp word [bp - 0x3b8], 0x0
        jnz short .73
        push word [bp + 0xe]
        lea ax, [bp - 0x35e]
        push ss
        push ax
        push word [bp - 0x3e]
        call 0x20E6:WriteTeamRec
        add sp, 0x8
        mov [bp - 0x3b8], ax
.73:
        lea ax, [bp - 0x3b2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x1c]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x3be]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x3e]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0x3b8]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayLeagueGame                                             25B2:208A  94 PC
; 'Select a team to play.'
;
; Takes 2 words of stack arguments. Calls LoadLeagueGameRef, LeagueCheckAlwaysZero, ReadLeagueInfo,
; _fstrcpy, _fstrcspn, MouseRead, SetDialogColors, MessageBox and others.
;-----------------------------------------------------------------------------
PlayLeagueGame:
        enter 0x76, 0x0
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6c], ax
        mov [bp - 0x6], ax
        mov [bp - 0x4], ax
        mov ax, 0xffff
        mov [bp - 0x4a], ax
        mov [bp - 0x52], ax
        mov [bp - 0x50], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x2], ax
        mov [lggameidx], ax
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jl short .1
        push word [bx]
        call 0x2E18:LoadLeagueGameRef
        add sp, 0x2
.1:
        push 0x3
        push word 0x3701
        push strict word CurLeagueName
        call 0x2305:LeagueCheckAlwaysZero
        add sp, 0x6
        mov [bp - 0x5c], ax
.2:
        mov word [bp - 0x42], 0x0
        cmp word [bp - 0x5c], 0x0
        jnz short .3
        push word 0x3a0b
        push strict word leagueinfo_tail
        push word 0x3a0b
        push strict word leagueinfo_w6
        push word 0x3a0b
        push strict word leagueinfo_w4
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word 0x3a0b
        push strict word leagueinfo
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3701
        push strict word CurLeagueName
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        mov [bp - 0x5c], ax
.3:
        cmp word [bp - 0x5c], 0x0
        jz short .4
        jmp near .11
.4:
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x6a]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x6a]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x1a], si
        mov byte [bp + si - 0x6a], 0x0
        mov es, [segWorkBuffer23]
        test byte [es:leagueinfo_w4], 0xc
        jnz short .5
        jmp near .10
.5:
        lea ax, [bp - 0x54]
        push ax
        lea cx, [bp - 0x4c]
        push cx
        lea dx, [bp - 0x6e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        mov es, [segWorkBuffer23]
        test byte [es:leagueinfo_w4], 0x8
        jz short .6
        lea ax, [bp - 0x6a]
        mov es, [segTeamChoiceText33]
        mov [es:argMasterDatabasesFor], ax
        mov [es:argMasterDatabasesFor + 0x2], ss
        push -0x1
        lea ax, [bp - 0x54]
        push ax
        lea ax, [bp - 0x4c]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgPlayLeagueGame
        push 0x5
        push es
        push word 0x9b4
        jmp short .7
        db 0x90
.6:
        lea ax, [bp - 0x6a]
        mov es, [segTeamChoiceText34]
        mov [es:argPlayersDatabasesFor], ax
        mov [es:argPlayersDatabasesFor + 0x2], ss
        push -0x1
        lea ax, [bp - 0x54]
        push ax
        lea ax, [bp - 0x4c]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgMergeFirst
        push 0x4
        push es
        push word 0x903
.7:
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x6e], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .9
        mov es, [segWorkBuffer23]
        test byte [es:leagueinfo_w4], 0x8
        jz short .8
        call 0x2CB7:MergeLeagueFiles
.8:
        call 0x2CB7:UpdateTeamDbs
        mov word [bp - 0x42], 0xffff
        jmp short .11
.9:
        mov word [bp - 0x5c], 0xffff
        jmp short .11
        db 0x90
.10:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x1
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x40]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        mov [bp - 0x5c], ax
.11:
        cmp word [bp - 0x42], 0x0
        jz short .12
        jmp near .2
.12:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jl short .13
        jmp near .25
.13:
        mov word [bp - 0x48], 0x0
        cmp word [bp - 0x5c], 0x0
        jnz short .14
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x18]
        push ss
        push ax
        push word 0x3701
        push strict word CurLeagueName
        call 0x2305:GetLeagueId
        add sp, 0x8
        mov [lghometeam], ax
.14:
        cmp word [bp - 0x5c], 0x0
        jnz short .15
        cmp word [lghometeam], 0x0
        jnl short .15
        push word lghometeam
        push word 0x3701
        push strict word str_SelectATeamToPlay
        push 0x8
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3a0b
        push strict word LeagueTeamNames
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word 0x3701
        push strict word CurLeagueName
        call 0x1F31:LeagueTeamSelect
        add sp, 0x18
        push strict word str_Pnt2_8
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov word [bp - 0x48], 0xffff
.15:
        cmp word [bp - 0x5c], 0x0
        jz short .16
        jmp near .28
.16:
        cmp word [lghometeam], 0x0
        jnl short .17
        jmp near .28
.17:
        push 0x0
        push 0x0
        push word [lghometeam]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call CheckLeagueDiskSync
        add sp, 0xe
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .18
        jmp near .23
.18:
        push word [lghometeam]
        push strict word str_02d_7
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x46]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx_2
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segWorkBuffer20]
        imul bx, [lghometeam], 0x1e
        test byte [es:bx + leagueinfo_teams + 0x16], 0x1
        jz short .19
        push word 0x3701
        push strict word CurLeagueName
        jmp short .20
        db 0x90
.19:
        push word 0x3701
        push strict word str_DriveColon
.20:
        push ds
        push strict word savleague
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segWorkBuffer24]
        cmp word [es:leagueinfo_w2], 0x1
        jz short .21
        cmp word [bp - 0x48], 0x0
        jnz short .22
.21:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
.22:
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [lghometeam]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
        mov [bp - 0x5c], ax
.23:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        jmp near .27
.24:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x40]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        jmp short .26
        db 0x90
.25:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push word [lghometeam]
        push strict word str_02d_6
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x46]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx_2
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [lghometeam]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
.26:
        mov [bp - 0x5c], ax
.27:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .28
        mov word [bp - 0x4], 0xffff
.28:
        push strict word str_Pntr_12
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        cmp word [bp - 0x4], 0x0
        jnz short .29
        jmp near PlayLeagueGameTail + 0x2F60
.29:
        cmp word [lggameidx], -0x1
        jnz short .30
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jl short .31
.30:
        cmp word [bp - 0x6c], 0x0
        jz short .32
.31:
        push word [lghometeam]
        push word 0x3701
        push strict word str_Xx_2
        push ds
        push strict word savleague
        push cs
        call CalendarScreen
        add sp, 0xa
        mov [lggameidx], ax
.32:
        cmp word [lggameidx], 0x0
        jnl short .33
        jmp near .94
.33:
        push word 0x3701
        push strict word str_Xx_2
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push ds
        push strict word savleague
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4a]
        push ax
        lea cx, [bp - 0x40]
        push cx
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .37
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .34
        push 0x2
        push ax
        push ax
        push ds
        push strict word lgreadword
        push word [bp - 0x4a]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.34:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .35
        push word [lggameidx]
        push ds
        push strict word lgschedrec
        push word [bp - 0x4a]
        call 0x0CD1:ReadEntry6
        add sp, 0x8
        mov [bp - 0x5c], ax
.35:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .37
        mov al, [lgschedrec_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [lghometeam]
        jnz short .36
        mov al, [lgschedrec_b3]
.36:
        mov [lgoppteam], ax
        mov word [lggamestate], 0xffff
        mov es, [segWorkBuffer20]
        imul bx, ax, 0x1e
        cmp byte [es:bx + leagueinfo_teams + 0x17], 0x0
        jnz short .37
        mov word [lggamestate], 0x0
.37:
        lea ax, [bp - 0x4a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [lggamestate], 0x0
        jnz short .38
        jmp near .44
.38:
        cmp word [bp - 0x5c], 0x0
        jnz short .41
        push 0x0
        push -0x1
        push word [lgoppteam]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call CheckLeagueDiskSync
        add sp, 0xe
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .41
        push word [lgoppteam]
        push strict word str_02d_5
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x46]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segWorkBuffer20]
        imul bx, [lgoppteam], 0x1e
        test byte [es:bx + leagueinfo_teams + 0x16], 0x1
        jz short .39
        cmp word [bp - 0x48], 0x0
        jz short .39
        push word 0x3701
        push strict word CurLeagueName
        jmp short .40
        db 0x90
.39:
        push word 0x3701
        push strict word str_DriveColon
.40:
        push ds
        push strict word savleague2
        call 0x0000:_fstrcpy
        add sp, 0x8
.41:
        cmp word [bp - 0x5c], 0x0
        jnz short .42
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push ds
        push strict word savleague2
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x52]
        push ax
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
.42:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .43
        cmp word [bp - 0x5c], 0x0
        jnz short .43
        push 0x2
        push 0x0
        push 0x0
        push ds
        push strict word lgreadword2
        push word [bp - 0x52]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.43:
        lea ax, [bp - 0x52]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x5c], 0x0
        jnz short .44
        push word [lgoppteam]
        push strict word str_02d_4
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x46]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [lgoppteam]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .44
        mov word [bp - 0x6], 0xffff
.44:
        cmp word [bp - 0x5c], 0x0
        jz short .45
        jmp near .59
.45:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jl short .46
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x58], ax
        mov [bp - 0x56], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x56]
        push word [bp - 0x58]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x56]
        push word [bp - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
.46:
        mov al, [lgschedrec_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [lghometeam]
        jnz short .47
        mov word [bp - 0x1e], 0x0
        mov word [bp - 0x20], 0x1
        push ax
        push word 0x3a0b
        push strict word leagueinfo_teams
        push ds
        push strict word savleague
        push ds
        push strict word HomeTeamDbName
        push cs
        call MakeTeamDbFmt
        add sp, 0xe
        mov al, [lgschedrec_b3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3a0b
        push strict word leagueinfo_teams
        push ds
        push strict word savleague2
        jmp short .48
        db 0x90
.47:
        mov word [bp - 0x1e], 0x1
        mov word [bp - 0x20], 0x0
        mov al, [lgschedrec_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3a0b
        push strict word leagueinfo_teams
        push ds
        push strict word savleague2
        push ds
        push strict word HomeTeamDbName
        push cs
        call MakeTeamDbFmt
        add sp, 0xe
        mov al, [lgschedrec_b3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3a0b
        push strict word leagueinfo_teams
        push ds
        push strict word savleague
.48:
        push ds
        push strict word AwayTeamDbName
        push cs
        call MakeTeamDbFmt
        add sp, 0xe
        cmp byte [AwayTeamDbName], 0x0
        jnz short .49
        push ds
        push strict word HomeTeamDbName
        push ds
        push strict word AwayTeamDbName
        call 0x0000:_fstrcpy
        add sp, 0x8
.49:
        cmp byte [HomeTeamDbName], 0x0
        jnz short .50
        push ds
        push strict word AwayTeamDbName
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcpy
        add sp, 0x8
.50:
        mov ax, [lggameidx]
        mov es, [segWorkBuffer25]
        mov [es:AwayGlStats + 0x12], ax
        cmp ax, 0x3f0
        jnl short .51
        or byte [AnnouncerFlags], 0x2
        jmp short .52
        db 0x90
.51:
        and byte [AnnouncerFlags], 0xfd
.52:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .53
        mov al, [lgschedrec]
        mov [savedteam1], al
        mov al, [lgschedrec_b1]
        mov [savedteam2], al
        mov al, [lgschedrec_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [HomeTeamNum], ax
        mov al, [lgschedrec_b3]
        mov [VisTeamNum], ax
.53:
        call 0x1B35:SetupControllersThunk
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .54
        mov al, [savedteam2]
        push ax
        mov al, [savedteam1]
        push ax
        call 0x1B35:CreateGSummaryDbThunk
        add sp, 0x4
.54:
        mov word [bp - 0x5c], 0x0
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .55
        mov al, [VisTeamNum]
        push ax
        mov al, [HomeTeamNum]
        push ax
        call 0x1B35:ShowMatchupScreenThunk
        add sp, 0x4
        mov [bp - 0x5c], ax
.55:
        cmp word [bp - 0x5c], 0x4
        jnz short .56
        jmp near .58
.56:
        mov word [teamstatscb], 0x250d
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x2503
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24f9
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24ef
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x232d
        mov word [menucbseg], 0x1b35
        call 0x0BFE:InputRemove
        push word [bp + 0x6]
        call 0x1B35:PlayGameThunk
        add sp, 0x2
        call 0x0BFE:InputInit
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov es, [segDgroup6]
        mov ax, [es:PageTableSeg]
        or ax, [es:PageTable]
        jz short .57
        push word [es:PageTableSeg]
        push word [es:PageTable]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov es, [segDgroup6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:PageTableSeg], ax
        mov [es:PageTable], ax
.57:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xc8
        push word 0x140
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov es, [segDbFiles13]
        cmp word [es:lgstate_w5A + 0x8], 0x1
        jnz short .59
        mov al, [hmscore]
        mov [lgschedrec_b4], al
        mov al, [awscore]
        mov [lgschedrec_b5], al
        jmp short .59
.58:
        mov es, [segDbFiles13]
        mov word [es:lgstate_w5A + 0x8], 0x2
.59:
        cmp word [bp - 0x5c], 0x0
        jz short .60
        jmp near .91
.60:
        mov es, [segDbFiles13]
        cmp word [es:lgstate_w5A + 0x8], 0x1
        jz short .61
        jmp near .91
.61:
        mov ax, [lggameidx]
        mov [bp - 0x4e], ax
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push strict word str_Pal_40
        push 0x0
        push strict word str_EasndeskQpp_2
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x76], ax
        mov [bp - 0x74], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x72], ax
        mov [bp - 0x70], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [bp - 0x74]
        push word [bp - 0x76]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov al, 0x17
        mov [bp - 0x46], al
        mov [bp - 0x45], al
        mov [bp - 0x44], al
        lea ax, [bp - 0x46]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x2a
        mov [bp - 0x46], al
        mov [bp - 0x45], al
        mov [bp - 0x44], al
        lea ax, [bp - 0x46]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x3f
        mov [bp - 0x46], al
        mov [bp - 0x45], al
        mov [bp - 0x44], al
        lea ax, [bp - 0x46]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        cmp word [lggamestate], 0x0
        jz short .64
        push -0x1
        push -0x1
        push word [lgoppteam]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call CheckLeagueDiskSync
        add sp, 0xe
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .64
        push word [lgoppteam]
        push strict word str_02d_3
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x46]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segWorkBuffer20]
        imul bx, [lgoppteam], 0x1e
        test byte [es:bx + leagueinfo_teams + 0x16], 0x1
        jz short .62
        cmp word [bp - 0x48], 0x0
        jz short .62
        push word 0x3701
        push strict word CurLeagueName
        jmp short .63
        db 0x90
.62:
        push word 0x3701
        push strict word str_DriveColon
.63:
        push ds
        push strict word savleague2
        call 0x0000:_fstrcpy
        add sp, 0x8
.64:
        cmp word [bp - 0x5c], 0x0
        jnz short .65
        push word 0x3701
        push strict word str_Xx_2
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push ds
        push strict word savleague
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4a]
        push ax
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
        cmp word [lggamestate], 0x0
        jz short .65
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .65
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push ds
        push strict word savleague2
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x52]
        push ax
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
.65:
        cmp word [bp - 0x5c], 0x0
        jnz short .66
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgUpdatingSchedule
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov word [bp - 0x1c], 0x0
        mov byte [bp - 0x14], 0x0
.66:
        cmp word [bp - 0x5c], 0x0
        jnz short .67
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push ds
        push strict word savleague
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:OpenWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
.67:
        cmp word [bp - 0x5c], 0x0
        jnz short .68
        push 0x2
        push 0x0
        push 0x4
        lea ax, [bp - 0x1c]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.68:
        cmp word [bp - 0x5c], 0x0
        jnz short .69
        push 0xd
        push 0x0
        push 0x6
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.69:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [lggamestate], 0x0
        jnz short .70
        jmp near .74
.70:
        cmp word [bp - 0x5c], 0x0
        jnz short .71
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push ds
        push strict word savleague2
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:OpenWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
.71:
        cmp word [bp - 0x5c], 0x0
        jnz short .72
        push 0x2
        push 0x0
        push 0x4
        lea ax, [bp - 0x1c]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.72:
        cmp word [bp - 0x5c], 0x0
        jnz short .73
        push 0xd
        push 0x0
        push 0x6
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.73:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.74:
        cmp word [bp - 0x5c], 0x0
        jnz short .75
        push word [lggameidx]
        push ds
        push strict word lgschedrec
        push word [bp - 0x4a]
        call 0x20E6:WriteSchedGame
        add sp, 0x8
        mov [bp - 0x5c], ax
.75:
        cmp word [bp - 0x5c], 0x0
        jnz short .76
        cmp word [lggamestate], 0x0
        jz short .76
        push word [lggameidx]
        push ds
        push strict word lgschedrec
        push word [bp - 0x52]
        call 0x20E6:WriteSchedGame
        add sp, 0x8
        mov [bp - 0x5c], ax
.76:
        cmp word [bp - 0x5c], 0x0
        jz short .77
        jmp near .85
.77:
        cmp word [lggameidx], 0x3f0
        jnl short .78
        jmp near .83
.78:
        push word 0x3701
        push strict word str_Xx_2
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push ds
        push strict word savleague
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x50]
        push ax
        lea cx, [bp - 0x40]
        push cx
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .79
        push word [lggameidx]
        push word [bp - 0x50]
        push word [bp - 0x4a]
        call 0x28CD:PostSeriesResult
        add sp, 0x6
        mov [bp - 0x5c], ax
.79:
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x5c], 0x0
        jz short .80
        jmp near .85
.80:
        cmp word [lggamestate], 0x0
        jnz short .81
        jmp near .85
.81:
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText29]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push ds
        push strict word savleague2
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x5a]
        push ax
        lea cx, [bp - 0x40]
        push cx
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .82
        push word [lggameidx]
        push word [bp - 0x5a]
        push word [bp - 0x52]
        call 0x28CD:PostSeriesResult
        add sp, 0x6
        mov [bp - 0x5c], ax
.82:
        lea ax, [bp - 0x5a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        jmp short .85
.83:
        mov ax, [lgreadword]
        inc word [lggameidx]
        cmp [lggameidx], ax
        jng short .84
        push 0x2
        push 0x0
        push 0x0
        push ds
        push strict word lggameidx
        push word [bp - 0x4a]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.84:
        cmp word [bp - 0x5c], 0x0
        jnz short .85
        cmp word [lggamestate], 0x0
        jz short .85
        mov ax, [lgreadword2]
        cmp [lggameidx], ax
        jng short .85
        push 0x2
        push 0x0
        push 0x0
        push ds
        push strict word lggameidx
        push word [bp - 0x52]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x5c], ax
.85:
        cmp word [bp - 0x5c], 0x0
        jz short .86
        jmp near .90
.86:
        push 0x2
        push word [lghometeam]
        push word 0x3a0b
        push strict word leagueinfo_teams
        mov ax, [lggameidx]
        dec ax
        push ax
        push word 0x3701
        push strict word str_Xx_2
        push ds
        push strict word savleague
        call 0x28CD:UpdateSeasonSchedule
        add sp, 0x12
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .87
        push ds
        push strict word savleague
        push word [bp - 0x4e]
        push word [bp - 0x1e]
        push word [lghometeam]
        push word 0x3701
        push strict word str_Xx_2
        push ds
        push strict word savleague
        push cs
        call PostGameToTeamDb
        add sp, 0x12
        mov [bp - 0x5c], ax
.87:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .90
        cmp [lggamestate], ax
        jz short .88
        push 0x2
        push word [lgoppteam]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [lggameidx]
        push word 0x3701
        push strict word str_Xx
        push ds
        push strict word savleague2
        call 0x28CD:UpdateSeasonSchedule
        add sp, 0x12
        mov [bp - 0x5c], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .90
        push ds
        push strict word savleague
        push word [bp - 0x4e]
        push word [bp - 0x20]
        push word [lgoppteam]
        push word 0x3701
        push strict word str_Xx
        push ds
        push strict word savleague2
        jmp short .89
        db 0x90
.88:
        push ds
        push strict word savleague
        push word [bp - 0x4e]
        push word [bp - 0x20]
        push word [lgoppteam]
        push word 0x3701
        push strict word str_Xx_2
        push ds
        push strict word savleague
.89:
        push cs
        call PostGameToTeamDb
        add sp, 0x12
        mov [bp - 0x5c], ax
.90:
        call 0x0D90:RestoreUnderBox
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
.91:
        cmp word [bp - 0x5c], 0x0
        jz short .92
        cmp word [bp - 0x6], 0x0
        jnz short .92
        cmp word [bp - 0x5c], 0x4
        jz short .92
        lea ax, [bp - 0x54]
        push ax
        lea cx, [bp - 0x4c]
        push cx
        lea dx, [bp - 0x6e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x54]
        push ax
        lea ax, [bp - 0x4c]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgErrorWhileUpdatingDatabase
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.92:
        cmp word [lggamestate], 0x0
        jz short .93
        lea ax, [bp - 0x52]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.93:
        lea ax, [bp - 0x4a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.94:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x58], ax
        mov [bp - 0x56], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x56]
        push word [bp - 0x58]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x56]
        push word [bp - 0x58]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0BFE:InputInit
        mov word [bp - 0x6c], 0xffff
        cmp word [bp - 0x5c], 0x4
        jnz short .95
        mov word [bp - 0x5c], 0x0
.95:
        push ds
        push strict word str_Sav_2
        push ds
        push strict word str_Game_2
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x40]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        cmp word [lggameidx], 0x0
        jl short PlayLeagueGameTail + 0x2F60
        cmp word [bp - 0x5c], 0x0
        jnz short PlayLeagueGameTail + 0x2F60
        lea ax, [bp - 0x40]
        push ax
        call 0x0CD1:FileExists
        add sp, 0x2
