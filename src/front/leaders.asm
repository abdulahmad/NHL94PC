; League leaders screen and its sort comparators (STATS.OVL)
; The first bytes finish the last routine of team_stats.asm.
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpGoals                                                   26BE:000A  94 PC
; Leaders comparator: goals (+2)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpGoals:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        cmp [es:di + 0x2], ax
        jz short .5
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp short .8
        db 0x90
.5:
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .6
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .8
        db 0x90
.6:
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        cmp [es:di + 0x6], ax
        jz short .7
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .8
        db 0x90
.7:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
.8:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpAssists                                                 26BE:00EC  94 PC
; Leaders comparator: assists (+4)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpAssists:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x4]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x4], ax
        jz short .5
        mov ax, [es:bx + 0x4]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x4]
        jmp short .8
.5:
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .6
        mov ax, [es:bx]
        mov es, [bp - 0x6]
        sub ax, [es:di]
        jmp short .8
        db 0x90
.6:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x6]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x6], ax
        jz short .7
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .8
        db 0x90
.7:
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
.8:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpPPGoals                                                 26BE:01C6  94 PC
; Leaders comparator: power play goals (+8)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpPPGoals:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x8]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x8], ax
        jz short .5
        mov ax, [es:bx + 0x8]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x8]
        jmp short .9
.5:
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .6
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .9
.6:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x6]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x6], ax
        jz short .7
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .9
        db 0x90
.7:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x2]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x2], ax
        jz short .8
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp short .9
        db 0x90
.8:
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
.9:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpSHGoals                                                 26BE:02C0  94 PC
; Leaders comparator: short-handed goals (+0Ah)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpSHGoals:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0xa]
        mov es, [bp - 0x2]
        cmp [es:bx + 0xa], ax
        jz short .5
        mov ax, [es:bx + 0xa]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0xa]
        jmp short .9
.5:
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .6
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .9
.6:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x6]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x6], ax
        jz short .7
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .9
        db 0x90
.7:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x2]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x2], ax
        jz short .8
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp short .9
        db 0x90
.8:
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
.9:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpPlusMinus                                               26BE:03BA  94 PC
; Leaders comparator: plus/minus (+10h)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpPlusMinus:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        cmp [es:di + 0x10], ax
        jz short .5
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
        jmp short .8
        db 0x90
.5:
        mov es, [bp - 0x2]
        mov ax, [es:bx]
        mov es, [bp - 0x6]
        cmp [es:di], ax
        jz short .6
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .8
        db 0x90
.6:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        cmp [es:di + 0x6], ax
        jz short .7
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .8
.7:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
.8:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpPIM                                                     26BE:049E  94 PC
; Leaders comparator: penalty minutes (+0Ch)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpPIM:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0xc]
        mov es, [bp - 0x2]
        cmp [es:bx + 0xc], ax
        jz short .5
        mov ax, [es:bx + 0xc]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0xc]
        jmp short .9
.5:
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .6
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .9
.6:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x6]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x6], ax
        jz short .7
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp short .9
        db 0x90
.7:
        mov es, [bp - 0x6]
        mov ax, [es:di + 0x2]
        mov es, [bp - 0x2]
        cmp [es:bx + 0x2], ax
        jz short .8
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp short .9
        db 0x90
.8:
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
.9:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpShootPct                                                26BE:0598  94 PC
; Leaders comparator: precomputed shooting percentage.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpShootPct:
        enter 0xe, 0x0
        push di
        push si
        mov bx, [bp + 0x6]
        mov si, [bp + 0x8]
        mov si, [si]
        mov [bp - 0xc], si
        shl si, 1
        add si, [g_CFC8]
        mov es, [g_CFCA]
        mov ax, [es:si]
        mov si, [bx]
        shl si, 1
        add si, [g_CFC8]
        mov cx, [es:si]
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jz short .1
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        pop si
        pop di
        leave
        retf
        db 0x90
.1:
        cmp word [g_200E], 0x0
        jnz short .2
        imul ax, [bx], 0x30
        add ax, [g_C044]
        mov dx, [statsskaterbuf]
        jmp short .3
