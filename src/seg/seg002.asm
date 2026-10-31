; Segment seg002. BlankBit reads port 3DAh. MakeChain allocates a DOS
; block and links 24h-byte records in it. SetBuf stores the count and
; the near buffer MakeChain checks.
; seg001 ends on WaitBlank retf. These first bytes are their own function.

; DGROUP words this segment uses. The bytes live in the near data, not here.
BlockEnd	equ	0x63F8
BlockSeg	equ	0x63FC
EmsOutPtr	equ	0x25C
BufPtr		equ	0x2BC
BufCount	equ	0x2BA
ChainIdx	equ	0xAE9C
ChainPtr	equ	0xAE9E
RecSeq		equ	0x2BE

; Bit 0 of the video status port. AX is 0 or 1.
BlankBit:
	mov	dx, 0x3da
	in	al, dx
	and	ax, 1
	retf

; Cap LargestFree at the dword at [bp+8], align it down to 16, and
; AllocBytes. The dword at [bp+0Ch], shifted down by 4, is subtracted
; from BlockEnd. BufCount below CCh calls seg022. Four 24h-byte records
; are named from near pointers, then [bp+6] more are linked through
; offset 1Ch. The near call stores its far result at ChainPtr.
MakeChain:
	enter	6, 0
	push	di
	push	si
	call	0x3A3:LargestFree
	mov	word [bp - 2], dx
	cmp	dx, word [bp + 0xa]
	jl	short L002B
	jg	short L0022
	cmp	ax, word [bp + 8]
	jbe	short L002B
L0022:
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	mov	word [bp - 2], dx
L002B:
	and	al, 0xf0
	call	0x3A3:AllocBytes
	mov	ax, word [bp + 0xc]
	mov	dx, word [bp + 0xe]
	sar	dx, 1
	rcr	ax, 1
	sar	dx, 1
	rcr	ax, 1
	sar	dx, 1
	rcr	ax, 1
	sar	dx, 1
	rcr	ax, 1
	sub	word [BlockEnd], ax
	cmp	word [BufPtr], 0
	jne	short L0059
	mov	word [BufPtr], 0x6528
L0059:
	cmp	word [BufCount], 0xcc
	jge	short L006C
	push	0x26c
	call	0xF4A:0x3E4		; seg022
	add	sp, 2
L006C:
	mov	ax, word [BufCount]
	shl	ax, 1
	add	ax, word [BufPtr]
	mov	word [ChainIdx], ax
	mov	ax, word [BufCount]
	dec	ax
	dec	ax
	mov	bx, word [BufPtr]
	mov	word [bx], ax
	mov	bx, word [BufPtr]
	mov	word [bx + 2], 0
	mov	ax, word [BlockEnd+2]
	mov	dx, word [BlockSeg]
	mov	word [ChainPtr+0xc], ax
	mov	word [ChainPtr+0xe], dx
	add	ax, strict word 0x24
	mov	word [ChainPtr+8], ax
	mov	word [ChainPtr+0xa], dx
	mov	ax, word [ChainPtr+0xc]
	imul	cx, word [bp + 6], 0x24
	db	0x03, 0xC1			; add ax, cx
	add	ax, strict word 0x48
	push	dx
	push	ax
	call	0x3A3:RoundSeg
	add	sp, 4
	les	bx, [ChainPtr+0xc]
	mov	word es:[bx], ax
	mov	word es:[bx + 2], dx
	push	0xc
	push	0x297
	mov	ax, word [ChainPtr+0xc]
	mov	dx, word [ChainPtr+0xe]
	add	ax, strict word 4
	push	dx
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	les	bx, [ChainPtr+0xc]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 0x16], ax
	mov	word es:[bx + 0x14], ax
	les	bx, [ChainPtr+0xc]
	mov	word es:[bx + 0x12], ax
	mov	word es:[bx + 0x10], ax
	mov	ax, word [ChainPtr+8]
	mov	dx, word [ChainPtr+0xa]
	les	bx, [ChainPtr+0xc]
	mov	word es:[bx + 0x1c], ax
	mov	word es:[bx + 0x1e], dx
	les	bx, [ChainPtr+0xc]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 0x22], ax
	mov	word es:[bx + 0x20], ax
	les	bx, [ChainPtr+0xc]
	mov	word es:[bx + 0x18], ax
	push	0xc
	push	0x29f
	mov	ax, word [ChainPtr+8]
	mov	dx, word [ChainPtr+0xa]
	add	ax, strict word 4
	push	dx
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	mov	ax, word [BlockEnd-2]
	mov	dx, word [BlockEnd]
	les	bx, [ChainPtr+8]
	mov	word es:[bx], ax
	mov	word es:[bx + 2], dx
	les	bx, [ChainPtr+8]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 0x16], ax
	mov	word es:[bx + 0x14], ax
	les	bx, [ChainPtr+8]
	mov	word es:[bx + 0x12], ax
	mov	word es:[bx + 0x10], ax
	les	bx, [ChainPtr+8]
	mov	word es:[bx + 0x1e], ax
	mov	word es:[bx + 0x1c], ax
	mov	ax, word [ChainPtr+0xc]
	mov	dx, word [ChainPtr+0xe]
	les	bx, [ChainPtr+8]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	les	bx, [ChainPtr+8]
	mov	word es:[bx + 0x18], 0x20
	mov	ax, word [ChainPtr+8]
	mov	dx, word [ChainPtr+0xa]
	add	ax, strict word 0x24
	mov	word [ChainPtr+4], ax
	mov	word [ChainPtr+6], dx
	add	ax, strict word 0x24
	mov	word [EmsOutPtr], ax
	mov	word [EmsOutPtr+2], dx
	les	bx, [ChainPtr+4]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 2], ax
	mov	word es:[bx], ax
	push	0xc
	push	0x2a8
	mov	ax, word [ChainPtr+4]
	mov	dx, word [ChainPtr+6]
	add	ax, strict word 4
	push	dx
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	les	bx, [ChainPtr+4]
	mov	word es:[bx + 0x14], 0x10
	mov	word es:[bx + 0x16], 0
	les	bx, [ChainPtr+4]
	mov	word es:[bx + 0x10], 0x10
	mov	word es:[bx + 0x12], 0
	mov	ax, word [EmsOutPtr]
	mov	dx, word [EmsOutPtr+2]
	les	bx, [ChainPtr+4]
	mov	word es:[bx + 0x1c], ax
	mov	word es:[bx + 0x1e], dx
	les	bx, [ChainPtr+4]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 0x22], ax
	mov	word es:[bx + 0x20], ax
	les	bx, [ChainPtr+4]
	mov	word es:[bx + 0x18], 0x80
	push	0xc
	push	0x2b0
	mov	ax, word [EmsOutPtr]
	mov	dx, word [EmsOutPtr+2]
	add	ax, strict word 4
	push	dx
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	les	bx, [EmsOutPtr]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[bx + 2], ax
	mov	word es:[bx], ax
	les	bx, [EmsOutPtr]
	mov	word es:[bx + 0x16], ax
	mov	word es:[bx + 0x14], ax
	les	bx, [EmsOutPtr]
	mov	word es:[bx + 0x12], ax
	mov	word es:[bx + 0x10], ax
	les	bx, [EmsOutPtr]
	mov	word es:[bx + 0x1e], ax
	mov	word es:[bx + 0x1c], ax
	mov	ax, word [ChainPtr+4]
	mov	dx, word [ChainPtr+6]
	les	bx, [EmsOutPtr]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	les	bx, [EmsOutPtr]
	mov	word es:[bx + 0x18], 0xa0
	mov	ax, word [EmsOutPtr]
	mov	dx, word [EmsOutPtr+2]
	add	ax, strict word 0x24
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], dx
	mov	word [ChainPtr+0x10], ax
	mov	word [ChainPtr+0x12], dx
	mov	ax, word [bp + 6]
	dec	ax
	db	0x0B, 0xC0			; or ax, ax
	jle	short L02BD
	mov	bx, word [bp + 6]
	dec	bx
	mov	es, dx
