; Loads the team crests palette (STATS.OVL)
; The first bytes finish the last routine of stats_util.asm.
        push bx
        call 0x0000:_fstrcat
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadCrestsPalette                                          20E4:000E  94 PC
; CRESTS3.BIN palette into the current palette.
;
; Calls GetPaletteFar, FadePaletteInThunk, LoadRawHeader, FindUnlink, LoadPackedHeader, FindFarMsg.
; Far routine (retf).
;-----------------------------------------------------------------------------
LoadCrestsPalette:
        enter 0x312, 0x0
        push di
        push si
        lea ax, [bp - 0x312]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x312]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        push strict word str_Crests3Bin
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        mov si, 0x1e0
        mov [bp - 0x12], di
        mov ds, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        sub bx, 0x1e0
        mov al, [bx]
        mov [bp + si - 0x312], al
        inc si
        cmp si, 0x300
        jl short .1
        mov ax, DGROUP
        mov ds, ax
        push word [bp - 0x10]
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
        push strict word str_Pal_30
        push 0x0
        push word DeskTitleText
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x12], di
        mov [bp - 0xa], si
        mov si, [bp - 0x2]
        lds di, [bp - 0xa]
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx]
        mov [bp + si - 0x312], al
        inc si
        cmp si, 0x180
        jl short .2
        mov si, 0x2f1
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx]
        mov [bp + si - 0x312], al
        inc si
        cmp si, 0x2fd
        jl short .3
        mov ax, DGROUP
        mov ds, ax
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x10
        lea ax, [bp - 0x312]
        push ss
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90