.2:
        imul ax, [bx], 0x30
        add ax, [g_C044]
        mov dx, [statsskaterbuf]
        add ax, strict word 0x12
.3:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [g_200E], 0x0
        jnz short .4
        imul ax, [bp - 0xc], 0x30
        add ax, [g_C044]
        jmp short .5
.4:
        imul ax, [bp - 0xc], 0x30
        add ax, [g_C044]
        mov dx, [statsskaterbuf]
        add ax, strict word 0x12
.5:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, dx
        cmp [es:bx], ax
        jz short .6
        mov ax, [es:bx]
        mov es, [bp - 0x6]
        sub ax, [es:di]
        pop si
        pop di
        leave
        retf
        db 0x90
.6:
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        cmp [es:di + 0x6], ax
        jz short .7
        mov es, dx
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        pop si
        pop di
        leave
        retf
.7:
        mov ax, [es:di + 0x2]
        mov es, dx
        cmp [es:bx + 0x2], ax
        jz short .8
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90
.8:
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x10]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpGoalieWins                                              26BE:067A  94 PC
; Leaders comparator: goalie wins (+2)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpGoalieWins:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        cmp [es:di + 0x2], ax
        jz short .5
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp near .11
.5:
        cmp word [ss:g_200E], 0x0
        jnz short .6
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        cmp [es:di + 0x6], ax
        jz short .6
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x6]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x6]
        jmp near .11
        db 0x90
.6:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x4]
        mov es, [bp - 0x6]
        cmp [es:di + 0x4], ax
        jz short .7
        mov ax, [es:di + 0x4]
        mov es, [bp - 0x2]
        sub ax, [es:bx + 0x4]
        jmp short .11
        db 0x90
.7:
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .8
        mov es, [bp - 0x6]
        mov ax, [es:di]
        mov es, [bp - 0x2]
        sub ax, [es:bx]
        jmp short .11
        db 0x90
.8:
        mov ax, [es:bx + 0xc]
        mov es, [bp - 0x6]
        cmp [es:di + 0xc], ax
        jz short .9
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0xc]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0xc]
        jmp short .11
        db 0x90
.9:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x10]
        mov es, [bp - 0x6]
        cmp [es:di + 0x10], ax
        jz short .10
        mov ax, [es:di + 0x10]
        mov es, [bp - 0x2]
        sub ax, [es:bx + 0x10]
        jmp short .11
        db 0x90
.10:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x14]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x14]
.11:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CmpSavePct                                                 26BE:07C2  94 PC
; Leaders comparator: save percentage (+14h)
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpSavePct:
        enter 0x8, 0x0
        push di
        push si
        cmp word [ss:g_200E], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        jmp short .2
        db 0x90
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        cmp word [ss:g_200E], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
        mov [bp - 0x2], ds
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [bp - 0x2], dx
.4:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x14]
        mov es, [bp - 0x6]
        cmp [es:di + 0x14], ax
        jz short .5
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x14]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x14]
        jmp short .10
        db 0x90
.5:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0xc]
        mov es, [bp - 0x6]
        cmp [es:di + 0xc], ax
        jz short .6
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0xc]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0xc]
        jmp short .10
.6:
        mov ax, [es:di]
        mov es, [bp - 0x2]
        cmp [es:bx], ax
        jz short .7
        mov ax, [es:bx]
        mov es, [bp - 0x6]
        sub ax, [es:di]
        jmp short .10
.7:
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        cmp [es:di + 0x2], ax
        jz short .8
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x2]
        mov es, [bp - 0x6]
        sub ax, [es:di + 0x2]
        jmp short .10
        db 0x90
.8:
        mov es, [bp - 0x2]
        mov ax, [es:bx + 0x4]
        mov es, [bp - 0x6]
        cmp [es:di + 0x4], ax
        jz short .9
        mov ax, [es:di + 0x4]
        mov es, [bp - 0x2]
        sub ax, [es:bx + 0x4]
        jmp short .10
        db 0x90
.9:
        mov ax, [es:di + 0x10]
        mov es, [bp - 0x2]
        sub ax, [es:bx + 0x10]
