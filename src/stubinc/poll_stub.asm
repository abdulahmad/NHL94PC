;	Segment build for pc/input/poll.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
ReadKeyEventHit		equ	0x0
MscRuntimeStart		equ	0x0
InputQueueCount		equ	0x508
InputQueueTail		equ	0x50C
PollCountdown		equ	0x50E
MouseEnabled		equ	0x510
StickEnabled		equ	0x512
KeysEnabled		equ	0x514
MousePosX		equ	0x516
MousePosY		equ	0x518
_exit		equ	0x687
SsIsDs		equ	0xE11
PollSticks		equ	0x1120
KeyDown		equ	0x16C1
KeyJump		equ	0x16EB
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
InputFlags		equ	0xAECE
InputQueue		equ	0xAED0
CursorX		equ	0xAFD0
CursorY		equ	0xAFD2
%include "pc/input/poll.asm"
