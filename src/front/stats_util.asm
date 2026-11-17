; Stats screen helpers: text formatting, player photos and the season title (STATS.OVL)
; The first bytes finish the last routine of stats_menu_loops.asm.
        mov [bp - 0x34], ax
        jmp near RosterMenuLoop.16 - 0x1E70

;-----------------------------------------------------------------------------
; InitMenuRemap                                              2095:0008  94 PC
; Builds the menu colour remap table.
;
; Takes 1 word of stack arguments. Calls SetRemapTable. Far routine (retf).
;-----------------------------------------------------------------------------
InitMenuRemap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        cmp word [bp + 0x6], 0x0
        jnz short .5
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov ax, 0x3a0b
        mov ds, ax
.1:
        mov byte [bx + MenuRemap], 0x0
        inc bx
        cmp bx, 0x15
        jl short .1
        mov bx, 0x15
.2:
        lea ax, [bx - 0x15]
        mov [bx + MenuRemap], al
        inc bx
        cmp bx, 0x40
        jl short .2
        mov bx, 0x40
.3:
        mov [bx + MenuRemap], bl
        inc bx
        cmp bx, 0x100
        jl short .3
.4:
        mov ax, DGROUP
        mov ds, ax
        jmp short .7
        db 0x90
.5:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov ax, 0x3a0b
        mov ds, ax
.6:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [si + MenuRemap], al
        mov [si + MenuRemap2], al
        inc si
        cmp si, 0x80
        jl short .6
        jmp short .4
.7:
        push word 0x3a0b
        push strict word MenuRemap
        call 0x0FEF:SetRemapTable
        add sp, 0x4
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawTextFmt                                                2095:0076  94 PC
; Sprintf with one argument into g_CFD4, then DrawText.
;
; Takes 4 words of stack arguments. Calls _sprintf, DrawText. Far routine (retf).
;-----------------------------------------------------------------------------
DrawTextFmt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word 0xcfd4
        call 0x0000:_sprintf
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0xcfd4
        call 0x0FEF:DrawText
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawTextFmt2                                               2095:009A  94 PC
; Same with two arguments.
;
; Takes 5 words of stack arguments. Calls _sprintf, DrawText. Far routine (retf).
;-----------------------------------------------------------------------------
DrawTextFmt2:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word 0xcfd4
        call 0x0000:_sprintf
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word 0xcfd4
        call 0x0FEF:DrawText
        leave
        retf

;-----------------------------------------------------------------------------
; CmpPoints                                                  2095:00C0  94 PC
; Leaders comparator: points (+6), then games, goals, plus/minus.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpPoints:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        cmp word [ss:statscontext], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        jmp short .2
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ds, dx
        cmp word [ss:statscontext], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x30
        add ax, [ss:g_C044]
        mov dx, [ss:statsskaterbuf]
        add ax, strict word 0x12
.4:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov es, dx
        cmp word [di], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        cmp word [es:bx], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .5
        mov ax, [es:bx]
        sub ax, [di]
        jmp short .9
.5:
        mov ax, [di + 0x6]
        cmp [es:bx + 0x6], ax
        jz short .6
        mov ax, [es:bx + 0x6]
        sub ax, [di + 0x6]
        jmp short .9
.6:
        mov ax, [di]
        cmp [es:bx], ax
        jz short .7
        sub ax, [es:bx]
        jmp short .9
.7:
        mov ax, [di + 0x2]
        cmp [es:bx + 0x2], ax
        jz short .8
        mov ax, [es:bx + 0x2]
        sub ax, [di + 0x2]
        jmp short .9
.8:
        mov ax, [es:bx + 0x10]
        sub ax, [di + 0x10]
.9:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CmpGAA                                                     2095:0180  94 PC
; Leaders comparator: goals against average.
;
; Takes 2 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
CmpGAA:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        cmp word [ss:statscontext], 0x0
        jnz short .1
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        jmp short .2
.1:
        mov bx, [bp + 0x6]
        imul ax, [ss:bx], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
