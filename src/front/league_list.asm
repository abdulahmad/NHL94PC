; League list and master password check; copies the human team databases (LP.OVL)
; The first bytes finish the last routine of league_info.asm.
        call 0x1B35:SetSoundDeviceThunk
        add sp, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CheckMasterPassword                                        2305:000C  94 PC
; Master password check.
;
; Calls LeagueCheckStub, ReadLeagueInfo, _fstrcpy, _fstrcspn, SetDialogColors, MouseRead, MessageBox,
; MergeLeagueFiles and others. Far routine (retf).
;-----------------------------------------------------------------------------
CheckMasterPassword:
        enter 0x1c, 0x0
        push di
        push si
        push 0x2
        mov ax, 0xe53
        mov cx, 0x3701
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], cx
        push cx
        push ax
        push cs
        call LeagueCheckStub
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x0B, 0xF6                           ; insn: or si, si
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
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        jmp near .5
.3:
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lea ax, [bp - 0x18]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov byte [bx], 0x0
        mov es, [segWorkBuffer17]
        test byte [es:0xac5e], 0x4
        jnz short .5
        mov es, [segTeamChoiceText22]
        mov [es:0x8b3], ax
        mov [es:0x8b5], ss
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
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
        lea ax, [bp - 0x6]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgMergeFirst
        push 0x4
        push word 0x3701
        push strict word msgMasterDatabasesFor
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        call 0x2CB7:MergeLeagueFiles
        mov di, 0xffff
        jmp short .5
.4:
        mov si, 0xffff
.5:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .6
        jmp near .1
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .7
        jmp near .9
.7:
        cmp byte [g_E36B], 0x0
        jz short .8
        push si
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        mov al, 0x17
        mov [bp - 0xa], al
        mov [bp - 0x9], al
        mov [bp - 0x8], al
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x2a
        mov [bp - 0xa], al
        mov [bp - 0x9], al
        mov [bp - 0x8], al
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x3f
        mov [bp - 0xa], al
        mov [bp - 0x9], al
        mov [bp - 0x8], al
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.8:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        mov es, [segWorkBuffer18]
        push word [es:0xac5a]
        call 0x28A8:AskMasterPassword
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp byte [g_E36B], 0x0
        jz short .9
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bp - 0xa], al
        mov [bp - 0x9], al
        mov [bp - 0x8], al
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        lea ax, [bp - 0xa]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.9:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FmtFromLeague                                              2305:0214  94 PC
; '<name> from the league <league>'
;
; Takes 6 words of stack arguments. Calls _fstrcpy, _fstrcspn, _fstrcat. Far routine (retf).
;-----------------------------------------------------------------------------
FmtFromLeague:
        enter 0xe, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        push word [bp + 0x10]
        push word [bp + 0xe]
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov byte [bp + di - 0xe], 0x0
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov ax, [bp + 0x8]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_FromTheLeague
        push di
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        lea ax, [bp - 0xe]
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

;-----------------------------------------------------------------------------
; BuildLeagueList                                            2305:0282  94 PC
; Lists the *.LP leagues.
;
; Takes 3 words of stack arguments. Calls _fstrcpy, _fstrcat, _dos_findfirst, _dos_findnext,
; AllocRecData, _fmemset, GetLeagueId, _fstrcspn and others. Far routine (retf).
;-----------------------------------------------------------------------------
BuildLeagueList:
        enter 0x52, 0x0
        push di
        push si
        push word 0x3701
        push strict word str_Star
        lea ax, [bp - 0x1e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Lp
        lea ax, [bp - 0x1e]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        db 0x2B, 0xFF                           ; insn: sub di, di
        lea ax, [bp - 0x4a]
        push ax
        push 0x10
        lea ax, [bp - 0x1e]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        mov di, 0x1
.1:
        lea ax, [bp - 0x4a]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        inc di
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .1
.3:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .4
        jmp near .14
.4:
        push 0x0
        db 0x8B, 0xC7                           ; insn: mov ax, di
        shl ax, byte 0x2
        cwd
        push dx
        push ax
        push word 0x182a
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4e], si
        mov [bp - 0x4c], dx
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov bx, [bp + 0x6]
        mov [bx], ax
        mov [bx + 0x2], dx
        push word [bp - 0x4e]
        push 0x0
        push dx
        push word [bx]
        call 0x0000:_fmemset
        add sp, 0x8
        push 0x0
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x3
        db 0x03, 0xC1                           ; insn: add ax, cx
        cwd
        push dx
        push ax
        push strict word str_Llsn
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x52], si
        mov [bp - 0x50], dx
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov bx, [bp + 0x8]
        mov [bx], ax
        mov [bx + 0x2], dx
        push word [bp - 0x52]
        push 0x0
        push dx
        push word [bx]
        call 0x0000:_fmemset
        add sp, 0x8
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov word [bp - 0x8], 0x0
        db 0x0B, 0xFF                           ; insn: or di, di
        jg short .5
        jmp near .14
