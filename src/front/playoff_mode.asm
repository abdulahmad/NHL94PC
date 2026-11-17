; Playoff mode: seeding the playoff tree, the playoff menu and drawing the tree (MENUS.OVL)

;-----------------------------------------------------------------------------
; LockerRoomLoopTail                                         26D4:0001  94 PC
; The rest of LockerRoomLoop, which runs on into this module.
;-----------------------------------------------------------------------------
LockerRoomLoopTail:
        cmp word [g_01BA], 0x1
        jnz short LockerRoomLoop.54 - 0xF70
.1:
        mov ax, [g_29CA]
        jmp short LockerRoomLoop.55 - 0xF70
        db 0x90

;-----------------------------------------------------------------------------
; POMenuResult4                                              26D4:000E  94 PC
; Menu item returning 4.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
POMenuResult4:
        mov ax, 0x4
        retf

;-----------------------------------------------------------------------------
; POMenuResult1                                              26D4:0012  94 PC
; Menu item returning 1.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
POMenuResult1:
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; MenuPlayoffHilights                                        26D4:0016  94 PC
; Highlights from the playoff desk.
;
; Calls SaveModeState, LoadModeState, ViewHilights, GetPage, CopyPlane, UseCurrentPage, BuildPathFar,
; LoadPackedHeader and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuPlayoffHilights:
        enter 0x10, 0x0
        push di
        push si
        push word 0x3415
        push strict word exhstate
        call 0x2E70:SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word postate
        call 0x2E70:LoadModeState
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
        call 0x2E70:LoadModeState
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
        push strict word str_Easndesk_20
        push 0x0
        push 0x0
        lea ax, [bp - 0x10]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Desk_17
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
        push strict word f_3448_0D44
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        mov es, [g_8B48]
        mov ax, [es:0xd46]
        add ax, [es:0xd4a]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov ax, [es:0xd48]
        add ax, [es:0xd44]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov word [g_08FC], 0x50
        push 0x10
        push strict word str_Pal_66
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
.3:
        mov es, [g_8B48]
        mov ax, [es:0xd46]
        add ax, [es:0xd4a]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov ax, [es:0xd48]
        add ax, [es:0xd44]
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
; CreatePlayoffs                                             26D4:0180  94 PC
; 'Please Enter New Play-Off Name'
;
; Calls SaveModeState, UseOtherPage, BuildPathFar, LoadPackedHeader, FindFarMsg, DrawRleFastHere,
; FindUnlink, VgaCopyBytes and others. Far routine (retf).
;-----------------------------------------------------------------------------
CreatePlayoffs:
        enter 0x90, 0x0
        push di
        push si
        mov byte [bp - 0x2e], 0x2e
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov cx, 0xc
        lea di, [bp - 0x2d]
        push ss
        pop es
        rep stosb
        push word 0x3415
        push strict word exhstate
        call 0x2E70:SaveModeState
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x90], ax
        mov [bp - 0x8e], cx
        push cx
        push ax
        push ds
        push strict word str_Embscup_4
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Bkgd_7
        push 0x0
        lea ax, [bp - 0x3c]
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
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [CurPage], 0x0
        jz short .1
        push word 0x3f00
        push 0x0
        push word 0x3f00
        jmp short .2
.1:
        push word 0x3f00
        push 0x0
        push word 0x7e00
.2:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word [bp - 0x8e]
        push word [bp - 0x90]
        push ds
        push strict word str_Playoffs
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x3c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x40], ax
        mov [bp - 0x3e], dx
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette_8
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x8e]
        push word [bp - 0x90]
        push ds
        push strict word str_Embpal_21
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_65
        push 0x0
        lea ax, [bp - 0x3c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xa], dx
        push 0xc
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        lea ax, [si + 0x24]
        push cx
        push ax
        lea ax, [si + 0x2f1]
        push cx
        push ax
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x0000:_fmemcpy
        add sp, 0xa
        push 0x10
        push di
        push si
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov ax, 0x40
        mov dx, 0x41
        call 0x03A3:SetCharPtr.regs
        push 0x0
        push 0x40
        push 0x42
        push 0x40
        push 0x41
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x5
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x36
        push 0x8
        lea ax, [bp - 0x2e]
        push ax
        push ds
        push strict word str_PleaseEnterNewPlayOffName
        call 0x0D90:NumberEntryDialog
        add sp, 0x14
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea ax, [bp - 0x14]
        push ax
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x18]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        cmp di, 0x1b
        jnz short .3
        jmp near .12
.3:
        cmp byte [bp - 0x2e], 0x0
        jnz short .4
        jmp near .12
.4:
        mov ax, 0x3415
        mov es, ax
        mov word [es:postate], 0x1
        mov word [es:f_3415_00B2], 0x9
        mov word [es:f_3415_00B4], 0x7
        or word [es:f_3415_00B6], 0x1ff
        and byte [es:f_3415_00B7], 0xfd
        mov ax, [es:f_3415_00B6]
        and ah, 0xfb
        or ah, 0x8
        mov [es:f_3415_00B6], ax
        or byte [es:f_3415_00B7], 0x70
        test byte [InputFlags], 0x2
        jz short .5
        mov word [es:f_3415_00BC], 0x2
        jmp short .9
.5:
        test byte [InputFlags], 0x4
        jz short .6
        mov word [es:f_3415_00BC], 0x4
        jmp short .9
.6:
        test byte [InputFlags], 0x8
        jz short .7
        mov word [es:f_3415_00BC], 0x8
        jmp short .9
.7:
        test byte [InputFlags], 0x1
        jz short .8
        mov word [es:f_3415_00BC], 0x1
        jmp short .9
.8:
        mov word [es:f_3415_00BC], 0x10
.9:
        mov es, [g_8B4A]
        cmp word [es:0xbc], 0x10
        jz short .10
        mov ax, 0x9
        jmp short .11
.10:
        mov ax, 0xffff
.11:
        mov [es:0xb8], ax
        mov word [es:0xbe], 0x10
        mov word [es:0xba], 0xfffe
        mov word [es:0xc0], 0x0
        mov word [es:0xc2], 0x1
        push es
        push strict word 0x62
        call 0x2E70:LoadModeState
        add sp, 0x4
        mov word [bp - 0xe], 0x0
        mov di, str_Po
        lea si, [bp - 0x2e]
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
        lea ax, [bp - 0x8c]
        push ax
        push 0x10
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        push -0x1
        lea ax, [bp - 0x14]
        push ax
        lea ax, [bp - 0x16]
        push ax
        push 0x2
        push word 0x3701
        push strict word f_3701_02A0
        push 0x2
        push word 0x36b8
        push strict word f_36B8_005B
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0xe], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .12
        lea ax, [bp - 0x2e]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
        jmp short .13
        db 0x90
.12:
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [bp - 0xe], 0x1
.13:
        cmp word [bp - 0xe], 0x0
        jz short .14
        jmp near .25
.14:
        lea ax, [bp - 0x2e]
        push ss
        push ax
        push word 0x3701
        push strict word f_3701_0E53
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea di, [bp - 0x2e]
        mov si, 0xc000
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
        mov di, str_SDb
        mov si, 0xc000
        push ds
        pop es
        mov cx, 0xffff
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
        mov di, 0xc000
        mov si, 0xc020
        mov cx, 0xffff
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        xchg di, si
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
.15:
        push word 0x3f00
        push word 0x7e00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_mkdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        mov ax, 0x190
        cwd
        call 0x03A3:SetDeadline.regs
        push strict word str_Err3_3
        push word [bp - 0x3e]
        push word [bp - 0x40]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        mov word [bp - 0xe], 0x1
        call 0x03A3:WaitDeadlineNoEoi
.16:
        cmp word [bp - 0xe], 0x0
        jz short .17
        jmp near .25
.17:
        call 0x0D90:AskYesNo
        call 0x25DD:LockerRoomScreen
        cmp ax, strict word 0x3
        jnz short .18
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_rmdir
        add sp, 0x2
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        jmp near .25
.18:
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        call 0x0FEF:CopyPlane
.19:
        push 0x10
        push strict word str_Pal_64
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        lea ax, [bp - 0x60]
        push ax
        push cs
        call POSeedTeams
        add sp, 0x2
        push strict word str_Wait
        push word [bp - 0x3e]
        push word [bp - 0x40]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        mov si, 0xb6c
        mov di, [bp - 0x2]
.20:
        push word 0x3701
        push strict word f_3701_0E53
        push word 0x3701
        push strict word f_3701_0BF4
        push word 0x3701
        push strict word str_Db_2
        push word [YesNoTextSeg]
        push word [YesNoText]
        mov es, [g_8B4C]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .21
        add si, 0x4
        cmp si, 0xb88
        jc short .20
        mov di, [bp - 0xe]
        jmp short .22
        db 0x90
.21:
        mov ax, 0x190
        cwd
        call 0x03A3:SetDeadline.regs
        push strict word str_Err3_2
        push word [bp - 0x3e]
        push word [bp - 0x40]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        lea ax, [bp - 0x2e]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
        mov di, 0x1
        call 0x03A3:WaitDeadlineNoEoi
.22:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .23
        jmp near .25
.23:
        lea ax, [bp - 0x2e]
        push ax
        lea ax, [bp - 0x60]
        push ax
        push cs
        call POCreateSchedule
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        mov ax, 0x190
        cwd
        call 0x03A3:SetDeadline.regs
        push strict word str_Err3
        push word [bp - 0x3e]
        push word [bp - 0x40]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastHere
        add sp, 0x4
        lea ax, [bp - 0x2e]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
        call 0x03A3:WaitDeadlineNoEoi
.24:
        push word 0x3415
        push strict word postate
        call 0x2E70:WriteModeState
        add sp, 0x4
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov es, [g_8B4E]
        mov word [es:0xbda], strict word PlayoffModeLoopThunk
        mov word [es:0xbdc], 0x1b35
        mov word [es:0xbf0], strict word EditPlayoffSettingsThunk
        mov word [es:0xbf2], 0x1b35
        mov word [es:0xc06], strict word MenuPlayoffHilightsThunk
        mov word [es:0xc08], 0x1b35
        mov word [g_11D8], 0x0
.25:
        push word [bp - 0x3e]
        push word [bp - 0x40]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Temp_15
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
        jz short .26
        call 0x0FEF:CopyPlane
.26:
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x8e]
        push word [bp - 0x90]
        push ds
        push strict word str_Easndesk_19
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x3c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_AE94], ax
        mov [g_AE96], dx
        push strict word str_Desk_16
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push word [g_AE96]
        push word [g_AE94]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word f_3448_0D44
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0x3415
        push strict word exhstate
        call 0x2E70:LoadModeState
        add sp, 0x4
        call 0x0837:NullFar11 + 0x10
        call 0x0837:NullFar
        call 0x0837:NullFar11 + 0x10
        mov ax, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; POSeedTeams                                                26D4:08CC  94 PC
; Seeds the playoff teams.
;
; Takes 1 word of stack arguments. Calls randomd0, POPickConfTeams. Far routine (retf).
;-----------------------------------------------------------------------------
POSeedTeams:
        enter 0xe, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov dx, 0x10
.1:
        inc bx
        inc bx
        mov word [bx - 0x2], 0xfff0
        dec dx
        jnz short .1
        mov word [bp - 0x4], 0x4
.2:
        mov ax, 0x10
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + di], -0x10
        jz short .4
.3:
        lea ax, [si + 0x1]
        mov cx, 0x10
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        cmp word [bx + di], -0x10
        jnz short .3
.4:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov word [bx + di], 0xffff
        mov ax, 0x10
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + di], -0x10
        jz short .6
.5:
        lea ax, [si + 0x1]
        mov cx, 0x10
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        cmp word [bx + di], -0x10
        jnz short .5
.6:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov word [bx + di], 0xfffe
        mov ax, 0x10
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + di], -0x10
        jz short .8
.7:
        lea ax, [si + 0x1]
        mov cx, 0x10
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        cmp word [bx + di], -0x10
        jnz short .7
.8:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov word [bx + di], 0xfffc
        mov ax, 0x10
        call 0x0C11:randomd0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + di], -0x10
        jz short .10
.9:
        lea ax, [si + 0x1]
        mov cx, 0x10
        cwd
        idiv cx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, 1
        cmp word [bx + di], -0x10
        jnz short .9
.10:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov word [bx + di], 0xfff8
        dec word [bp - 0x4]
        jz short .11
        jmp near .2
.11:
        mov ax, 0x3415
        mov es, ax
        mov bx, [g_29CC]
        shl bx, 1
        mov si, [g_29CA]
        shl si, 1
        mov ax, [es:si + f_3415_0128]
        mov [bp - 0xc], ax
        cmp ax, [es:bx + f_3415_0128]
        jnz short .16
        mov word [bp - 0x8], 0x0
        add ax, [di]
        jz short .13
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov di, [bp - 0x8]
.12:
        inc di
        mov ax, [bp - 0xc]
        inc bx
        inc bx
        add ax, [bx]
        jnz short .12
        mov [bp - 0x8], di
        mov di, [bp + 0x6]
