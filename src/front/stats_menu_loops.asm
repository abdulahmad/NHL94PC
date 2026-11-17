; Menu loops of the stats, standings and roster screens (STATS.OVL)
; The first bytes finish the last routine of stats_menus.asm.
        leave
        retf

;-----------------------------------------------------------------------------
; StrNotPrefixFar                                            1EAE:0002  94 PC
; 1 when the first far string differs from the start of the second.
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
StrNotPrefixFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        lds di, [bp + 0x6]
        cmp byte [di], 0x0
        jnz short .2
.1:
        mov ax, DGROUP
        mov ds, ax
        jmp short .5
.2:
        mov si, [bp + 0xa]
        mov es, [bp + 0xc]
.3:
        cmp byte [es:si], 0x0
        jz short .1
        mov al, [es:si]
        cmp [di], al
        jnz short .4
        inc si
        inc di
        cmp byte [di], 0x0
        jnz short .3
        jmp short .1
.4:
        mov ax, DGROUP
        mov ds, ax
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
.5:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; StatsMenuLoop                                              1EAE:0044  94 PC
; Pointer menu loop over a menu bar (pnt2/pntr, menubuff)
;
; Takes 6 words of stack arguments. Calls FindFarMsg, AllocRecData, GetBlockAt, DrawRleTransAt,
; MouseRange, MouseMove, FlushInputEvents, GetInputEvent and others. Far routine (retf).
;-----------------------------------------------------------------------------
StatsMenuLoop:
        enter 0x66, 0x0
        push di
        push si
        push strict word str_Pnt2_6
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [bp - 0x46], ax
        mov [bp - 0x44], dx
        mov ax, [bp + 0xa]
        mov [bp - 0x1e], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x48], ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x8], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        push ax
        les bx, [DialogData]
        mov cx, [es:bx]
        inc cx
        mov ax, [es:bx + 0x2]
        inc ax
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Pointer_7
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x5a], ax
        mov [bp - 0x58], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x5a]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x5a]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x5a]
        mov [es:bx + 0x2], ax
        les si, [bp - 0x46]
        mov ax, [es:si + 0x4]
        add ax, [es:si]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0xa], ax
        mov [bp - 0x12], ax
        mov ax, [es:si + 0x2]
        add ax, [es:si + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x6], ax
        mov [bp - 0x14], ax
        push ax
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x6]
        push word [bp - 0xa]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x0F99:FlushInputEvents
.1:
        db 0x2B, 0xFF                           ; insn: sub di, di
.2:
        call 0x0F99:GetInputEvent
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .3
        lea ax, [bp - 0x14]
        push ax
        lea ax, [bp - 0x12]
        push ax
        push si
        call far [HotKeyFn]
        add sp, 0x6
        db 0x8B, 0xF8                           ; insn: mov di, ax
        test di, 0x2
        jz short .2
.3:
        mov [bp - 0x2], di
        db 0x8B, 0xD7                           ; insn: mov dx, di
        test dl, 0x2
        jnz short .4
        jmp near .11
.4:
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x10]
        push ax
        lea ax, [bp - 0x36]
        push ax
        lea ax, [bp - 0x1e]
        push ax
        push word [bp - 0x8]
        lea ax, [bp - 0x46]
        push ax
        push word [bp - 0x14]
        push word [bp - 0x12]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .5
        jmp near .26
.5:
        imul ax, [bp - 0x16], 0x16
        mov si, [bp - 0x10]
        shl si, byte 0x2
        les bx, [bp + si - 0x46]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov [bp - 0x5e], bx
        mov [bp - 0x5c], es
        mov ax, [es:bx + 0xe]
        or ax, [es:bx + 0xc]
        jnz short .6
        jmp near .15
.6:
        mov ax, [bp - 0x16]
        mov si, [bp - 0x10]
        shl si, 1
        cmp [bp + si - 0x26], ax
        jz short .7
        jmp near .14
.7:
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x4], 0x3
        mov word [bp - 0x2], 0xc
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
.8:
        mov ax, [bp + si - 0x54]
        or ax, [bp + si - 0x56]
        jz short .9
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x34], ax
        mov [bp + si - 0x36], ax
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x06E1:FindUnlink
        add sp, 0x4
.9:
        sub si, 0x4
        dec di
        jns short .8
        push strict word str_Pntr_9
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        imul bx, [bp - 0x16], 0x16
        mov si, [bp - 0x10]
        shl si, byte 0x2
        les si, [bp + si - 0x46]
        call far [es:bx + si + 0xc]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push strict word str_Pnt2_5
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x48], ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x8], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x18], ax
        mov [bp - 0x1a], ax
        mov [bp - 0x1c], ax
        dec di
        jnz short .10
        jmp near .31
.10:
        mov si, [bp - 0xa]
        push word [bp - 0x6]
        push si
        call 0x03A3:MouseMove
        add sp, 0x4
        mov [bp - 0x12], si
        mov ax, [bp - 0x6]
        mov [bp - 0x14], ax
        call 0x0F99:FlushInputEvents
        jmp near .29
        db 0x90
.11:
        mov ax, [bp - 0xa]
        cmp [bp - 0x12], ax
        jz short .12
        jmp near .30
.12:
        mov ax, [bp - 0x6]
        cmp [bp - 0x14], ax
        jnz short .13
        jmp near .1
.13:
        jmp near .30
        db 0x90
