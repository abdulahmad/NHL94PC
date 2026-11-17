; Main desk menu loop and its menu items (new league, import and export of databases) (MENUS.OVL)
; The first bytes finish the last routine of desk.asm.
        mov byte [es:bx], 0x1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; MainDeskLoop                                               2E70:000A  94 PC
; The main EASN desk.
;
; Calls SetStatsMenuTextThunk, MouseRange, MouseMove, SetSideControls, SetupStatsMenusThunk, GetPage,
; CopyPlane, UseCurrentPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
MainDeskLoop:
        enter 0x96, 0x0
        push di
        push si
        mov word [bp - 0x6], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4e], ax
        push ax
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        mov ax, DeskMenuBar
        mov cx, 0x3448
        mov [bp - 0x68], ax
        mov [bp - 0x66], cx
        mov word [bp - 0x56], 0x3
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0x5a], dx
        mov [bp - 0x5c], dx
        mov [bp - 0x5e], dx
        mov [bp - 0x60], dx
        mov [bp - 0x62], dx
        mov [bp - 0x64], dx
        mov [bp - 0x74], dx
        mov [bp - 0x76], dx
        mov [bp - 0x78], dx
        mov [bp - 0x7a], dx
        mov [bp - 0x7c], dx
        mov [bp - 0x7e], dx
        mov [bp - 0x80], dx
        mov [bp - 0x82], dx
        mov es, cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx]
        mov es, [segMenuText17]
        add ax, [es:DeskMenuBar + 0x4]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x58], ax
        mov [bp - 0x38], ax
        mov ax, [es:DeskMenuBar + 0x2]
        add ax, [es:DeskMenuBar + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x6a], ax
        mov [bp - 0x3a], ax
        push word 0xc8
        push word 0x13c
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        push ax
        push ax
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x6a]
        push word [bp - 0x58]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x2037:SetSideControls
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov word [teamstatscb], 0x24db
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x24d1
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24c7
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24bd
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x219d
        mov word [menucbseg], 0x1b35
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_17
        push 0x0
        push 0x0
        lea ax, [bp - 0x4a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_12
        push 0x0
        lea ax, [bp - 0x4a]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push word [bp - 0x56]
        push word [bp - 0x66]
        push word [bp - 0x68]
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word [bp - 0x6a]
        push word [bp - 0x58]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov word [ScreenRowStride], 0x50
        push strict word str_Pal_50
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        push 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0F99:FlushInputEvents
.2:
        mov word [bp - 0x8c], 0x0
.3:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        lea cx, [bp - 0x3a]
        push cx
        lea cx, [bp - 0x38]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x8c], ax
        test byte [bp - 0x8c], 0x2
        jz short .3
.4:
        test byte [bp - 0x8c], 0x2
        jz short .5
        jmp near .10
.5:
        mov ax, [bp - 0x58]
        cmp [bp - 0x38], ax
        jnz short .6
        mov ax, [bp - 0x3a]
        cmp [bp - 0x6a], ax
        jz short .2
.6:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0x6a], 0xc8
        jnl short .9
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x6a]
        cmp ax, 0xc8
        jl short .7
        jmp near .43
.7:
        push word [es:bx + 0x2]
.8:
        mov ax, [es:bx]
        inc ax
        inc ax
        push ax
        push word [bp - 0x6a]
        mov ax, [bp - 0x58]
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
.9:
        push word [bp - 0x3a]
        push word [bp - 0x38]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x38]
        mov [bp - 0x58], ax
        mov ax, [bp - 0x3a]
        mov [bp - 0x6a], ax
        jmp near .2
.10:
        lea ax, [bp - 0x72]
        push ax
        lea cx, [bp - 0x4c]
        push cx
        lea dx, [bp - 0x36]
        push dx
        lea dx, [bp - 0x56]
        push dx
        push word [bp - 0x4e]
        lea dx, [bp - 0x68]
        push dx
        push word [bp - 0x3a]
        push word [bp - 0x38]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
        jmp near .37
.11:
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les si, [bp + si - 0x68]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .12
        jmp near .26
.12:
        mov ax, [bp - 0x72]
        mov si, [bp - 0x4c]
        shl si, 1
        cmp [bp + si - 0x8a], ax
        jz short .13
        jmp near .20
.13:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x4e]
        mov [bp - 0x6c], ax
        jmp short .16
.14:
        mov si, [bp - 0x6c]
        shl si, 1
        mov word [bp + si - 0x8a], 0x0
        mov si, [bp - 0x6c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x80]
        or ax, [bp + si - 0x82]
        jz short .15
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x80]
        push word [bp + si - 0x82]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x34], ax
        mov [bp + si - 0x36], ax
        push word [bp + si - 0x80]
        push word [bp + si - 0x82]
        call 0x06E1:FindUnlink
        add sp, 0x4
.15:
        dec word [bp - 0x6c]
