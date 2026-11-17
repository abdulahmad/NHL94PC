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
        mov word [es:0x1170], strict word DeskHomeLinesThunk
        mov word [es:0x1172], 0x1b35
        mov [es:0x1188], ax
        mov [es:0x1186], ax
        mov es, [segMenuText2]
        mov word [es:0x10ae], strict word HomeTeamMenuText
        mov word [es:0x10b0], 0x3448
        jmp near .7
.1:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x1172], ax
        mov [es:0x1170], ax
        mov word [es:0x1186], strict word DeskVisitorLinesThunk
        mov word [es:0x1188], 0x1b35
        mov es, [segMenuText2]
        mov [es:0x10b0], ax
        mov [es:0x10ae], ax
.2:
        mov word [es:0x10c4], strict word VisitorTeamMenuText
        mov word [es:0x10c6], 0x3448
        retf
        db 0x90
.3:
        cmp word [ctl1team], -0x1
        jz short .4
        cmp word [ctl2team], -0x1
        jz short .4
        mov es, [segMenuText1]
        mov word [es:0x1170], strict word DeskHomeLinesThunk
        mov word [es:0x1172], 0x1b35
        mov es, [segMenuText2]
        mov word [es:0x10ae], strict word HomeTeamMenuText
        mov word [es:0x10b0], 0x3448
        jmp short .5
.4:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x1172], ax
        mov [es:0x1170], ax
        mov es, [segMenuText2]
        mov [es:0x10b0], ax
        mov [es:0x10ae], ax
.5:
        cmp word [ctl1team], -0x2
        jz short .6
        cmp word [ctl2team], -0x2
        jz short .6
        mov es, [segMenuText1]
        mov word [es:0x1186], strict word DeskVisitorLinesThunk
        mov word [es:0x1188], 0x1b35
        mov es, [segMenuText2]
        jmp near .2
        db 0x90
.6:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x1188], ax
        mov [es:0x1186], ax
        mov es, [segMenuText2]
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x10c6], ax
