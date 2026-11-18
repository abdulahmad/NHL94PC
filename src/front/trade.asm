; Trade screen: jersey numbers, the player lists and the trade itself (LP.OVL)
; The first bytes finish the last routine of new_league.asm.
        add sp, 0xa
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PaintJerseyDigit                                           2A57:000A  94 PC
; One 15-pixel digit from the glyph table.
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PaintJerseyDigit:
        enter 0x2, 0x0
        push di
        push si
        mov cx, [bp + 0xa]
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        shl ax, byte 0x4
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov [bp - 0x2], ax
        mov di, [bp + 0x6]
.1:
        mov bx, [bp - 0x2]
        cmp byte [bx + si + JerseyDigitGlyphs], 0x0
        jz short .2
        mov al, [bp + 0xc]
        mov es, [bp + 0x8]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
.2:
        inc si
        cmp si, 0xf
        jl short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawJerseyNumber                                           2A57:0044  94 PC
; Two-digit jersey number.
;
; Takes 5 words of stack arguments. Calls PaintJerseyDigit. Far routine (retf).
;-----------------------------------------------------------------------------
DrawJerseyNumber:
        enter 0x4, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0x6]
        mov es, [bp + 0x8]
.1:
        mov al, [bp + 0xe]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
        inc si
        cmp si, 0x23
        jl short .1
        mov si, [bp + 0xa]
        cmp si, 0xa
        jnc short .2
        mov al, [bp + 0xe]
        push ax
        mov al, [bp + 0xc]
        push ax
        push si
        lea ax, [di + 0xa]
        push word [bp + 0x8]
        jmp short .3
        db 0x90
.2:
        mov al, [bp + 0xe]
        push ax
        mov cl, [bp + 0xc]
        push cx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov bx, 0xa
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div bx
        push ax
        mov ax, [bp + 0x8]
        push ax
        push di
        mov [bp - 0x4], di
        mov [bp - 0x2], ax
        push cs
        call PaintJerseyDigit
        add sp, 0xa
        mov al, [bp + 0xe]
        push ax
        mov al, [bp + 0xc]
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0x14
        push dx
.3:
        push ax
        push cs
        call PaintJerseyDigit
        add sp, 0xa
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; BuildTradeRoster                                           2A57:00C8  94 PC
; Roster list of a trade team.
;
; Takes 7 words of stack arguments. Calls BuildPathFar, OpenReadShared, ReadEntry744, CloseHandlePtr,
; ReadRecord52, _fstrcat. Far routine (retf).
;-----------------------------------------------------------------------------
BuildTradeRoster:
        enter 0x6e, 0x0
        push di
        push si
        mov ax, 0xffff
        mov [bp - 0x1a], ax
        mov [bp - 0x18], ax
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov ax, [bp + 0xc]
        mov dx, [bp + 0xe]
        inc ax
        inc ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
.1:
        db 0x8B, 0xFE                           ; insn: mov di, si
        add si, 0x16
        mov [di], bl
        inc bx
        cmp bx, 0x1c
        jl short .1
        mov ax, DGROUP
        mov ds, ax
        mov di, [bp + 0x6]
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word [bp + 0x8]
        push di
        lea ax, [bp - 0x3a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x1a]
        push ax
        lea ax, [bp - 0x3a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push word [bp + 0xa]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp - 0x1a]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        lea ax, [bp - 0x1a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x2]
        push word [es:DbFileNameList]
        mov ax, [bp + 0x8]
        push ax
        push di
        lea ax, [bp - 0x3a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x3a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        mov [bp - 0xe], si
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
        jmp near .14
.4:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, [bp + 0xc]
        mov dx, [bp + 0xe]
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        add ax, strict word 0x4c
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov si, [bp - 0x12]
.5:
        cmp word [bp - 0xe], 0x0
        jz short .6
        jmp near .9
.6:
        les bx, [bp - 0x16]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        cmp ax, strict word 0xffff
        jnz short .7
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jnz short .7
        mov es, [bp - 0x10]
        mov byte [es:si], 0x0
        jmp short .8
.7:
        push dx
        push ax
        lea ax, [bp - 0x6e]
        push ss
        push ax
        push word [bp - 0x18]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0xe], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .8
        mov al, [bp - 0x6c]
        mov es, [bp - 0x10]
        mov [es:si], al
        mov al, [bp - 0x6d]
        mov es, [bp - 0x10]
        mov [es:si + 0x1], al
        mov al, [bp - 0x6b]
        mov es, [bp - 0x10]
        mov [es:si + 0x3], al
        mov es, [segTeamChoiceText38]
        mov al, [es:str_Dot]
        mov es, [bp - 0x10]
        mov [es:si + 0x4], al
        mov es, [segTeamChoiceText39]
        mov al, [es:str_Space]
        mov es, [bp - 0x10]
        mov [es:si + 0x5], al
        mov es, [bp - 0x10]
        mov byte [es:si + 0x6], 0x0
        lea ax, [bp - 0x5b]
        push ss
        push ax
        lea ax, [si + 0x3]
        push word [bp - 0x10]
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
.8:
        add si, 0x16
        mov ax, [bp - 0x10]
        add word [bp - 0x16], 0x4
        inc di
        cmp di, 0x19
        jnl short .9
        jmp near .5
.9:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, [bp + 0xc]
        mov dx, [bp + 0xe]
        add ax, 0x226
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        add ax, 0xb0
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
.10:
        cmp word [bp - 0xe], 0x0
        jz short .11
        jmp near .14
.11:
        les bx, [bp - 0x16]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        cmp ax, strict word 0xffff
        jnz short .12
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jnz short .12
        mov es, [bp - 0x10]
        mov byte [es:si], 0x0
        jmp short .13
        db 0x90
.12:
        push dx
        push ax
        lea ax, [bp - 0x6e]
        push ss
        push ax
        push word [bp - 0x18]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0xe], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        mov al, [bp - 0x6c]
        mov es, [bp - 0x10]
        mov [es:si], al
        mov al, [bp - 0x6d]
        mov es, [bp - 0x10]
        mov [es:si + 0x1], al
        mov al, [bp - 0x6b]
        mov es, [bp - 0x10]
        mov [es:si + 0x3], al
        mov es, [segTeamChoiceText38]
        mov al, [es:str_Dot]
        mov es, [bp - 0x10]
        mov [es:si + 0x4], al
        mov es, [segTeamChoiceText39]
        mov al, [es:str_Space]
        mov es, [bp - 0x10]
        mov [es:si + 0x5], al
        mov es, [bp - 0x10]
        mov byte [es:si + 0x6], 0x0
        lea ax, [bp - 0x5b]
        push ss
        push ax
        lea ax, [si + 0x3]
        push word [bp - 0x10]
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
.13:
        add si, 0x16
        mov ax, [bp - 0x10]
        add word [bp - 0x16], 0x4
        inc di
        cmp di, 0x3
        jnl short .14
        jmp near .10
.14:
        lea ax, [bp - 0x18]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0xe]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TradeShowStats                                             2A57:034C  94 PC
