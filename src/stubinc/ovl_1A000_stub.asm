;	Segment build for overlay/ovl_1A000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py ovl_1A000).
	bits	16
	org	0x3A047
%include "overlay/ovl_1A000.asm"
