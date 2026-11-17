;	Segment build for seg/seg031.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
Atan2		equ	0x1DD4
FillFlag0		equ	0x2989
AngleTab		equ	0x32F8
%include "seg/seg031.asm"
