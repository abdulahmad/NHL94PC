;	Segment build for seg/seg000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg000).
;	seg005 defines these. The full build uses those labels; this build supplies the offsets.
	bits	16
	org	0x0
NullStartup4	equ	4
NullStartup6	equ	6
_main		equ	8
%include "seg/seg000.asm"
