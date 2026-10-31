; Segment seg003. RecFlag returns the word at offset 18h of a far
; record. NullFar is the retf _main calls. The last two bytes are
; another retf and a nop.

RecFlag:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	les	bx, [bp + 6]
	mov	ax, es:[bx + 0x18]
	leave
	retf
NullFar:
	retf
	nop
	retf
	nop
