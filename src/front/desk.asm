; Pre-game desk menus: team, goalie and settings choices (MENUS.OVL)

;-----------------------------------------------------------------------------
; ExhSetEditLoopTail                                         2CF8:0003  94 PC
; The rest of ExhSetEditLoop, which runs on into this module.
;
; Calls UseDbDescriptor. Far routine (retf).
;-----------------------------------------------------------------------------
ExhSetEditLoopTail:
        call 0x0F97:UseDbDescriptor
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SportsDesk                                                 2CF8:000E  94 PC
; The in-game desk ('eadesk%1d')
;
; Takes 1 word of stack arguments. Calls SetModeMenuLabels, SetStatsMenuTextThunk, ReplayIsEmptyThunk,
; MouseRead, FreePPVFilesThunk, FindUnlink, GetPaletteFar, FadePaletteInThunk and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
SportsDesk:
        enter 0x39e, 0x0
        push di
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x48], ax
        mov [bp - 0x70], ax
        mov word [bp - 0x4], 0x3e8
        push word [DbSaveMode]
        call 0x2B11:SetModeMenuLabels
        add sp, 0x2
        mov ax, [bp + 0x6]
        add ax, strict word 0x3
        push ax
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        call 0x1B35:ReplayIsEmptyThunk
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov es, [g_8B60]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x119e], ax
        mov [es:0x119c], ax
        jmp short .2
        db 0x90
.1:
        mov es, [g_8B60]
        mov word [es:0x119c], strict word DeskGoToReplay
        mov word [es:0x119e], 0x2cf8
.2:
        lea ax, [bp - 0x76]
        push ax
        lea ax, [bp - 0x72]
        push ax
        lea ax, [bp - 0x90]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_4B02], ax
        mov [PadRepeatOn], ax
        cmp [bp + 0x6], ax
        jnz short .3
        call 0x1B35:FreePPVFilesThunk
        push word [g_C25E]
        push word [g_C25C]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_C25A]
        push word [g_C258]
        call 0x06E1:FindUnlink
        add sp, 0x4
        lea ax, [bp - 0x390]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        cmp word [CurPage], 0x0
        jz short .4
        push word 0x3900
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0000:VgaPageFlip
.4:
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0FEF:UseOtherPage
        push word [bp + 0x6]
        push strict word str_Eadesk1d
        push word 0xc242
        call 0x0000:_sprintf
        add sp, 0x6
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word g_C242
        call 0x0000:_fstrcat
        add sp, 0x8
        push strict word str_Desk_14
        push 0x0
        push word 0xc242
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x2a], ax
        mov [bp - 0x28], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push word 0xff58
        push 0x0
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x0FEF:DrawRleAt
        add sp, 0x8
        call 0x0FEF:UseOtherPage
        push strict word str_Pal_60
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        mov word [bp - 0x66], 0x0
        mov es, [bp - 0x20]
.5:
        mov bx, [bp - 0x22]
        mov si, [bp - 0x66]
        mov al, [es:bx + si]
        mov [bp + si - 0x390], al
        inc word [bp - 0x66]
        cmp word [bp - 0x66], 0x180
        jl short .5
        mov word [bp - 0x66], 0x2f1
        mov es, [bp - 0x20]
.6:
        mov bx, [bp - 0x22]
        mov si, [bp - 0x66]
        mov al, [es:bx + si]
        mov [bp + si - 0x390], al
        inc word [bp - 0x66]
        cmp word [bp - 0x66], 0x2fd
        jl short .6
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        lea ax, [bp - 0x1e]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        cmp word [bp + 0x6], 0x2
        jnz short .7
        call 0x0EDC:LoadStudioSpeech
        mov word [bp - 0x62], f_3448_12AE
        mov word [bp - 0x60], 0x3448
        mov word [bp - 0x50], 0x3
        jmp short .8
        db 0x90
.7:
        mov word [bp - 0x62], f_3448_11FE
        mov word [bp - 0x60], 0x3448
        mov word [bp - 0x50], 0x6
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x5e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov [bp - 0x8e], ax
        push 0x5
        push 0xb
        push 0x11
        push word [bp - 0x50]
        push word [bp - 0x60]
        push word [bp - 0x62]
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        mov ax, [g_B092]
        mov [bp - 0x42], ax
        mov ax, [g_B094]
        mov [bp - 0x6a], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x78], ax
        mov [bp - 0x7a], ax
        mov [bp - 0x7c], ax
        mov [bp - 0x7e], ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        mov [g_B092], ax
        mov [g_B094], ax
        call 0x0000:VgaPageFlip
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        mov ax, [bp - 0x42]
        mov [g_B092], ax
        mov ax, [bp - 0x6a]
        mov [g_B094], ax
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0BFE:InputInit
        les bx, [bp - 0x62]
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x52], ax
        mov [bp - 0x3c], ax
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x64], ax
        mov [bp - 0x40], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x64]
        push word [bp - 0x52]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0x96
        push word 0x13b
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x64]
        push word [bp - 0x52]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x0F99:FlushInputEvents
        cmp word [bp + 0x6], 0x1
        jnz short .9
        cmp word [g_01B8], 0x0
        jnl short .9
        cmp word [g_01BA], 0x0
        jnl short .9
        mov word [bp - 0x70], 0x1
