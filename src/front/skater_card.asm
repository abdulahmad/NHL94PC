; Skater stats card (STATS.OVL)
; The first bytes finish the last routine of cal_stats.asm.
        leave
        retf

;-----------------------------------------------------------------------------
; SkaterStatsCard                                            23D5:0002  94 PC
; Skater card: portrait, season and career stats, ratings.
;
; Calls LoadRawHeader, BuildPathFar, _open, _lseek, _read, _close, UseOffscreenCanvas, _sprintf and
; others.
;-----------------------------------------------------------------------------
SkaterStatsCard:
        enter 0x19a, 0x0
        push di
        push si
        mov word [bp - 0x2], 0xcf1a
        push 0x0
        push strict word str_EasnFnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x4e], ax
        mov [bp - 0x4c], dx
        push 0x0
        push 0x0
        mov bx, [statsseason]
        shl bx, 1
        push ds
        push word [bx + StatsDbNames2]
        mov ax, 0x0
        mov cx, 0x3861
        mov [bp - 0x19a], ax
        mov [bp - 0x198], cx
        push cx
        push ax
        lea ax, [bp - 0x6e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0x6e]
        push ax
        call 0x0000:_open
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push 0x0
        cmp word [statsseason], 0x0
        jnz short .1
        mov ax, [statscardrec]
        mov dx, [statscardrecseg]
        jmp short .2
        db 0x90
.1:
        mov ax, [statscardrec2]
        mov dx, [statscardrec2seg]
.2:
        push dx
        push ax
        push si
        call 0x0000:_lseek
        add sp, 0x8
        push 0x28
        lea ax, [bp - 0x96]
        push ax
        push si
        call 0x0000:_read
        add sp, 0x6
        push si
        call 0x0000:_close
        add sp, 0x2
        push 0x0
        push 0x0
        push ds
        push strict word str_AttDb
        push word [bp - 0x198]
        push word [bp - 0x19a]
        lea ax, [bp - 0x6e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0x6e]
        push ax
        call 0x0000:_open
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push 0x0
        push word [statsfileposhi]
        push word [statsfilepos]
        push si
        call 0x0000:_lseek
        add sp, 0x8
        push 0x14
        lea ax, [bp - 0x32]
        push ax
        push si
        call 0x0000:_read
        add sp, 0x6
        push si
        call 0x0000:_close
        add sp, 0x2
        push 0x0
        push 0x0
        push ds
        push word [StatsDbNames3]
        push word [bp - 0x198]
        push word [bp - 0x19a]
        lea ax, [bp - 0x6e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0x6e]
        push ax
        call 0x0000:_open
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push 0x0
        mov al, [statscardteam]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cx, 0x4c
        mul cx
        push dx
        push ax
        push si
        call 0x0000:_lseek
        add sp, 0x8
        push 0x5
        lea ax, [bp - 0x1e]
        push ax
        push si
        call 0x0000:_read
        add sp, 0x6
        push si
        call 0x0000:_close
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        lea ax, [bp - 0x1e]
        push ax
        push strict word str_EmbS
        push word 0xcfd4
        call 0x0000:_sprintf
        add sp, 0x6
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word statstext
        push 0x0
        push 0x0
        lea ax, [bp - 0x6e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x6e]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Bkgd
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        mov bx, 0xa
        call 0x0FEF:SetClipRectRegs
        push word [statsbgseg]
        push word [statsbgshapes]
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp byte [statscardgoalie], 0x0
        jnz short .3
        jmp near .9
.3:
        push word 0x3701
        push strict word str_Nsh
        push ds
        push strict word str_Portrait
        push 0x0
        push 0x0
        lea ax, [bp - 0x6e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_13
        lea ax, [bp - 0x18]
        push ax
        call 0x0000:_sprintf
        add sp, 0x4
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x6e]
        push ax
        call 0x2095:LoadPhotoShape
        add sp, 0x4
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [statsbgshapes]
        jnz short .4
        jmp near .9
