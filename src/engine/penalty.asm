; Penalties: calls, referee signal and penalty times (AI.OVL)

;-----------------------------------------------------------------------------
; GetPeriodTimeRemaining                                     327B:0000  94 PC
; (period << 14) - clock + the time base.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
GetPeriodTimeRemaining:
        mov ah, [gsp]
        shl ah, byte 0x6
        db 0x2A, 0xC0                           ; insn: sub al, al
        sub ax, [gameclock]
        add ax, [gameclock2]
        retf

;-----------------------------------------------------------------------------
; AddPenalty                                                 327B:0012  94 PC
; Calls AddPenalty2 unless the clock is stopped or the crowd state forbids it.
;
; Takes 2 words of stack arguments. Calls CanRemovePlayer, AddPenalty2. Far routine (retf).
;-----------------------------------------------------------------------------
AddPenalty:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [gmode], 0x1
        jnz short .5
        mov si, [bp + 0x6]
        cmp word [si + 0x5e], 0x10
        jz short .5
        mov di, [bp + 0x8]
        cmp di, 0x6
        jz short .4
        cmp di, 0x8
        jnz short .2
        test byte [CrowdState], 0x2
.1:
        jnz short .4
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        cmp di, 0x17
        jnz short .3
        test byte [CrowdState], 0x8
        jmp short .1
.3:
        test byte [CrowdState], 0x1
        jz short .5
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xDB                           ; insn: sbb bx, bx
        inc bx
        cmp byte [bx + PBnum], 0x8
        jnl short .5
        push si
        call 0x317A:CanRemovePlayer
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
.4:
        push di
        push si
        push cs
        call AddPenalty2
        add sp, 0x4
.5:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; AddPenalty2                                                327B:007E  94 PC
; Calls a penalty on a player: banner, penalty list and delayed penalty.
;
; Takes 2 words of stack arguments. Calls PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
AddPenalty2:
        enter 0x4, 0x0
        push di
        push si
        test byte [sflags], 0x80
        jz short .1
        jmp near .11
.1:
        cmp word [SortPending], 0x0
        jz short .2
        jmp near .11
.2:
        mov si, [bp + 0x8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov ax, [bx + penshotstart]
        cmp ax, [bannermsg]
        jng short .3
        mov [bannermsg], ax
        inc ax
        jz short .3
        cmp word [bannermsg], 0x6
        jz short .3
        mov word [bannertimer], 0x50
.3:
        cmp si, 0x7
        jl short .7
        cmp word [CrowdSound], 0x320
        jg short .4
        add word [CrowdSound], 0x190
        cmp word [CrowdSound], 0x320
        jng short .4
        mov word [CrowdSound], 0x320
.4:
        mov bx, [bp + 0x6]
        test byte [bx + 0x44], 0x40
        jz short .5
        add word [crowdheat], 0x14
        push 0x7d
        jmp short .6
        db 0x90
.5:
        push word 0xa0
.6:
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.7:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov dx, PenBuf
        db 0x8B, 0xF2                           ; insn: mov si, dx
.8:
        cmp byte [si], 0x0
        jz short .9
        inc di
        inc si
        inc si
        cmp si, PenBuf + 0x40
        jc short .8
        pop si
        pop di
        leave
        retf
.9:
        mov si, [bp + 0x8]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov [bx + PenBuf], al
        mov dx, [bp + 0x6]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov cl, [bx + 0x5e]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bx + PenBuf_pl], cl
        cmp byte [si + penmintab], 0x0
        jz short .11
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        test byte [bx + 0x45], 0x10
        jnz short .10
        or byte [bx + 0x45], 0x10
        pop si
        pop di
        leave
        retf
.10:
        db 0x2A, 0xC0                           ; insn: sub al, al
        shl di, 1
        mov [di + PenBuf_pl], al
        mov [di + PenBuf], al
.11:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetPA                                                      327B:0158  94 PC
; Starts the referee's penalty signal animation.
;
; Takes 1 word of stack arguments. Calls assreplace. Far routine (retf).
;-----------------------------------------------------------------------------
SetPA:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov cx, [bp + 0x6]
        cmp cx, 0x5
        jz short .3
        cmp cx, 0x16
        jz short .3
        mov [RefPen], cx
        mov word [RefStep], 0x0
        cmp cx, 0x7
        jnz short .1
        mov ax, 0x23
        jmp short .2
