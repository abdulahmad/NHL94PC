;	Segment build for seg/seg004.asm. Labels defined in seg000.
	bits	16
	org	0x0
_fmemchr	equ	0x135C
RetOnly		equ	0x1398
LongShlAt	equ	0x1270
CopyFar		equ	0x276
%include "seg/seg004.asm"
