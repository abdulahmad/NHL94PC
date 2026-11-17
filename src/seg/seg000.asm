; Segment seg000. VGA copies, the C startup, file and DOS calls,
; strings, runtime messages, formatted output, and the number
; helpers, and the floating-point emulator. __astart jumps to MscStartup.

; Sixteen zero bytes. The first routine starts on the next paragraph.
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; VGA ports and the graphics window.
VgaGc		equ	0x3CE
VgaGcData	equ	0x3CF
VgaSeq		equ	0x3C4
VgaSeqData	equ	0x3C5
VgaAttr		equ	0x3C0
VgaCrtc		equ	0x3D4
VgaStatus	equ	0x3DA
VgaMem		equ	0xA000


; _outp: write one byte to an I/O port.
; Arguments: port, value. No result.
_outp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	dx
	mov	dx, word [bp+6]			; port
	mov	al, byte [bp+8]			; value
	out	dx, al
	pop	dx
	pop	bp
	retf

; _inp: read one byte from an I/O port.
; Argument: port. Result in AX, high byte cleared.
_inp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	dx
	mov	dx, word [bp+6]			; port
	in	al, dx
	db	0x32, 0xE4			; xor	ah, ah
	pop	dx
	pop	bp
	retf

; VgaCopyWrapped: latched VGA copy of one rectangle out of the circular
; buffer. Write mode 1, all four planes. The source wraps inside the
; buffer. Arguments: destination, column, row, width, height.
VgaCopyWrapped:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc			; graphics controller, mode register
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc			; write mode 1: latched copy
	inc	al
	out	dx, al
	mov	dx, VgaSeq			; sequencer, map mask
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0			; all four planes
	add	ax, strict word 0xf
	out	dx, al
	mov	bx, word [bp+0xa]
	mov	cx, word [bp+8]
	mov	ax, word [0x8fc]		; row stride
	mul	bx
	mov	di, word [bp+6]
	db	0x03, 0xF8			; add	di, ax
	db	0x03, 0xF9			; add	di, cx
	mov	ax, 0x60
	mov	dx, word [0xb0c2]
	shl	dx, 3
	db	0x03, 0xDA			; add	bx, dx
	cmp	bx, 0xb0			; keep the row inside the circular buffer
	jb	.nowrap
	sub	bx, 0xb0
.nowrap:
	mul	bx
	mov	si, 0x86a0			; source base in VGA memory
	db	0x03, 0xF0			; add	si, ax
	db	0x03, 0xF1			; add	si, cx
	mov	dx, word [0xb096]
	db	0x03, 0xF2			; add	si, dx
	db	0x03, 0xF2			; add	si, dx
	mov	ax, word [bp+0xc]
	mov	bx, word [0x8fc]
	db	0x2B, 0xD8			; sub	bx, ax
	mov	dx, 0x60
	db	0x2B, 0xD0			; sub	dx, ax
	cld
	mov	cx, VgaMem			; VGA graphics window
	mov	ds, cx
	mov	es, cx
	db	0x3D, 0x52, 0x00		; cmp	ax, 0x52
	jb	.row
	nop
.row:
	db	0x8B, 0xC8			; mov	cx, ax
	rep movsb
	db	0x03, 0xFB			; add	di, bx
	db	0x03, 0xF2			; add	si, dx
	cmp	si, 0xc8a0			; wrap the source
	jb	.srcok
	sub	si, 0x4200
.srcok:
	dec	word [bp+0xe]			; one less row
	jne	.row
	mov	dx, VgaSeqData			; restore the map mask and the mode
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaCopyToPitch: latched copy of packed rows into a pitched destination.
; Arguments: source, destination, width, height. The row stride is the
; near word used by the other copies.
VgaCopyToPitch:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	bx, word [0x8fc]
	sub	bx, word [bp+0xa]
	mov	ax, VgaMem
	mov	ds, ax
	mov	es, ax
	mov	si, word [bp+6]
	mov	di, word [bp+8]
	mov	ax, word [bp+0xc]
	cld
	mov	dx, word [bp+0xa]
.row:
	db	0x8B, 0xCA			; mov	cx, dx
	rep movsb
	db	0x03, 0xFB			; add	di, bx. destination moves down one row
	dec	ax
	jne	.row
	mov	dx, VgaSeqData
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaCopyFromPitch: latched copy of pitched rows into a packed destination.
; Arguments: source, destination, width, height.
VgaCopyFromPitch:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	bx, word [0x8fc]
	sub	bx, word [bp+0xa]
	mov	ax, VgaMem
	mov	ds, ax
	mov	es, ax
	mov	si, word [bp+6]
	mov	di, word [bp+8]
	mov	ax, word [bp+0xc]
	cld
	mov	dx, word [bp+0xa]
.row:
	db	0x8B, 0xCA			; mov	cx, dx
	rep movsb
	db	0x03, 0xF3			; add	si, bx. source moves down one row
	dec	ax
	jne	.row
	mov	dx, VgaSeqData
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaStamp8: copy an 8-row, 2-byte VGA block. Bit 0x800 selects the
; plane-by-plane path that swaps the two bytes. Bit 0x1000 walks the
; rows backward. Arguments: source, destination, flags.
VgaStamp8:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	bx, 0x60
	mov	ax, VgaMem
	mov	ds, ax
	mov	es, ax
	mov	si, word [bp+6]
	mov	di, word [bp+8]
	test	word [bp+0xa], 0x800		; bit 0x800: swap the two bytes, one plane at a time
	je	.latched
	jmp	.planes
	nop
.latched:
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	cx, 8
	test	word [bp+0xa], 0x1000		; bit 0x1000: walk the rows backward
	je	.down
	shl	bx, 3
	db	0x03, 0xFB			; add	di, bx
	shr	bx, 3
	db	0x2B, 0xFB			; sub	di, bx
	neg	bx
.down:
	sub	bx, 2
	cld
.byte:
	movsb
	movsb
	db	0x03, 0xFB			; add	di, bx
	loop	.byte
	jmp	.done
	nop
.planes:
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xfc			; write mode 0
	out	dx, al
	mov	dx, VgaGc
	mov	al, 4				; read map select
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xfc
	out	dx, al
	mov	dx, VgaSeq
	mov	al, 2
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xf0
	add	al, 8				; start on plane 3
	out	dx, al
	mov	ah, 8
	test	word [bp+0xa], 0x1000
	je	.down2
	shl	bx, 3
	db	0x03, 0xFB			; add	di, bx
	shr	bx, 3
	db	0x2B, 0xFB			; sub	di, bx
	neg	bx
.down2:
	push	si
	push	di
	mov	cx, 4
.plane:
	pop	di
	pop	si
	push	si
	push	di
	push	cx
	mov	cx, 8
.pair:
	mov	al, byte [si]
	mov	byte [es:di+1], al		; exchange the two bytes
	mov	al, byte [si+1]
	mov	byte [es:di], al
	db	0x03, 0xFB			; add	di, bx
	add	si, 2
	loop	.pair
	mov	dx, VgaSeq
	mov	al, 2
	out	dx, al
	inc	dx
	in	al, dx
	and	al, 0xf0
	shr	ah, 1				; next plane
	db	0x02, 0xC4			; add	al, ah
	out	dx, al
	mov	dx, VgaGc
	mov	al, 4
	out	dx, al
	inc	dx
	in	al, dx
	inc	al
	out	dx, al
	pop	cx
	loop	.plane
	in	al, dx
	dec	al
	out	dx, al
	pop	di
	pop	si
.done:
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaPageFlip: wait for the vertical retrace, then point the CRT at the
; other page and set the pel pan. No arguments. Toggles the page word.
VgaPageFlip:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	ax
	push	bx
	push	cx
	push	dx
	mov	bx, word [g_74DC]
	and	bx, 1				; toggle the displayed page
	xor	bx, 1
	mov	word [g_74DC], bx
	cmp	bx, 1
	je	.page1
	mov	di, 0xb00			; the two page bases
	jmp	.origin
	nop
.page1:
	mov	di, 0x4400
.origin:
	mov	ax, word [0x8fc]
	mul	word [0xb092]
	mov	bx, word [0xb094]
	db	0x8B, 0xCB			; mov	cx, bx
	shr	bx, 1
	shr	bx, 1
	db	0x03, 0xD8			; add	bx, ax
	db	0x03, 0xDF			; add	bx, di
	and	cx, 3
	shl	cx, 1
	mov	dx, VgaStatus			; input status: wait until the retrace is active
.blank:
	in	al, dx
	and	al, 8
	cmp	al, 8
	jne	.blank
	mov	dx, VgaCrtc			; CRT start address, high then low
	mov	al, 0xc
	db	0x8A, 0xE7			; mov	ah, bh
	out	dx, ax
	inc	ax
	db	0x8A, 0xE3			; mov	ah, bl
	out	dx, ax
	mov	dx, VgaStatus			; wait until the retrace ends
.visible:
	in	al, dx
	and	al, 8
	cmp	al, 8
	je	.visible
.blank2:
	in	al, dx
	and	al, 8
	cmp	al, 8
	jne	.blank2
	mov	dx, VgaAttr			; attribute controller, pel pan
	mov	al, 0x33
	out	dx, al
	in	al, dx
	and	ax, 0xf0
	db	0x03, 0xC1			; add	ax, cx
	out	dx, al
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	di
	pop	bp
	retf

; VgaStorePlanes: copy two bitmaps into VGA memory, one plane at a time.
; Arguments: pointer to the two far sources, pointer to the two sizes.
; Both images land at the same VGA offset, one after the other.
VgaStorePlanes:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	si
	push	di
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc			; write mode 0
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	mov	ah, 1				; plane 0 first
	and	al, 0xf0
	mov	si, word [bp+8]
	mov	bx, word [si]
	shr	bx, 2				; byte count, four planes
	push	ds
	mov	si, word [bp+6]
	lds	si, [si]			; far pointer to the first bitmap
	mov	cx, VgaMem
	mov	es, cx
	mov	cx, 4
.plane:
	db	0x02, 0xC4			; add	al, ah
	out	dx, al
	db	0x2A, 0xC4			; sub	al, ah
	shl	ah, 1
	push	cx
	db	0x8B, 0xCB			; mov	cx, bx
	mov	di, 0xda78			; fixed VGA destination
	cld
	rep movsb
	pop	cx
	loop	.plane
	pop	ds
	push	ds
	mov	si, word [bp+8]
	mov	bx, word [si+2]
	shr	bx, 2
	mov	si, word [bp+6]
	lds	si, [si+4]			; second bitmap
	mov	cx, 4
	mov	ah, 1
.plane2:
	push	di
	push	cx
	db	0x02, 0xC4			; add	al, ah
	out	dx, al
	db	0x2A, 0xC4			; sub	al, ah
	shl	ah, 1
	db	0x8B, 0xCB			; mov	cx, bx
	rep movsb
	pop	cx
	pop	di
	loop	.plane2
	pop	ds
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	pop	ax
	out	dx, al
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	pop	ax
	out	dx, al
	pop	di
	pop	si
	pop	ds
	pop	bp
	retf

; VgaCopyStrip: latched copy of a fixed strip out of the circular buffer.
; Argument: destination offset.
VgaCopyStrip:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	si
	push	di
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	al, 0xf
	out	dx, al
	mov	ax, word [0xb0c2]		; row inside the circular buffer
	mov	dx, 0x300
	mul	dx
	db	0x8B, 0xF0			; mov	si, ax
	add	si, 0x86a0			; buffer base
	mov	dx, word [0xb096]
	db	0x03, 0xF2			; add	si, dx
	db	0x03, 0xF2			; add	si, dx
	mov	di, word [bp+6]
	mov	ax, 0xb0
	mov	bx, 0x52
	mov	dx, 0xe
	mov	cx, VgaMem
	mov	ds, cx
	mov	es, cx
.row:
	db	0x8B, 0xCB			; mov	cx, bx
	rep movsb
	db	0x03, 0xF2			; add	si, dx
	cmp	si, 0xc8a0			; wrap
	jb	.srcok
	sub	si, 0x4200
.srcok:
	dec	ax
	jne	.row
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	pop	ax
	out	dx, al
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	pop	ax
	out	dx, al
	pop	di
	pop	si
	pop	ds
	pop	bp
	retf

; VgaCopyBlock: latched copy of one fixed-size VGA block.
; Arguments: source, destination.
VgaCopyBlock:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	ax, VgaMem
	mov	ds, ax
	mov	es, ax
	mov	si, word [bp+6]
	mov	di, word [bp+8]
	mov	cx, 0xa40			; fixed length
	cld
	rep movsb
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaCopyBytes: latched copy of a byte count inside VGA memory.
; Arguments: source, destination, count.
VgaCopyBytes:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	ax, VgaMem
	mov	ds, ax
	mov	es, ax
	mov	si, word [bp+6]
	mov	di, word [bp+8]
	mov	cx, word [bp+0xa]		; byte count
	cld
	rep movsb
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; VgaCopyRect: latched copy of a pitched rectangle to another pitched
; rectangle. Arguments: source base, destination base, column, row,
; width, height.
VgaCopyRect:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	push	di
	push	si
	mov	dx, VgaGc
	mov	ax, 5
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xfc
	inc	al
	out	dx, al
	mov	dx, VgaSeq
	mov	ax, 2
	out	dx, al
	inc	dx
	in	al, dx
	push	ax
	and	al, 0xf0
	add	ax, strict word 0xf
	out	dx, al
	mov	bx, word [bp+0xc]
	mov	cx, word [bp+0xa]
	mov	ax, word [0x8fc]		; row stride
	mul	bx
	db	0x8B, 0xF8			; mov	di, ax
	db	0x03, 0xF9			; add	di, cx
	db	0x8B, 0xF7			; mov	si, di
	add	di, word [bp+8]
	add	si, word [bp+6]
	mov	ax, word [bp+0xe]
	mov	bx, word [0x8fc]
	db	0x2B, 0xD8			; sub	bx, ax
	cld
	mov	cx, VgaMem
	mov	ds, cx
	mov	es, cx
.row:
	db	0x8B, 0xC8			; mov	cx, ax
	rep movsb
	db	0x03, 0xFB			; add	di, bx. both source and destination are pitched
	db	0x03, 0xF3			; add	si, bx
	dec	word [bp+0x10]
	jne	.row
	mov	dx, VgaSeqData
	pop	ax
	out	dx, al
	pop	ax
	mov	dx, VgaGcData
	out	dx, al
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf



; NullStartup4, NullStartup6 and _main are labels in seg005.

; Near data in DGROUP (past the load image, not this segment).
DGROUP		equ	0x45C9


; MscStartup: Microsoft C startup. __astart jumps here after the overlay preload.
; DOS 2 or newer, then the DGROUP stack, the near heap, and a zeroed BSS.
; Then two startup stubs in seg005, InitRuntime, _main, and _exit.
; Returns only when DOS is older than 2 (far return into the PSP).
MscStartup:
	mov	ah, 0x30		; DOS version: need 2 or newer
	int	0x21
	cmp	al, 2
	jae	.dos2
	db	0x33, 0xC0			; xor	ax, ax: older than DOS 2: far-return to the PSP
	push	es
	push	ax
	retf

.dos2:
	mov	di, DGROUP		; DI = DGROUP
	mov	si, word [2]		; SI = top of memory, from the PSP
	db	0x2B, 0xF7			; sub	si, di
	cmp	si, 0x1000		; keep the stack inside 64K of DGROUP
	jb	.limited
	mov	si, 0x1000

.limited:
	cli
	mov	ss, di			; SS = DGROUP, SP = the startup stack
	add	sp, 0xe36e
	sti
	jae	.stackok

.nostack:
	push	ss			; the add wrapped: no room for the stack
	pop	ds
	push	cs
	call	__FF_MSGBANNER		; banner, then R6000
	db	0x33, 0xC0			; xor	ax, ax
	push	ax
	push	cs
	call	__NMSG_WRITE
	mov	ax, 0x4cff		; terminate, status 255
	int	0x21

.stackok:
	db	0x8B, 0xC6			; mov	ax, si
	mov	cl, 4
	shl	ax, cl
	dec	ax
	mov	word [ss:g_851A], ax	; top offset of DGROUP
	mov	bx, 0x851c
	mov	word [ss:bx], ss
	and	sp, 0xfffe		; keep SP even
	mov	word [ss:bx+4], sp
	mov	ax, 0xfffe		; stack sentinels used by the overflow check
	push	ax
	mov	word [ss:bx+0xa], sp
	not	ax
	push	ax
	mov	word [ss:bx+6], sp
	mov	word [ss:bx+8], sp
	mov	word [ss:g_8516], sp
	db	0x03, 0xF7			; add	si, di
	mov	word [2], si
	mov	bx, es
	db	0x2B, 0xDE			; sub	bx, si
	neg	bx
	mov	ah, 0x4a		; shrink the DOS memory block to the program
	int	0x21
	mov	word [ss:__psp], ds	; save the PSP
	push	ss
	pop	es
	cld
	mov	di, 0x8ed6		; zero the BSS
	mov	cx, 0xe370
	db	0x2B, 0xCF			; sub	cx, di
	db	0x33, 0xC0			; xor	ax, ax
	rep stosb
	push	ss
	pop	ds
	mov	cx, word [g_8AE2]	; optional near hook, skipped when the word is 0
	jcxz	.afterhook
	call	cx

.afterhook:
	call	0x08F9:NullStartup6	; startup stub in seg005
	call	0x08F9:NullStartup4	; startup stub in seg005
	db	0x33, 0xED			; xor	bp, bp: end the stack frame chain before the runtime init
	call	0:InitRuntime
	push	ss
	pop	ds
	push	word [g_8577]		; environ, argv, argc (medium model, near pointers)
	push	word [g_8575]
	push	word [g_8573]
	call	0x08F9:_main		; _main
	push	ax			; status from _main
	push	cs
	call	_exit			; _exit(status)
	ret

; __cintDIV: integer divide-by-zero (interrupt 0). DS is set from the
; DGROUP word below, then AmsgExit prints R6003 and aborts.
__cintDIV:
	mov	ax, word [cs:CintdivDgroup]	; DGROUP word after this routine
	mov	ds, ax
	mov	ax, 3			; R6003 integer divide by 0
	mov	word [ss:g_8518], _exit	; errors leave through _exit
AmsgExit:
	push	ax			; message number is already in AX
	push	cs
	call	__FF_MSGBANNER
	push	cs
	call	__NMSG_WRITE
	cmp	word [ss:g_8AE4], 0xd6d6; CodeView is present when this word is the signature
	jne	.nodebug
	pop	ax
	push	ax
	call	word [ss:g_8AE8]

.nodebug:
	mov	ax, 0xff		; exit(255)
	push	ax
	push	cs
	call	word [g_8518]
; DGROUP, read by __cintDIV. The pad byte puts InitRuntime on the next instruction.
CintdivDgroup:
	dw	DGROUP
	db	0

; InitRuntime: install the divide handler, inherit _C_FILE_INFO into _osfile,
; mark device handles, and run the initializer table through _initterm.
; Far, no arguments. Returns to MscStartup.
InitRuntime:
	mov	ax, 0x3500		; remember the original interrupt 0 vector
	int	0x21
	mov	word [g_8542], bx
	mov	word [g_8544], es
	push	cs
	pop	ds
	mov	ax, 0x2500		; interrupt 0 -> __cintDIV
	mov	dx, __cintDIV
	int	0x21
	push	ss
	pop	ds
	mov	cx, word [g_8AF6]	; count of floating-point environment hooks; 0 skips them
	jcxz	.nofp
	mov	es, word [__psp]
	mov	si, word [es:0x2c]	; environment segment from the PSP
	lds	ax, [g_8AF8]
	mov	dx, ds
	db	0x33, 0xDB			; xor	bx, bx
	call	far [ss:g_8AF4]		; let the hook parse the environment
	jae	.fpok
	push	ss
	pop	ds
	jmp	FpFail			; hook failed: R6002 floating-point support not loaded

.fpok:
	lds	ax, [ss:g_8AFC]
	mov	dx, ds
	mov	bx, 3
	call	far [ss:g_8AF4]
	push	ss
	pop	ds

.nofp:
	mov	es, word [__psp]
	mov	cx, word [es:0x2c]	; walk the environment for _C_FILE_INFO=
	jcxz	.noinfo
	mov	es, cx
	db	0x33, 0xFF			; xor	di, di

.nextenv:
	cmp	byte [es:di], 0
	je	.noinfo
	mov	cx, 0xd			; 13 bytes: the name and the equals sign
	mov	si, 0x8534
	repe cmpsb
	je	.gotinfo
	mov	cx, 0x7fff
	db	0x33, 0xC0			; xor	ax, ax
	repne scasb
	jne	.noinfo
	jmp	.nextenv

.gotinfo:
	push	es			; decode A-P nibble pairs into _osfile
	push	ds
	pop	es
	pop	ds
	db	0x8B, 0xF7			; mov	si, di
	mov	di, _osfile
	mov	cl, 4

.decnib:
	lodsb
	sub	al, 0x41
	jb	.infoend
	shl	al, cl
	xchg	dx, ax
	lodsb
	sub	al, 0x41
	jb	.infoend
	db	0x0A, 0xC2			; or	al, dl
	stosb
	jmp	.decnib

.infoend:
	push	ss
	pop	ds

