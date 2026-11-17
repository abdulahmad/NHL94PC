;	Segment build for seg/seg009.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FlushInputEvents		equ	0x66
g_0516		equ	0x516
g_0518		equ	0x518
str_SecondsMsc		equ	0x5A2
g_08F6		equ	0x8F6
g_08F8		equ	0x8F8
g_08FA		equ	0x8FA
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
HookKbd		equ	0x149E
MouseMove		equ	0x1B03
g_AFD2		equ	0xAFD2
g_B08E		equ	0xB08E
g_B090		equ	0xB090
%include "seg/seg009.asm"
