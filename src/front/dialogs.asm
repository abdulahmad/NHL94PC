; Front-end dialog boxes: yes/no questions, bevelled boxes, number entry, and the scrolling lists
; with their row drawing and hit tests.

;-----------------------------------------------------------------------------
; AskYesNo                                                    0D90:0000  94 PC
; Two-button message box at the mouse; keeps the answer string.
;-----------------------------------------------------------------------------
AskYesNo:
        enter 0x6, 0x0
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x2]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x2
        push word 0x3701                        ; segment of the team choice text far data
        push strict word 0x67
        push 0x3
        push word 0x3701                        ; segment of the team choice text far data
        push strict word 0x5b
        push -0x1
        push -0x1
        push cs
        call MessageBox
        add sp, 0x16
        mov [bp - 0x2], ax
        cmp ax, strict word 0x1
        jnz short .1
        mov ax, 0xbb3
        mov dx, 0x3701                          ; segment of the team choice text far data
        jmp short .2
        db 0x90
.1:
        mov ax, 0xbaf
        mov dx, 0x3701                          ; segment of the team choice text far data
.2:
        mov [YesNoText], ax
        mov [YesNoTextSeg], dx
        mov ax, [bp - 0x2]
        leave
        retf

;-----------------------------------------------------------------------------
; DrawBevelBox                                                0D90:0060  94 PC
; Filled rectangle and four edge lines in a light and a dark colour.
;-----------------------------------------------------------------------------
DrawBevelBox:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov si, [bp + 0x8]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push si
        push di
        call 0x0FEF:FillRect
        add sp, 0xa
        push word [bp + 0x10]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, [bp + 0xc]
        lea cx, [si - 0x1]
        push cx
        push di
        push ax
        push di
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], cx
        call 0x0FEF:DrawLine
        add sp, 0xa
        push word [bp + 0x10]
        push si
        db 0x8B, 0xC7                           ; insn: mov ax, di
        add di, [bp + 0xa]
        lea cx, [di - 0x1]
        push cx
        push si
        push ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x4], cx
        call 0x0FEF:DrawLine
        add sp, 0xa
        push word [bp + 0x12]
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0x2]
        push di
        call 0x0FEF:DrawLine
        add sp, 0xa
        push word [bp + 0x12]
        push word [bp - 0x2]
        push word [bp - 0x4]
        push si
        push word [bp - 0x4]
        call 0x0FEF:DrawLine
        add sp, 0xa
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; NumberEntryDialog                                           0D90:00E6  94 PC
; Text entry box read back with atol.
;-----------------------------------------------------------------------------
NumberEntryDialog:
        enter 0xc, 0x0
        push di
        push si
        call 0x0BFE:InputShutdown
        call 0x0FEF:UseCurrentPage
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        add si, 0x10
        mov di, [bp + 0xe]
        add di, 0x8
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jnl short .1
        lea si, [di + 0x10]
.1:
        les bx, [FontPtr]
        mov ax, [es:bx + 0xe]
        add ax, strict word 0x9
        shl ax, 1
        mov [bp - 0x2], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        sub ax, 0xc8
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x6], ax
        push cx
        push si
        push ax
        mov ax, 0x140
        db 0x2B, 0xC6                           ; insn: sub ax, si
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        push ax
        mov [bp - 0xc], ax
        push cs
        call SaveUnderBox
        add sp, 0x8
        push word [ItemSelectColor]
        push word [ItemTextColor]
        call 0x0D39:SetTextColors
        add sp, 0x4
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [bp - 0x2]
        push si
        push word [bp - 0x6]
        push word [bp - 0xc]
        push cs
        call DrawBevelBox
        add sp, 0xe
        mov ax, [ItemTextColor]
        mov dx, [ItemSelectColor]
        call 0x03A3:SetCharPtr.regs
        push word [bp + 0x8]
        push word [bp + 0x6]
        mov ax, [bp - 0x6]
        add ax, strict word 0x7
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bp - 0xc]
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push word [DialogLightColor]
        push word [DialogDarkColor]
        push word [ItemSelectColor]
        push 0x9
        push di
        mov ax, [bp - 0x6]
        add ax, strict word 0x10
        push ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xC7                           ; insn: sub ax, di
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bp - 0xc]
        mov [bp - 0x8], ax
        push ax
        push cs
        call DrawBevelBox
        add sp, 0xe
        mov ax, [ItemTextColor]
        mov dx, [ItemSelectColor]
        call 0x03A3:SetCharPtr.regs
        mov [bp - 0xa], di
.2:
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        call 0x0F99:FlushInputEvents
        cmp word [bp + 0x10], 0x0
        jnz short .5
        mov si, [bp + 0xa]
.3:
        mov byte [si], 0x0
        push word [bp + 0x18]
        push 0x0
        push 0x0
        push word 0x3a3
        push word 0x734
        mov ax, [bp - 0x6]
        add ax, strict word 0x12
        push ax
        mov ax, [bp - 0x8]
        inc ax
        inc ax
        push ax
        mov ax, [bp - 0xa]
        sub ax, strict word 0x8
        push ax
        push word [bp + 0xc]
        push si
        call 0x1B35:OvlThunk102
        add sp, 0x14
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x2], 0x1
        cmp word [bp + 0x16], 0x0
        jz short .4
        cmp byte [si], 0x0
        jnz short .4
        cmp di, 0x1b
        jz short .4
        mov word [bp - 0x2], 0x0
.4:
        cmp word [bp - 0x2], 0x0
        jz short .3
        jmp near .10
        db 0x90
.5:
        mov si, [bp + 0xa]
