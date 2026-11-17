; Sets up the stats menus and their season titles (STATS.OVL)

;-----------------------------------------------------------------------------
; SetupStatsMenus                                            1E45:0000  94 PC
; Fills the stats menu items' far routine pointers for the chosen context and season.
;
; Takes 1 word of stack arguments. Calls CopyStrNFar. Far routine (retf).
;-----------------------------------------------------------------------------
SetupStatsMenus:
        enter 0x14, 0x0
        push di
        push si
        mov cx, [bp + 0x6]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnz short .3
        mov es, [segDbFiles15]
        mov al, [es:postate_name]
        mov [bp - 0x8], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .1
        mov es, [segDbFiles16]
        cmp byte [es:lgstate_name], 0x0
        jnz short .3
.1:
        cmp byte [bp - 0x8], 0x0
        jz short .2
        mov cx, 0x2
        jmp short .3
        db 0x90
.2:
        mov es, [segDbFiles16]
        cmp byte [es:lgstate_name], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cl, 0xfe
        add cx, 0x3
.3:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        dec ax
        jnz short .4
        jmp near .16
.4:
        dec ax
        jnz short .5
        jmp near .19
.5:
        dec ax
        jnz short .6
        jmp near .23
.6:
        mov si, [bp - 0x4]
        jmp near .30
.7:
        mov es, [SeasonTitleSegs]
        mov word [es:0xde], strict word OverlayThunks
        mov word [es:0xe0], 0x1b35
        mov word [es:0xf4], strict word StatsSelLeaguePlayoffsThunk
        mov word [es:0xf6], 0x1b35
        mov word [es:0x120], strict word StatsSelPlayoffModeThunk
        mov word [es:0x122], 0x1b35
        mov ax, 0x29
        mov cx, 0x384b
        mov [es:0xda], ax
        mov [es:0xdc], cx
        mov [bp - 0xc], ax
        mov [bp - 0xa], cx
        mov dx, 0x3d
        mov bx, 0x384b
        mov [bp - 0x10], dx
        mov [bp - 0xe], bx
        mov [es:0xf0], dx
        mov [es:0xf2], bx
        mov dx, 0x5b
        mov bx, 0x384b
        mov [bp - 0x14], dx
        mov [bp - 0x12], bx
        mov [es:0x11c], dx
        mov [es:0x11e], bx
        mov es, cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [es:bx], 0x1
        jnz short .9
        mov byte [es:bx], 0x1
        mov al, 0x2
        les bx, [bp - 0x14]
        mov [es:bx], al
        les bx, [bp - 0x10]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jz short .8
        mov word [statsmenusel], 0x0
.8:
        mov word [statscontext], 0x0
        jmp short .11
.9:
        les bx, [bp - 0x10]
        cmp byte [es:bx], 0x1
        jnz short .12
        mov byte [es:bx], 0x1
        mov al, 0x2
        les bx, [bp - 0x14]
        mov [es:bx], al
        les bx, [bp - 0xc]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .10
        mov word [statsmenusel], 0x0
.10:
        mov word [statscontext], 0x1
.11:
        push 0x1f
        push word 0x3415
        push strict word lgstate_name
        jmp short .14
.12:
        les bx, [bp - 0x14]
        cmp byte [es:bx], 0x1
        jnz short .15
        mov byte [es:bx], 0x1
        mov al, 0x2
        les bx, [bp - 0x10]
        mov [es:bx], al
        les bx, [bp - 0xc]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .13
        mov word [statsmenusel], 0x0
.13:
        mov word [statscontext], 0x1
        push 0x1f
        push word 0x3415
        push strict word postate_name
.14:
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.15:
        mov si, 0x7
        jmp near .30
.16:
        mov es, [SeasonTitleSegs]
        cmp byte [es:0x0], 0x2
        jnz short .18
        cmp byte [es:0x13], 0x2
        jnz short .18
        mov byte [es:0x0], 0x1
        mov al, 0x2
        mov [es:0x5b], al
        mov [es:0x3d], al
        mov [es:0x29], al
        mov [es:0x13], al
        mov word [statsseason], 0x0
        cmp word [statscontext], 0x0
        jz short .17
        mov word [statsmenusel], 0x0
.17:
        mov word [statscontext], 0x0
        push 0x1f
        push word 0x3415
        push strict word exhstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.18:
        mov si, 0x2
        jmp near .30
        db 0x90
.19:
        mov es, [SeasonTitleSegs]
        mov word [es:0xde], strict word StatsSelPlayoffModeThunk
        mov word [es:0xe0], 0x1b35
        mov ax, 0x5b
        mov cx, 0x384b
        mov [bp - 0x14], ax
        mov [bp - 0x12], cx
        mov [es:0xda], ax
        mov [es:0xdc], cx
        mov bx, 0x29
        mov [bp - 0xc], bx
        mov [bp - 0xa], es
        cmp byte [es:bx], 0x1
        jz short .20
        cmp byte [es:0x3d], 0x1
        jz short .20
        les bx, [bp - 0x14]
        cmp byte [es:bx], 0x1
        jnz short .22
