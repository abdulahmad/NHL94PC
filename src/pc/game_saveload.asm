; Saves and loads a game in progress (INIT.OVL)

;-----------------------------------------------------------------------------
; DrawReplayFrameTail                                        278C:0002  94 PC
; The rest of DrawReplayFrame, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
DrawReplayFrameTail:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SaveGameState                                              278C:0006  94 PC
; 'Error Saving Game'
;
; Takes 1 word of stack arguments. Calls WriteAtOffset, FatalError. Far routine (retf).
;-----------------------------------------------------------------------------
SaveGameState:
        enter 0xee, 0x0
        push di
        push si
        push 0x4
        push -0x1
        push -0x1
        push ds
        push strict word g_01C0
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        mov word [bp - 0x8], 0x0
.2:
        push 0x5a
        push -0x1
        push -0x1
        mov ax, [bp - 0x8]
        shl ax, byte 0x7
        add ax, 0xb50e
        push ds
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x11
        jl short .2
        mov word [bp - 0x8], 0x0
.4:
        push word 0xbe
        push -0x1
        push -0x1
        imul ax, [bp - 0x8], word 0xd6
        add ax, 0xb362
        push ds
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x2
        jl short .4
        push 0x30
        push -0x1
        push -0x1
        push ds
        push strict word g_AE10
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push 0x30
        push -0x1
        push -0x1
        push ds
        push strict word g_AE40
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        mov ax, [g_29CA]
        mov [bp - 0x8a], ax
        mov ax, [g_29CC]
        mov [bp - 0x88], ax
        mov ax, [camx]
        mov [bp - 0x86], ax
        mov ax, [camy]
        mov [bp - 0x84], ax
        lea ax, [bp - 0x82]
        mov [bp - 0x2], ax
        mov word [bp - 0x8], 0x0
.8:
        mov bx, [bp - 0x8]
        shl bx, 1
        mov ax, [bx + fofdata2]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x6
        jl short .8
        mov ax, [shotplayer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [lastplayer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [passdir]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [passspeed]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [passplayer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [threat]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov word [bp - 0x8], 0x0
.9:
        mov bx, [bp - 0x8]
        shl bx, 1
        mov ax, [bx + puckcross]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x4
        jl short .9
        mov ax, [lj1]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [lj2]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [lasttouch]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [ltx]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [lty]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [xc1]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [yc1]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [yleader]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [fox]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [foy]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [fodir1]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [fodir2]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [sflags]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [gmode2]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [sflags3]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [c1playernum]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [c2playernum]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [cont1team]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [cont2team]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [PenCntDwn]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [Penaltytimer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [refsignal]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [RefStep]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [RefPen]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [penaltysc]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [gsp]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [gameclock]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [clockticks]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [shownumbers]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [SortPending]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [exitgame]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [gameover]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [ovltimer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [refhitcount]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [fadeinpending]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [deferpending]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [injurystop]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [GoalState]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [bannermsg]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [bannertimer]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [seed]
        mov dx, [g_2A02]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x4
        mov [bx], ax
        mov [bx + 0x2], dx
        mov ax, [PBnum]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [iflags]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        push word 0x80
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.10:
        lea ax, [bp - 0x8a]
        mov [bp - 0x2], ax
        mov word [bp - 0x8], 0x0
.11:
        mov bx, [bp - 0x8]
        shl bx, 1
        mov ax, [bx + PlList]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x6
        jl short .11
        mov al, [PadStates]
        mov bx, [bp - 0x2]
        mov [bx], al
        mov al, [PadStates2]
        mov [bx + 0x1], al
        mov al, [collflag]
        add word [bp - 0x2], 0x2
        mov bx, [bp - 0x2]
        mov [bx], al
        mov al, [gmode]
        mov [bx + 0x1], al
        mov ax, [g_48CA]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48CC]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48CE]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [energywarn]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lcblink]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lcblinktime]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_48D6]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [g_48D8]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48DA]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48DC]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48DE]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_48E0]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lcboxon]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_48E4]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [g_D46C]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D46E]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lcline]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lctimer]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D60E]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D610]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_D612]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [g_D614]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [curperiod]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_4A4E]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D664]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D666]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D668]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_D66A]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [ltack]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [lastsfx]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D670]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [CrowdSound]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D6BC]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D6BE]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_D6C4]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [g_D004]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D00A]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_D010]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_01B8]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_01BA]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [g_01BC]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [g_01BE]
        mov bx, [bp - 0x2]
        mov [bx], ax
        mov ax, [hudclockmin]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [hudclocksec]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [hudclockhund]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [PenCntDwn2]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        mov ax, [hudhundaccum]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        mov ax, [frameaccum]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_4A24]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_D660]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_D662]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [DbSaveMode]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov al, [g_E366]
        mov bx, [bp - 0x2]
        mov [bx], al
        mov al, [g_E367]
        mov [bx + 0x1], al
        mov al, [g_E368]
        add word [bp - 0x2], 0x2
        mov bx, [bp - 0x2]
        mov [bx], al
        mov al, [g_E369]
        mov [bx + 0x1], al
        mov al, [g_E36A]
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov [bx], al
        mov al, [onetimerflag]
        mov [bx + 0x1], al
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        push word 0x80
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .12
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.12:
        mov ax, [g_01B8]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_01BA]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_01BC]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_01BE]
        mov bx, [bp - 0x2]
        mov [bx], ax
        lea ax, [bp - 0x8a]
        mov [bp - 0x2], ax
        mov word [bp - 0x8], 0x0
