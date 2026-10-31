; Segment seg001. EMS maps, far copies, the INT 24h hook, and file length.
; The first bytes finish the seg000 routine that ends on this paragraph.

; DGROUP words this segment uses. The bytes live in the near data, not here.
EmsMapCache	equ	0x24C
EmsWindowOff	equ	0x254
EmsOutPtr	equ	0x25C
EmsFrame	equ	0x260
EmsHandle	equ	0x262
EmmName		equ	0x264
EndPtr		equ	0x6DA4
EndMark		equ	0x62F6
CritRoutine	equ	0x62FE
CritOld		equ	0x62FA
SavedSp		equ	0x6402

; The previous segment ends on the first byte of test bx, 8.
; These bytes finish that test, then pop bp / ret 0xe.
	db	0xC3, 0x08, 0x00		; test bx, 8
	jne	short SpillRet
	mov	ax, 1
SpillRet:
	db	0x8B, 0xE5			; mov sp, bp
	pop	bp
	ret	0xe


; EmsMap: map CX logical pages starting at BX onto physical pages starting at AL.
; INT 67h AH=44h, handle at EmsHandle. Skips the call when the cache already matches.
; Carry set on failure. Near.
EmsMap:
	db	0x32, 0xE4			; xor ah, ah
	db	0x8B, 0xF0			; mov si, ax
	cmp	si, 4
	jae	short .2
	db	0x03, 0xF6			; add si, si
	and	word [si + EmsMapCache], 0x7fff
	db	0x8B, 0xD3			; mov dx, bx
	and	dx, 0x8000
	or	word [si + EmsMapCache], dx
	cmp	word [si + EmsMapCache], bx
	je	short .1
	cmp	bx, 0
	jl	short .1
	mov	word [si + EmsMapCache], bx
	mov	dx, word [EmsHandle]
	mov	ah, 0x44
	int	0x67
	db	0x0A, 0xE4			; or ah, ah
	jne	short .2
.1:
	inc	al
	inc	bx
	loop	EmsMap
	clc
	ret
.2:
	stc
	ret

; EmsMapRange: map the byte range (long at [bp+6], length at [bp+0Ah]) into a
; free physical window and return DX:AX inside the page frame. Zero if none fit.
EmsMapRange:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	si
	mov	ax, word [bp + 6]
	and	ax, 0x3fff
	add	ax, word [bp + 0xa]
	dec	ax
	shr	ax, 0xe
	inc	ax
	mov	word [bp - 4], ax
	mov	dx, word [bp + 8]
	mov	ax, word [bp + 6]
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	mov	word [bp - 2], dx
	mov	word [bp - 6], 0
.1:
	mov	bx, word [bp - 6]
	db	0x03, 0xDB			; add bx, bx
	mov	dx, word [bp - 4]
	mov	ax, word [bp - 2]
.2:
	cmp	word [bx + EmsMapCache], 0
	jl	short .3
	cmp	word [bx + EmsMapCache], ax
	jne	short .4
.3:
	dec	dx
	jle	short .6
	inc	ax
	add	bx, 2
	cmp	bx, 8
	jl	short .2
.4:
	inc	word [bp - 6]
	cmp	word [bp - 6], 4
	jl	short .1
.5:
	db	0x33, 0xC0			; xor ax, ax
	db	0x33, 0xD2			; xor dx, dx
	pop	si
	leave
	retf
.6:
	mov	ax, word [bp - 6]
	mov	bx, word [bp - 2]
	mov	cx, word [bp - 4]
	call	EmsMap
	jb	short .5
	mov	ax, word [bp + 6]
	and	ax, 0x3fff
	mov	bx, word [bp - 6]
	db	0x03, 0xDB			; add bx, bx
	add	ax, word [bx + EmsWindowOff]
	mov	dx, word [EmsFrame]
	pop	si
	leave
	retf

; EmsMarkStale: set the high bit of the four cached logical pages so the next map misses.
EmsMarkStale:
	mov	ax, 0x8000
	or	word [EmsMapCache], ax
	or	word [EmsMapCache+2], ax
	or	word [EmsMapCache+4], ax
	or	word [EmsMapCache+6], ax
	retf

