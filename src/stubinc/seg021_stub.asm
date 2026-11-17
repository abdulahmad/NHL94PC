;	Segment build for seg/seg021.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F010_0006		equ	0x6
F014_000A		equ	0xA
F014_0032		equ	0x32
F014_005A		equ	0x5A
F014_00B4		equ	0xB4
F008_042A		equ	0x42A
F008_0532		equ	0x532
F050_0BC6		equ	0xBC6
F050_0FD4		equ	0xFD4
_rand		equ	0x1012
F050_11BA		equ	0x11BA
F050_1226		equ	0x1226
F008_128A		equ	0x128A
F008_12EC		equ	0x12EC
F008_1362		equ	0x1362
F008_13C4		equ	0x13C4
F008_1426		equ	0x1426
F008_1546		equ	0x1546
F008_16E2		equ	0x16E2
F008_17FA		equ	0x17FA
F008_191A		equ	0x191A
L1A84		equ	0x1A84
F008_1B3C		equ	0x1B3C
F008_1E44		equ	0x1E44
F008_2032		equ	0x2032
F008_22C0		equ	0x22C0
F008_2322		equ	0x2322
F008_2354		equ	0x2354
%include "seg/seg021.asm"
