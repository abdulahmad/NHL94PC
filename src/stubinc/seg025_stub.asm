;	Segment build for seg/seg025.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullFar		equ	0xC
NullFar2		equ	0xE
InputQueueCount		equ	0x508
InputQueueHead		equ	0x50A
EventPending		equ	0xA3E
OvlThunk100		equ	0x23D7
InputEventDataSeg		equ	0x8B1E
%include "seg/seg025.asm"
