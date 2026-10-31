; The previous segment ends in the middle of a near call. These four
; bytes are the last byte of that call, then leave / retf, and a nop.
	db	0xFE
	leave
	retf
	nop

; Startup calls these two. Each is only a far return.
NullStartup4:
	retf
	nop
NullStartup6:
	retf
	nop

; _main: the far call from MscStartup lands here. It is not a lone retf.
; It compares two long results with fixed limits, prints the shortfall
; in 1024-byte units and exits if either is low, then calls the other
; segments. 320 and 200 are passed through as a pair. Paragraph 0x3415
; is the one the overlay startup preloads. The last bytes are the start
; of a far call that finishes in the next segment.
_main:
	enter	0x24, 0
	push	di
	push	si
	db	0x2B, 0xF6			; sub	si, si
	push	0x12c
	call	0x14DB:0xDB		; seg034
	add	sp, 2
	mov	word [bp-4], ax
	mov	word [bp-2], dx
	cmp	dx, 3
	jg	short .2
	jl	short .1
	cmp	ax, 0x2c00
	jae	short .2
.1:
	push	si
	push	0x400
	mov	ax, 0x2fff
	mov	dx, 3
	sub	ax, word [bp-4]
	sbb	dx, word [bp-2]
	push	dx
	push	ax
	call	0x0000:__aFldiv		; seg000
	push	dx
	push	ax
	push	0x42e
	call	0x0000:_printf		; seg000
	add	sp, 6
	mov	si, 1
.2:
	push	0x40
	push	0
	call	0x03A3:0xE7		; seg001
	add	sp, 4
	mov	word [bp-4], ax
	mov	word [bp-2], dx
	cmp	dx, 0x1f
	jg	short .4
	jl	short .3
	cmp	ax, 0xfc00
	jae	short .4
.3:
	push	0
	push	0x400
	mov	ax, 0xffff
	mov	dx, 0x1f
	sub	ax, word [bp-4]
	sbb	dx, word [bp-2]
	push	dx
	push	ax
	call	0x0000:__aFldiv		; seg000
	push	dx
	push	ax
	push	0x47e
	call	0x0000:_printf		; seg000
	add	sp, 6
	mov	si, 1
.4:
	db	0x0B, 0xF6			; or	si, si
	je	short .5
	call	0x0000:_exit		; seg000
.5:
	call	0x0FEF:0x39A		; seg028
	call	0x03A3:0xCCA		; seg001
	mov	word [0x524], 0
	push	0x969
	push	0x3fe
	call	0x03A3:0xD8C		; seg001
	add	sp, 4
	push	0
	call	0x0FEF:0x1320		; seg028
	add	sp, 2
	mov	bx, 0x7570
	mov	es, word [0x8b08]
	mov	word [bp-0x24], bx
	mov	word [bp-0x22], es
	mov	ax, word [es:bx+2]
	or	ax, word [es:bx]
	je	short .6
	push	word [es:bx+2]
	push	word [es:bx]
	call	0x06E1:0x99A		; seg002
	add	sp, 4
	les	bx, [bp-0x24]
	db	0x2B, 0xC0			; sub	ax, ax
	mov	word [es:bx+2], ax
	mov	word [es:bx], ax
.6:
	push	0
	push	2
	push	4
	push	0xc8
	push	0x140
	push	0xc8
	push	0x140
	call	0x0FEF:0x3804		; seg028
	add	sp, 0xe
	push	0xc8
	call	0x0FEF:0x1320		; seg028
	add	sp, 2
	or	byte [0xaece], 8
	push	0xc8
	push	0x140
	call	0x03A3:0x1C7B		; seg001
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	je	short .7
	or	byte [0xaece], 1
.7:
	call	0x03A3:0x1D72		; seg001
	mov	word [bp-6], ax
	test	byte [0x75e0], 3
	je	short .9
	cmp	word [0x75d6], 0
	jne	short .8
	cmp	word [0x75d8], 0
	je	short .9
.8:
	or	byte [0xaece], 2
	call	0x03A3:0x1405		; seg001
	call	0x1508:0x232		; seg037
	mov	word [0x51e], 1
.9:
	test	byte [0x75e0], 0xc
	je	short .11
	cmp	word [0x75da], 0
	jne	short .10
	cmp	word [0x75dc], 0
	je	short .11
.10:
	or	byte [0xaece], 4
	call	0x03A3:0x1423		; seg001
	call	0x1508:0x244		; seg037
	mov	word [0x520], 1