.20:
        les bx, [bp - 0x14]
        mov byte [es:bx], 0x1
        mov al, 0x2
        mov es, [SeasonTitleSegs]
        mov [es:0x3d], al
        les bx, [bp - 0xc]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .21
        mov word [statsmenusel], 0x0
.21:
        mov word [statscontext], 0x1
        push 0x1f
        push word 0x3415
        push strict word postate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.22:
        mov si, 0x4
        jmp near .30
        db 0x90
.23:
        mov es, [SeasonTitleSegs]
        mov word [es:0xde], strict word OverlayThunks
        mov word [es:0xe0], 0x1b35
        mov word [es:0xf4], strict word StatsSelLeaguePlayoffsThunk
        mov word [es:0xf6], 0x1b35
        mov ax, 0x29
        mov cx, 0x384b
        mov [bp - 0xc], ax
        mov [bp - 0xa], cx
        mov [es:0xda], ax
        mov [es:0xdc], cx
        mov ax, 0x3d
        mov cx, 0x384b
        mov [bp - 0x10], ax
        mov [bp - 0xe], cx
        mov [es:0xf0], ax
        mov [es:0xf2], cx
        mov bx, 0x5b
        mov [bp - 0x14], bx
        mov [bp - 0x12], es
        cmp byte [es:bx], 0x1
        jz short .26
        les bx, [bp - 0xc]
        cmp byte [es:bx], 0x1
        jz short .26
        les bx, [bp - 0x10]
        cmp byte [es:bx], 0x1
        jz short .24
        jmp near .29
.24:
        mov byte [es:bx], 0x1
        mov al, 0x2
        les bx, [bp - 0x14]
        mov [es:bx], al
        les bx, [bp - 0xc]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .25
        mov word [statsmenusel], 0x0
.25:
        mov word [statscontext], 0x1
        jmp short .28
        db 0x90
.26:
        les bx, [bp - 0xc]
        mov byte [es:bx], 0x1
        mov al, 0x2
        les bx, [bp - 0x14]
        mov [es:bx], al
        les bx, [bp - 0x10]
        mov [es:bx], al
        mov es, [SeasonTitleSegs]
        mov [es:0x13], al
        mov [es:0x0], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jz short .27
        mov word [statsmenusel], 0x0
.27:
        mov word [statscontext], 0x0
.28:
        push 0x1f
        push word 0x3415
        push strict word lgstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.29:
        mov si, 0x5
.30:
        cmp si, 0x4
        jnz short .31
        mov es, [SeasonTitleSegs]
        mov word [es:0x94], 0x78
        mov byte [es:0x88], 0x0
        jmp short .32
        db 0x90
.31:
        mov es, [SeasonTitleSegs]
        mov word [es:0x94], 0x9b
        mov byte [es:0x88], 0x2d
.32:
        mov cx, 0x8
        db 0x0B, 0xF6                           ; insn: or si, si
        jng short .34
        mov bx, 0x96
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov [bp - 0x4], si
        mov ax, 0x384b
        mov ds, ax
.33:
        mov [bx], cx
        mov ax, [SeasonTitlePtr]
        lea di, [bx - 0x2]
        mov [di], ax
        add bx, 0x16
        add cx, 0x8
        dec si
        jnz short .33
        mov si, [bp - 0x4]
        mov ax, DGROUP
        mov ds, ax
.34:
        mov es, [SeasonTitleSegs]
        imul bx, si, 0x16
        inc word [es:bx + 0x80]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov es, [segTeamChoiceText48]
        mov [es:TradeStatsMenuBar + 0x2A], al
        mov es, [segMenuText22]
        mov [es:GoalieStatsMenuBar + 0xDA], al
        mov es, [segMenuText23]
        mov [es:GoalieStatsMenuBar + 0x2A], al
        mov es, [segMenuText24]
        mov [es:SkaterStatsMenuBar + 0x2A], al
        mov es, [segMenuText25]
        mov [es:TeamStatsMenuBar + 0x2A], al
        mov es, [segMenuText26]
        mov [es:StandingsMenuBar2 + 0x2A], al
        mov es, [segMenuText27]
        mov [es:StandingsRosterMenuBar + 0x40], al
        mov es, [segMenuText28]
        mov [es:standingsmenubar + 0x40], al
        mov es, [segMenuText29]
        mov [es:PlayerStatsMenuBar + 0x2A], al
        mov es, [segMenuText30]
        mov [es:DeskMenuBar + 0x3C6], al
        mov es, [segMenuText31]
        mov [es:TeamNameTemplate + 0xA7F], al
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; BuildSeasonTitle                                           1E45:047C  94 PC
; '" Season' / '" Play-Offs' / '" Season Play-Offs' title strings.
;
; Calls SplitFileExt, _fstrcpy. Far routine (retf).
;-----------------------------------------------------------------------------
BuildSeasonTitle:
        enter 0x8, 0x0
        push si
        mov bx, 0x64
        mov es, [segDbFiles15]
        mov [bp - 0x4], bx
        mov [bp - 0x2], es
        cmp byte [es:bx], 0x0
        jz short .1
        push es
        push bx
        push cs
        call SplitFileExt
        add sp, 0x4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov es, [segDbFiles15]
        db 0x26, 0xC6, 0x87, 0x64, 0x00, 0x00   ; insn: mov byte [es:bx + 0x64], 0x0
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word 0x384b
        push strict word str_WwwwwwwwPlayOffs
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x384b
        push strict word str_PlayOffs
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, strict word 0x5e
        push word 0x384b
        push si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segDbFiles15]
        db 0x26, 0xC6, 0x84, 0x64, 0x00, 0x2E   ; insn: mov byte [es:si + 0x64], 0x2e
