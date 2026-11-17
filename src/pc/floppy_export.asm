; Exports a team or the league databases to floppy (LP.OVL)
; The first bytes and WaitLeagueFloppyTail finish WaitLeagueFloppy from floppy_drive.asm.
        push di
        push cs
        call FindLeagueFloppy - 0x410
        add sp, 0xa
WaitLeagueFloppyTail:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ExportTeamToFloppy                                         2139:000C  94 PC
; Writes a team's dbs to floppy.
;
; Takes 11 words of stack arguments. Calls BuildPathFar, OpenReadWriteShared, ReadLeagueTeamEntry,
; OpenReadShared, ReadAtOffset, CloseHandlePtr, _fstrcmp, FmtFromLeague and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
ExportTeamToFloppy:
        enter 0xe8, 0x0
        push si
        mov ax, 0xffff
        mov [bp - 0x2], ax
        mov [bp - 0xb0], ax
        mov [bp - 0xe8], ax
        mov [bp - 0xc6], ax
        imul ax, [bp + 0x12], 0x1e
        add ax, [bp + 0x14]
        mov dx, [bp + 0x16]
        mov [bp - 0xae], ax
        mov [bp - 0xac], dx
        mov word [bp - 0xb6], 0x0
        cmp word [bp + 0x1a], 0x0
        jnz short .1
        jmp near .18
.1:
        mov word [bp - 0x96], 0x0
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0xa8], ax
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xe8]
        push ax
        lea cx, [bp - 0x34]
        push cx
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0xb6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        jmp near .7
.3:
        push word [bp + 0x12]
        lea ax, [bp - 0xe6]
        push ss
        push ax
        push word [bp - 0xe8]
        call 0x20E6:ReadLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0xb6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xc6]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0xb6], ax
.4:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        push 0xb
        push ax
        push 0x1
        lea ax, [bp - 0xc2]
        push ss
        push ax
        push word [bp - 0xc6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.5:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
        push 0xd
        push ax
        push 0xc
        lea ax, [bp - 0xa4]
        push ss
        push ax
        push word [bp - 0xc6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.6:
        lea ax, [bp - 0xc6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0xb6], 0x0
        jnz short .8
        push word [bp - 0xac]
        push word [bp - 0xae]
        lea ax, [bp - 0xc2]
        push ss
        push ax
        call 0x0000:_fstrcmp
        add sp, 0x8
        mov [bp - 0xa8], ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0xa4]
        push ss
        push ax
        call 0x0000:_fstrcmp
        add sp, 0x8
        add [bp - 0xa8], ax
        jnz short .8
        mov word [bp - 0x96], 0x1
        jmp short .8
        db 0x90
.7:
        mov word [bp - 0x4], 0xffff
        mov word [bp - 0xb6], 0x0
.8:
        cmp word [bp - 0xa8], 0x0
        jnz short .9
        jmp near .11
.9:
        lea ax, [bp - 0xa4]
        push ss
        push ax
        lea ax, [bp - 0xc2]
        push ss
        push ax
        lea ax, [bp - 0x74]
        push ss
        push ax
        call 0x2305:FmtFromLeague
        add sp, 0xc
        lea ax, [bp - 0x74]
        mov es, [segTeamChoiceText12]
        mov [es:0x1f4], ax
        mov [es:0x1f6], ss
        lea ax, [bp - 0xb2]
        push ax
        lea cx, [bp - 0xaa]
        push cx
        lea dx, [bp - 0xc4]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xb2]
        push ax
        lea ax, [bp - 0xaa]
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
        mov [bp - 0xc4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
        mov word [bp - 0x96], 0xffff
        jmp short .11
        db 0x90, 0x90, 0x90
.10:
        mov word [bp - 0xb6], 0xffff
.11:
        cmp word [bp - 0xb6], 0x0
        jz short .12
        jmp near .17
.12:
        les bx, [bp - 0xae]
        test byte [es:bx + 0x18], 0x2
        jnz short .13
        jmp near .16
.13:
        cmp word [bp - 0x4], 0x0
        jnz short .14
        jmp near .16
.14:
        push 0x1
        push es
        push bx
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x20F8:WaitLeagueFloppy
        add sp, 0xa
        mov [bp - 0xb6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .17
        mov word [bp - 0xb6], 0x0
        lea ax, [bp - 0xb2]
        push ax
        lea cx, [bp - 0xaa]
        push cx
        lea dx, [bp - 0xb4]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xb2]
        push ax
        lea ax, [bp - 0xaa]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgNewFloppy
        push 0x2
        push word 0x3701
        push strict word msgAreYouSureYouWant
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0xc4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
        mov byte [bp - 0xd0], 0x1
        mov word [bp - 0x96], 0x1
.15:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .17
        mov word [bp - 0xb6], 0xffff
        jmp short .17
        db 0x90, 0x90, 0x90
.16:
        mov byte [bp - 0xd0], 0x1
        mov word [bp - 0xb6], 0x0
        mov word [bp - 0x96], 0x1
.17:
        lea ax, [bp - 0xe8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x96], 0x0
        jnz short .18
        cmp word [bp - 0xb6], 0x0
        jnz short .18
        jmp near .2
.18:
        cmp word [bp - 0xb6], 0x0
        jz short .19
        jmp near .43
.19:
        cmp word [bp + 0x18], 0x0
        jnz short .21
        les bx, [bp - 0xae]
        cmp byte [es:bx + 0x16], 0x1
        jz short .20
        jmp near .41
.20:
        cmp byte [bp - 0xd0], 0x1
        jz short .21
        jmp near .41
.21:
        imul ax, [bp + 0x12], 0x1e
        add ax, [bp + 0x14]
        mov dx, [bp + 0x16]
        push dx
        push ax
        call 0x2305:MsgCopyingDatabases
        add sp, 0x4
        mov word [bp - 0xb4], 0x0
.22:
        cmp word [bp - 0xb6], 0x0
        jnz short .23
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segTeamChoiceText13]
        mov bx, [bp - 0xb4]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        lea ax, [bp - 0x94]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x17d6
        lea ax, [bp - 0x94]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        inc word [bp - 0xb4]
        cmp word [bp - 0xb4], 0x7
        jl short .22
