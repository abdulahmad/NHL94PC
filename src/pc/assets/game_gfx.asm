; Loads the game graphics (player frames, rink end art) and sets up a game (INIT.OVL)

;-----------------------------------------------------------------------------
; IndexPPVFrames                                             1F9C:0000  94 PC
; Builds FrameTable from the loaded PPV files ('%04d' lookups)
;
; Calls _sprintf, RawBase, Lookup. Far routine (retf).
;-----------------------------------------------------------------------------
IndexPPVFrames:
        enter 0xe, 0x0
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov word [bp - 0x4], PPVFiles
.1:
        mov word [bp - 0x2], 0x0
        db 0x8B, 0xF7                           ; insn: mov si, di
        shl si, byte 0x2
        add si, FrameTable
.2:
        push di
        push word 0x4b64
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0xe]
        push ax
        mov bx, [bp - 0x4]
        push word [bx + 0x2]
        push word [bx]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:Lookup
        add sp, 0x6
        add si, 0x4
        mov [si - 0x4], ax
        mov [si - 0x2], dx
        inc di
        cmp si, GameTeamRecs
        jnc short .3
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0x32
        jl short .2
        add word [bp - 0x4], 0x4
        cmp word [bp - 0x4], PPVFiles + 18 * 4
        jc short .1
.3:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadPPVFiles                                               1F9C:0072  94 PC
; Loads f00_49.PPV / f50_99.PPV and indexes their frames.
;
; Calls _sprintf, _fstrcat, LoadRawHeader, FindFarMsg. Far routine (retf).
;-----------------------------------------------------------------------------
LoadPPVFiles:
        enter 0xe, 0x0
        push di
        push si
        mov ax, [photobankf_w2]
        or ax, [photobankf]
        jz short .1
        jmp near .6
.1:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, photobankf
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .3
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push ax
        push strict word str_FD50D99
        jmp short .4
        db 0x90
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push ax
        push strict word str_FD00D49
.4:
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push word 0x3701
        push strict word str_Ppv
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x149D:LoadRawHeader
        add sp, 0x4
        add di, 0x4
        mov [di - 0x4], ax
        mov [di - 0x2], dx
        inc si
        cmp di, demoflag
        jc short .2
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov si, SpriteFrames
.5:
        push di
        push strict word str_04d_3
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0xe]
        push ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        mov cx, 0x32
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x2
        push word [bx + photobankf_w2]
        push word [bx + photobankf]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add si, 0x4
        mov [si - 0x4], ax
        mov [si - 0x2], dx
        inc di
        cmp si, gameframe
        jc short .5
.6:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadPlayerFrames                                           1F9C:0138  94 PC
; Loads the player pose files and builds both frame tables.
;
; Calls _sprintf, _fstrcat, LoadRaw, IndexPPVFrames, LoadPPVFiles. Far routine (retf).
;-----------------------------------------------------------------------------
LoadPlayerFrames:
        enter 0xe, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, PPVFiles
.1:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x2
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push ax
        push strict word str_D50D99
        jmp short .3
        db 0x90
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        push ax
        push strict word str_D00D49
.3:
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push word 0x3701
        push strict word str_Ppv
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x80
        lea ax, [bp - 0xe]
        push ax
        call 0x149D:LoadRaw
        add sp, 0x4
        add di, 0x4
        mov [di - 0x4], ax
        mov [di - 0x2], dx
        inc si
        cmp di, PPVFiles + 18 * 4
        jc short .1
        push cs
        call IndexPPVFrames
        push cs
        call LoadPPVFiles
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRinkEndArt                                             1F9C:01B4  94 PC
; Loads trinknd.QPP.
;
; Calls BuildPathFar, LoadPackedHeader, FindFarMsg. Far routine (retf).
;-----------------------------------------------------------------------------
LoadRinkEndArt:
        enter 0x10, 0x0
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Trinknd
        push 0x0
        push 0x0
        lea ax, [bp - 0x10]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x10]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [RinkEndArt], ax
        mov [RinkEndArtSeg], dx
        push strict word str_0000_2
        push dx
        push ax
        call 0x03A3:FindFarMsg
        mov [RinkEndFrames], ax
        mov [RinkEndFramesSeg], dx
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadGameGfx                                                1F9C:01FC  94 PC
; Canvases, numshp, gadgets, scoreboard, player frames, palette fade-in.
;
; Calls SetStartPage, FindUnlink, AllocCanvases, UseOffscreenCanvas, ClearClipRect, UseCurrentPage,
; LoadReplayGadgets, BuildPathFar and others. Far routine (retf).
;-----------------------------------------------------------------------------
LoadGameGfx:
        enter 0x1c, 0x0
        push di
        push si
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, PageTable
        mov es, [segDgroup8]
        mov [bp - 0x1c], bx
        mov [bp - 0x1a], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .1
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x1c]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.1:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xb0
        push word 0x148
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        call 0x0FEF:UseOffscreenCanvas
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:UseCurrentPage
        mov word [ScreenRowStride], 0x52
        call 0x28FA:LoadReplayGadgets
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Numshp
        push 0x0
        push 0x0
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x18]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [GameGfx], ax
        mov [GameGfxSeg], dx
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov si, NumberSprites
.2:
        push di
        push strict word str_04d_2
        lea ax, [bp - 0xa]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0xa]
        push ax
        push word [GameGfxSeg]
        push word [GameGfx]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add si, 0x4
        mov [si - 0x4], ax
        mov [si - 0x2], dx
        inc di
        cmp si, NumberSprites2
        jc short .2
        push word NumberSprites2
        push strict word str_000g000d000d000l000c000r000x
        push word [GameGfxSeg]
        push word [GameGfx]
        call 0x03A3:FindFarList
        add sp, 0x8
        call 0x251E:InitScoreboard
        push cs
        call LoadRinkEndArt
        mov ax, 0x4
        mov dx, 0xff
        call 0x03A3:SetCharPtr.regs
        push cs
        call LoadPlayerFrames
        call 0x0D6B:HookDivideError
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
        mov ax, 0x1
        mov [fadeinpending], ax
        mov [DeskRedrawPage2], ax
        mov [DeskRedrawPage], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PlacePlayersAtStart                                        1F9C:0348  94 PC
