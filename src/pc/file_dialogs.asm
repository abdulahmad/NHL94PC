; Load and save dialogs for saved games and settings files (MENUS.OVL)
; The first bytes finish the last routine of jersey_shape.asm.
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MenuOpenSaved                                              23A3:0004  94 PC
; Open a saved game (gsummary.db, game.sav)
;
; Calls ScanSavedGames, VgaCopyBytes, DrawFileDlg, DrawFileDlgTabs, CopyPlane, RunFileDlg,
; BuildSeasonTitleThunk, SetupStatsMenusThunk and others. Far routine (retf).
;-----------------------------------------------------------------------------
MenuOpenSaved:
        enter 0x34, 0x0
        push di
        push si
        push cs
        call ScanSavedGames
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push cs
        call DrawFileDlg
        push cs
        call DrawFileDlgTabs
        call 0x0FEF:CopyPlane
        push word 0x3f00
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        push cs
        call RunFileDlg
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x1B35:BuildSeasonTitleThunk
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        jmp near .26
.1:
        mov ax, [fdlgtab]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        dec ax
        jnz short .2
        jmp near .17
.2:
        dec ax
        jnz short .3
        jmp near .23
.3:
        jmp near .26
        db 0x90
.4:
        push 0x1
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov bx, [lgfiles]
        shl bx, byte 0x2
        push word [bx + lgfilenames]
        push word [bx + savednames2]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, 0xe66
        lea si, [bp - 0x34]
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
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0xe6b
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        lea ax, [bp - 0x6]
        push ax
        push strict word str_GsummaryDb_4
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0xe7a
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push 0xc
        push 0x0
        push 0x62
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0xe7d
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        push 0xc
        push -0x1
        push -0x1
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push word 0xe80
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        mov word [bp - 0x8], 0x0
        mov bx, [bp - 0xe]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .12
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp - 0x2], bx
.9:
        push 0xc
        push -0x1
        push -0x1
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        push word 0xe83
        call 0x0F4A:FatalError
        add sp, 0x2
.10:
        push 0xc
        push -0x1
        push -0x1
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        push word 0xe86
        call 0x0F4A:FatalError
        add sp, 0x2
.11:
        dec si
        jnz short .9
.12:
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word otherscoreaway
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        push word 0xe89
        call 0x0F4A:FatalError
        add sp, 0x2
.13:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word otherscorehome
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        push word 0xe8c
        call 0x0F4A:FatalError
        add sp, 0x2
.14:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word otherscoresb
        push word [bp - 0x4]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        push word 0xe8f
        call 0x0F4A:FatalError
        add sp, 0x2
.15:
        mov es, [segDbFiles1]
        and byte [es:0x55], 0x7f
        lea ax, [bp - 0x4]
        push ax
        call 0x2E70:MenuNewExhibition
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.16:
        push 0x0
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
.17:
        push word 0x3415
        push strict word postate_name
        push word 0x3415
        push strict word postate_name
        push ds
        push strict word str_Db_6
        push ds
        push strict word str_Sav_5
        push ds
        push strict word str_Gsummary_5
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .18
        push word 0xea4
        call 0x0F4A:FatalError
        add sp, 0x2
.18:
        push 0x2
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov bx, [savedsel3]
        shl bx, byte 0x2
        push word [bx + savednames3seg]
        push word [bx + savednames3]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_PoGameSav
        lea si, [bp - 0x34]
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
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        push word 0xeb4
        call 0x0F4A:FatalError
        add sp, 0x2
.19:
        mov es, [segDbFiles2]
        and byte [es:0xb7], 0x7f
        lea ax, [bp - 0x4]
        push ax
        call 0x1B35:PlayoffModeLoopThunk
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, [segDbFiles2]
        test byte [es:0xb7], 0x80
.20:
        jz short .21
        jmp near .16
.21:
        mov es, [segDbFiles3]
        cmp word [es:0x126], 0x1
        jz short .22
        jmp near .16
.22:
        lea ax, [bp - 0x34]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
        jmp near .16
.23:
        push word 0x3415
        push strict word lgstate_name
        push word 0x3415
        push strict word lgstate_name
        push ds
        push strict word str_Db_5
        push ds
        push strict word str_Sav_4
        push ds
        push strict word str_Gsummary_4
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        push word 0xec9
        call 0x0F4A:FatalError
        add sp, 0x2
.24:
        push 0x3
        call 0x1B35:SetupStatsMenusThunk
        add sp, 0x2
        mov bx, [savedsel1]
        shl bx, byte 0x2
        push word [bx + savednames1seg]
        push word [bx + savednames1]
        lea ax, [bp - 0x34]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_LpGameSav
        lea si, [bp - 0x34]
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
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x34]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .25
        push word 0xed9
        call 0x0F4A:FatalError
        add sp, 0x2
.25:
        mov es, [segDbFiles4]
        and byte [es:0x119], 0x7f
        lea ax, [bp - 0x4]
        push ax
        call 0x1B35:MenuNextLeagueGameThunk
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, [segDbFiles4]
        test byte [es:0x119], 0x80
        jmp near .20
.26:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawFileDlgTabs                                            23A3:03FE  94 PC
; File dialog tabs.
;
; Calls WaitRetraceEnd, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
DrawFileDlgTabs:
        enter 0x60, 0x0
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
.1:
        mov al, 0x3f
        mov [bp + si - 0x5e], al
        mov [bp + si - 0x5f], al
        mov [bp + si - 0x60], al
        mov al, 0x17
        mov [bp + si - 0x46], al
        mov [bp + si - 0x47], al
        mov [bp + si - 0x48], al
        mov al, 0x3f
        mov [bp + si - 0x2e], al
        mov [bp + si - 0x2f], al
        mov [bp + si - 0x30], al
        mov al, 0x2a
        mov [bp + si - 0x16], al
        mov [bp + si - 0x17], al
        mov [bp + si - 0x18], al
        add si, 0x3
        cmp si, 0x18
        jl short .1
        cmp word [fdlgtab], 0x0
        jnl short .2
        mov al, 0x17
        mov [bp - 0x1f], al
        mov [bp - 0x20], al
        mov [bp - 0x21], al
        mov [bp - 0x1c], al
        mov [bp - 0x1d], al
        mov [bp - 0x1e], al
        mov [bp - 0x19], al
        mov [bp - 0x1a], al
        mov [bp - 0x1b], al
        mov [bp - 0x25], al
        mov [bp - 0x26], al
        mov [bp - 0x27], al
        mov [bp - 0x28], al
        mov [bp - 0x29], al
        mov [bp - 0x2a], al
        jmp short .6
        db 0x90
