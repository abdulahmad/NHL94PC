;	Segment build for seg/seg019.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F032_0002		equ	0x2
F033_0008		equ	0x8
BuildPathFar		equ	0x3E
FindFarMsg		equ	0x847
FindUnlink		equ	0x99A
F028_344C		equ	0x344C
%include "seg/seg019.asm"
