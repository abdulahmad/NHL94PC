; Loads the game's teams from the player databases and the game summary file (INIT.OVL)

;-----------------------------------------------------------------------------
; LoadGameTeams                                              2425:0000  94 PC
; Reads both teams from the 'teams' db into the team records.
;
; Takes 1 word of stack arguments. Calls _sprintf, _dos_findfirst, FatalError, OpenReadShared, _lseek,
; ReadAtOffset, CloseHandlePtr, OpenPlayerDbs and others. Far routine (retf).
;-----------------------------------------------------------------------------
LoadGameTeams:
        enter 0x58, 0x0
        push di
        push si
        cmp word [bp + 0x6], 0x0
        jz short .1
        cmp word [bp + 0x6], 0x1
        jnz short .2
.1:
        mov ax, 0x3a0b
        mov ds, ax
        mov ax, 0xffff
        mov [GameTeamWord7], ax
        mov [GameTeamWord6], ax
        mov [GameTeamWord5], ax
        mov [GameTeamWord4], ax
        mov [GameTeamWord3], ax
        mov [GameTeamWord2], ax
        mov [GameTeamWord1], ax
        mov [GameTeamWord0], ax
.2:
        mov ax, DGROUP
        mov ds, ax
        push strict word str_Teams_2
        push word HomeTeamDbName
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x58]
        push ax
        push 0x0
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x5046
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0x5048
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0x0
        push 0x0
        push 0x0
        push word [bp - 0x4]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .5
        push word 0x504a
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        push 0x0
        mov ax, 0x2e8
        imul word [HomeTeamNum]
        push dx
        push ax
        push word [bp - 0x4]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .6
        push word 0x504c
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push word 0x2e8
        push -0x1
        push -0x1
        push ds
        push strict word GameTeamRecs
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0x504e
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        lea ax, [bp - 0x4]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        push strict word str_Teams
        push word AwayTeamDbName
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x58]
        push ax
        push 0x0
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push word 0x5056
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x2c]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        push word 0x5058
        call 0x0F4A:FatalError
        add sp, 0x2
.9:
        push 0x0
        push 0x0
        push 0x0
        push word [bp - 0x4]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .10
        push word 0x505a
        call 0x0F4A:FatalError
        add sp, 0x2
.10:
        push 0x0
        mov ax, 0x2e8
        imul word [VisTeamNum]
        push dx
        push ax
        push word [bp - 0x4]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .11
        push word 0x505c
        call 0x0F4A:FatalError
        add sp, 0x2
.11:
        push word 0x2e8
        push -0x1
        push -0x1
        push ds
        push strict word GameRosterRecs
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .12
        push word 0x505e
        call 0x0F4A:FatalError
        add sp, 0x2
.12:
        lea ax, [bp - 0x4]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0xc]
        push ax
        push word HomeTeamDbName
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x8]
        push dx
        lea bx, [bp - 0xa]
        push bx
        lea si, [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call OpenPlayerDbs
        add sp, 0xe
        push 0x0
        push word [bp - 0xc]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp - 0x4]
        push word [bp + 0x6]
        push cs
        call BuildTeamRoster
        add sp, 0xe
        push si
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0xa]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov al, [bp + 0x6]
        and al, 0x6
        jnz short .13
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.13:
        lea ax, [bp - 0xc]
        push ax
        push word AwayTeamDbName
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x8]
        push dx
        lea bx, [bp - 0xa]
        push bx
        lea si, [bp - 0x4]
        push si
        push word [bp + 0x6]
        push cs
        call OpenPlayerDbs
        add sp, 0xe
        push 0x1
        push word [bp - 0xc]
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp - 0x4]
        push word [bp + 0x6]
        push cs
        call BuildTeamRoster
        add sp, 0xe
        push si
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0xa]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov al, [bp + 0x6]
        and al, 0x6
        jnz short .14
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
.14:
        cmp word [bp + 0x6], 0x0
        jz short .15
        cmp word [bp + 0x6], 0x2
        jnz short .16
.15:
        mov ax, HomeTeamRec
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov si, HomeLinesRec
        push ds
        pop es
        mov cx, 0x18
        rep movsw
        mov ax, AwayTeamRec
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov si, GameRosterRecs + 0xbc
        mov cx, 0x18
        rep movsw