.14:
        mov di, [bp + 0xc]
        mov si, [bp + 0xe]
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push si
        push di
        mov bx, [bp - 0x10]
        shl bx, byte 0x2
        lea ax, [bp - 0x34]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x03, 0xD8                           ; insn: add bx, ax
        push word [bx]
        lea bx, [bp - 0x36]
        db 0x03, 0xD9                           ; insn: add bx, cx
        push word [bx]
        mov bx, [bp - 0x10]
        shl bx, 1
        lea dx, [bp - 0x26]
        db 0x03, 0xDA                           ; insn: add bx, dx
        imul bx, [bx], 0x16
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        lea bx, [bp - 0x46]
        db 0x03, 0xD9                           ; insn: add bx, cx
        add ax, [bx]
        mov dx, [bx + 0x2]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push si
        push di
        mov bx, [bp - 0x10]
        shl bx, byte 0x2
        lea ax, [bp - 0x34]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x03, 0xD8                           ; insn: add bx, ax
        push word [bx]
        lea bx, [bp - 0x36]
        db 0x03, 0xD9                           ; insn: add bx, cx
        push word [bx]
        mov ax, [bp - 0x16]
        mov bx, [bp - 0x10]
        shl bx, 1
        lea dx, [bp - 0x26]
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov [bx], ax
        imul ax, ax, 0x16
        lea bx, [bp - 0x46]
        db 0x03, 0xD9                           ; insn: add bx, cx
        add ax, [bx]
        mov dx, [bx + 0x2]
        jmp near .24
.15:
        mov ax, [es:bx + 0x12]
        or ax, [es:bx + 0x10]
        jnz short .16
        jmp near .23
.16:
        mov si, [bp - 0x8]
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp [bp - 0x10], si
        jz short .20
        db 0x8B, 0xD6                           ; insn: mov dx, si
        cmp si, [bp - 0x10]
        jng short .19
        db 0x8B, 0xFA                           ; insn: mov di, dx
        shl di, 1
        shl si, byte 0x2
        mov [bp - 0x4], dx
.17:
        mov word [bp + di - 0x26], 0x0
        mov ax, [bp + si - 0x54]
        or ax, [bp + si - 0x56]
        jz short .18
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x34], ax
        mov [bp + si - 0x36], ax
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x54], ax
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x44], ax
        mov [bp + si - 0x46], ax
        mov [bp + di - 0x1e], ax
.18:
        dec di
        dec di
        sub si, 0x4
        mov ax, [bp - 0x10]
        dec word [bp - 0x4]
        cmp [bp - 0x4], ax
        jg short .17
.19:
        mov ax, [bp - 0x10]
        mov [bp - 0x8], ax
.20:
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x8]
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov di, [bp - 0x8]
        shl di, 1
        imul ax, [bp + di - 0x26], 0x16
        add ax, [bp + si - 0x46]
        mov dx, [bp + si - 0x44]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov ax, [bp - 0x16]
        mov [bp + di - 0x26], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x46]
        mov dx, [bp + si - 0x44]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x16], 0x16
        mov si, [bp - 0x10]
        shl si, byte 0x2
        les di, [bp + si - 0x46]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x8]
        mov di, [bp - 0x8]
        shl di, byte 0x2
        mov [bp + di - 0x46], ax
        mov [bp + di - 0x44], dx
        les si, [bp + si - 0x46]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov si, [bp - 0x8]
        shl si, 1
        mov [bp + si - 0x1e], ax
        mov [bp - 0x62], cx
        mov [bp - 0x60], es
        mov [bp - 0x64], si
        mov [bp - 0x66], di
        cmp word [bp - 0x8], 0x1
        jz short .21
        mov ax, 0x1
        jmp short .22
.21:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.22:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov bx, [bp - 0x62]
        add ax, [es:bx]
        db 0x8B, 0xF7                           ; insn: mov si, di
        add ax, [bp + si - 0x3a]
        mov [bp + si - 0x36], ax
        mov ax, [es:bx + 0x6]
        add ax, [bp + si - 0x38]
        mov [bp + si - 0x34], ax
        les bx, [bp + si - 0x46]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov di, [bp - 0x64]
        imul si, [bp + di - 0x1e], 0x16
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:si - 0x12]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov [bp - 0x2], ax
        mov cx, [es:si - 0x10]
        sub cx, [es:bx + 0x2]
        inc cx
        mov [bp - 0x4], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_3
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov si, [bp - 0x66]
        mov [bp + si - 0x56], ax
        mov [bp + si - 0x54], dx
        mov ax, [bp + si - 0x56]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push si
        push di
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        pop di
        pop si
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x2]
        mov [es:bx], cx
        mov cx, [bp - 0x4]
        mov [es:bx + 0x2], cx
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push dx
        push ax
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + di - 0x1e]
        push word [bp + si - 0x44]
        push word [bp + si - 0x46]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x26], 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x44]
        push word [bp + si - 0x46]
        jmp short .25
.23:
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x10]
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov di, [bp - 0x10]
        shl di, 1
        imul ax, [bp + di - 0x26], 0x16
        add ax, [bp + si - 0x46]
        mov dx, [bp + si - 0x44]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x10]
        shl si, byte 0x2
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        mov ax, [bp - 0x16]
        mov di, [bp - 0x10]
        shl di, 1
        mov [bp + di - 0x26], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x46]
        mov dx, [bp + si - 0x44]
.24:
        push dx
        push ax
.25:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp near .29
.26:
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x4], 0x3
        mov word [bp - 0x2], 0xc
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
.27:
        mov ax, [bp + si - 0x54]
        or ax, [bp + si - 0x56]
        jz short .28
        push word [bp + si - 0x34]
        push word [bp + si - 0x36]
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x34], ax
        mov [bp + si - 0x36], ax
        push word [bp + si - 0x54]
        push word [bp + si - 0x56]
        call 0x06E1:FindUnlink
        add sp, 0x4
.28:
        sub si, 0x4
        dec di
        jns short .27
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x38], ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x48], ax
        mov [bp - 0x4a], ax
        mov [bp - 0x4c], ax
        mov [bp - 0x4e], ax
        mov [bp - 0x50], ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x56], ax
        mov [bp - 0x8], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x18], ax
        mov [bp - 0x1a], ax
        mov [bp - 0x1c], ax