.6:
        mov byte [si], 0x0
        push word [bp + 0x18]
        push 0x0
        push 0x0
        push word 0x3a3
        push word 0x734
        mov ax, [bp - 0x6]
        add ax, strict word 0x12
        push ax
        mov ax, [bp - 0x8]
        inc ax
        inc ax
        push ax
        mov ax, [bp - 0xa]
        sub ax, strict word 0x8
        push ax
        push word [bp + 0xc]
        push si
        call 0x1B35:OvlThunk102
        add sp, 0x14
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0x2], ax
        cmp [bp + 0xc], ax
        jng short .9
        db 0x8B, 0xF8                           ; insn: mov di, ax
.7:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov al, [bx]
        cbw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        test byte [bx + CharTypes], 0x4
        jnz short .8
        cmp byte [si], 0x20
        jz short .8
        cmp byte [si], 0x0
        jz short .8
        cmp byte [si], 0x2d
        jnz short .9
.8:
        push si
        call 0x0000:_atoi
        add sp, 0x2
        mov [bp - 0x4], ax
        inc di
        cmp [bp + 0xc], di
        jg short .7
.9:
        mov ax, [bp - 0x4]
        cmp [bp + 0x12], ax
        jg short .6
        cmp [bp + 0x14], ax
        jl short .6
        db 0x8B, 0xF8                           ; insn: mov di, ax
.10:
        mov [bp - 0x4], di
.11:
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
        call 0x0F99:FlushInputEvents
        push cs
        call RestoreUnderBox
        call 0x0BFE:InputInit
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ItemColors                                                  0D90:032A  94 PC
; Picks the normal or highlight colour pair for a list row.
;-----------------------------------------------------------------------------
ItemColors:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov ax, [bp + 0x6]
        cmp [bp + 0x8], ax
        jnz short .1
        mov si, [ItemSelectColor]
        mov cx, [ItemTextColor]
        jmp short .2
.1:
        mov si, [ItemTextColor]
        mov cx, [ItemSelectColor]
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        call 0x03A3:SetCharPtr.regs
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ListHitTest                                                 0D90:0354  94 PC
; List row under the cursor.
;-----------------------------------------------------------------------------
ListHitTest:
        enter 0x10, 0x0
        push si
        mov bx, [bp + 0xc]
        inc bx
        inc bx
        mov dx, [bp + 0xa]
        inc dx
        inc dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp + 0xe]
        sub ax, strict word 0x4
        mov [bp - 0xe], ax
        mov word [bp - 0xa], 0xffff
        mov word [bp - 0x4], 0x0
        cmp word [bp + 0x10], 0x0
        jng short .3
        mov [bp - 0x10], dx
        les si, [FontPtr]
        mov cx, [es:si + 0xe]
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x03, 0xCB                           ; insn: add cx, bx
        inc cx
        inc cx
        inc ax
        inc ax
        mov [bp - 0xc], ax
        mov dx, [bp - 0x4]
        mov [bp + 0xc], bx
        db 0x8B, 0xF1                           ; insn: mov si, cx
.1:
        cmp word [bp - 0xa], 0x0
        jnl short .3
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov ax, [bp - 0x10]
        cmp [bp + 0x6], ax
        jl short .2
        mov ax, [bp - 0xe]
        cmp [bp + 0x6], ax
        jg short .2
        cmp cx, [bp + 0x8]
        jg short .2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        cmp [bp + 0x8], ax
        jg short .2
        mov [bp - 0xa], dx
.2:
        add si, [bp - 0xc]
        add bx, [bp - 0xc]
        inc dx
        cmp [bp + 0x10], dx
        jg short .1
.3:
        mov ax, [bp - 0xa]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawListRow                                                 0D90:03D6  94 PC
; One list row with its colours.
;-----------------------------------------------------------------------------
DrawListRow:
        enter 0x2, 0x0
        push di
        push si
        mov di, [bp + 0x12]
        mov si, [bp + 0xa]
        les bx, [FontPtr]
        mov ax, [es:bx + 0xe]
        inc ax
        inc ax
        mov [bp - 0x2], ax
        db 0x8B, 0xCF                           ; insn: mov cx, di
        sub cx, [bp + 0x10]
        imul cx
        inc ax
        inc ax
        add [bp + 0xc], ax
        inc si
        inc si
        sub word [bp + 0xe], 0x4
        cmp word [bp + 0x18], 0x0
        jz short .1
        les bx, [bp + 0x1a]
        cmp byte [es:bx + di], 0x0
        jz short .1
        mov cx, [DialogBackColor]
        jmp short .3
.1:
        cmp [bp + 0x14], di
        jnz short .2
        mov cx, [ItemTextColor]
        jmp short .3
        db 0x90
.2:
        mov cx, [ItemSelectColor]
.3:
        push cx
        push word [bp - 0x2]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push si
        call 0x0FEF:FillRect
        add sp, 0xa
        push word [bp + 0x14]
        push di
        push cs
        call ItemColors
        add sp, 0x4
        mov ax, [bp + 0x16]
        dec ax
        jz short .4
        dec ax
        jz short .5
        jmp short .7
        db 0x90
.4:
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        sub ax, [bp + 0xe]
        neg ax
        sub ax, strict word 0x4
        jmp short .6
.5:
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        sub ax, [bp + 0xe]
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
.6:
        db 0x03, 0xF0                           ; insn: add si, ax
.7:
        push word [bp + 0x8]
        push word [bp + 0x6]
        mov ax, [bp + 0xc]
        inc ax
        push ax
        push si
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawListRows                                                0D90:049A  94 PC
; The visible rows.
;-----------------------------------------------------------------------------
DrawListRows:
        enter 0x4, 0x0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp [bp + 0x14], si
        jng short .2
        mov ax, [bp + 0x10]
        shl ax, byte 0x2
        add ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
