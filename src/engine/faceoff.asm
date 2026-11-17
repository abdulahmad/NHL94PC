; Penalty box and faceoff set-up assignments (AI.OVL)
; The first bytes finish the last routine of hud_panel.asm.
        dec word [bp - 0x2]
        jz short DrawPanelPenaltiesTail
        jmp near DrawPanelPenalties.1 - 0xE10

;-----------------------------------------------------------------------------
; DrawPanelPenaltiesTail                                     2164:000A  94 PC
; The rest of DrawPanelPenalties, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
DrawPanelPenaltiesTail:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetPenaltyStrength                                         2164:000E  94 PC
; Sets the number of skaters each team has on the ice from the players in the penalty box.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
SetPenaltyStrength:
        enter 0xa, 0x0
        push di
        mov bx, hmshots
        mov dx, SortCords + 6 * 0x80 + 0x1a
.1:
        mov cx, 0x6
        mov di, 0x1b
        mov [bp - 0x2], dx
        lea ax, [bx + 0x9a]
        mov [bp - 0xa], dx
        mov [bp - 0x8], bx
        mov bx, [bp - 0x2]
        mov [bp - 0x6], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov dx, [bp - 0x6]
.2:
        cmp word [di], 0x0
        jng short .3
        cmp cx, 0x4
        jng short .3
        dec cx
        sub bx, 0x80
        mov word [bx], 0xffff
        mov word [bx + 0x14], 0xff9c
.3:
        dec di
        dec di
        dec dx
        jns short .2
        mov bx, [bp - 0x8]
        mov [bx + 0x22], cx
        mov bx, awshots
        mov dx, [bp - 0xa]
        add dh, 0x3
        cmp dx, 0xbe28
        jc short .1
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; TakePlayerFromBox                                          2164:006C  94 PC
; Takes the first roster player whose penalty is over out of the box and back to the bench.
;
; Takes 1 word of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
TakePlayerFromBox:
        enter 0x4, 0x0
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov bx, [bp + 0x6]
        mov al, [bx + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        mov [bp - 0x4], ax
        imul ax, ax, word 0x460
        add ax, hmroster
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.1:
        cmp byte [bx], 0x7
        jz short .2
        add bx, 0x28
        inc di
        cmp di, 0x19
        jl short .1
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        mov si, [bp + 0x6]
        mov word [si + 0x36], 0x4
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x7bf
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x20
        mov word [si + 0x26], 0x5a
        mov [si + 0x2e], di
        imul ax, [bp - 0x4], 0x1c
        db 0x8B, 0xCF                           ; insn: mov cx, di
        db 0x03, 0xF8                           ; insn: add di, ax
        imul bx, di, 0x28
        mov byte [bx + hmroster], 0x3
        imul bx, [bp - 0x4], 0x6b
        db 0x03, 0xD9                           ; insn: add bx, cx
        shl bx, 1
        mov word [bx + hmtmpdst], 0xfffe
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PenShotStart                                               2164:00E0  94 PC
; Sets the players of a team up for a penalty shot, or puts its skaters without a new position back
; into play.
;
; Takes 1 word of stack arguments. Calls assinsert. Far routine (retf).
;-----------------------------------------------------------------------------
PenShotStart:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        imul si, [bp + 0x6], word 0x300
        add si, SortCords
        mov di, 0x6
.1:
        cmp word [si + 0x1a], 0x0
        jl short .2
        cmp byte [si + 0x42], 0xff
        jnz short .2
        cmp byte [si + 0x43], 0xff
        jnz short .2
        cmp word [si + 0x2e], -0x64
        jz short .2
        mov bx, [si + 0x1c]
        cmp byte [bx + si + 0x1e], 0x27
        jz short .2
        push 0x27
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.2:
        add si, 0x80
        dec di
        jnz short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ForceStartLineup                                           2164:0128  94 PC
; At the opening faceoff of a game, forces the team's starting lineup onto the ice.
;
; Takes 1 word of stack arguments. Calls forcepldata. Far routine (retf).
;-----------------------------------------------------------------------------
ForceStartLineup:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cmp word [gsp], 0x0
        jnz short .1
        mov ax, [gameclock]
        cmp [gameclock2], ax
        jnz short .1
        cmp word [clockticks], 0x0
        jnz short .1
        imul ax, [bp + 0x6], word 0xd6
        add ax, hmshots
        push ax
        call 0x2E42:forcepldata
.1:
        leave
        retf

;-----------------------------------------------------------------------------
; PenShotAssign                                              2164:0152  94 PC
; Penalty shot set-up: the shooter takes his position and the other skaters wait by the side boards.
;
; Calls assinsert. Far routine (retf).
;-----------------------------------------------------------------------------
PenShotAssign:
        push di
        push si
        mov si, SortCords
        mov di, 0xc
.1:
        cmp word [si + 0x1a], 0x0
        jng short .2
        mov word [si + 0x2e], 0x0
        mov bx, [si + 0x1c]
        mov al, [bx + si + 0x1e]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        cmp ax, strict word 0x29
        jz short .2
        cmp dx, 0x1d
        jz short .2
        mov al, [CrowdState]
        and ax, strict word 0x4
        cmp ax, strict word 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        add ax, strict word 0x28
        push ax
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.2:
        cmp word [si + 0x1a], 0x0
        jnz short .3
        mov word [si + 0x2e], 0x0
        push 0x27
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
.3:
        add si, 0x80
        dec di
        jnz short .1
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; AllInPlace                                                 2164:01B0  94 PC
; Returns 1 when every skater on the ice has reached his spot, else 0.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
AllInPlace:
        mov bx, SortCords
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.1:
        cmp word [bx + 0x1a], 0x0
        jl short .2
        cmp word [bx + 0x2e], -0x64
        jnz short .3
.2:
        add bx, 0x80
        inc dx
        cmp dx, 0xc
        jl short .1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90
.4:
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; assleavebox                                                2164:01D6  94 PC
; Assignment: skates out of the penalty box area and brings the released player back on.
;
; Takes 1 word of stack arguments. Calls check4bench, randomd0, assinsert, setplayer, SetSPA,
; TakePlayerFromBox, skateto. Far routine (retf).
;-----------------------------------------------------------------------------
assleavebox:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .16
.1:
        push si
        push cs
        call check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .16
.2:
        test byte [si + 0x44], 0x2
        jz short .3
        and byte [si + 0x44], 0xfd
        mov word [si + 0x28], 0x8
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x8d
        add ax, strict word 0x41
        mov [si + 0x2c], ax
        mov ax, 0x4
        call 0x0C11:randomd0
        dec ax
        dec ax
        neg ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x4
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add [si + 0x2c], ax
        mov word [si + 0x2a], 0xff58
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x26], ax
        mov [si + 0x2e], ax
