; Sets the controlled side for each controller before a game (MENUS.OVL)

;-----------------------------------------------------------------------------
; SetSideControls                                            2037:0000  94 PC
; Sets the controls menu items for the human side(s)
;
; Far routine (retf).
;-----------------------------------------------------------------------------
SetSideControls:
        mov ax, [ctl1side]
        cmp [ctl2side], ax
        jnz short .3
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov es, [segMenuText1]
        mov word [es:itemHomeTeam + 0xC], strict word DeskHomeLinesThunk
        mov word [es:itemHomeTeam + 0xE], 0x1b35
        mov [es:itemVisitingTeam + 0xE], ax
        mov [es:itemVisitingTeam + 0xC], ax
        mov es, [segMenuText2]
        mov word [es:itemHomeTeamGoalie + 0x10], strict word HomeTeamMenuText
        mov word [es:itemHomeTeamGoalie + 0x12], 0x3448
        jmp near .7
.1:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemHomeTeam + 0xE], ax
        mov [es:itemHomeTeam + 0xC], ax
        mov word [es:itemVisitingTeam + 0xC], strict word DeskVisitorLinesThunk
        mov word [es:itemVisitingTeam + 0xE], 0x1b35
        mov es, [segMenuText2]
        mov [es:itemHomeTeamGoalie + 0x12], ax
        mov [es:itemHomeTeamGoalie + 0x10], ax
.2:
        mov word [es:itemVisitingTeamGoalie + 0x10], strict word VisitorTeamMenuText
        mov word [es:itemVisitingTeamGoalie + 0x12], 0x3448
        retf
        db 0x90
.3:
        cmp word [ctl1team], -0x1
        jz short .4
        cmp word [ctl2team], -0x1
        jz short .4
        mov es, [segMenuText1]
        mov word [es:itemHomeTeam + 0xC], strict word DeskHomeLinesThunk
        mov word [es:itemHomeTeam + 0xE], 0x1b35
        mov es, [segMenuText2]
        mov word [es:itemHomeTeamGoalie + 0x10], strict word HomeTeamMenuText
        mov word [es:itemHomeTeamGoalie + 0x12], 0x3448
        jmp short .5
.4:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemHomeTeam + 0xE], ax
        mov [es:itemHomeTeam + 0xC], ax
        mov es, [segMenuText2]
        mov [es:itemHomeTeamGoalie + 0x12], ax
        mov [es:itemHomeTeamGoalie + 0x10], ax
.5:
        cmp word [ctl1team], -0x2
        jz short .6
        cmp word [ctl2team], -0x2
        jz short .6
        mov es, [segMenuText1]
        mov word [es:itemVisitingTeam + 0xC], strict word DeskVisitorLinesThunk
        mov word [es:itemVisitingTeam + 0xE], 0x1b35
        mov es, [segMenuText2]
        jmp near .2
        db 0x90
.6:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemVisitingTeam + 0xE], ax
        mov [es:itemVisitingTeam + 0xC], ax
        mov es, [segMenuText2]
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:itemVisitingTeamGoalie + 0x12], ax