.16:
        cmp word [bp - 0x6c], 0x0
        jg short .14
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        lea ax, [bp - 0x6]
        push ax
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les si, [bp + si - 0x68]
        call far [es:bx + si + 0xc]
        add sp, 0x2
        mov [bp - 0x8c], ax
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x5e], ax
        mov [bp - 0x60], ax
        mov [bp - 0x62], ax
        mov [bp - 0x64], ax
        mov [bp - 0x74], ax
        mov [bp - 0x76], ax
        mov [bp - 0x78], ax
        mov [bp - 0x7a], ax
        mov [bp - 0x7c], ax
        mov [bp - 0x7e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        cmp word [bp - 0x8c], 0x1
        jnz short .17
        call 0x0F99:FlushInputEvents
        call 0x0BFE:InputShutdown
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.17:
        cmp word [bp - 0x8c], 0x2
        jnz short .18
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_16
        push ax
        push ax
        lea ax, [bp - 0x4a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_49
        push 0x0
        lea ax, [bp - 0x4a]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        push 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x06E1:FindUnlink
        add sp, 0x4
.18:
        push 0x0
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        lea ax, [bp - 0x6a]
        push ax
        lea cx, [bp - 0x58]
        push cx
        lea dx, [bp - 0x8c]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x58]
        mov [bp - 0x38], ax
        mov ax, [bp - 0x6a]
        mov [bp - 0x3a], ax
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .19
        call 0x0FEF:CopyPlane
.19:
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x6a]
        push word [bp - 0x58]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0xc8
        push word 0x13c
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x6a]
        push word [bp - 0x58]
        call 0x03A3:MouseMove
        add sp, 0x4
        call 0x0F99:FlushInputEvents
        jmp near .41
.20:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x4e]
        cmp [bp - 0x4c], ax
        jz short .24
        mov [bp - 0x6c], ax
        jmp short .23
.21:
        mov si, [bp - 0x6c]
        shl si, 1
        mov word [bp + si - 0x8a], 0x0
        mov di, [bp - 0x6c]
        shl di, byte 0x2
        mov ax, [bp + di - 0x80]
        or ax, [bp + di - 0x82]
        jz short .22
        push word [bp + di - 0x34]
        push word [bp + di - 0x36]
        push word [bp + di - 0x80]
        push word [bp + di - 0x82]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x34], ax
        mov [bp + di - 0x36], ax
        push word [bp + di - 0x80]
        push word [bp + di - 0x82]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x80], ax
        mov [bp + di - 0x82], ax
        mov [bp + di - 0x66], ax
        mov [bp + di - 0x68], ax
        mov [bp + si - 0x56], ax
.22:
        dec word [bp - 0x6c]
.23:
        mov ax, [bp - 0x4c]
        cmp [bp - 0x6c], ax
        jg short .21
        mov [bp - 0x4e], ax
.24:
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov di, [bp - 0x4c]
        shl di, 1
        imul ax, [bp + di - 0x8a], 0x16
        add ax, [bp + si - 0x68]
        mov dx, [bp + si - 0x66]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov ax, [bp - 0x72]
        mov di, [bp - 0x4c]
        shl di, 1
        mov [bp + di - 0x8a], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x68]
        mov dx, [bp + si - 0x66]
        push dx
        push ax
.25:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
        jmp near .41
.26:
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les si, [bp + si - 0x68]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .27
        jmp near .36
.27:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x4e]
        cmp [bp - 0x4c], ax
        jz short .31
        mov [bp - 0x6c], ax
        jmp short .30
.28:
        mov si, [bp - 0x6c]
        shl si, 1
        mov word [bp + si - 0x8a], 0x0
        mov di, [bp - 0x6c]
        shl di, byte 0x2
        mov ax, [bp + di - 0x80]
        or ax, [bp + di - 0x82]
        jz short .29
        push word [bp + di - 0x34]
        push word [bp + di - 0x36]
        push word [bp + di - 0x80]
        push word [bp + di - 0x82]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x34], ax
        mov [bp + di - 0x36], ax
        push word [bp + di - 0x80]
        push word [bp + di - 0x82]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x80], ax
        mov [bp + di - 0x82], ax
        mov [bp + di - 0x66], ax
        mov [bp + di - 0x68], ax
        mov [bp + si - 0x56], ax
.29:
        dec word [bp - 0x6c]
.30:
        mov ax, [bp - 0x4c]
        cmp [bp - 0x6c], ax
        jg short .28
        mov [bp - 0x4e], ax