.13:
        mov bx, [bp - 0x8]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        mov ax, [bx + rinkobjs]
        mov si, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [si], ax
        mov ax, [bx + rinkobjs_w2]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x14
        jl short .13
        mov ax, [ovlseq]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [ovlstep]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_D658]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        mov ax, [g_D65A]
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov [bx], ax
        push 0x58
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.14:
        push 0x42
        push -0x1
        push -0x1
        push ds
        push strict word PenBuf
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .15
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.15:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word curevent
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .16
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.16:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word goalevent
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .17
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.17:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .18
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.18:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.19:
        push 0x40
        push -0x1
        push -0x1
        push ds
        push strict word g_556C
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .20
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.20:
        push 0x40
        push -0x1
        push -0x1
        push ds
        push strict word g_55AC
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .21
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.21:
        lea ax, [bp - 0x8a]
        mov [bp - 0xa], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x8], ax
        jmp near .25
        db 0x90
.22:
        mov ax, [bp - 0x6]
        add ax, strict word 0x10
        cmp ax, 0x80
        jng short .24
        push word [bp - 0x6]
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .23
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.23:
        lea ax, [bp - 0x8a]
        mov [bp - 0xa], ax
        mov word [bp - 0x6], 0x0
.24:
        mov ax, [bp - 0xa]
        add word [bp - 0xa], 0x10
        mov [bp - 0xee], ax
        mov ax, [bp - 0x8]
        mov cx, 0x19
        cwd
        idiv cx
        mov ax, [bp - 0x8]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        imul ax, ax, 0x19
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x4
        add bx, 0x448
        mov ax, 0x3a0b
        mov dx, [bp - 0xee]
        push cx
        push ds
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xF3                           ; insn: mov si, bx
        push ds
        pop es
        mov ds, ax
        mov cx, 0x8
        rep movsw
        pop ds
        pop cx
        add word [bp - 0x6], 0x10
        inc word [bp - 0x8]
.25:
        cmp word [bp - 0x8], 0x32
        jnl short .26
        jmp near .22
.26:
        mov ax, [bp - 0xa]
        mov [bp - 0x4], ax
        mov word [bp - 0x8], 0x0
.27:
        mov ax, [bp - 0x6]
        add ax, strict word 0x6
        cmp ax, 0x80
        jng short .29
        push word [bp - 0x6]
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .28
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.28:
        lea ax, [bp - 0x8a]
        mov [bp - 0x4], ax
        mov word [bp - 0x6], 0x0
.29:
        mov ax, [bp - 0x4]
        add word [bp - 0x4], 0x6
        mov [bp - 0xee], ax
        mov ax, [bp - 0x8]
        mov cx, 0x3
        cwd
        idiv cx
        mov ax, [bp - 0x8]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv cx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl ax, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        add bx, 0x768
        mov ax, 0x3a0b
        mov dx, [bp - 0xee]
        push cx
        push ds
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xF3                           ; insn: mov si, bx
        push ds
        pop es
        mov ds, ax
        movsw
        movsw
        movsw
        pop ds
        pop cx
        add word [bp - 0x6], 0x6
        inc word [bp - 0x8]
        cmp word [bp - 0x8], 0x6
        jnl short .30
        jmp near .27
