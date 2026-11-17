;	Segment build for front/team_palettes.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
DgroupStart		equ	0x0
LoadRawHeader		equ	0x2
LoadPackedHeader		equ	0x8
BuildPathFar		equ	0x3E
FindFarMsg		equ	0x847
FindUnlink		equ	0x99A
DivideFault		equ	0x9C4
str_HomepalsBin		equ	0x9C6
str_AwaypalsBin		equ	0x9D3
str_Rinkpal		equ	0x9E0
str_Pal		equ	0x9E8
TeamPalette768		equ	0xA8E
str_Qpp		equ	0xBD0
SetPaletteFar		equ	0x344C
DGROUP		equ	0x45C9
TeamPalette1		equ	0xB0C4
TeamPalette2		equ	0xB1C4
%include "front/team_palettes.asm"
