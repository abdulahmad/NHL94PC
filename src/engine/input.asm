; Controller input queue and player input (AI.OVL)
; The first bytes finish the last routine of physics.asm.
        leave
        retf

;-----------------------------------------------------------------------------
; joyq_pop                                                   2C24:0002  94 PC
; Takes the oldest record off the input queue that the timer samples into.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
joyq_pop:
        cmp word [PadRepeatDelay], 0x0
        jng short .2
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        dec word [PadRepeatDelay]
        inc word [PadRepeatStep]
        cmp word [PadRepeatStep], 0x32
        jl short .1
        mov word [PadRepeatStep], 0x0
.1:
        mov [PadRepeatOn], ax
.2:
        retf

;-----------------------------------------------------------------------------
; joyq_flush                                                 2C24:002E  94 PC
; Empties the input queue.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
joyq_flush:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PadRepeatDelay], ax
        mov [PadRepeatTimer], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; joyq_peek                                                  2C24:0038  94 PC
; Returns the oldest input queue record, or 0 when the queue is empty.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
joyq_peek:
        cmp word [PadRepeatDelay], 0x0
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
.1:
        mov ax, [PadRepeatStep]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, 0xafd4
        retf
        db 0x90

;-----------------------------------------------------------------------------
; lineinput                                                  2C24:0050  94 PC
; Line change box input: the highlighted choice cycles and blinks; a press takes it.
;
; Takes 1 word of stack arguments. Calls RequestLineChange, lcfound, doplayeracc. Far routine (retf).
;-----------------------------------------------------------------------------
lineinput:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [di + 0x60]
        test byte [si + 0x2a], 0x1
        jz short .1
        and byte [si + 0x2a], 0xfe
        push di
        call 0x2519:RequestLineChange
        add sp, 0x2
.1:
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xF6                           ; insn: sbb si, si
        inc si
        test byte [regd2], 0x40
        jz short .2
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov ax, [bx + lcchoice]
        mov [regd2], ax
        push di
        mov [bp - 0x2], bx
        push cs
        call lcfound
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x2]
        mov [bx + lcsel], ax
        mov [bx + lcboxon], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov [bp - 0x4], bx
        mov ax, [bx + lctime]
        dec word [bx + lctime]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        mov bx, [bp - 0x4]
        add word [bx + lctime], 0x3c
        cmp word [bx + lcgroup], 0x3
        jng short .3
        mov bx, [bp - 0x4]
        mov ax, [bx + lcchoice]
        inc ax
        mov cx, 0x2
        jmp short .4
        db 0x90
.3:
        mov bx, [bp - 0x4]
        mov ax, [bx + lcchoice]
        inc ax
        mov cx, 0x4
.4:
        cwd
        idiv cx
        mov [bx + lcchoice], dx
        mov bx, [bp - 0x4]
        mov bx, [bx + lcgroup]
        shl bx, 1
        mov ax, [bx + LineChoiceKeys]
        mov bx, [bp - 0x4]
        mov [bx + lcgroup], ax
        mov word [bx + lcsel], 0x1
        mov word [bx + lcblink], 0xc
.5:
        mov bx, [bp - 0x4]
        mov ax, [bx + lcblink]
        dec word [bx + lcblink]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
        mov bx, [bp - 0x4]
        add word [bx + lcblink], 0xc
        cmp word [bx + lcsel], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        mov [bx + lcsel], ax
.6:
        test byte [di + 0x44], 0x8
        jz short .7
        cmp word [playsuspended], 0x0
        jnz short .7
        test byte [di + 0x44], 0x20
        jnz short .7
        test byte [di + 0x45], 0x1
        jnz short .7
        push word [regd0]
        push di
        call 0x2425:doplayeracc
        add sp, 0x4
