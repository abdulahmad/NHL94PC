;	Segment build for pc/heap_wrappers.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
MakeChain		equ	0x8
InsertRec		equ	0x2EC
FatalError		equ	0x3E4
ResizeRec		equ	0x86A
FindRec		equ	0x944
CpuProbe		equ	0x28DA
str_ThisProgramRequiresAn80286		equ	0x64AE
Cpu286		equ	0x763A
%include "pc/heap_wrappers.asm"