.1:
        mov ax, 0x20
.2:
        push ax
        push word refstruct
        call 0x1E7E:assreplace
.3:
        leave
        retf

;-----------------------------------------------------------------------------
; InProgress                                                 327B:018A  94 PC
; Referee penalty call in progress: messages, statistics and penalty information.
;
; Calls PaSpeechBusy, assreplace, PostPenaltyEvent, PanelAddPenalty, _sprintf, SetPA. Far routine
; (retf).
;-----------------------------------------------------------------------------
InProgress:
        enter 0x10, 0x0
        push di
        push si
        cmp word [RefStep], 0x0
        jnz short .1
        jmp near .35
.1:
        call 0x0EDC:PaSpeechBusy
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .35
.2:
        cmp byte [PenBuf], 0x0
        jnz short .3
        jmp near .14
.3:
        mov di, 0x1
        cmp byte [PenBuf_b2], 0x0
        jz short .5
        mov bx, PenBuf_b2
.4:
        inc di
        inc bx
        inc bx
        cmp byte [bx], 0x0
        jnz short .4
.5:
        dec di
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov [bp - 0xe], bx
        test byte [bx + PenBuf_pl], 0x80
        jnz short .6
        jmp near .12
.6:
        and byte [bx + PenBuf_pl], 0x7f
        mov al, [bx + PenBuf]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [si + penmintab]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .7
        jmp near .21
.7:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jl short .10
        mov bx, [bp - 0xe]
        mov al, [bx + PenBuf_pl]
        cbw
        mov [penaltysc], ax
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bx + PenBuf_pl], al
        mov [bx + PenBuf], al
        test byte [sflags], 0x80
        jnz short .8
        cmp word [SortPending], 0x0
        jz short .9
.8:
        cmp si, 0x7
        jnz short .2
.9:
        push si
        jmp near .34
        db 0x90
.10:
        mov [bp - 0x8], dx
        mov [bp - 0xc], si
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov [bp - 0xe], bx
        mov al, [bx + PenBuf_pl]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x7
        add si, SortCords
        mov ax, [si + 0x60]
        mov [bp - 0x4], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [si + 0x47]
        cbw
        mov cx, [bx + 0xd0]
        imul bx, ax, 0x28
        db 0x03, 0xD9                           ; insn: add bx, cx
        mov byte [bx], 0x8
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [bp - 0x4]
        cmp word [bx + 0x64], -0x3
        jng short .11
        push 0x1d
        push si
        call 0x1E7E:assreplace
        add sp, 0x4
.11:
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        add bx, [bp - 0x4]
        mov word [bx + 0x64], 0xfffb
        cmp di, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        push ax
        mov ax, [gameclock2]
        sub ax, [gameclock]
        mov cx, 0x3c
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push word [bp - 0x8]
        mov ax, [bp - 0xc]
        sub ax, strict word 0x9
        push ax
        mov al, [si + 0x47]
        cbw
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2352:PostPenaltyEvent
        add sp, 0xe
        mov bx, [bp - 0xe]
        mov al, [bx + PenBuf_pl]
        cbw
        mov [penaltysc], ax
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bx + PenBuf_pl], al
        mov [bx + PenBuf], al
        jmp near .33
        db 0x90
.12:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov [bp - 0xe], bx
        mov al, [bx + PenBuf_pl]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        cmp word [bx + sortobj0_position], 0x0
        jl short .13
        jmp near .35
.13:
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov bx, [bp - 0xe]
        mov [bx + PenBuf_pl], al
        mov [bx + PenBuf], al
        pop si
        pop di
        leave
        retf
.14:
        cmp word [ovlseq], 0x0
        jz short .15
        cmp word [ovlseq], 0x2
        jz short .15
        cmp word [ovltimer], 0x0
        jl short .15
        jmp near .35
.15:
        mov di, hmshots
        mov word [bp - 0x6], 0x2
.16:
        mov cx, 0x6
        mov dx, 0x1b
        lea bx, [di + 0x9a]
        mov [bp - 0x4], di
.17:
        cmp word [bx], 0x0
        jng short .18
        and byte [bx + 0x1], 0xdf
        test byte [bx + 0x1], 0x10
        jnz short .18
        cmp cx, 0x4
        jng short .18
        dec cx
