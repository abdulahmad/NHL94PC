; Plays a saved highlight (AI.OVL)

;-----------------------------------------------------------------------------
; updatereplayTail                                           2062:0001  94 PC
; The rest of updatereplay, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
updatereplayTail:
        mov [replaysfx], ax
        mov word [lastsfx], 0xffff
.1:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PlayHilight                                                2062:000E  94 PC
; Restores teams and clock from the saved highlight record, runs InstantReplay.
;
; Calls GetPaletteFar, FadePaletteInThunk, LoadTeamPalette, LoadRinkTilesThunk, LoadArenaJinglesThunk,
; LoadGameGfxThunk, InstantReplayThunk, UseCharSeg and others.
;-----------------------------------------------------------------------------
PlayHilight:
        enter 0x304, 0x0
        push di
        push si
        mov ax, 0x3a0b
        mov es, ax
        mov al, [es:hilightrec]
        mov [savedteam1], al
        mov al, [es:hilightrec_b1]
        mov [savedteam2], al
        mov al, [es:hilightrec_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [HomeTeamNum], ax
        mov al, [es:hilightrec_b1F]
        mov [VisTeamNum], ax
        mov ax, [es:hilightrec_w3C]
        mov [curperiod], ax
        mov ax, [es:hilightrec_w3E]
        mov [hudclockmin], ax
        mov ax, [es:hilightrec_w40]
        mov [hudclocksec], ax
        mov ax, [es:hilightrec_w42]
        mov [hudclockhund], ax
        mov ax, [es:hilightrec_w44]
        mov [sflags], ax
        mov ax, [es:hilightrec_w46]
        mov dx, [es:hilightrec_frames]
        add ax, [replayptr]
        adc dx, [replayseg]
        mov [replayrecptr], ax
        mov [replayrecseg], dx
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov si, 0xa556
.1:
        mov al, [es:di + hilightrec_home]
        mov [si], al
        mov al, [es:di + hilightrec_away]
        mov [si + 0x460], al
        inc di
        add si, 0x28
        cmp si, 0xa9b6
        jc short .1
        lea ax, [bp - 0x300]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x300]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0x3a0b
        push strict word TeamPalette768
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x1E64:LoadTeamPalette
        add sp, 0x8
        cmp word [HomeTeamNum], 0x18
        jl short .2
        mov cx, 0x9
        jmp short .3
.2:
        mov cx, [HomeTeamNum]
.3:
        push cx
        call 0x1B35:LoadRinkTilesThunk
        add sp, 0x2
        call 0x1B35:LoadArenaJinglesThunk
        call 0x1B35:LoadGameGfxThunk
        push 0x0
        call 0x1B35:InstantReplayThunk
        add sp, 0x2
        lea ax, [bp - 0x300]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x300]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x1B35:FreeArenaJinglesThunk
        call 0x1B35:FreePlayerFramesThunk
        push word [RinkEndArtSeg]
        push word [RinkEndArt]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [ScoreboardArtSeg]
        push word [ScoreboardArt]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [GameGfxSeg]
        push word [GameGfx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [ReplayFontSeg]
        push word [ReplayFont]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [RinkTilesSeg]
        push word [RinkTilesPtr]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [RinkTilesSeg], ax
        mov [RinkTilesPtr], ax
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x3d5
        out dx, al
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, 0x7570
        mov es, [segDgroup10]
        mov [bp - 0x304], bx
        mov [bp - 0x302], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .4
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x304]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.4:
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
        call 0x0F99:FlushInputEvents
