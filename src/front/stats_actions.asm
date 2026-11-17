; Menu items of the stats screens: standings actions, team stats and leader categories (STATS.OVL)
; The first bytes finish the last routine of stats_screens.asm.
        mov [statsmenucbseg], ax
        mov [statsredrawcb], ax
        mov [leaguestatsmode], ax
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; StandingsActExit                                           2248:000C  94 PC
; Menu item: leave the standings menu (action 1)
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StandingsActExit:
        mov ax, 0x1
        mov [statsmenumode], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StandingsActStandings                                      2248:0014  94 PC
; Menu item: standings (action 2)
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StandingsActStandings:
        mov word [statsmenumode], 0x2
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; StandingsActRoster                                         2248:001E  94 PC
; Menu item: team roster (action 3)
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StandingsActRoster:
        mov word [statsmenumode], 0x3
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; StatsSelNhlSeason                                          2248:0028  94 PC
; Season menu: NHL season stats.
;
; Calls CopyStrNFar, GetPaletteFar, FadePaletteInThunk. Far routine (retf).
;-----------------------------------------------------------------------------
StatsSelNhlSeason:
        cmp word [statsseason], 0x0
        jnz short .1
        cmp word [statscontext], 0x0
        jnz short .1
        jmp near .4
.1:
        mov es, [segSeasonTitles6]
        mov byte [es:titleSeason], 0x1
        mov al, 0x2
        mov es, [segSeasonTitles7]
        mov [es:titleLeaguePlayoffs], al
        mov es, [segSeasonTitles8]
        mov [es:titleLeagueSeasonPlayoffs], al
        mov es, [segSeasonTitles9]
        mov [es:titleLeagueSeason], al
        mov es, [segSeasonTitles10]
        mov [es:titlePlayoffs], al
        mov word [statsseason], 0x0
        cmp word [statscontext], 0x0
        jz short .2
        mov word [statsmenusel], 0x0
.2:
        mov word [statscontext], 0x0
        push 0x1f
        push word 0x3415
        push strict word exhstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .3
        push word 0x3a0b
        push strict word StatsScreenPalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov es, [segWorkBuffer41]
        mov word [es:dlgJerseyConflict + 0x4], 0xffff
        push word [statscategory]
        call far [statsredrawcb]
        add sp, 0x2
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StatsSelNhlPlayoffs                                        2248:00EC  94 PC
; Season menu: NHL playoff stats.
;
; Calls CopyStrNFar, GetPaletteFar, FadePaletteInThunk. Far routine (retf).
;-----------------------------------------------------------------------------
StatsSelNhlPlayoffs:
        cmp word [statsseason], 0x0
        jnz short .1
        cmp word [statscontext], 0x1
        jnz short .1
        jmp near .4
.1:
        mov es, [segSeasonTitles10]
        mov byte [es:titlePlayoffs], 0x1
        mov al, 0x2
        mov es, [segSeasonTitles7]
        mov [es:titleLeaguePlayoffs], al
        mov es, [segSeasonTitles8]
        mov [es:titleLeagueSeasonPlayoffs], al
        mov es, [segSeasonTitles9]
        mov [es:titleLeagueSeason], al
        mov es, [segSeasonTitles6]
        mov [es:titleSeason], al
        mov word [statsseason], 0x0
        cmp word [statscontext], 0x0
        jnz short .2
        mov word [statsmenusel], 0x0
.2:
        mov word [statscontext], 0x1
        push 0x1f
        push word 0x3415
        push strict word exhstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .3
        push word 0x3a0b
        push strict word StatsScreenPalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov es, [segWorkBuffer41]
        mov word [es:dlgJerseyConflict + 0x4], 0xffff
        push word [statscategory]
        call far [statsredrawcb]
        add sp, 0x2
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StatsSelLeague                                             2248:01B0  94 PC
; Season menu: league season.
;
; Calls CopyStrNFar, GetPaletteFar, FadePaletteInThunk. Far routine (retf).
;-----------------------------------------------------------------------------
StatsSelLeague:
        cmp word [statsseason], 0x1
        jnz short .1
        cmp word [statscontext], 0x0
        jnz short .1
        jmp near .4
.1:
        mov es, [segSeasonTitles9]
        mov byte [es:titleLeagueSeason], 0x1
        mov al, 0x2
        mov es, [segSeasonTitles7]
        mov [es:titleLeaguePlayoffs], al
        mov es, [segSeasonTitles8]
        mov [es:titleLeagueSeasonPlayoffs], al
        mov es, [segSeasonTitles10]
        mov [es:titlePlayoffs], al
        mov es, [segSeasonTitles6]
        mov [es:titleSeason], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jz short .2
        mov word [statsmenusel], 0x0