.3:
        cmp word [si + 0x26], 0x5a
        jnz short .4
        push 0x28
        push si
        call 0x1E7E:assinsert
        add sp, 0x4
        push word [si + 0x2e]
        push si
        call 0x2E42:setplayer
        add sp, 0x4
        mov word [si + 0x12], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x2e], ax
        mov [si + 0x26], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.4:
        cmp word [si + 0x26], 0x64
        jnz short .5
        jmp near .14
.5:
        dec word [si + 0x26]
        js short .6
        jmp near .13
.6:
        add word [si + 0x26], 0x8
        mov cx, [si + 0x6]
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0x88
        add ax, strict word 0x46
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov ax, [si + 0x2]
        sub ax, [si + 0x2a]
        mov [regd0], ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x26
        jng short .7
        jmp near .13
.7:
        cmp word [regd0], 0x1f
        jg short .13
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfd78
        add ax, 0x289
        mov [regd1], ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x4
        cmp word [si + 0x36], 0x6
        jz short .10
        cmp word [si + 0x36], 0x7
        jnl short .8
        cmp word [si + 0x36], 0x2
        jng short .8
        mov dx, 0x1
        jmp short .9
        db 0x90, 0x90
.8:
        mov dx, 0xffff
.9:
        mov al, [si + 0x36]
        db 0x02, 0xC2                           ; insn: add al, dl
        and ax, strict word 0x7
        mov [si + 0x36], ax
.10:
        mov word [si + 0xe], 0x0
        mov word [si + 0xc], 0xf800
        cmp word [regd0], 0x10
        jng short .11
        jmp near .16
.11:
        mov word [si + 0xc], 0x0
        cmp word [si + 0x36], 0x6
        jz short .12
        jmp near .16
.12:
        mov word [si + 0x26], 0x64
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x289
        call 0x2E42:SetSPA
        push si
        push cs
        call TakePlayerFromBox
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.13:
        test byte [si + 0x44], 0x4
        jnz short .16
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        add sp, 0x6
        pop si
        pop di
        leave
        retf
        db 0x90
.14:
        cmp [si + 0x1a], ax
        jng short .15
        cmp word [si + 0x36], 0x6
        jnz short .15
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        mov bx, [si + 0x60]
        mov ax, [bx + di + 0x2c]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x5
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        add ax, strict word 0x50
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xd97
        call 0x2E42:SetSPA
        or byte [si + 0x44], 0x20
        pop si
        pop di
        leave
        retf
        db 0x90
.15:
        cmp word [si + 0x38], 0x0
        jnz short .16
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x289
        call 0x2E42:SetSPA
.16:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; puckfaceoff                                                2164:03AA  94 PC
; Puck assignment at a stoppage: end of period, penalties, computer line choice, goalies back in net,
; then sets up the faceoff.
;
; Takes 1 word of stack arguments. Calls clockcont_0, Stop4Pen, ReturnGoalies, setpersonel,
; SprSortVert, StartFaceoffLineChange, CompLine, PenShotStart and others. Far routine (retf).
;-----------------------------------------------------------------------------
puckfaceoff:
        enter 0xa, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        lea ax, [di + 0x26]
        mov [bp - 0x6], ax
        lea ax, [di + 0x28]
        mov [bp - 0x4], ax
        test byte [di + 0x44], 0x2
        jnz short .1
        jmp near .13
