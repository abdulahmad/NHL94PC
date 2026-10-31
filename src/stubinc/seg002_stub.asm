;	Segment build for seg/seg002.asm. Labels defined in seg001.
	bits	16
	org	0x0
LargestFree	equ	0x65A
AllocBytes	equ	0x67A
RoundSeg	equ	0x0ADA
CopyStrN	equ	0x0BAE
%include "seg/seg002.asm"
