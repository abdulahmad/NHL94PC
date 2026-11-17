; League settings dialog and its edit loop (MENUS.OVL)

;-----------------------------------------------------------------------------
; LeagueSettingsDlg                                          2B26:0000  94 PC
; League settings dialog.
;
; Calls VgaCopyBytes, DrawLeagueSetDlg, DrawLeagueSetChecks, CopyPlane, LeagueSetEditLoop. Far routine
; (retf).
;-----------------------------------------------------------------------------
LeagueSettingsDlg:
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x0
        push cs
        call DrawLeagueSetDlg
        add sp, 0x2
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push cs
        call LeagueSetEditLoop
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuLeagueSettingsEdit                                     2B26:0052  94 PC
; League settings, editable.
;
; Calls VgaCopyBytes, GetPage, CopyPlane, DrawLeagueSetDlg, DrawLeagueSetChecks, LeagueSetEditLoop,
; UseCurrentPage. Far routine (retf).
;-----------------------------------------------------------------------------
MenuLeagueSettingsEdit:
        push word 0x3f00
        push word 0xbd00
        mov es, [segDgroup4]
        mov bx, [CurPage]
        shl bx, byte 0x2
        les bx, [es:bx + PageTable]
        push word [es:bx]
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        mov es, [segDgroup4]
        cmp word [CurPage], 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        neg bx
        shl bx, byte 0x2
        les bx, [es:bx + PageTable]
        push word [es:bx]
        mov bx, [CurPage]
        shl bx, byte 0x2
        mov es, [segDgroup4]
        les bx, [es:bx + PageTable]
        push word [es:bx]
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        call 0x0FEF:CopyPlane
.1:
        push 0x1
        push cs
        call DrawLeagueSetDlg
        add sp, 0x2
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push cs
        call LeagueSetEditLoop
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:UseCurrentPage
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; EditPlayoffSettings                                        2B26:0112  94 PC
; Playoff settings, writes game.set.
;
; Calls SaveModeState, LoadModeState, VgaCopyBytes, DrawLeagueSetDlg, DrawLeagueSetChecks, CopyPlane,
; LeagueSetEditLoop, WriteModeState. Far routine (retf).
;-----------------------------------------------------------------------------
EditPlayoffSettings:
        push word 0x3415
        push strict word exhstate
        call 0x2E70:SaveModeState
        add sp, 0x4
        push word 0x3415
        push strict word postate
        call 0x2E70:LoadModeState
        add sp, 0x4
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x0
        push cs
        call DrawLeagueSetDlg
        add sp, 0x2
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push cs
        call LeagueSetEditLoop
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3415
        push strict word postate
        call 0x2E70:WriteModeState
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
        call 0x2E70:LoadModeState
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuShowLeagueSettings                                     2B26:019C  94 PC
; League settings, view.
;
; Calls GetPaletteFar, VgaCopyBytes, DrawLeagueSetChecks, CopyPlane, LeagueSetEditLoop,
; WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
MenuShowLeagueSettings:
        enter 0xc0, 0x0
        push si
        mov si, [CurPage]
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .1
        push word 0x3f00
        push word 0x3f00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push 0x0
        push word 0x7e00
        jmp short .2
.1:
        push word 0x3f00
        push word 0x7e00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push 0x0
        push word 0x3f00
.2:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        jmp short .4
.3:
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
.4:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        call 0x0FEF:CopyPlane
.5:
        push cs
        call LeagueSetEditLoop
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .6
        push word 0x3f00
        push 0x0
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        jmp short .7
        db 0x90
.6:
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push 0x0
        push word 0x7e00
.7:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; MenuShowLeagueSettings2                                    2B26:02B0  94 PC
; Same, view loop.
;
; Calls GetPaletteFar, VgaCopyBytes, DrawLeagueSetChecks, CopyPlane, LeagueSetViewLoop,
; WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
MenuShowLeagueSettings2:
        enter 0xc0, 0x0
        push si
        mov si, [CurPage]
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .1
        push word 0x3f00
        push word 0x3f00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push 0x0
        push word 0x7e00
        jmp short .2
.1:
        push word 0x3f00
        push word 0x7e00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push 0x0
        push word 0x3f00
.2:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        jmp short .4
.3:
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
.4:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        call 0x0FEF:CopyPlane
.5:
        push cs
        call LeagueSetViewLoop
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .6
        push word 0x3f00
        push 0x0
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        jmp short .7
        db 0x90
