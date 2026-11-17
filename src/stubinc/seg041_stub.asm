;	Segment build for seg/seg041.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F027_0002		equ	0x2
F044_0002		equ	0x2
F029_0004		equ	0x4
F035_000C		equ	0xC
F028_0048		equ	0x48
F028_0136		equ	0x136
F038_019C		equ	0x19C
F028_01A6		equ	0x1A6
WaitAdd		equ	0x250
F022_03E2		equ	0x3E2
F028_073D		equ	0x73D
SaveCharTab		equ	0xC7A
LoadCharTab		equ	0xC9C
UseCharSeg		equ	0xCB8
F028_11DD		equ	0x11DD
ReadKey		equ	0x16D3
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
F028_46A8		equ	0x46A8
%include "seg/seg041.asm"
