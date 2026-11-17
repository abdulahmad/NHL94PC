;	Segment build for pc/video/shade_table.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
Mul16k.regs		equ	0x28C6
PaletteFlagsSeg		equ	0x8D0C
PaletteFlagsSeg2		equ	0x8D0E
ShadeTableOff		equ	0x8F56
ShadeTableSeg		equ	0x8F58
ShadeFactorR		equ	0x8F5A
ShadeFactorG		equ	0x8F5C
ShadeFactorB		equ	0x8F5E
ShadeR		equ	0x8F60
ShadeG		equ	0x8F62
ShadeB		equ	0x8F64
ShadeGrey		equ	0x8F66
%include "pc/video/shade_table.asm"