.23:
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Pinfo
        lea ax, [bp - 0x94]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x17d8
        lea ax, [bp - 0x94]
        push ax
        lea cx, [bp - 0x34]
        push cx
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Player
        lea ax, [bp - 0x94]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x17da
        lea ax, [bp - 0x94]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        mov word [bp - 0xb4], 0x0
.24:
        cmp word [bp - 0xb6], 0x0
        jz short .25
        jmp near .27
.25:
        push word 0x3701
        push strict word str_DriveColon
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [segTeamChoiceText13]
        mov bx, [bp - 0xb4]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0xb6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .26
        push word 0x3701
        push strict word str_DriveColon
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText13]
        mov bx, [bp - 0xb4]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0xb6], ax
.26:
        inc word [bp - 0xb4]
        cmp word [bp - 0xb4], 0x7
        jnl short .27
        jmp near .24
.27:
        cmp word [bp - 0xb6], 0x0
        jnz short .28
        push word 0x3701
        push strict word str_DriveColon
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0xb6], ax
.28:
        cmp word [bp - 0xb6], 0x0
        jnz short .29
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Game
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Game
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x94]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x94]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x1B35:CopyGameSettingsThunk
        add sp, 0x4
        mov [bp - 0xb6], ax
.29:
        les bx, [bp - 0xae]
        add word [es:bx + 0x1a], 0x1
        adc word [es:bx + 0x1c], 0x0
        mov al, 0x2
        mov [es:bx + 0x16], al
        or [es:bx + 0x18], al
        cmp word [bp - 0xb6], 0x0
        jnz short .30
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        mov [bp - 0xb6], ax
.30:
        cmp word [bp - 0xb6], 0x0
        jnz short .31
        mov al, [bp + 0x12]
        mov [bp - 0xc8], al
        push 0x1
        push 0x0
        push 0x0
        lea ax, [bp - 0xc8]
        push ss
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.31:
        cmp word [bp - 0xb6], 0x0
        jnz short .32
        push 0xb
        push -0x1
        push -0x1
        push word [bp - 0xac]
        push word [bp - 0xae]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.32:
        cmp word [bp - 0xb6], 0x0
        jnz short .33
        push 0xd
        push -0x1
        push -0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.33:
        cmp word [bp - 0xb6], 0x0
        jnz short .34
        push 0x4
        push -0x1
        push -0x1
        mov ax, [bp - 0xae]
        mov dx, [bp - 0xac]
        add ax, strict word 0x1a
        push dx
        push ax
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.34:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0xb6], 0x0
        jnz short .35
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xe8]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenWriteShared
        add sp, 0x4
        mov [bp - 0xb6], ax