.2:
        test byte [fdlgflags], 0x80
        jnz short .3
        mov al, 0x17
        mov [bp - 0x19], al
        mov [bp - 0x1a], al
        mov [bp - 0x1b], al
.3:
        test byte [fdlgflags], 0x40
        jnz short .4
        mov al, 0x17
        mov [bp - 0x1c], al
        mov [bp - 0x1d], al
        mov [bp - 0x1e], al
.4:
        test byte [fdlgflags], 0x20
        jnz short .5
        mov al, 0x17
        mov [bp - 0x1f], al
        mov [bp - 0x20], al
        mov [bp - 0x21], al
.5:
        mov al, 0x22
        mov [bp - 0x16], al
        mov [bp - 0x17], al
        mov [bp - 0x18], al
        mov [bp - 0x13], al
        mov [bp - 0x14], al
        mov [bp - 0x15], al
        mov al, 0x17
        mov si, [fdlgtab]
        add si, 0x5
        db 0x8B, 0xCE                           ; insn: mov cx, si
        shl si, 1
        db 0x03, 0xF1                           ; insn: add si, cx
        mov [bp + si - 0x5e], al
        mov [bp + si - 0x5f], al
        mov [bp + si - 0x60], al
        mov al, 0x3f
        lea si, [si + 0x18]
        mov [bp + si - 0x5e], al
        mov [bp + si - 0x5f], al
        mov [bp + si - 0x60], al
.6:
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x60]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; CmpFileNames                                               23A3:04FC  94 PC
; Qsort comparator of file names.
;
; Takes 2 words of stack arguments. Calls _fstrcmp. Far routine (retf).
;-----------------------------------------------------------------------------
CmpFileNames:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x8]
        push word [bx + 0x2]
        push word [bx]
        mov bx, [bp + 0x6]
        push word [bx + 0x2]
        push word [bx]
        call 0x0000:_fstrcmp
        leave
        retf

;-----------------------------------------------------------------------------
; ScanSavedGames                                             23A3:0516  94 PC
; Finds *.po and *.nhl saves.
;
; Calls _dos_findfirst, _dos_findnext, _qsort. Far routine (retf).
;-----------------------------------------------------------------------------
ScanSavedGames:
        enter 0x2c, 0x0
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [savedcount1], di
        lea ax, [bp - 0x2c]
        push ax
        push 0x10
        push word 0xee2
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .6
.1:
        mov ax, 0x3a0b
        mov es, ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        add ax, 0xa6d8
        mov bx, [savedcount1]
        shl bx, byte 0x2
        mov [bx + savednames1], ax
        mov [bx + savednames1seg], es
        db 0x2B, 0xF6                           ; insn: sub si, si
.2:
        cmp byte [bp + si - 0xe], 0x0
        jz short .3
        cmp byte [bp + si - 0xe], 0x2e
        jz short .3
        mov al, [bp + si - 0xe]
        mov [es:di + SavedGameNames], al
        inc di
        inc si
        cmp si, 0x8
        jl short .2
.3:
        mov byte [es:di + SavedGameNames], 0x0
        inc di
        inc word [savedcount1]
        cmp word [savedcount1], 0x20
        jnl short .4
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
.4:
        push word 0x23a3
        push strict word CmpFileNames
        push 0x4
        push word [savedcount1]
        push word 0xc05c
        call 0x0000:_qsort
        add sp, 0xa
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [savedtop1], ax
        mov [savedsel1], ax
        cmp word [savedcount1], 0x6
        jl short .5
        mov word [savedrows1], 0x5
        jmp short .6
.5:
        mov ax, [savedcount1]
        dec ax
        mov [savedrows1], ax
.6:
        mov word [savedcount3], 0x0
        lea ax, [bp - 0x2c]
        push ax
        push 0x10
        push strict word str_Po_3
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        jmp near .12
.7:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        add ax, 0xa6d8
        mov bx, [savedcount3]
        shl bx, byte 0x2
        mov [bx + savednames3], ax
        mov word [bx + savednames3seg], 0x3a0b
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, 0x3a0b
        mov es, ax
.8:
        cmp byte [bp + si - 0xe], 0x0
        jz short .9
        cmp byte [bp + si - 0xe], 0x2e
        jz short .9
        mov al, [bp + si - 0xe]
        mov [es:di + SavedGameNames], al
        inc di
        inc si
        cmp si, 0x8
        jl short .8
.9:
        mov byte [es:di + SavedGameNames], 0x0
        inc di
        inc word [savedcount3]
        cmp word [savedcount3], 0x20
        jnl short .10
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
.10:
        push word 0x23a3
        push strict word CmpFileNames
        push 0x4
        push word [savedcount3]
        push word 0xc16c
        call 0x0000:_qsort
        add sp, 0xa
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [savedtop3], ax
        mov [savedsel3], ax
        cmp word [savedcount3], 0x6
        jl short .11
        mov word [savedrows3], 0x5
        jmp short .12
        db 0x90
.11:
        mov ax, [savedcount3]
        dec ax
        mov [savedrows3], ax
.12:
        mov word [savedcount2], 0x0
        lea ax, [bp - 0x2c]
        push ax
        push 0x0
        push strict word str_Nhl_6
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        jmp near .18
.13:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        add ax, 0xa6d8
        mov bx, [savedcount2]
        shl bx, byte 0x2
        mov [bx + savednames2], ax
        mov word [bx + lgfilenames], 0x3a0b
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, 0x3a0b
        mov es, ax
.14:
        cmp byte [bp + si - 0xe], 0x0
        jz short .15
        cmp byte [bp + si - 0xe], 0x2e
        jz short .15
        mov al, [bp + si - 0xe]
        mov [es:di + SavedGameNames], al
        inc di
        inc si
        cmp si, 0x8
        jl short .14