.2:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ds, dx
        cmp word [ss:statscontext], 0x0
        jnz short .3
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        jmp short .4
.3:
        mov si, [bp + 0x8]
        imul ax, [ss:si], 0x36
        add ax, [ss:g_C040]
        mov dx, [ss:statsgoaliebuf]
        add ax, strict word 0x16
.4:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov es, dx
        cmp word [di + 0xc], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        cmp word [es:bx + 0xc], 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        neg cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        jz short .6
.5:
        mov ax, [es:bx + 0xc]
        sub ax, [di + 0xc]
        jmp short .12
.6:
        mov ax, [di + 0x10]
        cmp [es:bx + 0x10], ax
        jz short .7
        sub ax, [es:bx + 0x10]
        jmp short .12
        db 0x90
.7:
        mov ax, [di + 0xc]
        cmp [es:bx + 0xc], ax
        jnz short .5
        mov ax, [di]
        cmp [es:bx], ax
        jz short .8
        mov ax, [es:bx]
        sub ax, [di]
        jmp short .12
        db 0x90
.8:
        mov ax, [di + 0xe]
        cmp [es:bx + 0xe], ax
        jz short .9
        sub ax, [es:bx + 0xe]
        jmp short .12
        db 0x90
.9:
        mov ax, [di + 0x2]
        cmp [es:bx + 0x2], ax
        jz short .10
        mov ax, [es:bx + 0x2]
        sub ax, [di + 0x2]
        jmp short .12
.10:
        mov ax, [di + 0x4]
        cmp [es:bx + 0x4], ax
        jz short .11
        sub ax, [es:bx + 0x4]
        jmp short .12
        db 0x90
.11:
        mov ax, [es:bx + 0x14]
        sub ax, [di + 0x14]
.12:
        mov cx, DGROUP
        mov ds, cx
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPhotoShape                                             2095:026E  94 PC
; Reads one player photo from the 'shape' file ('sfh' header)
;
; Takes 2 words of stack arguments. Calls OpenReadShared, ReadAtOffset, AllocRecData, FindUnlink,
; _fmemcpy, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
LoadPhotoShape:
        enter 0x3c, 0x0
        push di
        push si
        mov word [bp - 0x16], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1c], dx
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        lea ax, [bp - 0x16]
        push ax
        push word [bp + 0x6]
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push 0x2
        push si
        push 0x4
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x16]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        mov [bp - 0xe], si
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push si
        mov si, [bp - 0x14]
        shl si, byte 0x3
        push 0x0
        push si
        push strict word str_Sfh
        call 0x14DB:AllocRecData
        add sp, 0x8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x1c], dx
        push si
        push 0x0
        push 0x6
        push dx
        push di
        push word [bp - 0x16]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0xe], ax
.2:
        cmp word [bp - 0xe], 0x0
        jnz short .5
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xc], ax
        mov [bp - 0x2], ax
        cmp [bp - 0x14], ax
        jng short .5
        mov ax, [bp - 0x1c]
        mov [bp - 0x22], di
        mov [bp - 0x20], ax
        mov [bp - 0x1e], di
.3:
        cmp word [bp - 0xc], 0x0
        jz short .8
.4:
        mov di, [bp - 0x1e]
.5:
        mov ax, [bp - 0x1c]
        db 0x0B, 0xC7                           ; insn: or ax, di
        jz short .6
        mov ax, [bp - 0x1c]
        push ax
        push di
        call 0x06E1:FindUnlink
        add sp, 0x4
.6:
        cmp word [bp - 0xe], 0x0
        jz short .7
        jmp near .12
.7:
        jmp near .13
        db 0x90
