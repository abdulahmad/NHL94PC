;	Segment build for seg/seg005.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar		equ	0xC
EmsInit		equ	0xE7
HookCrit		equ	0x3E4
g_051E		equ	0x51E
g_0520		equ	0x520
g_0524		equ	0x524
_exit		equ	0x687
_printf		equ	0x76E
FindFarMsg		equ	0x847
HookInt8		equ	0xCCA
AllocSlot		equ	0xD8C
_srand		equ	0x1000
_dos_gettime		equ	0x1172
__aFldiv		equ	0x118C
InitStick1		equ	0x1405
InitStick2		equ	0x1423
MouseRead		equ	0x1B34
MouseOpen		equ	0x1C7B
ReadPots		equ	0x1D72
OvlThunk22		equ	0x20CB
OvlThunk23		equ	0x20D5
OvlThunk24		equ	0x20DF
OvlThunk25		equ	0x20E9
OvlThunk26		equ	0x20F3
OvlThunk27		equ	0x20FD
g_75D6		equ	0x75D6
g_75D8		equ	0x75D8
g_75DA		equ	0x75DA
g_75DC		equ	0x75DC
g_75E0		equ	0x75E0
g_8B08		equ	0x8B08
g_AE90		equ	0xAE90
g_AE92		equ	0xAE92
g_AE98		equ	0xAE98
g_AE9A		equ	0xAE9A
g_AEB2		equ	0xAEB2
g_AEB4		equ	0xAEB4
g_AEB6		equ	0xAEB6
g_AEB8		equ	0xAEB8
g_AEBA		equ	0xAEBA
g_AEBC		equ	0xAEBC
g_AECE		equ	0xAECE
%include "seg/seg005.asm"