.15:
        mov byte [es:di + SavedGameNames], 0x0
        inc di
        inc word [savedcount2]
        cmp word [savedcount2], 0x20
        jnl short .16
        lea ax, [bp - 0x2c]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
.16:
        push word 0x23a3
        push strict word CmpFileNames
        push 0x4
        push word [savedcount2]
        push word 0xc0e4
        call 0x0000:_qsort
        add sp, 0xa
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [savedtop2], ax
        mov [lgfiles], ax
        cmp word [savedcount2], 0x6
        jl short .17
        mov word [savedrows2], 0x5
        pop si
        pop di
        leave
        retf
        db 0x90
.17:
        mov ax, [savedcount2]
        dec ax
        mov [savedrows2], ax
.18:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PrintTextCopy                                              23A3:072A  94 PC
; DrawText of a copied string.
;
; Takes 4 words of stack arguments. Calls DrawText. Far routine (retf).
;-----------------------------------------------------------------------------
PrintTextCopy:
        enter 0x40, 0x0
        push di
        push si
        lds di, [bp + 0x6]
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp byte [di], 0x0
        jz short .2
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov al, [bx + si]
        mov [bp + si - 0x40], al
        inc si
        cmp byte [bx + si], 0x0
        jnz short .1
.2:
        mov ax, DGROUP
        mov ds, ax
        mov byte [bp + si - 0x40], 0x0
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x40]
        push ax
        call 0x0FEF:DrawText
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawFileDlg                                                23A3:0766  94 PC
; Dialogbx frame.
;
; Calls UseOtherPage, BuildPathFar, LoadPackedHeader, FindFarMsg, DrawRleTransFastAt, FindUnlink,
; PrintTextCopy, DrawLine. Far routine (retf).
;-----------------------------------------------------------------------------
DrawFileDlg:
        enter 0x18, 0x0
        push di
        push si
        call 0x0FEF:UseOtherPage
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Dialogbx
        push 0x0
        push 0x0
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0xa
        push 0xa
        push strict word str_Dbox_9
        push 0x0
        lea ax, [bp - 0x18]
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
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [fdlgflags], 0x10
        mov word [fdlgtab], 0xffff
        cmp word [savedcount1], 0x0
        jz short .1
        mov word [fdlgflags], 0x90
        mov word [fdlgtab], 0x2
.1:
        cmp word [savedcount3], 0x0
        jz short .2
        or byte [fdlgflags], 0x40
        mov word [fdlgtab], 0x1
.2:
        cmp word [savedcount2], 0x0
        jz short .3
        or byte [fdlgflags], 0x20
        mov word [fdlgtab], 0x0
.3:
        cmp word [fdlgtab], 0x0
        jnl short .4
        jmp near DrawFileDlgJumpTable.7
.4:
        or word [fdlgflags], 0x20c
        mov ax, 0x11
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        mov es, [segDialogRects1]
        mov ax, [es:0x4a]
        add ax, strict word 0xa
        push ax
        mov ax, [es:0x48]
        add ax, strict word 0xa
        push ax
        mov bx, [fdlgtab]
        shl bx, 1
        mov si, [bx + FileDlgSpecs]
        mov bx, [si + 0x2]
        shl bx, byte 0x2
        push word [bx + si + 0xa]
        push word [bx + si + 0x8]
        push cs
        call PrintTextCopy
        add sp, 0x8
        mov di, [si + 0x4]
        mov word [bp - 0xa], 0xa
        mov ax, [si + 0x6]
        cmp [si + 0x4], ax
        jg short .6
        db 0x8B, 0xD7                           ; insn: mov dx, di
        shl dx, byte 0x2
        db 0x03, 0xD6                           ; insn: add dx, si
        add dx, 0x8
        mov word [bp - 0x2], 0x52
        mov [bp - 0x4], dx
        mov [bp - 0x6], di
        mov [bp - 0x8], si
        mov si, [bp - 0x2]
        db 0x8B, 0xFA                           ; insn: mov di, dx
.5:
        mov es, [segDialogRects1]
        mov ax, [es:si]
        add ax, strict word 0xa
        push ax
        lea bx, [si - 0x2]
        mov ax, [es:bx]
        add ax, strict word 0xa
        push ax
        push word [di + 0x2]
        push word [di]
        push cs
        call PrintTextCopy
        add sp, 0x8
        add di, 0x4
        add si, 0x8
        inc word [bp - 0x6]
        mov ax, [bp - 0x6]
        mov bx, [bp - 0x8]
        cmp [bx + 0x6], ax
        jnl short .5
        db 0x8B, 0xF3                           ; insn: mov si, bx
.6:
        cmp word [si], 0x6
        jg short .7
        jmp near .8
.7:
        or word [fdlgflags], 0xff03
        mov es, [segDialogRects1]
        mov ax, [es:0x40]
        add ax, strict word 0xa
        mov [bp - 0x2], ax
        mov cx, [es:0x42]
        add cx, 0xa
        mov [bp - 0xa], cx
        mov dx, [es:0x44]
        add dx, 0xa
        mov [bp - 0x4], dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, 0xc0
        db 0x8B, 0xFA                           ; insn: mov di, dx
        cwd
        idiv word [si]
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x03, 0xF8                           ; insn: add di, ax
        dec di
        push 0x11
        push cx
        dec dx
        push dx
        push cx
        push bx
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x11
        lea ax, [di - 0x1]
        push ax
        push word [bp - 0x2]
        push word [bp - 0xa]
        push word [bp - 0x2]
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x5
        push di
        push word [bp - 0x4]
        mov ax, [bp - 0xa]
        dec ax
        push ax
        push word [bp - 0x4]
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x5
        push di
        push word [bp - 0x4]
        push di
        mov ax, [bp - 0x2]
        dec ax
        push ax
        call 0x0FEF:DrawLine
        add sp, 0xa
        pop si
        pop di
        leave
        retf
        db 0x90
.8:
        mov ax, [si]
        dec ax
        cmp ax, strict word 0x5
        ja short DrawFileDlgJumpTable.7
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x95e]
DrawFileDlgJumpTable:                           ; jump table of DrawFileDlg: 6 case targets
        dw .6
        dw .5
        dw .4
        dw .3
        dw .2
        dw .1
.1:
        or byte [fdlgflags2], 0x80