.30:
        cmp word [bp - 0x6], 0x0
        jz short .31
        push word [bp - 0x6]
        push -0x1
        push -0x1
        lea ax, [bp - 0x8a]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .31
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.31:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadGameState                                              278C:09C8  94 PC
; 'Error Loading Game'
;
; Takes 2 words of stack arguments. Calls ReadAtOffset, FatalError, BuildPathFar, LoadPackedHeader,
; TableAt, TableCount, MouseMove, SaveModeStateThunk and others.
;-----------------------------------------------------------------------------
LoadGameState:
        enter 0x198, 0x0
        push di
        push si
        push 0x4
        push -0x1
        push -0x1
        push ds
        push strict word g_01C0
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push strict word str_ErrorSavingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        mov word [bp - 0xaa], 0x0
.2:
        push 0x5a
        push -0x1
        push -0x1
        mov ax, [bp - 0xaa]
        shl ax, byte 0x7
        add ax, 0xb50e
        push ds
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x11
        jl short .2
        mov word [bp - 0xaa], 0x0
.4:
        push word 0xbe
        push -0x1
        push -0x1
        imul ax, [bp - 0xaa], word 0xd6
        add ax, 0xb362
        push ds
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x2
        jl short .4
        push 0x30
        push -0x1
        push -0x1
        push ds
        push strict word g_AE10
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push 0x30
        push -0x1
        push -0x1
        push ds
        push strict word g_AE40
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        push word 0x80
        push -0x1
        push -0x1
        lea ax, [bp - 0x12c]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        mov ax, [bp - 0x12c]
        mov [g_29CA], ax
        mov ax, [bp - 0x12a]
        mov [g_29CC], ax
        mov ax, [bp - 0x128]
        mov [camx], ax
        mov ax, [bp - 0x126]
        mov [camy], ax
        lea ax, [bp - 0x124]
        mov [bp - 0x2], ax
        mov word [bp - 0xaa], 0x0
.9:
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xaa]
        shl bx, 1
        mov [bx + fofdata2], ax
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x6
        jl short .9
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [shotplayer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [lastplayer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [passdir], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [passspeed], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [passplayer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [threat], ax
        mov word [bp - 0xaa], 0x0
.10:
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xaa]
        shl bx, 1
        mov [bx + puckcross], ax
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x4
        jl short .10
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [lj1], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [lj2], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [lasttouch], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [ltx], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [lty], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [xc1], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [yc1], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [yleader], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [fox], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [foy], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [fodir1], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [fodir2], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [sflags], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [gmode2], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [sflags3], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [c1playernum], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [c2playernum], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [cont1team], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [cont2team], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [PenCntDwn], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [Penaltytimer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [refsignal], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [RefStep], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [RefPen], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [penaltysc], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [gsp], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [gameclock], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [clockticks], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [shownumbers], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [SortPending], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [exitgame], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [gameover], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [ovltimer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [refhitcount], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [fadeinpending], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [deferpending], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [injurystop], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [GoalState], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [bannermsg], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [bannertimer], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x4
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [seed], ax
        mov [g_2A02], dx
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [PBnum], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [iflags], ax
        push word 0x80
        push -0x1
        push -0x1
        lea ax, [bp - 0x12c]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .11
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.11:
        lea ax, [bp - 0x12c]
        mov [bp - 0x2], ax
        mov word [bp - 0xaa], 0x0
.12:
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xaa]
        shl bx, 1
        mov [bx + PlList], ax
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x6
        jl short .12
        mov bx, [bp - 0x2]
        mov al, [bx]
        mov [PadStates], al
        mov al, [bx + 0x1]
        mov [PadStates2], al
        add word [bp - 0x2], 0x2
        mov bx, [bp - 0x2]
        mov al, [bx]
        mov [collflag], al
        mov al, [bx + 0x1]
        mov [gmode], al
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48CA], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48CC], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48CE], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [energywarn], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lcblink], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lcblinktime], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_48D6], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48D8], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48DA], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48DC], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48DE], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_48E0], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lcboxon], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_48E4], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D46C], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D46E], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lcline], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lctimer], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D60E], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D610], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_D612], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D614], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [curperiod], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_4A4E], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D664], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D666], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D668], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_D66A], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [ltack], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [lastsfx], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D670], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [CrowdSound], ax
        mov [Crowdlevel], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D6BC], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D6BE], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_D6C4], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D004], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_D00A], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        cwd
        mov [g_D010], ax
        mov [g_D012], dx
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_01B8], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_01BA], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [g_01BC], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bx]
        mov [g_01BE], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [hudclockmin], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [hudclocksec], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [hudclockhund], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [PenCntDwn2], ax
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov ax, [bx]
        mov [hudhundaccum], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [frameaccum], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [g_4A24], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [g_D660], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [g_D662], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [DbSaveMode], ax
        mov bx, [bp - 0x2]
        mov al, [bx]
        mov [g_E366], al
        mov al, [bx + 0x1]
        mov [g_E367], al
        add word [bp - 0x2], 0x2
        mov bx, [bp - 0x2]
        mov al, [bx]
        mov [g_E368], al
        mov al, [bx + 0x1]
        mov [g_E369], al
        inc bx
        inc bx
        mov [bp - 0x2], bx
        mov al, [bx]
        mov [g_E36A], al
        mov al, [bx + 0x1]
        cbw
        mov [onetimerflag], ax
        lea ax, [bx + 0x2]
        mov [bp - 0x2], ax
        push 0x58
        push -0x1
        push -0x1
        lea ax, [bp - 0x12c]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.13:
        lea ax, [bp - 0x12c]
        mov [bp - 0x2], ax
        mov word [bp - 0xaa], 0x0
