;	Segment build for lib/fp_emulator.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FpErrHandler		equ	0x0
Fp87Present		equ	0x4
FpUserCw		equ	0x6
FpUserStatus		equ	0x8
FpEmuCw		equ	0xA
FpEmuStatus		equ	0xC
FpStackBase		equ	0xE
FpStackTop		equ	0x10
FpStackLimit		equ	0x12
FpMachineMode		equ	0x14
FpOpStatus		equ	0x16
FpTemp		equ	0x1A
FpSavedVectors		equ	0x1E
FpTemp0		equ	0x4A
FpSavedSs		equ	0x56
FpProbeWord		equ	0x58
FpTemp1		equ	0x5A
FpTemp2		equ	0x66
FpTemp3		equ	0x72
FpTemp4		equ	0x7E
FpTemp5		equ	0x8A
FpResultPtr		equ	0x96
FpDivisor		equ	0x98
FpRemExp		equ	0xA0
FpRemFlag		equ	0xA2
FpSignalMode		equ	0xA4
FpNextByte		equ	0xA6
FpExitVector		equ	0xA7
StoreOne		equ	0x28AE
StoreZero		equ	0x28C5
RetPop10		equ	0x28DA
StoreWord		equ	0x28E3
RetPop2		equ	0x28F9
WriteFar		equ	0x2902
%include "lib/fp_emulator.asm"