.2:
        or byte [fdlgflags2], 0x40
.3:
        or byte [fdlgflags2], 0x20
.4:
        or byte [fdlgflags2], 0x10
.5:
        or byte [fdlgflags2], 0x8
.6:
        or byte [fdlgflags2], 0x4
.7:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; FileDlgHitTest                                             23A3:098C  94 PC
; Row under the pointer.
;
; Takes 3 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
FileDlgHitTest:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov di, [bp + 0x6]
        sub di, 0xa
        sub word [bp + 0x8], 0xa
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov bx, 0x0
        mov [bp + 0x6], di
        mov ax, 0x369a
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
        cmp bx, 0x80
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
; DrawFileDlgList                                            23A3:09E4  94 PC
; List of saves.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOtherPage, FillRect, CopyPlane,
; VgaCopyRect, PrintTextCopy, DrawLine, WaitRetraceEnd and others. Far routine (retf).
;-----------------------------------------------------------------------------
DrawFileDlgList:
        enter 0x6a, 0x0
        push di
        push si
        lea ax, [bp - 0x6a]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        call 0x0FEF:UseOtherPage
        mov ax, 0x11
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        mov word [bp - 0x4], 0x0
.1:
        mov ax, [bp - 0x4]
        add ax, 0x99
        push ax
        mov es, [segDialogRects1]
        mov bx, [bp - 0x4]
        shl bx, byte 0x3
        db 0x26, 0x8B, 0x87, 0x56, 0x00         ; insn: mov ax, [es:bx + 0x56]
        db 0x26, 0x2B, 0x87, 0x52, 0x00         ; insn: sub ax, [es:bx + 0x52]
        inc ax
        push ax
        db 0x26, 0x8B, 0x87, 0x54, 0x00         ; insn: mov ax, [es:bx + 0x54]
        db 0x26, 0x2B, 0x87, 0x50, 0x00         ; insn: sub ax, [es:bx + 0x50]
        inc ax
        push ax
        db 0x26, 0x8B, 0x87, 0x52, 0x00         ; insn: mov ax, [es:bx + 0x52]
        add ax, strict word 0xa
        push ax
        db 0x26, 0x8B, 0x87, 0x50, 0x00         ; insn: mov ax, [es:bx + 0x50]
        add ax, strict word 0xa
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x6
        jl short .1
        push word 0x98
        mov es, [segDialogRects1]
        mov ax, [es:0x4e]
        sub ax, [es:0x4a]
        inc ax
        push ax
        mov ax, [es:0x4c]
        sub ax, [es:0x48]
        inc ax
        push ax
        mov ax, [es:0x4a]
        add ax, strict word 0xa
        push ax
        mov ax, [es:0x48]
        add ax, strict word 0xa
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        cmp word [bp + 0x6], 0x0
        jnz short .2
        call 0x0FEF:CopyPlane
        push 0x64
        push word 0x88
        push 0xa
        push 0x2
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyRect
        add sp, 0xc
        call 0x0FEF:CopyPlane
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x6
        jg short .5
        mov word [bp - 0x4], 0x0
        jmp short .4
        db 0x90
.3:
        inc word [bp - 0x4]
.4:
        mov ax, [bp - 0x4]
        mov bx, [bp + 0x6]
        cmp [bx], ax
        jng short .7
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x3
        mov es, [segDialogRects1]
        db 0x26, 0x8B, 0x8C, 0x52, 0x00         ; insn: mov cx, [es:si + 0x52]
        add cx, 0xa
        push cx
        db 0x26, 0x8B, 0x8C, 0x50, 0x00         ; insn: mov cx, [es:si + 0x50]
        add cx, 0xa
        push cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bx + si + 0xa]
        push word [bx + si + 0x8]
        push cs
        call PrintTextCopy
        add sp, 0x8
        jmp short .3
.5:
        mov word [bp - 0x4], 0x0
.6:
        mov es, [segDialogRects1]
        mov bx, [bp - 0x4]
        shl bx, byte 0x3
        db 0x26, 0x8B, 0x87, 0x52, 0x00         ; insn: mov ax, [es:bx + 0x52]
        add ax, strict word 0xa
        push ax
        db 0x26, 0x8B, 0x87, 0x50, 0x00         ; insn: mov ax, [es:bx + 0x50]
        add ax, strict word 0xa
        push ax
        mov bx, [bp + 0x6]
        mov si, [bx + 0x4]
        add si, [bp - 0x4]
        shl si, byte 0x2
        push word [bx + si + 0xa]
        push word [bx + si + 0x8]
        push cs
        call PrintTextCopy
        add sp, 0x8
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x6
        jl short .6
.7:
        mov bx, [bp + 0x6]
        cmp word [bx], 0x0
        jng short .8
        mov es, [segDialogRects1]
        mov ax, [es:0x4a]
        add ax, strict word 0xa
        push ax
        mov ax, [es:0x48]
        add ax, strict word 0xa
        push ax
        mov si, [bx + 0x2]
        shl si, byte 0x2
        push word [bx + si + 0xa]
        push word [bx + si + 0x8]
        push cs
        call PrintTextCopy
        add sp, 0x8
.8:
        mov word [bp - 0x4], 0x4b
.9:
        mov si, [bp - 0x4]
        mov byte [bp + si - 0x6a], 0x2a
        inc word [bp - 0x4]
        cmp word [bp - 0x4], 0x5d
        jl short .9
        mov bx, [bp + 0x6]
        mov ax, [bx + 0x4]
        cmp [bx + 0x2], ax
        jl short .10
        mov cx, [bx + 0x6]
        cmp [bx + 0x2], cx
        jg short .10
        sub ax, [bx + 0x2]
        neg ax
        add ax, strict word 0x19
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x4], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov byte [bp + si - 0x68], 0x22
        mov cl, [bp + si - 0x68]
        mov [bp + si - 0x69], cl
        mov [bp + si - 0x6a], cl