.6:
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0xc0]
        push ss
        push ax
        push 0x40
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push 0x0
        push word 0x7e00
.7:
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; DrawLeagueSetDlgSel                                        2B26:03C4  94 PC
; 'setting5' dbox.
;
; Calls GetPage, VgaCopyBytes, CopyPlane, SetRemapTable, UseOtherPage, BuildPathFar, LoadPackedHeader,
; FindFarMsg and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLeagueSetDlgSel:
        enter 0x10e, 0x0
        push di
        push si
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        jmp short .2
.1:
        push word 0x3f00
        push word 0xbd00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push word 0x7e00
        push word 0x3f00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
.2:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.3:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x10e], bl
        inc bx
        cmp bx, 0x100
        jl short .3
        cmp word [SoundOptions], 0x10
        jnz short .4
        mov al, 0x7b
        jmp short .5
.4:
        mov al, 0x7d
.5:
        mov [bp - 0x69], al
        cmp word [SoundOptions], 0x2
        jnz short .6
        mov al, 0x7d
        jmp short .7
.6:
        mov al, 0x7b
.7:
        mov [bp - 0x6a], al
        mov byte [bp - 0xfd], 0x7d
        mov byte [bp - 0x103], 0x7c
        mov byte [bp - 0x109], 0x7b
        lea ax, [bp - 0x10e]
        push ss
        push ax
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Setting5_2
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        push 0xa
        push strict word str_Dbox_7
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
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x7d
        push word [DbSaveMode]
        push 0x5
        push 0x0
        push 0xa
        call 0x2B11:DrawSettingsHeading
        add sp, 0xa
        push cs
        call DrawLeagueSetChecks
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push cs
        call LeagueSetViewLoop
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        call 0x0FEF:UseCurrentPage
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetLeagueSetImage                                          2B26:0530  94 PC
; Embnhl / setting5 / setting3 images.
;
; Takes 1 word of stack arguments. Calls SetRemapTable, UseOffscreenCanvas, BuildPathFar,
; LoadPackedHeader, FindFarMsg, DrawRleBody, FindUnlink, DrawRleTransRemapAt and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
SetLeagueSetImage:
        enter 0x11a, 0x0
        push di
        push si
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x10e], bl
        inc bx
        cmp bx, 0x100
        jl short .1
        mov si, [bp + 0x6]
        cmp word [SoundOptions], 0x10
        jnz short .2
        mov al, 0x57
        jmp short .3
        db 0x90
.2:
        mov al, 0x7f
.3:
        mov [bp - 0x69], al
        cmp word [SoundOptions], 0x2
        jnz short .4
        mov al, 0x7f
        jmp short .5
.4:
        mov al, 0x57
.5:
        mov [bp - 0x6a], al
        mov byte [bp - 0x109], 0x57
        mov byte [bp - 0x103], 0x6a
        mov byte [bp - 0xfd], 0x7f
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        mov al, 0x7f
        mov [bp - 0x65], al
        mov [bp - 0x66], al
        mov [bp - 0x67], al
        mov [bp - 0x68], al
.6:
        lea ax, [bp - 0x10e]
        push ss
        push ax
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x112], ax
        mov [bp - 0x110], cx
        push cx
        push ax
        push ds
        push strict word str_Embnhl_4
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Bkgd_6
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x116], di
        mov [bp - 0x114], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        push word [bp - 0x114]
        push word [bp - 0x116]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .7
        push word [bp - 0x110]
        push word [bp - 0x112]
        push ds
        push strict word str_Setting5
        jmp short .8
        db 0x90
.7:
        push word [bp - 0x110]
        push word [bp - 0x112]
        push ds
        push strict word str_Setting3_2
.8:
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        push 0xa
        push strict word str_Dbox_6
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x11a], di
        mov [bp - 0x118], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        push word [bp - 0x118]
        push word [bp - 0x11a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x7f
        push word [DbSaveMode]
        cmp si, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xfe
        add ax, strict word 0x5
        push ax
        push 0x0
        push 0xa
        call 0x2B11:DrawSettingsHeading
        add sp, 0xa
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawLeagueSetDlg                                           2B26:0696  94 PC
; 'setting3' dbox.
;
; Takes 1 word of stack arguments. Calls SetRemapTable, UseOtherPage, BuildPathFar, LoadPackedHeader,
; FindFarMsg, DrawRleTransRemapAt, FindUnlink, DrawSettingsHeading. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLeagueSetDlg:
        enter 0x112, 0x0
        push di
        push si
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x10e], bl
        inc bx
        cmp bx, 0x100
        jl short .1
        mov si, [bp + 0x6]
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .2
        mov dx, 0x7b
        mov cx, 0x7d
        mov byte [bp - 0xfd], 0x7d
        mov byte [bp - 0x103], 0x7c
        mov byte [bp - 0x109], 0x7b
        jmp short .3
        db 0x90
