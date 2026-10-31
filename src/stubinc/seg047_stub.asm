;	Segment build for seg/seg047.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg047).
	bits	16
	org	0x0
%include "seg/seg047.asm"