.1:
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word [bp + 0x18]
        push word [bp + 0x16]
        push word [bp + 0x12]
        mov ax, [bp + 0x10]
        db 0x03, 0xC6                           ; insn: add ax, si
        push ax
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov es, [bp - 0x2]
        push word [es:di + 0x2]
        push word [es:di]
        push cs
        call DrawListRow
        add sp, 0x18
        add di, 0x4
        mov ax, [bp - 0x2]
        inc si
        cmp [bp + 0x14], si
        jg short .1
.2:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ListDialog                                                  0D90:04FA  94 PC
; Scrolling list with a scroll bar, mouse and keys.
;-----------------------------------------------------------------------------
ListDialog:
        enter 0x32, 0x0
        push di
        push si
        call 0x0FEF:UseCurrentPage
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x4], ax
        mov [bp - 0x1c], ax
        cmp [bp + 0x12], ax
        jz short .1
        mov word [bp - 0x1c], 0xffff
.1:
        mov ax, [bp + 0xa]
        mov [bp - 0x22], ax
        cmp ax, strict word 0x14
        jng short .2
        mov word [bp - 0x22], 0x14
.2:
        push word [bp + 0xe]
        push word [bp + 0xc]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        mov [bp - 0x18], ax
        mov word [bp - 0x30], 0x0
        jmp short .6
.3:
        cmp word [bp + 0x12], 0x0
        jz short .4
        les bx, [bp + 0x14]
        mov si, [bp - 0x30]
        mov byte [es:bx + si], 0x0
.4:
        mov bx, [bp - 0x30]
        shl bx, byte 0x2
        les si, [bp + 0x6]
        push word [es:bx + si + 0x2]
        push word [es:bx + si]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        mov [bp - 0x10], ax
        cmp ax, [bp - 0x18]
        jng short .5
        mov [bp - 0x18], ax
.5:
        inc word [bp - 0x30]
.6:
        mov ax, [bp + 0xa]
        cmp [bp - 0x30], ax
        jl short .3
        mov ax, [bp - 0x10]
        add word [bp - 0x18], 0x9
        cmp [bp - 0x18], ax
        jnl short .7
        mov [bp - 0x18], ax
.7:
        push word [bp + 0xe]
        push word [bp + 0xc]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        mov [bp - 0x10], ax
        les bx, [FontPtr]
        mov ax, [es:bx + 0xe]
        inc ax
        inc ax
        imul word [bp - 0x22]
        add ax, strict word 0x4
        mov [bp - 0x1e], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x130
        sub ax, [bp - 0x18]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x2a], ax
        mov ax, 0xb0
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x2e], ax
        mov dx, [bp - 0x18]
        add dx, 0x10
        mov [bp - 0x24], dx
        add cx, 0x18
        mov [bp - 0x28], cx
        mov cx, [bp - 0x2a]
        add cx, 0x8
        mov [bp - 0x20], cx
        add ax, strict word 0x10
        mov [bp - 0x26], ax
        mov ax, [bp - 0x22]
        cmp [bp + 0xa], ax
        jg short .8
        jmp near .9
.8:
        sub cx, 0xa
        mov [bp - 0x20], cx
        mov cx, [bp - 0x2a]
        sub cx, 0xa
        mov [bp - 0x2a], cx
        mov word [bp - 0x6], 0xffff
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov es, [ListDialogDataSeg]
        mov [es:0x0], dx
        mov dx, [bp - 0x2e]
        mov [es:0x2], dx
        mov word [es:0x4], 0xa
        mov bx, [bp - 0x28]
        mov [es:0x6], bx
        push word [bp + 0xa]
        push ax
        push es
        push strict word 0x0
        db 0x8B, 0xF1                           ; insn: mov si, cx
        push cs
        call ScrollBarInit
        add sp, 0x8
        mov es, [ListDialogDataSeg]
        mov word [es:0x10], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        div word [es:0x14]
        mov [es:0xa], ax
        push word [bp - 0x28]
        mov ax, [bp - 0x24]
        add ax, strict word 0xa
        push ax
        push word [bp - 0x2e]
        push si
        push cs
        call SaveUnderBox
        add sp, 0x8
        push word 0x35ec                        ; segment of the list dialog data far data
        push strict word 0x0
        push cs
        call DrawScrollBar
        add sp, 0x4
        jmp short .10
.9:
        push word [bp - 0x28]
        push dx
        push word [bp - 0x2e]
        push word [bp - 0x2a]
        push cs
        call SaveUnderBox
        add sp, 0x8
.10:
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [bp - 0x28]
        push word [bp - 0x24]
        push word [bp - 0x2e]
        push word [bp - 0x2a]
        push cs
        call DrawBevelBox
        add sp, 0xe
        push word [ItemSelectColor]
        push word [ItemTextColor]
        call 0x0D39:SetTextColors
        add sp, 0x4
        push word [bp + 0xe]
        push word [bp + 0xc]
        mov ax, [bp - 0x2e]
        add ax, strict word 0x6
        push ax
        mov ax, [bp - 0x24]
        sub ax, [bp - 0x10]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [bp - 0x2a]
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        push word [DialogLightColor]
        push word [DialogDarkColor]
        push word [ItemSelectColor]
        push word [bp - 0x1e]
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        push cs
        call DrawBevelBox
        add sp, 0xe
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp - 0x22]
        push word [bp - 0x1c]
        push word [bp - 0x4]
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call DrawListRows
        add sp, 0x18
        les bx, [DialogData]
        mov ax, [es:bx + 0x2]
        inc ax
        mov cx, [es:bx]
        inc cx
        imul cx
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x2c], ax
        push 0x0
        cwd
        push dx
        push ax
        push word 0x9fe
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0xc]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0xc]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0xc]
        mov [es:bx + 0x2], ax
        lea ax, [bp - 0x1a]
        push ax
        lea cx, [bp - 0x16]
        push cx
        lea dx, [bp - 0x30]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x1a]
        mov [bp - 0xe], ax
        push ax
        mov ax, [bp - 0x16]
        mov [bp - 0x8], ax
        push ax
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x1a]
        push word [bp - 0x16]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
        mov word [bp - 0x14], 0x0