.2:
        mov dx, 0x5
        mov cx, 0x11
.3:
        cmp word [SoundOptions], 0x10
        jnz short .4
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        jmp short .5
        db 0x90
.4:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
.5:
        mov [bp - 0x69], al
        cmp word [SoundOptions], 0x2
        jnz short .6
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        jmp short .7
.6:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
.7:
        mov [bp - 0x6a], al
        mov [bp - 0x65], cl
        mov [bp - 0x66], cl
        mov [bp - 0x67], cl
        mov [bp - 0x68], cl
        cmp word [DbSaveMode], 0x1
        jnz short .10
        cmp word [LeagueSetChoice], 0x1
        jl short .8
        mov [bp - 0x68], dl
.8:
        cmp word [LeagueSetChoice], 0x3
        jl short .9
        mov [bp - 0x67], dl
.9:
        cmp word [LeagueSetChoice], 0x5
        jl short .10
        mov [bp - 0x66], dl
.10:
        lea ax, [bp - 0x10e]
        push ss
        push ax
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Setting3
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        push 0xa
        push strict word str_Dbox_2
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        push dx
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x112], di
        mov [bp - 0x110], dx
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        push word [bp - 0x110]
        push word [bp - 0x112]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp si, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x94
        add ax, strict word 0x7d
        push ax
        push word [DbSaveMode]
        push 0x3
        push 0x0
        push 0xa
        call 0x2B11:DrawSettingsHeading
        add sp, 0xa
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawLeagueSetChecks                                        2B26:07B4  94 PC
; All check boxes.
;
; Calls DrawLeagueSetCheck, GetPaletteFar, WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLeagueSetChecks:
        enter 0x10, 0x0
        push di
        push si
        mov al, [SoundOptions]
        and al, 0x10
        jz short .1
        db 0x2B, 0xFF                           ; insn: sub di, di
        jmp short .2
        db 0x90
.1:
        mov di, [CrowdState]
        and di, 0x40
.2:
        mov al, [SoundOptions]
        and al, 0x10
        jz short .3
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .4
.3:
        mov si, [CrowdState]
        and si, 0x80
.4:
        test byte [SoundOptions], 0x2
        jz short .5
        mov dh, [AnnouncerFlags]
        and dx, 0x100
        jmp short .6
        db 0x90
.5:
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.6:
        mov al, [CrowdState]
        and ax, strict word 0x20
        shr al, byte 0x5
        shl ax, 1
        mov cl, [CrowdState]
        and cx, 0x10
        shr cl, byte 0x4
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [CrowdState]
        and cx, 0x8
        shr cl, byte 0x3
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [CrowdState]
        and cx, 0x4
        shr cl, byte 0x2
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [CrowdState]
        and cx, 0x2
        shr cl, 1
        db 0x0B, 0xC1                           ; insn: or ax, cx
        shl ax, 1
        mov cl, [CrowdState]
        and cx, 0x1
        db 0x0B, 0xC1                           ; insn: or ax, cx
        db 0x0B, 0xC7                           ; insn: or ax, di
        db 0x0B, 0xC6                           ; insn: or ax, si
        db 0x0B, 0xC2                           ; insn: or ax, dx
        mov [editopts], ax
        mov al, [AnnouncerFlags]
        and ax, strict word 0xc
        shr al, byte 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        dec ax
        jz short .8
        dec ax
        jz short .9
        jmp short .10
        db 0x90
.7:
        or byte [editopts_b1], 0x8
        jmp short .10
        db 0x90
.8:
        or byte [editopts_b1], 0x4
        jmp short .10
        db 0x90
.9:
        or byte [editopts_b1], 0x2
.10:
        mov al, [AnnouncerFlags]
        and ax, strict word 0x70
        shr al, byte 0x4
        dec ax
        jz short .11
        dec ax
        dec ax
        jz short .12
        dec ax
        dec ax
        jz short .13
        dec ax
        dec ax
        jz short .14
        jmp short .15
        db 0x90
.11:
        or byte [editopts_b1], 0x10
        jmp short .15
        db 0x90
.12:
        or byte [editopts_b1], 0x20
        jmp short .15
        db 0x90
