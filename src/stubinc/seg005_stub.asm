;	Segment build for seg/seg005.asm. The full build has these labels in seg000 and seg056.
	bits	16
	org	0x0
__aFldiv	equ	0x118C
_printf		equ	0x76E
_exit		equ	0x687
_dos_gettime	equ	0x1172
_srand		equ	0x1000
OvlThunk22	equ	0x20CB
OvlThunk23	equ	0x20D5
OvlThunk24	equ	0x20DF
OvlThunk25	equ	0x20E9
OvlThunk26	equ	0x20F3
OvlThunk27	equ	0x20FD
EmsInit		equ	0xE7
HookCrit	equ	0x3E4
FindFarMsg	equ	0x847
HookInt8	equ	0xCCA
AllocSlot	equ	0xD8C
InitStick1	equ	0x1405
InitStick2	equ	0x1423
%include "seg/seg005.asm"
