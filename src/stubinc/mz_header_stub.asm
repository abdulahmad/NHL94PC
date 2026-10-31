;	Segment build for header/mz_header.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py mz_header).
	bits	16
	org	0x0
; Outside addresses, read from the retail EXE. Equates only (the full build has the labels).
__astart	equ	0x82F
%include "header/mz_header.asm"
