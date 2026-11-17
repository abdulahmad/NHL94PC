;	Segment build for seg/seg050.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
LoadRawHeader		equ	0x2
AllocRecData		equ	0x30
F049_003C		equ	0x3C
LoadRaw		equ	0x58
F055_00A0		equ	0xA0
F051_0110		equ	0x110
F051_0178		equ	0x178
EmsMapFrame		equ	0x192
F051_01DC		equ	0x1DC
F049_06C2		equ	0x6C2
F049_0792		equ	0x792
F049_0826		equ	0x826
F049_0864		equ	0x864
F049_0934		equ	0x934
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
F049_0A00		equ	0xA00
_strcpy		equ	0xC6C
_sprintf		equ	0xD74
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
__aFlshl		equ	0x1258
_fmemcpy		equ	0x12B8
_fmemset		equ	0x1456
RawBase		equ	0x1532
DGROUP		equ	0x45C9
%include "seg/seg050.asm"