.29:
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
.30:
        push word [bp - 0x6]
        push word [bp - 0xa]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0x14]
        push word [bp - 0x12]
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x14]
        push word [bp - 0x12]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x12]
        mov [bp - 0xa], ax
        mov ax, [bp - 0x14]
        mov [bp - 0x6], ax
        jmp near .1
.31:
        push strict word str_Pntr_8
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push word [bp - 0x58]
        push word [bp - 0x5a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; StandingsMenuLoop                                          1EAE:07B6  94 PC
; Menu loop with the standings team cursor (XorRect, TeamFromMouse)
;
; Takes 6 words of stack arguments. Calls FindFarMsg, AllocRecData, XorRectRegs, HiliteStandingsTeam,
; GetBlockAt, DrawRleTransAt, MouseRange, MouseMove and others. Far routine (retf).
;-----------------------------------------------------------------------------
StandingsMenuLoop:
        enter 0x6c, 0x0
        push di
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x30], ax
        mov [bp - 0x3a], ax
        mov [bp - 0x2e], ax
        push strict word str_Pnt2_4
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [bp - 0x4c], ax
        mov [bp - 0x4a], dx
        mov ax, [bp + 0xa]
        mov [bp - 0x38], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x46], ax
        mov [bp - 0x48], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x62], ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x58], cx
        mov [bp - 0x5a], cx
        mov [bp - 0x5c], cx
        mov [bp - 0x5e], cx
        mov [bp - 0x10], cx
        mov [bp - 0x12], cx
        push cx
        cwd
        push dx
        push ax
        push strict word str_Pointer_6
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x16]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx + 0x2], ax
        les bx, [bp - 0x4c]
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x3c], ax
        mov [bp - 0x18], ax
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x4e], ax
        mov [bp - 0x1a], ax
        cmp word [statscontext], 0x0
        jz short .1
        jmp near .6
.1:
        mov word [bp - 0x50], 0x0
.2:
        mov ax, [statsmenusel]
        mov bx, [bp - 0x50]
        shl bx, 1
        cmp [bx + standingstab], ax
        jnz short .3
        mov ax, [bp - 0x50]
        mov [bp - 0x3a], ax
.3:
        inc word [bp - 0x50]
        cmp word [bp - 0x50], 0x18
        jl short .2
        mov bx, [bp - 0x3a]
        shl bx, 1
        imul si, [bx + standingstab], 0x1a
        les bx, [statsteambufseg]
        mov al, [es:bx + si + 0xd]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        and al, 0x1
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xbf
        add ax, strict word 0x74
        mov [bp - 0x50], ax
        mov [bp - 0x62], ax
        cmp cl, 0x2
        jc short .4
        mov ax, 0xa0
        jmp short .5
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.5:
        mov [bp - 0x54], ax
        push word 0x80
        push 0x7
        push word 0xa0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x3a]
        mov dx, 0x6
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv bx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        add dx, [bp - 0x62]
        push dx
        push cx
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        jmp short .7
        db 0x90
.6:
        mov bx, [statsmenusel]
        mov [bp - 0x3a], bx
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jz short .7
        push 0x0
        push 0x0
        lea ax, [bp - 0x3a]
        push ax
        call 0x24E6:HiliteStandingsTeam
        add sp, 0x6
.7:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x0F99:FlushInputEvents
.8:
        mov word [bp - 0x60], 0x0
.9:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        lea cx, [bp - 0x1a]
        push cx
        lea cx, [bp - 0x18]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x60], ax
        test al, 0x2
        jz short .9
.10:
        test byte [bp - 0x60], 0x2
        jz short .11
        jmp near .22
.11:
        mov word [bp - 0x56], 0x0
        cmp word [statscontext], 0x1
        jz short .12
        jmp near .19
.12:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        lea ax, [bp - 0x3a]
        push ax
        push word [bp - 0x18]
        call 0x24E6:MoveStandingsHilite
        add sp, 0xc
        mov [bp - 0x56], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
        jmp near .19
.13:
        cmp word [bp - 0x2e], 0x0
        jz short .17
        mov ax, [bp - 0x2e]
        mov [bp - 0x50], ax
        jmp short .16
.14:
        mov si, [bp - 0x50]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .15
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x28], ax
        mov [bp + si - 0x2a], ax
        mov [bp + si - 0x4a], ax
        mov [bp + si - 0x4c], ax
        mov si, [bp - 0x50]
        shl si, 1
        mov [bp + si - 0x38], ax
.15:
        dec word [bp - 0x50]
.16:
        cmp word [bp - 0x50], 0x0
        jnl short .14
        mov word [bp - 0x2e], 0x0
.17:
        call 0x24E6:DrawStandingsPage
        mov bx, [bp - 0x3a]
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jz short .18
        push 0x0
        push 0x0
        lea ax, [bp - 0x3a]
        push ax
        call 0x24E6:HiliteStandingsTeam
        add sp, 0x6
.18:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
.19:
        mov ax, [bp - 0x3c]
        cmp [bp - 0x18], ax
        jnz short .20
        mov ax, [bp - 0x4e]
        cmp [bp - 0x1a], ax
        jnz short .20
        cmp word [bp - 0x56], 0x0
        jnz short .20
        jmp near .8
.20:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
.21:
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x18]
        mov [bp - 0x3c], ax
        mov ax, [bp - 0x1a]
        mov [bp - 0x4e], ax
        jmp near .8
        db 0x90
.22:
        lea ax, [bp - 0x52]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x12]
        push dx
        lea dx, [bp - 0x38]
        push dx
        push word [bp - 0x2e]
        lea dx, [bp - 0x4c]
        push dx
        push word [bp - 0x1a]
        push word [bp - 0x18]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .23
        jmp near .48
