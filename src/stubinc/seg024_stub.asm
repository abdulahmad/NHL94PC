;	Segment build for seg/seg024.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg024).
	bits	16
	org	0x0
%include "seg/seg024.asm"