.31:
        push 0x5
        push 0xb
        push 0x11
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov ax, [bp + si - 0x68]
        mov dx, [bp + si - 0x66]
        mov di, [bp - 0x4e]
        shl di, 1
        imul cx, [bp + di - 0x8a], 0x16
        db 0x03, 0xC1                           ; insn: add ax, cx
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov ax, [bp - 0x72]
        mov [bp + di - 0x8a], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x68]
        mov dx, [bp + si - 0x66]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les di, [bp + si - 0x68]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x4e]
        mov di, [bp - 0x4e]
        shl di, byte 0x2
        mov [bp + di - 0x68], ax
        mov [bp + di - 0x66], dx
        les si, [bp + si - 0x68]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov di, [bp - 0x4e]
        shl di, 1
        mov [bp + di - 0x56], ax
        mov [bp - 0x94], si
        mov [bp - 0x92], es
        cmp word [bp - 0x4e], 0x1
        jz short .32
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [es:bx + 0x4]
        jmp short .33
.32:
        imul si, [bp - 0x72], 0x16
        mov di, [bp - 0x4c]
        shl di, byte 0x2
        les bx, [bp + di - 0x68]
        mov ax, [es:bx + si]
.33:
        mov [bp - 0x8e], ax
        mov si, [bp - 0x4e]
        shl si, byte 0x2
        mov ax, [bp + si - 0x3a]
        add ax, [bp - 0x8e]
        mov [bp + si - 0x36], ax
        cmp word [bp - 0x4e], 0x1
        jz short .34
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les si, [bp + si - 0x68]
        mov ax, [es:bx + si + 0x2]
        jmp short .35
        db 0x90
.34:
        imul bx, [bp - 0x72], 0x16
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        les si, [bp + si - 0x68]
        mov ax, [es:bx + si + 0x6]
.35:
        mov [bp - 0x90], ax
        mov si, [bp - 0x4e]
        shl si, byte 0x2
        mov ax, [bp + si - 0x38]
        add ax, [bp - 0x90]
        mov [bp + si - 0x34], ax
        les bx, [bp + si - 0x68]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov di, [bp - 0x4e]
        shl di, 1
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        imul bx, [bp + di - 0x56], 0x16
        db 0x03, 0xD9                           ; insn: add bx, cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [es:bx - 0x12]
        mov [bp - 0x96], dx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sub ax, [bp - 0x96]
        inc ax
        mov [bp - 0x4], ax
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov cx, [es:bx + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub cx, [es:bx - 0x10]
        neg cx
        inc cx
        mov [bp - 0x6e], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_7
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x82], ax
        mov [bp + si - 0x80], dx
        lea ax, [bp + si - 0x82]
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
        mov cx, [bp - 0x4]
        mov [es:bx], cx
        mov cx, [bp - 0x6e]
        mov [es:bx + 0x2], cx
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push dx
        push ax
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + di - 0x56]
        push word [bp + si - 0x66]
        push word [bp + si - 0x68]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x8a], 0x0
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x66]
        push word [bp + si - 0x68]
        jmp near .25
.36:
        call 0x0FEF:UseOtherPage
        jmp near .24
.37:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x4e]
        mov [bp - 0x6c], ax
        jmp short .40
        db 0x90
.38:
        mov si, [bp - 0x6c]
        shl si, 1
        mov word [bp + si - 0x8a], 0x0
        mov si, [bp - 0x6c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x80]
        or ax, [bp + si - 0x82]
        jz short .39
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x80]
        push word [bp + si - 0x82]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x34], ax
        mov [bp + si - 0x36], ax
        push word [bp + si - 0x80]
        push word [bp + si - 0x82]
        call 0x06E1:FindUnlink
        add sp, 0x4
.39:
        dec word [bp - 0x6c]
.40:
        cmp word [bp - 0x6c], 0x0
        jg short .38
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x5e], ax
        mov [bp - 0x60], ax
        mov [bp - 0x62], ax
        mov [bp - 0x64], ax
        mov [bp - 0x74], ax
        mov [bp - 0x76], ax
        mov [bp - 0x78], ax
        mov [bp - 0x7a], ax
        mov [bp - 0x7c], ax
        mov [bp - 0x7e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
.41:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0x6a], 0xc8
        jl short .42
        jmp near .9
.42:
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x6a]
        cmp ax, 0xc8
        jnl short .43
        jmp near .7
.43:
        mov ax, 0xc8
        sub ax, [bp - 0x6a]
        push ax
        jmp near .8
        db 0x90