.11:
        mov word [bp - 0x32], 0x0
.12:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        lea cx, [bp - 0xe]
        push cx
        lea cx, [bp - 0x8]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x32], ax
.13:
        cmp word [bp - 0x2], 0x0
        jz short .14
        test byte [bp - 0x32], 0x2
        jz short .12
.14:
        cmp word [bp - 0x32], 0x0
        jnz short .16
        mov ax, [bp - 0x16]
        cmp [bp - 0x8], ax
        jnz short .15
        mov ax, [bp - 0x1a]
        cmp [bp - 0xe], ax
        jnz short .15
        jmp near .26
.15:
        push word [bp - 0x1a]
        push word [bp - 0x16]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        jmp near .25
        db 0x90
.16:
        push word [bp - 0x1a]
        push word [bp - 0x16]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        test byte [bp - 0x32], 0x2
        jnz short .17
        jmp near .24
.17:
        push word [bp - 0x22]
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        push word [bp - 0xe]
        push word [bp - 0x8]
        push cs
        call ListHitTest
        add sp, 0xc
        mov [bp - 0x30], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnl short .18
        jmp near .22
.18:
        mov ax, [bp - 0x1c]
        mov [bp - 0x12], ax
        mov ax, [bp - 0x30]
        add ax, [bp - 0x4]
        mov [bp - 0x1c], ax
        cmp word [bp + 0x12], 0x0
        jz short .20
        cmp ax, [bp - 0x12]
        jnz short .19
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        les si, [bp + 0x14]
        cmp byte [es:bx + si], 0x0
        jnz short .20
.19:
        les bx, [bp + 0x14]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        not byte [es:bx + si]
.20:
        cmp word [bp - 0x12], 0x0
        jl short .21
        mov ax, [bp - 0x4]
        cmp [bp - 0x12], ax
        jl short .21
        add ax, [bp - 0x22]
        cmp ax, [bp - 0x12]
        jng short .21
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp - 0x1c]
        push word [bp - 0x12]
        push word [bp - 0x4]
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        mov bx, [bp - 0x12]
        shl bx, byte 0x2
        les si, [bp + 0x6]
        push word [es:bx + si + 0x2]
        push word [es:bx + si]
        push cs
        call DrawListRow
        add sp, 0x18
.21:
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp - 0x1c]
        push word [bp - 0x1c]
        push word [bp - 0x4]
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        mov bx, [bp - 0x1c]
        shl bx, byte 0x2
        les si, [bp + 0x6]
        push word [es:bx + si + 0x2]
        push word [es:bx + si]
        push cs
        call DrawListRow
        add sp, 0x18
.22:
        mov ax, [bp - 0x12]
        cmp [bp - 0x1c], ax
        jnz short .24
        cmp word [bp + 0x12], 0x0
        jz short .23
        les bx, [bp + 0x14]
        mov si, [bp - 0x1c]
        cmp byte [es:bx + si], 0x0
        jz short .24
.23:
        mov word [bp - 0x14], 0x1
.24:
        cmp word [bp - 0x6], 0x0
        jz short .25
        push word [bp - 0x32]
        push word [bp - 0xe]
        push word [bp - 0x8]
        push 0x1
        push word 0x35ec                        ; segment of the list dialog data far data
        push strict word 0x0
        push cs
        call ScrollBarDrag
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .25
        mov ax, [bp - 0x4]
        mov es, [ListDialogDataSeg]
        cmp [es:0x10], ax
        jz short .25
        mov ax, [es:0x10]
        mov [bp - 0x4], ax
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp - 0x22]
        push word [bp - 0x1c]
        push ax
        push word [bp - 0x18]
        push word [bp - 0x26]
        push word [bp - 0x20]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call DrawListRows
        add sp, 0x18
.25:
        push word [bp - 0xe]
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x8]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x8]
        mov [bp - 0x16], ax
        mov ax, [bp - 0xe]
        mov [bp - 0x1a], ax
.26:
        cmp word [bp - 0x14], 0x0
        jnz short .27
        jmp near .11
.27:
        push ax
        push word [bp - 0x16]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push cs
        call RestoreUnderBox
        mov ax, [bp - 0x1c]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; GrowToTextWidth                                             0D90:0A12  94 PC
; Widens a box to a string's width and adds a line height.
;-----------------------------------------------------------------------------
GrowToTextWidth:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp [di], si
        jnl short .1
        mov [di], si
.1:
        mov ax, [bp + 0xe]
        mov bx, [bp + 0xc]
        add [bx], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SetDialogColors                                             0D90:0A3C  94 PC
; The five dialog colours.
;-----------------------------------------------------------------------------
SetDialogColors:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov [DialogBackColor], ax
        mov ax, [bp + 0x8]
        mov [DialogLightColor], ax
        mov ax, [bp + 0xa]
        mov [DialogDarkColor], ax
        mov ax, [bp + 0xc]
        mov [ItemTextColor], ax
        mov ax, [bp + 0xe]
        mov [ItemSelectColor], ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; HiliteButton                                                0D90:0A60  94 PC
; Redraws the old and the new button.
;-----------------------------------------------------------------------------
HiliteButton:
        enter 0x6, 0x0
        push di
        push si
        mov word [bp - 0x2], 0xffff
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [bp + 0xa], di
        jg short .1
        jmp near .7
.1:
        db 0x2B, 0xF6                           ; insn: sub si, si
