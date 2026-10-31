; Segment seg001. EMS maps, far copies, the INT 24h hook, file length,
; a file-head count, find-first paths, the DOS memory block, a 4-byte lookup,
; far-pointer lookup, a counted copy, multiply and divide, file writes,
; character widths, the INT 8 handler, and the game port sticks.
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
PathBuf		equ	0x6310
PathCut		equ	0x6374
FindDta		equ	0x6376
BlockEnd		equ	0x63F8
BlockSeg		equ	0x63FC
SavedCs		equ	0x63FE
SavedDs		equ	0x6400
CharSeg		equ	0x6D50
SlotTab		equ	0x6DB4
TickGate		equ	0x6DB0
TickSkip		equ	0x6DB2
Int8Sp		equ	0x6F08
Int8Ss		equ	0x6F0A
CallCount	equ	0x6DA0
TickFrac		equ	0x6DA8
TickStep		equ	0x6DAA
TickTotal	equ	0x6DA4
SkipEoi		equ	0x6F0E
WantText		equ	0x640A
JoyX		equ	0x6FF8
JoyY		equ	0x6FFA
JoyBtn		equ	0x6FFD
JoyBits		equ	0x6FFE
JoyOn		equ	0x7308
Stick1X		equ	0x7050
Stick1Y		equ	0x7052
Stick2X		equ	0x7030
Stick2Y		equ	0x7032
Stick1Bits	equ	0x7055
Stick2Bits	equ	0x7056
StickRaw		equ	0x7054
GamePort	equ	0x201
FmtSave		equ	0x64CE
FmtBuf		equ	0x64D6

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

; Call the routine at 0x1DD4 with the two words, take the absolute value,
; and fold it: at or above 100h it becomes 200h minus the value. Above 80h
; the result comes from the routine at 0x32EA and the first word; otherwise
; from 0x32F1 and the second word. The dividend is the absolute word shifted
; left 14, then divided by that result. Those three calls are still incbin.
FoldScale:
	push	bp
	db	0x8B, 0xEC			; mov bp, sp
	push	word [bp+8]
	push	word [bp+6]
	call	0x3A3:0x1DD4			; seg001, still incbin
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
	call	0x3A3:0x32F1			; seg001, still incbin
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
	call	0x3A3:0x32EA			; seg001, still incbin
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
	call	0x3A3:EmsMarkStale		; seg001
	mov	ax, word [bp+6]
	push	ax
	mov	ax, word [bp+4]
	push	ax
	call	0x3A3:EmsMapFrame		; seg001
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
	call	0x3A3:FindFarMsg		; seg001
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
	call	0x3A3:FindFar			; seg001
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
	call	0x3A3:CopyFar			; seg001
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
	jmp	short L0C49


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
L0C24:
	mov	bl, byte [si]
	db	0x0A, 0xDB			; or bl, bl
	je	short L0C49
	inc	si
	db	0x32, 0xFF			; xor bh, bh
	db	0x03, 0xDB			; add bx, bx
	mov	bx, word es:[bx + 0x16]
	db	0x0B, 0xDB			; or bx, bx
	je	short L0C24
	db	0x0A, 0xC9			; or cl, cl
	je	short L0C42
	mov	bl, byte es:[bx]
	db	0x32, 0xFF			; xor bh, bh
	db	0x8B, 0xFB			; mov di, bx
L0C42:
	db	0x03, 0xC7			; add ax, di
	dec	dx
	je	short L0C49
	jmp	short L0C24
L0C49:
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
	call	0x2964			; still incbin
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
	mov	word [0x6daa], 0x2e9b
	cli
	mov	word [0x6da8], 0
	mov	word [0x6db0], 1
	mov	word [0x6db4], 0
	mov	word [0x6db6], 0
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
	je	short L0D10
	mov	word [0x6d98], ax
L0D10:
	mov	ax, word es:[0x22]
	mov	bx, cs
	db	0x3B, 0xC3			; cmp ax, bx
	je	short L0D33
	mov	word [0x6d9a], ax
	mov	word [es:0x20], Int8Handler
	mov	word es:[0x22], cs
	mov	word [0x6d9c], EmptyRet
	mov	word [0x6d9e], cs
L0D33:
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
	call	0x3A3:OnexitThunk
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
	je	short L0D60
	retf
L0D60:
	mov	ax, word es:[0x20]
	cmp	ax, Int8Handler
	je	short L0D6A
	retf