;-----------------------------------------------------------------------------
; MenuExit                                                   2E70:0964  94 PC
; Menu item: exit.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
MenuExit:
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; SaveModeState                                              2E70:0968  94 PC
; Copies the mode settings out.
;
; Takes 2 words of stack arguments. Calls _fstrcpy. Far routine (retf).
;-----------------------------------------------------------------------------
SaveModeState:
        enter 0x4, 0x0
        push si
        mov si, [bp + 0x6]
        push word 0x3701
        push strict word CurLeagueName
        mov cx, [bp + 0x8]
        mov [bp - 0x4], si
        mov [bp - 0x2], cx
        inc si
        inc si
        push cx
        push si
        call 0x0000:_fstrcpy
        add sp, 0x8
        push ds
        push strict word HomeTeamDbName
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0xf
        push dx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push ds
        push strict word AwayTeamDbName
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0x2f
        push dx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov ax, [HomeTeamNum]
        les bx, [bp - 0x4]
        mov [es:bx + 0x50], ax
        mov ax, [VisTeamNum]
        mov [es:bx + 0x52], ax
        mov ax, [CrowdState]
        mov [es:bx + 0x54], ax
        mov ax, [ctl1team]
        mov [es:bx + 0x56], ax
        mov ax, [ctl2team]
        mov [es:bx + 0x58], ax
        mov ax, [ctl1dev]
        mov [es:bx + 0x5a], ax
        mov ax, [ctl2dev]
        mov [es:bx + 0x5c], ax
        mov ax, [ctl1side]
        mov [es:bx + 0x5e], ax
        mov ax, [ctl2side]
        mov [es:bx + 0x60], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; LoadModeState                                              2E70:09FE  94 PC
; Copies them back and applies them.
;
; Takes 2 words of stack arguments. Calls _fstrcpy, MusicOn, MusicOff, SfxOn, SfxOff, SetSideControls,
; CopyStrNFar. Far routine (retf).
;-----------------------------------------------------------------------------
LoadModeState:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov cx, [bp + 0x8]
        mov [bp - 0x4], si
        mov [bp - 0x2], cx
        inc si
        inc si
        push cx
        push si
        push word 0x3701
        push strict word CurLeagueName
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0xf
        push dx
        push ax
        push ds
        push strict word HomeTeamDbName
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, strict word 0x2f
        push dx
        push ax
        push ds
        push strict word AwayTeamDbName
        call 0x0000:_fstrcpy
        add sp, 0x8
        les bx, [bp - 0x4]
        mov ax, [es:bx]
        mov [DbSaveMode], ax
        mov ax, [es:bx + 0x50]
        mov [HomeTeamNum], ax
        mov ax, [es:bx + 0x52]
        mov [VisTeamNum], ax
        mov ax, [es:bx + 0x54]
        mov [CrowdState], ax
        mov ax, [es:bx + 0x56]
        mov [ctl1team], ax
        mov ax, [es:bx + 0x58]
        mov [ctl2team], ax
        mov ax, [es:bx + 0x5a]
        mov [ctl1dev], ax
        mov ax, [es:bx + 0x5c]
        mov [ctl2dev], ax
        mov ax, [es:bx + 0x5e]
        mov [ctl1side], ax
        mov ax, [es:bx + 0x60]
        mov [ctl2side], ax
        mov ax, [ctl1dev]
        dec ax
        jz short .1
        dec ax
        jz short .2
        dec ax
        dec ax
        jz short .3
        jmp short .5
        db 0x90
.1:
        test byte [InputFlags], 0x1
        jmp short .4
        db 0x90
.2:
        test byte [InputFlags], 0x2
        jmp short .4
        db 0x90
.3:
        test byte [InputFlags], 0x4
.4:
        jnz short .5
        mov word [ctl1dev], 0x0
.5:
        mov ax, [ctl2dev]
        dec ax
        jz short .6
        dec ax
        jz short .7
        dec ax
        dec ax
        jz short .8
        jmp short .10
.6:
        test byte [InputFlags], 0x1
        jmp short .9
        db 0x90
.7:
        test byte [InputFlags], 0x2
        jmp short .9
        db 0x90
.8:
        test byte [InputFlags], 0x4
.9:
        jnz short .10
        mov word [ctl2dev], 0x0
.10:
        cmp word [ctl1dev], 0x0
        jnz short .15
        test byte [InputFlags], 0x2
        jz short .11
        cmp word [ctl2dev], 0x2
        jz short .11
        mov word [ctl1dev], 0x2
        jmp short .15
.11:
        test byte [InputFlags], 0x4
        jz short .12
        cmp word [ctl2dev], 0x4
        jz short .12
        mov word [ctl1dev], 0x4
        jmp short .15
.12:
        test byte [InputFlags], 0x8
        jz short .13
        cmp word [ctl2dev], 0x8
        jz short .13
        mov word [ctl1dev], 0x8
        jmp short .15
.13:
        test byte [InputFlags], 0x1
        jz short .14
        cmp word [ctl2dev], 0x1
        jz short .14
        mov word [ctl1dev], 0x1
        jmp short .15
.14:
        mov word [ctl1dev], 0x10
.15:
        cmp word [ctl2dev], 0x0
        jnz short .20
        test byte [InputFlags], 0x2
        jz short .16
        cmp word [ctl1dev], 0x2
        jz short .16
        mov word [ctl2dev], 0x2
        jmp short .20
        db 0x90
.16:
        test byte [InputFlags], 0x4
        jz short .17
        cmp word [ctl1dev], 0x4
        jz short .17
        mov word [ctl2dev], 0x4
        jmp short .20
