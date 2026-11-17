; Game stats screens and the background save and restore around them (STATS.OVL)
; The first bytes finish the last routine of goalie_card.asm.
        add sp, 0x4
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SaveBkgdPlanes                                             215A:000C  94 PC
; Copies the four VGA planes into the 'BKGD' record.
;
; Calls InsertRecWrap, RawBase, EmsMapFrame, _fmemcpy. Far routine (retf).
;-----------------------------------------------------------------------------
SaveBkgdPlanes:
        enter 0x2, 0x0
        push si
        push word 0x80
        push 0x0
        push strict word str_Bkgd_10
        push word 0x2128
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave0Off], ax
        mov [VgaSave0Seg], dx
        push word 0x80
        push 0x0
        push strict word str_Bkgd_10
        push strict word str_Plane1_3
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave1Off], ax
        mov [VgaSave1Seg], dx
        push word 0x80
        push 0x0
        push strict word str_Bkgd_10
        push strict word str_Plane2_3
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave2Off], ax
        mov [VgaSave2Seg], dx
        push word 0x80
        push 0x0
        push strict word str_Bkgd_10
        push strict word str_Plane3_3
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave3Off], ax
        mov [VgaSave3Seg], dx
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xf0
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xfc
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        out dx, al
        push strict word str_Bkgd_10
        push word VgaMem
        push 0x0
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x1]
        mov dx, 0x3cf
        out dx, al
        push strict word str_Bkgd_10
        push word VgaMem
        push 0x0
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x2]
        mov dx, 0x3cf
        out dx, al
        push strict word str_Bkgd_10
        push word VgaMem
        push 0x0
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x3]
        mov dx, 0x3cf
        out dx, al
        push strict word str_Bkgd_10
        push word VgaMem
        push 0x0
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, 0x3cf
        out dx, al
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RestoreBkgdPlanes                                          215A:018A  94 PC
; Copies them back and frees the record.
;
; Calls RawBase, EmsMapFrame, _fmemcpy, UnlinkRec. Far routine (retf).
;-----------------------------------------------------------------------------
RestoreBkgdPlanes:
        enter 0x2, 0x0
        push si
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xf0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xfc
        out dx, al
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        inc ax
        mov dx, 0x3c5
        out dx, al
        push strict word str_Bkgd_10
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x2]
        mov dx, 0x3c5
        out dx, al
        push strict word str_Bkgd_10
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x4]
        mov dx, 0x3c5
        out dx, al
        push strict word str_Bkgd_10
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x8]
        mov dx, 0x3c5
        out dx, al
        push strict word str_Bkgd_10
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, 0x3cf
        out dx, al
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; GameTeamStatsScreen                                        215A:02E6  94 PC
; Team stats from the in-game menu.
;
; Takes 1 word of stack arguments. Calls SaveBkgdPlanes, GetPaletteFar, FadePaletteInThunk,
; SetStartPage, UseOffscreenCanvas, InitMenuRemap, TeamStatsScreen, DrawMenuBar and others. Far
; routine (retf).
;-----------------------------------------------------------------------------
GameTeamStatsScreen:
        enter 0x30e, 0x0
        push si
        mov si, [bp + 0x6]
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x64a
        mov word [statsmenucbseg], 0x25e5
        push cs
        call SaveBkgdPlanes
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        push 0x1
        call 0x2095:InitMenuRemap
        add sp, 0x2
        push si
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word TeamStatsMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_15
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Pal_28
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word TeamStatsMenuBar
        call 0x1EAE:StatsMenuLoop
        add sp, 0xc
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push cs
        call RestoreBkgdPlanes
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x20E4:LoadCrestsPalette
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; GameSkaterStatsScreen                                      215A:0428  94 PC
; Skater leaders from the in-game menu.
;
; Takes 1 word of stack arguments. Calls SaveBkgdPlanes, GetPaletteFar, FadePaletteInThunk,
; SetStartPage, UseOffscreenCanvas, InitMenuRemap, LeadersScreen, DrawMenuBar and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
GameSkaterStatsScreen:
        enter 0x30e, 0x0
        push si
        mov si, [bp + 0x6]
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x8da
        mov word [statsmenucbseg], 0x26be
        push cs
        call SaveBkgdPlanes
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        push 0x1
        call 0x2095:InitMenuRemap
        add sp, 0x2
        push si
        call 0x26BE:LeadersScreen
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word SkaterStatsMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_14
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Pal_27
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word SkaterStatsMenuBar
        call 0x1EAE:StatsMenuLoop
        add sp, 0xc
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push cs
        call RestoreBkgdPlanes
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x20E4:LoadCrestsPalette
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; GameGoalieStatsScreen                                      215A:056A  94 PC
; Goalie leaders from the in-game menu.
;
; Takes 1 word of stack arguments. Calls SaveBkgdPlanes, GetPaletteFar, FadePaletteInThunk,
; SetStartPage, UseOffscreenCanvas, InitMenuRemap, LeadersScreen, DrawMenuBar and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
GameGoalieStatsScreen:
        enter 0x30e, 0x0
        push si
        mov si, [bp + 0x6]
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x8da
        mov word [statsmenucbseg], 0x26be
        push cs
        call SaveBkgdPlanes
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseOffscreenCanvas
        push 0x1
        call 0x2095:InitMenuRemap
        add sp, 0x2
        push si
        call 0x26BE:LeadersScreen
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word GoalieStatsMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_13
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Pal_26
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word GoalieStatsMenuBar
        call 0x1EAE:StatsMenuLoop
        add sp, 0xc
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push cs
        call RestoreBkgdPlanes
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x20E4:LoadCrestsPalette
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; GameStandingsScreen                                        215A:06AC  94 PC
; Standings from the in-game menu.
;
; Calls LoadRawHeader, BuildPathFar, LoadPackedHeader, GetPage, CopyPlane, ShowStandingsTable,
; DrawMenuBar, FreeStandingsGfx and others. Far routine (retf).
;-----------------------------------------------------------------------------
GameStandingsScreen:
        enter 0xe, 0x0
        cmp word [statscontext], 0x0
        jnz short .1
        jmp near .5