.4:
        mov ax, [statsbgshapes]
        add ax, strict word 0x10
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov [bp - 0x12], di
.5:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x196], bl
        inc bx
        cmp bx, 0x100
        jl short .5
        mov es, [segWorkBuffer44]
        cmp word [es:dlgJerseyConflict + 0x4], 0x0
        jz short .6
        push word 0xb4
        push word [bp - 0x10]
        push di
        push word 0x3a0b
        push strict word StatsCardBuf
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word 0xb4
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov dx, [bp - 0x10]
        add ax, 0xb4
        push dx
        push ax
        push word 0x3a0b
        push strict word StatsCardBuf2
        call 0x0000:_fmemcpy
        add sp, 0xa
        jmp short .7
        db 0x90
.6:
        mov ax, [bp - 0x10]
        push ax
        push di
        push 0x3c
        push 0x44
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        lea ax, [di + 0xb4]
        push si
        push ax
        push 0x3c
        push word 0xc4
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.7:
        db 0x2B, 0xF6                           ; insn: sub si, si
.8:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xCE                           ; insn: mov cx, si
        add al, 0x44
        mov [bp + si - 0x196], al
        sub cl, 0x3c
        mov [bp + si - 0x15a], cl
        inc si
        cmp si, 0x3c
        jl short .8
        push word [statsbgseg]
        push word [statsbgshapes]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [statscardgoalie]
        mov dx, [statscardrec3]
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        mov byte [bp - 0x13], 0x0
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x6e]
        push ax
        call 0x2095:LoadPhotoShape
        add sp, 0x4
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [statsbgshapes]
        jz short .9
        lea ax, [bp - 0x196]
        push ss
        push ax
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0x14
        push 0x24
        push word [statsbgseg]
        push word [statsbgshapes]
        call 0x0FEF:DrawRawTransRemapAt
        add sp, 0x8
        push word [statsbgseg]
        push word [statsbgshapes]
        call 0x06E1:FindUnlink
        add sp, 0x4
.9:
        lea ax, [bp - 0x4a]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0x4c]
        push word [bp - 0x4e]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        push 0x43
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        push word 0xcf2d
        push word 0xcf1d
        push strict word str_SS_3
        push word 0xcfd4
        call 0x0000:_sprintf
        add sp, 0x8
        push ds
        push strict word statstext
        push 0x28
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        mov al, [statscardplayer]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_D_4
        push word 0xcfd4
        call 0x0000:_sprintf
        add sp, 0x6
        mov al, [statsplayer]
        cbw
        cmp ax, strict word 0x52
        jz short .13
        ja short .15
        sub al, 0x43
        jz short .10
        dec al
        jz short .11
        sub al, 0x8
        jz short .12
        jmp short .15
.10:
        mov di, str_Center
        jmp short .14
        db 0x90
.11:
        mov di, str_Defense
        jmp short .14
        db 0x90
.12:
        mov di, str_LeftWing
        jmp short .14
        db 0x90
.13:
        mov di, str_RightWing
.14:
        mov si, 0xcfd4
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
.15:
        push ds
        push strict word statstext
        push 0x30
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push ds
        push strict word str_Gp_6
        push 0x50
        push 0x3c
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_G_2
        push 0x50
        push 0x50
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_A_2
        push 0x50
        push 0x64
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pt_2
        push 0x50
        push 0x78
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pim_2
        push 0x50
        push word 0x8c
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_PlusMinus2
        push 0x50
        push word 0xa0
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Ppg
        push 0x50
        push word 0xbe
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Shg
        push 0x50
        push word 0xd2
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Shots_2
        push 0x50
        push word 0xe6
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Pct_3
        push 0x50
        push word 0x104
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov di, 0x59
        lea ax, [bp - 0x96]
        mov [bp - 0x2], ax
        mov word [bp - 0x8], 0x1f96
