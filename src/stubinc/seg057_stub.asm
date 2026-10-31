;	Segment build for seg/seg057.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg057).
	bits	16
	org	0x0
%include "seg/seg057.asm"
