;	Segment build for seg/seg049.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
DrvService		equ	0x1A8
EmsSaveMap		equ	0x1B9
DrvNeedsService		equ	0x1C0
EmsRestoreMap		equ	0x1D1
DrvSendMidi		equ	0x22E
g_0511		equ	0x511
g_05CF		equ	0x5CF
GetPatch		equ	0x87C
SsIsDs		equ	0xE11
_abs		equ	0xE6A
__aFldiv		equ	0x118C
__aFlshl		equ	0x1258
ReadFarDword		equ	0x1434
ReadFarWord		equ	0x144A
DGROUP		equ	0x45C9
g_846A		equ	0x846A
g_846C		equ	0x846C
g_84C6		equ	0x84C6
g_84C8		equ	0x84C8
g_84CA		equ	0x84CA
g_84CC		equ	0x84CC
g_84CE		equ	0x84CE
g_84F4		equ	0x84F4
g_84F6		equ	0x84F6
g_84F8		equ	0x84F8
g_84FA		equ	0x84FA
g_84FE		equ	0x84FE
g_8502		equ	0x8502
g_8D10		equ	0x8D10
g_8D12		equ	0x8D12
g_8F68		equ	0x8F68
g_8F69		equ	0x8F69
g_8F6A		equ	0x8F6A
g_8F80		equ	0x8F80
g_8F81		equ	0x8F81
g_8F82		equ	0x8F82
g_8F84		equ	0x8F84
g_8F86		equ	0x8F86
g_8F88		equ	0x8F88
g_8F8A		equ	0x8F8A
g_DF74		equ	0xDF74
g_DF75		equ	0xDF75
%include "seg/seg049.asm"
