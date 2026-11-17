;	Segment build for seg/seg026.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F028_000C		equ	0xC
F028_0136		equ	0x136
F028_01C6		equ	0x1C6
F028_0E85		equ	0xE85
%include "seg/seg026.asm"