.2:
        mov word [statscontext], 0x0
        push 0x1f
        push word 0x3415
        push strict word lgstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .3
        push word 0x3a0b
        push strict word StatsScreenPalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov es, [segWorkBuffer41]
        mov word [es:dlgJerseyConflict + 0x4], 0xffff
        push word [statscategory]
        call far [statsredrawcb]
        add sp, 0x2
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StatsSelLeaguePlayoffs                                     2248:0274  94 PC
; Season menu: league playoffs.
;
; Calls _fstrcmp, CopyStrNFar, GetPaletteFar, FadePaletteInThunk. Far routine (retf).
;-----------------------------------------------------------------------------
StatsSelLeaguePlayoffs:
        cmp word [statsseason], 0x1
        jnz short .1
        cmp word [statscontext], 0x1
        jnz short .1
        push word 0x3415
        push strict word lgstate_name
        push word 0x3861
        push strict word 0x0
        call 0x0000:_fstrcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near .4
.1:
        mov es, [segSeasonTitles8]
        mov byte [es:titleLeagueSeasonPlayoffs], 0x1
        mov al, 0x2
        mov es, [segSeasonTitles7]
        mov [es:titleLeaguePlayoffs], al
        mov es, [segSeasonTitles9]
        mov [es:titleLeagueSeason], al
        mov es, [segSeasonTitles10]
        mov [es:titlePlayoffs], al
        mov es, [segSeasonTitles6]
        mov [es:titleSeason], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .2
        mov word [statsmenusel], 0x0
.2:
        mov word [statscontext], 0x1
        push 0x1f
        push word 0x3415
        push strict word lgstate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .3
        push word 0x3a0b
        push strict word StatsScreenPalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov es, [segWorkBuffer41]
        mov word [es:dlgJerseyConflict + 0x4], 0xffff
        push word [statscategory]
        call far [statsredrawcb]
        add sp, 0x2
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StatsSelPlayoffMode                                        2248:0350  94 PC
; Season menu: playoff mode.
;
; Calls _fstrcmp, CopyStrNFar, GetPaletteFar, FadePaletteInThunk. Far routine (retf).
;-----------------------------------------------------------------------------
StatsSelPlayoffMode:
        cmp word [statsseason], 0x1
        jnz short .1
        cmp word [statscontext], 0x1
        jnz short .1
        push word 0x3415
        push strict word postate_name
        push word 0x3861
        push strict word 0x0
        call 0x0000:_fstrcmp
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near .4
.1:
        mov es, [segSeasonTitles7]
        mov byte [es:titleLeaguePlayoffs], 0x1
        mov al, 0x2
        mov es, [segSeasonTitles8]
        mov [es:titleLeagueSeasonPlayoffs], al
        mov es, [segSeasonTitles9]
        mov [es:titleLeagueSeason], al
        mov es, [segSeasonTitles10]
        mov [es:titlePlayoffs], al
        mov es, [segSeasonTitles6]
        mov [es:titleSeason], al
        mov word [statsseason], 0x1
        cmp word [statscontext], 0x0
        jnz short .2
        mov word [statsmenusel], 0x0