.16:
        db 0x2B, 0xF6                           ; insn: sub si, si
.17:
        cmp byte [si + HomeTeamColours], 0x64
        jz short .18
        mov al, [si + HomeTeamColours]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x28
        mov byte [bx + hmroster], 0x2
.18:
        cmp byte [si + AwayTeamColours], 0x64
        jz short .19
        mov al, [si + AwayTeamColours]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x28
        mov byte [bx + GamePlayerFlags], 0x2
.19:
        inc si
        cmp si, 0x8
        jl short .17
        mov bx, [bp + 0x6]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jz short .20
        dec bx
        jnz short .30
.20:
        mov si, GameTeamName1
        mov cx, [bp - 0x2]
        mov ax, 0x3a0b
        mov ds, ax
.21:
        mov ax, [ss:HomeTeamNum]
        cmp ax, strict word 0x15
        jz short .25
        ja short .22
        sub al, 0x3
        jz short .23
        sub al, 0x6
        jz short .24
.22:
        mov word [si], 0xffff
        jmp short .27
        db 0x90
.23:
        cmp word [si], 0x1e
        jmp short .26
        db 0x90
.24:
        cmp word [si], 0x21
        jmp short .26
        db 0x90
.25:
        cmp word [si], 0x1
.26:
        jnz short .27
        mov ax, [si]
        mov [GameTeamName1], ax
.27:
        mov ax, [ss:VisTeamNum]
        sub ax, strict word 0x4
        jz short .28
        mov word [si + 0x6], 0xffff
        jmp short .29
.28:
        cmp word [si + 0x6], 0x20
        jnz short .29
        mov ax, [si + 0x6]
        mov [GameTeamName2], ax
.29:
        inc si
        inc si
        cmp si, GameTeamName2
        jc short .21
        mov cx, DGROUP
        mov ds, cx
.30:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CreateGSummaryDb                                           2425:0374  94 PC
; Writes the gsummary.db header for a new game, then loads the teams.
;
; Takes 2 words of stack arguments. Calls LoadCupFinalSeries, GSummaryPath, CreateFileNormal,
; FatalError, WriteAtOffset, CloseHandlePtr, LoadGameTeams. Far routine (retf).
;-----------------------------------------------------------------------------
CreateGSummaryDb:
        enter 0x8, 0x0
        push di
        push si
        mov al, [bp + 0x8]
        mov [savedteam2], al
        mov word [curperiod], 0xffff
        mov cl, [bp + 0x6]
        mov [savedteam1], cl
        mov [gsumheader_b2], cl
        mov [gsumheader_b3], al
        mov al, [HomeTeamNum]
        mov [gsumheader_b4], al
        mov al, [VisTeamNum]
        mov [gsumheader_b5], al
        mov word [gsumcount], 0x1
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [gsumtail_goals1], al
        mov [gsumtail_shots1], al
        mov [gsumtail_goals2], al
        mov [gsumtail_shots2], al
        test byte [AnnouncerFlags], 0x2
        jnz short .1
        call 0x1E45:LoadCupFinalSeries
.1:
        push cs
        call GSummaryPath
        lea ax, [bp - 0x8]
        push ax
        push word gsummarypath
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word 0x5060
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp - 0x8]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x5063
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp - 0x8]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0x5066
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        push 0x0
        push cs
        call LoadGameTeams
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov es, [segWorkBuffer54]
        mov [es:HomePlStats_w2 + 0xC], ax
        mov [es:HomePlStats_w2 + 0xA], ax
        mov [es:HomePlStats_w2 + 0x8], ax
        mov [es:HomePlStats_w2 + 0x6], ax
        mov [es:HomePlStats_w2 + 0x4], ax
        mov [es:HomePlStats_w2 + 0x2], ax
        mov [es:HomePlStats_w2], ax
        mov [es:HomePlStats], ax
        mov word [bp - 0x4], 0x448
        mov word [bp - 0x6], 0x2
.5:
        mov word [bp - 0x2], 0x19
        mov ax, 0x3a0b
        mov es, ax
.6:
        mov bx, [bp - 0x4]
        push ds
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov si, 0x448
        mov ds, ax
        mov cx, 0x8
        rep movsw
        pop ds
        add word [bp - 0x4], 0x10
        dec word [bp - 0x2]
        jnz short .6
        dec word [bp - 0x6]
        jnz short .5
        mov ax, 0x3a0b
        mov es, ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:HomeGlStats_w4], ax
        mov [es:HomeGlStats_w2], ax
        mov [es:HomeGlStats], ax
        mov word [bp - 0x4], 0x768
        mov word [bp - 0x6], 0x2