.7:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; faceoffinput                                               2C24:0158  94 PC
; Faceoff input: the pull direction, with an automatic pull when the timer runs out.
;
; Takes 1 word of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
faceoffinput:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        mov bx, [si + 0x1c]
        cmp byte [bx + si + 0x1e], 0x17
        jnz short .6
        test byte [si + 0x44], 0x80
        jz short .1
        mov ax, [regd0]
        mov [fodir2], ax
        jmp short .2
.1:
        mov ax, [regd0]
        mov [fodir1], ax
.2:
        test byte [si + 0x45], 0x2
        jnz short .6
        test byte [regd1], 0x10
        jnz short .3
        dec word [si + 0x2e]
        jns short .6
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x7f1
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90
.3:
        or byte [si + 0x45], 0x2
        cmp word [pucktemp1], 0x11
        jnl short .4
        or byte [si + 0x44], 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x7dd
        jmp short .5
.4:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xd05
.5:
        call 0x2E42:SetSPA
        mov word [si + 0x2e], 0xffff
.6:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; Acheck                                                     2C24:01C4  94 PC
; Starts a hold check of one player against another and locks the animation.
;
; Takes 2 words of stack arguments. Calls SetSPA. Far routine (retf).
;-----------------------------------------------------------------------------
Acheck:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        or byte [si + 0x44], 0x20
        cmp word [si + 0x18], 0x0
        jnz short .1
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x873
        call 0x2E42:SetSPA
.1:
        mov dx, [si + 0x6]
        mov bx, [bp + 0x8]
        sub dx, [bx + 0x6]
        test byte [si + 0x44], 0x80
        jz short .2
        neg dx
.2:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .3
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x873
        jmp short .4
        db 0x90
.3:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x639
.4:
        call 0x2E42:SetSPA
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; Holdplayer                                                 2C24:020A  94 PC
; Hold button without the puck: hold, shot block dive or hold check.
;
; Takes 1 word of stack arguments. Calls SetSPA, Acheck. Far routine (retf).
;-----------------------------------------------------------------------------
Holdplayer:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov si, [bp + 0x6]
        or byte [si + 0x44], 0x20
        cmp word [si + 0x18], 0x0
        jnz short .1
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0x873
        call 0x2E42:SetSPA
.1:
        mov ax, [si + 0x14]
        shl ax, byte 0x7
        add ax, 0xb50e
        push ax
        push si
        push cs
        call Acheck
        add sp, 0x4
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; lcselect                                                   2C24:023A  94 PC
; Line change by number from the keyboard keys.
;
; Takes 2 words of stack arguments. Calls DrawPanelLine, setpersonel. Far routine (retf).
;-----------------------------------------------------------------------------
lcselect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [CrowdState], 0x4
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.2:
        mov di, [bp + 0x6]
        mov si, [di + 0x60]
        mov bx, [di + 0x62]
        mov ax, [bx + 0x22]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        sub ax, [bx + 0x22]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov cx, [bp + 0x8]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        cmp cx, 0x1
        jg short .1
.3:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .4
        cmp cx, 0x3
        jg short .1
.4:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .5
        add cx, 0x4
        jmp short .6
        db 0x90
.5:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .6
        add cx, 0x6
.6:
        and byte [di + 0x45], 0xf7
        or byte [di + 0x44], 0x8
        and byte [si + 0x2a], 0xfd
        cmp [si + 0x16], cx
        jz short .8
        mov [si + 0x16], cx
        cmp cx, 0x4
        jnl short .7
        inc word [si + 0x18]
        cmp word [si + 0x18], 0x3
        jl short .7
        sub word [si + 0x18], 0x3
.7:
        push cx
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2083:DrawPanelLine
        add sp, 0x4
        push si
        call 0x2E42:setpersonel
        add sp, 0x2