.14:
        mov bx, [bp - 0xaa]
        shl bx, 1
        mov word [bx + g_D9DA], 0x0
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x10
        jl short .14
        mov word [bp - 0xaa], 0x0
.15:
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov bx, [bp - 0xaa]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shl bx, 1
        db 0x03, 0xD9                           ; insn: add bx, cx
        shl bx, 1
        db 0x03, 0xD9                           ; insn: add bx, cx
        shl bx, 1
        add bx, 0xd1ae
        mov [bp - 0x196], bx
        mov [bx], ax
        mov [bp - 0x12e], ax
        mov cx, 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cwd
        idiv cx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x4
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov ax, 0x1
        shl ax, cl
        or [di + g_D9DA], ax
        mov si, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [si]
        mov [bx + 0x2], ax
        cmp word [bp - 0x12e], 0x0
        jl short .16
        mov ax, 0x3
        imul word [bp - 0x12e]
        mov [bp - 0x12e], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov es, [g_8CCC]
        mov cx, [es:si + 0xf8]
        mov [bx + 0x6], cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        inc si
        mov [bp - 0x12e], si
        shl si, 1
        mov ax, [es:si + 0xf8]
        mov [bx + 0x8], ax
        mov si, [bp - 0x12e]
        inc si
        mov [bp - 0x12e], si
        shl si, 1
        mov si, [es:si + 0xf8]
        mov [bx + 0xa], si
        mov es, [g_8CCE]
        db 0x26, 0x8A, 0x84, 0x00, 0x00         ; insn: mov al, [es:si + 0x0]
        mov [bx + 0xc], al
        mov al, [bx + 0x3]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        add si, [bx + 0xa]
        db 0x26, 0x8A, 0x84, 0x00, 0x00         ; insn: mov al, [es:si + 0x0]
        mov [bx + 0x4], al
.16:
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x14
        jnl short .17
        jmp near .15
.17:
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [ovlseq], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [ovlstep], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [g_D658], ax
        mov bx, [bp - 0x2]
        add word [bp - 0x2], 0x2
        mov ax, [bx]
        mov [g_D65A], ax
        cmp word [ovlseq], -0x1
        jnz short .18
        jmp near .22
.18:
        cmp word [ovlstep], -0x1
        jnz short .19
        jmp near .22
.19:
        push word 0x3701
        push strict word str_Qpp
        mov bx, [ovlseq]
        shl bx, 1
        push ds
        push word [bx + g_4A00]
        push 0x0
        push 0x0
        lea ax, [bp - 0x94]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0x94]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [g_D62C], ax
        mov [g_D62E], dx
        mov word [bp - 0xaa], 0x0
        jmp short .21
        db 0x90
.20:
        push word [bp - 0xaa]
        push word [g_D62E]
        push word [g_D62C]
        call 0x03A3:TableAt
        add sp, 0x6
        mov bx, [bp - 0xaa]
        shl bx, byte 0x2
        mov [bx + g_D630], ax
        mov [bx + g_D632], dx
        inc word [bp - 0xaa]
.21:
        push word [g_D62E]
        push word [g_D62C]
        call 0x03A3:TableCount
        add sp, 0x4
        cmp ax, [bp - 0xaa]
        jg short .20
        mov bx, [ovlseq]
        shl bx, byte 0x2
        mov ax, [bx + g_4A0A]
        mov dx, [bx + g_4A0C]
        mov [g_D65C], ax
        mov [g_D65E], dx