.noinfo:
	mov	bx, 4			; handles 4..0: clear the device bit, set it if IOCTL says device

.nexthandle:
	and	byte [bx+_osfile], 0xbf
	mov	ax, 0x4400
	int	0x21
	jb	.nextdec
	test	dl, 0x80
	je	.nextdec
	or	byte [bx+_osfile], 0x40

.nextdec:
	dec	bx
	jns	.nexthandle
	mov	si, 0x8b00		; initializer tables. The first span is empty
	mov	di, 0x8b00
	call	_initterm
	mov	si, 0x8b00
	mov	di, 0x8b04
	call	_initterm
	retf

; _exit: C exit. Run atexit terminators, flush files, return to DOS.
; Argument: status. Does not return.
_exit:
	push	bp			; cx = 0: terminators, then DOS
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x33, 0xC9			; xor	cx, cx
	jmp	ExitCommon

; __exit: C _exit. Skip atexit, still flush and return to DOS.
; Argument: status. Does not return.
__exit:
	push	bp			; cx = 1: no terminators, then DOS
	db	0x8B, 0xEC			; mov	bp, sp
	mov	cx, 1
	jmp	ExitCommon

; _cexit: C _cexit. Run atexit and flush, then return to the caller.
; Argument: status (ignored). Returns.
_cexit:
	push	bp			; cx = 0x100: terminators, then return
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	cx, 0x100
	jmp	ExitCommon

; __cexit: C _c_exit. Flush only, then return to the caller.
; Argument: status (ignored). Returns.
__cexit:
	push	bp			; cx = 0x101: no terminators, then return
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	cx, 0x101

ExitCommon:
	push	cx
	db	0x0A, 0xC9			; or	cl, cl: cl == 0 runs the atexit tables
	jne	.after_atexit
	mov	si, 0x90b8
	mov	di, 0x9138
	call	_initterm
	mov	si, 0x8b04
	mov	di, 0x8b08
	call	_initterm
	cmp	word [g_8AE4], 0xd6d6	; debugger termination hook
	jne	.after_atexit
	call	word [g_8AEA]

.after_atexit:
	mov	si, 0x8b08
	mov	di, 0x8b08
	call	_initterm
	mov	si, 0x8b08
	mov	di, 0x8b08
	call	_initterm
	call	0:__nullcheck		; null-pointer check. AX != 0 means the low bytes of DGROUP changed
	db	0x0B, 0xC0			; or	ax, ax
	je	.doclose
	pop	ax
	db	0x0A, 0xE4			; or	ah, ah
	push	ax
	jne	.doclose
	cmp	word [bp+6], 0		; a zero status from _exit becomes 255
	jne	.doclose
	mov	word [bp+6], 0xff

.doclose:
	call	ExitRestore
	pop	ax
	db	0x0A, 0xE4			; or	ah, ah
	jne	.return
	mov	ax, word [bp+6]		; AH = 4Ch, status in AL
	mov	ah, 0x4c
	int	0x21

.return:
	pop	di			; _cexit / __cexit return to the caller
	pop	si
	pop	bp
	retf

; ExitRestore: put interrupt 0 back and drop the math error hook.
; Near, no arguments.
ExitRestore:
	mov	cx, word [g_8AF6]	; put interrupt 0 back
	jcxz	.nomathexit
	mov	bx, 2
	call	far [g_8AF4]

.nomathexit:
	push	ds
	lds	dx, [g_8542]
	mov	ax, 0x2500
	int	0x21
	pop	ds
	cmp	byte [g_8580], 0	; math error vector, if one was installed
	je	.restored
	push	ds
	mov	al, byte [g_8581]
	lds	dx, [g_8582]
	mov	ah, 0x25
	int	0x21
	pop	ds

.restored:
	ret

; _initterm: call each far pointer in [si, di), from the top down.
; A null pointer is skipped. Near. si = start, di = end.
_initterm:
	db	0x3B, 0xF7			; cmp	si, di: stop once di has walked down to si
	jae	.none
	sub	di, 4			; next far pointer, toward the start
	mov	ax, word [di]
	or	ax, word [di+2]
	je	_initterm
	call	far [di]
	jmp	_initterm

.none:
	ret

; __chkstk: grow the stack by AX bytes. Far. On overflow, R6000 via
; AmsgExit, or the alternate handler if one was stored.
; The return address is popped and pushed again so SP moves under it.
__chkstk:
	pop	cx			; pop the far return, then drop SP by AX
	pop	dx
	db	0x8B, 0xDC			; mov	bx, sp
	db	0x2B, 0xD8			; sub	bx, ax
	jb	.overflow
	cmp	bx, word [g_858A]	; below the stack limit
	jb	.overflow
	db	0x8B, 0xE3			; mov	sp, bx
	push	dx
	push	cx
	retf

.overflow:
	push	dx
	push	cx
	mov	ax, word [g_8586]	; 0xFFFF means no alternate handler
	inc	ax
	jne	.altstack
	db	0x33, 0xC0			; xor	ax, ax
	jmp	AmsgExit		; AX = 0: R6000 stack overflow

.altstack:
	jmp	far [g_8586]		; jump to the alternate stack-overflow handler


; Low-level C files, DOS calls, strings, and the runtime messages.


; _printf: print to the standard output.
; Prepares that FILE, formats, then flushes.
; Argument: format, then the values. Result is the _output count.
_printf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	push	di
	push	si
	mov	si, 0x86d2
	push	si
	call	_stbuf
	add	sp, 2
	db	0x8B, 0xF8			; mov	di, ax
	lea	ax, [bp+8]
	push	ax
	push	word [bp+6]
	mov	ax, 0x86d2
	push	ax
	call	0:_output
	add	sp, 6
	mov	word [bp-4], ax
	mov	ax, 0x86d2
	push	ax
	push	di
	call	_ftbuf
	add	sp, 4
	mov	ax, word [bp-4]
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; _close: close a C file handle and clear its _osfile byte.
; Argument: handle. Returns 0, or an error through DosRet.
_close:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	bx, word [bp+6]
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short .valid
	mov	ax, 0x900
	stc
	jmp	short .join
.valid:
	mov	ah, 0x3e
	int	0x21
	jb	short .join
	mov	byte [bx-0x7aa1], 0
.join:
	jmp	near DosRet

; _lseek: move a file position.
; Arguments: handle, offset low, offset high, origin. Result is the new position.
_lseek:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	mov	bx, word [bp+6]
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short .seek
	mov	ax, 0x900
	jmp	short .1
.seek:
	test	word [bp+0xa], 0x8000
	je	short .doseek
	cmp	word [bp+0xc], 0
	je	short .bad
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4201
	int	0x21
	jb	short .2
	test	word [bp+0xc], 2
	jne	short .fromend
	add	ax, word [bp+8]
	adc	dx, word [bp+0xa]
	jns	short .doseek
.bad:
	mov	ax, 0x1600
.1:
	stc
	jmp	short .2
.fromend:
	mov	word [bp-2], dx
	mov	word [bp-4], ax
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4202
	int	0x21
	add	ax, word [bp+8]
	adc	dx, word [bp+0xa]
	jns	short .doseek
	mov	cx, word [bp-2]
	mov	dx, word [bp-4]
	mov	ax, 0x4200
	int	0x21
	jmp	short .bad
.doseek:
	mov	dx, word [bp+8]
	mov	cx, word [bp+0xa]
	mov	al, byte [bp+0xc]
	mov	ah, 0x42
	int	0x21
	jb	short .2
	and	byte [bx-0x7aa1], 0xfd
.2:
	jmp	near DosRetLong

; _sopen: open a file with a sharing mode, then the same path as _open.
; Arguments: path, access, share.
_sopen:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	db	0x32, 0xFF			; xor	bh, bh
	cmp	byte [g_8558], 3
	jb	short .noshare
	mov	bh, byte [bp+0xa]
.noshare:
	mov	ax, word [bp+0xc]
	mov	word [bp+0xa], ax
	jmp	short OpenBody

; _open: open a file and record text or binary in _osfile.
; Arguments: path, access flags.
_open:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	db	0x32, 0xFF			; xor	bh, bh

OpenBody:
	mov	byte [bp-2], bh
	mov	ax, word [bp+8]
	db	0x8B, 0xC8			; mov	cx, ax
	mov	byte [bp-4], 0
	test	ax, 0x8000
	jne	short .haveflag
	test	ax, 0x4000
	jne	short .binary
	test	byte [0x8875], 0x80
	jne	short .haveflag
.binary:
	mov	byte [bp-4], 0x80
.haveflag:
	mov	dx, word [bp+6]
	and	al, 3
	db	0x0A, 0xC7			; or	al, bh
	mov	ah, 0x3d
	int	0x21
	jae	short .opened
	db	0x3D, 0x02, 0x00			; cmp	ax, 2
	jne	short .fail
	test	cx, 0x100
	je	short .fail
	jmp	near .9
.fail:
	stc
	jmp	near DosRetLong
.opened:
	xchg	bx, ax
	db	0x8B, 0xC1			; mov	ax, cx
	and	ax, 0x500
	cmp	ax, 0x500
	jne	short .1
	mov	ah, 0x3e
	int	0x21
	mov	ax, 0x1100
	jmp	short .fail
.1:
	mov	byte [bp-3], 1
	mov	ax, 0x4400
	int	0x21
	test	dl, 0x80
	je	short .2
	or	byte [bp-4], 0x40
.2:
	test	byte [bp-4], 0x40
	je	short .3
	jmp	near .15
.3:
	mov	ax, word [bp+8]
	test	ax, 0x200
	je	short .5
	test	ax, 3
	je	short .4
	db	0x33, 0xC9			; xor	cx, cx
	mov	ah, 0x40
	int	0x21
	jmp	near .15
.4:
	mov	ah, 0x3e
	int	0x21
	mov	dx, word [bp+6]
	mov	ax, 0x4300
	int	0x21
	jmp	short .11
.5:
	test	byte [bp-4], 0x80
	jne	short .6
	jmp	near .15
.6:
	test	ax, 2
	jne	short .7
	jmp	near .15
.7:
	mov	cx, 0xffff
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4202
	int	0x21
	neg	cx
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	db	0x0B, 0xC0			; or	ax, ax
	je	short .8
	cmp	byte [bp-1], 0x1a
	jne	short .8
	neg	cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4202
	int	0x21
	db	0x33, 0xC9			; xor	cx, cx
	mov	ah, 0x40
	int	0x21
.8:
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4200
	int	0x21
	jmp	short .15
.9:
	mov	byte [bp-3], 0
	mov	cx, word [bp+0xa]
	call	.20
	mov	word [bp+0xa], cx
	test	byte [bp-2], 0xff
	jne	short .10
	test	word [bp+8], 2
	jne	short .11
.10:
	and	cl, 0xfe
.11:
	mov	dx, word [bp+6]
	mov	ah, 0x3c
	int	0x21
	jae	short .13
.12:
	jmp	near DosRetLong
.13:
	xchg	bx, ax
	test	byte [bp-2], 0xff
	jne	short .14
	test	word [bp+8], 2
	jne	short .15
.14:
	mov	ah, 0x3e
	int	0x21
	mov	al, byte [bp+8]
	and	al, 3
	or	al, byte [bp-2]
	mov	dx, word [bp+6]
	mov	ah, 0x3d
	int	0x21
	jb	short .12
	xchg	bx, ax
	test	byte [bp-3], 1
	jne	short .15
	test	word [bp+0xa], 1
	je	short .15
	or	cl, 1
	mov	dx, word [bp+6]
	mov	ax, 0x4301
	int	0x21
	jb	short .12
.15:
	test	byte [bp-4], 0x40
	jne	short .19
	mov	dx, word [bp+6]
	mov	ax, 0x4300
	int	0x21
	db	0x8B, 0xC1			; mov	ax, cx
	db	0x32, 0xC9			; xor	cl, cl
	db	0x25, 0x01, 0x00			; and	ax, 1
	je	short .16
	mov	cl, 0x10
.16:
	test	word [bp+8], 8
	je	short .17
	or	cl, 0x20
.17:
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short .18
	mov	ah, 0x3e
	int	0x21
	mov	ax, 0x1800
	jmp	near .fail
.18:
	or	cl, byte [bp-4]
	or	cl, 1
	mov	byte [bx-0x7aa1], cl
	db	0x8B, 0xC3			; mov	ax, bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
.19:
	db	0x32, 0xC9			; xor	cl, cl
	jmp	short .17
.20:
	mov	ax, word [0x8552]
	not	ax
	db	0x23, 0xC1			; and	ax, cx
	db	0x33, 0xC9			; xor	cx, cx
	test	al, 0x80
	jne	short .21
	or	cl, 1
.21:
	ret

; _read: read bytes from a C file handle.
; Arguments: handle, buffer, count.
_read:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	mov	bx, word [bp+6]
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short .go
	stc
	mov	ax, 0x900
	jmp	short .8
.go:
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, word [bp+0xa]
	jcxz	.8
	test	byte [bx-0x7aa1], 2
	jne	short .8
	cmp	word [g_8AE4], 0xd6d6
	jne	short .1
	call	word [g_8AE6]
.1:
	mov	cx, word [bp+0xa]
	mov	dx, word [bp+8]
	mov	ah, 0x3f
	int	0x21
	jae	short .2
	mov	ah, 9
	jmp	short .8
.2:
	test	byte [bx-0x7aa1], 0x80
	je	short .8
	and	byte [bx-0x7aa1], 0xfb
	push	si
	push	di
	cld
	db	0x8B, 0xF2			; mov	si, dx
	db	0x8B, 0xFA			; mov	di, dx
	db	0x8B, 0xC8			; mov	cx, ax
	jcxz	.7
	mov	ah, 0xd
	cmp	byte [si], 0xa
	jne	short .3
	or	byte [bx-0x7aa1], 4
.3:
	lodsb
	db	0x3A, 0xC4			; cmp	al, ah
	je	short .9
	cmp	al, 0x1a
	jne	short .4
	or	byte [bx-0x7aa1], 2
	jmp	short .6
.4:
	mov	byte [di], al
	inc	di
.5:
	loop	.3
.6:
	db	0x8B, 0xC7			; mov	ax, di
	db	0x2B, 0xC2			; sub	ax, dx
.7:
	pop	di
	pop	si
.8:
	jmp	near DosRetLong
.9:
	cmp	cx, 1
	je	short .10
	cmp	byte [si], 0xa
	je	short .5
	jmp	short .4
.10:
	test	byte [bx-0x7aa1], 0x40
	je	short .12
	mov	ax, 0x4400
	int	0x21
	test	dx, 0x20
	jne	short .11
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	jb	short .7
.11:
	mov	al, 0xa
	jmp	short .15
.12:
	mov	byte [bp-1], 0
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	jb	short .7
	db	0x0B, 0xC0			; or	ax, ax
	je	short .14
	cmp	word [bp+0xa], 1
	je	short .17
.13:
	mov	cx, 0xffff
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4201
	int	0x21
	mov	cx, 1
	cmp	byte [bp-1], 0xa
	je	short .16
.14:
	mov	al, 0xd
.15:
	mov	dx, word [bp+8]
	jmp	short .4
.16:
	mov	dx, word [bp+8]
	jmp	short .5
.17:
	cmp	byte [bp-1], 0xa
	jne	short .13
	jmp	short .11
	db	0

; _write: write bytes, expanding newlines when the handle is text.
; Arguments: handle, buffer, count.
_write:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 8
	mov	bx, word [bp+6]
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short .go
	mov	ax, 0x900
	stc
.1:
	jmp	near DosRetLong
.go:
	cmp	word [g_8AE4], 0xd6d6
	jne	short .2
	call	word [g_8AE6]
.2:
	test	byte [bx-0x7aa1], 0x20
	je	short .3
	mov	ax, 0x4202
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	int	0x21
	jb	short .1
.3:
	test	byte [bx-0x7aa1], 0x80
	je	short .13
	mov	dx, word [bp+8]
	push	ds
	pop	es
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [bp-2], ax
	mov	word [bp-4], ax
	cld
	push	di
	push	si
	db	0x8B, 0xFA			; mov	di, dx
	db	0x8B, 0xF2			; mov	si, dx
	mov	word [bp-8], sp
	mov	cx, word [bp+0xa]
	jcxz	.8
	mov	al, 0xa
	repne scasb
	jne	short .12
	call	0:0x1D8E
	cmp	ax, 0xa8
	jbe	short .14
	sub	sp, 2
	db	0x8B, 0xDC			; mov	bx, sp
	mov	dx, 0x200
	cmp	ax, 0x228
	jae	short .4
	mov	dx, 0x80
.4:
	db	0x2B, 0xE2			; sub	sp, dx
	db	0x8B, 0xD4			; mov	dx, sp
	db	0x8B, 0xFA			; mov	di, dx
	push	ss
	pop	es
	mov	cx, word [bp+0xa]
.5:
	lodsb
	cmp	al, 0xa
	je	short .9
.6:
	db	0x3B, 0xFB			; cmp	di, bx
	je	short .11
.7:
	stosb
	loop	.5
	call	.15
.8:
	jmp	short .20
.9:
	mov	al, 0xd
	db	0x3B, 0xFB			; cmp	di, bx
	jne	short .10
	call	.15
.10:
	stosb
	mov	al, 0xa
	inc	word [bp-4]
	jmp	short .6
.11:
	call	.15
	jmp	short .7
.12:
	pop	si
	pop	di
.13:
	jmp	short .23
.14:
	mov	ax, 0xfffc
	push	cs
	call	__chkstk
.15:
	push	ax
	push	bx
	push	cx
	db	0x8B, 0xCF			; mov	cx, di
	db	0x2B, 0xCA			; sub	cx, dx
	jcxz	.16
	push	cx
	mov	bx, word [bp+6]
	mov	ah, 0x40
	int	0x21
	pop	cx
	jb	short .17
	add	word [bp-2], ax
	db	0x3B, 0xC8			; cmp	cx, ax
	ja	short .17
.16:
	pop	cx
	pop	bx
	pop	ax
	db	0x8B, 0xFA			; mov	di, dx
	ret
.17:
	lahf
	add	sp, 8
	cmp	word [bp-2], 0
	jne	short .20
	sahf
	jae	short .18
	mov	ah, 9
	jmp	short .21
.18:
	test	byte [bx-0x7aa1], 0x40
	je	short .19
	mov	bx, word [bp+8]
	cmp	byte [bx], 0x1a
	jne	short .19
	clc
	jmp	short .21
.19:
	stc
	mov	ax, 0x1c00
	jmp	short .21
.20:
	mov	ax, word [bp-2]
	sub	ax, word [bp-4]
.21:
	mov	sp, word [bp-8]
	pop	si
	pop	di
.22:
	jmp	near DosRetLong
.23:
	mov	cx, word [bp+0xa]
	db	0x0B, 0xC9			; or	cx, cx
	jne	short .24
	db	0x8B, 0xC1			; mov	ax, cx
	jmp	near DosRetLong
.24:
	mov	dx, word [bp+8]
	mov	ah, 0x40
	int	0x21
	jae	short .25
	mov	ah, 9
	jmp	short .22
.25:
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .22
	test	byte [bx-0x7aa1], 0x40
	je	short .26
	db	0x8B, 0xDA			; mov	bx, dx
	cmp	byte [bx], 0x1a
	jne	short .26
	clc
	jmp	short .22
.26:
	stc
	mov	ax, 0x1c00
	jmp	short .22