.8:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; doinput                                                    2C24:02D0  94 PC
; Controller input for a controlled player: line change, faceoff, pass, shot, check and skate.
;
; Takes 2 words of stack arguments. Calls lcselect, faceoffinput, lineinput, restorepl, checkob,
; passmode, ShotMode, setpassmode and others. Far routine (retf).
;-----------------------------------------------------------------------------
doinput:
        enter 0x8, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xFF                           ; insn: sbb di, di
        inc di
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        cmp word [bx + controlled], 0x0
        jz short .4
        mov ax, [cont1team]
        cmp [cont2team], ax
        jnz short .1
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jnz short .4
.1:
        test byte [gmode], 0x1
        jz short .2
        test byte [si + 0x45], 0x8
        jz short .3
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov [bp - 0x2], bx
        push word [bx + lcline]
        push si
        push cs
        call lcselect
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov bx, [bp - 0x2]
        mov [bx + lcsel], ax
        mov [bx + lcboxon], ax
.3:
        shl di, 1
        mov word [di + controlled], 0x0
.4:
        test byte [gmode2], 0x1
        jz short .6
        push si
        push cs
        call faceoffinput
.5:
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        test byte [si + 0x45], 0x8
        jz short .7
        push si
        push cs
        call lineinput
        jmp short .5
        db 0x90
.7:
        mov bx, [puck_1C]
        cmp byte [bx + puckasslist], 0x1c
        jnz short .9
        test byte [regd1], 0x10
        jnz short .8
        test byte [regd1], 0x20
        jnz short .8
        jmp near .54
.8:
        mov word [introskipped], 0x1
        pop si
        pop di
        leave
        retf
.9:
        test byte [si + 0x44], 0x8
        jnz short .10
        jmp near .54
.10:
        test byte [si + 0x44], 0x20
        jnz short .11
        jmp near .30
.11:
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x4], al
        cbw
        cmp ax, [si + 0x5e]
        jnz short .12
        jmp near .54
.12:
        test byte [regd1], 0x10
        jz short .13
        jmp near .40
.13:
        mov ax, [passplayer]
        cmp [si + 0x5e], ax
        jnz short .17
.14:
        test byte [regd1], 0x20
        jz short .15
        test byte [si + 0x45], 0x4
        jnz short .15
        cmp byte [bp - 0x4], 0x0
        jnl short .15
        mov word [onetimerflag], 0x1
.15:
        cmp word [onetimerflag], 0x0
        jnz short .16
        jmp near .54
.16:
        mov al, [regd0]
        and ax, strict word 0xf
        mov [passdir], ax
        pop si
        pop di
        leave
        retf
.17:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, byte 0x7
        add di, 0xb50e
        cmp byte [bp - 0x4], 0x0
        jl short .18
        jmp near .54
.18:
        test byte [regd1], 0x20
        jnz short .19
        jmp near .54
.19:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .20
        jmp near .54
.20:
        cmp ax, strict word 0x6
        jnl short .21
        mov ax, 0x1
        jmp short .22
        db 0x90
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        mov [bp - 0x6], ax
        cmp word [si + 0x5e], 0x6
        jnl short .23
        mov ax, 0x1
        jmp short .24
.23:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.24:
        cmp ax, [bp - 0x6]
        jz short .25
        jmp near .54
.25:
        test byte [di + 0x44], 0x8
        jz short .26
        jmp near .54
.26:
        test byte [di + 0x45], 0x4
        jz short .27
        jmp near .54
.27:
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jz short .28
        jmp near .48
.28:
        cmp [di + 0x5e], ax
        jnz short .29
        jmp near .49
.29:
        push ax
        push word [di + 0x5e]
        call 0x2E42:restorepl
        add sp, 0x4
        mov [c1playernum], ax
        jmp near .49
        db 0x90
.30:
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x4], al
        cbw
        cmp ax, [si + 0x5e]
        jnz short .38
        push si
        call 0x28BB:checkob
        add sp, 0x2
        cmp word [si + 0x1a], 0x0
        jnz short .31
        test byte [si + 0x45], 0x2
        jz short .31
        jmp near .54