.10:
        push 0xb
        mov es, [segDialogRects1]
        mov ax, [es:0x46]
        sub ax, [es:0x42]
        inc ax
        push ax
        mov ax, [es:0x44]
        sub ax, [es:0x40]
        inc ax
        push ax
        mov ax, [es:0x42]
        add ax, strict word 0xa
        push ax
        mov ax, [es:0x40]
        add ax, strict word 0xa
        push ax
        call 0x0FEF:FillRect
        add sp, 0xa
        mov bx, [bp + 0x6]
        cmp word [bx], 0x6
        jg short DrawFileDlgListJumpTable.1
        and word [fdlgflags], 0x6fc
        mov ax, [bx]
        jmp short .17
.11:
        or byte [fdlgflags2], 0x80
.12:
        or byte [fdlgflags2], 0x40
.13:
        or byte [fdlgflags2], 0x20
.14:
        or byte [fdlgflags2], 0x10
.15:
        or byte [fdlgflags2], 0x8
.16:
        or byte [fdlgflags2], 0x4
        jmp near DrawFileDlgListJumpTable.2
        db 0x90
.17:
        dec ax
        cmp ax, strict word 0x5
        jna short .18
        jmp near DrawFileDlgListJumpTable.2
.18:
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0xc40]
        db 0x90
DrawFileDlgListJumpTable:                       ; jump table of DrawFileDlgList: 6 case targets
        dw DrawFileDlgList.16
        dw DrawFileDlgList.15
        dw DrawFileDlgList.14
        dw DrawFileDlgList.13
        dw DrawFileDlgList.12
        dw DrawFileDlgList.11
.1:
        or word [fdlgflags], 0xf903
        mov es, [segDialogRects1]
        mov ax, [es:0x40]
        add ax, strict word 0xa
        mov [bp - 0x2], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bx + 0x4]
        shl ax, byte 0x5
        cwd
        idiv word [bx]
        add ax, [es:0x42]
        add ax, strict word 0xa
        mov [bp - 0x8], ax
        mov dx, [es:0x44]
        add dx, 0xa
        mov [bp - 0x6], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [bx + 0x6]
        inc ax
        shl ax, byte 0x5
        db 0x8B, 0xFA                           ; insn: mov di, dx
        cwd
        idiv word [bx]
        add ax, [es:0x42]
        add ax, strict word 0xa
        mov [bp - 0xa], ax
        push 0x11
        push si
        lea ax, [di - 0x1]
        push ax
        push si
        push cx
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x11
        mov ax, [bp - 0xa]
        dec ax
        push ax
        push word [bp - 0x2]
        push word [bp - 0x8]
        push word [bp - 0x2]
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x5
        push word [bp - 0xa]
        push word [bp - 0x6]
        mov ax, [bp - 0x8]
        inc ax
        push ax
        push word [bp - 0x6]
        call 0x0FEF:DrawLine
        add sp, 0xa
        push 0x5
        push word [bp - 0xa]
        push word [bp - 0x6]
        push word [bp - 0xa]
        mov ax, [bp - 0x2]
        inc ax
        push ax
        call 0x0FEF:DrawLine
        add sp, 0xa
.2:
        mov al, 0x3f
        mov [bp - 0x53], al
        mov [bp - 0x54], al
        mov [bp - 0x55], al
        mov [bp - 0x56], al
        mov [bp - 0x57], al
        mov [bp - 0x58], al
        mov [bp - 0x59], al
        mov [bp - 0x5a], al
        mov [bp - 0x5b], al
        mov al, 0x17
        mov [bp - 0x3b], al
        mov [bp - 0x3c], al
        mov [bp - 0x3d], al
        mov [bp - 0x3e], al
        mov [bp - 0x3f], al
        mov [bp - 0x40], al
        mov [bp - 0x41], al
        mov [bp - 0x42], al
        mov [bp - 0x43], al
        cmp word [fdlgtab], 0x0
        jl short .3
        mov si, [fdlgtab]
        lea si, [si + 0x5]
        db 0x8B, 0xCE                           ; insn: mov cx, si
        shl si, 1
        db 0x03, 0xF1                           ; insn: add si, cx
        mov [bp - 0x4], si
        mov [bp + si - 0x68], al
        mov [bp + si - 0x69], al
        mov [bp + si - 0x6a], al
        mov al, 0x3f
        mov [bp + si - 0x50], al
        mov [bp + si - 0x51], al
        mov [bp + si - 0x52], al
.3:
        call 0x0FEF:WaitRetraceEnd
        lea ax, [bp - 0x6a]
        push ss
        push ax
        push 0x20
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        call 0x0FEF:CopyPlane
        push 0x64
        push word 0x88
        push 0xa
        push 0x2
        push word 0x3f00
        push word 0x7e00
        call 0x0000:VgaCopyRect
        add sp, 0xc
        call 0x0FEF:CopyPlane
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; RunFileDlg                                                 23A3:0D94  94 PC
; File dialog input loop.
;
; Calls MouseRead, UseCurrentPage, DrawRleTransAt, FlushInputEvents, GetInputEvent, VgaCopyRect,
; FileDlgHitTest, DrawFileDlgList and others. Far routine (retf).
;-----------------------------------------------------------------------------
RunFileDlg:
        enter 0x1a, 0x0
        mov word [bp - 0x18], 0x0
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
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov bx, [fdlgtab]
        shl bx, 1
        mov ax, [bx + FileDlgSpecs]
        mov [bp - 0x14], ax
        call 0x0F99:FlushInputEvents
.1:
        mov word [bp - 0x16], 0x0
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
        mov [bp - 0x16], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
.3:
        cmp word [bp - 0x16], 0x0
        jz short .4
        jmp near .9
.4:
        mov ax, [bp - 0x8]
        cmp [bp - 0x4], ax
        jnz short .5
        mov ax, [bp - 0x6]
        cmp [bp - 0xe], ax
        jz short .1
.5:
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0xe], 0xc8
        jnl short .8
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
.8:
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
.9:
        test byte [bp - 0x16], 0x1
        jnz short .10
        jmp near .29
.10:
        test byte [fdlgflags2], 0x1
        jnz short .11
        jmp near .29
.11:
        mov ax, [bp - 0x6]
        cmp [bp - 0x8], ax
        jnz short .12
        cmp [bp - 0xe], ax
        jnz short .12
        jmp near .1
.12:
        lea ax, [bp - 0xa]
        push ax
        push word [bp - 0x6]
        push word [bp - 0x4]
        push cs
        call FileDlgHitTest
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        jmp near .28
.13:
        cmp word [bp - 0xa], 0x8
        jz short .14
        jmp near .28
