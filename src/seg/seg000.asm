; Segment seg000. VGA copies and port I/O, then the Microsoft C startup
; and the C runtime. __astart (seg056) jumps to MscStartup. Everything
; after __chkstk is still the original image.

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
	mov	bx, word [0x74dc]
	and	bx, 1				; toggle the displayed page
	xor	bx, 1
	mov	word [0x74dc], bx
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


; Targets that are still the original bytes later in this segment.
__FF_MSGBANNER	equ	0x160C			; prints the runtime banner
__NMSG_WRITE	equ	0x1683			; writes one runtime message
__nullcheck	equ	0x1634			; checksum of the low DGROUP bytes
FpFail		equ	0x162E			; mov ax, 2 / jmp AmsgExit (R6002)

; seg005 is still incbin. Each entry is one retf. Which library symbol the
; first two are is not settled (see docs/HANDOFF.md).
NullStartup4	equ	4			; seg005 offset 4
NullStartup6	equ	6			; seg005 offset 6
_main		equ	8			; seg005 offset 8

; Near data in DGROUP (past the load image, not this segment).
DGROUP		equ	0x45C9
__psp		equ	0x8556
_osfile		equ	0x855F


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
	mov	word [ss:0x851a], ax	; top offset of DGROUP
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
	mov	word [ss:0x8516], sp
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
	mov	cx, word [0x8ae2]	; optional near hook, skipped when the word is 0
	jcxz	.afterhook
	call	cx

.afterhook:
	call	0x08F9:NullStartup6	; startup stub in seg005
	call	0x08F9:NullStartup4	; startup stub in seg005
	db	0x33, 0xED			; xor	bp, bp: end the stack frame chain before the runtime init
	call	0:InitRuntime
	push	ss
	pop	ds
	push	word [0x8577]		; environ, argv, argc (medium model, near pointers)
	push	word [0x8575]
	push	word [0x8573]
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
	mov	word [ss:0x8518], _exit	; errors leave through _exit
AmsgExit:
	push	ax			; message number is already in AX
	push	cs
	call	__FF_MSGBANNER
	push	cs
	call	__NMSG_WRITE
	cmp	word [ss:0x8ae4], 0xd6d6; CodeView is present when this word is the signature
	jne	.nodebug
	pop	ax
	push	ax
	call	word [ss:0x8ae8]

.nodebug:
	mov	ax, 0xff		; exit(255)
	push	ax
	push	cs
	call	word [0x8518]
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
	mov	word [0x8542], bx
	mov	word [0x8544], es
	push	cs
	pop	ds
	mov	ax, 0x2500		; interrupt 0 -> __cintDIV
	mov	dx, __cintDIV
	int	0x21
	push	ss
	pop	ds
	mov	cx, word [0x8af6]	; count of floating-point environment hooks; 0 skips them
	jcxz	.nofp
	mov	es, word [__psp]
	mov	si, word [es:0x2c]	; environment segment from the PSP
	lds	ax, [0x8af8]
	mov	dx, ds
	db	0x33, 0xDB			; xor	bx, bx
	call	far [ss:0x8af4]		; let the hook parse the environment
	jae	.fpok
	push	ss
	pop	ds
	jmp	FpFail			; hook failed: R6002 floating-point support not loaded

.fpok:
	lds	ax, [ss:0x8afc]
	mov	dx, ds
	mov	bx, 3
	call	far [ss:0x8af4]
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
	cmp	word [0x8ae4], 0xd6d6	; debugger termination hook
	jne	.after_atexit
	call	word [0x8aea]

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
	mov	cx, word [0x8af6]	; put interrupt 0 back
	jcxz	.nomathexit
	mov	bx, 2
	call	far [0x8af4]

.nomathexit:
	push	ds
	lds	dx, [0x8542]
	mov	ax, 0x2500
	int	0x21
	pop	ds
	cmp	byte [0x8580], 0	; math error vector, if one was installed
	je	.restored
	push	ds
	mov	al, byte [0x8581]
	lds	dx, [0x8582]
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
	cmp	bx, word [0x858a]	; below the stack limit
	jb	.overflow
	db	0x8B, 0xE3			; mov	sp, bx
	push	dx
	push	cx
	retf

.overflow:
	push	dx
	push	cx
	mov	ax, word [0x8586]	; 0xFFFF means no alternate handler
	inc	ax
	jne	.altstack
	db	0x33, 0xC0			; xor	ax, ax
	jmp	AmsgExit		; AX = 0: R6000 stack overflow

.altstack:
	jmp	far [0x8586]		; jump to the alternate stack-overflow handler

	incbin	"Extracted/segments/seg000.bin", $ - $$
