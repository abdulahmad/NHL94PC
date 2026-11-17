;	Segment build for pc/video/save_planes.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
InsertRecWrap		equ	0x13
ClearClipRect		equ	0xB4
EmsMapFrame		equ	0x192
UseCurrentPage		equ	0x1A6
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
str_Plane0		equ	0xA1E
str_Plane1		equ	0xA26
str_Plane2		equ	0xA2E
str_Plane3		equ	0xA36
CopyPlane		equ	0x10A7
UseOtherPage		equ	0x118C
GetPage		equ	0x11B1
_fmemcpy		equ	0x12B8
SetStartPage		equ	0x1320
RawBase		equ	0x1532
ConPrint		equ	0x17CA
AllocCanvases		equ	0x3804
PageTable		equ	0x7570
DgroupSegB		equ	0x8B1C
VgaSave0Off		equ	0xB34E
VgaSave0Seg		equ	0xB350
VgaSave1Off		equ	0xB352
VgaSave1Seg		equ	0xB354
VgaSave2Off		equ	0xB356
VgaSave2Seg		equ	0xB358
VgaSave3Off		equ	0xB35A
VgaSave3Seg		equ	0xB35C
%include "pc/video/save_planes.asm"
