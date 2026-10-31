; Segment seg004. NineCmp and TypeId look at a short header.
; The first two bytes are retf and nop.

; DGROUP words this segment uses. The bytes live in the near data, not here.
MapLo		equ	0x8ED6
MapHi		equ	0x8ED8
MapPair		equ	0x8EE2
OutPtr		equ	0x8EDA
InPtr		equ	0x8EDE
BitBuf		equ	0x8EE4
BitCount	equ	0x8EE8

	retf
	nop
; Compare 9 bytes of the far string with the bytes at 402h.
; A difference returns that pointer. A match calls RetOnly and
; returns one past its result.
NineCmp:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, word [bp + 6]
	push	9
	push	ds
	push	0x402
	push	word [bp + 8]
	push	si
	call	0:_fmemchr
	add	sp, 0xa
	db	0x0B, 0xC0			; or ax, ax
	je	short S002A
	db	0x8B, 0xC6			; mov ax, si
	mov	dx, word [bp + 8]
	pop	si
	pop	di
	leave
	retf
	nop
S002A:
	mov	ax, word [bp + 8]
	push	ax
	push	si
	db	0x8B, 0xF8			; mov di, ax
	call	0:RetOnly
	add	sp, 4
	db	0x03, 0xC6			; add ax, si
	db	0x8B, 0xD7			; mov dx, di
	inc	ax
	pop	si
	pop	di
	leave
	retf
; Fold the counted far bytes into a dword. Each new byte is
; added after the previous value has moved up 8 bits.
ReadBe:
	enter	4, 0
	push	di
	push	si
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 2], ax
	mov	word [bp - 4], ax
	mov	si, word [bp + 6]
	mov	di, word [bp + 0xa]
	jmp	short S007D
S0058:
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	mov	es, word [bp + 8]
	db	0x8B, 0xDE			; mov bx, si
	inc	si
	mov	cl, byte es:[bx]
	db	0x2A, 0xED			; sub ch, ch
	db	0x2B, 0xDB			; sub bx, bx
	db	0x03, 0xC8			; add cx, ax
	db	0x13, 0xDA			; adc bx, dx
	mov	word [bp - 4], cx
	mov	word [bp - 2], bx
S007D:
	db	0x8B, 0xC7			; mov ax, di
	dec	di
	db	0x0B, 0xC0			; or ax, ax
	jne	short S0058
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	pop	si
	pop	di
	leave
	retf
; A second byte of FBh selects a type code from the first byte.
; Otherwise the first four bytes are a big-endian dword, and 3F3h
; is its own code.
TypeId:
	enter	2, 0
	push	di
	push	si
	mov	si, word [bp + 6]
	push	word [bp + 8]
	push	si
	push	cs
	call	2
	add	sp, 4
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	db	0x8B, 0xF3			; mov si, bx
	mov	word [bp + 8], es
	cmp	byte es:[bx + 1], 0xfb
	je	short S00B5
	jmp	near S023A
S00B5:
	mov	cl, byte es:[si]
	and	cx, 0xfe
	db	0x8B, 0xC1			; mov ax, cx
	cmp	ax, strict word 0x42
	jne	short S00C6
	jmp	near S017A
S00C6:
	ja	short S00EA
	sub	ax, strict word 0x26
	test	al, 1
	jne	short S010E
	cmp	ax, strict word 0xe
	ja	short S010E
	xchg	bx, ax
	jmp	word [cs:bx+TypeTab]
TypeTab:
	dw	S0146
	dw	S015A
	dw	S0146
	dw	S0150
	dw	S015A
	dw	S0164
	dw	S016E
	dw	S0174
S00EA:
	cmp	ax, strict word 0x70
	jne	short S00F2
	jmp	near S0198
S00F2:
	ja	short S0118
	cmp	ax, strict word 0x6e
	jne	short S00FC
	jmp	near S0192
S00FC:
	ja	short S010E
	sub	al, 0x44
	je	short S017A
	sub	al, 2
	je	short S0180
	sub	al, 0x20
	je	short S0186
	sub	al, 4
	je	short S018C
S010E:
	mov	di, 0x10
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf
	nop
S0118:
	cmp	ax, strict word 0x76
	jne	short S0120
	jmp	near S01AA
S0120:
	ja	short S012E
	sub	ax, strict word 0x72
	je	short S019E
	dec	ax
	dec	ax
	je	short S01A4
	jmp	short S010E
	nop
