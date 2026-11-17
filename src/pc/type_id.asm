; Segment seg004. NineCmp and TypeId look at a short header.
; The first two bytes are retf and nop.

; DGROUP words this segment uses. The bytes live in the near data, not here.

        retf
        nop
; Compare 9 bytes of the far string with the bytes at 402h.
; A difference returns that pointer. A match calls RetOnly and
; returns one past its result.
NineCmp:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, word [bp + 6]
        push 9
        push ds
        push 0x402
        push word [bp + 8]
        push si
        call 0:_fmemchr
        add sp, 0xa
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .1
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, word [bp + 8]
        pop si
        pop di
        leave
        retf
        nop
.1:
        mov ax, word [bp + 8]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0:RetOnly
        add sp, 4
        db 0x03, 0xC6                           ; insn: add ax, si
        db 0x8B, 0xD7                           ; insn: mov dx, di
        inc ax
        pop si
        pop di
        leave
        retf
; Fold the counted far bytes into a dword. Each new byte is
; added after the previous value has moved up 8 bits.
ReadBe:
        enter 4, 0
        push di
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 2], ax
        mov word [bp - 4], ax
        mov si, word [bp + 6]
        mov di, word [bp + 0xa]
        jmp short .2
.1:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov es, word [bp + 8]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        mov word [bp - 4], cx
        mov word [bp - 2], bx
.2:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        dec di
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .1
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        pop si
        pop di
        leave
        retf
; A second byte of FBh selects a type code from the first byte.
; Otherwise the first four bytes are a big-endian dword, and 3F3h
; is its own code.
TypeId:
        enter 2, 0
        push di
        push si
        mov si, word [bp + 6]
        push word [bp + 8]
        push si
        push cs
        call 2
        add sp, 4
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov word [bp + 8], es
        cmp byte es:[bx + 1], 0xfb
        je short .1
        jmp near TypeTab.33
.1:
        mov cl, byte es:[si]
        and cx, 0xfe
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        cmp ax, strict word 0x42
        jne short .2
        jmp near TypeTab.16
.2:
        ja short TypeTab.1
        sub ax, strict word 0x26
        test al, 1
        jne short TypeTab.4
        cmp ax, strict word 0xe
        ja short TypeTab.4
        xchg bx, ax
        jmp word [cs:bx+TypeTab]
TypeTab:
        dw .10
        dw .12
        dw .10
        dw .11
        dw .12
        dw .13
        dw .14
        dw .15
.1:
        cmp ax, strict word 0x70
        jne short .2
        jmp near .21
.2:
        ja short .5
        cmp ax, strict word 0x6e
        jne short .3
        jmp near .20
.3:
        ja short .4
        sub al, 0x44
        je short .16
        sub al, 2
        je short .17
        sub al, 0x20
        je short .18
        sub al, 4
        je short .19
.4:
        mov di, 0x10
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        nop
.5:
        cmp ax, strict word 0x76
        jne short .6
        jmp near .24
.6:
        ja short .7
        sub ax, strict word 0x72
        je short .22
        dec ax
        dec ax
        je short .23
        jmp short .4
        nop
.7:
        cmp ax, 0xc0
        je short .19
        ja short .4
        sub al, 0x78
        jne short .8
        jmp near .28
.8:
        sub al, 2
        jne short .9
        jmp near .29
.9:
        jmp short .4
        nop
.10:
        mov di, 0x16
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        nop
.11:
        mov di, 0x17
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        nop
.12:
        mov di, 0x18
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        nop
.13:
        mov di, 7
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf
        nop
.14:
        mov di, 9
        jmp near .35
.15:
        mov di, 0xa
        jmp near .35
.16:
        mov di, 0x15
        jmp near .35
.17:
        mov di, 5
        jmp near .35
.18:
        mov di, 0x19
        jmp near .35
.19:
        mov di, 0x1d
        jmp near .35
.20:
        mov di, 1
        jmp near .35
.21:
        mov di, 0xe
        jmp near .35
.22:
        mov di, 0xb
        jmp near .35
.23:
        mov di, 0xd
        jmp near .35
.24:
        mov word [bp - 2], 0x12
        mov bx, 5
        test ch, 1
        je short .25
        mov bx, 8
.25:
        db 0x8B, 0xFE                           ; insn: mov di, si
        cmp byte es:[bx + di], 1
        jne short .26
        db 0x03, 0xFB                           ; insn: add di, bx
        cmp byte es:[di + 1], 1
        jne short .26
        mov word [bp - 2], 0x13