.13:
        mov si, [bp - 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov ax, [g_29CA]
        mov [bx + di], ax
        mov si, 0xf
        mov bx, [g_29CC]
        shl bx, 1
        mov ax, [es:bx + f_3415_0128]
        mov [bp - 0xe], ax
        add ax, [di + 0x1e]
        jz short .15
        lea dx, [di + 0x1e]
        mov [bp - 0x2], dx
        mov [bp - 0x8], si
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov di, [bp - 0x8]
.14:
        dec di
        mov ax, [bp - 0xe]
        dec si
        dec si
        add ax, [si]
        jnz short .14
        mov [bp - 0x8], di
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov di, [bp + 0x6]
.15:
        mov ax, [g_29CC]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov [bx + di], ax
        jmp near .27
        db 0x90
.16:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov word [bp - 0x2], 0xffff
        mov ax, 0x3
        call 0x0C11:randomd0
        mov [bp - 0x6], ax
        inc ax
        jz short .19
        mov [bp - 0x4], di
        mov ax, 0x3415
        mov es, ax
        mov bx, [g_29CA]
        shl bx, 1
        mov ax, [es:bx + f_3415_0128]
        mov [bp - 0xc], ax
        mov bx, [bp - 0x2]
.17:
        mov ax, [bp - 0xc]
        mov di, [bp - 0x4]
        add ax, [di]
        jnz short .18
        inc bx
.18:
        add word [bp - 0x4], 0x2
        inc si
        cmp [bp - 0x6], bx
        jnz short .17
.19:
        mov ax, [g_29CA]
        dec si
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov di, [bp + 0x6]
        mov [bx + di], ax
        mov [bp - 0xa], si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov word [bp - 0x2], 0xffff
        mov [bp - 0x8], si
        mov ax, 0x4
        sub ax, [bp - 0x6]
        call 0x0C11:randomd0
        add [bp - 0x6], ax
        cmp word [bp - 0x6], -0x1
        jz short .22
        mov [bp - 0x8], si
        mov ax, [bp + 0x6]
        mov [bp - 0x4], ax
        mov ax, 0x3415
        mov es, ax
        mov bx, [g_29CC]
        shl bx, 1
        mov ax, [es:bx + f_3415_0128]
        mov [bp - 0xe], ax
        mov bx, [bp - 0x2]
        mov di, [bp - 0x4]
.20:
        mov ax, [bp - 0xe]
        add ax, [di]
        jnz short .21
        inc bx
.21:
        inc di
        inc di
        inc word [bp - 0x8]
        cmp [bp - 0x6], bx
        jnz short .20
.22:
        mov di, [bp + 0x6]
        mov ax, [g_29CC]
        mov bx, [bp - 0x8]
        dec bx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shl bx, 1
        mov [bx + di], ax
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        cmp cx, [bp - 0xa]
        jnl short .27
        shl bx, 1
        mov ax, [bx + di]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov bx, [bp - 0xa]
        shl bx, 1
        xor [bx + di], ax
        mov ax, [bx + di]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xor [bx + di], ax
        mov ax, [bx + di]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        xor [bx + di], ax
        mov word [bp - 0x4], 0x10
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov di, [bp - 0x4]
        mov ax, 0x3415
        mov es, ax
.23:
        mov si, [g_29CA]
        shl si, 1
        mov ax, [es:si + f_3415_0128]
        mov [bp - 0xc], ax
        add ax, [bx]
        jnz short .24
        mov si, [g_29CC]
        shl si, 1
        mov ax, [es:si + f_3415_0128]
        jmp short .25
        db 0x90
.24:
        mov si, [g_29CC]
        shl si, 1
        mov ax, [es:si + f_3415_0128]
        add ax, [bx]
        jnz short .26
        mov ax, [bp - 0xc]
.25:
        neg ax
        mov [bx], ax
.26:
        inc bx
        inc bx
        dec di
        jnz short .23
        mov di, [bp + 0x6]
.27:
        push 0x0
        push 0x1
        push di
        push cs
        call POPickConfTeams
        add sp, 0x6
        push 0x6
        push 0x2
        push di
        push cs
        call POPickConfTeams
        add sp, 0x6
        push 0xc
        push 0x4
        push di
        push cs
        call POPickConfTeams
        add sp, 0x6
        push 0x12
        push 0x8
        push di
        push cs
        call POPickConfTeams
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; POPickConfTeams                                            26D4:0B92  94 PC
; Picks each conference's teams.
;
; Takes 3 words of stack arguments. Calls randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
POPickConfTeams:
        enter 0xc, 0x0
        push di
        push si
        mov word [bp - 0x4], 0x0
        mov ax, [bp + 0x8]
        mov es, [g_8B50]
        mov bx, [g_29CA]
        shl bx, 1
        cmp [es:bx + 0x128], ax
        jnz short .3
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, [bp + 0xa]
        shl bx, 1
        add bx, 0x158
        mov ax, 0x3415
        mov es, ax
.1:
        mov ax, [g_29CA]
        cmp [es:bx], ax
        jz short .2
        inc bx
        inc bx
        inc di
        cmp di, 0x6
        jl short .1
.2:
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov ax, 0x1
        shl ax, cl
        mov [bp - 0x4], ax
.3:
        mov ax, [bp + 0x8]
        mov es, [g_8B50]
        mov bx, [g_29CC]
        shl bx, 1
        cmp [es:bx + 0x128], ax
        jz short .4
        mov si, [bp - 0x4]
        jmp short .7
.4:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, [bp + 0xa]
        shl bx, 1
        add bx, 0x158
        mov ax, 0x3415
        mov es, ax
.5:
        mov ax, [g_29CC]
        cmp [es:bx], ax
        jz short .6
        inc bx
        inc bx
        inc di
        cmp di, 0x6
        jl short .5
.6:
        mov si, [bp - 0x4]
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov ax, 0x1
        shl ax, cl
        db 0x0B, 0xF0                           ; insn: or si, ax
.7:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0xc], cx
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jz short .9
        mov [bp - 0x4], si
.8:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0xc], cx
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jnz short .8
.9:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0xa], cx
        mov ax, 0x1
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov cl, [bp - 0xc]
        shl ax, cl
        db 0x0B, 0xF0                           ; insn: or si, ax
        db 0x8A, 0xCA                           ; insn: mov cl, dl
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jz short .11
        mov [bp - 0x4], si
.10:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0xa], cx
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jnz short .10
.11:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], cx
        mov ax, 0x1
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov cl, [bp - 0xa]
        shl ax, cl
        db 0x0B, 0xF0                           ; insn: or si, ax
        db 0x8A, 0xCA                           ; insn: mov cl, dl
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jz short .13
        mov [bp - 0x4], si
.12:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], cx
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jnz short .12
.13:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x6], cx
        mov ax, 0x1
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        mov cl, [bp - 0x8]
        shl ax, cl
        db 0x0B, 0xF0                           ; insn: or si, ax
        db 0x8A, 0xCA                           ; insn: mov cl, dl
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jz short .15
        mov [bp - 0x4], si
.14:
        mov ax, 0x6
        call 0x0C11:randomd0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x6], cx
        mov ax, 0x1
        shl ax, cl
        test si, ax
        jnz short .14
.15:
        lea di, [bp - 0xc]
        mov bx, [bp + 0x6]
        mov word [bp - 0x4], 0x10
        mov ax, 0x3415
        mov es, ax
.16:
        mov ax, [bp + 0x8]
        add ax, [bx]
        jnz short .17
        inc di
        inc di
        mov si, [di - 0x2]
        add si, [bp + 0xa]
        shl si, 1
        mov ax, [es:si + f_3415_0158]
        mov [bx], ax
.17:
        inc bx
        inc bx
        dec word [bp - 0x4]
        jnz short .16
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POCreateSchedule                                           26D4:0D3A  94 PC
; Writes schedule.db.
;
; Takes 2 words of stack arguments. Calls _chdir, LoadRawHeader0, POInitSchedule, POPreSimRound1,
; POSeedRound2, POPreSimRound2, POSeedConfFinals, POPreSimConfFinals and others. Far routine (retf).
;-----------------------------------------------------------------------------
POCreateSchedule:
        enter 0xa, 0x0
        push di
        push word [bp + 0x8]
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
.1:
        mov ax, 0x1
        pop di
        leave
        retf
.2:
        push 0x0
        push strict word str_ScheduleDb_6
        call 0x149D:LoadRawHeader0
        add sp, 0x4
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [bp - 0x8]
        jz short .1
        les bx, [bp - 0x8]
        mov word [es:bx + 0x44], 0x7
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x44]
        mov [es:bx + 0x42], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x42]
        mov [es:bx + 0x40], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x40]
        mov [es:bx + 0x3e], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x3e]
        mov [es:bx + 0x3c], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x3c]
        mov [es:bx + 0x3a], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x3a]
        mov [es:bx + 0x38], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x38]
        mov [es:bx + 0x36], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x36]
        mov [es:bx + 0x34], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x34]
        mov [es:bx + 0x32], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x32]
        mov [es:bx + 0x30], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x30]
        mov [es:bx + 0x2e], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x2e]
        mov [es:bx + 0x2c], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x2c]
        mov [es:bx + 0x2a], ax
        les bx, [bp - 0x8]
        mov ax, [es:bx + 0x2a]
        mov [es:bx + 0x28], ax
        push word [bp + 0x6]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POInitSchedule
        add sp, 0x6
        mov es, [g_8B50]
        mov bx, [g_29CC]
        shl bx, 1
        mov ax, [es:bx + 0x128]
        mov bx, [g_29CA]
        shl bx, 1
        cmp [es:bx + 0x128], ax
        jnz short .3
        jmp near .6
.3:
        push word [g_29CC]
        push word [g_29CA]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POPreSimRound1
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POSeedRound2
        add sp, 0x4
        push word [g_29CC]
        push word [g_29CA]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POPreSimRound2
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POSeedConfFinals
        add sp, 0x4
        mov es, [g_8B50]
        mov bx, [g_29CA]
        shl bx, 1
        mov ax, [es:bx + 0x128]
        cmp ax, strict word 0x3
        jnl short .4
        mov bx, [g_29CC]
        shl bx, 1
        cmp word [es:bx + 0x128], 0x3
        jg short .5
.4:
        cmp ax, strict word 0x3
        jng short .6
        mov bx, [g_29CC]
        shl bx, 1
        cmp word [es:bx + 0x128], 0x3
        jnl short .6
.5:
        push word [g_29CC]
        push word [g_29CA]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POPreSimConfFinals
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        push cs
        call POSeedFinal
        add sp, 0x4
.6:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        add ax, 0x17a0
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.7:
        mov es, [bp - 0x2]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [g_29CA]
        jnz short .8
        mov al, [es:bx + 0x3]
        cmp ax, [g_29CC]
        jz short .9
.8:
        add di, 0x7
        add bx, 0x2a
        mov ax, es
        jmp short .7
.9:
        les bx, [bp - 0x8]
        mov [es:bx + 0x20], di
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        les bx, [bp - 0x8]
        mov [es:bx + 0x22], ax
        push strict word str_ScheduleDb_5
        call 0x03A3:FileSizeMsg
        add sp, 0x2
        push dx
        push ax
        push word [bp - 0x6]
        push word [bp - 0x8]
        push strict word str_ScheduleDb_4
        call 0x03A3:WriteFileCode
        add sp, 0xa
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        push word 0x1291
        call 0x0000:_chdir
        add sp, 0x2
        jmp near .1
.10:
        push word 0x1294
        call 0x0000:_chdir
        add sp, 0x2
        push word [bp - 0x6]
        push word [bp - 0x8]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; POSetSeriesTeams                                           26D4:0F72  94 PC
; Sets a series' two teams.
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
POSetSeriesTeams:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0xc]
        mov cx, [bp + 0xa]
        mov di, [bp + 0x6]
        mov es, [bp + 0x8]
        mov [es:di + 0x26], cl
        mov [es:di + 0x21], cl
        mov [es:di + 0x1a], cl
        mov [es:di + 0x15], cl
        mov [es:di + 0xf], cl
        mov [es:di + 0x8], cl
        mov [es:di + 0x2], cl
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:di + 0x27], al
        mov [es:di + 0x20], al
        mov [es:di + 0x1b], al
        mov [es:di + 0x14], al
        mov [es:di + 0xe], al
        mov [es:di + 0x9], al
        mov [es:di + 0x3], al
        lea ax, [di + 0x4]
        mov [bp - 0x6], es
        mov word [bp - 0xa], 0x7
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov cx, [bp - 0xa]
.1:
        mov al, 0xff
        mov es, [bp - 0x6]
        mov [es:si], al
        mov es, [bp - 0x6]
        mov [es:si + 0x1], al
        add si, 0x6
        mov ax, [bp - 0x6]
        loop .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POInitSchedule                                             26D4:0FEA  94 PC
; Empty playoff schedule.
;
; Takes 3 words of stack arguments. Calls POSetSeriesTeams. Far routine (retf).
;-----------------------------------------------------------------------------
POInitSchedule:
        enter 0x12, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov es, [bp + 0x8]
