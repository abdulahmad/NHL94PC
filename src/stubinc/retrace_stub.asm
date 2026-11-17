;	Segment build for pc/video/retrace.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
BlankBit		equ	0x0
DrawChar		equ	0xE85
_disable		equ	0x1142
_enable		equ	0x1170
WaitRetraceCount		equ	0x3406
WaitRetraceStart		equ	0x3499
RetraceWait		equ	0x7670
RetraceCount		equ	0xDF72
%include "pc/video/retrace.asm"