.31:
        test byte [sflags], 0x4
        jz short .32
        push si
        call 0x28BB:passmode
        jmp near .5
        db 0x90
.32:
        test byte [sflags], 0x8
        jz short .33
        push si
        call 0x28BB:ShotMode
        jmp near .5
.33:
        test byte [regd1], 0x10
        jz short .34
        push si
        call 0x28BB:setpassmode
        jmp near .5
.34:
        test byte [regd1], 0x40
        jz short .35
        push si
        call 0x2519:SetLCmode
        jmp near .5
.35:
        cmp word [si + 0x1a], 0x0
        jnz short .36
        jmp near .54
.36:
        test byte [regd1], 0x20
        jnz short .37
        jmp near .52
.37:
        push si
        call 0x28BB:SetShotMode
        jmp near .5
.38:
        test byte [regd1], 0x40
        jz short .39
        push si
        push cs
        call Holdplayer
        jmp near .5
        db 0x90
.39:
        test byte [regd1], 0x10
        jz short .41
.40:
        push word [bp + 0x8]
        push si
        call 0x2E42:changeplayer
        jmp near .53
        db 0x90
.41:
        cmp word [si + 0x1a], 0x0
        jnz short .42
        jmp near .54
.42:
        mov di, [passplayer]
        shl di, byte 0x7
        add di, 0xb50e
        mov ax, [passplayer]
        cmp [si + 0x5e], ax
        jnz short .43
        jmp near .14
.43:
        cmp byte [bp - 0x4], 0x0
        jnl short .50
        test byte [regd1], 0x20
        jz short .50
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .50
        cmp ax, strict word 0x6
        jnl short .44
        mov ax, 0x1
        jmp short .45
.44:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.45:
        mov [bp - 0x8], ax
        cmp word [si + 0x5e], 0x6
        jnl short .46
        mov ax, 0x1
        jmp short .47
.46:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.47:
        cmp ax, [bp - 0x8]
        jnz short .50
        test byte [di + 0x44], 0x8
        jnz short .50
        test byte [di + 0x45], 0x4
        jnz short .50
        mov ax, [c1playernum]
        cmp [si + 0x5e], ax
        jnz short .48
        jmp near .28
.48:
        mov ax, [c2playernum]
        cmp [di + 0x5e], ax
        jz short .49
        push ax
        push word [di + 0x5e]
        call 0x2E42:restorepl
        add sp, 0x4
        mov [c2playernum], ax
.49:
        mov word [onetimerflag], 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.50:
        test byte [regd1], 0x20
        jz short .51
        push si
        call 0x28BB:burst
        jmp near .5
.51:
        cmp word [playsuspended], 0x0
        jnz short .54
.52:
        push word [regd0]
        push si
        call 0x2425:doplayeracc
.53:
        add sp, 0x4
.54:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; getlchoice                                                 2C24:05C0  94 PC
; Returns the line for a line change choice.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
getlchoice:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov bx, [bp + 0x6]
        mov si, [bx + 0x60]
        mov di, [bx + 0x62]
        mov ax, [di + 0x22]
        mov bx, [bx + 0x60]
        sub ax, [bx + 0x22]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        add word [regd0], 0x20
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .1
        add word [regd0], 0x20
.1:
        mov ax, [si + 0x16]
        mov [regd1], ax
        shl ax, byte 0x2
        add [regd0], ax
        mov bx, [regd0]
        mov al, [bx + lchoicetab_m1]
        cbw
        mov [regd0], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; lcfound                                                    2C24:0608  94 PC
; Applies a line change choice: sets the team's line and its personnel.
;
; Takes 1 word of stack arguments. Calls getlchoice, DrawPanelLine, setpersonel. Far routine (retf).
;-----------------------------------------------------------------------------
lcfound:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [di + 0x60]
        mov ax, [regd2]
        mov [regd0], ax
        push di
        push cs
        call getlchoice
        add sp, 0x2
        cmp word [regd0], 0x0
        jl short .2
        and byte [di + 0x45], 0xf7
        or byte [di + 0x44], 0x8
        and byte [si + 0x2a], 0xfd
        mov ax, [regd0]
        cmp [si + 0x16], ax
        jz short .2
        mov [si + 0x16], ax
        cmp word [regd0], 0x4
        jnl short .1
        inc word [si + 0x18]
        cmp word [si + 0x18], 0x3
        jl short .1
        sub word [si + 0x18], 0x3