.1:
        mov ax, [di]
        mov si, [bp + 0x6]
        mov [es:bx + si], ax
        inc di
        inc di
        inc bx
        inc bx
        cmp bx, 0x20
        jl short .1
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
.2:
        mov byte [si], 0x4
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, 0x13
        mov [si + 0x1], dl
        cmp dl, 0x1e
        jna short .3
        inc byte [si]
        sub byte [si + 0x1], 0x1e
.3:
        add si, 0x6
        inc di
        cmp di, 0x1c
        jl short .2
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1848
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
.4:
        mov byte [si], 0x4
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        add dl, 0x9
        shl dl, 1
        mov [si + 0x1], dl
        cmp dl, 0x1e
        jna short .5
        inc byte [si]
        sub byte [si + 0x1], 0x1e
.5:
        add si, 0x6
        inc di
        cmp di, 0x1c
        jl short .4
        mov ax, DGROUP
        mov ds, ax
        lea di, [bp - 0x12]
        mov bx, [bp + 0xa]
        mov word [bp - 0x4], 0x10
.6:
        mov es, [g_8B50]
        mov si, [bx]
        shl si, 1
        cmp word [es:si + 0x128], 0x1
        jnz short .7
        mov ax, [bx]
        inc di
        inc di
        mov [di - 0x2], ax
.7:
        inc bx
        inc bx
        dec word [bp - 0x4]
        jnz short .6
        push word [bp - 0xc]
        push word [bp - 0x12]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x10]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17ca
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        lea di, [bp - 0x12]
        mov si, [bp + 0xa]
        mov word [bp - 0x4], 0x10
.8:
        mov es, [g_8B50]
        mov bx, [si]
        shl bx, 1
        cmp word [es:bx + 0x128], 0x2
        jnz short .9
        mov ax, [si]
        inc di
        inc di
        mov [di - 0x2], ax
.9:
        inc si
        inc si
        dec word [bp - 0x4]
        jnz short .8
        push word [bp - 0xc]
        push word [bp - 0x12]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17f4
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x10]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x181e
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        lea di, [bp - 0x12]
        mov si, [bp + 0xa]
        mov word [bp - 0x4], 0x10
.10:
        mov es, [g_8B50]
        mov bx, [si]
        shl bx, 1
        cmp word [es:bx + 0x128], 0x4
        jnz short .11
        mov ax, [si]
        inc di
        inc di
        mov [di - 0x2], ax
.11:
        inc si
        inc si
        dec word [bp - 0x4]
        jnz short .10
        push word [bp - 0xc]
        push word [bp - 0x12]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1848
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x10]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1872
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        lea di, [bp - 0x12]
        mov si, [bp + 0xa]
        mov word [bp - 0x4], 0x10
.12:
        mov es, [g_8B50]
        mov bx, [si]
        shl bx, 1
        cmp word [es:bx + 0x128], 0x8
        jnz short .13
        mov ax, [si]
        inc di
        inc di
        mov [di - 0x2], ax
.13:
        inc si
        inc si
        dec word [bp - 0x4]
        jnz short .12
        push word [bp - 0xc]
        push word [bp - 0x12]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x189c
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x10]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18c6
        push dx
        push ax
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov di, 0x31
        mov es, [bp - 0x8]
.14:
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [es:si + 0x1], al
        mov [es:si], al
        mov al, 0xff
        mov [es:si + 0x3], al
        mov [es:si + 0x2], al
        mov [es:si + 0x5], al
        mov [es:si + 0x4], al
        add si, 0x6
        mov ax, [bp - 0x8]
        dec di
        jnz short .14
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SeriesWinner                                               26D4:1226  94 PC
; Winner of a series.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
SeriesWinner:
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
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POSeriesScore                                              26D4:12BA  94 PC
; Wins of each team in a series.
;
; Takes 6 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
POSeriesScore:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov cx, [bp + 0xc]
        mov di, [bp + 0xa]
        les si, [bp + 0x6]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov bx, [bp + 0xe]
        mov [bx], ax
        mov al, [es:si + 0x3]
        mov bx, [bp + 0x10]
        mov [bx], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov [bx], ax
        mov [di], ax
.1:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        cmp word [bx], 0x4
        jnl short .7
        cmp byte [es:si + 0x4], 0xff
        jz short .6
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov bx, [bp + 0xe]
        cmp ax, [bx]
        jnz short .4
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jna short .5
.2:
        inc word [di]
.3:
        add si, 0x6
        cmp word [di], 0x4
        jl short .1
        jmp short .7
        db 0x90
.4:
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jna short .2
.5:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        inc word [bx]
        jmp short .3
.6:
        mov ax, 0xffff
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

;-----------------------------------------------------------------------------
; POSeedRound2                                               26D4:1334  94 PC
; Second round.
;
; Takes 2 words of stack arguments. Calls SeriesWinner, POSetSeriesTeams. Far routine (retf).
;-----------------------------------------------------------------------------
POSeedRound2:
        enter 0xc, 0x0
        push di
        push si
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17c4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        cmp byte [si + 0x4], 0xff
        jnz short .2
        cmp byte [si + 0x2e], 0xff
        jnz short .2
        cmp byte [si + 0x58], 0xff
        jnz short .2
        cmp byte [si + 0x82], 0xff
        jnz short .2
        cmp byte [si + 0xac], 0xff
        jnz short .2
        cmp byte [si + 0xd6], 0xff
        jnz short .2
        cmp byte [si + 0x100], 0xff
        jnz short .2
        cmp byte [si + 0x12a], 0xff
        jnz short .2
        sub si, 0x6
        inc bx
        cmp bx, 0x6
        jl short .1
.2:
        mov al, [si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0xc], ax
        mov al, [si + 0x1]
        inc ax
        inc ax
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xFF                           ; insn: sub di, di
.3:
        mov al, [bp - 0xc]
        mov [si], al
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, [bp - 0xa]
        mov [si + 0x1], dl
        cmp dl, 0x1e
        jna short .4
        inc byte [si]
        sub byte [si + 0x1], 0x1e
.4:
        add si, 0x6
        inc di
        cmp di, 0xe
        jl short .3
        inc word [bp - 0xa]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1944
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xFF                           ; insn: sub di, di
.5:
        mov al, [bp - 0xc]
        mov [si], al
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, [bp - 0xa]
        mov [si + 0x1], dl
        cmp dl, 0x1e
        jna short .6
        inc byte [si]
        sub byte [si + 0x1], 0x1e
.6:
        add si, 0x6
        inc di
        cmp di, 0xe
        jl short .5
        mov ax, DGROUP
        mov ds, ax
        push cx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .9
        mov ds, dx
.7:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .10
.8:
        mov ax, DGROUP
        mov ds, ax
.9:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .11
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .12
.10:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .7
        jmp short .8
        db 0x90
.11:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.12:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push 0x7
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17f4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .15
        mov ds, dx
.13:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .16
.14:
        mov ax, DGROUP
        mov ds, ax
.15:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x191a
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .17
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .18
.16:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .13
        jmp short .14
        db 0x90
.17:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.18:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push 0x7
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1848
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .21
        mov ds, dx
.19:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .22
.20:
        mov ax, DGROUP
        mov ds, ax
.21:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1944
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .23
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .24
.22:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .19
        jmp short .20
        db 0x90
.23:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.24:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push 0x7
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x189c
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .27
        mov ds, dx
.25:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .28
.26:
        mov ax, DGROUP
        mov ds, ax
.27:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x196e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .29
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .30
.28:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .25
        jmp short .26
        db 0x90
.29:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.30:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POSeedConfFinals                                           26D4:164A  94 PC
; Conference finals.
;
; Takes 2 words of stack arguments. Calls SeriesWinner, POSetSeriesTeams. Far routine (retf).
;-----------------------------------------------------------------------------
POSeedConfFinals:
        enter 0xc, 0x0
        push di
        push si
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1914
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        cmp byte [si + 0x4], 0xff
        jnz short .2
        cmp byte [si + 0x2e], 0xff
        jnz short .2
        cmp byte [si + 0x58], 0xff
        jnz short .2
        cmp byte [si + 0x82], 0xff
        jnz short .2
        sub si, 0x6
        inc bx
        cmp bx, 0x3
        jl short .1
.2:
        mov al, [si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0xc], ax
        mov al, [si + 0x1]
        inc ax
        inc ax
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xFF                           ; insn: sub di, di
.3:
        mov al, [bp - 0xc]
        mov [si], al
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, [bp - 0xa]
        mov [si + 0x1], dl
        cmp dl, 0x1f
        jna short .4
        inc byte [si]
        sub byte [si + 0x1], 0x1f
.4:
        add si, 0x6
        inc di
        db 0x3B, 0xF9                           ; insn: cmp di, cx
        jl short .3
        inc word [bp - 0xa]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19c2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xFF                           ; insn: sub di, di
.5:
        mov al, [bp - 0xc]
        mov [si], al
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, [bp - 0xa]
        mov [si + 0x1], dl
        cmp dl, 0x1f
        jna short .6
        inc byte [si]
        sub byte [si + 0x1], 0x1f
.6:
        add si, 0x6
        inc di
        db 0x3B, 0xF9                           ; insn: cmp di, cx
        jl short .5
        mov ax, DGROUP
        mov ds, ax
        push cx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .9
        mov ds, dx
.7:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .10
.8:
        mov ax, DGROUP
        mov ds, ax
.9:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .11
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .12
.10:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .7
        jmp short .8
        db 0x90
.11:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.12:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        push 0x7
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1944
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x6]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .15
        mov ds, dx
.13:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .16
.14:
        mov ax, DGROUP
        mov ds, ax
.15:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19c2
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .17
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .18
.16:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .13
        jmp short .14
        db 0x90
.17:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x6]
.18:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POSeedFinal                                                26D4:1826  94 PC
; Seeds the final series of the playoff tree.
;
; Takes 2 words of stack arguments. Calls SeriesWinner, POSetSeriesTeams. Far routine (retf).
;-----------------------------------------------------------------------------
POSeedFinal:
        enter 0xc, 0x0
        push di
        push si
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19bc
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        cmp byte [si + 0x4], 0xff
        jnz short .2
        cmp byte [si + 0x2e], 0xff
        jnz short .2
        sub si, 0x6
        inc bx
        cmp bx, 0x3
        jl short .1
.2:
        mov al, [si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0xc], ax
        mov al, [si + 0x1]
        add ax, strict word 0x3
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19ec
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        db 0x2B, 0xFF                           ; insn: sub di, di
.3:
        mov al, [bp - 0xc]
        mov [si], al
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x7
        cwd
        idiv cx
        shl dl, 1
        add dl, [bp - 0xa]
        mov [si + 0x1], dl
        cmp dl, 0x1f
        jna short .4
        inc byte [si]
        sub byte [si + 0x1], 0x1f
.4:
        add si, 0x6
        inc di
        db 0x3B, 0xF9                           ; insn: cmp di, cx
        jl short .3
        mov ax, DGROUP
        mov ds, ax
        push cx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xc], ax
        push 0x7
        lea ax, [di + 0x2a]
        push word [bp - 0x2]
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        cmp [es:bx], ax
        jz short .7
        mov ds, dx
.5:
        mov ax, [bp - 0xa]
        cmp [si], ax
        jnz short .8
.6:
        mov ax, DGROUP
        mov ds, ax
.7:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19ec
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
        mov ax, [bp - 0xc]
        mov es, [bp - 0x6]
        cmp [es:si], ax
        jnz short .9
        push word [bp - 0xa]
        push ax
        push dx
        jmp short .10
.8:
        mov ax, [bp - 0xc]
        inc si
        inc si
        cmp [si], ax
        jnz short .5
        jmp short .6
        db 0x90
.9:
        push ax
        push word [bp - 0xa]
        push word [bp - 0x2]
.10:
        push di
        push cs
        call POSetSeriesTeams
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POSimSeriesTeamWins                                        26D4:192E  94 PC
; Simulates until a team has its wins.
;
; Takes 3 words of stack arguments. Calls BuildPathFar, OpenReadWriteShared, FatalError,
; OpenReadShared, SimulateGameThunk, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
POSimSeriesTeamWins:
        enter 0x2c, 0x0
        push di
        push si
        lea di, [bp - 0x4]
        mov si, 0x1297
        mov ax, ss
        mov es, ax
        movsb
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov cx, 0x1
        lea di, [bp - 0x3]
        rep stosb
        mov ax, 0xbaf
        mov cx, 0x3701
        mov [bp - 0x2c], ax
        mov [bp - 0x2a], cx
        push cx
        push ax
        mov es, [g_8B4C]
        push word [es:0xb7e]
        push word [es:0xb7c]
        push 0x0
        push 0x0
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x28]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x1298
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        mov es, [g_8B4C]
        push word [es:0xb7a]
        push word [es:0xb78]
        push 0x0
        push 0x0
        lea ax, [bp - 0x28]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x28]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word 0x129b
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x2], di
        mov si, [bp + 0x6]
.3:
        cmp [bp - 0x2], di
        jnl short .4
        push 0x2
        jmp short .6
.4:
        mov es, [bp + 0x8]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0xa]
        jnz short .5
        push 0x0
        jmp short .6
.5:
        push 0x1