.22:
        push 0x42
        push -0x1
        push -0x1
        push ds
        push strict word PenBuf
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .23
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.23:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word curevent
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.24:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word goalevent
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .25
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.25:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .26
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.26:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .27
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.27:
        push 0x40
        push -0x1
        push -0x1
        lea ax, [bp - 0x86]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .28
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.28:
        push 0x40
        push -0x1
        push -0x1
        lea ax, [bp - 0x44]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .29
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.29:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa4], ax
        mov [bp - 0xaa], ax
        jmp near .34
        db 0x90
.30:
        cmp word [bp - 0xa4], 0x0
        jnz short .33
        mov word [bp - 0xa4], 0x80
        cmp word [bp - 0xaa], 0x30
        jl short .31
        mov word [bp - 0xa4], 0x44
.31:
        push word [bp - 0xa4]
        push -0x1
        push -0x1
        lea ax, [bp - 0x12c]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .32
        push strict word str_ErrorLoadingGame
        call 0x0F4A:FatalError
        add sp, 0x2
.32:
        lea ax, [bp - 0x12c]
        mov [bp - 0xac], ax
.33:
        mov ax, [bp - 0xac]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0xaa]
        mov dx, 0x19
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv bx
        mov ax, [bp - 0xaa]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cwd
        idiv bx
        imul ax, ax, 0x19
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, byte 0x4
        mov es, [hmplstats]
        lea di, [si + 0x448]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov cx, 0x8
        rep movsw
        add word [bp - 0xac], 0x10
        sub word [bp - 0xa4], 0x10
        inc word [bp - 0xaa]
.34:
        cmp word [bp - 0xaa], 0x32
        jnl short .35
        jmp near .30
.35:
        mov ax, [bp - 0xac]
        mov [bp - 0x46], ax
        mov word [bp - 0xaa], 0x0
        mov es, [hmglstats]
.36:
        mov ax, [bp - 0x46]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0xaa]
        mov dx, 0x3
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv bx
        mov ax, [bp - 0xaa]
        db 0x8B, 0xF2                           ; insn: mov si, dx
        cwd
        idiv bx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl ax, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl si, 1
        db 0x03, 0xF0                           ; insn: add si, ax
        shl si, 1
        lea di, [si + SpeechMemOff]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        movsw
        movsw
        movsw
        add word [bp - 0x46], 0x6
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x6
        jl short .36
        cmp byte [PadStates], 0x1
        jz short .37
        cmp byte [PadStates2], 0x1
        jnz short .38
.37:
        push 0x64
        push word 0xa0
        call 0x03A3:MouseMove
        add sp, 0x4
.38:
        mov ax, [DbSaveMode]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .39
        dec ax
        jz short .42
        dec ax
        jz short .43
        jmp short .41
        db 0x90
.39:
        push word 0x3415
        push strict word exhstate
        call 0x1B35:SaveModeStateThunk
        add sp, 0x4
        push word 0x3415
        push strict word exhstate
.40:
        call 0x1B35:LoadModeStateThunk
        add sp, 0x4
.41:
        call 0x1B35:GetPeriodTimeThunk
        mov [g_D1AC], ax
        push 0x1
        call 0x2425:LoadGameTeams
        add sp, 0x2
        push word 0x3a0b
        push strict word f_3A0B_0A8E
        push word [g_29CC]
        push word [g_29CA]
        call 0x1E64:LoadTeamPalette
        add sp, 0x8
        mov ax, 0x1
        mov [g_4B22], ax
        mov [g_4B20], ax
        mov word [hudhundstep], 0x0
        cmp word [g_29CA], 0x18
        jl short .44
        mov ax, 0x9
        jmp short .45
        db 0x90
.42:
        push word 0x3415
        push strict word postate
        call 0x1B35:SaveModeStateThunk
        add sp, 0x4
        push word 0x3415
        push strict word postate
        jmp short .40
.43:
        push word 0x3415
        push strict word lgstate
        call 0x1B35:SaveModeStateThunk
        add sp, 0x4
        push word 0x3415
        push strict word lgstate
        jmp short .40
.44:
        mov ax, [g_29CA]
