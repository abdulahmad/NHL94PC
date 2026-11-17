; Loads raw files and their headers into memory blocks.

;-----------------------------------------------------------------------------
; NullFar9                                                    149D:0000  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar9:
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRawHeader                                               149D:0002  94 PC
; LoadRawHeaderMode with mode 1.
;-----------------------------------------------------------------------------
LoadRawHeader:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x149D:LoadRawHeaderMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRawHeader0                                              149D:0014  94 PC
; LoadRawHeaderMode with mode 0.
;-----------------------------------------------------------------------------
LoadRawHeader0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x0
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x149D:LoadRawHeaderMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRawHeaderMode                                           149D:0026  94 PC
; LoadRawMode, then returns the first dword of the data.
;-----------------------------------------------------------------------------
LoadRawHeaderMode:
        enter 0x4, 0x0
        push si
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x149D:LoadRawMode
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .1
        mov es, [bp - 0x2]
        mov ax, [es:si]
        mov dx, [es:si + 0x2]
        pop si
        leave
        retf
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRaw                                                     149D:0058  94 PC
; LoadRawMode with mode 1.
;-----------------------------------------------------------------------------
LoadRaw:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x149D:LoadRawMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRaw0                                                    149D:006A  94 PC
; LoadRawMode with mode 0.
;-----------------------------------------------------------------------------
LoadRaw0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x0
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x149D:LoadRawMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadRawMode                                                 149D:007C  94 PC
; Reads an unpacked file (.esh, .vsh and others) into a heap record, EMS
; aware.
;-----------------------------------------------------------------------------
LoadRawMode:
        enter 0x16, 0x0
        push di
        push si
        test byte [bp + 0x8], 0x80
        jnz short .1
        push word [bp + 0x6]
        call 0x06E1:CopyByName
        pop bx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xa], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .1
        db 0xE9, 0x13, 0x01                     ; insn: jmp 0x1b0
.1:
        push word [bp + 0xa]
        lea ax, [bp - 0x12]
        push ax
        lea cx, [bp - 0x16]
        push cx
        lea cx, [bp - 0xe]
        push cx
        push word [bp + 0x6]
        call 0x03A3:FileOpenArg
        add sp, 0xa
        mov ax, [bp - 0x10]
        or ax, [bp - 0x12]
        jnz short .3
.2:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        db 0xE9, 0xEE, 0x00                     ; insn: jmp 0x1b3
.3:
        mov si, [bp + 0xa]
        push si
        push word [bp + 0x8]
        push word [bp - 0x10]
        push word [bp - 0x12]
        push word [bp + 0x6]
        call 0x06E1:InsertRec
        add sp, 0xa
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .4
        push word [bp - 0xe]
        call 0x03A3:FileClose
        pop bx
        jmp short .2
.4:
        test byte [bp + 0x8], 0x80
        jnz short .5
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push si
        mov es, [bp - 0xa]
        push word [es:di + 0x2]
        push word [es:di]
        push word [bp - 0x10]
        push word [bp - 0x12]
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [bp - 0xe]
        call 0x03A3:ReadAtArg
        add sp, 0x10
        jmp near .9
.5:
        db 0x8B, 0xF8                           ; insn: mov di, ax
        push word [bp - 0xa]
        push di
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
.6:
        cmp word [bp - 0x10], 0x0
        jl short .9
        jg short .7
        cmp word [bp - 0x12], 0x0
        jz short .9
.7:
        mov ax, 0xc000
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        sub [bp - 0x12], ax
        sbb [bp - 0x10], dx
        cmp [bp - 0x10], dx
        jnl short .8
        mov ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        add ah, 0xc0
        adc dx, 0x0
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
.8:
        push si
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word [bp - 0x6]
        push word [bp - 0x8]
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [bp - 0xe]
        call 0x03A3:ReadAtArg
        add sp, 0x10
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        add [bp - 0x16], ax
        adc [bp - 0x14], dx
        add [bp - 0x4], ax
        adc [bp - 0x2], dx
        jmp short .6
.9:
        push word [bp - 0xe]
        call 0x03A3:FileClose
        pop bx
        db 0x8B, 0xC7                           ; insn: mov ax, di