.1:
        mov ax, [StandingsGfx1Seg]
        or ax, [StandingsGfx1]
        jnz short .2
        push 0x0
        push strict word str_EasnFnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [StandingsGfx1], ax
        mov [StandingsGfx1Seg], dx
.2:
        mov ax, [StandingsGfx2Seg]
        or ax, [StandingsGfx2]
        jnz short .3
        push word 0x3701
        push strict word str_Qpp
        mov bx, [statscontext]
        shl bx, 1
        push ds
        push word [bx + StatsDbNames]
        push 0x0
        push 0x0
        lea ax, [bp - 0xe]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0xe]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [StandingsGfx2], ax
        mov [StandingsGfx2Seg], dx
.3:
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        call 0x0FEF:CopyPlane
.4:
        push word standingstab
        push word [statsteambuf]
        push word [statsteambufseg]
        call 0x24E6:ShowStandingsTable
        add sp, 0x6
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word 0xc8
        jmp short .7
        db 0x90
.5:
        call 0x0FEF:GetPage
        dec ax
        jz short .6
        call 0x0FEF:CopyPlane
.6:
        call 0x2248:FreeStandingsGfx
        call 0x0FEF:UseOffscreenCanvas
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push word standingstab
        push word [statsteambuf]
        push word [statsteambufseg]
        call 0x24E6:StandingsScreen
        add sp, 0x6
        push 0x0
.7:
        call 0x0FEF:SetStartPage
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GameStandingsMenu                                          215A:079E  94 PC
; Standings, roster and player cards from the in-game menu.
;
; Calls SaveBkgdPlanes, GetPaletteFar, FadePaletteInThunk, InsertRecWrap, RawBase, EmsMapFrame,
; _fmemcpy, SetStartPage and others.
;-----------------------------------------------------------------------------
GameStandingsMenu:
        enter 0x328, 0x0
        push si
        mov word [leaguestatsmode], 0x1
        mov ax, [VisTeam]
        mov dx, [HomeTeam]
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenusel], ax
        mov [statscategory], ax
        mov byte [statsplayer], 0x0
        push cs
        call SaveBkgdPlanes
        lea ax, [bp - 0x320]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x320]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0x80
        push 0x0
        push word 0x3b00
        push strict word str_Plane0_2
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        push word 0x80
        push 0x0
        push word 0x3b00
        push strict word str_Plane1_2
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        push word 0x80
        push 0x0
        push word 0x3b00
        push strict word str_Plane2_2
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        push word 0x80
        push 0x0
        push word 0x3b00
        push strict word str_Plane3_2
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xf0
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xfc
        out dx, al
        push word 0x3b00
        push word VgaMem
        push word 0x4400
        push word [bp - 0x1e]
        push word [bp - 0x20]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        db 0x8B, 0xC6                           ; insn: mov ax, si
        inc ax
        mov dx, 0x3cf
        out dx, al
        push word 0x3b00
        push word VgaMem
        push word 0x4400
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x2]
        mov dx, 0x3cf
        out dx, al
        push word 0x3b00
        push word VgaMem
        push word 0x4400
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x3]
        mov dx, 0x3cf
        out dx, al
        push word 0x3b00
        push word VgaMem
        push word 0x4400
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x1]
        cbw
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x2]
        cbw
        mov dx, 0x3cf
        out dx, al
        push word 0xc7
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, PageTable
        mov es, [PoStandingsMode]
        mov [bp - 0x324], bx
        mov [bp - 0x322], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .1
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x324]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.1:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xc8
        push word 0x140
        call 0x0FEF:AllocCanvases
        add sp, 0xe
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
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        call 0x0FEF:UseOffscreenCanvas
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push 0x1
        call 0x2095:InitMenuRemap
        add sp, 0x2
        push 0x0
        push 0x0
        push word 0x270
        push strict word str_Tstat_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsteambufseg], ax
        mov [statsteambuf], dx
        push 0x0
        push 0x0
        push word 0x5b0
        push strict word str_Keys_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsplayerbufseg], ax
        mov [statsplayerbuf], dx
        push 0x0
        push 0x0
        push word 0x4b0
        push strict word str_Pstat_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsskaterbufseg], ax
        mov [statsskaterbuf], dx
        push 0x0
        push 0x0
        push word 0x10e
        push strict word str_Gstat_4
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsgoaliebufseg], ax
        mov [statsgoaliebuf], dx
        push 0x0
        call far [VisTeam]
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        mov ax, [standingstab]
        mov [statsmenusel], ax
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_12
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
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Pal_25
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        add ax, strict word 0x10
        push dx
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x1EAE:StandingsMenuLoop
        add sp, 0xc
        call 0x2248:FreeStandingsGfx
        call 0x0FEF:UseOffscreenCanvas
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push word 0x3f00
        push word 0x100
        push word 0x4000
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
.3:
        cmp word [statsmenumode], 0x1
        jnz short .4
        jmp near .17