.26:
        db 0x8B, 0xFE                           ; insn: mov di, si
        cmp byte es:[bx + di], 2
        jne short .32
        mov di, word [bp - 2]
        db 0x03, 0xF3                           ; insn: add si, bx
        cmp byte es:[si + 1], 1
        je short .27
        jmp near .35
.27:
        mov di, 0x14
        jmp near .35
        nop
.28:
        mov di, 0xf
        jmp near .35
.29:
        mov word [bp - 2], 2
        mov bx, 5
        test ch, 1
        je short .30
        mov bx, 8
.30:
        db 0x8B, 0xFE                           ; insn: mov di, si
        cmp byte es:[bx + di], 1
        jne short .31
        db 0x03, 0xFB                           ; insn: add di, bx
        cmp byte es:[di + 1], 1
        jne short .31
        mov word [bp - 2], 3
.31:
        db 0x8B, 0xFE                           ; insn: mov di, si
        cmp byte es:[bx + di], 2
        jne short .32
        mov di, word [bp - 2]
        db 0x03, 0xF3                           ; insn: add si, bx
        cmp byte es:[si + 1], 1
        jne short .35
        mov di, 4
        jmp short .35
        nop
.32:
        mov di, word [bp - 2]
        jmp short .35
        nop
.33:
        mov al, byte es:[si + 3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov cl, byte es:[si + 2]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        mov dl, byte es:[si + 1]
        db 0x2A, 0xF6                           ; insn: sub dh, dh
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, byte es:[si]
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0x03, 0xC7                           ; insn: add ax, di
        adc dx, 0
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0x03, 0xC1                           ; insn: add ax, cx
        adc dx, 0
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0x03, 0xC3                           ; insn: add ax, bx
        adc dx, 0
        cmp ax, 0x3f3
        jne short .34
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jne short .34
        mov di, 0x1f
        jmp short .35
.34:
        db 0x2B, 0xFF                           ; insn: sub di, di
.35:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf

; ReadHead runs NineCmp and TypeId. A type from 1 to 1Ch returns the
; 3-byte value that follows the two type bytes. Otherwise the caller
; dword is returned.
; EmitByte writes one byte through OutPtr, or expands it through the
; two maps when the low map marks it. GetBits pulls that many bits
; from BitBuf, refilling from InPtr when fewer than 16 remain.

ReadHead:
        enter 4, 0
        push di
        push si
        cmp word [bp + 0xc], 0
        jl short .2
        jg short .1
        cmp word [bp + 0xa], 2
        jbe short .2
.1:
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call 2
        add sp, 4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], dx
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, word [bp + 6]
        db 0x1B, 0xD2                           ; insn: sbb dx, dx
        sub word [bp + 0xa], ax
        sbb word [bp + 0xc], dx
        push bx
        push cx
        push cs
        call TypeId
        add sp, 4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jle short .2
        cmp di, 0x1c
        jg short .2
        push 3
        mov cx, word [bp - 2]
        inc si
        inc si
        push cx
        push si
        push cs
        call ReadBe
        add sp, 6
        pop si
        pop di
        leave
        retf
        nop
.2:
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        pop si
        pop di
        leave
        retf
EmitByte:
        enter 2, 0
        push si
        mov bl, byte [bp + 4]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov word [bp - 2], bx
        mov si, word [MapLo]
        cmp byte [bx + si], bh
        je short .1
        mov si, word [MapHi]
        mov al, byte [bx + si]
        push ax
        call EmitByte
        mov bx, word [bp - 2]
        mov si, word [MapPair]
        mov al, byte [bx + si]
        push ax
        call EmitByte
        pop si
        leave
        ret 2
        nop