.6:
        push word [bp - 0x8]
        push word [bp - 0x6]
        push word [bp + 0x8]
        push si
        push word 0x44c
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        lea ax, [bp - 0x4]
        push ss
        push ax
        call 0x1B35:SimulateGameThunk
        add sp, 0x14
        mov es, [bp + 0x8]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0xa]
        jnz short .8
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jna short .9
.7:
        inc di
        jmp short .10
        db 0x90
.8:
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jc short .7
.9:
        inc word [bp - 0x2]
.10:
        add si, 0x6
        cmp di, 0x4
        jl short .3
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POSimSeries                                                26D4:1A6C  94 PC
; Simulates a series.
;
; Takes 3 words of stack arguments. Calls BuildPathFar, OpenReadWriteShared, FatalError,
; OpenReadShared, SimulateGameThunk, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
POSimSeries:
        enter 0x2e, 0x0
        push di
        push si
        mov si, [bp + 0xa]
        push si
        lea di, [bp - 0x6]
        mov si, 0x129e
        mov ax, ss
        mov es, ax
        movsb
        pop si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov cx, 0x1
        lea di, [bp - 0x5]
        rep stosb
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shr ax, 1
        inc ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        les bx, [bp + 0x6]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x4], ax
        mov ax, 0xbaf
        mov cx, 0x3701
        mov [bp - 0x2e], ax
        mov [bp - 0x2c], cx
        push cx
        push ax
        mov es, [g_8B4C]
        push word [es:0xb7e]
        push word [es:0xb7c]
        push 0x0
        push 0x0
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x129f
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        mov es, [g_8B4C]
        push word [es:0xb7a]
        push word [es:0xb78]
        push 0x0
        push 0x0
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word 0x12a2
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x2], di
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .8
        mov [bp + 0xa], si
        mov si, [bp + 0x6]
.3:
        cmp [bp + 0xa], di
        jna short .8
        push 0x2
        push word [bp - 0xa]
        push word [bp - 0x8]
        push word [bp + 0x8]
        push si
        push word 0x44c
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        lea ax, [bp - 0x6]
        push ss
        push ax
        call 0x1B35:SimulateGameThunk
        add sp, 0x14
        mov es, [bp + 0x8]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp - 0x4]
        jnz short .4
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jna short .5
        jmp short .6
        db 0x90
.4:
        mov al, [es:si + 0x5]
        cmp [es:si + 0x4], al
        jna short .6
.5:
        inc di
        jmp short .7
        db 0x90
.6:
        inc word [bp - 0x2]
.7:
        add si, 0x6
        mov ax, [bp - 0x2]
        cmp [bp + 0xa], ax
        ja short .3
.8:
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0xa]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; POPreSimRound1                                             26D4:1BB8  94 PC
; Simulates round 1 series without humans.
;
; Takes 4 words of stack arguments. Calls POSimSeries, POSimSeriesTeamWins. Far routine (retf).
;-----------------------------------------------------------------------------
POPreSimRound1:
        enter 0x6, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4], dx
        mov word [bp - 0x2], 0x8
.1:
        mov es, [bp - 0x4]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x3]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x2]
        cmp ax, [bp + 0xc]
        jz short .2
        mov al, [es:si + 0x3]
        cmp ax, [bp + 0xc]
        jz short .2
        push 0x7
        push es
        push si
        push cs
        call POSimSeries
        jmp short .5
        db 0x90
.2:
        push word [bp + 0xc]
        jmp short .4
        db 0x90
.3:
        push di
.4:
        push es
        push si
        push cs
        call POSimSeriesTeamWins
.5:
        add sp, 0x6
        add si, 0x2a
        mov ax, [bp - 0x4]
        dec word [bp - 0x2]
        jnz short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POPreSimRound2                                             26D4:1C26  94 PC
; Same for round 2.
;
; Takes 4 words of stack arguments. Calls POSimSeries, POSimSeriesTeamWins. Far routine (retf).
;-----------------------------------------------------------------------------
POPreSimRound2:
        enter 0x6, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4], dx
        mov word [bp - 0x2], 0x4
.1:
        mov es, [bp - 0x4]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x3]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x2]
        cmp ax, [bp + 0xc]
        jz short .2
        mov al, [es:si + 0x3]
        cmp ax, [bp + 0xc]
        jz short .2
        push 0x7
        push es
        push si
        push cs
        call POSimSeries
        jmp short .5
        db 0x90
.2:
        push word [bp + 0xc]
        jmp short .4
        db 0x90
.3:
        push di
.4:
        push es
        push si
        push cs
        call POSimSeriesTeamWins
.5:
        add sp, 0x6
        add si, 0x2a
        mov ax, [bp - 0x4]
        dec word [bp - 0x2]
        jnz short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POPreSimConfFinals                                         26D4:1C94  94 PC
; Same for the conference finals.
;
; Takes 4 words of stack arguments. Calls POSimSeries, POSimSeriesTeamWins. Far routine (retf).
;-----------------------------------------------------------------------------
POPreSimConfFinals:
        enter 0x6, 0x0
        push di
        push si
        mov di, [bp + 0xa]
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4], dx
        mov word [bp - 0x2], 0x2
.1:
        mov es, [bp - 0x4]
        mov al, [es:si + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x3]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .3
        mov al, [es:si + 0x2]
        cmp ax, [bp + 0xc]
        jz short .2
        mov al, [es:si + 0x3]
        cmp ax, [bp + 0xc]
        jz short .2
        push 0x7
        push es
        push si
        push cs
        call POSimSeries
        jmp short .5
        db 0x90
.2:
        push word [bp + 0xc]
        jmp short .4
        db 0x90
.3:
        push di
.4:
        push es
        push si
        push cs
        call POSimSeriesTeamWins
.5:
        add sp, 0x6
        add si, 0x2a
        mov ax, [bp - 0x4]
        dec word [bp - 0x2]
        jnz short .1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POHandleElimination                                        26D4:1D02  94 PC
; Human team eliminated.
;
; Takes 3 words of stack arguments. Calls SetDialogColors, MessageBox, _fstrcpy, _chdir, FatalError,
; POSimSeries, POSeedConfFinals, POSeedFinal and others. Far routine (retf).
;-----------------------------------------------------------------------------
POHandleElimination:
        enter 0x2e, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov word [bp - 0x16], 0xa0
        mov word [bp - 0x18], 0x64
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        jmp near .34
.1:
        push 0x0
        push 0x40
        push 0x42
        push 0x40
        push 0x41
        call 0x0D90:SetDialogColors
        add sp, 0xa
        dec si
        jz short .2
        jmp near .31
.2:
        push -0x1
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x16]
        push ax
        push 0x2
        push word 0x36b8
        push strict word f_36B8_0170
        push 0x4
        push ds
        push strict word g_12AC
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        jmp near .33
.3:
        push 0x0
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x16]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push ds
        push strict word g_12D4
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push strict word str_Xx1_2
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        les bx, [bp + 0x8]
        mov ax, [es:bx + 0x22]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .5
        jmp near .28
.5:
        sub ax, strict word 0x7
        jng short .10
        dec ax
        jnl short .6
        jmp near .28
.6:
        dec ax
        dec ax
        jg short .7
        jmp near .17
.7:
        dec ax
        dec ax
        jnl short .8
        jmp near .28
.8:
        dec ax
        jg short .9
        jmp near .24
.9:
        jmp near .28
        db 0x90
.10:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        mov [es:bx + 0x3e], ax
        les bx, [bp + 0x8]
        mov ax, [es:bx + 0x3e]
        mov [es:bx + 0x3c], ax
        les bx, [bp + 0x8]
        mov ax, [es:bx + 0x3c]
        mov [es:bx + 0x3a], ax
        les bx, [bp + 0x8]
        mov ax, [es:bx + 0x3a]
        mov [es:bx + 0x38], ax
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        add ax, 0x18f0
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        mov word [bp - 0x1a], 0x4
.11:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [bp - 0x1c]
        push word [bp - 0x1e]
        push cs
        call POSimSeries
        add sp, 0x6
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        add ax, strict word 0x4
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x8], si
        db 0x8B, 0xFE                           ; insn: mov di, si
.12:
        mov es, [bp - 0xa]
        cmp byte [es:bx], 0xff
        jz short .13
        add bx, 0x6
        mov ax, es
        inc di
        cmp di, 0x7
        jl short .12
.13:
        mov bl, [AnnouncerFlags]
        and bx, 0x60
        shr bl, byte 0x5
        inc bx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        cmp bx, 0x4
        jnl short .15
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC7                           ; insn: add ax, di
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, 0x4
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0x6], ax
        mov [bp - 0x8], di
        mov [bp - 0xa], bx
        mov es, [bp - 0x12]
.14:
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        mov di, [bp - 0x14]
        movsw
        movsw
        movsw
        pop ds
        add word [bp - 0x14], 0x6
        dec word [bp - 0x6]
        jnz short .14
.15:
        add word [bp - 0x1e], 0x2a
        dec word [bp - 0x1a]
        jz short .16
        jmp near .11
.16:
        push word [bp + 0xa]
        push word [bp + 0x8]
        push cs
        call POSeedConfFinals
        add sp, 0x4
.17:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x8]
        mov [es:bx + 0x42], ax
        les bx, [bp + 0x8]
        mov ax, [es:bx + 0x42]
        mov [es:bx + 0x40], ax
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        add ax, 0x1998
        mov [bp - 0x1e], ax
        mov [bp - 0x1c], dx
        mov word [bp - 0x1a], 0x2
.18:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [bp - 0x1c]
        push word [bp - 0x1e]
        push cs
        call POSimSeries
        add sp, 0x6
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        add ax, strict word 0x4
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x8], si
        db 0x8B, 0xFE                           ; insn: mov di, si
.19:
        mov es, [bp - 0xa]
        cmp byte [es:bx], 0xff
        jz short .20
        add bx, 0x6
        mov ax, es
        inc di
        cmp di, 0x7
        jl short .19
.20:
        mov bl, [AnnouncerFlags]
        and bx, 0x60
        shr bl, byte 0x5
        inc bx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        cmp bx, 0x4
        jnl short .22
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC7                           ; insn: add ax, di
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, 0x4
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0x6], ax
        mov [bp - 0x8], di
        mov [bp - 0xa], bx
        mov es, [bp - 0x12]
.21:
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        mov di, [bp - 0x14]
        movsw
        movsw
        movsw
        pop ds
        add word [bp - 0x14], 0x6
        dec word [bp - 0x6]
        jnz short .21
.22:
        add word [bp - 0x1e], 0x2a
        dec word [bp - 0x1a]
        jz short .23
        jmp near .18
.23:
        push word [bp + 0xa]
        push word [bp + 0x8]
        push cs
        call POSeedFinal
        add sp, 0x4
.24:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x8]
        mov [es:bx + 0x44], ax
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        add ax, 0x19ec
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x1c], dx
        push dx
        push ax
        push cs
        call POSimSeries
        add sp, 0x6
        db 0x2B, 0xFF                           ; insn: sub di, di
        lea ax, [si + 0x4]
        mov cx, [bp - 0x1c]
        mov [bp - 0xc], ax
        mov [bp - 0xa], cx
        mov [bp - 0x1e], si
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.25:
        mov es, [bp - 0xa]
        cmp byte [es:bx], 0xff
        jz short .26
        add bx, 0x6
        mov ax, es
        inc di
        cmp di, 0x7
        jl short .25
.26:
        mov [bp - 0x8], di
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov bl, [AnnouncerFlags]
        and bx, 0x60
        shr bl, byte 0x5
        inc bx
        db 0x2B, 0xF3                           ; insn: sub si, bx
        cmp bx, 0x4
        jnl short .28
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC6                           ; insn: add ax, si
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, 0x4
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0x6], ax
        mov [bp - 0x8], si
        mov [bp - 0xa], bx
        mov es, [bp - 0x12]
.27:
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        mov di, [bp - 0x14]
        movsw
        movsw
        movsw
        pop ds
        add word [bp - 0x14], 0x6
        dec word [bp - 0x6]
        jnz short .27
.28:
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        add ax, 0x17a0
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1c], dx
        mov si, 0x20
.29:
        les bx, [bp + 0x8]
        push word [es:bx + si + 0x8]
        push word [bp - 0x1c]
        push di
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [si + playofftree], ax
        cmp ax, strict word 0xffff
        jnz short .30
        mov word [si + playofftree], 0x18
.30:
        add di, 0x2a
        mov ax, [bp - 0x1c]
        inc si
        inc si
        cmp si, 0x3e
        jl short .29
        push word 0x12a9
        call 0x0000:_chdir
        add sp, 0x2
        jmp short .32
        db 0x90
.31:
        mov ax, 0x3e8
        cwd
        call 0x03A3:SetDeadline.regs
        push 0x0
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x16]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x6
        push ds
        push strict word g_12BC
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        call 0x03A3:WaitDeadlineNoEoi
.32:
        call 0x0D90:RestoreUnderBox