Rt0C2C:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	mov	ax, ds
	mov	es, ax
	mov	di, word [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	lea	si, [di-1]
	mov	di, word [bp+8]
	mov	cx, 0xffff
	repne scasb
	not	cx
	db	0x2B, 0xF9			; sub	di, cx
	db	0x87, 0xFE			; xchg	si, di
	mov	ax, word [bp+6]
	test	si, 1
	je	short .1
	movsb
	dec	cx
.1:
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf
	db	0

; _strcpy: copy a string, a word at a time once the destination is even.
; Arguments: destination, source. Preserves SI and DI.
_strcpy:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	mov	si, word [bp+8]
	db	0x8B, 0xFE			; mov	di, si
	mov	ax, ds
	mov	es, ax
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	mov	di, word [bp+6]
	db	0x8B, 0xC7			; mov	ax, di
	test	al, 1
	je	short .words
	movsb
	dec	cx
.words:
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf

; _strlen: length of a string, not counting the zero.
; Argument: string. Result in AX.
_strlen:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	mov	ax, ds
	mov	es, ax
	mov	di, word [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	dec	cx
	xchg	cx, ax
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf
	db	0

; _strncpy: copy at most a count of bytes, then pad with zeros.
; Arguments: destination, source, count. Result is the destination.
_strncpy:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	push	ds
	pop	es
	mov	di, word [bp+6]
	mov	si, word [bp+8]
	db	0x8B, 0xDF			; mov	bx, di
	mov	cx, word [bp+0xa]
	jcxz	.done
.copy:
	lodsb
	db	0x0A, 0xC0			; or	al, al
	je	short .pad
	stosb
	loop	.copy
.pad:
	db	0x32, 0xC0			; xor	al, al
	rep stosb
.done:
	db	0x8B, 0xC3			; mov	ax, bx
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

JumpAhead:
	jmp	near _atol
	db	0

; WriteStderr: write a C string to handle 2.
; Argument: string.
WriteStderr:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	push	di
	push	si
	mov	si, word [bp+6]
	mov	di, 2
	db	0x0B, 0xF6			; or	si, si
	je	short .1
	cmp	byte [si], 0
	je	short .1
	push	si
	db	0x9A, 0x9E, 0x0C, 0x00, 0x00			; call	0:_strlen
	db	0x03, 0xE7			; add	sp, di
	push	ax
	push	si
	db	0x8B, 0xC7			; mov	ax, di
	push	ax
	db	0x9A, 0xEC, 0x0A, 0x00, 0x00			; call	0:_write
	add	sp, 6
	db	0x8B, 0xC7			; mov	ax, di
	push	ax
	mov	ax, 0x868e
	push	ax
	db	0x8B, 0xC7			; mov	ax, di
	push	ax
	db	0x9A, 0xEC, 0x0A, 0x00, 0x00			; call	0:_write
	add	sp, 6
.1:
	db	0x83, 0x3E, 0x50, 0x85, 0x00			; cmp	word [errno], 0
	jl	short .2
	db	0xA1, 0x50, 0x85			; mov	ax, word [errno]
	cmp	word [0x8a14], ax
	jg	short .3
.2:
	mov	ax, word [0x8a14]
	jmp	short .4
	db	144
.3:
	db	0xA1, 0x50, 0x85			; mov	ax, word [errno]
.4:
	mov	word [bp-2], ax
	mov	bx, word [bp-2]
	shl	bx, 1
	mov	si, word [bx-0x7638]
	push	si
	db	0x9A, 0x9E, 0x0C, 0x00, 0x00			; call	0:_strlen
	db	0x03, 0xE7			; add	sp, di
	push	ax
	push	si
	push	di
	db	0x9A, 0xEC, 0x0A, 0x00, 0x00			; call	0:_write
	add	sp, 6
	mov	ax, 1
	push	ax
	mov	ax, 0x8691
	push	ax
	push	di
	db	0x9A, 0xEC, 0x0A, 0x00, 0x00			; call	0:_write
	add	sp, 6
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

_sprintf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	push	di
	push	si
	mov	byte [g_909C], 0x42
	mov	ax, word [bp+6]
	mov	word [g_909A], ax
	mov	si, 0x9096
	mov	word [si], ax
	mov	word [g_9098], 0x7fff
	lea	ax, [bp+0xa]
	push	ax
	push	word [bp+8]
	db	0x8B, 0xC6			; mov	ax, si
	push	ax
	call	0:_output
	add	sp, 6
	db	0x8B, 0xF8			; mov	di, ax
	dec	word [g_9098]
	js	short .1
	mov	bx, word [g_9096]
	inc	word [g_9096]
	mov	byte [bx], 0
	jmp	short .2
	db	144
.1:
	push	si
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	call	0:0x1710
	add	sp, 4
.2:
	db	0x8B, 0xC7			; mov	ax, di
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; _stricmp: compare two strings without regard to case.
; Arguments: two strings. Result is negative, zero, or positive.
_stricmp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD6			; mov	dx, si
	mov	si, word [bp+8]
	mov	bx, word [bp+6]
	mov	al, 0xff
.1:
	db	0x0A, 0xC0			; or	al, al
	je	short .2
	lodsb
	mov	ah, byte [bx]
	inc	bx
	db	0x3A, 0xE0			; cmp	ah, al
	je	short .1
	sub	al, 0x41
	cmp	al, 0x1a
	db	0x1A, 0xC9			; sbb	cl, cl
	and	cl, 0x20
	db	0x02, 0xC1			; add	al, cl
	add	al, 0x41
	db	0x86, 0xE0			; xchg	al, ah
	sub	al, 0x41
	cmp	al, 0x1a
	db	0x1A, 0xC9			; sbb	cl, cl
	and	cl, 0x20
	db	0x02, 0xC1			; add	al, cl
	add	al, 0x41
	db	0x3A, 0xC4			; cmp	al, ah
	je	short .1
	db	0x1A, 0xC0			; sbb	al, al
	sbb	al, 0xff
.2:
	db	0x98			; cwde
	db	0x8B, 0xF2			; mov	si, dx
	pop	bp
	retf

; StrIndexInSet: index in the first string of the first character that
; also occurs in the second. Result in AX, or -1.
StrIndexInSet:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x20
	push	si
	push	di
	mov	si, word [bp+8]
	mov	ax, ss
	mov	es, ax
	mov	cx, 0x10
	db	0x33, 0xC0			; xor	ax, ax
	lea	di, [bp-0x20]
	rep stosw
.1:
	lodsb
	db	0x0A, 0xC0			; or	al, al
	je	short .2
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	or	byte [bp+di-0x20], al
	jmp	short .1
.2:
	mov	si, word [bp+6]
	mov	bx, 0xffff
.3:
	inc	bx
	lodsb
	and	ax, 0xff
	je	short .4
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	and	al, byte [bp+di-0x20]
	je	short .3
.4:
	xchg	bx, ax
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; _abs: absolute value of a signed int.
; Argument: value. Result in AX.
_abs:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, word [bp+6]
	db	0x99			; cdq
	db	0x33, 0xC2			; xor	ax, dx
	db	0x2B, 0xC2			; sub	ax, dx
	pop	bp
	retf
	db	144

; _onexit: register a function and return its pointer.
_onexit:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, 0xffff
	jmp	short atexit.1

; atexit: register a function. Returns 0, or nothing useful if the table is full.
atexit:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x33, 0xC0			; xor	ax, ax
.1:
	db	0x8B, 0xC8			; mov	cx, ax
	db	0x99			; cdq
	mov	bx, word [g_8694]
	cmp	bx, 0x9138
	je	short .2
	add	word [g_8694], 4
	mov	dx, word [bp+8]
	mov	word [bx+2], dx
	mov	ax, word [bp+6]
	mov	word [bx], ax
	jcxz	.2
	db	0x33, 0xC0			; xor	ax, ax
.2:
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

CallArg:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	cmp	word [bp+0xa], 0
	je	short .2
	mov	cx, word [bp+8]
	jcxz	.2
	dec	cx
	je	short .2
	mov	si, word [bp+6]
.1:
	db	0x8B, 0xF9			; mov	di, cx
	push	si
	add	si, word [bp+0xa]
	push	si
	call	far [bp+0xc]
	add	sp, 4
	db	0x8B, 0xCF			; mov	cx, di
	db	0x0B, 0xC0			; or	ax, ax
	js	short .3
	loop	.1
.2:
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
.3:
	mov	ax, word [bp+8]
	dec	ax
	db	0x33, 0xC9			; xor	cx, cx
.4:
	shr	ax, 1
	loopne	.4
	neg	cx
	mov	ax, 4
	mul	cx
	jb	short .6
	db	0x8B, 0xF0			; mov	si, ax
	call	0:0x1D8E
	db	0x3B, 0xC6			; cmp	ax, si
	jb	short .6
	push	bp
	db	0x8B, 0xFC			; mov	di, sp
	mov	ax, word [bp+8]
	dec	ax
	mul	word [bp+0xa]
	add	ax, word [bp+6]
	push	ax
	push	word [bp+6]
	jmp	short .7
.5:
	pop	bp
	jmp	short .2
.6:
	mov	ax, 0xfffc
	push	cs
	call	__chkstk
	jmp	short .2
.7:
	db	0x3B, 0xE7			; cmp	sp, di
	jae	short .5
.8:
	db	0x8B, 0xEC			; mov	bp, sp
	mov	si, word [bp]
	cmp	si, word [bp+2]
	jb	short .9
	add	sp, 4
	jmp	short .7
.9:
	sub	sp, 4
	mov	dx, word [bp+2]
	mov	word [bp-2], dx
	add	dx, word [ss:di+0x10]
	mov	word [bp-4], si
.10:
	push	dx
.11:
	add	si, word [ss:di+0x10]
	cmp	si, word [bp+2]
	je	short .12
	push	word [bp]
	push	si
	call	far [ss:di+0x12]
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	jg	short .12
	je	short .11
	mov	word [bp-4], si
	jmp	short .11
.12:
	pop	dx
	push	si
	db	0x8B, 0xF2			; mov	si, dx
.13:
	sub	si, word [ss:di+0x10]
	push	si
	push	word [bp]
	call	far [ss:di+0x12]
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	jg	short .15
	je	short .14
	mov	word [bp-2], si
	jmp	short .13
.14:
	cmp	si, word [bp]
	jne	short .13
.15:
	db	0x8B, 0xD6			; mov	dx, si
	pop	si
	db	0x3B, 0xD6			; cmp	dx, si
	jbe	short .16
	mov	ax, word [ss:di+0x10]
	db	0x87, 0xFA			; xchg	dx, di
	call	.18
	db	0x87, 0xFA			; xchg	dx, di
	mov	word [bp-2], dx
	mov	word [bp-4], si
	jmp	short .10
.16:
	mov	ax, word [ss:di+0x10]
	db	0x87, 0xFA			; xchg	dx, di
	db	0x8B, 0xCE			; mov	cx, si
	mov	si, word [bp]
	call	.18
	db	0x8B, 0xF1			; mov	si, cx
	db	0x87, 0xFA			; xchg	dx, di
	mov	si, word [bp+2]
	sub	si, word [bp-2]
	add	si, word [bp]
	sub	si, word [bp-4]
	jb	short .17
	mov	cx, word [bp]
	mov	ax, word [bp-2]
	mov	word [bp], ax
	mov	ax, word [bp-4]
	mov	word [bp-2], ax
	mov	word [bp-4], cx
	jmp	near .8
.17:
	mov	cx, word [bp+2]
	mov	ax, word [bp-4]
	mov	word [bp+2], ax
	mov	ax, word [bp-2]
	mov	word [bp-4], ax
	mov	word [bp-2], cx
	jmp	near .8
.18:
	db	0x8B, 0xD8			; mov	bx, ax
	test	bx, 1
	je	short .19
	dec	bx
	mov	al, byte [bx+si]
	xchg	byte [bx+di], al
	mov	byte [bx+si], al
	je	short .20
.19:
	sub	bx, 2
	mov	ax, word [bx+si]
	xchg	word [bx+di], ax
	mov	word [bx+si], ax
	jne	short .19
.20:
	ret
	db	0

; _srand: set the rand seed.
; Argument: seed.
_srand:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, word [bp+6]
	mov	word [g_8696], ax
	mov	word [g_8698], 0
	pop	bp
	retf
	db	144

; _rand: advance the Microsoft C seed and return the high 15 bits.
_rand:
	mov	ax, 0x43fd
	mov	dx, 3
	push	dx
	push	ax
	push	word [g_8698]
	push	word [g_8696]
	db	0x9A, 0x26, 0x12, 0x00, 0x00			; call	0:__aFlmul
	add	ax, strict word 0x9ec3
	adc	dx, 0x26
	mov	word [g_8696], ax
	mov	word [g_8698], dx
	db	0x8B, 0xC2			; mov	ax, dx
	and	ah, 0x7f
	retf

; _mkdir: create a directory. Shares the path call with _chdir.
; Argument: path.
_mkdir:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x39
	jmp	short ChdirPath

; _chdir: change directory.
; Argument: path.
_chdir:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x3b

ChdirPath:
	mov	dx, word [bp+6]
	int	0x21

ChdirErr:
	jmp	near DosRet

; _rmdir: remove a directory. A wildcard in the name becomes a distinct error.
; Argument: path.
_rmdir:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x3a
	mov	dx, word [bp+6]
	int	0x21
	jae	short ChdirErr
	db	0x3D, 0x10, 0x00			; cmp	ax, 0x10
	jne	short ChdirErr
	xchg	dx, ax
	xchg	bx, ax
.scan:
	mov	al, byte [bx]
	inc	bx
	cmp	al, 0
	je	short .denied
	cmp	al, 0x3f
	je	short .wild
	cmp	al, 0x2a
	jne	short .scan
.wild:
	mov	dl, 3
.denied:
	xchg	dx, ax
	stc
	jmp	short ChdirErr

; _unlink: delete a file.
; Argument: path.
_unlink:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	dx, word [bp+6]
	mov	ah, 0x41
	int	0x21
	jmp	near DosRet
	db	0

; _dos_close: close a DOS handle.
; Argument: handle.
_dos_close:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	bx, word [bp+6]
	mov	ah, 0x3e
	int	0x21
	jmp	near DosRetCode
	db	0

; _dos_creatnew: create a file only if it does not exist.
; Arguments: path, attribute, pointer that receives the handle.
_dos_creatnew:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	bh, 0x5b
	jmp	short DosCreate

; _dos_creat: create or truncate a file.
; Arguments: path, attribute, pointer that receives the handle.
_dos_creat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	bh, 0x3c

DosCreate:
	mov	dx, word [bp+6]
	mov	cx, word [bp+8]
	db	0x8A, 0xE7			; mov	ah, bh
	int	0x21
	jae	short .store
	db	0x3D, 0x50, 0x00			; cmp	ax, 0x50
	stc
	jne	short .join
	mov	ah, 0x11
	jmp	short .join
.store:
	mov	bx, word [bp+0xa]
	mov	word [bx], ax
.join:
	jmp	near DosRetCode

; _dos_findnext: continue a find.
; Argument: the find buffer.
_dos_findnext:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	mov	al, 0x4f
	mov	dx, word [bp+6]
	jmp	short FindCommon

; _dos_findfirst: start a find.
; Arguments: name, attribute, find buffer.
_dos_findfirst:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	mov	al, 0x4e
	mov	dx, word [bp+0xa]

FindCommon:
	mov	ah, 0x2f
	int	0x21
	mov	ah, 0x1a
	int	0x21
	cmp	al, 0x4e
	jne	short .go
	mov	dx, word [bp+6]
	mov	cx, word [bp+8]
.go:
	db	0x8A, 0xE0			; mov	ah, al
	int	0x21
	push	ax
	lahf
	push	ax
	mov	dx, es
	mov	ds, dx
	db	0x8B, 0xD3			; mov	dx, bx
	mov	ah, 0x1a
	int	0x21
	pop	ax
	sahf
	pop	ax
	pop	ds
	jmp	near DosRetCode

; _dos_open: open a file and store the handle.
; Arguments: path, access, pointer that receives the handle.
_dos_open:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	dx, word [bp+6]
	mov	ax, word [bp+8]
	mov	ah, 0x3d
	int	0x21
	jb	short .join
	mov	bx, word [bp+0xa]
	mov	word [bx], ax
.join:
	jmp	near DosRetCode
	db	0

_dos_read:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x3f
	jmp	short _dos_write.1

; _dos_write: write from a far buffer.
; Arguments: handle, far buffer, count.
_dos_write:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x40
.1:
	mov	bx, word [bp+6]
	mov	cx, word [bp+0xc]
	cmp	word [g_8AE4], 0xd6d6
	jne	short .write
	call	word [g_8AE6]
.write:
	push	ds
	lds	dx, [bp+8]
	int	0x21
	pop	ds
	jb	short .2
	mov	bx, word [bp+0xe]
	mov	word [bx], ax
.2:
	jmp	near DosRetCode
	db	0,250,203

; _dos_getdiskfree: free space on a drive.
; Arguments: drive, pointer to the result.
_dos_getdiskfree:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	dl, byte [bp+6]
	mov	ah, 0x36
	int	0x21
	db	0x3D, 0xFF, 0xFF			; cmp	ax, 0xffff
	jne	short .fill
	db	0xC7, 0x06, 0x50, 0x85, 0x16, 0x00			; mov	word [errno], 0x16
	jmp	short .done
.fill:
	push	si
	mov	si, word [bp+8]
	mov	word [si+4], ax
	mov	word [si+2], bx
	mov	word [si+6], cx
	mov	word [si], dx
	pop	si
	db	0x33, 0xC0			; xor	ax, ax
.done:
	pop	bp
	retf
	db	0,251,203

; _dos_gettime: time of day into hour, minute, second, and hundredths.
; Argument: pointer to four bytes.
_dos_gettime:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x2c
	int	0x21
	mov	bx, word [bp+6]
	mov	byte [bx], ch
	mov	byte [bx+1], cl
	mov	byte [bx+2], dh
	mov	byte [bx+3], dl
	db	0x33, 0xC0			; xor	ax, ax
	pop	bp
	retf
	db	0

; __aFldiv: signed divide of two longs. Result in DX:AX. Pops 8 bytes.
__aFldiv:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	push	bx
	db	0x33, 0xFF			; xor	di, di
	mov	ax, word [bp+8]
	db	0x0B, 0xC0			; or	ax, ax
	jge	short .pos
	inc	di
	mov	dx, word [bp+6]
	neg	ax
	neg	dx
	db	0x1D, 0x00, 0x00			; sbb	ax, 0
	mov	word [bp+8], ax
	mov	word [bp+6], dx
.pos:
	mov	ax, word [bp+0xc]
	db	0x0B, 0xC0			; or	ax, ax
	jge	short .1
	inc	di
	mov	dx, word [bp+0xa]
	neg	ax
	neg	dx
	db	0x1D, 0x00, 0x00			; sbb	ax, 0
	mov	word [bp+0xc], ax
	mov	word [bp+0xa], dx
.1:
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .2
	mov	cx, word [bp+0xa]
	mov	ax, word [bp+8]
	db	0x33, 0xD2			; xor	dx, dx
	div	cx
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bp+6]
	div	cx
	db	0x8B, 0xD3			; mov	dx, bx
	jmp	short .6
.2:
	db	0x8B, 0xD8			; mov	bx, ax
	mov	cx, word [bp+0xa]
	mov	dx, word [bp+8]
	mov	ax, word [bp+6]
.3:
	shr	bx, 1
	rcr	cx, 1
	shr	dx, 1
	rcr	ax, 1
	db	0x0B, 0xDB			; or	bx, bx
	jne	short .3
	div	cx
	db	0x8B, 0xF0			; mov	si, ax
	mul	word [bp+0xc]
	xchg	cx, ax
	mov	ax, word [bp+0xa]
	mul	si
	db	0x03, 0xD1			; add	dx, cx
	jb	short .4
	cmp	dx, word [bp+8]
	ja	short .4
	jb	short .5
	cmp	ax, word [bp+6]
	jbe	short .5
.4:
	dec	si
.5:
	db	0x33, 0xD2			; xor	dx, dx
	xchg	si, ax
.6:
	dec	di
	jne	short .7
	neg	dx
	neg	ax
	sbb	dx, 0
.7:
	pop	bx
	pop	si
	pop	di
	pop	bp
	retf	8

; __aFlmul: multiply two longs. DX:AX is the product.
; Arguments: low and high of each long. Pops 8 bytes.
__aFlmul:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, word [bp+8]
	mov	cx, word [bp+0xc]
	db	0x0B, 0xC8			; or	cx, ax
	mov	cx, word [bp+0xa]
	jne	short .full
	mov	ax, word [bp+6]
	mul	cx
	pop	bp
	retf	8
.full:
	push	bx
	mul	cx
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bp+6]
	mul	word [bp+0xc]
	db	0x03, 0xD8			; add	bx, ax
	mov	ax, word [bp+6]
	mul	cx
	db	0x03, 0xD3			; add	dx, bx
	pop	bx
	pop	bp
	retf	8

; __aFlshl: shift DX:AX left by CX.
; No frame. Result in DX:AX.
__aFlshl:
	db	0x32, 0xED			; xor	ch, ch
	jcxz	.done
.1:
	shl	ax, 1
	rcl	dx, 1
	loop	.1
.done:
	retf
	db	0

; __aFlsar: arithmetic shift of DX:AX right by CX.
__aFlsar:
	db	0x32, 0xED			; xor	ch, ch
	jcxz	.done
.1:
	sar	dx, 1
	rcr	ax, 1
	loop	.1
.done:
	retf
	db	0

LongShlAt:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	bx
	mov	bx, word [bp+6]
	mov	ax, word [bx]
	mov	dx, word [bx+2]
	mov	cx, word [bp+8]
	push	cs
	call	__aFlshl
	mov	word [bx], ax
	mov	word [bx+2], dx
	pop	bx
	pop	bp
	retf	4
	db	0

LongSarAt:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	bx
	mov	bx, word [bp+6]
	mov	ax, word [bx]
	mov	dx, word [bx+2]
	mov	cx, word [bp+8]
	push	cs
	call	__aFlsar
	mov	word [bx], ax
	mov	word [bx+2], dx
	pop	bx
	pop	bp
	retf	4
	db	0

; __aFlshr: logical shift of DX:AX right by CX.
__aFlshr:
	db	0x32, 0xED			; xor	ch, ch
	jcxz	.done
.1:
	shr	dx, 1
	rcr	ax, 1
	loop	.1
.done:
	retf
	db	0

; _fmemcpy: copy a count of bytes through far pointers.
; Arguments: destination, source, count.
_fmemcpy:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	cx, word [bp+0xe]
	push	ds
	push	di
	push	si
	jcxz	.done
	lds	si, [bp+0xa]
	les	di, [bp+6]
.1:
	db	0x8B, 0xC1			; mov	ax, cx
	dec	ax
	db	0x8B, 0xD7			; mov	dx, di
	not	dx
	db	0x2B, 0xC2			; sub	ax, dx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC2			; add	ax, dx
	db	0x8B, 0xD6			; mov	dx, si
	not	dx
	db	0x2B, 0xC2			; sub	ax, dx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC2			; add	ax, dx
	inc	ax
	xchg	cx, ax
	db	0x2B, 0xC1			; sub	ax, cx
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	xchg	cx, ax
	jcxz	.done
	db	0x0B, 0xF6			; or	si, si
	jne	short .2
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
.2:
	db	0x0B, 0xFF			; or	di, di
	jne	short .1
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
	jmp	short .1