S012E:
	cmp	ax, 0xc0
	je	short S018C
	ja	short S010E
	sub	al, 0x78
	jne	short S013C
	jmp	near S01EE
S013C:
	sub	al, 2
	jne	short S0143
	jmp	near S01F4
S0143:
	jmp	short S010E
	nop
S0146:
	mov	di, 0x16
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf
	nop
S0150:
	mov	di, 0x17
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf
	nop
S015A:
	mov	di, 0x18
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf
	nop
S0164:
	mov	di, 7
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf
	nop
S016E:
	mov	di, 9
	jmp	near S028C
S0174:
	mov	di, 0xa
	jmp	near S028C
S017A:
	mov	di, 0x15
	jmp	near S028C
S0180:
	mov	di, 5
	jmp	near S028C
S0186:
	mov	di, 0x19
	jmp	near S028C
S018C:
	mov	di, 0x1d
	jmp	near S028C
S0192:
	mov	di, 1
	jmp	near S028C
S0198:
	mov	di, 0xe
	jmp	near S028C
S019E:
	mov	di, 0xb
	jmp	near S028C
S01A4:
	mov	di, 0xd
	jmp	near S028C
S01AA:
	mov	word [bp - 2], 0x12
	mov	bx, 5
	test	ch, 1
	je	short S01BA
	mov	bx, 8
S01BA:
	db	0x8B, 0xFE			; mov di, si
	cmp	byte es:[bx + di], 1
	jne	short S01D0
	db	0x03, 0xFB			; add di, bx
	cmp	byte es:[di + 1], 1
	jne	short S01D0
	mov	word [bp - 2], 0x13
S01D0:
	db	0x8B, 0xFE			; mov di, si
	cmp	byte es:[bx + di], 2
	jne	short S0234
	mov	di, word [bp - 2]
	db	0x03, 0xF3			; add si, bx
	cmp	byte es:[si + 1], 1
	je	short S01E7
	jmp	near S028C
S01E7:
	mov	di, 0x14
	jmp	near S028C
	nop
S01EE:
	mov	di, 0xf
	jmp	near S028C
S01F4:
	mov	word [bp - 2], 2
	mov	bx, 5
	test	ch, 1
	je	short S0204
	mov	bx, 8
S0204:
	db	0x8B, 0xFE			; mov di, si
	cmp	byte es:[bx + di], 1
	jne	short S021A
	db	0x03, 0xFB			; add di, bx
	cmp	byte es:[di + 1], 1
	jne	short S021A
	mov	word [bp - 2], 3
S021A:
	db	0x8B, 0xFE			; mov di, si
	cmp	byte es:[bx + di], 2
	jne	short S0234
	mov	di, word [bp - 2]
	db	0x03, 0xF3			; add si, bx
	cmp	byte es:[si + 1], 1
	jne	short S028C
	mov	di, 4
	jmp	short S028C
	nop
S0234:
	mov	di, word [bp - 2]
	jmp	short S028C
	nop
S023A:
	mov	al, byte es:[si + 3]
	db	0x2A, 0xE4			; sub ah, ah
	mov	cl, byte es:[si + 2]
	db	0x2A, 0xED			; sub ch, ch
	mov	dl, byte es:[si + 1]
	db	0x2A, 0xF6			; sub dh, dh
	db	0x8B, 0xD8			; mov bx, ax
	mov	al, byte es:[si]
	db	0x8B, 0xFA			; mov di, dx
	db	0x2B, 0xD2			; sub dx, dx
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	db	0x03, 0xC7			; add ax, di
	adc	dx, 0
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	db	0x03, 0xC1			; add ax, cx
	adc	dx, 0
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	db	0x03, 0xC3			; add ax, bx
	adc	dx, 0
	cmp	ax, 0x3f3
	jne	short S028A
	db	0x0B, 0xD2			; or dx, dx
	jne	short S028A
	mov	di, 0x1f
	jmp	short S028C
S028A:
	db	0x2B, 0xFF			; sub di, di
S028C:
	db	0x8B, 0xC7			; mov ax, di
	pop	si
	pop	di
	leave
	retf

; ReadHead runs NineCmp and TypeId. A type from 1 to 1Ch returns the
; 3-byte value that follows the two type bytes. Otherwise the caller
; dword is returned.
; EmitByte writes one byte through OutPtr, or expands it through the
; two maps when the low map marks it. GetBits pulls that many bits
; from BitBuf, refilling from InPtr when fewer than 16 remain.

