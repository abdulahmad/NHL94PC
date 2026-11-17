; Locker room screen and its input loop (MENUS.OVL)
; The first bytes finish the last routine of sound_config.asm.
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LockerRoomScreen                                           25DD:0006  94 PC
; Draws the locker room screen.
;
; Calls GetPaletteFar, VgaCopyBytes, DrawLockerRoom, LockerRoomLoop, CopyPlane, FadePaletteInThunk.
; Far routine (retf).
;-----------------------------------------------------------------------------
LockerRoomScreen:
        enter 0x300, 0x0
        push si
        lea ax, [bp - 0x300]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push cs
        call DrawLockerRoom
        push cs
        call LockerRoomLoop
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        cmp word [DbSaveMode], 0x0
        jnz short .1
        push 0x10
        lea ax, [bp - 0x300]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.1:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawLockerRoom                                             25DD:006E  94 PC
; Lockrm background, jerseys.
;
; Calls UseOtherPage, BuildPathFar, LoadPackedHeader, FindFarMsg, DrawRleTransFastHere, FindUnlink,
; DrawRleFastHere, VgaCopyBytes and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLockerRoom:
        enter 0x62a, 0x0
        push di
        push si
        call 0x0FEF:UseOtherPage
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x624], ax
        mov [bp - 0x622], cx
        push cx
        push ax
        push ds
        push strict word str_Lockrm
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_P01_4
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov si, [bp - 0x2]
        mov [bp - 0xa], di
        mov es, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0x320], al
        inc si
        cmp si, 0x180
        jl short .1
        mov di, [bp - 0x12]
        push strict word str_0000_6
        push word [bp - 0x10]
        push di
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransFastHere
        add sp, 0x4
        push word [bp - 0x10]
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x622]
        push word [bp - 0x624]
        push ds
        push strict word str_Exhgame2
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Botm
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        cmp word [DbSaveMode], 0x0
        jnz short .2
        push strict word str_Top
        jmp short .3
        db 0x90
.2:
        push strict word str_Head
.3:
        push word [bp - 0x10]
        push di
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        push word [bp - 0x10]
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0x3f00
        push 0x0
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        mov bx, [HomeTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        push strict word str_JerSh_2
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        push word [bp - 0x622]
        push word [bp - 0x624]
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push strict word str_P01_3
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x240
        mov [bp - 0xa], si
        mov [bp - 0x12], di
        mov si, [bp - 0x2]
        les cx, [bp - 0xa]
.4:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0x320], al
        inc si
        cmp si, 0x300
        jl short .4
        push word 0xaf
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x13f
        mov bx, 0x2e
        call 0x0FEF:SetClipRectRegs
        push strict word str_0000_5
        push word [bp - 0x10]
        push di
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word [bp - 0x10]
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov bx, [VisTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        push strict word str_JerSv_2
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        push word [bp - 0x622]
        push word [bp - 0x624]
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push strict word str_P01_2
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x180
        mov [bp - 0x12], di
        mov [bp - 0xa], si
        mov si, [bp - 0x2]
        les di, [bp - 0xa]
.5:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0x320], al
        inc si
        cmp si, 0x240
        jl short .5
        mov di, [bp - 0x12]
        push strict word str_0000_4
        mov ax, [bp - 0x10]
        push ax
        push di
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push si
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0xc7
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x13f
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x46
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x6a
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xc6
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xea
        call 0x0FEF:FillRect
        add sp, 0xa
        mov ax, 0x4a
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        cmp word [DbSaveMode], 0x0
        jnz short .6
        mov ax, [HomeTeamNum]
        add ax, strict word 0x19
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .7
        inc si
        inc si
        jmp short .7
        db 0x90
.6:
        mov ax, [HomeTeamNum]
        add ax, strict word 0x17
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, [VisTeamNum]
        jnz short .7
        lea ax, [si + 0x17]
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
.7:
        push word 0xbb
        push 0x46
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        cmp word [DbSaveMode], 0x0
        jnz short .8
        mov ax, [HomeTeamNum]
        inc ax
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .9
        inc si
        inc si
        jmp short .9
.8:
        mov ax, [HomeTeamNum]
        inc ax
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov [bp - 0x626], si
.9:
        push word 0xbb
        push 0x6b
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        cmp word [DbSaveMode], 0x0
        jnz short .10
        mov ax, [VisTeamNum]
        add ax, strict word 0x19
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .11
        inc si
        inc si
        jmp short .11
        db 0x90
