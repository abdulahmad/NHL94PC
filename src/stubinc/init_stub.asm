;	Segment build for pc/input/init.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FlushInputEvents		equ	0x66
MousePosX		equ	0x516
MousePosY		equ	0x518
str_SecondsMsc		equ	0x5A2
InputInstalled		equ	0x8F6
MouseRangeX		equ	0x8F8
MouseRangeY		equ	0x8FA
str_Sav		equ	0x93A
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
HookKbd		equ	0x149E
MouseMove		equ	0x1B03
CursorY		equ	0xAFD2
HotKeyFn		equ	0xB08E
HotKeyFnSeg		equ	0xB090
%include "pc/input/init.asm"