.1:
        mov bx, [puckc]
        cmp byte [bx], 0x10
        jz short .2
        mov byte [bx], 0xff
.2:
        and byte [di + 0x44], 0xfd
        cmp word [gameclock], 0x0
        jnz short .3
        cmp word [clockticks], 0x0
        jnz short .3
        jmp near .16
.3:
        test byte [gmode], 0x40
        jz short .4
        jmp near .16
.4:
        cmp word [gsp], 0x3
        jnz short .5
        mov ax, [hmscore]
        cmp [awscore], ax
        jz short .5
        call 0x2E42:clockcont_0
        pop si
        pop di
        leave
        retf
.5:
        test byte [gmode], 0x8
        jz short .6
        push 0x0
        call 0x327B:Stop4Pen
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        call 0x28BB:ReturnGoalies
        test byte [CrowdState], 0x4
        jnz short .7
        push word hmshots
        call 0x2E42:setpersonel
        add sp, 0x2
        push word awshots
        call 0x2E42:setpersonel
        add sp, 0x2
.7:
        mov al, 0xff
        mov [di + 0x27], al
        mov [di + 0x29], al
        test byte [CrowdState], 0x4
        jnz short .8
        jmp near .13
.8:
        and byte [hmtmflags], 0xfd
        and byte [awtmflags], 0xfd
        mov bx, SortCords
        mov dx, 0xc
.9:
        and byte [bx + 0x45], 0xf7
        add bx, 0x80
        dec dx
        jnz short .9
        mov ax, [cont2team]
        or ax, [cont1team]
        jz short .10
        cmp word [SortPending], 0x0
        jz short .10
        or byte [sflags], 0x40
        call 0x2E42:SprSortVert
        mov word [SortPending], 0x0
.10:
        mov ax, [c1playernum]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .11
        shl ax, byte 0x7
        add ax, SortCords
        push ax
        push di
        call 0x2519:StartFaceoffLineChange
        add sp, 0x4
.11:
        mov ax, [c2playernum]
        mov [regd0], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .12
        mov ax, [cont1team]
        cmp [cont2team], ax
        jz short .12
        mov ax, [regd0]
        shl ax, byte 0x7
        add ax, SortCords
        push ax
        push di
        call 0x2519:StartFaceoffLineChange
        add sp, 0x4
.12:
        mov word [regd0], 0x2
        mov word [regd0_w2], 0x0
        test byte [CrowdState], 0x4
        jz short .13
        mov ax, [regd0]
        cmp [cont1team], ax
        jz short .13
        cmp [cont2team], ax
        jz short .13
        push word awshots
        push word hmshots
        call 0x2E42:CompLine
        add sp, 0x4
        push word awshots
        call 0x2E42:setpersonel
        add sp, 0x2
        push 0x1
        push cs
        call PenShotStart
        add sp, 0x2
.13:
        mov byte [bp - 0x1], 0x0
.14:
        mov al, [bp - 0x1]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xa], si
        shl si, 1
        mov [bp - 0x8], si
        mov bx, [bp + si - 0x6]
        cmp word [bx], 0x0
        jnl short .15
        jmp near .19
.15:
        mov bx, [bx + 0x4]
        mov [regd1], bx
        shl bx, byte 0x7
        test byte [bx + sortobj0_pflags2], 0x8
        jnz short .17
        mov bx, [bp + si - 0x6]
        mov byte [bx + 0x1], 0xff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + lcsel], ax
        mov [si + lcboxon], ax
        jmp short .18
.16:
        call 0x2E42:SetExitGame
        pop si
        pop di
        leave
        retf
        db 0x90
.17:
        mov bx, [bp + si - 0x6]
        dec word [bx]
        jns short .19
        mov si, [regd1]
        shl si, byte 0x7
        add si, SortCords
        test byte [si + 0x45], 0x8
        jz short .19
        mov word [regd2], 0x0
        push si
        call 0x2C24:lcfound
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x8]
        mov [bx + lcsel], ax
        mov [bx + lcboxon], ax
.18:
        imul ax, [bp - 0xa], word 0xd6
        add ax, hmshots
        push ax
        call 0x2E42:setpersonel
        add sp, 0x2
        push word [bp - 0xa]
        push cs
        call PenShotStart
        add sp, 0x2
        push word [bp - 0xa]
        push cs
        call ForceStartLineup
        add sp, 0x2
.19:
        inc byte [bp - 0x1]
        cmp byte [bp - 0x1], 0x2
        jz short .20
        jmp near .14
