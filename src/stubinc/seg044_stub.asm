;	Segment build for seg/seg044.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F028_0366		equ	0x366
__aFlshr		equ	0x12AC
%include "seg/seg044.asm"