.35:
        cmp word [bp - 0xb6], 0x0
        jnz short .36
        mov word [bp - 0xa6], 0x0
        push 0x2
        push 0x0
        push 0x13
        lea ax, [bp - 0xa6]
        push ss
        push ax
        push word [bp - 0xe8]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0xb6], ax
.36:
        cmp word [bp - 0xb6], 0x0
        jnz short .37
        push word [bp + 0x12]
        push word [bp - 0xac]
        push word [bp - 0xae]
        push word [bp - 0xe8]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0xb6], ax
.37:
        lea ax, [bp - 0xe8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0xb6], 0x0
        jnz short .38
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xb0]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0xb6], ax
.38:
        cmp word [bp - 0xb6], 0x0
        jnz short .39
        push word [bp + 0x12]
        push word [bp - 0xac]
        push word [bp - 0xae]
        push word [bp - 0xb0]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0xb6], ax
.39:
        call 0x0D90:RestoreUnderBox
        cmp word [bp - 0xb6], 0x0
        jnz short .40
        jmp near .43
.40:
        les bx, [bp - 0xae]
        mov byte [es:bx + 0x16], 0x1
        or byte [es:bx + 0x18], 0x1
        push word [bp + 0x12]
        push es
        push bx
        push word [bp - 0xb0]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        lea ax, [bp - 0xb2]
        push ax
        lea cx, [bp - 0xaa]
        push cx
        lea dx, [bp - 0xb4]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xb2]
        push ax
        lea ax, [bp - 0xaa]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3821
        push strict word msgErrorWhileExportingPlayerPlayer
        jmp near .42
        db 0x90
.41:
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x12]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x12]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x14], si
        mov byte [bp + si - 0x12], 0x0
        lea ax, [bp - 0x12]
        mov es, [segTeamChoiceText14]
        mov [es:0x4e5], ax
        mov [es:0x4e7], ss
        mov ax, [bp - 0xae]
        mov dx, [bp - 0xac]
        mov [es:0x4ed], ax
        mov [es:0x4ef], dx
        lea ax, [bp - 0xb2]
        push ax
        lea cx, [bp - 0xaa]
        push cx
        lea dx, [bp - 0xb4]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xb2]
        push ax
        lea ax, [bp - 0xaa]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word dlgExportButtons
.42:
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.43:
        lea ax, [bp - 0xb0]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0xb6]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CopyLeagueFiles                                            2139:07F4  94 PC
; Copies the league db files ('.xx')
;
; Takes 4 words of stack arguments. Calls CopyFileByName. Far routine (retf).
;-----------------------------------------------------------------------------
CopyLeagueFiles:
        enter 0x4, 0x0
        push di
        push si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov si, 0xb6c
        mov di, [bp + 0xa]
.1:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .3
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText13]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Xx_2
        push word 0x3701
        push strict word str_Xx_2
        mov es, [segTeamChoiceText13]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
.2:
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        add si, 0x4
        cmp si, 0xb88
        jc short .1
.3:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .4
        db 0x8B, 0xF2                           ; insn: mov si, dx
        jmp short .5
        db 0x90
.4:
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ImportMasterLeague                                         2139:08C6  94 PC
; Imports the master league from floppy.
;
; Calls BuildPathFar, OpenReadShared, ReadAtOffset, CloseHandlePtr, ReadLeagueInfo, _fstrcpy,
; _dos_findfirst, AskMasterPassword and others. Far routine (retf).
;-----------------------------------------------------------------------------
ImportMasterLeague:
        enter 0x70, 0x0
        push si
        mov ax, 0xffff
        mov [bp - 0xa], ax
        mov [bp - 0x8], ax
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        mov ax, 0xbfa
        mov cx, 0x3701
        mov [bp - 0x6c], ax
        mov [bp - 0x6a], cx
        push cx
        push ax
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push 0xd
        push si
        push 0xc
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0xa]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        lea ax, [bp - 0xa]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .2
        jmp near .13
