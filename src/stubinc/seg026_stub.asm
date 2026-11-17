;	Segment build for seg/seg026.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
DrawLine		equ	0xC
FillRect		equ	0x136
DrawText		equ	0x1C6
g_050C		equ	0x50C
g_0510		equ	0x510
g_0512		equ	0x512
g_0514		equ	0x514
DrawChar		equ	0xE85
DGROUP		equ	0x45C9
%include "seg/seg026.asm"
