;	Segment build for seg/seg037.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F039_0002		equ	0x2
F035_000C		equ	0xC
SetCanvas		equ	0x48
ClearClipRectColor		equ	0xB9
FillRect		equ	0x136
F038_019C		equ	0x19C
UseCurrentPage		equ	0x1A6
DrawRawBody		equ	0x75A
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
SetClipRectPlanes		equ	0x3A59
CopyPlanesRect		equ	0x4262
TickSkip		equ	0x6DB2
g_6F10		equ	0x6F10
g_6F22		equ	0x6F22
str_LeftJoystick		equ	0x6FDB
str_RightJoystick		equ	0x6FE9
JoyOn		equ	0x7308
g_7642		equ	0x7642
g_7646		equ	0x7646
g_8D06		equ	0x8D06
%include "seg/seg037.asm"
