;	Segment build for front/db_descriptor.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
exhstate		equ	0x0
UseDbDescriptorTail.1		equ	0x4
postate		equ	0x62
DbSaveMode		equ	0x1B4
%include "front/db_descriptor.asm"
