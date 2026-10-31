;	Segment build for overlay/ovl_05000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py ovl_05000).
	bits	16
	org	0x25047
%include "overlay/ovl_05000.asm"
