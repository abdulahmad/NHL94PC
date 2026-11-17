;	Segment build for seg/seg009.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F025_0066		equ	0x66
str_Nyr		equ	0x70
g_0516		equ	0x516
g_0518		equ	0x518
str_SecondsMsc		equ	0x5A2
g_08F6		equ	0x8F6
g_08F8		equ	0x8F8
g_08FA		equ	0x8FA
str_Sav		equ	0x93A
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
HookKbd		equ	0x149E
MouseMove		equ	0x1B03
g_AFD2		equ	0xAFD2
g_B08E		equ	0xB08E
g_B090		equ	0xB090
%include "seg/seg009.asm"
