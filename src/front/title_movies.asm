; Title movies at start-up (INIT.OVL)
; The first bytes finish the last routine of end_game.asm.
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayTitleMovies                                            23CB:0004  94 PC
; P1.MVI, EASCRN.QPP, G1.MVI, logo.
;
; Takes 3 words of stack arguments. Calls _strcpy, _strcat, VgaCopyBytes, VgaPageFlip, VgaCopyBlock,
; GetPaletteFar, FadePalette, SetStartPage and others. Far routine (retf).
;-----------------------------------------------------------------------------
PlayTitleMovies:
        enter 0x30, 0x0
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [MovieBufSeg], ax
        mov [MovieBuf], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        cmp [bp + 0xa], ax
        jnz short .1
        jmp near .12
.1:
        cmp [bp + 0x6], ax
        jz short .2
        mov bx, [VisTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        push word 0x4fe2
        jmp short .3
        db 0x90
.2:
        mov bx, [HomeTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        push word 0x4fe4
.3:
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        push strict word str_P1Mvi
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        mov ax, 0x1
        mov es, [segWorkBuffer51]
        mov bx, [bp + 0x6]
        shl bx, byte 0x3
        mov [es:bx - 0x499c], ax
.4:
        mov [bp - 0x26], ax
        cmp word [CurPage], 0x0
        jnz short .5
        push word 0x3860
        push word 0x4400
        push word 0xb00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0000:VgaPageFlip
.5:
        push word 0x7c60
        push 0x0
        call 0x0000:VgaCopyBlock
        add sp, 0x4
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x8
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        mov word [bp - 0x28], 0x0
        mov es, [segWorkBuffer53]
.6:
        mov bx, [bp - 0x28]
        mov byte [es:bx - 0x4992], 0x0
        inc word [bp - 0x28]
        cmp word [bp - 0x28], 0x300
        jl short .6
        cmp word [bp - 0x26], 0x0
        jnz short .7
        jmp near .18
.7:
        push word 0x3a0b
        push strict word MovieState
        push 0x2
        lea ax, [bp - 0x20]
        push ax
        call 0x1B35:MviOpenThunk
        add sp, 0x8
        mov [MovieBuf], ax
        mov [MovieBufSeg], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [MovieBuf]
        jz short .8
        jmp near .21
.8:
        mov word [bp - 0x26], 0x0
.9:
        push 0x0
        push 0x0
        push strict word str_Scrn
        push 0x0
        push strict word str_EascrnQpp
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x2c], ax
        mov [bp - 0x2a], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastAt
        add sp, 0x8
        push strict word str_Pal_3
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        mov word [bp - 0x28], 0x0
.10:
        les bx, [bp - 0x30]
        mov si, [bp - 0x28]
        mov al, [es:bx + si]
        mov es, [segWorkBuffer53]
        mov [es:si - 0x4992], al
        inc word [bp - 0x28]
        cmp word [bp - 0x28], 0x30
        jl short .10
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [bp - 0x22]
        or ax, [bp - 0x24]
        jnz short .11
        jmp near .22
.11:
        push 0x22
        push 0xf
        push strict word str_0000
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleFastAt
        add sp, 0x8
        push word [bp - 0x22]
        push word [bp - 0x24]
        call 0x06E1:FindUnlink
        add sp, 0x4
        jmp near .23
.12:
        imul ax, [bp + 0x6], 0x1c
        add ax, [bp + 0x8]
        imul bx, ax, 0x28
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov es, [segWorkBuffer52]
        mov bx, [bp + 0x6]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shl bx, 1
        db 0x03, 0xD9                           ; insn: add bx, cx
        shl bx, 1
        cmp ax, [es:bx - 0x49ae]
        jz short .13
        jmp near .17
.13:
        mov es, [segWorkBuffer51]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        shl bx, byte 0x3
        cmp word [es:bx - 0x49a2], 0x0
        jl short .14
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90
.14:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jz short .15
        mov bx, [VisTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        push word 0x4fed
        jmp short .16
        db 0x90
.15:
        mov bx, [HomeTeamNum]
        shl bx, 1
        push word [bx + TeamNameClips]
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        push word 0x4fef
.16:
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        push strict word str_G1Mvi
        lea ax, [bp - 0x20]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        mov ax, 0x1
        mov es, [segWorkBuffer51]
        mov bx, [bp + 0x6]
        shl bx, byte 0x3
        mov [es:bx - 0x49a2], ax
        jmp near .4
        db 0x90
.17:
        mov ax, 0x1
        pop si
        leave
        retf
.18:
        push 0x0
        lea ax, [bp - 0x20]
        push ax
        call 0x14B8:LoadPackedHeader0
        add sp, 0x4
        mov [bp - 0x24], ax
        mov [bp - 0x22], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .19
        jmp near .8
.19:
        push strict word str_Pal_4
        push word [bp - 0x22]
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        mov word [bp - 0x28], 0x78
.20:
        les bx, [bp - 0x30]
        mov si, [bp - 0x28]
        mov al, [es:bx + si]
        mov es, [segWorkBuffer53]
        mov [es:si - 0x4992], al
        inc word [bp - 0x28]
        cmp word [bp - 0x28], 0x300
        jl short .20
.21:
        mov word [bp - 0x26], 0x1
        jmp near .9
.22:
        push 0x25
        push 0x64
        push word 0xa0
        push 0x22
        push 0xf
        call 0x0FEF:FillRect
        add sp, 0xa
.23:
        push strict word str_Stop
        lea ax, [bp - 0x10]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        cmp word [bp + 0x6], 0x0
        jz short .26
        cmp word [VisTeamNum], 0x18
        jnl short .25
        mov bx, [VisTeamNum]
.24:
        shl bx, 1
        push word [bx + TeamNameClips]
        jmp short .29
        db 0x90
.25:
        mov bx, [VisTeamNum]
        jmp short .28
.26:
        cmp word [HomeTeamNum], 0x18
        jnl short .27
        mov bx, [HomeTeamNum]
        jmp short .24
        db 0x90
.27:
        mov bx, [HomeTeamNum]
.28:
        shl bx, 1
        push word [bx + 0x1e4]
.29:
        lea ax, [bp - 0x10]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        push strict word str_Qpp_2
        lea ax, [bp - 0x10]
        push ax
        call 0x0000:_strcat
        add sp, 0x4
        push 0x54
        push word 0xf8
        push strict word str_Logo
        push 0x0
        lea ax, [bp - 0x10]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x2c], ax
        mov [bp - 0x2a], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        push dx
        push ax
        call 0x0FEF:DrawRleTransFast
        add sp, 0x8
        push strict word str_Pal_2
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        mov word [bp - 0x28], 0x30
.30:
        les bx, [bp - 0x30]
        mov si, [bp - 0x28]
        mov al, [es:bx + si]
        mov es, [segWorkBuffer53]
        mov [es:si - 0x4992], al
        inc word [bp - 0x28]
        cmp word [bp - 0x28], 0x60
        jl short .30
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov al, 0x3f
        mov es, [segWorkBuffer53]
        mov [es:hilightrec_frames + 0xA901], al
        mov [es:hilightrec_frames + 0xA8FB], al
        mov [es:hilightrec_frames + 0xA8F9], al
        mov [es:hilightrec_frames + 0xA8F8], al
        mov al, 0x39
        mov [es:hilightrec_frames + 0xA8FE], al
        mov [es:hilightrec_frames + 0xA8FC], al
        mov byte [es:hilightrec_frames + 0xA8FF], 0x2e
        mov al, 0x3c
        mov [es:hilightrec_frames + 0xA906], al
        mov [es:hilightrec_frames + 0xA905], al
        mov [es:hilightrec_frames + 0xA904], al
        mov ax, [bp - 0x26]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayMovie                                                  23CB:042C  94 PC
; Plays an .MVI ('vidframe') at a fixed frame rate.
;
; Calls SetStartPage, FadePalette, AllocRecData, MviNextFrameThunk, PlanarToLinearThunk, PutBlockAt,
; __aFldiv, WaitDeadlineNoEoi and others. Far routine (retf).
;-----------------------------------------------------------------------------
PlayMovie:
        enter 0x4, 0x0
        push di
        push si
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x8
        push word 0x3a0b
        push strict word MoviePalette
        push 0x0
        call 0x1E7E:FadePalette
        add sp, 0x8
        mov ax, 0x1
        mov [DeskRedrawPage2], ax
        mov [DeskRedrawPage], ax
        mov ax, [MovieBufSeg]
        or ax, [MovieBuf]
        jnz short .1
        jmp near .3
.1:
        push 0x0
        les bx, [MovieBuf]
        mov ax, [es:bx + 0x18]
        imul word [es:bx + 0x1a]
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Vidframe
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x4]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [MovieBuf]
        mov ax, [es:bx + 0x18]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        les bx, [bp - 0x4]
        mov [es:bx], ax
        les si, [MovieBuf]
        mov ax, [es:si + 0x1a]
        les bx, [bp - 0x4]
        mov [es:bx + 0x2], ax