L02A6:
	db	0x8B, 0xC6			; mov ax, si
	db	0x8B, 0xFE			; mov di, si
	add	ax, strict word 0x24
	mov	word es:[di + 0x1c], ax
	mov	word es:[di + 0x1e], dx
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], dx
	dec	bx
	jne	short L02A6
L02BD:
	mov	es, word [bp - 2]
	db	0x2B, 0xC0			; sub ax, ax
	mov	word es:[si + 0x1e], ax
	mov	word es:[si + 0x1c], ax
	push	cs
	call	0x1396			; still incbin
	mov	word [ChainPtr], ax
	mov	word [ChainPtr+2], dx
	pop	si
	pop	di
	leave
	retf
	nop
; Store the near buffer and the count MakeChain reads.
SetBuf:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	ax, word [bp + 6]
	mov	word [BufPtr], ax
	mov	ax, word [bp + 8]
	mov	word [BufCount], ax
	leave
	retf
	nop

; Insert a 24h-byte record into the chain. PathTail keeps the name.
; The dword at [bp+8] is rounded up to 16. Bits in [bp+0Ch] pick the
; walk: 20h uses one chain, 80h another, and anything else above that
; calls seg022. A gap that fits is linked in and returned in DX:AX.

InsertRec:
	enter	0x1a, 0
	push	si
	push	word [bp + 6]
	call	0x3A3:PathTail
	add	sp, 2
	mov	word [bp + 6], ax
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	add	ax, strict word 0xf
	adc	dx, 0
	and	al, 0xf0
	mov	word [bp - 0xc], ax
	mov	word [bp - 0xa], dx
	test	word [bp + 0xc], 0xff80
	je	short L031D
	jmp	near L06A8
L031D:
	test	byte [bp + 0xc], 0x20
	je	short L0326
	jmp	near L04EC
L0326:
	test	byte [bp + 0xc], 0x10
	jne	short L0330
	push	cs
	call	0xE54			; still incbin
L0330:
	les	bx, [ChainPtr+0xc]
	mov	ax, word es:[bx + 0x1c]
	mov	dx, word es:[bx + 0x1e]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
L0351:
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 0x14], ax
	mov	word [bp - 0x16], ax
L035F:
	les	bx, [bp - 8]
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	cmp	dx, word [bp - 2]
	jl	short L03C8
	jg	short L037D
	cmp	ax, word [bp - 4]
	jbe	short L03C8
