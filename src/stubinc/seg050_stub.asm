;	Segment build for seg/seg050.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
LoadRawHeader		equ	0x2
AllocRecData		equ	0x30
SeqService		equ	0x3C
LoadRaw		equ	0x58
LoadFileCached		equ	0xA0
DrvStub1		equ	0x110
DrvShutdown		equ	0x178
EmsMapFrame		equ	0x192
DrvLoadBank		equ	0x1DC
SendController		equ	0x6C2
SendVoiceNoteOff		equ	0x792
SendPitchBend		equ	0x826
AllocVoice		equ	0x864
QueueMidiBytes		equ	0x934
FindUnlink		equ	0x99A
UnlinkRec		equ	0x9B2
SendProgramChange		equ	0xA00
_strcpy		equ	0xC6C
_sprintf		equ	0xD74
AllocSlot		equ	0xD8C
FreeSlot		equ	0xDC0
__aFlshl		equ	0x1258
_fmemcpy		equ	0x12B8
_fmemset		equ	0x1456
RawBase		equ	0x1532
DGROUP		equ	0x45C9
%include "seg/seg050.asm"
