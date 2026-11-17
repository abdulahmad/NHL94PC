;	Segment build for seg/seg013.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F032_0002		equ	0x2
F033_0008		equ	0x8
F025_000E		equ	0xE
F034_0030		equ	0x30
F015_003E		equ	0x3E
F025_0066		equ	0x66
F028_01A6		equ	0x1A6
g_01B4		equ	0x1B4
g_01B7		equ	0x1B7
F022_03E4		equ	0x3E4
F015_040C		equ	0x40C
F015_041E		equ	0x41E
F015_0496		equ	0x496
F028_04B5		equ	0x4B5
FileSizeMsg		equ	0x4EF
F015_051E		equ	0x51E
F028_073D		equ	0x73D
FindFarMsg		equ	0x847
str_GsummaryDb		equ	0x908
str_GsummaryDb_2		equ	0x914
str_GameSav		equ	0x92E
str_Sav		equ	0x93A
str_Db		equ	0x93F
str_Gsummary		equ	0x943
FindUnlink		equ	0x99A
F020_0A3C		equ	0xA3C
F028_0C45		equ	0xC45
F028_0E85		equ	0xE85
F020_0F22		equ	0xF22
F020_0FC8		equ	0xFC8
_dos_findfirst		equ	0x10C7
F028_11DD		equ	0x11DD
_fstrcpy		equ	0x13DA
ConPrint		equ	0x17CA
F028_1857		equ	0x1857
L1A84		equ	0x1A84
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
F028_1C71		equ	0x1C71
OvlThunk99		equ	0x23CD
OvlThunk100		equ	0x23D7
OvlThunk101		equ	0x23E1
OvlThunk102		equ	0x23EB
g_8B14		equ	0x8B14
g_8B16		equ	0x8B16
g_8B18		equ	0x8B18
%include "seg/seg013.asm"