L037D:
	les	bx, [bp - 8]
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	sub	ax, word [bp - 4]
	sbb	dx, word [bp - 2]
	mov	word [bp - 0x16], ax
	mov	word [bp - 0x14], dx
L039B:
	mov	ax, word [bp - 6]
	or	ax, word [bp - 8]
	jne	short L0400
	push	cs
	call	AxClear
	db	0x0B, 0xC0			; or ax, ax
	je	short L03AE
	jmp	near L0326
L03AE:
	cmp	word [bp + 0xe], ax
	jne	short L03B6
	jmp	near L084F
L03B6:
	push	cs
	call	0x1396			; still incbin
	push	dx
	push	ax
	push	word [bp + 0xa]
	push	word [bp + 8]
	push	0x2c0
	jmp	near L0847
L03C8:
	les	bx, [bp - 8]
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	les	bx, [bp - 8]
	add	ax, word es:[bx + 0x10]
	adc	dx, word es:[bx + 0x12]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	mov	ax, word es:[bx + 0x1c]
	mov	dx, word es:[bx + 0x1e]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L039B
	jmp	near L035F
L0400:
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	cmp	word [bp - 0x14], dx
	jge	short L040E
	jmp	near L04CC
L040E:
	jg	short L0418
	cmp	word [bp - 0x16], ax
	jae	short L0418
	jmp	near L04CC
L0418:
	push	cs
	call	0x14A8			; still incbin
	mov	word [bp - 0x1a], ax
	mov	word [bp - 0x18], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bp + 0xc]
	mov	word es:[bx + 0x18], ax
	mov	ax, word [RecSeq]
	mov	word es:[bx + 0x1a], ax
	inc	word [RecSeq]
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	mov	word es:[bx + 0x14], ax
	mov	word es:[bx + 0x16], dx
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	mov	word es:[bx + 0x10], ax
	mov	word es:[bx + 0x12], dx
	push	0xc
	push	word [bp + 6]
	lea	ax, [bx + 4]
	push	es
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	call	0x3A3:LinearToFarRegs
	les	bx, [bp - 0x1a]
	mov	word es:[bx], ax
	mov	word es:[bx + 2], dx
	les	si, [bp - 8]
	mov	ax, word es:[si + 0x20]
	mov	dx, word es:[si + 0x22]
	les	bx, [bp - 0x1a]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	mov	ax, word [bp - 8]
	mov	dx, word [bp - 6]
	mov	word es:[bx + 0x1c], ax
	mov	word es:[bx + 0x1e], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	db	0x26, 0xC4, 0x77, 0x20			; les si, ptr es:[bx + 0x20]
	mov	ax, word [bp - 0x1a]
	mov	dx, word [bp - 0x18]
	mov	word es:[si + 0x1c], ax
	mov	word es:[si + 0x1e], dx
	les	bx, [bp - 8]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
L04C0:
	call	0x1366			; still incbin
	mov	ax, word [bp - 0x1a]
	mov	dx, word [bp - 0x18]
	pop	si
	leave
	retf
L04CC:
	les	bx, [bp - 8]
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	les	bx, [bp - 8]
	add	ax, word es:[bx + 0x10]
	adc	dx, word es:[bx + 0x12]
	jmp	near L0351
L04EC:
	mov	word [bp - 0xe], 0
	test	byte [bp + 0xc], 0x10
	jne	short L04FB
	push	cs
	call	0x10EA			; still incbin
L04FB:
	cmp	word [bp - 0xe], 0
	je	short L0505
	push	cs
	call	0xE54			; still incbin
L0505:
	les	bx, [ChainPtr+8]
	mov	ax, word es:[bx + 0x20]
	mov	dx, word es:[bx + 0x22]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
L0517:
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 0x14], ax
	mov	word [bp - 0x16], ax
L0534:
	les	bx, [bp - 8]
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	les	bx, [bp - 8]
	add	ax, word es:[bx + 0x10]
	adc	dx, word es:[bx + 0x12]
	cmp	dx, word [bp - 2]
	jg	short L0586
	jl	short L055D
	cmp	ax, word [bp - 4]
	jae	short L0586
L055D:
	mov	cx, word [bp - 4]
	mov	bx, word [bp - 2]
	db	0x2B, 0xC8			; sub cx, ax
	db	0x1B, 0xDA			; sbb bx, dx
	mov	word [bp - 0x16], cx
	mov	word [bp - 0x14], bx
L056D:
	mov	ax, word [bp - 6]
	or	ax, word [bp - 8]
	jne	short L05B2
	cmp	word [bp - 0xe], 0
	je	short L057E
	jmp	near L0682
L057E:
	mov	word [bp - 0xe], 1
	jmp	near L04FB
L0586:
	push	word es:[bx + 2]
	push	word es:[bx]
	call	0x3A3:FarToLinear
	add	sp, 4
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	les	bx, [bp - 8]
	mov	ax, word es:[bx + 0x20]
	mov	dx, word es:[bx + 0x22]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L056D
	jmp	short L0534
L05B2:
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	cmp	word [bp - 0x14], dx
	jge	short L05C0
	jmp	near L067C
