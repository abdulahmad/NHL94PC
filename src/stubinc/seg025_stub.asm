;	Segment build for seg/seg025.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar		equ	0xC
F011_000E		equ	0xE
OvlThunk100		equ	0x23D7
%include "seg/seg025.asm"