.5:
        mov [bp - 0xa], di
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x4], cx
        lea ax, [bp - 0x2c]
        mov [bp - 0x6], si
        mov [bp - 0x2], cx
        mov [bp - 0xc], si
        db 0x8B, 0xF1                           ; insn: mov si, cx
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        lea ax, [bp - 0x4a]
        push ax
        push 0x10
        lea ax, [bp - 0x1e]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        jmp short .8
        db 0x90
.7:
        lea ax, [bp - 0x4a]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
.8:
        lea ax, [bp - 0x10]
        push ss
        push ax
        lea ax, [bp - 0x2c]
        push ss
        push ax
        push cs
        call GetLeagueId
        add sp, 0x8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .9
        test byte [bp + 0xa], 0x2
        jnz short .10
.9:
        db 0x0B, 0xFF                           ; insn: or di, di
        jl short .11
        test byte [bp + 0xa], 0x1
        jz short .11
.10:
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x2c]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push di
        lea ax, [bp - 0x2c]
        push ss
        push ax
        mov bx, [bp + 0x8]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov bx, [bp + 0x8]
        les bx, [bx]
        db 0x03, 0xDF                           ; insn: add bx, di
        mov byte [es:bx + si], 0x0
        mov bx, [bp + 0x8]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        db 0x03, 0xC6                           ; insn: add ax, si
        mov bx, [bp + 0x6]
        les bx, [bx]
        mov di, [bp - 0x4]
        mov [es:bx + di], ax
        mov [es:bx + di + 0x2], dx
        jmp short .12
.11:
        dec word [bp - 0xa]
.12:
        add word [bp - 0x4], 0x4
        add si, 0x9
        dec word [bp - 0x6]
        jz short .13
        jmp near .6
.13:
        mov di, [bp - 0xa]
.14:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .15
        mov bx, [bp + 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0x2], ax
        mov [bx], ax
        mov bx, [bp + 0x8]
        mov [bx + 0x2], ax
        mov [bx], ax