.2:
        mov ax, [bp + 0xc]
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bp - 0x4], es
        cmp [es:bx], ax
        jg short .4
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cmp ax, [bp + 0xc]
        jng short .4
        mov ax, [bp + 0xe]
        cmp [es:bx + 0x2], ax
        jg short .4
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cmp ax, [bp + 0xe]
        jng short .4
        cmp word [es:bx + 0x8], 0x0
        jnz short .3
        test byte [bp + 0x10], 0x1
        jz short .3
        mov word [es:bx + 0x8], 0xffff
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
        push cs
        call DrawButton
        add sp, 0x4
.3:
        test byte [bp + 0x10], 0x2
        jz short .6
        mov [bp - 0x2], di
        les bx, [bp + 0x6]
        mov word [es:bx + si + 0x8], 0x0
        jmp short .5
        db 0x90
.4:
        mov es, [bp - 0x4]
        cmp word [es:bx + 0x8], 0x0
        jz short .6
        mov word [es:bx + 0x8], 0x0
.5:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
        push cs
        call DrawButton
        add sp, 0x4
.6:
        add si, 0x10
        inc di
        cmp [bp + 0xa], di
        jng short .7
        jmp near .2
.7:
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawButtons                                                 0D90:0B16  94 PC
; Every button of a message box.
;-----------------------------------------------------------------------------
DrawButtons:
        enter 0x2, 0x0
        push di
        push si
        mov dx, [bp + 0xa]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jng short .2
        db 0x2B, 0xF6                           ; insn: sub si, si
        db 0x8B, 0xFA                           ; insn: mov di, dx
.1:
        les bx, [bp + 0x6]
        mov word [es:bx + si + 0x8], 0x0
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
        push cs
        call DrawButton
        add sp, 0x4
        add si, 0x10
        dec di
        jnz short .1
.2:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawButton                                                  0D90:0B4C  94 PC
; One button: bevel box and centred label.
;-----------------------------------------------------------------------------
DrawButton:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        cmp word [es:si + 0x8], 0x0
        jz short .1
        mov ax, [DialogDarkColor]
        xor [DialogLightColor], ax
        mov ax, [DialogLightColor]
        xor [DialogDarkColor], ax
        xor ax, [DialogDarkColor]
        mov [DialogLightColor], ax
.1:
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [es:si + 0x6]
        push word [es:si + 0x4]
        push word [es:si + 0x2]
        push word [es:si]
        mov di, es
        push cs
        call DrawBevelBox
        add sp, 0xe
        mov es, di
        cmp word [es:si + 0x8], 0x0
        jz short .2
        mov ax, [DialogDarkColor]
        xor [DialogLightColor], ax
        mov ax, [DialogLightColor]
        xor [DialogDarkColor], ax
        xor ax, [DialogDarkColor]
        mov [DialogLightColor], ax
.2:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0xe]
        or ax, [es:si + 0xc]
        jz short .3
        push word [es:si + 0xe]
        push word [es:si + 0xc]
        mov ax, [es:si + 0x6]
        mov cx, es
        les bx, [FontPtr]
        sub ax, [es:bx + 0xe]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov es, cx
        add ax, [es:si + 0x2]
        push ax
        push word [es:si + 0xe]
        push word [es:si + 0xc]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x0D39:TextWidthFar
        add sp, 0x4
        mov es, di
        sub ax, [es:si + 0x4]
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        add ax, [es:si]
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
.3:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ScrollBarInit                                               0D90:0C14  94 PC
; Scroll bar position, size and thumb length from the item counts.
;-----------------------------------------------------------------------------
ScrollBarInit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, [bp + 0x6]
        mov ax, [bp + 0xc]
        mov es, [bp + 0x8]
        mov [es:si + 0x14], ax
        mov ax, [bp + 0xa]
        mov [es:si + 0x12], ax
        mov word [es:si + 0x10], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x8], ax
        mov [es:si + 0xa], ax
        mov ax, [es:si + 0x4]
        sub ax, strict word 0x4
        mov [es:si + 0xc], ax
        push 0x0
        push word [es:si + 0x14]
        push 0x0
        push word [es:si + 0x12]
        mov ax, [es:si + 0x6]
        sub ax, strict word 0x4
        cwd
        push dx
        push ax
        mov di, es
        call 0x0000:__aFlmul
        push dx
        push ax
        call 0x0000:__aFldiv
        mov es, di
        mov [es:si + 0xe], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawScrollBar                                               0D90:0C76  94 PC
; Bar and thumb.
;-----------------------------------------------------------------------------
DrawScrollBar:
        enter 0x6, 0x0
        push di
        push si
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov di, [es:si]
        mov ax, [es:si + 0x2]
        mov [bp - 0x2], ax
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [es:si + 0x6]
        push word [es:si + 0x4]
        push ax
        push word [es:si]
        mov [bp - 0x6], si
        mov [bp - 0x4], es
        push cs
        call DrawBevelBox
        add sp, 0xe
        les bx, [bp - 0x6]
        cmp word [es:bx + 0x16], 0x0
        jz short .1
        mov ax, [DialogDarkColor]
        xor [DialogLightColor], ax
        mov ax, [DialogLightColor]
        xor [DialogDarkColor], ax
        xor ax, [DialogDarkColor]
        mov [DialogLightColor], ax
.1:
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x8]
        inc ax
        inc ax
        db 0x03, 0xF8                           ; insn: add di, ax
        mov ax, [es:si + 0xa]
        inc ax
        inc ax
        add [bp - 0x2], ax
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [es:si + 0xe]
        push word [es:si + 0xc]
        push word [bp - 0x2]
        push di
        mov di, es
        push cs
        call DrawBevelBox
        add sp, 0xe
        mov es, di
        cmp word [es:si + 0x16], 0x0
        jz short .2
        mov ax, [DialogDarkColor]
        xor [DialogLightColor], ax
        mov ax, [DialogLightColor]
        xor [DialogDarkColor], ax
        xor ax, [DialogDarkColor]
        mov [DialogLightColor], ax