L05C0:
	jg	short L05CA
	cmp	word [bp - 0x16], ax
	jae	short L05CA
	jmp	near L067C
L05CA:
	push	cs
	call	0x14A8			; still incbin
	mov	word [bp - 0x1a], ax
	mov	word [bp - 0x18], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bp + 0xc]
	mov	word es:[bx + 0x18], ax
	mov	ax, word [RecSeq]
	mov	word es:[bx + 0x1a], ax
	inc	word [RecSeq]
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	mov	word es:[bx + 0x14], ax
	mov	word es:[bx + 0x16], dx
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	mov	word es:[bx + 0x10], ax
	mov	word es:[bx + 0x12], dx
	push	0xc
	push	word [bp + 6]
	lea	cx, [bx + 4]
	push	es
	push	cx
	call	0x3A3:CopyStrN
	add	sp, 8
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	sub	ax, word [bp - 0xc]
	sbb	dx, word [bp - 0xa]
	call	0x3A3:LinearToFarRegs
	les	bx, [bp - 0x1a]
	mov	word es:[bx], ax
	mov	word es:[bx + 2], dx
	mov	ax, word [bp - 8]
	mov	dx, word [bp - 6]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word es:[bx + 0x1c]
	mov	dx, word es:[bx + 0x1e]
	les	si, [bp - 0x1a]
	mov	word es:[si + 0x1c], ax
	mov	word es:[si + 0x1e], dx
	les	bx, [bp - 8]
	db	0x26, 0xC4, 0x77, 0x1C			; les si, ptr es:[bx + 0x1c]
	mov	ax, word [bp - 0x1a]
	mov	dx, word [bp - 0x18]
	mov	word es:[si + 0x20], ax
	mov	word es:[si + 0x22], dx
	les	bx, [bp - 8]
	mov	word es:[bx + 0x1c], ax
	mov	word es:[bx + 0x1e], dx
	jmp	near L04C0
	nop
L067C:
	les	bx, [bp - 8]
	jmp	near L0517
L0682:
	push	cs
	call	AxClear
	db	0x0B, 0xC0			; or ax, ax
	je	short L068D
	jmp	near L04FB
L068D:
	cmp	word [bp + 0xe], ax
	jne	short L0695
	jmp	near L084F
L0695:
	push	cs
	call	0x1396			; still incbin
	push	dx
	push	ax
	push	word [bp + 0xa]
	push	word [bp + 8]
	push	0x2fa
	jmp	near L0847
	nop
L06A8:
	mov	ax, word [bp + 0xc]
	and	al, 0x80
	cmp	ax, 0x80
	je	short L06B5
	jmp	near L084F
L06B5:
	les	bx, [ChainPtr+4]
	mov	ax, word es:[bx + 0x1c]
	mov	dx, word es:[bx + 0x1e]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
L06C7:
	mov	ax, word es:[bx + 0x10]
	mov	dx, word es:[bx + 0x12]
	add	ax, word es:[bx]
	adc	dx, word es:[bx + 2]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
L06DC:
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 0x14], ax
	mov	word [bp - 0x16], ax
L06E4:
	test	byte [bp + 0xc], 0x40
	je	short L06FF
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	add	ax, 0x3fff
	adc	dx, 0
	and	ax, 0xc000
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
L06FF:
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	les	bx, [bp - 8]
	cmp	word es:[bx + 2], dx
	jl	short L0744
	jg	short L0715
	cmp	word es:[bx], ax
	jbe	short L0744
L0715:
	mov	cx, word es:[bx]
	mov	si, word es:[bx + 2]
	db	0x2B, 0xC8			; sub cx, ax
	db	0x1B, 0xF2			; sbb si, dx
	mov	word [bp - 0x16], cx
	mov	word [bp - 0x14], si
L0726:
	mov	ax, word [bp - 6]
	or	ax, word [bp - 8]
	jne	short L076E
	mov	al, byte [bp + 0xc]
	and	ax, strict word 7
	push	ax
	push	cs
	call	DropOldest
	add	sp, 2
	db	0x0B, 0xC0			; or ax, ax
	jne	short L06DC
	jmp	near L0832
	nop
L0744:
	mov	ax, word es:[bx + 0x10]
	mov	dx, word es:[bx + 0x12]
	add	ax, word es:[bx]
	adc	dx, word es:[bx + 2]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	mov	ax, word es:[bx + 0x1c]
	mov	dx, word es:[bx + 0x1e]
	mov	word [bp - 8], ax
	mov	word [bp - 6], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L0726
	jmp	near L06E4
L076E:
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	cmp	word [bp - 0x14], dx
	jge	short L077C
	jmp	near L082C
L077C:
	jg	short L0786
	cmp	word [bp - 0x16], ax
	jae	short L0786
	jmp	near L082C