.15:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LeagueCheckStub                                            2305:044C  94 PC
; Empty check routine.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
LeagueCheckStub:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GetLeagueId                                                2305:0450  94 PC
; League id from PLAYER.ID.
;
; Takes 4 words of stack arguments. Calls BuildPathFar, OpenReadShared, ReadAtOffset, CloseHandlePtr.
; Far routine (retf).
;-----------------------------------------------------------------------------
GetLeagueId:
        enter 0x24, 0x0
        push si
        mov word [bp - 0x4], 0xffff
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x24]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push 0x1
        push si
        push si
        lea ax, [bp - 0x1]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push 0x4
        push si
        push 0x19
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        mov byte [bp - 0x1], 0xff
.3:
        lea ax, [bp - 0x4]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov al, [bp - 0x1]
        cbw
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; WriteLeagueInfo                                            2305:04DC  94 PC
; Writes PINFO.DB.
;
; Takes 12 words of stack arguments. Calls BuildPathFar, CreateFileNormal, WriteAtOffset,
; CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
WriteLeagueInfo:
        enter 0x22, 0x0
        push si
        mov word [bp - 0x2], 0xffff
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x22]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push 0x2
        push si
        push si
        lea ax, [bp + 0x14]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push 0x2
        push si
        push 0x2
        lea ax, [bp + 0x12]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        push 0x2
        push si
        push 0x4
        lea ax, [bp + 0x18]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        push 0xd
        push si
        push 0x6
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        push 0x2
        push si
        push 0x13
        lea ax, [bp + 0x16]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        push 0xb
        push si
        push 0x15
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        push word 0x2d0
        push si
        push 0x20
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.7:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; MsgCopyingDatabases                                        2305:05E8  94 PC
; 'copying databases' message.
;
; Takes 2 words of stack arguments. Calls MessageBox. Far routine (retf).
;-----------------------------------------------------------------------------
MsgCopyingDatabases:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov es, [segTeamChoiceText23]
        mov [es:0x6ca], ax
        mov [es:0x6cc], dx
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push es
        push word 0x6c6
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CopyHumanTeamDBs                                           2305:061C  94 PC
; Copies the human teams' dbs.
;
; Takes 6 words of stack arguments. Calls MsgCopyingDatabases, _fstrcpy, DeleteMatching,
; CopyFileByName, BuildPathFar, OpenReadWriteShared, WriteLeagueTeamEntry, CloseHandlePtr and others.
;-----------------------------------------------------------------------------
CopyHumanTeamDBs:
        enter 0xa8, 0x0
        push si
        mov ax, 0xffff
        mov [bp - 0x2], ax
        mov [bp - 0x9e], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa4], ax
        mov [bp - 0xa2], ax
        jmp near .9
.1:
        mov word [bp - 0xa4], 0xffff
        jmp near .8
        db 0x90
.2:
        imul ax, [bp - 0xa2], 0x1e
        add ax, [bp + 0xa]
        mov dx, es
        push dx
        push ax
        push cs
        call MsgCopyingDatabases
        add sp, 0x4
        mov word [bp - 0xa6], 0x0
.3:
        cmp word [bp - 0xa4], 0x0
        jz short .4
        jmp near .5
.4:
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x1e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segTeamChoiceText26]
        mov bx, [bp - 0xa6]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        lea ax, [bp - 0x54]
        push ss
        push ax
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Xx_2
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x33]
        push ax
        lea ax, [bp - 0x54]
        push ax
        lea ax, [bp - 0x1e]
        push ax
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Xx_2
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText26]
        push word [es:si + 0xb6e]
        push word [es:si + 0xb6c]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0xa4], ax
        inc word [bp - 0xa6]
        cmp word [bp - 0xa6], 0x7
        jnl short .5
        jmp near .3
.5:
        cmp word [bp - 0xa4], 0x0
        jnz short .6
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x54]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x9e]
        push ax
        lea ax, [bp - 0x54]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0xa4], ax
.6:
        cmp word [bp - 0xa4], 0x0
        jnz short .7
        imul si, [bp - 0xa2], 0x1e
        les bx, [bp + 0xa]
        mov byte [es:bx + si + 0x16], 0x1
        push word [bp - 0xa2]
        add si, [bp + 0xa]
        mov cx, [bp + 0xc]
        push cx
        push si
        push word [bp - 0x9e]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0xa4], ax
.7:
        lea ax, [bp - 0x9e]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        call 0x0D90:RestoreUnderBox
.8:
        inc word [bp - 0xa2]
.9:
        cmp word [bp - 0xa2], 0x18
        jl short .10
        jmp near .24
.10:
        cmp word [bp - 0xa4], 0x0
        jz short .11
        jmp near .24
.11:
        imul si, [bp - 0xa2], 0x1e
        les bx, [bp + 0xa]
        cmp byte [es:bx + si + 0x17], 0x1
        jnz short .8
        cmp word [bp + 0xe], 0x0
        jl short .12
        mov ax, [bp + 0xe]
        cmp [bp - 0xa2], ax
        jnz short .8