.14:
        cmp word [bp - 0x18], 0x0
        jnz short .15
        jmp near .27
.15:
        mov ax, [bp - 0xe]
        mov es, [segDialogRects1]
        sub ax, [es:0x42]
        sub ax, strict word 0xa
        mov bx, [bp - 0x14]
        imul word [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x5
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xc], ax
        mov cx, [bx + 0x6]
        mov [bp - 0x1a], cx
        mov dx, [bp - 0x6]
        cmp [bp - 0xe], dx
        jnz short .16
        jmp near .1
.16:
        cmp ax, [bx + 0x4]
        jnl short .17
        jmp near .1
.17:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jng short .18
        jmp near .1
.18:
        cmp [bp - 0xe], dx
        jnl short .20
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        sub ax, [bp - 0xe]
        imul word [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x5
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xc], ax
        db 0x03, 0xC8                           ; insn: add cx, ax
        cmp cx, [bx]
        jnl short .19
        add [bx + 0x4], ax
        mov ax, [bp - 0xc]
        add [bx + 0x6], ax
        jmp short .22
.19:
        mov ax, [bx]
        dec ax
        mov [bx + 0x6], ax
        mov ax, [bx]
        sub ax, strict word 0x6
        mov [bx + 0x4], ax
        jmp short .22
.20:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        cmp [bp - 0xe], ax
        jng short .22
        sub ax, [bp - 0xe]
        neg ax
        imul word [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x5
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xc], ax
        sub ax, [bx + 0x4]
        neg ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .21
        mov [bx + 0x4], ax
        mov ax, [bp - 0xc]
        sub [bx + 0x6], ax
        jmp short .22
        db 0x90
.21:
        mov word [bx + 0x4], 0x0
        mov word [bx + 0x6], 0x5
.22:
        cmp word [bp - 0xe], 0xc8
        jnl short .25
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0xe]
        cmp ax, 0xc8
        jl short .23
        mov ax, 0xc8
        sub ax, [bp - 0xe]
        push ax
        jmp short .24
.23:
        push word [es:bx + 0x2]
.24:
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
.25:
        mov ax, [bp - 0x1a]
        mov bx, [bp - 0x14]
        cmp [bx + 0x6], ax
        jnz short .26
        jmp near .42
.26:
        jmp near .40
.27:
        mov word [bp - 0x18], 0x1
        jmp near .1
.28:
        mov word [bp - 0x18], 0x0
        jmp near .1
.29:
        test byte [bp - 0x16], 0x2
        jnz short .30
        jmp near .60
.30:
        mov word [bp - 0x18], 0x0
        lea ax, [bp - 0xa]
        push ax
        push word [bp - 0x6]
        push word [bp - 0x4]
        push cs
        call FileDlgHitTest
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .31
        jmp near .1
.31:
        cmp word [bp - 0xe], 0xc8
        jnl short .34
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0xe]
        cmp ax, 0xc8
        jl short .32
        mov ax, 0xc8
        sub ax, [bp - 0xe]
        push ax
        jmp short .33
.32:
        push word [es:bx + 0x2]
.33:
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
.34:
        mov cl, [bp - 0xa]
        mov ax, 0x1
        shl ax, cl
        mov [bp - 0xa], ax
        test [fdlgflags], ax
        jz short .42
        cmp ax, strict word 0x10
        jnz short .35
        jmp near .61
.35:
        jng short .36
        jmp near .57
.36:
        dec ax
        jz short .39
        dec ax
        jz short .43
        dec ax
        dec ax
        jnz short .37
        jmp near .54
.37:
        sub ax, strict word 0x4
        jnz short .38
        jmp near .55
.38:
        jmp near .58
        db 0x90
.39:
        mov bx, [bp - 0x14]
        cmp word [bx + 0x4], 0x0
        jz short .42
        dec word [bx + 0x4]
        dec word [bx + 0x6]
.40:
        push bx
.41:
        push cs
        call DrawFileDlgList
        add sp, 0x2
.42:
        call 0x0FEF:UseCurrentPage
        jmp near .8
        db 0x90
.43:
        mov bx, [bp - 0x14]
        mov ax, [bx + 0x6]
        inc ax
        cmp ax, [bx]
        jnl short .42
        inc word [bx + 0x4]
        inc word [bx + 0x6]
        jmp short .40
        db 0x90
