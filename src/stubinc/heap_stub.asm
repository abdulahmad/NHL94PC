;	Segment build for pc/heap.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
EmsMapFrame		equ	0x192
EmsOutPtr		equ	0x25C
BufCount		equ	0x2BA
BufPtr		equ	0x2BC
RecSeq		equ	0x2BE
CopyParas		equ	0x32C
CopyParasDown		equ	0x374
LargestFree		equ	0x65A
AllocBytes		equ	0x67A
FarToLinear		equ	0x92E
LinearToFarRegs		equ	0x959
CopyBytes		equ	0x968
RoundSeg		equ	0xADA
PathTail		equ	0xB78
PathTailFar		equ	0xB82
CopyStrN		equ	0xBAE
StrnDiff		equ	0xBD7
DGROUP		equ	0x45C9
BlockEnd		equ	0x63F8
BlockSeg		equ	0x63FC
ChainIdx		equ	0xAE9C
ChainPtr		equ	0xAE9E
%include "pc/heap.asm"