.11:
	call	0x0BFE:0xE		; seg009
	lea	ax, [bp-6]
	push	ax
	push	ax
	push	ax
	call	0x03A3:0x1B34		; seg001
	add	sp, 6
	push	0xd90
	push	0x14b8
	call	0x03A3:0x3E4		; seg001
	add	sp, 4
	push	0x3701
	push	0xbd0
	push	ds
	push	0x4be
	push	0
	push	0
	lea	ax, [bp-0x20]
	push	ss
	push	ax
	call	0x0CD1:0x3E		; seg015
	add	sp, 0x10
	push	0
	lea	ax, [bp-0x20]
	push	ax
	call	0x14B8:0x8		; seg033
	add	sp, 4
	mov	word [0xaeb2], ax
	mov	word [0xaeb4], dx
	push	0x4c7
	push	dx
	push	ax
	call	0x03A3:0x847		; seg001
	add	sp, 6
	mov	word [0xae98], ax
	mov	word [0xae9a], dx
	push	0
	push	0x4cc
	call	0x149D:0x2		; seg032
	add	sp, 4
	mov	word [0xae90], ax
	mov	word [0xae92], dx
	push	0
	push	0x4d9
	call	0x149D:0x2		; seg032
	add	sp, 4
	mov	word [0xaeb6], ax
	mov	word [0xaeb8], dx
	push	0
	push	0x4e4
	call	0x149D:0x2		; seg032
	add	sp, 4
	mov	word [0xaeba], ax
	mov	word [0xaebc], dx
	push	word [0xae92]
	push	word [0xae90]
	call	0x03A3:0xCB8		; seg001
	add	sp, 4
	lea	ax, [bp-8]
	push	ax
	push	0x4ef
	call	0x0CD1:0x3D6		; seg015
	add	sp, 4
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .14
	push	0x62
	push	-1
	push	-1
	push	0x3415
	db	0x68, 0x00, 0x00			; push	0
	push	word [bp-8]
	call	0x0CD1:0x442		; seg015
	add	sp, 0xc
	db	0x0B, 0xC0			; or	ax, ax
	je	short .12
	push	0x4f8
	call	0x0F4A:0x3E4		; seg022
	add	sp, 2
.12:
	lea	ax, [bp-8]
	push	ax
	call	0x0CD1:0x41E		; seg015
	add	sp, 2
	db	0x0B, 0xC0			; or	ax, ax
	jne	short .13
	jmp	near .22
.13:
	push	0x4fb
	call	0x0F4A:0x3E4		; seg022
	add	sp, 2
	jmp	near .22
.14:
	test	byte [0xaece], 2
	je	short .15
	mov	ax, 0x3415
	mov	es, ax
	mov	word [es:0x5a], 2
	jmp	short .19
	nop
.15:
	test	byte [0xaece], 4
	je	short .16
	mov	ax, 0x3415
	mov	es, ax
	mov	word [es:0x5a], 4
	jmp	short .19
	nop
.16:
	test	byte [0xaece], 8
	je	short .17
	mov	ax, 0x3415
	mov	es, ax
	mov	word [es:0x5a], 8
	jmp	short .19
	nop
.17:
	test	byte [0xaece], 1
	je	short .18
	mov	ax, 0x3415
	mov	es, ax
	mov	word [es:0x5a], 1
	jmp	short .19
	nop
.18:
	mov	ax, 0x3415
	mov	es, ax
	mov	word [es:0x5a], 0x10
.19:
	mov	word [es:0x5c], 0x10
	mov	word [es:0x5e], 0
	mov	word [es:0x60], 1
	cmp	word [es:0x5a], 0x10
	je	short .20
	mov	ax, 9
	jmp	short .21
.20:
	mov	ax, 0xffff
.21:
	mov	word [es:0x56], ax
	mov	word [es:0x58], 0xfffe
.22:
	push	0x3415
	db	0x68, 0x00, 0x00			; push	0
	call	0x1B35:OvlThunk26		; seg056
	add	sp, 4
	call	0x1B35:OvlThunk25		; seg056
	call	0x1B35:OvlThunk24		; seg056
	push	0
	push	0
	push	0x300
	push	0x4fe
	call	0x14DB:0x30		; seg034
	add	sp, 8
	mov	word [bp-2], dx
	push	dx
	push	ax
	push	0x100
	push	0
	db	0x8B, 0xF0			; mov	si, ax
	db	0x8B, 0xFA			; mov	di, dx
	call	0x0FEF:0x366		; seg028
	add	sp, 8
	push	0x10
	push	di
	push	si
	push	1
	call	0x1B35:OvlThunk23		; seg056
	add	sp, 8
	push	di
	push	si
	call	0x06E1:0x99A		; seg002
	add	sp, 4
	lea	ax, [bp-0xc]
	push	ax
	call	0x0000:_dos_gettime		; seg000
	add	sp, 2
	mov	al, byte [bp-9]
	db	0x2A, 0xE4			; sub	ah, ah
	push	ax
	call	0x0000:_srand		; seg000
	add	sp, 2
	call	0x1B35:OvlThunk22		; seg056
	push	0
	push	0
	push	0x300
	push	0x503
	call	0x14DB:0x30		; seg034
	add	sp, 8
	push	dx
	push	ax
	push	0x100
	push	0
	db	0x8B, 0xF0			; mov	si, ax
	db	0x8B, 0xFA			; mov	di, dx
	call	0x0FEF:0x366		; seg028
	add	sp, 8
	push	0x10
	push	di
	push	si
	push	1
	call	0x1B35:OvlThunk23		; seg056
	add	sp, 8
	call	0x0BFE:0xE		; seg009
	call	0x1B35:OvlThunk27		; seg056
	push	di
	push	si
	push	0x100
	push	0
	call	0x0FEF:0x366		; seg028
	add	sp, 8
	push	0x10
	push	di
	push	si
	push	1
	call	0x1B35:OvlThunk23		; seg056
	add	sp, 8
	call	0x0837:0xC		; seg003

; The far call continues in the next segment. Those bytes complete it as
; a call to _exit.
	db	0x9A, 0x87