.7:
        mov word [bp - 0x2], 0x3
        mov ax, 0x3a0b
        mov es, ax
.8:
        mov bx, [bp - 0x4]
        push ds
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov si, SpeechMemOff
        mov ds, ax
        movsw
        movsw
        movsw
        pop ds
        add word [bp - 0x4], 0x6
        dec word [bp - 0x2]
        jnz short .8
        dec word [bp - 0x6]
        jnz short .7
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ReadDbBlock                                                2425:04E0  94 PC
; Seeks and reads one block of a db file.
;
; Takes 13 words of stack arguments. Calls _lseek, FatalError, ReadAtOffset. Far routine (retf).
;-----------------------------------------------------------------------------
ReadDbBlock:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        push 0x0
        push 0x0
        push 0x0
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .1
        push word 0x5069
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .2
        push word 0x506b
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push 0x34
        push -0x1
        push -0x1
        push ds
        push word [bp + 0x12]
        push si
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x506d
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        mov si, [bp + 0x8]
        push 0x0
        push 0x0
        push 0x0
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .4
        push word 0x506f
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0x0
        mov bx, [bp + 0x12]
        push word [bx + 0x26]
        push word [bx + 0x24]
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .5
        push word 0x5071
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        push word [bp + 0x16]
        push -0x1
        push -0x1
        push ds
        push word [bp + 0x14]
        push si
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0x5073
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        mov si, [bp + 0xa]
        push 0x0
        push 0x0
        push 0x0
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .7
        push word 0x5075
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        push 0x0
        mov bx, [bp + 0x12]
        push word [bx + 0x2e]
        push word [bx + 0x2c]
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .8
        push word 0x5077
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        push word [bp + 0x1a]
        push -0x1
        push -0x1
        push ds
        push word [bp + 0x18]
        push si
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        push word 0x5079
        call 0x0F4A:FatalError
        add sp, 0x2
.9:
        cmp word [bp + 0x1e], 0x0
        jnz short .10
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
.10:
        mov si, [bp + 0xc]
        push 0x0
        push 0x0
        push 0x0
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .11
        push word 0x507b
        call 0x0F4A:FatalError
        add sp, 0x2
.11:
        push 0x0
        mov bx, [bp + 0x12]
        push word [bx + 0x2a]
        push word [bx + 0x28]
        push si
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .12
        push word 0x507d
        call 0x0F4A:FatalError
        add sp, 0x2
.12:
        push word [bp + 0x1e]
        push -0x1
        push -0x1
        push ds
        push word [bp + 0x1c]
        push si
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        push word 0x507f
        call 0x0F4A:FatalError
        add sp, 0x2
.13:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; OpenPlayerDbs                                              2425:068A  94 PC
; Opens the key, att, season and career dbs.
;
; Takes 7 words of stack arguments. Calls _sprintf, _dos_findfirst, FatalError, OpenReadShared. Far
; routine (retf).
;-----------------------------------------------------------------------------
OpenPlayerDbs:
        enter 0x4c, 0x0
        push si
        mov si, [bp + 0x10]
        push strict word str_Key
        push si
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x4c]
        push ax
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x5085
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push word [bp + 0x8]
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word 0x5087
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push strict word str_Att
        push si
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x4c]
        push ax
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x508d
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push word [bp + 0xa]
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0x508f
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push strict word str_Season_2
        push si
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x4c]
        push ax
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x5098
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        push word [bp + 0xc]
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0x509a
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        test byte [bp + 0x6], 0x6
        jz short .7
        mov bx, [bp + 0x12]
        mov word [bx], 0x0
        pop si
        leave
        retf
        db 0x90
.7:
        push strict word str_Career_2
        push si
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x4c]
        push ax
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push word 0x50a3
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        push word [bp + 0xe]
        lea ax, [bp - 0x20]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        push word 0x50a5
        call 0x0F4A:FatalError
        add sp, 0x2