.8:
        push 0x4
        push word [bp - 0x20]
        push word [bp - 0x22]
        lea ax, [bp - 0x26]
        push ss
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov ax, [bp + 0x8]
        mov cx, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        lea si, [bp - 0x26]
        push ds
        pop es
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repe cmpsb
        jz short .9
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        sbb ax, strict word 0xffff
.9:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .10
        mov word [bp - 0xc], 0xffff
        mov ax, [bp - 0x14]
        cwd
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        shl ax, 1
        rcl dx, 1
        mov bx, [bp - 0x14]
        add bx, [bp - 0x2]
        shl bx, byte 0x2
        les si, [bp - 0x1e]
        add ax, [es:bx + si]
        adc dx, [es:bx + si + 0x2]
        add ax, strict word 0x6
        adc dx, 0x0
        mov [bp - 0x1a], ax
        mov [bp - 0x18], dx
        push 0x12
        push dx
        push ax
        lea ax, [bp - 0x3c]
        push ss
        push ax
        push word [bp - 0x16]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0xe], ax
.10:
        add word [bp - 0x22], 0x4
        mov ax, [bp - 0x14]
        inc word [bp - 0x2]
        cmp [bp - 0x2], ax
        jnl short .11
        jmp near .3
.11:
        jmp near .4
        db 0x90
.12:
        mov si, [bp - 0x2a]
        jmp short .14
        db 0x90
.13:
        mov si, [bp - 0x2a]
        cmp word [bp - 0xc], 0x0
        jz short .14
        push 0x0
        mov ax, [bp - 0x3a]
        imul word [bp - 0x3c]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, byte 0x2
        add di, 0x12
        push 0x0
        push di
        push strict word str_Shape
        call 0x14DB:AllocRecData
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x28], dx
        push di
        push word [bp - 0x18]
        push word [bp - 0x1a]
        push dx
        push si
        push word [bp - 0x16]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .14
        push word [bp - 0x28]
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x28], dx
.14:
        lea ax, [bp - 0x16]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0x28]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; GetSeasonTitle                                             2095:0438  94 PC
; Copies the season title for the stats header.
;
; Takes 5 words of stack arguments. Calls _fstrlen, CopyStrNFar.
;-----------------------------------------------------------------------------
GetSeasonTitle:
        enter 0xe, 0x0
        push di
        push si
        mov es, [segSeasonTitles1]
        cmp byte [es:0x0], 0x1
        jnz short .2
        mov ax, 0x2
        mov cx, 0x384b
.1:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], cx
        db 0x2B, 0xFF                           ; insn: sub di, di
        jmp short .7
        db 0x90
.2:
        mov es, [segSeasonTitles2]
        cmp byte [es:0x13], 0x1
        jnz short .3
        mov ax, 0x15
        mov cx, 0x384b
        jmp short .6
.3:
        mov es, [segSeasonTitles3]
        cmp byte [es:0x29], 0x1
        jnz short .4
        mov ax, 0x2b
        mov cx, 0x384b
        jmp short .1
.4:
        mov es, [segSeasonTitles4]
        cmp byte [es:0x3d], 0x1
        jnz short .5
        mov ax, 0x3f
        mov cx, 0x384b
        jmp short .6
.5:
        mov si, [bp - 0xa]
        mov di, [bp - 0x6]
        mov es, [segSeasonTitles5]
        cmp byte [es:0x5b], 0x1
        jnz short .7
        mov ax, 0x5d
        mov cx, 0x384b
.6:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], cx
        mov di, 0x1
.7:
        mov ax, [bp - 0x8]
        push ax
        push si
        mov [bp - 0xe], si
        mov [bp - 0xc], ax
        call 0x0000:_fstrlen
        add sp, 0x4
        db 0x2B, 0xC7                           ; insn: sub ax, di
        push ax
        push word [bp - 0xc]
        push word [bp - 0xe]
        push word [bp + 0x8]
        push word [bp + 0x6]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        les bx, [bp + 0x6]
        mov byte [es:bx + si], 0x0
        push word [bp + 0xc]
        push word [bp + 0xa]
        push es