.9:
        call 0x03A3:CallCountStep
        cmp word [bp + 0x6], 0x2
        jz short .10
        jmp near .15
.10:
        mov es, [g_8B62]
        cmp word [es:0x78c], 0x3f0
        jl short .15
        mov ax, [hmscore]
        cmp [awscore], ax
        jnl short .11
        mov ax, [g_29CA]
        jmp short .12
        db 0x90, 0x90
.11:
        mov ax, [g_29CC]
.12:
        mov [bp - 0x3e], ax
        mov word [bp - 0x74], 0x0
        cmp word [curperiod], 0x3
        jng short .13
        mov word [bp - 0x74], 0xffff
.13:
        mov es, [g_8B64]
        mov bx, [g_29CA]
        shl bx, 1
        mov ax, [es:bx + 0x128]
        mov bx, [g_29CC]
        shl bx, 1
        or ax, [es:bx + 0x128]
        mov [bp - 0x44], ax
        mov word [bp - 0x6c], 0x1
        mov es, [g_8B62]
        cmp word [es:0x78c], 0x428
        jl short .14
        mov word [bp - 0x6c], 0x2
.14:
        push word [bp - 0x74]
        push word [bp - 0x6c]
        push ax
        mov ax, [es:0x78c]
        sub ax, 0x3f0
        mov cx, 0x7
        cwd
        idiv cx
        inc dx
        push dx
        push word [bp - 0x3e]
        call 0x0EDC:AnnouncePlayoffResult
        add sp, 0xa
.15:
        cmp word [bp - 0x70], 0x0
        jnz short .16
        jmp near .19
.16:
        call 0x03A3:CallCountStep
        sub [bp - 0x4], ax
        js short .17
        jmp near .19
.17:
        call 0x1B35:LoadPPVFilesThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadScoreboardArtThunk
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        call 0x0F99:FlushInputEvents
        call 0x0BFE:InputShutdown
        lea ax, [bp - 0x1e]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        mov ax, [bp - 0x42]
        mov [g_B092], ax
        mov ax, [bp - 0x6a]
        mov [g_B094], ax
        mov word [deferpending], 0x0
        push word [bp - 0x76]
        push word [bp - 0x72]
        call 0x03A3:MouseMove
        add sp, 0x4
        lea ax, [bp - 0x390]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0000:VgaPageFlip
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
.18:
        push word [DbSaveMode]
        call 0x1B35:SetStatsMenuTextThunk
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.19:
        mov word [bp - 0x90], 0x0
.20:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .21
        lea cx, [bp - 0x40]
        push cx
        lea cx, [bp - 0x3c]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x90], ax
        test byte [bp - 0x90], 0x2
        jz short .20
.21:
        test byte [bp - 0x90], 0x2
        jz short .22
        jmp near .28
.22:
        mov ax, [bp - 0x52]
        cmp [bp - 0x3c], ax
        jnz short .23
        mov ax, [bp - 0x64]
        cmp [bp - 0x40], ax
        jnz short .23
        jmp near .15
.23:
        mov word [bp - 0x70], 0x0
        call 0x0FEF:UseCurrentPage
        cmp word [bp - 0x64], 0xb0
        jnl short .27
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x64]
        cmp ax, 0xb0
        jl short .24
        mov ax, 0xb0
        sub ax, [bp - 0x64]
        push ax
        jmp short .25
.24:
        push word [es:bx + 0x2]
.25:
        mov ax, [es:bx]
        inc ax
        inc ax
        push ax
        push word [bp - 0x64]
        mov ax, [bp - 0x52]
        sub ax, strict word 0x4
.26:
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyRect
        add sp, 0xc
.27:
        push word [bp - 0x40]
        push word [bp - 0x3c]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x3c]
        mov [bp - 0x52], ax
        mov ax, [bp - 0x40]
        mov [bp - 0x64], ax
        jmp near .15
        db 0x90