.done:
	mov	ax, word [bp+6]
	mov	dx, word [bp+8]
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

_fmemcmp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD6			; mov	dx, si
	push	ds
	lds	si, [bp+0xa]
	les	bx, [bp+6]
	mov	al, 0xff
.1:
	db	0x0A, 0xC0			; or	al, al
	je	short .2
	lodsb
	mov	ah, byte [es:bx]
	inc	bx
	db	0x3A, 0xE0			; cmp	ah, al
	je	short .1
	sub	al, 0x41
	cmp	al, 0x1a
	db	0x1A, 0xC9			; sbb	cl, cl
	and	cl, 0x20
	db	0x02, 0xC1			; add	al, cl
	add	al, 0x41
	db	0x86, 0xE0			; xchg	al, ah
	sub	al, 0x41
	cmp	al, 0x1a
	db	0x1A, 0xC9			; sbb	cl, cl
	and	cl, 0x20
	db	0x02, 0xC1			; add	al, cl
	add	al, 0x41
	db	0x3A, 0xC4			; cmp	al, ah
	je	short .1
	db	0x1A, 0xC0			; sbb	al, al
	sbb	al, 0xff
.2:
	db	0x98			; cwde
	pop	ds
	db	0x8B, 0xF2			; mov	si, dx
	pop	bp
	retf
	db	0

_fmemchr:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	push	ds
	mov	cx, word [bp+0xe]
	jcxz	.none
	db	0x8B, 0xD9			; mov	bx, cx
	les	di, [bp+6]
	db	0x8B, 0xF7			; mov	si, di
	db	0x33, 0xC0			; xor	ax, ax
	repne scasb
	neg	cx
	db	0x03, 0xCB			; add	cx, bx
	db	0x8B, 0xFE			; mov	di, si
	lds	si, [bp+0xa]
	repe cmpsb
	mov	al, byte [si-1]
	db	0x33, 0xC9			; xor	cx, cx
	cmp	al, byte [es:di-1]
	ja	short .1
	je	short .none
	dec	cx
	dec	cx
.1:
	not	cx
.none:
	db	0x8B, 0xC1			; mov	ax, cx
	pop	ds
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	0