ReadHead:
	enter	4, 0
	push	di
	push	si
	cmp	word [bp + 0xc], 0
	jl	short S02F0
	jg	short S02A6
	cmp	word [bp + 0xa], 2
	jbe	short S02F0
S02A6:
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
	call	2
	add	sp, 4
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], dx
	db	0x8B, 0xCE			; mov cx, si
	db	0x8B, 0xDA			; mov bx, dx
	sub	ax, word [bp + 6]
	db	0x1B, 0xD2			; sbb dx, dx
	sub	word [bp + 0xa], ax
	sbb	word [bp + 0xc], dx
	push	bx
	push	cx
	push	cs
	call	TypeId
	add	sp, 4
	db	0x8B, 0xF8			; mov di, ax
	db	0x0B, 0xFF			; or di, di
	jle	short S02F0
	cmp	di, 0x1c
	jg	short S02F0
	push	3
	mov	cx, word [bp - 2]
	inc	si
	inc	si
	push	cx
	push	si
	push	cs
	call	ReadBe
	add	sp, 6
	pop	si
	pop	di
	leave
	retf
	nop
S02F0:
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	pop	si
	pop	di
	leave
	retf
EmitByte:
	enter	2, 0
	push	si
	mov	bl, byte [bp + 4]
	db	0x2A, 0xFF			; sub bh, bh
	mov	word [bp - 2], bx
	mov	si, word [MapLo]
	cmp	byte [bx + si], bh
	je	short S032C
	mov	si, word [MapHi]
	mov	al, byte [bx + si]
	push	ax
	call	EmitByte
	mov	bx, word [bp - 2]
	mov	si, word [MapPair]
	mov	al, byte [bx + si]
	push	ax
	call	EmitByte
	pop	si
	leave
	ret	2
	nop
S032C:
	mov	al, byte [bp + 4]
	les	bx, [OutPtr]
	mov	byte es:[bx], al
	add	word [OutPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [OutPtr+2], ax
	pop	si
	leave
	ret	2
	nop
GetBits:
	enter	4, 0
	push	si
	mov	si, word [bp + 6]
	cmp	si, 0x10
	jle	short S037C
	lea	ax, [si - 0x10]
	push	ax
	push	cs
	call	GetBits
	add	sp, 2
	mov	word [bp - 4], 0
	mov	word [bp - 2], ax
	push	0x10
	push	cs
	call	GetBits
	add	sp, 2
	or	ax, word [bp - 4]
	or	dx, word [bp - 2]
	pop	si
	leave
	retf
S037C:
	mov	ax, word [BitBuf]
	mov	dx, word [BitBuf+2]
	mov	cl, 0x20
	db	0x8B, 0xDE			; mov bx, si
	db	0x2A, 0xCB			; sub cl, bl
	je	short S0393
S038B:
	shr	dx, 1
	rcr	ax, 1
	dec	cl
	jne	short S038B
S0393:
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	push	bx
	push	0x8ee4
	call	0:LongShlAt
	sub	word [BitCount], si
	cmp	word [BitCount], 0x10
	jge	short S03E9
S03AD:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S03BE
	add	word [InPtr+2], 0x1000
S03BE:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x2B, 0xD2			; sub dx, dx
	mov	cl, 0x18
	sub	cl, byte [BitCount]
	je	short S03D5
S03CD:
	shl	ax, 1
	rcl	dx, 1
	dec	cl
	jne	short S03CD
S03D5:
	or	word [BitBuf], ax
	or	word [BitBuf+2], dx
	add	word [BitCount], 8
	cmp	word [BitCount], 0x10
	jl	short S03AD
S03E9:
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	pop	si
	leave
	retf

; ReadVar reads a variable-length number from the bit stream.
; Unpack checks for the word 31FBh, builds a decode table on the
; stack, and writes the output through OutPtr. A following 32FBh
; adds a running sum into each output byte. Expand checks for
; 47FBh, fills the three maps on the stack, and emits the bytes.
; It returns with ret 8.

ReadVar:
	enter	4, 0
	push	si
	mov	word [bp - 4], 2
	mov	word [bp - 2], 0
	mov	si, 1
S0404:
	shl	word [bp - 4], 1
	db	0xD1, 0x56, 0xFE			; rcl word [bp - 2]
	inc	si
	push	1
	push	cs
	call	GetBits
	add	sp, 2
	db	0x0B, 0xD0			; or dx, ax
	je	short S0404
	push	si
	push	cs
	call	GetBits
	add	sp, 2
	add	ax, word [bp - 4]
	adc	dx, word [bp - 2]
	sub	ax, strict word 4
	sbb	dx, 0
	pop	si
	leave
	retf
	nop
Unpack:
	enter	0x284, 0
	push	di
	push	si
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	mov	word [OutPtr], ax
	mov	word [OutPtr+2], dx
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 0x14e], ax
	mov	word [bp - 0x150], ax
	mov	ax, word [bp + 6]
	mov	dx, word [bp + 8]
	mov	word [InPtr], ax
	mov	word [InPtr+2], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short S0461
	jmp	near S0722