.28:
        mov word [bp - 0x70], 0x0
        lea ax, [bp - 0x6e]
        push ax
        lea cx, [bp - 0x46]
        push cx
        lea dx, [bp - 0x3a]
        push dx
        lea dx, [bp - 0x50]
        push dx
        push word [bp - 0x48]
        lea dx, [bp - 0x62]
        push dx
        push word [bp - 0x40]
        push word [bp - 0x3c]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .29
        jmp near .64
.29:
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les si, [bp + si - 0x62]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .30
        jmp near .50
.30:
        mov ax, [bp - 0x6e]
        mov si, [bp - 0x46]
        shl si, 1
        cmp [bp + si - 0x7e], ax
        jz short .31
        jmp near .43
.31:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x48]
        mov [bp - 0x66], ax
        jmp short .34
.32:
        mov si, [bp - 0x66]
        shl si, 1
        mov word [bp + si - 0x7e], 0x0
        mov si, [bp - 0x66]
        shl si, byte 0x2
        mov ax, [bp + si - 0x8c]
        or ax, [bp + si - 0x8e]
        jz short .33
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        push word [bp + si - 0x8c]
        push word [bp + si - 0x8e]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x38], ax
        mov [bp + si - 0x3a], ax
        push word [bp + si - 0x8c]
        push word [bp + si - 0x8e]
        call 0x06E1:FindUnlink
        add sp, 0x4
.33:
        dec word [bp - 0x66]
.34:
        cmp word [bp - 0x66], 0x0
        jg short .32
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les si, [bp + si - 0x62]
        call far [es:bx + si + 0xc]
        mov [bp - 0x90], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x5e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov [bp - 0x8e], ax
        mov [bp - 0x48], ax
        mov [bp - 0x78], ax
        mov [bp - 0x7a], ax
        mov [bp - 0x7c], ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        cmp word [bp - 0x90], 0x1
        jz short .35
        cmp word [bp - 0x90], 0x5
        jz short .35
        jmp near .37
.35:
        call 0x0F99:FlushInputEvents
        call 0x0BFE:InputShutdown
        lea ax, [bp - 0x1e]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        mov ax, [bp - 0x42]
        mov [g_B092], ax
        mov ax, [bp - 0x6a]
        mov [g_B094], ax
        mov word [deferpending], 0x0
        push word [bp - 0x76]
        push word [bp - 0x72]
        call 0x03A3:MouseMove
        add sp, 0x4
        lea ax, [bp - 0x390]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0000:VgaPageFlip
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        cmp word [bp - 0x90], 0x1
        jnz short .36
        jmp near .18
.36:
        mov es, [g_8B66]
        mov word [es:0x126], 0x2
        jmp near .18
        db 0x90
.37:
        cmp word [bp - 0x90], 0x2
        jz short .38
        jmp near .42
.38:
        lea ax, [bp - 0x390]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        cmp word [CurPage], 0x0
        jnz short .39
        call 0x0FEF:CopyPlane
.39:
        call 0x0FEF:UseCurrentPage
        push strict word str_Desk_13
        push 0x0
        push word 0xc242
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x2a], ax
        mov [bp - 0x28], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x26], ax
        mov [bp - 0x24], dx
        push dx
        push ax
        call 0x0FEF:DrawRleBody
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push word 0xff58
        push 0x0
        push word [bp - 0x24]
        push word [bp - 0x26]
        call 0x0FEF:DrawRleAt
        add sp, 0x8
        push strict word str_Pal_59
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x22], ax
        mov [bp - 0x20], dx
        mov word [bp - 0x66], 0x0
        mov es, [bp - 0x20]
.40:
        mov bx, [bp - 0x22]
        mov si, [bp - 0x66]
        mov al, [es:bx + si]
        mov [bp + si - 0x390], al
        inc word [bp - 0x66]
        cmp word [bp - 0x66], 0x180
        jl short .40
        mov word [bp - 0x66], 0x2f1
        mov es, [bp - 0x20]
.41:
        mov bx, [bp - 0x22]
        mov si, [bp - 0x66]
        mov al, [es:bx + si]
        mov [bp + si - 0x390], al
        inc word [bp - 0x66]
        cmp word [bp - 0x66], 0x2fd
        jl short .41
        push word [bp - 0x28]
        push word [bp - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        call 0x0FEF:UseCurrentPage
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x5
        push 0xb
        push 0x11
        push word [bp - 0x50]
        push word [bp - 0x60]
        push word [bp - 0x62]
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x10
        lea ax, [bp - 0x390]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.42:
        call 0x0FEF:UseCurrentPage
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word [bp - 0x64]
        push word [bp - 0x52]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0x96
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x64]
        push word [bp - 0x52]
        call 0x03A3:MouseMove
        add sp, 0x4
        call 0x0F99:FlushInputEvents
        jmp near .68
