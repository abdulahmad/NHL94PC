;	Segment build for seg/seg035.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
BufPtr		equ	0x2BC
F022_03E4		equ	0x3E4
FindUnlink		equ	0x99A
ChainIdx		equ	0xAE9C
%include "seg/seg035.asm"
