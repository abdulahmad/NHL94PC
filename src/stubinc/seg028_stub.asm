;	Segment build for seg/seg028.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
F040_000C		equ	0xC
F034_0030		equ	0x30
F042_0134		equ	0x134
F022_03E4		equ	0x3E4
TableAt		equ	0xAF6
LineClip		equ	0x1F0E
SaveMode		equ	0x3338
g_6406		equ	0x6406
WantText		equ	0x640A
g_743E		equ	0x743E
g_743F		equ	0x743F
g_7440		equ	0x7440
g_7441		equ	0x7441
g_7442		equ	0x7442
g_7444		equ	0x7444
g_74DC		equ	0x74DC
g_74DE		equ	0x74DE
g_74E4		equ	0x74E4
g_74EC		equ	0x74EC
g_74EE		equ	0x74EE
g_74F0		equ	0x74F0
g_74F2		equ	0x74F2
g_74F4		equ	0x74F4
g_74FC		equ	0x74FC
g_74FE		equ	0x74FE
g_756C		equ	0x756C
g_7570		equ	0x7570
g_7572		equ	0x7572
g_7580		equ	0x7580
g_7582		equ	0x7582
g_7584		equ	0x7584
Cpu286		equ	0x763A
g_7664		equ	0x7664
g_7665		equ	0x7665
g_7666		equ	0x7666
g_7670		equ	0x7670
HoldWord		equ	0x7672
g_7674		equ	0x7674
g_7679		equ	0x7679
g_767D		equ	0x767D
g_7681		equ	0x7681
g_7692		equ	0x7692
%include "seg/seg028.asm"