.33:
        push cs
        call DrawPlayoffTree
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word f_3448_19BA
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
.34:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POAfterGame                                                26D4:2112  94 PC
; After a playoff game.
;
; Takes 2 words of stack arguments. Calls PostGameToTeamDbThunk, SeriesWinner, _fstrcpy, _chdir,
; FatalError, POSimSeries, POSeedRound2, POSeedConfFinals and others. Far routine (retf).
;-----------------------------------------------------------------------------
POAfterGame:
        enter 0x2a, 0x0
        push di
        push si
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x20]
        mov [bp - 0xc], ax
        push word 0x3701
        push strict word f_3701_0E53
        add ax, 0x3f0
        push ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4], ax
        push ax
        push word [g_29CA]
        push ds
        push strict word str_Db_4
        push word 0x3701
        push strict word f_3701_0E53
        call 0x1B35:PostGameToTeamDbThunk
        add sp, 0x12
        push word 0x3701
        push strict word f_3701_0E53
        mov ax, [bp - 0xc]
        add ax, 0x3f0
        push ax
        push 0x1
        push word [g_29CC]
        push ds
        push strict word str_Db_3
        push word 0x3701
        push strict word f_3701_0E53
        call 0x1B35:PostGameToTeamDbThunk
        add sp, 0x12
        mov ax, [bp - 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov al, [hmscore]
        les bx, [bp - 0x12]
        mov [es:bx + 0x4], al
        mov al, [awscore]
        mov [es:bx + 0x5], al
        mov cx, 0x7
        mov ax, [bp - 0xc]
        cwd
        idiv cx
        mov [bp - 0xc], ax
        imul ax, ax, 0x2a
        add ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov cl, [AnnouncerFlags]
        and cx, 0x70
        shr cl, byte 0x4
        push cx
        push dx
        push ax
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [bp - 0x8], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .1
        jmp near POAfterGameJumpTable.3
.1:
        cmp ax, [g_29CA]
        jnz short .2
        mov word [bp - 0x6], 0x1
        jmp short .3
        db 0x90
.2:
        mov word [bp - 0x6], 0x0
.3:
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push strict word str_Xx1
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        cmp word [bp - 0xc], 0x8
        jl short .5
        jmp near .15
.5:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x6]
        mov [es:bx + 0x36], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x36]
        mov [es:bx + 0x34], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x34]
        mov [es:bx + 0x32], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x32]
        mov [es:bx + 0x30], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x30]
        mov [es:bx + 0x2e], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x2e]
        mov [es:bx + 0x2c], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x2c]
        mov [es:bx + 0x2a], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x2a]
        mov [es:bx + 0x28], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov word [bp - 0xa], 0x0
        jmp short .11
        db 0x90
.6:
        inc word [bp - 0x14]
.7:
        cmp word [bp - 0x14], 0x7
        jnl short .8
        mov si, [bp - 0x14]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        les bx, [bp - 0x12]
        cmp byte [es:bx + si + 0x4], 0xff
        jnz short .6
.8:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x60
        shr al, byte 0x5
        inc ax
        mov [bp - 0xe], ax
        sub [bp - 0x14], ax
        jmp short .10
.9:
        mov ax, [bp - 0xe]
        add ax, [bp - 0x14]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, dx
        mov ds, dx
        movsw
        movsw
        movsw
        pop ds
        inc word [bp - 0xe]
.10:
        cmp word [bp - 0xe], 0x4
        jl short .9
        inc word [bp - 0xa]
        add word [bp - 0x12], 0x2a
.11:
        cmp word [bp - 0xa], 0x8
        jnl short .13
        mov ax, [bp - 0xc]
        cmp [bp - 0xa], ax
        jz short .12
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [bp - 0x10]
        push word [bp - 0x12]
        push cs
        call POSimSeries
        add sp, 0x6
.12:
        mov word [bp - 0x14], 0x0
        jmp near .7
        db 0x90
.13:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call POSeedRound2
.14:
        add sp, 0x4
        jmp near .41
.15:
        cmp word [bp - 0xc], 0xc
        jl short .16
        jmp near .25
.16:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x6]
        mov [es:bx + 0x3e], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x3e]
        mov [es:bx + 0x3c], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x3c]
        mov [es:bx + 0x3a], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x3a]
        mov [es:bx + 0x38], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov word [bp - 0xa], 0x8
        jmp short .22
.17:
        inc word [bp - 0x14]
.18:
        cmp word [bp - 0x14], 0x7
        jnl short .19
        mov si, [bp - 0x14]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        les bx, [bp - 0x12]
        cmp byte [es:bx + si + 0x4], 0xff
        jnz short .17
.19:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x60
        shr al, byte 0x5
        inc ax
        mov [bp - 0xe], ax
        sub [bp - 0x14], ax
        jmp short .21
.20:
        mov ax, [bp - 0xe]
        add ax, [bp - 0x14]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, dx
        mov ds, dx
        movsw
        movsw
        movsw
        pop ds
        inc word [bp - 0xe]
.21:
        cmp word [bp - 0xe], 0x4
        jl short .20
        inc word [bp - 0xa]
        add word [bp - 0x12], 0x2a
.22:
        cmp word [bp - 0xa], 0xc
        jnl short .24
        mov ax, [bp - 0xc]
        cmp [bp - 0xa], ax
        jz short .23
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [bp - 0x10]
        push word [bp - 0x12]
        push cs
        call POSimSeries
        add sp, 0x6
.23:
        mov word [bp - 0x14], 0x0
        jmp near .18
        db 0x90
.24:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call POSeedConfFinals
        jmp near .14
        db 0x90
.25:
        cmp word [bp - 0xc], 0xe
        jl short .26
        jmp near .35
.26:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x6]
        mov [es:bx + 0x42], ax
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x42]
        mov [es:bx + 0x40], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov word [bp - 0xa], 0xc
        jmp short .32
.27:
        inc word [bp - 0x14]
.28:
        cmp word [bp - 0x14], 0x7
        jnl short .29
        mov si, [bp - 0x14]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        les bx, [bp - 0x12]
        cmp byte [es:bx + si + 0x4], 0xff
        jnz short .27
.29:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x60
        shr al, byte 0x5
        inc ax
        mov [bp - 0xe], ax
        sub [bp - 0x14], ax
        jmp short .31
.30:
        mov ax, [bp - 0xe]
        add ax, [bp - 0x14]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, dx
        mov ds, dx
        movsw
        movsw
        movsw
        pop ds
        inc word [bp - 0xe]
.31:
        cmp word [bp - 0xe], 0x4
        jl short .30
        inc word [bp - 0xa]
        add word [bp - 0x12], 0x2a
.32:
        cmp word [bp - 0xa], 0xe
        jnl short .34
        mov ax, [bp - 0xc]
        cmp [bp - 0xa], ax
        jz short .33
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        push ax
        push word [bp - 0x10]
        push word [bp - 0x12]
        push cs
        call POSimSeries
        add sp, 0x6
.33:
        mov word [bp - 0x14], 0x0
        jmp near .28
        db 0x90
.34:
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call POSeedFinal
        jmp near .14
        db 0x90
.35:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        les bx, [bp + 0x6]
        mov [es:bx + 0x44], ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19ec
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov word [bp - 0x14], 0x0
        jmp short .37
.36:
        inc word [bp - 0x14]
.37:
        cmp word [bp - 0x14], 0x7
        jnl short .38
        mov si, [bp - 0x14]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        les bx, [bp - 0x12]
        cmp byte [es:bx + si + 0x4], 0xff
        jnz short .36
.38:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x60
        shr al, byte 0x5
        inc ax
        mov [bp - 0xe], ax
        sub [bp - 0x14], ax
        jmp short .40
.39:
        mov ax, [bp - 0xe]
        add ax, [bp - 0x14]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        add ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, strict word 0x6
        push ds
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, dx
        mov ds, dx
        movsw
        movsw
        movsw
        pop ds
        inc word [bp - 0xe]
.40:
        cmp word [bp - 0xe], 0x4
        jl short .39
.41:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x17a0
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        mov word [bp - 0xa], 0x10
.42:
        mov si, [bp - 0xa]
        shl si, 1
        les bx, [bp + 0x6]
        push word [es:bx + si + 0x8]
        push word [bp - 0x10]
        push word [bp - 0x12]
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [si + playofftree], ax
        cmp ax, strict word 0xffff
        jnz short .43
        mov word [si + playofftree], 0x18
.43:
        inc word [bp - 0xa]
        add word [bp - 0x12], 0x2a
        cmp word [bp - 0xa], 0x1f
        jl short .42
        push word 0x12e4
        call 0x0000:_chdir
        add sp, 0x2
        mov ax, [bp - 0xc]
        jmp near .53
        db 0x90
.44:
        mov word [bp - 0xc], 0x8
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x18f0
.45:
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        jmp near POAfterGameJumpTable.1
        db 0x90
.46:
        mov word [bp - 0xc], 0x9
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x191a
        jmp short .45
.47:
        mov word [bp - 0xc], 0xa
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1944
        jmp short .45
.48:
        mov word [bp - 0xc], 0xb
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x196e
        jmp short .45
.49:
        mov word [bp - 0xc], 0xc
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x1998
        jmp short .45
.50:
        mov word [bp - 0xc], 0xd
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19c2
        jmp short .45
.51:
        mov word [bp - 0xc], 0xe
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, 0x19ec
        jmp short .45
.52:
        mov word [bp - 0xc], 0xf
        mov es, [g_8B52]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x18d6], ax
        mov [es:0x18d4], ax
        les bx, [bp + 0x6]
        mov word [es:bx + 0x20], 0x69
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call SaveScheduleDB
        add sp, 0x4
        jmp short POAfterGameJumpTable.1
        db 0x90
.53:
        cmp ax, strict word 0xe
        ja short POAfterGameJumpTable.1
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x269e]
        db 0x90
POAfterGameJumpTable:                           ; jump table of POAfterGame: 15 case targets
        dw POAfterGame.44
        dw POAfterGame.44
        dw POAfterGame.46
        dw POAfterGame.46
        dw POAfterGame.47
        dw POAfterGame.47
        dw POAfterGame.48
        dw POAfterGame.48
        dw POAfterGame.49
        dw POAfterGame.49
        dw POAfterGame.50
        dw POAfterGame.50
        dw POAfterGame.51
        dw POAfterGame.51
        dw POAfterGame.52
.1:
        mov ax, [bp - 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        les bx, [bp + 0x6]
        mov [es:bx + 0x20], ax
        push word 0x3415
        push strict word postate
        call 0x2E70:WriteModeState
        add sp, 0x4
        push 0x0
        push 0x0
        push strict word str_Tied_3
        push word [g_11D6]
        push word 0xc1f4
        call 0x0000:_sprintf
        add sp, 0xa
        push ds
        push strict word g_C1F4
        push word 0x3a0b
        push strict word f_3A0B_AC45
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp word [bp - 0xc], 0xf
        jnz short .2
        jmp near .8
.2:
        mov bx, [bp - 0xc]
        shl bx, 1
        mov word [bx + g_C224], 0x19
        jmp near .8
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x26], ax
        mov [bp - 0x24], ax
        les bx, [bp + 0x6]
        inc word [es:bx + 0x20]
        les bx, [bp + 0x6]
        mov ax, [es:bx + 0x20]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        add bx, 0x17a0
        mov [bp - 0x12], bx
        mov [bp - 0x10], es
        lea ax, [bp - 0x28]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        lea ax, [bp - 0x24]
        push ax
        lea cx, [bp - 0x26]
        push cx
        imul dx, [bp - 0xc], 0x2a
        add dx, [bp + 0x6]
        mov bx, es
        add dx, 0x17a0
        push bx
        push dx
        push cs
        call POSeriesScore
        add sp, 0xc
        mov ax, [bp - 0x26]
        cmp [bp - 0x24], ax
        jnz short .4
        push word [bp - 0x24]
        push ax
        push strict word str_Tied_2
        jmp short .7
        db 0x90
.4:
        cmp [bp - 0x24], ax
        jnl short .5
        push word [bp - 0x24]
        push ax
        mov bx, [bp - 0x2a]
        jmp short .6
.5:
        push ax
        push word [bp - 0x24]
        mov bx, [bp - 0x28]
.6:
        shl bx, 1
        push word [bx + TeamNameClips]
.7:
        push word [g_11D6]
        push word 0xc1f4
        call 0x0000:_sprintf
        add sp, 0xa
        push ds
        push strict word g_C1F4
        push word 0x3a0b
        push strict word f_3A0B_AC45
        call 0x0000:_fstrcpy
        add sp, 0x8
.8:
        cmp word [bp - 0xc], 0xf
        jl short .9
        jmp near .40
.9:
        cmp word [bp - 0x8], 0x0
        jnl short .10
        jmp near .33
.10:
        mov ax, [g_01C0]
        cmp [g_01C2], ax
        jnz short .12
.11:
        mov word [bp - 0x2], 0x1
        jmp short .18
.12:
        cmp word [g_01B8], 0x0
        jnl short .13
        mov ax, 0x1
        jmp short .14
.13:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.14:
        mov [bp - 0x2a], ax
        cmp word [g_01BA], 0x0
        jnl short .15
        mov ax, 0x1
        jmp short .16
        db 0x90
.15:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.16:
        xor ax, [bp - 0x2a]
        jnz short .11
        cmp word [g_01B8], 0x0
        jnl short .17
        cmp word [g_01BA], 0x0
        jnl short .17
        mov word [bp - 0x2], 0x0
        jmp short .18
