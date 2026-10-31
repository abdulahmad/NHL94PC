; Segment seg000. Microsoft C startup and the C runtime, and the VGA
; copies that were linked in front of them. __astart (seg056) jumps to
; MscStartup. The bytes before that, and everything after __chkstk, are
; still the original image.
	incbin	"Extracted/segments/seg000.bin", 0, 0x4CA

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
