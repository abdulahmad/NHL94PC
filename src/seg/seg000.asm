; Segment seg000. VGA copies, the C startup, file and DOS calls,
; strings, runtime messages, formatted output, and the number
; helpers. __astart jumps to MscStartup. The floating-point emulator
; after these helpers is still the original image.

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


; Low-level C files, DOS calls, strings, and the runtime messages.
_nfile		equ	0x855D		; highest C handle
errno		equ	0x8550
_doserrno	equ	0x855B


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
	jmp	short 0x80A
.seek:
	test	word [bp+0xa], 0x8000
	je	short .doseek
	cmp	word [bp+0xc], 0
	je	short .bad
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4201
	int	0x21
	jb	short 0x843
	test	word [bp+0xc], 2
	jne	short .fromend
	add	ax, word [bp+8]
	adc	dx, word [bp+0xa]
	jns	short .doseek
.bad:
	mov	ax, 0x1600
	stc
	jmp	short 0x843
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
	jb	short 0x843
	and	byte [bx-0x7aa1], 0xfd
	jmp	near DosRetLong

; _sopen: open a file with a sharing mode, then the same path as _open.
; Arguments: path, access, share.
_sopen:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	db	0x32, 0xFF			; xor	bh, bh
	cmp	byte [0x8558], 3
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
	jmp	near 0x943
.fail:
	stc
	jmp	near DosRetLong
.opened:
	xchg	bx, ax
	db	0x8B, 0xC1			; mov	ax, cx
	and	ax, 0x500
	cmp	ax, 0x500
	jne	short 0x8BC
	mov	ah, 0x3e
	int	0x21
	mov	ax, 0x1100
	jmp	short .fail
	mov	byte [bp-3], 1
	mov	ax, 0x4400
	int	0x21
	test	dl, 0x80
	je	short 0x8CE
	or	byte [bp-4], 0x40
	test	byte [bp-4], 0x40
	je	short 0x8D7
	jmp	near 0x9AA
	mov	ax, word [bp+8]
	test	ax, 0x200
	je	short 0x8FB
	test	ax, 3
	je	short 0x8ED
	db	0x33, 0xC9			; xor	cx, cx
	mov	ah, 0x40
	int	0x21
	jmp	near 0x9AA
	mov	ah, 0x3e
	int	0x21
	mov	dx, word [bp+6]
	mov	ax, 0x4300
	int	0x21
	jmp	short 0x960
	test	byte [bp-4], 0x80
	jne	short 0x904
	jmp	near 0x9AA
	test	ax, 2
	jne	short 0x90C
	jmp	near 0x9AA
	mov	cx, 0xffff
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4202
	int	0x21
	neg	cx
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	db	0x0B, 0xC0			; or	ax, ax
	je	short 0x938
	cmp	byte [bp-1], 0x1a
	jne	short 0x938
	neg	cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4202
	int	0x21
	db	0x33, 0xC9			; xor	cx, cx
	mov	ah, 0x40
	int	0x21
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4200
	int	0x21
	jmp	short 0x9AA
	mov	byte [bp-3], 0
	mov	cx, word [bp+0xa]
	call	0x9f1
	mov	word [bp+0xa], cx
	test	byte [bp-2], 0xff
	jne	short 0x95D
	test	word [bp+8], 2
	jne	short 0x960
	and	cl, 0xfe
	mov	dx, word [bp+6]
	mov	ah, 0x3c
	int	0x21
	jae	short 0x96C
	jmp	near DosRetLong
	xchg	bx, ax
	test	byte [bp-2], 0xff
	jne	short 0x97A
	test	word [bp+8], 2
	jne	short 0x9AA
	mov	ah, 0x3e
	int	0x21
	mov	al, byte [bp+8]
	and	al, 3
	or	al, byte [bp-2]
	mov	dx, word [bp+6]
	mov	ah, 0x3d
	int	0x21
	jb	short 0x969
	xchg	bx, ax
	test	byte [bp-3], 1
	jne	short 0x9AA
	test	word [bp+0xa], 1
	je	short 0x9AA
	or	cl, 1
	mov	dx, word [bp+6]
	mov	ax, 0x4301
	int	0x21
	jb	short 0x969
	test	byte [bp-4], 0x40
	jne	short 0x9ED
	mov	dx, word [bp+6]
	mov	ax, 0x4300
	int	0x21
	db	0x8B, 0xC1			; mov	ax, cx
	db	0x32, 0xC9			; xor	cl, cl
	db	0x25, 0x01, 0x00			; and	ax, 1
	je	short 0x9C3
	mov	cl, 0x10
	test	word [bp+8], 8
	je	short 0x9CD
	or	cl, 0x20
	db	0x3B, 0x1E, 0x5D, 0x85			; cmp	bx, word [_nfile]
	jb	short 0x9DD
	mov	ah, 0x3e
	int	0x21
	mov	ax, 0x1800
	jmp	near .fail
	or	cl, byte [bp-4]
	or	cl, 1
	mov	byte [bx-0x7aa1], cl
	db	0x8B, 0xC3			; mov	ax, bx
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	0x32, 0xC9			; xor	cl, cl
	jmp	short 0x9CD
	mov	ax, word [0x8552]
	not	ax
	db	0x23, 0xC1			; and	ax, cx
	db	0x33, 0xC9			; xor	cx, cx
	test	al, 0x80
	jne	short 0xA01
	or	cl, 1
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
	jmp	short 0xA7F
.go:
	db	0x33, 0xC0			; xor	ax, ax
	mov	cx, word [bp+0xa]
	jcxz	0xA7F
	test	byte [bx-0x7aa1], 2
	jne	short 0xA7F
	cmp	word [0x8ae4], 0xd6d6
	jne	short 0xA31
	call	word [0x8ae6]
	mov	cx, word [bp+0xa]
	mov	dx, word [bp+8]
	mov	ah, 0x3f
	int	0x21
	jae	short 0xA41
	mov	ah, 9
	jmp	short 0xA7F
	test	byte [bx-0x7aa1], 0x80
	je	short 0xA7F
	and	byte [bx-0x7aa1], 0xfb
	push	si
	push	di
	cld
	db	0x8B, 0xF2			; mov	si, dx
	db	0x8B, 0xFA			; mov	di, dx
	db	0x8B, 0xC8			; mov	cx, ax
	jcxz	0xA7D
	mov	ah, 0xd
	cmp	byte [si], 0xa
	jne	short 0xA64
	or	byte [bx-0x7aa1], 4
	lodsb
	db	0x3A, 0xC4			; cmp	al, ah
	je	short 0xA82
	cmp	al, 0x1a
	jne	short 0xA74
	or	byte [bx-0x7aa1], 2
	jmp	short 0xA79
	mov	byte [di], al
	inc	di
	loop	0xA64
	db	0x8B, 0xC7			; mov	ax, di
	db	0x2B, 0xC2			; sub	ax, dx
	pop	di
	pop	si
	jmp	near DosRetLong
	cmp	cx, 1
	je	short 0xA8E
	cmp	byte [si], 0xa
	je	short 0xA77
	jmp	short 0xA74
	test	byte [bx-0x7aa1], 0x40
	je	short 0xAAD
	mov	ax, 0x4400
	int	0x21
	test	dx, 0x20
	jne	short 0xAA9
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	jb	short 0xA7D
	mov	al, 0xa
	jmp	short 0xAD9
	mov	byte [bp-1], 0
	lea	dx, [bp-1]
	mov	ah, 0x3f
	int	0x21
	jb	short 0xA7D
	db	0x0B, 0xC0			; or	ax, ax
	je	short 0xAD7
	cmp	word [bp+0xa], 1
	je	short 0xAE3
	mov	cx, 0xffff
	db	0x8B, 0xD1			; mov	dx, cx
	mov	ax, 0x4201
	int	0x21
	mov	cx, 1
	cmp	byte [bp-1], 0xa
	je	short 0xADE
	mov	al, 0xd
	mov	dx, word [bp+8]
	jmp	short 0xA74
	mov	dx, word [bp+8]
	jmp	short 0xA77
	cmp	byte [bp-1], 0xa
	jne	short 0xAC4
	jmp	short 0xAA9
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
	jmp	near DosRetLong
