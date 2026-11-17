; Shade tables: darker and lighter versions of each colour, and merging two remap tables.
        db 0xF2, 0x76
        inc si
CopyBytesFarTail:
        cmp si, 0x10
        db 0x7C, 0xEF                           ; insn: jl 0xfff7
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ShadeColor                                                  160E:000C  94 PC
; Scales one palette entry by the RGB factors, clamps to 3Fh, optional grey.
;-----------------------------------------------------------------------------
ShadeColor:
        enter 0xa, 0x0
        push di
        push si
        mov si, [bp + 0x8]
        imul bx, si, 0x3
        les si, [bp + 0x4]
        mov al, [es:bx + si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, [ShadeFactorR]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x03A3:Mul16k.regs
        mov [ShadeR], ax
        mov es, [bp + 0x6]
        db 0x03, 0xFE                           ; insn: add di, si
        mov al, [es:di + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, [ShadeFactorG]
        mov si, es
        call 0x03A3:Mul16k.regs
        mov [ShadeG], ax
        mov es, si
        lea bx, [di + 0x1]
        mov al, [es:bx + 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov dx, [ShadeFactorB]
        call 0x03A3:Mul16k.regs
        mov [ShadeB], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp word [ShadeGrey], 0x0
        jz short .1
        mov ax, [ShadeG]
        add ax, [ShadeR]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [ShadeG], bx
        mov [ShadeR], bx
.1:
        cmp word [ShadeG], 0x3f
        jng short .2
        mov word [ShadeG], 0x3f
.2:
        cmp word [ShadeR], 0x3f
        jg short .3
        mov di, [ShadeR]
        jmp short .4
.3:
        mov di, 0x3f
.4:
        cmp bx, 0x3f
        jng short .5
        mov bx, 0x3f
.5:
        cmp word [ShadeGrey], 0x0
        jz short .6
        mov ax, [ShadeG]
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x03, 0xC7                           ; insn: add ax, di
        mov cx, 0x3
        cwd
        idiv cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov [ShadeG], bx
        db 0x8B, 0xFB                           ; insn: mov di, bx
.6:
        mov [ShadeR], di
        mov [ShadeB], bx
        mov word [bp - 0x8], 0x270f
        mov ax, [bp + 0x4]
        db 0x8B, 0xD6                           ; insn: mov dx, si
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [ShadeTableSeg], dx
        mov word [bp - 0x6], 0x0
        mov [ShadeTableOff], cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov bx, [bp - 0x6]
        jmp short .12
.7:
        mov es, [PaletteFlagsSeg]
        cmp byte [es:bx + 0x100], 0x0
        jnz short .8
        add si, 0x3
        jmp short .11
.8:
        mov es, [ShadeTableSeg]
        db 0x8B, 0xFE                           ; insn: mov di, si
        inc si
        mov al, [es:di]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [ShadeR]
        neg ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        imul cx
        shl ax, 1
        mov [bp - 0x4], ax
        cmp ax, [bp - 0x8]
        jl short .9
        inc si
        inc si
        jmp short .11
.9:
        db 0x8B, 0xFE                           ; insn: mov di, si
        inc si
        mov al, [es:di]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [ShadeG]
        neg ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        imul cx
        imul ax, ax, 0x3
        add [bp - 0x4], ax
        mov ax, [bp - 0x8]
        cmp [bp - 0x4], ax
        jl short .10
        inc si
        jmp short .11
.10:
        db 0x8B, 0xFE                           ; insn: mov di, si
        inc si
        mov al, [es:di]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        sub ax, [ShadeB]
        neg ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        imul cx
        add [bp - 0x4], ax
        mov ax, [bp - 0x8]
        cmp [bp - 0x4], ax
        jnl short .11
        mov ax, [bp - 0x4]
        mov [bp - 0x8], ax
        mov [bp - 0x9], bl
.11:
        inc bx
.12:
        cmp bx, 0x100
        jnl short .13
        jmp near .7
.13:
        mov [ShadeTableOff], si
        mov al, [bp - 0x9]
        pop si
        pop di
        leave
        ret 0x6
        db 0x90, 0x90

;-----------------------------------------------------------------------------
; BuildShadeTable                                             160E:0180  94 PC
; ShadeColor for every used colour, writes a 256-byte remap table.
;-----------------------------------------------------------------------------
BuildShadeTable:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov ax, [bp + 0x6]
        mov [ShadeFactorR], ax
        mov ax, [bp + 0x8]
        mov [ShadeFactorG], ax
        mov ax, [bp + 0xa]
        mov [ShadeFactorB], ax
        db 0x33, 0xF6                           ; insn: xor si, si
        mov [ShadeGrey], si
        mov di, [bp + 0x10]
        jmp short .3
.1:
        mov es, [PaletteFlagsSeg2]
        db 0x26, 0x80, 0xBC, 0x00, 0x00, 0x00   ; insn: cmp byte [es:si + 0x0], 0x0
        jz short .2
        push si
        push word [bp + 0xe]
        push word [bp + 0xc]
        call ShadeColor
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bx], al
.2:
        inc si
.3:
        cmp si, 0x100
        jl short .1
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; BuildShadeTableEven                                         160E:01CC  94 PC
; BuildShadeTable with one factor for all three channels.
;-----------------------------------------------------------------------------
BuildShadeTableEven:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp + 0x6]
        push word [bp + 0x6]
        call 0x160E:BuildShadeTable
        leave
        retf

;-----------------------------------------------------------------------------
; MergeRemapTables                                            160E:01E8  94 PC
; Combines two remap tables into the global one.
;-----------------------------------------------------------------------------
MergeRemapTables:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        db 0x33, 0xF6                           ; insn: xor si, si
        mov di, [bp + 0xa]
        mov cx, [bp + 0x6]
        jmp short .1
        db 0x8E, 0x46, 0x08, 0x8B, 0xD9, 0x03, 0xDE, 0x26, 0x8A, 0x07, 0x8E, 0x06, 0x0E, 0x8D, 0x26, 0x88
        db 0x84, 0x00, 0x00, 0x8E, 0x46, 0x0C, 0x8B, 0xDF, 0x03, 0xDE, 0x26, 0x8A, 0x07, 0x8E, 0x06, 0x0E
        db 0x8D, 0x26, 0x88, 0x84, 0x00, 0x01, 0x46
.1:
        db 0x81, 0xFE