.2:
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
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, 0xe53
        mov cx, 0x3701
        mov [bp - 0x70], ax
        mov [bp - 0x6e], cx
        push cx
        push ax
        lea ax, [bp - 0x1c]
        push ss
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
        jnz short .3
        jmp near .12
.3:
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        mov es, [segWorkBuffer12]
        push word [es:0xac5a]
        call 0x28A8:AskMasterPassword
        add sp, 0xa
        mov [bp - 0xc], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        jmp near .13
.4:
        push ax
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3821
        push strict word msgImportingMasterDatabases
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        lea ax, [bp - 0x1c]
        push ax
        call 0x0000:_mkdir
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        mov [bp - 0x6], si
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        push word [bp - 0x6e]
        push word [bp - 0x70]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText13]
        mov bx, [bp - 0x6]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc word [bp - 0x6]
        cmp word [bp - 0x6], 0x7
        jl short .5
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        push word [bp - 0x6e]
        push word [bp - 0x70]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x8B, 0xF0                           ; insn: mov si, ax
.7:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .8
        push word [bp - 0x6e]
        push word [bp - 0x70]
        push word [bp - 0x6a]
        push word [bp - 0x6c]
        push ds
        push strict word str_Set_4
        push ds
        push strict word str_Set_3
        push ds
        push strict word str_Game_5
        call 0x0CD1:CopyFileByName
        add sp, 0x14
.8:
        call 0x0D90:RestoreUnderBox
        push word [bp - 0x6e]
        push word [bp - 0x70]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push strict word str_Sav_7
        push strict word str_Game_9
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp - 0x6e]
        push word [bp - 0x70]
        lea ax, [bp - 0x3c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x3c]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .9
        push 0x2
        push si
        push 0x13
        lea ax, [bp - 0xe]
        push ss
        push ax
        push word [bp - 0x8]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.9:
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .10
        push -0x1
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x6e]
        push word [bp - 0x70]
        call 0x2305:CopyHumanTeamDBs
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.10:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .11
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3836
        push strict word msgErrorWhileUpdatingPlayersDatabases
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.11:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .13
        lea ax, [bp - 0x1c]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
        jmp short .13
.12:
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
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
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3701
        push strict word msgCanNotImportMasterLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.13:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .14
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
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
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgErrorWhileImportingLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.14:
        cmp word [bp - 0xc], 0x0
        jz short .15
        mov si, 0xffff
.15:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ImportPlayerTeam                                           2139:0C2E  94 PC
; Imports a player's team from floppy.
;
; Calls SetDialogColors, BuildPathFar, OpenReadShared, ReadAtOffset, CloseHandlePtr, _sprintf,
; _fstrcpy, OpenReadWriteShared and others. Far routine (retf).
;-----------------------------------------------------------------------------
ImportPlayerTeam:
        enter 0xae, 0x0
        push si
        mov ax, 0xffff
        mov [bp - 0x8a], ax
        mov [bp - 0x90], ax
        mov [bp - 0x60], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x5c], ax
        push ax
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x50]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8a]
        push ax
        lea cx, [bp - 0x50]
        push cx
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x6a], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        push 0x1
        push ax
        push ax
        lea ax, [bp - 0x8e]
        push ss
        push ax
        push word [bp - 0x8a]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x6a], ax
.1:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        push 0xb
        push ax
        push 0x1
        lea ax, [bp - 0x84]
        push ss
        push ax
        push word [bp - 0x8a]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x6a], ax
.2:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push 0xd
        push ax
        push 0xc
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x8a]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x6a], ax
.3:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        push 0x4
        push ax
        push 0x19
        lea ax, [bp - 0x68]
        push ss
        push ax
        push word [bp - 0x8a]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x6a], ax
.4:
        lea ax, [bp - 0x8a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x6a], 0x0
        jnz short .5
        mov al, [bp - 0x8e]
        cbw
        push ax
        push strict word str_02d_11
        lea ax, [bp - 0x56]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x56]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx_2
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x50]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x90]
        push ax
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x6a], ax
.5:
        cmp word [bp - 0x6a], 0x0
        jnz short .6
        mov al, [bp - 0x8e]
        cbw
        push ax
        lea ax, [bp - 0xae]
        push ss
        push ax
        push word [bp - 0x90]
        call 0x20E6:ReadLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0x6a], ax