.10:
        mov ax, [VisTeamNum]
        add ax, strict word 0x17
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov [bp - 0x628], si
.11:
        push word 0xbb
        push word 0xc6
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        cmp word [DbSaveMode], 0x0
        jnz short .12
        mov ax, [VisTeamNum]
        inc ax
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .13
        inc si
        inc si
        jmp short .13
.12:
        mov ax, [VisTeamNum]
        inc ax
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov [bp - 0x62a], si
.13:
        push word 0xbb
        push word 0xeb
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        cmp word [DbSaveMode], 0x0
        jnz short .14
        push 0x52
        push 0x6
        push 0x5b
        push 0x15
        push 0x3b
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x5b
        jmp short .15
        db 0x90
.14:
        push 0x52
        push 0x6
        push 0x39
        push 0x15
        push 0x5d
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x39
.15:
        push 0x15
        push word 0xaa
        call 0x0FEF:FillRect
        add sp, 0xa
        mov bx, [HomeTeamNum]
        shl bx, 1
        push word [bx + 0x218]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        mov si, 0x97
        db 0x2B, 0xF0                           ; insn: sub si, ax
        push 0x15
        push si
        mov bx, [HomeTeamNum]
        shl bx, 1
        push word [bx + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x15
        push word 0xaa
        mov bx, [VisTeamNum]
        shl bx, 1
        push word [bx + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
        cmp word [DbSaveMode], 0x1
        jnz short .16
        push 0x52
        push 0x6
        push 0x7c
        push 0xc
        push 0x62
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0xc
        mov es, [segDbFiles5]
        mov bx, [VisTeamNum]
        shl bx, 1
        mov bx, [es:bx + 0x128]
        mov si, [HomeTeamNum]
        shl si, 1
        or bx, [es:si + 0x128]
        shl bx, 1
        mov bx, [bx + LockerItemTable]
        shl bx, 1
        push word [bx + LockerTextPtrs]
        call 0x0FEC:DrawTextCenteredInWindow
        add sp, 0x4
.16:
        lea ax, [bp - 0x620]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x620]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push 0x10
        lea ax, [bp - 0x320]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        db 0x2B, 0xF6                           ; insn: sub si, si
.17:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [si + TeamPalette2], al
        inc si
        cmp si, 0x100
        jl short .17
        mov byte [g_B1D4], 0x2c
        mov byte [g_B1D5], 0x1
        mov byte [g_B1CB], 0x2f
        mov byte [g_B1D7], 0x32
        mov byte [g_B1D8], 0x3a
        mov byte [g_B20D], 0x19
        mov byte [g_B1DA], 0x51
        mov byte [g_B224], 0x18
        mov byte [g_B1C9], 0x7f
        mov al, 0x6d
        mov [g_B215], al
        mov [g_B2BF], al
        mov al, 0x6e
        mov [g_B214], al
        mov [g_B2C0], al
        mov byte [g_B2C1], 0x70
        mov byte [g_B2C2], 0x58
        push ds
        push strict word TeamPalette2
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LockerHitTest                                              25DD:05F0  94 PC
; Item under the pointer.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
LockerHitTest:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov di, [bp + 0x6]
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov bx, 0x0
        mov ax, 0x36b4
        mov ds, ax
.1:
        cmp [bx], di
        jg short .2
        cmp [bx + 0x4], di
        jl short .2
        mov ax, [bp + 0x8]
        cmp [bx + 0x2], ax
        jg short .2
        cmp [bx + 0x6], ax
        jnl short .3
.2:
        inc cx
        add bx, 0x8
        cmp bx, strict word 0x40
        jc short .1
        mov ax, DGROUP
        mov ds, ax
        jmp short .4
.3:
        mov ax, DGROUP
        mov ds, ax
        mov bx, [bp + 0xa]
        mov [bx], cx
        mov ax, 0x1
        pop di
        leave
        retf
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawLockerJersey                                           25DD:063E  94 PC
; 'JER%sV' / 'JER%sH'
;
; Takes 5 words of stack arguments. Calls VgaCopyRect, UseOtherPage, _sprintf, _fstrcat,
; LoadPackedHeader, FindFarMsg, SetClipRectRegs, DrawRleTransBody and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLockerJersey:
        enter 0xe0, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        push word 0x81
        push 0x28
        push 0x2e
        cmp di, 0x1
        cmc
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x28
        push ax
        push word 0x7e00
        push 0x0
        call 0x0000:VgaCopyRect
        add sp, 0xc
        call 0x0FEF:UseOtherPage
        mov bx, [bp + 0x8]
        shl bx, 1
        mov [bp - 0xe0], bx
        push word [bx + TeamNameClips]
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        mov ax, str_JerSv
        jmp short .2
.1:
        mov ax, str_JerSh
.2:
        push ax
        lea ax, [bp - 0x1e]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        push word 0x3701
        push strict word str_Qpp
        lea ax, [bp - 0x1e]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push strict word str_P01
        push 0x0
        lea ax, [bp - 0x1e]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .4
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, dx
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx + 0x180]
        mov [bp + si - 0xde], al
        inc si
        cmp si, 0xc0
        jl short .3
        jmp short .6
        db 0x90