.1:
        push word [regd0]
        mov al, [di + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2083:DrawPanelLine
        add sp, 0x4
        push si
        call 0x2E42:setpersonel
        add sp, 0x2
.2:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadJoy1                                                   2C24:0678  94 PC
; Reads the first controller from the input record.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ReadJoy1:
        cmp word [joyrec], 0x0
        jz short .1
        mov bx, [joyrec]
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [regd0], ax
        jmp short .2
.1:
        mov word [regd0], 0x8
.2:
        mov ax, [lj1]
        mov [regd2], ax
        mov al, [regd0]
        and ax, strict word 0x70
        mov [regd1], ax
        mov [lj1], ax
        mov [regd3], ax
        xor [regd2], ax
        and ax, [regd2]
        mov [regd1], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadJoy2                                                   2C24:06B4  94 PC
; Reads the second controller from the input record.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ReadJoy2:
        cmp word [joyrec], 0x0
        jz short .1
        mov bx, [joyrec]
        mov al, [bx + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [regd0], ax
        jmp short .2
        db 0x90
.1:
        mov word [regd0], 0x8
.2:
        mov ax, [lj2]
        mov [regd2], ax
        mov al, [regd0]
        and ax, strict word 0x70
        mov [regd1], ax
        mov [lj2], ax
        mov [regd3], ax
        xor [regd2], ax
        and ax, [regd2]
        mov [regd1], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CenterMouse                                                2C24:06F2  94 PC
; Puts the mouse at the centre of the screen.
;
; Calls MouseMove. Far routine (retf).
;-----------------------------------------------------------------------------
CenterMouse:
        push 0x64
        push word 0xa0
        call 0x03A3:MouseMove
        add sp, 0x4
        retf

;-----------------------------------------------------------------------------
; PassCompleted                                              2C24:0700  94 PC
; A pass reached a teammate: counts it for the team.
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PassCompleted:
        enter 0x2, 0x0
        cmp word [passplayer], 0x0
        jl short .5
        mov bx, [bp + 0x6]
        cmp word [passplayer], 0x6
        jnl short .1
        mov ax, 0x1
        jmp short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        mov [bp - 0x2], ax
        cmp word [bx + 0x5e], 0x6
        jnl short .3
        mov ax, 0x1
        jmp short .4
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        cmp ax, [bp - 0x2]
        jnz short .5
        test byte [gmode], 0x10
        jnz short .5
        mov bx, [bx + 0x60]
        inc word [bx + 0x14]
.5:
        mov word [passplayer], 0xffff
        leave
        retf

;-----------------------------------------------------------------------------
; assonetimer                                                2C24:0746  94 PC
; Assignment: the one-timer shot when the pass arrives.
;
; Takes 1 word of stack arguments. Calls ImulRegs, VectorToDir8, Findhittype, SetSPA, updateanim,
; a2touchpuck, doshot, PassCompleted and others. Far routine (retf).
;-----------------------------------------------------------------------------
assonetimer:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x6], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .1
        jmp near .21
.1:
        cmp byte [si + 0x27], 0xe7
        jnl short .2
        jmp near .21
.2:
        cmp word [onetimerflag], 0x0
        jnz short .3
        jmp near .24
.3:
        cmp word [si + 0x38], 0xdd3
        jnz short .4
        jmp near .10
.4:
        cmp word [si + 0x38], 0xe2b
        jnz short .5
        jmp near .10
.5:
        cmp byte [si + 0x27], 0x16
        jng short .6
        jmp near .24
.6:
        cmp byte [si + 0x27], 0xf6
        jnl short .7
        jmp near .24
.7:
        mov al, [si + 0x27]
        cbw
        add ax, strict word 0xa
        shl ax, byte 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov bx, [puckvx]
        mov ax, [bx]
        call 0x03A3:ImulRegs
        mov bx, [puckx]
        add dx, [bx]
        neg dx
        mov [bp - 0x2], dx
        mov bx, [puckvy]
        mov ax, [bx]
        db 0x8B, 0xD7                           ; insn: mov dx, di
        call 0x03A3:ImulRegs
        mov al, [si + 0x44]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfe30
        add ax, 0xe8
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov bx, [pucky]
        sub ax, [bx]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov ax, [bp - 0x2]
        call 0x0D5F:VectorToDir8
        push ax
        push si
        call 0x28BB:Findhittype
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xe2b
.8:
        call 0x2E42:SetSPA
        pop si
        pop di
        leave
        retf
.9:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, 0xdd3
        jmp short .8
        db 0x90
.10:
        mov word [si + 0x3e], 0x5
        mov al, [si + 0x36]
        and ax, strict word 0x7
        mov [regd0], ax
        test byte [si + 0x49], 0x8
        jz short .11
        neg ax
        and ax, strict word 0x7
        mov [regd0], ax
.11:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov al, [bx + OneTimerDirs2]
        cbw
        mov [regd1], ax
        mov al, [bx + OneTimerDirs]
        cbw
        mov [regd0], ax
        test byte [si + 0x49], 0x8
        jz short .12
        neg word [regd0]
.12:
        mov ax, [si + 0x6]
        mov bx, [pucky]
        sub ax, [bx]
        add ax, [regd1]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        call 0x03A3:ImulRegs
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [si + 0x2]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov di, [puckx]
        sub dx, [di]
        add dx, [regd0]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0xa], di
        mov [bp - 0x8], bx
        call 0x03A3:ImulRegs
        add ax, [bp - 0xa]
        adc dx, [bp - 0x8]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        cmp word [si + 0x3a], 0x0
        jnz short .13
        cmp byte [si + 0x27], 0xfc
        jl short .14
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .14
        jg short .13
        cmp ax, 0x190
        jc short .14