.45:
        push ax
        call 0x24DE:LoadRinkTiles
        add sp, 0x2
        call 0x2137:LoadArenaJingles
        call 0x1F9C:LoadGameGfx
        call 0x0FEF:UseOffscreenCanvas
        push 0x0
        push word [curperiod]
        push word [g_29CC]
        push word [g_29CA]
        call 0x1B35:DrawHudPanelThunk
        add sp, 0x8
        call 0x1B35:BuildEventLinesThunk
        mov ax, [g_2986]
        mov dx, [g_2988]
        mov [g_D014], ax
        mov [g_D016], dx
        call 0x1B35:ReplayRecordResetThunk
        and byte [sflags], 0xef
        mov word [fadeinpending], 0x1
        mov word [hmtmsort], f_3A0B_0000
        mov word [hmtmplattr], 0x3a0b
        mov word [g_B426], f_3A0B_03E8
        mov word [g_B428], 0x3a0b
        mov word [hmtmlines], 0xae10
        mov word [g_B42A], f_3A0B_0448
        mov word [g_B42C], 0x3a0b
        mov word [hmtmglstats], f_3A0B_0768
        mov word [hmtmroster], 0x3a0b
        mov word [g_B432], 0xa550
        mov word [hmtmptrF2], 0x9f80
        mov word [g_B50C], 0xb80e
        mov word [awtmsort], f_3A0B_01F4
        mov word [g_B4FA], 0x3a0b
        mov word [awtmglattr], f_3A0B_0418
        mov word [awtmlines], 0x3a0b
        mov word [g_B4F6], 0xae40
        mov word [awtmplstats], f_3A0B_05D8
        mov word [awtmglstats], 0x3a0b
        mov word [g_B504], f_3A0B_077A
        mov word [g_B506], 0x3a0b
        mov word [awtmptrF2], 0xa9b0
        mov word [g_B50A], 0xa268
        mov ax, 0xb50e
        mov [g_B436], ax
        mov [bp - 0x130], ax
        mov word [bp - 0xaa], 0x0
        jmp short .50
.46:
        mov bx, [bp - 0x130]
        mov word [bx + 0x60], 0xb362
.47:
        mov bx, [bp - 0x130]
        test byte [bx + 0x44], 0x40
        jnz short .48
        mov word [bx + 0x62], 0xb438
        jmp short .49
.48:
        mov word [bx + 0x62], 0xb362
.49:
        mov bx, [bp - 0x130]
        mov ax, [bx]
        mov dx, [bx + 0x2]
        mov [bx + 0x64], ax
        mov [bx + 0x66], dx
        mov ax, [bx + 0x4]
        mov dx, [bx + 0x6]
        mov [bx + 0x68], ax
        mov [bx + 0x6a], dx
        mov ax, [bx + 0x8]
        mov dx, [bx + 0xa]
        mov [bx + 0x6c], ax
        mov [bx + 0x6e], dx
        mov al, [bp - 0xaa]
        mov bx, [bp - 0xaa]
        mov [bx + g_D4F4], al
        shl bx, 1
        mov ax, [bp - 0xaa]
        mov [bx + g_D496], ax
        inc word [bp - 0xaa]
        add word [bp - 0x130], 0x80
.50:
        cmp word [bp - 0xaa], 0x11
        jnl short .52
        mov ax, [bp - 0xaa]
        mov bx, [bp - 0x130]
        mov [bx + 0x5e], ax
        imul si, ax, 0x12
        mov es, [g_8CD4]
        db 0x26, 0x8B, 0x84, 0x0A, 0x00         ; insn: mov ax, [es:si + 0xa]
        mov [bx + 0x5a], ax
        db 0x26, 0x8B, 0x84, 0x0C, 0x00         ; insn: mov ax, [es:si + 0xc]
        mov [bx + 0x5c], ax
        test byte [bx + 0x44], 0x40
        jnz short .51
        jmp near .46
.51:
        mov word [bx + 0x60], 0xb438
        jmp near .47
.52:
        call 0x1B35:SprSortThunk
        mov word [bp - 0xaa], 0x0
.53:
        mov bx, [bp - 0xaa]
        shl bx, byte 0x3
        db 0x8B, 0xF3                           ; insn: mov si, bx
        push si
        lea di, [bx + g_556C]
        lea si, [bp + si - 0x86]
        mov ax, ds
        mov es, ax
        movsw
        movsw
        movsw
        movsw
        pop si
        lea di, [bx + g_55AC]
        lea si, [bp + si - 0x44]
        mov ax, ds
        movsw
        movsw
        movsw
        movsw
        inc word [bp - 0xaa]
        cmp word [bp - 0xaa], 0x8
        jl short .53
