;	Segment build for pc/divide_error.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
OnexitThunk		equ	0x4AE
Dir8Table		equ	0x9AC
OldInt0Seg		equ	0x9BC
OldInt0Off		equ	0x9BE
%include "pc/divide_error.asm"