.20:
        cmp word [di + 0x26], 0x0
        jnl short .23
        cmp word [di + 0x28], 0x0
        jnl short .23
        mov word [regd0], 0x1
        test byte [CrowdState], 0x4
        jz short .21
        cmp word [cont1team], 0x1
        jz short .21
        cmp word [cont2team], 0x1
        jz short .21
        push word hmshots
        push word awshots
        call 0x2E42:CompLine
        add sp, 0x4
        push word hmshots
        call 0x2E42:setpersonel
        add sp, 0x2
        push 0x0
        push cs
        call PenShotStart
        add sp, 0x2
.21:
        test byte [CrowdState], 0x4
        jnz short .22
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [awtmlcnt], ax
        mov [awtmline], ax
        mov [hmtmlcnt], ax
        mov [hmtmline], ax
        push ax
        push ax
        call 0x2083:DrawPanelLine
        add sp, 0x4
        push 0x0
        push 0x1
        call 0x2083:DrawPanelLine
        add sp, 0x4
.22:
        push 0x1c
        push di
        call 0x1E7E:assreplace
        add sp, 0x4
        mov word [di + 0x2e], 0x3e8
.23:
        pop si
        pop di
        leave
        retf
        db 0x90, 0x90, 0x90

;-----------------------------------------------------------------------------
; puckfaceoff2                                               2164:0650  94 PC
; Puck assignment while the faceoff is being set up.
;
; Takes 1 word of stack arguments. Calls AllInPlace, FindUnlink, FlushGSumQueue, SprSortVert,
; checkwindow, ResetBench, setpersonel, forcepldata and others. Far routine (retf).
;-----------------------------------------------------------------------------
puckfaceoff2:
        enter 0xa, 0x0
        push si
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x2
        jnz short .1
        jmp near .51
.1:
        dec word [bx + 0x2e]
        cmp word [bx + 0x2e], 0x0
        jng short .5
        cmp word [demoflag], 0x0
        jnz short .5
        cmp word [introskipped], 0x0
        jnz short .5
        cmp word [injurystop], 0x0
        jnz short .5
        cmp word [gsp], 0x0
        jnz short .2
        cmp word [clockticks], 0x0
        jnz short .2
        mov ax, [gameclock]
        cmp [gameclock2], ax
        jz short .5
.2:
        cmp word [RefStep], 0x0
        jl short .3
        jmp near .54
.3:
        cmp word [ovltimer], 0x0
        jl short .4
        jmp near .54
.4:
        push cs
        call AllInPlace
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        jmp near .54
.5:
        mov bx, [bp + 0x6]
        and byte [bx + 0x44], 0xfd
        cmp word [introskipped], 0x0
        jz short .6
        cmp word [ovlseq], -0x1
        jz short .6
        push word [OverlayGfxSeg]
        push word [OverlayGfx]
        call 0x06E1:FindUnlink
        add sp, 0x4
.6:
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        call 0x2352:FlushGSumQueue
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
        mov ax, 0xffff
        mov [bannermsg], ax
        mov [ovlstep], ax
        mov [ovlseq], ax
        mov [ovltimer], ax
        mov word [bannertimer], 0x0
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [textline5], al
        mov [textline4], al
        mov [textline2], al
        mov [textline1], al
        mov [textline3], al
        cmp word [demoflag], 0x0
        jz short .7
        jmp near .12
.7:
        cmp word [gsp], 0x0
        jz short .8
        jmp near .12
.8:
        mov ax, [gameclock]
        cmp [gameclock2], ax
        jz short .9
        jmp near .12
.9:
        cmp word [clockticks], 0x0
        jnz short .12
        cmp word [introskipped], 0x0
        jnz short .12
.10:
        mov word [fadeinpending], 0x0
.11:
        and byte [sflags], 0xfe
        and byte [sflags3], 0xfe
        mov byte [iflags], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [introskipped], ax
        mov [injurystop], ax
        mov [refsignal], ax
        mov al, 0xff
        mov [GoalState_m5], al
        mov [GoalState_m1], al
        and byte [gmode2], 0x7d
        or byte [gmode2], 0x5
        mov ax, 0xffff
        mov [RefStep], ax
        mov [passplayer], ax
        call 0x2E42:SprSortVert
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [SortPending], ax
        mov [camy], ax
        mov [camx], ax
        mov ax, [fox]
        mov [xc1], ax
        mov cx, [foy]
        mov [yc1], cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x20
        jng short .16
        cmp word [xc1], 0x0
        jng short .14
        mov ax, 0x20
        jmp short .15
        db 0x90, 0x90, 0x90, 0x90
.12:
        cmp word [demoflag], 0x0
        jnz short .13
        cmp word [introskipped], 0x0
        jnz short .13
        cmp word [injurystop], 0x0
        jnz short .13
        jmp near .10
.13:
        mov word [fadeinpending], 0x1
        jmp near .11
        db 0x90
.14:
        mov ax, 0xffe0
.15:
        mov [xc1], ax
.16:
        cmp word [yc1], 0xff44
        jg short .17
        mov word [yc1], 0xff44
        jmp short .18
.17:
        cmp word [yc1], 0xec
        jl short .18
        mov word [yc1], 0xec