L0D6A:
	in	al, 0x21
	or	al, 3
	out	0x21, al
	cli
	mov	ax, word [0x6d98]
	mov	word es:[0x20], ax
	mov	ax, word [0x6d9a]
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
L0D95:
	cmp	word [bx + 2], 0
	je	short L0DA9
	add	bx, 4
	loop	L0D95
	mov	ax, 0x6ddc
	push	ax
	call	0xF4A:0x3E4			; seg022
L0DA9:
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
L0DCF:
	cmp	word [bx], ax
	jne	short L0DD8
	cmp	word [bx + 2], dx
	je	short L0DDF
L0DD8:
	add	bx, 4
	loop	L0DCF
	leave
	retf
L0DDF:
	cli
	dec	cx
	je	short L0DF3
L0DE3:
	mov	ax, word [bx + 4]
	mov	word [bx], ax
	mov	ax, word [bx + 6]
	mov	word [bx + 2], ax
	add	bx, 4
	loop	L0DE3
L0DF3:
	mov	word [bx], 0
	mov	word [bx + 2], 0
	sti
	leave
	retf


; AX is how many SlotTab pairs have a nonzero second word.
CountSlots:
	db	0x33, 0xC0			; xor ax, ax
	mov	bx, SlotTab
L0E04:
	cmp	word [bx + 2], 0
	je	short L0E10
	add	bx, 4
	inc	ax
	jmp	short L0E04
L0E10:
	retf


; AX is 1 when SS equals DS, else 0.
SsIsDs:
	db	0x33, 0xC0			; xor ax, ax
	mov	bx, ss
	mov	dx, ds
	db	0x3B, 0xDA			; cmp bx, dx
	jne	short L0E1C
	inc	ax
L0E1C:
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
	jne	short L0E32
	mov	al, 0x20
	out	0x20, al
L0E32:
	sti
	push	bx
	dec	word [TickGate]
	jne	short L0E7D
	cmp	byte [TickSkip], 0
	jne	short L0E7D
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
	jne	short L0E6A
	inc	word [0x6da2]
	jmp	short L0E6A
L0E65:
	db	0xFF, 0x1C			; lcall [si]
	add	si, 4
L0E6A:
	cmp	word [si + 2], 0
	jne	short L0E65
	mov	ax, word [Int8Ss]
	mov	ss, ax
	mov	sp, word [Int8Sp]
	pop	es
	pop	si
	pop	dx
	pop	cx
L0E7D:
	inc	word [TickGate]
	mov	ax, word [TickStep]
	add	word [TickFrac], ax
	jae	short L0ECA
	inc	word [TickTotal]
	jne	short L0E94
	inc	word [0x6da6]
L0E94:
	db	0x33, 0xC0			; xor ax, ax
	mov	ds, ax
	mov	bx, 0x46c
	inc	word [bx]
	jne	short L0EA2
	inc	word [bx + 2]
L0EA2:
	cmp	word [bx + 2], 0x18
	jb	short L0EB7
	cmp	word [bx], 0xb0
	jb	short L0EB7
	mov	word [bx], ax
	mov	word [bx + 2], ax
	mov	byte [bx + 4], 1
L0EB7:
	dec	byte [0x440]
	jne	short L0ECA
	push	dx
	mov	dx, 0x3f2
	mov	al, 0xf
	out	dx, al
	pop	dx
	and	byte [0x43f], 0xf0
L0ECA:
	pop	bx
	pop	ax
	pop	ds
	iret


; If WantText is nonzero, clears it, calls seg028, forces the BIOS equipment
; word to 80-column color, and sets video mode 3 with background 0.
ResetText:
	cmp	word [WantText], 0
	je	short L0F06
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
L0F06:
	retf

	db	0x00


; If bit 0 of JoyOn is clear, return JoyBits. Otherwise read port 201h.
; Bits 4 and 5 are the buttons. Bits 0 and 1 are timed until they drop, or
; until the count reaches 0FA0h. The counts are kept against running limits,
; and JoyBits gains a bit when a count falls outside the inner range.
PollJoy:
	mov	byte [JoyBits], 0
	test	byte [JoyOn], 1
	jne	short L0F17
	jmp	near L10B6
L0F17:
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
L0F37:
	in	al, dx
	db	0x22, 0xC3			; and al, bl
	db	0x32, 0xC3			; xor al, bl
	jne	short L0F47
	inc	cx
	cmp	cx, 0xfa0
	jl	short L0F37
	jmp	short L0F63