.43:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x48]
        cmp [bp - 0x46], ax
        jz short .47
        mov [bp - 0x66], ax
        jmp short .46
.44:
        mov si, [bp - 0x66]
        shl si, 1
        mov word [bp + si - 0x7e], 0x0
        mov di, [bp - 0x66]
        shl di, byte 0x2
        mov ax, [bp + di - 0x8c]
        or ax, [bp + di - 0x8e]
        jz short .45
        push word [bp + di - 0x38]
        push word [bp + di - 0x3a]
        push word [bp + di - 0x8c]
        push word [bp + di - 0x8e]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x38], ax
        mov [bp + di - 0x3a], ax
        push word [bp + di - 0x8c]
        push word [bp + di - 0x8e]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x8c], ax
        mov [bp + di - 0x8e], ax
        mov [bp + di - 0x60], ax
        mov [bp + di - 0x62], ax
        mov [bp + si - 0x50], ax
.45:
        dec word [bp - 0x66]
.46:
        mov ax, [bp - 0x46]
        cmp [bp - 0x66], ax
        jg short .44
        mov [bp - 0x48], ax
.47:
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x46]
        shl si, byte 0x2
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        mov si, [bp - 0x46]
        shl si, 1
        imul cx, [bp + si - 0x7e], 0x16
        db 0x03, 0xC1                           ; insn: add ax, cx
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x46]
        shl si, byte 0x2
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp - 0x6e]
        mov di, [bp - 0x46]
        shl di, 1
        mov [bp + di - 0x7e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        push dx
        push ax
.48:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
.49:
        call 0x0FEF:UseCurrentPage
        jmp near .68
        db 0x90
.50:
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les si, [bp + si - 0x62]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .51
        jmp near .60
.51:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x48]
        cmp [bp - 0x46], ax
        jz short .55
        mov [bp - 0x66], ax
        jmp short .54
.52:
        mov si, [bp - 0x66]
        shl si, 1
        mov word [bp + si - 0x7e], 0x0
        mov di, [bp - 0x66]
        shl di, byte 0x2
        mov ax, [bp + di - 0x8c]
        or ax, [bp + di - 0x8e]
        jz short .53
        push word [bp + di - 0x38]
        push word [bp + di - 0x3a]
        push word [bp + di - 0x8c]
        push word [bp + di - 0x8e]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x38], ax
        mov [bp + di - 0x3a], ax
        push word [bp + di - 0x8c]
        push word [bp + di - 0x8e]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x8c], ax
        mov [bp + di - 0x8e], ax
        mov [bp + di - 0x60], ax
        mov [bp + di - 0x62], ax
        mov [bp + si - 0x50], ax
.53:
        dec word [bp - 0x66]
.54:
        mov ax, [bp - 0x46]
        cmp [bp - 0x66], ax
        jg short .52
        mov [bp - 0x48], ax
.55:
        call 0x0FEF:UseOtherPage
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x48]
        shl si, byte 0x2
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        mov di, [bp - 0x48]
        shl di, 1
        imul cx, [bp + di - 0x7e], 0x16
        db 0x03, 0xC1                           ; insn: add ax, cx
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp - 0x6e]
        mov [bp + di - 0x7e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les di, [bp + si - 0x62]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x48]
        mov di, [bp - 0x48]
        shl di, byte 0x2
        mov [bp + di - 0x62], ax
        mov [bp + di - 0x60], dx
        les si, [bp + si - 0x62]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov di, [bp - 0x48]
        shl di, 1
        mov [bp + di - 0x50], ax
        mov [bp - 0x398], si
        mov [bp - 0x396], es
        cmp word [bp - 0x48], 0x1
        jz short .56
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, [es:bx + 0x4]
        jmp short .57
        db 0x90
.56:
        imul si, [bp - 0x6e], 0x16
        mov di, [bp - 0x46]
        shl di, byte 0x2
        les bx, [bp + di - 0x62]
        mov ax, [es:bx + si]
.57:
        mov [bp - 0x392], ax
        mov si, [bp - 0x48]
        shl si, byte 0x2
        mov ax, [bp + si - 0x3e]
        add ax, [bp - 0x392]
        mov [bp + si - 0x3a], ax
        cmp word [bp - 0x48], 0x1
        jz short .58
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les si, [bp + si - 0x62]
        mov ax, [es:bx + si + 0x2]
        jmp short .59
        db 0x90