.2:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ScrollBarDrag                                               0D90:0D28  94 PC
; Moves the thumb with the mouse and updates the first item.
;-----------------------------------------------------------------------------
ScrollBarDrag:
        enter 0xe, 0x0
        push di
        push si
        mov word [bp - 0x4], 0xffff
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [bp + 0xa], di
        jg short .1
        jmp near .14
.1:
        db 0x2B, 0xF6                           ; insn: sub si, si
.2:
        mov ax, [bp + 0xc]
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bp - 0x6], es
        cmp [es:bx], ax
        jng short .3
        jmp near .11
.3:
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        cmp ax, [bp + 0xc]
        jg short .4
        jmp near .11
.4:
        mov ax, [bp + 0xe]
        cmp [es:bx + 0x2], ax
        jng short .5
        jmp near .11
.5:
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        cmp ax, [bp + 0xe]
        jg short .6
        jmp near .11
.6:
        mov cx, [es:bx + 0xa]
        test byte [bp + 0x10], 0x1
        jz short .7
        cmp word [es:bx + 0x16], 0x0
        jnz short .7
        mov word [es:bx + 0x16], 0xffff
        mov cx, 0xffff
.7:
        mov [bp - 0x2], cx
        test byte [bp + 0x10], 0x2
        jz short .8
        les bx, [bp + 0x6]
        mov word [es:bx + si + 0x16], 0x0
        mov word [bp - 0x2], 0xffff
.8:
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov ax, [es:bx + 0xe]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, [bp + 0xe]
        neg ax
        sub ax, [es:bx + 0x2]
        mov [es:bx + 0xa], ax
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bp - 0x6], es
        cmp word [es:bx + 0xa], 0x0
        jnl short .9
        mov word [es:bx + 0xa], 0x0
        jmp short .10
.9:
        mov es, [bp - 0x6]
        mov ax, [es:bx + 0x6]
        sub ax, [es:bx + 0xe]
        sub ax, strict word 0x4
        cmp ax, [es:bx + 0xa]
        jnl short .10
        mov [es:bx + 0xa], ax
.10:
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov ax, [es:bx + 0x6]
        sub ax, strict word 0x4
        cwd
        push dx
        push ax
        mov ax, [es:bx + 0xa]
        cwd
        push dx
        push ax
        push 0x0
        push word [es:bx + 0x14]
        mov [bp - 0xe], bx
        mov [bp - 0xc], es
        call 0x0000:__aFlmul
        push dx
        push ax
        call 0x0000:__aFldiv
        les bx, [bp - 0xe]
        mov [es:bx + 0x10], ax
        mov [bp - 0x4], di
        mov ax, [bp - 0x2]
        les bx, [bp + 0x6]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bp - 0x6], es
        cmp [es:bx + 0xa], ax
        jz short .13
        push es
        push bx
        jmp short .12
        db 0x90
.11:
        mov es, [bp - 0x6]
        cmp word [es:bx + 0x16], 0x0
        jz short .13
        mov word [es:bx + 0x16], 0x0
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
.12:
        push cs
        call DrawScrollBar
        add sp, 0x4
.13:
        add si, 0x18
        inc di
        cmp [bp + 0xa], di
        jng short .14
        jmp near .2
.14:
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SaveUnderBox                                                0D90:0E7A  94 PC
; Allocates a block and saves the screen under a box (GetBlock).
;-----------------------------------------------------------------------------
SaveUnderBox:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        push 0x0
        mov ax, [bp + 0xc]
        add ax, strict word 0x4
        mov cx, [bp + 0xa]
        add cx, 0x8
        imul cx
        add ax, strict word 0x12
        adc dx, 0x0
        push dx
        push ax
        push word 0xa06
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [SaveUnderOff], ax
        mov [SaveUnderSeg], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [SaveUnderOff]
        jz short .1
        mov ax, [SaveUnderOff]
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
        mov ax, [bp + 0xa]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        inc ax
        inc ax
        mov bx, [SaveUnderOff]
        mov [es:bx], ax
        mov ax, [bp + 0xc]
        add ax, strict word 0x4
        les bx, [SaveUnderOff]
        mov [es:bx + 0x2], ax
        mov ax, [bp + 0x8]
        mov [BoxSaveY], ax
        push ax
        mov ax, [bp + 0x6]
        cwd
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, byte 0x2
        db 0x33, 0xC2                           ; insn: xor ax, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        shl ax, byte 0x2
        mov [BoxSaveX], ax
        push ax
        push word [SaveUnderSeg]
        push word [SaveUnderOff]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
.1:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; RestoreUnderBox                                             0D90:0F22  94 PC
; Puts the saved screen back and frees the block.
;-----------------------------------------------------------------------------
RestoreUnderBox:
        mov ax, [SaveUnderSeg]
        or ax, [SaveUnderOff]
        jz short .1
        push word [BoxSaveY]
        push word [BoxSaveX]
        push word [SaveUnderSeg]
        push word [SaveUnderOff]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [SaveUnderSeg]
        push word [SaveUnderOff]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [SaveUnderSeg], ax
        mov [SaveUnderOff], ax
.1:
        retf

;-----------------------------------------------------------------------------
; GrowToItemBox                                               0D90:0F5C  94 PC
; Widens and heightens a box to fit an item rectangle.
;-----------------------------------------------------------------------------
GrowToItemBox:
        enter 0x8, 0x0
        push di
        les bx, [bp + 0x6]
        test byte [es:bx + 0xa], 0x1
        jz short .1
        mov di, [bp + 0xa]
        mov ax, [es:bx + 0x4]
        add ax, [es:bx]
        add ax, strict word 0x8
        mov [bp - 0x2], ax
        jmp short .2
        db 0x90