.4:
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov es, dx
.5:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx + 0x240]
        mov [bp + si - 0xde], al
        inc si
        cmp si, 0xc0
        jl short .5
.6:
        push word 0xaf
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x13f
        mov bx, 0x2e
        call 0x0FEF:SetClipRectRegs
        push strict word str_0000_3
        push word [bp - 0xe]
        push word [bp - 0x10]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word [bp - 0xe]
        push word [bp - 0x10]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0xc7
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x13f
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        mov ax, 0x4a
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        cmp word [DbSaveMode], 0x1
        jnz short .7
        push 0x52
        push 0x6
        push 0x7c
        push 0xc
        push 0x62
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0xc
        mov bx, [bp + 0xa]
        shl bx, 1
        mov bx, [bx + LockerItemTable]
        shl bx, 1
        push word [bx + LockerTextPtrs]
        call 0x0FEC:DrawTextCenteredInWindow
        add sp, 0x4
.7:
        cmp word [DbSaveMode], 0x0
        jz short .8
        jmp near .16
.8:
        cmp word [bp + 0x6], 0x0
        jnz short .9
        jmp near .13
.9:
        mov di, [bp + 0x8]
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xc6
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xea
        call 0x0FEF:FillRect
        add sp, 0xa
        lea ax, [di + 0x19]
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .10
        inc si
        inc si
.10:
        push word 0xbb
        push word 0xc6
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [di + 0x1]
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .11
        inc si
        inc si
