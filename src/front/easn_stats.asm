; Stats screens reached from the EASN desk (STATS.OVL)

;-----------------------------------------------------------------------------
; EasnTeamStatsScreen                                        22B3:0000  94 PC
; Team stats from the EASN desk.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; TeamStatsScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
EasnTeamStatsScreen:
        enter 0x312, 0x0
        push si
        mov si, [bp + 0x6]
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x64a
        mov word [statsmenucbseg], 0x25e5
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
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x312], ax
        mov [bp - 0x310], cx
        push cx
        push ax
        push ds
        push strict word str_Embpal_11
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
        push strict word str_Pal_24
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
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
        push 0x10
        mov ax, [statsbgshapes]
        mov dx, [statsbgseg]
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
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
        cmp word [DbSaveMode], 0x1
        jz short .1
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Easndesk_3
        jmp short .2
        db 0x90
.1:
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Embpal_10
.2:
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
        push strict word str_Pal_23
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x10
        push word [statsbgseg]
        push word [statsbgshapes]
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EasnSkaterStatsScreen                                      22B3:01C8  94 PC
; Skater leaders from the EASN desk.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; LeadersScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
EasnSkaterStatsScreen:
        enter 0x312, 0x0
        push si
        mov si, [bp + 0x6]
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x8da
        mov word [statsmenucbseg], 0x26be
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
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x312], ax
        mov [bp - 0x310], cx
        push cx
        push ax
        push ds
        push strict word str_Embpal_9
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
        push strict word str_Pal_22
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
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
        push 0x10
        mov ax, [statsbgshapes]
        mov dx, [statsbgseg]
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
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
        cmp word [DbSaveMode], 0x1
        jz short .1
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Easndesk_2
        jmp short .2
        db 0x90
.1:
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Embpal_8
.2:
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
        push strict word str_Pal_21
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x10
        push word [statsbgseg]
        push word [statsbgshapes]
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EasnGoalieStatsScreen                                      22B3:0390  94 PC
; Goalie leaders from the EASN desk.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; LeadersScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
EasnGoalieStatsScreen:
        enter 0x312, 0x0
        push si
        mov si, [bp + 0x6]
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        mov word [leaguestatsmode], 0x1
        mov [statscategory], si
        mov word [statsredrawcb], 0x8da
        mov word [statsmenucbseg], 0x26be
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
        mov ax, 0xbd0
        mov cx, 0x3701
        mov [bp - 0x312], ax
        mov [bp - 0x310], cx
        push cx
        push ax
        push ds
        push strict word str_Embpal_7
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
        push strict word str_Pal_20
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
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
        push 0x10
        mov ax, [statsbgshapes]
        mov dx, [statsbgseg]
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
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
        cmp word [DbSaveMode], 0x1
        jz short .1
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Easndesk
        jmp short .2
        db 0x90
.1:
        push word [bp - 0x310]
        push word [bp - 0x312]
        push ds
        push strict word str_Embpal_6
.2:
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
        push strict word str_Pal_19
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push 0x10
        lea ax, [bp - 0x30e]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push 0x10
        push word [statsbgseg]
        push word [statsbgshapes]
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EasnStandingsScreen                                        22B3:0558  94 PC
; Standings from the EASN desk.
;
; Calls LoadRawHeader, BuildPathFar, LoadPackedHeader, ShowStandingsTable, DrawMenuBar,
; FreeStandingsGfx, UseOffscreenCanvas, StandingsScreen and others. Far routine (retf).
;-----------------------------------------------------------------------------
EasnStandingsScreen:
        enter 0xe, 0x0
        cmp word [statscontext], 0x0
        jnz short .1
        jmp near .4
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
        push word 0xcee8
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
        jmp short .5
        db 0x90
.4:
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
        push word 0xcee8
        push word [statsteambuf]
        push word [statsteambufseg]
        call 0x24E6:StandingsScreen
        add sp, 0x6
        push 0x0
.5:
        call 0x0FEF:SetStartPage
        leave
        retf