.23:
        imul bx, [bp - 0x52], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x4c]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .24
        jmp near .40
.24:
        mov ax, [bp - 0x52]
        mov si, [bp - 0x2c]
        shl si, 1
        cmp [bp + si - 0x5e], ax
        jz short .25
        jmp near .38
.25:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x50], 0x3
.26:
        mov si, [bp - 0x50]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .27
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.27:
        dec word [bp - 0x50]
        jns short .26
        mov word [bp - 0x2e], 0x0
        cmp word [statscontext], 0x0
        jnz short .28
        mov bx, [bp - 0x3a]
        shl bx, 1
        mov ax, [bx + standingstab]
        mov [bp - 0x30], ax
        mov [statscategory], ax
        jmp short .29
        db 0x90
.28:
        mov bx, [bp - 0x3a]
        shl bx, 1
        mov ax, [bx + playofftree]
        mov [statscategory], ax
        mov ax, [bp - 0x3a]
.29:
        mov [statsmenusel], ax
        push strict word str_Pntr_7
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        imul bx, [bp - 0x52], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x4c]
        call far [es:bx + si + 0xc]
        mov [bp - 0x60], ax
        push strict word str_Pnt2_3
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x46], ax
        mov [bp - 0x48], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        cmp word [bp - 0x60], 0x1
        jnz short .30
        push strict word str_Pntr_6
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.30:
        cmp [statscontext], ax
        jz short .31
        jmp near .36
.31:
        mov [bp - 0x50], ax
.32:
        mov ax, [bp - 0x30]
        mov bx, [bp - 0x50]
        shl bx, 1
        cmp [bx + standingstab], ax
        jnz short .33
        mov ax, [bp - 0x50]
        mov [bp - 0x3a], ax
.33:
        inc word [bp - 0x50]
        cmp word [bp - 0x50], 0x18
        jl short .32
        mov bx, [bp - 0x3a]
        shl bx, 1
        imul si, [bx + standingstab], 0x1a
        les bx, [statsteambufseg]
        mov al, [es:bx + si + 0xd]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        and al, 0x1
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xbf
        add ax, strict word 0x74
        mov [bp - 0x50], ax
        mov [bp - 0x62], ax
        cmp cl, 0x2
        jc short .34
        mov ax, 0xa0
        jmp short .35
.34:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.35:
        mov [bp - 0x54], ax
        push word 0x80
        push 0x7
        push word 0xa0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x3a]
        mov dx, 0x6
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv bx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        add dx, [bp - 0x62]
        push dx
        push cx
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        jmp short .37
        db 0x90
.36:
        mov bx, [statsmenusel]
        mov [bp - 0x3a], bx
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jz short .37
        push ax
        push ax
        lea ax, [bp - 0x3a]
        push ax
        call 0x24E6:HiliteStandingsTeam
        add sp, 0x6
.37:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0x3c]
        mov [bp - 0x18], ax
        mov ax, [bp - 0x4e]
        mov [bp - 0x1a], ax
        call 0x0F99:FlushInputEvents
        jmp near .21
.38:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x2c]
        shl di, 1
        imul ax, [bp + di - 0x5e], 0x16
        add ax, [bp + si - 0x4c]
        mov dx, [bp + si - 0x4a]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x52]
        mov di, [bp - 0x2c]
        shl di, 1
        mov [bp + di - 0x5e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x4c]
        mov dx, [bp + si - 0x4a]
        push dx
        push ax
.39:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp near .21
.40:
        imul bx, [bp - 0x52], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x4c]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .41
        jmp near .38
.41:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x2e]
        cmp [bp - 0x2c], ax
        jz short .45
        mov [bp - 0x50], ax
        jmp short .44
        db 0x90
.42:
        mov si, [bp - 0x50]
        shl si, 1
        mov word [bp + si - 0x5e], 0x0
        mov di, [bp - 0x50]
        shl di, byte 0x2
        mov ax, [bp + di - 0x28]
        or ax, [bp + di - 0x2a]
        jz short .43
        push word [bp + di - 0x10]
        push word [bp + di - 0x12]
        push word [bp + di - 0x28]
        push word [bp + di - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x10], ax
        mov [bp + di - 0x12], ax
        push word [bp + di - 0x28]
        push word [bp + di - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x28], ax
        mov [bp + di - 0x2a], ax
        mov [bp + di - 0x4a], ax
        mov [bp + di - 0x4c], ax
        mov [bp + si - 0x38], ax
.43:
        dec word [bp - 0x50]
.44:
        mov ax, [bp - 0x2c]
        cmp [bp - 0x50], ax
        jg short .42
        mov [bp - 0x2e], ax
.45:
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        imul ax, [bp + di - 0x5e], 0x16
        add ax, [bp + si - 0x4c]
        mov dx, [bp + si - 0x4a]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x52]
        mov [bp + di - 0x5e], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x4c]
        mov dx, [bp + si - 0x4a]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x52], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les di, [bp + si - 0x4c]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x2e]
        mov di, [bp - 0x2e]
        shl di, byte 0x2
        mov [bp + di - 0x4c], ax
        mov [bp + di - 0x4a], dx
        les si, [bp + si - 0x4c]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov si, [bp - 0x2e]
        shl si, 1
        mov [bp + si - 0x38], ax
        mov [bp - 0x66], ax
        mov [bp - 0x6a], cx
        mov [bp - 0x68], es
        mov [bp - 0x6c], di
        cmp word [bp - 0x2e], 0x1
        jz short .46
        mov ax, 0x1
        jmp short .47
        db 0x90
