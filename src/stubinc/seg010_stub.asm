;	Segment build for seg/seg010.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
MulRegs		equ	0x9D5
g_2A00		equ	0x2A00
g_2A02		equ	0x2A02
%include "seg/seg010.asm"
