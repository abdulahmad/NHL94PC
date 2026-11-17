;	Segment build for seg/seg008.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F034_0013		equ	0x13
F034_0030		equ	0x30
F051_0178		equ	0x178
EmsMapFrame		equ	0x192
EmsSaveMap		equ	0x1B9
EmsRestoreMap		equ	0x1D1
F051_02A6		equ	0x2A6
__chkstk		equ	0x74A
_lseek		equ	0x7CC
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
CopyStrNFar		equ	0xBBC
LoadReport		equ	0xBD8
_strncpy		equ	0xCBA
_sprintf		equ	0xD74
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
SsIsDs		equ	0xE11
_dos_close		equ	0x1084
_dos_open		equ	0x10FA
_dos_read		equ	0x1112
_fstrlen		equ	0x13DA
_fmemmove		equ	0x14FA
RawBase		equ	0x1532
EmulatedFloat		equ	0x15C4
%include "seg/seg008.asm"
