; Creates a new league (LP.OVL)
; The first bytes finish the last routine of season.asm.
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CreateNewLeague                                            2A1B:0004  94 PC
; 'Enter New League Name'
;
; Calls SetDialogColors, _fmemset, NumberEntryDialog, MouseRead, _fstrcat, _fstrcpy, _dos_findfirst,
; MessageBox and others.
;-----------------------------------------------------------------------------
CreateNewLeague:
        enter 0x70, 0x0
        push di
        push si
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x2], di
        mov [bp - 0x8], di
        mov [bp - 0x6], di
.1:
        push 0xb
        push 0x0
        imul ax, [bp - 0x8], 0x1e
        add ax, 0xac62
        push word 0x3a0b
        push ax
        call 0x0000:_fmemset
        add sp, 0x8
        push 0xb
        push 0x0
        imul ax, [bp - 0x8], 0x1e
        add ax, 0xac6d
        push word 0x3a0b
        push ax
        call 0x0000:_fmemset
        add sp, 0x8
        mov es, [segWorkBuffer26]
        imul bx, [bp - 0x8], 0x1e
        mov byte [es:bx - 0x5388], 0x1
        mov byte [es:bx - 0x5387], 0x0
        mov byte [es:bx - 0x5386], 0x2
        mov byte [es:bx - 0x5385], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx - 0x5382], ax
        mov [es:bx - 0x5384], ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x18
        jl short .1
        push 0x5
        push ax
        push ax
        push ax
        push ax
        push 0x30
        push 0x8
        lea ax, [bp - 0x1c]
        push ax
        push word 0x3701
        push strict word str_EnterNewLeagueName
        call 0x0D90:NumberEntryDialog
        add sp, 0x14
        mov [bp - 0x8], ax
        cmp byte [bp - 0x1c], 0x0
        jnz short .2
        jmp near .19
.2:
        cmp ax, strict word 0x1b
        jnz short .3
        jmp near .19
.3:
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0xc]
        push ax
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        push word 0x3701
        push strict word str_Lp
        lea ax, [bp - 0x1c]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea ax, [bp - 0x1c]
        push ss
        push ax
        mov ax, 0xe53
        mov cx, 0x3701
        mov [bp - 0x6c], ax
        mov [bp - 0x6a], cx
        push cx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x68]
        push ax
        push 0x10
        lea ax, [bp - 0x1c]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        push -0x1
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0xc]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgReplaceLeague
        push 0x2
        push word 0x3701
        push strict word msgThereIsAlreadyALeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        lea ax, [bp - 0x1c]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
        jmp short .5
        db 0x90
.4:
        mov di, 0x1
.5:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .6
        push -0x1
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0xc]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgWhichSchedule
        push 0x1
        push word 0x3701
        push strict word msgWhichScheduleDoYouWant
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x4], ax
        inc ax
        jnz short .6
        mov di, 0xffff
.6:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .7
        call 0x0D90:AskYesNo
        inc ax
        jnz short .7
        mov di, 0xffff
.7:
        mov si, [bp - 0x2]
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        lea ax, [bp - 0x1c]
        push ax
        call 0x0000:_mkdir
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.8:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .9
        jmp near .16
.9:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .10
        jmp near .16
.10:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText36]
        push word [es:msgThereIsASavedGame + 0x4C]
        push word [es:msgThereIsASavedGame + 0x4A]
        push si
        push si
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x1
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x3c]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .11
        jmp near .16
.11:
        lea ax, [bp - 0xe]
        push ax
        push word 0x3701
        push strict word str_SelectHumanControlledTeams
        push 0x1
        mov cx, 0xac62
        mov dx, 0x3a0b
        mov [bp - 0x70], cx
        mov [bp - 0x6e], dx
        push dx
        push cx
        push word 0x3a0b
        push strict word LeagueTeamNames
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        call 0x1F31:LeagueTeamSelect
        add sp, 0x18
        push strict word str_Pnt2_7
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        cmp word [bp - 0xe], 0x0
        jnl short .12
        jmp near .16
.12:
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgCreatingLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        push word 0x3a0b
        push strict word leagueinfo_tail
        mov es, [segWorkBuffer27]
        push word [es:leagueinfo_w6]
        mov es, [segWorkBuffer28]
        push word [es:leagueinfo_w4]
        mov es, [segWorkBuffer29]
        push word [es:leagueinfo_w2]
        mov es, [segWorkBuffer30]
        push word [es:leagueinfo]
        push word 0x3a0b
        push strict word leagueinfo_password
        push word [bp - 0x6e]
        push word [bp - 0x70]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        call 0x2305:WriteLeagueInfo
        add sp, 0x18
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x8], 0x0
.13:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .14
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        push si
        push si
        push word 0x3701
        push strict word str_Db_2
        push word [YesNoTextSeg]
        push word [YesNoText]
        mov es, [segTeamChoiceText36]
        mov bx, [bp - 0x8]
        shl bx, byte 0x2
        push word [es:bx + msgThereIsASavedGame + 0x3C]
        push word [es:bx + msgThereIsASavedGame + 0x3A]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x7
        jl short .13
.14:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .15
        push word 0x3415
        push strict word lgstate
        call 0x1B35:WriteModeStateThunk
        add sp, 0x4
        push word [bp - 0x4]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        call 0x28CD:RandomizeSchedule
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
.15:
        call 0x0D90:RestoreUnderBox
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .16
        push -0x1
        push word [bp - 0x6e]
        push word [bp - 0x70]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        call 0x2305:CopyHumanTeamDBs
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.16:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .17
        cmp [bp - 0xe], si
        jnl short .19
.17:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .18
        lea ax, [bp - 0xa]
        push ax
        lea cx, [bp - 0xc]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0xc]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgErrorWhileCreatingLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.18:
        mov es, [segDbFiles14]
        mov byte [es:lgstate_name], 0x0
        lea ax, [bp - 0x1c]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
.19:
        push strict word str_Pntr_11
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
