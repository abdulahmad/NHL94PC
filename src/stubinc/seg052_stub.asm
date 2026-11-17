;	Segment build for seg/seg052.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F053_0002		equ	0x2
F034_0092		equ	0x92
EmsMapFrame		equ	0x192
F022_03E4		equ	0x3E4
LinearToFarRegs		equ	0x959
%include "seg/seg052.asm"
