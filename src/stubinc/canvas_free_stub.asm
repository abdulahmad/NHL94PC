;	Segment build for pc/video/canvas_free.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
SortPairsTail.check		equ	0x2
InitHeap.1		equ	0xE9
BufPtr		equ	0x2BC
FatalError		equ	0x3E4
FindUnlink		equ	0x99A
str_RowSpaceCorrupted		equ	0x6D28
ChainIdx		equ	0xAE9C
%include "pc/video/canvas_free.asm"