.18:
        dec bx
        dec bx
        dec dx
        jns short .17
        mov [di + 0x22], cx
        mov di, awshots
        dec word [bp - 0x6]
        jnz short .16
        and byte [gmode], 0xfb
        mov word [bp - 0x6], puckstruct
        mov bx, [puck_1C]
        mov al, [bx + puckasslist]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        cmp ax, strict word 0x1b
        jnz short .19
        jmp near .35
.19:
        cmp dx, 0x1c
        jnz short .20
        jmp near .35
.20:
        push 0x1b
        push word puckstruct
        call 0x1E7E:assreplace
        add sp, 0x4
        pop si
        pop di
        leave
        retf
.21:
        mov [bp - 0x8], dx
        mov [bp - 0xc], si
        mov [bp - 0x2], di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov bx, [bp - 0x2]
        shl bx, 1
        mov [bp - 0xe], bx
        mov al, [bx + PenBuf_pl]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x7
        add si, SortCords
        mov ax, [si + 0x60]
        mov [bp - 0x4], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        inc word [bx + 0x6]
        mov bx, [bp - 0x4]
        add [bx + 0x8], di
        mov al, [si + 0x47]
        cbw
        mov [bp - 0xa], ax
        cmp ax, strict word 0x19
        jnl short .22
        shl ax, byte 0x4
        mov bx, [bp - 0x4]
        les bx, [bx + 0xc8]
        db 0x03, 0xD8                           ; insn: add bx, ax
        add [es:bx + 0x4], di
.22:
        push di
        mov al, [si + 0x52]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2083:PanelAddPenalty
        add sp, 0x6
        cmp word [bp - 0x2], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        push ax
        mov ax, [gameclock2]
        sub ax, [gameclock]
        mov cx, 0x3c
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push di
        mov ax, [bp - 0xc]
        sub ax, strict word 0x9
        push ax
        mov al, [si + 0x47]
        cbw
        push ax
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        push ax
        call 0x2352:PostPenaltyEvent
        add sp, 0xe
        mov ax, 0x3c
        imul di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp ax, 0x12c
        jnz short .23
        or di, 0x4000
.23:
        or di, 0x2000
        mov [bp - 0x8], di
        mov bx, [bp - 0xa]
        shl bx, 1
        add bx, [bp - 0x4]
        add bx, 0x64
        cmp word [bx], -0x3
        jz short .24
        mov [bp - 0x6], si
        cmp word [bx], -0x4
        jz short .24
        mov si, [bp - 0xa]
        mov di, [bp - 0x4]
        jmp short .29
.24:
        mov bx, [bp - 0x4]
        mov si, [bx + 0xd4]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        db 0x8B, 0xFB                           ; insn: mov di, bx
.25:
        cmp word [si + 0x1a], 0x0
        jng short .26
        mov al, [si + 0x47]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + di + 0x64], -0x1
        jnz short .26
        test byte [si + 0x45], 0x10
        jz short .27
.26:
        add si, 0x80
        inc dx
        cmp dx, 0x6
        jl short .25
.27:
        mov [bp - 0x6], si
        cmp dx, 0x6
        jnz short .28
        jmp near .35
.28:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov al, [bx + 0x47]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [bx + 0x5e]
        mov bx, [bp - 0xe]
        mov cl, [bx + PenBuf_pl]
        and cl, 0x80
        db 0x0A, 0xC1                           ; insn: or al, cl
        mov [bx + PenBuf_pl], al
        mov bx, [bp - 0x6]
        mov al, [bx + 0x52]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_ServedByD
        push word textline5
        call 0x0000:_sprintf
        add sp, 0x6
.29:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDF                           ; insn: add bx, di
        add bx, 0x64
        cmp word [bx], 0x0
        jl short .30
        test byte [bx + 0x1], 0x10
        jz short .30
        or byte [bp - 0x7], 0x10
.30:
        mov ax, [bp - 0x8]
        mov [bx], ax
        imul bx, si, 0x28
        add bx, [di + 0xd0]
        mov byte [bx], 0x5
        mov word [bp - 0x2], 0x0
        mov [bp - 0xa], si
        mov di, [bp - 0x2]
        mov si, [bp - 0x4]