; Stats of the player under the cursor.
;
; Takes 11 words of stack arguments. Calls AllocRecData, UseCurrentPage, ClearClipRect, BuildPathFar,
; LoadPackedHeader, FindFarMsg, SetPaletteFar, FindUnlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
TradeShowStats:
        enter 0x24, 0x0
        push di
        push si
        mov si, [bp + 0xa]
        mov word [leaguestatsmode], 0x1
        mov word [statsredrawcb], 0x2459
        mov word [statsmenucbseg], 0x1b35
        mov al, [bp + 0x8]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [statscategory], ax
        push 0x0
        push 0x0
        push word 0x270
        push word 0x1a2a
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsteambufseg], ax
        mov [statsteambuf], dx
        push 0x0
        push 0x0
        push word 0x5b0
        push strict word str_Keys_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsplayerbufseg], ax
        mov [statsplayerbuf], dx
        push 0x0
        push 0x0
        push word 0x4b0
        push strict word str_Pstat_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsskaterbufseg], ax
        mov [statsskaterbuf], dx
        push 0x0
        push 0x0
        push word 0x10e
        push strict word str_Gstat_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsgoaliebufseg], ax
        mov [statsgoaliebuf], dx
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_17
        push 0x0
        push 0x0
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        db 0x8B, 0xC7                           ; insn: mov ax, di
        push strict word str_Pal_39
        push 0x0
        lea cx, [bp - 0x1a]
        push cx
        mov [bp - 0x1c], ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x6], dx
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x20], di
        mov [bp - 0x1e], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x1
        call 0x1B35:InitMenuRemapThunk
        add sp, 0x2
        push word [bp - 0x1c]
        call 0x1B35:RosterScreenThunk
        add sp, 0x2
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x42
        push 0x41
        push 0x40
        push 0x2
        push word 0x3701
        push strict word TradeStatsMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x2
        push word 0x3701
        push strict word TradeStatsMenuBar
        call 0x1B35:StatsMenuLoopThunk
        add sp, 0xc
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov word [leaguestatsmode], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        push word [statsteambuf]
        push word [statsteambufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsgoaliebuf]
        push word [statsgoaliebufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsskaterbuf]
        push word [statsskaterbufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsplayerbuf]
        push word [statsplayerbufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsplayerbuf], ax
        mov [statsplayerbufseg], ax
        mov [statsteambuf], ax
        mov [statsteambufseg], ax
        mov [statsgoaliebuf], ax
        mov [statsgoaliebufseg], ax
        mov [statsskaterbuf], ax
        mov [statsskaterbufseg], ax
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Lineditp_2
        push 0x0
        push 0x0
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_38
        push 0x0
        lea ax, [bp - 0x1a]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x24], di
        mov [bp - 0x22], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x80
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [si + 0x2]
        push word [si]
        call 0x1E9D:LoadHomePals
        add sp, 0x4
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push si
        push word [bp + 0xc]
        push word [bp + 0x1a]
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x18]
        push word [bp + 0x16]
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0x6]
        push cs
        call DrawTradeScreen
        add sp, 0x14
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FixJerseyConflict                                          2A57:05C0  94 PC
; 'The jersey number %2d is already used'
;
; Takes 4 words of stack arguments. Calls ReadRecord52, _fstrcat, _sprintf, MouseRead, MessageBox,
; NumberEntryDialog, WriteRecord52. Far routine (retf).
;-----------------------------------------------------------------------------
FixJerseyConflict:
        enter 0x630, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x6], si
        mov di, [bp + 0xa]
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        mov es, [bp + 0xc]
        mov bx, [bp - 0x6]
        shl bx, byte 0x2
        db 0x03, 0xDF                           ; insn: add bx, di
        push word [es:bx + 0x4e]
        push word [es:bx + 0x4c]
        imul ax, [bp - 0x6], 0x34
        lea cx, [bp - 0x630]
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc word [bp - 0x6]
        cmp word [bp - 0x6], 0x1c
        jl short .1
.2:
        mov [bp - 0x4], si
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        jmp near .9
.3:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x6], di
        mov si, [bp + 0x8]
.4:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .6
        cmp [bp - 0x6], si
        jz short .5
        imul bx, si, 0x34
        lea ax, [bp - 0x62f]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov cl, [bx]
        imul bx, [bp - 0x6], 0x34
        db 0x03, 0xD8                           ; insn: add bx, ax
        cmp [bx], cl
        jnz short .5
        mov di, 0xffff
.5:
        inc word [bp - 0x6]
        cmp word [bp - 0x6], 0x1c
        jl short .4
.6:
        mov [bp - 0x2], di
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .7
        jmp near .8
.7:
        imul si, [bp + 0x8], 0x34
        push si
        lea di, [bp + si - 0x62d]
        lea si, [bp - 0x2e]
        push ss
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        xchg di, si
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        pop si
        push word 0x3701
        push strict word str_Space
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push si
        lea di, [bp + si - 0x61d]
        lea si, [bp - 0x2e]
        push ss
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
        pop si
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        add ax, strict word 0x1a
        push dx
        push ax
        mov al, [bp + si - 0x62f]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_TheJerseyNumber2dIsAlready
        lea ax, [bp - 0x80]
        push ax
        call 0x0000:_sprintf
        add sp, 0xa
        lea ax, [bp - 0x80]
        mov es, [segWorkBuffer31]
        mov [es:dlgJerseyConflict], ax
        mov [es:dlgJerseyConflict + 0x2], ss
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0xa]
        push dx
        lea bx, [bp - 0x6]
        push bx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0xa]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3a0b
        push strict word dlgJerseyConflict
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        lea ax, [bp - 0x2e]
        push ax
        push strict word str_EnterJerseyNumberForS
        lea ax, [bp - 0x80]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        mov byte [bp - 0xe], 0x0
        push 0x0
        push 0x0
        push 0x63
        push 0x1
        push -0x1
        push 0x16
        push 0x2
        lea ax, [bp - 0xe]
        push ax
        lea ax, [bp - 0x80]
        push ss
        push ax
        call 0x0D90:NumberEntryDialog
        add sp, 0x14
        mov [bp + si - 0x62f], al
        mov di, [bp + 0x8]
        shl di, byte 0x2
        les bx, [bp + 0xa]
        add bx, 0x4c
        push word [es:bx + di + 0x2]
        push word [es:bx + di]
        lea ax, [bp + si - 0x630]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteRecord52
        add sp, 0xa
        mov [bp - 0x4], ax
.8:
        cmp word [bp - 0x2], 0x0
        jz short .9
        cmp word [bp - 0x4], 0x0
        jnz short .9
        jmp near .3
.9:
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ExecuteTrade                                               2A57:078E  94 PC
; Swaps the players in the dbs.
;
; Takes 4 words of stack arguments. Calls SetDialogColors, BuildPathFar, OpenReadWriteShared,
; ReadEntry744, ReadRecord52, ClearPlayerFromLines, WriteRecord52, WriteTeamRec and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
ExecuteTrade:
        enter 0x672, 0x0
        push di
        push si
        mov ax, 0xffff
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xc], ax
        push ax
        push 0x7d
        push 0x7b
        push 0x7d
        push 0x7c
        call 0x0D90:SetDialogColors
        add sp, 0xa
        mov ax, str_Db_2
        mov cx, 0x3701
        mov [bp - 0x670], ax
        mov [bp - 0x66e], cx
        push cx
        push ax
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x14]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        mov bx, [bp + 0xa]
        push word [bx]
        lea ax, [bp - 0x384]
        push ss
        push ax
        push word [bp - 0x14]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        mov bx, [bp + 0xa]
        push word [bx + 0x2]
        lea ax, [bp - 0x66c]
        push ss
        push ax
        push word [bp - 0x14]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        push word [bp - 0x66e]
        push word [bp - 0x670]
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x2]
        push word [es:DbFileNameList]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x12]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        mov [bp - 0xa], si
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
        jmp near .16
.4:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0x2], dx
        mov di, [bp + 0xc]
.5:
        cmp word [bp - 0xa], 0x0
        jz short .6
        jmp near .16
.6:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        cmp byte [bx], 0xff
        jnz short .7
        jmp near .15
.7:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        cmp byte [bx + 0x2], 0xff
        jnz short .8
        jmp near .15
.8:
        mov word [bp - 0xc], 0xffff
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov bl, [bx]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        lea ax, [bp - 0x338]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        push dx
        push ax
        lea ax, [bp - 0x68]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0xa], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .9
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov bl, [bx + 0x2]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        lea ax, [bp - 0x620]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        push dx
        push ax
        lea ax, [bp - 0x9c]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        mov [bp - 0xa], ax