.go:
	cmp	word [0x8ae4], 0xd6d6
	jne	short 0xB0E
	call	word [0x8ae6]
	test	byte [bx-0x7aa1], 0x20
	je	short 0xB20
	mov	ax, 0x4202
	db	0x33, 0xC9			; xor	cx, cx
	db	0x8B, 0xD1			; mov	dx, cx
	int	0x21
	jb	short 0xAFF
	test	byte [bx-0x7aa1], 0x80
	je	short 0xB97
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
	jcxz	0xB7D
	mov	al, 0xa
	repne scasb
	jne	short 0xB95
	call	0:0x1D8E
	cmp	ax, 0xa8
	jbe	short 0xB99
	sub	sp, 2
	db	0x8B, 0xDC			; mov	bx, sp
	mov	dx, 0x200
	cmp	ax, 0x228
	jae	short 0xB63
	mov	dx, 0x80
	db	0x2B, 0xE2			; sub	sp, dx
	db	0x8B, 0xD4			; mov	dx, sp
	db	0x8B, 0xFA			; mov	di, dx
	push	ss
	pop	es
	mov	cx, word [bp+0xa]
	lodsb
	cmp	al, 0xa
	je	short 0xB7F
	db	0x3B, 0xFB			; cmp	di, bx
	je	short 0xB90
	stosb
	loop	0xB6E
	call	0xba0
	jmp	short 0xBEA
	mov	al, 0xd
	db	0x3B, 0xFB			; cmp	di, bx
	jne	short 0xB88
	call	0xba0
	stosb
	mov	al, 0xa
	inc	word [bp-4]
	jmp	short 0xB73
	call	0xba0
	jmp	short 0xB77
	pop	si
	pop	di
	jmp	short 0xBF8
	mov	ax, 0xfffc
	push	cs
	call	0x74a
	push	ax
	push	bx
	push	cx
	db	0x8B, 0xCF			; mov	cx, di
	db	0x2B, 0xCA			; sub	cx, dx
	jcxz	0xBBB
	push	cx
	mov	bx, word [bp+6]
	mov	ah, 0x40
	int	0x21
	pop	cx
	jb	short 0xBC1
	add	word [bp-2], ax
	db	0x3B, 0xC8			; cmp	cx, ax
	ja	short 0xBC1
	pop	cx
	pop	bx
	pop	ax
	db	0x8B, 0xFA			; mov	di, dx
	ret
	lahf
	add	sp, 8
	cmp	word [bp-2], 0
	jne	short 0xBEA
	sahf
	jae	short 0xBD2
	mov	ah, 9
	jmp	short 0xBF0
	test	byte [bx-0x7aa1], 0x40
	je	short 0xBE4
	mov	bx, word [bp+8]
	cmp	byte [bx], 0x1a
	jne	short 0xBE4
	clc
	jmp	short 0xBF0
	stc
	mov	ax, 0x1c00
	jmp	short 0xBF0
	mov	ax, word [bp-2]
	sub	ax, word [bp-4]
	mov	sp, word [bp-8]
	pop	si
	pop	di
	jmp	near DosRetLong
	mov	cx, word [bp+0xa]
	db	0x0B, 0xC9			; or	cx, cx
	jne	short 0xC04
	db	0x8B, 0xC1			; mov	ax, cx
	jmp	near DosRetLong
	mov	dx, word [bp+8]
	mov	ah, 0x40
	int	0x21
	jae	short 0xC11
	mov	ah, 9
	jmp	short 0xBF5
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0xBF5
	test	byte [bx-0x7aa1], 0x40
	je	short 0xC26
	db	0x8B, 0xDA			; mov	bx, dx
	cmp	byte [bx], 0x1a
	jne	short 0xC26
	clc
	jmp	short 0xBF5
	stc
	mov	ax, 0x1c00
	jmp	short 0xBF5

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
	je	short 0xC5D
	movsb
	dec	cx
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
	je	short 0xD24
	cmp	byte [si], 0
	je	short 0xD24
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
	db	0x83, 0x3E, 0x50, 0x85, 0x00			; cmp	word [errno], 0
	jl	short 0xD34
	db	0xA1, 0x50, 0x85			; mov	ax, word [errno]
	cmp	word [0x8a14], ax
	jg	short 0xD3A
	mov	ax, word [0x8a14]
	jmp	short 0xD3D
	db	144
	db	0xA1, 0x50, 0x85			; mov	ax, word [errno]
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
	mov	byte [0x909c], 0x42
	mov	ax, word [bp+6]
	mov	word [0x909a], ax
	mov	si, 0x9096
	mov	word [si], ax
	mov	word [0x9098], 0x7fff
	lea	ax, [bp+0xa]
	push	ax
	push	word [bp+8]
	db	0x8B, 0xC6			; mov	ax, si
	push	ax
	call	0:_output
	add	sp, 6
	db	0x8B, 0xF8			; mov	di, ax
	dec	word [0x9098]
	js	short 0xDBA
	mov	bx, word [0x9096]
	inc	word [0x9096]
	mov	byte [bx], 0
	jmp	short 0xDC6
	db	144
	push	si
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	call	0:0x1710
	add	sp, 4
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
	db	0x0A, 0xC0			; or	al, al
	je	short 0xE0B
	lodsb
	mov	ah, byte [bx]
	inc	bx
	db	0x3A, 0xE0			; cmp	ah, al
	je	short 0xDDB
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
	je	short 0xDDB
	db	0x1A, 0xC0			; sbb	al, al
	sbb	al, 0xff
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
	lodsb
	db	0x0A, 0xC0			; or	al, al
	je	short 0xE42
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	or	byte [bp+di-0x20], al
	jmp	short 0xE29
	mov	si, word [bp+6]
	mov	bx, 0xffff
	inc	bx
	lodsb
	and	ax, 0xff
	je	short 0xE63
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	and	al, byte [bp+di-0x20]
	je	short 0xE48
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
	jmp	short 0xE85

; atexit: register a function. Returns 0, or nothing useful if the table is full.
atexit:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xC8			; mov	cx, ax
	db	0x99			; cdq
	mov	bx, word [0x8694]
	cmp	bx, 0x9138
	je	short 0xEA6
	add	word [0x8694], 4
	mov	dx, word [bp+8]
	mov	word [bx+2], dx
	mov	ax, word [bp+6]
	mov	word [bx], ax
	jcxz	0xEA6
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

CallArg:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	si
	push	di
	cmp	word [bp+0xa], 0
	je	short 0xED5
	mov	cx, word [bp+8]
	jcxz	0xED5
	dec	cx
	je	short 0xED5
	mov	si, word [bp+6]
	db	0x8B, 0xF9			; mov	di, cx
	push	si
	add	si, word [bp+0xa]
	push	si
	call	far [bp+0xc]
	add	sp, 4
	db	0x8B, 0xCF			; mov	cx, di
	db	0x0B, 0xC0			; or	ax, ax
	js	short 0xEDB
	loop	0xEC0
	pop	di
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	mov	ax, word [bp+8]
	dec	ax
	db	0x33, 0xC9			; xor	cx, cx
	shr	ax, 1
	loopne	0xEE1
	neg	cx
	mov	ax, 4
	mul	cx
	jb	short 0xF0F
	db	0x8B, 0xF0			; mov	si, ax
	call	0:0x1D8E
	db	0x3B, 0xC6			; cmp	ax, si
	jb	short 0xF0F
	push	bp
	db	0x8B, 0xFC			; mov	di, sp
	mov	ax, word [bp+8]
	dec	ax
	mul	word [bp+0xa]
	add	ax, word [bp+6]
	push	ax
	push	word [bp+6]
	jmp	short 0xF18
	pop	bp
	jmp	short 0xED5
	mov	ax, 0xfffc
	push	cs
	call	0x74a
	jmp	short 0xED5
	db	0x3B, 0xE7			; cmp	sp, di
	jae	short 0xF0C
	db	0x8B, 0xEC			; mov	bp, sp
	mov	si, word [bp]
	cmp	si, word [bp+2]
	jb	short 0xF2B
	add	sp, 4
	jmp	short 0xF18
	sub	sp, 4
	mov	dx, word [bp+2]
	mov	word [bp-2], dx
	add	dx, word [ss:di+0x10]
	mov	word [bp-4], si
	push	dx
	add	si, word [ss:di+0x10]
	cmp	si, word [bp+2]
	je	short 0xF5B
	push	word [bp]
	push	si
	call	far [ss:di+0x12]
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	jg	short 0xF5B
	je	short 0xF3C
	mov	word [bp-4], si
	jmp	short 0xF3C
	pop	dx
	push	si
	db	0x8B, 0xF2			; mov	si, dx
	sub	si, word [ss:di+0x10]
	push	si
	push	word [bp]
	call	far [ss:di+0x12]
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	jg	short 0xF7E
	je	short 0xF79
	mov	word [bp-2], si
	jmp	short 0xF5F
	cmp	si, word [bp]
	jne	short 0xF5F
	db	0x8B, 0xD6			; mov	dx, si
	pop	si
	db	0x3B, 0xD6			; cmp	dx, si
	jbe	short 0xF98
	mov	ax, word [ss:di+0x10]
	db	0x87, 0xFA			; xchg	dx, di
	call	0xfe2
	db	0x87, 0xFA			; xchg	dx, di
	mov	word [bp-2], dx
	mov	word [bp-4], si
	jmp	short 0xF3B
	mov	ax, word [ss:di+0x10]
	db	0x87, 0xFA			; xchg	dx, di
	db	0x8B, 0xCE			; mov	cx, si
	mov	si, word [bp]
	call	0xfe2
	db	0x8B, 0xF1			; mov	si, cx
	db	0x87, 0xFA			; xchg	dx, di
	mov	si, word [bp+2]
	sub	si, word [bp-2]
	add	si, word [bp]
	sub	si, word [bp-4]
	jb	short 0xFCD
	mov	cx, word [bp]
	mov	ax, word [bp-2]
	mov	word [bp], ax
	mov	ax, word [bp-4]
	mov	word [bp-2], ax
	mov	word [bp-4], cx
	jmp	near 0xF1C
	mov	cx, word [bp+2]
	mov	ax, word [bp-4]
	mov	word [bp+2], ax
	mov	ax, word [bp-2]
	mov	word [bp-4], ax
	mov	word [bp-2], cx
	jmp	near 0xF1C
	db	0x8B, 0xD8			; mov	bx, ax
	test	bx, 1
	je	short 0xFF3
	dec	bx
	mov	al, byte [bx+si]
	xchg	byte [bx+di], al
	mov	byte [bx+si], al
	je	short 0xFFE
	sub	bx, 2
	mov	ax, word [bx+si]
	xchg	word [bx+di], ax
	mov	word [bx+si], ax
	jne	short 0xFF3
	ret
	db	0

