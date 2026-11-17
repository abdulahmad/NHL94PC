;	Segment build for pc/assets/load_packed.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
InsertRec		equ	0x2EC
ResizeRec		equ	0x86A
FarToLinear		equ	0x92E
LinearToFarRegs		equ	0x959
LoadBlock		equ	0xAAA
MovePtr		equ	0xB10
CopyByName		equ	0xD58
__aFlshl		equ	0x1258
FileOpenArg		equ	0x2690
FileClose		equ	0x279D
ReadAtArg		equ	0x27AE
%include "pc/assets/load_packed.asm"