.11:
        push word 0xbb
        push word 0xeb
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x52
        push 0x6
        push 0x5b
        push 0x15
        push word 0xaa
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x15
        push word 0xaa
        mov bx, [bp - 0xe0]
        push word [bx + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [bp - 0xde]
        push ss
        push ax
        push 0x40
        push word 0x80
.12:
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        jmp near .21
        db 0x90
.13:
        mov di, [bp + 0x8]
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x46
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x6a
        call 0x0FEF:FillRect
        add sp, 0xa
        lea ax, [di + 0x19]
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .14
        inc si
        inc si
.14:
        push word 0xbb
        push 0x46
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [di + 0x1]
        mov cx, 0x1a
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, 0x18
        jl short .15
        inc si
        inc si
.15:
        push word 0xbb
        push 0x6b
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x52
        push 0x6
        push 0x5b
        push 0x15
        push 0x3b
        call 0x0FEF:FillRect
        add sp, 0xa
        mov bx, [bp - 0xe0]
        push word [bx + 0x218]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        mov si, 0x97
        db 0x2B, 0xF0                           ; insn: sub si, ax
        push 0x15
        push si
        mov bx, [bp - 0xe0]
        push word [bx + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [bp - 0xde]
        push ss
        push ax
        push 0x40
        push word 0xc0
        jmp near .12
        db 0x90
.16:
        mov di, [bp + 0xc]
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xc6
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push word 0xea
        call 0x0FEF:FillRect
        add sp, 0xa
        mov ax, [bp + 0xe]
        add ax, strict word 0x17
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jnz short .17
        lea ax, [si + 0x17]
        mov cx, 0x18
        cwd
        idiv cx
.17:
        push word 0xbb
        push word 0xc6
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        mov ax, [bp + 0xe]
        inc ax
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jnz short .18
        lea ax, [si + 0x1]
        mov cx, 0x18
        cwd
        idiv cx
.18:
        push word 0xbb
        push word 0xeb
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x52
        push 0x6
        push 0x39
        push 0x15
        push word 0xaa
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x15
        push word 0xaa
        mov bx, [bp + 0xe]
        shl bx, 1
        push word [bx + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x46
        call 0x0FEF:FillRect
        add sp, 0xa
        push 0x52
        push 0x6
        push 0x11
        push word 0xbb
        push 0x6a
        call 0x0FEF:FillRect
        add sp, 0xa
        lea ax, [di + 0x17]
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, [bp + 0xe]
        jnz short .19
        lea ax, [si + 0x17]
        mov cx, 0x18
        cwd
        idiv cx
.19:
        push word 0xbb
        push 0x46
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        lea ax, [di + 0x1]
        mov cx, 0x18
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cmp si, [bp + 0xe]
        jnz short .20
        lea ax, [si + 0x1]
        mov cx, 0x18
        cwd
        idiv cx
.20:
        push word 0xbb
        push 0x6b
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        push word [bx + TeamNameClips]
        call 0x0FEF:DrawText
        add sp, 0x6
        push 0x52
        push 0x6
        push 0x39
        push 0x15
        push 0x5d
        call 0x0FEF:FillRect
        add sp, 0xa
        shl di, 1
        push word [di + 0x218]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        mov si, 0x97
        db 0x2B, 0xF0                           ; insn: sub si, ax
        push 0x15
        push si
        push word [di + 0x218]
        call 0x0FEF:DrawText
        add sp, 0x6
.21:
        cmp word [bp + 0x6], 0x0
        jz short .22
        lea ax, [bp - 0xde]
        push ss
        push ax
        push 0x40
        push word 0x80
        jmp short .23
        db 0x90
.22:
        lea ax, [bp - 0xde]
        push ss
        push ax
        push 0x40
        push word 0xc0
.23:
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LockerRoomLoop                                             25DD:0AC8  94 PC
; Input loop of the locker room screen.
;
; Calls MouseRead, UseCurrentPage, DrawRleTransRemapFastAt, FlushInputEvents, GetInputEvent,
; VgaCopyRect, LockerHitTest, DrawLockerJersey and others. Far routine (retf).
;-----------------------------------------------------------------------------
LockerRoomLoop:
        enter 0x318, 0x0
        mov ax, [VisTeamNum]
        mov [bp - 0x14], ax
        mov ax, [HomeTeamNum]
        mov [bp - 0x318], ax
        cmp ax, [ctl1team]
        jnz short .1
        mov word [ctl1team], 0x1
        jmp short .2
        db 0x90
.1:
        mov ax, [VisTeamNum]
        cmp [ctl1team], ax
        jnz short .2
        mov word [ctl1team], 0x2
.2:
        mov ax, [HomeTeamNum]
        cmp [ctl2team], ax
        jnz short .3
        mov word [ctl2team], 0x1
        jmp short .4
.3:
        mov ax, [VisTeamNum]
        cmp [ctl2team], ax
        jnz short .4
        mov word [ctl2team], 0x2
.4:
        lea ax, [bp - 0xe]
        push ax
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0x16]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x8]
        mov [bp - 0x4], ax
        mov ax, [bp - 0xe]
        mov [bp - 0x6], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x6]
        mov ax, [bp - 0x4]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
.5:
        mov word [bp - 0x16], 0x0
.6:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        lea cx, [bp - 0x6]
        push cx
        lea cx, [bp - 0x4]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x16], ax
        test byte [bp - 0x16], 0x6
        jz short .6
.7:
        test byte [bp - 0x16], 0x6
        jz short .8
        jmp near .13
.8:
        mov ax, [bp - 0x8]
        cmp [bp - 0x4], ax
        jnz short .9
        mov ax, [bp - 0xe]
        cmp [bp - 0x6], ax
        jz short .5
.9:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0xe], 0xc8
        jnl short .12
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0xe]
        cmp ax, 0xc8
        jl short .10
        mov ax, 0xc8
        sub ax, [bp - 0xe]
        push ax
        jmp short .11
        db 0x90
.10:
        push word [es:bx + 0x2]
.11:
        mov ax, [es:bx]
        inc ax
        push ax
        push word [bp - 0xe]
        mov ax, [bp - 0x8]
        sub ax, strict word 0x4
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyRect
        add sp, 0xc
