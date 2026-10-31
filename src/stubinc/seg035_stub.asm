;	Segment build for seg/seg035.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg035).
	bits	16
	org	0x0
%include "seg/seg035.asm"
