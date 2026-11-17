; Segment seg001. EMS maps, far copies, the INT 24h hook, file length,
; a file-head count, find-first paths, the DOS memory block, a 4-byte lookup,
; far-pointer lookup, a counted copy, multiply and divide, file writes,
; character widths, the INT 8 handler, the game port, the keyboard hook,
; the monochrome console, the CallCount waits, line clipping, file reads, a CPU probe, a polygon fill, and the video-mode save.
; The first bytes finish the seg000 routine that ends on this paragraph.

; DGROUP words this segment uses. The bytes live in the near data, not here.
GamePort	equ	0x201

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
	call	CopyParasDown.4:OnexitThunk		; seg001
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

; ReadEndPtr: return the far pointer at TickTotal in DX:AX.
ReadEndPtr:
	les	ax, [TickTotal]
	mov	dx, es
	retf

; SetEndMark: store TickTotal plus the long argument at EndMark.
SetEndMark:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	les	ax, [TickTotal]
	mov	dx, es
	add	ax, word [bp + 6]
	adc	dx, word [bp + 8]
	mov	word [EndMark], ax
	mov	word [EndMark+2], dx
	leave
	retf

; WaitEnd: spin until TickTotal is at or past EndMark.
WaitEnd:
	les	ax, [TickTotal]
	mov	dx, es
	cmp	dx, word [EndMark+2]
	jb	short WaitEnd
	cmp	ax, word [EndMark]
	jb	short WaitEnd
	retf

; EndReached: AX is 1 when TickTotal is at or past EndMark, else 0.
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

; WaitAdd: add the long argument to TickTotal, then spin until TickTotal reaches that sum.
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
; 32K at a time. Word moves, or dword moves when Cpu386 is not zero.
CopyFar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	lds	si, [bp + 6]
	les	di, [bp + 0xa]
	call	NormDsSi
	call	NormEsDi
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
	cmp	word [ss:Cpu386], 0
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
	db	0xF3, 0x66, 0xA5		; rep movsd
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
	db	0xF3, 0x66, 0xA5		; rep movsd
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
.4:
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
	call	CopyParasDown.4:OnexitThunk		; seg001
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
; and jumps to FillPoly. Nothing in the EXE far-calls them.
; PassFlag1 and PassFlag0 take the word at [bp+0Eh]. AddrFlag0 and AddrFlag1
; take its address. The flag is the byte at [bp-9]. ScanFn is set to 3ABBh.
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
	mov	word [g_7664], ax
	mov	ax, word [bp+0xa]
	mov	word [g_7666], ax
	mov	ax, word [bp+8]
	mov	word [bp+6], ax
	mov	ax, word [bp+0xc]
	mov	word [bp+8], ax
	mov	ax, 0x3abb
	mov	word [ScanFn], ax
	mov	ax, 0xc
	mov	word [LineFn], ax
	jmp	near FillPoly

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


; Open the path at [bp+6] and read four bytes. Bytes 1, 2 and 3 are a
; 24-bit count; byte 0 is unused. The result is that count divided by 16,
; plus 1 when the low nibble was set. The word at [bp-8] selects the failure
; path, same as FileSize. FileHeadArg takes it from the caller. FileHead
; forces 0 (return AX 0). FileHeadMsg forces 1 (call seg022). That call is
; not followed by a return here: the next instruction is FindPath.
FileHeadArg:
	push	bp
	db	0x8B, 0xEC
	add	sp, -8
	push	ds
	push	si
	push	di
	mov	ax, word [bp+8]
	mov	word [bp-8], ax
	jmp	short FileHeadBody
FileHead:
	push	bp
	db	0x8B, 0xEC
	add	sp, -8
	push	ds
	push	si
	push	di
	mov	word [bp-8], 0
	jmp	short FileHeadBody
FileHeadMsg:
	push	bp
	db	0x8B, 0xEC
	add	sp, -8
	push	ds
	push	si
	push	di
	mov	word [bp-8], 1
FileHeadBody:
	mov	dx, word [bp+6]
	mov	dx, word [bp+6]
	mov	ah, 0x3d
	db	0x32, 0xC0
	int	0x21
	jae	short .1
	jmp	short .3
.1:
	mov	word [bp-2], ax
	mov	bx, word [bp-2]
	lea	dx, [bp-6]
	mov	cx, 4
	mov	ah, 0x3f
	int	0x21
	db	0x3B, 0xC1			; cmp ax, cx
	jne	short .2
	mov	bx, word [bp-2]
	mov	ah, 0x3e
	int	0x21
	mov	ax, word [bp-5]
	mov	dx, word [bp-3]
	db	0x32, 0xF6
	db	0x33, 0xDB
	test	ax, 0xf
	je	short .4
	mov	bx, 1
.4:
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	db	0x03, 0xC3
	pop	di
	pop	si
	pop	ds
	leave
	retf
.2:
	mov	bx, word [bp-2]
	mov	ah, 0x3e
	int	0x21
.3:
	cmp	word [bp-8], 0
	jne	short .5
	db	0x33, 0xC0
	pop	di
	pop	si
	pop	ds
	leave
	retf
.5:
	mov	ax, 0x6302
	mov	bx, ss
	mov	ds, bx
	push	word [bp+6]
	push	ax
	call	0xF4A:0x3E4


; Find first file. Sets the DTA, searches with attribute 6, copies the
; directory part of the path (through the last ":" or "\") into PathBuf,
; then appends the 13-byte name from the DTA. Returns PathBuf, or 0.
FindPath:
	push	bp
	db	0x8B, 0xEC
	push	ds
	push	si
	push	di
	mov	dx, FindDta
	mov	ah, 0x1a
	int	0x21
	mov	dx, word [bp+6]
	mov	cl, 6
	mov	ah, 0x4e
	int	0x21
	jb	short FindNone
	mov	di, PathBuf
	mov	word [PathCut], di
	mov	si, word [bp+6]
	mov	cx, 0x57
	mov	ax, ds
	mov	es, ax
.1:
	lodsb
	stosb
	cmp	al, 0
	je	short FindCopyName
	cmp	al, 0x3a
	je	short .2
	cmp	al, 0x5c
	jne	short .3
.2:
	mov	word [PathCut], di
.3:
	loop	.1
FindCopyName:
	mov	ax, ds
	mov	es, ax
	mov	si, FindDta+0x1e
	mov	di, word [PathCut]
	mov	cx, 0xd
	cld
	rep	movsb
	mov	ax, PathBuf
FindExit:
	pop	di
	pop	si
	pop	ds
	leave
	retf
FindNone:
	db	0x33, 0xC0
	jmp	short FindExit


; Find next file and append that DTA name at the same cut. Returns PathBuf, or 0.
FindNextPath:
	push	bp
	db	0x8B, 0xEC
	push	ds
	push	si
	push	di
	mov	dx, FindDta
	mov	ah, 0x1a
	int	0x21
	mov	ah, 0x4f
	int	0x21
	jb	short FindNone
	jmp	short FindCopyName
	db	0


; INT 21h AH=48h with BX=FFFFh. That fails and leaves the largest free
; block in BX. Returns that size in bytes (paragraphs shifted up by 4).
LargestFree:
	push	si
	push	di
	mov	bx, 0xffff
	mov	ah, 0x48
	int	0x21
	db	0x8B, 0xC3
	db	0x33, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	pop	di
	pop	si
	retf


; DX:AX is a byte size, not a stack argument. Rounds it up to paragraphs
; and allocates that. If the alloc fails, the second AH=48h uses the largest
; block DOS reported in BX. Stores CS, DS, SP, the block segment and the
; paragraph past the block. Returns the allocated size in bytes.
AllocBytes:
	push	si
	push	di
	mov	word [SavedCs], cs
	mov	word [SavedDs], ds
	mov	word [SavedSp], sp
	add	ax, 0xf
	adc	dx, 0
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	shr	dx, 1
	rcr	ax, 1
	db	0x8B, 0xD8
	mov	ah, 0x48
	int	0x21
	jae	short .1
	mov	ah, 0x48
	int	0x21
.1:
	mov	word [BlockSeg], ax
	db	0x03, 0xC3
	mov	word [BlockEnd], ax
	db	0x8B, 0xC3
	db	0x33, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	db	0x03, 0xC0
	db	0x13, 0xD2
	pop	di
	pop	si
	retf

	db	0

; Call Atan2 with the two words, take the absolute value, and fold it:
; at or above 100h it becomes 200h minus the value. Above 80h the result
; comes from SinLookup and the first word; otherwise from CosLookup
; and the second word. The dividend is the absolute word shifted left 14,
; then divided by that result.
FoldScale:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	word [bp+8]
	push	word [bp+6]
	call	CopyParasDown.4:Atan2			; seg001
	add	sp, 4
	db	0x0B, 0xC0			; or ax, ax
	jge	short .1
	neg	ax
.1:
	cmp	ax, 0x100
	jl	short .2
	sub	ax, 0x200
	neg	ax
.2:
	cmp	ax, 0x80
	jg	short .4
	push	ax
	call	CopyParasDown.4:CosLookup		; seg001
	add	sp, 2
	db	0x8B, 0xD8			; mov bx, ax
	mov	dx, word [bp+8]
	db	0x0B, 0xD2			; or dx, dx
	jge	short .3
	neg	dx
.3:
	db	0x33, 0xC0			; xor ax, ax
	sar	dx, 1
	rcr	ax, 1
	sar	dx, 1
	rcr	ax, 1
	div	bx
	leave
	retf
.4:
	push	ax
	call	CopyParasDown.4:SinLookup		; seg001
	add	sp, 2
	db	0x8B, 0xD8			; mov bx, ax
	mov	dx, word [bp+6]
	db	0x0B, 0xD2			; or dx, dx
	jge	short .5
	neg	dx
.5:
	db	0x33, 0xC0			; xor ax, ax
	sar	dx, 1
	rcr	ax, 1
	sar	dx, 1
	rcr	ax, 1
	div	bx
	leave
	retf

RetZero:
	db	0x33, 0xC0			; xor ax, ax
	retf

	db	0

; Near. Mark the EMS map stale, map the long at [bp+4], and return it in ES:BX.
MapEsBx:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	call	CopyParasDown.4:EmsMarkStale		; seg001
	mov	ax, word [bp+6]
	push	ax
	mov	ax, word [bp+4]
	push	ax
	call	CopyParasDown.4:EmsMapFrame		; seg001
	add	sp, 4
	mov	es, dx
	db	0x8B, 0xD8			; mov bx, ax
	leave
	ret

; Near. Walk at most four bytes at SI. After a 0, fill the rest of the four with spaces.
PadSpace4:
	cld
	mov	cx, 4
.1:
	cmp	byte [si], 0
	je	short .2
	inc	si
	loop	.1
	ret
.2:
	mov	byte [si], 0x20
	inc	si
	loop	.2
	ret

; Look up a 4-byte key at [bp+0Ah] in the block addressed by the long at [bp+6].
; The word at [bp-2] is the failure flag: LookupArg takes it from the caller,
; Lookup forces 0, LookupMsg forces 1. A hit returns a long. A miss returns 0,
; or calls seg022 when the flag is 1.
LookupArg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	push	si
	push	di
	mov	ax, word [bp+0xc]
	mov	word [bp-2], ax
	jmp	short LookupBody
Lookup:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	push	si
	push	di
	mov	word [bp-2], 0
	jmp	short LookupBody
LookupMsg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	push	si
	push	di
	mov	word [bp-2], 1
LookupBody:
	mov	ax, word [bp+6]
	mov	dx, word [bp+8]
	db	0x0B, 0xC2			; or ax, dx
	je	short .miss
	mov	ax, 8
	push	ax
	push	word [bp+8]
	push	word [bp+6]
	call	MapEsBx
	add	sp, 6
	mov	ax, word [es:bx+4]
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	add	ax, 8
	push	ax
	push	word [bp+8]
	push	word [bp+6]
	call	MapEsBx
	add	sp, 6
	db	0x8B, 0xFB			; mov di, bx
	mov	si, word [bp+0xa]
	call	PadSpace4
	mov	dx, word [es:di+4]
	db	0x8B, 0xC2			; mov ax, dx
	db	0x0B, 0xC0			; or ax, ax
	je	short .none
	add	di, 6
	db	0x8B, 0xDF			; mov bx, di
.rec:
	db	0x8B, 0xFB			; mov di, bx
	mov	si, word [bp+0xa]
	mov	cx, 4
.cmp:
	cmpsb
	jne	short .ne
	loop	.cmp
	jmp	short .hit
.ne:
	cmp	byte [es:di-1], 0
	jne	short .next
	cmp	byte [si-1], 0x20
	je	short .hit
.next:
	add	bx, 4
	dec	ax
	jge	short .rec
.none:
	cmp	word [bp-2], 1
	jne	short .miss
	mov	dx, 0x6430
	push	word [bp+0xa]
	push	dx
	call	0xF4A:0x3E4			; seg022
.miss:
	db	0x33, 0xC0			; xor ax, ax
	db	0x8B, 0xD0			; mov dx, ax
	pop	di
	pop	si
	leave
	retf
.hit:
	db	0x8B, 0xC2			; mov ax, dx
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xD8			; add bx, ax
	db	0x03, 0xC0			; add ax, ax
	add	ax, 6
	add	ax, word [bp+6]
	mov	dx, word [bp+8]
	adc	dx, 0
	add	ax, word [es:bx]
	adc	dx, word [es:bx+2]
	pop	di
	pop	si
	leave
	retf

; Look up the long at the near pointer [bp+8] in the far table at [bp+4].
; Records start at offset 6 and are four bytes. A miss with BX nonzero calls
; seg022. A hit returns the far pointer stored after the keys, added to DS.
; FindFar passes no message. FindFarAlt uses 0x6485. FindFarMsg uses 0x645c.
FindFar:
	db	0x33, 0xDB			; xor bx, bx
	jmp	short FindFarBody
FindFarAlt:
	mov	bx, 0x6485
	jmp	short FindFarBody
FindFarMsg:
	mov	bx, 0x645c
FindFarBody:
	db	0x8B, 0xC4			; mov ax, sp
	push	bp
	push	si
	push	ds
	db	0x8B, 0xE8			; mov bp, ax
	mov	si, word [bp+8]
	mov	ax, word [si]
	mov	dx, word [si+2]
	lds	si, [bp+4]
	mov	cx, word [si+4]
	add	si, 6
	db	0x0B, 0xC9			; or cx, cx
	jne	short .scan
.miss:
	db	0x0B, 0xDB			; or bx, bx
	je	short .zero
	mov	ax, ss
	mov	ds, ax
	push	word [bp+8]
	push	bx
	call	0xF4A:0x3E4			; seg022
.zero:
	db	0x33, 0xD2			; xor dx, dx
	db	0x33, 0xC0			; xor ax, ax
	jmp	short .leave
.jcx:
	jcxz	.miss
.next:
	add	si, 4
.scan:
	cmp	dx, word [si+2]
	loopne	.next
	jne	short .miss
	cmp	ax, word [si]
	jne	short .jcx
	mov	bx, word [bp+4]
	mov	ax, word [bx+4]
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xF0			; add si, ax
	db	0x03, 0xC0			; add ax, ax
	add	ax, 6
	db	0x03, 0xC3			; add ax, bx
	mov	dx, word [si]
	and	dx, 0xf
	db	0x03, 0xC2			; add ax, dx
	mov	dx, word [si]
	mov	cx, word [si+2]
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	mov	cx, ds
	db	0x03, 0xD1			; add dx, cx
.leave:
	pop	ds
	pop	si
	pop	bp
	retf

; Walk keys at [bp+8] until a 0 byte. Each call of FindFarMsg stores DX:AX at DI.
FindFarList:
	db	0x8B, 0xC4			; mov ax, sp
	push	si
	push	di
	push	bp
	db	0x8B, 0xE8			; mov bp, ax
	mov	si, word [bp+8]
	mov	di, word [bp+0xa]
	push	si
	push	word [bp+6]
	push	word [bp+4]
	jmp	short .2
.1:
	mov	word [bp-8], si
	call	CopyParasDown.4:FindFarMsg		; seg001
	mov	word [di], ax
	mov	word [di+2], dx
	add	di, 4
	add	si, 4
.2:
	cmp	byte [si], 0
	jne	short .1
	add	sp, 6
	pop	bp
	pop	di
	pop	si
	retf

; The same walk, calling FindFar so a miss stays quiet.
FindFarQuiet:
	db	0x8B, 0xC4			; mov ax, sp
	push	si
	push	di
	push	bp
	db	0x8B, 0xE8			; mov bp, ax
	mov	si, word [bp+8]
	mov	di, word [bp+0xa]
	push	si
	push	word [bp+6]
	push	word [bp+4]
	jmp	short .2
.1:
	mov	word [bp-8], si
	call	CopyParasDown.4:FindFar			; seg001
	mov	word [di], ax
	mov	word [di+2], dx
	add	di, 4
	add	si, 4
.2:
	cmp	byte [si], 0
	jne	short .1
	add	sp, 6
	pop	bp
	pop	di
	pop	si
	retf

; Far pointer on the stack to a 20-bit address in DX:AX.
FarToLinear:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+6]
	rol	ax, 4
	db	0x8B, 0xD0			; mov dx, ax
	and	ax, 0xfff0
	and	dx, 0xf
	add	ax, word [bx+4]
	adc	dx, 0
	retf

; 20-bit address on the stack back to a far pointer with offset under 16.
LinearToFar:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+4]
	db	0x8B, 0xD0			; mov dx, ax
	and	ax, 0xf
	and	dx, 0xfff0
	or	dx, word [bx+6]
	ror	dx, 4
	retf

; Same conversion with the low word in AX and the high word in DX.
LinearToFarRegs:
	db	0x8B, 0xD8			; mov bx, ax
	and	ax, 0xf
	and	bx, 0xfff0
	db	0x0B, 0xD3			; or dx, bx
	ror	dx, 4
	retf

	db	0

; Copy the word count at [bp+0Eh] from the far pointer at [bp+0Ah]
; to the far pointer at [bp+6]. The high half of the count is zero.
CopyBytes:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	db	0x33, 0xC0			; xor ax, ax
	push	ax
	push	word [bp+0xe]
	push	word [bp+8]
	push	word [bp+6]
	push	word [bp+0xc]
	push	word [bp+0xa]
	call	CopyParasDown.4:CopyFar			; seg001
	add	sp, 0xc
	leave
	retf

	db	0

; Pops the far return address and two words. Calls _sprintf with FmtBuf,
; then calls seg028 with those two words and FmtBuf, then far-returns
; through the saved address. No far call in the EXE lands on this entry.
FormatCall:
	pop	ax
	mov	word [FmtSave], ax
	pop	ax
	mov	word [FmtSave+2], ax
	pop	ax
	mov	word [FmtSave+4], ax
	pop	ax
	mov	word [FmtSave+6], ax
	mov	ax, FmtBuf
	push	ax
	call	0:_sprintf			; seg000
	add	sp, 2
	push	word [FmtSave+6]
	push	word [FmtSave+4]
	mov	ax, FmtBuf
	push	ax
	call	0xFEF:0xE85			; seg028
	add	sp, 2
	push	word [FmtSave+2]
	push	word [FmtSave]
	retf

	db	0