.10:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LeadersScreen                                              26BE:08DA  94 PC
; Skater and goalie leaders table.
;
; Takes 1 word of stack arguments. Calls AllocRecData, BuildPathFar, _open, __aFlmul, _lseek, _read,
; _close, __aFldiv and others. Far routine (retf).
;-----------------------------------------------------------------------------
LeadersScreen:
        enter 0x21c, 0x0
        push di
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x1e4], ax
        push ax
        push ax
        push word 0x444
        push strict word str_Keys
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C048], ax
        mov [statsplayerbuf], dx
        cmp word [bp + 0x6], 0x8
        jnl short .1
        push 0x0
        push 0x0
        push word 0x3f0
        push strict word str_Pstat
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C044], ax
        mov [statsskaterbuf], dx
        jmp short .2
.1:
        push 0x0
        push 0x0
        push word 0x46e
        push strict word str_Gstat
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_C040], ax
        mov [statsgoaliebuf], dx
.2:
        cmp word [bp + 0x6], 0x7
        jnz short .3
        push 0x0
        push 0x0
        push 0x2a
        push strict word str_Addsort
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [g_CFC8], ax
        mov [g_CFCA], dx
.3:
        cmp word [bp + 0x6], 0x8
        jz short .4
        cmp word [bp + 0x6], 0xa
        jz short .4
        cmp word [bp + 0x6], 0x5
        jz short .4
        cmp word [bp + 0x6], 0x7
        jz short .4
        jmp near .10
.4:
        push 0x0
        push 0x0
        mov bx, [g_2010]
        shl bx, 1
        push ds
        push word [bx + g_1FAA]
        push word 0x3861
        push strict word 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0xc6]
        push ax
        call 0x0000:_open
        add sp, 0x4
        mov [bp - 0x174], ax
        cmp word [g_2010], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0xfd64
        add ax, 0x2e8
        mov [bp - 0x6a], ax
        mov word [bp - 0x68], 0x0
        mov word [bp - 0x17c], 0x0
        jmp short .8
.5:
        mov al, [bp - 0x2c]
.6:
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov si, [bp - 0x17c]
        shl si, 1
        mov [bp + si - 0xf6], ax
        cmp word [g_2010], 0x0
        jnz short .7
        cmp word [g_200E], 0x0
        jnz short .7
        mov si, [bp - 0x17c]
        shl si, 1
        cmp word [bp + si - 0xf6], 0x0
        jnz short .7
        mov word [bp + si - 0xf6], 0x0
.7:
        inc word [bp - 0x17c]
.8:
        cmp word [bp - 0x17c], 0x18
        jnl short .9
        push 0x0
        push word [bp - 0x68]
        push word [bp - 0x6a]
        mov ax, [bp - 0x17c]
        cwd
        push dx
        push ax
        call 0x0000:__aFlmul
        push dx
        push ax
        push word [bp - 0x174]
        call 0x0000:_lseek
        add sp, 0x8
        push 0x4c
        lea ax, [bp - 0x66]
        push ax
        push word [bp - 0x174]
        call 0x0000:_read
        add sp, 0x6
        cmp word [g_200E], 0x0
        jnz short .5
        mov al, [bp - 0x3e]
        jmp short .6
        db 0x90
.9:
        push word [bp - 0x174]
        call 0x0000:_close
        add sp, 0x2
.10:
        push 0x0
        push 0x0
        push ds
        push strict word str_KeyDb
        push word 0x3861
        push strict word 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0xc6]
        push ax
        call 0x0000:_open
        add sp, 0x4
        mov [bp - 0x17e], ax
        push 0x0
        push 0x0
        mov bx, [g_2010]
        shl bx, 1
        push ds
        push word [bx + g_1FA6]
        push word 0x3861
        push strict word 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0xc6]
        push ax
        call 0x0000:_open
        add sp, 0x4
        mov [bp - 0x2], ax
        jmp near .48
        db 0x90
.11:
        cmp byte [bp - 0x1b2], 0x18
        jc short .12
        jmp near .48
