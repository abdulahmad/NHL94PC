;	Segment build for seg/seg037.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F039_0002		equ	0x2
F035_000C		equ	0xC
F028_0048		equ	0x48
F028_00B9		equ	0xB9
F028_0136		equ	0x136
F038_019C		equ	0x19C
F028_01A6		equ	0x1A6
F028_075A		equ	0x75A
SaveCharTab		equ	0xC7A
LoadCharTab		equ	0xC9C
UseCharSeg		equ	0xCB8
JoyNibble		equ	0x10E1
PollSticks		equ	0x1120
LargestGap		equ	0x1396
InitStick1		equ	0x1405
InitStick2		equ	0x1423
ReadKey		equ	0x16D3
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
F028_3A59		equ	0x3A59
F028_4262		equ	0x4262
%include "seg/seg037.asm"