.31:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        cmp byte [bx + 0x9c], 0x0
        jl short .32
        inc di
        cmp di, 0x1c
        jl short .31
.32:
        mov al, [bp - 0xa]
        db 0x03, 0xFE                           ; insn: add di, si
        mov [di + 0x9c], al
        mov byte [di + 0x9d], 0xff
        push 0xc
        push word [bp - 0x6]
        call 0x1E7E:assreplace
        add sp, 0x4
        mov bx, [bp - 0x6]
        mov ax, [bx + 0x5e]
        mov [penaltysc], ax
.33:
        push word [bp - 0xc]
.34:
        push cs
        call SetPA
        add sp, 0x2
.35:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; chkprogress                                                327B:0550  94 PC
; The penalty countdown; InProgress when it runs out.
;
; Calls UpdateTextOverlay, InProgress, assinsert. Far routine (retf).
;-----------------------------------------------------------------------------
chkprogress:
        push di
        push si
        test byte [gmode], 0x1
        jnz short .1
        jmp near .7
.1:
        call 0x226F:UpdateTextOverlay
        cmp word [PenCntDwn2], 0x0
        jl short .2
        dec word [PenCntDwn2]
        jns short .2
        or byte [gmode2], 0x4
.2:
        test byte [gmode], 0x4
        jnz short .3
        jmp near .7
.3:
        cmp word [PenCntDwn], 0x0
        jnl short .4
        push cs
        call InProgress
        pop si
        pop di
        retf
        db 0x90
.4:
        dec word [refsignal]
        jns short .5
        mov word [refsignal], 0x0
.5:
        dec word [PenCntDwn]
        jns short .7
        and byte [gmode], 0xf7
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [refsignal], di
        mov si, regd1_w2
.6:
        inc si
        inc si
        db 0x8B, 0xDF                           ; insn: mov bx, di
        inc di
        shl bx, 1
        cmp byte [bx + PenBuf], 0x0
        jz short .7
        mov al, [si]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx + penmintab], 0x0
        jz short .6
        or byte [gmode2], 0x4
        mov word [PenCntDwn2], 0xffff
        mov word [SortPending], 0x1
        mov bx, [puckc]
        mov byte [bx], 0xff
        push 0x1a
        push word puckstruct
        call 0x1E7E:assinsert
        add sp, 0x4
        mov word [pucktemp1], 0x1c20
        mov byte [refsignal_b1], 0xff
        mov word [refsignal], 0x0
        cmp word [bannertimer], 0x0
        jnz short .7
        mov word [bannermsg], 0xffff
.7:
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; Stop4Pen                                                   327B:060C  94 PC
; Stops play for a penalty and picks the faceoff spot.
;
; Takes 1 word of stack arguments. Calls PlaySoundEffect, SetPA. Far routine (retf).
;-----------------------------------------------------------------------------
Stop4Pen:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        shl si, 1
        mov al, [si + PenBuf]
        mov [bp - 0x1], al
        mov al, [si + PenBuf_pl]
        mov [bp - 0x2], al
        test byte [gmode], 0x1
        jz short .1
        jmp near .20
.1:
        or byte [gmode], 0x1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [foy], ax
        mov [fox], ax
        cmp byte [bp - 0x1], 0x7
        jz short .5
        mov ax, [ltx]
        mov [fox], ax
        mov ax, [lty]
        mov [foy], ax
        cmp byte [bp - 0x1], 0x3
        jz short .5
        cmp byte [bp - 0x1], 0x17
        jz short .5
        mov bx, [puckx]
        mov ax, [bx]
        mov [fox], ax
        mov bx, [pucky]
        mov ax, [bx]
        mov [foy], ax
        cmp byte [bp - 0x1], 0x8
        jnz short .3
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        cmp ax, strict word 0x4e
        jnl short .5
        cmp word [foy], 0x0
        jl short .2
        mov ax, 0x4e
        jmp short .4
        db 0x90
.2:
        mov ax, 0xffb2
        jmp short .4
        db 0x90
.3:
        cmp byte [bp - 0x1], 0x6
        jnz short .5
        mov al, [bp - 0x2]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        mov al, [bx + CwdExciteLvl]
        and al, 0x80
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x4b0
        add ax, 0xfda8
.4:
        mov [foy], ax
