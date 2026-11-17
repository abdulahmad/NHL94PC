;	Segment build for seg/seg039.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
TextWidthAll		equ	0xC0A
DgroupSegE		equ	0x8D08
%include "seg/seg039.asm"
