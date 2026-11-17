;	Segment build for pc/assets/load_asset.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
LoadAssetModeTail		equ	0x2
LoadAssetModeTail.1		equ	0x4
ShapeBankSize		equ	0x6
LoadAssetModeTail.2		equ	0x7
CopyBytesFar		equ	0x8
LargestShapeSize		equ	0xC
FileCanOpen		equ	0xE
AllocRecData0		equ	0x38
AskYesNoBox		equ	0x46
LoadRawMode		equ	0x7C
LoadPackedMode		equ	0x82
CopyFar		equ	0x276
InsertRec		equ	0x2EC
FatalError		equ	0x3E4
FindFar		equ	0x83E
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
TableCount		equ	0xAEC
TableAt		equ	0xAF6
MovePtr		equ	0xB10
TableStore		equ	0xB44
_strcpy		equ	0xC6C
CopyByName		equ	0xD58
_stricmp		equ	0xDCE
__aFlshl		equ	0x1258
ConPrint		equ	0x17CA
RemapShapeBank		equ	0x472A
ConvertShapeBank		equ	0x4782
str_Vgabuf		equ	0x76D6
AssetExtList		equ	0x76DE
IdentityRemap		equ	0x76F2
str_Qns		equ	0x7730
str_Pns		equ	0x7735
str_Qvs		equ	0x773A
str_Pvs		equ	0x773F
str_Qes		equ	0x7744
str_Pes		equ	0x7749
str_Esh		equ	0x774E
str_Vsh		equ	0x7753
str_Mga		equ	0x7758
str_LoadshapeblockaNoMemoryForMcgatovga		equ	0x775D
str_LoadshapeblockaNoMemoryForMcgatovga_2		equ	0x7788
%include "pc/assets/load_asset.asm"