.5:
        cmp word [fox], 0x60
        jl short .6
        mov word [fox], 0x60
        jmp short .7
        db 0x90
.6:
        cmp word [fox], -0x60
        jg short .7
        mov word [fox], 0xffa0
.7:
        cmp word [foy], 0x90
        jl short .10
        cmp word [fox], 0x0
        jl short .8
        mov ax, 0x60
        jmp short .9
        db 0x90
.8:
        mov ax, 0xffa0
.9:
        mov [fox], ax
        mov word [foy], 0xb8
        jmp short .13
.10:
        cmp word [foy], 0xff70
        jg short .13
        cmp word [fox], 0x0
        jl short .11
        mov ax, 0x60
        jmp short .12
.11:
        mov ax, 0xffa0
.12:
        mov [fox], ax
        mov word [foy], 0xff48
.13:
        mov si, PenBuf_pl
        mov dx, [bp + 0x6]
.14:
        mov al, [si]
        and ax, strict word 0x7f
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        test byte [bx + CwdExciteLvl], 0x80
        jnz short .16
        cmp word [foy], -0x4e
        jg short .19
        mov word [foy], 0xffc3
        cmp word [fox], 0x0
        jl short .17
.15:
        mov ax, 0x64
        jmp short .18
.16:
        cmp word [foy], 0x4e
        jl short .19
        mov word [foy], 0x3d
        cmp word [fox], 0x0
        jnl short .15
.17:
        mov ax, 0xff9c
.18:
        mov [fox], ax
.19:
        inc si
        inc si
        cmp byte [si - 0x1], 0x0
        jnz short .14
.20:
        mov word [PenCntDwn], 0x0
        or byte [gmode], 0x4
        push word 0xa4
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
        push 0x5
        push cs
        call SetPA
        add sp, 0x2
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; checkfornewpen                                             327B:0784  94 PC
; Stops play for new penalties, or starts a delayed penalty while the other team has the puck.
;
; Calls SetPA, Stop4Pen. Far routine (retf).
;-----------------------------------------------------------------------------
checkfornewpen:
        enter 0x6, 0x0
        push di
        push si
        test byte [sflags], 0x80
        jz short .1
        jmp near .15
.1:
        cmp word [SortPending], 0x0
        jz short .2
        jmp near .15
.2:
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp byte [PenBuf], 0x0
        jnz short .3
        jmp near .15
.3:
        mov si, PenBuf_pl
.4:
        mov al, [si - 0x1]
        mov [bp - 0x1], al
        mov al, [si]
        mov [bp - 0x2], al
        test byte [gmode], 0x4
        jnz short .11
        mov al, [bp - 0x1]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [bx + penmintab], 0x0
        jz short .10
        mov bx, [puckc]
        mov al, [bx]
        mov [bp - 0x4], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jl short .9
        cmp byte [bp - 0x2], 0x6
        jnl short .5
        mov ax, 0x1
        jmp short .6
        db 0x90, 0x90
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.6:
        mov [bp - 0x6], ax
        cmp byte [bp - 0x4], 0x6
        jnl short .7
        mov ax, 0x1
        jmp short .8
.7:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.8:
        xor ax, [bp - 0x6]
        jnz short .9
        mov word [refsignal], 0x28
        cmp word [bannermsg], -0x1
        jz short .10
        mov word [bannertimer], 0x50
        jmp short .10
.9:
        test byte [gmode], 0x8
        jnz short .14
        or byte [gmode], 0x8
        push 0x16
        push cs
        call SetPA
        add sp, 0x2
        jmp short .14
        db 0x90
.10:
        push di
        push cs
        call Stop4Pen
        add sp, 0x2
.11:
        test byte [si], 0x80
        jnz short .14
        or byte [si], 0x80
        mov al, [bp - 0x1]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + pendelaytab]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, byte 0x5
        cmp dx, [PenCntDwn]
        jng short .12
        mov [PenCntDwn], dx
.12:
        cmp word [injurystop], 0x0
        jz short .13
        mov word [PenCntDwn], 0x140
.13:
        mov al, [bp - 0x1]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + penkindtab]
        cbw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, byte 0x5
        cmp dx, [PenCntDwn2]
        jng short .14
        mov [PenCntDwn2], dx
.14:
        inc di
        inc si
        inc si
        cmp byte [si - 0x1], 0x0
        jz short .15
        jmp near .4
