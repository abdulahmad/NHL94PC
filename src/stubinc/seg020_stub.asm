;	Segment build for seg/seg020.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
TextWidthFar		equ	0x2
DrawLine		equ	0xC
GetInputEvent		equ	0xE
InputInit		equ	0xE
SetTextColors		equ	0x24
AllocRecData		equ	0x30
InputShutdown		equ	0x4C
FlushInputEvents		equ	0x66
str_Philadelphia		equ	0x130
FillRect		equ	0x136
DrawShadowText		equ	0x166
UseCurrentPage		equ	0x1A6
DrawTextFar		equ	0x246
PutBlockAt		equ	0x4B5
FindUnlink		equ	0x99A
DialogBackColor		equ	0x9EE
DialogLightColor		equ	0x9F0
DialogDarkColor		equ	0x9F2
ItemTextColor		equ	0x9F4
ItemSelectColor		equ	0x9F6
SaveUnderOff		equ	0x9FA
SaveUnderSeg		equ	0x9FC
JumpAhead		equ	0xCE2
__aFldiv		equ	0x118C
GetBlockAt		equ	0x11DD
__aFlmul		equ	0x1226
KeyDown		equ	0x16C1
DrawRleTransAt		equ	0x1857
MouseMove		equ	0x1B03
MouseRead		equ	0x1B34
OvlThunk102		equ	0x23EB
FontPtr		equ	0x6D4E
CharTypes		equ	0x858D
ListDialogDataSeg		equ	0x8B1A
DialogData		equ	0xAE98
DialogDataSeg		equ	0xAE9A
HotKeyFn		equ	0xB08E
BoxSaveX		equ	0xB2CC
BoxSaveY		equ	0xB2CE
YesNoText		equ	0xB2D0
YesNoTextSeg		equ	0xB2D2
MessageBoxSel		equ	0xB2D4
%include "seg/seg020.asm"
