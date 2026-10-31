;	Segment build for overlay/ovl_18000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py ovl_18000).
	bits	16
	org	0x38047
%include "overlay/ovl_18000.asm"