; EmsInit: if no handle yet, check the INT 67h device name against EmmName,
; read the page frame, and allocate the smaller of the free page count and
; four times the long argument. The allocated count divided by 4 is stored
; through the far pointer at EmsOutPtr. EmsFree is registered with _onexit.
; Then calls seg030. Returns that call, or zero.
EmsInit:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	push	si
	push	di
	cmp	word [EmsHandle], -1
	jne	short .3
	mov	ax, 0x3567
	int	0x21
	mov	di, 0xa
	mov	si, EmmName
	mov	cx, 4
	repe cmpsw
	jne	short .4
	mov	ah, 0x41
	int	0x67
	db	0x0A, 0xE4			; or ah, ah
	jne	short .4
	mov	word [EmsFrame], bx
	mov	ax, word [bp + 6]
	mov	dx, word [bp + 8]
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	db	0x0B, 0xC0			; or ax, ax
	je	short .1
	inc	dx
.1:
	mov	word [bp - 2], dx
	mov	ah, 0x42
	int	0x67
	db	0x0A, 0xE4			; or ah, ah
	jne	short .4
	cmp	bx, word [bp - 2]
	jb	short .2
	mov	bx, word [bp - 2]
.2:
	mov	ah, 0x43
	int	0x67
	db	0x0A, 0xE4			; or ah, ah
	jne	short .4
	mov	word [EmsHandle], dx
	db	0x33, 0xC0			; xor ax, ax
	db	0x8B, 0xD3			; mov dx, bx
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	les	bx, [EmsOutPtr]
	mov	word [es:bx], ax
	mov	word [es:bx+2], dx
	push	strict word 0x3A3		; seg001
	push	strict word EmsFree
	call	0x3A3:OnexitThunk		; seg001
	add	sp, 4
.3:
	call	0x148B:0x4		; seg030
	pop	di
	pop	si
	leave
	retf
.4:
	db	0x33, 0xC0			; xor ax, ax
	db	0x33, 0xD2			; xor dx, dx
	pop	di
	pop	si
	leave
	retf

; EmsFree: deallocate the EMS handle (INT 67h AH=45h) and store -1. _onexit calls this.
EmsFree:
	cmp	word [EmsHandle], -1
	je	short .1
	mov	ah, 0x45
	mov	dx, word [EmsHandle]
	int	0x67
	mov	word [EmsHandle], 0xffff
.1:
	retf

; EmsMapFrame: map four physical pages at the 16K page of the long argument and
; return DX:AX (page frame, offset within the page).
EmsMapFrame:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	mov	bx, word [bp + 8]
	mov	ax, word [bp + 6]
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xDB			; adc bx, bx
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xDB			; adc bx, bx
	db	0x33, 0xC0			; xor ax, ax
	mov	cx, 4
	call	EmsMap
	mov	ax, word [bp + 6]
	and	ax, 0x3fff
	mov	dx, word [EmsFrame]
	pop	si
	leave
	retf

; EmsSaveMap: copy the four cached logical-page words to the near buffer in [bp+6].
EmsSaveMap:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, EmsMapCache
	mov	di, word [bp + 6]
	mov	ax, ds
	mov	es, ax
	mov	cx, 4
	rep movsw
	pop	si
	pop	di
	leave
	retf

; EmsRestoreMap: map the four logical pages in the near buffer back onto physical pages 0-3.
EmsRestoreMap:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	di, word [bp + 6]
	mov	bx, word [di]
	mov	al, 0
	mov	cx, 1
	call	EmsMap
	mov	bx, word [di + 2]
	mov	al, 1
	mov	cx, 1
	call	EmsMap
	mov	bx, word [di + 4]
	mov	al, 2
	mov	cx, 1
	call	EmsMap
	mov	bx, word [di + 6]
	mov	al, 3
	mov	cx, 1
	call	EmsMap
	pop	di
	pop	si
	leave
	retf