.17:
        test byte [InputFlags], 0x8
        jz short .18
        cmp word [ctl1dev], 0x8
        jz short .18
        mov word [ctl2dev], 0x8
        jmp short .20
.18:
        test byte [InputFlags], 0x1
        jz short .19
        cmp word [ctl1dev], 0x1
        jz short .19
        mov word [ctl2dev], 0x1
        jmp short .20
.19:
        mov word [ctl2dev], 0x10
.20:
        cmp word [ctl1dev], 0x10
        jnz short .21
        mov ax, 0x1
        jmp short .22
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        mov [bp - 0x6], ax
        cmp word [ctl2dev], 0x10
        jnz short .23
        mov ax, 0x1
        jmp short .24
        db 0x90
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        xor ax, [bp - 0x6]
        jz short .27
        cmp word [ctl1dev], 0x10
        jnz short .25
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov di, 0x1
        jmp short .26
        db 0x90
.25:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, 0x1
.26:
        db 0x8B, 0xF7                           ; insn: mov si, di
        shl si, 1
        cmp word [si + ctl1side], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, 1
        mov [si + ctl1side], ax
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x1
        add ax, strict word 0xfffe
        mov [si + ctl1team], ax
.27:
        test byte [CrowdState], 0x40
        jz short .28
        call 0x16F2:MusicOn
        jmp short .29
        db 0x90
.28:
        call 0x16F2:MusicOff
.29:
        test byte [CrowdState], 0x80
        jz short .30
        call 0x16F2:SfxOn
        jmp short .31
        db 0x90
.30:
        call 0x16F2:SfxOff
.31:
        call 0x2037:SetSideControls
        cmp word [DbSaveMode], 0x0
        jz short .32
        jmp near .40
.32:
        cmp word [HomeTeamNum], 0x18
        jnl short .34
        mov bx, [HomeTeamNum]
        shl bx, 1
        mov bx, [bx + TeamNameClips]
        mov [bp - 0x8], bx
        cmp byte [bx + 0x2], 0x0
        jz short .33
        push 0x3
        push ds
        push bx
        jmp short .35
.33:
        push 0x2
        push ds
        push bx
        push word 0x3448
        push strict word str_Mtl_2
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov es, [segMenuText18]
        mov byte [es:str_Mtl_2 + 0x2], 0x20
        jmp short .36
.34:
        push 0x3
        mov bx, [HomeTeamNum]
        shl bx, 1
        push ds
        push word [bx + TeamNameClips + 4]
.35:
        push word 0x3448
        push strict word str_Mtl_2
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.36:
        cmp word [VisTeamNum], 0x18
        jnl short .38
        mov bx, [VisTeamNum]
        shl bx, 1
        mov bx, [bx + TeamNameClips]
        mov [bp - 0xa], bx
        cmp byte [bx + 0x2], 0x0
        jz short .37
        push 0x3
        push ds
        push bx
        jmp short .39
        db 0x90
.37:
        push 0x2
        push ds
        push bx
        push word 0x3448
        push strict word str_LaAtMtl
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov es, [segMenuText18]
        mov byte [es:str_LaAtMtl + 0x2], 0x20
        pop si
        pop di
        leave
        retf
.38:
        push 0x3
        mov bx, [VisTeamNum]
        shl bx, 1
        push ds
        push word [bx + TeamNameClips + 4]
.39:
        push word 0x3448
        push strict word str_LaAtMtl
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.40:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; WriteModeState                                             2E70:0D0A  94 PC
; Writes game.set.
;
; Takes 2 words of stack arguments. Calls _fstrcpy, BuildPathFar, CreateFileNormal, FatalError,
; WriteAtOffset, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
WriteModeState:
        enter 0x22, 0x0
        push di
        push si
        push word 0x3701
        push strict word CurLeagueName
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        inc ax
        inc ax
        push dx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push ds
        push strict word HomeTeamDbName
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, strict word 0xf
        push dx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push ds
        push strict word AwayTeamDbName
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, strict word 0x2f
        push dx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov ax, [DbSaveMode]
        les bx, [bp + 0x6]
        mov [es:bx], ax
        mov ax, [HomeTeamNum]
        mov [es:bx + 0x50], ax
        mov ax, [VisTeamNum]
        mov [es:bx + 0x52], ax
        mov ax, [CrowdState]
        mov [es:bx + 0x54], ax
        mov ax, [ctl1team]
        mov [es:bx + 0x56], ax
        mov ax, [ctl2team]
        mov [es:bx + 0x58], ax
        mov ax, [ctl1dev]
        mov [es:bx + 0x5a], ax
        mov ax, [ctl2dev]
        mov [es:bx + 0x5c], ax
        mov ax, [ctl1side]
        mov [es:bx + 0x5e], ax
        mov ax, [ctl2side]
        mov [es:bx + 0x60], ax
        cmp word [DbSaveMode], 0x0
        jnz short .1
        lea di, [bp - 0x22]
        mov si, str_GameSet_2
        mov ax, ss
        mov es, ax
        movsw
        movsw
        movsw
        movsw
        movsb
        jmp short .2