; Puts both teams at their opening positions.
;
; Calls forceteamsThunk, assinsert, VectorToDir8. Far routine (retf).
;-----------------------------------------------------------------------------
PlacePlayersAtStart:
        push di
        push si
        cmp word [demoflag], 0x0
        jz short .1
        jmp near .16
.1:
        call 0x1B35:forceteamsThunk
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [foy], ax
        mov [fox], ax
        mov bx, [pucky]
        mov [bx], ax
        mov bx, [pucky]
        mov ax, [bx]
        mov bx, [puckx]
        mov [bx], ax
        mov si, SortCords
        mov word [regd2], 0xc
.2:
        mov word [si + 0x2e], 0xff9c
        mov ax, [si + 0x1a]
        mov [regd1], ax
        cmp ax, strict word 0x4
        jnz short .3
        mov ax, 0x17
        jmp short .4
        db 0x90
.3:
        mov ax, 0x16
.4:
        push ax
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
        cmp word [regd1], 0x0
        jnl short .5
        jmp near .15
.5:
        test byte [si + 0x44], 0x40
        jz short .6
        mov ax, [awtmap]
        jmp short .7
.6:
        mov ax, [hmtmap]
.7:
        neg ax
        mov [regd4], ax
        add ax, strict word 0x6
        shl ax, byte 0x3
        mov [regd4], ax
        mov di, [regd1]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + di + apl]
        cbw
        mov [regd4], ax
        shl word [regd4], 1
        mov bx, [regd4]
        shl bx, 1
        mov ax, [bx + puckfaceoff2_ptab]
        mov [regd0], ax
        mov ax, [bx + puckfaceoff2_ptab_y]
        mov [regd1], ax
        test byte [si + 0x44], 0x80
        jnz short .8
        neg word [regd0]
        neg word [regd1]
.8:
        mov ax, [regd0]
        mov [si + 0x2], ax
        mov ax, [regd1]
        mov [si + 0x6], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        mov bx, [puckx]
        mov ax, [bx]
        sub ax, [regd0]
        mov bx, [pucky]
        mov dx, [bx]
        sub dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov [si + 0x36], ax
        cmp word [si + 0x1a], 0x0
        jnz short .11
        cmp byte [si + 0x59], 0x0
        jz short .9
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp short .10
        db 0x90
.9:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        neg bx
        and bx, 0x7
.10:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        add bx, 0x196
        mov [si + 0x12], bx
        mov word [regd1], 0x1
        jmp short .14
.11:
        cmp byte [si + 0x59], 0x0
        jz short .12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp short .13
.12:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        neg bx
        and bx, 0x7
.13:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, byte 0x2
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov [si + 0x12], bx
        mov word [regd1], SPAno(SPAglide)
.14:
        and byte [si + 0x45], 0xfb
        and byte [si + 0x44], 0xdf
        mov word [si + 0x3a], 0x0
        mov ax, [regd1]
        mov [si + 0x38], ax
        mov word [si + 0x3c], 0xffff
.15:
        add si, 0x80
        dec word [regd2]
        jz short .16
        jmp near .2
