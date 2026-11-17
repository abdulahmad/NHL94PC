;	Segment build for pc/input/pad.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
VectorToDir8		equ	0x89
StickPresent		equ	0x51E
PadTickCount		equ	0x522
PadRepeatOn		equ	0x524
PadRepeatStep		equ	0x526
PadRepeatDelay		equ	0x528
PadRepeatTimer		equ	0x52A
PadStates		equ	0x52C
PadStates2		equ	0x52D
HotKeyPending		equ	0x52E
KeyPadMap		equ	0x530
ImulRegs		equ	0x9CA
SsIsDs		equ	0xE11
PollSticks		equ	0x1120
KeyDown		equ	0x16C1
MousePosFn		equ	0x6418
MouseX		equ	0x6422
MouseY		equ	0x6424
MouseBtn		equ	0x6426
PadStatePtr		equ	0xB06A
%include "pc/input/pad.asm"