RetOnly:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	les	di, [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	dec	cx
	xchg	cx, ax
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf
	db	0

RetOnly2:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	push	ds
	lds	si, [bp+6]
	les	di, [bp+0xa]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	db	0x2B, 0xF9			; sub	di, cx
	repe cmpsb
	je	short .1
	db	0x1B, 0xC0			; sbb	ax, ax
	db	0x1D, 0xFF, 0xFF			; sbb	ax, 0xffff
.1:
	pop	ds
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf
	db	0

; _fstrcpy: length of a far string.
_fstrcpy:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	push	ds
	lds	si, [bp+0xa]
	db	0x8B, 0xFE			; mov	di, si
	mov	ax, ds
	mov	es, ax
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	les	di, [bp+6]
	db	0x8B, 0xC7			; mov	ax, di
	test	al, 1
	je	short .1
	movsb
	dec	cx
.1:
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	ds
	mov	dx, es
	pop	bp
	retf

; _fstrcat: append one far string to another.
_fstrcat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	push	ds
	les	di, [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	lea	si, [di-1]
	les	di, [bp+0xa]
	mov	cx, 0xffff
	repne scasb
	not	cx
	db	0x2B, 0xF9			; sub	di, cx
	mov	ax, es
	mov	ds, ax
	mov	es, word [bp+8]
	db	0x87, 0xFE			; xchg	si, di
	mov	ax, word [bp+6]
	test	si, 1
	je	short .1
	movsb
	dec	cx
.1:
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	ds
	mov	dx, es
	pop	bp
	retf

; _fmemset: fill a far buffer.
; Arguments: destination, byte, count.
_fmemset:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	cx, word [bp+0xc]
	jcxz	.done
	push	di
	les	di, [bp+6]
	db	0x8B, 0xD7			; mov	dx, di
	neg	dx
	je	short .1
	db	0x2B, 0xD1			; sub	dx, cx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xD3			; and	dx, bx
	db	0x03, 0xD1			; add	dx, cx
	db	0x87, 0xD1			; xchg	cx, dx
	db	0x2B, 0xD1			; sub	dx, cx
.1:
	mov	ax, word [bp+0xa]
	db	0x8A, 0xE0			; mov	ah, al
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
	db	0x87, 0xD1			; xchg	cx, dx
	jcxz	.2
	mov	bx, es
	add	bx, 0x1000
	mov	es, bx
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
.2:
	pop	di
.done:
	mov	ax, word [bp+6]
	mov	dx, word [bp+8]
	pop	bp
	retf

_fstrcspn:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x20
	push	si
	push	di
	push	ds
	lds	si, [bp+0xa]
	mov	ax, ss
	mov	es, ax
	mov	cx, 0x10
	db	0x33, 0xC0			; xor	ax, ax
	lea	di, [bp-0x20]
	rep stosw
.1:
	lodsb
	db	0x0A, 0xC0			; or	al, al
	je	short .2
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	or	byte [bp+di-0x20], al
	jmp	short .1
.2:
	lds	si, [bp+6]
	mov	bx, 0xffff
.3:
	inc	bx
	lodsb
	and	ax, 0xff
	je	short .4
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	and	al, byte [bp+di-0x20]
	je	short .3
.4:
	xchg	bx, ax
	pop	ds
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; _fmemmove: copy far bytes, including when the ranges overlap.
_fmemmove:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	cx, word [bp+0xe]
	push	ds
	push	di
	push	si
	db	0x0B, 0xC9			; or	cx, cx
	jne	short .copy
	jmp	near .done
.copy:
	lds	si, [bp+0xa]
	les	di, [bp+6]
	push	ds
	push	si
	push	es
	push	di
	call	0:0x1DF6
	mov	cx, word [bp+0xe]
	db	0x0B, 0xD2			; or	dx, dx
	js	short .5
	db	0x2B, 0xC1			; sub	ax, cx
	sbb	dx, 0
	jae	short .5
	dec	cx
	db	0x03, 0xF1			; add	si, cx
	jae	short .1
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
.1:
	db	0x03, 0xF9			; add	di, cx
	jae	short .2
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
.2:
	inc	cx
.3:
	db	0x8B, 0xC1			; mov	ax, cx
	dec	ax
	db	0x2B, 0xC7			; sub	ax, di
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC7			; add	ax, di
	db	0x2B, 0xC6			; sub	ax, si
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC6			; add	ax, si
	inc	ax
	xchg	cx, ax
	db	0x2B, 0xC1			; sub	ax, cx
	std
	rep movsb
	cld
	xchg	cx, ax
	jcxz	.done
	cmp	si, -1
	jne	short .4
	mov	ax, ds
	sub	ax, 0x1000
	mov	ds, ax
.4:
	cmp	di, -1
	jne	short .3
	mov	ax, es
	sub	ax, 0x1000
	mov	es, ax
	jmp	short .3
.5:
	db	0x8B, 0xC1			; mov	ax, cx
	dec	ax
	db	0x8B, 0xD7			; mov	dx, di
	not	dx
	db	0x2B, 0xC2			; sub	ax, dx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC2			; add	ax, dx
	db	0x8B, 0xD6			; mov	dx, si
	not	dx
	db	0x2B, 0xC2			; sub	ax, dx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xC3			; and	ax, bx
	db	0x03, 0xC2			; add	ax, dx
	inc	ax
	xchg	cx, ax
	db	0x2B, 0xC1			; sub	ax, cx
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
	xchg	cx, ax
	jcxz	.done
	db	0x0B, 0xF6			; or	si, si
	jne	short .6
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
.6:
	db	0x0B, 0xFF			; or	di, di
	jne	short .5
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
	jmp	short .5
.done:
	mov	ax, word [bp+6]
	mov	dx, word [bp+8]
	pop	si
	pop	di
	pop	ds
	pop	bp
	retf

; EmulatedFloat: floating-point work done with the emulator interrupts.
EmulatedFloat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xc
	push	bx
	push	cx
	push	si
	push	di
	int	0x35
.1:
	jle	short .1
	int	0x3d
	mov	ax, word [bp-2]
	or	ah, 0xc
	mov	word [bp-4], ax
	int	0x35
	outsb
	cld
	int	0x3b
	jle	short 0x15D9
	int	0x35
	outsb
	dec	byte [bp+di-0xbba]
	mov	dx, word [bp-0xa]
	pop	di
	pop	si
	pop	cx
	pop	bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	0

; CopyTemplate: copy twelve words from one near buffer to another.
CopyTemplate:
	push	si
	push	di
	mov	ax, ds
	mov	es, ax
	mov	si, 0x869a
	mov	di, 0x8876
	mov	cx, 0xc
	rep movsw
	pop	di
	pop	si
	retf

; __FF_MSGBANNER: print the runtime banner lines.
; No arguments.
__FF_MSGBANNER:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, 0xfc
	push	ax
	push	cs
	call	__NMSG_WRITE
	cmp	word [g_86B4], 0
	je	short .nobannerhook
	call	far [g_86B2]
.nobannerhook:
	mov	ax, 0xff
	push	ax
	push	cs
	call	__NMSG_WRITE
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; FpFail: report R6002, floating-point support not loaded, and abort.
FpFail:
	mov	ax, 2
	jmp	near AmsgExit

; __nullcheck: checksum the first bytes of DGROUP.
; If it does not match, report the null-pointer assignment.
__nullcheck:
	push	si
	db	0x33, 0xF6			; xor	si, si
	mov	cx, 0x42
	db	0x32, 0xE4			; xor	ah, ah
	cld
.sum:
	lodsb
	db	0x32, 0xE0			; xor	ah, al
	loop	.sum
	xor	ah, 0x55
	je	short .ok
	push	cs
	call	__FF_MSGBANNER
	mov	ax, 1
	push	ax
	push	cs
	call	__NMSG_WRITE
	mov	ax, 1
.ok:
	pop	si
	retf

; __NMSG_TEXT: find the text for a runtime message number.
; Argument: number. Result is the string, or 0.
__NMSG_TEXT:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	push	ds
	pop	es
	mov	dx, word [bp+6]
	mov	si, 0x8d26
.next:
	lodsw
	db	0x3B, 0xC2			; cmp	ax, dx
	je	short .found
	inc	ax
	xchg	si, ax
	je	short .found
	xchg	di, ax
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	db	0x8B, 0xF7			; mov	si, di
	jmp	short .next
.found:
	xchg	si, ax
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	2

; __NMSG_WRITE: write one runtime message to handle 2.
; Argument: message number.
__NMSG_WRITE:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	word [bp+6]
	push	cs
	call	__NMSG_TEXT
	db	0x0B, 0xC0			; or	ax, ax
	je	short .none
	xchg	dx, ax
	db	0x8B, 0xFA			; mov	di, dx
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 0xffff
	repne scasb
	not	cx
	dec	cx
	mov	bx, 2
	cmp	word [g_8AE4], 0xd6d6
	jne	short .nodebug
	call	word [g_8AE6]
.nodebug:
	mov	ah, 0x40
	int	0x21
.none:
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	2
	db	0

; DosRet: success returns 0. A carry returns -1 after mapping the DOS error.
DosRet:
	jb	short DosRetBad

DosRetZero:
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; DosRetCode: success returns 0. A carry maps the error and returns its low byte.
DosRetCode:
	jae	short DosRetZero
	push	ax
	call	DosMapErr
	pop	ax
	db	0x32, 0xE4			; xor	ah, ah
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; DosRetLong: success keeps DX:AX. A carry maps the error and returns -1.
DosRetLong:
	jae	short DosRetLeave

DosRetBad:
	call	DosMapErr
	mov	ax, 0xffff
	db	0x99			; cdq

DosRetLeave:
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; DosRetErrno: map the DOS error in AX and return.
DosRetErrno:
	db	0x32, 0xE4			; xor	ah, ah
	call	DosMapErr
	retf

; DosMapErr: store the DOS error in _doserrno and the C errno.
DosMapErr:
	db	0xA2, 0x5B, 0x85			; mov	byte [_doserrno], al
	db	0x0A, 0xE4			; or	ah, ah
	jne	short .high
	cmp	byte [g_8558], 3
	jb	short .low
	cmp	al, 0x22
	jae	short .1
	cmp	al, 0x20
	jb	short .low
	mov	al, 5
	jmp	short .map
.low:
	cmp	al, 0x13
	jbe	short .map
.1:
	mov	al, 0x13
.map:
	mov	bx, 0x86b6
	xlatb
.2:
	db	0x98			; cwde
	db	0xA3, 0x50, 0x85			; mov	word [errno], ax
	ret
.high:
	db	0x8A, 0xC4			; mov	al, ah
	jmp	short .2
	db	0

; Formatted output: flush, buffer, and _output.


; _flsbuf: flush one FILE buffer. The FILE is the second argument.
_flsbuf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	si, word [bp+8]
	mov	al, byte [si+6]
	test	al, 0x82
	je	short .done
	test	al, 0x40
	jne	short .done
	mov	word [si+2], 0
	test	al, 1
	je	short .1
	test	al, 0x10
	je	short .done
	mov	cx, word [si+4]
	mov	word [si], cx
	and	al, 0xfe
.1:
	or	al, 2
	and	al, 0xef
	mov	byte [si+6], al
	db	0x8B, 0xFE			; mov	di, si
	sub	di, 0x86ca
	add	di, 0x876a
	db	0x33, 0xDB			; xor	bx, bx
	mov	bl, byte [si+7]
	test	al, 8
	jne	short .5
	test	al, 4
	jne	short .3
	test	byte [di], 1
	jne	short .5
	cmp	si, 0x86d2
	je	short .2
	cmp	si, 0x86da
	je	short .2
	cmp	si, 0x86ea
	jne	short .4
.2:
	test	byte [bx-0x7aa1], 0x40
	je	short .4
.3:
	mov	cx, 1
	push	cx
	lea	di, [bp+6]
	push	di
	push	bx
	push	cs
	call	_write
	add	sp, 6
	mov	cx, 1
	jmp	short .7
.done:
	mov	ax, 0xffff
	or	byte [si+6], 0x20
	jmp	short .9
.4:
	push	bx
	push	si
	call	ConvertFloat
	pop	bx
	pop	bx
	test	byte [si+6], 8
	je	short .3
.5:
	mov	cx, word [si]
	mov	dx, word [si+4]
	db	0x2B, 0xCA			; sub	cx, dx
	inc	dx
	mov	word [si], dx
	mov	dx, word [di+2]
	dec	dx
	mov	word [si+2], dx
	jcxz	.8
	push	cx
	push	cx
	push	word [si+4]
	push	bx
	push	cs
	call	_write
	add	sp, 6
	pop	cx
.6:
	mov	di, word [si+4]
	mov	dx, word [bp+6]
	mov	byte [di], dl
.7:
	db	0x3B, 0xC1			; cmp	ax, cx
	jne	short .done
	db	0x33, 0xC0			; xor	ax, ax
	mov	al, byte [bp+6]
	jmp	short .9
.8:
	db	0x33, 0xC0			; xor	ax, ax
	test	byte [bx-0x7aa1], 0x20
	je	short .6
	mov	cx, 2
	push	cx
	push	ax
	push	ax
	push	bx
	push	cs
	call	_lseek
	add	sp, 8
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xC8			; mov	cx, ax
	jmp	short .6
.9:
	pop	di
	pop	si
	pop	bp
	retf
	db	0

_stbuf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	si, word [bp+4]
	mov	bx, 0x880c
	cmp	si, 0x86d2
	je	short .stdio
	mov	bx, 0x880e
	cmp	si, 0x86da
	je	short .stdio
	mov	bx, 0x8810
	cmp	si, 0x86ea
	jne	short .nobuf
.stdio:
	db	0x8B, 0xFE			; mov	di, si
	sub	di, 0x86ca
	add	di, 0x876a
	test	byte [si+6], 0xc
	jne	short .nobuf
	test	byte [di], 1
	jne	short .nobuf
	mov	ax, word [bx]
	db	0x0B, 0xC0			; or	ax, ax
	je	short .2
.1:
	mov	word [si+4], ax
	mov	word [si], ax
	mov	word [si+2], 0x200
	mov	word [di+2], 0x200
	or	byte [si+6], 2
	mov	byte [di], 0x11
	mov	ax, 1
	jmp	short .3
.2:
	push	bx
	mov	ax, 0x200
	push	ax
	call	0:JmpFpConvert
	pop	bx
	pop	bx
	db	0x0B, 0xC0			; or	ax, ax
	je	short .nobuf
	mov	word [bx], ax
	jmp	short .1
.nobuf:
	db	0x33, 0xC0			; xor	ax, ax
.3:
	pop	di
	pop	si
	pop	bp
	ret

_ftbuf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	si, word [bp+6]
	db	0x8B, 0xFE			; mov	di, si
	sub	di, 0x86ca
	add	di, 0x876a
	test	byte [di], 0x10
	je	short .out
	db	0x33, 0xDB			; xor	bx, bx
	mov	bl, byte [si+7]
	test	byte [bx-0x7aa1], 0x40
	je	short .out
	push	si
	push	cs
	call	fflush
	pop	ax
	cmp	word [bp+4], 0
	je	short .out
	db	0x33, 0xC0			; xor	ax, ax
	mov	byte [di], al
	mov	word [di+2], ax
	mov	word [si], ax
	mov	word [si+4], ax
.out:
	pop	di
	pop	si
	pop	bp
	ret
	db	13,25,24,25,44,25,96,25,140,25,148,25,189,25,239,25

_output:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, 0x171
	push	cs
	call	__chkstk
	push	si
	push	di
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [bp-8], ax
	mov	byte [bp-5], al
.next:
	mov	si, word [bp+8]
	lodsb
	mov	word [bp+8], si
	mov	byte [bp-2], al
	db	0x0A, 0xC0			; or	al, al
	je	short .1
	cmp	word [bp-8], 0
	jge	short .2
.1:
	mov	ax, word [bp-8]
	jmp	near .90
.2:
	mov	bx, 0x8812
	sub	al, 0x20
	cmp	al, 0x58
	ja	short .3
	xlatb
	and	al, 0xf
	jmp	short .4
.3:
	mov	al, 0
.4:
	mov	cl, 3
	shl	al, cl
	add	al, byte [bp-5]
	xlatb
	inc	cl
	shr	al, cl
	mov	byte [bp-5], al
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	shl	bx, 1
	jmp	word [cs:bx+0x18a6]
.widthdig:
	mov	dl, byte [bp-2]
	mov	cx, 1
	call	.82
	jmp	short .next
.reset:
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [bp-0x10], ax
	mov	word [bp-0xa], ax
	mov	word [bp-0x12], ax
	mov	word [bp-4], ax
	dec	ax
	mov	word [bp-0xc], ax
	jmp	short .next
.flags:
	mov	al, byte [bp-2]
	cmp	al, 0x2d
	jne	short .5
	or	byte [bp-4], 4
	jmp	short .next
.5:
	cmp	al, 0x2b
	jne	short .6
	or	byte [bp-4], 1
	jmp	short .next
.6:
	cmp	al, 0x20
	jne	short .7
	or	byte [bp-4], 2
	jmp	near .next
.7:
	cmp	al, 0x23
	jne	short .8
	or	byte [bp-4], 0x80
	jmp	near .next
.8:
	or	byte [bp-4], 8
	jmp	near .next
.widthstar:
	mov	cl, byte [bp-2]
	cmp	cl, 0x2a
	jne	short .9
	call	.70
	db	0x0B, 0xC0			; or	ax, ax
	jns	short .10
	neg	ax
	or	byte [bp-4], 4
	jmp	short .10
.9:
	sub	cl, 0x30
	db	0x32, 0xED			; xor	ch, ch
	mov	ax, word [bp-0xa]
	mov	bx, 0xa
	mul	bx
	db	0x03, 0xC1			; add	ax, cx
.10:
	mov	word [bp-0xa], ax
	jmp	near .next
.prec0:
	mov	word [bp-0xc], 0
	jmp	near .next
.precstar:
	mov	cl, byte [bp-2]
	cmp	cl, 0x2a
	jne	short .11
	call	.70
	db	0x0B, 0xC0			; or	ax, ax
	jns	short .12
	mov	ax, 0xffff
	jmp	short .12
.11:
	sub	cl, 0x30
	db	0x32, 0xED			; xor	ch, ch
	mov	ax, word [bp-0xc]
	mov	bx, 0xa
	mul	bx
	db	0x03, 0xC1			; add	ax, cx
.12:
	mov	word [bp-0xc], ax
	jmp	near .next
.sizech:
	mov	al, byte [bp-2]
	cmp	al, 0x6c
	jne	short .13
	or	byte [bp-4], 0x10
	jmp	short .17
.13:
	cmp	al, 0x46
	jne	short .14
	or	byte [bp-4], 0x20
	jmp	short .17
.14:
	cmp	al, 0x4e
	jne	short .15
	or	byte [bp-3], 0x10
	jmp	short .17
.15:
	cmp	al, 0x4c
	jne	short .16
	or	byte [bp-3], 4
	jmp	short .17
.16:
	or	byte [bp-3], 8
.17:
	jmp	near .next
.convert:
	mov	al, byte [bp-2]
	cmp	al, 0x64
	jne	short .18
	jmp	near .44
.18:
	cmp	al, 0x69
	jne	short .19
	jmp	near .44
.19:
	cmp	al, 0x75
	jne	short .20
	jmp	near .45
.20:
	cmp	al, 0x58
	jne	short .21
	jmp	near .46
.21:
	cmp	al, 0x78
	jne	short .22
	jmp	near .47
.22:
	cmp	al, 0x6f
	jne	short .23
	jmp	near .50
.23:
	cmp	al, 0x63
	je	short .25
	cmp	al, 0x73
	je	short .26
	cmp	al, 0x6e
	je	short .29
	cmp	al, 0x70
	je	short .31
	cmp	al, 0x45
	je	short .24
	cmp	al, 0x47
	je	short .24
	jmp	near .36
.24:
	jmp	near .35
.25:
	call	.70
	lea	di, [bp-0x171]
	push	ss
	pop	es
	stosb
	dec	di
	mov	cx, 1
	jmp	near .62
.26:
	call	.72
	db	0x0B, 0xFF			; or	di, di
	jne	short .27
	mov	ax, es
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .27
	push	ds
	pop	es
	mov	di, 0x886b
	mov	cx, word [g_8871]
	jmp	near .62
.27:
	push	di
	mov	cx, word [bp-0xc]
	jcxz	.28
	db	0x32, 0xC0			; xor	al, al
	repne scasb
	jne	short .28
	dec	di
.28:
	pop	cx
	db	0x2B, 0xF9			; sub	di, cx
	db	0x87, 0xCF			; xchg	di, cx
	jmp	near .62
.29:
	call	.72
	mov	ax, word [bp-8]
	stosw
	test	byte [bp-4], 0x10
	je	short .30
	db	0x33, 0xC0			; xor	ax, ax
	stosw
.30:
	jmp	near .next
.31:
	test	byte [bp-4], 0x30
	jne	short .32
	call	.70
	jmp	short .33
.32:
	call	.71
	test	byte [bp-3], 0x18
	jne	short .33
	mov	byte [bp-1], 7
	mov	cx, 0x10
	push	ss
	pop	es
	push	dx
	db	0x33, 0xD2			; xor	dx, dx
	lea	di, [bp-0x169]
	mov	si, 4
	call	.85
	mov	cx, 0x10
	lea	di, [bp-0x16e]
	pop	ax
	db	0x33, 0xD2			; xor	dx, dx
	mov	si, 4
	call	.85
	mov	byte [bp-0x16d], 0x3a
	mov	cx, 9
	jmp	short .34
.33:
	mov	byte [bp-1], 7
	mov	cx, 0x10
	push	ss
	pop	es
	db	0x33, 0xD2			; xor	dx, dx
	lea	di, [bp-0x16e]
	mov	si, 4
	call	.85
	mov	cx, 4
.34:
	lea	di, [bp-0x171]
	jmp	near .62
.35:
	inc	word [bp-0x12]
.36:
	or	byte [bp-4], 0x40
	mov	al, byte [bp-2]
	or	al, 0x20
	db	0x98			; cwde
	db	0x8B, 0xF0			; mov	si, ax
	cmp	word [bp-0xc], 0
	jg	short .38
	je	short .37
	mov	word [bp-0xc], 6
	jmp	short .38
.37:
	db	0x3D, 0x67, 0x00			; cmp	ax, 0x67
	jne	short .38
	mov	word [bp-0xc], 1
.38:
	lea	di, [bp-0x171]
	push	word [bp-0x12]
	push	word [bp-0xc]
	push	si
	push	di
	push	word [bp+0xa]
	test	byte [bp-3], 4
	je	short .39
	call	far [g_888A]
	add	word [bp+0xa], 0xa
	jmp	short .40
.39:
	call	far [g_8876]
	add	word [bp+0xa], 8
.40:
	add	sp, 0xa
	test	byte [bp-4], 0x80
	je	short .41
	cmp	word [bp-0xc], 0
	jne	short .41
	push	di
	call	far [g_8882]
	add	sp, 2
.41:
	cmp	si, 0x67
	jne	short .42
	test	word [bp-4], 0x80
	jne	short .42
	push	di
	call	far [g_887A]
	add	sp, 2
.42:
	push	ss
	pop	es
	cmp	byte [es:di], 0x2d
	jne	short .43
	inc	di
	or	byte [bp-3], 1
.43:
	mov	cx, 0xffff
	push	di
	mov	al, 0
	repne scasb
	dec	di
	pop	cx
	db	0x2B, 0xF9			; sub	di, cx
	db	0x87, 0xCF			; xchg	di, cx
	jmp	near .62
.44:
	or	byte [bp-4], 0x40
.45:
	mov	byte [bp-6], 0xa
	jmp	short .52
.46:
	mov	byte [bp-1], 7
	jmp	short .48
.47:
	mov	byte [bp-1], 0x27
.48:
	test	byte [bp-4], 0x80
	je	short .49
	mov	word [bp-0x10], 2
	mov	byte [bp-0xe], 0x30
	mov	dl, 0x51
	add	dl, byte [bp-1]
	mov	byte [bp-0xd], dl
.49:
	mov	byte [bp-6], 0x10
	jmp	short .52
.50:
	test	byte [bp-4], 0x80
	je	short .51
	or	byte [bp-3], 2
.51:
	mov	byte [bp-6], 8
.52:
	test	byte [bp-4], 0x10
	je	short .53
	call	.71
	jmp	short .55
.53:
	call	.70
	test	byte [bp-4], 0x40
	je	short .54
	db	0x99			; cdq
	jmp	short .55
.54:
	db	0x33, 0xD2			; xor	dx, dx
.55:
	test	byte [bp-4], 0x40
	je	short .56
	db	0x0B, 0xD2			; or	dx, dx
	jge	short .56
	or	byte [bp-3], 1
	neg	ax
	adc	dx, 0
	neg	dx
.56:
	cmp	word [bp-0xc], 0
	jge	short .57
	mov	word [bp-0xc], 1
	jmp	short .58
.57:
	and	byte [bp-4], 0xf7
.58:
	db	0x8B, 0xD8			; mov	bx, ax
	db	0x0B, 0xDA			; or	bx, dx
	jne	short .59
	mov	word [bp-0x10], 0
.59:
	lea	di, [bp-0x15]
	push	ss
	pop	es
	mov	cl, byte [bp-6]
	db	0x32, 0xED			; xor	ch, ch
	mov	si, word [bp-0xc]
	call	.85
	test	byte [bp-3], 2
	je	short .61
	jcxz	.60
	cmp	byte [es:di], 0x30
	je	short .61
.60:
	dec	di
	mov	byte [es:di], 0x30
	inc	cx
.61:
	jmp	short .62
.62:
	test	byte [bp-4], 0x40
	je	short .65
	test	byte [bp-3], 1
	je	short .63
	mov	byte [bp-0xe], 0x2d
	mov	word [bp-0x10], 1
	jmp	short .65
.63:
	test	byte [bp-4], 1
	je	short .64
	mov	byte [bp-0xe], 0x2b
	mov	word [bp-0x10], 1
	jmp	short .65
.64:
	test	byte [bp-4], 2
	je	short .65
	mov	byte [bp-0xe], 0x20
	mov	word [bp-0x10], 1
.65:
	mov	ax, word [bp-0xa]
	db	0x2B, 0xC1			; sub	ax, cx
	sub	ax, word [bp-0x10]
	jge	short .66
	db	0x33, 0xC0			; xor	ax, ax
.66:
	push	es
	push	di
	push	cx
	test	byte [bp-4], 0xc
	jne	short .67
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x20
	call	.82
.67:
	push	ax
	push	ss
	pop	es
	lea	di, [bp-0xe]
	mov	cx, word [bp-0x10]
	call	.79
	pop	ax
	test	byte [bp-4], 8
	je	short .68
	test	byte [bp-4], 4
	jne	short .68
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x30
	call	.82
.68:
	pop	cx
	pop	di
	pop	es
	push	ax
	call	.79
	pop	ax
	test	byte [bp-4], 4
	je	short .69
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x20
	call	.82
.69:
	jmp	near .next
.getarg:
.70:
	mov	si, word [bp+0xa]
	lodsw
	mov	word [bp+0xa], si
	ret
.71:
	mov	si, word [bp+0xa]
	lodsw
	db	0x8B, 0xD0			; mov	dx, ax
	lodsw
	xchg	dx, ax
	mov	word [bp+0xa], si
	ret
.72:
	test	byte [bp-4], 0x20
	je	short .73
	call	.71
	mov	es, dx
	db	0x8B, 0xF8			; mov	di, ax
	ret
.73:
	call	.70
	db	0x8B, 0xF8			; mov	di, ax
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .74
	mov	es, ax
	ret
.74:
	push	ds
	pop	es
	ret
.75:
	db	0x98			; cwde
	push	di
	mov	bx, word [bp+6]
	dec	word [bx+2]
	js	short .78
	mov	di, word [bx]
	inc	word [bx]
	mov	byte [di], al
.76:
	db	0x33, 0xC0			; xor	ax, ax
.77:
	pop	di
	ret
.78:
	push	es
	push	cx
	push	dx
	push	bx
	push	ax
	push	cs
	call	_flsbuf
	add	sp, 4
	pop	dx
	pop	cx
	pop	es
	db	0x3D, 0xFF, 0xFF			; cmp	ax, 0xffff
	jne	short .76
	jmp	short .77
.79:
	jcxz	.81
	db	0x8B, 0xF7			; mov	si, di
	add	word [bp-8], cx
	push	di
	db	0x33, 0xFF			; xor	di, di
.80:
	db	0x26, 0xAC			; lodsb
	call	.75
	db	0x0B, 0xF8			; or	di, ax
	loop	.80
	db	0x0B, 0xFF			; or	di, di
	pop	di
	je	short .81
	mov	word [bp-8], 0xffff
.81:
	ret
.count:
.82:
	jcxz	.84
	add	word [bp-8], cx
	push	di
	db	0x33, 0xFF			; xor	di, di
.83:
	db	0x8A, 0xC2			; mov	al, dl
	call	.75
	db	0x0B, 0xF8			; or	di, ax
	loop	.83
	db	0x0B, 0xFF			; or	di, di
	pop	di
	je	short .84
	mov	word [bp-8], 0xffff
.84:
	ret
.85:
	std
	push	di
	xchg	bx, ax
.86:
	db	0x0B, 0xF6			; or	si, si
	jg	short .87
	db	0x0B, 0xDB			; or	bx, bx
	jne	short .87
	db	0x0B, 0xD2			; or	dx, dx
	jne	short .87
	jmp	short .89
.87:
	xchg	dx, ax
	db	0x33, 0xD2			; xor	dx, dx
	div	cx
	xchg	bx, ax
	div	cx
	xchg	dx, ax
	db	0x87, 0xD3			; xchg	bx, dx
	add	al, 0x30
	cmp	al, 0x39
	jbe	short .88
	add	al, byte [bp-1]
.88:
	stosb
	db	0x8B, 0xC2			; mov	ax, dx
	dec	si
	jmp	short .86
.89:
	pop	cx
	db	0x2B, 0xCF			; sub	cx, di
	inc	di
	cld
	ret
.90:
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	0,89,90,161,138,133,59,196,115,7,43,196,247,216,82,81
	db	203,51,192,235,249

; Number conversion, fflush, and memory moves.


; _atol: read an optional sign and decimal digits into a long.
; Argument: string. Result in DX:AX.
_atol:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	mov	si, word [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	db	0x99			; cdq
	db	0x33, 0xDB			; xor	bx, bx
.1:
	lodsb
	cmp	al, 0x20
	je	short .1
	cmp	al, 9
	je	short .1
	push	ax
	cmp	al, 0x2d
	je	short .2
	cmp	al, 0x2b
	jne	short .3
.2:
	lodsb
.3:
	cmp	al, 0x39
	ja	short .4
	sub	al, 0x30
	jb	short .4
	shl	bx, 1
	rcl	dx, 1
	db	0x8B, 0xCB			; mov	cx, bx
	db	0x8B, 0xFA			; mov	di, dx
	shl	bx, 1
	rcl	dx, 1
	shl	bx, 1
	rcl	dx, 1
	db	0x03, 0xD9			; add	bx, cx
	db	0x13, 0xD7			; adc	dx, di
	db	0x03, 0xD8			; add	bx, ax
	adc	dx, 0
	jmp	short .2
.4:
	pop	ax
	cmp	al, 0x2d
	xchg	bx, ax
	jne	short .5
	neg	ax
	adc	dx, 0
	neg	dx
.5:
	pop	si
	pop	di
	pop	bp
	retf

Mul16Diff:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, word [bp+8]
	sub	ax, word [bp+0xc]
	db	0x1B, 0xD2			; sbb	dx, dx
	db	0x03, 0xC0			; add	ax, ax
	db	0x13, 0xD2			; adc	dx, dx
	db	0x03, 0xC0			; add	ax, ax
	db	0x13, 0xD2			; adc	dx, dx
	db	0x03, 0xC0			; add	ax, ax
	db	0x13, 0xD2			; adc	dx, dx
	db	0x03, 0xC0			; add	ax, ax
	db	0x13, 0xD2			; adc	dx, dx
	add	ax, word [bp+6]
	adc	dx, 0
	sub	ax, word [bp+0xa]
	sbb	dx, 0
	pop	bp
	retf	8
	db	0

ScanFloat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 6
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	test	byte [bx-0x7a73], 1
	je	short .1
	lea	ax, [bx+0x20]
	jmp	short .2
.1:
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	db	0x98			; cwde
.2:
	db	0x3D, 0x65, 0x00			; cmp	ax, 0x65
	je	short .4
.3:
	inc	word [bp+6]
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	test	byte [bx-0x7a73], 4
	jne	short .3
.4:
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	mov	byte [bp-2], al
	mov	byte [bx], 0x2e
	inc	word [bp+6]
.5:
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	mov	byte [bp-4], al
	mov	al, byte [bp-2]
	mov	byte [bx], al
	mov	al, byte [bp-4]
	mov	byte [bp-2], al
	mov	bx, word [bp+6]
	inc	word [bp+6]
	cmp	byte [bx], 0
	jne	short .5
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

ScanPoint:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	jmp	short .2
.1:
	cmp	byte [bx], 0x2e
	je	short .3
	inc	word [bp+6]
.2:
	mov	bx, word [bp+6]
	cmp	byte [bx], 0
	jne	short .1
.3:
	inc	word [bp+6]
	cmp	byte [bx], 0
	je	short .10
	jmp	short .5
.4:
	cmp	byte [bx], 0x65
	je	short .6
	cmp	byte [bx], 0x45
	je	short .6
	inc	word [bp+6]
.5:
	mov	bx, word [bp+6]
	cmp	byte [bx], 0
	jne	short .4
.6:
	db	0x8B, 0xC3			; mov	ax, bx
	dec	word [bp+6]
	mov	word [bp-2], ax
	jmp	short .8
	db	144
.7:
	dec	word [bp+6]
.8:
	mov	bx, word [bp+6]
	cmp	byte [bx], 0x30
	je	short .7
	cmp	byte [bx], 0x2e
	jne	short .9
	dec	word [bp+6]
.9:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	al, byte [bx]
	inc	word [bp+6]
	mov	bx, word [bp+6]
	mov	byte [bx], al
	db	0x0A, 0xC0			; or	al, al
	jne	short .9
.10:
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

FloatLoad:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	mov	bx, word [bp+6]
	int	0x39
	pop	es
	int	0x38
	push	ss
	push	ss
	db	141,205,57,216,205,57,126,254,205,61,138,102,255,158,114,8
	db	184,1,0,139,229,93,203,144,43,192,139,229,93,203

FormatFloat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	mov	ax, word [bp+6]
	dec	ax
	je	short .3
	dec	ax
	je	short .1
	push	word [bp+0xc]
	db	0x9A, 0xF8, 0x27, 0x00, 0x00			; call	0:SkipSpace
	add	sp, 2
	db	0x8B, 0xD8			; mov	bx, ax
	int	0x39
	pop	es
	les	bx, [bp+8]
	int	0x3c
	fstp	dword [bx]
	jmp	short .2
	db	144
.1:
	push	word [bp+0xc]
	db	0x9A, 0x18, 0x2C, 0x00, 0x00			; call	0:FloatStatus
	add	sp, 2
	les	bx, [bp+8]
	int	0x3c
	db	0xDB, 0x3F			; fstp	xword [bx]
.2:
	int	0x3d
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
.3:
	push	word [bp+0xc]
	db	0x9A, 0xF8, 0x27, 0x00, 0x00			; call	0:SkipSpace
	add	sp, 2
	db	0x8B, 0xF0			; mov	si, ax
	les	di, [bp+8]
	movsw
	movsw
	movsw
	movsw
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FloatBuf:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	push	di
	push	si
	cmp	byte [g_8A1C], 0
	je	short .5
	mov	bx, word [g_909E]
	mov	word [bp-2], bx
	cmp	word [bx], 0x2d
	jne	short .1
	mov	si, 1
	jmp	short .2
.1:
	db	0x2B, 0xF6			; sub	si, si
.2:
	add	si, word [bp+8]
	push	si
	cmp	word [bp+0xa], 0
	jle	short .3
	mov	ax, 1
	jmp	short .4
	db	144
.3:
	db	0x2B, 0xC0			; sub	ax, ax
.4:
	push	ax
	call	FormatLen
	jmp	short .10
.5:
	mov	bx, word [bp+6]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	db	0x9A, 0xD2, 0x2B, 0x00, 0x00			; call	0:PackArgs
	add	sp, 8
	mov	word [bp-2], ax
	push	ax
	mov	ax, word [bp+0xa]
	inc	ax
	push	ax
	cmp	word [bp+0xa], 0
	jle	short .6
	mov	ax, 1
	jmp	short .7
.6:
	db	0x2B, 0xC0			; sub	ax, ax
.7:
	mov	bx, word [bp-2]
	mov	word [bp-4], ax
	cmp	word [bx], 0x2d
	jne	short .8
	mov	ax, 1
	jmp	short .9
.8:
	db	0x2B, 0xC0			; sub	ax, ax
.9:
	add	ax, word [bp-4]
	add	ax, word [bp+8]
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
.10:
	mov	si, word [bp+8]
	mov	bx, word [bp-2]
	cmp	word [bx], 0x2d
	jne	short .11
	mov	byte [si], 0x2d
	inc	si
.11:
	cmp	word [bp+0xa], 0
	jle	short .12
	mov	al, byte [si+1]
	mov	byte [si], al
	lea	ax, [si+1]
	db	0x8B, 0xF0			; mov	si, ax
	mov	byte [si], 0x2e
.12:
	mov	ax, 0x8a16
	push	ax
	cmp	byte [g_8A1C], 1
	db	0x1B, 0xC0			; sbb	ax, ax
	neg	ax
	add	ax, word [bp+0xa]
	db	0x03, 0xC6			; add	ax, si
	push	ax
	call	0:0xC6C
	add	sp, 4
	db	0x8B, 0xF0			; mov	si, ax
	cmp	word [bp+0xc], 0
	je	short .13
	mov	byte [si], 0x45
.13:
	inc	si
	mov	bx, word [bp-2]
	mov	bx, word [bx+6]
	cmp	byte [bx], 0x30
	je	short .17
	mov	bx, word [bp-2]
	mov	di, word [bx+2]
	dec	di
	jns	short .14
	db	0x8B, 0xC7			; mov	ax, di
	neg	ax
	db	0x8B, 0xF8			; mov	di, ax
	mov	byte [si], 0x2d
.14:
	inc	si
	cmp	di, 0x64
	jl	short .15
	db	0x8B, 0xC7			; mov	ax, di
	mov	cx, 0x64
	db	0x99			; cdq
	idiv	cx
	add	byte [si], al
	db	0x8B, 0xC7			; mov	ax, di
	db	0x99			; cdq
	idiv	cx
	db	0x8B, 0xFA			; mov	di, dx
.15:
	inc	si
	cmp	di, 0xa
	jl	short .16
	db	0x8B, 0xC7			; mov	ax, di
	mov	cx, 0xa
	db	0x99			; cdq
	idiv	cx
	add	byte [si], al
	db	0x8B, 0xC7			; mov	ax, di
	db	0x99			; cdq
	idiv	cx
	db	0x8B, 0xFA			; mov	di, dx
.16:
	db	0x8B, 0xC7			; mov	ax, di
	inc	si
	add	byte [si], al
.17:
	mov	ax, word [bp+8]
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

FloatToStr:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	mov	byte [g_8A1C], 1
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatBuf
	mov	byte [g_8A1C], 0
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FloatWidth:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 6
	push	si
	cmp	byte [g_8A1C], 0
	je	short .3
	mov	bx, word [g_909E]
	mov	word [bp-2], bx
	cmp	word [bx], 0x2d
	jne	short .1
	mov	si, 1
	jmp	short .2
	db	144
.1:
	db	0x2B, 0xF6			; sub	si, si
.2:
	add	si, word [bp+8]
	mov	ax, word [g_8A1E]
	cmp	word [bp+0xa], ax
	jne	short .6
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx+si], 0x30
	db	0x03, 0xDE			; add	bx, si
	inc	bx
	mov	byte [bx], 0
	jmp	short .6
.3:
	mov	bx, word [bp+6]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	db	0x9A, 0xD2, 0x2B, 0x00, 0x00			; call	0:PackArgs
	add	sp, 8
	mov	word [bp-2], ax
	push	ax
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bx+2]
	add	ax, word [bp+0xa]
	push	ax
	cmp	word [bx], 0x2d
	jne	short .4
	mov	ax, 1
	jmp	short .5
	db	144
.4:
	db	0x2B, 0xC0			; sub	ax, ax
.5:
	add	ax, word [bp+8]
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
.6:
	mov	si, word [bp+8]
	mov	bx, word [bp-2]
	cmp	word [bx], 0x2d
	jne	short .7
	mov	byte [si], 0x2d
	inc	si
.7:
	cmp	word [bx+2], 0
	jg	short .8
	push	si
	mov	ax, 1
	push	ax
	call	FormatLen
	mov	byte [si], 0x30
	inc	si
	jmp	short .9
	db	144
.8:
	add	si, word [bx+2]
.9:
	cmp	word [bp+0xa], 0
	jle	short .12
	push	si
	mov	ax, 1
	push	ax
	call	FormatLen
	mov	byte [si], 0x2e
	inc	si
	mov	bx, word [bp-2]
	cmp	word [bx+2], 0
	jge	short .12
	cmp	byte [g_8A1C], 0
	je	short .10
	mov	ax, word [bx+2]
	neg	ax
	jmp	short .11
.10:
	mov	ax, word [bx+2]
	neg	ax
	cmp	ax, word [bp+0xa]
	jle	short .11
	mov	ax, word [bp+0xa]
.11:
	mov	word [bp+0xa], ax
	push	si
	push	ax
	call	FormatLen
	push	word [bp+0xa]
	mov	ax, 0x30
	push	ax
	push	si
	db	0x9A, 0x64, 0x29, 0x00, 0x00			; call	0:_memset
	add	sp, 6
.12:
	mov	ax, word [bp+8]
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

FloatToSci:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	mov	byte [g_8A1C], 1
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatWidth
	mov	byte [g_8A1C], 0
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

FormatOne:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	mov	bx, word [bp+6]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	db	0x9A, 0xD2, 0x2B, 0x00, 0x00			; call	0:PackArgs
	add	sp, 8
	mov	word [g_909E], ax
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bx+2]
	dec	ax
	mov	word [g_8A1E], ax
	push	bx
	push	word [bp+0xa]
	cmp	word [bx], 0x2d
	jne	short .1
	mov	ax, 1
	jmp	short .2