L0F47:
	test	al, 1
	jne	short L0F5A
L0F4B:
	test	al, 2
	je	short L0F37
	mov	word [JoyY], cx
	and	bl, 1
	jne	short L0F37
	jmp	short L0F63
L0F5A:
	mov	word [JoyX], cx
	and	bl, 2
	jne	short L0F4B
L0F63:
	sti
	mov	ax, word [JoyX]
	cmp	ax, word [0x6fff]
	jge	short L0FBA
	dec	word [0x7007]
	jle	short L0F7E
	cmp	ax, word [0x7001]
	jl	short L0FED
	mov	word [0x7001], ax
	jmp	short L0FED
L0F7E:
	mov	bx, word [0x7001]
	mov	word [0x6fff], bx
	mov	bx, word [0x7003]
L0F8A:
	sub	bx, word [0x6fff]
	jle	short L0F9A
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x701b], ax
L0F9A:
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
	jmp	short L0FDB
L0FBA:
	cmp	ax, word [0x7003]
	jle	short L0FDB
	dec	word [0x7007]
	jle	short L0FD1
	cmp	ax, word [0x7005]
	jge	short L0FED
	mov	word [0x7005], ax
	jmp	short L0FED
L0FD1:
	mov	bx, word [0x7005]
	mov	word [0x7003], bx
	jmp	short L0F8A
L0FDB:
	mov	word [0x7007], 0x14
	mov	word [0x7005], 0x4e20
	mov	word [0x7001], 0
L0FED:
	cmp	ax, word [0x7009]
	jl	short L1054
	cmp	ax, word [0x700b]
	jl	short L0FFE
	or	byte [JoyBits], 4
L0FFE:
	mov	ax, word [JoyY]
	cmp	ax, word [0x700d]
	jae	short L105B
	dec	word [0x7015]
	jle	short L1018
	cmp	ax, word [0x700f]
	jl	short L108E
	mov	word [0x700f], ax
	jmp	short L108E
L1018:
	mov	bx, word [0x700f]
	mov	word [0x700d], bx
	mov	bx, word [0x7011]
L1024:
	sub	bx, word [0x700d]
	jle	short L1034
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x701d], ax
L1034:
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
	jmp	short L107C
L1054:
	or	byte [JoyBits], 8
	jmp	short L0FFE
L105B:
	cmp	ax, word [0x7011]
	jle	short L107C
	dec	word [0x7015]
	je	short L1072
	cmp	ax, word [0x7013]
	jge	short L108E
	mov	word [0x7013], ax
	jmp	short L108E
L1072:
	mov	bx, word [0x7013]
	mov	word [0x7011], bx
	jmp	short L1024
L107C:
	mov	word [0x7015], 0x14
	mov	word [0x7013], 0x4e20
	mov	word [0x700f], 0
L108E:
	cmp	ax, word [0x7017]
	jb	short L10BC
	cmp	ax, word [0x7019]
	jb	short L109F
	or	byte [JoyBits], 2
L109F:
	in	al, dx
	and	al, 0x30
	cmp	al, byte [JoyBtn]
	je	short L10AD
	mov	al, byte [0x6ffc]
	jmp	short L10B2
L10AD:
	xor	al, 0x30
	mov	byte [0x6ffc], al
L10B2:
	or	byte [JoyBits], al
L10B6:
	mov	al, byte [JoyBits]
	db	0x32, 0xE4			; xor ah, ah
	retf
L10BC:
	or	byte [JoyBits], 1
	jmp	short L109F


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
	mov	al, byte [bx + 0x701f]
	db	0x32, 0xE4			; xor ah, ah
	leave
	retf


; (JoyX minus the low limit) times the X scale. The high word of that
; product, minus 1Fh, is the result. A reading under the limit returns the
; scale of zero, then the same subtract.
JoyScaleX:
	mov	ax, word [JoyX]
	sub	ax, word [0x6fff]
	jge	short L10FD
	db	0x33, 0xC0			; xor ax, ax
L10FD:
	mul	word [0x701b]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for JoyY.
JoyScaleY:
	mov	ax, word [JoyY]
	sub	ax, word [0x700d]
	jge	short L1114
	db	0x33, 0xC0			; xor ax, ax
L1114:
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
	jne	short L112B
	db	0x33, 0xC0			; xor ax, ax
	retf