.12:
        cmp byte [bp - 0x1b0], 0x47
        jz short .13
        jmp near .29
.13:
        cmp word [bp + 0x6], 0x8
        jnl short .14
        jmp near .48
.14:
        push 0x0
        cmp word [g_2010], 0x0
        jnz short .15
        mov ax, [bp - 0x18a]
        mov dx, [bp - 0x188]
        jmp short .16
.15:
        mov ax, [bp - 0x186]
        mov dx, [bp - 0x184]
.16:
        push dx
        push ax
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        push 0x36
        lea ax, [bp - 0xa6]
        push ax
        push word [bp - 0x2]
        call 0x0000:_read
        add sp, 0x6
        cmp word [g_200E], 0x0
        jnz short .17
        mov ax, [bp - 0xa6]
        jmp short .18
.17:
        mov ax, [bp - 0x90]
.18:
        mov [bp - 0x216], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .19
        jmp near .48
.19:
        cmp word [bp + 0x6], 0x8
        jz short .20
        cmp word [bp + 0x6], 0xa
        jnz short .22
.20:
        mov al, [bp - 0x1b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        cmp word [bp + si - 0xf6], 0x0
        jnz short .21
        jmp near .48
.21:
        imul ax, [bp - 0x216], 0x64
        cwd
        idiv word [bp + si - 0xf6]
        cmp ax, strict word 0x1e
        jnl short .25
        jmp near .48
        db 0x90
.22:
        cmp word [bp + 0x6], 0x9
        jnz short .25
        cmp word [g_200E], 0x0
        jnz short .23
        mov ax, [bp - 0xa4]
        jmp short .24
        db 0x90
.23:
        mov ax, [bp - 0x8e]
.24:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .25
        jmp near .48
.25:
        imul bx, [bp - 0x1e4], 0x36
        les si, [g_C040]
        lea di, [bx + si]
        lea si, [bp - 0xa6]
        mov cx, 0x1b
        rep movsw
        cmp word [bp - 0x1e4], 0x14
        jl short .26
        mov si, [bp - 0x1e4]
        shl si, 1
        lea ax, [bp + si - 0x1e4]
        push ax
        lea ax, [bp - 0x1e4]
        push ax
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        call far [bx + g_26B2]
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .26
        jmp near .48
.26:
        cmp word [bp - 0x1e4], 0x14
        jnl short .28
.27:
        imul bx, [bp - 0x1e4], 0x34
        les si, [g_C048]
        lea di, [bx + si]
        lea si, [bp - 0x1b2]
        mov cx, 0x1a
        rep movsw
        mov ax, [bp - 0x1e4]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        mov [bp + si - 0x1e2], ax
        inc word [bp - 0x1e4]
        jmp near .47
.28:
        mov si, [bp - 0x1e4]
        shl si, 1
        mov ax, [bp + si - 0x1e4]
        mov [bp - 0x1b6], ax
        imul bx, ax, 0x34
        les si, [g_C048]
        lea di, [bx + si]
        lea si, [bp - 0x1b2]
        mov cx, 0x1a
        rep movsw
        imul bx, [bp - 0x1b6], 0x36
        les si, [g_C040]
        lea di, [bx + si]
        lea si, [bp - 0xa6]
        mov cx, 0x1b
        rep movsw
        jmp near .47
        db 0x90
.29:
        cmp word [bp + 0x6], 0x8
        jl short .30
        jmp near .48
.30:
        push 0x0
        cmp word [g_2010], 0x0
        jnz short .31
        mov ax, [bp - 0x18a]
        mov dx, [bp - 0x188]
        jmp short .32
.31:
        mov ax, [bp - 0x186]
        mov dx, [bp - 0x184]
.32:
        push dx
        push ax
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        push 0x30
        lea ax, [bp - 0x214]
        push ax
        push word [bp - 0x2]
        call 0x0000:_read
        add sp, 0x6
        cmp word [g_200E], 0x0
        jnz short .33
        mov ax, [bp - 0x214]
        jmp short .34
.33:
        mov ax, [bp - 0x202]
.34:
        mov [bp - 0x216], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .35
        jmp near .48
.35:
        cmp word [bp + 0x6], 0x5
        jz short .36
        cmp word [bp + 0x6], 0x7
        jnz short .38
.36:
        mov al, [bp - 0x1b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, 1
        cmp word [bp + si - 0xf6], 0x0
        jnz short .37
        jmp near .48
.37:
        imul ax, [bp - 0x216], 0x64
        cwd
        idiv word [bp + si - 0xf6]
        cmp ax, strict word 0x50
        jnl short .38
        jmp near .48
.38:
        imul bx, [bp - 0x1e4], 0x30
        les si, [g_C044]
        lea di, [bx + si]
        lea si, [bp - 0x214]
        mov cx, 0x18
        rep movsw
        cmp word [bp + 0x6], 0x7
        jnz short .44
        cmp word [g_200E], 0x0
        jnz short .39
        mov ax, [bp - 0x206]
        jmp short .40
.39:
        mov ax, [bp - 0x1f4]
.40:
        mov [bp - 0x1b6], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .43
        cwd
        push dx
        push ax
        cmp word [g_200E], 0x0
        jnz short .41
        mov ax, [bp - 0x212]
        jmp short .42
.41:
        mov ax, [bp - 0x200]
.42:
        mov [bp - 0x17c], ax
        mov cx, 0x3e8
        imul cx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x1b6]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        cwd
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        push bx
        push cx
        call 0x0000:__aFldiv
        mov bx, [bp - 0x1e4]
        shl bx, 1
        les si, [g_CFC8]
        mov [es:bx + si], ax
        jmp short .44
        db 0x90
.43:
        mov bx, [bp - 0x1e4]
        shl bx, 1
        les si, [g_CFC8]
        mov word [es:bx + si], 0x0
.44:
        cmp word [bp - 0x1e4], 0x14
        jl short .45
        mov si, [bp - 0x1e4]
        shl si, 1
        lea ax, [bp + si - 0x1e4]
        push ax
        lea ax, [bp - 0x1e4]
        push ax
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        call far [bx + g_26B2]
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .48
.45:
        cmp word [bp - 0x1e4], 0x14
        jnl short .46
        jmp near .27
.46:
        mov si, [bp - 0x1e4]
        shl si, 1
        mov ax, [bp + si - 0x1e4]
        mov [bp - 0x1b6], ax
        imul bx, ax, 0x34
        les si, [g_C048]
        lea di, [bx + si]
        lea si, [bp - 0x1b2]
        mov cx, 0x1a
        rep movsw
        imul bx, [bp - 0x1b6], 0x30
        les si, [g_C044]
        lea di, [bx + si]
        lea si, [bp - 0x214]
        mov cx, 0x18
        rep movsw
        cmp word [bp + 0x6], 0x7
        jnz short .47
        mov bx, [bp - 0x1e4]
        shl bx, 1
        les si, [g_CFC8]
        mov ax, [es:bx + si]
        mov bx, [bp - 0x1b6]
        shl bx, 1
        mov [es:bx + si], ax
.47:
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        push word [bx + g_26B4]
        push word [bx + g_26B2]
        push 0x2
        push word [bp - 0x1e4]
        lea ax, [bp - 0x1e2]
        push ax
        call 0x0000:_qsort
        add sp, 0xa
.48:
        push 0x34
        lea ax, [bp - 0x1b2]
        push ax
        push word [bp - 0x17e]
        call 0x0000:_read
        add sp, 0x6
        cmp ax, strict word 0x34
        jnz short .49
        jmp near .11
.49:
        push word [bp - 0x2]
        call 0x0000:_close
        add sp, 0x2
        push word [bp - 0x17e]
        call 0x0000:_close
        add sp, 0x2
        push 0x0
        push strict word str_EasnFnt
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x178], ax
        mov [bp - 0x176], dx
        mov word [bp - 0x6c], 0x7
        lea ax, [bp - 0x1a]
        push ax
        call 0x03A3:SaveCharTab
        add sp, 0x2
        push word [bp - 0x176]
        push word [bp - 0x178]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        call 0x0FEF:UseOffscreenCanvas
        push word 0x3701
        push strict word str_Qpp
        mov bx, [g_200E]
        shl bx, 1
        push ds
        push word [bx + g_1FA2]
        push 0x0
        push 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0x0
        lea ax, [bp - 0xc6]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [fileoncd], ax
        mov [cddriveptr], dx
        push strict word str_Bkgd
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [statsbgshapes], ax
        mov [g_C2B4], dx
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        mov bx, 0xa
        call 0x0FEF:SetClipRectRegs
        push word [g_C2B4]
        push word [statsbgshapes]
        call 0x0FEF:DrawRleTransBody
        add sp, 0x4
        push word 0xc8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x140
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x0FEF:SetClipRectRegs
        push word [cddriveptr]
        push word [fileoncd]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x43
        push 0x40
        call 0x0D39:SetTextColors
        add sp, 0x4
        mov bx, [bp + 0x6]
        shl bx, 1
        push ds
        push word [bx + g_28DE]
        lea ax, [bp - 0x172]
        push ss
        push ax
        call 0x2095:GetSeasonTitle
        add sp, 0x8
        lea ax, [bp - 0x172]
        push ss
        push ax
        push 0xc
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
        push ds
        push strict word str_Pos
        mov ax, 0x14
        mov [bp - 0x17a], ax
        push ax
        push 0x5
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_No
        push 0x14
        push 0x19
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Player_2
        push 0x14
        push 0x28
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Team
        push 0x14
        push 0x7d
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push strict word str_Gp
        push 0x14
        push word 0xb9
        call 0x0D39:DrawShadowText
        add sp, 0x8
        mov bx, [bp + 0x6]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, byte 0x2
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push ds
        push word [bx + g_28F4]
        push 0x14
        push word 0xcd
        db 0x8B, 0xF3                           ; insn: mov si, bx
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push word [si + g_28F6]
        push 0x14
        push word 0xe6
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push ds
        push word [si + g_28F8]
        push 0x14
        push word 0xfa
        call 0x0D39:DrawShadowText
        add sp, 0x8
        cmp word [bp + 0x6], 0x9
        jnz short .50
        cmp word [g_200E], 0x1
        jz short .51