.12:
        push word [bp - 0x6]
        mov ax, [bp - 0x4]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransRemapFastAt
        add sp, 0x8
        mov ax, [bp - 0x4]
        mov [bp - 0x8], ax
        mov ax, [bp - 0x6]
        mov [bp - 0xe], ax
        jmp near .5
.13:
        test byte [bp - 0x16], 0x2
        jnz short .14
        jmp near LockerRoomLoopJumpTable.2
.14:
        cmp word [bp - 0xe], 0xc8
        jnl short .17
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0xe]
        cmp ax, 0xc8
        jl short .15
        mov ax, 0xc8
        sub ax, [bp - 0xe]
        push ax
        jmp short .16
        db 0x90
.15:
        push word [es:bx + 0x2]
.16:
        mov ax, [es:bx]
        inc ax
        push ax
        push word [bp - 0xe]
        mov ax, [bp - 0x8]
        sub ax, strict word 0x4
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyRect
        add sp, 0xc
.17:
        lea ax, [bp - 0xa]
        push ax
        push word [bp - 0x6]
        push word [bp - 0x4]
        push cs
        call LockerHitTest
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        jmp near LockerRoomLoopJumpTable.1
.18:
        mov ax, [bp - 0xa]
        jmp near .57
        db 0x90
.19:
        cmp word [DbSaveMode], 0x0
        jnz short .20
        mov ax, [bp - 0x318]
        add ax, strict word 0x19
        jmp short .25
.20:
        mov ax, [bp - 0x318]
        add ax, strict word 0x17
        mov cx, 0x18
        cwd
        idiv cx
        mov [bp - 0x318], dx
        cmp dx, [bp - 0x14]
        jnz short .22
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, strict word 0x17
.21:
        cwd
        idiv cx
        mov [bp - 0x318], dx
.22:
        push word [bp - 0x14]
        push word [bp - 0x318]
        mov es, [segDbFiles5]
        mov bx, [bp - 0x318]
        shl bx, 1
        mov ax, [es:bx + 0x128]
        mov bx, [bp - 0x14]
        shl bx, 1
        or ax, [es:bx + 0x128]
        push ax
        push word [bp - 0x318]
        push 0x0
.23:
        push cs
        call DrawLockerJersey
        add sp, 0xa
        jmp near LockerRoomLoopJumpTable.1
        db 0x90
.24:
        cmp word [DbSaveMode], 0x0
        jnz short .26
        mov ax, [bp - 0x318]
        inc ax
.25:
        mov cx, 0x1a
        jmp short .21
        db 0x90
.26:
        mov ax, [bp - 0x318]
        inc ax
        mov cx, 0x18
        cwd
        idiv cx
        mov [bp - 0x318], dx
        cmp dx, [bp - 0x14]
        jnz short .22
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        inc ax
        jmp short .21
        db 0x90
.27:
        cmp word [DbSaveMode], 0x0
        jnz short .28
        mov ax, [bp - 0x14]
        add ax, strict word 0x19
        jmp short .32
        db 0x90
.28:
        mov ax, [bp - 0x14]
        add ax, strict word 0x17
        mov cx, 0x18
        cwd
        idiv cx
        mov [bp - 0x14], dx
        cmp dx, [bp - 0x318]
        jnz short .30
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, strict word 0x17
.29:
        cwd
        idiv cx
        mov [bp - 0x14], dx
.30:
        push word [bp - 0x14]
        push word [bp - 0x318]
        mov es, [segDbFiles5]
        mov bx, [bp - 0x318]
        shl bx, 1
        mov ax, [es:bx + 0x128]
        mov bx, [bp - 0x14]
        shl bx, 1
        or ax, [es:bx + 0x128]
        push ax
        push word [bp - 0x14]
        push 0x1
        jmp near .23
        db 0x90
.31:
        cmp word [DbSaveMode], 0x0
        jnz short .33
        mov ax, [bp - 0x14]
        inc ax
.32:
        mov cx, 0x1a
        jmp short .29
.33:
        mov ax, [bp - 0x14]
        inc ax
        mov cx, 0x18
        cwd
        idiv cx
        mov [bp - 0x14], dx
        cmp dx, [bp - 0x318]
        jnz short .30
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        inc ax
        jmp short .29
