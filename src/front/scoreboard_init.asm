; Resets the scoreboard and loads its art (INIT.OVL)
; The first bytes finish the last routine of rink_tiles.asm.
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; InitScoreboard                                             251E:0004  94 PC
; Resets the scoreboard state, loads its art.
;
; Calls LoadScoreboardArt. Far routine (retf).
;-----------------------------------------------------------------------------
InitScoreboard:
        db 0x2B, 0xDB                           ; insn: sub bx, bx
.1:
        mov ax, 0xffff
        mov [bx + g_55AC], ax
        mov [bx + g_556C], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + g_55B2], ax
        mov [bx + g_5572], ax
        mov [bx + g_55B0], ax
        mov [bx + g_5570], ax
        mov [bx + g_55AE], ax
        mov [bx + g_556E], ax
        add bx, 0x8
        cmp bx, 0x40
        jl short .1
        push cs
        call LoadScoreboardArt
        retf

;-----------------------------------------------------------------------------
; LoadScoreboardArt                                          251E:0038  94 PC
; scrbrd1.QPP digits and labels.
;
; Calls BuildPathFar, LoadPackedHeader, FindFarList, FindFarMsg.
;-----------------------------------------------------------------------------
LoadScoreboardArt:
        enter 0xe, 0x0
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Scrbrd1
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
        mov [g_C258], ax
        mov [g_C25A], dx
        push word 0xdaa2
        push strict word str_0000000100020003000400050006000700080009000
        push dx
        push ax
        call 0x03A3:FindFarList
        add sp, 0x8
        push word 0xda76
        push strict word str_1000100110021003100410051006100710081009100
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarList
        add sp, 0x8
        push word 0xda4a
        push strict word str_2000200120022003200420052006200720082009200
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarList
        add sp, 0x8
        push word 0xda3e
        push strict word str_VlinvppVpk
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarList
        add sp, 0x8
        push word 0xda32
        push strict word str_HlinhppHpk
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarList
        add sp, 0x8
        push strict word str_Visp
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [g_DA2E], ax
        mov [g_DA30], dx
        push strict word str_Homp
        push word [g_C25A]
        push word [g_C258]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [g_DA2A], ax
        mov [g_DA2C], dx
        push word 0xda0a
        push strict word str_Lin1lin2lin3lin4pp1Pp2Pk1
        push word [g_C25A]