; Signed product of the two stack words, in DX:AX.
ImulWords:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+4]
	mov	dx, word [bx+6]
ImulRegs:
	imul	dx
	retf

; Unsigned product of the two stack words, in DX:AX.
MulWords:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+4]
	mov	dx, word [bx+6]
MulRegs:
	mul	dx
	retf

; Signed DX:AX divided by the third stack word.
IdivWords:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+4]
	mov	dx, word [bx+6]
	mov	bx, word [bx+8]
	idiv	bx
	retf

; Unsigned DX:AX divided by the third stack word.
DivWords:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx+4]
	mov	dx, word [bx+6]
	mov	bx, word [bx+8]
	div	bx
	retf

; Signed DX:AX divided by BX. Quotient comes back in DX:AX.
Idiv32:
	shl	edx, 0x10
	db	0x8B, 0xD0			; mov dx, ax
	db	0x66, 0x8B, 0xC2		; mov eax, edx
	movzx	ecx, bx
	db	0x66, 0x33, 0xD2		; xor edx, edx
	idiv	ecx
	db	0x66, 0x8B, 0xD0		; mov edx, eax
	shr	edx, 0x10
	retf

; Stack dword divided by the stack word. The high half is cleared first.
; Quotient comes back in DX:AX.
IdivDword:
	db	0x8B, 0xDC			; mov bx, sp
	db	0x66, 0x33, 0xD2		; xor edx, edx
	mov	eax, dword [bx+4]
	movzx	ebx, word [bx+8]
	idiv	ebx
	db	0x66, 0x8B, 0xD0		; mov edx, eax
	shr	edx, 0x10
	retf

; Create the path at [bp+6] and write the far buffer at [bp+8]. The long
; at [bp+0Ch] is the byte count, moved 16K at a time. A short write or a DOS
; error deletes the file. This entry then calls seg022 and returns 0.
WriteFile:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	push	si
	push	di
	mov	word [bp - 4], 0
	jmp	short WriteFileBody


; The same write. Returns the DOS error, or 1 when a write was short.
WriteFileCode:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	push	si
	push	di
	mov	word [bp - 4], 1

WriteFileBody:
	mov	dx, word [bp + 6]
	db	0x33, 0xC9			; xor cx, cx
	mov	ah, 0x3c
	int	0x21
	jb	short .A9D
	mov	word [bp - 2], ax
.A54:
	cmp	word [bp + 0xc], 0
	jne	short .A60
	cmp	word [bp + 0xe], 0
	je	short .ACB
.A60:
	mov	cx, 0x4000
	mov	ax, word [bp + 0xc]
	sub	word [bp + 0xc], cx
	sbb	word [bp + 0xe], 0
	jae	short .A80
	mov	cx, word [bp + 0xc]
	mov	word [bp + 0xc], 0
	mov	word [bp + 0xe], 0
	add	cx, 0x4000
.A80:
	mov	ds, word [bp + 0xa]
	mov	dx, word [bp + 8]
	mov	bx, word [bp - 2]
	mov	ah, 0x40
	int	0x21
	jb	short .A9D
	db	0x3B, 0xC1			; cmp ax, cx
	jne	short .A9A
	add	word [bp + 0xa], 0x400
	jmp	short .A54
.A9A:
	mov	ax, 1
.A9D:
	mov	word [bp - 6], ax
	mov	bx, word [bp - 2]
	mov	ah, 0x3e
	int	0x21
	mov	ax, ss
	mov	ds, ax
	mov	dx, word [bp + 6]
	mov	ah, 0x41
	int	0x21
	mov	ax, word [bp - 6]
	cmp	word [bp - 4], 0
	jne	short .AD4
	mov	ax, ss
	mov	ds, ax
	mov	ax, 0x6d3e
	push	word [bp + 6]
	push	ax
	call	0xF4A:0x3E4			; seg022
.ACB:
	mov	bx, word [bp - 2]
	mov	ah, 0x3e
	int	0x21
	db	0x33, 0xC0			; xor ax, ax
.AD4:
	pop	di
	pop	si
	pop	ds
	leave
	retf
	db	0x00


; Add (offset+15)/16 to the segment. AX is 0.
RoundSeg:
	db	0x8B, 0xDC			; mov bx, sp
	mov	dx, word [bx + 4]
	add	dx, 0xf
	shr	dx, 4
	add	dx, word [bx + 6]
	db	0x33, 0xC0			; xor ax, ax
	retf
	db	0x00


; Return the word at offset 4 of the far structure.
TableCount:
	db	0x8B, 0xDC			; mov bx, sp
	les	bx, [bx + 4]
	mov	ax, word es:[bx + 4]
	retf


; Far pointer for the entry index, or 0 when the index is past the count.
; The pointer is normalized the same way FindFar normalizes a hit.
TableAt:
	db	0x8B, 0xDC			; mov bx, sp
	mov	dx, word [bx + 8]
	les	bx, [bx + 4]
	mov	ax, word es:[bx + 4]
	db	0x3B, 0xD0			; cmp dx, ax
	jae	short .B3F
	db	0x03, 0xD0			; add dx, ax
	db	0x03, 0xD2			; add dx, dx
	db	0x03, 0xD2			; add dx, dx
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC3			; add ax, bx
	add	ax, 6
	db	0x03, 0xDA			; add bx, dx
	mov	dx, word es:[bx + 6]
	and	dx, 0xf
	db	0x03, 0xC2			; add ax, dx
	mov	dx, word es:[bx + 6]
	mov	cx, word es:[bx + 8]
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	shr	cx, 1
	rcr	dx, 1
	mov	cx, es
	db	0x03, 0xD1			; add dx, cx
	retf
.B3F:
	db	0x33, 0xC0			; xor ax, ax
	db	0x8B, 0xD0			; mov dx, ax
	retf


; Store that entry's dword through the near pointer, or store 0.
TableStore:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 8]
	mov	cx, word [bx + 0xa]
	les	bx, [bx + 4]
	cmp	ax, word es:[bx + 4]
	jae	short .B6B
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xD8			; add bx, ax
	mov	ax, word es:[bx + 6]
	mov	dx, word es:[bx + 8]
	db	0x8B, 0xD9			; mov bx, cx
	mov	word [bx], ax
	mov	word [bx + 2], dx
	retf
.B6B:
	db	0x8B, 0xD9			; mov bx, cx
	mov	word [bx], 0
	mov	word [bx + 2], 0
	retf
	db	0x00


; DX:AX points just past the last colon, at-sign, slash, or backslash.
; PathTail reads a near string. PathTailFar reads a far string.
PathTail:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	mov	si, word [bp + 6]
	jmp	short PathTailBody

PathTailFar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	lds	si, [bp + 6]

PathTailBody:
	db	0x8B, 0xDE			; mov bx, si
	cld
.B8D:
	lodsb
	db	0x0A, 0xC0			; or al, al
	je	short .BA6
	cmp	al, 0x3a
	je	short .BA2
	cmp	al, 0x40
	je	short .BA2
	cmp	al, 0x2f
	je	short .BA2
	cmp	al, 0x5c
	jne	short .B8D
.BA2:
	db	0x8B, 0xDE			; mov bx, si
	jmp	short .B8D
.BA6:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, ds
	pop	si
	pop	ds
	leave
	retf


; Copy bytes, including the null, and stop at the null or at the count.
; CopyStrN reads a near string. CopyStrNFar reads a far string. The destination is far.
CopyStrN:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	mov	si, word [bp + 0xa]
	mov	cx, word [bp + 0xc]
	jmp	short CopyStrNBody

CopyStrNFar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	lds	si, [bp + 0xa]
	mov	cx, word [bp + 0xe]

CopyStrNBody:
	les	di, [bp + 6]
	cld
.BCC:
	lodsb
	stosb
	db	0x0A, 0xC0			; or al, al
	loopne	.BCC
	pop	di
	pop	si
	pop	ds
	leave
	retf


; Compare up to the count. AX is 0 when the bytes match through a null, else 1.
StrnDiff:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	si
	push	di
	lds	si, [bp + 0xa]
	les	di, [bp + 6]
	mov	cx, word [bp + 0xe]
	cld
	mov	ax, 1
.BEA:
	cmpsb
	jne	short .BF4
	cmp	byte [si - 1], ah
	loopne	.BEA
	db	0x33, 0xC0			; xor ax, ax
.BF4:
	pop	di
	pop	si
	pop	ds
	leave
	retf
	db	0x00

; Sum per-character values from the table in CharSeg. [bp+8] is how many
; characters to read; zero returns 0. The word at ES:10h is the value used
; when the flag byte at ES:14h is set. Otherwise the word at ES:(char*2+16h).
TextWidth:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	dx, word [bp + 8]
	db	0x0B, 0xD2			; or dx, dx
	jne	short TextWidthBody
	db	0x33, 0xC0			; xor ax, ax
	jmp	short TextWidthBody.3


; The same sum through the terminating 0.
TextWidthAll:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	db	0x33, 0xD2			; xor dx, dx

TextWidthBody:
	mov	es, word [CharSeg]
	mov	si, word [bp + 6]
	db	0x33, 0xC0			; xor ax, ax
	mov	cl, byte es:[0x14]
	mov	di, word es:[0x10]
.1:
	mov	bl, byte [si]
	db	0x0A, 0xDB			; or bl, bl
	je	short .3
	inc	si
	db	0x32, 0xFF			; xor bh, bh
	db	0x03, 0xDB			; add bx, bx
	mov	bx, word es:[bx + 0x16]
	db	0x0B, 0xDB			; or bx, bx
	je	short .1
	db	0x0A, 0xC9			; or cl, cl
	je	short .2
	mov	bl, byte es:[bx]
	db	0x32, 0xFF			; xor bh, bh
	db	0x8B, 0xFB			; mov di, bx
.2:
	db	0x03, 0xC7			; add ax, di
	dec	dx
	je	short .3
	jmp	short .1
.3:
	pop	di
	pop	si
	leave
	retf
	db	0x00


; Store the far pointer at the start of the CharSeg block.
SetCharPtr:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	mov	es, word [CharSeg]
	mov	word es:[0], ax
	mov	word es:[2], dx
	retf


; Store the far pointer at offset 8 of the CharSeg block.
SetCharPtr2:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	mov	es, word [CharSeg]
	mov	word es:[8], ax
	mov	word es:[0xa], dx
	retf


; Copy 11 words from the start of CharSeg into the near buffer, and
; store CharSeg at offset 16h of that buffer.
SaveCharTab:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ds
	push	di
	push	si
	db	0x33, 0xF6			; xor si, si
	mov	di, word [bp + 6]
	mov	ax, ds
	mov	es, ax
	mov	ds, word [CharSeg]
	cld
	mov	word es:[di + 0x16], ds
	mov	cx, 0xb
	rep movsw
	pop	si
	pop	di
	pop	ds
	leave
	retf


; The reverse. The segment word at offset 16h of the buffer becomes CharSeg.
LoadCharTab:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, word [bp + 6]
	mov	ax, word [si + 0x16]
	mov	word [CharSeg], ax
	mov	es, ax
	db	0x33, 0xFF			; xor di, di
	cld
	mov	cx, 0xb
	rep movsw
	pop	si
	pop	di
	leave
	retf


; Normalize the far pointer and store its segment as CharSeg.
UseCharSeg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	les	di, [bp + 6]
	call	NormEsDi
	mov	word [CharSeg], es
	pop	di
	leave
	retf
	db	0x00


; Write 0B6h to port 43h, mask IRQ 0 and IRQ 1, point INT 8 at seg001:0E20h
; if that is not already the vector, unmask, and write 2E9Ch to port 40h.
; Registers UnhookInt8 with _onexit. _main calls this.
HookInt8:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	dx, 0x2e9c
	mov	word [TickStep], 0x2e9b
	cli
	mov	word [TickFrac], 0
	mov	word [TickGate], 1
	mov	word [SlotTab], 0
	mov	word [g_6DB6], 0
	mov	word [cs:Int8Ds], ds
	sti
	mov	al, 0xb6
	out	0x43, al
	in	al, 0x21
	or	al, 3
	out	0x21, al
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	cli
	mov	ax, word es:[0x20]
	cmp	ax, Int8Handler
	je	short .1
	mov	word [g_6D98], ax
.1:
	mov	ax, word es:[0x22]
	mov	bx, cs
	db	0x3B, 0xC3			; cmp ax, bx
	je	short .2
	mov	word [g_6D9A], ax
	mov	word [es:0x20], Int8Handler
	mov	word es:[0x22], cs
	mov	word [g_6D9C], EmptyRet
	mov	word [g_6D9E], cs
.2:
	in	al, 0x21
	and	al, 0xfc
	out	0x21, al
	sti
	db	0x8A, 0xC2			; mov al, dl
	out	0x40, al
	db	0x8A, 0xC6			; mov al, dh
	out	0x40, al
	push	cs
	mov	ax, UnhookInt8
	push	ax
	call	CopyParasDown.4:OnexitThunk
	add	sp, 4
	leave
	retf


; If INT 8 still points at seg001:0E20h, mask IRQ 0 and IRQ 1, restore the
; saved vector, unmask, and write 0 to port 40h twice.
UnhookInt8:
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	ax, word es:[0x22]
	mov	dx, cs
	db	0x3B, 0xC2			; cmp ax, dx
	je	short .1
	retf
.1:
	mov	ax, word es:[0x20]
	cmp	ax, Int8Handler
	je	short .2
	retf
.2:
	in	al, 0x21
	or	al, 3
	out	0x21, al
	cli
	mov	ax, word [g_6D98]
	mov	word es:[0x20], ax
	mov	ax, word [g_6D9A]
	mov	word es:[0x22], ax
	in	al, 0x21
	and	al, 0xfc
	out	0x21, al
	sti
	db	0x32, 0xC0			; xor al, al
	out	0x40, al
	out	0x40, al


; Find a free pair in the eight pairs at 6DB4h and store the two arguments.
; Calls seg022 when every pair is in use. _main calls this.
AllocSlot:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	cx, 8
	mov	bx, 0x6db4
.1:
	cmp	word [bx + 2], 0
	je	short .2
	add	bx, 4
	loop	.1
	mov	ax, 0x6ddc
	push	ax
	call	0xF4A:0x3E4			; seg022
.2:
	mov	ax, word [bp + 6]
	mov	word [bx], ax
	mov	word [bx + 2], 0
	mov	ax, word [bp + 8]
	mov	word [bx + 2], ax
	mov	word [bx + 6], 0
	leave
	retf

; Remove the pair at SlotTab that matches the two arguments, and slide the
; later pairs down. The last pair is cleared.
FreeSlot:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	cx, 8
	mov	bx, SlotTab
	mov	ax, word [bp + 6]
	mov	dx, word [bp + 8]
.1:
	cmp	word [bx], ax
	jne	short .2
	cmp	word [bx + 2], dx
	je	short .3
.2:
	add	bx, 4
	loop	.1
	leave
	retf
.3:
	cli
	dec	cx
	je	short .5
.4:
	mov	ax, word [bx + 4]
	mov	word [bx], ax
	mov	ax, word [bx + 6]
	mov	word [bx + 2], ax
	add	bx, 4
	loop	.4
.5:
	mov	word [bx], 0
	mov	word [bx + 2], 0
	sti
	leave
	retf


; AX is how many SlotTab pairs have a nonzero second word.
CountSlots:
	db	0x33, 0xC0			; xor ax, ax
	mov	bx, SlotTab
.1:
	cmp	word [bx + 2], 0
	je	short .2
	add	bx, 4
	inc	ax
	jmp	short .1
.2:
	retf


; AX is 1 when SS equals DS, else 0.
SsIsDs:
	db	0x33, 0xC0			; xor ax, ax
	mov	bx, ss
	mov	dx, ds
	db	0x3B, 0xDA			; cmp bx, dx
	jne	short .1
	inc	ax
.1:
	retf


; A far return. HookInt8 stores this address next to the old INT 8 vector.
EmptyRet:
	retf
Int8Ds:
	dw	0


; INT 8. Loads DS from Int8Ds. Sends EOI unless SkipEoi is set. When
; TickGate drops to 0 and TickSkip is clear, switches to the stack at Int8Sp
; and far-calls every SlotTab pair whose second word is nonzero. Adds TickStep
; into TickFrac. On carry, bumps TickTotal and the BIOS tick at 0:046Ch, rolls
; that tick over at midnight, and turns the floppy motors off when the BIOS
; motor count reaches 0.
Int8Handler:
	push	ds
	push	ax
	mov	ds, word cs:[0xe1e]
	cmp	word [SkipEoi], 0
	jne	short .1
	mov	al, 0x20
	out	0x20, al
.1:
	sti
	push	bx
	dec	word [TickGate]
	jne	short .4
	cmp	byte [TickSkip], 0
	jne	short .4
	push	cx
	push	dx
	push	si
	push	es
	mov	ax, ss
	mov	word [Int8Sp], sp
	mov	word [Int8Ss], ax
	mov	ax, ds
	mov	ss, ax
	mov	sp, 0x6f04
	mov	si, SlotTab
	cld
	inc	word [CallCount]
	jne	short .3
	inc	word [0x6da2]
	jmp	short .3
.2:
	db	0xFF, 0x1C			; lcall [si]
	add	si, 4
.3:
	cmp	word [si + 2], 0
	jne	short .2
	mov	ax, word [Int8Ss]
	mov	ss, ax
	mov	sp, word [Int8Sp]
	pop	es
	pop	si
	pop	dx
	pop	cx
.4:
	inc	word [TickGate]
	mov	ax, word [TickStep]
	add	word [TickFrac], ax
	jae	short .8
	inc	word [TickTotal]
	jne	short .5
	inc	word [g_6DA6]
.5:
	db	0x33, 0xC0			; xor ax, ax
	mov	ds, ax
	mov	bx, 0x46c
	inc	word [bx]
	jne	short .6
	inc	word [bx + 2]
.6:
	cmp	word [bx + 2], 0x18
	jb	short .7
	cmp	word [bx], 0xb0
	jb	short .7
	mov	word [bx], ax
	mov	word [bx + 2], ax
	mov	byte [bx + 4], 1
.7:
	dec	byte [0x440]
	jne	short .8
	push	dx
	mov	dx, 0x3f2
	mov	al, 0xf
	out	dx, al
	pop	dx
	and	byte [0x43f], 0xf0
.8:
	pop	bx
	pop	ax
	pop	ds
	iret


; If WantText is nonzero, clears it, calls seg028, forces the BIOS equipment
; word to 80-column color, and sets video mode 3 with background 0.
ResetText:
	cmp	word [WantText], 0
	je	short .1
	mov	word [WantText], 0
	db	0x33, 0xC0			; xor ax, ax
	push	ax
	call	0xFEF:0x3A84		; seg028
	add	sp, 2
	mov	ax, 0x40
	mov	es, ax
	mov	ax, word es:[0x10]
	and	ax, 0xffcf
	or	ax, 0x10
	mov	word es:[0x10], ax
	db	0x32, 0xE4			; xor ah, ah
	mov	al, 3
	int	0x10
	mov	ah, 0xb
	mov	bx, 0
	int	0x10