.34:
        mov ax, [bp - 0x318]
        mov [HomeTeamNum], ax
        mov cx, [bp - 0x14]
        mov [VisTeamNum], cx
        cmp word [DbSaveMode], 0x0
        jz short .35
        jmp near .43
.35:
        cmp ax, strict word 0x18
        jnl short .37
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov bx, [bx + TeamNameClips]
        cmp byte [bx + 0x2], 0x0
        jz short .36
        push 0x3
        push ds
        push bx
        jmp short .38
        db 0x90
.36:
        push 0x2
        mov bx, [HomeTeamNum]
        shl bx, 1
        push ds
        push word [bx + TeamNameClips]
        push word 0x3448
        push strict word str_Mtl_2
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov es, [segMenuText8]
        mov byte [es:0x119], 0x20
        jmp short .39
        db 0x90
.37:
        push 0x3
        mov bx, [HomeTeamNum]
        shl bx, 1
        push ds
        push word [bx + 0x1e4]
.38:
        push word 0x3448
        push strict word str_Mtl_2
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.39:
        cmp word [VisTeamNum], 0x18
        jnl short .41
        mov bx, [VisTeamNum]
        shl bx, 1
        mov bx, [bx + TeamNameClips]
        cmp byte [bx + 0x2], 0x0
        jz short .40
        push 0x3
        push ds
        push bx
        jmp short .42
.40:
        push 0x2
        mov bx, [VisTeamNum]
        shl bx, 1
        push ds
        push word [bx + TeamNameClips]
        push word 0x3448
        push strict word str_LaAtMtl
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov es, [segMenuText8]
        mov byte [es:0x112], 0x20
        jmp short .43
        db 0x90
.41:
        push 0x3
        mov bx, [VisTeamNum]
        shl bx, 1
        push ds
        push word [bx + 0x1e4]
.42:
        push word 0x3448
        push strict word str_LaAtMtl
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.43:
        cmp word [ctl1team], 0x1
        jnz short .44
        mov ax, [HomeTeamNum]
        jmp short .45
        db 0x90
.44:
        cmp word [ctl1team], 0x2
        jnz short .46
        mov ax, [VisTeamNum]
.45:
        mov [ctl1team], ax
.46:
        cmp word [ctl2team], 0x1
        jnz short .47
        mov ax, [HomeTeamNum]
        jmp short .48
        db 0x90
.47:
        cmp word [ctl2team], 0x2
        jnz short .49
        mov ax, [VisTeamNum]
.48:
        mov [ctl2team], ax
.49:
        call 0x0F97:UseDbDescriptor
        lea ax, [bp - 0x316]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x316]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.50:
        cmp word [ctl1team], 0x1
        jnz short .51
        mov ax, [HomeTeamNum]
        jmp short .52
.51:
        cmp word [ctl1team], 0x2
        jnz short .53
        mov ax, [VisTeamNum]
.52:
        mov [ctl1team], ax
.53:
        cmp word [ctl2team], 0x1
        jz short LockerRoomLoopTail.1 + 0xF70
.54:
        cmp word [ctl2team], 0x2
        jnz short .56
        mov ax, [VisTeamNum]
.55:
        mov [ctl2team], ax
.56:
        lea ax, [bp - 0x316]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x316]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov ax, 0x3
        leave
        retf
        db 0x90
.57:
        cmp ax, strict word 0x7
        ja short LockerRoomLoopJumpTable.1
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0xf40]
        db 0x90
LockerRoomLoopJumpTable:                        ; jump table of LockerRoomLoop: 8 case targets
        dw LockerRoomLoop.24
        dw LockerRoomLoop.31
        dw LockerRoomLoop.19
        dw LockerRoomLoop.24
        dw LockerRoomLoop.27
        dw LockerRoomLoop.31
        dw LockerRoomLoop.34
        dw LockerRoomLoop.50
.1:
        call 0x0FEF:UseCurrentPage
        jmp near LockerRoomLoop.12
.2:
        cmp word [ctl1team], 0x1
        jnz short .3
        mov ax, [HomeTeamNum]
        jmp short .4
.3:
        cmp word [ctl1team], 0x2
        jnz short LockerRoomLoopTail + 0xF70
        mov ax, [VisTeamNum]
.4:
        mov [ctl1team], ax