.2:
        push word [bp - 0x2]
        push word [bp - 0x4]
        push 0x0
        push 0x32
        push 0x5
        push word [MovieBufSeg]
        push word [MovieBuf]
        call 0x1B35:MviNextFrameThunk
        add sp, 0xa
        push dx
        push ax
        call 0x1B35:PlanarToLinearThunk
        add sp, 0x8
        push 0x22
        push 0xf
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        les bx, [MovieBuf]
        mov ax, [es:bx + 0x12]
        cwd
        push dx
        push ax
        push 0x0
        push 0x64
        call 0x0000:__aFldiv
        call 0x03A3:SetDeadline.regs
        call 0x03A3:WaitDeadlineNoEoi
        les bx, [MovieBuf]
        cmp word [es:bx + 0x20], 0x0
        jnz short .2
        mov ax, [es:bx + 0x12]
        cwd
        push dx
        push ax
        push dx
        push ax
        push -0x1
        push -0x64
        call 0x0000:__aFldiv
        push dx
        push ax
        call 0x0000:__aFlmul
        add ax, 0x190
        adc dx, 0x0
        call 0x03A3:SetDeadline.regs
        call 0x03A3:WaitDeadlineNoEoi
        push word [MovieBufSeg]
        push word [MovieBuf]
        call 0x1B35:MviCloseThunk
        add sp, 0x4
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        jmp short .4
.3:
        mov ax, 0x190
        cwd
        call 0x03A3:SetDeadline.regs
        call 0x03A3:WaitDeadlineNoEoi
.4:
        push 0x8
        push word 0x3a0b
        push strict word MoviePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
