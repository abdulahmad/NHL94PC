;	Segment build for pc/video/canvas_alloc.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
InsertRecWrap		equ	0x13
AllocRecData		equ	0x30
BufPtr		equ	0x2BC
FatalError		equ	0x3E4
FarToLinear		equ	0x92E
LinearToFarRegs		equ	0x959
__aFlmul		equ	0x1226
__aFlshl		equ	0x1258
__aFlsar		equ	0x1264
FillFarZero		equ	0x1E5F
ChainIdx		equ	0xAE9C
%include "pc/video/canvas_alloc.asm"
