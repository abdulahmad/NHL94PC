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
DriverCount		equ	0x84C6
DriverName		equ	0x8500
DriverServiceIdx		equ	0x8502
DrvTableName		equ	0x8FCE
DrvTableSeg		equ	0x8FD0
DrvTableInit		equ	0x8FD6
DrvTableCall04		equ	0x8FDA
DrvTableCall08		equ	0x8FDE
DrvTableShutdown		equ	0x8FE2
DrvTableCall10		equ	0x8FE6
DrvTableService		equ	0x8FEA
DrvTableNeedsService		equ	0x8FEE
DrvTableLoadBank		equ	0x8FF2
DrvTableSendMidi		equ	0x9002
DrvTablePlaySample		equ	0x900A
DriverTypes		equ	0xE084
DriverEntrySeg		equ	0xE086
%include "seg/seg051.asm"
