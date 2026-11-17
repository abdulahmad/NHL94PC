;	Segment build for seg/seg007.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F017_0089		equ	0x89
g_051E		equ	0x51E
g_0522		equ	0x522
g_0524		equ	0x524
g_0526		equ	0x526
g_0528		equ	0x528
g_052A		equ	0x52A
g_052C		equ	0x52C
g_052D		equ	0x52D
g_052E		equ	0x52E
g_0530		equ	0x530
ImulRegs		equ	0x9CA
SsIsDs		equ	0xE11
PollSticks		equ	0x1120
KeyDown		equ	0x16C1
g_6418		equ	0x6418
MouseX		equ	0x6422
MouseY		equ	0x6424
MouseBtn		equ	0x6426
g_B06A		equ	0xB06A
%include "seg/seg007.asm"
