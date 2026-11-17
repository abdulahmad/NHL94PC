;	Segment build for seg/seg048.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
g_8D0C		equ	0x8D0C
g_8D0E		equ	0x8D0E
g_8F56		equ	0x8F56
g_8F58		equ	0x8F58
g_8F5A		equ	0x8F5A
g_8F5C		equ	0x8F5C
g_8F5E		equ	0x8F5E
g_8F60		equ	0x8F60
g_8F62		equ	0x8F62
g_8F64		equ	0x8F64
g_8F66		equ	0x8F66
%include "seg/seg048.asm"
