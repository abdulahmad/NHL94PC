;	Segment build for pc/assets/shape_size.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FindNearestColor.1		equ	0x4D
TableCount		equ	0xAEC
TableAt		equ	0xAF6
%include "pc/assets/shape_size.asm"
