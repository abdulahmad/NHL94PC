;	Segment build for seg/seg016.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F035_000C		equ	0xC
F028_0048		equ	0x48
F028_00B4		equ	0xB4
F038_019C		equ	0x19C
F026_0246		equ	0x246
TextWidthAll		equ	0xC0A
_sprintf		equ	0xD74
F028_13B0		equ	0x13B0
_fstrlen		equ	0x13DA
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
%include "seg/seg016.asm"
