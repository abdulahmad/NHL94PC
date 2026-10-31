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
	incbin	"Extracted/segments/seg004.bin", 0x3F2, 0xC10 - 0x3F2
