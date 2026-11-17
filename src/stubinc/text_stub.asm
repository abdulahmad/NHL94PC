;	Segment build for pc/video/text.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FreeCanvas		equ	0xC
SetCanvas		equ	0x48
ClearClipRect		equ	0xB4
AllocCanvas		equ	0x19C
DrawTextFar		equ	0x246
TextColor		equ	0x998
ShadowColor		equ	0x99A
OutlineDx		equ	0x99C
OutlineDy		equ	0x9A4
TextWidthAll		equ	0xC0A
_sprintf		equ	0xD74
DrawRawTransAt		equ	0x13B0
_fstrcpy		equ	0x13DA
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
FontPtr		equ	0x6D4E
%include "pc/video/text.asm"
