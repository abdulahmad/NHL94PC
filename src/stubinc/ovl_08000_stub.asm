;	Segment build for overlay/ovl_08000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py ovl_08000).
	bits	16
	org	0x28047
%include "overlay/ovl_08000.asm"