.46:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.47:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov bx, [bp - 0x6a]
        add ax, [es:bx]
        db 0x8B, 0xF7                           ; insn: mov si, di
        add ax, [bp + si - 0x16]
        mov [bp + si - 0x12], ax
        mov ax, [es:bx + 0x6]
        add ax, [bp + si - 0x14]
        mov [bp + si - 0x10], ax
        les bx, [bp + si - 0x4c]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        imul di, [bp - 0x66], 0x16
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:di - 0x12]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov [bp - 0x62], ax
        mov cx, [es:di - 0x10]
        sub cx, [es:bx + 0x2]
        inc cx
        mov [bp - 0x64], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff_2
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x2a], ax
        mov [bp + si - 0x28], dx
        mov ax, [bp + si - 0x2a]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x62]
        mov [es:bx], cx
        mov cx, [bp - 0x64]
        mov [es:bx + 0x2], cx
        mov si, [bp - 0x2e]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x2e]
        shl di, 1
        push word [bp + di - 0x38]
        push word [bp + si - 0x4a]
        push word [bp + si - 0x4c]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x5e], 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x4a]
        push word [bp + si - 0x4c]
        jmp near .39
.48:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        lea ax, [bp - 0x30]
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x18]
        call 0x24E6:TeamFromMouse
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .49
        jmp near .65
.49:
        mov ax, [bp - 0x3a]
        cmp [bp - 0x30], ax
        jnz short .50
        jmp near .59
.50:
        cmp word [statscontext], 0x0
        jz short .51
        jmp near .56
.51:
        push word 0x80
        push 0x7
        push word 0xa0
        mov cx, 0x6
        cwd
        idiv cx
        mov bx, [bp - 0x3a]
        shl bx, 1
        imul si, [bx + standingstab], 0x1a
        les bx, [statsteambufseg]
        mov al, [es:bx + si + 0xd]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        and al, 0x1
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xbf
        add ax, strict word 0x74
        db 0x8B, 0xF2                           ; insn: mov si, dx
        shl dx, 1
        db 0x03, 0xD6                           ; insn: add dx, si
        shl dx, 1
        db 0x03, 0xD6                           ; insn: add dx, si
        db 0x03, 0xC2                           ; insn: add ax, dx
        push ax
        cmp bl, 0x2
        jc short .52
        mov ax, 0xa0
        jmp short .53
.52:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.53:
        push ax
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        mov bx, [bp - 0x30]
        mov [bp - 0x3a], bx
        shl bx, 1
        imul si, [bx + standingstab], 0x1a
        les bx, [statsteambufseg]
        mov al, [es:bx + si + 0xd]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        and al, 0x1
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and al, 0xbf
        add ax, strict word 0x74
        mov [bp - 0x50], ax
        mov [bp - 0x6c], ax
        cmp cl, 0x2
        jc short .54
        mov ax, 0xa0
        jmp short .55
        db 0x90
.54:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.55:
        mov [bp - 0x54], ax
        push word 0x80
        push 0x7
        push word 0xa0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp - 0x3a]
        mov dx, 0x6
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        idiv bx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        shl dx, 1
        db 0x03, 0xD0                           ; insn: add dx, ax
        add dx, [bp - 0x6c]
        push dx
        push cx
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        jmp near .21
.56:
        mov bx, [bp - 0x30]
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jnz short .57
        jmp near .21
.57:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jnz short .58
        jmp near .21
.58:
        lea ax, [bp - 0x30]
        push ax
        lea ax, [bp - 0x3a]
        push ax
        call 0x24E6:HiliteStandingsTeam
        add sp, 0x4
        jmp near .21
.59:
        cmp word [statscontext], 0x0
        jz short .60
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        cmp word [bx + playofftree], 0x18
        jnz short .60
        jmp near .21
.60:
        mov word [bp - 0x50], 0x3
.61:
        mov si, [bp - 0x50]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .62
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.62:
        dec word [bp - 0x50]
        jns short .61
        mov word [bp - 0x2e], 0x0
        cmp word [statscontext], 0x0
        jnz short .63
        mov bx, [bp - 0x3a]
        shl bx, 1
        mov ax, [bx + standingstab]
        mov [bp - 0x30], ax
        mov [statscategory], ax
        jmp short .64
.63:
        mov bx, [bp - 0x3a]
        shl bx, 1
        mov ax, [bx + playofftree]
        mov [statscategory], ax
        mov ax, [bp - 0x3a]
.64:
        mov [statsmenusel], ax
        call 0x2248:StandingsActRoster2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x46], ax
        mov [bp - 0x48], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push strict word str_Pntr_5
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.65:
        push word [bp - 0x4e]
        push word [bp - 0x3c]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x50], 0x3
.66:
        mov si, [bp - 0x50]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .67
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.67:
        dec word [bp - 0x50]
        jns short .66
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x46], ax
        mov [bp - 0x48], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        mov [bp - 0x2e], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x5c], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov [bp - 0x36], ax
        jmp near .21

;-----------------------------------------------------------------------------
; RosterMenuLoop                                             1EAE:12F6  94 PC
; Menu loop with the roster row cursor.
;
; Takes 6 words of stack arguments. Calls FindFarMsg, AllocRecData, StrNotPrefixFar, XorRectRegs,
; GetBlockAt, DrawRleTransAt, MouseRange, MouseMove and others. Far routine (retf).
;-----------------------------------------------------------------------------
RosterMenuLoop:
        enter 0x6a, 0x0
        push di
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x52], ax
        mov [bp - 0x54], ax
        mov [bp - 0x2e], ax
        push strict word str_Pnt2_2
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [bp - 0x48], ax
        mov [bp - 0x46], dx
        mov ax, [bp + 0xa]
        mov [bp - 0x36], ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x60], ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        mov [bp - 0x56], cx
        mov [bp - 0x58], cx
        mov [bp - 0x5a], cx
        mov [bp - 0x5c], cx
        mov [bp - 0x10], cx
        mov [bp - 0x12], cx
        push cx
        cwd
        push dx
        push ax
        push strict word str_Pointer_5
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x16], ax
        mov [bp - 0x14], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x16]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x16]
        mov [es:bx + 0x2], ax
        les bx, [bp - 0x48]
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x38], ax
        mov [bp - 0x18], ax
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x4a], ax
        mov [bp - 0x1a], ax
        cmp byte [statsplayer], 0x47
        jz short .1
        cmp byte [statsplayer], 0x67
        jnz short .5