.1:
	retf

	db	0x00


; If bit 0 of JoyOn is clear, return JoyBits. Otherwise read port 201h.
; Bits 4 and 5 are the buttons. Bits 0 and 1 are timed until they drop, or
; until the count reaches 0FA0h. The counts are kept against running limits,
; and JoyBits gains a bit when a count falls outside the inner range.
PollJoy:
	mov	byte [JoyBits], 0
	test	byte [JoyOn], 1
	jne	short .1
	jmp	near .26
.1:
	mov	dx, GamePort
	in	al, dx
	and	al, 0x30
	mov	byte [JoyBtn], al
	mov	bl, 3
	mov	word [JoyX], 0x50
	mov	word [JoyY], 0x50
	cli
	out	dx, al
	mov	cx, 0x14
	db	0xE2, 0xFE			; loop 0xf33
	db	0x33, 0xC9			; xor cx, cx
.2:
	in	al, dx
	db	0x22, 0xC3			; and al, bl
	db	0x32, 0xC3			; xor al, bl
	jne	short .3
	inc	cx
	cmp	cx, 0xfa0
	jl	short .2
	jmp	short .6
.3:
	test	al, 1
	jne	short .5
.4:
	test	al, 2
	je	short .2
	mov	word [JoyY], cx
	and	bl, 1
	jne	short .2
	jmp	short .6
.5:
	mov	word [JoyX], cx
	and	bl, 2
	jne	short .4
.6:
	sti
	mov	ax, word [JoyX]
	cmp	ax, word [0x6fff]
	jge	short .10
	dec	word [0x7007]
	jle	short .7
	cmp	ax, word [0x7001]
	jl	short .13
	mov	word [0x7001], ax
	jmp	short .13
.7:
	mov	bx, word [0x7001]
	mov	word [0x6fff], bx
	mov	bx, word [0x7003]
.8:
	sub	bx, word [0x6fff]
	jle	short .9
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x701b], ax
.9:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x6fff]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x700b], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x7009], ax
	mov	ax, word [JoyX]
	jmp	short .12
.10:
	cmp	ax, word [0x7003]
	jle	short .12
	dec	word [0x7007]
	jle	short .11
	cmp	ax, word [0x7005]
	jge	short .13
	mov	word [0x7005], ax
	jmp	short .13
.11:
	mov	bx, word [0x7005]
	mov	word [0x7003], bx
	jmp	short .8
.12:
	mov	word [0x7007], 0x14
	mov	word [0x7005], 0x4e20
	mov	word [0x7001], 0
.13:
	cmp	ax, word [0x7009]
	jl	short .18
	cmp	ax, word [0x700b]
	jl	short .14
	or	byte [JoyBits], 4
.14:
	mov	ax, word [JoyY]
	cmp	ax, word [0x700d]
	jae	short .19
	dec	word [0x7015]
	jle	short .15
	cmp	ax, word [0x700f]
	jl	short .22
	mov	word [0x700f], ax
	jmp	short .22
.15:
	mov	bx, word [0x700f]
	mov	word [0x700d], bx
	mov	bx, word [0x7011]
.16:
	sub	bx, word [0x700d]
	jle	short .17
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x701d], ax
.17:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x700d]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x7019], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x7017], ax
	mov	ax, word [JoyY]
	jmp	short .21
.18:
	or	byte [JoyBits], 8
	jmp	short .14
.19:
	cmp	ax, word [0x7011]
	jle	short .21
	dec	word [0x7015]
	je	short .20
	cmp	ax, word [0x7013]
	jge	short .22
	mov	word [0x7013], ax
	jmp	short .22
.20:
	mov	bx, word [0x7013]
	mov	word [0x7011], bx
	jmp	short .16
.21:
	mov	word [0x7015], 0x14
	mov	word [0x7013], 0x4e20
	mov	word [0x700f], 0
.22:
	cmp	ax, word [0x7017]
	jb	short .27
	cmp	ax, word [0x7019]
	jb	short .23
	or	byte [JoyBits], 2
.23:
	in	al, dx
	and	al, 0x30
	cmp	al, byte [JoyBtn]
	je	short .24
	mov	al, byte [0x6ffc]
	jmp	short .25
.24:
	xor	al, 0x30
	mov	byte [0x6ffc], al
.25:
	or	byte [JoyBits], al
.26:
	mov	al, byte [JoyBits]
	db	0x32, 0xE4			; xor ah, ah
	retf
.27:
	or	byte [JoyBits], 1
	jmp	short .23


; Set bit 0 of JoyOn and the initial axis limits.
InitJoy:
	mov	byte [JoyOn], 1
	mov	word [0x6fff], 0x50
	mov	word [0x7003], 0
	mov	word [0x700d], 0x50
	mov	word [0x7011], 0
	retf


; The low nibble of the argument indexes the 16 bytes at 701Fh.
JoyNibble:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	bx, word [bp + 6]
	and	bx, 0xf
	mov	al, byte [bx + g_701F]
	db	0x32, 0xE4			; xor ah, ah
	leave
	retf


; (JoyX minus the low limit) times the X scale. The high word of that
; product, minus 1Fh, is the result. A reading under the limit returns the
; scale of zero, then the same subtract.
JoyScaleX:
	mov	ax, word [JoyX]
	sub	ax, word [0x6fff]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [0x701b]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for JoyY.
JoyScaleY:
	mov	ax, word [JoyY]
	sub	ax, word [0x700d]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [0x701d]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf

; If JoyOn is 0, return 0. Otherwise time up to four axes on port 201h.
; The axis mask comes from the byte at JoyOn in the table at 7074h. Bit 0 of
; JoyOn calibrates the first pair into Stick1Bits. Bit 1 calibrates the second
; pair into Stick2Bits. AL is Stick1Bits and AH is Stick2Bits.
PollSticks:
	mov	bl, byte [JoyOn]
	db	0x0A, 0xDB			; or bl, bl
	jne	short .1
	db	0x33, 0xC0			; xor ax, ax
	retf
.1:
	mov	byte [Stick1Bits], 0
	mov	byte [Stick2Bits], 0
	mov	dx, GamePort
	in	al, dx
	mov	byte [StickRaw], al
	db	0x32, 0xFF			; xor bh, bh
	mov	bl, byte [bx + g_7074]
	mov	ax, 0x50
	mov	word [Stick1X], ax
	mov	word [Stick1Y], ax
	mov	word [Stick2X], ax
	mov	word [Stick2Y], ax
	cli
	out	dx, al
	mov	cx, 0x14
	db	0xE2, 0xFE			; loop 0x1156
	db	0x33, 0xC9			; xor cx, cx
.2:
	in	al, dx
	db	0x22, 0xC3			; and al, bl
	db	0x32, 0xC3			; xor al, bl
	jne	short .3
	inc	cx
	cmp	cx, 0xfa0
	jl	short .2
	jmp	short .10
.3:
	test	al, 1
	jne	short .7
.4:
	test	al, 2
	jne	short .8
.5:
	test	al, 4
	jne	short .9
.6:
	test	al, 8
	je	short .2
	mov	word [Stick2Y], cx
	and	bl, 7
	jne	short .2
	jmp	short .10
.7:
	mov	word [Stick1X], cx
	and	bl, 0xe
	jne	short .4
	jmp	short .10
.8:
	mov	word [Stick1Y], cx
	and	bl, 0xd
	jne	short .5
	jmp	short .10
.9:
	mov	word [Stick2X], cx
	and	bl, 0xb
	jne	short .6
.10:
	sti
	test	byte [JoyOn], 1
	jne	short .11
	jmp	near .28
.11:
	mov	bx, word [Stick1X]
	cmp	bx, word [g_7058]
	jge	short .14
	mov	word [g_7058], bx
	mov	bx, word [g_705A]
.12:
	sub	bx, word [g_7058]
	jle	short .13
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [g_7070], ax
.13:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [g_7058]
	db	0x03, 0xC3			; add ax, bx
	mov	word [g_7062], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [g_7060], ax
	mov	bx, word [Stick1X]
	jmp	short .16
.14:
	cmp	bx, word [g_705A]
	jle	short .16
	dec	word [g_705E]
	je	short .15
	cmp	bx, word [g_705C]
	jge	short .17
	mov	word [g_705C], bx
	jmp	short .17
.15:
	mov	bx, word [g_705C]
	mov	word [g_705A], bx
	jmp	short .12
.16:
	mov	word [g_705E], 8
	mov	word [g_705C], 0x4e20
.17:
	cmp	bx, word [g_7060]
	jl	short .21
	cmp	bx, word [g_7062]
	jl	short .18
	or	byte [Stick1Bits], 4
.18:
	mov	bx, word [Stick1Y]
	cmp	bx, word [g_7064]
	jae	short .22
	mov	word [g_7064], bx
	mov	bx, word [g_7066]
.19:
	sub	bx, word [g_7064]
	jle	short .20
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [g_7072], ax
.20:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [g_7064]
	db	0x03, 0xC3			; add ax, bx
	mov	word [g_706E], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [g_706C], ax
	mov	bx, word [Stick1Y]
	jmp	short .24
.21:
	or	byte [Stick1Bits], 8
	jmp	short .18
.22:
	cmp	bx, word [g_7066]
	jle	short .24
	dec	word [g_706A]
	je	short .23
	cmp	bx, word [g_7068]
	jge	short .25
	mov	word [g_7068], bx
	jmp	short .25
.23:
	mov	bx, word [g_7068]
	mov	word [g_7066], bx
	jmp	short .19
.24:
	mov	word [g_706A], 8
	mov	word [g_7068], 0x4e20
.25:
	cmp	bx, word [g_706C]
	jb	short .27
	cmp	bx, word [g_706E]
	jb	short .26
	or	byte [Stick1Bits], 2
.26:
	in	al, dx
	and	al, byte [StickRaw]
	and	al, 0x30
	xor	al, 0x30
	or	byte [Stick1Bits], al
	jmp	short .28
.27:
	or	byte [Stick1Bits], 1
	jmp	short .26
.28:
	test	byte [JoyOn], 2
	jne	short .29
	jmp	near .45
.29:
	mov	bx, word [Stick2X]
	cmp	bx, word [g_7034]
	jge	short .32
	mov	word [g_7034], bx
	mov	bx, word [g_7036]
.30:
	sub	bx, word [g_7034]
	jle	short .31
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [g_704C], ax
.31:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [g_7034]
	db	0x03, 0xC3			; add ax, bx
	mov	word [g_703E], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [g_703C], ax
	mov	bx, word [Stick2X]
	jmp	short .34
.32:
	cmp	bx, word [g_7036]
	jle	short .34
	dec	word [g_703A]
	je	short .33
	cmp	bx, word [g_7038]
	jge	short .35
	mov	word [g_7038], bx
	jmp	short .35
.33:
	mov	bx, word [g_7038]
	mov	word [g_7036], bx
	jmp	short .30
.34:
	mov	word [g_703A], 8
	mov	word [g_7038], 0x4e20
.35:
	cmp	bx, word [g_703C]
	jl	short .39
	cmp	bx, word [g_703E]
	jl	short .36
	or	byte [Stick2Bits], 4
.36:
	mov	bx, word [Stick2Y]
	cmp	bx, word [g_7040]
	jae	short .40
	mov	word [g_7040], bx
	mov	bx, word [g_7042]
.37:
	sub	bx, word [g_7040]
	jle	short .38
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [g_704E], ax
.38:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [g_7040]
	db	0x03, 0xC3			; add ax, bx
	mov	word [g_704A], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [g_7048], ax
	mov	bx, word [Stick2Y]
	jmp	short .42
.39:
	or	byte [Stick2Bits], 8
	jmp	short .36
.40:
	cmp	bx, word [g_7042]
	jle	short .42
	dec	word [g_7046]
	je	short .41
	cmp	bx, word [g_7044]
	jge	short .43
	mov	word [g_7044], bx
	jmp	short .43
.41:
	mov	bx, word [g_7044]
	mov	word [g_7042], bx
	jmp	short .37
.42:
	mov	word [g_7046], 8
	mov	word [g_7044], 0x4e20
.43:
	cmp	bx, word [g_7048]
	jb	short .46
	cmp	bx, word [g_704A]
	jb	short .44
	or	byte [Stick2Bits], 2
.44:
	in	al, dx
	and	al, byte [StickRaw]
	and	al, 0xc0
	xor	al, 0xc0
	shr	al, 1
	shr	al, 1
	or	byte [Stick2Bits], al
.45:
	mov	al, byte [Stick1Bits]
	mov	ah, byte [Stick2Bits]
	retf
.46:
	or	byte [Stick2Bits], 1
	jmp	short .44


; Set JoyOn bit 0 and the initial limits for the first pair. _main calls this.
InitStick1:
	or	byte [JoyOn], 1
	mov	word [g_7058], 0x50
	mov	word [g_705A], 0
	mov	word [g_7064], 0x50
	mov	word [g_7066], 0
	retf


; Set JoyOn bit 1 and the initial limits for the second pair. _main calls this.
InitStick2:
	or	byte [JoyOn], 2
	mov	word [g_7034], 0x50
	mov	word [g_7036], 0
	mov	word [g_7040], 0x50
	mov	word [g_7042], 0
	retf


; (Stick1X minus its low limit) times the X scale. High word of the product minus 1Fh.
ScaleStick1X:
	mov	ax, word [Stick1X]
	sub	ax, word [g_7058]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [g_7070]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick1Y.
ScaleStick1Y:
	mov	ax, word [Stick1Y]
	sub	ax, word [g_7064]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [g_7072]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick2X.
ScaleStick2X:
	mov	ax, word [Stick2X]
	sub	ax, word [g_7034]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [g_704C]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick2Y.
ScaleStick2Y:
	mov	ax, word [Stick2Y]
	sub	ax, word [g_7040]
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	mul	word [g_704E]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf

	db	0x00


; Save DS at KbdDs. If INT 9 is not already KbdIrq, save INT 9, INT 16h,
; and INT 23h, and point them at KbdIrq, Int16Hook, and BreakIrq. Point KeyPtr
; at KeyService, clear the key-state bytes, and register UnhookKbd.
HookKbd:
	push	di
	mov	word [cs:KbdDs], ds
	in	al, 0x21
	db	0x8A, 0xE0			; mov ah, al
	or	al, 3
	out	0x21, al
	db	0x33, 0xDB			; xor bx, bx
	mov	es, bx
	mov	bx, word es:[0x24]
	cmp	bx, KbdIrq
	je	short .1
	mov	word [g_712E], bx
	mov	bx, word es:[0x26]
	mov	word [g_7130], bx
	mov	word [es:0x24], KbdIrq
	mov	word es:[0x26], cs
	mov	bx, word es:[0x58]
	mov	word [g_7132], bx
	mov	bx, word es:[0x5a]
	mov	word [g_7134], bx
	mov	word [es:0x58], Int16Hook
	mov	word es:[0x5a], cs
	mov	bx, word es:[0x8c]
	mov	word [g_7136], bx
	mov	bx, word es:[0x8e]
	mov	word [g_7138], bx
	mov	word [es:0x8c], BreakIrq
	mov	word es:[0x8e], cs
	mov	bx, KeyService
	mov	word [KeyPtr], bx
.1:
	db	0x8A, 0xC4			; mov al, ah
	out	0x21, al
	mov	ax, ds
	mov	es, ax
	mov	di, KeyState
	mov	cx, 0x5a
	db	0x33, 0xC0			; xor ax, ax
	rep stosb
	push	cs
	mov	ax, UnhookKbd
	push	ax
	call	CopyParasDown.4:OnexitThunk
	add	sp, 4
	pop	di
	retf


; Restore those three vectors when a previous INT 9 offset was saved.
; Point KeyPtr at BiosKey and clear the BIOS shift flags.
UnhookKbd:
	in	al, 0x21
	db	0x8A, 0xE0			; mov ah, al
	or	al, 3
	out	0x21, al
	db	0x33, 0xDB			; xor bx, bx
	mov	es, bx
	mov	bx, word [g_712E]
	db	0x0B, 0xDB			; or bx, bx
	je	short .2
	mov	word es:[0x24], bx
	mov	bx, word [g_7130]
	mov	word es:[0x26], bx
	mov	bx, word [g_7132]
	mov	word es:[0x58], bx
	mov	bx, word [g_7134]
	mov	word es:[0x5a], bx
	mov	bx, word [g_7136]
.1:
	mov	word es:[0x8c], bx
	mov	bx, word [g_7138]
	mov	word es:[0x8e], bx
	mov	bx, BiosKey
	mov	word [KeyPtr], bx
	mov	al, byte es:[0x417]
	and	al, 0xf0
	mov	byte es:[0x417], al
.2:
	db	0x8A, 0xC4			; mov al, ah
	out	0x21, al
	retf
KbdDs:
	dw	0


; INT 9. Acknowledges the keyboard, reads the scan code, and sends EOI.
; A break code clears the key-state byte. A make code sets it and, unless a
; translation flag sends it elsewhere, queues the byte from the table at 713Ah.
; One flag path stores 1234h at 0:0472h and jumps to FFFF:0000h.
KbdIrq:
	sti
	push	ax
	push	bx
	push	ds
	in	al, 0x61
	db	0x8A, 0xE0			; mov ah, al
	or	al, 0x80
	out	0x61, al
	db	0x8A, 0xC4			; mov al, ah
	out	0x61, al
	db	0x33, 0xC0			; xor ax, ax
	in	al, 0x60
	db	0x8B, 0xD8			; mov bx, ax
	mov	al, 0x20
	out	0x20, al
	mov	ds, word [cs:KbdDs]
	db	0x0A, 0xDB			; or bl, bl
	jns	short .1
	mov	byte [bx + 0x702e], 0
	pop	ds
	pop	bx
	pop	ax
	iret
.1:
	mov	byte [bx + KeyState], 1
	test	byte [0x70e6], 1
	jne	short .8
	test	byte [0x70cb], 1
	jne	short .7
	test	byte [0x70d8], 1
	jne	short .6
	test	byte [0x70e4], 1
	jne	short .6
	test	byte [0x70e8], 1
	jne	short .10
	mov	al, byte [bx + 0x713a]
.2:
	db	0x0A, 0xC0			; or al, al
	js	short .5
.3:
	mov	bx, word [KeyHead]
	mov	word [bx + KeyBuf], ax
	add	bx, 2
	and	bx, word [KeyMask]
	cmp	word [KeyTail], bx
	je	short .4
	mov	word [KeyHead], bx
.4:
	pop	ds
	pop	bx
	pop	ax
	iret
.5:
	db	0x8A, 0xE0			; mov ah, al
	db	0x32, 0xC0			; xor al, al
	cmp	ah, 0x90
	jb	short .3
	and	ah, 0x7f
	jmp	short .3