; _srand: set the rand seed.
; Argument: seed.
_srand:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ax, word [bp+6]
	mov	word [0x8696], ax
	mov	word [0x8698], 0
	pop	bp
	retf
	db	144

; _rand: advance the Microsoft C seed and return the high 15 bits.
_rand:
	mov	ax, 0x43fd
	mov	dx, 3
	push	dx
	push	ax
	push	word [0x8698]
	push	word [0x8696]
	db	0x9A, 0x26, 0x12, 0x00, 0x00			; call	0:__aFlmul
	add	ax, strict word 0x9ec3
	adc	dx, 0x26
	mov	word [0x8696], ax
	mov	word [0x8698], dx
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
	jmp	short 0x111E

; _dos_write: write from a far buffer.
; Arguments: handle, far buffer, count.
_dos_write:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	mov	ah, 0x40
	mov	bx, word [bp+6]
	mov	cx, word [bp+0xc]
	cmp	word [0x8ae4], 0xd6d6
	jne	short .write
	call	word [0x8ae6]
.write:
	push	ds
	lds	dx, [bp+8]
	int	0x21
	pop	ds
	jb	short 0x113E
	mov	bx, word [bp+0xe]
	mov	word [bx], ax
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
	jge	short 0x11C4
	inc	di
	mov	dx, word [bp+0xa]
	neg	ax
	neg	dx
	db	0x1D, 0x00, 0x00			; sbb	ax, 0
	mov	word [bp+0xc], ax
	mov	word [bp+0xa], dx
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x11DD
	mov	cx, word [bp+0xa]
	mov	ax, word [bp+8]
	db	0x33, 0xD2			; xor	dx, dx
	div	cx
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bp+6]
	div	cx
	db	0x8B, 0xD3			; mov	dx, bx
	jmp	short 0x1215
	db	0x8B, 0xD8			; mov	bx, ax
	mov	cx, word [bp+0xa]
	mov	dx, word [bp+8]
	mov	ax, word [bp+6]
	shr	bx, 1
	rcr	cx, 1
	shr	dx, 1
	rcr	ax, 1
	db	0x0B, 0xDB			; or	bx, bx
	jne	short 0x11E8
	div	cx
	db	0x8B, 0xF0			; mov	si, ax
	mul	word [bp+0xc]
	xchg	cx, ax
	mov	ax, word [bp+0xa]
	mul	si
	db	0x03, 0xD1			; add	dx, cx
	jb	short 0x1211
	cmp	dx, word [bp+8]
	ja	short 0x1211
	jb	short 0x1212
	cmp	ax, word [bp+6]
	jbe	short 0x1212
	dec	si
	db	0x33, 0xD2			; xor	dx, dx
	xchg	si, ax
	dec	di
	jne	short 0x121F
	neg	dx
	neg	ax
	sbb	dx, 0
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
	shl	ax, 1
	rcl	dx, 1
	loop	0x125C
.done:
	retf
	db	0

; __aFlsar: arithmetic shift of DX:AX right by CX.
__aFlsar:
	db	0x32, 0xED			; xor	ch, ch
	jcxz	.done
	sar	dx, 1
	rcr	ax, 1
	loop	0x1268
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
	call	0x1258
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
	call	0x1264
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
	shr	dx, 1
	rcr	ax, 1
	loop	0x12B0
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
	jne	short 0x12FE
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
	db	0x0B, 0xFF			; or	di, di
	jne	short 0x12C9
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
	jmp	short 0x12C9
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
	db	0x0A, 0xC0			; or	al, al
	je	short 0x1355
	lodsb
	mov	ah, byte [es:bx]
	inc	bx
	db	0x3A, 0xE0			; cmp	ah, al
	je	short 0x1324
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
	je	short 0x1324
	db	0x1A, 0xC0			; sbb	al, al
	sbb	al, 0xff
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
	ja	short 0x138C
	je	short .none
	dec	cx
	dec	cx
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
	je	short 0x13D2
	db	0x1B, 0xC0			; sbb	ax, ax
	db	0x1D, 0xFF, 0xFF			; sbb	ax, 0xffff
	pop	ds
	db	0x8B, 0xF3			; mov	si, bx
	db	0x8B, 0xFA			; mov	di, dx
	pop	bp
	retf
	db	0

; _fstrlen: length of a far string.
_fstrlen:
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
	je	short 0x13FF
	movsb
	dec	cx
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
	je	short 0x1445
	movsb
	dec	cx
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
	je	short 0x1474
	db	0x2B, 0xD1			; sub	dx, cx
	db	0x1B, 0xDB			; sbb	bx, bx
	db	0x23, 0xD3			; and	dx, bx
	db	0x03, 0xD1			; add	dx, cx
	db	0x87, 0xD1			; xchg	cx, dx
	db	0x2B, 0xD1			; sub	dx, cx
	mov	ax, word [bp+0xa]
	db	0x8A, 0xE0			; mov	ah, al
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
	db	0x87, 0xD1			; xchg	cx, dx
	jcxz	0x1495
	mov	bx, es
	add	bx, 0x1000
	mov	es, bx
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
	pop	di
.done:
	mov	ax, word [bp+6]
	mov	dx, word [bp+8]
	pop	bp
	retf

_fstrcpy:
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
	lodsb
	db	0x0A, 0xC0			; or	al, al
	je	short 0x14D1
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	or	byte [bp+di-0x20], al
	jmp	short 0x14B8
	lds	si, [bp+6]
	mov	bx, 0xffff
	inc	bx
	lodsb
	and	ax, 0xff
	je	short 0x14F2
	db	0x8B, 0xF8			; mov	di, ax
	db	0x8B, 0xC8			; mov	cx, ax
	mov	al, 1
	and	cl, 7
	shl	al, cl
	mov	cl, 3
	shr	di, cl
	and	al, byte [bp+di-0x20]
	je	short 0x14D7
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
	js	short 0x1577
	db	0x2B, 0xC1			; sub	ax, cx
	sbb	dx, 0
	jae	short 0x1577
	dec	cx
	db	0x03, 0xF1			; add	si, cx
	jae	short 0x1533
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
	db	0x03, 0xF9			; add	di, cx
	jae	short 0x153E
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
	inc	cx
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
	jne	short 0x1569
	mov	ax, ds
	sub	ax, 0x1000
	mov	ds, ax
	cmp	di, -1
	jne	short 0x153F
	mov	ax, es
	sub	ax, 0x1000
	mov	es, ax
	jmp	short 0x153F
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
	jne	short 0x15AC
	mov	ax, ds
	add	ax, strict word 0x1000
	mov	ds, ax
	db	0x0B, 0xFF			; or	di, di
	jne	short 0x1577
	mov	ax, es
	add	ax, strict word 0x1000
	mov	es, ax
	jmp	short 0x1577
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
	jle	short 0x15D0
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
	call	0x1683
	cmp	word [0x86b4], 0
	je	short .nobannerhook
	call	far [0x86b2]
.nobannerhook:
	mov	ax, 0xff
	push	ax
	push	cs
	call	0x1683
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; FpFail: report R6002, floating-point support not loaded, and abort.
FpFail:
	mov	ax, 2
	jmp	near 0x59D

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
	call	0x160c
	mov	ax, 1
	push	ax
	push	cs
	call	0x1683
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
	call	0x1658
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
	cmp	word [0x8ae4], 0xd6d6
	jne	short .nodebug
	call	word [0x8ae6]
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
	call	0x16e2
	pop	ax
	db	0x32, 0xE4			; xor	ah, ah
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; DosRetLong: success keeps DX:AX. A carry maps the error and returns -1.
DosRetLong:
	jae	short DosRetLeave