.1:
        mov word [bp - 0x4c], 0x0
        jmp short .3
.2:
        inc word [bp - 0x4c]
.3:
        mov ax, [rostersel]
        cmp [bp - 0x4c], ax
        jl short .4
        jmp near .9
.4:
        mov bx, [bp - 0x4c]
        shl bx, 1
        mov bx, [bx + rosterrowptrs2]
        shl bx, 1
        mov ax, [bx + rosterrows2]
        mov [bp - 0x50], ax
        imul ax, ax, 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x3
        push dx
        push ax
        push ds
        push strict word rosterfilter
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        imul ax, [bp - 0x50], 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x13
        push dx
        push ax
        push ds
        push strict word rosterfilter2
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        mov ax, [bp - 0x4c]
        add ax, [rostertop]
        jmp short .8
.5:
        cmp byte [statsplayer], 0x0
        jz short .9
        mov word [bp - 0x4c], 0x0
        jmp short .7
.6:
        inc word [bp - 0x4c]
.7:
        mov ax, [rostertop]
        cmp [bp - 0x4c], ax
        jnl short .9
        mov bx, [bp - 0x4c]
        shl bx, 1
        mov bx, [bx + rosterrowptrs]
        shl bx, 1
        mov ax, [bx + rosterrows]
        mov [bp - 0x50], ax
        imul ax, ax, 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x3
        push dx
        push ax
        push ds
        push strict word rosterfilter
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
        imul ax, [bp - 0x50], 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x13
        push dx
        push ax
        push ds
        push strict word rosterfilter2
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .6
        mov ax, [bp - 0x4c]
.8:
        mov [bp - 0x54], ax
.9:
        push word 0x80
        push 0x7
        push word 0x140
        mov ax, [rostertop]
        cmp [bp - 0x54], ax
        jl short .10
        mov ax, 0x1f
        jmp short .11
        db 0x90
.10:
        mov ax, 0x17
.11:
        mov cx, [bp - 0x54]
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, 1
        db 0x03, 0xCA                           ; insn: add cx, dx
        shl cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x4c], ax
        push ax
        push 0x0
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        push word 0xc8
        push word 0x140
        push 0x0
        push 0x0
        call 0x03A3:MouseRange
        add sp, 0x8
        push word [bp - 0x4a]
        push word [bp - 0x38]
        call 0x03A3:MouseMove
        add sp, 0x4
        call far [MousePosFn]
        call 0x0F99:FlushInputEvents
.12:
        mov word [bp - 0x5e], 0x0
.13:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .14
        lea cx, [bp - 0x1a]
        push cx
        lea cx, [bp - 0x18]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x5e], ax
        test al, 0x2
        jz short .13
.14:
        test byte [bp - 0x5e], 0x2
        jnz short .17
        mov ax, [bp - 0x38]
        cmp [bp - 0x18], ax
        jnz short .15
        mov ax, [bp - 0x4a]
        cmp [bp - 0x1a], ax
        jz short .12
.15:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
.16:
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x1a]
        push word [bp - 0x18]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x18]
        mov [bp - 0x38], ax
        mov ax, [bp - 0x1a]
        mov [bp - 0x4a], ax
        jmp near .12
.17:
        lea ax, [bp - 0x4e]
        push ax
        lea cx, [bp - 0x2c]
        push cx
        lea dx, [bp - 0x12]
        push dx
        lea dx, [bp - 0x36]
        push dx
        push word [bp - 0x2e]
        lea dx, [bp - 0x48]
        push dx
        push word [bp - 0x1a]
        push word [bp - 0x18]
        call 0x0FA0:MenuHitTest
        add sp, 0x10
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        jmp near .46
.18:
        imul bx, [bp - 0x4e], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x48]
        mov ax, [es:bx + si + 0xe]
        or ax, [es:bx + si + 0xc]
        jnz short .19
        jmp near .36
.19:
        mov ax, [bp - 0x4e]
        mov si, [bp - 0x2c]
        shl si, 1
        cmp [bp + si - 0x5c], ax
        jz short .20
        jmp near .44
.20:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x4c], 0x3
.21:
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .22
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.22:
        dec word [bp - 0x4c]
        jns short .21
        mov word [bp - 0x2e], 0x0
        mov ax, [bp - 0x52]
        cmp [rostertop], ax
        jng short .23
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov bx, [bx + rosterrowptrs]
        mov [bp - 0x4c], bx
        shl bx, 1
        mov ax, [bx + rosterrows]
        jmp short .24
        db 0x90
.23:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        sub bx, [rostertop]
        shl bx, 1
        mov bx, [bx + rosterrowptrs2]
        mov [bp - 0x4c], bx
        shl bx, 1
        mov ax, [bx + rosterrows2]
.24:
        mov [bp - 0x50], ax
        mov ax, 0xcf1a
        imul cx, [bp - 0x50], 0x34
        add cx, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        push ds
        pop es
        mov ds, dx
        mov cx, 0x1a
        rep movsw
        pop ds
        push strict word str_Pntr_4
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        imul bx, [bp - 0x4e], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x48]
        call far [es:bx + si + 0xc]
        mov [bp - 0x5e], ax
        push strict word str_Pnt2
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        cmp word [bp - 0x5e], 0x1
        jnz short .25
        push strict word str_Pntr_3
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.25:
        cmp byte [statsplayer], 0x47
        jnz short .29
        mov [bp - 0x4c], ax
        jmp short .27
