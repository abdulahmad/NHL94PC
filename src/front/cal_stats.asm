; Stats screens reached from the calendar (STATS.OVL)
; The first bytes finish the last routine of easn_stats.asm.
        jl short EasnStandingsMenu.14 - 0x9E0
        mov ax, 0x2
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalTeamStatsScreen                                         2351:000A  94 PC
; Team stats from the calendar.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; TeamStatsScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
CalTeamStatsScreen:
        enter 0x30e, 0x0
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
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_4
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
        push strict word str_Pal_17
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [g_C2B4], dx
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
        mov dx, [g_C2B4]
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
        mov word [statspalshape], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalSkaterStatsScreen                                       2351:014C  94 PC
; Skater leaders from the calendar.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; LeadersScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
CalSkaterStatsScreen:
        enter 0x30e, 0x0
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
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_3
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
        push strict word str_Pal_16
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [g_C2B4], dx
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
        mov dx, [g_C2B4]
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
        mov word [statspalshape], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalGoalieStatsScreen                                       2351:028E  94 PC
; Goalie leaders from the calendar.
;
; Takes 1 word of stack arguments. Calls GetPaletteFar, UseOffscreenCanvas, InitMenuRemap,
; LeadersScreen, DrawMenuBar, BuildPathFar, LoadPackedHeader, FindFarMsg and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
CalGoalieStatsScreen:
        enter 0x30e, 0x0
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
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal_2
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
        push strict word str_Pal_15
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [g_C2B4], dx
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
        mov dx, [g_C2B4]
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
        mov word [statspalshape], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CalStandingsScreen                                         2351:03D0  94 PC
; Standings from the calendar.
;
; Calls LoadRawHeader, BuildPathFar, LoadPackedHeader, ShowStandingsTable, DrawMenuBar,
; FreeStandingsGfx, UseOffscreenCanvas, StandingsScreen and others. Far routine (retf).
;-----------------------------------------------------------------------------
CalStandingsScreen:
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
        push word [g_C04C]
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
        push word [g_C04C]
        call 0x24E6:StandingsScreen
        add sp, 0x6
        push 0x0
.5:
        call 0x0FEF:SetStartPage
        leave
        retf

;-----------------------------------------------------------------------------
; CalStandingsMenu                                           2351:04A6  94 PC
; Standings menu from the calendar.
;
; Calls VgaCopyBytes, GetPaletteFar, FadePaletteInThunk, InitMenuRemap, AllocRecData, DrawMenuBar,
; BuildPathFar, LoadPackedHeader and others.
;-----------------------------------------------------------------------------
CalStandingsMenu:
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
        push strict word str_Tstat
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C04C], ax
        mov [statsteambuf], dx
        push 0x0
        push 0x0
        push word 0x5b0
        push strict word str_Keys_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C048], ax
        mov [statsplayerbuf], dx
        push 0x0
        push 0x0
        push word 0x4b0
        push strict word str_Pstat_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C044], ax
        mov [statsskaterbuf], dx
        push 0x0
        push 0x0
        push word 0x10e
        push strict word str_Gstat_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C040], ax
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
        mov ax, [g_CEE8]
        mov [statsmenusel], ax
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Embpal
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
        push strict word str_Pal_14
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [g_C2B4], dx
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
        mov word [g_C050], 0x0
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
        mov es, [segWorkBuffer43]
        mov word [es:0xb050], 0x0
        push word 0xcf1a
        mov ax, strict word GoalieStatsCard
        mov dx, 0x20f4
        jmp short .10
.9:
        mov es, [segWorkBuffer43]
        mov word [es:0xb050], 0x0
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
        push word [g_C04C]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsgoaliebuf]
        push word [g_C040]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsskaterbuf]
        push word [g_C044]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsplayerbuf]
        push word [g_C048]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [statsplayerbuf], ax
        mov [g_C048], ax
        mov [statsteambuf], ax
        mov [g_C04C], ax
        mov [statsgoaliebuf], ax
        mov [g_C040], ax
        mov [statsskaterbuf], ax
        mov [g_C044], ax
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
        jl short .14
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
        mov word [statspalshape], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