.1:
        push ds
        push strict word str_Set_5
        push ds
        push strict word str_Game_6
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
.2:
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x22]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x158f
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0x62
        push -0x1
        push -0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0x1592
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x1595
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CopyGameSettings                                           2E70:0E36  94 PC
; Copies a game.set.
;
; Takes 2 words of stack arguments. Calls OpenReadShared, ReadAtOffset, CloseHandlePtr,
; OpenReadWriteShared, CreateFileNormal, WriteAtOffset. Far routine (retf).
;-----------------------------------------------------------------------------
CopyGameSettings:
        enter 0xc6, 0x0
        push di
        push si
        lea ax, [bp - 0x2]
        push ax
        push word [bp + 0x6]
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
.1:
        mov ax, 0xffff
        pop si
        pop di
        leave
        retf
.2:
        push 0x62
        push -0x1
        push -0x1
        lea ax, [bp - 0x64]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov si, [bp + 0x8]
        lea ax, [bp - 0x2]
        push ax
        push si
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        lea ax, [bp - 0x2]
        push ax
        push si
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        lea di, [bp - 0xc6]
        lea si, [bp - 0x64]
        mov ax, ss
        mov es, ax
        mov cx, 0x31
        rep movsw
        jmp short .5
        db 0x90
.3:
        push 0x62
        push -0x1
        push -0x1
        lea ax, [bp - 0xc6]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        jmp near .1
.4:
        mov ax, [bp - 0x10]
        mov [bp - 0x72], ax
        lea di, [bp - 0xc4]
        lea si, [bp - 0x62]
        mov ax, ss
        mov es, ax
        mov cx, 0x6
        rep movsw
        movsb
.5:
        push 0x62
        push 0x0
        push 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        jmp near .1
.6:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        jmp near .1
.7:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuNewExhibition                                          2E70:0F22  94 PC
; New exhibition game.
;
; Takes 1 word of stack arguments. Calls SetupControllersThunk, CreateGSummaryDbThunk,
; ShowMatchupScreenThunk, InputShutdown, SetupStatsMenusThunk, AllocRecData, GetPaletteFar,
; FadePaletteInThunk and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuNewExhibition:
        enter 0x16, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov es, [schedgameidx]
        mov [es:AwayGlStats + 0x12], si
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
        call 0x1B35:SetupControllersThunk
        cmp [di], si
        jnl short .1
        push si
        push si
        call 0x1B35:CreateGSummaryDbThunk
        add sp, 0x4
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x1B35:ShowMatchupScreenThunk
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0BFE:InputShutdown
.1:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        test al, 0x4
        jz short .2
        jmp near .4
.2:
        push 0x1
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        cmp word [di], 0x0
        jl short .3
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette
        call 0x14DB:AllocRecData
        add sp, 0x8
        push dx
        push ax
        push word 0x100
        push 0x0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x12], si
        mov [bp - 0x10], dx
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x10]
        push word [bp - 0x12]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x06E1:FindUnlink
        add sp, 0x4