.6:
	mov	al, byte [bx + 0x7195]
	jmp	short .2
.7:
	mov	al, byte [bx + 0x724b]
	cmp	bx, 1
	jne	short .2
	call	0xF4A:0x3E2
.8:
	test	byte [0x70cb], 1
	jne	short .11
.9:
	mov	al, byte [bx + 0x72a6]
	jmp	short .2
.10:
	mov	al, byte [bx + 0x71f0]
	jmp	short .2
.11:
	test	byte [0x7101], 1
	je	short .9
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	ax, 0x1234
	mov	word es:[0x472], ax
	jmp	0xFFFF:0x0


; INT 23h. Saves the registers, calls seg041, and returns from the interrupt.
BreakIrq:
	push	bp
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	call	UnhookKbd.1:0x224		; seg041
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	iret


; INT 16h. Loads DS from KbdDs, calls KeyService, and returns with retf 2.
Int16Hook:
	push	bx
	push	ds
	mov	ds, word [cs:KbdDs]
	call	KeyService
	pop	ds
	pop	bx
	retf	0x2


; AH 0 reads a queued key. AH 1 reports one without removing it.
; Any other AH returns the two flag bytes ORed together.
KeyService:
	cmp	ah, 1
	jb	short .1
	ja	short .2
	mov	bx, word [KeyTail]
	cmp	bx, word [KeyHead]
	je	short .3
	mov	ax, word [bx + KeyBuf]
	ret
.1:
	mov	bx, word [KeyTail]
	cmp	bx, word [KeyHead]
	je	short .3
	mov	ax, word [bx + KeyBuf]
	add	bx, 2
	and	bx, word [KeyMask]
	mov	word [KeyTail], bx
	db	0x0B, 0xC0			; or ax, ax
	ret
.2:
	db	0x33, 0xC0			; xor ax, ax
	mov	al, byte [0x70d8]
	or	al, byte [0x70e4]
	ret
.3:
	db	0x33, 0xC0			; xor ax, ax
	ret


; The key-state byte for the scan code argument.
KeyDown:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	bx, word [bp + 6]
	mov	al, byte [bx + KeyState]
	db	0x32, 0xE4			; xor ah, ah
	leave
	retf
	db	0x00


; INT 16h, then a near return. KeyPtr points here while the hook is removed.
BiosKey:
	int	0x16
	ret


; Ask KeyPtr whether a key is waiting, then read it.
ReadKey:
	mov	ah, 1
	call	word [KeyPtr]
	jne	short .1
	db	0x33, 0xC0			; xor ax, ax
	retf
.1:
	db	0x32, 0xE4			; xor ah, ah
	call	word [KeyPtr]
	db	0x0A, 0xC0			; or al, al
	je	short .2
	db	0x32, 0xE4			; xor ah, ah
.2:
	retf


; Far jump through KeyHook.
KeyJump:
	jmp	far [KeyHook]


; Like ReadKey, but a zero low byte stays zero instead of being read again.
ReadKeyNz:
	mov	ah, 1
	call	word [KeyPtr]
	jne	short .1
	db	0x33, 0xC0			; xor ax, ax
	retf
.1:
	db	0x0A, 0xC0			; or al, al
	je	short .2
	db	0x32, 0xE4			; xor ah, ah
.2:
	retf


; Store the far pointer argument at KeyHook.
SetKeyHook:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	ax, word [bp + 6]
	mov	word [KeyHook], ax
	mov	ax, word [bp + 8]
	mov	word [0x7304], ax
	leave
	retf


; Return that far pointer.
GetKeyHook:
	mov	ax, word [KeyHook]
	mov	dx, word [0x7304]
	retf


; Call KeyJump until it returns nonzero.
WaitKey:
	push	cs
	call	KeyJump
	cmp	ax, 0
	je	short WaitKey
	retf


; Call ReadKey until it returns zero.
FlushKeys:
	push	cs
	call	ReadKey
	db	0x0B, 0xC0			; or ax, ax
	jne	short FlushKeys
	retf


; Call KeyJump until it returns nonzero or ReadCallCount passes Deadline.
WaitKeyUntil:
	push	cs
	call	KeyJump
	cmp	ax, 0
	jne	short .2
	call	CopyParasDown.4:ReadCallCount	; seg001
	cmp	dx, word [g_7520]
	jb	short WaitKeyUntil
	ja	short .1
	cmp	ax, word [Deadline]
	jb	short WaitKeyUntil
.1:
	db	0x33, 0xC0			; xor ax, ax
.2:
	retf

; Add the long argument to ReadCallCount, then wait for a key or until
; that sum is reached. A key returns in AX. The time path returns 0.
WaitKeyAdd:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	call	CopyParasDown.4:ReadCallCount		; seg001
	add	ax, word [bp + 6]
	adc	dx, word [bp + 8]
	mov	word [bp - 4], ax
	mov	word [bp - 2], dx
.1:
	push	cs
	call	KeyJump
	cmp	ax, 0
	jne	short .3
	call	CopyParasDown.4:ReadCallCount		; seg001
	cmp	dx, word [bp - 2]
	jb	short .1
	ja	short .2
	cmp	ax, word [bp - 4]
	jb	short .1
.2:
	db	0x33, 0xC0			; xor ax, ax
.3:
	leave
	retf
	db	0x00


; Fill the monochrome text buffer at B000h with zeros.
ClearMono:
	push	di
	push	es
	mov	ax, 0xb000
	mov	es, ax
	db	0x33, 0xFF			; xor di, di
	mov	cx, 0x7d0
	db	0x33, 0xC0			; xor ax, ax
	cld
	rep stosw
	pop	es
	pop	di
	retf


; A single retf.
RetFar:
	retf


; Scroll the monochrome buffer up one row from TextRow and clear the last row.
ScrollMono:
	push	si
	push	di
	push	ds
	mov	al, byte [TextRow]
	mov	bl, 0xa0
	mul	bl
	db	0x8B, 0xF0			; mov si, ax
	db	0x8B, 0xFE			; mov di, si
	add	si, 0xa0
	mov	ax, 0x18
	sub	al, byte [TextRow]
	mov	bl, 0x50
	mul	bl
	db	0x8B, 0xC8			; mov cx, ax
	mov	ax, es
	mov	ds, ax
	cld
	rep movsw
	db	0x33, 0xC0			; xor ax, ax
	mov	cx, 0x50
	rep stosw
	pop	ds
	pop	di
	pop	si
	retf


; Write the string already at ConBuf. ConPrint formats into that buffer first.
ConFlush:
	jmp	short ConOut

ConPrint:
	pop	ax
	mov	word [g_744C], ax
	pop	ax
	mov	word [g_744E], ax
	mov	ax, ConBuf
	push	ax
	call	0:_sprintf			; seg000
	add	sp, 2
	mov	byte [ConKeep], 1
	mov	ax, word [TextMark]
	mov	word [TextPos], ax
.1:
	mov	ax, word [g_744E]
	push	ax
	mov	ax, word [g_744C]
	push	ax

ConOut:
	push	si
	mov	ax, 0xb000
	mov	es, ax
	mov	si, ConBuf
	mov	dh, byte [TextAttr]
.1:
	mov	dl, byte [si]
	inc	si
	db	0x0A, 0xD2			; or dl, dl
	je	short .3
	cmp	dl, 0x20
	jb	short .5
	mov	bx, word [TextPos]
	cmp	bx, 0xfa0
	jl	short .2
	push	cs
	call	ScrollMono
	mov	bx, 0xf00
	mov	word [TextPos], bx
.2:
	mov	word es:[bx], dx
	add	word [TextPos], 2
	jmp	short .1
.3:
	cmp	byte [ConKeep], 0
	je	short .4
	mov	ax, word [TextPos]
	mov	word [TextMark], ax
.4:
	pop	si
	retf
.5:
	cmp	dl, 0xa
	jne	short .6
	mov	ax, word [TextPos]
	mov	bx, 0xa0
	div	bl
	db	0x32, 0xE4			; xor ah, ah
	inc	al
	mul	bl
	mov	word [TextPos], ax
	cmp	word [TextPos], 0xfa0
	jl	short .1
	push	cs
	call	ScrollMono
	mov	word [TextPos], 0xf00
	jmp	short .1
.6:
	cmp	dl, 8
	jne	short .7
	cmp	word [TextPos], 0
	je	short .1
	sub	word [TextPos], 2
	jmp	short .1
.7:
	cmp	dl, 0xc
	jne	short .8
	push	cs
	call	ClearMono
	mov	al, byte [TextRow]
	mov	bl, 0xa0
	mul	bl
	mov	word [TextPos], ax
	jmp	near .1
.8:
	cmp	dl, 0xb
	jne	short .9
	mov	word [TextPos], 0
	jmp	near .1
.9:
	cmp	dl, 9
	jne	short .10
	add	word [TextPos], 0x10
	and	word [TextPos], 0xfff0
.10:
	jmp	near .1


; Set the cursor from a row and column, format into ConBuf, and write it.
ConPrintAt:
	pop	ax
	mov	word [g_744C], ax
	pop	ax
	mov	word [g_744E], ax
	pop	bx
	pop	ax
	mov	dl, 0xa0
	mul	dl
	db	0x03, 0xDB			; add bx, bx
	db	0x03, 0xC3			; add ax, bx
	mov	word [TextPos], ax
	mov	ax, ConBuf
	push	ax
	call	0:_sprintf			; seg000
	add	sp, 2
	sub	sp, 4
	mov	byte [ConKeep], 0
	jmp	near ConPrint.1


; Clamp the argument into 0..24 and store it as TextRow.
SetTextRow:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	ax, word [bp + 6]
	cmp	ax, 0
	jge	short .1
	db	0x33, 0xC0			; xor ax, ax
.1:
	cmp	ax, 0x18
	jle	short .2
	mov	ax, 0x18
.2:
	mov	byte [TextRow], al
	leave
	retf


; Store the low byte as the attribute used with each character.
SetTextAttr:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	byte [TextAttr], al
	retf


; Write the argument as two hex digits at the remembered cursor.
WriteHex:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	mov	byte [ConKeep], 1
	mov	dx, word [bp + 6]
	mov	ax, word [TextMark]
	mov	word [TextPos], ax
	jmp	short WriteHexAt.1


; Write two hex digits at the row and column arguments.
WriteHexAt:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	mov	dx, word [bp + 6]
	mov	ax, word [bp + 8]
	mov	bx, 0xa0
	mul	bl
	db	0x03, 0xC2			; add ax, dx
	db	0x03, 0xC2			; add ax, dx
	mov	word [TextPos], ax
	mov	byte [ConKeep], 0
	mov	dx, word [bp + 0xa]
.1:
	db	0x8B, 0xDA			; mov bx, dx
	and	bx, 0xf
	mov	al, byte [bx + 0x74c8]
	mov	byte [0x7451], al
	db	0x8B, 0xDA			; mov bx, dx
	shr	bx, 1
	shr	bx, 1
	shr	bx, 1
	shr	bx, 1
	and	bx, 0xf
	mov	al, byte [bx + 0x74c8]
	mov	byte [ConBuf], al
	mov	byte [0x7452], 0
	push	cs
	call	ConFlush
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	leave
	retf


; Write the low byte at the remembered cursor.
WriteChar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	mov	byte [ConKeep], 1
	mov	ax, word [TextMark]
	mov	word [TextPos], ax
	mov	dx, word [bp + 6]
	jmp	short WriteCharAt.1


; Write the low byte at the row and column arguments.
WriteCharAt:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	mov	dx, word [bp + 6]
	mov	ax, word [bp + 8]
	mov	bx, 0xa0
	mul	bl
	db	0x03, 0xC2			; add ax, dx
	db	0x03, 0xC2			; add ax, dx
	mov	word [TextPos], ax
	mov	byte [ConKeep], 0
	mov	dx, word [bp + 0xa]
.1:
	mov	byte [ConBuf], dl
	mov	byte [0x7451], 0
	push	cs
	call	ConFlush
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	leave
	retf


; Copy 15 words from 74E2h and 15 words from the block selected by 74DCh
; into the near buffer.
SaveTextState:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, 0x74e2
	mov	di, word [bp + 6]
	mov	ax, ds
	mov	es, ax
	mov	cx, 0xf
	rep movsw
	mov	bx, word [g_74DC]
	db	0x03, 0xDB			; add bx, bx
	db	0x03, 0xDB			; add bx, bx
	mov	si, word [bx + g_7570]
	mov	ds, word [bx + g_7572]
	mov	cx, 0xf
	rep movsw
	mov	ds, ax
	pop	si
	pop	di
	leave
	retf


; Copy those words back from the near buffer.
LoadTextState:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	push	si
	mov	si, word [bp + 6]
	mov	ax, ds
	mov	es, ax
	mov	di, 0x74e2
	mov	cx, 0xf
	rep movsw
	mov	bx, word [g_74DC]
	db	0x03, 0xDB			; add bx, bx
	db	0x03, 0xDB			; add bx, bx
	mov	di, word [bx + g_7570]
	mov	es, word [bx + g_7572]
	mov	cx, 0xf
	rep movsw
	pop	si
	pop	di
	leave
	retf


; Return CallCount in DX:AX. Int8Handler increments that dword.
ReadCallCount:
	les	ax, [CallCount]
	mov	dx, es
	retf


; Return CallCount minus the long argument.
CallCountDiff:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	db	0x8B, 0xD8			; mov bx, ax
	db	0x8B, 0xCA			; mov cx, dx
	les	ax, [CallCount]
	mov	dx, es
	db	0x2B, 0xC3			; sub ax, bx
	db	0x1B, 0xD1			; sbb dx, cx
	retf


; Return CallCount minus the previous sample, and store the new sample.
CallCountStep:
	mov	bx, word [LastCount]
	mov	cx, word [0x7524]
	les	ax, [CallCount]
	mov	dx, es
	mov	word [LastCount], ax
	mov	word [0x7524], dx
	db	0x2B, 0xC3			; sub ax, bx
	db	0x1B, 0xD1			; sbb dx, cx
	retf


; Zero CallCount.
ClearCallCount:
	db	0x33, 0xC0			; xor ax, ax
	mov	word [CallCount], ax
	mov	word [0x6da2], ax
	retf


; Store FBEAh just under SP and hlt until that word changes or the count expires.
HaltSpin:
	db	0x8B, 0xDC			; mov bx, sp
	sub	bx, 2
	mov	cx, 0x2710
	mov	ax, 0xfbea
	mov	word [bx], ax
.1:
	hlt
	cmp	word [bx], ax
	loope	.1
	mov	word [bx], 0
	retf


; Store CallCount plus the long argument at Deadline. WaitKeyUntil compares it.
SetDeadline:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	les	bx, [CallCount]
	mov	cx, es
	db	0x03, 0xC3			; add ax, bx
	db	0x13, 0xD1			; adc dx, cx
	mov	word [Deadline], ax
	mov	word [g_7520], dx
	retf

; Specific EOI for IRQ 0, then hlt until CallCount reaches Deadline.
; If the low word of CallCount does not change, start over.
WaitDeadline:
	mov	al, 0x60
	out	0x20, al
WaitDeadlineNoEoi:
	db	0x33, 0xC9			; xor cx, cx
	mov	bx, word [CallCount]
	jmp	short .2
.1:
	hlt
.2:
	les	ax, [CallCount]
	mov	dx, es
	sub	ax, word [Deadline]
	sbb	dx, word [g_7520]
	jns	short .3
	loop	.1
	cmp	word [CallCount], bx
	jne	short WaitDeadlineNoEoi
	jmp	short WaitDeadline
.3:
	retf


; AX is 1 when CallCount is at or past Deadline.
DeadlineReached:
	db	0x33, 0xC0			; xor ax, ax
	les	bx, [CallCount]
	mov	dx, es
	sub	bx, word [Deadline]
	sbb	dx, word [g_7520]
	adc	ax, -2
	not	ax
	retf


; Spin until CallCount reaches its current value plus the long argument.
WaitCount:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	les	bx, [CallCount]
	mov	cx, es
	db	0x03, 0xC3			; add ax, bx
	db	0x13, 0xD1			; adc dx, cx
.1:
	les	bx, [CallCount]
	mov	cx, es
	db	0x2B, 0xD8			; sub bx, ax
	db	0x1B, 0xCA			; sbb cx, dx
	js	short .1
	retf
	db	0x00

; If a mouse is present, INT 33h AX=0Fh. The two arguments are shifted
; right by MouseRatioShift and become the mickey counts.
MouseRatio:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	cmp	word [MouseOn], 0
	je	short .1
	mov	ax, 0xf
	mov	bx, word [bp + 6]
	mov	dx, word [bp + 8]
	mov	cx, word [MouseRatioShift]
	shr	bx, cl
	shr	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
.1:
	pop	di
	pop	si
	leave
	retf


; If a mouse is present, store the arguments and INT 33h AX=4.
; X is shifted by MouseXShift and Y by MouseYShift.
MouseMove:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	cmp	word [MouseOn], 0
	je	short .1
	mov	ax, 4
	mov	cx, word [MouseXShift]
	mov	bx, word [bp + 6]
	mov	word [MouseX], bx
	shl	bx, cl
	mov	cx, word [MouseYShift]
	mov	dx, word [bp + 8]
	mov	word [MouseY], dx
	shl	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
.1:
	pop	di
	pop	si
	leave
	retf


; INT 33h AX=3. Store buttons, X, and Y through the three near pointers.
; X and Y are shifted back down. _main calls this. Nothing is stored when MouseOn is 0.
MouseRead:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	db	0x33, 0xC0			; xor ax, ax
	cmp	word [MouseOn], 1
	jb	short .3
	je	short .1
	mov	ax, 3
	int	0x33
	and	ax, 1
	and	bx, 2
	db	0x0B, 0xD8			; or bx, ax
	jmp	short .2
.1:
	mov	ax, 3
	int	0x33
.2:
	db	0x8B, 0xC1			; mov ax, cx
	mov	cx, word [MouseXShift]
	shr	ax, cl
	mov	cx, word [MouseYShift]
	shr	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	mov	bx, word [bp + 6]
	mov	word [bx], cx
	mov	bx, word [bp + 8]
	mov	word [bx], ax
	mov	bx, word [bp + 0xa]
	mov	word [bx], dx
.3:
	pop	di
	pop	si
	leave
	retf


; INT 33h AX=7, or AX=10h when MouseOn is above 1. The limits are shifted up.
MouseXRange:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	ax, 7
	cmp	word [MouseOn], 1
	jb	short .2
	je	short .1
	mov	ax, 0x10
.1:
	mov	cx, word [MouseXShift]
	mov	bx, word [bp + 6]
	mov	dx, word [bp + 8]
	shl	bx, cl
	shl	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
.2:
	pop	di
	pop	si
	leave
	retf


; INT 33h AX=8, or AX=11h when MouseOn is not 1. The limits are shifted up.
MouseYRange:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	ax, 8
	cmp	word [MouseOn], 1
	je	short .1
	mov	ax, 0x11
