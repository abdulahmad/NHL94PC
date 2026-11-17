;	Segment build for seg/seg022.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F034_0013		equ	0x13
str_Que		equ	0x80
ClearClipRect		equ	0xB4
EmsMapFrame		equ	0x192
UseCurrentPage		equ	0x1A6
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
CopyPlane		equ	0x10A7
UseOtherPage		equ	0x118C
GetPage		equ	0x11B1
_fmemcpy		equ	0x12B8
SetStartPage		equ	0x1320
RawBase		equ	0x1532
ConPrint		equ	0x17CA
AllocCanvases		equ	0x3804
g_8B1C		equ	0x8B1C
g_B34E		equ	0xB34E
g_B350		equ	0xB350
g_B352		equ	0xB352
g_B354		equ	0xB354
g_B356		equ	0xB356
g_B358		equ	0xB358
g_B35A		equ	0xB35A
g_B35C		equ	0xB35C
%include "seg/seg022.asm"