.50:
        mov bx, [bp + 0x6]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, byte 0x2
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push ds
        push word [bx + g_28FA]
        push word [bp - 0x17a]
        push word 0x10e
        call 0x0D39:DrawShadowText
        add sp, 0x8
.51:
        mov bx, [bp + 0x6]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, byte 0x2
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, 1
        push ds
        push word [bx + g_28FC]
        push word [bp - 0x17a]
        push word 0x127
        call 0x0D39:DrawShadowText
        add sp, 0x8
        add word [bp - 0x17a], 0xa
        cmp word [bp - 0x1e4], 0x0
        jnz short .55
        push ds
        push strict word str_StatsUnavailable
        push word [bp - 0x17a]
        call 0x0D39:DrawShadowTextCentered
        add sp, 0x6
.52:
        lea ax, [bp - 0x1a]
        push ax
        call 0x03A3:LoadCharTab
        add sp, 0x2
        push word [bp - 0x176]
        push word [bp - 0x178]
        call 0x06E1:FindUnlink
        add sp, 0x4
        cmp word [bp + 0x6], 0x7
        jnz short .53
        push word [g_CFCA]
        push word [g_CFC8]
        call 0x06E1:FindUnlink
        add sp, 0x4
.53:
        cmp word [bp + 0x6], 0x8
        jl short .54
        jmp near LeadersScreenJumpTable.7