.13:
        or byte [editopts_b1], 0x40
        jmp short .15
        db 0x90
.14:
        or byte [editopts_b1], 0x80
.15:
        push cs
        call DrawLeagueSetCheck
        lea ax, [bp - 0x10]
        push ss
        push ax
        push 0x5
        push word 0xa0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        mov al, 0x3f
        mov [bp - 0xb], al
        mov [bp - 0xc], al
        mov [bp - 0xd], al
        mov [bp - 0xe], al
        mov [bp - 0xf], al
        mov [bp - 0x10], al
        mov al, 0x17
        mov [bp - 0x5], al
        mov [bp - 0x6], al
        mov [bp - 0x7], al
        mov [bp - 0x8], al
        mov [bp - 0x9], al
        mov [bp - 0xa], al
        test byte [SoundOptions], 0x2
        jz short .16
        mov al, 0x3f
        jmp short .17
.16:
        mov al, 0x17
.17:
        mov [bp - 0x2], al
        mov [bp - 0x3], al
        mov [bp - 0x4], al
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x10]
        push ss
        push ax
        push 0x5
        push word 0xa0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LeagueOptsToBits                                           2B26:091A  94 PC
; Option index to its flag bits.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
LeagueOptsToBits:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov di, [bp + 0x6]
        sub di, 0xa
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov bx, 0x0
        mov [bp + 0x6], di
        mov ax, 0x36d1
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
        cmp bx, 0xd8
        jc short .1
.3:
        mov ax, DGROUP
        mov ds, ax
        cmp cx, 0x1b
        jnz short .5
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop di
        leave
        retf
.5:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, strict word 0xa
        cmp ax, strict word 0xd
        ja short LeagueOptsToBitsJumpTable.8
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x972]
LeagueOptsToBitsJumpTable:                      ; jump table of LeagueOptsToBits: 14 case targets
        dw LeagueOptsToBits.4
        dw LeagueOptsToBits.4
        dw .1
        dw .1
        dw .1
        dw .1
        dw .3
        dw .3
        dw .8
        dw .8
        dw .8
        dw .4
        dw .6
        dw .7
.1:
        cmp word [SoundOptions], 0x10
.2:
        jnz short .8
        jmp short LeagueOptsToBits.4
        db 0x90
.3:
        test byte [SoundOptions], 0x2
        jmp short .2
        db 0x90
.4:
        cmp word [DbSaveMode], 0x1
        jnz short .8
        cmp word [LeagueSetChoice], 0x1
.5:
        jl short .8
        jmp short LeagueOptsToBits.4
.6:
        cmp word [DbSaveMode], 0x1
        jnz short .8
        cmp word [LeagueSetChoice], 0x3
        jmp short .5
.7:
        cmp word [DbSaveMode], 0x1
        jnz short .8
        cmp word [LeagueSetChoice], 0x5
        jmp short .5
.8:
        mov bx, [bp + 0xa]
        mov [bx], cx
        mov ax, 0x1
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawLeagueSetCheck                                         2B26:09D8  94 PC
; One check box.
;
; Calls GetPaletteFar, WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
DrawLeagueSetCheck:
        enter 0x6c, 0x0
        push di
        push si
        lea ax, [bp - 0x6c]
        push ss
        push ax
        push 0x24
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        db 0x2B, 0xFF                           ; insn: sub di, di
        lea si, [bp - 0x6a]
.1:
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov ax, 0x1
        shl ax, cl
        test [editopts], ax
        jz short .2
        mov al, 0x17
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x3f
        jmp short .3
.2:
        mov al, 0x3f
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x17
.3:
        mov [si + 0x18], al
        mov [si + 0x17], al
        mov [si + 0x16], al
        inc di
        add si, 0x3
        lea ax, [bp - 0x52]
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        jc short .1
        test byte [editopts_b1], 0x1
        jz short .4
        mov al, 0x17
        mov [bp - 0x25], al
        mov [bp - 0x26], al
        mov [bp - 0x27], al
        mov al, 0x3f
        jmp short .5
.4:
        mov al, 0x3f
        mov [bp - 0x25], al
        mov [bp - 0x26], al
        mov [bp - 0x27], al
        mov al, 0x17
.5:
        mov [bp - 0xd], al
        mov [bp - 0xe], al
        mov [bp - 0xf], al
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        lea si, [bp - 0x3a]
.6:
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov ax, 0x200
        shl ax, cl
        test [editopts], ax
        jz short .7
        mov al, 0x17
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x3f
        jmp short .8