L112B:
	mov	byte [Stick1Bits], 0
	mov	byte [Stick2Bits], 0
	mov	dx, GamePort
	in	al, dx
	mov	byte [StickRaw], al
	db	0x32, 0xFF			; xor bh, bh
	mov	bl, byte [bx + 0x7074]
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
L115A:
	in	al, dx
	db	0x22, 0xC3			; and al, bl
	db	0x32, 0xC3			; xor al, bl
	jne	short L116A
	inc	cx
	cmp	cx, 0xfa0
	jl	short L115A
	jmp	short L11A4
L116A:
	test	al, 1
	jne	short L1185
L116E:
	test	al, 2
	jne	short L1190
L1172:
	test	al, 4
	jne	short L119B
L1176:
	test	al, 8
	je	short L115A
	mov	word [Stick2Y], cx
	and	bl, 7
	jne	short L115A
	jmp	short L11A4
L1185:
	mov	word [Stick1X], cx
	and	bl, 0xe
	jne	short L116E
	jmp	short L11A4
L1190:
	mov	word [Stick1Y], cx
	and	bl, 0xd
	jne	short L1172
	jmp	short L11A4
L119B:
	mov	word [Stick2X], cx
	and	bl, 0xb
	jne	short L1176
L11A4:
	sti
	test	byte [JoyOn], 1
	jne	short L11AF
	jmp	near L12D0
L11AF:
	mov	bx, word [Stick1X]
	cmp	bx, word [0x7058]
	jge	short L11F2
	mov	word [0x7058], bx
	mov	bx, word [0x705a]
L11C1:
	sub	bx, word [0x7058]
	jle	short L11D1
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x7070], ax
L11D1:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x7058]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x7062], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x7060], ax
	mov	bx, word [Stick1X]
	jmp	short L1214
L11F2:
	cmp	bx, word [0x705a]
	jle	short L1214
	dec	word [0x705e]
	je	short L120A
	cmp	bx, word [0x705c]
	jge	short L1220
	mov	word [0x705c], bx
	jmp	short L1220
L120A:
	mov	bx, word [0x705c]
	mov	word [0x705a], bx
	jmp	short L11C1
L1214:
	mov	word [0x705e], 8
	mov	word [0x705c], 0x4e20
L1220:
	cmp	bx, word [0x7060]
	jl	short L1274
	cmp	bx, word [0x7062]
	jl	short L1231
	or	byte [Stick1Bits], 4
L1231:
	mov	bx, word [Stick1Y]
	cmp	bx, word [0x7064]
	jae	short L127B
	mov	word [0x7064], bx
	mov	bx, word [0x7066]
L1243:
	sub	bx, word [0x7064]
	jle	short L1253
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x7072], ax
L1253:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x7064]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x706e], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x706c], ax
	mov	bx, word [Stick1Y]
	jmp	short L129D
L1274:
	or	byte [Stick1Bits], 8
	jmp	short L1231
L127B:
	cmp	bx, word [0x7066]
	jle	short L129D
	dec	word [0x706a]
	je	short L1293
	cmp	bx, word [0x7068]
	jge	short L12A9
	mov	word [0x7068], bx
	jmp	short L12A9
L1293:
	mov	bx, word [0x7068]
	mov	word [0x7066], bx
	jmp	short L1243
L129D:
	mov	word [0x706a], 8
	mov	word [0x7068], 0x4e20
L12A9:
	cmp	bx, word [0x706c]
	jb	short L12C9
	cmp	bx, word [0x706e]
	jb	short L12BA
	or	byte [Stick1Bits], 2
L12BA:
	in	al, dx
	and	al, byte [StickRaw]
	and	al, 0x30
	xor	al, 0x30
	or	byte [Stick1Bits], al
	jmp	short L12D0
L12C9:
	or	byte [Stick1Bits], 1
	jmp	short L12BA
L12D0:
	test	byte [JoyOn], 2
	jne	short L12DA
	jmp	near L13F6
L12DA:
	mov	bx, word [Stick2X]
	cmp	bx, word [0x7034]
	jge	short L131D
	mov	word [0x7034], bx
	mov	bx, word [0x7036]
L12EC:
	sub	bx, word [0x7034]
	jle	short L12FC
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x704c], ax
L12FC:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x7034]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x703e], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x703c], ax
	mov	bx, word [Stick2X]
	jmp	short L133F
L131D:
	cmp	bx, word [0x7036]
	jle	short L133F
	dec	word [0x703a]
	je	short L1335
	cmp	bx, word [0x7038]
	jge	short L134B
	mov	word [0x7038], bx
	jmp	short L134B
