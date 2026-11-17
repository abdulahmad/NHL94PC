;	Segment build for seg/seg040.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F028_0E85		equ	0xE85
F028_3406		equ	0x3406
F028_3499		equ	0x3499
%include "seg/seg040.asm"