.26:
        inc word [bp - 0x4c]
.27:
        mov ax, [rostersel]
        cmp [bp - 0x4c], ax
        jl short .28
        jmp near .33
.28:
        mov bx, [bp - 0x4c]
        shl bx, 1
        mov bx, [bx + rosterrowptrs2]
        shl bx, 1
        mov ax, [bx + rosterrows2]
        mov [bp - 0x50], ax
        imul ax, ax, 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x3
        push dx
        push ax
        push ds
        push strict word rosterfilter
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .26
        imul ax, [bp - 0x50], 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x13
        push dx
        push ax
        push ds
        push strict word rosterfilter2
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .26
        mov ax, [bp - 0x4c]
        add ax, [rostertop]
        jmp short .32
.29:
        cmp byte [statsplayer], 0x0
        jz short .33
        mov [bp - 0x4c], ax
        jmp short .31
.30:
        inc word [bp - 0x4c]
.31:
        mov ax, [rostertop]
        cmp [bp - 0x4c], ax
        jnl short .33
        mov bx, [bp - 0x4c]
        shl bx, 1
        mov bx, [bx + rosterrowptrs]
        shl bx, 1
        mov ax, [bx + rosterrows]
        mov [bp - 0x50], ax
        imul ax, ax, 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x3
        push dx
        push ax
        push ds
        push strict word rosterfilter
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .30
        imul ax, [bp - 0x50], 0x34
        add ax, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        add ax, strict word 0x13
        push dx
        push ax
        push ds
        push strict word rosterfilter2
        push cs
        call StrNotPrefixFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .30
        mov ax, [bp - 0x4c]
.32:
        mov [bp - 0x54], ax
.33:
        push word 0x80
        push 0x7
        push word 0x140
        mov ax, [rostertop]
        cmp [bp - 0x54], ax
        jl short .34
        mov ax, 0x1f
        jmp short .35
        db 0x90
.34:
        mov ax, 0x17
.35:
        mov cx, [bp - 0x54]
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, 1
        db 0x03, 0xCA                           ; insn: add cx, dx
        shl cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x4c], ax
        push ax
        push 0x0
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        push word [bp - 0x4a]
        push word [bp - 0x38]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0x38]
        mov [bp - 0x18], ax
        mov ax, [bp - 0x4a]
        mov [bp - 0x1a], ax
        call 0x0F99:FlushInputEvents
        jmp near .16
.36:
        imul bx, [bp - 0x4e], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les si, [bp + si - 0x48]
        mov ax, [es:bx + si + 0x12]
        or ax, [es:bx + si + 0x10]
        jnz short .37
        jmp near .44
.37:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, [bp - 0x2e]
        cmp [bp - 0x2c], ax
        jz short .41
        mov [bp - 0x4c], ax
        jmp short .40
        db 0x90
.38:
        mov si, [bp - 0x4c]
        shl si, 1
        mov word [bp + si - 0x5c], 0x0
        mov di, [bp - 0x4c]
        shl di, byte 0x2
        mov ax, [bp + di - 0x28]
        or ax, [bp + di - 0x2a]
        jz short .39
        push word [bp + di - 0x10]
        push word [bp + di - 0x12]
        push word [bp + di - 0x28]
        push word [bp + di - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x10], ax
        mov [bp + di - 0x12], ax
        push word [bp + di - 0x28]
        push word [bp + di - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + di - 0x28], ax
        mov [bp + di - 0x2a], ax
        mov [bp + di - 0x46], ax
        mov [bp + di - 0x48], ax
        mov [bp + si - 0x36], ax
.39:
        dec word [bp - 0x4c]
.40:
        mov ax, [bp - 0x2c]
        cmp [bp - 0x4c], ax
        jg short .38
        mov [bp - 0x2e], ax
.41:
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        shl di, 1
        imul ax, [bp + di - 0x5c], 0x16
        add ax, [bp + si - 0x48]
        mov dx, [bp + si - 0x46]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x4e]
        mov [bp + di - 0x5c], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x48]
        mov dx, [bp + si - 0x46]
        push dx
        push ax
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        imul bx, [bp - 0x4e], 0x16
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        les di, [bp + si - 0x48]
        mov ax, [es:bx + di + 0x10]
        mov dx, [es:bx + di + 0x12]
        inc word [bp - 0x2e]
        mov di, [bp - 0x2e]
        shl di, byte 0x2
        mov [bp + di - 0x48], ax
        mov [bp + di - 0x46], dx
        les si, [bp + si - 0x48]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov al, [es:si + 0x14]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov si, [bp - 0x2e]
        shl si, 1
        mov [bp + si - 0x36], ax
        mov [bp - 0x64], ax
        mov [bp - 0x68], cx
        mov [bp - 0x66], es
        mov [bp - 0x6a], di
        cmp word [bp - 0x2e], 0x1
        jz short .42
        mov ax, 0x1
        jmp short .43
        db 0x90
.42:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.43:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov bx, [bp - 0x68]
        add ax, [es:bx]
        db 0x8B, 0xF7                           ; insn: mov si, di
        add ax, [bp + si - 0x16]
        mov [bp + si - 0x12], ax
        mov ax, [es:bx + 0x6]
        add ax, [bp + si - 0x14]
        mov [bp + si - 0x10], ax
        les bx, [bp + si - 0x48]
        mov ax, [es:bx]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        imul di, [bp - 0x64], 0x16
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:di - 0x12]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov [bp - 0x60], ax
        mov cx, [es:di - 0x10]
        sub cx, [es:bx + 0x2]
        inc cx
        mov [bp - 0x62], cx
        push 0x0
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        cwd
        push dx
        push ax
        push strict word str_Menubuff
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp + si - 0x2a], ax
        mov [bp + si - 0x28], dx
        mov ax, [bp + si - 0x2a]
        mov cx, [DialogData]
        mov bx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov es, dx
        mov ds, bx
        mov cx, 0x9
        rep movsw
        pop ds
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, [bp - 0x60]
        mov [es:bx], cx
        mov cx, [bp - 0x62]
        mov [es:bx + 0x2], cx
        mov si, [bp - 0x2e]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x2e]
        shl di, 1
        push word [bp + di - 0x36]
        push word [bp + si - 0x46]
        push word [bp + si - 0x48]
        call 0x0FA0:DrawMenuPanel
        add sp, 0x10
        mov word [bp + di - 0x5c], 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x46]
        push word [bp + si - 0x48]
        jmp short .45
        db 0x90
