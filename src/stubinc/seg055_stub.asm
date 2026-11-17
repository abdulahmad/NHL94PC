;	Segment build for seg/seg055.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
CopyFar		equ	0x276
FindUnlink		equ	0x99A
NameBase		equ	0xD2C
RecSize		equ	0x14EC
FileOpenArg		equ	0x2690
FileClose		equ	0x279D
ReadAtArg		equ	0x27AE
%include "seg/seg055.asm"