DosRetBad:
	call	0x16e2
	mov	ax, 0xffff
	db	0x99			; cdq

DosRetLeave:
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

; DosRetErrno: map the DOS error in AX and return.
DosRetErrno:
	db	0x32, 0xE4			; xor	ah, ah
	call	0x16e2
	retf

; DosMapErr: store the DOS error in _doserrno and the C errno.
DosMapErr:
	db	0xA2, 0x5B, 0x85			; mov	byte [_doserrno], al
	db	0x0A, 0xE4			; or	ah, ah
	jne	short .high
	cmp	byte [0x8558], 3
	jb	short .low
	cmp	al, 0x22
	jae	short 0x1700
	cmp	al, 0x20
	jb	short .low
	mov	al, 5
	jmp	short .map
.low:
	cmp	al, 0x13
	jbe	short .map
	mov	al, 0x13
.map:
	mov	bx, 0x86b6
	xlatb
	db	0x98			; cwde
	db	0xA3, 0x50, 0x85			; mov	word [errno], ax
	ret
.high:
	db	0x8A, 0xC4			; mov	al, ah
	jmp	short 0x1706
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
	je	short 0x1737
	test	al, 0x10
	je	short .done
	mov	cx, word [si+4]
	mov	word [si], cx
	and	al, 0xfe
	or	al, 2
	and	al, 0xef
	mov	byte [si+6], al
	db	0x8B, 0xFE			; mov	di, si
	sub	di, 0x86ca
	add	di, 0x876a
	db	0x33, 0xDB			; xor	bx, bx
	mov	bl, byte [si+7]
	test	al, 8
	jne	short 0x179E
	test	al, 4
	jne	short 0x1773
	test	byte [di], 1
	jne	short 0x179E
	cmp	si, 0x86d2
	je	short 0x176C
	cmp	si, 0x86da
	je	short 0x176C
	cmp	si, 0x86ea
	jne	short 0x1791
	test	byte [bx-0x7aa1], 0x40
	je	short 0x1791
	mov	cx, 1
	push	cx
	lea	di, [bp+6]
	push	di
	push	bx
	push	cs
	call	0xaec
	add	sp, 6
	mov	cx, 1
	jmp	short 0x17C7
.done:
	mov	ax, 0xffff
	or	byte [si+6], 0x20
	jmp	short 0x17EF
	push	bx
	push	si
	call	0x26e6
	pop	bx
	pop	bx
	test	byte [si+6], 8
	je	short 0x1773
	mov	cx, word [si]
	mov	dx, word [si+4]
	db	0x2B, 0xCA			; sub	cx, dx
	inc	dx
	mov	word [si], dx
	mov	dx, word [di+2]
	dec	dx
	mov	word [si+2], dx
	jcxz	0x17D2
	push	cx
	push	cx
	push	word [si+4]
	push	bx
	push	cs
	call	0xaec
	add	sp, 6
	pop	cx
	mov	di, word [si+4]
	mov	dx, word [bp+6]
	mov	byte [di], dl
	db	0x3B, 0xC1			; cmp	ax, cx
	jne	short .done
	db	0x33, 0xC0			; xor	ax, ax
	mov	al, byte [bp+6]
	jmp	short 0x17EF
	db	0x33, 0xC0			; xor	ax, ax
	test	byte [bx-0x7aa1], 0x20
	je	short 0x17BF
	mov	cx, 2
	push	cx
	push	ax
	push	ax
	push	bx
	push	cs
	call	0x7cc
	add	sp, 8
	db	0x33, 0xC0			; xor	ax, ax
	db	0x8B, 0xC8			; mov	cx, ax
	jmp	short 0x17BF
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
	je	short 0x184D
	mov	word [si+4], ax
	mov	word [si], ax
	mov	word [si+2], 0x200
	mov	word [di+2], 0x200
	or	byte [si+6], 2
	mov	byte [di], 0x11
	mov	ax, 1
	jmp	short 0x1863
	push	bx
	mov	ax, 0x200
	push	ax
	call	0:JmpFpConvert
	pop	bx
	pop	bx
	db	0x0B, 0xC0			; or	ax, ax
	je	short .nobuf
	mov	word [bx], ax
	jmp	short 0x1832
.nobuf:
	db	0x33, 0xC0			; xor	ax, ax
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
	call	0x74a
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
	je	short 0x18DE
	cmp	word [bp-8], 0
	jge	short 0x18E4
	mov	ax, word [bp-8]
	jmp	near 0x1D87
	mov	bx, 0x8812
	sub	al, 0x20
	cmp	al, 0x58
	ja	short 0x18F2
	xlatb
	and	al, 0xf
	jmp	short 0x18F4
	mov	al, 0
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
	call	0x1d3a
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
	jne	short 0x1939
	or	byte [bp-4], 4
	jmp	short .next
	cmp	al, 0x2b
	jne	short 0x1943
	or	byte [bp-4], 1
	jmp	short .next
	cmp	al, 0x20
	jne	short 0x194E
	or	byte [bp-4], 2
	jmp	near .next
	cmp	al, 0x23
	jne	short 0x1959
	or	byte [bp-4], 0x80
	jmp	near .next
	or	byte [bp-4], 8
	jmp	near .next
.widthstar:
	mov	cl, byte [bp-2]
	cmp	cl, 0x2a
	jne	short 0x1977
	call	0x1cc1
	db	0x0B, 0xC0			; or	ax, ax
	jns	short 0x1986
	neg	ax
	or	byte [bp-4], 4
	jmp	short 0x1986
	sub	cl, 0x30
	db	0x32, 0xED			; xor	ch, ch
	mov	ax, word [bp-0xa]
	mov	bx, 0xa
	mul	bx
	db	0x03, 0xC1			; add	ax, cx
	mov	word [bp-0xa], ax
	jmp	near .next
.prec0:
	mov	word [bp-0xc], 0
	jmp	near .next
.precstar:
	mov	cl, byte [bp-2]
	cmp	cl, 0x2a
	jne	short 0x19A8
	call	0x1cc1
	db	0x0B, 0xC0			; or	ax, ax
	jns	short 0x19B7
	mov	ax, 0xffff
	jmp	short 0x19B7
	sub	cl, 0x30
	db	0x32, 0xED			; xor	ch, ch
	mov	ax, word [bp-0xc]
	mov	bx, 0xa
	mul	bx
	db	0x03, 0xC1			; add	ax, cx
	mov	word [bp-0xc], ax
	jmp	near .next
.sizech:
	mov	al, byte [bp-2]
	cmp	al, 0x6c
	jne	short 0x19CA
	or	byte [bp-4], 0x10
	jmp	short 0x19EC
	cmp	al, 0x46
	jne	short 0x19D4
	or	byte [bp-4], 0x20
	jmp	short 0x19EC
	cmp	al, 0x4e
	jne	short 0x19DE
	or	byte [bp-3], 0x10
	jmp	short 0x19EC
	cmp	al, 0x4c
	jne	short 0x19E8
	or	byte [bp-3], 4
	jmp	short 0x19EC
	or	byte [bp-3], 8
	jmp	near .next