.1:
	db	0x2B, 0xC0			; sub	ax, ax
.2:
	add	ax, word [bp+8]
	mov	word [bp-2], ax
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
	mov	bx, word [g_909E]
	mov	ax, word [bx+2]
	dec	ax
	mov	word [bp-4], ax
	cmp	ax, word [g_8A1E]
	jle	short .3
	mov	al, 1
	jmp	short .4
.3:
	db	0x2A, 0xC0			; sub	al, al
.4:
	mov	byte [g_8A20], al
	mov	ax, word [bp-4]
	mov	word [g_8A1E], ax
	db	0x3D, 0xFC, 0xFF			; cmp	ax, 0xfffc
	jl	short .5
	cmp	ax, word [bp+0xa]
	jl	short .6
.5:
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatToStr
	add	sp, 8
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
.6:
	cmp	byte [g_8A20], 0
	je	short .8
.7:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	cmp	byte [bx], 0
	jne	short .7
	mov	bx, word [bp-2]
	mov	byte [bx-2], 0
.8:
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatToSci
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatExp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+0xa], 0x65
	je	short .1
	cmp	word [bp+0xa], 0x45
	jne	short .3
.1:
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatBuf
.2:
	db	0x8B, 0xE5			; mov	sp, bp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
.3:
	cmp	word [bp+0xa], 0x66
	jne	short .4
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FloatWidth
	jmp	short .2
	db	144
.4:
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FormatOne
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatLen:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+4], 0
	je	short .1
	push	word [bp+6]
	call	0:0xC9E
	db	0x8B, 0xE5			; mov	sp, bp
	inc	ax
	push	ax
	push	word [bp+6]
	mov	ax, word [bp+4]
	add	ax, word [bp+6]
	push	ax
	db	0x9A, 0x1C, 0x29, 0x00, 0x00			; call	0:_memmove
.1:
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	4

; FpError: print a floating-point error and exit.
; The code in AX is adjusted and used as a runtime message.
FpError:
	pop	dx
	pop	dx
	mov	dx, 0x45c9
	mov	ds, dx
	db	0x2A, 0xE4			; sub	ah, ah
	push	ax
	sub	ax, 0x81
	mov	word [0x8a40], ax
	call	0:0x160C
	mov	bx, word [0x8a40]
	shl	bx, 1
	mov	cx, word [bx-0x75de]
	mov	bx, 0x8a3a
	mov	word [bx+4], cx
	db	0x9A, 0x92, 0x29, 0x00, 0x00			; call	0:WriteCounted
	mov	ax, 0xfd
	push	ax
	call	0:0x1683
	mov	ax, word [0x8a40]
	add	ax, strict word 0x65
	push	ax
	call	0:0x1683
	call	0:0x687

FormatFixed:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x1a
	mov	bx, word [bp+6]
	push	word [bx+8]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	mov	ax, word [bp+0xa]
	inc	ax
	db	0x3D, 0x01, 0x00			; cmp	ax, 1
	jge	short .1
	mov	ax, 1
.1:
	push	ax
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	lea	ax, [bp-0x1a]
	push	ax
	call	HexConvert
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	FormatPad
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

FormatPad:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 8
	mov	ax, word [bp+8]
	mov	word [bp-2], ax
	mov	cx, word [bp+6]
	add	cx, 4
	mov	word [bp-6], cx
	mov	bx, word [bp+6]
	cmp	byte [bx+2], 0x2d
	jne	short .1
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx], 0x2d
	inc	ax
	mov	word [bp-2], ax
.1:
	mov	bx, word [bp+6]
	cmp	byte [bx+3], 0
	je	short .2
	db	0x8B, 0xD9			; mov	bx, cx
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	jmp	short .3
	db	144
.2:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	mov	bx, word [bp+6]
	inc	byte [bx+3]
	inc	word [bx]
.3:
	cmp	word [bp+0xa], 0
	jle	short .8
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2e
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	dec	ax
	mov	word [bp-4], ax
	sub	word [bp+0xa], ax
	jmp	short .5
.4:
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	dec	word [bp-4]
.5:
	cmp	word [bp-4], 0
	jne	short .4
	jmp	short .7
	db	144
.6:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
.7:
	dec	word [bp+0xa]
	jns	short .6
.8:
	cmp	word [bp+0xc], 0
	je	short .9
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x45
	jmp	short .10
	db	144
.9:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x65
.10:
	mov	bx, word [bp+6]
	mov	ax, word [bx]
	dec	ax
	mov	word [bp-8], ax
	db	0x0B, 0xC0			; or	ax, ax
	jge	short .11
	neg	ax
	mov	word [bp-8], ax
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2d
	jmp	short .12
.11:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2b
.12:
	cmp	ax, 0x3e8
	jl	short .13
	mov	cx, 0x3e8
	db	0x99			; cdq
	idiv	cx
	add	al, 0x30
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	mov	ax, word [bp-8]
	db	0x99			; cdq
	idiv	cx
	mov	word [bp-8], dx
.13:
	mov	ax, word [bp-8]
	mov	cx, 0x64
	db	0x99			; cdq
	idiv	cx
	add	al, 0x30
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	mov	ax, word [bp-8]
	db	0x99			; cdq
	idiv	cx
	mov	word [bp-8], dx
	db	0x8B, 0xC2			; mov	ax, dx
	mov	cx, 0xa
	db	0x99			; cdq
	idiv	cx
	add	al, 0x30
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	mov	ax, word [bp-8]
	db	0x99			; cdq
	idiv	cx
	add	dl, 0x30
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], dl
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0
	mov	ax, word [bp+8]
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatG:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x1a
	mov	bx, word [bp+6]
	push	word [bx+8]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	mov	ax, word [bp+0xa]
	db	0x0B, 0xC0			; or	ax, ax
	jge	short .1
	db	0x2B, 0xC0			; sub	ax, ax
.1:
	push	ax
	mov	ax, 1
	push	ax
	lea	ax, [bp-0x1a]
	push	ax
	call	HexConvert
	push	word [bp+0xa]
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	FormatCopy
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatCopy:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xa
	mov	ax, word [bp+8]
	mov	word [bp-2], ax
	mov	bx, word [bp+6]
	mov	cx, word [bx]
	mov	word [bp-8], cx
	lea	cx, [bx+4]
	mov	word [bp-6], cx
	cmp	byte [bx+2], 0x2d
	jne	short .1
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx], 0x2d
	inc	ax
	mov	word [bp-2], ax
.1:
	cmp	word [bp-8], 0
	jle	short .6
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	cmp	ax, word [bp-8]
	jle	short .2
	mov	ax, word [bp-8]
.2:
	mov	word [bp-4], ax
	sub	word [bp-8], ax
	mov	al, byte [bp-4]
	sub	byte [bx+3], al
	jmp	short .4
.3:
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
.4:
	mov	ax, word [bp-4]
	dec	word [bp-4]
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .3
.5:
	cmp	word [bp-8], 0
	je	short .7
	dec	word [bp-8]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	jmp	short .5
.6:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
.7:
	cmp	word [bp+0xa], 0
	jle	short .14
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2e
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	sub	ax, word [bp-8]
	neg	ax
	add	word [bp+0xa], ax
	jmp	short .9
	db	144
.8:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
.9:
	mov	ax, word [bp-8]
	inc	word [bp-8]
	db	0x0B, 0xC0			; or	ax, ax
	jl	short .8
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	mov	word [bp-4], ax
	jmp	short .11
	db	144
.10:
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
.11:
	mov	ax, word [bp-4]
	dec	word [bp-4]
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .10
	jmp	short .13
.12:
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
.13:
	mov	ax, word [bp+0xa]
	dec	word [bp+0xa]
	db	0x0B, 0xC0			; or	ax, ax
	jg	short .12
.14:
	mov	bx, word [bp-2]
	mov	byte [bx], 0
	mov	ax, word [bp+8]
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatDigits:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x1a
	cmp	word [bp+0xa], 0
	jg	short .1
	mov	word [bp+0xa], 1
.1:
	mov	bx, word [bp+6]
	push	word [bx+8]
	push	word [bx+6]
	push	word [bx+4]
	push	word [bx+2]
	push	word [bx]
	push	word [bp+0xa]
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	lea	ax, [bp-0x1a]
	push	ax
	call	HexConvert
	cmp	word [bp-0x1a], -4
	jle	short .2
	mov	ax, word [bp-0x1a]
	cmp	word [bp+0xa], ax
	jge	short .3
.2:
	push	word [bp+0xc]
	mov	ax, word [bp+0xa]
	dec	ax
	push	ax
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	FormatPad
	add	sp, 8
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
.3:
	mov	ax, word [bp+0xa]
	sub	ax, word [bp-0x1a]
	push	ax
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	FormatCopy
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatExp2:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+0xa], 0x65
	je	short .1
	cmp	word [bp+0xa], 0x45
	jne	short .3
.1:
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FormatFixed
.2:
	db	0x8B, 0xE5			; mov	sp, bp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
.3:
	cmp	word [bp+0xa], 0x66
	je	short .4
	cmp	word [bp+0xa], 0x46
	jne	short .5
.4:
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FormatG
	jmp	short .2
	db	144
.5:
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	FormatDigits
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

ConvertFloat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	mov	si, word [bp+4]
	mov	ax, 0x200
	push	ax
	db	0x9A, 0xF2, 0x27, 0x00, 0x00			; call	0:JmpFpConvert
	pop	cx
	db	0x8B, 0xDE			; mov	bx, si
	sub	bx, 0x86ca
	add	bx, 0x876a
	db	0x0B, 0xC0			; or	ax, ax
	je	short .1
	or	byte [si+6], 8
	mov	word [bx+2], 0x200
	jmp	short .2
.1:
	or	byte [si+6], 4
	mov	word [bx+2], 1
	lea	ax, [bx+1]
.2:
	mov	word [si], ax
	mov	word [si+4], ax
	mov	word [si+2], 0
	pop	si
	pop	bp
	ret
	db	0

; fflush: flush one FILE, or every open FILE when the argument is null.
fflush:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	push	di
	push	si
	db	0x2B, 0xFF			; sub	di, di
	cmp	word [bp+6], di
	jne	short .one
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	call	FlushAll
	jmp	short .3
	db	144
.one:
	mov	si, word [bp+6]
	mov	al, byte [si+6]
	db	0x8B, 0xC8			; mov	cx, ax
	and	al, 3
	cmp	al, 2
	jne	short .2
	test	cl, 8
	jne	short .1
	db	0x8B, 0xDE			; mov	bx, si
	sub	bx, 0x86ca
	test	byte [bx-0x7896], 1
	je	short .2
.1:
	mov	ax, word [si]
	sub	ax, word [si+4]
	mov	word [bp-2], ax
	db	0x0B, 0xC0			; or	ax, ax
	jle	short .2
	push	ax
	push	word [si+4]
	mov	cl, byte [si+7]
	db	0x2A, 0xED			; sub	ch, ch
	push	cx
	call	0:0xAEC
	add	sp, 6
	cmp	word [bp-2], ax
	je	short .2
	or	byte [si+6], 0x20
	mov	di, 0xffff
.2:
	mov	ax, word [si+4]
	mov	word [si], ax
	mov	word [si+2], 0
	db	0x8B, 0xC7			; mov	ax, di
.3:
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	184,1,0,80,232,1,0,203

FlushAll:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 2
	push	di
	push	si
	mov	si, 0x86ca
	db	0x2B, 0xFF			; sub	di, di
	mov	word [bp-2], di
	jmp	short .3
.1:
	mov	word [bp-2], 0xffff
.2:
	add	si, 8
.3:
	cmp	word [g_880A], si
	jb	short .4
	test	byte [si+6], 0x83
	je	short .2
	push	si
	db	0x9A, 0x2A, 0x27, 0x00, 0x00			; call	0:fflush
	add	sp, 2
	inc	ax
	je	short .1
	inc	di
	jmp	short .2
	db	144
.4:
	cmp	word [bp+4], 1
	jne	short .5
	db	0x8B, 0xC7			; mov	ax, di
	jmp	short .6
.5:
	mov	ax, word [bp-2]
.6:
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	2
	db	144

JmpFpConvert:
	jmp	0:FpConvert
	db	0

SkipSpace:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	mov	si, word [bp+6]
	jmp	short .2
.1:
	inc	si
.2:
	mov	al, byte [si]
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	test	byte [bx-0x7a73], 8
	jne	short .1
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	push	ax
	push	si
	call	0:0xC9E
	add	sp, 2
	push	ax
	push	si
	call	0:0x3592
	add	sp, 8
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, 0x90a0
	push	si
	db	0x8B, 0xF8			; mov	di, ax
	lea	si, [bx+8]
	push	ds
	pop	es
	movsw
	movsw
	movsw
	movsw
	pop	si
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

WriteDigits:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	mov	bx, word [bp+0xa]
	mov	di, word [bx+6]
	mov	bx, word [bp+6]
	mov	byte [bx], 0x30
	lea	si, [bx+1]
	jmp	short .4
.1:
	cmp	byte [di], 0
	je	short .2
	mov	al, byte [di]
	mov	byte [si], al
	inc	di
	jmp	short .3
.2:
	mov	byte [si], 0x30
.3:
	inc	si
	dec	word [bp+8]
.4:
	cmp	word [bp+8], 0
	jg	short .1
	mov	byte [si], 0
	cmp	word [bp+8], 0
	jl	short .7
	cmp	byte [di], 0x35
	jl	short .7
	jmp	short .6
	db	144
.5:
	mov	byte [si], 0x30
.6:
	dec	si
	cmp	byte [si], 0x39
	je	short .5
	inc	byte [si]
.7:
	mov	bx, word [bp+6]
	cmp	byte [bx], 0x31
	jne	short .8
	mov	bx, word [bp+0xa]
	inc	word [bx+2]
	jmp	short .9
	db	144
.8:
	db	0x8B, 0xC3			; mov	ax, bx
	inc	ax
	push	ax
	push	bx
	call	0:0xC6C
	add	sp, 4
.9:
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

StoreOne:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	bx
	push	es
	les	bx, [bp+0xa]
	mov	word [es:bx], 1
	db	0x33, 0xC0			; xor	ax, ax
	pop	es
	pop	bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	8