.44:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov di, [bp - 0x2c]
        shl di, 1
        imul ax, [bp + di - 0x5c], 0x16
        add ax, [bp + si - 0x48]
        mov dx, [bp + si - 0x46]
        push dx
        push ax
        call 0x0FA0:DrawMenuItem
        add sp, 0xe
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov si, [bp - 0x2c]
        shl si, byte 0x2
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        mov ax, [bp - 0x4e]
        mov di, [bp - 0x2c]
        shl di, 1
        mov [bp + di - 0x5c], ax
        imul ax, ax, 0x16
        add ax, [bp + si - 0x48]
        mov dx, [bp + si - 0x46]
        push dx
        push ax
.45:
        call 0x0FA0:DrawMenuItemHilite
        add sp, 0xe
        jmp near .16
.46:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        lea ax, [bp - 0x52]
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x18]
        call 0x2446:RosterRowAt
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .47
        jmp near .59
.47:
        mov word [bp - 0x4c], 0x3
.48:
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .49
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.49:
        dec word [bp - 0x4c]
        jns short .48
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        mov [bp - 0x2e], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        mov ax, [bp - 0x52]
        cmp [bp - 0x54], ax
        jz short .54
        push word 0x80
        push 0x7
        push word 0x140
        mov ax, [rostertop]
        cmp [bp - 0x54], ax
        jl short .50
        mov ax, 0x1f
        jmp short .51
        db 0x90
.50:
        mov ax, 0x17
.51:
        mov cx, [bp - 0x54]
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, 1
        db 0x03, 0xCA                           ; insn: add cx, dx
        shl cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        push 0x0
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        mov ax, [bp - 0x52]
        mov [bp - 0x54], ax
        cmp ax, [rostertop]
        jl short .52
        mov ax, 0x1f
        jmp short .53
.52:
        mov ax, 0x17
.53:
        mov cx, [bp - 0x54]
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        shl cx, 1
        db 0x03, 0xCA                           ; insn: add cx, dx
        shl cx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [bp - 0x4c], ax
        push word 0x80
        push 0x7
        push word 0x140
        push ax
        push 0x0
        call 0x0FEF:XorRectRegs
        add sp, 0xa
        jmp near .16
        db 0x90
.54:
        mov word [bp - 0x4c], 0x3
.55:
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .56
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.56:
        dec word [bp - 0x4c]
        jns short .55
        mov word [bp - 0x2e], 0x0
        mov ax, [bp - 0x52]
        cmp [rostertop], ax
        jng short .57
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov bx, [bx + rosterrowptrs]
        mov [bp - 0x4c], bx
        shl bx, 1
        mov ax, [bx + rosterrows]
        jmp short .58
        db 0x90
.57:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        sub bx, [rostertop]
        shl bx, 1
        mov bx, [bx + rosterrowptrs2]
        mov [bp - 0x4c], bx
        shl bx, 1
        mov ax, [bx + rosterrows2]
.58:
        mov [bp - 0x50], ax
        mov ax, 0xcf1a
        imul cx, [bp - 0x50], 0x34
        add cx, [statsplayerbufseg]
        mov dx, [statsplayerbuf]
        push ds
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x8B, 0xF1                           ; insn: mov si, cx
        push ds
        pop es
        mov ds, dx
        mov cx, 0x1a
        rep movsw
        pop ds
        call 0x2248:StandingsActPlayer
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push strict word str_Pntr_2
        push word [MemBlock1Seg]
        push word [MemBlock1Off]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [DialogData], ax
        mov [DialogDataSeg], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
        mov [bp - 0x34], ax
        pop si
        pop di
        leave
        retf
        db 0x90
.59:
        push word [bp - 0x4a]
        push word [bp - 0x38]
        push word [bp - 0x14]
        push word [bp - 0x16]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov word [bp - 0x4c], 0x3
.60:
        mov si, [bp - 0x4c]
        shl si, byte 0x2
        mov ax, [bp + si - 0x28]
        or ax, [bp + si - 0x2a]
        jz short .61
        push word [bp + si - 0x10]
        push word [bp + si - 0x12]
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp + si - 0x10], ax
        mov [bp + si - 0x12], ax
        push word [bp + si - 0x28]
        push word [bp + si - 0x2a]
        call 0x06E1:FindUnlink
        add sp, 0x4
.61:
        dec word [bp - 0x4c]
        jns short .60
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x3a], ax
        mov [bp - 0x3c], ax
        mov [bp - 0x3e], ax
        mov [bp - 0x40], ax
        mov [bp - 0x42], ax
        mov [bp - 0x44], ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        mov [bp - 0x20], ax
        mov [bp - 0x22], ax
        mov [bp - 0x24], ax
        mov [bp - 0x26], ax
        mov [bp - 0x28], ax
        mov [bp - 0x2a], ax
        mov [bp - 0x2e], ax
        mov [bp - 0x56], ax
        mov [bp - 0x58], ax
        mov [bp - 0x5a], ax
        mov [bp - 0x30], ax
        mov [bp - 0x32], ax