.1:
        mov di, [bp + 0xa]
        mov ax, [es:bx + 0x4]
        sub ax, [es:bx]
        add ax, strict word 0x8
        mov [bp - 0x4], ax
.2:
        cmp ax, [di]
        jng short .3
        mov [di], ax
.3:
        test byte [es:bx + 0xa], 0x4
        jz short .4
        mov di, [bp + 0xc]
        mov ax, [es:bx + 0x2]
        add ax, [es:bx + 0x6]
        add ax, strict word 0x8
        mov [bp - 0x6], ax
        jmp short .5
.4:
        mov di, [bp + 0xc]
        mov ax, [es:bx + 0x6]
        sub ax, [es:bx + 0x2]
        add ax, strict word 0x8
        mov [bp - 0x8], ax
.5:
        cmp ax, [di]
        jng short .6
        mov [di], ax
.6:
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MessageBox                                                  0D90:0FC8  94 PC
; Box with text lines and buttons; returns the button chosen.
;-----------------------------------------------------------------------------
MessageBox:
        enter 0x1e, 0x0
        push di
        push si
        mov di, [bp + 0xe]
        call 0x0FEF:UseCurrentPage
        push cs
        call RestoreUnderBox
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x1a], ax
        mov [bp - 0x18], ax
        les bx, [FontPtr]
        mov ax, [es:bx + 0xe]
        inc ax
        inc ax
        mov [bp - 0x16], ax
        mov word [bp - 0x10], 0x0
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .2
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x4], dx
        db 0x8B, 0xCF                           ; insn: mov cx, di
        mov [bp - 0x2], cx
.1:
        push word [bp - 0x16]
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x1a]
        push ax
        mov es, [bp - 0x4]
        push word [es:si + 0x2]
        push word [es:si]
        push cs
        call GrowToTextWidth
        add sp, 0xa
        add si, 0x4
        mov ax, [bp - 0x4]
        dec di
        jnz short .1
.2:
        add word [bp - 0x1a], 0x10
        add word [bp - 0x18], 0x10
        mov word [bp - 0x10], 0x0
        cmp word [bp + 0x14], 0x0
        jng short .4
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov dx, [bp + 0x14]
        mov [bp - 0x2], dx
        db 0x8B, 0xFA                           ; insn: mov di, dx
.3:
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x1a]
        push ax
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        db 0x03, 0xC6                           ; insn: add ax, si
        push dx
        push ax
        push cs
        call GrowToItemBox
        add sp, 0x8
        add si, 0x10
        dec di
        jnz short .3
.4:
        cmp word [bp + 0x6], 0x0
        jnl short .5
        mov ax, 0x140
        sub ax, [bp - 0x1a]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xF8                           ; insn: mov di, ax
        jmp short .6
.5:
        mov di, [bp + 0x6]
.6:
        cmp word [bp + 0x8], 0x0
        jnl short .7
        mov ax, 0xc8
        sub ax, [bp - 0x18]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .8
.7:
        mov si, [bp + 0x8]
.8:
        push word [bp - 0x18]
        push word [bp - 0x1a]
        push si
        push di
        push cs
        call SaveUnderBox
        add sp, 0x8
        push word [DialogDarkColor]
        push word [DialogLightColor]
        push word [DialogBackColor]
        push word [bp - 0x18]
        push word [bp - 0x1a]
        push si
        push di
        push cs
        call DrawBevelBox
        add sp, 0xe
        lea ax, [si + 0x8]
        mov [bp - 0x8], ax
        push word [ItemSelectColor]
        push word [ItemTextColor]
        call 0x0D39:SetTextColors
        add sp, 0x4
        mov word [bp - 0x10], 0x0
        mov [bp - 0x14], si
        mov [bp - 0x12], di
        cmp word [bp + 0xe], 0x0
        jng short .10
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0xa], dx
        mov ax, [bp + 0xe]
        mov [bp - 0xe], ax
        mov [bp - 0xc], cx
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov di, [bp - 0x8]
.9:
        mov es, [bp - 0xa]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x0D39:TextWidthFar
        add sp, 0x4
        sub ax, [bp - 0x1a]
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        mov [bp - 0x2], ax
        mov es, [bp - 0xa]
        push word [es:si + 0x2]
        push word [es:si]
        push di
        add ax, [bp - 0x12]
        push ax
        call 0x0D39:DrawShadowText
        add sp, 0x8
        add di, [bp - 0x16]
        add si, 0x4
        mov ax, [bp - 0xa]
        dec word [bp - 0xe]
        jnz short .9
.10:
        mov word [bp - 0x10], 0x0
        mov di, [bp + 0x14]
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .16
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov [bp - 0x2], di
        mov di, [bp - 0x12]
        mov cx, [bp - 0x14]
.11:
        les si, [bp + 0x10]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov [bp - 0x1e], si
        mov [bp - 0x1c], es
        test byte [es:si + 0xa], 0x1
        jz short .12
        add [es:si], di
        jmp short .13
        db 0x90
.12:
        mov ax, [bp - 0x1a]
        mov es, [bp - 0x1c]
        sub ax, [es:si + 0x4]
        db 0x03, 0xC7                           ; insn: add ax, di
        add [es:si], ax
.13:
        les si, [bp + 0x10]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov [bp - 0x1e], si
        mov [bp - 0x1c], es
        test byte [es:si + 0xa], 0x4
        jz short .14
        add [es:si + 0x2], cx
        jmp short .15
        db 0x90
.14:
        mov ax, [bp - 0x18]
        mov es, [bp - 0x1c]
        sub ax, [es:si + 0x6]
        db 0x03, 0xC1                           ; insn: add ax, cx
        add [es:si + 0x2], ax
