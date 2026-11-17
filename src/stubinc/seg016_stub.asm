;	Segment build for seg/seg016.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FreeCanvas		equ	0xC
SetCanvas		equ	0x48
ClearClipRect		equ	0xB4
AllocCanvas		equ	0x19C
DrawTextFar		equ	0x246
g_0998		equ	0x998
g_099A		equ	0x99A
g_099C		equ	0x99C
g_09A4		equ	0x9A4
TextWidthAll		equ	0xC0A
_sprintf		equ	0xD74
DrawRawTransAt		equ	0x13B0
_fstrcpy		equ	0x13DA
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
g_6D4E		equ	0x6D4E
%include "seg/seg016.asm"