.7:
        mov al, 0x3f
        mov [si], al
        mov [si - 0x1], al
        mov [si - 0x2], al
        mov al, 0x17
.8:
        mov [si + 0x18], al
        mov [si + 0x17], al
        mov [si + 0x16], al
        inc dx
        add si, 0x3
        lea ax, [bp - 0x25]
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        jc short .6
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x6c]
        push ss
        push ax
        push 0x24
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LeagueSetViewLoop                                          2B26:0AB8  94 PC
; View-only loop.
;
; Calls MouseRead, UseCurrentPage, DrawRleTransAt, FlushInputEvents, GetInputEvent, VgaCopyRect. Far
; routine (retf).
;-----------------------------------------------------------------------------
LeagueSetViewLoop:
        enter 0xa, 0x0
        push si
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0xa]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x4]
        mov [bp - 0x6], ax
        mov ax, [bp - 0x2]
        mov [bp - 0x8], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x8]
        mov ax, [bp - 0x6]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
.1:
        mov word [bp - 0xa], 0x0
.2:
        call 0x0F99:GetInputEvent
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push si
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0xa], ax
        test byte [bp - 0xa], 0x6
        jz short .2
.3:
        cmp word [bp - 0xa], 0x0
        jz short .4
        jmp near .9
.4:
        mov ax, [bp - 0x4]
        cmp [bp - 0x6], ax
        jnz short .5
        mov ax, [bp - 0x2]
        cmp [bp - 0x8], ax
        jz short .1
.5:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0x2], 0xc8
        jnl short .8
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x2]
        cmp ax, 0xc8
        jl short .6
        mov ax, 0xc8
        sub ax, [bp - 0x2]
        push ax
        jmp short .7
.6:
        push word [es:bx + 0x2]
.7:
        mov ax, [es:bx]
        inc ax
        push ax
        push word [bp - 0x2]
        mov ax, [bp - 0x4]
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
.8:
        push word [bp - 0x8]
        mov ax, [bp - 0x6]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x6]
        mov [bp - 0x4], ax
        mov ax, [bp - 0x8]
        mov [bp - 0x2], ax
        jmp near .1
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LeagueSetEditLoop                                          2B26:0BC4  94 PC
; Edit loop of the league settings screen.
;
; Calls MouseRead, UseCurrentPage, DrawRleTransAt, FlushInputEvents, GetInputEvent, VgaCopyRect,
; LeagueOptsToBits, DrawLeagueSetCheck and others. Far routine (retf).
;-----------------------------------------------------------------------------
LeagueSetEditLoop:
        enter 0x14, 0x0
        lea ax, [bp - 0xe]
        push ax
        lea cx, [bp - 0x8]
        push cx
        lea dx, [bp - 0x14]
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
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
.1:
        mov word [bp - 0x14], 0x0
.2:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        lea cx, [bp - 0x6]
        push cx
        lea cx, [bp - 0x4]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x14], ax
        test byte [bp - 0x14], 0x6
        jz short .2
.3:
        test byte [bp - 0x14], 0x6
        jnz short .8
        mov ax, [bp - 0x8]
        cmp [bp - 0x4], ax
        jnz short .4
        mov ax, [bp - 0xe]
        cmp [bp - 0x6], ax
        jz short .1
.4:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0xe], 0xc8
        jl short .5
        jmp near .15
.5:
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0xe]
        cmp ax, 0xc8
        jl short .6
        mov ax, 0xc8
        sub ax, [bp - 0xe]
        push ax
        jmp short .7
.6:
        push word [es:bx + 0x2]
.7:
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
        jmp near .15
.8:
        test byte [bp - 0x14], 0x2
        jnz short .9
        jmp near .40
.9:
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
        lea ax, [bp - 0xa]
        push ax
        push word [bp - 0x6]
        push word [bp - 0x4]
        push cs
        call LeagueOptsToBits
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        cmp word [bp - 0xa], 0x12
        jnl short .17
        mov ax, [bp - 0xa]
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .16
        mov ax, [bp - 0xa]
        cwd
        idiv cx
        mov [bp - 0xa], ax
        db 0x8A, 0xC8                           ; insn: mov cl, al
        mov ax, 0x1
        shl ax, cl
        not ax
        and [editopts], ax
.13:
        push cs
        call DrawLeagueSetCheck
.14:
        call 0x0FEF:UseCurrentPage