.9:
        mov bx, [bp + 0x12]
        mov word [bx], 0x28
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; BuildTeamRoster                                            2425:07EA  94 PC
; Fills the player records of one team from the dbs.
;
; Takes 7 words of stack arguments. Calls ReadDbBlock. Far routine (retf).
;-----------------------------------------------------------------------------
BuildTeamRoster:
        enter 0xfe, 0x0
        push di
        push si
        mov bx, [bp + 0x12]
        imul ax, bx, word 0xc8
        add ax, plstatsoff
        mov [bp - 0x2], ax
        imul ax, bx, word 0x1f4
        add ax, strict word 0x0
        mov [bp - 0xa], ax
        imul ax, bx, word 0x460
        add ax, hmroster
        mov [bp - 0x4], ax
        imul ax, bx, word 0xd6
        add ax, hmtmpdst
        mov [bp - 0xc], ax
        imul ax, bx, word 0x2e8
        add ax, GamePlayerNames
        mov [bp - 0x6], ax
        mov word [bp - 0xe], 0x19
.1:
        mov bx, [bp - 0x6]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [bp - 0xfa], ax
        mov [bp - 0xf8], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .2
        jmp near .13
.2:
        push word [bp + 0x10]
        lea ax, [bp - 0x5c]
        push ax
        push 0x30
        lea ax, [bp - 0x8c]
        push ax
        push 0x14
        lea ax, [bp - 0x34]
        push ax
        lea ax, [bp - 0xc0]
        push ax
        push word [bp - 0xf8]
        push word [bp - 0xfa]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push cs
        call ReadDbBlock
        add sp, 0x1a
        mov al, [bp - 0xbf]
        mov bx, [bp - 0x4]
        mov [bx + 0x6], al
        mov al, [bp - 0xbe]
        mov bx, [bp - 0x4]
        mov [bx + 0x7], al
        mov bx, [bp - 0x4]
        lea di, [bp - 0xbd]
        lea si, [bx + 0x8]
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
        mov bx, [bp - 0x4]
        lea di, [bp - 0xad]
        lea si, [bx + 0x18]
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
        cmp [bp + 0x6], ax
        jz short .5
        cmp word [bp + 0x6], 0x2
        jz short .5
        mov bx, [bp - 0xc]
        mov bx, [bx]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .3
        mov al, 0x5
        jmp short .4
        db 0x90
.3:
        mov si, 0x50a8
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, 1
        db 0x2B, 0xF0                           ; insn: sub si, ax
        mov al, [si]
.4:
        mov si, [bp - 0x4]
        mov [si], al
        jmp short .10
.5:
        mov al, [savedteam1]
        cmp [bp - 0x66], al
        jna short .7
.6:
        mov al, 0x1
        jmp short .9
.7:
        mov al, [savedteam1]
        cmp [bp - 0x66], al
        jc short .8
        mov al, [savedteam2]
        cmp [bp - 0x65], al
        ja short .6
.8:
        mov al, 0x3
.9:
        mov bx, [bp - 0x4]
        mov [bx], al
.10:
        imul ax, [bp + 0x12], 0x19
        add ax, [bp - 0x8]
        mov bx, [bp - 0xa]
        mov es, [segWorkBuffer55]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        lea si, [bp - 0x34]
        mov cx, 0xa
        rep movsw
        test byte [bp + 0x6], 0x6
        jnz short .14
        test byte [AnnouncerFlags], 0x2
        jz short .12
        mov ax, [bp - 0x38]
        mov bx, [bp - 0x2]
        mov [bx], ax
        add ax, [bp - 0x36]
        mov bx, [bp - 0x2]
        mov [bx + 0x2], ax
        mov ax, [bp - 0x8a]
        mov bx, [bp - 0x2]
        mov [bx + 0x4], ax
        add ax, [bp - 0x88]
.11:
        mov bx, [bp - 0x2]
        mov [bx + 0x6], ax
        jmp short .14
        db 0x90
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov bx, [bp - 0x2]
        mov [bx + 0x2], ax
        mov ax, [bp - 0x78]
        mov bx, [bp - 0x2]
        mov [bx + 0x4], ax
        add ax, [bp - 0x76]
        jmp short .11
        db 0x90
.13:
        mov bx, [bp - 0x4]
        mov byte [bx], 0x0
.14:
        add word [bp - 0x2], 0x8
        add word [bp - 0xa], 0x14
        add word [bp - 0x4], 0x28
        add word [bp - 0xc], 0x2
        add word [bp - 0x6], 0x4
        dec word [bp - 0xe]
        jz short .15
        jmp near .1
