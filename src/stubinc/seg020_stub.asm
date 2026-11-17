;	Segment build for seg/seg020.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
TextWidthFar		equ	0x2
DrawLine		equ	0xC
GetInputEvent		equ	0xE
InputInit		equ	0xE
SetTextColors		equ	0x24
F034_0030		equ	0x30
InputShutdown		equ	0x4C
FlushInputEvents		equ	0x66
FillRect		equ	0x136
DrawShadowText		equ	0x166
UseCurrentPage		equ	0x1A6
DrawTextFar		equ	0x246
PutBlockAt		equ	0x4B5
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
GetBlockAt		equ	0x11DD
__aFlmul		equ	0x1226
KeyDown		equ	0x16C1
DrawRleTransAt		equ	0x1857
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
OvlThunk102		equ	0x23EB
g_6D4E		equ	0x6D4E
g_858D		equ	0x858D
g_B2CC		equ	0xB2CC
g_B2CE		equ	0xB2CE
g_B2D0		equ	0xB2D0
g_B2D2		equ	0xB2D2
g_B2D4		equ	0xB2D4
%include "seg/seg020.asm"
