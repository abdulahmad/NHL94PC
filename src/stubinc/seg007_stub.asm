;	Segment build for seg/seg007.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F017_0089		equ	0x89
ImulRegs		equ	0x9CA
SsIsDs		equ	0xE11
PollSticks		equ	0x1120
KeyDown		equ	0x16C1
%include "seg/seg007.asm"