;-----------------------------------------------------------------------------
; EasnStandingsMenu                                          22B3:062E  94 PC
; Standings menu from the EASN desk.
;
; Calls VgaCopyBytes, GetPaletteFar, FadePaletteInThunk, InitMenuRemap, AllocRecData, DrawMenuBar,
; BuildPathFar, LoadPackedHeader and others.
;-----------------------------------------------------------------------------
EasnStandingsMenu:
        enter 0x350, 0x0
        push si
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        mov ax, [bx + playofftree]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp + si - 0x4c], ax
        inc bx
        inc bx
        cmp bx, 0x3e
        jl short .1
        mov word [leaguestatsmode], 0x1
        mov ax, [VisTeam]
        mov dx, [HomeTeam]
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenusel], ax
        mov [statscategory], ax
        mov byte [statsplayer], 0x0
        push word 0x3f00
        push word 0xbd00
        push word 0x7e00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        lea ax, [bp - 0x34c]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x34c]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push 0x1
        call 0x2095:InitMenuRemap
        add sp, 0x2
        push 0x0
        push 0x0
        push word 0x270
        push strict word str_Tstat_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsteambufseg], ax
        mov [statsteambuf], dx
        push 0x0
        push 0x0
        push word 0x5b0
        push strict word str_Keys_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsplayerbufseg], ax
        mov [statsplayerbuf], dx
        push 0x0
        push 0x0
        push word 0x4b0
        push strict word str_Pstat_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [statsskaterbufseg], ax
        mov [statsskaterbuf], dx
        push 0x0
        push 0x0
        push word 0x10e
        push strict word str_Gstat_3
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
        push strict word str_Embpal_5
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
        push strict word str_Pal_18
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [statsbgseg], dx
        push 0x10
        add ax, strict word 0x10
        push dx
        push ax
        push 0x0
        call 0x1B35:FadePaletteInThunk
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
        cmp word [statsmenumode], 0x1
        jnz short .2
        jmp near .13
.2:
        mov ax, [statsmenumode]
        dec ax
        dec ax
        jz short .5
        dec ax
        jz short .7
        dec ax
        jnz short .3
        jmp near .8
.3:
        dec ax
        jnz short .4
        jmp near .9
.4:
        jmp near .12
        db 0x90
.5:
        push 0x0
        mov ax, [VisTeam]
        mov dx, [HomeTeam]
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x34e], dx
        mov [bp - 0x350], ax
        call far [bp - 0x350]
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
        jnz short .6
        jmp near .12
.6:
        call 0x2248:FreeStandingsGfx
        call 0x0FEF:UseOffscreenCanvas
        jmp near .12
.7:
        mov word [statsrosterteam], 0x0
        push word [statscategory]
        mov ax, strict word RosterScreen
        mov dx, 0x2446
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x34e], dx
        mov [bp - 0x350], ax
        call far [bp - 0x350]
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
        jmp short .11
        db 0x90
.8:
        mov es, [segWorkBuffer42]
        mov word [es:dlgJerseyConflict + 0x4], 0x0
        push word 0xcf1a
        mov ax, strict word GoalieStatsCard
        mov dx, 0x20f4
        jmp short .10
.9:
        mov es, [segWorkBuffer42]
        mov word [es:dlgJerseyConflict + 0x4], 0x0
        push word 0xcf1a
        mov ax, strict word SkaterStatsCard
        mov dx, 0x23d5
.10:
        mov [statsredrawcb], ax
        mov [statsmenucbseg], dx
        mov [bp - 0x34e], dx
        mov [bp - 0x350], ax
        call far [bp - 0x350]
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
.11:
        add sp, 0xc
.12:
        cmp word [statsmenumode], 0x1
        jz short .13
        jmp near .2
.13:
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
        lea ax, [bp - 0x34c]
        push ss
        push ax
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        lea ax, [bp - 0x34c]
        push ss
        push ax
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        push word 0x3f00
        push word 0x7e00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        push word 0x3f00
        push word 0x3f00
        push word 0xbd00
        call 0x0000:VgaCopyBytes
        add sp, 0x6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [leaguestatsmode], si
.14:
        mov ax, [bp + si - 0x4c]
        mov [si + playofftree], ax
        inc si
        inc si
        cmp si, 0x3e