; ReadEndPtr: return the far pointer at EndPtr in DX:AX.
ReadEndPtr:
	les	ax, [EndPtr]
	mov	dx, es
	retf

; SetEndMark: store EndPtr plus the long argument at EndMark.
SetEndMark:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	les	ax, [EndPtr]
	mov	dx, es
	add	ax, word [bp + 6]
	adc	dx, word [bp + 8]
	mov	word [EndMark], ax
	mov	word [EndMark+2], dx
	leave
	retf

; WaitEnd: spin until EndPtr is at or past EndMark.
WaitEnd:
	les	ax, [EndPtr]
	mov	dx, es
	cmp	dx, word [EndMark+2]
	jb	short WaitEnd
	cmp	ax, word [EndMark]
	jb	short WaitEnd
	retf

; EndReached: AX is 1 when EndPtr is at or past EndMark, else 0.
EndReached:
	push	cs
	call	ReadEndPtr
	db	0x33, 0xC9			; xor cx, cx
	cmp	dx, word [EndMark+2]
	jb	short .1
	cmp	ax, word [EndMark]
	jb	short .1
	inc	cx
.1:
	db	0x8B, 0xC1			; mov ax, cx
	retf

; WaitAdd: add the long argument to EndPtr, then spin until EndPtr reaches that sum.
WaitAdd:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	cs
	call	ReadEndPtr
	add	ax, word [bp + 6]
	adc	dx, word [bp + 8]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
.1:
	push	cs
	call	ReadEndPtr
	cmp	dx, word [bp - 2]
	jb	short .1
	cmp	ax, word [bp - 4]
	jb	short .1
	leave
	retf

; CopyFar: copy the long byte count at [bp+0Eh] from the far pointer at [bp+6]
; to the far pointer at [bp+0Ah]. Offsets are kept under 16, then the copy moves
; 32K at a time. Word moves, or dword moves when the word at 0x763C is not zero.
CopyFar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	lds	si, [bp + 6]
	les	di, [bp + 0xa]
	call	0x2953			; still incbin
	call	0x2964			; still incbin
	mov	cx, word [bp + 0xe]
	mov	dx, word [bp + 0x10]
	cld
	jmp	short .2
.1:
	sub	cx, 1
	sbb	dx, 0
	jb	short .5
	movsb
.2:
	test	di, 0xf
	jne	short .1
	cmp	word [ss:0x763c], 0
	jne	short .6
	db	0x8B, 0xD9			; mov bx, cx
	db	0x03, 0xC9			; add cx, cx
	db	0x13, 0xD2			; adc dx, dx
	jmp	short .4
.3:
	mov	cx, 0x4000
	rep movsw
	sub	si, 0x8000
	mov	ax, ds
	add	ax, 0x800
	mov	ds, ax
	sub	di, 0x8000
	mov	ax, es
	add	ax, 0x800
	mov	es, ax
.4:
	dec	dx
	jns	short .3
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 0x7fff
	shr	cx, 1
	rep movsw
	db	0x13, 0xC9			; adc cx, cx
	rep movsb
.5:
	pop	di
	pop	si
	pop	ds
	leave
	retf
.6:
	db	0x8B, 0xD9			; mov bx, cx
	db	0x03, 0xC9			; add cx, cx
	db	0x13, 0xD2			; adc dx, dx
	db	0x66, 0x33, 0xC9			; xor ecx, ecx
	and	edi, 0xffff
	jmp	short .8
.7:
	mov	cx, 0x2000
	rep movsd
	sub	si, 0x8000
	mov	ax, ds
	add	ax, 0x800
	mov	ds, ax
	sub	di, 0x8000
	mov	ax, es
	add	ax, 0x800
	mov	es, ax
.8:
	dec	dx
	jns	short .7
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 0x7fff
	shr	cx, 1
	shr	cx, 1
	rep movsd
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 3
	rep movsb
	pop	di
	pop	si
	pop	ds
	leave
	retf
	db	0x00