.54:
        push word [statsskaterbuf]
        push word [g_C044]
        jmp near LeadersScreenJumpTable.8
        db 0x90
.55:
        mov word [bp - 0x17c], 0x0
        jmp near LeadersScreenJumpTable.2
        db 0x90
.56:
        imul bx, [bp - 0x1b6], 0x30
        add bx, [g_C044]
        mov es, [statsskaterbuf]
        add bx, 0x12
.57:
        mov [bp - 0x70], bx
        mov [bp - 0x6e], es
        push word [es:bx]
        push strict word str_2d
        push word [bp - 0x17a]
        push word 0xb9
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x70]
        push word [es:bx + 0x2]
        push strict word str_3d
        push word [bp - 0x17a]
        push word 0xcd
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x70]
        push word [es:bx + 0x4]
        push strict word str_3d
        push word [bp - 0x17a]
        push word 0xe6
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x70]
        push word [es:bx + 0x6]
        push strict word str_3d
        push word [bp - 0x17a]
        push word 0xfa
        jmp short .61
.58:
        cmp word [g_200E], 0x0
        jnz short .59
        imul bx, [bp - 0x1b6], 0x36
        add bx, [g_C040]
        mov es, [statsgoaliebuf]
        jmp short .60
.59:
        imul bx, [bp - 0x1b6], 0x36
        add bx, [g_C040]
        mov es, [statsgoaliebuf]
        add bx, 0x16