S0461:
	les	bx, [InPtr]
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	mov	word [bp - 0x148], ax
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, es
	add	ax, strict word 1
	db	0x1B, 0xC9			; sbb cx, cx
	and	cx, 0x1000
	db	0x03, 0xD1			; add dx, cx
	mov	word [InPtr], ax
	mov	word [InPtr+2], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	cl, byte es:[bx]
	mov	ch, byte [bp - 0x148]
	mov	word [bp - 0x148], cx
	add	ax, strict word 1
	db	0x1B, 0xC9			; sbb cx, cx
	and	cx, 0x1000
	db	0x03, 0xD1			; add dx, cx
	mov	word [InPtr], ax
	mov	word [InPtr+2], dx
	cmp	word [bp - 0x148], 0x31fb
	jne	short S04BF
	add	ax, strict word 3
	db	0x1B, 0xC9			; sbb cx, cx
	and	cx, 0x1000
	db	0x03, 0xD1			; add dx, cx
	mov	word [InPtr], ax
	mov	word [InPtr+2], dx
S04BF:
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [BitBuf+2], ax
	mov	word [BitBuf], ax
	mov	word [BitCount], ax
	push	ax
	push	cs
	call	GetBits
	add	sp, 2
	push	0x18
	push	cs
	call	GetBits
	add	sp, 2
	mov	word [bp - 0x150], ax
	mov	word [bp - 0x14e], dx
	cmp	word [bp + 0xe], 0
	jne	short S04EC
	jmp	near S0722
S04EC:
	push	8
	push	cs
	call	GetBits
	add	sp, 2
	mov	byte [bp - 0x154], al
	mov	word [bp - 0x24], 0
	mov	word [bp - 0x146], 1
	mov	word [bp - 0x158], 0
S050A:
	shl	word [bp - 0x158], 1
	mov	ax, word [bp - 0x158]
	sub	ax, word [bp - 0x24]
	mov	si, word [bp - 0x146]
	shl	si, 1
	mov	word [bp + si - 0x17a], ax
	push	cs
	call	ReadVar
	mov	word [bp - 0x280], ax
	mov	word [bp + si - 0x22], ax
	add	word [bp - 0x24], ax
	db	0x8B, 0xC8			; mov cx, ax
	add	ax, word [bp - 0x158]
	mov	word [bp - 0x158], ax
	mov	word [bp - 2], 0
	db	0x0B, 0xC9			; or cx, cx
	je	short S054B
	mov	cl, 0x10
	sub	cl, byte [bp - 0x146]
	shl	ax, cl
	mov	word [bp - 2], ax
S054B:
	mov	ax, word [bp - 2]
	mov	si, word [bp - 0x146]
	shl	si, 1
	mov	word [bp + si - 0x144], ax
	inc	word [bp - 0x146]
	cmp	word [bp - 0x280], 0
	je	short S050A
	cmp	word [bp - 2], 0
	jne	short S050A
	mov	ax, word [bp - 0x146]
	dec	ax
	mov	word [bp - 0x152], ax
	mov	word [bp - 0x156], 0
S0578:
	mov	si, word [bp - 0x156]
	mov	byte [bp + si - 0x124], 0
	inc	word [bp - 0x156]
	cmp	word [bp - 0x156], 0x100
	jl	short S0578
	mov	word [bp - 0x27e], 0xffff
	mov	word [bp - 0x156], 0
	jmp	short S05D2
	nop
S059C:
	mov	si, word [bp - 0x27e]
	inc	si
	and	si, 0xff
	mov	word [bp - 0x27e], si
	cmp	byte [bp + si - 0x124], 0
	jne	short S05B4
	dec	word [bp - 0x17c]
S05B4:
	cmp	word [bp - 0x17c], 0
	jne	short S059C
	mov	si, word [bp - 0x27e]
	mov	byte [bp + si - 0x124], 1
	db	0x8B, 0xC6			; mov ax, si
	mov	si, word [bp - 0x156]
	mov	byte [bp + si - 0x27c], al
	inc	word [bp - 0x156]
