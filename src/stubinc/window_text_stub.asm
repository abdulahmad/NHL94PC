;	Segment build for front/window_text.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
TextWidthAll		equ	0xC0A
ClipLeftX		equ	0x74FC
ClipRightX		equ	0x74FE
DgroupSegC		equ	0x8D04
%include "front/window_text.asm"
