;	Segment build for pc/video/xor_frame.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar10		equ	0x0
SortPairsPass		equ	0xA0
XorRect		equ	0x352C
%include "pc/video/xor_frame.asm"