.4:
        mov ax, [statsmenumode]
        dec ax
        dec ax
        jz short .8
        dec ax
        jnz short .5
        jmp near .11
.5:
        dec ax
        jnz short .6
        jmp near .12
.6:
        dec ax
        jnz short .7
        jmp near .13
.7:
        jmp near .16
.8:
        push 0x0
        mov ax, [VisTeam]
        mov dx, [HomeTeam]
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x326], dx
        mov [bp - 0x328], ax
        call far [bp - 0x328]
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word standingsmenubar
        call 0x1EAE:StandingsMenuLoop
        add sp, 0xc
        cmp word [statscontext], 0x0
        jnz short .9
        jmp near .16
.9:
        call 0x2248:FreeStandingsGfx
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
        push word 0x3f00
        push word 0x100
        push word 0x4000
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        call 0x0FEF:CopyPlane
.10:
        call 0x0FEF:UseOffscreenCanvas
        jmp near .16
        db 0x90
.11:
        mov word [statsrosterteam], 0x0
        push word [statscategory]
        mov ax, strict word RosterScreen
        mov dx, 0x2446
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x326], dx
        mov [bp - 0x328], ax
        call far [bp - 0x328]
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word StandingsRosterMenuBar
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x3
        push word 0x3448
        push strict word StandingsRosterMenuBar
        call 0x1EAE:RosterMenuLoop
        jmp short .15
        db 0x90
.12:
        mov es, [segWorkBuffer40]
        mov word [es:dlgJerseyConflict + 0x4], 0x0
        push word statscardteam
        mov ax, strict word GoalieStatsCard
        mov dx, 0x20f4
        jmp short .14
.13:
        mov es, [segWorkBuffer40]
        mov word [es:dlgJerseyConflict + 0x4], 0x0
        push word statscardteam
        mov ax, strict word SkaterStatsCard
        mov dx, 0x23d5
.14:
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x326], dx
        mov [bp - 0x328], ax
        call far [bp - 0x328]
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x2
        push word 0x3448
        push strict word StandingsMenuBar2
        call 0x0FA0:DrawMenuBar
        add sp, 0xc
        push 0x0
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x42
        push 0x41
        push 0x40
        push 0x2
        push word 0x3448
        push strict word StandingsMenuBar2
        call 0x1EAE:StatsMenuLoop
.15:
        add sp, 0xc
.16:
        cmp word [statsmenumode], 0x1
        jz short .17
        jmp near .4
.17:
        lea ax, [bp - 0x320]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x320]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xf0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xfc
        out dx, al
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        inc ax
        mov dx, 0x3c5
        out dx, al
        push word 0x3b00
        push word [bp - 0x1e]
        push word [bp - 0x20]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push word 0x4400
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x2]
        mov dx, 0x3c5
        out dx, al
        push word 0x3b00
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push word 0x4400
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x4]
        mov dx, 0x3c5
        out dx, al
        push word 0x3b00
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push word 0x4400
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x8]
        mov dx, 0x3c5
        out dx, al
        push word 0x3b00
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word VgaMem
        push word 0x4400
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x1]
        cbw
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x2]
        cbw
        mov dx, 0x3cf
        out dx, al
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        les bx, [bp - 0x324]
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .18
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x324]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.18:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xb0
        push word 0x148
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .19
        call 0x0FEF:CopyPlane
.19:
        push cs
        call RestoreBkgdPlanes
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x20E4:LoadCrestsPalette
        call 0x2248:FreeStandingsGfx
        push word [statsteambuf]
        push word [statsteambufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsgoaliebuf]
        push word [statsgoaliebufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsskaterbuf]
        push word [statsskaterbufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsplayerbuf]
        push word [statsplayerbufseg]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsplayerbuf], ax
        mov [statsplayerbufseg], ax
        mov [statsteambuf], ax
        mov [statsteambufseg], ax
        mov [statsgoaliebuf], ax
        mov [statsgoaliebufseg], ax
        mov [statsskaterbuf], ax
        mov [statsskaterbufseg], ax
