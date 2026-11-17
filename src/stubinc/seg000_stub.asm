;	Segment build for seg/seg000.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullStartup4		equ	0x4
NullStartup6		equ	0x6
_main		equ	0x8
__psp		equ	0x8556
_osfile		equ	0x855F
%include "seg/seg000.asm"