.convert:
	mov	al, byte [bp-2]
	cmp	al, 0x64
	jne	short 0x19F9
	jmp	near 0x1B87
	cmp	al, 0x69
	jne	short 0x1A00
	jmp	near 0x1B87
	cmp	al, 0x75
	jne	short 0x1A07
	jmp	near 0x1B8B
	cmp	al, 0x58
	jne	short 0x1A0E
	jmp	near 0x1B91
	cmp	al, 0x78
	jne	short 0x1A15
	jmp	near 0x1B97
	cmp	al, 0x6f
	jne	short 0x1A1C
	jmp	near 0x1BB8
	cmp	al, 0x63
	je	short 0x1A3A
	cmp	al, 0x73
	je	short 0x1A4B
	cmp	al, 0x6e
	je	short 0x1A79
	cmp	al, 0x70
	je	short 0x1A8C
	cmp	al, 0x45
	je	short 0x1A37
	cmp	al, 0x47
	je	short 0x1A37
	jmp	near 0x1AF2
	jmp	near 0x1AEF
	call	0x1cc1
	lea	di, [bp-0x171]
	push	ss
	pop	es
	stosb
	dec	di
	mov	cx, 1
	jmp	near 0x1C36
	call	0x1cd5
	db	0x0B, 0xFF			; or	di, di
	jne	short 0x1A64
	mov	ax, es
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x1A64
	push	ds
	pop	es
	mov	di, 0x886b
	mov	cx, word [0x8871]
	jmp	near 0x1C36
	push	di
	mov	cx, word [bp-0xc]
	jcxz	0x1A71
	db	0x32, 0xC0			; xor	al, al
	repne scasb
	jne	short 0x1A71
	dec	di
	pop	cx
	db	0x2B, 0xF9			; sub	di, cx
	db	0x87, 0xCF			; xchg	di, cx
	jmp	near 0x1C36
	call	0x1cd5
	mov	ax, word [bp-8]
	stosw
	test	byte [bp-4], 0x10
	je	short 0x1A89
	db	0x33, 0xC0			; xor	ax, ax
	stosw
	jmp	near .next
	test	byte [bp-4], 0x30
	jne	short 0x1A97
	call	0x1cc1
	jmp	short 0x1AD0
	call	0x1cc9
	test	byte [bp-3], 0x18
	jne	short 0x1AD0
	mov	byte [bp-1], 7
	mov	cx, 0x10
	push	ss
	pop	es
	push	dx
	db	0x33, 0xD2			; xor	dx, dx
	lea	di, [bp-0x169]
	mov	si, 4
	call	0x1d56
	mov	cx, 0x10
	lea	di, [bp-0x16e]
	pop	ax
	db	0x33, 0xD2			; xor	dx, dx
	mov	si, 4
	call	0x1d56
	mov	byte [bp-0x16d], 0x3a
	mov	cx, 9
	jmp	short 0x1AE8
	mov	byte [bp-1], 7
	mov	cx, 0x10
	push	ss
	pop	es
	db	0x33, 0xD2			; xor	dx, dx
	lea	di, [bp-0x16e]
	mov	si, 4
	call	0x1d56
	mov	cx, 4
	lea	di, [bp-0x171]
	jmp	near 0x1C36
	inc	word [bp-0x12]
	or	byte [bp-4], 0x40
	mov	al, byte [bp-2]
	or	al, 0x20
	db	0x98			; cwde
	db	0x8B, 0xF0			; mov	si, ax
	cmp	word [bp-0xc], 0
	jg	short 0x1B17
	je	short 0x1B0D
	mov	word [bp-0xc], 6
	jmp	short 0x1B17
	db	0x3D, 0x67, 0x00			; cmp	ax, 0x67
	jne	short 0x1B17
	mov	word [bp-0xc], 1
	lea	di, [bp-0x171]
	push	word [bp-0x12]
	push	word [bp-0xc]
	push	si
	push	di
	push	word [bp+0xa]
	test	byte [bp-3], 4
	je	short 0x1B36
	call	far [0x888a]
	add	word [bp+0xa], 0xa
	jmp	short 0x1B3E
	call	far [0x8876]
	add	word [bp+0xa], 8
	add	sp, 0xa
	test	byte [bp-4], 0x80
	je	short 0x1B55
	cmp	word [bp-0xc], 0
	jne	short 0x1B55
	push	di
	call	far [0x8882]
	add	sp, 2
	cmp	si, 0x67
	jne	short 0x1B69
	test	word [bp-4], 0x80
	jne	short 0x1B69
	push	di
	call	far [0x887a]
	add	sp, 2
	push	ss
	pop	es
	cmp	byte [es:di], 0x2d
	jne	short 0x1B76
	inc	di
	or	byte [bp-3], 1
	mov	cx, 0xffff
	push	di
	mov	al, 0
	repne scasb
	dec	di
	pop	cx
	db	0x2B, 0xF9			; sub	di, cx
	db	0x87, 0xCF			; xchg	di, cx
	jmp	near 0x1C36
	or	byte [bp-4], 0x40
	mov	byte [bp-6], 0xa
	jmp	short 0x1BC6
	mov	byte [bp-1], 7
	jmp	short 0x1B9B
	mov	byte [bp-1], 0x27
	test	byte [bp-4], 0x80
	je	short 0x1BB2
	mov	word [bp-0x10], 2
	mov	byte [bp-0xe], 0x30
	mov	dl, 0x51
	add	dl, byte [bp-1]
	mov	byte [bp-0xd], dl
	mov	byte [bp-6], 0x10
	jmp	short 0x1BC6
	test	byte [bp-4], 0x80
	je	short 0x1BC2
	or	byte [bp-3], 2
	mov	byte [bp-6], 8
	test	byte [bp-4], 0x10
	je	short 0x1BD1
	call	0x1cc9
	jmp	short 0x1BDF
	call	0x1cc1
	test	byte [bp-4], 0x40
	je	short 0x1BDD
	db	0x99			; cdq
	jmp	short 0x1BDF
	db	0x33, 0xD2			; xor	dx, dx
	test	byte [bp-4], 0x40
	je	short 0x1BF4
	db	0x0B, 0xD2			; or	dx, dx
	jge	short 0x1BF4
	or	byte [bp-3], 1
	neg	ax
	adc	dx, 0
	neg	dx
	cmp	word [bp-0xc], 0
	jge	short 0x1C01
	mov	word [bp-0xc], 1
	jmp	short 0x1C05
	and	byte [bp-4], 0xf7
	db	0x8B, 0xD8			; mov	bx, ax
	db	0x0B, 0xDA			; or	bx, dx
	jne	short 0x1C10
	mov	word [bp-0x10], 0
	lea	di, [bp-0x15]
	push	ss
	pop	es
	mov	cl, byte [bp-6]
	db	0x32, 0xED			; xor	ch, ch
	mov	si, word [bp-0xc]
	call	0x1d56
	test	byte [bp-3], 2
	je	short 0x1C34
	jcxz	0x1C2E
	cmp	byte [es:di], 0x30
	je	short 0x1C34
	dec	di
	mov	byte [es:di], 0x30
	inc	cx
	jmp	short 0x1C36
	test	byte [bp-4], 0x40
	je	short 0x1C6D
	test	byte [bp-3], 1
	je	short 0x1C4D
	mov	byte [bp-0xe], 0x2d
	mov	word [bp-0x10], 1
	jmp	short 0x1C6D
	test	byte [bp-4], 1
	je	short 0x1C5E
	mov	byte [bp-0xe], 0x2b
	mov	word [bp-0x10], 1
	jmp	short 0x1C6D
	test	byte [bp-4], 2
	je	short 0x1C6D
	mov	byte [bp-0xe], 0x20
	mov	word [bp-0x10], 1
	mov	ax, word [bp-0xa]
	db	0x2B, 0xC1			; sub	ax, cx
	sub	ax, word [bp-0x10]
	jge	short 0x1C79
	db	0x33, 0xC0			; xor	ax, ax
	push	es
	push	di
	push	cx
	test	byte [bp-4], 0xc
	jne	short 0x1C89
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x20
	call	0x1d3a
	push	ax
	push	ss
	pop	es
	lea	di, [bp-0xe]
	mov	cx, word [bp-0x10]
	call	0x1d1c
	pop	ax
	test	byte [bp-4], 8
	je	short 0x1CA9
	test	byte [bp-4], 4
	jne	short 0x1CA9
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x30
	call	0x1d3a
	pop	cx
	pop	di
	pop	es
	push	ax
	call	0x1d1c
	pop	ax
	test	byte [bp-4], 4
	je	short 0x1CBE
	db	0x8B, 0xC8			; mov	cx, ax
	mov	dl, 0x20
	call	0x1d3a
	jmp	near .next
.getarg:
	mov	si, word [bp+0xa]
	lodsw
	mov	word [bp+0xa], si
	ret
	mov	si, word [bp+0xa]
	lodsw
	db	0x8B, 0xD0			; mov	dx, ax
	lodsw
	xchg	dx, ax
	mov	word [bp+0xa], si
	ret
	test	byte [bp-4], 0x20
	je	short 0x1CE3
	call	0x1cc9
	mov	es, dx
	db	0x8B, 0xF8			; mov	di, ax
	ret
	call	0x1cc1
	db	0x8B, 0xF8			; mov	di, ax
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x1CEF
	mov	es, ax
	ret
	push	ds
	pop	es
	ret
	db	0x98			; cwde
	push	di
	mov	bx, word [bp+6]
	dec	word [bx+2]
	js	short 0x1D06
	mov	di, word [bx]
	inc	word [bx]
	mov	byte [di], al
	db	0x33, 0xC0			; xor	ax, ax
	pop	di
	ret
	push	es
	push	cx
	push	dx
	push	bx
	push	ax
	push	cs
	call	0x1710
	add	sp, 4
	pop	dx
	pop	cx
	pop	es
	db	0x3D, 0xFF, 0xFF			; cmp	ax, 0xffff
	jne	short 0x1D02
	jmp	short 0x1D04
	jcxz	0x1D39
	db	0x8B, 0xF7			; mov	si, di
	add	word [bp-8], cx
	push	di
	db	0x33, 0xFF			; xor	di, di
	db	0x26, 0xAC			; lodsb
	call	0x1cf2
	db	0x0B, 0xF8			; or	di, ax
	loop	0x1D26
	db	0x0B, 0xFF			; or	di, di
	pop	di
	je	short 0x1D39
	mov	word [bp-8], 0xffff
	ret