.1:
	mov	cx, word [MouseYShift]
	mov	bx, word [bp + 6]
	mov	dx, word [bp + 8]
	shl	bx, cl
	shl	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
	pop	di
	pop	si
	leave
	retf


; Set both ranges. X limits are the first and third words, Y the second and fourth.
MouseRange:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	ax, 7
	cmp	word [MouseOn], 1
	jb	short .3
	je	short .1
	mov	ax, 0x10
.1:
	mov	cx, word [MouseXShift]
	mov	bx, word [bp + 6]
	mov	dx, word [bp + 0xa]
	shl	bx, cl
	shl	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
	mov	ax, 8
	cmp	word [MouseOn], 1
	je	short .2
	mov	ax, 0x11
.2:
	mov	cx, word [MouseYShift]
	mov	bx, word [bp + 8]
	mov	dx, word [bp + 0xc]
	shl	bx, cl
	shl	dx, cl
	db	0x8B, 0xCB			; mov cx, bx
	int	0x33
.3:
	pop	di
	pop	si
	leave
	retf


; INT 33h AX=3. Return the button word, with bits masked when MouseOn is above 1.
MouseButtons:
	push	si
	push	di
	db	0x33, 0xC0			; xor ax, ax
	cmp	word [MouseOn], 1
	jb	short .2
	ja	short .1
	mov	ax, 3
	int	0x33
	db	0x8B, 0xC3			; mov ax, bx
	pop	di
	pop	si
	retf
.1:
	mov	ax, 3
	int	0x33
	and	ax, 1
	and	bx, 2
	db	0x0B, 0xC3			; or ax, bx
.2:
	pop	di
	pop	si
	retf


; INT 33h AX=3. Store the scaled position and the buttons.
MouseSample:
	push	si
	push	di
	db	0x33, 0xC0			; xor ax, ax
	cmp	word [MouseOn], 1
	jb	short .3
	je	short .1
	mov	ax, 3
	int	0x33
	and	ax, 1
	and	bx, 2
	db	0x0B, 0xD8			; or bx, ax
	jmp	short .2
.1:
	mov	ax, 3
	int	0x33
.2:
	db	0x8B, 0xC1			; mov ax, cx
	mov	cx, word [MouseXShift]
	shr	ax, cl
	mov	cx, word [MouseYShift]
	shr	dx, cl
	mov	word [MouseX], ax
	mov	word [MouseY], dx
	db	0x8B, 0xC3			; mov ax, bx
.3:
	mov	word [MouseBtn], ax
	pop	di
	pop	si
	retf


; Reset the mouse with INT 33h AX=0. Return 0 when no driver answers.
; Width at most 320 sets MouseXShift. The box is the size minus one, the pointer
; starts at one quarter of the size, and the mickey count is 16. _main calls this.
; Registers MouseHide with _onexit.
MouseOpen:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	si
	push	di
	mov	word [MouseOn], 0
	mov	word [MouseRatioShift], 0
	db	0x33, 0xC0			; xor ax, ax
	int	0x33
	db	0x0B, 0xC0			; or ax, ax
	jne	short .1
	jmp	near .4
.1:
	inc	word [MouseOn]
	mov	word [MouseYShift], 0
	cmp	word [g_6406], 0
	je	short .2
	mov	word [MouseRatioShift], 2
	inc	word [MouseYShift]
	mov	ax, 3
	int	0x33
	db	0x0B, 0xC0			; or ax, ax
	jne	short .2
	mov	word [MouseOn], 2
.2:
	db	0x33, 0xC0			; xor ax, ax
	cmp	word [bp + 6], 0x140
	jg	short .3
	inc	ax
.3:
	mov	word [MouseXShift], ax
	mov	ax, word [bp + 8]
	dec	ax
	push	ax
	mov	ax, word [bp + 6]
	dec	ax
	push	ax
	db	0x33, 0xC0			; xor ax, ax
	push	ax
	push	ax
	push	cs
	call	MouseRange
	mov	ax, word [bp + 8]
	shr	ax, 1
	shr	ax, 1
	push	ax
	mov	ax, word [bp + 6]
	shr	ax, 1
	shr	ax, 1
	push	ax
	push	cs
	call	MouseMove
	mov	ax, 0x10
	push	ax
	push	ax
	push	cs
	call	MouseRatio
	mov	ax, cs
	mov	word [g_640C], 0x1d56
	mov	word [g_640E], ax
	mov	word [g_6410], 0x1d56
	mov	word [g_6412], ax
	mov	word [g_6414], 0x1d37
	mov	word [g_6416], ax
	mov	word [g_6418], 0x1c3d
	mov	word [g_641A], ax
	push	ax
	push	word [g_6410]
	call	CopyParasDown.4:OnexitThunk
	add	sp, 0x14
.4:
	mov	ax, word [MouseOn]
	pop	di
	pop	si
	leave
	retf


; Increment the show count. INT 33h AX=1 once it becomes positive.
MouseShow:
	push	si
	push	di
	inc	word [MouseLevel]
	cmp	word [MouseLevel], 1
	jl	short .1
	mov	ax, 1
	mov	word [MouseLevel], ax
	cmp	word [MouseOn], 0
	je	short .1
	int	0x33
.1:
	pop	di
	pop	si
	retf


; Decrement the show count. INT 33h AX=2 when it reaches 0.
MouseHide:
	push	si
	push	di
	dec	word [MouseLevel]
	cmp	word [MouseLevel], 0
	jne	short .1
	cmp	word [MouseOn], 0
	je	short .1
	mov	ax, 2
	int	0x33
.1:
	pop	di
	pop	si
	retf


; Time four bits on port 201h. The mask is the byte at 75E0h. Store the
; four counts and the button nibble. On a timeout, store the bits still set and retry.
; _main calls this.
ReadPots:
	push	bp
	push	si
	push	di
	mov	ah, byte [g_75E0]
	mov	cx, 0x2710
	mov	dx, GamePort
	db	0x33, 0xDB			; xor bx, bx
	db	0x8B, 0xEB			; mov bp, bx
	db	0x8B, 0xF3			; mov si, bx
	db	0x8B, 0xFB			; mov di, bx
	cli
	out	dx, al
	jmp	short .2
.1:
	shr	al, 1
	adc	bp, 0
	shr	al, 1
	adc	si, 0
	shr	al, 1
	adc	di, 0
	shr	al, 1
	adc	bx, 0
.2:
	in	al, dx
	test	ah, al
	loopne	.1
	sti
	jcxz	.4
.3:
	shr	al, 1
	shr	al, 1
	shr	al, 1
	shr	al, 1
	mov	byte [g_75DE], al
	mov	word [g_75D6], bp
	mov	word [g_75D8], si
	mov	word [g_75DA], di
	mov	word [g_75DC], bx
	pop	di
	pop	si
	pop	bp
	retf
.4:
	db	0x8A, 0xE0			; mov ah, al
	not	ah
	and	ah, 0xf
	mov	byte [g_75E0], ah
	jmp	short .3
	db	0x00



; Two signed words. The byte table at AtanByte is indexed by the
; ratio of the smaller absolute value to the larger. The flags in DI
; record the signs and which value was larger. The word table then
; negates the result and adds or subtracts 100h or 200h, so a full
; turn is 100h. FoldScale calls this.
Atan2:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	db	0x33, 0xFF			; xor di, di
	mov	dx, word [bp+6]
	mov	cx, word [bp+8]
	db	0x0B, 0xD2			; or dx, dx
	jge	short .dxpos
	or	di, 8
	neg	dx
.dxpos:
	db	0x0B, 0xC9			; or cx, cx
	jge	short .cxpos
	or	di, 4
	neg	cx
.cxpos:
	db	0x3B, 0xD1			; cmp dx, cx
	jl	short .ratio
	je	short .half
	db	0x87, 0xD1			; xchg cx, dx
	or	di, 2
.ratio:
	db	0x33, 0xC0			; xor ax, ax
	div	cx
	db	0x8A, 0xDC			; mov bl, ah
	db	0x32, 0xFF			; xor bh, bh
	add	al, 0x80
	adc	bx, 0
	mov	al, byte [bx+AtanByte]
	db	0x32, 0xE4			; xor ah, ah
	jmp	word [cs:di+AtanTab]
.half:
	mov	ax, 0x80
	jmp	word [cs:di+AtanTab]

AtanTab:
	dw	AtanDone
	dw	AtanNegInc
	dw	AtanNegTwo
	dw	AtanInc
	dw	AtanNeg
	dw	AtanDec
	dw	AtanDecTwo
	dw	AtanIncNeg

AtanNegInc:
	neg	ax
	add	ah, 1
AtanDone:
	pop	di
	leave
	retf
AtanInc:
	add	ah, 1
	jmp	short AtanDone
AtanNegTwo:
	neg	ax
	add	ah, 2
	jmp	short AtanDone
AtanNeg:
	neg	ax
	jmp	short AtanDone
AtanDec:
	sub	ah, 1
	jmp	short AtanDone
AtanIncNeg:
	add	ah, 1
	neg	ax
	jmp	short AtanDone
AtanDecTwo:
	sub	ah, 2
	jmp	short AtanDone

; Fill the far buffer with the byte argument. The count is the long at [bp+0Ah].
; Offsets stay under 16, then the fill moves 32K at a time. Word stores, or dword
; stores when Cpu386 is nonzero. FillFarZero uses a zero byte.

FillFar:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	mov	ax, word [bp + 0xe]
	jmp	short FillFarBody

FillFarZero:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	di
	db	0x33, 0xC0			; xor ax, ax

FillFarBody:
	db	0x8A, 0xE0			; mov ah, al
	les	di, [bp + 6]
	call	NormEsDi
	mov	cx, word [bp + 0xa]
	mov	dx, word [bp + 0xc]
	cld
	jmp	short .2
.1:
	sub	cx, 1
	sbb	dx, 0
	jb	short .5
	stosb
.2:
	test	di, 0xf
	jne	short .1
	cmp	word ss:[Cpu386], 0
	jne	short .6
	db	0x8B, 0xD9			; mov bx, cx
	db	0x03, 0xC9			; add cx, cx
	db	0x13, 0xD2			; adc dx, dx
	jmp	short .4
.3:
	mov	cx, 0x4000
	rep stosw
	sub	di, 0x8000
	mov	cx, es
	add	cx, 0x800
	mov	es, cx
.4:
	dec	dx
	jns	short .3
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 0x7fff
	shr	cx, 1
	rep stosw
	db	0x13, 0xC9			; adc cx, cx
	rep stosb
.5:
	pop	di
	leave
	retf
.6:
	db	0x8B, 0xD8			; mov bx, ax
	shl	eax, 0x10
	db	0x8B, 0xC3			; mov ax, bx
	db	0x8B, 0xD9			; mov bx, cx
	db	0x66, 0x33, 0xC9			; xor ecx, ecx
	and	edi, 0xffff
	db	0x03, 0xC9			; add cx, cx
	db	0x13, 0xD2			; adc dx, dx
	jmp	short .8
.7:
	mov	cx, 0x2000
	db	0xF3, 0x66, 0xAB		; rep stosd
	sub	di, 0x8000
	mov	cx, es
	add	cx, 0x800
	mov	es, cx
.8:
	dec	dx
	jns	short .7
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 0x7fff
	shr	cx, 2
	db	0xF3, 0x66, 0xAB		; rep stosd
	db	0x8B, 0xCB			; mov cx, bx
	and	cx, 3
	rep stosb
	pop	di
	leave
	retf
	db	0x00

; Order two points into the record at [bp+0Eh]. LineOpen skips the box test.
; LineClip rejects a line when both ends share an outcode against the box at
; 74F2h/74F4h and 74FCh/74FEh, and otherwise stores a direction byte. The
; equal-Y path is LineFlat and the overflow path is LineOverflow.
; A line with no clip bits returns 0 from LineOk.

LineOpen:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	si
	push	di
	mov	byte [bp - 3], 1
	jmp	short LineBody

LineClip:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -4
	push	si
	push	di
	mov	byte [bp - 3], 0

LineBody:
	mov	si, word [bp + 0xe]
	mov	word [si + 0x12], 0xff
	db	0x33, 0xC0			; xor ax, ax
	mov	word [si], ax
	mov	word [si + 4], ax
	mov	word [si + 0x14], ax
	mov	word [si + 0x16], ax
	mov	word [si + 0x18], ax
	mov	word [si + 0x1a], ax
	mov	ax, word [bp + 8]
	mov	bx, word [bp + 0xc]
	mov	cx, word [bp + 6]
	mov	dx, word [bp + 0xa]
	db	0x3B, 0xC3			; cmp ax, bx
	jg	short .1
	mov	word [si + 2], cx
	mov	word [si + 6], ax
	mov	word [si + 8], dx
	mov	word [si + 0xa], bx
	jmp	short .2
.1:
	mov	word [si + 2], dx
	mov	word [si + 6], bx
	mov	word [si + 8], cx
	mov	word [si + 0xa], ax
.2:
	jne	short .3
	jmp	near LineFlat
.3:
	db	0x33, 0xD2			; xor dx, dx
	cmp	byte [bp - 3], 0
	jne	short .12
	mov	ax, word [si + 6]
	mov	bx, word [g_74F2]
	mov	cx, word [g_74F4]
	db	0x3B, 0xC1			; cmp ax, cx
	jl	short .4
	mov	dl, 8
	jmp	near LineReject
.4:
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .5
	or	dh, 4
.5:
	mov	ax, word [si + 0xa]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .6
	mov	dl, 4
	jmp	near LineReject
.6:
	db	0x3B, 0xC1			; cmp ax, cx
	jl	short .7
	or	dl, 8
.7:
	mov	bx, word [g_74FC]
	mov	cx, word [g_74FE]
	mov	ax, word [si + 2]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .8
	or	dh, 2
.8:
	db	0x3B, 0xC1			; cmp ax, cx
	jl	short .9
	or	dh, 1
.9:
	mov	ax, word [si + 8]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .10
	or	dl, 2
.10:
	db	0x3B, 0xC1			; cmp ax, cx
	jl	short .11
	or	dl, 1
.11:
	test	dh, dl
	je	short .12
	db	0x22, 0xD6			; and dl, dh
	jmp	near LineReject
.12:
	db	0x0A, 0xD6			; or dl, dh
	db	0x32, 0xF6			; xor dh, dh
	mov	word [bp - 2], dx
	mov	cx, word [si + 0xa]
	sub	cx, word [si + 6]
	jno	short .14
.13:
	jmp	near LineOverflow
.14:
	mov	dx, word [si + 8]
	sub	dx, word [si + 2]
	jo	short .13
	jne	short .15
	inc	cx
	mov	word [si + 0xe], cx
	mov	byte [si + 0x12], 2
	jmp	short .26
.15:
	jl	short .22
	db	0x3B, 0xD1			; cmp dx, cx
	jb	short .20
	je	short .21
	mov	byte [si + 0x12], 8
.16:
	db	0x87, 0xCA			; xchg dx, cx
.17:
	cmp	cx, word [g_78D2]
	jge	short .18
	db	0x8B, 0xD9			; mov bx, cx
	db	0x03, 0xDB			; add bx, bx
	mov	bx, word [bx + g_78D4]
	db	0x03, 0xDA			; add bx, dx
	db	0x03, 0xDA			; add bx, dx
	mov	ax, word [bx]
	jmp	short .19
.18:
	db	0x33, 0xC0			; xor ax, ax
	div	cx
	db	0x8B, 0xD9			; mov bx, cx
	shr	bx, 1
	db	0x2B, 0xDA			; sub bx, dx
	adc	ax, 0
.19:
	mov	word [si + 0xc], ax
	inc	cx
	jo	short .13
	mov	word [si + 0xe], cx
	jmp	short .26
.20:
	mov	byte [si + 0x12], 6
	jmp	short .17
.21:
	mov	byte [si + 0x12], 4
	jmp	short .25
.22:
	neg	dx
	jo	short .13
	db	0x3B, 0xD1			; cmp dx, cx
	jb	short .23
	je	short .24
	mov	byte [si + 0x12], 7
	jmp	short .16
.23:
	mov	byte [si + 0x12], 5
	jmp	short .17
.24:
	mov	byte [si + 0x12], 3
.25:
	inc	cx
	mov	word [si + 0xe], cx
.26:
	mov	bx, word [bp - 2]
	db	0x03, 0xDB			; add bx, bx
	je	short LineOk
	jmp	word [cs:bx+LineTab]
LineTab:
	dw	LineOk
	dw	ClipRight
	dw	ClipLeft
	dw	ClipLeft
	dw	ClipTop
	dw	ClipTop
	dw	ClipTop
	dw	ClipTop
	dw	ClipBottom
	dw	ClipBottom
	dw	ClipBottom
	dw	ClipBottom
	dw	ClipTop
	dw	ClipTop
	dw	ClipTop
	dw	ClipTop

LineOk:
	db	0x33, 0xC0			; xor ax, ax
	pop	di
	pop	si
	leave
	retf

; Slide an endpoint onto one edge of the box. ClipTop uses the top,
; ClipBottom the bottom, and ClipLeft the left. The direction byte
; picks how X or Y moves with that edge. Each case then jumps to
; AfterTop, AfterBottom, or AfterLeft. ClipRet returns with AH 0.


ClipTop:
	mov	ax, word [si + 6]
	mov	cx, word [g_74F2]
	mov	word [si + 6], cx
	db	0x2B, 0xC8			; sub cx, ax
	mov	bl, byte [si + 0x12]
	db	0x03, 0xDB			; add bx, bx
	jmp	word [cs:bx+TopTab]
TopTab:
	dw	0
	dw	0
	dw	.1
	dw	.2
	dw	.3
	dw	.4
	dw	.5
	dw	.6
	dw	.8
.1:
	sub	word [si + 0xe], cx
	jmp	near AfterTop
.2:
	sub	word [si + 2], cx
	sub	word [si + 0xe], cx
	jmp	near AfterTop
.3:
	add	word [si + 2], cx
	sub	word [si + 0xe], cx
	jmp	near AfterTop
.4:
	mov	ax, word [si + 0xc]
	mul	cx
	sub	word [si], ax
	sbb	word [si + 2], dx
	sub	word [si + 0xe], cx
	jmp	near AfterTop
.5:
	mov	ax, word [si + 0xc]
	mul	cx
	add	word [si], ax
	adc	word [si + 2], dx
	sub	word [si + 0xe], cx
	jmp	near AfterTop
.6:
	mov	word [si + 6], ax
	db	0x8B, 0xD1			; mov dx, cx
	db	0x33, 0xC0			; xor ax, ax
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	sub	word [si + 2], ax
	sub	word [si + 0xe], ax
	jle	short .7
	mul	word [si + 0xc]
	add	word [si + 4], ax
	adc	word [si + 6], dx
	jmp	near AfterTop
.7:
	mov	word [si + 0xe], 1
	mov	ax, word [g_74F2]
	mov	word [si + 6], ax
	mov	ax, word [si + 8]
	mov	word [si + 2], ax
	jmp	near AfterTop
