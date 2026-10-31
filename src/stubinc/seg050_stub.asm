;	Segment build for seg/seg050.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg050).
	bits	16
	org	0x0
%include "seg/seg050.asm"
