;	Segment build for seg/seg005.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar		equ	0xC
EmsInit		equ	0xE7
HookCrit		equ	0x3E4
StickPresent		equ	0x51E
StickPresent2		equ	0x520
PadRepeatOn		equ	0x524
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
Pot1X		equ	0x75D6
Pot1Y		equ	0x75D8
Pot2X		equ	0x75DA
Pot2Y		equ	0x75DC
PotButtons		equ	0x75E0
DgroupSegA		equ	0x8B08
HeapSizeLo		equ	0xAE90
HeapSizeHi		equ	0xAE92
DialogData		equ	0xAE98
DialogDataSeg		equ	0xAE9A
MemBlock1Off		equ	0xAEB2
MemBlock1Seg		equ	0xAEB4
MemBlock2Off		equ	0xAEB6
MemBlock2Seg		equ	0xAEB8
MemBlock3Off		equ	0xAEBA
MemBlock3Seg		equ	0xAEBC
InputFlags		equ	0xAECE
%include "seg/seg005.asm"