.13:
        cmp word [si + 0x3a], 0x2
        jnz short .15
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jg short .15
        jl short .14
        cmp ax, 0x100
        jnc short .15
.14:
        mov word [si + 0x3c], 0x0
        push si
        call 0x2E42:updateanim
        add sp, 0x2
.15:
        cmp word [bp - 0x2], 0x0
        jl short .19
        jg short .16
        cmp word [bp - 0x4], 0x64
        jna short .19
.16:
        cmp word [bp - 0x2], 0x0
        jng short .17
        jmp near .24
.17:
        jl short .18
        cmp word [bp - 0x4], 0x90
        jna short .18
        jmp near .24
.18:
        cmp byte [si + 0x27], 0xf6
        jnl short .24
.19:
        cmp word [passdir], 0x8
        jng short .20
        mov word [passdir], 0x8
.20:
        mov al, [si + 0x4f]
        shr al, 1
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add ax, strict word 0x1e
        mov [passspeed], ax
        mov ax, 0x4
        mov [si + 0x3a], ax
        mov [si + 0x3c], ax
        mov byte [si + 0x46], 0x0
        push si
        call 0x2E42:updateanim
        add sp, 0x2
        add word [CrowdSound], 0x64
        push si
        call 0x2519:a2touchpuck
        add sp, 0x2
        push si
        call 0x28BB:doshot
        add sp, 0x2
        push si
        push cs
        call PassCompleted
        add sp, 0x2
        jmp short .23
        db 0x90, 0x90
.21:
        mov al, [bp - 0x6]
        cbw
        cmp ax, [si + 0x5e]
        jnz short .22
        push si
        push cs
        call PassCompleted
        add sp, 0x2