.8:
	mov	word [si + 6], ax
	db	0x8B, 0xD1			; mov dx, cx
	db	0x33, 0xC0			; xor ax, ax
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	add	word [si + 2], ax
	sub	word [si + 0xe], ax
	jle	short .7
	mul	word [si + 0xc]
	add	word [si + 4], ax
	adc	word [si + 6], dx
	jmp	near AfterTop

ClipBottom:
	mov	cx, word [si + 0xa]
	mov	dx, word [g_74F4]
	dec	dx
	mov	word [si + 0xa], dx
	db	0x2B, 0xCA			; sub cx, dx
	mov	bl, byte [si + 0x12]
	db	0x03, 0xDB			; add bx, bx
	jmp	word [cs:bx+BotTab]
BotTab:
	dw	0
	dw	0
	dw	.1
	dw	.2
	dw	.3
	dw	.4
	dw	.5
	dw	.6
	dw	.9
.1:
	sub	word [si + 0xe], cx
	jmp	near AfterBottom
.2:
	add	word [si + 8], cx
	sub	word [si + 0xe], cx
	jmp	near AfterBottom
.3:
	sub	word [si + 8], cx
	sub	word [si + 0xe], cx
	jmp	near AfterBottom
.4:
	mov	dx, word [si + 0xe]
	db	0x2B, 0xD1			; sub dx, cx
	mov	word [si + 0xe], dx
	dec	dx
	mov	ax, word [si + 0xc]
	mul	dx
	mov	bx, word [si]
	mov	cx, word [si + 2]
	db	0x2B, 0xD8			; sub bx, ax
	db	0x1B, 0xCA			; sbb cx, dx
	add	bx, 0x8000
	adc	cx, 0
	mov	word [si + 8], cx
	jmp	near AfterBottom
.5:
	mov	dx, word [si + 0xe]
	db	0x2B, 0xD1			; sub dx, cx
	mov	word [si + 0xe], dx
	dec	dx
	mov	ax, word [si + 0xc]
	mul	dx
	add	ax, word [si]
	adc	dx, word [si + 2]
	add	ax, 0x8000
	adc	dx, 0
	mov	word [si + 8], dx
	jmp	near AfterBottom
.6:
	db	0x33, 0xC0			; xor ax, ax
	sub	ax, word [si + 4]
	sbb	dx, word [si + 6]
	jl	short .8
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
.7:
	mov	dx, word [si + 2]
	db	0x2B, 0xD0			; sub dx, ax
	mov	word [si + 8], dx
	inc	ax
	mov	word [si + 0xe], ax
	jmp	near AfterBottom
.8:
	db	0x33, 0xC0			; xor ax, ax
	jmp	short .7
.9:
	db	0x33, 0xC0			; xor ax, ax
	sub	ax, word [si + 4]
	sbb	dx, word [si + 6]
	jl	short .8
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	mov	dx, word [si + 2]
	db	0x03, 0xD0			; add dx, ax
	mov	word [si + 8], dx
	inc	ax
	mov	word [si + 0xe], ax
	jmp	near AfterBottom

ClipLeft:
	mov	bl, byte [si + 0x12]
	db	0x03, 0xDB			; add bx, bx
	jmp	word [cs:bx+LeftTab]
LeftTab:
	dw	0
	dw	0
	dw	.10
	dw	.1
	dw	.2
	dw	.3
	dw	.6
	dw	.8
	dw	.9
.1:
	mov	cx, word [g_74FC]
	mov	ax, word [si + 8]
	mov	word [si + 8], cx
	db	0x2B, 0xC8			; sub cx, ax
	add	word [si + 0x16], cx
	sub	word [si + 0xe], cx
	sub	word [si + 0xa], cx
	jmp	near AfterLeft
.2:
	mov	ax, word [si + 2]
	mov	cx, word [g_74FC]
	mov	word [si + 2], cx
	db	0x2B, 0xC8			; sub cx, ax
	add	word [si + 0x14], cx
	add	word [si + 6], cx
	sub	word [si + 0xe], cx
	jmp	near AfterLeft
.3:
	mov	ax, word [si]
	mov	dx, word [si + 2]
	mov	cx, word [g_74FC]
	mov	word [si + 8], cx
	db	0x2B, 0xD1			; sub dx, cx
	jl	short .5
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	inc	ax
.4:
	mov	cx, word [si + 0xe]
	mov	word [si + 0xe], ax
	db	0x2B, 0xC8			; sub cx, ax
	add	word [si + 0x16], cx
	dec	ax
	add	ax, word [si + 6]
	mov	word [si + 0xa], ax
	jmp	near AfterLeft
.5:
	mov	ax, 1
	jmp	short .4
.6:
	mov	dx, word [g_74FC]
	db	0x33, 0xC0			; xor ax, ax
	sub	ax, word [si]
	sbb	dx, word [si + 2]
	jl	short .7
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	add	word [si + 6], ax
	add	word [si + 0x14], ax
	sub	word [si + 0xe], ax
	jle	short .10
	mul	word [si + 0xc]
	add	word [si], ax
	adc	word [si + 2], dx
	jmp	near AfterLeft
.7:
	jmp	short .10
.8:
	mov	ax, word [si + 2]
	mov	dx, word [g_74FC]
	mov	word [si + 8], dx
	db	0x2B, 0xC2			; sub ax, dx
	db	0x8B, 0xC8			; mov cx, ax
	inc	cx
	mov	word [si + 0xe], cx
	mul	word [si + 0xc]
	add	ax, word [si + 4]
	adc	dx, word [si + 6]
	add	ax, 0x8000
	adc	dx, 0
	mov	ax, word [si + 0xa]
	db	0x2B, 0xC2			; sub ax, dx
	mov	word [si + 0xa], dx
	add	word [si + 0x16], ax
	jmp	near AfterLeft
.9:
	mov	cx, word [si + 2]
	mov	ax, word [g_74FC]
	mov	word [si + 2], ax
	db	0x2B, 0xC1			; sub ax, cx
	sub	word [si + 0xe], ax
	mul	word [si + 0xc]
	mov	bx, word [si + 4]
	mov	cx, word [si + 6]
	db	0x03, 0xC3			; add ax, bx
	db	0x13, 0xD1			; adc dx, cx
	mov	word [si + 4], ax
	mov	word [si + 6], dx
	add	bx, 0x8000
	adc	cx, 0
	add	ax, 0x8000
	adc	dx, 0
	db	0x2B, 0xD1			; sub dx, cx
	add	word [si + 0x14], dx
	jmp	near AfterLeft
.10:
	mov	dx, 2
LineReject:
	mov	byte [si + 0x13], dl
	mov	word [si + 0xe], 0
	mov	al, byte [si + 0x13]
	test	al, 4
	je	short .1
	mov	bx, word [g_74F2]
	mov	word [si + 6], bx
	mov	word [si + 4], 0
	dec	bx
	mov	word [si + 0xa], bx
	jmp	short ClipRet
.1:
	test	al, 8
	je	short .2
	mov	bx, word [g_74F4]
	mov	word [si + 6], bx
	mov	word [si + 4], 0
	jmp	short ClipRet
.2:
	mov	cx, word [si + 0xa]
	cmp	cx, word [g_74F4]
	jl	short .3
	mov	cx, word [g_74F4]
	dec	cx
.3:
	mov	dx, word [si + 6]
	mov	bx, word [si + 4]
	add	bx, 0x8000
	adc	dx, 0
	cmp	dx, word [g_74F2]
	jge	short .4
	mov	dx, word [g_74F2]
.4:
	mov	word [si + 6], dx
	mov	word [si + 4], 0
	db	0x2B, 0xCA			; sub cx, dx
	dec	dx
	inc	cx
	mov	word [si + 0xa], dx
	test	al, 2
	je	short .5
	add	word [si + 0x16], cx
	jmp	short ClipRet
.5:
	add	word [si + 0x1a], cx

ClipRet:
	db	0x32, 0xE4			; xor ah, ah
	pop	di
	pop	si
	leave
	retf


; ClipRight pulls the line onto the right edge. Directions 0 and 1
; are unused. Direction 2 rejects the line. The other cases move an
; endpoint onto that edge. AfterTop runs ClipBottom when the bottom
; outcode is still set. AfterBottom rebuilds the left and right
; outcodes: both ends on one side is LineReject, and a side bit that
; remains goes back through LineTab. AfterLeft runs ClipRight when
; the right outcode is still set. LineFlat is the equal-Y path.
; LineOverflow shifts an endpoint that sits far outside the box.

ClipRight:
	mov	bl, byte [si + 0x12]
	db	0x32, 0xFF			; xor bh, bh
	db	0x03, 0xDB			; add bx, bx
	jmp	word [cs:bx+RightTab]
RightTab:
	dw	0
	dw	0
	dw	.1
	dw	.2
	dw	.3
	dw	.4
	dw	.5
	dw	.6
	dw	.7
.1:
	mov	dx, 1
	jmp	near LineReject
.2:
	mov	cx, word [si + 2]
	mov	ax, word [g_74FE]
	dec	ax
	mov	word [si + 2], ax
	db	0x2B, 0xC8			; sub cx, ax
	add	word [si + 6], cx
	sub	word [si + 0xe], cx
	add	word [si + 0x18], cx
	jmp	near LineOk
.3:
	mov	cx, word [g_74FE]
	dec	cx
	mov	ax, word [si + 8]
	mov	word [si + 8], cx
	db	0x2B, 0xC1			; sub ax, cx
	add	word [si + 0x1a], ax
	sub	word [si + 0xe], ax
	sub	word [si + 0xa], ax
	jmp	near LineOk
.4:
	mov	ax, word [si]
	mov	dx, word [si + 2]
	sub	dx, word [g_74FE]
	inc	dx
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	sub	word [si + 0xe], ax
	jle	short .1
	add	word [si + 6], ax
	add	word [si + 0x18], ax
	mul	word [si + 0xc]
	sub	word [si], ax
	sbb	word [si + 2], dx
	jmp	near LineOk
.5:
	mov	dx, word [g_74FE]
	dec	dx
	mov	word [si + 8], dx
	db	0x33, 0xC0			; xor ax, ax
	sub	ax, word [si]
	sbb	dx, word [si + 2]
	jl	short .1
	mov	cx, word [si + 0xc]
	div	cx
	shr	cx, 1
	db	0x2B, 0xCA			; sub cx, dx
	adc	ax, 0
	inc	ax
	mov	cx, word [si + 0xe]
	mov	word [si + 0xe], ax
	db	0x2B, 0xC8			; sub cx, ax
	add	word [si + 0x1a], cx
	dec	ax
	add	ax, word [si + 6]
	mov	word [si + 0xa], ax
	jmp	near LineOk
.6:
	mov	ax, word [si + 2]
	mov	cx, word [g_74FE]
	dec	cx
	db	0x2B, 0xC1			; sub ax, cx
	mov	word [si + 2], cx
	sub	word [si + 0xe], ax
	mul	word [si + 0xc]
	mov	bx, word [si + 4]
	mov	cx, word [si + 6]
	db	0x03, 0xC3			; add ax, bx
	db	0x13, 0xD1			; adc dx, cx
	mov	word [si + 4], ax
	mov	word [si + 6], dx
	add	bx, 0x8000
	adc	cx, 0
	add	ax, 0x8000
	adc	dx, 0
	db	0x2B, 0xD1			; sub dx, cx
	add	word [si + 0x18], dx
	jmp	near LineOk
.7:
	mov	ax, word [g_74FE]
	db	0x8B, 0xC8			; mov cx, ax
	dec	cx
	mov	word [si + 8], cx
	sub	ax, word [si + 2]
	mov	word [si + 0xe], ax
	dec	ax
	mul	word [si + 0xc]
	add	ax, word [si + 4]
	adc	dx, word [si + 6]
	add	ax, 0x8000
	adc	dx, 0
	mov	ax, word [si + 0xa]
	db	0x2B, 0xC2			; sub ax, dx
	mov	word [si + 0xa], dx
	add	word [si + 0x1a], ax
	jmp	near LineOk
AfterTop:
	test	word [bp - 2], 8
	je	short AfterBottom
	jmp	near ClipBottom
AfterBottom:
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, word [si + 2]
	cmp	ax, word [g_74FC]
	jge	short .1
	or	dh, 2
.1:
	mov	bx, word [si]
	add	bx, 0x8000
	adc	ax, 0
	cmp	ax, word [g_74FE]
	jl	short .2
	or	dh, 1
.2:
	mov	ax, word [si + 8]
	cmp	ax, word [g_74FC]
	jge	short .3
	or	dl, 2
.3:
	cmp	ax, word [g_74FE]
	jl	short .4
	or	dl, 1
.4:
	test	dh, dl
	je	short .5
	db	0x22, 0xD6			; and dl, dh
	jmp	near LineReject
.5:
	db	0x0A, 0xD6			; or dl, dh
	je	short AfterLeft.1
	db	0x32, 0xF6			; xor dh, dh
	mov	word [bp - 2], dx
	jmp	near LineBody.26
AfterLeft:
	test	word [bp - 2], 1
	je	short .1
	jmp	near ClipRight
.1:
	jmp	near LineOk
LineFlat:
	mov	byte [si + 0x12], 1
	db	0x3B, 0xCA			; cmp cx, dx
	jne	short .1
	mov	byte [si + 0x12], 9
.1:
	jle	short .2
	mov	byte [si + 0x12], 0
	mov	word [si + 2], dx
	mov	word [si + 8], cx
	db	0x87, 0xCA			; xchg dx, cx
.2:
	cmp	byte [bp - 3], 0
	jne	short .4
	mov	bx, word [g_74F2]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .5
	mov	al, 4
	mov	word [si + 6], bx
	mov	word [si + 0xa], bx
.3:
	mov	byte [si + 0x13], al
	mov	word [si + 0xe], 0
	db	0x32, 0xE4			; xor ah, ah
	pop	di
	pop	si
	leave
	retf
.4:
	db	0x2B, 0xD1			; sub dx, cx
	inc	dx
	mov	word [si + 0xe], dx
	jmp	near LineOk
.5:
	mov	bx, word [g_74F4]
	db	0x3B, 0xC3			; cmp ax, bx
	jl	short .6
	mov	al, 8
	mov	word [si + 6], bx
	mov	word [si + 0xa], bx
	jmp	short .3
.6:
	db	0x8B, 0xC2			; mov ax, dx
	db	0x2B, 0xC1			; sub ax, cx
	inc	ax
	mov	word [si + 0xe], ax
	cmp	dx, word [g_74FC]
	jge	short .7
	dec	word [si + 0xa]
	mov	word [si + 0x16], 1
	mov	al, 2
	jmp	short .3
.7:
	cmp	cx, word [g_74FE]
	jl	short .8
	dec	word [si + 0xa]
	mov	word [si + 0x1a], 1
	mov	al, 1
	jmp	short .3
.8:
	mov	ax, word [g_74FC]
	db	0x8B, 0xD8			; mov bx, ax
	db	0x2B, 0xC1			; sub ax, cx
	jle	short .9
	mov	word [si + 2], bx
	sub	word [si + 0xe], ax
.9:
	db	0x8B, 0xC2			; mov ax, dx
	mov	bx, word [g_74FE]
	dec	bx
	db	0x2B, 0xC3			; sub ax, bx
	jle	short .10
	sub	word [si + 0xe], ax
	mov	word [si + 8], bx
.10:
	jmp	near LineOk
LineOverflow:
	mov	cx, word [si + 0xa]
	sar	cx, 1
	mov	ax, word [si + 6]
	sar	ax, 1
	db	0x2B, 0xC8			; sub cx, ax
	sar	cx, 1
	mov	dx, word [si + 8]
	sar	dx, 1
	mov	ax, word [si + 2]
	sar	ax, 1
	db	0x2B, 0xD0			; sub dx, ax
	sar	dx, 1
.1:
	cmp	word [si + 6], 0xc180
	jg	short .7
.2:
	mov	ax, word [si + 6]
	db	0x03, 0xC1			; add ax, cx
	mov	word [si + 6], ax
	db	0x8B, 0xD8			; mov bx, ax
	sub	ax, word [g_74F2]
	jle	short .6
	db	0x3B, 0xC1			; cmp ax, cx
	jle	short .3
	db	0x8B, 0xC1			; mov ax, cx
.3:
	sub	bx, word [g_74F4]
	jle	short .4
	db	0x2B, 0xC3			; sub ax, bx
	jle	short .6
.4:
	mov	bx, word [si + 2]
	cmp	bx, word [g_74FC]
	jge	short .5
	add	word [si + 0x14], ax
	jmp	short .6
.5:
	add	word [si + 0x18], ax
.6:
	add	word [si + 2], dx
	jmp	short .1
.7:
	cmp	word [si + 0xa], 0x3e80
	jge	short .8
	cmp	word [si + 2], 0xc180
	jle	short .2
	cmp	word [si + 2], 0x3e80
	jge	short .2
	cmp	word [si + 8], 0xc180
	jle	short .8
	cmp	word [si + 8], 0x3e80
	jge	short .8
	jmp	near LineBody.3
.8:
	mov	ax, word [si + 0xa]
	db	0x2B, 0xC1			; sub ax, cx
	mov	word [si + 0xa], ax
	db	0x8B, 0xD8			; mov bx, ax
	sub	ax, word [g_74F4]
	inc	ax
	jge	short .12
	neg	ax
	db	0x3B, 0xC1			; cmp ax, cx
	jle	short .9
	db	0x8B, 0xC1			; mov ax, cx
.9:
	sub	bx, word [g_74F2]
	inc	bx
	jge	short .10
	db	0x03, 0xC3			; add ax, bx
	jle	short .12
.10:
	mov	bx, word [si + 8]
	cmp	bx, word [g_74FC]
	jge	short .11
	add	word [si + 0x16], ax
	jmp	short .12
.11:
	add	word [si + 0x1a], ax
.12:
	sub	word [si + 8], dx
	jmp	short .7
	db	0

; Open the path at [bp+6] for reading. The handle is written through [bp+8],
; the length through [bp+0Ch], and the position after a seek to the start
; through [bp+0Ah]. FileOpenArg takes the failure word from the caller.
; FileOpen forces 0. FileOpenMsg forces 1. Zero clears those three results.
; One reports the path through seg022. A failed open whose AltPath byte is
; set reads 400h bytes from that path and calls the far routine at AltCall.
; FileClose closes the handle at [bp+6], and skips the DOS call when it is 0.
; ReadAt seeks to the dword at [bp+8], then reads [bp+0Ch] bytes in 4000h
; chunks into the far buffer at [bp+10h]. ReadClose reads until a short
; read and then closes the handle. Both return that far pointer, or zero
; when the flag is 0. A flag of 1 reports the handle through seg022.

FileOpenArg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	mov	ax, word [bp + 0xe]
	mov	word [bp - 2], ax
	jmp	short FileOpenBody
FileOpen:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	mov	word [bp - 2], 0
	jmp	short FileOpenBody
FileOpenMsg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -2
	mov	word [bp - 2], 1
