;	Segment build for pc/sound/midi.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
SaveGameNameDialog.13		equ	0x78D
QueueMidiBytes		equ	0x934
%include "pc/sound/midi.asm"