.17:
        mov word [bp - 0x2], 0x2
.18:
        cmp word [bp - 0x2], 0x1
        jnz short .21
        mov ax, [bp - 0x8]
        cmp [g_01B8], ax
        jnz short .19
        jmp near .24
.19:
        cmp [g_01BA], ax
        jnz short .20
        jmp near .24
.20:
        les bx, [bp + 0x6]
        mov word [es:bx + 0x20], 0x69
        mov es, [g_8B52]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x18d6], ax
        mov [es:0x18d4], ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call SaveScheduleDB
        add sp, 0x4
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.21:
        cmp word [bp - 0x2], 0x2
        jnz short .24
        imul ax, [bp - 0x6], word 0x2e8
        add ax, 0x9f85
        push ds
        push ax
        push word 0x36b8
        push strict word f_36B8_00D0
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp word [bp - 0x6], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        imul ax, ax, word 0x2e8
        add ax, 0x9f85
        push ds
        push ax
        push word 0x36b8
        push strict word f_36B8_0113
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov ax, [bp - 0x8]
        cmp [g_01B8], ax
        jz short .22
        cmp word [g_01C0], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x1
        add ax, strict word 0xfffe
        mov [g_01B8], ax
        jmp short .23
.22:
        cmp word [g_01C2], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x1
        add ax, strict word 0xfffe
        mov [g_01BA], ax
.23:
        mov word [bp - 0x4], 0x2
.24:
        mov ax, [bp - 0xc]
        les bx, [bp + 0x6]
        mov [es:bx + 0x22], ax
        les bx, [bp - 0x12]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [g_29CA], ax
        mov al, [es:bx + 0x3]
        mov [g_29CC], ax
        mov ax, [bp - 0x8]
        cmp [g_01B8], ax
        jnz short .27
        cmp [g_01BA], ax
        jnz short .27
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [g_01B8]
        jnz short .26
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.25:
        mov [g_01C2], ax
        mov [g_01C0], ax
        jmp near .40
.26:
        mov ax, 0x1
        jmp short .25
        db 0x90
.27:
        cmp [g_01B8], ax
        jnz short .30
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [g_01B8]
        jnz short .28
        mov word [g_01C0], 0x0
        mov word [g_01BA], 0xfffe
        jmp near .39
        db 0x90
.28:
        mov word [g_01C0], 0x1
        mov word [g_01BA], 0xffff
.29:
        mov word [g_01C2], 0x0
        jmp near .40
        db 0x90
.30:
        cmp [g_01BA], ax
        jz short .31
        jmp near .40
.31:
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [g_01BA]
        jnz short .32
        mov word [g_01C2], 0x0
        mov word [g_01B8], 0xfffe
        mov word [g_01C0], 0x1
        jmp short .40
        db 0x90
.32:
        mov word [g_01C2], 0x1
        mov word [g_01B8], 0xffff
        mov word [g_01C0], 0x0
        jmp short .40
.33:
        les bx, [bp - 0x12]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [g_29CA], ax
        mov al, [es:bx + 0x3]
        mov [g_29CC], ax
        cmp word [g_01B8], -0x1
        jnz short .35
.34:
        mov word [g_01C0], 0x0
        jmp short .37
.35:
        cmp word [g_01B8], -0x2
        jz short .36
        mov ax, [g_29CA]
        cmp [g_01B8], ax
        jz short .34
.36:
        mov word [g_01C0], 0x1
.37:
        cmp word [g_01BA], -0x1
        jnz short .38
        jmp near .29
.38:
        cmp word [g_01BA], -0x2
        jz short .39
        mov ax, [g_29CA]
        cmp [g_01BA], ax
        jnz short .39
        jmp near .29
.39:
        mov word [g_01C2], 0x1
.40:
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadScheduleDB                                             26D4:29F2  94 PC
; Loads schedule.db.
;
; Takes 1 word of stack arguments. Calls _fstrcpy, _chdir, LoadRawHeader0. Far routine (retf).
;-----------------------------------------------------------------------------
LoadScheduleDB:
        enter 0xe, 0x0
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_chdir
        add sp, 0x2
        push 0x0
        push strict word str_ScheduleDb_3
        call 0x149D:LoadRawHeader0
        add sp, 0x4
        mov bx, [bp + 0x6]
        mov [bx], ax
        mov [bx + 0x2], dx
        push word 0x12fd
        call 0x0000:_chdir
        leave
        retf

;-----------------------------------------------------------------------------
; SaveScheduleDB                                             26D4:2A34  94 PC
; Writes schedule.db.
;
; Takes 2 words of stack arguments. Calls _fstrcpy, _chdir, FileSizeMsg, WriteFile. Far routine
; (retf).
;-----------------------------------------------------------------------------
SaveScheduleDB:
        enter 0xe, 0x0
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_chdir
        add sp, 0x2
        push strict word str_ScheduleDb_2
        call 0x03A3:FileSizeMsg
        add sp, 0x2
        push dx
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push strict word str_ScheduleDb
        call 0x03A3:WriteFile
        add sp, 0xa
        push word 0x1318
        call 0x0000:_chdir
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayoffModeLoop                                            26D4:2A80  94 PC
; Playoff desk loop.
;
; Takes 1 word of stack arguments. Calls SaveModeState, LoadModeState, SetupStatsMenusThunk,
; VgaCopyBytes, SetStatsMenuTextThunk, _fstrcpy, OpenReadShared, LoadScheduleDB and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
PlayoffModeLoop:
        enter 0x44, 0x0
        push di
        push si
        mov word [bp - 0x22], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        push word 0x3415
        push strict word exhstate
        call 0x2E70:SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word postate
        call 0x2E70:LoadModeState
        add sp, 0x4
        push 0x2
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x1
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .1
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_GameSav_6
        lea si, [bp - 0x20]
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
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov bx, [bp + 0x6]
        mov word [bx], 0xffff
.1:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jnl short .2
        jmp near .7
.2:
        lea ax, [bp - 0x3c]
        push ax
        push cs
        call LoadScheduleDB
        add sp, 0x2
        les bx, [bp - 0x3c]
        mov ax, [es:bx + 0x20]
        add ax, 0x3f0
        mov es, [g_8B54]
        mov [es:0x78c], ax
        push word [bp - 0x3a]
        push bx
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette_7
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x2037:SetSideControls
        call 0x1B35:SetupControllersThunk
        mov word [teamstatscb], 0x250d
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x2503
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24f9
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24ef
        mov word [HomeTeam], 0x1b35
        mov word [g_21D2], 0x232d
        mov word [g_21D4], 0x1b35
        push word [bp + 0x6]
        call 0x1B35:PlayGameThunk
        add sp, 0x2
        mov word [teamstatscb], 0x24db
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x24d1
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24c7
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24bd
        mov word [HomeTeam], 0x1b35
        mov word [g_21D2], 0x219d
        mov word [g_21D4], 0x1b35
        mov word [g_08FC], 0x50
        lea ax, [bp - 0x3c]
        push ax
        push cs
        call LoadScheduleDB
        add sp, 0x2
        mov es, [g_8B56]
        cmp word [es:0x126], 0x1
        jz short .3
        jmp near .5
.3:
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_GameSav_5
        lea si, [bp - 0x20]
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
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
        mov es, [g_8B4A]
        and byte [es:0xb7], 0x7f
        and byte [AnnouncerFlags], 0x7f
.4:
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call POAfterGame
        add sp, 0x4
        mov [bp - 0x22], ax
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call SaveScheduleDB
        add sp, 0x4
.5:
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette_6
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov es, [g_8B58]
        mov ax, [es:0x7572]
        or ax, [es:0x7570]
        jz short .6
        push word [es:0x7572]
        push word [es:0x7570]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov es, [g_8B58]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x7572], ax
        mov [es:0x7570], ax
.6:
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
        call 0x0BFE:InputInit
.7:
        mov ax, [bp - 0x3a]
        or ax, [bp - 0x3c]
        jnz short .8
        lea ax, [bp - 0x3c]
        push ax
        push cs
        call LoadScheduleDB
        add sp, 0x2
.8:
        mov ax, [bp - 0x3c]
        mov dx, [bp - 0x3a]
        add ax, 0x17a0
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        mov word [bp - 0x28], 0x0
        mov es, [bp - 0x2e]
.9:
        mov bx, [bp - 0x30]
        mov al, [es:bx + 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov si, [bp - 0x28]
        shl si, 1
        mov [si + playofftree], ax
        mov al, [es:bx + 0x3]
        mov [si + g_C206], ax
        add word [bp - 0x28], 0x2
        add word [bp - 0x30], 0x2a
        cmp word [bp - 0x28], 0x10
        jl short .9
        mov ax, [bp - 0x3c]
        mov dx, [bp - 0x3a]
        add ax, 0x17a0
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        mov word [bp - 0x28], 0x10
.10:
        mov si, [bp - 0x28]
        shl si, 1
        les bx, [bp - 0x3c]
        push word [es:bx + si + 0x8]
        push word [bp - 0x2e]
        push word [bp - 0x30]
        push cs
        call SeriesWinner
        add sp, 0x6
        mov [si + playofftree], ax
        mov bx, [bp - 0x28]
        shl bx, 1
        cmp word [bx + playofftree], -0x1
        jnz short .11
        mov word [bx + playofftree], 0x18
.11:
        inc word [bp - 0x28]
        add word [bp - 0x30], 0x2a
        cmp word [bp - 0x28], 0x1f
        jl short .10
        mov word [bp - 0x28], 0x0
.12:
        mov bx, [bp - 0x28]
        shl bx, 1
        push ds
        push word [bx + 0x218]
        imul ax, [bp - 0x28], 0x15
        add ax, 0xaa38
        push word 0x3a0b
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        inc word [bp - 0x28]
        cmp word [bp - 0x28], 0x18
        jl short .12
        push ds
        push strict word g_133F
        push word 0x3a0b
        push strict word f_3A0B_AC30
        call 0x0000:_fstrcpy
        add sp, 0x8
        push 0x0
        push strict word str_Teeny05Fnt_3
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [g_21B0], ax
        mov [g_21B2], dx
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embscup_3
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_21B4], ax
        mov [g_21B6], dx
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push word [bp - 0x22]
        push cs
        call POHandleElimination
        add sp, 0x6
        les bx, [bp - 0x3c]
        mov ax, [es:bx + 0x20]
        mov [bp - 0x2a], ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        add bx, 0x17a0
        mov [bp - 0x30], bx
        mov [bp - 0x2e], es
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov cx, 0x7
        cwd
        idiv cx
        mov [g_11D8], dx
        mov ax, [bp - 0x2a]
        cwd
        idiv cx
        mov [bp - 0x2a], ax
        cmp ax, strict word 0xf
        jnl short .13
        mov es, [g_8B52]
        mov word [es:0x18d4], strict word POMenuResult4Thunk
        mov word [es:0x18d6], 0x1b35
        jmp short .14
        db 0x90
.13:
        mov es, [g_8B52]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x18d6], ax
        mov [es:0x18d4], ax
.14:
        cmp word [bp - 0x2a], 0xf
        jl short .15
        jmp near .20
.15:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x40], ax
        mov [bp - 0x3e], ax
        lea ax, [bp - 0x42]
        push ax
        lea ax, [bp - 0x44]
        push ax
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x40]
        push cx
        imul dx, [bp - 0x2a], 0x2a
        add dx, [bp - 0x3c]
        mov bx, [bp - 0x3a]
        add dx, 0x17a0
        push bx
        push dx
        push cs
        call POSeriesScore
        add sp, 0xc
        mov ax, [bp - 0x40]
        cmp [bp - 0x3e], ax
        jnz short .16
        push word [bp - 0x3e]
        push ax
        push strict word str_Tied
        jmp short .19
        db 0x90
.16:
        cmp [bp - 0x3e], ax
        jnl short .17
        push word [bp - 0x3e]
        push ax
        mov bx, [bp - 0x44]
        jmp short .18
.17:
        push ax
        push word [bp - 0x3e]
        mov bx, [bp - 0x42]
.18:
        shl bx, 1
        push word [bx + TeamNameClips]
.19:
        push word [g_11D6]
        push word 0xc1f4
        call 0x0000:_sprintf
        add sp, 0xa
        push ds
        push strict word g_C1F4
        push word 0x3a0b
        push strict word f_3A0B_AC45
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov bx, [bp - 0x2a]
        shl bx, 1
        mov word [bx + g_C224], 0x19
.20:
        push cs
        call DrawPlayoffTree
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word f_3448_19BA
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_20
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_63
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        push 0xc
        add ax, strict word 0x24
        push dx
        push ax
        mov ax, [bp - 0x26]
        add ax, 0x2f1
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        push 0x10
        push word [bp - 0x24]
        push word [bp - 0x26]
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x3c]
        jmp near .29
        db 0x90