FileOpenBody:
	mov	dx, word [bp + 6]
	db	0x32, 0xC0			; xor al, al
	mov	ah, 0x3d
	int	0x21
	jb	short FileOpenAlt
	mov	bx, word [bp + 8]
	mov	word [bx], ax
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, 0x4202
	db	0x33, 0xC9			; xor cx, cx
	db	0x33, 0xD2			; xor dx, dx
	int	0x21
	jb	short FileOpenAlt
	mov	bx, word [bp + 0xc]
	mov	word [bx], ax
	mov	word [bx + 2], dx
	mov	bx, word [bp + 8]
	mov	bx, word [bx]
	mov	ax, 0x4200
	db	0x33, 0xC9			; xor cx, cx
	db	0x33, 0xD2			; xor dx, dx
	int	0x21
	jb	short FileOpenAlt
	mov	bx, word [bp + 0xa]
	mov	word [bx], ax
	mov	word [bx + 2], ax		; both words from AX
	leave
	retf
FileOpenAlt:
	cmp	byte [AltPath], 0
	je	short FileOpenFail
	mov	dx, AltPath
	db	0x32, 0xC0			; xor al, al
	mov	ah, 0x3d
	int	0x21
	jb	short FileOpenFail
	mov	bx, word [bp + 8]
	mov	word [bx], ax
	db	0x8B, 0xD8			; mov bx, ax
	lds	dx, [AltBuf]
	mov	cx, 0x400
	mov	ah, 0x3f
	int	0x21
	mov	ax, ss
	mov	ds, ax
	jb	short FileOpenFail
	push	word [bp + 6]
	push	word [AltBuf+2]
	push	word [AltBuf]
	call	far [AltCall]
	add	sp, 6
	db	0x0B, 0xC0			; or ax, ax
	jne	short .1
	db	0x0B, 0xD2			; or dx, dx
	je	short FileOpenFail
.1:
	mov	bx, word [bp + 0xa]
	mov	word [bx], ax
	mov	word [bx + 2], dx
	mov	bx, word [AltSize]
	mov	cx, word [bx]
	mov	ax, word [bx + 2]
	mov	bx, word [bp + 0xc]
	mov	word [bx], cx
	mov	word [bx + 2], ax
	db	0x8B, 0xC8			; mov cx, ax
	mov	ax, 0x4200
	mov	bx, word [bp + 8]
	mov	bx, word [bx]
	int	0x21
	jb	short FileOpenFail
	leave
	retf
FileOpenFail:
	mov	bx, word [bp + 8]
	mov	ax, word [bx]
	mov	word [bx], 0
	push	ax
	push	cs
	call	FileClose
	add	sp, 2
	cmp	word [bp - 2], 0
	jne	short .1
	mov	bx, word [bp + 0xc]
	db	0x33, 0xC0			; xor ax, ax
	mov	word [bx], ax
	mov	word [bx + 2], ax
	mov	bx, word [bp + 0xa]
	mov	word [bx], ax
	mov	word [bx + 2], ax
	leave
	retf
.1:
	mov	ax, ss
	mov	ds, ax
	mov	ax, 0x75e2
	push	word [bp + 6]
	push	ax
	call	0xF4A:0x3E4			; seg022
FileClose:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	mov	bx, word [bp + 6]
	cmp	bx, 0
	je	short .1
	mov	ah, 0x3e
	int	0x21
.1:
	leave
	retf
ReadAtArg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	ax, word [bp + 0x14]
	mov	word [bp - 6], ax
	jmp	short ReadAtBody
ReadAt:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	word [bp - 6], 0
	jmp	short ReadAtBody
ReadAtMsg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	word [bp - 6], 1
ReadAtBody:
	mov	ax, word [bp + 0x10]
	mov	word [bp - 2], ax
	mov	ax, word [bp + 0x12]
	mov	word [bp - 4], ax
	mov	bx, word [bp + 6]
	mov	ax, 0x4200
	mov	cx, word [bp + 0xa]
	mov	dx, word [bp + 8]
	int	0x21
	jb	short ReadAtFail
.1:
	mov	ds, word [bp - 4]
	mov	dx, word [bp - 2]
	mov	cx, 0x4000
	sub	word [bp + 0xc], cx
	sbb	word [bp + 0xe], 0
	jge	short .2
	add	cx, word [bp + 0xc]
	jle	short .3
.2:
	mov	bx, word [bp + 6]
	mov	ah, 0x3f
	int	0x21
	jb	short ReadAtFail
	add	word [bp - 4], 0x400
	jmp	short .1
.3:
	mov	ax, word [bp + 0x10]
	mov	dx, word [bp + 0x12]
	pop	ds
	leave
	retf
ReadAtFail:
	cmp	word [bp - 6], 0
	jne	short .1
	db	0x33, 0xC0			; xor ax, ax
	db	0x33, 0xD2			; xor dx, dx
	pop	ds
	leave
	retf
.1:
	mov	ax, 0x75f1
	mov	bx, ss
	mov	ds, bx
	push	word [bp + 6]
	push	ax
	call	0xF4A:0x3E4			; seg022
ReadCloseArg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	ax, word [bp + 0xc]
	mov	word [bp - 6], ax
	jmp	short ReadCloseBody
ReadClose:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	word [bp - 6], 0
	jmp	short ReadCloseBody
ReadCloseMsg:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -6
	push	ds
	mov	word [bp - 6], 1
ReadCloseBody:
	mov	ax, word [bp + 8]
	mov	word [bp - 2], ax
	mov	ax, word [bp + 0xa]
	mov	word [bp - 4], ax
.1:
	mov	ds, word [bp - 4]
	mov	dx, word [bp - 2]
	mov	cx, 0x4000
	mov	bx, word [bp + 6]
	mov	ah, 0x3f
	int	0x21
	jb	short ReadCloseFail
	add	word [bp - 4], 0x400
	cmp	ax, 0x4000
	je	short .1
	mov	bx, word [bp + 6]
	mov	ah, 0x3e
	int	0x21
	mov	ax, word [bp + 8]
	mov	dx, word [bp + 0xa]
	pop	ds
	leave
	retf
ReadCloseFail:
	cmp	word [bp - 6], 0
	jne	short .1
	db	0x33, 0xC0			; xor ax, ax
	db	0x33, 0xD2			; xor dx, dx
	pop	ds
	leave
	retf
.1:
	mov	ax, 0x75f1
	mov	bx, ss
	mov	ds, bx
	push	word [bp + 6]
	push	ax
	call	0xF4A:0x3E4			; seg022

; (arg1 * arg2 + 1FFFh) >> 14, returned in AX. The two words sit above
; the far return address.
; CpuProbe records the processor. A 286 or later pushes SP before
; decrementing it, so the compare falls through and Cpu286 is set.
; Flag bits 12-14 stick on a 386 or later, which sets Cpu386. CopyFar
; and FillFar test that word before a dword move. CpuPe is the PE bit
; from smsw. Cpu486 is set when the alignment flag can be flipped.
; An 8086 leaves all four words clear.
; NormFar returns the caller's pointer with the offset under 16.
; NormDsSi and NormEsDi do that for DS:SI and ES:DI. FarZero returns AX 0.

Mul16k:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	imul	dx
	add	ax, 0x1fff
	adc	dx, 0
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	db	0x03, 0xC0			; add ax, ax
	db	0x13, 0xD2			; adc dx, dx
	db	0x8B, 0xC2			; mov ax, dx
	retf
	db	0
CpuProbe:
	pushf
	push	sp
	pop	bx
	db	0x3B, 0xDC			; cmp bx, sp
	jne	short CpuProbeDone
	mov	word [Cpu286], 1
	pushf
	pop	bx
	or	bx, 0x7000
	push	bx
	popf
	pushf
	pop	bx
	and	bx, 0x7000
	je	short CpuProbeDone
	mov	word [Cpu386], 1
	movzx	esp, sp
	smsw	ax
	and	ax, 1
	mov	word [CpuPe], ax
	and	esp, 0xffff
	db	0x66, 0x8B, 0xD4			; mov edx, esp
	and	esp, 0xfffffffc
	pushfd
	pop	eax
	db	0x66, 0x8B, 0xC8			; mov ecx, eax
	xor	eax, 0x40000
	push	eax
	popfd
	pushfd
	pop	eax
	db	0x66, 0x33, 0xC1			; xor eax, ecx
	shr	eax, 0x12
	and	ax, 1
	mov	word [Cpu486], ax
	db	0x66, 0x8B, 0xE2			; mov esp, edx
CpuProbeDone:
	popf
	retf
	db	0
NormFar:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	mov	dx, word [bx + 6]
	db	0x8B, 0xD8			; mov bx, ax
	and	ax, 0xf
	shr	bx, 4
	db	0x03, 0xD3			; add dx, bx
	retf
NormDsSi:
	push	ax
	push	si
	shr	si, 4
	mov	ax, ds
	db	0x03, 0xC6			; add ax, si
	mov	ds, ax
	pop	si
	and	si, 0xf
	pop	ax
	ret
NormEsDi:
	push	ax
	push	di
	shr	di, 4
	mov	ax, es
	db	0x03, 0xC7			; add ax, di
	mov	es, ax
	pop	di
	and	di, 0xf
	pop	ax
	ret
	db	0
FarZero:
	db	0x33, 0xC0			; xor ax, ax
	retf
	db	0

; Another four entries into FillPoly. SI comes from [bp+0Ah], or from the
; address of that argument. ScanFn is 48D2h instead of the 3ABBh ArgSetup
; stores. The byte at [bp-9] selects which direction table SpanBack uses.
; FillPoly walks a list of X,Y points. [bp+8] is the count. A list that
; misses the box returns. A flat list calls LineFn. Each rising edge goes
; through LineClip or LineOpen, and ScanFn is called once per scanline
; with the two edge tables built on the stack.

FillFlag1:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 1
	jmp	short FillArg
FillFlag0:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 0
FillArg:
	mov	ax, 0x48d2
	mov	word [ScanFn], ax
	mov	ax, 0xc
	mov	word [LineFn], ax
	mov	si, word [bp + 0xa]
	jmp	short FillPoly
FillAddr1:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 1
	jmp	short FillAddr
FillAddr0:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 0
FillAddr:
	mov	ax, 0x48d2
	mov	word [ScanFn], ax
	mov	ax, 0xc
	mov	word [LineFn], ax
	lea	si, [bp + 0xa]
FillPoly:
	mov	word [bp - 6], si
	mov	cx, word [bp + 8]
	db	0x8B, 0xC1			; mov ax, cx
	dec	ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC6			; add ax, si
	mov	word [bp - 8], ax
	cld
	mov	ax, ss
	mov	es, ax
	lea	ax, [bp - 0x796]
	mov	word [bp - 0x16], ax
	mov	ax, word [g_74FC]
	mov	word [bp - 2], ax
	mov	ax, word [g_74FE]
	dec	ax
	mov	word [bp - 4], ax
	mov	ax, word [si + 2]
	mov	word [bp - 0xc], ax
	mov	word [bp - 0x10], ax
	mov	bx, word [si]
	db	0x8B, 0xD3			; mov dx, bx
	mov	word [bp - 0xe], si
	mov	word [bp - 0x12], si
	add	si, 4
	dec	cx
	jne	short .1
	push	word [bp + 6]
	mov	si, word [bp - 6]
	push	word [si + 2]
	push	word [si]
	push	word [si + 2]
	push	word [si]
	call	far [LineFn]
	add	sp, 0xa
	pop	di
	pop	si
	leave
	retf
.1:
	mov	ax, word [si + 2]
	cmp	ax, word [bp - 0xc]
	jg	short .2
	mov	word [bp - 0xc], ax
	mov	word [bp - 0xe], si
.2:
	cmp	ax, word [bp - 0x10]
	jle	short .3
	mov	word [bp - 0x10], ax
	mov	word [bp - 0x12], si
.3:
	mov	ax, word [si]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .4
	db	0x8B, 0xD8			; mov bx, ax
.4:
	db	0x3B, 0xC2			; cmp ax, dx
	jle	short .5
	db	0x8B, 0xD0			; mov dx, ax
.5:
	add	si, 4
	loop	.1
	cmp	dx, word [bp - 2]
	jl	short .9
	cmp	bx, word [bp - 4]
	jge	short .9
	mov	ax, word [bp - 0x10]
	cmp	ax, word [g_74F2]
	jl	short .9
	mov	cx, word [bp - 0xc]
	cmp	cx, word [g_74F4]
	jge	short .9
	mov	byte [bp - 0xa], 0
	cmp	dx, word [bp - 4]
	jg	short .6
	cmp	bx, word [bp - 2]
	jl	short .6
	cmp	ax, word [g_74F4]
	jge	short .6
	cmp	cx, word [g_74F2]
	jge	short .7
.6:
	mov	byte [bp - 0xa], 1
.7:
	db	0x3B, 0xC1			; cmp ax, cx
	je	short .8
	db	0x3B, 0xD3			; cmp dx, bx
	jne	short .10
.8:
	push	word [bp + 6]
	mov	si, word [bp - 6]
	push	ax
	push	dx
	push	cx
	push	bx
	call	far [LineFn]
	add	sp, 0xa
.9:
	pop	di
	pop	si
	leave
	retf
.10:
	lea	si, [bp - 0x7ce]
	mov	di, word [bp - 0xe]
.11:
	mov	ax, word [di + 2]
	mov	cx, word [di]
	add	di, 4
	cmp	di, word [bp - 8]
	jbe	short .12
	mov	di, word [bp - 6]
.12:
	mov	dx, word [di + 2]
	db	0x3B, 0xD0			; cmp dx, ax
	jle	short .15
	push	si
	push	dx
	push	word [di]
	push	ax
	push	cx
	cmp	byte [bp - 0xa], 0
	je	short .13
	call	CopyParasDown.4:LineClip
	mov	word [bp - 0x14], di
	call	SpanMargin
	jmp	short .14
.13:
	call	CopyParasDown.4:LineOpen
	mov	word [bp - 0x14], di
	call	SpanFill
.14:
	mov	di, word [bp - 0x14]
	add	sp, 0xa
.15:
	cmp	di, word [bp - 0x12]
	jne	short .11
	mov	di, word [bp - 0xe]
.16:
	mov	ax, word [di + 2]
	mov	cx, word [di]
	sub	di, 4
	cmp	di, word [bp - 6]
	jae	short .17
	mov	di, word [bp - 8]
.17:
	mov	dx, word [di + 2]
	db	0x3B, 0xD0			; cmp dx, ax
	jle	short .20
	push	si
	push	dx
	push	word [di]
	push	ax
	push	cx
	cmp	byte [bp - 0xa], 0
	je	short .18
	call	CopyParasDown.4:LineClip
	jmp	short .19
.18:
	call	CopyParasDown.4:LineOpen
.19:
	mov	word [bp - 0x14], di
	call	SpanBack
	mov	di, word [bp - 0x14]
	add	sp, 0xa
.20:
	cmp	di, word [bp - 0x12]
	jne	short .16
	mov	ax, word [bp - 0x10]
	cmp	ax, word [g_74F4]
	jl	short .21
	mov	ax, word [g_74F4]
	dec	ax
.21:
	mov	bx, word [bp - 0xc]
	cmp	bx, word [g_74F2]
	jge	short .22
	mov	bx, word [g_74F2]
.22:
	db	0x2B, 0xC3			; sub ax, bx
	jle	short .23
	inc	ax
	push	word [bp + 6]
	push	ax
	push	bx
	db	0x03, 0xDB			; add bx, bx
	lea	ax, [bp - 0x3d6]
	db	0x03, 0xC3			; add ax, bx
	push	ax
	lea	ax, [bp - 0x796]
	db	0x03, 0xC3			; add ax, bx
	push	ax
	call	far [ScanFn]
	add	sp, 0xa
.23:
	pop	di
	pop	si
	leave
	retf

; Write one clipped edge into the two scanline tables. They sit 3C0h
; bytes apart, one word per row. SpanMargin fills the rows the clipper
; counted with the left or right side of the box. SpanFill and SpanBack
; walk the edge. The direction byte selects the case. SpanBack uses
; SpanTab3 when the byte at [bp-9] is 0, and SpanTab2 otherwise.
; Directions 0, 1, and 9 return.

SpanMargin:
	mov	cx, word [si + 0x14]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .1
	mov	di, word [si + 6]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	adc	di, 0
	db	0x2B, 0xF9			; sub di, cx
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FC]
	push	cx
	push	di
	rep stosw
	pop	di
	pop	cx
	add	di, 0x3c0
	dec	ax
	rep stosw
.1:
	mov	cx, word [si + 0x18]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .2
	mov	di, word [si + 6]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	adc	di, 0
	db	0x2B, 0xF9			; sub di, cx
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FE]
	push	cx
	push	di
	rep stosw
	pop	di
	pop	cx
	add	di, 0x3c0
	dec	ax
	rep stosw
.2:
	mov	cx, word [si + 0x16]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .3
	mov	di, word [si + 0xa]
	inc	di
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FC]
	push	cx
	push	di
	rep stosw
	pop	di
	pop	cx
	add	di, 0x3c0
	dec	ax
	rep stosw
.3:
	mov	cx, word [si + 0x1a]
	db	0x0B, 0xC9			; or cx, cx
	jle	short SpanFill
	mov	di, word [si + 0xa]
	inc	di
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FE]
	push	cx
	push	di
	rep stosw
	pop	di
	pop	cx
	add	di, 0x3c0
	dec	ax
	rep stosw
SpanFill:
	mov	cx, word [si + 0xe]
	db	0x0B, 0xC9			; or cx, cx
	jle	short SpanTab.3
	mov	di, word [si + 6]
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	bl, byte [si + 0x12]
	db	0x32, 0xFF			; xor bh, bh
	db	0x03, 0xDB			; add bx, bx
	jmp	word [cs:bx+SpanTab]
SpanTab:
	dw	.3
	dw	.3
	dw	.1
	dw	.4
	dw	.6
	dw	.8
	dw	.10
	dw	.12
	dw	.16
	dw	.3
.1:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.2:
	mov	word [di + 0x3c0], ax
	stosw
	loop	.2
.3:
	ret
.4:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.5:
	mov	word [di + 0x3c0], ax
	stosw
	dec	ax
	loop	.5
	ret
.6:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.7:
	mov	word [di + 0x3c0], ax
	stosw
	inc	ax
	loop	.7
	ret
.8:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.9:
	mov	word [di + 0x3c0], ax
	stosw
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.9
	ret
.10:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.11:
	mov	word [di + 0x3c0], ax
	stosw
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.11
	ret
.12:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .13
	add	di, 2
.13:
	mov	word [di + 0x3c0], ax
.14:
	db	0x03, 0xD3			; add dx, bx
	jae	short .15
	stosw
	dec	ax
	loop	.13
	sub	di, 2
	ret
.15:
	dec	ax
	loop	.14
	inc	ax
	mov	word [di], ax
	ret
.16:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .17
	add	di, 2
.17:
	mov	word [di], ax
.18:
	db	0x03, 0xD3			; add dx, bx
	jae	short .19
	mov	word [di + 0x3c0], ax
	add	di, 2
	inc	ax
	loop	.17
	sub	di, 2
	ret