.3:
        push di
        call 0x1B35:PlayGameThunk
        add sp, 0x2
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x3d5
        out dx, al
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
.4:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_14
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
        call 0x0BFE:InputInit
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, PageTable
        mov es, [musicslot]
        mov [bp - 0x16], bx
        mov [bp - 0x14], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .5
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x16]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.5:
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        call 0x0FEF:CopyPlane
.6:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_15
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_11
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        mov es, [segMenuText17]
        mov ax, [es:DeskMenuBar + 0x2]
        add ax, [es:DeskMenuBar + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov ax, [es:DeskMenuBar + 0x4]
        add ax, [es:DeskMenuBar]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov word [ScreenRowStride], 0x50
        push 0x10
        push strict word str_Pal_48
        push di
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [teamstatscb], 0x24db
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x24d1
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24c7
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24bd
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x219d
        mov word [menucbseg], 0x1b35
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuNewLeague                                              2E70:11EC  94 PC
; Menu item: start a new league.
;
; Calls SaveModeState, LoadModeState, SetLeagueSetImage, CreateNewLeagueThunk, BuildSeasonTitleThunk,
; SetupStatsMenusThunk, AllocRecData, GetPaletteFar and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuNewLeague:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        mov es, [segDbFiles11]
        mov word [es:lgstate], 0x2
        mov word [es:lgstate + 0x50], 0x9
        mov word [es:lgstate + 0x52], 0x7
        or word [es:lgstate + 0x54], 0x3ff
        mov ax, [es:lgstate + 0x54]
        and ah, 0xfb
        or ah, 0x8
        mov [es:lgstate + 0x54], ax
        or byte [es:lgstate + 0x55], 0x70
        test byte [InputFlags], 0x2
        jz short .1
        mov word [es:lgstate_w5A], 0x2
        jmp short .5
        db 0x90
.1:
        mov ax, 0x3415
        mov es, ax
        test byte [InputFlags], 0x4
        jz short .2
        mov word [es:lgstate_w5A], 0x4
        jmp short .5
        db 0x90
.2:
        test byte [InputFlags], 0x8
        jz short .3
        mov word [es:lgstate_w5A], 0x8
        jmp short .5
.3:
        test byte [InputFlags], 0x1
        jz short .4
        mov word [es:lgstate_w5A], 0x1
        jmp short .5
.4:
        mov word [es:lgstate_w5A], 0x10
.5:
        mov es, [segDbFiles11]
        cmp word [es:lgstate_w5A], 0x10
        jz short .6
        mov ax, 0x9
        jmp short .7
.6:
        mov ax, 0xffff
.7:
        mov [es:lgstate + 0x56], ax
        mov word [es:lgstate_w5A + 0x2], 0x10
        mov word [es:lgstate + 0x58], 0xfffe
        mov word [es:lgstate_w5A + 0x4], 0x0
        mov word [es:lgstate_w5A + 0x6], 0x1
        push es
        push word 0xc4
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        call 0x2B26:SetLeagueSetImage
        add sp, 0x2
        call 0x1B35:CreateNewLeagueThunk
        mov es, [segDbFiles11]
        cmp byte [es:lgstate_name], 0x0
        jz short .8
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov es, [segMenuText19]
        mov word [es:itemExportDatabases + 0xA], strict word MenuExportDbsThunk
        mov word [es:itemExportDatabases + 0xC], 0x1b35
        mov word [es:itemNextLeagueGame + 0xA], strict word MenuNextLeagueGameThunk
        mov word [es:itemNextLeagueGame + 0xC], 0x1b35
        mov word [es:itemLeagueManager + 0xE], 0xd86
        mov word [es:itemLeagueManager + 0x10], 0x3448
        jmp short .9
.8:
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov es, [segMenuText19]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemExportDatabases + 0xC], ax
        mov [es:itemExportDatabases + 0xA], ax
        mov [es:itemNextLeagueGame + 0xC], ax
        mov [es:itemNextLeagueGame + 0xA], ax
        mov [es:itemLeagueManager + 0x10], ax
        mov [es:itemLeagueManager + 0xE], ax
.9:
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_13
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        call 0x0FEF:CopyPlane
.10:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_14
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_10
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuAddTeam                                                2E70:144A  94 PC
; Add a human team.
;
; Calls SaveModeState, LoadModeState, SetupStatsMenusThunk, AddHumanTeamThunk, AllocRecData,
; GetPaletteFar, FadePaletteInThunk, FindUnlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuAddTeam:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        call 0x1B35:AddHumanTeamThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_12
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_13
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_9
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuRemoveTeam                                             2E70:1594  94 PC
; Remove a human team.
;
; Calls SaveModeState, LoadModeState, SetupStatsMenusThunk, RemoveHumanTeamThunk, AllocRecData,
; GetPaletteFar, FadePaletteInThunk, FindUnlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuRemoveTeam:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        call 0x1B35:RemoveHumanTeamThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_11
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_12
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_8
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuLeagueSettings                                         2E70:16DE  94 PC
; League settings.
;
; Calls SaveModeState, LoadModeState, CheckMasterPasswordThunk, AllocRecData, GetPaletteFar,
; FadePaletteInThunk, FindUnlink, GetPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuLeagueSettings:
        enter 0x24, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:CheckMasterPasswordThunk
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov si, 0xffff
.1:
        cmp byte [lgflags], 0x0
        jnz short .2
        jmp near .4
.2:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_10
        call 0x14DB:AllocRecData
        add sp, 0x8
        push dx
        push ax
        push word 0x100
        push 0x0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1c], di
        mov [bp - 0x1a], dx
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        call 0x0FEF:CopyPlane
.3:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_11
        push 0x0
        push 0x0
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_7
        push 0x0
        lea ax, [bp - 0x18]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x20], di
        mov [bp - 0x1e], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_10
        push 0x0
        push 0x0
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_47
        push 0x0
        lea ax, [bp - 0x18]
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
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        push 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x06E1:FindUnlink
        add sp, 0x4
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .5
        call 0x2B26:LeagueSettingsDlg
