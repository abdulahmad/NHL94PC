;	Segment build for lib/eaclib/seq_events.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
DrvService		equ	0x1A8
EmsSaveMap		equ	0x1B9
DrvNeedsService		equ	0x1C0
EmsRestoreMap		equ	0x1D1
MergeRemapTables.copy		equ	0x1F7
DrvSendMidi		equ	0x22E
GetPatch		equ	0x87C
SsIsDs		equ	0xE11
_abs		equ	0xE6A
__aFldiv		equ	0x118C
__aFlshl		equ	0x1258
ReadFarDword		equ	0x1434
ReadFarWord		equ	0x144A
DGROUP		equ	0x45C9
SeqTickCount		equ	0x846A
SeqBusy		equ	0x846C
DriverCount		equ	0x84C6
TrackSlots		equ	0x84C8
TrackSlotsSeg		equ	0x84CA
Voices		equ	0x84CC
VoicesSeg		equ	0x84CE
SeqLock		equ	0x84F4
MidiQueueLen		equ	0x84F6
MidiQueueBusy		equ	0x84F8
TracksMuted		equ	0x84FA
MusicEnabled		equ	0x84FE
DriverServiceIdx		equ	0x8502
WorkBufferSeg		equ	0x8D10
WorkBufferSeg2		equ	0x8D12
MidiMsg		equ	0x8F68
MidiMsg1		equ	0x8F69
MidiMsg2		equ	0x8F6A
SeqEmsMap		equ	0x8F74
MidiEvent		equ	0x8F7C
MidiEvCmd		equ	0x8F80
MidiEvData		equ	0x8F81
MidiEvValue		equ	0x8F82
MidiEvLength		equ	0x8F86
MidiNextEvent		equ	0x8F88
SysexBuffer		equ	0xB96E
ChannelSetup		equ	0xBB6F
MidiQueue		equ	0xDF74
MidiQueue1		equ	0xDF75
%include "lib/eaclib/seq_events.asm"