.22:
        mov word [passplayer], 0xffff
.23:
        and byte [si + 0x44], 0xfe
        push si
        call 0x2519:assexit
        add sp, 0x2
        mov word [onetimerflag], 0x0
.24:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; OneTimerChk                                                2C24:096C  94 PC
; Looks for a one-timer chance for a receiver in the attacking zone.
;
; Takes 1 word of stack arguments. Calls randomd0. Far routine (retf).
;-----------------------------------------------------------------------------
OneTimerChk:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, [di + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp bx, 0x4e
        jg short .1
        jmp near .12
.1:
        cmp bx, 0xde
        jl short .2
        jmp near .12
.2:
        cmp word [di + 0x6], 0x0
        jnl short .3
        mov ax, 0x1
        jmp short .4
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.4:
        mov cl, [di + 0x44]
        and cl, 0x80
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .12
        mov bx, [di + 0x62]
        cmp word [bx + 0x24], 0x0
        jl short .12
        cmp word [di + 0x5e], 0x6
        jl short .5
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        jmp short .6
        db 0x90
.5:
        mov bx, 0x6
.6:
        shl bx, byte 0x7
        add bx, 0xb50e
        db 0x2B, 0xD2                           ; insn: sub dx, dx
.7:
        cmp word [bx + 0x1a], 0x0
        jz short .8
        add bx, 0x80
        inc dx
        cmp dx, 0x6
        jl short .7
.8:
        mov cx, 0x3
        mov ax, [di + 0x2]
        xor ax, [bx + 0x2]
        jz short .11
        mov ax, [bx + 0x2]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0xc
        jng short .10
.9:
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
        db 0x90
.10:
        db 0x8B, 0xF7                           ; insn: mov si, di
        cmp si, 0x6
        jng short .11
        mov cx, 0x2
.11:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        call 0x0C11:randomd0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .9
.12:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; asspassrec                                                 2C24:0A1C  94 PC
; Assignment: catching a pass, with the one-timer and pass statistics.
;
; Takes 1 word of stack arguments. Calls donothing, assonetimer, OneTimerChk, assexit, PassCompleted.
; Far routine (retf).
;-----------------------------------------------------------------------------
asspassrec:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        test byte [si + 0x44], 0x20
        jz short .1
        jmp near asspassrecTail + 0xAE0
.1:
        test byte [gmode], 0x1
        jz short .3
        push si
        call 0x2519:donothing
.2:
        add sp, 0x2
        pop si
        leave
        retf
.3:
        dec byte [si + 0x27]
        test byte [si + 0x44], 0x8
        jz short .5
.4:
        push si
        push cs
        call assonetimer
        jmp short .2
.5:
        test byte [si + 0x44], 0x2
        jz short .6
        and byte [si + 0x44], 0xfd
        or byte [si + 0x44], 0x1
        mov word [si + 0x28], 0x8
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        inc ax
        mov [regd0], ax
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .6
        cmp [cont1team], ax
        jz short .6
        cmp [cont2team], ax
        jz short .6
        push si
        push cs
        call OneTimerChk
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        mov word [onetimerflag], 0x1
.6:
        cmp word [onetimerflag], 0x0
        jnz short .4
        mov bx, [puckc]
        cmp byte [bx], 0x0
        jnl short .7
        cmp byte [si + 0x27], 0xfb
        jnl short asspassrecTail + 0xAE0
.7:
        and byte [si + 0x44], 0xfe
        push si
        call 0x2519:assexit
        add sp, 0x2
        mov word [onetimerflag], 0x0
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x2], al
        cbw
        cmp ax, [si + 0x5e]
        jnz short .8
        push si
        push cs
        call PassCompleted
        jmp near .2
.8:
        cmp byte [bp - 0x2], 0x0
        jl short asspassrecTail + 0xAE0
        mov word [passplayer], 0xffff