.60:
        mov [bp - 0x1ba], bx
        mov [bp - 0x1b8], es
        push word [es:bx]
        push strict word str_2d
        push word [bp - 0x17a]
        push word 0xb9
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x1ba]
        push word [es:bx + 0xc]
        push strict word str_4d
        push word [bp - 0x17a]
        push word 0xcd
.61:
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov ax, [bp + 0x6]
        jmp near .76
        db 0x90
.62:
        les bx, [bp - 0x70]
        push word [es:bx + 0x8]
        jmp near .72
.63:
        les bx, [bp - 0x70]
        push word [es:bx + 0xa]
.64:
        push strict word str_3d
        jmp near .73
        db 0x90
.65:
        les bx, [bp - 0x70]
        push word [es:bx + 0xc]
        jmp short .64
        db 0x90
.66:
        les bx, [bp - 0x70]
        push word [es:bx + 0x10]
        push strict word str_4d
        jmp near .73
        db 0x90
.67:
        les bx, [bp - 0x70]
        push word [es:bx + 0xe]
        push strict word str_5d
        push word [bp - 0x17a]
        push word 0x10e
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        mov bx, [bp - 0x1b6]
        shl bx, 1
        les si, [g_CFC8]
        mov ax, [es:bx + si]
        mov cx, 0xa
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cwd
        idiv cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cwd
        idiv cx
        push ax
        push strict word str_3d1d
        push word [bp - 0x17a]
        push word 0x127
.68:
        call 0x0D39:DrawShadowTextF2
        add sp, 0xa
        jmp near LeadersScreenJumpTable.1
.69:
        les bx, [bp - 0x1ba]
        push word [es:bx + 0xe]
        push strict word str_3d
        push word [bp - 0x17a]
        push word 0xe6
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x1ba]
        mov ax, [es:bx + 0x10]
        mov cx, 0x64
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push ax
        push strict word str_2d22d
        push word [bp - 0x17a]
        push word 0xfa
        jmp short .68
        db 0x90
.70:
        les bx, [bp - 0x1ba]
        push word [es:bx + 0x2]
        push strict word str_2d
        push word [bp - 0x17a]
        push word 0xe6
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x1ba]
        push word [es:bx + 0x4]
        push strict word str_2d
        push word [bp - 0x17a]
        push word 0xfa
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        cmp word [g_200E], 0x0
        jz short .71
        jmp near LeadersScreenJumpTable.1
.71:
        les bx, [bp - 0x1ba]
        push word [es:bx + 0x6]
.72:
        push strict word str_2d
.73:
        push word [bp - 0x17a]
        push word 0x10e
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        jmp near LeadersScreenJumpTable.1
        db 0x90
.74:
        les bx, [bp - 0x1ba]
        push word [es:bx + 0xe]
        push strict word str_3d
        push word [bp - 0x17a]
        push word 0xe6
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x1ba]
        push word [es:bx + 0x12]
        push strict word str_4d
        push word [bp - 0x17a]
        push word 0xfa
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
        les bx, [bp - 0x1ba]
        cmp word [es:bx + 0x14], 0x3e8
        jnc short .75
        mov ax, [es:bx + 0x14]
        mov cx, 0x3e8
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        push strict word str_03d
        jmp short .73
        db 0x90
