;	Segment build for pc/video/nearest_color.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FindNearestColorTail		equ	0x4
GetPaletteFar		equ	0x366
__aFlshr		equ	0x12AC
%include "pc/video/nearest_color.asm"