.16:
        pop si
        pop di
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetupGame                                                  1F9C:04A0  94 PC
; Lines, crowd, faceoff setup before the opening faceoff.
;
; Calls BuildDefaultLinesThunk, SetupTeamLinesThunk, ResetGameVars, DrawHudPanelThunk,
; StartPreGameThunk, GetPaletteFar, FadePalette, PlacePlayersAtStart. Far routine (retf).
;-----------------------------------------------------------------------------
SetupGame:
        push si
        call 0x1B35:BuildDefaultLinesThunk
        push 0x0
        call 0x1B35:SetupTeamLinesThunk
        add sp, 0x2
        push 0x1
        call 0x1B35:SetupTeamLinesThunk
        add sp, 0x2
        mov word [gsp], 0xffff
        mov word [introskipped], 0x0
        push cs
        call ResetGameVars
        push 0x1
        push 0x1
        push word [VisTeamNum]
        push word [HomeTeamNum]
        call 0x1B35:DrawHudPanelThunk
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [CrowdSound], ax
        mov [Crowdlevel], ax
        push ax
        push ax
        call 0x1B35:StartPreGameThunk
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .1
        mov ax, 0xffff
        pop si
        retf
        db 0x90
.1:
        mov si, [introskipped]
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .2
        mov word [fadeinpending], 0x1
.2:
        mov word [gsp], 0x0
        push cs
        call ResetGameVars
        mov [introskipped], si
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        push word 0x3a0b
        push strict word GamePalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word GamePalette
        push 0x1
        call 0x1E7E:FadePalette
        add sp, 0x8
.3:
        test byte [CrowdState], 0x4
        jnz short .4
        cmp word [introskipped], 0x0
        jnz short .5
.4:
        push cs
        call PlacePlayersAtStart
.5:
        cmp word [demoflag], 0x0
        jnz short .6
        cmp word [introskipped], 0x0
        jnz short .6
        mov word [fadeinpending], 0x0
.6:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetGameVars                                              1F9C:056A  94 PC
; Clears clock, score and game state.
;
; Calls randomd0, StartGameThunk, MouseMove, joyq_flushThunk.
;-----------------------------------------------------------------------------
ResetGameVars:
        push si
        mov al, 0xff
        mov [curevent], al
        mov [goalevent], al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [goalienotebits], ax
        mov [threat], ax
        mov [passplayer], ax
        mov [passspeed], ax
        mov [passdir], ax
        mov [lastplayer], ax
        mov [shotplayer], ax
        mov [SortPending], ax
        mov [RefPen], ax
        mov [refsignal], ax
        mov [Penaltytimer], ax
        mov [lcblinktime], ax
        mov [lcblink], ax
        mov [energywarn], ax
        mov [lcsel], ax
        mov [lcrequestteam], ax
        mov [energywarnteam], ax
        mov [lcreqchoice+2], ax
        mov [lcreqchoice], ax
        mov [lcrequest+2], ax
        mov [lcrequest], ax
        mov ax, 0xffff
        mov [ovltimer], ax
        mov [penaltysc], ax
        mov [RefStep], ax
        mov [PenCntDwn], ax
        mov [PenCntDwn2], ax
        mov [bannermsg], ax
        mov [ovlstep], ax
        mov [ovlseq], ax
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [gamevar2], al
        mov [gamevar1], al
        mov [scorerflags2], al
        mov [scorerflags], al
        mov [textline5], al
        mov [textline4], al
        mov [textline2], al
        mov [textline1], al
        mov [textline3], al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [lcreqchoice], ax
        mov [hudredraw], ax
        mov [lcboxon], ax
        mov [lcstate2], ax
        mov [lctime], ax
        mov [lcactive], ax
        mov [lcgroup], ax
        mov [lcstate], ax
        mov [lcchoice], ax
        mov [mousey], ax
        mov [mousex], ax
        mov [bannertimer], ax
        mov [injurystop], ax
        mov [refhitcount], ax
        mov [crowdheat], ax
        mov si, rinkobjs
.1:
        mov word [si], 0xffff
        mov ax, 0x28
        call 0x0C11:randomd0
        add al, 0x3c
        mov [si + 0x2], al
        add si, 0xe
        cmp si, SpriteFrames
        jc short .1
        mov bx, rinkobjused
.2:
        inc bx
        inc bx
        mov word [bx - 0x2], 0x0
        cmp bx, hilightslots
        jc short .2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [gamevar5], ax
        mov [gamevar4], ax
        mov [gamevar3], ax
        mov [crowdcount], ax
        mov [crowdtimer], ax
        mov [gamevar8], ax
        mov [gamevar7], ax
        mov [crowdsumhi], ax
        mov [crowdsum], ax
        mov word [gamevar6], 0xffff
        call 0x1B35:StartGameThunk
        mov word [curperiod], 0x1
        cmp byte [PadStates], 0x1
        jz short .3
        cmp byte [PadStates2], 0x1
        jnz short .4
.3:
        push 0x64
        push word 0xa0
        call 0x03A3:MouseMove
        add sp, 0x4
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [deferpending], ax
        mov [inputframes], ax
        mov [exitgame], ax
        mov [gameover], ax
        mov [hudhundaccum], ax
        mov [frameaccum], ax
        mov [PadRepeatOn], ax
        mov [gameframe], ax
        call 0x1B35:joyq_flushThunk