.18:
        mov ax, [xc1]
        mov [camx], ax
        mov ax, [yc1]
        mov [camy], ax
        mov word [yleader], 0x0
        mov ax, [fox]
        mov bx, [puckx]
        mov [bx], ax
        mov ax, [foy]
        mov bx, [pucky]
        mov [bx], ax
        mov bx, [puckz]
        mov word [bx], 0xff9c
        mov bx, [puckvx]
        mov word [bx], 0x0
        mov bx, [puckvy]
        mov word [bx], 0x0
        mov bx, [puckvz]
        mov word [bx], 0x0
        mov bx, [puckc]
        mov byte [bx], 0xff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [sortobj12_Xvel], ax
        mov [sortobj12_Yvel], ax
        mov [sortobj12_Xpos2], ax
        mov word [sortobj12_Ypos2], 0xec
        mov [sortobj13_Xvel], ax
        mov [sortobj13_Yvel], ax
        mov [sortobj13_Xpos2], ax
        mov word [sortobj13_Ypos2], 0xff14
        mov [RefPen], ax
        mov word [penaltysc], 0xffff
        mov ax, [fox]
        mov [ltx], ax
        mov ax, [foy]
        mov [lty], ax
        mov word [doorframe], 0x189
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [door_38], ax
        mov [door_48], ax
        mov [puck_48], ax
        mov word [puckframe], 0x18a
        and byte [sflags], 0xbf
        call 0x226F:checkwindow
        call 0x2E42:ResetBench
        push word hmshots
        call 0x2E42:setpersonel
        add sp, 0x2
        push word hmshots
        call 0x2E42:forcepldata
        add sp, 0x2
        push word awshots
        call 0x2E42:setpersonel
        add sp, 0x2
        push word awshots
        call 0x2E42:forcepldata
        add sp, 0x2
        call 0x2E42:resetplstuff
        mov word [bp - 0x8], SortCords
        mov word [regd2], 0xc
.19:
        mov bx, [bp - 0x8]
        mov word [bx + 0x2], 0xff10
        mov word [bx + 0x6], 0x0
        mov ax, [bx + 0x1a]
        mov [regd1], ax
        mov bx, [bp + 0x6]
        cmp word [bx + 0x2e], -0x64
        jnz short .20
        mov word [bx + 0x2e], 0x0
.20:
        cmp word [regd1], 0x0
        jnl short .21
        jmp near .42
.21:
        jz short .24
        cmp word [regd1], 0x4
        jnz short .22
        mov bx, [bp - 0x8]
        mov ax, [bx + 0x60]
        mov [bp - 0x2], ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [bx + 0x47]
        cbw
        mov [si + 0x1c], ax
        mov al, 0xff
        mov bx, [bp - 0x2]
        mov [bx + 0x1f], al
        mov [bx + 0x21], al
        and byte [bx + 0x2a], 0xf7
        mov word [regd0], 0x17
        jmp short .23
        db 0x90
.22:
        mov word [regd0], 0x16
.23:
        push word [regd0]
        push word [bp - 0x8]
        call 0x1E7E:assinsert
        add sp, 0x4
.24:
        mov bx, [bp - 0x8]
        mov si, [bx + 0x60]
        mov ax, [si + 0x22]
        neg ax
        mov [regd4], ax
        cmp ax, strict word 0xfffa
        jng short .25
        mov bx, [bx + 0x60]
        cmp word [bx + 0x24], 0x0
        jnl short .25
        dec ax
        mov [regd4], ax
.25:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        add si, 0x6
        shl si, byte 0x3
        mov [regd4], si
        mov bx, [regd1]
        mov al, [bx + si + apl]
        cbw
        mov [regd4], ax
        shl word [regd4], 1
        mov bx, [regd4]
        shl bx, 1
        mov ax, [bx + puckfaceoff2_ptab]
        mov [regd0], ax
        mov cx, [bx + puckfaceoff2_ptab_y]
        mov [regd1], cx
        mov bx, [bp - 0x8]
        test byte [bx + 0x44], 0x80
        jnz short .26
        neg ax
        mov [regd0], ax
        neg cx
        mov [regd1], cx
.26:
        cmp word [bx + 0x1a], 0x0
        jz short .29
        cmp word [regd4], 0x4
        jg short .28
        xor ax, [fox]
        jnl short .27
        mov ax, [foy]
        sar ax, byte 0x3
        sub [regd1], ax
.27:
        mov ax, [fox]
        sar ax, byte 0x2
        sub [regd0], ax
.28:
        mov ax, [fox]
        add [regd0], ax
        mov ax, [foy]
        add [regd1], ax
        jmp short .32
        db 0x90
.29:
        mov ax, [foy]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x27
        jng short .32
        cmp word [foy], 0x0
        jnl short .30
        mov ax, 0x1
        jmp short .31
        db 0x90