StoreZero:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	bx
	push	es
	les	bx, [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	byte [es:bx], al
	pop	es
	pop	bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	4

RetPop10:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	0xa

StoreWord:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	bx
	push	es
	mov	ax, word [bp+0xa]
	les	bx, [bp+6]
	mov	word [es:bx], ax
	pop	es
	pop	bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	6

RetPop2:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	2

WriteFar:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	ds
	mov	cx, word [bp+0xa]
	mov	bx, word [bp+0x10]
	lds	dx, [bp+0xc]
	mov	ah, 0x40
	int	0x21
	db	0x33, 0xC0			; xor	ax, ax
	pop	ds
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf	0xc

; _memmove: copy bytes, including when the ranges overlap.
; Arguments: destination, source, count.
_memmove:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	db	0x8B, 0xDE			; mov	bx, si
	mov	ax, ds
	mov	es, ax
	mov	si, word [bp+8]
	mov	di, word [bp+6]
	db	0x8B, 0xC7			; mov	ax, di
	mov	cx, word [bp+0xa]
	jcxz	.3
	db	0x3B, 0xFE			; cmp	di, si
	jbe	short .1
	db	0x8B, 0xC6			; mov	ax, si
	db	0x03, 0xC1			; add	ax, cx
	db	0x3B, 0xF8			; cmp	di, ax
	jae	short .1
	db	0x8B, 0xC7			; mov	ax, di
	db	0x03, 0xF1			; add	si, cx
	db	0x03, 0xF9			; add	di, cx
	dec	si
	dec	di
	std
	rep movsb
	cld
	jmp	short .3
.1:
	db	0x8B, 0xC7			; mov	ax, di
	test	al, 1
	je	short .2
	movsb
	dec	cx
.2:
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
.3:
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf

; _memset: fill a count of bytes with one value.
; Arguments: destination, byte, count.
_memset:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x8B, 0xD7			; mov	dx, di
	mov	ax, ds
	mov	es, ax
	mov	di, word [bp+6]
	db	0x8B, 0xDF			; mov	bx, di
	mov	cx, word [bp+0xa]
	jcxz	.2
	mov	al, byte [bp+8]
	db	0x8A, 0xE0			; mov	ah, al
	test	di, 1
	je	short .1
	stosb
	dec	cx
.1:
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
.2:
	db	0x8B, 0xFA			; mov	di, dx
	xchg	bx, ax
	pop	bp
	retf
	db	0

WriteCounted:
	mov	cl, byte [bx]
	db	0x2A, 0xED			; sub	ch, ch
	inc	bx
	db	0x8B, 0xD3			; mov	dx, bx
	mov	bx, 2
	cmp	word [g_8AE4], 0xd6d6
	jne	short .1
	call	word [g_8AE6]
.1:
	mov	ah, 0x40
	int	0x21
	retf
	db	0,205,204,204,204,204,204,204,204,251,63,205,204,204,204,204
	db	204,204,204,204,204,251,63

HexConvert:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xc
	push	si
	push	di
	push	ds
	db	0x33, 0xC0			; xor	ax, ax
	xchg	word [bp+8], ax
	mov	word [bp-2], ax
	mov	di, word [bp+4]
	mov	ax, word [bp+0x12]
	mov	byte [ss:di+2], 0x20
	test	ah, 0x80
	je	short .1
	and	byte [bp+0x13], 0x7f
	mov	byte [ss:di+2], 0x2d
	and	ax, 0x7fff
.1:
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .2
	mov	ax, word [bp+0xa]
	or	ax, word [bp+0xc]
	or	ax, word [bp+0xe]
	or	ax, word [bp+0x10]
	je	short .5
	jmp	short .6
.2:
	cmp	ax, 0x7fff
	jne	short .6
	mov	ax, word [bp+0xa]
	or	ax, word [bp+0xc]
	or	ax, word [bp+0xe]
	mov	ax, word [bp+0x10]
	jne	short .3
	mov	si, 0x8a52
	cmp	ax, 0x8000
	je	short .4
	cmp	ax, 0xc000
	jne	short .3
	mov	si, 0x8a58
	cmp	byte [ss:di+2], 0x2d
	je	short .4
.3:
	mov	si, 0x8a44
	test	ax, 0x4000
	je	short .4
	mov	si, 0x8a4b
.4:
	mov	word [ss:di], 1
	push	ss
	pop	es
	lea	di, [di+3]
	db	0x33, 0xC9			; xor	cx, cx
	mov	cl, byte [si]
	inc	cx
	rep movsb
	db	0x33, 0xC0			; xor	ax, ax
	jmp	near .21
.5:
	mov	di, word [bp+4]
	mov	word [ss:di], 0
	mov	byte [ss:di+2], 0x20
	mov	byte [ss:di+3], 0
	mov	byte [ss:di+4], 0
	jmp	near .20
.6:
	db	0x33, 0xFF			; xor	di, di
	mov	bh, byte [bp+0x11]
	mov	ax, word [bp+0x12]
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dx, 0x4d10
	mul	dx
	xchg	cx, ax
	mov	al, 0x4d
	mul	ah
	db	0x03, 0xC8			; add	cx, ax
	db	0x13, 0xD7			; adc	dx, di
	mov	al, 0x9a
	mul	bh
	db	0x03, 0xC8			; add	cx, ax
	db	0x13, 0xFA			; adc	di, dx
	sub	cx, 0x12f4
	sbb	di, 0x1343
	push	di
	neg	di
	lea	ax, [bp+8]
	push	ss
	push	ax
	push	di
	mov	ax, 1
	push	ax
	call	FpDecode
	pop	di
.7:
	cmp	word [bp+0x12], 0x3fff
	jb	short .8
	inc	di
	lea	ax, [bp+8]
	push	ss
	push	ax
	mov	ax, 0x29b8
	push	cs
	push	ax
	call	FpRound
	jmp	short .7
.8:
	mov	bx, word [bp+4]
	mov	word [ss:bx], di
	mov	ax, word [bp-2]
	test	word [bp+6], 1
	je	short .9
	db	0x03, 0xC7			; add	ax, di
	jns	short .9
	jmp	short .5
.9:
	db	0x3D, 0x15, 0x00			; cmp	ax, 0x15
	jbe	short .10
	mov	ax, 0x15
.10:
	mov	word [bp-2], ax
	inc	ax
	mov	word [bp-0xc], ax
	mov	ax, word [bp+0x12]
	sub	ax, 0x3ffe
	neg	ax
	db	0x32, 0xE4			; xor	ah, ah
	mov	bx, word [bp+0x10]
	mov	cx, word [bp+0xe]
	mov	dx, word [bp+0xc]
	mov	si, word [bp+0xa]
	mov	di, word [bp+8]
	db	0x0A, 0xC0			; or	al, al
	je	short .12
.11:
	shr	bx, 1
	rcr	cx, 1
	rcr	dx, 1
	rcr	si, 1
	rcr	di, 1
	rcr	ah, 1
	dec	al
	jne	short .11
.12:
	push	ss
	pop	es
	mov	word [bp-0xa], di
	mov	di, word [bp+4]
	lea	di, [di+4]
	xchg	word [bp-0xa], di
.13:
	db	0x32, 0xC0			; xor	al, al
	mov	word [bp+0x12], bx
	mov	word [bp+0x10], cx
	mov	word [bp+0xe], dx
	mov	word [bp+0xc], si
	mov	word [bp+0xa], di
	mov	byte [bp+9], ah
	shl	ah, 1
	rcl	di, 1
	rcl	si, 1
	rcl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	al, 1
	shl	ah, 1
	rcl	di, 1
	rcl	si, 1
	rcl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	al, 1
	add	ah, byte [bp+9]
	adc	di, word [bp+0xa]
	adc	si, word [bp+0xc]
	adc	dx, word [bp+0xe]
	adc	cx, word [bp+0x10]
	adc	bx, word [bp+0x12]
	adc	al, 0
	shl	ah, 1
	rcl	di, 1
	rcl	si, 1
	rcl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	al, 1
	add	al, 0x30
	xchg	word [bp-0xa], di
	stosb
	xchg	word [bp-0xa], di
	dec	word [bp-0xc]
	jne	short .13
	mov	di, word [bp-0xa]
	mov	si, word [bp+4]
	sub	di, 2
	cmp	al, 0x35
	jb	short .17
	lea	cx, [si+4]
	jmp	short .15
.14:
	cmp	byte [es:di], 0x39
	jne	short .16
	mov	byte [es:di], 0x30
	dec	di
.15:
	db	0x3B, 0xCF			; cmp	cx, di
	jbe	short .14
	inc	di
	mov	byte [es:di], 0x30
	inc	word [ss:si]
.16:
	inc	byte [es:di]
	db	0x2B, 0xF9			; sub	di, cx
	db	0x8B, 0xDF			; mov	bx, di
	inc	bx
	mov	byte [ss:si+3], bl
	jmp	short .20
.17:
	mov	cx, word [bp-2]
	jcxz	.18
	mov	al, 0x30
	std
	repe scasb
	cld
	jne	short .19
.18:
	jmp	near .5
.19:
	inc	cx
	mov	byte [ss:si+3], cl
.20:
	mov	ax, 1
.21:
	pop	ds
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	0x10

PackArgs:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	cld
	mov	ax, ds
	mov	es, ax
	lea	si, [bp+6]
	mov	di, 0x8a66
	db	0x36, 0xA5			; movsw
	db	0x36, 0xA5			; movsw
	db	0x36, 0xA5			; movsw
	db	0x36, 0xA5			; movsw
	mov	si, 0x8a66
	push	bp
	call	FpExec.6
	pop	bp
	mov	di, 0x8a6e
	db	0x8B, 0xC8			; mov	cx, ax
	lodsb
	db	0x98			; cwde
	xchg	cx, ax
	rep movsb
	xchg	cx, ax
	stosb
	mov	di, 0x8a5e
	db	0x32, 0xFF			; xor	bh, bh
	mov	word [di], bx
	mov	word [di+2], dx
	mov	word [di+4], cx
	mov	word [di+6], 0x8a6e
	db	0x8B, 0xC7			; mov	ax, di
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FloatStatus:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xe
	lea	ax, [bp-0xa]
	push	ss
	push	ax
	lea	cx, [bp-0xe]
	push	ss
	push	cx
	push	ds
	push	word [bp+6]
	mov	cx, 1
	push	cx
	call	FpPack
	int	0x37
	outsb
	db	0xF6, 0x8B, 0xE5, 0x5D, 0xCB			; test	byte [bp+di+0x5de5], -0x35
	nop

AdjustStack:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	mov	bx, word [bp+6]
	mov	si, 0x851c
	cmp	word [si+6], bx
	jae	short .1
	dec	bx
	dec	bx
	or	byte [bx], 1
	cmp	word [si+8], bx
	jbe	short .1
	mov	word [si+8], bx
.1:
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; Floating-point convert and the emulator helpers.


; FpConvert: turn a floating value into an integer, or zero when it is out of range.
FpConvert:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	mov	cx, word [bp+6]
	cmp	cx, -0x18
	ja	short .zero
	mov	bx, 0x851c
	call	FpPush
	jae	short .done
	call	FpPop
	jb	short .zero
	call	FpPush
	jae	short .done
.zero:
	db	0x33, 0xC0			; xor	ax, ax
	db	0x99			; cdq
	jmp	short .done
.done:
	pop	di
	pop	si
	pop	bp
	retf
	db	102,252,255,255,255,255,255,255,254
	aas
	int	0xcc
	int3
	int3
	int3
	int3
	int3
	int3
	sti
	aas

; FpExec: the emulator body. Interrupt 34h through 3Dh stand in for the coprocessor.
FpExec:
	mov	si, 0x8a8e
	mov	word [si], 0x3001
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xD0			; mov	dx, ax
	inc	ax
	mov	bl, 0x20
	pop	es
	ret
.1:
	db	0x0B, 0xD2			; or	dx, dx
	jne	short .2
	cmp	cx, -8
	je	short .4
	and	cl, 0xf
	je	short .3
.2:
	mov	si, 0x8aa6
	test	cl, 8
	jne	short .5
	mov	si, 0x8a9f
	jmp	short .5
.3:
	mov	si, 0x8aad
	jmp	short .5
.4:
	mov	si, 0x8ab3
.5:
	mov	dx, 1
	pop	es
	db	0x33, 0xC0			; xor	ax, ax
	ret
.6:
	push	es
	mov	ax, ds
	mov	es, ax
	cld
	mov	di, 0x8a82
	push	di
	mov	cx, 4
	rep movsw
	pop	si
	mov	cx, word [si+6]
	and	byte [si+7], 0x7f
	mov	bl, 0x20
	mov	ax, word [si]
	or	ax, word [si+2]
	or	ax, word [si+4]
	db	0x8B, 0xD0			; mov	dx, ax
	or	ax, word [si+6]
	je	short FpExec
	db	0x0B, 0xC9			; or	cx, cx
	jns	short .7
	mov	bl, 0x2d
.7:
	not	cx
	test	cx, 0x7ff0
	not	cx
	je	short .1
	push	bx
	int	0x35
	db	0x3E, 0xBB, 0x8A, 0xCD			; mov	bx, 0xcd8a
	cmp	ax, 0xa050
	mov	bx, 0xa28a
	mov	bp, 0x588a
	int	0x35
	db	0x2E, 0xBD, 0x8A, 0xCD			; mov	bp, 0xcd8a
	cmp	word [si], ax
	int	0x35
	ror	ch, 0x37
	cmp	al, 0xcd
	cmp	ax, 0xff33
	mov	si, 0x8a89
	lodsb
	db	0x8A, 0xF8			; mov	bh, al
	lodsw
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dx, 0x4d10
	mul	dx
	xchg	cx, ax
	mov	al, 0x4d
	mul	ah
	db	0x03, 0xC8			; add	cx, ax
	db	0x13, 0xD7			; adc	dx, di
	mov	al, 0x9a
	mul	bh
	db	0x03, 0xC8			; add	cx, ax
	db	0x13, 0xFA			; adc	di, dx
	sub	cx, 0x12f4
	sbb	di, 0x1343
	push	di
	neg	di
	mov	si, 0x8a82
	call	0x38dd
	mov	bx, 0x2c85
	pop	di
	int	0x3c
	wait
	das
	int	0x34
	db	0xD9, 0xCD			; fxch	st(5)
	cmp	word [0x8ab9], di
	int	0x3d
	test	byte [g_8ABA], 0x41
	je	short .8
	inc	di
	mov	bx, 0x2c8f
	int	0x3c
	wait
	das
	int	0x3a
	leave
.8:
	push	di
	int	0x37
	cmp	al, 0xcd
	xor	ax, 0xbb2e
	db	0x8A, 0xCD			; mov	cl, ch
	cmp	ax, 0x97ad
	lodsw
	xchg	bp, ax
	lodsw
	xchg	dx, ax
	lodsw
	xchg	bx, ax
	lodsw
	xchg	cx, ax
	sub	cx, 0x3ffe
	neg	cx
	db	0x8B, 0xF7			; mov	si, di
	db	0x33, 0xC0			; xor	ax, ax
	jcxz	.10
.9:
	shr	bx, 1
	rcr	dx, 1
	rcr	bp, 1
	rcr	si, 1
	rcr	ah, 1
	loop	.9
.10:
	adc	si, 0x39a
	db	0x13, 0xE9			; adc	bp, cx
	db	0x13, 0xD1			; adc	dx, cx
	db	0x13, 0xD9			; adc	bx, cx
	mov	di, 0x8a8f
	mov	cx, 0x10
.11:
	db	0x32, 0xC0			; xor	al, al
	push	cx
	push	bx
	push	dx
	push	bp
	push	si
	push	ax
	shl	ah, 1
	rcl	si, 1
	rcl	bp, 1
	rcl	dx, 1
	rcl	bx, 1
	rcl	al, 1
	shl	ah, 1
	rcl	si, 1
	rcl	bp, 1
	rcl	dx, 1
	rcl	bx, 1
	rcl	al, 1
	pop	cx
	db	0x12, 0xE5			; adc	ah, ch
	pop	cx
	db	0x13, 0xF1			; adc	si, cx
	pop	cx
	db	0x13, 0xE9			; adc	bp, cx
	pop	cx
	db	0x13, 0xD1			; adc	dx, cx
	pop	cx
	db	0x13, 0xD9			; adc	bx, cx
	adc	al, 0
	shl	ah, 1
	rcl	si, 1
	rcl	bp, 1
	rcl	dx, 1
	rcl	bx, 1
	rcl	al, 1
	pop	cx
	add	al, 0x30
	stosb
	loop	.11
	dec	di
	dec	cx
	mov	al, 0x30
	std
	repe scasb
	cld
	add	cx, 0x12
	mov	si, 0x8a8e
	mov	byte [si], cl
	mov	ax, 1
	pop	dx
	pop	bx
	pop	es
	ret
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si+0x4002], ah
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	al, cl
	add	ax, strict word 0x40
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	cli
	db	0x08, 0x40, 0x00			; or	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si], al
	add	byte [bx+si-0x64], al
	or	al, 0x40
	db	0,0,0,0,0,0,0,0,80,195,15
	inc	ax
	db	0,0,0,0,0,0,0,0,36,244,18,64,0,0,0,0
	db	0,0,0,128,150,152,22,64,0,0,0,0,0,0,0,32
	db	188,190,25,64,0,0,0,0,0,4,191,201,27,142,52,64
	db	0,0,0,161,237,204,206,27,194,211,78,64,32,240,158,181
	db	112,43,168,173,197,157,105,64,208,93,253,37,229,26,142,79
	db	25,235,131,64,113,150,215,149,67,14,5,141,41,175,158,64
	db	249,191,160,68,237,129,18,143,129,130,185,64,191,60,213,166
	db	207,255,73,31,120,194,211,64,111,198,224,140,233,128,201,71
	db	186,147,168,65,188,133,107,85,39,57,141,247,112,224,124,66
	db	188,221,142,222,249,157,251,235,126,170,81,67,161,230,118,227
	db	204,242,41,47,132,129,38,68,40,16,23,170,248,174,16,227
	db	197,196,250,68,235,167,212,243,247,235,225,74,122,149,207,69
	db	101,204,199,145,14,166,174,160,25,227,163,70,13,101,23,12
	db	117,129,134,117,118,201,72,77,88,66,228,167,147,57,59,53
	db	184,178,237,83,77,167,229,93,61,197,93,59,139,158,146,90
	db	255,93,166,240,161,32,192,84,165,140,55,97,209,253,139,90
	db	139,216,37,93,137,249,219,103,170,149,248,243,39,191,162,200
	db	93,221,128,110,76,201,155,151,32,138,2,82,96,196,37,117
	db	205,204,205,204,204,204,204,204,204,204,251,63,113,61,10,215
	db	163,112,61,10,215,163,248,63,90,100,59,223,79,141,151,110
	db	18,131,245,63,195,211,44,101,25,226,88,23,183,209,241,63
	db	208,15,35,132,71,27,71,172,197,167,238,63,64,166,182,105
	db	108,175,5,189,55,134,235,63,51,61,188,66,122,229,213,148
	db	191,214,231,63,194,253,253,206,97,132,17,119,204,171,228,63
	db	47,76,91,225,77,196,190,148,149,230,201,63,146,196,83,59
	db	117,68,205,20,190,154,175,63,222,103,186,148,57,69,173,30
	db	177,207,148,63,36,35,198,226,188,186,59,49,97,139,122,63
	db	97,85,89,193,126,177,83,124,18,187,95,63,215,238,47,141
	db	6,190,146,133,21,251,68,63,36,63,165,233,57,165,39,234
	db	127,168,42,63,125,172,161,228,188,100,124,70,208,221,85,62
	db	99,123,6,204,35,84,119,131,255,145,129,61,145,250,58,25
	db	122,99,37,67,49,192,172,60,33,137,209,56,130,71,151,184
	db	0,253,215,59,220,136,88,8,27,177,232,227,134,166,3,59
	db	198,132,69,66,7,182,153,117,55,219,46,58,51,113,28,210
	db	35,219,50,238,73,144,90,57,166,135,190,192,87,218,165,130
	db	166,162,181,50,226,104,178,17,167,82,159,68,89,183,16,44
	db	37,73,228,45,54,52,79,83,174,206,107,37,143,89,4,164
	db	192,222,194,125,251,232,198,30,158,231,136,90,87,145,60,191
	db	80,131,34,24,78,75,101,98,253,131,143,175,6,148,125,17
	db	228,45,222,159,206,210,200,4,221,166,216,10

FpDecode:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 6
	push	si
	push	di
	mov	di, word [bp+6]
	mov	bx, 0x2db8
	db	0x0B, 0xFF			; or	di, di
	je	short .7
	jns	short .1
	mov	bx, 0x2f14
	neg	di
.1:
	mov	word [bp-6], 0x316e
	cmp	word [bp+4], 0
	jne	short .3
	mov	word [bp-6], 0x3164
	int	0x35
.2:
	jle	short .2
	int	0x3d
	mov	ax, word [bp-2]
	db	0x0D, 0x38, 0x00			; or	ax, 0x38
	mov	word [bp-4], ax
	int	0x35
	outsb
	cld
	les	si, [bp+8]
	int	0x3c
	db	0xDB, 0x6C, 0x02			; fld	xword [si+2]
.3:
	push	di
.4:
	pop	di
	add	bx, 0x54
	db	0x0B, 0xFF			; or	di, di
	je	short .6
	db	0x8B, 0xC7			; mov	ax, di
	shr	di, 1
	shr	di, 1
	shr	di, 1
	push	di
	db	0x25, 0x07, 0x00			; and	ax, 7
	je	short .4
	push	bx
	shl	al, 1
	shl	al, 1
	db	0x8A, 0xE0			; mov	ah, al
	shl	al, 1
	db	0x02, 0xC4			; add	al, ah
	db	0x32, 0xE4			; xor	ah, ah
	db	0x03, 0xD8			; add	bx, ax
	jmp	word [bp-6]
.5:
	pop	bx
	jmp	short .4
.6:
	cmp	word [bp+4], 0
	jne	short .7
	int	0x37
	loop	0x3117
	xor	ax, 0xfe6e
	les	si, [bp+8]
	int	0x3c
	db	0xDB, 0x7C, 0x02			; fstp	xword [si+2]
	mov	word [es:si], 0
	int	0x3d
.7:
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	8
	int	0x3c
	wait
	outsw
	db	0x02, 0xCD			; add	cl, ch
	db	0x3A, 0xC9			; cmp	cl, cl
	jmp	short .5
	push	word [cs:bx+0xa]
	push	word [cs:bx+8]
	push	word [cs:bx+6]
	push	word [cs:bx+4]
	mov	cx, word [cs:bx+2]
	mov	ax, word [cs:bx]
	cmp	ax, 0x8000
	adc	cx, -1
	push	cx
	push	ax
	db	0x8B, 0xC4			; mov	ax, sp
	push	word [bp+0xa]
	push	word [bp+8]
	push	ss
	push	ax
	call	FpRound
	add	sp, 0xc
	jmp	short .5
.8:
	jmp	near FpRound.14
.9:
	jmp	near FpRound.13

FpRound:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x12
	push	si
	push	di
	mov	cx, 9
	mov	ax, ss
	mov	es, ax
	lea	di, [bp-0x12]
	db	0x33, 0xC0			; xor	ax, ax
	rep stosw
	lds	si, [bp+8]
	les	di, [bp+4]
	mov	ax, word [si+0xa]
	mov	bx, word [es:di+0xa]
	db	0x8B, 0xC8			; mov	cx, ax
	db	0x33, 0xCB			; xor	cx, bx
	and	cx, 0x8000
	mov	word [bp-2], cx
	mov	dx, 0x7fff
	db	0x23, 0xC2			; and	ax, dx
	db	0x3B, 0xC2			; cmp	ax, dx
	je	short FpDecode.8
	db	0x23, 0xDA			; and	bx, dx
	db	0x3B, 0xDA			; cmp	bx, dx
	je	short FpDecode.8
	db	0x8B, 0xD0			; mov	dx, ax
	db	0x03, 0xD3			; add	dx, bx
	cmp	dx, 0xbffd
	ja	short FpDecode.8
	cmp	dx, 0x3fbf
	jbe	short FpDecode.9
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .1
	inc	dx
	mov	ax, word [si]
	or	ax, word [si+2]
	or	ax, word [si+4]
	or	ax, word [si+6]
	or	ax, word [si+8]
	je	short FpDecode.9
.1:
	db	0x0B, 0xDB			; or	bx, bx
	jne	short .2
	inc	dx
	mov	ax, word [es:di]
	or	ax, word [es:di+2]
	or	ax, word [es:di+4]
	or	ax, word [es:di+6]
	or	ax, word [es:di+8]
	je	short FpDecode.9
.2:
	sub	dx, 0x3ffe
	mov	word [si+0xa], dx
	add	di, 8
	mov	cx, 5
	lea	bx, [bp-0x12]
.3:
	push	cx
	push	si
	push	di
.4:
	mov	ax, word [es:di]
	mul	word [si]
	add	word [ss:bx], ax
	adc	word [ss:bx+2], dx
	adc	word [ss:bx+4], 0
	add	si, 2
	sub	di, 2
	loop	.4
	pop	di
	pop	si
	pop	cx
	add	bx, 2
	add	si, 2
	add	cx, -1
	jne	short .3
	mov	si, word [bp+8]
	mov	dx, word [bp-0x10]
	mov	cx, word [bp-0xe]
	mov	bx, word [bp-0xc]
	mov	ax, word [bp-0xa]
	mov	di, word [bp-8]
	cmp	word [si+0xa], 0
	jg	short .6
	jmp	short .11
