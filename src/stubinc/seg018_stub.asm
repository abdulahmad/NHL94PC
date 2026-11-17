;	Segment build for seg/seg018.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
OnexitThunk		equ	0x4AE
g_09AC		equ	0x9AC
g_09BC		equ	0x9BC
g_09BE		equ	0x9BE
%include "seg/seg018.asm"