.58:
        imul bx, [bp - 0x6e], 0x16
        mov si, [bp - 0x46]
        shl si, byte 0x2
        les si, [bp + si - 0x62]
        mov ax, [es:bx + si + 0x6]
.59:
        mov [bp - 0x394], ax
        mov si, [bp - 0x48]
        shl si, byte 0x2
        mov ax, [bp + si - 0x3c]
        add ax, [bp - 0x394]
        mov [bp + si - 0x38], ax
        les bx, [bp + si - 0x62]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov di, [bp - 0x48]
        shl di, 1
        imul cx, [bp + di - 0x50], 0x16
        mov [bp - 0x39c], bx
        mov [bp - 0x39a], es
        db 0x03, 0xD9                           ; insn: add bx, cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:bx - 0x12]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov [bp - 0x6], ax
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov dx, es
        mov bx, [bp - 0x39c]
        push ax
        mov ax, [es:bx + 0x2]
        mov [bp - 0x39e], ax
        pop ax
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov cx, [es:bx - 0x10]
        sub cx, [bp - 0x39e]
        inc cx
        mov [bp - 0x68], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_8
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x8e], ax
        mov [bp + si - 0x8c], dx
        lea ax, [bp + si - 0x8e]
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
        mov cx, [bp - 0x6]
        mov [es:bx], cx
        mov cx, [bp - 0x68]
        mov [es:bx + 0x2], cx
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        push dx
        push ax
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        push word [bp + di - 0x50]
        push word [bp + si - 0x60]
        push word [bp + si - 0x62]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x7e], 0x0
        push 0x5
        push 0xb
        push 0x11
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        push word [bp + si - 0x60]
        push word [bp + si - 0x62]
        jmp near .48
.60:
        call 0x0FEF:UseOtherPage
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x46]
        shl si, byte 0x2
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        mov si, [bp - 0x46]
        shl si, 1
        imul cx, [bp + si - 0x7e], 0x16
        db 0x03, 0xC1                           ; insn: add ax, cx
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push 0x5
        push 0xb
        push 0x11
        mov si, [bp - 0x46]
        shl si, byte 0x2
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        mov ax, [bp - 0x6e]
        mov di, [bp - 0x46]
        shl di, 1
        mov [bp + di - 0x7e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x62]
        mov dx, [bp + si - 0x60]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        call 0x0FEF:CopyPlane
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
        cmp word [bp - 0x64], 0xb0
        jl short .61
        jmp near .49
.61:
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        add ax, [bp - 0x64]
        cmp ax, 0xb0
        jl short .62
        mov ax, 0xb0
        sub ax, [bp - 0x64]
        push ax
        jmp short .63
.62:
        push word [es:bx + 0x2]
.63:
        mov ax, [es:bx]
        inc ax
        inc ax
        push ax
        push word [bp - 0x64]
        mov ax, [bp - 0x52]
        sub ax, strict word 0x4
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push ax
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyRect
        add sp, 0xc
        jmp near .49
        db 0x90
.64:
        call 0x0FEF:UseOtherPage
        mov ax, [bp - 0x48]
        mov [bp - 0x66], ax
        jmp short .67
        db 0x90
.65:
        mov si, [bp - 0x66]
        shl si, 1
        mov word [bp + si - 0x7e], 0x0
        mov si, [bp - 0x66]
        shl si, byte 0x2
        mov ax, [bp + si - 0x8c]
        or ax, [bp + si - 0x8e]
        jz short .66
        push word [bp + si - 0x38]
        push word [bp + si - 0x3a]
        push word [bp + si - 0x8c]
        push word [bp + si - 0x8e]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x38], ax
        mov [bp + si - 0x3a], ax
        push word [bp + si - 0x8c]
        push word [bp + si - 0x8e]
        call 0x06E1:FindUnlink
        add sp, 0x4
.66:
        dec word [bp - 0x66]
.67:
        cmp word [bp - 0x66], 0x0
        jg short .65
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x5e], ax
        mov [bp - 0x80], ax
        mov [bp - 0x82], ax
        mov [bp - 0x84], ax
        mov [bp - 0x86], ax
        mov [bp - 0x88], ax
        mov [bp - 0x8a], ax
        mov [bp - 0x8c], ax
        mov [bp - 0x8e], ax
        mov [bp - 0x48], ax
        mov [bp - 0x78], ax
        mov [bp - 0x7a], ax
        mov [bp - 0x7c], ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        call 0x0FEF:CopyPlane
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
.68:
        call 0x0FEF:UseCurrentPage
        les bx, [DialogData]
        push word [es:bx + 0x2]
        mov ax, [es:bx]
        inc ax
        inc ax
        push ax
        push word [bp - 0x64]
        mov ax, [bp - 0x52]
        jmp near .26