.75:
        mov ax, [es:bx + 0x14]
        mov cx, 0x3e8
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div cx
        push ax
        push strict word str_1d03d
        push word [bp - 0x17a]
        push word 0x10e
        jmp near .68
.76:
        cmp ax, strict word 0xa
        ja short LeadersScreenJumpTable.1
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + 0x12ca]
        db 0x90
LeadersScreenJumpTable:                         ; jump table of LeadersScreen: 11 case targets
        dw .1
        dw .1
        dw .1
        dw LeadersScreen.62
        dw LeadersScreen.63
        dw LeadersScreen.66
        dw LeadersScreen.65
        dw LeadersScreen.67
        dw LeadersScreen.69
        dw LeadersScreen.70
        dw LeadersScreen.74
.1:
        mov ax, [bp - 0x6c]
        add [bp - 0x17a], ax
        inc word [bp - 0x17c]
.2:
        mov ax, [bp - 0x1e4]
        cmp [bp - 0x17c], ax
        jl short .3
        jmp near LeadersScreen.52
.3:
        mov si, [bp - 0x17c]
        shl si, 1
        mov ax, [bp + si - 0x1e2]
        mov [bp - 0x1b6], ax
        imul ax, ax, 0x34
        add ax, [g_C048]
        mov dx, [statsplayerbuf]
        push ds
        lea di, [bp - 0x1b2]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push ss
        pop es
        mov ds, dx
        mov cx, 0x1a
        rep movsw
        pop ds
        mov al, [bp - 0x1b0]
        cbw
        push ax
        push word 0x28da
        push word 0xcfd4
        call 0x0000:_sprintf
        add sp, 0x6
        push ds
        push strict word g_CFD4
        push word [bp - 0x17a]
        push 0x5
        call 0x0D39:DrawShadowText
        add sp, 0x8
        cmp byte [bp - 0x1b1], 0x64
        jnc short .4
        mov al, [bp - 0x1b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push strict word str_2d
        push word [bp - 0x17a]
        push 0x19
        call 0x0D39:DrawShadowTextF
        add sp, 0x8
.4:
        push 0x50
        lea ax, [bp - 0x19f]
        push ss
        push ax
        lea ax, [bp - 0x1af]
        push ss
        push ax
        push ds
        push strict word g_CFD4
        call 0x0F89:FitNameToWidth
        add sp, 0xe
        push ds
        push strict word g_CFD4
        push word [bp - 0x17a]
        push 0x28
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push 0x0
        push 0x0
        push ds
        push word [g_1FAA]
        push word 0x3861
        push strict word 0x0
        lea ax, [bp - 0xc6]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push word 0x8000
        lea ax, [bp - 0xc6]
        push ax
        call 0x0000:_open
        add sp, 0x4
        mov [bp - 0x174], ax
        push 0x0
        mov al, [bp - 0x1b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cx, 0x4c
        mul cx
        push dx
        push ax
        push word [bp - 0x174]
        call 0x0000:_lseek
        add sp, 0x8
        push 0x27
        lea ax, [bp - 0x66]
        push ax
        push word [bp - 0x174]
        call 0x0000:_read
        add sp, 0x6
        push word [bp - 0x174]
        call 0x0000:_close
        add sp, 0x2
        lea ax, [bp - 0x4c]
        push ss
        push ax
        push word [bp - 0x17a]
        push 0x7d
        call 0x0D39:DrawShadowText
        add sp, 0x8
        cmp word [bp + 0x6], 0x8
        jl short .5
        jmp near LeadersScreen.58
.5:
        cmp word [g_200E], 0x0
        jz short .6
        jmp near LeadersScreen.56
.6:
        imul bx, [bp - 0x1b6], 0x30
        add bx, [g_C044]
        mov es, [statsskaterbuf]
        jmp near LeadersScreen.57
        db 0x90
.7:
        push word [statsgoaliebuf]
        push word [g_C040]
.8:
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [statsplayerbuf]
        push word [g_C048]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
        pop di
        leave
        retf