.count:
	jcxz	0x1D55
	add	word [bp-8], cx
	push	di
	db	0x33, 0xFF			; xor	di, di
	db	0x8A, 0xC2			; mov	al, dl
	call	0x1cf2
	db	0x0B, 0xF8			; or	di, ax
	loop	0x1D42
	db	0x0B, 0xFF			; or	di, di
	pop	di
	je	short 0x1D55
	mov	word [bp-8], 0xffff
	ret
	std
	push	di
	xchg	bx, ax
	db	0x0B, 0xF6			; or	si, si
	jg	short 0x1D67
	db	0x0B, 0xDB			; or	bx, bx
	jne	short 0x1D67
	db	0x0B, 0xD2			; or	dx, dx
	jne	short 0x1D67
	jmp	short 0x1D81
	xchg	dx, ax
	db	0x33, 0xD2			; xor	dx, dx
	div	cx
	xchg	bx, ax
	div	cx
	xchg	dx, ax
	db	0x87, 0xD3			; xchg	bx, dx
	add	al, 0x30
	cmp	al, 0x39
	jbe	short 0x1D7B
	add	al, byte [bp-1]
	stosb
	db	0x8B, 0xC2			; mov	ax, dx
	dec	si
	jmp	short 0x1D59
	pop	cx
	db	0x2B, 0xCF			; sub	cx, di
	inc	di
	cld
	ret
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
	lodsb
	cmp	al, 0x20
	je	short 0x1DAF
	cmp	al, 9
	je	short 0x1DAF
	push	ax
	cmp	al, 0x2d
	je	short 0x1DC1
	cmp	al, 0x2b
	jne	short 0x1DC2
	lodsb
	cmp	al, 0x39
	ja	short 0x1DE5
	sub	al, 0x30
	jb	short 0x1DE5
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
	jmp	short 0x1DC1
	pop	ax
	cmp	al, 0x2d
	xchg	bx, ax
	jne	short 0x1DF2
	neg	ax
	adc	dx, 0
	neg	dx
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
	je	short 0x1E3C
	lea	ax, [bx+0x20]
	jmp	short 0x1E42
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	db	0x98			; cwde
	db	0x3D, 0x65, 0x00			; cmp	ax, 0x65
	je	short 0x1E59
	inc	word [bp+6]
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	test	byte [bx-0x7a73], 4
	jne	short 0x1E47
	mov	bx, word [bp+6]
	mov	al, byte [bx]
	mov	byte [bp-2], al
	mov	byte [bx], 0x2e
	inc	word [bp+6]
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
	jne	short 0x1E67
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144