;-----------------------------------------------------------------------------
; DeskReloadGame                                             2CF8:0E04  94 PC
; Reloads crests and team palettes after the desk.
;
; Calls VgaCopyBytes, SetStartPage, UseOffscreenCanvas, BuildPathFar, LoadPackedHeader, SetRemapTable,
; FindFarMsg, DrawRleTransRemapAt and others. Far routine (retf).
;-----------------------------------------------------------------------------
DeskReloadGame:
        enter 0x1a0, 0x0
        push di
        push si
        push strict word str_Bkgd_10
        push word 0x79d0
        push 0x0
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Crests4_7
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
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        mov al, 0x11
        mov [g_B207], al
        mov [g_B107], al
        push ds
        push strict word TeamPalette2
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0x4
        push 0x4
        mov bx, [g_29CA]
        shl bx, 1
        push word [bx + g_5604]
        push word [bp - 0x10]
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        push ds
        push strict word TeamPalette1
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        push 0x4
        push word 0x11c
        mov bx, [g_29CC]
        shl bx, 1
        push word [bx + g_5604]
        push word [bp - 0x10]
        push si
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransRemapAt
        add sp, 0x8
        mov al, 0x43
        mov [g_B207], al
        mov [g_B107], al
        push word [bp - 0x10]
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push strict word str_HomepalsBin_4
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        imul cx, [g_29CA], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x12], si
        mov si, [bp - 0x2]
        mov [bp - 0xa], di
        mov es, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0x1a0], al
        inc si
        cmp si, 0xc0
        jl short .1
        mov si, [bp - 0x12]
        push word [bp - 0x10]
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push strict word str_AwaypalsBin_3
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        imul cx, [g_29CC], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x12], si
        mov si, [bp - 0x2]
        mov [bp - 0xa], di
        mov es, dx
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [bp + si - 0xe0], al
        inc si
        cmp si, 0xc0
        jl short .2
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x06E1:FindUnlink
        add sp, 0x4
        lea ax, [bp - 0x1a0]
        push ss
        push ax
        push word 0x80
        push word 0x80
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskBackToGame                                             2CF8:0F98  94 PC
; Menu item: back to the game.
;
; Calls LoadPPVFilesThunk, LoadRinkEndArtThunk, LoadScoreboardArtThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskBackToGame:
        call 0x1B35:LoadPPVFilesThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadScoreboardArtThunk
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskToSportsDesk                                           2CF8:0FB2  94 PC
; Menu item: to the sports desk.
;
; Calls LoadPPVFilesThunk, LoadRinkEndArtThunk, LoadScoreboardArtThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskToSportsDesk:
        call 0x1B35:LoadPPVFilesThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadScoreboardArtThunk
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        mov ax, 0x5
        retf

;-----------------------------------------------------------------------------
; DeskReturnConfirm                                          2CF8:0FCE  94 PC
; Confirmation box.
;
; Calls MouseRead, SetDialogColors, MessageBox, LoadPPVFilesThunk, LoadRinkEndArtThunk,
; LoadScoreboardArtThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskReturnConfirm:
        enter 0x6, 0x0
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [DbSaveMode]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        dec ax
        jz short .2
        dec ax
        jz short .3
        jmp short .4
        db 0x90
.1:
        mov es, [g_8B68]
        mov word [es:0xb3], 0x0
        mov word [es:0xb5], 0x36f5
        jmp short .4
.2:
        mov es, [g_8B68]
        mov word [es:0xb3], 0x3d
        mov word [es:0xb5], 0x36f5
        jmp short .4
.3:
        mov es, [g_8B68]
        mov word [es:0xb3], 0x1c
        mov word [es:0xb5], 0x36f5