.16:
        mov si, [bp - 0x2]
        mov bx, [bp - 0x8]
        push ds
        push word [bx]
        push di
        push 0x14
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push word [si]
        push strict word str_2d
        push di
        push 0x3c
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0x2]
        push strict word str_3d
        push di
        push 0x50
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0x4]
        push strict word str_3d
        push di
        push 0x64
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0x6]
        push strict word str_3d
        push di
        push 0x78
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0xc]
        push strict word str_3d
        push di
        push word 0x8c
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0x10]
        push strict word str_4d
        push di
        push word 0xa0
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0x8]
        push strict word str_3d
        push di
        push word 0xbe
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0xa]
        push strict word str_3d
        push di
        push word 0xd2
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        push word [si + 0xe]
        push strict word str_5d
        push di
        push word 0xe6
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        cmp word [si + 0xe], 0x0
        jz short .17
        push 0x0
        push word [si + 0xe]
        mov ax, 0x3e8
        mul word [si + 0x2]
        mov cx, [si + 0xe]
        shr cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        adc dx, 0x0
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [bp - 0x6], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .18
.17:
        db 0x2B, 0xF6                           ; insn: sub si, si
.18:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0xa
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        idiv cx
        push ax
        push strict word str_3d1d
        push di
        push word 0x104
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        lea ax, [bp - 0x84]
        mov [bp - 0x2], ax
        add di, 0x7
        add word [bp - 0x8], 0x2
        cmp word [bp - 0x8], 0x1f9a
        jnc short .19
        jmp near .16
.19:
        cmp word [statsseason], 0x0
        jnz short .20
        push ds
        push strict word str_Career
        push di
        push 0x14
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov ax, [bp - 0x82]
        add ax, [bp - 0x72]
        add ax, [bp - 0x94]
        push ax
        push strict word str_4d
        push di
        push 0x4c
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov ax, [bp - 0x70]
        add ax, [bp - 0x92]
        add ax, [bp - 0x80]
        push ax
        push strict word str_4d
        push di
        push 0x60
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov ax, [bp - 0x70]
        add ax, [bp - 0x90]
        add ax, [bp - 0x7e]
        add ax, [bp - 0x72]
        push ax
        push strict word str_4d
        push di
        push 0x74
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        add di, 0xa
.20:
        push ds
        push strict word str_Ratings
        add di, 0xf
        push di
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push ds
        push strict word str_Shoots
        lea di, [di + 0xa]
        push di
        push 0xa
        call 0x0D39:DrawShadowText
        add sp, 0x8
        lea bx, [bp - 0x32]
        mov [bp - 0x2], bx
        cmp byte [bx], 0x0
        jz short .21
        push ds
        push strict word str_L_3
        jmp short .22
        db 0x90
.21:
        push ds
        push strict word str_R
.22:
        push di
        push word 0x82
        call 0x0D39:DrawShadowText
        add sp, 0x8
        add di, 0x7
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x8], si
        mov word [bp - 0xa], 0x23ce
        mov word [bp - 0x6], 0xfff9
.23:
        cmp word [bp - 0x6], -0x38
        jnz short .24
        add word [bp - 0x8], 0xa0
        add di, [bp - 0x6]
.24:
        mov bx, [bp - 0xa]
        push ds
        push word [bx]
        push di
        mov ax, [bp - 0x8]
        add ax, strict word 0xa
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov al, [si + SkaterCardCols]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lea ax, [bp - 0x32]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x5
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push strict word str_3d
        push di
        mov ax, [bp - 0x8]
        add ax, 0x82
        push ax
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        add di, 0x7
        add word [bp - 0xa], 0x2
        inc si
        sub word [bp - 0x6], 0x7
        cmp word [bp - 0x6], -0x69
        jg short .23
        lea ax, [bp - 0x4a]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0x4c]
        push word [bp - 0x4e]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [bp - 0x2]
