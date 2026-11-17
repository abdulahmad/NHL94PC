;	Segment build for pc/type_id.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
CopyFar		equ	0x276
LongShlAt		equ	0x1270
_fmemchr		equ	0x135C
RetOnly		equ	0x1398
MapLo		equ	0x8ED6
MapHi		equ	0x8ED8
OutPtr		equ	0x8EDA
InPtr		equ	0x8EDE
MapPair		equ	0x8EE2
BitBuf		equ	0x8EE4
BitCount		equ	0x8EE8
%include "pc/type_id.asm"