L0786:
	push	cs
	call	0x14A8			; still incbin
	mov	word [bp - 0x1a], ax
	mov	word [bp - 0x18], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bp + 0xc]
	mov	word es:[bx + 0x18], ax
	mov	ax, word [RecSeq]
	mov	word es:[bx + 0x1a], ax
	inc	word [RecSeq]
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	mov	word es:[bx + 0x14], ax
	mov	word es:[bx + 0x16], dx
	mov	ax, word [bp - 0xc]
	mov	dx, word [bp - 0xa]
	mov	word es:[bx + 0x10], ax
	mov	word es:[bx + 0x12], dx
	push	0xc
	push	word [bp + 6]
	lea	ax, [bx + 4]
	push	es
	push	ax
	call	0x3A3:CopyStrN
	add	sp, 8
	mov	ax, word [bp - 4]
	mov	dx, word [bp - 2]
	les	bx, [bp - 0x1a]
	mov	word es:[bx], ax
	mov	word es:[bx + 2], dx
	les	si, [bp - 8]
	mov	ax, word es:[si + 0x20]
	mov	dx, word es:[si + 0x22]
	les	bx, [bp - 0x1a]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	mov	ax, word [bp - 8]
	mov	dx, word [bp - 6]
	mov	word es:[bx + 0x1c], ax
	mov	word es:[bx + 0x1e], dx
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	db	0x26, 0xC4, 0x77, 0x20			; les si, ptr es:[bx + 0x20]
	mov	ax, word [bp - 0x1a]
	mov	dx, word [bp - 0x18]
	mov	word es:[si + 0x1c], ax
	mov	word es:[si + 0x1e], dx
	les	bx, [bp - 8]
	mov	word es:[bx + 0x20], ax
	mov	word es:[bx + 0x22], dx
	pop	si
	leave
	retf
L082C:
	les	bx, [bp - 8]
	jmp	near L06C7
L0832:
	cmp	word [bp + 0xe], ax
	je	short L084F
	call	0x148B:0x4		; seg030
	push	dx
	push	ax
	push	word [bp + 0xa]
	push	word [bp + 8]
	push	0x334
L0847:
	call	0xF4A:0x3E4		; seg022
	add	sp, 0xa
L084F:
	cmp	word [bp + 0xe], 0
	je	short L0863
	push	word [bp + 0xc]
	push	0x36b
	call	0xF4A:0x3E4		; seg022
	add	sp, 4
L0863:
	db	0x2B, 0xC0			; sub ax, ax
	db	0x99			; cdq
	pop	si
	leave
	retf
	nop

; ResizeRec grows the record when the next one leaves room. A nonzero
; word at [bp+0Eh] reports a short gap through seg022. FindRec walks the
; chain for the far base that matches the argument. UnlinkRec splices a
; record out. FindUnlink and FindTrim find first. TrimAfter drops the
; following records whose flag byte lacks bit 20h. DropOldest unlinks
; the oldest record of the requested class.

ResizeRec:
	enter	0xc, 0
	push	di
	push	si
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	les	bx, [bp + 6]
	db	0x8B, 0xF3			; mov si, bx
	mov	word [bp - 2], es
	cmp	word es:[bx + 0x12], dx
	jl	short L08AA
	jg	short L088C
	cmp	word es:[bx + 0x10], ax
	jbe	short L08AA
L088C:
	mov	es, word [bp - 2]
	mov	word es:[si + 0x14], ax
	mov	word es:[si + 0x16], dx
	add	ax, strict word 0xf
	adc	dx, 0
	and	al, 0xf0
	mov	word es:[si + 0x10], ax
	mov	word es:[si + 0x12], dx
	jmp	near L0931
L08AA:
	mov	es, word [bp - 2]
	test	byte es:[si + 0x18], 0x80
	jne	short L08EC
	push	word es:[si + 2]
	push	word es:[si]
	call	0x3A3:FarToLinear
	add	sp, 4
	mov	es, word [bp - 2]
		les	bx, es:[si + 0x1c]
	push	word es:[bx + 2]
	push	word es:[bx]
	db	0x8B, 0xF8			; mov di, ax
	mov	word [bp - 0xc], di
	mov	word [bp - 0xa], dx
	call	0x3A3:FarToLinear
	add	sp, 4
	sub	ax, word [bp - 0xc]
	sbb	dx, word [bp - 0xa]
	mov	word [bp - 8], ax
	jmp	short L0905
L08EC:
	mov	ax, es
		les	bx, es:[si + 0x1c]
	mov	cx, word es:[bx]
	mov	dx, word es:[bx + 2]
	mov	es, ax
	sub	cx, word es:[si]
	sbb	dx, word es:[si + 2]
	mov	word [bp - 8], cx
L0905:
	mov	word [bp - 6], dx
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	cmp	word [bp - 6], dx
	jl	short L0920
	jle	short L0918
	jmp	near L088C
L0918:
	cmp	word [bp - 8], ax
	jbe	short L0920
	jmp	near L088C
L0920:
	cmp	word [bp + 0xe], 0
	je	short L093C
	push	0x393
	call	0xF4A:0x3E4		; seg022
	add	sp, 2
L0931:
	mov	ax, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	pop	si
	pop	di
	leave
	retf
	nop
L093C:
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	pop	di
	leave
	retf
	nop
FindRec:
	enter	4, 0
	push	si
	les	si, [ChainPtr+0xc]
	mov	ax, word es:[si + 0x1c]
	mov	dx, word es:[si + 0x1e]
	db	0x8B, 0xD8			; mov bx, ax
	mov	cx, word [bp + 6]
	mov	ds, dx
L095C:
	mov	ax, word [bp + 8]
	cmp	word [bx], cx
	jne	short L0968
	cmp	word [bx + 2], ax
	je	short L0978
