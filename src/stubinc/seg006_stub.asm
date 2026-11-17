;	Segment build for seg/seg006.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
g_0508		equ	0x508
g_050C		equ	0x50C
g_050E		equ	0x50E
g_0510		equ	0x510
g_0512		equ	0x512
g_0514		equ	0x514
g_0516		equ	0x516
g_0518		equ	0x518
SsIsDs		equ	0xE11
PollSticks		equ	0x1120
KeyDown		equ	0x16C1
KeyJump		equ	0x16EB
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
g_AECE		equ	0xAECE
g_AED0		equ	0xAED0
g_AFD0		equ	0xAFD0
g_AFD2		equ	0xAFD2
%include "seg/seg006.asm"
