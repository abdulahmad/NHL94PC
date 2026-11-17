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
        mov word [es:RtlShowMessage + 0xC73], strict word DeskHomeLinesThunk
        mov word [es:RtlShowMessage + 0xC75], 0x1b35
        mov [es:RtlShowMessage + 0xC8B], ax
        mov [es:RtlShowMessage + 0xC89], ax
        mov es, [segMenuText2]
        mov word [es:RtlShowMessage + 0xBB1], strict word HomeTeamMenuText
        mov word [es:RtlShowMessage + 0xBB3], 0x3448
        jmp near .7
.1:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:RtlShowMessage + 0xC75], ax
        mov [es:RtlShowMessage + 0xC73], ax
        mov word [es:RtlShowMessage + 0xC89], strict word DeskVisitorLinesThunk
        mov word [es:RtlShowMessage + 0xC8B], 0x1b35
        mov es, [segMenuText2]
        mov [es:RtlShowMessage + 0xBB3], ax
        mov [es:RtlShowMessage + 0xBB1], ax
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
        mov word [es:RtlShowMessage + 0xC73], strict word DeskHomeLinesThunk
        mov word [es:RtlShowMessage + 0xC75], 0x1b35
        mov es, [segMenuText2]
        mov word [es:RtlShowMessage + 0xBB1], strict word HomeTeamMenuText
        mov word [es:RtlShowMessage + 0xBB3], 0x3448
        jmp short .5
.4:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:RtlShowMessage + 0xC75], ax
        mov [es:RtlShowMessage + 0xC73], ax
        mov es, [segMenuText2]
        mov [es:RtlShowMessage + 0xBB3], ax
        mov [es:RtlShowMessage + 0xBB1], ax
.5:
        cmp word [ctl1team], -0x2
        jz short .6
        cmp word [ctl2team], -0x2
        jz short .6
        mov es, [segMenuText1]
        mov word [es:RtlShowMessage + 0xC89], strict word DeskVisitorLinesThunk
        mov word [es:RtlShowMessage + 0xC8B], 0x1b35
        mov es, [segMenuText2]
        jmp near .2
        db 0x90
.6:
        mov es, [segMenuText1]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:RtlShowMessage + 0xC8B], ax
        mov [es:RtlShowMessage + 0xC89], ax
        mov es, [segMenuText2]
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:0x10c6], ax