.9:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        jmp near .15
.10:
        mov bx, [bp + 0xa]
        mov al, [bx + 0x2]
        mov [bp - 0x68], al
        mov al, [bx]
        mov [bp - 0x9c], al
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov bl, [bx]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        lea ax, [bp - 0x338]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov ax, [bp - 0x10]
        mov dx, [bp - 0xe]
        mov [bx], ax
        mov [bx + 0x2], dx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov bl, [bx + 0x2]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        lea ax, [bp - 0x620]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov ax, [bp - 0x6]
        mov dx, [bp - 0x4]
        mov [bx], ax
        mov [bx + 0x2], dx
        lea ax, [bp - 0x2c8]
        push ss
        push ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx]
        push ax
        mov [bp - 0x672], bx
        call 0x1EAE:ClearPlayerFromLines
        add sp, 0x6
        lea ax, [bp - 0x298]
        push ss
        push ax
        mov bx, [bp - 0x672]
        mov al, [bx]
        push ax
        call 0x1EAE:ClearPlayerFromLines
        add sp, 0x6
        lea ax, [bp - 0x5b0]
        push ss
        push ax
        mov bx, [bp - 0x672]
        mov al, [bx + 0x2]
        push ax
        call 0x1EAE:ClearPlayerFromLines
        add sp, 0x6
        lea ax, [bp - 0x580]
        push ss
        push ax
        mov bx, [bp - 0x672]
        mov al, [bx + 0x2]
        push ax
        call 0x1EAE:ClearPlayerFromLines
        add sp, 0x6
        push word [bp - 0x4]
        push word [bp - 0x6]
        lea ax, [bp - 0x68]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:WriteRecord52
        add sp, 0xa
        mov [bp - 0xa], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
        push word [bp - 0xe]
        push word [bp - 0x10]
        lea ax, [bp - 0x9c]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:WriteRecord52
        add sp, 0xa
        mov [bp - 0xa], ax
.11:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .12
        mov bx, [bp + 0xa]
        push word [bx]
        lea ax, [bp - 0x384]
        push ss
        push ax
        push word [bp - 0x14]
        call 0x20E6:WriteTeamRec
        add sp, 0x8
        mov [bp - 0xa], ax
.12:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        mov bx, [bp + 0xa]
        push word [bx + 0x2]
        lea ax, [bp - 0x66c]
        push ss
        push ax
        push word [bp - 0x14]
        call 0x20E6:WriteTeamRec
        add sp, 0x8
        mov [bp - 0xa], ax
.13:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        lea ax, [bp - 0x384]
        push ss
        push ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bp - 0x12]
        push cs
        call FixJerseyConflict
        add sp, 0x8
        mov [bp - 0xa], ax
.14:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
        lea ax, [bp - 0x66c]
        push ss
        push ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bp - 0x12]
        push cs
        call FixJerseyConflict
        add sp, 0x8
        mov [bp - 0xa], ax
.15:
        inc si
        cmp si, 0x2
        jnl short .16
        jmp near .5
.16:
        lea ax, [bp - 0x12]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x14]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0xa], 0x0
        jz short .17
        jmp near .19
.17:
        cmp word [bp - 0xc], 0x0
        jnz short .18
        jmp near .19
.18:
        mov bx, [bp + 0xa]
        mov ax, [bx]
        mov [HomeTeamNum], ax
        mov ax, [bx + 0x2]
        mov [VisTeamNum], ax
        push word 0x3701
        push strict word CurLeagueName
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Backslash
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x3701
        push strict word str_S
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcat
        add sp, 0x8
        push word [bp - 0x66e]
        push word [bp - 0x670]
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcat
        add sp, 0x8
        mov di, HomeTeamDbName
        mov si, AwayTeamDbName
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        xchg di, si
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        push ax
        call 0x1B35:LoadGameTeamsThunk
        add sp, 0x2
        mov word [curperiod], 0xfffe
        push 0x3
        push word 0x3448
        push strict word TradeLinesMenu
        push word HomeTeamRec
        push 0x0
        call 0x1B35:GameLineEditorThunk
        add sp, 0xa
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_37
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x6]
        push word [bp - 0x8]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x3
        push word 0x3448
        push strict word TradeLinesMenu
        push word AwayTeamRec
        push 0x1
        call 0x1B35:GameLineEditorThunk
        add sp, 0xa
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_36
        call 0x14DB:AllocRecData
        add sp, 0x8
        push dx
        push ax
        push word 0x100
        push 0x0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push di
        push si
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
.19:
        mov ax, [bp - 0xa]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawTradeRow                                               2A57:0BE2  94 PC
; Draws one row of the trade screen ('%c %2d %s').
;
; Takes 1 word of stack arguments. Calls FormatCall. Far routine (retf).
;-----------------------------------------------------------------------------
DrawTradeRow:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        imul ax, si, 0x1c
        db 0x8B, 0xCE                           ; insn: mov cx, si
        shl si, 1
        add ax, [si + tradesel]
        imul ax, ax, 0x16
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        add ax, traderows + 3
        push ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + traderows_b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [bx + traderows]
        push ax
        push strict word str_C2dS_2
        mov ax, [si + tradesel]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl ax, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        shl ax, 1
        add ax, strict word 0x1d
        push ax
        imul ax, cx, word 0xe0
        add ax, strict word 0x5
        push ax
        call 0x03A3:FormatCall
        add sp, 0xc
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawTradeScreen                                            2A57:0C32  94 PC
; Plaques and both rosters.
;
; Takes 10 words of stack arguments. Calls UseOtherPage, BuildPathFar, LoadPackedHeader, FindFarMsg,
; DrawRleTransAt, FindUnlink, UseCharSeg, DrawMenuBar and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawTradeScreen:
        enter 0x28, 0x0
        push di
        push si
        call 0x0FEF:UseOtherPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embnhl_2
        push 0x0
        push 0x0
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        push 0x0
        push strict word str_Bkgd_3
        push 0x0
        lea ax, [bp - 0x22]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x12], dx
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x26], si
        mov [bp - 0x24], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x7b
        push 0x7c
        push 0x7d
        push word [bp + 0x14]
        push word [bp + 0xe]
        push word [bp + 0xc]
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push 0x1
        push word 0xc7
        push word 0x13f
        push 0x1a
        push word 0xe0
        call 0x1B35:DrawDlgFrameThunk
        add sp, 0xa
        push 0x1
        push word 0xc7
        push 0x5f
        push 0x1a
        push 0x0
        call 0x1B35:DrawDlgFrameThunk
        add sp, 0xa
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Plaque
        push 0x0
        push 0x0
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x22]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x12], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, [bp + 0x6]
        mov [bp - 0x4], ax
        mov word [bp - 0x2], tradecolour
        mov [bp - 0x14], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
.1:
        mov bx, [bp - 0x2]
        push ds
        push word [bx]
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push di
        push strict word str_S_3
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        push 0x0
        push si
        lea ax, [bp - 0x22]
        push ax
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
        add si, 0xe0
        add di, 0x2e8
        add word [bp - 0x2], 0x2
        cmp word [bp - 0x2], 0xc7a0
        jc short .1
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov word [bp - 0x10], 0x2
        mov ax, [bp + 0x16]
        inc ax
        mov [bp - 0x4], ax
.2:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        and bl, 0xfe
        mov di, [bp + 0x18]
        mov al, [bx + di]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add al, 0x40
        mov [bp - 0x2], al
        add cl, 0x60
        mov [bp - 0x1], cl
        mov bx, [bp - 0x4]
        mov al, [bx]
        mov [bp - 0x28], al
        cmp al, 0xff
        jz short .3
        db 0x8A, 0xC1                           ; insn: mov al, cl
        push ax
        mov al, [bp - 0x2]
        push ax
        mov al, [bp - 0x28]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3680
        push strict word JerseyRemapTable
        push cs
        call DrawJerseyNumber
        add sp, 0xa
        jmp short .5
.3:
        mov [bp - 0xc], si
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, 0x3680
        mov ds, ax
.4:
        mov al, [bp - 0x1]
        db 0x88, 0x85, 0x00, 0x00               ; insn: mov [di + 0x0], al
        inc di
        cmp di, 0x23
        jl short .4
        mov si, [bp - 0xc]
        mov ax, DGROUP
        mov ds, ax
.5:
        push word 0x80
        db 0x8B, 0xDE                           ; insn: mov bx, si
        and bl, 0xfe
        mov ax, [bx + tradecolour]
        add ax, 0x80
        push ds
        push ax
        push word 0x3680
        push strict word TradeRemapTable
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word 0x3680
        push strict word JerseyRemapTable
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        mov es, [segTradeMessages1]
        mov bx, [bp - 0x10]
        push word [es:bx]
        dec bx
        dec bx
        push word [es:bx]
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        add word [bp - 0x4], 0x16
        inc si
        add word [bp - 0x10], 0x4
        cmp word [bp - 0x10], strict word 0x12
        jnc short .6
        jmp near .2
