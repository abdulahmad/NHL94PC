;	Segment build for seg/seg042.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F046_0006		equ	0x6
F047_0008		equ	0x8
F045_000C		equ	0xC
F043_000E		equ	0xE
F034_0038		equ	0x38
F032_007C		equ	0x7C
F033_0082		equ	0x82
CopyFar		equ	0x276
InsertRec		equ	0x2EC
F022_03E4		equ	0x3E4
FindFar		equ	0x83E
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
TableCount		equ	0xAEC
TableAt		equ	0xAF6
MovePtr		equ	0xB10
TableStore		equ	0xB44
_strcpy		equ	0xC6C
CopyByName		equ	0xD58
_stricmp		equ	0xDCE
__aFlshl		equ	0x1258
ConPrint		equ	0x17CA
F028_472A		equ	0x472A
F028_4782		equ	0x4782
%include "seg/seg042.asm"
