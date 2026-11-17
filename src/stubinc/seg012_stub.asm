;	Segment build for seg/seg012.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F025_000E		equ	0xE
ReadCallCount		equ	0x1A0E
g_B08E		equ	0xB08E
%include "seg/seg012.asm"