.15:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; releasepl                                                  327B:088C  94 PC
; Puts a released player back on the ice for his team.
;
; Takes 2 words of stack arguments. Calls Setplass, setplayer. Far routine (retf).
;-----------------------------------------------------------------------------
releasepl:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [di + 0xd4]
        cmp word [si + 0x1a], 0x0
        jl short .2
.1:
        add si, 0x80
        cmp word [si + 0x1a], 0x0
        jnl short .1
.2:
        inc word [di + 0x22]
        or byte [hmtmflags], 0x1
        or byte [awtmflags], 0x1
        or byte [hmtmcoachflags], 0x40
        or byte [awtmcoachflags], 0x40
        mov bx, [di + 0x22]
        mov [bp - 0x2], si
        cmp word [di + 0x24], 0x0
        jl short .3
        mov bx, [di + 0x22]
        db 0x2B, 0xF6                           ; insn: sub si, si
        jmp short .4
        db 0x90
.3:
        mov si, 0x1
.4:
        mov al, [bx + si + priolist_m1]
        cbw
        mov bx, [bp - 0x2]
        mov [bx + 0x1a], ax
        push bx
        call 0x2E42:Setplass
        add sp, 0x2
        push word [bp + 0x8]
        push word [bp - 0x2]
        call 0x2E42:setplayer
        add sp, 0x4
        mov bx, [bp - 0x2]
        or byte [bx + 0x45], 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; chkatop                                                    327B:0904  94 PC
; Counts attack time for the team with the puck past the blue line.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
chkatop:
        enter 0x2, 0x0
        test byte [gmode], 0x10
        jnz short .6
        mov bx, [pucky]
        mov ax, [bx]
        mov [bp - 0x2], ax
        cmp ax, strict word 0x4e
        jng short .1
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        jmp short .2
        db 0x90
.1:
        cmp ax, strict word 0xffb2
        jnl short .6
        mov dx, 0x1
.2:
        test byte [gmode], 0x2
        jz short .3
        xor dx, 0x1
.3:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .4
        mov bx, awshots
        jmp short .5
        db 0x90
.4:
        mov bx, hmshots
.5:
        inc word [bx + 0xa]
.6:
        leave
        retf

;-----------------------------------------------------------------------------
; updatepentime_ut_chk                                       327B:0946  94 PC
; Checks one penalty time for updatepentime_ut.
;
; Takes 2 words of stack arguments. Calls releasepl, PlaySoundEffect. Far routine (retf).
;-----------------------------------------------------------------------------
updatepentime_ut_chk:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x8]
        mov si, [bp + 0x6]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, 1
        mov ax, [bx + si + 0x64]
        mov [bp - 0x2], ax
        and ah, 0x3f
        cmp ax, strict word 0x5
        jg short .2
        cmp word [bp - 0x2], 0x0
        jnz short .1
        push di
        push si
        push cs
        call releasepl
        add sp, 0x4
.1:
        push word 0x97
        call 0x0EDC:PlaySoundEffect
        add sp, 0x2
.2:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; updatepentime_ut                                           327B:0982  94 PC
; Counts down the penalty times and releases players whose time is up.
;
; Takes 1 word of stack arguments. Calls updatepentime_ut_chk. Far routine (retf).
;-----------------------------------------------------------------------------
updatepentime_ut:
        enter 0x8, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, 0x2
        cwd
        mov [regd1], ax
        mov [regd1_w2], dx
        mov [regd3], ax
        mov [regd3_w2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0x2], ax
.1:
        mov bx, [bp - 0x2]
        mov al, [bx + di + 0x9c]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jl short .6
        dec word [regd1]
        js short .2
        mov bx, [bp - 0x4]
        lea cx, [bp - 0x6]
        db 0x03, 0xD9                           ; insn: add bx, cx
        mov [bx], al
        inc word [bp - 0x4]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDF                           ; insn: add bx, di
        add bx, 0x64
        mov [bp - 0x8], bx
        dec word [bx]
        test word [bx], 0x3fff
        jnz short .2
        imul bx, si, 0x28
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov si, [di + 0xd0]
        mov byte [bx + si], 0x7
        mov bx, [bp - 0x8]
        and byte [bx + 0x1], 0xbf
        mov word [regd2], 0x1
        mov si, [bp + 0x6]
        mov di, [bp - 0x2]
        jmp short .4
        db 0x90