.44:
        mov ax, [bp - 0x6]
        mov es, [segDialogRects1]
        sub ax, [es:0x42]
        sub ax, strict word 0xa
        mov bx, [bp - 0x14]
        imul word [bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x5
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov [bp - 0xc], ax
        cmp ax, [bx + 0x4]
        jnl short .45
        cmp ax, strict word 0x3
        jnl short .47
        mov word [bx + 0x4], 0x0
        mov word [bx + 0x6], 0x5
        jmp short .49
        db 0x90
.45:
        cmp [bx + 0x6], ax
        jnl short .42
        add ax, strict word 0x3
        cmp ax, [bx]
        jng short .46
        mov ax, [bx]
        sub ax, strict word 0x6
        mov [bx + 0x4], ax
        mov ax, [bx]
        dec ax
        jmp short .48
        db 0x90
.46:
        mov ax, [bp - 0xc]
.47:
        sub ax, strict word 0x3
        mov [bx + 0x4], ax
        mov ax, [bp - 0xc]
        inc ax
        inc ax
.48:
        mov [bx + 0x6], ax
.49:
        push word [bp - 0x14]
        jmp near .41
        db 0x90
.50:
        mov word [fdlgtab], 0x0
        mov ax, [FileDlgSpecs]
.51:
        mov [bp - 0x14], ax
        push ax
        jmp near .41
.52:
        mov word [fdlgtab], 0x1
        mov ax, [FileDlgSpec2]
        jmp short .51
        db 0x90
.53:
        mov word [fdlgtab], 0x2
        mov ax, [FileDlgSpec3]
        jmp short .51
        db 0x90
.54:
        push cs
        call SelectSavedFile
        leave
        retf
.55:
        mov bx, [fdlgtab]
        shl bx, 1
        push word [bx + FileDlgSpecs]
        push cs
        call DeleteSavedGame
        add sp, 0x2
        cmp word [fdlgtab], 0x0
        jnl short .56
        mov word [bp - 0x14], 0x0
        jmp short .49
        db 0x90
.56:
        mov bx, [fdlgtab]
        shl bx, 1
        mov ax, [bx + FileDlgSpecs]
        mov [bp - 0x14], ax
        jmp short .49
        db 0x90
.57:
        sub ax, strict word 0x20
        jz short .50
        sub ax, strict word 0x20
        jz short .52
        sub ax, strict word 0x40
        jz short .53
        sub ax, 0x80
        jnz short .58
        jmp near .44
.58:
        lea ax, [bp - 0xa]
        push ax
        push word [bp - 0x6]
        push word [bp - 0x4]
        push cs
        call FileDlgHitTest
        add sp, 0x6
        cmp word [bp - 0xa], 0x9
        jg short .59
        jmp near .49
.59:
        mov bx, [bp - 0x14]
        mov ax, [bx + 0x4]
        add ax, [bp - 0xa]
        sub ax, strict word 0xa
        mov [bx + 0x2], ax
        jmp near .49
        db 0x90
.60:
        test byte [bp - 0x16], 0x4
        jnz short .61
        jmp near .1
.61:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeleteSavedGame                                            23A3:121A  94 PC
; Deletes a save and its directory.
;
; Takes 1 word of stack arguments. Calls SetDialogColors, MessageBox, _fstrcpy, _dos_findfirst,
; _fmemcmp, _chdir, FatalError, _unlink and others. Far routine (retf).
;-----------------------------------------------------------------------------
DeleteSavedGame:
        enter 0x46, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov word [bp - 0xc], 0xf00
        mov word [bp - 0xa], 0xf05
        mov word [bp - 0x8], 0xf09
        mov word [bp - 0x4], 0xa0
        mov word [bp - 0x6], 0x64
        cmp word [fdlgtab], 0x0
        jnz short .1
        mov ax, 0x98
        mov dx, 0x369a
        jmp short .3
        db 0x90
.1:
        cmp word [fdlgtab], 0x1
        jnz short .2
        mov ax, 0xbf
        mov dx, 0x369a
        jmp short .3
        db 0x90
.2:
        mov ax, 0xb0
        mov dx, 0x369a
.3:
        mov [DelFileName], ax
        mov [DelFileNameSeg], dx
        mov bx, [si + 0x2]
        shl bx, byte 0x2
        mov ax, [bx + si + 0x8]
        mov dx, [bx + si + 0xa]
        mov [DelFileName2], ax
        mov [DelFileName2Seg], dx
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push -0x1
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x2
        push word 0x36b8
        push strict word dlgReturnConfirm
        push 0x3
        push ds
        push strict word msgConfirmDeletionOfThe
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        dec ax
        jz short .5
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.5:
        mov bx, [bp + 0x6]
        mov si, [bx + 0x2]
        shl si, byte 0x2
        push word [bx + si + 0xa]
        push word [bx + si + 0x8]
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov si, [fdlgtab]
        shl si, 1
        mov bx, [bp + si - 0xc]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        lea si, [bp - 0x1a]
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
        lea ax, [bp - 0x46]
        push ax
        push 0x10
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        mov si, [bp + 0x6]
        test byte [bp - 0x31], 0x10
        jnz short .6
        jmp near .14
.6:
        push word 0x3415
        push strict word lgstate_name
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x0000:_fmemcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .7
        mov es, [segDbFiles4]
        mov byte [es:0xc6], 0x0
        mov es, [segMenuText7]
        mov [es:0xb6e], ax
        mov [es:0xb6c], ax
        mov [es:0xb84], ax
        mov [es:0xb82], ax
        mov [es:0xb9e], ax
        mov [es:0xb9c], ax
        jmp short .8
.7:
        push word 0x3415
        push strict word postate_name
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x0000:_fmemcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .8
        mov es, [segDbFiles2]
        mov byte [es:0x64], 0x0
        mov es, [segMenuText7]
        mov [es:0xbdc], ax
        mov [es:0xbda], ax
        mov [es:0xbf2], ax
        mov [es:0xbf0], ax
        mov [es:0xc08], ax
        mov [es:0xc06], ax
.8:
        lea ax, [bp - 0x28]
        push ax
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        push word 0xf0d
        call 0x0F4A:FatalError
        add sp, 0x2
.9:
        lea ax, [bp - 0x46]
        push ax
        push 0x0
        push word 0xf10
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .12
.10:
        lea ax, [bp - 0x28]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        push word 0xf14
        call 0x0F4A:FatalError
        add sp, 0x2
.11:
        lea ax, [bp - 0x46]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
.12:
        push word 0xf17
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        push word 0xf1a
        call 0x0F4A:FatalError
        add sp, 0x2
.13:
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_rmdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        push word 0xf1d
        jmp short .15
        db 0x90
.14:
        lea ax, [bp - 0x28]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        push word 0xf20
.15:
        call 0x0F4A:FatalError
        add sp, 0x2
.16:
        dec word [si]
        jz short .21
        mov dx, [si + 0x2]
        mov ax, [si]
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jnl short .18
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shl bx, byte 0x2
        db 0x03, 0xDE                           ; insn: add bx, si
        add bx, 0x8
        mov [bp - 0x2], dx
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov cx, [bp + 0x6]
.17:
        mov ax, [bx + 0x4]
        mov dx, [bx + 0x6]
        mov [bx], ax
        mov [bx + 0x2], dx
        add bx, 0x4
        inc si
        db 0x8B, 0xF9                           ; insn: mov di, cx
        cmp [di], si
        jg short .17
        mov si, [bp + 0x6]
.18:
        cmp word [si], 0x6
        jnl short .19
        mov ax, [si]
        dec ax
        mov [si + 0x6], ax
        mov word [si + 0x4], 0x0
        jmp short .20
.19:
        mov ax, [si]
        cmp [si + 0x6], ax
        jnz short .20
        dec word [si + 0x4]
        dec word [si + 0x6]
.20:
        mov ax, [si]
        cmp [si + 0x2], ax
        jnz short .30
        dec word [si + 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90
.21:
        mov ax, [fdlgtab]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .22
        dec ax
        jz short .23
        dec ax
        jz short .24
        jmp short .25
        db 0x90
.22:
        and byte [fdlgflags], 0xdf
        jmp short .25
        db 0x90
.23:
        and byte [fdlgflags], 0xbf
        jmp short .25
        db 0x90
.24:
        and byte [fdlgflags], 0x7f
.25:
        cmp word [savedcount2], 0x0
        jz short .26
        mov word [fdlgtab], 0x0
        jmp short .29
.26:
        cmp word [savedcount3], 0x0
        jz short .27
        mov word [fdlgtab], 0x1
        jmp short .29
        db 0x90
.27:
        cmp word [savedcount1], 0x0
        jz short .28
        mov word [fdlgtab], 0x2
        jmp short .29
        db 0x90
.28:
        mov word [fdlgtab], 0xffff
        and byte [fdlgflags], 0xf3
.29:
        push cs
        call DrawFileDlgTabs
.30:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SelectSavedFile                                            23A3:1518  94 PC
; 'LA  at MTL ...' line of a save.
;
; Calls _fstrcpy, ReadGameSettings, LoadModeState, CopyStrNFar, LoadScheduleDB, FindUnlink. Far
; routine (retf).
;-----------------------------------------------------------------------------
SelectSavedFile:
        enter 0x18, 0x0
        push di
        push si
        mov ax, [fdlgtab]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        dec ax
        jnz short .1
        jmp near .8
.1:
        dec ax
        jnz short .2
        jmp near .9
.2:
        pop si
        pop di
        leave
        retf
        db 0x90
.3:
        mov bx, [lgfiles]
        shl bx, byte 0x2
        push word [bx + lgfilenames]
        push word [bx + savednames2]
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_Nhl_5
        lea si, [bp - 0x14]
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
        push 0x1
        lea ax, [bp - 0x14]
        push ax
        push word 0x3415
        push strict word exhstate
        push cs
        call ReadGameSettings
        add sp, 0x8
        push word 0x3415
        push strict word exhstate
        call 0x2E70:LoadModeState
        add sp, 0x4
        mov es, [segDbFiles1]
        mov ax, [es:0x50]
        mov [bp - 0x16], ax
        cmp ax, strict word 0x18
        jnl short .4
        push 0x3
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        push ds
        push word [bx + TeamNameClips]
        jmp short .5
        db 0x90
.4:
        push 0x3
        mov bx, [bp - 0x16]
        shl bx, 1
        push ds
        push word [bx + 0x1e4]
.5:
        push word 0x3448
        push strict word str_LaAtMtl
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov es, [segDbFiles1]
        mov ax, [es:0x52]
        mov [bp - 0x18], ax
        cmp ax, strict word 0x18
        jnl short .6
        push 0x3
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        push ds
        push word [bx + TeamNameClips]
        jmp short .7
        db 0x90
.6:
        push 0x3
        mov bx, [bp - 0x18]
        shl bx, 1
        push ds
        push word [bx + 0x1e4]
.7:
        push word 0x3448
        push strict word str_Mtl_2
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.8:
        mov bx, [savedsel3]
        shl bx, byte 0x2
        push word [bx + savednames3seg]
        push word [bx + savednames3]
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_Po_2
        lea si, [bp - 0x14]
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
        push ax
        lea ax, [bp - 0x14]
        push ax
        push word 0x3415
        push strict word postate
        push cs
        call ReadGameSettings
        add sp, 0x8
        mov [bp - 0x2], ax
        mov es, [segMenuText7]
        mov word [es:0xbda], strict word PlayoffModeLoopThunk
        mov word [es:0xbdc], 0x1b35
        mov word [es:0xbf0], strict word EditPlayoffSettingsThunk
        mov word [es:0xbf2], 0x1b35
        mov word [es:0xc06], strict word MenuPlayoffHilightsThunk
        mov word [es:0xc08], 0x1b35
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word 0x3701
        push strict word CurLeagueName
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x6]
        push ax
        call 0x26D4:LoadScheduleDB
        add sp, 0x2
        push word 0x3415
        push strict word exhstate_name
        push word 0x3701
        push strict word CurLeagueName
        call 0x0000:_fstrcpy
        add sp, 0x8
        les bx, [bp - 0x6]
        mov ax, [es:bx + 0x20]
        mov cx, 0x7
        cwd
        idiv cx
        mov [LeagueSetChoice], dx
        push es
        push bx
        call 0x06E1:FindUnlink
        add sp, 0x4
        jmp near .10
        db 0x90
.9:
        mov bx, [savedsel1]
        shl bx, byte 0x2
        push word [bx + savednames1seg]
        push word [bx + savednames1]
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, str_Lp_2
        lea si, [bp - 0x14]
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
        push ax
        lea ax, [bp - 0x14]
        push ax
        push word 0x3415
        push strict word lgstate
        push cs
        call ReadGameSettings
        add sp, 0x8
        mov [bp - 0x2], ax
        mov es, [segMenuText7]
        mov word [es:0xb6c], strict word MenuExportDbsThunk
        mov word [es:0xb6e], 0x1b35
        mov word [es:0xb82], strict word MenuNextLeagueGameThunk
        mov word [es:0xb84], 0x1b35
        mov word [es:0xb9c], 0xd86
        mov word [es:0xb9e], 0x3448
.10:
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadGameSettings                                           23A3:1778  94 PC
; Game.set of a save.
;
; Takes 4 words of stack arguments. Calls _chdir, FatalError, OpenReadShared, ReadAtOffset,
; CloseHandlePtr, FindPath. Far routine (retf).
;-----------------------------------------------------------------------------
ReadGameSettings:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0xc]
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .2
        mov si, [bp + 0xa]
        push si
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0xf3d
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        lea ax, [bp - 0x2]
        push ax
        push strict word str_GameSet_3
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0xf49
        jmp short .3
.2:
        mov si, [bp + 0xa]
        lea ax, [bp - 0x2]
        push ax
        push si
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push strict word str_Dd2
.3:
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0x62
        push -0x1
        push -0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0xf50
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0xf53
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .7
        push strict word str_GameSav_7
        call 0x03A3:FindPath
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word 0xf5f
        call 0x0000:_chdir
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0xf62
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .8
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