.6:
        push word [bp + 0x12]
        push word [bp + 0x10]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov word [bp - 0x8], 0x5
        mov word [bp - 0x6], tradesel
        mov word [bp - 0xa], traderows
.7:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov word [bp - 0x4], 0x1d
        mov dx, [bp - 0xa]
        mov [bp - 0x2], dx
        db 0x8B, 0xF2                           ; insn: mov si, dx
.8:
        cmp byte [si], 0x0
        jz short .11
        mov bx, [bp - 0x6]
        cmp [bx], di
        jnz short .9
        mov ax, 0x7d
        jmp short .10
        db 0x90
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.10:
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        lea ax, [si + 0x3]
        push ax
        mov al, [si + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [si]
        push ax
        push strict word str_C2dS
        push word [bp - 0x4]
        push word [bp - 0x8]
        call 0x03A3:FormatCall
        add sp, 0xc
        add si, 0x16
        inc di
        add word [bp - 0x4], 0x6
        cmp word [bp - 0x4], 0xc5
        jl short .8
.11:
        add word [bp - 0x8], 0xe0
        add word [bp - 0x6], 0x2
        add word [bp - 0xa], 0x268
        cmp word [bp - 0xa], 0xc792
        jc short .7
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TradeHitTest                                               2A57:0EF8  94 PC
; Row under the pointer.
;
; Takes 5 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
TradeHitTest:
        enter 0x2, 0x0
        push di
        push si
        mov dx, [bp + 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x2], ax
        mov bx, [bp + 0xe]
        mov [bx], ax
        cmp dx, 0x5f
        jng short .5
        cmp dx, 0xe0
        jnl short .5
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, TradeHitRects
        mov ax, 0x382b
        mov es, ax
.1:
        mov ax, [bp + 0x6]
        cmp [es:bx], ax
        jg short .4
        mov ax, [es:bx]
        add ax, strict word 0x19
        cmp ax, [bp + 0x6]
        jng short .4
        mov ax, [bp + 0x8]
        cmp [es:bx + 0x2], ax
        jg short .4
        mov ax, [es:bx + 0x2]
        add ax, strict word 0x10
        cmp ax, [bp + 0x8]
        jng short .4
        mov si, [bp + 0xc]
        cmp word [si], 0x0
        jl short .2
        mov si, [si]
        shl si, 1
        add si, [bp + 0xa]
        mov [si], di
        jmp short .3
        db 0x90
.2:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [si], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        add si, [bp + 0xa]
        mov [si], di
        mov si, [bp + 0xe]
        mov word [si], 0xffff
.3:
        mov word [bp - 0x2], 0x1
.4:
        inc di
        add bx, 0x4
        cmp bx, strict word 0x10
        jc short .1
        jmp short .8
.5:
        cmp word [bp + 0x8], 0x1e
        jl short .8
        cmp word [bp + 0x8], 0xc5
        jnl short .8
        cmp dx, 0x5f
        jnl short .6
        mov bx, [bp + 0xc]
        mov [bx], ax
        jmp short .7
        db 0x90
.6:
        mov bx, [bp + 0xc]
        mov word [bx], 0x1
.7:
        mov ax, [bp + 0x8]
        sub ax, strict word 0x1d
        mov cx, 0x6
        cwd
        idiv cx
        add ax, strict word 0x64
        mov bx, [bx]
        shl bx, 1
        mov si, [bp + 0xa]
        mov [bx + si], ax
        mov word [bp - 0x2], 0x1
        mov es, [segTeamChoiceText40]
        mov word [es:itemShowPlayerStatistics + 0xC], strict word TradeShowStatsThunk
        mov word [es:itemShowPlayerStatistics + 0xE], 0x1b35
.8:
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; TradeDone                                                  2A57:0FDE  94 PC
; Menu item: done ('The trading deadline has passed!')
;
; Takes 12 words of stack arguments. Calls SetDialogColors, MouseRead, MessageBox, MouseMove. Far
; routine (retf).
;-----------------------------------------------------------------------------
TradeDone:
        enter 0x6, 0x0
        push si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0x2], dx
        mov bx, [bp + 0x1c]
.1:
        mov si, [bp - 0x2]
        cmp byte [bx + si], 0xff
        jnz short .2
        db 0x03, 0xF3                           ; insn: add si, bx
        cmp byte [si + 0x2], 0xff
        jnz short .3
.2:
        mov si, [bp - 0x2]
        cmp byte [bx + si], 0xff
        jz short .4
        db 0x03, 0xF3                           ; insn: add si, bx
        cmp byte [si + 0x2], 0xff
        jnz short .4
.3:
        mov dx, 0xffff
.4:
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0x2
        jl short .1
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .5
        push 0x0
        push 0x7d
        push 0x7b
        push 0x7d
        push 0x7c
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x2]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x6]
        push cx
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x382b
        push strict word msgThereMustBeAnEqual
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x03A3:MouseMove
        add sp, 0x4
        pop si
        leave
        retf
.5:
        mov word [tradestate], 0x1
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; TradeCancel                                                2A57:1080  94 PC
; Menu item: cancel.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
TradeCancel:
        mov word [tradestate], 0xffff
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FindTradeSlot                                              2A57:1088  94 PC
; Free slot in a roster.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
FindTradeSlot:
        enter 0x4, 0x0
        push di
        push si
        mov word [bp - 0x4], 0xffff
        db 0x2B, 0xFF                           ; insn: sub di, di
        imul ax, [bp + 0x6], word 0x268
        add ax, traderows_b2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        mov al, [si]
        cmp [bp + 0x8], al
        jz short .2
        add si, 0x16
        inc di
        cmp di, 0x1c
        jl short .1
        mov bx, [bp - 0x4]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        pop si
        pop di
        leave
        retf
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TradeScreenLoop                                            2A57:10C0  94 PC
; Trade screen input loop.
;
; Takes 12 words of stack arguments. Calls DrawTradeScreen, FindFarMsg, AllocRecData, MouseRead,
; GetBlockAt, DrawRleTransAt, FlushInputEvents, GetInputEvent and others. Far routine (retf).
;-----------------------------------------------------------------------------
TradeScreenLoop:
        enter 0xda, 0x0
        push di
        push si
        mov word [bp - 0x8], 0x7d
        mov word [bp - 0x9e], 0x7c
        mov word [bp - 0x92], 0x7b
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x90], ax
        mov [bp - 0xbc], ax
        jmp short .2
        db 0x90
.1:
        imul si, [bp - 0xbc], 0x16
        mov byte [bp + si - 0x75], 0xff
        inc word [bp - 0xbc]
.2:
        cmp word [bp - 0xbc], 0x4
        jl short .1
        push word [bp + 0xc]
        lea ax, [bp - 0x76]
        push ax
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word [bp + 0x18]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp + 0xa]
        push cs
        call DrawTradeScreen
        add sp, 0x14
        push strict word str_Pntr_10
        push word [bp + 0x16]
        push word [bp + 0x14]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0xb6], ax
        mov [bp - 0xb4], dx
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        mov [bp - 0xb2], ax
        mov [bp - 0xb0], dx
        mov ax, [bp + 0x1c]
        mov [bp - 0x9c], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa4], ax
        mov [bp - 0xa6], ax
        mov [bp - 0xa8], ax
        mov [bp - 0xaa], ax
        mov [bp - 0xac], ax
        mov [bp - 0xae], ax
        mov [bp - 0x7e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov es, [segMenuText21]
        mov [es:itemScratchPlayer + 0xE], ax
        mov [es:itemScratchPlayer + 0xC], ax
        mov [es:itemDressPlayer + 0xE], ax
        mov [es:itemDressPlayer + 0xC], ax
        les bx, [bp - 0xb6]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0xc4], ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0xc6], cx
        mov [bp - 0xc8], cx
        mov [bp - 0xca], cx
        mov [bp - 0xcc], cx
        mov [bp - 0x16], cx
        mov [bp - 0x18], cx
        push cx
        cwd
        push dx
        push ax
        push strict word str_Pointer_8
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        mov ax, [bp - 0xb6]
        mov dx, [bp - 0xb4]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x1c]
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [es:bx]
        inc cx
        les si, [bp - 0x1c]
        mov [es:si], cx
        mov es, dx
        mov ax, [es:bx + 0x2]
        inc ax
        les bx, [bp - 0x1c]
        mov [es:bx + 0x2], ax
        lea ax, [bp - 0xb8]
        push ax
        lea cx, [bp - 0xa0]
        push cx
        lea dx, [bp - 0xbc]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0xa0]
        mov [bp - 0x1e], ax
        mov ax, [bp - 0xb8]
        mov [bp - 0x7a], ax
        cmp ax, strict word 0xb
        jl short .3
        sub ax, strict word 0xb
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        mov [bp - 0xd0], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .5
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xb8]
        mov ax, [bp - 0xa0]
        sub ax, strict word 0x3
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
        mov word [tradestate], 0x0
        mov es, [segTeamChoiceText40]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemShowPlayerStatistics + 0xE], ax
        mov [es:itemShowPlayerStatistics + 0xC], ax