L0968:
		lds	bx, [bx + 0x1c]
	mov	ax, ds
	db	0x0B, 0xC3			; or ax, bx
	jne	short L095C
	mov	ax, DGROUP
	mov	ds, ax
	jmp	short L0984
L0978:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, ds
	mov	cx, DGROUP
	mov	ds, cx
	pop	si
	leave
	retf
L0984:
	push	word [bp + 8]
	push	cx
	push	0x3b7
	call	0xF4A:0x3E4		; seg022
	add	sp, 6
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	leave
	retf
	nop
FindUnlink:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
		call	FindRec
	db	0x8B, 0xE5			; mov sp, bp
	push	dx
	push	ax
	push	cs
		call	UnlinkRec
	leave
	retf
	nop
UnlinkRec:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, word [bp + 6]
	mov	es, word [bp + 8]
	mov	ax, es
		les	bx, es:[si + 0x20]
	mov	cx, es
	mov	es, ax
	mov	dx, word es:[si + 0x1c]
	mov	di, word es:[si + 0x1e]
	mov	es, cx
	mov	word es:[bx + 0x1c], dx
	mov	word es:[bx + 0x1e], di
	mov	es, ax
	mov	cx, word es:[si + 0x20]
	mov	dx, word es:[si + 0x22]
		les	bx, es:[si + 0x1c]
	mov	word es:[bx + 0x20], cx
	mov	word es:[bx + 0x22], dx
	push	ax
	push	si
	push	cs
	call	0x1486			; still incbin
	add	sp, 4
	pop	si
	pop	di
	leave
	retf
FindTrim:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
		call	FindRec
	db	0x8B, 0xE5			; mov sp, bp
	push	dx
	push	ax
	push	cs
		call	TrimAfter
	leave
	retf
	nop
TrimAfter:
	enter	8, 0
	push	di
	push	si
	les	bx, [bp + 6]
		les	bx, es:[bx + 0x1c]
	db	0x8B, 0xF3			; mov si, bx
	mov	word [bp - 2], es
	test	byte es:[bx + 0x18], 0x20
	jne	short L0A5A
L0A2D:
	mov	es, word [bp - 2]
		les	bx, es:[si + 0x1c]
	db	0x8B, 0xF3			; mov si, bx
	mov	word [bp - 2], es
	push	word es:[bx + 0x22]
	push	word es:[bx + 0x20]
	db	0x8B, 0xFE			; mov di, si
	mov	word [bp - 8], di
	mov	word [bp - 6], es
	push	cs
		call	UnlinkRec
	add	sp, 4
	les	bx, [bp - 8]
	test	byte es:[bx + 0x18], 0x20
	je	short L0A2D
L0A5A:
	pop	si
	pop	di
	leave
	retf
DropOldest:
	enter	0x12, 0
	push	si
	db	0x2B, 0xC0			; sub ax, ax
	mov	word [bp - 0xe], ax
	mov	word [bp - 0x10], ax
	mov	ax, word [bp + 6]
	mov	word [bp - 6], ax
	mov	word [bp - 8], 0
	les	si, [ChainPtr+4]
	mov	ax, word es:[si + 0x1c]
	mov	dx, word es:[si + 0x1e]
	db	0x8B, 0xD8			; mov bx, ax
	mov	ds, dx
L0A86:
	test	byte [bx + 0x18], 8
	je	short L0AC4
	mov	al, byte [bx + 0x18]
	and	ax, strict word 7
	mov	word [bp - 0x12], ax
	cmp	ax, word [bp - 6]
	ja	short L0AAE
	mov	ax, word [bp - 6]
	cmp	word [bp - 0x12], ax
	jne	short L0AC4
	mov	ax, word ss:[RecSeq]
	sub	ax, word [bx + 0x1a]
	cmp	ax, word [bp - 8]
	jl	short L0AC4
L0AAE:
	mov	word [bp - 0x10], bx
	mov	word [bp - 0xe], ds
	mov	ax, word [bp - 0x12]
	mov	word [bp - 6], ax
	mov	ax, word ss:[RecSeq]
	sub	ax, word [bx + 0x1a]
	mov	word [bp - 8], ax
L0AC4:
		lds	bx, [bx + 0x1c]
	mov	ax, ds
	db	0x0B, 0xC3			; or ax, bx
	jne	short L0A86
	mov	ax, DGROUP
	mov	ds, ax
	mov	cx, word [bp - 0x10]
	mov	ax, word [bp - 0xe]
	db	0x0B, 0xC1			; or ax, cx
	je	short L0AEE
	mov	ax, word [bp - 0xe]
	push	ax
	push	cx
	push	cs
		call	UnlinkRec
	add	sp, 4
	mov	ax, 1
	pop	si
	leave
	retf
L0AEE:
	db	0x2B, 0xC0			; sub ax, ax
	pop	si
	leave
	retf
	nop

; MoveFound and MoveFlag find the record first. MovePtr passes the
; caller's pointer. All three enter MoveRec. Flag 81h is the fixed
; value. MoveRec copies the 12-byte name, asks InsertRec for a new
; record, and copies the bytes across in pieces no larger than C000h.
; A failed insert tries DropOldest and asks again.