.5:
	shl	word [bp-0x12], 1
	rcl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	ax, 1
	rcl	di, 1
	dec	word [si+0xa]
	je	short .11
.6:
	db	0x0B, 0xFF			; or	di, di
	jns	short .5
.7:
	cmp	word [bp-0x12], 0x8000
	jb	short .9
	ja	short .8
	test	dx, 1
	je	short .9
.8:
	add	dx, 1
	adc	cx, 0
	adc	bx, 0
	db	0x15, 0x00, 0x00			; adc	ax, 0
	adc	di, 0
	jae	short .9
	mov	di, 0x8000
	inc	word [si+0xa]
.9:
	cmp	word [si+0xa], 0x7fff
	jae	short .14
	mov	word [si+8], di
	mov	word [si+6], ax
	mov	word [si+4], bx
	mov	word [si+2], cx
	mov	word [si], dx
	mov	ax, word [bp-2]
	or	word [si+0xa], ax
.10:
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	8
.11:
	dec	word [si+0xa]
.12:
	shr	di, 1
	rcr	ax, 1
	rcr	bx, 1
	rcr	cx, 1
	rcr	dx, 1
	rcr	word [bp-0x12], 1
	adc	word [bp-4], 0
	inc	word [si+0xa]
	jne	short .12
	cmp	word [bp-4], 0
	je	short .7
	or	word [bp-0x12], 1
	jmp	short .7
.13:
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [si+0xa], ax
	mov	word [si+8], ax
	mov	word [si+6], ax
	mov	word [si+4], ax
	mov	word [si+2], ax
	mov	word [si], ax
	jmp	short .10
.14:
	mov	ax, 0x7fff
	or	ax, word [bp-2]
	mov	word [si+0xa], ax
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [si+8], ax
	mov	word [si+6], ax
	mov	word [si+4], ax
	mov	word [si+2], ax
	mov	word [si], ax
	jmp	short .10
	db	0

FpPack:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0x34
	push	si
	push	di
	push	ds
	lds	si, [bp+6]
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [bp-0xe], ax
	mov	word [bp-0x10], ds
	mov	word [bp-0x12], si
	mov	word [bp-0x14], ax
	mov	word [bp-0x18], ax
	mov	word [bp-0x16], ax
	mov	word [bp-0x1a], 0x19
	push	ss
	pop	es
	lea	di, [bp-0x34]
.1:
	lodsb
	cmp	al, 0x20
	je	short .1
	cmp	al, 9
	je	short .1
	cmp	al, 0xa
	je	short .1
	cmp	al, 0xd
	je	short .1
	db	0x0A, 0xC0			; or	al, al
	jne	short .3
.2:
	jmp	near .42
.3:
	cmp	al, 0x2b
	je	short .4
	cmp	al, 0x2d
	jne	short .5
	mov	word [bp-0x14], 0x8000
.4:
	lodsb
.5:
	cmp	al, 0x30
	jb	short .6
	cmp	al, 0x39
	jbe	short .8
.6:
	cmp	al, 0x2e
	jne	short .2
	lodsb
	cmp	al, 0x30
	jb	short .2
	cmp	al, 0x39
	ja	short .2
	jmp	short .12
.7:
	lodsb
.8:
	cmp	al, 0x30
	je	short .7
	db	0x0A, 0xC0			; or	al, al
	jne	short .10
.9:
	dec	si
	mov	word [bp-0x12], si
	jmp	near .43
.10:
	cmp	al, 0x2e
	jne	short .14
.11:
	lodsb
.12:
	dec	word [bp-0x16]
	cmp	al, 0x30
	je	short .11
	inc	word [bp-0x16]
	db	0x0A, 0xC0			; or	al, al
	je	short .9
	jmp	short .19
.13:
	lodsb
.14:
	cmp	al, 0x30
	jb	short .17
	cmp	al, 0x39
	ja	short .17
	sub	al, 0x30
	stosb
	dec	word [bp-0x1a]
	jne	short .13
.15:
	lodsb
	inc	word [bp-0x16]
	cmp	al, 0x30
	jb	short .16
	cmp	al, 0x39
	jbe	short .15
.16:
	dec	word [bp-0x16]
	cmp	al, 0x2e
	je	short .20
	jmp	short .21
.17:
	cmp	al, 0x2e
	jne	short .21
.18:
	lodsb
.19:
	cmp	al, 0x30
	jb	short .21
	cmp	al, 0x39
	ja	short .21
	sub	al, 0x30
	stosb
	dec	word [bp-0x16]
	dec	word [bp-0x1a]
	jne	short .18
.20:
	lodsb
	cmp	al, 0x30
	jb	short .21
	cmp	al, 0x39
	jbe	short .20
.21:
	neg	word [bp-0x1a]
	add	word [bp-0x1a], 0x19
	lea	bx, [si-1]
	mov	word [bp-0x12], bx
	db	0x33, 0xDB			; xor	bx, bx
	cmp	al, 0x45
	je	short .22
	cmp	al, 0x65
	je	short .22
	cmp	al, 0x44
	je	short .22
	cmp	al, 0x64
	je	short .22
	jmp	short .29
.22:
	lodsb
	cmp	al, 0x2b
	je	short .23
	cmp	al, 0x2d
	jne	short .24
	mov	word [bp-0x18], 0xffff
.23:
	lodsb
.24:
	cmp	al, 0x30
	jb	short .29
	cmp	al, 0x39
	ja	short .29
	db	0x2D, 0x30, 0x00			; sub	ax, 0x30
	db	0x8B, 0xD8			; mov	bx, ax
.25:
	lodsb
	cmp	al, 0x30
	jb	short .28
	cmp	al, 0x39
	ja	short .28
	sub	al, 0x30
	cmp	bx, 0x666
	ja	short .26
	shl	bx, 1
	db	0x03, 0xC3			; add	ax, bx
	shl	bx, 1
	shl	bx, 1
	db	0x03, 0xD8			; add	bx, ax
	jns	short .25
.26:
	mov	bx, 0x3fff
.27:
	lodsb
	cmp	al, 0x30
	jb	short .28
	cmp	al, 0x39
	jbe	short .27
.28:
	xor	bx, word [bp-0x18]
	sub	bx, word [bp-0x18]
	add	word [bp-0x16], bx
	dec	si
	mov	word [bp-0x12], si
.29:
	cmp	word [bp-0x1a], 0
	jne	short .30
	jmp	near .43
.30:
	mov	byte [es:di], 0
	dec	di
	cmp	word [bp-0x1a], 0x18
	jbe	short .31
	mov	al, byte [es:di]
	mov	byte [es:di], 0
	dec	word [bp-0x1a]
	inc	word [bp-0x16]
	dec	di
	cmp	al, 5
	jb	short .33
	inc	byte [es:di]
	jmp	short .34
.31:
	cmp	word [bp-0x16], 0
	je	short .34
	jmp	short .33
.32:
	dec	di
	dec	word [bp-0x1a]
	inc	word [bp-0x16]
.33:
	cmp	byte [es:di], 0
	je	short .32
.34:
	push	ss
	lea	ax, [bp-0x34]
	push	ax
	push	word [bp-0x1a]
	lea	ax, [bp-0xc]
	push	ax
	call	FpFormat
	mov	ax, word [bp-0x16]
	db	0x0B, 0xC0			; or	ax, ax
	je	short .37
	cmp	ax, 0x1450
	jl	short .35
	jmp	near .45
.35:
	cmp	ax, 0xebb0
	jg	short .36
	jmp	near .44
.36:
	push	ss
	lea	ax, [bp-0xc]
	push	ax
	push	word [bp-0x16]
	push	word [bp+4]
	call	FpDecode
.37:
	mov	ax, word [bp-4]
	mov	bx, word [bp-6]
	mov	cx, word [bp-8]
	mov	dx, word [bp-0xa]
	cmp	word [bp-0xc], 0x8000
	jb	short .39
	ja	short .38
	test	dx, 1
	je	short .39
.38:
	add	dx, 1
	adc	cx, 0
	adc	bx, 0
	db	0x15, 0x00, 0x00			; adc	ax, 0
	jae	short .39
	or	ah, 0x80
	inc	word [bp-2]
.39:
	mov	si, word [bp-2]
	cmp	si, 0x7fff
	jae	short .45
	db	0x0B, 0xF6			; or	si, si
	jne	short .40
	db	0x8B, 0xF0			; mov	si, ax
	db	0x0B, 0xF3			; or	si, bx
	db	0x0B, 0xF1			; or	si, cx
	db	0x0B, 0xF2			; or	si, dx
	je	short .44
.40:
	lds	si, [bp+0xe]
	mov	word [si+6], ax
	mov	word [si+4], bx
	mov	word [si+2], cx
	mov	word [si], dx
	mov	ax, word [bp-2]
	or	ax, word [bp-0x14]
	mov	word [si+8], ax
.41:
	lds	si, [bp+0xa]
	mov	ax, word [bp-0x12]
	mov	word [si], ax
	mov	ax, word [bp-0x10]
	mov	word [si+2], ax
	mov	ax, word [bp-0xe]
	pop	ds
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	0xe
.42:
	or	word [bp-0xe], 4
.43:
	les	di, [bp+0xe]
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, 5
	rep stosw
	jmp	short .41
.44:
	or	word [bp-0xe], 1
	jmp	short .43
.45:
	or	word [bp-0xe], 2
	lds	si, [bp+0xe]
	mov	ax, 0x7fff
	or	ax, word [bp-0x14]
	mov	word [si+8], ax
	mov	word [si+6], 0x8000
	db	0x33, 0xC0			; xor	ax, ax
	mov	word [si+4], ax
	mov	word [si+2], ax
	mov	word [si], ax
	jmp	short .41

FpScale:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 6
	mov	ax, 0x90b0
	push	ds
	push	ax
	lea	ax, [bp-6]
	push	ss
	push	ax
	push	ds
	push	word [bp+6]
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	call	FpCall
	mov	word [bp-2], ax
	mov	ax, word [bp-6]
	sub	ax, word [bp+6]
	mov	word [g_90AA], ax
	mov	word [g_90A8], 0
	test	byte [bp-2], 4
	je	short .1
	mov	word [g_90A8], 0x200
.1:
	test	byte [bp-2], 2
	je	short .2
	or	byte [g_90A8], 1
.2:
	test	byte [bp-2], 1
	je	short .3
	or	byte [g_90A9], 1
.3:
	mov	ax, 0x90a8
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	nop

FpPush:
	inc	cx
	and	cl, 0xfe
	push	bx
	cld
	mov	si, word [bx+8]
	mov	bx, word [bx+0xa]
	db	0x33, 0xFF			; xor	di, di
	jmp	short .3
.1:
	db	0x8B, 0xC3			; mov	ax, bx
	pop	bx
	test	al, 1
	jne	short .7
	push	bx
	mov	si, word [bx+6]
	mov	bx, word [bx+8]
	db	0x3B, 0xDE			; cmp	bx, si
	je	short .6
	dec	bx
	db	0x33, 0xFF			; xor	di, di
	jmp	short .3
	nop
.2:
	lea	dx, [si-2]
	db	0x3B, 0xD3			; cmp	dx, bx
	jae	short .1
	db	0x03, 0xF0			; add	si, ax
	jb	short .5
.3:
	lodsw
	test	al, 1
	je	short .2
	db	0x8B, 0xFE			; mov	di, si
.4:
	dec	ax
	db	0x3B, 0xC1			; cmp	ax, cx
	jae	short .8
	db	0x03, 0xF0			; add	si, ax
	jb	short .5
	db	0x8B, 0xD0			; mov	dx, ax
	lodsw
	test	al, 1
	je	short .2
	db	0x03, 0xC2			; add	ax, dx
	add	ax, strict word 0x2
	db	0x8B, 0xF7			; mov	si, di
	mov	word [si-2], ax
	jmp	short .4
.5:
	db	0x8B, 0xC0			; mov	ax, ax
.6:
	pop	bx
.7:
	mov	ax, word [bx+6]
	mov	word [bx+8], ax
	stc
	jmp	short .10
.8:
	pop	bx
	mov	word [si-2], cx
	je	short .9
	db	0x03, 0xF9			; add	di, cx
	db	0x2B, 0xC1			; sub	ax, cx
	dec	ax
	mov	word [di], ax
	db	0x2B, 0xF9			; sub	di, cx
.9:
	db	0x03, 0xF9			; add	di, cx
	mov	word [bx+8], di
	db	0x8B, 0xC6			; mov	ax, si
	mov	dx, ds
	clc
.10:
	ret

FpPop:
	push	cx
	push	di
	test	byte [bx+2], 1
	je	short .9
	call	.19
	db	0x8B, 0xFE			; mov	di, si
	mov	ax, word [si]
	test	al, 1
	je	short .1
	db	0x2B, 0xC8			; sub	cx, ax
	dec	cx
.1:
	inc	cx
	inc	cx
	mov	si, word [bx+4]
	db	0x0B, 0xF6			; or	si, si
	je	short .9
	db	0x03, 0xCE			; add	cx, si
	jae	short .2
	db	0x33, 0xC0			; xor	ax, ax
	mov	dx, 0xfff0
	jcxz	.7
	jmp	short .9
.2:
	push	ss
	pop	es
	mov	ax, word [es:0x8acc]
	cmp	ax, 0x2000
	je	short .5
	mov	dx, 0x8000
.3:
	db	0x3B, 0xD0			; cmp	dx, ax
	jb	short .4
	shr	dx, 1
	jne	short .3
	jmp	short .8
.4:
	cmp	dx, 8
	jb	short .8
	shl	dx, 1
	db	0x8B, 0xC2			; mov	ax, dx
.5:
	dec	ax
	db	0x8B, 0xD0			; mov	dx, ax
	db	0x03, 0xC1			; add	ax, cx
	jae	short .6
	db	0x33, 0xC0			; xor	ax, ax
.6:
	not	dx
	db	0x23, 0xC2			; and	ax, dx
.7:
	push	dx
	call	.12
	pop	dx
	jae	short .10
	cmp	dx, -0x10
	je	short .9
.8:
	mov	ax, 0x10
	jmp	short .5
.9:
	stc
	jmp	short .11
.10:
	db	0x8B, 0xD0			; mov	dx, ax
	sub	dx, word [bx+4]
	mov	word [bx+4], ax
	mov	word [bx+8], di
	mov	si, word [bx+0xa]
	dec	dx
	mov	word [si], dx
	inc	dx
	db	0x03, 0xF2			; add	si, dx
	mov	word [si], 0xfffe
	mov	word [bx+0xa], si
.11:
	pop	di
	pop	cx
	ret
.12:
	db	0x8B, 0xD0			; mov	dx, ax
	test	byte [bx+2], 4
	je	short .14
	dec	dx
	mov	si, word [bx+4]
	dec	si
	db	0x3B, 0xD6			; cmp	dx, si
	jb	short .13
	cmp	word [bx-2], dx
	jae	short .17
.13:
	inc	dx
.14:
	push	bx
	push	cx
	mov	si, ds
	mov	es, si
	mov	cl, 4
	shr	ax, cl
	jne	short .15
	mov	ax, 0x1000
.15:
	test	byte [bx+2], 4
	je	short .16
	db	0x03, 0xC6			; add	ax, si
	mov	bx, word [__psp]
	db	0x2B, 0xC3			; sub	ax, bx
	mov	es, bx
.16:
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ah, 0x4a
	int	0x21
	pop	cx
	pop	bx
	jb	short .18
	db	0x8B, 0xC2			; mov	ax, dx
	test	byte [bx+2], 4
	je	short .17
	dec	dx
	mov	word [bx-2], dx
.17:
	clc
	jmp	short .18
	stc
.18:
	ret
.19:
	push	di
	mov	si, word [bx+8]
	cmp	si, word [bx+0xa]
	jne	short .20
	mov	si, word [bx+6]
.20:
	lodsw
	db	0x3D, 0xFE, 0xFF			; cmp	ax, 0xfffe
	je	short .21
	db	0x8B, 0xFE			; mov	di, si
	and	al, 0xfe
	db	0x03, 0xF0			; add	si, ax
	jmp	short .20
.21:
	dec	di
	dec	di
	db	0x8B, 0xF7			; mov	si, di
	pop	di
	ret
	db	0,0,0,0,0,0,0,160,2,64,0,0,0,0,0,0
	db	0,200,5,64,0,0,0,0,0,0,0,250,8,64,0,0
	db	0,0,0,0,64,156,12,64,0,0,0,0,0,0,80,195
	db	15,64,0,0,0,0,0,0,36,244,18,64,0,0,0,0
	db	0,128,150,152,22,64,0,0,0,0,0,32,188,190,25,64
	db	0,0,0,4,191,201,27,142,52,64,0,161,237,204,206,27
	db	194,211,78,64,158,181,112,43,168,173,197,157,105,64,253,37
	db	229,26,142,79,25,235,131,64,215,149,67,14,5,141,41,175
	db	158,64,160,68,237,129,18,143,129,130,185,64,213,166,207,255
	db	73,31,120,194,211,64,224,140,233,128,201,71,186,147,168,65
	db	107,85,39,57,141,247,112,224,124,66,142,222,249,157,251,235
	db	126,170,81,67,118,227,204,242,41,47,132,129,38,68,205,204
	db	204,204,204,204,204,204,251,63,10,215,163,112,61,10,215,163
	db	248,63,59,223,79,141,151,110,18,131,245,63,44,101,25,226
	db	88,23,183,209,241,63,35,132,71,27,71,172,197,167,238,63
	db	182,105,108,175,5,189,55,134,235,63,188,66,122,229,213,148
	db	191,214,231,63,253,206,97,132,17,119,204,171,228,63,91,225
	db	77,196,190,148,149,230,201,63,83,59,117,68,205,20,190,154
	db	175,63,186,148,57,69,173,30,177,207,148,63,198,226,188,186
	db	59,49,97,139,122,63,89,193,126,177,83,124,18,187,95,63
	db	47,141,6,190,146,133,21,251,68,63,165,233,57,165,39,234
	db	127,168,42,63,161,228,188,100,124,70,208,221,85,62,6,204
	db	35,84,119,131,255,145,129,61,58,25,122,99,37,67,49,192
	db	172,60,209,56,130,71,151,184,0,253,215,59,187,17,55,11
	db	255,121,5,187,207,55,247,223,87,95,129,195,70,0,11,255
	db	116,39,139,199,209,239,209,239,209,239,87,37,7,0,116,233
	db	83,208,224,138,224,208,224,208,224,2,196,50,228,3,216,205
	db	60,155,47,205,58,201,91,235,208,195,0

FpFormat:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xc
	push	si
	push	di
	mov	ax, word [bp+6]
	mov	word [bp-0xc], ax
	les	si, [bp+8]
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xD8			; mov	bx, ax
	db	0x8B, 0xC8			; mov	cx, ax
	db	0x8B, 0xD0			; mov	dx, ax
	mov	dl, byte [es:si]
	inc	si
	jmp	short .2
.1:
	mov	word [bp-2], di
	mov	word [bp-4], ax
	mov	word [bp-6], bx
	mov	word [bp-8], cx
	mov	word [bp-0xa], dx
	call	.7
	call	.7
	add	dx, word [bp-0xa]
	adc	cx, word [bp-8]
	adc	bx, word [bp-6]
	adc	ax, word [bp-4]
	adc	di, word [bp-2]
	call	.7
	add	dl, byte [es:si]
	inc	si
	adc	dh, 0
	adc	cx, 0
	adc	bx, 0
	db	0x15, 0x00, 0x00			; adc	ax, 0
	adc	di, 0
.2:
	dec	word [bp-0xc]
	jne	short .1
	mov	si, 0x404e
	jmp	short .4
.3:
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC3			; mov	ax, bx
	db	0x8B, 0xD9			; mov	bx, cx
	db	0x8B, 0xCA			; mov	cx, dx
	db	0x33, 0xD2			; xor	dx, dx
	sub	si, 0x10
.4:
	db	0x0B, 0xFF			; or	di, di
	je	short .3
	js	short .6
.5:
	shl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	ax, 1
	rcl	di, 1
	dec	si
	db	0x0B, 0xFF			; or	di, di
	jns	short .5
.6:
	push	si
	mov	si, word [bp+4]
	pop	word [ss:si+0xa]
	mov	word [ss:si+8], di
	mov	word [ss:si+6], ax
	mov	word [ss:si+4], bx
	mov	word [ss:si+2], cx
	mov	word [ss:si], dx
	db	0x8B, 0xC6			; mov	ax, si
	mov	dx, ss
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	8
.7:
	shl	dx, 1
	rcl	cx, 1
	rcl	bx, 1
	rcl	ax, 1
	rcl	di, 1
	ret
	db	0

FpCall:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 0xe
	push	ss
	lea	ax, [bp-0xa]
	push	ax
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	word [bp+4]
	call	FpPack
	int	0x35
	jle	short 0x39E9
	int	0x37
	outsb
	db	0xF6, 0x8B, 0x5E, 0xF2, 0x83			; test	byte [bp+di-0xda2], -0x7d
	retf
	db	24,137,94,244,205,55,226,196,94,14,205,53,110,244,205,60
	db	221,31,205,57,126,244,205,55,226,205,53,110,242,11,192,117
	db	23,139,94,244,51,192,247,195,24,0,116,12,184,2
	add	bh, dh