.7:
        mov word [bp - 0xce], 0x0
.8:
        call 0x0F99:GetInputEvent
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        lea cx, [bp - 0x7a]
        push cx
        lea cx, [bp - 0x1e]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0xce], ax
.9:
        cmp word [bp - 0x6], 0x0
        jz short .10
        test byte [bp - 0xce], 0x2
        jz short .8
.10:
        test byte [bp - 0xce], 0x2
        jnz short .19
        mov ax, [bp - 0xa0]
        cmp [bp - 0x1e], ax
        jnz short .11
        mov ax, [bp - 0xb8]
        cmp [bp - 0x7a], ax
        jnz short .11
        jmp near .111
.11:
        cmp word [bp - 0xb8], 0xb
        jl short .12
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .13
        db 0x90
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.13:
        mov [bp - 0xd2], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .14
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp short .15
        db 0x90
.14:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.15:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp word [bp - 0x7a], 0xb
        jl short .16
        mov ax, [bp - 0x7a]
        sub ax, strict word 0xb
        jmp short .17
        db 0x90
.16:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.17:
        mov [bp - 0xd4], ax
        push ax
        cmp word [bp - 0x1e], 0xb
        jnl short .18
        jmp near .102
.18:
        mov ax, [bp - 0x1e]
        sub ax, strict word 0xb
        jmp near .103
        db 0x90
.19:
        lea ax, [bp - 0xc0]
        push ax
        lea cx, [bp - 0x8e]
        push cx
        lea dx, [bp - 0x18]
        push dx
        lea dx, [bp - 0x9c]
        push dx
        push word [bp - 0x90]
        lea dx, [bp - 0xb2]
        push dx
        push word [bp - 0x7a]
        push word [bp - 0x1e]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .20
        jmp near .54
.20:
        imul bx, [bp - 0xc0], 0x16
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        les si, [bp + si - 0xb2]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .21
        jmp near .37
.21:
        mov ax, [bp - 0xc0]
        mov si, [bp - 0x8e]
        shl si, 1
        cmp [bp + si - 0xcc], ax
        jz short .22
        jmp near .31
.22:
        cmp word [bp - 0xb8], 0xb
        jl short .23
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .24
        db 0x90
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        mov [bp - 0xd6], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .25
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp short .26
        db 0x90
.25:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.26:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp + 0x1c]
        mov [bp - 0xbc], ax
        jmp short .29
.27:
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        mov ax, [bp + si - 0x8a]
        or ax, [bp + si - 0x8c]
        jz short .28
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x18], ax
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x06E1:FindUnlink
        add sp, 0x4
.28:
        dec word [bp - 0xbc]
.29:
        cmp word [bp - 0xbc], 0x0
        jnl short .27
        push word [bp + 0xe]
        push word [bp + 0x1c]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp + 0x1a]
        push word [bp + 0x18]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x76]
        push ax
        push word [bp + 0xc]
        mov bx, [tradecursor]
        shl bx, 1
        mov si, [bp + 0xc]
        push word [bx + si]
        push word [bp + 0xa]
        imul bx, [bp - 0xc0], 0x16
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        les si, [bp + si - 0xb2]
        call far [es:bx + si + 0xc]
        add sp, 0x18
        mov [bp - 0xce], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa4], ax
        mov [bp - 0xa6], ax
        mov [bp - 0xa8], ax
        mov [bp - 0xaa], ax
        mov [bp - 0xac], ax
        mov [bp - 0xae], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov [bp - 0x90], ax
        mov [bp - 0xc6], ax
        mov [bp - 0xc8], ax
        mov [bp - 0xca], ax
        mov [bp - 0x96], ax
        mov [bp - 0x98], ax
        mov [bp - 0x9a], ax
        cmp word [bp - 0xce], 0x1
        jnz short .30
        call 0x0F99:FlushInputEvents
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.30:
        push word [bp - 0xb8]
        push word [bp - 0xa0]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0xa0]
        mov [bp - 0x1e], ax
        mov ax, [bp - 0xb8]
        mov [bp - 0x7a], ax
        call 0x0F99:FlushInputEvents
        jmp near .98
.31:
        cmp word [bp - 0xb8], 0xb
        jl short .32
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .33
.32:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.33:
        mov [bp - 0xd6], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .34
        jmp near .53
.34:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.35:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        mov di, [bp - 0x8e]
        shl di, 1
        imul ax, [bp + di - 0xcc], 0x16
        add ax, [bp + si - 0xb2]
        mov dx, [bp + si - 0xb0]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        mov ax, [bp - 0xc0]
        mov di, [bp - 0x8e]
        shl di, 1
        mov [bp + di - 0xcc], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0xb2]
        mov dx, [bp + si - 0xb0]
        push dx
        push ax
.36:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp near .98
        db 0x90
.37:
        imul bx, [bp - 0xc0], 0x16
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        les si, [bp + si - 0xb2]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .38
        jmp near .50
.38:
        cmp word [bp - 0xb8], 0xb
        jl short .39
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .40
        db 0x90
.39:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.40:
        mov [bp - 0xd6], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .41
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp short .42
        db 0x90
.41:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.42:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x90]
        cmp [bp - 0x8e], ax
        jnz short .43
        jmp near .47
.43:
        mov [bp - 0xbc], ax
        jmp short .46
.44:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov word [bp + si - 0xcc], 0x0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        mov ax, [bp + si - 0x8a]
        or ax, [bp + si - 0x8c]
        jz short .45
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x18], ax
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x8a], ax
        mov [bp + si - 0x8c], ax
        mov [bp + si - 0xb0], ax
        mov [bp + si - 0xb2], ax
        mov si, [bp - 0xbc]
        shl si, 1
        mov [bp + si - 0x9c], ax
.45:
        dec word [bp - 0xbc]
.46:
        mov ax, [bp - 0xbc]
        cmp [bp - 0x8e], ax
        jl short .44
        mov ax, [bp - 0x8e]
        mov [bp - 0x90], ax
.47:
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        imul ax, [bp + di - 0xcc], 0x16
        add ax, [bp + si - 0xb2]
        mov dx, [bp + si - 0xb0]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        mov ax, [bp - 0xc0]
        mov [bp + di - 0xcc], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0xb2]
        mov dx, [bp + si - 0xb0]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0xc0], 0x16
        mov si, [bp - 0x8e]
        shl si, byte 0x2
        les di, [bp + si - 0xb2]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x90]
        mov di, [bp - 0x90]
        shl di, byte 0x2
        mov [bp + di - 0xb2], ax
        mov [bp + di - 0xb0], dx
        les si, [bp + si - 0xb2]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov si, [bp - 0x90]
        shl si, 1
        mov [bp + si - 0x9c], ax
        mov [bp - 0xd6], ax
        mov [bp - 0xda], cx
        mov [bp - 0xd8], es
        mov [bp - 0xd4], si
        mov [bp - 0xd2], di
        cmp word [bp - 0x90], 0x1
        jz short .48
        mov ax, 0x1
        jmp short .49
        db 0x90