.6:
        cmp word [bp - 0x6a], 0x0
        jnz short .7
        push 0x2
        push 0x0
        push 0x4
        lea ax, [bp - 0x30]
        push ss
        push ax
        push word [bp - 0x90]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x6a], ax
.7:
        lea ax, [bp - 0x90]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x6a], 0x0
        jz short .8
        jmp near .10
.8:
        cmp word [bp - 0x30], 0x0
        jnz short .9
        jmp near .10
.9:
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], si
        mov byte [bp + si - 0x78], 0x0
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x84]
        mov es, [segTeamChoiceText15]
        mov [es:0x69c], ax
        mov [es:0x69e], ss
        lea ax, [bp - 0x78]
        mov [es:0x6a4], ax
        mov [es:0x6a6], ss
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x5
        push word 0x3701
        push strict word dlgImportTeam2
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        jmp near .42
        db 0x90
.10:
        cmp word [bp - 0x6a], 0x0
        jz short .11
        jmp near .42
.11:
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x2e]
        push ax
        push 0x10
        lea ax, [bp - 0x78]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        mov [bp - 0x88], ax
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], si
        mov byte [bp + si - 0x78], 0x0
        cmp word [bp - 0x88], 0x0
        jz short .12
        jmp near .16
.12:
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
        mov [bp - 0x6a], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x52], ax
        push ax
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov es, [segWorkBuffer13]
        test byte [es:0xac5e], 0xc
        jz short .13
        lea ax, [bp - 0x78]
        mov es, [segTeamChoiceText16]
        mov [es:0x907], ax
        mov [es:0x909], ss
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgMergeFirst
        push 0x4
        push es
        push word 0x903
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x86], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        call 0x2CB7:UpdateTeamDbs
        mov word [bp - 0x52], 0xffff
        jmp short .15
        db 0x90
.13:
        mov es, [segWorkBuffer14]
        cmp word [es:0xac60], 0x0
        jz short .15
        lea ax, [bp - 0x78]
        mov es, [segTeamChoiceText17]
        mov [es:0xb36], ax
        mov [es:0xb38], ss
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
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
.14:
        mov word [bp - 0x5c], 0xffff
.15:
        cmp word [bp - 0x52], 0x0
        jz short .16
        jmp near .12
.16:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        cmp word [bp - 0x6a], 0x0
        jz short .17
        jmp near .41
.17:
        cmp word [bp - 0x5c], 0x0
        jz short .18
        jmp near .41
.18:
        lea ax, [bp - 0x5a]
        push ss
        push ax
        push word 0x3701
        push strict word CurLeagueName
        call 0x2305:GetLeagueId
        add sp, 0x8
        mov [bp - 0x8c], ax
        cmp byte [bp - 0x98], 0x2
        jnz short .20
        cmp word [bp - 0x88], 0x0
        jz short .19
        jmp near .21
.19:
        mov al, [bp - 0x8e]
        cbw
        imul bx, ax, 0x1e
        mov es, [segWorkBuffer15]
        cmp byte [es:bx - 0x5388], 0x2
        jz short .21
        mov ax, [bp - 0x94]
        mov dx, [bp - 0x92]
        cmp [es:bx - 0x5382], dx
        jc short .21
        ja short .20
        cmp [es:bx - 0x5384], ax
        jc short .21
.20:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x84]
        mov es, [segTeamChoiceText18]
        mov [es:0x63c], ax
        mov [es:0x63e], ss
        lea ax, [bp - 0x78]
        mov [es:0x644], ax
        mov [es:0x646], ss
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word dlgImportTeam
        jmp near .26
.21:
        cmp word [bp - 0x88], 0x0
        jz short .22
        jmp near .33
.22:
        mov al, [bp - 0x8e]
        cbw
        imul bx, ax, 0x1e
        mov es, [segWorkBuffer15]
        mov ax, [bp - 0x94]
        mov dx, [bp - 0x92]
        cmp [es:bx - 0x5382], dx
        jc short .24
        ja short .23
        cmp [es:bx - 0x5384], ax
        jna short .24
