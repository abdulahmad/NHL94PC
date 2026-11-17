;	Segment build for seg/seg009.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F025_0066		equ	0x66
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
HookKbd		equ	0x149E
MouseMove		equ	0x1B03
%include "seg/seg009.asm"