.48:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.49:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov bx, [bp - 0xda]
        add ax, [es:bx]
        db 0x8B, 0xF7                           ; insn: mov si, di
        add ax, [bp + si - 0x1c]
        mov [bp + si - 0x18], ax
        mov ax, [es:bx + 0x6]
        add ax, [bp + si - 0x1a]
        mov [bp + si - 0x16], ax
        les bx, [bp + si - 0xb2]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        imul di, [bp - 0xd6], 0x16
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:di - 0x12]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov [bp - 0x4], ax
        mov cx, [es:di - 0x10]
        sub cx, [es:bx + 0x2]
        inc cx
        mov [bp - 0xba], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x8c], ax
        mov [bp + si - 0x8a], dx
        mov ax, [bp + si - 0x8c]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push si
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        pop si
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x4]
        mov [es:bx], cx
        mov cx, [bp - 0xba]
        mov [es:bx + 0x2], cx
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        push dx
        push ax
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        mov di, [bp - 0xd4]
        push word [bp + di - 0x9c]
        push word [bp + si - 0xb0]
        push word [bp + si - 0xb2]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0xcc], 0x0
        push word [bp - 0x92]
        push word [bp - 0x9e]
        push word [bp - 0x8]
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        push word [bp + si - 0xb0]
        push word [bp + si - 0xb2]
        jmp near .36
        db 0x90
.50:
        cmp word [bp - 0xb8], 0xb
        jl short .51
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .52
.51:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.52:
        mov [bp - 0xda], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jnl short .53
        jmp near .34
.53:
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp near .35
        db 0x90
.54:
        cmp word [bp - 0xb8], 0xb
        jl short .55
        mov ax, [bp - 0xb8]
        sub ax, strict word 0xb
        jmp short .56
.55:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.56:
        mov [bp - 0xda], ax
        push ax
        cmp word [bp - 0xa0], 0xb
        jl short .57
        mov ax, [bp - 0xa0]
        sub ax, strict word 0xb
        jmp short .58
        db 0x90
.57:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.58:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        lea ax, [bp - 0xa2]
        push ax
        push word tradecursor
        push word tradescroll
        push word [bp - 0x7a]
        push word [bp - 0x1e]
        push cs
        call TradeHitTest
        add sp, 0xa
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .59
        jmp near .98
.59:
        push word [bp + 0x1a]
        push word [bp + 0x18]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov ax, [bp + 0x1c]
        mov [bp - 0xbc], ax
        jmp short .62
        db 0x90
.60:
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        mov ax, [bp + si - 0x8a]
        or ax, [bp + si - 0x8c]
        jz short .61
        push word [bp + si - 0x16]
        push word [bp + si - 0x18]
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov si, [bp - 0xbc]
        shl si, byte 0x2
        mov [bp + si - 0x16], ax
        mov [bp + si - 0x18], ax
        push word [bp + si - 0x8a]
        push word [bp + si - 0x8c]
        call 0x06E1:FindUnlink
        add sp, 0x4
.61:
        dec word [bp - 0xbc]
.62:
        cmp word [bp - 0xbc], 0x0
        jnl short .60
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa4], ax
        mov [bp - 0xa6], ax
        mov [bp - 0xa8], ax
        mov [bp - 0xaa], ax
        mov [bp - 0xac], ax
        mov [bp - 0xae], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov [bp - 0x90], ax
        mov [bp - 0xc6], ax
        mov [bp - 0xc8], ax
        mov [bp - 0xca], ax
        mov [bp - 0x96], ax
        mov [bp - 0x98], ax
        mov [bp - 0x9a], ax
        mov bx, [tradecursor]
        shl bx, 1
        cmp word [bx + tradescroll], 0x64
        jl short .63
        jmp near .92
.63:
        cmp word [bx + tradesel], -0x1
        jnz short .64
        cmp [bp - 0xa2], ax
        jnz short .64
        jmp near .92
.64:
        mov [bp - 0x78], ax
        mov bx, [tradecursor]
        shl bx, 1
        mov ax, [bx + tradescroll]
        mov [bp - 0x7c], ax
        mov cx, [bx + tradesel]
        mov [bp - 0x2], cx
        cmp word [bp - 0xa2], 0x0
        jnz short .65
        jmp near .68
.65:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov si, [bp + 0xe]
        cmp byte [bx + si], 0xff
        jz short .67
        inc cx
        jz short .66
        mov al, [bx + si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp - 0x2]
        jz short .66
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
.66:
        mov bx, [bp - 0x7c]
        mov si, [bp + 0xe]
        mov al, [bx + si]
        push ax
        push word [tradecursor]
        push cs
        call FindTradeSlot
        add sp, 0x4
        mov bx, [tradecursor]
        shl bx, 1
        mov [bx + tradesel], ax
        mov ax, 0x7d
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
        mov al, 0xff
        mov bx, [bp - 0x7c]
        mov [bx + si], al
        imul si, bx, 0x16
        mov [bp + si - 0x75], al
        mov word [bp - 0x78], 0xffff
        mov es, [segTeamChoiceText40]
        mov word [es:itemShowPlayerStatistics + 0xC], strict word TradeShowStatsThunk
        mov word [es:itemShowPlayerStatistics + 0xE], 0x1b35
        jmp near .84
.67:
        mov word [tradecursor], 0xffff
        jmp near .84
        db 0x90
.68:
        cmp ax, strict word 0x2
        jl short .69
        jmp near .76
.69:
        cmp word [tradecursor], 0x0
        jz short .70
        jmp near .84
.70:
        mov bx, [bp + 0xe]
        mov al, [bx]
        imul cx, [tradecursor], 0x1c
        add cx, [bp - 0x2]
        imul si, cx, 0x16
        cmp [si + traderows_b2], al
        jnz short .71
        jmp near .84
.71:
        mov al, [bx + 0x1]
        cmp [si + traderows_b2], al
        jnz short .72
        jmp near .84
.72:
        mov bx, [bp - 0x7c]
        mov al, [si + traderows_b2]
        mov si, [bp + 0xe]
        mov [bx + si], al
        imul si, bx, 0x16
        lea ax, [bp + si - 0x76]
        imul cx, [tradecursor], 0x1c
        add cx, [bp - 0x2]
        imul bx, cx, 0x16
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bx + traderows]
        push ds
        pop es
        mov cx, 0xb
        rep movsw
        pop si
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx], 0x47
        jnz short .73
        cmp byte [bp + si - 0x4a], 0x47
        jnz short .75
.73:
        imul si, [bp - 0x7c], 0x16
        cmp byte [bp + si - 0x76], 0x47
        jnz short .74
        jmp near .83
.74:
        cmp byte [bp + si - 0x4a], 0x47
        jz short .75
        jmp near .83
.75:
        mov al, 0xff
        mov bx, [bp + 0xe]
        mov si, [bp - 0x7c]
        mov [bx + si + 0x2], al
        imul si, si, 0x16
        mov [bp + si - 0x49], al
        jmp near .83
.76:
        cmp ax, strict word 0x4
        jl short .77
        jmp near .84
.77:
        cmp word [tradecursor], 0x1
        jz short .78
        jmp near .84
.78:
        mov bx, [bp + 0xe]
        mov al, [bx + 0x2]
        imul cx, [tradecursor], 0x1c
        add cx, [bp - 0x2]
        imul si, cx, 0x16
        cmp [si + traderows_b2], al
        jnz short .79
        jmp near .84
.79:
        mov al, [bx + 0x3]
        cmp [si + traderows_b2], al
        jnz short .80
        jmp near .84
.80:
        mov bx, [bp - 0x7c]
        mov al, [si + traderows_b2]
        mov si, [bp + 0xe]
        mov [bx + si], al
        imul si, bx, 0x16
        lea ax, [bp + si - 0x76]
        imul cx, [tradecursor], 0x1c
        add cx, [bp - 0x2]
        imul bx, cx, 0x16
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bx + traderows]
        push ds
        pop es
        mov cx, 0xb
        rep movsw
        pop si
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx], 0x47
        jnz short .81
        cmp byte [bp + si - 0xa2], 0x47
        jnz short .82
.81:
        imul si, [bp - 0x7c], 0x16
        cmp byte [bp + si - 0x76], 0x47
        jz short .83
        cmp byte [bp + si - 0xa2], 0x47
        jnz short .83
.82:
        mov al, 0xff
        mov bx, [bp + 0xe]
        mov si, [bp - 0x7c]
        mov [bx + si - 0x2], al
        imul si, si, 0x16
        mov [bp + si - 0xa1], al
.83:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
        mov es, [segTeamChoiceText40]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemShowPlayerStatistics + 0xE], ax
        mov [es:itemShowPlayerStatistics + 0xC], ax
        mov ax, 0xffff
        mov bx, [tradecursor]
        shl bx, 1
        mov [bx + tradesel], ax
        mov [tradecursor], ax
        mov [bp - 0x78], ax