.21:
        push word [g_21B2]
        push word [g_21B0]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_21B2], ax
        mov [g_21B0], ax
        push word [g_21B6]
        push word [g_21B4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_21B6], ax
        mov [g_21B4], ax
        push ax
        push ax
        push word 0x300
        push strict word str_Palette_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x1B35:SetupControllersThunk
        push word 0x3415
        push strict word postate
        call 0x2E70:WriteModeState
        add sp, 0x4
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call SaveScheduleDB
        add sp, 0x4
        les bx, [bp - 0x3c]
        mov ax, [es:bx + 0x20]
        add ax, 0x3f0
        mov es, [g_8B54]
        mov [es:0x78c], ax
        call 0x2037:SetSideControls
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_GameSav_4
        lea si, [bp - 0x20]
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
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .22
        mov bx, [bp + 0x6]
        mov word [bx], 0xffff
        les bx, [bp - 0x30]
        mov al, [es:bx + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [es:bx]
        push ax
        call 0x1B35:CreateGSummaryDbThunk
        add sp, 0x4
        push word [g_29CC]
        push word [g_29CA]
        call 0x1B35:ShowMatchupScreenThunk
        add sp, 0x4
        mov [bp - 0x38], ax
        call 0x0BFE:InputShutdown
        jmp short .23
.22:
        mov word [bp - 0x38], 0x0
.23:
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        test byte [bp - 0x38], 0x4
        jz short .24
        jmp near .25
.24:
        mov word [teamstatscb], 0x250d
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x2503
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24f9
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24ef
        mov word [HomeTeam], 0x1b35
        mov word [g_21D2], 0x232d
        mov word [g_21D4], 0x1b35
        push word [bp + 0x6]
        call 0x1B35:PlayGameThunk
        add sp, 0x2
        mov word [teamstatscb], 0x24db
        mov word [skaterstatscb], 0x1b35
        mov word [goaliestatscb], 0x24d1
        mov word [standingscb], 0x1b35
        mov word [standingsmenucb], 0x24c7
        mov word [gameopts], 0x1b35
        mov word [VisTeam], 0x24bd
        mov word [HomeTeam], 0x1b35
        mov word [g_21D2], 0x219d
        mov word [g_21D4], 0x1b35
.25:
        mov word [g_08FC], 0x50
        lea ax, [bp - 0x3c]
        push ax
        push cs
        call LoadScheduleDB
        add sp, 0x2
        mov es, [g_8B56]
        cmp word [es:0x126], 0x1
        jnz short .26
        test byte [bp - 0x38], 0x4
        jnz short .26
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call POAfterGame
        add sp, 0x4
        mov [bp - 0x22], ax
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call SaveScheduleDB
        add sp, 0x4
        jmp short .27
        db 0x90
.26:
        mov word [bp - 0x22], 0x0
.27:
        les bx, [bp - 0x3c]
        mov ax, [es:bx + 0x20]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        add bx, 0x17a0
        mov [bp - 0x30], bx
        mov [bp - 0x2e], es
        push 0x0
        push strict word str_Teeny05Fnt_2
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [g_21B0], ax
        mov [g_21B2], dx
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embscup_2
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_21B4], ax
        mov [g_21B6], dx
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Palette_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov es, [g_8B58]
        mov ax, [es:0x7572]
        or ax, [es:0x7570]
        jz short .28
        push word [es:0x7572]
        push word [es:0x7570]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov es, [g_8B58]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x7572], ax
        mov [es:0x7570], ax
.28:
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
        push cs
        call DrawPlayoffTree
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word f_3448_19BA
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_19
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x10
        push strict word str_Pal_62
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0BFE:InputInit
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push word [bp - 0x22]
        push cs
        call POHandleElimination
        add sp, 0x6
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        push cs
        call SaveScheduleDB
        add sp, 0x4
        les bx, [bp - 0x3c]
        mov ax, [es:bx + 0x20]
        mov cx, 0x7
        cwd
        idiv cx
        mov [g_11D8], dx
        mov ax, [es:bx + 0x20]
        cwd
        idiv cx
        mov [bp - 0x2a], ax
.29:
        push word [es:bx + 0x22]
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word f_3448_19BA
        push cs
        call PlayoffTreeMenu
        add sp, 0xe
        mov [bp - 0x36], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .30
        jmp near .21
.30:
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_21B2]
        push word [g_21B0]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_21B2], ax
        mov [g_21B0], ax
        push word [g_21B6]
        push word [g_21B4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_21B6], ax
        mov [g_21B4], ax
        push ax
        push ax
        push word 0x300
        push strict word str_Palette_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x34], ax
        mov [bp - 0x32], dx
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word [bp - 0x32]
        push word [bp - 0x34]
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x32]
        push word [bp - 0x34]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .31
        call 0x0FEF:CopyPlane
.31:
        call 0x0FEF:UseCurrentPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Easndesk_18
        push 0x0
        push 0x0
        lea ax, [bp - 0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_AE94], ax
        mov [g_AE96], dx
        push strict word str_Desk_15
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push word [g_AE96]
        push word [g_AE94]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x5
        push 0xb
        push 0x11
        push 0x3
        push word 0x3448
        push strict word f_3448_0D44
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x36]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        lea cx, [bp - 0x28]
        push cx
        call 0x03A3:MouseRead
        add sp, 0x6
        push word [bp - 0x2c]
        push word [bp - 0x28]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        push word 0x3415
        push strict word postate
        call 0x2E70:WriteModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        call 0x2E70:LoadModeState
        add sp, 0x4
        mov ax, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PORestoreSlot                                              26D4:35E8  94 PC
; Puts back the block under a tree slot.
;
; Takes 5 words of stack arguments. Calls PutBlockAt. Far routine (retf).
;-----------------------------------------------------------------------------
PORestoreSlot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jg short .1
        cmp [g_2486], dx
        jnl short .3
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x0FEF:PutBlockAt
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        add word [g_2486], 0x8
        cmp word [g_2486], 0x0
        jng short .2
        mov word [g_2486], 0x0
        jmp short .2
        db 0x90
.1:
        cmp bx, 0x13f
        jl short .3
        cmp word [g_2486], 0xff65
        jng short .3
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x0FEF:PutBlockAt
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        sub word [g_2486], 0x8
        cmp word [g_2486], 0xff65
        jnl short .2
        mov word [g_2486], 0xff65
.2:
        mov dx, 0xffff
.3:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; POHiliteSlot                                               26D4:365E  94 PC
; XOR box on a tree slot.
;
; Takes 2 words of stack arguments. Calls XorRect. Far routine (retf).
;-----------------------------------------------------------------------------
POHiliteSlot:
        enter 0x6, 0x0
        push di
        push si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0x4], dx
        mov [bp - 0x2], dx
.1:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x6], dx
        mov di, [bp - 0x2]
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + g_24D0]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0x6]
        jnz short .3
        push word 0x80
        push 0x8
        push 0x32
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + g_2488]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, strict word 0x1f
        push ax
        mov ax, [bp - 0x4]
        add ax, [g_2486]
        add ax, strict word 0x4
        push ax
        call 0x0FEF:XorRect
        add sp, 0xa
.3:
        inc si
        cmp si, 0x8
        jl short .2
        add word [bp - 0x4], 0x34
        mov dx, [bp - 0x6]
        inc dx
        add di, 0x8
        mov [bp - 0x2], di
        cmp di, 0x48
        jl short .1
        cmp word [bp + 0x8], 0x0
        jnl short .4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.4:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov [bp - 0x4], dx
.5:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x6], dx
        mov [bp - 0x2], di
.6:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + g_24D0]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        cmp ax, [bp + 0x8]
        jnz short .7
        push word 0x80
        push 0x8
        push 0x32
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx + g_2488]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, strict word 0x1f
        push ax
        mov ax, [bp - 0x4]
        add ax, [g_2486]
        add ax, strict word 0x4
        push ax
        call 0x0FEF:XorRect
        add sp, 0xa
.7:
        inc si
        cmp si, 0x8
        jl short .6
        add word [bp - 0x4], 0x34
        mov dx, [bp - 0x6]
        inc dx
        add di, 0x8
        cmp di, 0x48
        jl short .5
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayoffTreeMenu                                            26D4:373C  94 PC
; Playoff tree input loop.
;
; Takes 7 words of stack arguments. Calls FindFarMsg, AllocRecData, GetBlockAt, DrawRleTransAt,
; MouseRange, MouseMove, FlushInputEvents, POHiliteSlot and others. Far routine (retf).
;-----------------------------------------------------------------------------
PlayoffTreeMenu:
        enter 0x14a, 0x0
        push di
        push si
        push strict word str_Pnt2_12
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [bp - 0x58], ax
        mov [bp - 0x56], dx
        mov ax, [bp + 0xa]
        mov [bp - 0x46], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x2c], ax
        mov [bp - 0x2e], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x78], ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x3e], cx
        mov [bp - 0x6e], cx
        mov [bp - 0x70], cx
        mov [bp - 0x72], cx
        mov [bp - 0x74], cx
        mov [bp - 0x10], cx
        mov [bp - 0x12], cx
        push cx
        cwd
        push dx
        push ax
        push strict word str_Pointer_12
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x16]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx + 0x2], ax
        les bx, [bp - 0x58]
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x48], ax
        mov [bp - 0x18], ax
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x5c], ax
        mov [bp - 0x1a], ax
        push ax
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x5c]
        push word [bp - 0x48]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x0F99:FlushInputEvents
        mov ax, [bp + 0x12]
        shl ax, 1
        mov [bp - 0x5a], ax
        cmp ax, strict word 0x1e
        jnz short .1
        mov ax, 0xffff
        jmp short .2
.1:
        inc ax
.2:
        mov [bp - 0x5e], ax
        push ax
        push word [bp - 0x5a]
        push cs
        call POHiliteSlot
        add sp, 0x4
.3:
        mov word [bp - 0x76], 0x0
.4:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        lea cx, [bp - 0x1a]
        push cx
        lea cx, [bp - 0x18]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x76], ax
        test al, 0x2
        jz short .4
.5:
        test byte [bp - 0x76], 0x2
        jz short .6
        jmp near .15
.6:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [bp - 0x18]
        push cs
        call PORestoreSlot
        add sp, 0xa
        mov [bp - 0x66], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        jmp near .12
.7:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp word [bp - 0x3e], 0x0
        jz short .11
        mov ax, [bp - 0x3e]
        mov [bp - 0x60], ax
        jmp short .10
.8:
        mov si, [bp - 0x60]
        shl si, byte 0x2
        mov ax, [bp + si - 0x38]
        or ax, [bp + si - 0x3a]
        jz short .9
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x38], ax
        mov [bp + si - 0x3a], ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x58], ax
        mov si, [bp - 0x60]
        shl si, 1
        mov [bp + si - 0x46], ax
.9:
        dec word [bp - 0x60]
.10:
        cmp word [bp - 0x60], 0x0
        jnl short .8
        mov word [bp - 0x3e], 0x0
.11:
        push cs
        call DrawPlayoffTree
        push word [bp - 0x5e]
        push word [bp - 0x5a]
        push cs
        call POHiliteSlot
        add sp, 0x4
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
.12:
        mov ax, [bp - 0x48]
        cmp [bp - 0x18], ax
        jnz short .13
        mov ax, [bp - 0x5c]
        cmp [bp - 0x1a], ax
        jnz short .13
        cmp word [bp - 0x66], 0x0
        jnz short .13
        jmp near .3
.13:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
.14:
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x18]
        mov [bp - 0x48], ax
        mov ax, [bp - 0x1a]
        mov [bp - 0x5c], ax
        jmp near .3
        db 0x90
.15:
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x3c]
        push cx
        lea dx, [bp - 0x12]
        push dx
        lea dx, [bp - 0x46]
        push dx
        push word [bp - 0x3e]
        lea dx, [bp - 0x58]
        push dx
        push word [bp - 0x1a]
        push word [bp - 0x18]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .16
        jmp near .39
.16:
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les si, [bp + si - 0x58]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .17
        jmp near .27
.17:
        mov ax, [bp - 0x62]
        mov si, [bp - 0x3c]
        shl si, 1
        cmp [bp + si - 0x74], ax
        jz short .18
        jmp near .37
.18:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x60], 0x3
.19:
        mov si, [bp - 0x60]
        shl si, byte 0x2
        mov ax, [bp + si - 0x38]
        or ax, [bp + si - 0x3a]
        jz short .20
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.20:
        dec word [bp - 0x60]
        jns short .19
        mov word [bp - 0x3e], 0x0
        push word [bp - 0x5e]
        push word [bp - 0x5a]
        push cs
        call POHiliteSlot
        add sp, 0x4
        mov ax, [g_2486]
        mov [bp - 0x6c], ax
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push strict word str_Pntr_17
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov byte [bp - 0x84], 0x18
        mov byte [bp - 0x81], 0x2a
        mov byte [bp - 0x7d], 0x12
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bp - 0x83], al
        mov [bp - 0x82], al
        mov [bp - 0x80], al
        mov [bp - 0x7f], al
        mov [bp - 0x7c], al
        mov al, 0x3b
        mov [bp - 0x7e], al
        mov [bp - 0x7b], al
        mov [bp - 0x7a], al
        mov [bp - 0x79], al
        lea ax, [bp - 0x84]
        push ss
        push ax
        push 0x4
        push word 0xfb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les si, [bp + si - 0x58]
        call far [es:bx + si + 0xc]
        mov [bp - 0x76], ax
        push strict word str_Pnt2_11
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x84], ax
        push 0x0
        cwd
        push dx
        push ax
        push strict word str_Pointer_11
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x16]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx + 0x2], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        mov [bp - 0x6e], ax
        mov [bp - 0x70], ax
        mov [bp - 0x72], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        cmp word [bp - 0x76], 0x1
        jnz short .21
        push strict word str_Pntr_16
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.21:
        cmp word [bp - 0x76], 0x4
        jnz short .22
        push strict word str_Pntr_15
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.22:
        cmp word [bp - 0x76], 0x2
        jz short .23
        jmp near .24
