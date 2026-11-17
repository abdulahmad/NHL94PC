;	Segment build for seg/seg028.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F040_000C		equ	0xC
F034_0030		equ	0x30
F042_0134		equ	0x134
F022_03E4		equ	0x3E4
TableAt		equ	0xAF6
LineClip		equ	0x1F0E
SaveMode		equ	0x3338
%include "seg/seg028.asm"
