;	Segment build for seg/seg001.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
_exit		equ	0x687
_sprintf		equ	0xD74
_onexit		equ	0xE78
DGROUP		equ	0x45C9
%include "seg/seg001.asm"