.12:
        push word [bp - 0xa2]
        push strict word str_02d_9
        lea ax, [bp - 0x94]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x94]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx_2
        call 0x0000:_fstrcpy
        add sp, 0x8
        imul bx, [bp - 0xa2], 0x1e
        add bx, [bp + 0xa]
        mov es, [bp + 0xc]
        cmp byte [es:bx + 0x18], 0x2
        jz short .13
        jmp near .2
.13:
        test byte [es:bx + 0x16], 0x1
        jz short .14
        jmp near .2
.14:
        imul ax, [bp - 0xa2], 0x1e
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        push dx
        push ax
        lea ax, [bp - 0xe]
        push ss
        push ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0xe]
        mov es, [segTeamChoiceText24]
        mov [es:0x19e], ax
        mov [es:0x1a0], ss
        lea ax, [bp - 0xa0]
        push ax
        lea cx, [bp - 0x9a]
        push cx
        lea dx, [bp - 0xa8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xa0]
        push ax
        lea ax, [bp - 0x9a]
        push ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x9c], ax
        push ax
        push ax
        push ax
        push 0x3
        push word 0x3701
        push strict word msgInsertDiskFor
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x98], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
        add si, [bp + 0xa]
        mov cx, [bp + 0xc]
        push cx
        push si
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x20F8:SelectFloppyDrive
        add sp, 0x8
        mov [bp - 0x98], ax
.15:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        jmp near .21
.16:
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x54]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x54]
        push cx
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0xa4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .17
        jmp near .20
.17:
        push 0xb
        push ax
        push 0x1
        lea ax, [bp - 0xe]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        push 0xd
        push -0x1
        push -0x1
        lea ax, [bp - 0x2c]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        lea ax, [bp - 0xe]
        push ss
        push ax
        imul ax, [bp - 0xa2], 0x1e
        add ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        push dx
        push ax
        call 0x0000:_fmemcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        lea ax, [bp - 0x2c]
        push ss
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0000:_fmemcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .20
.18:
        lea ax, [bp - 0x2c]
        push ss
        push ax
        lea ax, [bp - 0xe]
        push ss
        push ax
        lea ax, [bp - 0x94]
        push ss
        push ax
        push cs
        call FmtFromLeague
        add sp, 0xc
        lea ax, [bp - 0x94]
        mov es, [segTeamChoiceText25]
        mov [es:0x1f4], ax
        mov [es:0x1f6], ss
        lea ax, [bp - 0xa0]
        push ax
        lea cx, [bp - 0x9a]
        push cx
        lea dx, [bp - 0xa8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xa0]
        push ax
        lea ax, [bp - 0x9a]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgInsertDisk
        push 0x3
        push word 0x3701
        push strict word msgThatDiskIsFor
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0xa8], ax
        cmp ax, strict word 0x1
        jz short .19
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .20
.19:
        mov word [bp - 0x9c], 0x1
.20:
        mov word [bp - 0xa4], 0x0
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.21:
        cmp word [bp - 0x9c], 0x0
        jz short .22
        cmp word [bp - 0x98], 0x0
        jnz short .22
        jmp near .14
.22:
        call 0x0F99:FlushInputEvents
        cmp word [bp - 0x98], 0x0
        jz short .23
        jmp near .1
.23:
        push 0x0
        push -0x1
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp - 0xa2]
        push word 0x3701
        push strict word str_Xx_2
        push word 0x3701
        push strict word str_Db_2
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x2139:ExportTeamToFloppy
        add sp, 0x16
        mov [bp - 0xa4], ax
        jmp near .8
        db 0x90
.24:
        cmp word [bp - 0xa4], 0x0
        jnz short .25
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x54]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x9e]
        push ax
        lea ax, [bp - 0x54]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0xa4], ax
.25:
        cmp word [bp - 0xa4], 0x0
        jnz short .26
        mov word [bp - 0x96], 0x0
        push 0x2
        push 0x0
        push 0x13
        lea ax, [bp - 0x96]
        push ss
        push ax
        push word [bp - 0x9e]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xa4], ax
.26:
        lea ax, [bp - 0x9e]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0xa4]
        pop si
