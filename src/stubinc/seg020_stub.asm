;	Segment build for seg/seg020.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F016_0002		equ	0x2
F028_000C		equ	0xC
F025_000E		equ	0xE
F009_000E		equ	0xE
F016_0024		equ	0x24
F034_0030		equ	0x30
F009_004C		equ	0x4C
F025_0066		equ	0x66
F028_0136		equ	0x136
F016_0166		equ	0x166
F028_01A6		equ	0x1A6
F026_0246		equ	0x246
F028_04B5		equ	0x4B5
FindUnlink		equ	0x99A
g_09EE		equ	0x9EE
g_09F0		equ	0x9F0
g_09F2		equ	0x9F2
g_09F4		equ	0x9F4
g_09F6		equ	0x9F6
g_09FA		equ	0x9FA
g_09FC		equ	0x9FC
JumpAhead		equ	0xCE2
__aFldiv		equ	0x118C
F028_11DD		equ	0x11DD
__aFlmul		equ	0x1226
KeyDown		equ	0x16C1
F028_1857		equ	0x1857
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
OvlThunk102		equ	0x23EB
g_6D4E		equ	0x6D4E
g_B2CC		equ	0xB2CC
g_B2CE		equ	0xB2CE
g_B2D0		equ	0xB2D0
g_B2D2		equ	0xB2D2
g_B2D4		equ	0xB2D4
%include "seg/seg020.asm"