.1:
        mov bx, 0xc6
        mov es, [segDbFiles16]
        mov [bp - 0x8], bx
        mov [bp - 0x6], es
        cmp byte [es:bx], 0x0
        jz short .2
        push es
        push bx
        push cs
        call SplitFileExt
        add sp, 0x4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov es, [segDbFiles16]
        mov byte [es:bx + lgstate_name], 0x0
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word 0x384b
        push strict word str_WwwwwwwwSeason
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word 0x384b
        push strict word str_WwwwwwwwSeasonPlayOffs
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x384b
        push strict word str_Season
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, strict word 0x2c
        push word 0x384b
        push si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x384b
        push strict word str_SeasonPlayOffs
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, strict word 0x40
        push word 0x384b
        push si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [segDbFiles16]
        mov byte [es:si + lgstate_name], 0x2e
.2:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; SplitFileExt                                               1E45:0576  94 PC
; Cuts a file name at its '.'
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
SplitFileExt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds bx, [bp + 0x6]
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        cmp byte [bx], 0x0
        jz short .2
.1:
        cmp byte [bx], 0x2e
        jz short .2
        inc cx
        inc bx
        cmp byte [bx], 0x0
        jnz short .1
.2:
        mov ax, DGROUP
        mov ds, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        leave
        retf

;-----------------------------------------------------------------------------
; SetStatsMenuText                                           1E45:0598  94 PC
; Switch on the context (0..5) choosing the menu text pointers.
;
; Takes 2 words of stack arguments.
;-----------------------------------------------------------------------------
SetStatsMenuText:
        enter 0xa, 0x0
        mov ax, [bp + 0x6]
        cmp ax, strict word 0x5
        ja short SetStatsMenuTextJumpTable.1
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x5ac]
SetStatsMenuTextJumpTable:                      ; jump table of SetStatsMenuText: 6 case targets
        dw .2
        dw .3
        dw .4
        dw .5
        dw .6
        dw .7
.1:
        mov bx, [bp - 0x2]
        mov cx, [bp - 0xa]
        jmp short .8
.2:
        mov ax, 0x90c
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x46
        jmp short .8
.3:
        mov ax, 0x92b
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x3f
        jmp short .8
.4:
        mov ax, 0x91b
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x4d
        jmp short .8
.5:
        mov ax, 0x938
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x50
        jmp short .8
.6:
        mov ax, 0x948
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x51
        jmp short .8
.7:
        mov ax, 0x95a
        mov dx, 0x3448
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x8], dx
        mov bx, 0x6b
.8:
        mov ax, [bp - 0x8]
        mov es, [segMenuText32]
        mov [es:standingsmenubar + 0xA2], cx
        mov [es:standingsmenubar + 0xA4], ax
        mov es, [segMenuText33]
        mov [es:standingsmenubar + 0x60], cx
        mov [es:standingsmenubar + 0x62], ax
        mov es, [segMenuText34]
        mov [es:PlayerStatsMenuBar + 0x60], cx
        mov [es:PlayerStatsMenuBar + 0x62], ax
        mov es, [segMenuText35]
        mov [es:PlayerStatsMenuBar + 0x34], cx
        mov [es:PlayerStatsMenuBar + 0x36], ax
        mov es, [segMenuText34]
        mov [es:PlayerStatsMenuBar + 0x5C], bx
        mov es, [segMenuText35]
        mov [es:PlayerStatsMenuBar + 0x30], bx
        cmp bx, 0x4f
        jnl short .9
        mov bx, 0x4f
.9:
        mov es, [segMenuText32]
        mov [es:standingsmenubar + 0x9E], bx
        mov [es:standingsmenubar + 0x88], bx
        mov [es:standingsmenubar + 0x72], bx
        mov es, [segMenuText33]
        mov [es:standingsmenubar + 0x5C], bx
        mov [es:standingsmenubar + 0x46], bx