; CopyParas: copy BX paragraphs from the segment at [bp+6] to the segment at [bp+8].
CopyParas:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	cld
	mov	ds, word [bp + 6]
	mov	es, word [bp + 8]
	mov	bx, word [bp + 0xa]
.1:
	db	0x0B, 0xDB			; or bx, bx
	je	short .3
	mov	cx, 0x8000
	db	0x8B, 0xC3			; mov ax, bx
	sub	bx, 0x1000
	jae	short .2
	add	bx, 0x1000
	db	0x03, 0xDB			; add bx, bx
	db	0x03, 0xDB			; add bx, bx
	db	0x03, 0xDB			; add bx, bx
	db	0x8B, 0xCB			; mov cx, bx
	db	0x33, 0xDB			; xor bx, bx
.2:
	db	0x33, 0xF6			; xor si, si
	db	0x33, 0xFF			; xor di, di
	rep movsw
	mov	ax, ds
	add	ax, 0x1000
	mov	ds, ax
	mov	ax, es
	add	ax, 0x1000
	mov	es, ax
	jmp	short .1
.3:
	pop	di
	pop	si
	pop	ds
	leave
	retf

; CopyParasDown: the same copy, starting at the top so an overlap moves down safely.
CopyParasDown:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	std
	mov	bx, word [bp + 0xa]
	mov	ax, word [bp + 6]
	db	0x03, 0xC3			; add ax, bx
	mov	ds, ax
	mov	ax, word [bp + 8]
	db	0x03, 0xC3			; add ax, bx
	mov	es, ax
.1:
	db	0x0B, 0xDB			; or bx, bx
	je	short .3
	mov	cx, 0x1000
	sub	bx, 0x1000
	jae	short .2
	add	bx, 0x1000
	db	0x8B, 0xCB			; mov cx, bx
	db	0x33, 0xDB			; xor bx, bx
.2:
	mov	ax, ds
	db	0x2B, 0xC1			; sub ax, cx
	mov	ds, ax
	mov	ax, es
	db	0x2B, 0xC1			; sub ax, cx
	mov	es, ax
	db	0x03, 0xC9			; add cx, cx
	db	0x03, 0xC9			; add cx, cx
	db	0x03, 0xC9			; add cx, cx
	db	0x8B, 0xC1			; mov ax, cx
	db	0x03, 0xC0			; add ax, ax
	dec	ax
	dec	ax
	db	0x8B, 0xF0			; mov si, ax
	db	0x8B, 0xF8			; mov di, ax
	rep movsw
	jmp	short .1
.3:
	cld
	pop	di
	pop	si
	pop	ds
	leave
	retf
	db	0x00

; CritHandler: INT 24h. Far-calls the routine whose address HookCrit stored.
CritHandler:
	push	bx
	push	dx
	push	cx
	push	si
	push	di
	push	ds
	push	es
	push	bp
	push	ax
	mov	ax, ss
	mov	ds, ax
	mov	bx, CritRoutine
	pop	ax
	call	far [bx]
	pop	bp
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	cx
	pop	dx
	pop	bx
	iret

; HookCrit: register CritRestore with _onexit, store the caller's far routine,
; save the old INT 24h vector, and point INT 24h at CritHandler.
HookCrit:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	cs
	mov	ax, CritRestore
	push	ax
	call	0x3A3:OnexitThunk		; seg001
	add	sp, 4
	mov	ax, word [bp + 6]
	mov	word [CritRoutine], ax
	mov	ax, word [bp + 8]
	mov	word [CritRoutine+2], ax
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	bx, 4*0x24
	mov	ax, word [es:bx]
	mov	word [CritOld], ax
	mov	ax, word [es:bx+2]
	mov	word [CritOld+2], ax
	mov	dx, CritHandler
	mov	ax, cs
	mov	ds, ax
	mov	al, 0x24
	mov	ah, 0x25
	int	0x21
	pop	ds
	leave
	retf

