;	Segment build for seg/seg004.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
CopyFar		equ	0x276
LongShlAt		equ	0x1270
_fmemchr		equ	0x135C
RetOnly		equ	0x1398
%include "seg/seg004.asm"
