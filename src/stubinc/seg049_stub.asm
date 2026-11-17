;	Segment build for seg/seg049.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F051_01A8		equ	0x1A8
EmsSaveMap		equ	0x1B9
F051_01C0		equ	0x1C0
EmsRestoreMap		equ	0x1D1
F051_022E		equ	0x22E
F050_087C		equ	0x87C
SsIsDs		equ	0xE11
_abs		equ	0xE6A
__aFldiv		equ	0x118C
__aFlshl		equ	0x1258
F050_1434		equ	0x1434
F050_144A		equ	0x144A
%include "seg/seg049.asm"
