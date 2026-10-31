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
	incbin	"Extracted/segments/seg002.bin", 0x2EC, 0x1560 - 0x2EC
