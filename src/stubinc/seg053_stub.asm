;	Segment build for seg/seg053.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
CopyFar		equ	0x276
FarToLinear		equ	0x92E
FillFar		equ	0x1E56
%include "seg/seg053.asm"