.4:
        mov es, [g_8B68]
        mov word [es:0xbb], 0x87
        mov word [es:0xbd], 0x36f5
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x2
        push word 0x36b8
        push strict word f_36B8_0170
        push 0x3
        push word 0x36f5
        push strict word f_36F5_00B3
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .5
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.5:
        call 0x1B35:LoadPPVFilesThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadScoreboardArtThunk
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        mov ax, 0x5
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskExitGame                                               2CF8:10A4  94 PC
; Quits to DOS.
;
; Calls MouseRead, SetDialogColors, MessageBox, GetPaletteFar, FadePaletteInThunk, SetStartPage,
; FindUnlink, AllocCanvases and others. Far routine (retf).
;-----------------------------------------------------------------------------
DeskExitGame:
        enter 0x30a, 0x0
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov es, [g_8B68]
        mov word [es:0xb3], 0x5b
        mov word [es:0xb5], 0x36f5
        mov word [es:0xbb], 0x9e
        mov word [es:0xbd], 0x36f5
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x2
        push word 0x36b8
        push strict word f_36B8_0170
        push 0x3
        push word 0x36f5
        push strict word f_36F5_00B3
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jg short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.1:
        lea ax, [bp - 0x306]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x306]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, 0x7570
        mov es, [g_8B6A]
        mov [bp - 0x30a], bx
        mov [bp - 0x308], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .2
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x30a]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.2:
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
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        call 0x0FEF:CopyPlane
.3:
        call 0x1F9D:GoodnightScreen
        lea ax, [bp - 0x306]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x306]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        call 0x0000:_exit
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskGoToReplay                                             2CF8:1206  94 PC
; Instant replay.
;
; Calls LoadScoreboardArtThunk, LoadRinkEndArtThunk, LoadPPVFilesThunk, InstantReplayThunk,
; UseCharSeg, FreePPVFilesThunk, FindUnlink. Far routine (retf).
;-----------------------------------------------------------------------------
DeskGoToReplay:
        enter 0x2, 0x0
        call 0x1B35:LoadScoreboardArtThunk
        call 0x1B35:LoadRinkEndArtThunk
        call 0x1B35:LoadPPVFilesThunk
        mov ax, 0xc
        mov dx, 0x3d4
        out dx, al
        mov dx, 0x3d5
        in al, dx
        mov [bp - 0x2], al
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        mov dx, 0x3d5
        in al, dx
        mov [bp - 0x1], al
        push 0x0
        call 0x1B35:InstantReplayThunk
        add sp, 0x2
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x1B35:FreePPVFilesThunk
        push word [g_C25E]
        push word [g_C25C]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_C25A]
        push word [g_C258]
        call 0x06E1:FindUnlink
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        mov ax, 0xc
        mov dx, 0x3d4
        out dx, al
        mov al, [bp - 0x2]
        cbw
        mov dx, 0x3d5
        out dx, al
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        mov al, [bp - 0x1]
        cbw
        mov dx, 0x3d5
        out dx, al
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        mov ax, 0x2
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskHomeLines                                              2CF8:12AA  94 PC
; Home line editor.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, MouseRange, VgaCopyBytes,
; GameLineEditor. Far routine (retf).
;-----------------------------------------------------------------------------
DeskHomeLines:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_58
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
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x2
        push word 0x3448
        push strict word f_3448_1584
        push word 0xae10
        push 0x0
        call 0x2047:GameLineEditor
        add sp, 0xa
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_57
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
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x96
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskVisitorLines                                           2CF8:1388  94 PC
; Visitor line editor.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, MouseRange, VgaCopyBytes,
; GameLineEditor. Far routine (retf).
;-----------------------------------------------------------------------------
DeskVisitorLines:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_56
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
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push 0x2
        push word 0x3448
        push strict word f_3448_1584
        push word 0xae40
        push 0x1
        call 0x2047:GameLineEditor
        add sp, 0xa
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_55
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
        push word 0x3860
        push word 0xb00
        push word 0x4400
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x96
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        mov ax, 0x2
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskGameStats                                              2CF8:1466  94 PC
; Team stats screen.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, VgaCopyBlock, SaveVgaPlanes,
; ShowTeamStatsThunk, RestoreVgaPlanes. Far routine (retf).
;-----------------------------------------------------------------------------
DeskGameStats:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_54
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
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0F4A:SaveVgaPlanes
        call 0x1B35:ShowTeamStatsThunk
        call 0x0F4A:RestoreVgaPlanes
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov ax, 0x2
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; DeskPenaltySummary                                         2CF8:14D4  94 PC
; Penalty summary.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, VgaCopyBlock, SaveVgaPlanes,
; ShowGameSummaryThunk, RestoreVgaPlanes. Far routine (retf).
;-----------------------------------------------------------------------------
DeskPenaltySummary:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_53
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
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0F4A:SaveVgaPlanes
        push 0x0
        push word [curperiod]
        push 0x1
        push 0x2
        call 0x1B35:ShowGameSummaryThunk
        add sp, 0x8
        call 0x0F4A:RestoreVgaPlanes
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov ax, 0x2
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskScoringSummary                                         2CF8:1550  94 PC
; Scoring summary.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, VgaCopyBlock, SaveVgaPlanes,
; ShowGameSummaryThunk, RestoreVgaPlanes. Far routine (retf).
;-----------------------------------------------------------------------------
DeskScoringSummary:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_52
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
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0F4A:SaveVgaPlanes
        push 0x0
        push word [curperiod]
        push 0x1
        push 0x1
        call 0x1B35:ShowGameSummaryThunk
        add sp, 0x8
        call 0x0F4A:RestoreVgaPlanes
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov ax, 0x2
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskTeamScratches                                          2CF8:15CC  94 PC
; Game summary page.
;
; Calls AllocRecData, GetPaletteFar, FadePaletteInThunk, FindUnlink, VgaCopyBlock, SaveVgaPlanes,
; ShowGameSummaryThunk, RestoreVgaPlanes. Far routine (retf).
;-----------------------------------------------------------------------------
DeskTeamScratches:
        push di
        push si
        push 0x0
        push 0x0
        push word 0x300
        push strict word str_Pal_51
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
        push 0x0
        push word 0x7c60
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        call 0x0F4A:SaveVgaPlanes
        push 0x0
        push 0x0
        push 0x0
        push 0x4
        call 0x1B35:ShowGameSummaryThunk
        add sp, 0x8
        call 0x0F4A:RestoreVgaPlanes
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        mov ax, 0x2
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeskHomeGoalie1                                            2CF8:1646  94 PC
; Home goalie 1.
;
; Calls SetTeamGoalieThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskHomeGoalie1:
        push 0x0
        push 0x0
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6C]
        les bx, [es:0x12f8]
        mov byte [es:bx], 0x1
        mov es, [g_8B6C]
        les bx, [es:0x130e]
        mov byte [es:bx], 0x2
        mov es, [g_8B6C]
        les bx, [es:0x1324]
        mov byte [es:bx], 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; DeskHomeGoalie2                                            2CF8:167C  94 PC