.30:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.31:
        mov cl, [bx + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xD2                           ; insn: sbb dx, dx
        neg dx
        db 0x33, 0xD0                           ; insn: xor dx, ax
        jz short .32
        mov ax, [foy]
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x4e
        add cx, -0x27
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        push 0x0
        push word 0x1000
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [fox]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        call 0x03A3:ImulRegs
        push dx
        push ax
        call 0x0000:__aFldiv
        add [regd0], ax
.32:
        mov ax, [regd0]
        mov bx, [bp - 0x8]
        mov [bx + 0x2], ax
        mov ax, [regd1]
        mov [bx + 0x6], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + 0xc], ax
        mov [bx + 0xe], ax
        mov si, [puckx]
        mov ax, [si]
        sub ax, [regd0]
        mov si, [pucky]
        mov dx, [si]
        sub dx, [regd1]
        call 0x0D5F:VectorToDir8
        mov bx, [bp - 0x8]
        mov [bx + 0x36], ax
        cmp word [bx + 0x1a], 0x0
        jnz short .37
        cmp byte [bx + 0x59], 0x0
        jz short .33
        mov bx, [bp - 0x8]
        mov ax, [bx + 0x36]
        jmp short .34
.33:
        mov bx, [bp - 0x8]
        mov ax, [bx + 0x36]
        neg ax
        and ax, strict word 0x7
.34:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, 0x196
        mov [bx + 0x12], ax
        mov word [regd1], 0x1
        cmp word [bx + 0x36], 0x2
        jnz short .36
        mov al, [bx + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x2
        inc ax
.35:
        mov [bx + 0x36], ax
        jmp short .41
        db 0x90
.36:
        mov bx, [bp - 0x8]
        cmp word [bx + 0x36], 0x6
        jnz short .41
        mov al, [bx + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xfe
        add ax, strict word 0x7
        jmp short .35
        db 0x90
.37:
        mov bx, [bp - 0x8]
        cmp word [bx + 0x1a], 0x4
        jnz short .38
        cmp word [bx + 0x36], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x5
        add ax, 0x167
        mov [bx + 0x12], ax
        mov word [regd1], 0x0
        jmp short .41
.38:
        cmp byte [bx + 0x59], 0x0
        jz short .39
        mov ax, [bx + 0x36]
        jmp short .40
        db 0x90
.39:
        mov ax, [bx + 0x36]
        neg ax
        and ax, strict word 0x7
.40:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bx + 0x12], ax
        mov word [regd1], 0x289
.41:
        mov bx, [bp - 0x8]
        and byte [bx + 0x45], 0xfb
        and byte [bx + 0x44], 0xdf
        mov ax, [regd1]
        call 0x2E42:SetSPA
.42:
        mov bx, [bp - 0x8]
        and byte [bx + 0x45], 0x7f
        add word [bp - 0x8], 0x80
        dec word [regd2]
        jz short .43
        jmp near .19
.43:
        mov word [bp - 0x8], refstruct
        cmp word [fox], 0x0
        jg short .44
        mov word [ref_36], 0x2
        mov ax, [fox]
        sub ax, strict word 0xf
        mov [refXpos2], ax
        jmp short .45
        db 0x90
.44:
        mov bx, [bp - 0x8]
        mov word [bx + 0x36], 0x6
        mov ax, [fox]
        add ax, strict word 0xf
        mov [bx + 0x2], ax
.45:
        mov ax, [foy]
        mov bx, [bp - 0x8]
        mov [bx + 0x6], ax
        cmp word [bx + 0x36], 0x3
        jng short .46
        mov ax, 0x2c7
        jmp short .47
        db 0x90
.46:
        mov ax, 0x2bf
.47:
        mov bx, [bp - 0x8]
        mov [bx + 0x12], ax
        push 0x1e
        push bx
        call 0x1E7E:assinsert
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x8]
        mov [bx + 0xc], ax
        mov [bx + 0xe], ax
        and byte [bx + 0x44], 0xdf
        mov ax, 0xc57
        call 0x2E42:SetSPA
        call 0x2E42:SprSort
        mov ax, 0xffff
        mov [c1playernum], ax
        mov [c2playernum], ax
        cmp word [cont1team], 0x0
        jz short .48
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [regd4], ax
        push ax
        push word [bp + 0x6]
        call 0x2E42:changeplayer
        add sp, 0x4
.48:
        cmp word [cont2team], 0x0
        jz short .49
        mov word [regd4], 0x2
        mov word [regd4_w2], 0x0
        push word [regd4]
        push word [bp + 0x6]
        call 0x2E42:changeplayer
        add sp, 0x4
.49:
        call 0x2C24:CenterMouse
        mov ax, 0x78
        call 0x0C11:randomd0
        add ax, 0xb4
        mov bx, [bp + 0x6]
        mov [bx + 0x26], ax
        mov word [fofdata2], 0x1
        mov word [fofdata_w2], 0x4
        mov word [fofdata_w4], 0xa800
        mov word [fofdata_w6], 0x7
        mov ax, 0x8000
        mov [fofdata], ax
        mov [fofdata_w8], ax
        test byte [gmode], 0x2
        jnz short .50
        mov word [fofdata], 0x8800
        mov word [fofdata_w4], 0xa000