.5:
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuRebuildDbs                                             2E70:18A6  94 PC
; Rebuild the league dbs.
;
; Calls SaveModeState, LoadModeState, RebuildLeagueDbsThunk. Far routine (retf).
;-----------------------------------------------------------------------------
MenuRebuildDbs:
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:RebuildLeagueDbsThunk
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; MenuMergeUpdateDbs                                         2E70:18E2  94 PC
; Merge update dbs.
;
; Calls SaveModeState, LoadModeState, MergeUpdateDbsThunk, AllocRecData, GetPaletteFar,
; FadePaletteInThunk, FindUnlink, GetPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuMergeUpdateDbs:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:MergeUpdateDbsThunk
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        jmp near .3
.1:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_9
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_9
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_6
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuMergeLeagueFiles                                       2E70:1A26  94 PC
; Merge league files.
;
; Calls SaveModeState, LoadModeState, MergeLeagueFilesThunk, AllocRecData, GetPaletteFar,
; FadePaletteInThunk, FindUnlink, GetPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuMergeLeagueFiles:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:MergeLeagueFilesThunk
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        jmp near .3
.1:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_8
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_8
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_5
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuUpdateTeamDbs                                          2E70:1B6A  94 PC
; Update team dbs.
;
; Calls SaveModeState, LoadModeState, UpdateTeamDbsThunk. Far routine (retf).
;-----------------------------------------------------------------------------
MenuUpdateTeamDbs:
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:UpdateTeamDbsThunk
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; MenuTradePlayers                                           2E70:1BA6  94 PC
; Trade players.
;
; Calls SaveModeState, LoadModeState, SetupStatsMenusThunk, TradePlayersThunk, AllocRecData,
; GetPaletteFar, FadePaletteInThunk, FindUnlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTradePlayers:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        call 0x1B35:TradePlayersThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_7
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_7
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_4
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuNextLeagueGame                                         2E70:1CF0  94 PC
; Next league game.
;
; Takes 1 word of stack arguments. Calls SaveModeState, LoadModeState, SetupStatsMenusThunk,
; SetLeagueSetImage, SetStatsMenuTextThunk, _fstrcpy, OpenReadShared, PlayLeagueGameThunk and others.
; Far routine (retf).
;-----------------------------------------------------------------------------
MenuNextLeagueGame:
        enter 0x26, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push 0x1
        call 0x2B26:SetLeagueSetImage
        add sp, 0x2
        push 0x2
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .1
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x26]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_GameSav_3
        lea si, [bp - 0x26]
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
        push word [bp + 0x6]
        lea ax, [bp - 0x26]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov bx, [bp + 0x6]
        mov word [bx], 0xffff
.1:
        push word [bp + 0x6]
        call 0x1B35:PlayLeagueGameThunk
        add sp, 0x2
        mov word [teamstatscb], 0x24db
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x24d1
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24c7
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24bd
        mov word [HomeTeam], 0x1b35
        mov word [menucbfn], 0x219d
        mov word [menucbseg], 0x1b35
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_6
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_6
        push 0x0
        push 0x0
        lea ax, [bp - 0x26]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_3
        push 0x0
        lea ax, [bp - 0x26]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuLeagueHilights                                         2E70:1EEC  94 PC
; League highlights.
;
; Calls SaveModeState, LoadModeState, ViewHilights, GetPage, CopyPlane, UseCurrentPage, BuildPathFar,
; LoadPackedHeader and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuLeagueHilights:
        enter 0x10, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        mov word [DbSaveMode], 0x0
        call 0x1F4F:ViewHilights
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .3
.1:
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_5
        push 0x0
        push 0x0
        lea ax, [bp - 0x10]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_2
        push 0x0
        lea ax, [bp - 0x10]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        mov es, [segMenuText17]
        mov ax, [es:DeskMenuBar + 0x2]
        add ax, [es:DeskMenuBar + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov ax, [es:DeskMenuBar + 0x4]
        add ax, [es:DeskMenuBar]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov word [ScreenRowStride], 0x50
        push 0x10
        push strict word str_Pal_46
        push di
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.3:
        mov es, [segMenuText17]
        mov ax, [es:DeskMenuBar + 0x2]
        add ax, [es:DeskMenuBar + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov ax, [es:DeskMenuBar + 0x4]
        add ax, [es:DeskMenuBar]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuImportDbs                                              2E70:2054  94 PC
; Menu item: import the databases.
;
; Calls SaveModeState, LoadModeState, ImportDbsThunk. Far routine (retf).
;-----------------------------------------------------------------------------
MenuImportDbs:
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        call 0x1B35:ImportDbsThunk
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; MenuExportDbs                                              2E70:2090  94 PC
; Menu item: export the databases.
;
; Calls SaveModeState, LoadModeState, SetupStatsMenusThunk, ExportDbsThunk, AllocRecData,
; GetPaletteFar, FadePaletteInThunk, FindUnlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuExportDbs:
        enter 0x14, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        call 0x1B35:ExportDbsThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word lgstate
        push cs
        call SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        push cs
        call LoadModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_5
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
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_4
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk
        push 0x0
        lea ax, [bp - 0x14]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word DeskMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