.84:
        cmp word [bp - 0x78], 0x0
        jnz short .85
        jmp near .97
.85:
        mov word [bp - 0xbc], 0x0
        jmp short .89
.86:
        mov word [bp - 0xc2], 0x0
        mov es, [segCharTable2]
.87:
        mov al, [bp - 0x94]
        mov bx, [bp - 0xc2]
        db 0x26, 0x88, 0x87, 0x00, 0x00         ; insn: mov [es:bx + 0x0], al
        inc word [bp - 0xc2]
        cmp word [bp - 0xc2], 0x23
        jl short .87
.88:
        push word 0x80
        mov bx, [bp - 0xbc]
        and bl, 0xfe
        mov ax, [bx + tradecolour]
        add ax, 0x80
        push ds
        push ax
        push word 0x3680
        push strict word TradeRemapTable
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word 0x3680
        push strict word JerseyRemapTable
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        mov es, [segTradeMessages1]
        mov bx, [bp - 0xbc]
        shl bx, byte 0x2
        db 0x26, 0xFF, 0xB7, 0x02, 0x00         ; insn: push word [es:bx + 0x2]
        db 0x26, 0xFF, 0xB7, 0x00, 0x00         ; insn: push word [es:bx + 0x0]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        inc word [bp - 0xbc]
.89:
        cmp word [bp - 0xbc], 0x4
        jl short .90
        jmp near .97
.90:
        mov bx, [bp + 0xe]
        mov si, [bp - 0xbc]
        cmp byte [bx + si], 0xff
        jnz short .91
        jmp near .86
.91:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        and bl, 0xfe
        mov di, [bp + 0xc]
        mov al, [bx + di]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add al, 0x40
        mov [bp - 0xbe], al
        add cl, 0x60
        mov [bp - 0x94], cl
        push cx
        push ax
        imul si, si, 0x16
        mov al, [bp + si - 0x75]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3680
        push strict word JerseyRemapTable
        push cs
        call DrawJerseyNumber
        add sp, 0xa
        jmp near .88
        db 0x90
.92:
        mov bx, [tradecursor]
        shl bx, 1
        cmp word [bx + tradescroll], 0x64
        jnl short .93
        jmp near .97
.93:
        sub word [bx + tradescroll], 0x64
        mov ax, [bx + tradescroll]
        imul cx, [tradecursor], 0x1c
        db 0x03, 0xC8                           ; insn: add cx, ax
        imul si, cx, 0x16
        cmp byte [si + traderows], 0x0
        jnz short .94
        jmp near .97
.94:
        cmp ax, [bx + tradesel]
        jnz short .95
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
        mov ax, 0xffff
        mov bx, [tradecursor]
        shl bx, 1
        mov [bx + tradesel], ax
        mov [tradecursor], ax
        mov es, [segTeamChoiceText40]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemShowPlayerStatistics + 0xE], ax
        mov [es:itemShowPlayerStatistics + 0xC], ax
        jmp short .97
        db 0x90, 0x90
.95:
        mov bx, [tradecursor]
        shl bx, 1
        cmp word [bx + tradesel], -0x1
        jz short .96
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
.96:
        mov bx, [tradecursor]
        shl bx, 1
        mov ax, [bx + tradescroll]
        mov [bx + tradesel], ax
        mov ax, 0x7d
        mov dx, 0x7c
        call 0x03A3:SetCharPtr.regs
        push word [tradecursor]
        push cs
        call DrawTradeRow
        add sp, 0x2
.97:
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
.98:
        cmp word [tradestate], 0x0
        jz short .99
        jmp near .111
.99:
        cmp word [bp - 0x7a], 0xb
        jl short .100
        mov ax, [bp - 0x7a]
        sub ax, strict word 0xb
        jmp short .101
.100:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.101:
        mov [bp - 0xda], ax
        push ax
        cmp word [bp - 0x1e], 0xb
        jl short .102
        jmp near .18
.102:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.103:
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        mov ax, [bp - 0x7a]
        les bx, [bp - 0xb2]
        cmp [es:bx + 0x6], ax
        jl short .104
        jmp near .110
.104:
        cmp word [bp - 0x1e], 0x5f
        jg short .105
        jmp near .110
.105:
        cmp word [bp - 0x1e], 0xe0
        jl short .106
        jmp near .110
.106:
        cmp word [tradecursor], -0x1
        jnz short .107
        jmp near .110
.107:
        mov bx, [tradecursor]
        shl bx, 1
        cmp word [bx + tradesel], -0x1
        jnz short .108
        jmp near .110
.108:
        mov cx, [bp - 0xac]
        or cx, [bp - 0xae]
        jz short .109
        lea cx, [bp - 0xc0]
        push cx
        lea cx, [bp - 0x8e]
        push cx
        lea cx, [bp - 0x18]
        push cx
        lea cx, [bp - 0x9c]
        push cx
        push word [bp - 0x90]
        lea cx, [bp - 0xb2]
        push cx
        push ax
        push word [bp - 0x1e]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .109
        jmp near .110
.109:
        mov bx, [tradecursor]
        shl bx, 1
        mov si, [bp + 0xc]
        mov al, [bx + si]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add al, 0x40
        mov [bp - 0xbe], al
        add cl, 0x60
        mov [bp - 0x94], cl
        push cx
        push ax
        imul ax, [tradecursor], 0x1c
        add ax, [bx + tradesel]
        imul bx, ax, 0x16
        mov al, [bx + traderows_b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x3680
        push strict word JerseyRemapTable
        push cs
        call DrawJerseyNumber
        add sp, 0xa
        push word 0x80
        mov bx, [tradecursor]
        shl bx, 1
        mov ax, [bx + tradecolour]
        add ax, 0x80
        push ds
        push ax
        push word 0x3680
        push strict word TradeRemapTable
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word 0x3680
        push strict word JerseyRemapTable
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        mov ax, [bp - 0x7a]
        sub ax, strict word 0xb
        push ax
        mov ax, [bp - 0x1e]
        sub ax, strict word 0xb
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
.110:
        push word [bp - 0x7a]
        mov ax, [bp - 0x1e]
        sub ax, strict word 0x3
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x1e]
        mov [bp - 0xa0], ax
        mov ax, [bp - 0x7a]
        mov [bp - 0xb8], ax
.111:
        cmp word [tradestate], 0x0
        jnz short .112
        jmp near .7
.112:
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [tradestate], 0x0
        jng short .113
        mov word [tradestate], 0x0
.113:
        mov ax, [tradestate]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; TradeRosterCmp                                             2A57:1F1C  94 PC
; Qsort comparator of roster rows.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
TradeRosterCmp:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x8]
        mov di, [bp + 0x6]
        mov al, [si]
        cmp [di], al
        jnz short .2
        cmp byte [di], 0x0
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.1:
        lea si, [si + 0x6]
        lea di, [di + 0x6]
        xchg si, di
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        repe cmpsb
        jz short .6
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        sbb ax, strict word 0xffff
        pop si
        pop di
        leave
        retf
.2:
        cmp byte [di], 0x0
        jz short .5
        cmp byte [si], 0x0
        jnz short .4
.3:
        mov ax, 0xffff
        pop si
        pop di
        leave
        retf
        db 0x90
.4:
        cmp byte [di], 0x4c
        jz short .3
        cmp byte [si], 0x4c
        jz short .5
        cmp byte [di], 0x43
        jz short .3
        cmp byte [si], 0x43
        jz short .5
        cmp byte [di], 0x52
        jz short .3
        cmp byte [si], 0x52
        jz short .5
        cmp byte [di], 0x44
        jz short .3
.5:
        mov ax, 0x1
.6:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TradeScreen                                                2A57:1F96  94 PC
; Sets up and runs the trade screen.
;
; Takes 7 words of stack arguments. Calls UseCurrentPage, ClearClipRect, GetPage, UseOtherPage,
; CopyPlane, SaveCharTab, LoadRawHeader, UseCharSeg and others. Far routine (retf).
;-----------------------------------------------------------------------------
TradeScreen:
        enter 0x610, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:GetPage
        dec ax
        jnz short .1
        call 0x0FEF:UseOtherPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:CopyPlane