ScanPoint:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 4
	jmp	short 0x1E9A
	cmp	byte [bx], 0x2e
	je	short 0x1EA2
	inc	word [bp+6]
	mov	bx, word [bp+6]
	cmp	byte [bx], 0
	jne	short 0x1E92
	inc	word [bp+6]
	cmp	byte [bx], 0
	je	short 0x1EF3
	jmp	short 0x1EB9
	cmp	byte [bx], 0x65
	je	short 0x1EC1
	cmp	byte [bx], 0x45
	je	short 0x1EC1
	inc	word [bp+6]
	mov	bx, word [bp+6]
	cmp	byte [bx], 0
	jne	short 0x1EAC
	db	0x8B, 0xC3			; mov	ax, bx
	dec	word [bp+6]
	mov	word [bp-2], ax
	jmp	short 0x1ECF
	db	144
	dec	word [bp+6]
	mov	bx, word [bp+6]
	cmp	byte [bx], 0x30
	je	short 0x1ECC
	cmp	byte [bx], 0x2e
	jne	short 0x1EDF
	dec	word [bp+6]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	al, byte [bx]
	inc	word [bp+6]
	mov	bx, word [bp+6]
	mov	byte [bx], al
	db	0x0A, 0xC0			; or	al, al
	jne	short 0x1EDF
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
	je	short 0x1F68
	dec	ax
	je	short 0x1F4E
	push	word [bp+0xc]
	db	0x9A, 0xF8, 0x27, 0x00, 0x00			; call	0:SkipSpace
	add	sp, 2
	db	0x8B, 0xD8			; mov	bx, ax
	int	0x39
	pop	es
	les	bx, [bp+8]
	int	0x3c
	fstp	dword [bx]
	jmp	short 0x1F60
	db	144
	push	word [bp+0xc]
	db	0x9A, 0x18, 0x2C, 0x00, 0x00			; call	0:FloatStatus
	add	sp, 2
	les	bx, [bp+8]
	int	0x3c
	db	0xDB, 0x3F			; fstp	xword [bx]
	int	0x3d
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
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
	cmp	byte [0x8a1c], 0
	je	short 0x1FBC
	mov	bx, word [0x909e]
	mov	word [bp-2], bx
	cmp	word [bx], 0x2d
	jne	short 0x1FA2
	mov	si, 1
	jmp	short 0x1FA4
	db	0x2B, 0xF6			; sub	si, si
	add	si, word [bp+8]
	push	si
	cmp	word [bp+0xa], 0
	jle	short 0x1FB4
	mov	ax, 1
	jmp	short 0x1FB6
	db	144
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	call	0x22e8
	jmp	short 0x2009
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
	jle	short 0x1FE6
	mov	ax, 1
	jmp	short 0x1FE8
	db	0x2B, 0xC0			; sub	ax, ax
	mov	bx, word [bp-2]
	mov	word [bp-4], ax
	cmp	word [bx], 0x2d
	jne	short 0x1FF8
	mov	ax, 1
	jmp	short 0x1FFA
	db	0x2B, 0xC0			; sub	ax, ax
	add	ax, word [bp-4]
	add	ax, word [bp+8]
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
	mov	si, word [bp+8]
	mov	bx, word [bp-2]
	cmp	word [bx], 0x2d
	jne	short 0x2018
	mov	byte [si], 0x2d
	inc	si
	cmp	word [bp+0xa], 0
	jle	short 0x202B
	mov	al, byte [si+1]
	mov	byte [si], al
	lea	ax, [si+1]
	db	0x8B, 0xF0			; mov	si, ax
	mov	byte [si], 0x2e
	mov	ax, 0x8a16
	push	ax
	cmp	byte [0x8a1c], 1
	db	0x1B, 0xC0			; sbb	ax, ax
	neg	ax
	add	ax, word [bp+0xa]
	db	0x03, 0xC6			; add	ax, si
	push	ax
	call	0:0xC6C
	add	sp, 4
	db	0x8B, 0xF0			; mov	si, ax
	cmp	word [bp+0xc], 0
	je	short 0x2051
	mov	byte [si], 0x45
	inc	si
	mov	bx, word [bp-2]
	mov	bx, word [bx+6]
	cmp	byte [bx], 0x30
	je	short 0x20A2
	mov	bx, word [bp-2]
	mov	di, word [bx+2]
	dec	di
	jns	short 0x206F
	db	0x8B, 0xC7			; mov	ax, di
	neg	ax
	db	0x8B, 0xF8			; mov	di, ax
	mov	byte [si], 0x2d
	inc	si
	cmp	di, 0x64
	jl	short 0x2086
	db	0x8B, 0xC7			; mov	ax, di
	mov	cx, 0x64
	db	0x99			; cdq
	idiv	cx
	add	byte [si], al
	db	0x8B, 0xC7			; mov	ax, di
	db	0x99			; cdq
	idiv	cx
	db	0x8B, 0xFA			; mov	di, dx
	inc	si
	cmp	di, 0xa
	jl	short 0x209D
	db	0x8B, 0xC7			; mov	ax, di
	mov	cx, 0xa
	db	0x99			; cdq
	idiv	cx
	add	byte [si], al
	db	0x8B, 0xC7			; mov	ax, di
	db	0x99			; cdq
	idiv	cx
	db	0x8B, 0xFA			; mov	di, dx
	db	0x8B, 0xC7			; mov	ax, di
	inc	si
	add	byte [si], al
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
	mov	byte [0x8a1c], 1
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x1f82
	mov	byte [0x8a1c], 0
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FloatWidth:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	sub	sp, 6
	push	si
	cmp	byte [0x8a1c], 0
	je	short 0x210A
	mov	bx, word [0x909e]
	mov	word [bp-2], bx
	cmp	word [bx], 0x2d
	jne	short 0x20F0
	mov	si, 1
	jmp	short 0x20F2
	db	144
	db	0x2B, 0xF6			; sub	si, si
	add	si, word [bp+8]
	mov	ax, word [0x8a1e]
	cmp	word [bp+0xa], ax
	jne	short 0x2146
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx+si], 0x30
	db	0x03, 0xDE			; add	bx, si
	inc	bx
	mov	byte [bx], 0
	jmp	short 0x2146
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
	jne	short 0x2138
	mov	ax, 1
	jmp	short 0x213A
	db	144
	db	0x2B, 0xC0			; sub	ax, ax
	add	ax, word [bp+8]
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
	mov	si, word [bp+8]
	mov	bx, word [bp-2]
	cmp	word [bx], 0x2d
	jne	short 0x2155
	mov	byte [si], 0x2d
	inc	si
	cmp	word [bx+2], 0
	jg	short 0x216A
	push	si
	mov	ax, 1
	push	ax
	call	0x22e8
	mov	byte [si], 0x30
	inc	si
	jmp	short 0x216D
	db	144
	add	si, word [bx+2]
	cmp	word [bp+0xa], 0
	jle	short 0x21BB
	push	si
	mov	ax, 1
	push	ax
	call	0x22e8
	mov	byte [si], 0x2e
	inc	si
	mov	bx, word [bp-2]
	cmp	word [bx+2], 0
	jge	short 0x21BB
	cmp	byte [0x8a1c], 0
	je	short 0x2196
	mov	ax, word [bx+2]
	neg	ax
	jmp	short 0x21A3
	mov	ax, word [bx+2]
	neg	ax
	cmp	ax, word [bp+0xa]
	jle	short 0x21A3
	mov	ax, word [bp+0xa]
	mov	word [bp+0xa], ax
	push	si
	push	ax
	call	0x22e8
	push	word [bp+0xa]
	mov	ax, 0x30
	push	ax
	push	si
	db	0x9A, 0x64, 0x29, 0x00, 0x00			; call	0:_memset
	add	sp, 6
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
	mov	byte [0x8a1c], 1
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x20d0
	mov	byte [0x8a1c], 0
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
	mov	word [0x909e], ax
	db	0x8B, 0xD8			; mov	bx, ax
	mov	ax, word [bx+2]
	dec	ax
	mov	word [0x8a1e], ax
	push	bx
	push	word [bp+0xa]
	cmp	word [bx], 0x2d
	jne	short 0x221C
	mov	ax, 1
	jmp	short 0x221E
	db	0x2B, 0xC0			; sub	ax, ax
	add	ax, word [bp+8]
	mov	word [bp-2], ax
	push	ax
	db	0x9A, 0x3E, 0x28, 0x00, 0x00			; call	0:WriteDigits
	add	sp, 6
	mov	bx, word [0x909e]
	mov	ax, word [bx+2]
	dec	ax
	mov	word [bp-4], ax
	cmp	ax, word [0x8a1e]
	jle	short 0x2242
	mov	al, 1
	jmp	short 0x2244
	db	0x2A, 0xC0			; sub	al, al
	mov	byte [0x8a20], al
	mov	ax, word [bp-4]
	mov	word [0x8a1e], ax
	db	0x3D, 0xFC, 0xFF			; cmp	ax, 0xfffc
	jl	short 0x2257
	cmp	ax, word [bp+0xa]
	jl	short 0x226E
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x20ac
	add	sp, 8
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	cmp	byte [0x8a20], 0
	je	short 0x2287
	mov	bx, word [bp-2]
	inc	word [bp-2]
	cmp	byte [bx], 0
	jne	short 0x2275
	mov	bx, word [bp-2]
	mov	byte [bx-2], 0
	push	word [bp+0xa]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x21c4
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatExp:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+0xa], 0x65
	je	short 0x22A7
	cmp	word [bp+0xa], 0x45
	jne	short 0x22BE
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x1f82
	db	0x8B, 0xE5			; mov	sp, bp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
	cmp	word [bp+0xa], 0x66
	jne	short 0x22D4
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x20d0
	jmp	short 0x22B7
	db	144
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x21e6
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatLen:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+4], 0
	je	short 0x230C
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
	jge	short 0x2379
	mov	ax, 1
	push	ax
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	lea	ax, [bp-0x1a]
	push	ax
	call	0x29c4
	push	word [bp+0xc]
	push	word [bp+0xa]
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	0x239a
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
	jne	short 0x23C1
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx], 0x2d
	inc	ax
	mov	word [bp-2], ax
	mov	bx, word [bp+6]
	cmp	byte [bx+3], 0
	je	short 0x23DC
	db	0x8B, 0xD9			; mov	bx, cx
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	jmp	short 0x23ED
	db	144
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	mov	bx, word [bp+6]
	inc	byte [bx+3]
	inc	word [bx]
	cmp	word [bp+0xa], 0
	jle	short 0x2436
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2e
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	dec	ax
	mov	word [bp-4], ax
	sub	word [bp+0xa], ax
	jmp	short 0x241F
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	dec	word [bp-4]
	cmp	word [bp-4], 0
	jne	short 0x240C
	jmp	short 0x2431
	db	144
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	dec	word [bp+0xa]
	jns	short 0x2428
	cmp	word [bp+0xc], 0
	je	short 0x2448
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x45
	jmp	short 0x2451
	db	144
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x65
	mov	bx, word [bp+6]
	mov	ax, word [bx]
	dec	ax
	mov	word [bp-8], ax
	db	0x0B, 0xC0			; or	ax, ax
	jge	short 0x246E
	neg	ax
	mov	word [bp-8], ax
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2d
	jmp	short 0x2477
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2b
	cmp	ax, 0x3e8
	jl	short 0x2495
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
	jge	short 0x2504
	db	0x2B, 0xC0			; sub	ax, ax
	push	ax
	mov	ax, 1
	push	ax
	lea	ax, [bp-0x1a]
	push	ax
	call	0x29c4
	push	word [bp+0xa]
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	0x2522
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
	jne	short 0x254B
	db	0x8B, 0xD8			; mov	bx, ax
	mov	byte [bx], 0x2d
	inc	ax
	mov	word [bp-2], ax
	cmp	word [bp-8], 0
	jle	short 0x259C
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	cmp	ax, word [bp-8]
	jle	short 0x2560
	mov	ax, word [bp-8]
	mov	word [bp-4], ax
	sub	word [bp-8], ax
	mov	al, byte [bp-4]
	sub	byte [bx+3], al
	jmp	short 0x257E
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	mov	ax, word [bp-4]
	dec	word [bp-4]
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x256E
	cmp	word [bp-8], 0
	je	short 0x25A5
	dec	word [bp-8]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	jmp	short 0x2588
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	cmp	word [bp+0xa], 0
	jle	short 0x2615
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x2e
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	sub	ax, word [bp-8]
	neg	ax
	add	word [bp+0xa], ax
	jmp	short 0x25CF
	db	144
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	mov	ax, word [bp-8]
	inc	word [bp-8]
	db	0x0B, 0xC0			; or	ax, ax
	jl	short 0x25C6
	mov	bx, word [bp+6]
	mov	al, byte [bx+3]
	db	0x98			; cwde
	mov	word [bp-4], ax
	jmp	short 0x25F6
	db	144
	mov	bx, word [bp-6]
	inc	word [bp-6]
	mov	al, byte [bx]
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], al
	mov	ax, word [bp-4]
	dec	word [bp-4]
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x25E6
	jmp	short 0x260B
	mov	bx, word [bp-2]
	inc	word [bp-2]
	mov	byte [bx], 0x30
	mov	ax, word [bp+0xa]
	dec	word [bp+0xa]
	db	0x0B, 0xC0			; or	ax, ax
	jg	short 0x2602
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
	jg	short 0x2633
	mov	word [bp+0xa], 1
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
	call	0x29c4
	cmp	word [bp-0x1a], -4
	jle	short 0x265F
	mov	ax, word [bp-0x1a]
	cmp	word [bp+0xa], ax
	jge	short 0x267A
	push	word [bp+0xc]
	mov	ax, word [bp+0xa]
	dec	ax
	push	ax
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	0x239a
	add	sp, 8
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
	mov	ax, word [bp+0xa]
	sub	ax, word [bp-0x1a]
	push	ax
	push	word [bp+8]
	lea	ax, [bp-0x1a]
	push	ax
	push	cs
	call	0x2522
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf

FormatExp2:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	cmp	word [bp+0xa], 0x65
	je	short 0x269F
	cmp	word [bp+0xa], 0x45
	jne	short 0x26B6
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x2356
	db	0x8B, 0xE5			; mov	sp, bp
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	db	144
	cmp	word [bp+0xa], 0x66
	je	short 0x26C2
	cmp	word [bp+0xa], 0x46
	jne	short 0x26D2
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x24e4
	jmp	short 0x26AF
	db	144
	push	word [bp+0xe]
	push	word [bp+0xc]
	push	word [bp+8]
	push	word [bp+6]
	push	cs
	call	0x2622
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
	je	short 0x2710
	or	byte [si+6], 8
	mov	word [bx+2], 0x200
	jmp	short 0x271C
	or	byte [si+6], 4
	mov	word [bx+2], 1
	lea	ax, [bx+1]
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
	call	0x27a6
	jmp	short 0x2798
	db	144