.2:
        mov di, [bp - 0x2]
        jmp short .5
        db 0x90
.3:
        inc word [regd2]
.4:
        mov bx, [regd2]
        db 0x03, 0xDE                           ; insn: add bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx + 0x9c]
        mov [bx + 0x9b], al
        mov bx, [regd2]
        db 0x03, 0xDE                           ; insn: add bx, si
        cmp byte [bx + di + 0x9b], 0x0
        jnl short .3
        dec di
.5:
        inc di
        mov [bp - 0x2], di
        cmp di, 0x1c
        jl short .7
.6:
        mov si, [bp + 0x6]
        cmp word [regd1], 0x1
        jnz short .8
        mov al, [bp - 0x6]
        jmp short .11
.7:
        mov di, [bp + 0x6]
        jmp near .1
.8:
        cmp word [regd1], 0x0
        jnz short .9
        mov al, [bp - 0x6]
        cbw
        push ax
        push si
        push cs
        call updatepentime_ut_chk
        add sp, 0x4
        jmp short .10
.9:
        cmp word [regd1], -0x1
        jnz short .12
.10:
        mov al, [bp - 0x5]
.11:
        cbw
        push ax
        push si
        push cs
        call updatepentime_ut_chk
        add sp, 0x4
.12:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; updatepentime                                              327B:0A70  94 PC
; Every 18h ticks chkatop and updatepentime_ut for both teams.
;
; Calls chkatop, updatepentime_ut. Far routine (retf).
;-----------------------------------------------------------------------------
updatepentime:
        and byte [sflags3], 0xbf
        test byte [gmode], 0x1
        jnz short .1
        dec word [Penaltytimer]
        jns short .1
        add word [Penaltytimer], 0x18
        or byte [sflags3], 0x40
        push cs
        call chkatop
        push word hmshots
        push cs
        call updatepentime_ut
        add sp, 0x2
        push word awshots
        push cs
        call updatepentime_ut
        add sp, 0x2
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PenaltyManager                                             327B:0AA6  94 PC
; Updatepentime, checkfornewpen, chkprogress.
;
; Calls updatepentime, checkfornewpen, chkprogress. Far routine (retf).
;-----------------------------------------------------------------------------
PenaltyManager:
        push cs
        call updatepentime
        push cs
        call checkfornewpen
        push cs
        call chkprogress
        retf
        db 0x90

;-----------------------------------------------------------------------------
; UpdatePowerPlayFlags                                       327B:0AB4  94 PC
; Sets the power play flags from the number of skaters each team has.
;
; Calls PlayArenaJingle. Far routine (retf).
;-----------------------------------------------------------------------------
UpdatePowerPlayFlags:
        mov bx, awshots
        mov ax, [hmtmap]
        sub ax, [awtmap]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        and byte [gmode2], 0xdf
        retf
.1:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .2
        mov bx, hmshots
        test byte [gmode2], 0x40
        jz short .3
        and byte [gmode2], 0x9f
        jmp short .3
        db 0x90
.2:
        test byte [gmode2], 0x40
        jnz short .3
        and byte [gmode2], 0xdf
        or byte [gmode2], 0x40
.3:
        test byte [gmode2], 0x20
        jnz short .7
        or byte [gmode2], 0x20
        inc word [bx + 0x4]
        test byte [gmode], 0x1
        jz short .7
        test byte [AnnouncerFlags], 0x1
        jz short .4
        cmp word [SoundOptions], 0x2
        jz short .7
.4:
        cmp bx, hmshots
        jnz short .5
        push 0x1
        jmp short .6
        db 0x90
.5:
        push 0x4
.6:
        call 0x0EDC:PlayArenaJingle
        add sp, 0x2
.7:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ClearPenaltyBuffer                                         327B:0B2C  94 PC
; Clears the 32 byte pairs of the penalty buffer.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
ClearPenaltyBuffer:
        push si
        mov si, PenBuf_pl