.15:
        mov bx, [bp + 0x12]
        imul ax, bx, 0x30
        add ax, 0x3e8
        mov [bp - 0xa], ax
        imul ax, bx, word 0x460
        add ax, hmroster + 0x3e8
        mov [bp - 0x2], ax
        imul ax, bx, word 0xd6
        add ax, hmshots + 0x96
        mov [bp - 0xc], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, 1
        db 0x03, 0xC3                           ; insn: add ax, bx
        shl ax, 1
        add ax, GameTeamName1
        mov [bp - 0xe], ax
        imul ax, bx, word 0x2e8
        add ax, GamePlayerNames + 0x64
        mov [bp - 0x4], ax
        mov word [bp - 0x10], 0x3
.16:
        mov bx, [bp - 0x4]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [bp - 0xfe], ax
        mov [bp - 0xfc], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .17
        jmp near .28
.17:
        push 0x0
        push 0x0
        push 0x36
        lea ax, [bp - 0xf6]
        push ax
        push 0x10
        lea ax, [bp - 0x20]
        push ax
        lea ax, [bp - 0xc0]
        push ax
        push word [bp - 0xfc]
        push word [bp - 0xfe]
        push 0x0
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push cs
        call ReadDbBlock
        add sp, 0x1a
        mov al, [bp - 0xbf]
        mov bx, [bp - 0x2]
        mov [bx + 0x6], al
        mov al, [bp - 0xbe]
        mov bx, [bp - 0x2]
        mov [bx + 0x7], al
        mov bx, [bp - 0x2]
        lea di, [bp - 0xbd]
        lea si, [bx + 0x8]
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
        mov bx, [bp - 0x2]
        lea di, [bp - 0xad]
        lea si, [bx + 0x18]
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
        cmp [bp + 0x6], ax
        jz short .18
        cmp word [bp + 0x6], 0x1
        jnz short .19
.18:
        mov al, [bp - 0xbf]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [segWorkBuffer56]
        mov bx, [bp - 0xe]
        mov [es:bx], ax
.19:
        cmp word [bp + 0x6], 0x0
        jz short .22
        cmp word [bp + 0x6], 0x2
        jz short .22
        mov bx, [bp - 0xc]
        mov bx, [bx]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .20
        mov al, 0x5
        jmp short .21
.20:
        mov si, 0x50a8
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, 1
        db 0x2B, 0xF0                           ; insn: sub si, ax
        mov al, [si]
.21:
        mov si, [bp - 0x2]
        mov [si], al
        jmp short .27
.22:
        mov al, [savedteam1]
        cmp [bp - 0xc8], al
        jna short .24
.23:
        mov al, 0x1
        jmp short .26
        db 0x90
.24:
        mov al, [savedteam1]
        cmp [bp - 0xc8], al
        jc short .25
        mov al, [savedteam2]
        cmp [bp - 0xc7], al
        ja short .23
.25:
        mov al, 0x3
.26:
        mov bx, [bp - 0x2]
        mov [bx], al
.27:
        mov bx, [bp - 0xa]
        mov es, [segWorkBuffer57]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        lea si, [bp - 0x20]
        mov cx, 0x8
        rep movsw
        jmp short .29
.28:
        mov bx, [bp - 0x2]
        mov byte [bx], 0x0
.29:
        add word [bp - 0xa], 0x10
        add word [bp - 0x2], 0x28
        add word [bp - 0xc], 0x2
        add word [bp - 0xe], 0x2
        add word [bp - 0x4], 0x4
        dec word [bp - 0x10]
        jz short .30
        jmp near .16
.30:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; GSummaryPath                                               2425:0B20  94 PC
; Builds the gsummary.db path.
;
; Calls _fstrcpy.
;-----------------------------------------------------------------------------
GSummaryPath:
        push di
        push si
        mov byte [gsummarypath], 0x0
        mov es, [segTeamChoiceText53]
        cmp byte [es:CurLeagueName], 0x0
        jz short .1
        push word 0x3701
        push strict word CurLeagueName
        push ds
        push strict word gsummarypath
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, 0x50b8
        mov si, gsummarypath
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
.1:
        mov di, str_GsummaryDb_3
        mov si, gsummarypath
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