.23:
        lea ax, [bp - 0x78]
        mov es, [segTeamChoiceText19]
        mov [es:0x71a], ax
        mov [es:0x71c], ss
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgThatFloppyDiskHasAn
        jmp short .26
.24:
        cmp word [bp - 0x8c], 0x0
        jnl short .25
        jmp near .28
.25:
        mov al, [bp - 0x8e]
        cbw
        cmp ax, [bp - 0x8c]
        jz short .27
        lea ax, [bp - 0x78]
        mov es, [segTeamChoiceText20]
        mov [es:0x60b], ax
        mov [es:0x60d], ss
        imul ax, [bp - 0x8c], 0x1e
        add ax, 0xac62
        mov [es:0x613], ax
        mov word [es:0x615], 0x3a0b
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x4
        push word 0x3701
        push strict word msgTheLeague2
.26:
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        jmp near .41
        db 0x90
.27:
        lea ax, [bp - 0x84]
        push ss
        push ax
        call 0x2305:MsgCopyingDatabases
        add sp, 0x4
        mov byte [bp - 0x98], 0x1
        cmp word [bp - 0x6a], 0x0
        jnz short .30
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word str_DriveColon
        push cs
        call CopyLeagueFiles
        add sp, 0x8
        mov [bp - 0x6a], ax
        jmp short .30
        db 0x90
.28:
        lea ax, [bp - 0x84]
        push ss
        push ax
        call 0x2305:MsgCopyingDatabases
        add sp, 0x4
        mov byte [bp - 0x98], 0x1
        mov word [bp - 0x64], 0x0
.29:
        cmp word [bp - 0x6a], 0x0
        jnz short .30
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word str_DriveColon
        push word 0x3701
        push strict word str_Xx_2
        push word 0x3701
        push strict word str_Xx_2
        mov es, [segTeamChoiceText13]
        mov bx, [bp - 0x64]
        shl bx, byte 0x2
        push word [es:bx + 0xb6e]
        push word [es:bx + 0xb6c]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x6a], ax
        inc word [bp - 0x64]
        cmp word [bp - 0x64], 0x7
        jl short .29
.30:
        cmp word [bp - 0x6a], 0x0
        jnz short .31
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word str_DriveColon
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Game
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x6a], ax
.31:
        cmp word [bp - 0x6a], 0x0
        jnz short .32
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x50]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x60]
        push ax
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x6a], ax
.32:
        cmp word [bp - 0x6a], 0x0
        jmp near .37
.33:
        lea ax, [bp - 0x84]
        push ss
        push ax
        call 0x2305:MsgCopyingDatabases
        add sp, 0x4
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x78]
        push ax
        call 0x0000:_mkdir
        add sp, 0x2
        mov [bp - 0x6a], ax
        mov byte [bp - 0x98], 0x1
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .34
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word str_DriveColon
        push cs
        call CopyLeagueFiles
        add sp, 0x8
        mov [bp - 0x6a], ax
.34:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .35
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word str_DriveColon
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Set
        push word 0x3701
        push strict word str_Game
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x6a], ax
.35:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .36
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x50]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x60]
        push ax
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x6a], ax
.36:
        db 0x0B, 0xC0                           ; insn: or ax, ax
.37:
        jnz short .38
        mov al, [bp - 0x8e]
        cbw
        push ax
        lea ax, [bp - 0xae]
        push ss
        push ax
        push word [bp - 0x60]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0x6a], ax
.38:
        lea ax, [bp - 0x60]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x6a], 0x0
        jnz short .39
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word str_DriveColon
        lea ax, [bp - 0x50]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x90]
        push ax
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x6a], ax
.39:
        cmp word [bp - 0x6a], 0x0
        jnz short .40
        mov al, [bp - 0x8e]
        cbw
        push ax
        lea ax, [bp - 0xae]
        push ss
        push ax
        push word [bp - 0x90]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
.40:
        lea ax, [bp - 0x90]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.41:
        cmp word [bp - 0x6a], 0x0
        jz short .42
        cmp word [bp - 0x88], 0x0
        jz short .42
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x78]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x78]
        push ax
        call 0x0CD1:RemoveDirTree
        add sp, 0x2
