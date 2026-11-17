;	Segment build for pc/random.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
MulRegs		equ	0x9D5
seed		equ	0x2A00
%include "pc/random.asm"