.1:
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [si], al
        mov [si - 0x1], al
        inc si
        inc si
        cmp si, PenBuf_pl + 0x40
        jc short .1
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PenGoalStuff                                               327B:0B42  94 PC
; After a goal drops the scored-on team's finished minor penalties.
;
; Takes 1 word of stack arguments. Calls releasepl, PanelRemovePenalty. Far routine (retf).
;-----------------------------------------------------------------------------
PenGoalStuff:
        enter 0x14, 0x0
        push di
        push si
        mov cx, [bp + 0x6]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .1
        mov ax, awshots
        jmp short .2
.1:
        mov ax, hmshots
.2:
        mov [bp - 0xc], ax
        cmp cx, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        mov [bp - 0xe], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jng short .3
        mov dx, awshots
        jmp short .4
        db 0x90
.3:
        mov dx, hmshots
.4:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0x4], di
        cmp byte [PenBuf], 0x0
        jnz short .5
        jmp near .14
.5:
        mov [bp - 0xa], dx
        mov word [bp - 0x6], PenBuf
        mov word [bp - 0x2], PenBuf_pl
        mov [bp - 0x8], di
        mov si, [bp - 0x2]
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov di, [bp - 0x6]
.6:
        cmp word [gsp], 0x3
        jnz short .7
        mov ax, [hmscore]
        cmp [awscore], ax
        jnz short .10
.7:
        mov al, [si - 0x1]
        mov [bp - 0x12], al
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + penmintab]
        mov [bp - 0x10], al
        inc al
        jz short .12
        cmp byte [bp - 0x10], 0x5
        jz short .12
        cmp byte [bp - 0x10], 0x2
        jnz short .10
        cmp byte [si], 0x6
        jnl short .8
        mov ax, 0x1
        jmp short .9
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.9:
        xor ax, [bp + 0x6]
        jnz short .12
.10:
        cmp byte [si], 0x0
        jl short .11
        cmp byte [si], 0xc
        jnl short .11
        mov al, [si]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x7
        and byte [bx + sortobj0_pflags2], 0xef
.11:
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [si], al
        mov [si - 0x1], al
        jmp short .13
        db 0x90
.12:
        cmp [bp - 0x4], dx
        jz short .13
        mov al, [bp - 0x12]
        mov [di], al
        mov al, [si]
        mov [di + 0x1], al
        inc di
        inc di
        inc word [bp - 0x4]
.13:
        inc dx
        inc si
        inc si
        cmp byte [si - 0x1], 0x0
        jnz short .6
        mov dx, [bp - 0xa]
.14:
        cmp byte [PenBuf], 0x0
        jnz short .15
        cmp word [bannermsg], 0x6
        jnz short .15
        mov word [bannermsg], 0xffff
.15:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov ax, [bx + 0x22]
        mov bx, [bp - 0xc]
        cmp [bx + 0x22], ax
        jg short .16
        jmp near .22
.16:
        db 0x2B, 0xFF                           ; insn: sub di, di
        mov [bp - 0xa], dx
.17:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov al, [bx + di + 0x9c]
        cbw
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnl short .18
        jmp near .22
.18:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        db 0x03, 0xDA                           ; insn: add bx, dx
        test byte [bx + 0x65], 0x40
        jz short .19
        inc di
        cmp di, 0x1c
        jl short .17
.19:
        mov [bp - 0x8], di
        mov di, [bp - 0xa]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, 1
        mov word [bx + di + 0x64], 0x0
        imul bx, si, 0x28
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        add bx, [di + 0xd0]
        mov byte [bx], 0x7
        push si
        push di
        mov [bp - 0x14], ax
        push cs
        call releasepl
        add sp, 0x4
        mov bx, [di + 0xd0]
        add bx, [bp - 0x14]
        mov al, [bx + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word [bp - 0xe]
        call 0x2083:PanelRemovePenalty
        add sp, 0x4
        mov si, 0x1
        mov di, [bp - 0x8]
        mov dx, [bp - 0xa]
        jmp short .21
        db 0x90
.20:
        inc si
.21:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x03, 0xDE                           ; insn: add bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx + 0x9c]
        mov [bx + 0x9b], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jnl short .20
        mov bx, [bp - 0xc]
        inc word [bx + 0x2]
        or byte [hmtmflags], 0x1
        or byte [awtmflags], 0x1
.22:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PenGoalStuffTail                                                327B:0CD8  94 PC
; A lone retf after PenGoalStuff; nothing calls it.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
PenGoalStuffTail:
        retf
        db 0x90
