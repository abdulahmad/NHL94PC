;	Segment build for seg/seg025.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar		equ	0xC
F011_000E		equ	0xE
g_0508		equ	0x508
g_050A		equ	0x50A
g_0A3E		equ	0xA3E
OvlThunk100		equ	0x23D7
g_8B1E		equ	0x8B1E
%include "seg/seg025.asm"