.23:
        push ax
        push strict word str_Teeny05Fnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [g_21B0], ax
        mov [g_21B2], dx
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embscup
        push 0x0
        push 0x0
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x2a]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_21B4], ax
        mov [g_21B6], dx
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_18
        push 0x0
        push 0x0
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_61
        push 0x0
        lea ax, [bp - 0x2a]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x6a], ax
        mov [bp - 0x68], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x84], ax
        mov [bp - 0x82], dx
        push 0xc
        add ax, strict word 0x24
        push dx
        push ax
        mov ax, [bp - 0x84]
        add ax, 0x2f1
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        push 0x10
        push word [bp - 0x82]
        push word [bp - 0x84]
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [bp - 0x68]
        push word [bp - 0x6a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.24:
        mov word [bp - 0x84], 0x0
.25:
        mov al, [bp - 0x84]
        mov si, [bp - 0x84]
        db 0x8B, 0xCE                           ; insn: mov cx, si
        shl si, 1
        db 0x03, 0xF1                           ; insn: add si, cx
        mov [bp + si - 0x143], al
        mov [bp + si - 0x144], al
        mov byte [bp + si - 0x142], 0x0
        inc word [bp - 0x84]
        cmp word [bp - 0x84], 0x40
        jl short .25
        lea ax, [bp - 0x144]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:UseCurrentPage
        mov ax, [g_2486]
        cmp [bp - 0x6c], ax
        jz short .26
        mov ax, [bp - 0x6c]
        mov [g_2486], ax
        push cs
        call DrawPlayoffTree
.26:
        push word [bp - 0x5e]
        push word [bp - 0x5a]
        push cs
        call POHiliteSlot
        add sp, 0x4
        push word [bp - 0x5c]
        push word [bp - 0x48]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0x48]
        mov [bp - 0x18], ax
        mov ax, [bp - 0x5c]
        mov [bp - 0x1a], ax
        call 0x0F99:FlushInputEvents
        jmp near .43
.27:
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les si, [bp + si - 0x58]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .28
        jmp near .37
.28:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x3e]
        cmp [bp - 0x3c], ax
        jz short .32
        mov [bp - 0x60], ax
        jmp short .31
        db 0x90
.29:
        mov si, [bp - 0x60]
        shl si, 1
        mov word [bp + si - 0x74], 0x0
        mov di, [bp - 0x60]
        shl di, byte 0x2
        mov ax, [bp + di - 0x38]
        or ax, [bp + di - 0x3a]
        jz short .30
        push word [bp + di - 0x10]
        push word [bp + di - 0x12]
        push word [bp + di - 0x38]
        push word [bp + di - 0x3a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x10], ax
        mov [bp + di - 0x12], ax
        push word [bp + di - 0x38]
        push word [bp + di - 0x3a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x38], ax
        mov [bp + di - 0x3a], ax
        mov [bp + di - 0x56], ax
        mov [bp + di - 0x58], ax
        mov [bp + si - 0x46], ax
.30:
        dec word [bp - 0x60]
.31:
        mov ax, [bp - 0x3c]
        cmp [bp - 0x60], ax
        jg short .29
        mov [bp - 0x3e], ax
.32:
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        imul ax, [bp + di - 0x74], 0x16
        add ax, [bp + si - 0x58]
        mov dx, [bp + si - 0x56]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x62]
        mov [bp + di - 0x74], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x58]
        mov dx, [bp + si - 0x56]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les di, [bp + si - 0x58]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x3e]
        mov di, [bp - 0x3e]
        shl di, byte 0x2
        mov [bp + di - 0x58], ax
        mov [bp + di - 0x56], dx
        les si, [bp + si - 0x58]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov di, [bp - 0x3e]
        shl di, 1
        mov [bp + di - 0x46], ax
        mov [bp - 0x14a], si
        mov [bp - 0x148], es
        cmp word [bp - 0x3e], 0x1
        jz short .33
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [es:bx + 0x4]
        jmp short .34
.33:
        imul si, [bp - 0x62], 0x16
        mov di, [bp - 0x3c]
        shl di, byte 0x2
        les bx, [bp + di - 0x58]
        mov ax, [es:bx + si]
.34:
        mov [bp - 0x144], ax
        mov si, [bp - 0x3e]
        shl si, byte 0x2
        mov ax, [bp + si - 0x16]
        add ax, [bp - 0x144]
        mov [bp + si - 0x12], ax
        cmp word [bp - 0x3e], 0x1
        jz short .35
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les si, [bp + si - 0x58]
        mov ax, [es:bx + si + 0x2]
        jmp short .36
        db 0x90
.35:
        imul bx, [bp - 0x62], 0x16
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        les si, [bp + si - 0x58]
        mov ax, [es:bx + si + 0x6]
.36:
        mov [bp - 0x84], ax
        mov si, [bp - 0x3e]
        shl si, byte 0x2
        mov ax, [bp + si - 0x14]
        add ax, [bp - 0x84]
        mov [bp + si - 0x10], ax
        les bx, [bp + si - 0x58]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov di, [bp - 0x3e]
        shl di, 1
        imul di, [bp + di - 0x46], 0x16
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
        mov [bp - 0x78], ax
        mov cx, [es:di - 0x10]
        sub cx, [es:bx + 0x2]
        inc cx
        mov [bp - 0x146], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_9
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x3a], ax
        mov [bp + si - 0x38], dx
        lea ax, [bp + si - 0x3a]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x78]
        mov [es:bx], cx
        mov cx, [bp - 0x146]
        mov [es:bx + 0x2], cx
        mov si, [bp - 0x3e]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x3e]
        shl di, 1
        push word [bp + di - 0x46]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x74], 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x56]
        push word [bp + si - 0x58]
        jmp short .38
        db 0x90
.37:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x3c]
        shl di, 1
        imul ax, [bp + di - 0x74], 0x16
        add ax, [bp + si - 0x58]
        mov dx, [bp + si - 0x56]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x3c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x62]
        mov di, [bp - 0x3c]
        shl di, 1
        mov [bp + di - 0x74], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x58]
        mov dx, [bp + si - 0x56]
        push dx
        push ax
.38:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp short .43
        db 0x90
.39:
        push word [bp - 0x5c]
        push word [bp - 0x48]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp word [bp - 0x3e], 0x0
        jz short .43
        mov ax, [bp - 0x3e]
        mov [bp - 0x60], ax
        jmp short .42
.40:
        mov si, [bp - 0x60]
        shl si, byte 0x2
        mov ax, [bp + si - 0x38]
        or ax, [bp + si - 0x3a]
        jz short .41
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x38], ax
        mov [bp + si - 0x3a], ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x58], ax
        mov si, [bp - 0x60]
        shl si, 1
        mov [bp + si - 0x46], ax
.41:
        dec word [bp - 0x60]
.42:
        cmp word [bp - 0x60], 0x0
        jnl short .40
        mov word [bp - 0x3e], 0x0
.43:
        call 0x0FEF:UseCurrentPage
        jmp near .14

;-----------------------------------------------------------------------------
; DrawPlayoffTree                                            26D4:4146  94 PC
; 'Playoff standings'
;
; Calls VgaCopyBytes, UseOtherPage, SetClipRectRegs, FindFarMsg, DrawRleTransBody, SaveCharTab,
; UseCharSeg, SetTextColors and others.
;-----------------------------------------------------------------------------
DrawPlayoffTree:
        enter 0x4c, 0x0
        push di
        push si
        push word 0xd00
        mov es, [g_8B58]
        cmp word [CurPage], 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        neg bx
        shl bx, byte 0x2
        les bx, [es:bx + 0x7570]
        push word [es:bx]
        mov bx, [CurPage]
        shl bx, byte 0x2
        mov es, [g_8B58]
        les bx, [es:bx + 0x7570]
        push word [es:bx]
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:UseOtherPage
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        mov bx, 0xa
        call 0x0FEF:SetClipRectRegs
        push strict word str_Bkgd
        push word [g_21B6]
        push word [g_21B4]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        lea ax, [bp - 0x2a]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [g_21B2]
        push word [g_21B0]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x43
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        push ds
        push strict word str_PlayoffStandings
        push 0xf
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push 0x43
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        push ds
        push strict word str_CampbellConference_3
        push 0x19
        mov ax, [g_2486]
        add ax, strict word 0x50
        push ax
        call 0x0D39:DrawShadowTextBuffered
        add sp, 0x8
        push ds
        push strict word str_WalesConference_3
        push 0x19
        mov ax, [g_2486]
        add ax, 0x13b
        push ax
        call 0x0D39:DrawShadowTextBuffered
        add sp, 0x8
        mov word [bp - 0xc], 0x0
.1:
        cmp word [bp - 0xc], 0x0
        jnz short .2
        mov bx, 0x43
        mov dx, 0x1
        jmp short .3
.2:
        mov bx, 0x40
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.3:
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0xa], cx
        mov [bp - 0x8], cx
        mov [bp - 0x10], dx
        mov [bp - 0x12], bx
        db 0x8B, 0xF1                           ; insn: mov si, cx
.4:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0xe], cx
        mov [bp - 0x8], si
.5:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bp - 0x4c], bx
        cmp byte [bx + g_2488], 0xff
        jnz short .6
        jmp near .11
.6:
        mov al, [bx + g_2488]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, strict word 0x28
        mov [bp - 0x2], ax
        mov cx, [bp - 0xa]
        add cx, [g_2486]
        inc cx
        inc cx
        mov [bp - 0x4], cx
        add cx, 0x34
        mov [bp - 0x6], ax
        cmp si, 0x20
        jz short .7
        push word [bp - 0x12]
        mov ax, [bp - 0x10]
        add ax, [bp - 0x6]
        push ax
        add cx, [bp - 0x10]
        push cx
        mov ax, [bp - 0x10]
        add ax, [bp - 0x2]
        push ax
        mov ax, [bp - 0x10]
        add ax, [bp - 0x4]
        push ax
        call 0x0FEF:DrawLine
        add sp, 0xa
.7:
        cmp word [bp - 0xc], 0x0
        jnz short .8
        mov bx, [bp - 0x4c]
        mov bl, [bx + g_24D0]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        imul ax, [bx + playofftree], 0x15
        add ax, 0xaa38
        push word 0x3a0b
        push ax
        lea ax, [bp - 0x4a]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x4a]
        push ss
        push ax
        mov ax, [bp - 0x2]
        sub ax, strict word 0x8
        push ax
        mov ax, [bp - 0x4]
        add ax, strict word 0x3
        push ax
        call 0x0D39:DrawShadowTextBuffered
        add sp, 0x8
.8:
        test di, 0x1
        jnz short .9
        jmp near .11
.9:
        cmp si, 0x18
        jnl short .10
        push word [bp - 0x12]
        mov bx, [bp - 0x4c]
        mov al, [bx + g_2487]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, [bp - 0x10]
        add ax, strict word 0x28
        push ax
        mov ax, [bp - 0x10]
        add ax, [bp - 0xa]
        add ax, [g_2486]
        add ax, strict word 0x36
        push ax
        mov cl, [bx + g_2488]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, byte 0x3
        db 0x03, 0xCA                           ; insn: add cx, dx
        add cx, [bp - 0x10]
        add cx, 0x28
        push cx
        push ax
        call 0x0FEF:DrawLine
        add sp, 0xa
.10:
        cmp si, 0x28
        jng short .11
        push word [bp - 0x12]
        mov bx, [bp - 0x4c]
        mov al, [bx + g_2487]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, [bp - 0x10]
        add ax, strict word 0x28
        push ax
        mov ax, [bp - 0x10]
        add ax, [bp - 0xa]
        add ax, [g_2486]
        inc ax
        inc ax
        push ax
        mov cl, [bx + g_2488]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, byte 0x3
        db 0x03, 0xCA                           ; insn: add cx, dx
        add cx, [bp - 0x10]
        add cx, 0x28
        push cx
        push ax
        call 0x0FEF:DrawLine
        add sp, 0xa
.11:
        inc di
        cmp di, 0x8
        jnl short .12
        jmp near .5
.12:
        add word [bp - 0xa], 0x34
        mov cx, [bp - 0xe]
        inc cx
        add si, 0x8
        cmp si, 0x48
        jnl short .13
        jmp near .4
.13:
        inc word [bp - 0xc]
        cmp word [bp - 0xc], 0x2
        jnl short .14
        jmp near .1
.14:
        call 0x0FEF:CopyPlane
        lea ax, [bp - 0x2a]
        push ax
