;	Segment build for seg/seg051.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F033_001A		equ	0x1A
EmsMapFrame		equ	0x192
F052_0272		equ	0x272
FarToLinear		equ	0x92E
LinearToFarRegs		equ	0x959
FindUnlink		equ	0x99A
_sprintf		equ	0xD74
RecBase		equ	0x1508
RawBase		equ	0x1532
%include "seg/seg051.asm"