.42:
        call 0x0D90:RestoreUnderBox
        cmp word [bp - 0x6a], 0x0
        jz short .43
        lea ax, [bp - 0x62]
        push ax
        lea cx, [bp - 0x5e]
        push cx
        lea dx, [bp - 0x64]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x62]
        push ax
        lea ax, [bp - 0x5e]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgErrorWhileImportingLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.43:
        mov ax, [bp - 0x6a]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ImportDbs                                                  2139:1430  94 PC
; Import menu item.
;
; Calls SetDialogColors, MouseRead, MessageBox, SelectFloppyDrive, ImportMasterLeague,
; ImportPlayerTeam, BuildPathFar, OpenReadShared and others. Far routine (retf).
;-----------------------------------------------------------------------------
ImportDbs:
        enter 0x28, 0x0
        push si
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
        push strict word dlgImportChoice
        push 0x2
        push word 0x3701
        push strict word msgImportMasterCopyOfLeague
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .1
        jmp near .10
.1:
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3701
        push strict word msgPutDiskWithLeagueTo
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push si
        push si
        push si
        push si
        call 0x20F8:SelectFloppyDrive
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        jmp near .10
.3:
        cmp [bp - 0x2], si
        jnz short .4
        push cs
        call ImportMasterLeague
        jmp short .5
        db 0x90
.4:
        push cs
        call ImportPlayerTeam
.5:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .6
        jmp near .9
.6:
        push ds
        push strict word str_Set_2
        push ds
        push strict word str_Game_4
        push word 0x3701
        push strict word CurLeagueName
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
        jnz short .8
        push 0x62
        push -0x1
        push -0x1
        push word 0x3415
        push strict word lgstate
        push word [bp - 0x8]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0x1805
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push word 0x1808
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        push word 0x3415
        push strict word lgstate
        call 0x1B35:LoadModeStateThunk
        add sp, 0x4
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov es, [segMenuText20]
        mov word [es:0xb6c], strict word MenuExportDbsThunk
        mov word [es:0xb6e], 0x1b35
        mov word [es:0xb82], strict word MenuNextLeagueGameThunk
        mov word [es:0xb84], 0x1b35
        mov word [es:0xb9c], 0xd86
        mov word [es:0xb9e], 0x3448
        jmp short .10
.9:
        mov es, [segDbFiles12]
        mov byte [es:0xc6], 0x0
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov es, [segMenuText20]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0xb6e], ax
        mov [es:0xb6c], ax
        mov [es:0xb84], ax
        mov [es:0xb82], ax
        mov [es:0xb9e], ax
        mov [es:0xb9c], ax
.10:
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
        add sp, 0xa
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ExportDbs                                                  2139:15EC  94 PC
; 'Select a team to export.'
;
; Calls LeagueCheckStub, ReadLeagueInfo, _fstrcpy, _fstrcspn, SetDialogColors, MouseRead, MessageBox,
; UpdateTeamDbs and others. Far routine (retf).
;-----------------------------------------------------------------------------
ExportDbs:
        enter 0x58, 0x0
        push di
        push si
        push 0x3
        mov ax, 0xe53
        mov cx, 0x3701
        mov [bp - 0x52], ax
        mov [bp - 0x50], cx
        push cx
        push ax
        call 0x2305:LeagueCheckStub
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .2
        jmp near .5
.2:
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
        push word [bp - 0x50]
        push word [bp - 0x52]
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lea ax, [bp - 0x2e]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov byte [bx], 0x0
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x14]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        mov es, [segWorkBuffer13]
        test byte [es:0xac5e], 0xc
        jz short .3
        lea ax, [bp - 0x2e]
        mov es, [segTeamChoiceText16]
        mov [es:0x907], ax
        mov [es:0x909], ss
        push -0x1
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x18]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgMergeFirst
        push 0x4
        push es
        push word 0x903
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x14], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        call 0x2CB7:UpdateTeamDbs
        mov di, 0xffff
        jmp short .5
.3:
        mov es, [segWorkBuffer14]
        cmp word [es:0xac60], 0x0
        jz short .5
        lea ax, [bp - 0x2e]
        mov es, [segTeamChoiceText17]
        mov [es:0xb36], ax
        mov [es:0xb38], ss
        push -0x1
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x18]
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
        mov si, 0xffff
.5:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .6
        jmp near .1
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .7
        jmp near .21
