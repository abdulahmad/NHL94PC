;	Segment build for seg/seg000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg000).
;	Calls out to seg005 are the NullStartup6, NullStartup4 and _main equates in seg/seg000.asm
;	(that segment is still incbin, so the full build cannot see real labels yet).
	bits	16
	org	0x0
%include "seg/seg000.asm"