.2:
        mov word [statscontext], 0x1
        push 0x1f
        push word 0x3415
        push strict word postate_name
        push word 0x3861
        push strict word 0x0
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .3
        push word 0x3a0b
        push strict word StatsScreenPalette
        push word 0x100
        push 0x0
        call 0x0FEF:GetPaletteFar
        add sp, 0x8
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x1
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
        mov es, [segWorkBuffer41]
        mov word [es:dlgJerseyConflict + 0x4], 0xffff
        push word [statscategory]
        call far [statsredrawcb]
        add sp, 0x2
        push 0x10
        push word 0x3a0b
        push strict word StatsScreenPalette
        push 0x0
        call 0x1B35:FadePaletteInThunk
        add sp, 0x8
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MenuTeamScoring                                            2248:042C  94 PC
; Team stats sorted by CmpTeamScoring.
;
; Calls TeamStatsScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTeamScoring:
        mov word [statscategory], 0x0
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x0
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        retf
.1:
        push 0x0
        call far [teamstatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuTeamDefense                                            2248:044E  94 PC
; Team stats sorted by CmpTeamDefense.
;
; Calls TeamStatsScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTeamDefense:
        mov word [statscategory], 0x1
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x1
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        retf
.1:
        push 0x1
        call far [teamstatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuTeamPP                                                 2248:0470  94 PC
; Team stats sorted by CmpTeamPP.
;
; Calls TeamStatsScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTeamPP:
        mov word [statscategory], 0x2
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x2
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        retf
.1:
        push 0x2
        call far [teamstatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuTeamPK                                                 2248:0492  94 PC
; Team stats sorted by CmpTeamPK.
;
; Calls TeamStatsScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTeamPK:
        mov word [statscategory], 0x3
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x3
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        retf
.1:
        push 0x3
        call far [teamstatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuTeamPenalties                                          2248:04B4  94 PC
; Team stats sorted by CmpTeamPenalties.
;
; Calls TeamStatsScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuTeamPenalties:
        mov word [statscategory], 0x4
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x4
        call 0x25E5:TeamStatsScreen
        add sp, 0x2
        retf
.1:
        push 0x4
        call far [teamstatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuPointLeaders                                           2248:04D6  94 PC
; Menu item: point leaders (leaders table entry 0).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuPointLeaders:
        mov word [statscategory], 0x0
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x0
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x0
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuGoalLeaders                                            2248:04F8  94 PC
; Menu item: goal leaders (leaders table entry 1).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuGoalLeaders:
        mov word [statscategory], 0x1
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x1
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x1
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuAssistLeaders                                          2248:051A  94 PC
; Menu item: assist leaders (leaders table entry 2).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuAssistLeaders:
        mov word [statscategory], 0x2
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x2
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x2
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuPPGoalLeaders                                          2248:053C  94 PC
; Menu item: power play goal leaders (leaders table entry 3).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuPPGoalLeaders:
        mov word [statscategory], 0x3
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x3
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x3
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuSHGoalLeaders                                          2248:055E  94 PC
; Menu item: shorthanded goal leaders (leaders table entry 4).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuSHGoalLeaders:
        mov word [statscategory], 0x4
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x4
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x4
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuPlusMinusLeaders                                       2248:0580  94 PC
; Menu item: plus/minus leaders (leaders table entry 5).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuPlusMinusLeaders:
        mov word [statscategory], 0x5
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x5
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x5
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuPIMLeaders                                             2248:05A2  94 PC
; Menu item: penalty minutes leaders (leaders table entry 6).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuPIMLeaders:
        mov word [statscategory], 0x6
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x6
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x6
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuShootPctLeaders                                        2248:05C4  94 PC
; Menu item: shooting percentage leaders (leaders table entry 7).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuShootPctLeaders:
        mov word [statscategory], 0x7
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x7
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x7
        call far [goaliestatscb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuGAALeaders                                             2248:05E6  94 PC
; Menu item: goals against average leaders (leaders table entry 8).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuGAALeaders:
        mov word [statscategory], 0x8
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x8
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x8
        call far [standingsmenucb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuWinsLeaders                                            2248:0608  94 PC
; Menu item: goalie wins leaders (leaders table entry 9).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuWinsLeaders:
        mov word [statscategory], 0x9
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0x9
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0x9
        call far [standingsmenucb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; MenuSavePctLeaders                                         2248:062A  94 PC
; Menu item: save percentage leaders (leaders table entry 10).
;
; Calls LeadersScreen. Far routine (retf).
;-----------------------------------------------------------------------------
MenuSavePctLeaders:
        mov word [statscategory], 0xa
        cmp word [leaguestatsmode], 0x0
        jz short .1
        push 0xa
        call 0x26BE:LeadersScreen
        add sp, 0x2
        retf
.1:
        push 0xa
        call far [standingsmenucb]
        add sp, 0x2
        retf

;-----------------------------------------------------------------------------
; StandingsActRoster2                                        2248:064C  94 PC
; Roster action from the standings cursor.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StandingsActRoster2:
        mov word [statsmenumode], 0x3
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; StandingsActPlayer                                         2248:0656  94 PC
; Player card action: goalie card for a 'G', else skater card.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
StandingsActPlayer:
        cmp byte [statsplayer], 0x47
        jnz short .1
        mov ax, 0x4
        jmp short .2
.1:
        mov ax, 0x5
.2:
        mov [statsmenumode], ax
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; FreeStandingsGfx                                           2248:066C  94 PC
; Frees the four standings shape records.
;
; Calls FindUnlink. Far routine (retf).
;-----------------------------------------------------------------------------
FreeStandingsGfx:
        mov ax, [StandingsGfx2Seg]
        or ax, [StandingsGfx2]
        jz short .1
        push word [StandingsGfx2Seg]
        push word [StandingsGfx2]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [StandingsGfx2Seg], ax
        mov [StandingsGfx2], ax
.1:
        mov ax, [StandingsGfx1Seg]
        or ax, [StandingsGfx1]
        jz short .2
        push word [StandingsGfx1Seg]
        push word [StandingsGfx1]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [StandingsGfx1Seg], ax
        mov [StandingsGfx1], ax
.2:
        retf
        db 0x90
