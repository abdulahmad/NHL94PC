;	Segment build for seg/seg051.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
LoadPackedHeader0		equ	0x1A
EmsMapFrame		equ	0x192
LinkDriver		equ	0x272
FarToLinear		equ	0x92E
LinearToFarRegs		equ	0x959
FindUnlink		equ	0x99A
_sprintf		equ	0xD74
RecBase		equ	0x1508
RawBase		equ	0x1532
DGROUP		equ	0x45C9
str_CEaclibS		equ	0x849A
g_84C6		equ	0x84C6
g_8500		equ	0x8500
g_8502		equ	0x8502
g_8FCE		equ	0x8FCE
g_8FD0		equ	0x8FD0
g_8FD6		equ	0x8FD6
g_8FDA		equ	0x8FDA
g_8FDE		equ	0x8FDE
g_8FE2		equ	0x8FE2
g_8FE6		equ	0x8FE6
g_8FEA		equ	0x8FEA
g_8FEE		equ	0x8FEE
g_8FF2		equ	0x8FF2
g_9002		equ	0x9002
g_900A		equ	0x900A
g_E084		equ	0xE084
g_E086		equ	0xE086
%include "seg/seg051.asm"