.50:
        mov ax, 0xffff
        mov [fodir2], ax
        mov [fodir1], ax
        pop si
        leave
        retf
        db 0x90
.51:
        dec word [bx + 0x26]
        js short .53
        cmp word [bx + 0x26], 0x11
        jnz short .52
        lea bx, [refstruct]
        mov ax, 0xc43
        call 0x2E42:SetSPA
.52:
        mov bx, [bp + 0x6]
        cmp word [bx + 0x26], 0x0
        jz short .54
        mov ax, [bx + 0x26]
        add ax, strict word 0x6
        sar ax, byte 0x3
        mov [regd0], ax
        cmp ax, strict word 0x2
        jg short .54
        sub ax, strict word 0xa
        neg ax
        mov [fofdata_w6], ax
        pop si
        leave
        retf
.53:
        push word [bp + 0x6]
        call 0x2519:Endfaceoff
        add sp, 0x2
.54:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; assbenchwait                                               2164:0CB0  94 PC
; Assignment: waits on the bench until the player is sent back on.
;
; Takes 1 word of stack arguments. Calls check4bench. Far routine (retf).
;-----------------------------------------------------------------------------
assbenchwait:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jnz short .1
        mov word [si + 0x12], 0xffff
        push si
        push cs
        call check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov word [si + 0x26], 0x64
        mov word [si + 0x2e], 0x0
.1:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; asstakeposition                                            2164:0CDC  94 PC
; Assignment: the goalie goes to his net; a skater skates to his position slot for the team's
; formation.
;
; Takes 1 word of stack arguments. Calls check4bench, assexit, ImulRegs, __aFldiv, SetSPA,
; VectorToDir8, skateto, SkateToSpot. Far routine (retf).
;-----------------------------------------------------------------------------
asstakeposition:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near .30
.1:
        push si
        push cs
        call check4bench
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .30
.2:
        cmp word [si + 0x2e], -0x64
        jnz short .4
        push si
        call 0x2519:assexit
        add sp, 0x2
        mov bx, [si + 0x1c]
        mov al, [bx + si + 0x1e]
        cmp al, 0x7
        jz short .3
        cmp al, 0x28
        jz short .3
        jmp near .30
.3:
        push si
        call 0x2519:assexit
        add sp, 0x2
        pop si
        pop di
        leave
        retf
.4:
        test byte [si + 0x44], 0x2
        jnz short .5
        jmp near .14
.5:
        and byte [si + 0x44], 0xfd
        mov word [si + 0x28], 0x8
        mov [si + 0x26], ax
        mov ax, [si + 0x1a]
        mov [regd1], ax
        mov bx, [si + 0x60]
        mov ax, [bx + 0x22]
        neg ax
        mov [regd4], ax
        cmp ax, strict word 0xfffa
        jng short .6
        mov bx, [si + 0x60]
        cmp word [bx + 0x24], 0x0
        jnl short .6
        dec word [regd4]
.6:
        mov di, [regd4]
        add di, 0x6
        shl di, byte 0x3
        mov [regd4], di
        mov bx, [regd1]
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
        jnz short .7
        neg word [regd0]
        neg word [regd1]
.7:
        cmp word [si + 0x1a], 0x0
        jz short .10
        cmp word [regd4], 0x4
        jg short .9
        mov ax, [regd0]
        xor ax, [fox]
        jnl short .8
        mov ax, [foy]
        sar ax, byte 0x3
        sub [regd1], ax
.8:
        mov ax, [fox]
        sar ax, byte 0x2
        sub [regd0], ax
.9:
        mov ax, [fox]
        add [regd0], ax
        mov ax, [foy]
        add [regd1], ax
        jmp short .13
.10:
        mov ax, [foy]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x27
        jng short .13
        cmp word [foy], 0x0
        jnl short .11
        mov ax, 0x1
        jmp short .12
        db 0x90
.11:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.12:
        mov cl, [si + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .13
        push 0x0
        push word 0x1000
        mov ax, [foy]
        mov cl, [si + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x4e
        add cx, -0x27
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [fox]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        call 0x03A3:ImulRegs
        push dx
        push ax
        call 0x0000:__aFldiv
        add [regd0], ax
.13:
        mov ax, [regd0]
        mov [si + 0x2a], ax
        mov ax, [regd1]
        mov [si + 0x2c], ax
        or byte [si + 0x45], 0x20
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0x30], ax
        mov [si + 0x32], ax
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfe10
        add ax, 0x289
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
.14:
        mov ax, [si + 0x6]
        sub ax, [si + 0x2c]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        sub dx, [si + 0x2a]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0xa], di
        mov [bp - 0x8], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xa]
        adc dx, [bp - 0x8]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .15
        jmp near .26
.15:
        jl short .16
        cmp ax, strict word 0x40
        jc short .16
        jmp near .26
