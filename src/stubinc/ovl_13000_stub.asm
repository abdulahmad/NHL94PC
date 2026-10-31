;	Segment build for overlay/ovl_13000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py ovl_13000).
	bits	16
	org	0x33047
%include "overlay/ovl_13000.asm"