.one:
	mov	si, word [bp+6]
	mov	al, byte [si+6]
	db	0x8B, 0xC8			; mov	cx, ax
	and	al, 3
	cmp	al, 2
	jne	short 0x278C
	test	cl, 8
	jne	short 0x2762
	db	0x8B, 0xDE			; mov	bx, si
	sub	bx, 0x86ca
	test	byte [bx-0x7896], 1
	je	short 0x278C
	mov	ax, word [si]
	sub	ax, word [si+4]
	mov	word [bp-2], ax
	db	0x0B, 0xC0			; or	ax, ax
	jle	short 0x278C
	push	ax
	push	word [si+4]
	mov	cl, byte [si+7]
	db	0x2A, 0xED			; sub	ch, ch
	push	cx
	call	0:0xAEC
	add	sp, 6
	cmp	word [bp-2], ax
	je	short 0x278C
	or	byte [si+6], 0x20
	mov	di, 0xffff
	mov	ax, word [si+4]
	mov	word [si], ax
	mov	word [si+2], 0
	db	0x8B, 0xC7			; mov	ax, di
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
	jmp	short 0x27C0
	mov	word [bp-2], 0xffff
	add	si, 8
	cmp	word [0x880a], si
	jb	short 0x27DC
	test	byte [si+6], 0x83
	je	short 0x27BD
	push	si
	db	0x9A, 0x2A, 0x27, 0x00, 0x00			; call	0:fflush
	add	sp, 2
	inc	ax
	je	short 0x27B8
	inc	di
	jmp	short 0x27BD
	db	144
	cmp	word [bp+4], 1
	jne	short 0x27E6
	db	0x8B, 0xC7			; mov	ax, di
	jmp	short 0x27E9
	mov	ax, word [bp-2]
	pop	si
	pop	di
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	ret	2
	db	144

JmpFpConvert:
	jmp	0:0x2C5D
	db	0

SkipSpace:
	push	bp
	db	0x8B, 0xEC			; mov	bp, sp
	push	di
	push	si
	mov	si, word [bp+6]
	jmp	short 0x2803
	inc	si
	mov	al, byte [si]
	db	0x98			; cwde
	db	0x8B, 0xD8			; mov	bx, ax
	test	byte [bx-0x7a73], 8
	jne	short 0x2802
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
	jmp	short 0x2867
	cmp	byte [di], 0
	je	short 0x2860
	mov	al, byte [di]
	mov	byte [si], al
	inc	di
	jmp	short 0x2863
	mov	byte [si], 0x30
	inc	si
	dec	word [bp+8]
	cmp	word [bp+8], 0
	jg	short 0x2854
	mov	byte [si], 0
	cmp	word [bp+8], 0
	jl	short 0x2889
	cmp	byte [di], 0x35
	jl	short 0x2889
	jmp	short 0x2881
	db	144
	mov	byte [si], 0x30
	dec	si
	cmp	byte [si], 0x39
	je	short 0x287E
	inc	byte [si]
	mov	bx, word [bp+6]
	cmp	byte [bx], 0x31
	jne	short 0x289A
	mov	bx, word [bp+0xa]
	inc	word [bx+2]
	jmp	short 0x28A7
	db	144
	db	0x8B, 0xC3			; mov	ax, bx
	inc	ax
	push	ax
	push	bx
	call	0:0xC6C
	add	sp, 4
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
	jcxz	0x295E
	db	0x3B, 0xFE			; cmp	di, si
	jbe	short 0x294E
	db	0x8B, 0xC6			; mov	ax, si
	db	0x03, 0xC1			; add	ax, cx
	db	0x3B, 0xF8			; cmp	di, ax
	jae	short 0x294E
	db	0x8B, 0xC7			; mov	ax, di
	db	0x03, 0xF1			; add	si, cx
	db	0x03, 0xF9			; add	di, cx
	dec	si
	dec	di
	std
	rep movsb
	cld
	jmp	short 0x295E
	db	0x8B, 0xC7			; mov	ax, di
	test	al, 1
	je	short 0x2956
	movsb
	dec	cx
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc	cx, cx
	rep movsb
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
	jcxz	0x298C
	mov	al, byte [bp+8]
	db	0x8A, 0xE0			; mov	ah, al
	test	di, 1
	je	short 0x2984
	stosb
	dec	cx
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc	cx, cx
	rep stosb
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
	cmp	word [0x8ae4], 0xd6d6
	jne	short 0x29A8
	call	word [0x8ae6]
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
	je	short 0x29F1
	and	byte [bp+0x13], 0x7f
	mov	byte [ss:di+2], 0x2d
	and	ax, 0x7fff
	db	0x0B, 0xC0			; or	ax, ax
	jne	short 0x2A05
	mov	ax, word [bp+0xa]
	or	ax, word [bp+0xc]
	or	ax, word [bp+0xe]
	or	ax, word [bp+0x10]
	je	short 0x2A50
	jmp	short 0x2A6A
	cmp	ax, 0x7fff
	jne	short 0x2A6A
	mov	ax, word [bp+0xa]
	or	ax, word [bp+0xc]
	or	ax, word [bp+0xe]
	mov	ax, word [bp+0x10]
	jne	short 0x2A2F
	mov	si, 0x8a52
	cmp	ax, 0x8000
	je	short 0x2A3A
	cmp	ax, 0xc000
	jne	short 0x2A2F
	mov	si, 0x8a58
	cmp	byte [ss:di+2], 0x2d
	je	short 0x2A3A
	mov	si, 0x8a44
	test	ax, 0x4000
	je	short 0x2A3A
	mov	si, 0x8a4b
	mov	word [ss:di], 1
	push	ss
	pop	es
	lea	di, [di+3]
	db	0x33, 0xC9			; xor	cx, cx
	mov	cl, byte [si]
	inc	cx
	rep movsb
	db	0x33, 0xC0			; xor	ax, ax
	jmp	near 0x2BC9
	mov	di, word [bp+4]
	mov	word [ss:di], 0
	mov	byte [ss:di+2], 0x20
	mov	byte [ss:di+3], 0
	mov	byte [ss:di+4], 0
	jmp	near 0x2BC6
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
	call	0x30d0
	pop	di
	cmp	word [bp+0x12], 0x3fff
	jb	short 0x2ABA
	inc	di
	lea	ax, [bp+8]
	push	ss
	push	ax
	mov	ax, 0x29b8
	push	cs
	push	ax
	call	0x31a5
	jmp	short 0x2AA3
	mov	bx, word [bp+4]
	mov	word [ss:bx], di
	mov	ax, word [bp-2]
	test	word [bp+6], 1
	je	short 0x2AD0
	db	0x03, 0xC7			; add	ax, di
	jns	short 0x2AD0
	jmp	short 0x2A50
	db	0x3D, 0x15, 0x00			; cmp	ax, 0x15
	jbe	short 0x2AD8
	mov	ax, 0x15
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
	je	short 0x2B0C
	shr	bx, 1
	rcr	cx, 1
	rcr	dx, 1
	rcr	si, 1
	rcr	di, 1
	rcr	ah, 1
	dec	al
	jne	short 0x2AFC
	push	ss
	pop	es
	mov	word [bp-0xa], di
	mov	di, word [bp+4]
	lea	di, [di+4]
	xchg	word [bp-0xa], di
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
	jne	short 0x2B1A
	mov	di, word [bp-0xa]
	mov	si, word [bp+4]
	sub	di, 2
	cmp	al, 0x35
	jb	short 0x2BB1
	lea	cx, [si+4]
	jmp	short 0x2B97
	cmp	byte [es:di], 0x39
	jne	short 0x2BA3
	mov	byte [es:di], 0x30
	dec	di
	db	0x3B, 0xCF			; cmp	cx, di
	jbe	short 0x2B8C
	inc	di
	mov	byte [es:di], 0x30
	inc	word [ss:si]
	inc	byte [es:di]
	db	0x2B, 0xF9			; sub	di, cx
	db	0x8B, 0xDF			; mov	bx, di
	inc	bx
	mov	byte [ss:si+3], bl
	jmp	short 0x2BC6
	mov	cx, word [bp-2]
	jcxz	0x2BBE
	mov	al, 0x30
	std
	repe scasb
	cld
	jne	short 0x2BC1
	jmp	near 0x2A50
	inc	cx
	mov	byte [ss:si+3], cl
	mov	ax, 1
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
	call	0x2cd3
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
	call	0x332a
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
	jae	short 0x2C58
	dec	bx
	dec	bx
	or	byte [bx], 1
	cmp	word [si+8], bx
	jbe	short 0x2C58
	mov	word [si+8], bx
	pop	si
	db	0x8B, 0xE5			; mov	sp, bp
	pop	bp
	retf
	incbin	"Extracted/segments/seg000.bin", 0x2C5D