L1335:
	mov	bx, word [0x7038]
	mov	word [0x7036], bx
	jmp	short L12EC
L133F:
	mov	word [0x703a], 8
	mov	word [0x7038], 0x4e20
L134B:
	cmp	bx, word [0x703c]
	jl	short L139F
	cmp	bx, word [0x703e]
	jl	short L135C
	or	byte [Stick2Bits], 4
L135C:
	mov	bx, word [Stick2Y]
	cmp	bx, word [0x7040]
	jae	short L13A6
	mov	word [0x7040], bx
	mov	bx, word [0x7042]
L136E:
	sub	bx, word [0x7040]
	jle	short L137E
	db	0x33, 0xD2			; xor dx, dx
	mov	ax, 0x4000
	div	bx
	mov	word [0x704e], ax
L137E:
	db	0x8B, 0xC3			; mov ax, bx
	mov	dx, GamePort
	shr	ax, 1
	db	0x8B, 0xD8			; mov bx, ax
	shr	bx, 1
	add	ax, word [0x7040]
	db	0x03, 0xC3			; add ax, bx
	mov	word [0x704a], ax
	db	0x2B, 0xC3			; sub ax, bx
	db	0x2B, 0xC3			; sub ax, bx
	mov	word [0x7048], ax
	mov	bx, word [Stick2Y]
	jmp	short L13C8
L139F:
	or	byte [Stick2Bits], 8
	jmp	short L135C
L13A6:
	cmp	bx, word [0x7042]
	jle	short L13C8
	dec	word [0x7046]
	je	short L13BE
	cmp	bx, word [0x7044]
	jge	short L13D4
	mov	word [0x7044], bx
	jmp	short L13D4
L13BE:
	mov	bx, word [0x7044]
	mov	word [0x7042], bx
	jmp	short L136E
L13C8:
	mov	word [0x7046], 8
	mov	word [0x7044], 0x4e20
L13D4:
	cmp	bx, word [0x7048]
	jb	short L13FE
	cmp	bx, word [0x704a]
	jb	short L13E5
	or	byte [Stick2Bits], 2
L13E5:
	in	al, dx
	and	al, byte [StickRaw]
	and	al, 0xc0
	xor	al, 0xc0
	shr	al, 1
	shr	al, 1
	or	byte [Stick2Bits], al
L13F6:
	mov	al, byte [Stick1Bits]
	mov	ah, byte [Stick2Bits]
	retf
L13FE:
	or	byte [Stick2Bits], 1
	jmp	short L13E5


; Set JoyOn bit 0 and the initial limits for the first pair. _main calls this.
InitStick1:
	or	byte [JoyOn], 1
	mov	word [0x7058], 0x50
	mov	word [0x705a], 0
	mov	word [0x7064], 0x50
	mov	word [0x7066], 0
	retf


; Set JoyOn bit 1 and the initial limits for the second pair. _main calls this.
InitStick2:
	or	byte [JoyOn], 2
	mov	word [0x7034], 0x50
	mov	word [0x7036], 0
	mov	word [0x7040], 0x50
	mov	word [0x7042], 0
	retf


; (Stick1X minus its low limit) times the X scale. High word of the product minus 1Fh.
ScaleStick1X:
	mov	ax, word [Stick1X]
	sub	ax, word [0x7058]
	jge	short L144C
	db	0x33, 0xC0			; xor ax, ax
L144C:
	mul	word [0x7070]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick1Y.
ScaleStick1Y:
	mov	ax, word [Stick1Y]
	sub	ax, word [0x7064]
	jge	short L1463
	db	0x33, 0xC0			; xor ax, ax
L1463:
	mul	word [0x7072]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick2X.
ScaleStick2X:
	mov	ax, word [Stick2X]
	sub	ax, word [0x7034]
	jge	short L147A
	db	0x33, 0xC0			; xor ax, ax
L147A:
	mul	word [0x704c]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf


; The same scale for Stick2Y.
ScaleStick2Y:
	mov	ax, word [Stick2Y]
	sub	ax, word [0x7040]
	jge	short L1491
	db	0x33, 0xC0			; xor ax, ax
L1491:
	mul	word [0x704e]
	db	0x8A, 0xC4			; mov al, ah
	db	0x8A, 0xE2			; mov ah, dl
	sub	ax, 0x1f
	retf

	incbin	"Extracted/segments/seg001.bin", 0x149D, 0x33E0 - 0x149D