; Home goalie 2.
;
; Calls SetTeamGoalieThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskHomeGoalie2:
        push 0x1
        push 0x0
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6C]
        les bx, [es:0x12f8]
        mov byte [es:bx], 0x2
        mov es, [g_8B6C]
        les bx, [es:0x130e]
        mov byte [es:bx], 0x1
        mov es, [g_8B6C]
        les bx, [es:0x1324]
        mov byte [es:bx], 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; DeskHomeGoalieNone                                         2CF8:16B2  94 PC
; Pull the home goalie.
;
; Calls SetTeamGoalieThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskHomeGoalieNone:
        push -0x1
        push 0x0
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6C]
        les bx, [es:0x12f8]
        mov byte [es:bx], 0x2
        mov es, [g_8B6C]
        les bx, [es:0x130e]
        mov byte [es:bx], 0x2
        mov es, [g_8B6C]
        les bx, [es:0x1324]
        mov byte [es:bx], 0x1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; DeskAwayGoalie1                                            2CF8:16E8  94 PC
; Away goalie 1.
;
; Calls SetTeamGoalieThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskAwayGoalie1:
        push 0x0
        push 0x1
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6E]
        les bx, [es:0x133a]
        mov byte [es:bx], 0x1
        mov es, [g_8B6E]
        les bx, [es:0x1350]
        mov byte [es:bx], 0x2
        mov es, [g_8B6E]
        les bx, [es:0x1366]
        mov byte [es:bx], 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; DeskAwayGoalie2                                            2CF8:171E  94 PC
; Away goalie 2.
;
; Calls SetTeamGoalieThunk. Far routine (retf).
;-----------------------------------------------------------------------------
DeskAwayGoalie2:
        push 0x1
        push 0x1
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6E]
        les bx, [es:0x133a]
        mov byte [es:bx], 0x2
        mov es, [g_8B6E]
        les bx, [es:0x1350]
        mov byte [es:bx], 0x1
        mov es, [g_8B6E]
        les bx, [es:0x1366]
        mov byte [es:bx], 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf

;-----------------------------------------------------------------------------
; DeskAwayGoalieNone                                         2CF8:1754  94 PC
; Pull the away goalie.
;
; Calls SetTeamGoalieThunk.
;-----------------------------------------------------------------------------
DeskAwayGoalieNone:
        push -0x1
        push 0x1
        call 0x1B35:SetTeamGoalieThunk
        add sp, 0x4
        mov es, [g_8B6E]
        les bx, [es:0x133a]
        mov byte [es:bx], 0x2
        mov es, [g_8B6E]
        les bx, [es:0x1350]
        mov byte [es:bx], 0x2
        mov es, [g_8B6E]
        les bx, [es:0x1366]
