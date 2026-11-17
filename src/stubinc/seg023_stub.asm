;	Segment build for seg/seg023.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
TextWidthFar		equ	0x2
_exit		equ	0x687
RetOnly		equ	0x1398
_fstrcpy		equ	0x13DA
_fstrcat		equ	0x1410
%include "seg/seg023.asm"