.7:
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText13]
        push word [es:0xb7e]
        push word [es:0xb7c]
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x4e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x1
        push word 0x3a0b
        push strict word LeagueTeamNames
        lea ax, [bp - 0x4e]
        push ax
        call 0x22D3:ReadTeamNames
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        jmp near .21
.8:
        mov [bp - 0x4], ax
        mov word [bp - 0x2], 0xffff
        lea ax, [bp - 0x1c]
        push ss
        push ax
        push word [bp - 0x50]
        push word [bp - 0x52]
        call 0x2305:GetLeagueId
        add sp, 0x8
        mov [bp - 0x12], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .9
        lea ax, [bp - 0x12]
        push ax
        push word 0x3701
        push strict word str_SelectATeamToExport
        push 0x8
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3a0b
        push strict word LeagueTeamNames
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word [bp - 0x50]
        push word [bp - 0x52]
        call 0x1F31:LeagueTeamSelect
        add sp, 0x18
        mov es, [segWorkBuffer16]
        cmp word [es:0xac5c], 0x1
        jnz short .10
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        jmp short .10
        db 0x90
.9:
        mov word [bp - 0x2], 0x0
.10:
        cmp word [bp - 0x12], 0x0
        jnl short .11
        jmp near .15
.11:
        mov es, [segWorkBuffer15]
        imul bx, [bp - 0x12], 0x1e
        mov [bp - 0x54], bx
        cmp byte [es:bx - 0x5388], 0x2
        jz short .12
        jmp near .15
.12:
        lea ax, [bp - 0x2e]
        mov es, [segTeamChoiceText14]
        mov [es:0x4e5], ax
        mov [es:0x4e7], ss
        mov ax, [bp - 0x54]
        add ax, 0xac62
        mov [es:0x4ed], ax
        mov word [es:0x4ef], 0x3a0b
        lea ax, [bp - 0x16]
        push ax
        lea cx, [bp - 0x18]
        push cx
        lea dx, [bp - 0x14]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x18]
        push ax
        push 0x2
        push word 0x3701
        push strict word dlgExportToFloppy
        push 0x4
        push word 0x3701
        push strict word dlgExportButtons
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x14], ax
        mov si, 0xffff
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        mov es, [segWorkBuffer12]
        push word [es:0xac5a]
        call 0x28A8:AskMasterPassword
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.13:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .14
        mov word [bp - 0x4], 0xffff
        mov es, [segWorkBuffer15]
        imul bx, [bp - 0x12], 0x1e
        add word [es:bx - 0x5384], 0x0
        adc word [es:bx - 0x5382], 0x1
        jmp short .15
        db 0x90
.14:
        mov word [bp - 0x12], 0xffff
.15:
        cmp word [bp - 0x12], 0x0
        jnl short .16
        jmp near .21
.16:
        mov es, [segWorkBuffer16]
        cmp word [es:0xac5c], 0x1
        jz short .17
        cmp word [bp - 0x2], 0x0
        jnz short .18
.17:
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
.18:
        push word [bp - 0x12]
        push strict word str_02d_10
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x20]
        push ss
        push ax
        mov ax, 0xbe4
        mov cx, 0x3701
        mov [bp - 0x58], ax
        mov [bp - 0x56], cx
        push cx
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        cmp word [bp - 0x4], 0x0
        jz short .19
        mov ax, 0xbaf
        mov cx, 0x3701
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xe], cx
        jmp short .20
.19:
        mov ax, [bp - 0x58]
        mov dx, [bp - 0x56]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xe], dx
.20:
        mov ax, [bp - 0x58]
        mov dx, [bp - 0x56]
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        imul ax, [bp - 0x12], 0x1e
        add ax, 0xac62
        push word 0x3a0b
        push ax
        push word [bp - 0x50]
        push word [bp - 0x52]
        call 0x20F8:SelectFloppyDrive
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .21
        push -0x1
        push word [bp - 0x4]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x12]
        push word 0x3701
        push strict word str_Xx_2
        push word [bp - 0xe]
        push si
        push word [bp - 0x50]
        push word [bp - 0x52]
        push cs
        call ExportTeamToFloppy
        add sp, 0x16
.21:
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
        add sp, 0xa
        pop si
        pop di
        leave
        retf
        db 0x90