.19:
	inc	ax
	loop	.18
	dec	ax
	mov	word [di + 0x3c0], ax
	ret
SpanBack:
	mov	cx, word [si + 0xe]
	db	0x0B, 0xC9			; or cx, cx
	jle	short SpanTab2.3
	mov	di, word [si + 6]
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	bl, byte [si + 0x12]
	db	0x32, 0xFF			; xor bh, bh
	db	0x03, 0xDB			; add bx, bx
	cmp	byte [bp - 9], 0
	jne	short .1
	jmp	word [cs:bx+SpanTab3]
.1:
	jmp	word [cs:bx+SpanTab2]
SpanTab2:
	dw	SpanTab.3
	dw	SpanTab.3
	dw	.1
	dw	.6
	dw	.10
	dw	.14
	dw	.18
	dw	.22
	dw	.28
	dw	SpanTab.3
.1:
	mov	ax, word [si + 2]
.2:
	cmp	word [di + 0x3c0], ax
	jl	short .4
	cmp	word [di], ax
	jle	short .5
	stosw
	loop	.2
.3:
	jmp	near SpanTab3.45
.4:
	mov	word [di + 0x3c0], ax
.5:
	add	di, 2
	loop	.2
	jmp	near SpanTab3.45
.6:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.7:
	cmp	word [di + 0x3c0], ax
	jl	short .8
	cmp	word [di], ax
	jle	short .9
	stosw
	dec	ax
	loop	.7
	jmp	near SpanTab3.45
.8:
	mov	word [di + 0x3c0], ax
.9:
	add	di, 2
	dec	ax
	loop	.7
	jmp	near SpanTab3.45
.10:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.11:
	cmp	word [di + 0x3c0], ax
	jl	short .12
	cmp	word [di], ax
	jle	short .13
	stosw
	inc	ax
	loop	.11
	jmp	near SpanTab3.45
.12:
	mov	word [di + 0x3c0], ax
.13:
	add	di, 2
	inc	ax
	loop	.11
	jmp	near SpanTab3.45
.14:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.15:
	cmp	word [di + 0x3c0], ax
	jl	short .16
	cmp	word [di], ax
	jle	short .17
	stosw
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.15
	jmp	near SpanTab3.45
.16:
	mov	word [di + 0x3c0], ax
.17:
	add	di, 2
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.15
	jmp	near SpanTab3.45
.18:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.19:
	cmp	word [di + 0x3c0], ax
	jl	short .20
	cmp	word [di], ax
	jle	short .21
	stosw
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.19
	jmp	near SpanTab3.45
.20:
	mov	word [di + 0x3c0], ax
.21:
	add	di, 2
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.19
	jmp	near SpanTab3.45
.22:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .23
	add	di, 2
.23:
	cmp	word [di + 0x3c0], ax
	jge	short .24
	mov	word [di + 0x3c0], ax
.24:
	db	0x03, 0xD3			; add dx, bx
	jae	short .26
	cmp	word [di], ax
	jle	short .25
	mov	word [di], ax
.25:
	add	di, 2
	dec	ax
	loop	.23
	sub	di, 2
	jmp	near SpanTab3.45
.26:
	dec	ax
	loop	.24
	inc	ax
	cmp	word [di], ax
	jle	short .27
	mov	word [di], ax
.27:
	jmp	near SpanTab3.45
.28:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .29
	add	di, 2
.29:
	cmp	word [di], ax
	jle	short .30
	mov	word [di], ax
.30:
	db	0x03, 0xD3			; add dx, bx
	jae	short .32
	cmp	word [di + 0x3c0], ax
	jge	short .31
	mov	word [di + 0x3c0], ax
.31:
	add	di, 2
	inc	ax
	loop	.29
	sub	di, 2
	jmp	near SpanTab3.45
.32:
	inc	ax
	loop	.30
	dec	ax
	cmp	word [di + 0x3c0], ax
	jge	short .27
	mov	word [di + 0x3c0], ax
	jmp	near SpanTab3.45
SpanTab3:
	dw	SpanTab.3
	dw	SpanTab.3
	dw	.1
	dw	.5
	dw	.10
	dw	.15
	dw	.20
	dw	.25
	dw	.35
	dw	SpanTab.3
.1:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.2:
	cmp	word [di], ax
	jg	short .3
	cmp	word [di + 0x3c0], ax
	jl	short .4
	add	di, 2
	loop	.2
	jmp	near .45
.3:
	rep stosw
	jmp	near .45
.4:
	add	di, 0x3c0
	rep stosw
	jmp	near .45
.5:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.6:
	cmp	word [di], ax
	jg	short .7
	cmp	word [di + 0x3c0], ax
	jl	short .8
	add	di, 2
	dec	ax
	loop	.6
	jmp	near .45
.7:
	stosw
	dec	ax
	loop	.7
	jmp	near .45
.8:
	add	di, 0x3c0
.9:
	stosw
	dec	ax
	loop	.9
	jmp	near .45
.10:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
.11:
	cmp	word [di], ax
	jg	short .12
	cmp	word [di + 0x3c0], ax
	jl	short .13
	add	di, 2
	inc	ax
	loop	.11
	jmp	near .45
.12:
	stosw
	inc	ax
	loop	.12
	jmp	near .45
.13:
	add	di, 0x3c0
.14:
	stosw
	inc	ax
	loop	.14
	jmp	near .45
.15:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.16:
	cmp	word [di], ax
	jg	short .17
	cmp	word [di + 0x3c0], ax
	jl	short .18
	add	di, 2
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.16
	jmp	near .45
.17:
	stosw
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.17
	jmp	near .45
.18:
	add	di, 0x3c0
.19:
	stosw
	db	0x2B, 0xD3			; sub dx, bx
	sbb	ax, 0
	loop	.19
	jmp	near .45
.20:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	dx, word [si]
	add	dx, 0x8000
	adc	ax, 0
	mov	bx, word [si + 0xc]
.21:
	cmp	word [di], ax
	jg	short .22
	cmp	word [di + 0x3c0], ax
	jl	short .23
	add	di, 2
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.21
	jmp	near .45
.22:
	stosw
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.22
	jmp	near .45
.23:
	add	di, 0x3c0
.24:
	stosw
	db	0x03, 0xD3			; add dx, bx
	adc	ax, 0
	loop	.24
	jmp	near .45
.25:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .26
	add	di, 2
.26:
	cmp	word [di + 0x3c0], ax
	jl	short .28
	db	0x03, 0xD3			; add dx, bx
	jae	short .27
	cmp	word [di], ax
	jg	short .33
	add	di, 2
.27:
	dec	ax
	loop	.26
	jmp	short .45
.28:
	add	di, 0x3c0
.29:
	stosw
.30:
	dec	ax
	db	0x03, 0xD3			; add dx, bx
	jae	short .31
	loop	.29
	jmp	short .45
.31:
	loop	.30
	jmp	short .45
.32:
	db	0x03, 0xD3			; add dx, bx
	jae	short .34
.33:
	stosw
	dec	ax
	loop	.32
	jmp	short .45
.34:
	dec	ax
	loop	.32
	inc	ax
	mov	word [di], ax
	jmp	short .45
.35:
	mov	cx, word [si + 0xe]
	mov	ax, word [si + 2]
	mov	bx, word [si + 0xc]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	jae	short .36
	add	di, 2
.36:
	cmp	word [di], ax
	jg	short .43
	db	0x03, 0xD3			; add dx, bx
	jae	short .37
	cmp	word [di + 0x3c0], ax
	jl	short .38
	add	di, 2
.37:
	inc	ax
	loop	.36
	jmp	short .45
.38:
	add	di, 0x3c0
.39:
	mov	word [di], ax
.40:
	inc	ax
	db	0x03, 0xD3			; add dx, bx
	jae	short .41
	add	di, 2
	loop	.39
	dec	ax
	mov	word [di], ax
	jmp	short .45
.41:
	loop	.40
	add	di, 2
	dec	ax
	mov	word [di], ax
	jmp	short .45
.42:
	db	0x03, 0xD3			; add dx, bx
	jae	short .44
.43:
	stosw
.44:
	inc	ax
	loop	.42
	jmp	short .45
.45:
	cmp	byte [bp - 0xa], 0
	jne	short .46
	ret
.46:
	mov	cx, word [si + 0x14]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .47
	mov	di, word [si + 6]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	adc	di, 0
	db	0x2B, 0xF9			; sub di, cx
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FC]
	rep stosw
.47:
	mov	cx, word [si + 0x18]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .48
	mov	di, word [si + 6]
	mov	dx, word [si + 4]
	add	dx, 0x8000
	adc	di, 0
	db	0x2B, 0xF9			; sub di, cx
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	add	di, 0x3c0
	mov	ax, word [g_74FE]
	dec	ax
	rep stosw
.48:
	mov	cx, word [si + 0x16]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .49
	mov	di, word [si + 0xa]
	inc	di
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	mov	ax, word [g_74FC]
	rep stosw
.49:
	mov	cx, word [si + 0x1a]
	db	0x0B, 0xC9			; or cx, cx
	jle	short .50
	mov	di, word [si + 0xa]
	inc	di
	db	0x03, 0xFF			; add di, di
	add	di, word [bp - 0x16]
	add	di, 0x3c0
	mov	ax, word [g_74FE]
	dec	ax
	rep stosw
.50:
	ret

; FillRec1 and FillRec0 walk a list of pointers to line records. The
; flag byte selects the span table, as in FillPoly. LineFn is 3C9Ah.
; SinLookup and CosLookup read a quadrant of the word table. CosLookup
; increments AH first. SaveMode records the BIOS mode, equipment byte,
; columns, and rows, and registers RestoreMode. WaitBlank waits through
; one pulse of status port 3DAh bit 0.

FillRec1:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 1
	mov	ax, 0x48d2
	mov	word [ScanFn], ax
	mov	ax, 0x3c9a
	mov	word [LineFn], ax
	jmp	short FillRec
FillRec0:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	add	sp, -0x7ce
	push	si
	push	di
	mov	byte [bp - 9], 0
	mov	ax, 0x48d2
	mov	word [ScanFn], ax
	mov	ax, 0x3c9a
	mov	word [LineFn], ax
FillRec:
	lea	si, [bp + 0xa]
	mov	word [bp - 6], si
	mov	cx, word [bp + 8]
	db	0x8B, 0xC1			; mov ax, cx
	dec	ax
	db	0x03, 0xC0			; add ax, ax
	db	0x03, 0xC6			; add ax, si
	mov	word [bp - 8], ax
	cld
	mov	ax, ss
	mov	es, ax
	lea	ax, [bp - 0x796]
	mov	word [bp - 0x16], ax
	mov	ax, word [g_74FC]
	mov	word [bp - 2], ax
	mov	ax, word [g_74FE]
	dec	ax
	mov	word [bp - 4], ax
	mov	di, word [si]
	mov	ax, word [di + 6]
	sub	ax, word [di + 0x14]
	sub	ax, word [di + 0x18]
	mov	word [bp - 0xc], ax
	mov	ax, word [di + 0xa]
	add	ax, word [di + 0x16]
	add	ax, word [di + 0x1a]
	mov	word [bp - 0x10], ax
	mov	word [bp - 0x7ce], 3
	mov	bx, word [di + 2]
	mov	dx, word [di + 8]
	db	0x3B, 0xDA			; cmp bx, dx
	jle	short .1
	db	0x87, 0xDA			; xchg dx, bx
.1:
	mov	word [bp - 0xe], si
	mov	word [bp - 0x12], si
	add	si, 2
	dec	cx
	jne	short .2
	mov	ax, word [bp + 6]
	mov	word [bp + di + 6], ax
	push	di
	call	far [LineFn]
	add	sp, 2
	pop	di
	pop	si
	leave
	retf
.2:
	mov	di, word [si]
	mov	ax, word [di + 6]
	sub	ax, word [di + 0x14]
	sub	ax, word [di + 0x18]
	cmp	ax, word [bp - 0xc]
	jg	short .4
	jne	short .3
	test	word [bp - 0x7ce], 1
	je	short .5
.3:
	mov	word [bp - 0xc], ax
	mov	word [bp - 0xe], si
	or	word [bp - 0x7ce], 1
	jmp	short .5
.4:
	and	word [bp - 0x7ce], 2
.5:
	mov	ax, word [di + 0xa]
	add	ax, word [di + 0x16]
	add	ax, word [di + 0x1a]
	cmp	ax, word [bp - 0x10]
	jl	short .7
	jne	short .6
	test	word [bp - 0x7ce], 2
	jne	short .8
.6:
	mov	word [bp - 0x10], ax
	mov	word [bp - 0x12], si
	or	word [bp - 0x7ce], 2
	jmp	short .8
.7:
	and	word [bp - 0x7ce], 1
.8:
	mov	ax, word [di + 2]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .9
	db	0x8B, 0xD8			; mov bx, ax
.9:
	db	0x3B, 0xC2			; cmp ax, dx
	jle	short .10
	db	0x8B, 0xD0			; mov dx, ax
.10:
	mov	ax, word [di + 8]
	db	0x3B, 0xC3			; cmp ax, bx
	jge	short .11
	db	0x8B, 0xD8			; mov bx, ax
.11:
	db	0x3B, 0xC2			; cmp ax, dx
	jle	short .12
	db	0x8B, 0xD0			; mov dx, ax
.12:
	add	si, 2
	loop	.2
	cmp	dx, word [bp - 2]
	jl	short .16
	cmp	bx, word [bp - 4]
	jge	short .16
	mov	ax, word [bp - 0x10]
	cmp	ax, word [g_74F2]
	jl	short .16
	mov	cx, word [bp - 0xc]
	cmp	cx, word [g_74F4]
	jge	short .16
	mov	byte [bp - 0xa], 0
	cmp	dx, word [bp - 4]
	jg	short .13
	cmp	bx, word [bp - 2]
	jl	short .13
	cmp	ax, word [g_74F4]
	jge	short .13
	cmp	cx, word [g_74F2]
	jge	short .14
.13:
	mov	byte [bp - 0xa], 1
.14:
	db	0x3B, 0xC1			; cmp ax, cx
	je	short .15
	db	0x3B, 0xD3			; cmp dx, bx
	jne	short .17
.15:
	mov	si, word [bp - 6]
	mov	di, word [si]
	push	di
	call	far [LineFn]
	add	sp, 2
.16:
	pop	di
	pop	si
	leave
	retf
.17:
	mov	di, word [bp - 0xe]
.18:
	mov	si, word [di]
	cmp	byte [si + 0x12], 2
	jl	short .21
	mov	word [bp - 0x14], di
	cmp	byte [bp - 0xa], 0
	je	short .19
	call	SpanMargin
	jmp	short .20
.19:
	call	SpanFill
.20:
	mov	di, word [bp - 0x14]
.21:
	cmp	di, word [bp - 0x12]
	je	short .22
	add	di, 2
	cmp	di, word [bp - 8]
	jbe	short .18
	mov	di, word [bp - 6]
	jmp	short .18
.22:
	mov	di, word [bp - 0xe]
.23:
	sub	di, 2
	cmp	di, word [bp - 6]
	jae	short .24
	mov	di, word [bp - 8]
.24:
	cmp	di, word [bp - 0x12]
	je	short .25
	mov	si, word [di]
	cmp	byte [si + 0x12], 2
	jl	short .23
	mov	word [bp - 0x14], di
	call	SpanBack
	mov	di, word [bp - 0x14]
	jmp	short .23
.25:
	mov	ax, word [bp - 0x10]
	cmp	ax, word [g_74F4]
	jl	short .26
	mov	ax, word [g_74F4]
	dec	ax
.26:
	mov	bx, word [bp - 0xc]
	cmp	bx, word [g_74F2]
	jge	short .27
	mov	bx, word [g_74F2]
.27:
	db	0x2B, 0xC3			; sub ax, bx
	jle	short .28
	inc	ax
	push	word [bp + 6]
	push	ax
	push	bx
	db	0x03, 0xDB			; add bx, bx
	lea	ax, [bp - 0x3d6]
	db	0x03, 0xC3			; add ax, bx
	push	ax
	lea	ax, [bp - 0x796]
	db	0x03, 0xC3			; add ax, bx
	push	ax
	call	far [ScanFn]
	add	sp, 0xa
.28:
	pop	di
	pop	si
	leave
	retf
SinLookup:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	jmp	short AngleTab
CosLookup:
	db	0x8B, 0xDC			; mov bx, sp
	mov	ax, word [bx + 4]
	inc	ah
AngleTab:
	and	ah, 3
	jnp	short .1
	jne	short .3
	db	0x03, 0xC0			; add ax, ax
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bx + Sin0]
	retf
.1:
	dec	ah
	jne	short .2
	neg	ax
	db	0x03, 0xC0			; add ax, ax
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bx + Sin1]
	retf
.2:
	db	0x03, 0xC0			; add ax, ax
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bx + Sin2]
	neg	ax
	retf
.3:
	neg	ax
	db	0x03, 0xC0			; add ax, ax
	db	0x8B, 0xD8			; mov bx, ax
	mov	ax, word [bx + Sin3]
	neg	ax
	retf
	db	0
ClearHold:
	mov	word [HoldWord], 0
	retf
	db	0
SaveMode:
	cmp	byte [VidMode], 0
	jne	short .1
	mov	ah, 0xf
	int	0x10
	mov	byte [VidMode], al
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	al, byte es:[0x410]
	mov	byte [VidEquip], al
	mov	ax, word es:[0x44a]
	mov	word [VidCols], ax
	mov	al, byte es:[0x484]
	mov	byte [VidRows], al
	mov	ax, 0x336d
	push	cs
	push	ax
	call	CopyParasDown.4:OnexitThunk
	add	sp, 4
.1:
	retf
RestoreMode:
	cmp	byte [VidMode], 0
	je	short .3
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	al, byte [VidEquip]
	mov	byte es:[0x410], al
	db	0x32, 0xE4			; xor ah, ah
	mov	al, byte [VidMode]
	int	0x10
	cmp	byte [VidMode], 3
	jne	short .1
	cmp	word [VidCols], 0x50
	jne	short .1
	cmp	byte [VidRows], 0x2a
	jb	short .1
	cmp	byte [VidRows], 0x32
	ja	short .1
	mov	ax, 0x1112
	db	0x33, 0xDB			; xor bx, bx
	int	0x10
.1:
	db	0x33, 0xC0			; xor ax, ax
	mov	es, ax
	mov	al, byte [VidEquip]
	mov	byte es:[0x410], al
	and	al, 0x30
	cmp	al, 0x30
	jne	short .2
	db	0x33, 0xC0			; xor ax, ax
	push	ax
	call	0xFEF:0x3A84		; seg028
	add	sp, 2
.2:
	mov	ah, 0xb
	mov	bx, 0
	int	0x10
	mov	byte [VidMode], 0
.3:
	retf
WaitBlank:
	mov	dx, 0x3da
.1:
	in	al, dx
	test	al, 1
	je	short .1
.2:
	in	al, dx
	test	al, 1
	jne	short .2
	retf