.1:
        mov si, [bp + 0xa]
        lea ax, [bp - 0x3c]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push 0x0
        push strict word str_LineditFnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        push dx
        push ax
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Lineditp
        push 0x0
        push 0x0
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Shrt
        push 0x0
        lea ax, [bp - 0x24]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        push dx
        push ax
        mov [bp - 0x610], ax
        mov [bp - 0x60e], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        push strict word str_Pal_35
        push word [bp - 0x60e]
        push word [bp - 0x610]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x80
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [si + 0x2]
        push word [si]
        call 0x1E9D:LoadHomePals
        add sp, 0x4
        mov word [tradecolour], TeamPalette2
        mov word [tradecolour2], TeamPalette1
        mov ax, 0xffff
        mov [tradesel], ax
        mov [tradesel2], ax
        mov [tradescroll], ax
        mov [tradescroll2], ax
        mov [tradecursor], ax
        lea ax, [bp - 0x60c]
        push ss
        push ax
        push ds
        push strict word traderows
        push word [si]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call BuildTradeRoster
        add sp, 0xe
        mov [bp - 0x6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        lea ax, [bp - 0x324]
        push ss
        push ax
        push ds
        push strict word traderoster
        push word [si + 0x2]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call BuildTradeRoster
        add sp, 0xe
        mov [bp - 0x6], ax
.2:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push word 0x2a57
        push strict word TradeRosterCmp
        push 0x16
        push 0x1c
        push word traderows
        call 0x0000:_qsort
        add sp, 0xa
        push word 0x2a57
        push strict word TradeRosterCmp
        push 0x16
        push 0x1c
        push word traderoster
        call 0x0000:_qsort
        add sp, 0xa
        push word [bp + 0x12]
        push word [bp - 0xc]
        push word [bp - 0xe]
        push word [bp - 0x10]
        push di
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push si
        lea ax, [bp - 0x60c]
        push ax
        push word [bp - 0x14]
        push word [bp - 0x16]
        push cs
        call TradeScreenLoop
        add sp, 0x18
        mov [bp - 0x6], ax
.3:
        mov ax, [bp - 0x10]
        push ax
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        lea ax, [bp - 0x3c]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0xc]
        push word [bp - 0xe]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [bp - 0x6]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; TradePlayers                                               2A57:2152  94 PC
; 'Select two teams for trading players'
;
; Calls LeagueCheckAlwaysZero, ReadLeagueInfo, SetDialogColors, MouseRead, _fstrcpy, _fstrcspn, MessageBox,
; MergeLeagueFiles and others.
;-----------------------------------------------------------------------------
TradePlayers:
        enter 0x5a, 0x0
        push si
        mov word [bp - 0x4], 0xffff
        mov al, 0xff
        mov [bp - 0x2a], al
        mov [bp - 0x29], al
        mov [bp - 0x28], al
        mov [bp - 0x27], al
        push 0x2
        push word 0x3701
        push strict word CurLeagueName
        call 0x2305:LeagueCheckAlwaysZero
        add sp, 0x6
        mov [bp - 0x3e], ax
.1:
        mov word [bp - 0x26], 0x0
        cmp word [bp - 0x3e], 0x0
        jnz short .2
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
        mov [bp - 0x3e], ax
.2:
        cmp word [bp - 0x3e], 0x0
        jz short .3
        jmp near .7
.3:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x32]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x4e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x4c]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x4c]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], si
        mov byte [bp + si - 0x4c], 0x0
        mov es, [segWorkBuffer32]
        cmp word [es:leagueinfo_w6], 0x0
        jz short .5
        lea ax, [bp - 0x4c]
        mov es, [segTeamChoiceText41]
        mov [es:msgThereIsASavedGame + 0x4], ax
        mov [es:msgThereIsASavedGame + 0x6], ss
        push -0x1
        lea ax, [bp - 0x32]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push es
        push word 0xb32
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.4:
        mov word [bp - 0x3e], 0xffff
        jmp near .7
        db 0x90
.5:
        mov es, [segWorkBuffer33]
        test byte [es:leagueinfo_w4], 0x4
        jnz short .6
        lea ax, [bp - 0x4c]
        mov es, [segTeamChoiceText42]
        mov [es:msgMasterDatabasesFor + 0x4], ax
        mov [es:msgMasterDatabasesFor + 0x6], ss
        push -0x1
        lea ax, [bp - 0x32]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgMergeFirst
        push 0x4
        push es
        push word 0x8af
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x4e], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        call 0x2CB7:MergeLeagueFiles
        mov word [bp - 0x26], 0xffff
        jmp short .7
        db 0x90
.6:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x1
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x24]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        mov [bp - 0x3e], ax
.7:
        cmp word [bp - 0x26], 0x0
        jz short .8
        jmp near .1
.8:
        cmp byte [lgflags], 0x0
        jnz short .9
        jmp near .10
.9:
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push strict word str_Pal_34
        push 0x0
        push strict word str_EasndeskQpp
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x56], ax
        mov [bp - 0x54], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x52], ax
        mov [bp - 0x50], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [bp - 0x54]
        push word [bp - 0x56]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov al, 0x17
        mov [bp - 0x5a], al
        mov [bp - 0x59], al
        mov [bp - 0x58], al
        lea ax, [bp - 0x5a]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x2a
        mov [bp - 0x5a], al
        mov [bp - 0x59], al
        mov [bp - 0x58], al
        lea ax, [bp - 0x5a]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x3f
        mov [bp - 0x5a], al
        mov [bp - 0x59], al
        mov [bp - 0x58], al
        lea ax, [bp - 0x5a]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.10:
        cmp word [bp - 0x3e], 0x0
        jz short .11
        jmp near TradePlayersTail + 0x2600
.11:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText37]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x24]
        push cx
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x3e], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .12
        push 0x2
        push ax
        push ax
        lea ax, [bp - 0x30]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x3e], ax
.12:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        cmp word [bp - 0x30], 0x459
        jnl short .13
        push word [bp - 0x30]
        lea ax, [bp - 0x38]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x0CD1:ReadEntry6
        add sp, 0x8
        mov [bp - 0x3e], ax
.13:
        lea ax, [bp - 0x4]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x3e], 0x0
        jz short .14
        jmp near .18
.14:
        cmp byte [bp - 0x38], 0x3
        jnz short .15
        cmp byte [bp - 0x37], 0x14
        jnc short .17
.15:
        cmp byte [bp - 0x38], 0x3
        jna short .16
        cmp byte [bp - 0x38], 0xa
        jc short .17
.16:
        cmp word [bp - 0x30], 0x3f0
        jl short .18
.17:
        lea ax, [bp - 0x32]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x4e]
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
        lea ax, [bp - 0x32]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x4e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x32]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x382b
        push strict word msgTheTradingDeadlineHasPassed
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov word [bp - 0x3e], 0xffff
.18:
        cmp word [bp - 0x3e], 0x0
        jz short .19
        jmp near TradePlayersTail + 0x2600
.19:
        mov es, [segWorkBuffer34]
        cmp word [es:leagueinfo_w2], 0x1
        jnz short .20
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x32]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x4e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x32]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3701
        push strict word msgThereIsOnlyOneHuman
        jmp near .24
        db 0x90
.20:
        lea ax, [bp - 0x3c]
        push ax
        push word 0x3701
        push strict word str_SelectTwoTeamsForTrading
        push 0x10
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
        cmp word [bp - 0x3c], 0x0
        jl short .23
        cmp word [bp - 0x3a], 0x0
        jl short .23
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x3c]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
        mov [bp - 0x2e], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .21
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x3a]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
        mov [bp - 0x2e], ax
.21:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .22
        push 0x2
        push word 0x3701
        push strict word TradeMenu
        lea ax, [bp - 0x2a]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call TradeScreen
        add sp, 0xe
        mov [bp - 0x2e], ax
.22:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .23
        lea ax, [bp - 0x2a]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call ExecuteTrade
        add sp, 0x8
        mov [bp - 0x3e], ax
.23:
        cmp word [bp - 0x3e], 0x0
        jz short TradePlayersTail + 0x2600
        lea ax, [bp - 0x32]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x4e]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x32]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgErrorWhileTradingPlayers
.24:
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
