;	Segment build for seg/seg043.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FileOpen		equ	0x269E
FileClose		equ	0x279D
%include "seg/seg043.asm"