.16:
        mov ax, [si + 0xc]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jl short .17
        jmp near .26
.17:
        mov ax, [si + 0xe]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x10
        jl short .18
        jmp near .26
.18:
        mov ax, [si + 0x2a]
        mov [si + 0x2], ax
        mov ax, [si + 0x2c]
        mov [si + 0x6], ax
        dec word [si + 0x26]
        js short .19
        jmp near .30
.19:
        add word [si + 0x26], 0x8
        cmp word [si + 0x1a], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfe10
        add ax, 0x289
        db 0x8B, 0xDE                           ; insn: mov bx, si
        call 0x2E42:SetSPA
        mov ax, [fox]
        sub ax, [si + 0x2]
        mov dx, [foy]
        sub dx, [si + 0x6]
        call 0x0D5F:VectorToDir8
        cwd
        mov [regd2], ax
        mov [regd2_w2], dx
        cmp word [si + 0x1a], 0x0
        jnz short .22
        cmp ax, strict word 0x2
        jnz short .20
        mov al, [si + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, strict word 0x2
        inc ax
        jmp short .21
        db 0x90
.20:
        cmp ax, strict word 0x6
        jnz short .22
        mov al, [si + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xfe
        add ax, strict word 0x7
.21:
        mov [regd2], ax
.22:
        mov ax, [regd2]
        cmp [si + 0x36], ax
        jz short .25
        mov al, [regd2]
        sub al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd2], ax
        cmp ax, strict word 0x5
        jl short .23
        mov ax, 0xffff
        jmp short .24
.23:
        mov ax, 0x1
.24:
        add al, [si + 0x36]
        and ax, strict word 0x7
        mov [si + 0x36], ax
        pop si
        pop di
        leave
        retf
.25:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + 0xe], ax
        mov [si + 0xc], ax
        mov word [si + 0x2e], 0xff9c
        pop si
        pop di
        leave
        retf
        db 0x90
.26:
        mov ax, [si + 0x2a]
        mov [regd0], ax
        mov ax, [si + 0x2c]
        mov [regd1], ax
        cmp word [bp - 0x2], 0x0
        jl short .28
        jg short .27
        cmp word [bp - 0x4], 0x190
        jc short .28
.27:
        push 0x0
        push 0x0
        push si
        call 0x2425:skateto
        jmp short .29
        db 0x90
.28:
        push 0x0
        push 0x0
        push si
        call 0x2519:SkateToSpot
.29:
        add sp, 0x6
.30:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; check4bench                                                2164:0FC4  94 PC
; Returns 1 when the player was taken off for a line change, 0 when he stays; called by every skater
; assignment.
;
; Takes 1 word of stack arguments. Calls assreplace, Setplass, assinsert. Far routine (retf).
;-----------------------------------------------------------------------------
check4bench:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        test byte [gmode], 0x1
        jnz short .1
        test byte [si + 0x44], 0x8
        jz short .1
        jmp near .15
.1:
        test byte [si + 0x45], 0x10
        jz short .2
        jmp near .15
.2:
        cmp byte [si + 0x42], 0x0
        jnl short .3
        cmp byte [si + 0x43], 0x0
        jnl short .3
        jmp near .15
.3:
        mov al, [si + 0x43]
        cmp [si + 0x47], al
        jz short .7
        mov bx, [si + 0x1c]
        cmp byte [bx + si + 0x1e], 0xb
        jnz short .4
        jmp near .15
.4:
        mov bx, [puckc]
        mov al, [bx]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .5
        jmp near .15
.5:
        or byte [si + 0x45], 0x4
        and byte [si + 0x44], 0xfb
        mov word [si + 0x26], 0x0
        test byte [gmode], 0x1
        jz short .6
        mov word [si + 0x2e], 0x0
.6:
        push 0xb
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
        jmp short .14
.7:
        and byte [si + 0x45], 0xfb
        and byte [si + 0x44], 0xfb
        cmp byte [si + 0x42], 0x0
        jl short .10
        cmp byte [si + 0x47], 0x19
        jnl short .8
        mov ax, 0x1
        jmp short .9
        db 0x90
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        cmp byte [si + 0x42], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC1                           ; insn: xor ax, cx
        jz short .10
        mov al, [si + 0x42]
        cbw
        mov [si + 0x1a], ax
.10:
        push si
        call 0x2E42:Setplass
        add sp, 0x2
        test byte [gmode], 0x1
        jz short .13
        mov word [si + 0x2e], 0x0
        mov bx, [si + 0x1c]
        cmp byte [bx + si + 0x1e], 0x28
        jnz short .11
        push 0x27
        push si
        call 0x1E7E:assreplace
        jmp short .12
        db 0x90
.11:
        push 0x27
        push si
        call 0x1E7E:assinsert
.12:
        add sp, 0x4
.13:
        mov al, 0xff
        mov [si + 0x43], al
        mov [si + 0x42], al
.14:
        mov ax, 0x1
        pop si
        leave
        retf
        db 0x90
.15:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
