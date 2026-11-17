;	Segment build for seg/seg000.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullStartup4		equ	0x4
NullStartup6		equ	0x6
_main		equ	0x8
g_74DC		equ	0x74DC
g_8516		equ	0x8516
g_8518		equ	0x8518
g_851A		equ	0x851A
g_8542		equ	0x8542
g_8544		equ	0x8544
__psp		equ	0x8556
g_8558		equ	0x8558
_osfile		equ	0x855F
g_8573		equ	0x8573
g_8575		equ	0x8575
g_8577		equ	0x8577
g_8580		equ	0x8580
g_8581		equ	0x8581
g_8582		equ	0x8582
g_8586		equ	0x8586
g_858A		equ	0x858A
g_8694		equ	0x8694
g_8696		equ	0x8696
g_8698		equ	0x8698
g_86B2		equ	0x86B2
g_86B4		equ	0x86B4
g_880A		equ	0x880A
g_8871		equ	0x8871
g_8876		equ	0x8876
g_887A		equ	0x887A
g_8882		equ	0x8882
g_888A		equ	0x888A
g_8A1C		equ	0x8A1C
g_8A1E		equ	0x8A1E
g_8A20		equ	0x8A20
g_8ABA		equ	0x8ABA
g_8AE2		equ	0x8AE2
g_8AE4		equ	0x8AE4
g_8AE6		equ	0x8AE6
g_8AE8		equ	0x8AE8
g_8AEA		equ	0x8AEA
g_8AF4		equ	0x8AF4
g_8AF6		equ	0x8AF6
g_8AF8		equ	0x8AF8
g_8AFC		equ	0x8AFC
g_9096		equ	0x9096
g_9098		equ	0x9098
g_909A		equ	0x909A
g_909C		equ	0x909C
g_909E		equ	0x909E
g_90A8		equ	0x90A8
g_90A9		equ	0x90A9
g_90AA		equ	0x90AA
%include "seg/seg000.asm"
