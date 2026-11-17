;	Segment build for front/pause_exit.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
FontTable		equ	0x0
DrawTextCenteredInWindow		equ	0x2
FindNearestColor		equ	0x2
DrawFrame		equ	0x4
FreeCanvas		equ	0xC
SetCanvas		equ	0x48
FillRect		equ	0x136
AllocCanvas		equ	0x19C
UseCurrentPage		equ	0x1A6
WaitAdd		equ	0x250
NullQuitHook		equ	0x3E2
DrawRawAt		equ	0x73D
SetCharPtr.regs		equ	0xC56
SaveCharTab		equ	0xC7A
LoadCharTab		equ	0xC9C
UseCharSeg		equ	0xCB8
GetBlockAt		equ	0x11DD
ReadKey		equ	0x16D3
SaveTextState		equ	0x19B2
LoadTextState		equ	0x19E1
SetCanvasClip		equ	0x46A8
MouseShowFn		equ	0x640C
MouseHideFn		equ	0x6410
MouseReadFn		equ	0x6414
MousePosFn		equ	0x6418
TickSkip		equ	0x6DB2
CurPage		equ	0x74DC
PageTable		equ	0x7570
PageTableSeg		equ	0x7572
BeforeDialogFn		equ	0x7642
AfterDialogFn		equ	0x7646
str_ExitToDosYN		equ	0x76A4
str_PausePressAnyKeyTo		equ	0x76B6
DgroupSegF		equ	0x8D0A
%include "front/pause_exit.asm"
