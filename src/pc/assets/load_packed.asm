; Loads packed (compressed) files and their headers. The first bytes finish LoadRawMode.
;-----------------------------------------------------------------------------
; LoadRawModeTail                                             14B8:0000  94 PC
; End of LoadRawMode, which starts in the file before.
;-----------------------------------------------------------------------------
LoadRawModeTail:
        mov dx, [bp - 0xa]
.1:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadPackedHeader                                            14B8:0008  94 PC
; LoadPackedHeaderMode with mode 1.
;-----------------------------------------------------------------------------
LoadPackedHeader:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x14B8:LoadPackedHeaderMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPackedHeader0                                           14B8:001A  94 PC
; LoadPackedHeaderMode with mode 0.
;-----------------------------------------------------------------------------
LoadPackedHeader0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x0
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x14B8:LoadPackedHeaderMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPackedHeaderMode                                        14B8:002C  94 PC
; LoadPackedMode, then returns the first dword of the data.
;-----------------------------------------------------------------------------
LoadPackedHeaderMode:
        enter 0x4, 0x0
        push si
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x14B8:LoadPackedMode
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
; LoadPacked                                                  14B8:005E  94 PC
; LoadPackedMode with mode 1.
;-----------------------------------------------------------------------------
LoadPacked:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x14B8:LoadPackedMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPacked0                                                 14B8:0070  94 PC
; LoadPackedMode with mode 0.
;-----------------------------------------------------------------------------
LoadPacked0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x0
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x14B8:LoadPackedMode
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPackedMode                                              14B8:0082  94 PC
; Reads and unpacks a packed file (.qns, .pns, .qvs, .pvs, .qes, .pes).
;-----------------------------------------------------------------------------
LoadPackedMode:
        enter 0x1a, 0x0
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
        jmp near .9
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
        jmp near .10
.3:
        mov si, [bp + 0xa]
        push si
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [bp - 0xe]
        call 0x14B8:ReadPackedSize
        add sp, 0x8
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .5
.4:
        push word [bp - 0xe]
        call 0x03A3:FileClose
        pop bx
        jmp short .2
.5:
        mov dx, [bp - 0x6]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        cmp dx, [bp - 0x10]
        jg short .7
        jl short .6
        cmp ax, [bp - 0x12]
        jnc short .7
.6:
        mov ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
.7:
        push si
        push word [bp + 0x8]
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        add ax, 0x3e8
        adc dx, 0x0
        push dx
        push ax
        push word [bp + 0x6]
        call 0x06E1:InsertRec
        add sp, 0xa
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0xa], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .4
        mov es, [bp - 0xa]
        push word [es:di + 0x2]
        push word [es:di]
        call 0x03A3:FarToLinear
        add sp, 0x4
        sub ax, [bp - 0x12]
        sbb dx, [bp - 0x10]
        add ax, [bp - 0x4]
        adc dx, [bp - 0x2]
        add ax, 0x3e8
        adc dx, 0x0
        call 0x03A3:LinearToFarRegs
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        push word [bp + 0xa]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        push ax
        push si
        push word [bp - 0x10]
        push word [bp - 0x12]
        push word [bp - 0x14]
        push word [bp - 0x16]
        push word [bp - 0xe]
        mov [bp - 0x1a], si
        mov [bp - 0x18], ax
        call 0x03A3:ReadAtArg
        add sp, 0x10
        push word [bp + 0xa]
        mov es, [bp - 0xa]
        push word [es:di + 0x2]
        push word [es:di]
        push word [bp - 0x18]
        push si
        call 0x0838:LoadBlock
        add sp, 0xa
        push word [bp + 0xa]
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0xa]
        push di
        call 0x06E1:ResizeRec
        add sp, 0xa
        push word [bp - 0xe]
        call 0x03A3:FileClose
        pop bx
        test byte [bp + 0x8], 0x80
        jz short .8
        push word [bp - 0xa]
        push di
        call 0x06E1:MovePtr
        add sp, 0x4
.8:
        db 0x8B, 0xC7                           ; insn: mov ax, di
.9:
        mov dx, [bp - 0xa]
.10:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ReadPackedSize                                              14B8:01E0  94 PC
; Reads the 8-byte header and builds the 24-bit unpacked size.
;-----------------------------------------------------------------------------
ReadPackedSize:
        enter 0xc, 0x0
        push word [bp + 0xc]
        lea ax, [bp - 0xc]
        push ss
        push ax
        push 0x0
        push 0x8
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:ReadAtArg
        add sp, 0x10
        db 0x0B, 0xD0                           ; insn: or dx, ax
        db 0x74, 0x2F                           ; insn: jz 0x234
        mov al, [bp - 0xa]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x8
        call 0x0000:__aFlshl
        mov cl, [bp - 0x9]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        adc dx, 0x0
        mov cl, 0x8
        call 0x0000:__aFlshl
        mov cl, [bp - 0x8]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x03, 0xC1                           ; insn: add ax, cx
        adc dx, 0x0
        db 0x89, 0x46