S05D2:
	mov	ax, word [bp - 0x156]
	cmp	word [bp - 0x24], ax
	jle	short S0640
	push	cs
	call	ReadVar
	inc	ax
	mov	word [bp - 0x17c], ax
	jmp	short S05B4
S05E6:
	mov	ax, word [bp - 0x146]
	cmp	word [bp - 0x152], ax
	jle	short S0603
	inc	word [bp - 0x146]
S05F4:
	mov	ax, word [bp - 2]
	mov	si, word [bp - 0x146]
	shl	si, 1
	cmp	word [bp + si - 0x144], ax
	jbe	short S05E6
S0603:
	push	word [bp - 0x146]
	push	cs
	call	GetBits
	add	sp, 2
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], si
	mov	di, word [bp - 0x146]
	shl	di, 1
	sub	si, word [bp + di - 0x17a]
	mov	al, byte [bp + si - 0x27c]
	mov	byte [bp - 0x15a], al
	cmp	al, byte [bp - 0x154]
	je	short S064E
S062B:
	les	bx, [OutPtr]
	mov	byte es:[bx], al
	add	word [OutPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [OutPtr+2], ax
S0640:
	mov	ax, word [BitBuf+2]
	mov	word [bp - 2], ax
	mov	word [bp - 0x146], 1
	jmp	short S05F4
S064E:
	push	cs
	call	ReadVar
	mov	word [bp - 0x14c], ax
	mov	word [bp - 0x14a], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short S06AE
	mov	ax, word [OutPtr]
	mov	dx, word [OutPtr+2]
	add	ax, strict word 0xffff
	db	0x1B, 0xC9			; sbb cx, cx
	not	cx
	and	cx, 0x1000
	db	0x2B, 0xD1			; sub dx, cx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	al, byte es:[bx]
	mov	byte [bp - 0x15a], al
S067D:
	mov	ax, word [bp - 0x14c]
	mov	dx, word [bp - 0x14a]
	sub	word [bp - 0x14c], 1
	sbb	word [bp - 0x14a], 0
	db	0x0B, 0xD0			; or dx, ax
	je	short S0640
	mov	al, byte [bp - 0x15a]
	les	bx, [OutPtr]
	mov	byte es:[bx], al
	add	word [OutPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [OutPtr+2], ax
	jmp	short S067D
S06AE:
	push	1
	push	cs
	call	GetBits
	add	sp, 2
	db	0x0B, 0xD0			; or dx, ax
	je	short S0712
	cmp	word [bp - 0x148], 0x32fb
	jne	short S0722
	mov	word [bp - 0x156], 0
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	mov	word [OutPtr], ax
	mov	word [OutPtr+2], dx
S06D6:
	mov	ax, word [bp - 0x150]
	add	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	cmp	dx, word [OutPtr+2]
	jb	short S0722
	ja	short S06EE
	cmp	ax, word [OutPtr]
	jbe	short S0722
S06EE:
	les	bx, [OutPtr]
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	add	word [bp - 0x156], ax
	mov	al, byte [bp - 0x156]
	mov	byte es:[bx], al
	add	word [OutPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [OutPtr+2], ax
	jmp	short S06D6
S0712:
	push	8
	push	cs
	call	GetBits
	add	sp, 2
	mov	byte [bp - 0x15a], al
	jmp	near S062B
S0722:
	mov	ax, word [bp - 0x150]
	mov	dx, word [bp - 0x14e]
	pop	si
	pop	di
	leave
	retf
Expand:
	enter	0x30a, 0
	push	di
	push	si
	mov	ax, word [bp + 4]
	mov	dx, word [bp + 6]
	mov	word [OutPtr], ax
	mov	word [OutPtr+2], dx
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 4], ax
	mov	word [bp - 6], ax
	lea	ax, [bp - 0x10a]
	mov	word [MapLo], ax
	lea	ax, [bp - 0x20a]
	mov	word [MapHi], ax
	lea	ax, [bp - 0x30a]
	mov	word [MapPair], ax
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	mov	word [InPtr], ax
	mov	word [InPtr+2], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short S0772
	jmp	near S0950
S0772:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S0783
	add	word [InPtr+2], 0x1000
S0783:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x8B, 0xF0			; mov si, ax
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S079B
	add	word [InPtr+2], 0x1000
S079B:
	mov	cl, byte es:[bx]
	db	0x8A, 0xE8			; mov ch, al
	db	0x8B, 0xF1			; mov si, cx
	cmp	si, 0x47fb
	jne	short S07B6
	add	word [InPtr], 3
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [InPtr+2], ax
S07B6:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S07C7
	add	word [InPtr+2], 0x1000
S07C7:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	mov	word [bp - 6], ax
	mov	word [bp - 4], 0
	mov	dx, word [bp - 4]
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S07F0
	add	word [InPtr+2], 0x1000
S07F0:
	mov	cl, byte es:[bx]
	db	0x2A, 0xED			; sub ch, ch
	db	0x2B, 0xDB			; sub bx, bx
	db	0x03, 0xC8			; add cx, ax
	db	0x13, 0xDA			; adc bx, dx
	mov	word [bp - 6], cx
	mov	word [bp - 4], bx
	db	0x8B, 0xC1			; mov ax, cx
	db	0x8B, 0xD3			; mov dx, bx
	db	0x8A, 0xF2			; mov dh, dl
	db	0x8A, 0xD4			; mov dl, ah
	db	0x8A, 0xE0			; mov ah, al
	db	0x2A, 0xC0			; sub al, al
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S081E
	add	word [InPtr+2], 0x1000
S081E:
	mov	cl, byte es:[bx]
	db	0x2A, 0xED			; sub ch, ch
	db	0x2B, 0xDB			; sub bx, bx
	db	0x03, 0xC8			; add cx, ax
	db	0x13, 0xDA			; adc bx, dx
	mov	word [bp - 6], cx
	mov	word [bp - 4], bx
	db	0x2B, 0xF6			; sub si, si
S0831:
	mov	bx, word [MapLo]
	mov	byte [bx + si], 0
	inc	si
	cmp	si, 0x100
	jl	short S0831
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S0850
	add	word [InPtr+2], 0x1000
S0850:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x8B, 0xF0			; mov si, ax
	mov	bx, word [MapLo]
	mov	byte [bx + si], 1
	mov	word [bp - 8], 0
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S0874
	add	word [InPtr+2], 0x1000
S0874:
	mov	cl, byte es:[bx]
	db	0x2A, 0xED			; sub ch, ch
	db	0x0B, 0xC9			; or cx, cx
	jle	short S08DA
	db	0x8B, 0xF9			; mov di, cx
	mov	word [bp - 0xa], cx
S0882:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S0893
	add	word [InPtr+2], 0x1000
S0893:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x8B, 0xF0			; mov si, ax
	les	bx, [InPtr]
	mov	al, byte es:[bx]
	mov	bx, word [MapHi]
	mov	byte [bx + si], al
	add	word [InPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [InPtr+2], ax
	les	bx, [InPtr]
	mov	al, byte es:[bx]
	mov	bx, word [MapPair]
	mov	byte [bx + si], al
	add	word [InPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [InPtr+2], ax
	mov	bx, word [MapLo]
	mov	byte [bx + si], 0xff
	dec	di
	jne	short S0882
S08DA:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S08EB
	add	word [InPtr+2], 0x1000
S08EB:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x8B, 0xF0			; mov si, ax
	mov	bx, word [MapLo]
	mov	al, byte [bx + si]
	mov	byte [bp - 1], al
	db	0x0A, 0xC0			; or al, al
	jne	short S0918
S08FF:
	db	0x8B, 0xC6			; mov ax, si
	les	bx, [OutPtr]
	mov	byte es:[bx], al
	add	word [OutPtr], 1
	db	0x1B, 0xC0			; sbb ax, ax
	and	ax, 0x1000
	add	word [OutPtr+2], ax
	jmp	short S08DA
S0918:
	cmp	byte [bp - 1], 0
	jge	short S0934
	mov	bx, word [MapHi]
	mov	al, byte [bx + si]
	push	ax
	call	EmitByte
	mov	bx, word [MapPair]
	mov	al, byte [bx + si]
	push	ax
	call	EmitByte
	jmp	short S08DA
S0934:
	les	bx, [InPtr]
	add	word [InPtr], 1
	jae	short S0945
	add	word [InPtr+2], 0x1000
S0945:
	mov	al, byte es:[bx]
	db	0x2A, 0xE4			; sub ah, ah
	db	0x8B, 0xF0			; mov si, ax
	db	0x0B, 0xF6			; or si, si
	jne	short S08FF
S0950:
	mov	ax, word [bp - 6]
	mov	dx, word [bp - 4]
	pop	si
	pop	di
	leave
	ret	8
	incbin	"Extracted/segments/seg004.bin", 0x95C, 0xC10 - 0x95C
