;	Segment build for seg/seg001.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg001).
	bits	16
	org	0x0
DGROUP		equ	0x45C9
_onexit		equ	0xE78
_exit		equ	0x687
_sprintf	equ	0xD74
%include "seg/seg001.asm"