MoveFound:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	0x81
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
	call	FindRec
	add	sp, 4
	push	dx
	push	ax
	push	cs
	call	MoveRec
	leave
	retf
	nop
MovePtr:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	0x81
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
	call	MoveRec
	leave
	retf
MoveFlag:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	word [bp + 0xa]
	push	word [bp + 8]
	push	word [bp + 6]
	push	cs
	call	FindRec
	add	sp, 4
	push	dx
	push	ax
	push	cs
	call	MoveRec
	leave
	retf
	nop
MoveRec:
	enter	0x32, 0
	push	di
	push	si
	mov	ax, word [bp + 6]
	mov	dx, word [bp + 8]
	db	0x8B, 0xF8			; mov di, ax
	mov	word [bp - 0x1a], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0B5A
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	pop	di
	leave
	retf
L0B5A:
	mov	dx, word [bp - 0x1a]
	add	ax, strict word 4
	push	dx
	push	ax
	push	cs
	call	FindName
	add	sp, 4
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L0B7E
	mov	ax, word [bp - 2]
	push	ax
	push	si
	push	cs
	call	UnlinkRec
	add	sp, 4
L0B7E:
	db	0x2B, 0xF6			; sub si, si
	mov	word [bp - 0x1c], di
	mov	es, word [bp - 0x1a]
L0B86:
	db	0x8B, 0xDF			; mov bx, di
	add	bx, 4
	mov	al, byte es:[bx + si]
	mov	byte [bp + si - 0x32], al
	inc	si
	cmp	si, 0xc
	jl	short L0B86
	mov	byte [bp - 0x26], 0
L0B9B:
	push	0
	mov	es, word [bp - 0x1a]
	mov	ax, word es:[di + 0x18]
	or	al, 0x88
	push	ax
	push	word es:[di + 0x16]
	push	word es:[di + 0x14]
	lea	ax, [bp - 0x32]
	push	ax
	push	cs
	call	InsertRec
	add	sp, 0xa
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 0x1e], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0BD1
	push	word [bp + 0xa]
	push	cs
	call	DropOldest
	add	sp, 2
	db	0x0B, 0xC0			; or ax, ax
	jne	short L0B9B
L0BD1:
	mov	ax, word [bp - 0x1e]
	db	0x0B, 0xC6			; or ax, si
	jne	short L0BDB
	jmp	near L0CA6
L0BDB:
	mov	es, word [bp - 0x1e]
	mov	ax, word es:[si + 0x14]
	mov	dx, word es:[si + 0x16]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	mov	cx, word es:[si]
	mov	bx, word es:[si + 2]
	mov	word [bp - 8], cx
	mov	word [bp - 6], bx
	mov	es, word [bp - 0x1a]
	mov	cx, word es:[di]
	mov	bx, word es:[di + 2]
	mov	word [bp - 0x24], cx
	mov	word [bp - 0x22], bx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0C10
	jmp	near L0CA6
L0C10:
	mov	word [bp - 0x20], si
L0C13:
	cmp	word [bp - 2], 0
	jl	short L0C28
	jg	short L0C22
	cmp	word [bp - 4], 0xc000
	jbe	short L0C28
L0C22:
	mov	si, 0xc000
	jmp	short L0C2B
	nop
L0C28:
	mov	si, word [bp - 4]
L0C2B:
	push	word [bp - 6]
	push	word [bp - 8]
	call	0x3A3:EmsMapFrame
	add	sp, 4
	db	0x8B, 0xF8			; mov di, ax
	mov	word [bp - 0xe], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L0C90
	push	si
	push	word [bp - 0x22]
	push	word [bp - 0x24]
	mov	ax, word [bp - 0xe]
	push	ax
	push	di
	call	0x3A3:CopyBytes
	add	sp, 0xa
	db	0x2B, 0xC9			; sub cx, cx
	add	word [bp - 8], si
	adc	word [bp - 6], cx
	push	word [bp - 0x22]
	push	word [bp - 0x24]
	db	0x8B, 0xF9			; mov di, cx
	call	0x3A3:FarToLinear
	add	sp, 4
	db	0x03, 0xC6			; add ax, si
	db	0x13, 0xD7			; adc dx, di
	call	0x3A3:LinearToFarRegs
	mov	word [bp - 0x24], ax
	mov	word [bp - 0x22], dx
	sub	word [bp - 4], si
	sbb	word [bp - 2], di
	mov	ax, word [bp - 2]
	or	ax, word [bp - 4]
	jne	short L0C13
	mov	si, word [bp - 0x20]
	jmp	short L0CA6
L0C90:
	mov	si, word [bp - 0x20]
	push	word [bp - 0x1e]
	push	si
	push	cs
	call	UnlinkRec
	add	sp, 4
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 0x1e], dx
L0CA6:
	push	word [bp - 0x1a]
	push	word [bp - 0x1c]
	push	cs
	call	UnlinkRec
	add	sp, 4
	db	0x8B, 0xC6			; mov ax, si
	mov	dx, word [bp - 0x1e]
	pop	si
	pop	di
	leave
	retf

; FindName keeps the tail of the far string and walks the chain at
; ChainPtr+4. A 12-byte name match returns that record. A miss returns
; AX 0. AxClear is the retf that returns AX 0.

