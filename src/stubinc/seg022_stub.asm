;	Segment build for seg/seg022.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F034_0013		equ	0x13
F028_00B4		equ	0xB4
EmsMapFrame		equ	0x192
F028_01A6		equ	0x1A6
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
F028_10A7		equ	0x10A7
F028_118C		equ	0x118C
F028_11B1		equ	0x11B1
_fmemcpy		equ	0x12B8
F028_1320		equ	0x1320
RawBase		equ	0x1532
ConPrint		equ	0x17CA
F028_3804		equ	0x3804
%include "seg/seg022.asm"