.15:
        add bx, 0x10
        dec word [bp - 0x2]
        jnz short .11
        mov di, [bp + 0x14]
.16:
        push di
        push word [bp + 0x12]
        push word [bp + 0x10]
        push cs
        call DrawButtons
        add sp, 0x6
        call 0x0F99:FlushInputEvents
        cmp word [bp + 0x1a], 0x0
        jz short .17
        push di
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp + 0x18]
        push word [bp + 0x16]
        push cs
        call MessageBoxLoop
        add sp, 0xa
        mov [bp - 0x4], ax
        push cs
        call RestoreUnderBox
.17:
        mov word [bp - 0x10], 0x0
        db 0x0B, 0xFF                           ; insn: or di, di
        jng short .23
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        mov [bp - 0x2], di
        mov cx, [bp - 0x14]
        mov di, [bp - 0x12]
.18:
        les si, [bp + 0x10]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov [bp - 0x1e], si
        mov [bp - 0x1c], es
        test byte [es:si + 0xa], 0x1
        jz short .19
        sub [es:si], di
        jmp short .20
.19:
        mov es, [bp - 0x1c]
        mov ax, [es:si + 0x4]
        sub ax, [bp - 0x1a]
        db 0x2B, 0xC7                           ; insn: sub ax, di
        add [es:si], ax
.20:
        les si, [bp + 0x10]
        db 0x03, 0xF3                           ; insn: add si, bx
        mov [bp - 0x1e], si
        mov [bp - 0x1c], es
        test byte [es:si + 0xa], 0x4
        jz short .21
        sub [es:si + 0x2], cx
        jmp short .22
        db 0x90
.21:
        mov es, [bp - 0x1c]
        mov ax, [es:si + 0x6]
        sub ax, [bp - 0x18]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add [es:si + 0x2], ax
.22:
        add bx, 0x10
        dec word [bp - 0x2]
        jnz short .18
.23:
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MessageBoxLoop                                              0D90:1260  94 PC
; Input loop of MessageBox (mouse, keys, highlight).
;-----------------------------------------------------------------------------
MessageBoxLoop:
        enter 0x18, 0x0
        push di
        push si
        push 0x0
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
        push word 0xa0b
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x18]
        mov cx, 0x9
        rep movsw
        pop ds
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        les bx, [bp - 0x18]
        mov [es:bx], ax
        les si, [DialogData]
        mov ax, [es:si + 0x2]
        inc ax
        les bx, [bp - 0x18]
        mov [es:bx + 0x2], ax
        mov word [bp - 0x14], 0x0
        mov si, [bp + 0x6]
        mov ax, [si]
        mov [bp - 0xc], ax
        mov [bp - 0x8], ax
        mov si, [bp + 0x8]
        mov ax, [si]
        mov [bp - 0xe], ax
        mov [bp - 0xa], ax
        push ax
        push word [bp - 0xc]
        call 0x03A3:MouseMove
        add sp, 0x4
        push word [bp - 0xe]
        push word [bp - 0xc]
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0xc]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
.1:
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        call 0x0F99:FlushInputEvents
        mov word [bp - 0x6], 0x0
        mov si, [bp - 0xc]
        mov di, [bp - 0xe]
.2:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        jmp near .12
.3:
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0x8]
        push ax
        push word [bp - 0x2]
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x4], ax
        test al, 0x2f
        jnz short .4
        jmp near .10
.4:
        push di
        push si
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        cmp word [bp + 0xe], 0x0
        jng short .6
        test byte [bp - 0x4], 0x4
        jz short .5
        mov ax, 0xffff
        mov [bp - 0x14], ax
        mov [bp - 0x6], ax
        jmp short .9
        db 0x90
.5:
        push word [bp - 0x4]
        push word [bp - 0xa]
        push word [bp - 0x8]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push cs
        call HiliteButton
        add sp, 0xc
        mov [bp - 0x14], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jl short .9
        jmp short .8
.6:
        mov dx, [bp - 0x4]
        test dl, 0x4
        jz short .7
        mov word [bp - 0x14], 0x4
        jmp short .8
        db 0x90
.7:
        test dl, 0x2a
        jz short .9
.8:
        mov word [bp - 0x6], 0xffff
.9:
        push di
        push si
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push di
        push si
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
.10:
        cmp [bp - 0x8], si
        jnz short .11
        cmp [bp - 0xa], di
        jz short .12
.11:
        push di
        push si
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0xa]
        push word [bp - 0x8]
        push word [bp - 0x16]
        push word [bp - 0x18]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xa]
        push word [bp - 0x8]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov si, [bp - 0x8]
        mov di, [bp - 0xa]
.12:
        cmp word [bp - 0x6], 0x0
        jnz short .13
        jmp near .2
.13:
        mov [bp - 0xe], di
        mov [bp - 0xc], si
.14:
        push 0x1
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        push 0x1c
        call 0x03A3:KeyDown
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        mov si, [bp - 0x18]
        call 0x0F99:FlushInputEvents
        push word [bp - 0xe]
        push word [bp - 0xc]
        mov ax, [bp - 0x16]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        call 0x0F99:FlushInputEvents
        push word [bp - 0xa]
        push word [bp - 0x8]
        call 0x03A3:MouseMove
        add sp, 0x4
        mov ax, [bp - 0x8]
        mov bx, [bp + 0x6]
        mov [bx], ax
        mov ax, [bp - 0xa]
        mov bx, [bp + 0x8]
        mov [bx], ax
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [bp - 0x14]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MessageBoxReset                                             0D90:14B8  94 PC
; Sets the last button to -1.
;-----------------------------------------------------------------------------
MessageBoxReset:
        mov word [MessageBoxSel], 0xffff
        db 0x2B, 0xC0                           ; insn: sub ax, ax
