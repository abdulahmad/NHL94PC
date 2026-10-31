;	Segment build for seg/seg002.asm. Labels defined in seg001.
	bits	16
	org	0x0
DGROUP		equ	0x45C9
LargestFree	equ	0x65A
AllocBytes	equ	0x67A
RoundSeg	equ	0x0ADA
CopyStrN	equ	0x0BAE
PathTail		equ	0xB78
FarToLinear	equ	0x92E
LinearToFarRegs	equ	0x959
EmsMapFrame	equ	0x192
CopyBytes	equ	0x968
%include "seg/seg002.asm"
