;	Segment build for seg/seg032.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
EmsMapFrame		equ	0x192
InsertRec		equ	0x2EC
CopyByName		equ	0xD58
RawBase		equ	0x1532
FileOpenArg		equ	0x2690
FileClose		equ	0x279D
ReadAtArg		equ	0x27AE
%include "seg/seg032.asm"