.15:
        push word [bp - 0x6]
        mov ax, [bp - 0x4]
        sub ax, strict word 0x4
        push ax
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x4]
        mov [bp - 0x8], ax
        mov ax, [bp - 0x6]
        mov [bp - 0xe], ax
        jmp near .1
        db 0x90
.16:
        mov ax, [bp - 0xa]
        cwd
        idiv cx
        mov [bp - 0xa], ax
        db 0x8A, 0xC8                           ; insn: mov cl, al
        mov ax, 0x1
        shl ax, cl
        or [editopts], ax
        jmp short .13
.17:
        cmp word [bp - 0xa], 0x15
        jnl short .19
        sub word [bp - 0xa], 0x9
        mov cl, [bp - 0xa]
        mov ax, 0x1
        shl ax, cl
        mov cx, [editopts]
        and ch, 0xf1
.18:
        db 0x0B, 0xC1                           ; insn: or ax, cx
        mov [editopts], ax
        jmp short .13
.19:
        cmp word [bp - 0xa], 0x19
        jnl short .20
        sub word [bp - 0xa], 0x9
        mov cl, [bp - 0xa]
        mov ax, 0x1
        shl ax, cl
        mov cx, [editopts]
        and ch, 0xf
        jmp short .18
        db 0x90
.20:
        cmp word [bp - 0xa], 0x19
        jz short .21
        jmp near .39
.21:
        mov al, [editopts]
        and ax, strict word 0x1
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        xor al, [CrowdState]
        and ax, strict word 0x1
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x2
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, 1
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x2
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x4
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, byte 0x2
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x4
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x8
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, byte 0x3
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x8
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x10
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, byte 0x4
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x10
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x20
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, byte 0x5
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, strict word 0x20
        xor [CrowdState], ax
        cmp word [SoundOptions], 0x10
        jz short .22
        mov al, [editopts]
        and ax, strict word 0x40
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        shl al, byte 0x6
        xor al, [CrowdState]
        and ax, strict word 0x40
        xor [CrowdState], ax
        mov al, [CrowdState]
        mov cl, [editopts]
        and cx, 0x80
        cmp cx, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        shl cx, byte 0x7
        db 0x32, 0xC1                           ; insn: xor al, cl
        and ax, 0x80
        xor [CrowdState], ax
.22:
        test byte [SoundOptions], 0x2
        jz short .23
        mov ah, [editopts_b1]
        and ax, 0x100
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        db 0x8A, 0xE0                           ; insn: mov ah, al
        xor ah, [AnnouncerFlags]
        and ax, 0x100
        xor [CrowdState], ax
.23:
        mov ah, [editopts_b1]
        and ax, 0xe00
        sub ax, 0x200
        jz short .24
        sub ax, 0x200
        jz short .27
        sub ax, 0x400
        jz short .28
        jmp short .26
.24:
        mov ax, [CrowdState]
        and ah, 0xfb
        or ah, 0x8
.25:
        mov [CrowdState], ax
.26:
        mov ah, [editopts_b1]
        and ax, 0xf000
        sub ax, 0x1000
        jz short .29
        sub ax, 0x1000
        jz short .32
        sub ax, 0x2000
        jz short .33
        sub ax, 0x4000
        jz short .34
        jmp short .31
        db 0x90
.27:
        mov ax, [CrowdState]
        and ah, 0xf7
        or ah, 0x4
        jmp short .25
        db 0x90
.28:
        and byte [AnnouncerFlags], 0xf3
        jmp short .26
        db 0x90
.29:
        mov ax, [CrowdState]
        and ah, 0x9f
        or ah, 0x10
.30:
        mov [CrowdState], ax
.31:
        test byte [CrowdState], 0x40
        jz short .35
        call 0x16F2:MusicOn
        jmp short .36
.32:
        mov ax, [CrowdState]
        and ah, 0xbf
        or ah, 0x30
        jmp short .30
        db 0x90
.33:
        mov ax, [CrowdState]
        and ah, 0xdf
        or ah, 0x50
        jmp short .30
        db 0x90
.34:
        or byte [AnnouncerFlags], 0x70
        jmp short .31
        db 0x90
.35:
        call 0x16F2:MusicOff
.36:
        test byte [CrowdState], 0x80
        jz short .37
        call 0x16F2:SfxOn
        jmp short .38
        db 0x90
.37:
        call 0x16F2:SfxOff
.38:
        call 0x0F97:UseDbDescriptor
.39:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.40:
        test byte [bp - 0x14], 0x4
        jnz short .39