; CritRestore: point INT 24h back at the saved vector, unless that vector's
; segment word equals its offset word.
CritRestore:
	push	ds
	mov	ax, word [CritOld+2]
	sub	ax, word [CritOld]
	je	short .1
	mov	dx, word [CritOld]
	mov	ds, word [CritOld+2]
	mov	al, 0x24
	mov	ah, 0x25
	int	0x21
.1:
	pop	ds
	retf
	db	0x00


; These four set SI and one flag byte, then ArgSetup stores the arguments
; and jumps to the body that is still incbin. Nothing in the EXE far-calls them.
; PassFlag1 and PassFlag0 take the word at [bp+0Eh]. AddrFlag0 and AddrFlag1
; take its address. The flag is the byte at [bp-9].
PassFlag1:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	si, word [bp+0xe]
	mov	byte [bp-9], 1
	jmp	short ArgSetup

PassFlag0:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	si, word [bp+0xe]
	mov	byte [bp-9], 0

ArgSetup:
	mov	ax, word [bp+6]
	mov	word [0x7664], ax
	mov	ax, word [bp+0xa]
	mov	word [0x7666], ax
	mov	ax, word [bp+8]
	mov	word [bp+6], ax
	mov	ax, word [bp+0xc]
	mov	word [bp+8], ax
	mov	ax, 0x3abb
	mov	word [0x7668], ax
	mov	ax, 0xc
	mov	word [0x766c], ax
	jmp	near 0x29d2			; body still incbin

AddrFlag0:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	lea	si, [bp+0xe]
	mov	byte [bp-9], 0
	jmp	short ArgSetup

AddrFlag1:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	lea	si, [bp+0xe]
	mov	byte [bp-9], 1
	jmp	short ArgSetup

	db	0

; Tail call. The far return from _onexit goes to this caller's caller.
OnexitThunk:
	jmp	0:_onexit			; seg000

; If SavedSp is nonzero, SS becomes DGROUP and SP becomes that word. Then _exit(0).
ExitSavedSp:
	mov	ax, DGROUP
	mov	ds, ax
	cmp	word [SavedSp], 0
	je	short .1
	mov	ss, ax
	mov	sp, word [SavedSp]
.1:
	db	0x33, 0xC0			; xor ax, ax
	push	ax
	call	0:_exit			; seg000

	db	0

; File length. Opens the path at [bp+6] for reading, seeks to the end, closes,
; and returns the length in DX:AX. The word at [bp-4] is nonzero to report a
; failed open through seg022; zero returns AX 0 instead.
; FileSizeArg takes that word from the caller. FileSize forces zero.
; FileSizeMsg forces one.
FileSizeArg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	ds
	push	si
	push	di
	mov	ax, word [bp+8]
	mov	word [bp-4], ax
	jmp	short FileSizeBody

FileSize:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	ds
	push	si
	push	di
	mov	word [bp-4], 0
	jmp	short FileSizeBody

FileSizeMsg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	ds
	push	si
	push	di
	mov	word [bp-4], 1

FileSizeBody:
	mov	dx, word [bp+6]
	mov	ah, 0x3d
	db	0x32, 0xC0			; xor al, al
	int	0x21
	jae	short .1
	cmp	word [bp-4], 0
	jne	short .2
	db	0x33, 0xC0			; xor ax, ax
	pop	di
	pop	si
	pop	ds
	leave
	retf
.2:
	mov	ax, 0x6302
	mov	bx, ss
	mov	ds, bx
	push	word [bp+6]
	push	ax
	call	0xF4A:0x3E4			; seg022
.1:
	mov	word [bp-2], ax
	db	0x8B, 0xD8			; mov bx, ax
	db	0x2B, 0xC9			; sub cx, cx
	db	0x2B, 0xD2			; sub dx, dx
	mov	ax, 0x4202
	int	0x21
	push	dx
	push	ax
	mov	bx, word [bp-2]
	mov	ah, 0x3e
	int	0x21
	pop	ax
	pop	dx
	pop	di
	pop	si
	pop	ds
	leave
	retf

	incbin	"Extracted/segments/seg001.bin", 0x543, 0x33E0 - 0x543