FindName:
	enter	0xc, 0
	push	di
	push	si
	push	word [bp + 8]
	push	word [bp + 6]
	call	0x3A3:PathTailFar
	add	sp, 4
	db	0x8B, 0xF8			; mov di, ax
	mov	word [bp - 0xa], dx
	mov	ax, word [ChainPtr+4]
	mov	dx, word [ChainPtr+6]
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 6], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L0D20
L0CE5:
	push	0xc
	mov	dx, word [bp - 6]
	add	ax, strict word 4
	push	dx
	push	ax
	push	word [bp - 0xa]
	push	di
	call	0x3A3:StrnDiff
	add	sp, 0xa
	db	0x0B, 0xC0			; or ax, ax
	je	short L0D16
	mov	es, word [bp - 6]
	mov	ax, word es:[si + 0x1c]
	mov	dx, word es:[si + 0x1e]
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 6], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0CE5
	jmp	short L0D20
	nop
L0D16:
	db	0x8B, 0xC6			; mov ax, si
	mov	dx, word [bp - 6]
	pop	si
	pop	di
	leave
	retf
	nop
L0D20:
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	pop	di
	leave
	retf
	nop
AxClear:
	db	0x2B, 0xC0			; sub ax, ax
	retf
	nop

; NameBase looks the near name up and returns the record base.
; CopyByName finds that record, inserts another with the same size,
; and copies the bytes across in pieces no larger than C000h.

NameBase:
	enter	4, 0
	push	si
	push	word [bp + 6]
	push	cs
	call	CopyByName
	add	sp, 2
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 2], dx
	db	0x0B, 0xD0			; or dx, ax
	je	short L0D52
	mov	es, word [bp - 2]
	mov	ax, word es:[si]
	mov	dx, word es:[si + 2]
	pop	si
	leave
	retf
	nop
L0D52:
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	leave
	retf
CopyByName:
	enter	0x1c, 0
	push	di
	push	si
	mov	di, word [bp + 6]
	push	ds
	push	di
	push	cs
	call	FindName
	add	sp, 4
	db	0x8B, 0xF0			; mov si, ax
	mov	word [bp - 0xa], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0D76
	jmp	near L0E4C
L0D76:
	push	0
	mov	es, word [bp - 0xa]
	mov	ax, word es:[si + 0x18]
	and	al, 0x77
	push	ax
	push	word es:[si + 0x16]
	push	word es:[si + 0x14]
	push	di
	push	cs
	call	InsertRec
	add	sp, 0xa
	mov	word [bp - 0x14], ax
	mov	word [bp - 0x12], dx
	db	0x0B, 0xD0			; or dx, ax
	jne	short L0D9F
	jmp	near L0E4C
L0D9F:
	mov	es, word [bp - 0xa]
	mov	ax, word es:[si + 0x14]
	mov	dx, word es:[si + 0x16]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
	mov	cx, word es:[si]
	mov	bx, word es:[si + 2]
	mov	word [bp - 8], cx
	mov	word [bp - 6], bx
	db	0xC4, 0x5E, 0xEC			; les bx, ptr [bp - 0x14]
	mov	cx, word es:[bx]
	mov	si, word es:[bx + 2]
	db	0x8B, 0xF9			; mov di, cx
	mov	word [bp - 0x16], si
	db	0x0B, 0xD0			; or dx, ax
	je	short L0E42
L0DD0:
	cmp	word [bp - 2], 0
	jl	short L0DE4
	jg	short S0DDF
	cmp	word [bp - 4], 0xc000
	jbe	short L0DE4
S0DDF:
	mov	si, 0xc000
	jmp	short L0DE7
L0DE4:
	mov	si, word [bp - 4]
L0DE7:
	push	si
	push	word [bp - 6]
	push	word [bp - 8]
	call	0x3A3:EmsMapFrame
	add	sp, 4
	push	dx
	push	ax
	push	word [bp - 0x16]
	push	di
	call	0x3A3:CopyBytes
	add	sp, 0xa
	db	0x2B, 0xC9			; sub cx, cx
	add	word [bp - 8], si
	adc	word [bp - 6], cx
	push	word [bp - 0x16]
	push	di
	mov	word [bp - 0x1c], si
	mov	word [bp - 0x1a], cx
	call	0x3A3:FarToLinear
	add	sp, 4
	add	ax, word [bp - 0x1c]
	adc	dx, word [bp - 0x1a]
	call	0x3A3:LinearToFarRegs
	db	0x8B, 0xF8			; mov di, ax
	mov	word [bp - 0x16], dx
	mov	ax, word [bp - 0x1c]
	mov	dx, word [bp - 0x1a]
	sub	word [bp - 4], ax
	sbb	word [bp - 2], dx
	mov	ax, word [bp - 2]
	or	ax, word [bp - 4]
	jne	short L0DD0
L0E42:
	mov	ax, word [bp - 0x14]
	mov	dx, word [bp - 0x12]
	pop	si
	pop	di
	leave
	retf
L0E4C:
	db	0x2B, 0xC0			; sub ax, ax
	cwd
	pop	si
	pop	di
	leave
	retf
	nop
	incbin	"Extracted/segments/seg002.bin", 0xE54, 0x1560 - 0xE54