.1:
        mov al, byte [bp + 4]
        les bx, [OutPtr]
        mov byte es:[bx], al
        add word [OutPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [OutPtr+2], ax
        pop si
        leave
        ret 2
        nop
GetBits:
        enter 4, 0
        push si
        mov si, word [bp + 6]
        cmp si, 0x10
        jle short .1
        lea ax, [si - 0x10]
        push ax
        push cs
        call GetBits
        add sp, 2
        mov word [bp - 4], 0
        mov word [bp - 2], ax
        push 0x10
        push cs
        call GetBits
        add sp, 2
        or ax, word [bp - 4]
        or dx, word [bp - 2]
        pop si
        leave
        retf
.1:
        mov ax, word [BitBuf]
        mov dx, word [BitBuf+2]
        mov cl, 0x20
        db 0x8B, 0xDE                           ; insn: mov bx, si
        db 0x2A, 0xCB                           ; insn: sub cl, bl
        je short .3
.2:
        shr dx, 1
        rcr ax, 1
        dec cl
        jne short .2
.3:
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        push bx
        push 0x8ee4
        call 0:LongShlAt
        sub word [BitCount], si
        cmp word [BitCount], 0x10
        jge short .8
.4:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .5
        add word [InPtr+2], 0x1000
.5:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x18
        sub cl, byte [BitCount]
        je short .7
.6:
        shl ax, 1
        rcl dx, 1
        dec cl
        jne short .6
.7:
        or word [BitBuf], ax
        or word [BitBuf+2], dx
        add word [BitCount], 8
        cmp word [BitCount], 0x10
        jl short .4
.8:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        pop si
        leave
        retf

; ReadVar reads a variable-length number from the bit stream.
; Unpack checks for the word 31FBh, builds a decode table on the
; stack, and writes the output through OutPtr. A following 32FBh
; adds a running sum into each output byte. Expand checks for
; 47FBh, fills the three maps on the stack, and emits the bytes.
; It returns with ret 8.

ReadVar:
        enter 4, 0
        push si
        mov word [bp - 4], 2
        mov word [bp - 2], 0
        mov si, 1
.1:
        shl word [bp - 4], 1
        db 0xD1, 0x56, 0xFE                     ; insn: rcl word [bp - 2]
        inc si
        push 1
        push cs
        call GetBits
        add sp, 2
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .1
        push si
        push cs
        call GetBits
        add sp, 2
        add ax, word [bp - 4]
        adc dx, word [bp - 2]
        sub ax, strict word 4
        sbb dx, 0
        pop si
        leave
        retf
        nop
Unpack:
        enter 0x284, 0
        push di
        push si
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        mov word [OutPtr], ax
        mov word [OutPtr+2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0x14e], ax
        mov word [bp - 0x150], ax
        mov ax, word [bp + 6]
        mov dx, word [bp + 8]
        mov word [InPtr], ax
        mov word [InPtr+2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        jmp near .21
.1:
        les bx, [InPtr]
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov word [bp - 0x148], ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, es
        add ax, strict word 1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov word [InPtr], ax
        mov word [InPtr+2], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cl, byte es:[bx]
        mov ch, byte [bp - 0x148]
        mov word [bp - 0x148], cx
        add ax, strict word 1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov word [InPtr], ax
        mov word [InPtr+2], dx
        cmp word [bp - 0x148], 0x31fb
        jne short .2
        add ax, strict word 3
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov word [InPtr], ax
        mov word [InPtr+2], dx
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [BitBuf+2], ax
        mov word [BitBuf], ax
        mov word [BitCount], ax
        push ax
        push cs
        call GetBits
        add sp, 2
        push 0x18
        push cs
        call GetBits
        add sp, 2
        mov word [bp - 0x150], ax
        mov word [bp - 0x14e], dx
        cmp word [bp + 0xe], 0
        jne short .3
        jmp near .21
.3:
        push 8
        push cs
        call GetBits
        add sp, 2
        mov byte [bp - 0x154], al
        mov word [bp - 0x24], 0
        mov word [bp - 0x146], 1
        mov word [bp - 0x158], 0
.4:
        shl word [bp - 0x158], 1
        mov ax, word [bp - 0x158]
        sub ax, word [bp - 0x24]
        mov si, word [bp - 0x146]
        shl si, 1
        mov word [bp + si - 0x17a], ax
        push cs
        call ReadVar
        mov word [bp - 0x280], ax
        mov word [bp + si - 0x22], ax
        add word [bp - 0x24], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, word [bp - 0x158]
        mov word [bp - 0x158], ax
        mov word [bp - 2], 0
        db 0x0B, 0xC9                           ; insn: or cx, cx
        je short .5
        mov cl, 0x10
        sub cl, byte [bp - 0x146]
        shl ax, cl
        mov word [bp - 2], ax
.5:
        mov ax, word [bp - 2]
        mov si, word [bp - 0x146]
        shl si, 1
        mov word [bp + si - 0x144], ax
        inc word [bp - 0x146]
        cmp word [bp - 0x280], 0
        je short .4
        cmp word [bp - 2], 0
        jne short .4
        mov ax, word [bp - 0x146]
        dec ax
        mov word [bp - 0x152], ax
        mov word [bp - 0x156], 0
.6:
        mov si, word [bp - 0x156]
        mov byte [bp + si - 0x124], 0
        inc word [bp - 0x156]
        cmp word [bp - 0x156], 0x100
        jl short .6
        mov word [bp - 0x27e], 0xffff
        mov word [bp - 0x156], 0
        jmp short .9
        nop
.7:
        mov si, word [bp - 0x27e]
        inc si
        and si, 0xff
        mov word [bp - 0x27e], si
        cmp byte [bp + si - 0x124], 0
        jne short .8
        dec word [bp - 0x17c]
.8:
        cmp word [bp - 0x17c], 0
        jne short .7
        mov si, word [bp - 0x27e]
        mov byte [bp + si - 0x124], 1
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov si, word [bp - 0x156]
        mov byte [bp + si - 0x27c], al
        inc word [bp - 0x156]
.9:
        mov ax, word [bp - 0x156]
        cmp word [bp - 0x24], ax
        jle short .14
        push cs
        call ReadVar
        inc ax
        mov word [bp - 0x17c], ax
        jmp short .8
.10:
        mov ax, word [bp - 0x146]
        cmp word [bp - 0x152], ax
        jle short .12
        inc word [bp - 0x146]
.11:
        mov ax, word [bp - 2]
        mov si, word [bp - 0x146]
        shl si, 1
        cmp word [bp + si - 0x144], ax
        jbe short .10
.12:
        push word [bp - 0x146]
        push cs
        call GetBits
        add sp, 2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], si
        mov di, word [bp - 0x146]
        shl di, 1
        sub si, word [bp + di - 0x17a]
        mov al, byte [bp + si - 0x27c]
        mov byte [bp - 0x15a], al
        cmp al, byte [bp - 0x154]
        je short .15
.13:
        les bx, [OutPtr]
        mov byte es:[bx], al
        add word [OutPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [OutPtr+2], ax
.14:
        mov ax, word [BitBuf+2]
        mov word [bp - 2], ax
        mov word [bp - 0x146], 1
        jmp short .11
.15:
        push cs
        call ReadVar
        mov word [bp - 0x14c], ax
        mov word [bp - 0x14a], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .17
        mov ax, word [OutPtr]
        mov dx, word [OutPtr+2]
        add ax, strict word 0xffff
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        not cx
        and cx, 0x1000
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, byte es:[bx]
        mov byte [bp - 0x15a], al
.16:
        mov ax, word [bp - 0x14c]
        mov dx, word [bp - 0x14a]
        sub word [bp - 0x14c], 1
        sbb word [bp - 0x14a], 0
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .14
        mov al, byte [bp - 0x15a]
        les bx, [OutPtr]
        mov byte es:[bx], al
        add word [OutPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [OutPtr+2], ax
        jmp short .16
.17:
        push 1
        push cs
        call GetBits
        add sp, 2
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .20
        cmp word [bp - 0x148], 0x32fb
        jne short .21
        mov word [bp - 0x156], 0
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        mov word [OutPtr], ax
        mov word [OutPtr+2], dx
.18:
        mov ax, word [bp - 0x150]
        add ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        cmp dx, word [OutPtr+2]
        jb short .21
        ja short .19
        cmp ax, word [OutPtr]
        jbe short .21
.19:
        les bx, [OutPtr]
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        add word [bp - 0x156], ax
        mov al, byte [bp - 0x156]
        mov byte es:[bx], al
        add word [OutPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [OutPtr+2], ax
        jmp short .18
.20:
        push 8
        push cs
        call GetBits
        add sp, 2
        mov byte [bp - 0x15a], al
        jmp near .13
.21:
        mov ax, word [bp - 0x150]
        mov dx, word [bp - 0x14e]
        pop si
        pop di
        leave
        retf
Expand:
        enter 0x30a, 0
        push di
        push si
        mov ax, word [bp + 4]
        mov dx, word [bp + 6]
        mov word [OutPtr], ax
        mov word [OutPtr+2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 4], ax
        mov word [bp - 6], ax
        lea ax, [bp - 0x10a]
        mov word [MapLo], ax
        lea ax, [bp - 0x20a]
        mov word [MapHi], ax
        lea ax, [bp - 0x30a]
        mov word [MapPair], ax
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word [InPtr], ax
        mov word [InPtr+2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        jmp near .19
.1:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .2
        add word [InPtr+2], 0x1000
.2:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .3
        add word [InPtr+2], 0x1000
.3:
        mov cl, byte es:[bx]
        db 0x8A, 0xE8                           ; insn: mov ch, al
        db 0x8B, 0xF1                           ; insn: mov si, cx
        cmp si, 0x47fb
        jne short .4
        add word [InPtr], 3
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [InPtr+2], ax
.4:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .5
        add word [InPtr+2], 0x1000
.5:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov word [bp - 6], ax
        mov word [bp - 4], 0
        mov dx, word [bp - 4]
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .6
        add word [InPtr+2], 0x1000
.6:
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        mov word [bp - 6], cx
        mov word [bp - 4], bx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .7
        add word [InPtr+2], 0x1000
.7:
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        mov word [bp - 6], cx
        mov word [bp - 4], bx
        db 0x2B, 0xF6                           ; insn: sub si, si
.8:
        mov bx, word [MapLo]
        mov byte [bx + si], 0
        inc si
        cmp si, 0x100
        jl short .8
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .9
        add word [InPtr+2], 0x1000
.9:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov bx, word [MapLo]
        mov byte [bx + si], 1
        mov word [bp - 8], 0
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .10
        add word [InPtr+2], 0x1000
.10:
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .13
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov word [bp - 0xa], cx
.11:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .12
        add word [InPtr+2], 0x1000
.12:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        les bx, [InPtr]
        mov al, byte es:[bx]
        mov bx, word [MapHi]
        mov byte [bx + si], al
        add word [InPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [InPtr+2], ax
        les bx, [InPtr]
        mov al, byte es:[bx]
        mov bx, word [MapPair]
        mov byte [bx + si], al
        add word [InPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [InPtr+2], ax
        mov bx, word [MapLo]
        mov byte [bx + si], 0xff
        dec di
        jne short .11
.13:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .14
        add word [InPtr+2], 0x1000
.14:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov bx, word [MapLo]
        mov al, byte [bx + si]
        mov byte [bp - 1], al
        db 0x0A, 0xC0                           ; insn: or al, al
        jne short .16
.15:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        les bx, [OutPtr]
        mov byte es:[bx], al
        add word [OutPtr], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [OutPtr+2], ax
        jmp short .13
.16:
        cmp byte [bp - 1], 0
        jge short .17
        mov bx, word [MapHi]
        mov al, byte [bx + si]
        push ax
        call EmitByte
        mov bx, word [MapPair]
        mov al, byte [bx + si]
        push ax
        call EmitByte
        jmp short .13
.17:
        les bx, [InPtr]
        add word [InPtr], 1
        jae short .18
        add word [InPtr+2], 0x1000
.18:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jne short .15
.19:
        mov ax, word [bp - 6]
        mov dx, word [bp - 4]
        pop si
        pop di
        leave
        ret 8

; AddCopy accepts 62FBh or 66FBh and writes each input byte plus a
; running count. LoadBlock picks the unpacker from the type byte:
; 30h and 32h call Unpack, 46h calls Expand, 60h 62h and 66h call
; AddCopy, and 6Ah and 6Eh copy from five bytes into the header.
; Anything else, when the flag word is set, calls seg022. A zero
; result copies the header bytes themselves. LoadReport passes flag
; 1. LoadQuiet passes flag 0. Its near call finishes in seg005.

AddCopy:
        enter 0x10, 0
        push si
        mov ax, word [bp + 4]
        mov dx, word [bp + 6]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0xe], ax
        mov word [bp - 0x10], ax
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        jmp near .12
.1:
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .2
        add word [bp - 2], 0x1000
.2:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .3
        add word [bp - 2], 0x1000
.3:
        mov cl, byte es:[bx]
        db 0x8A, 0xE8                           ; insn: mov ch, al
        db 0x8B, 0xF1                           ; insn: mov si, cx
        cmp si, 0x62fb
        jne short .4
        add word [bp - 4], 3
        jmp short .5
.4:
        cmp si, 0x66fb
        jne short .6
        add word [bp - 4], 4
.5:
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [bp - 2], ax
.6:
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .7
        add word [bp - 2], 0x1000
.7:
        mov al, byte es:[bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov word [bp - 0x10], ax
        mov word [bp - 0xe], 0
        mov dx, word [bp - 0xe]
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .8
        add word [bp - 2], 0x1000
.8:
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        mov word [bp - 0x10], cx
        mov word [bp - 0xe], bx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x2A, 0xC0                           ; insn: sub al, al
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .9
        add word [bp - 2], 0x1000
.9:
        mov cl, byte es:[bx]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov word [bp - 0x10], ax
        mov word [bp - 0xe], dx
        add ax, word [bp - 8]
        db 0x13, 0xD3                           ; insn: adc dx, bx
        mov cx, 0xc
        shl dx, cl
        add dx, word [bp - 6]
        mov word [bp - 0xc], ax
        mov word [bp - 0xa], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp dx, word [bp - 6]
        jb short .12
        ja short .10
        cmp ax, word [bp - 8]
        jbe short .12
.10:
        db 0xC4, 0x5E, 0xFC                     ; insn: les bx, ptr [bp - 4]
        add word [bp - 4], 1
        jae short .11
        add word [bp - 2], 0x1000
.11:
        mov al, byte es:[bx]
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x02, 0xC1                           ; insn: add al, cl
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0xC4, 0x5E, 0xF8                     ; insn: les bx, ptr [bp - 8]
        mov byte es:[bx], al
        add word [bp - 8], 1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add word [bp - 6], ax
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        cmp dx, word [bp - 0xa]
        jb short .10
        ja short .12
        cmp ax, word [bp - 0xc]
        jb short .10
.12:
        mov ax, word [bp - 0x10]
        mov dx, word [bp - 0xe]
        pop si
        leave
        ret 8
        nop
LoadBlock:
        enter 0xc, 0
        push di
        push si
        mov di, word [bp + 6]
        push word [bp + 0x10]
        push word [bp + 0xe]
        mov ax, word [bp + 8]
        push ax
        push di
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push cs
        call ReadHead
        add sp, 8
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 2], ax
        mov word [bp - 4], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xD6                           ; insn: mov dx, si
        push dx
        push ax
        push cs
        call 2
        add sp, 4
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov word [bp - 0xa], es
        cmp byte es:[bx + 1], 0xfb
        je short .1
        jmp near .10
.1:
        mov al, byte es:[si]
        and ax, 0xfe
        cmp ax, strict word 0x6e
        je short .8
        ja short .2
        cmp al, 0x60
        je short .7
        jg short .4
        sub al, 0x30
        je short .5
        sub al, 2
        je short .5
        sub al, 0x14
        je short .6
.2:
        cmp word [bp + 0x12], 0
        jne short .3
        jmp near .10
.3:
        mov es, word [bp - 0xa]
        mov al, byte es:[si + 1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push 0x40c
        call 0xF4A:FatalError                   ; seg022
        add sp, 4
        jmp short .10
        nop
        nop
.4:
        sub al, 0x62
        je short .7
        sub al, 4
        je short .7
        sub al, 4
        je short .8
        jmp short .2
.5:
        push 1
        push word [bp + 0xc]
        push word [bp + 0xa]
        push es
        push si
        push cs
        call Unpack
        add sp, 0xa
        jmp short .9
        nop
.6:
        push es
        push si
        push word [bp + 0xc]
        push word [bp + 0xa]
        call Expand
        jmp short .9
        nop
.7:
        push word [bp - 0xa]
        push si
        push word [bp + 0xc]
        push word [bp + 0xa]
        call AddCopy
        jmp short .9
        nop
.8:
        push word [bp - 6]
        push word [bp - 8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, word [bp - 0xa]
        add ax, strict word 5
        push dx
        push ax
        call 0x3A3:CopyFar
        add sp, 0xc
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
.9:
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.10:
        mov ax, word [bp - 2]
        or ax, word [bp - 4]
        jne short .11
        push word [bp - 6]
        push word [bp - 8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov ax, word [bp - 0xa]
        push ax
        push si
        call 0x3A3:CopyFar
        add sp, 0xc
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.11:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        pop si
        pop di
        leave
        retf
        nop
LoadReport:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 1
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call LoadBlock
        leave
        retf
        nop
LoadQuiet:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 8]
        push word [bp + 6]
        push cs
        db 0xE8, 0x99                           ; insn: call LoadBlock, finished in seg005
