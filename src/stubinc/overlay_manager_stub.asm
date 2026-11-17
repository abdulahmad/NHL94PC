;	Segment build for lib/rtlink/overlay_manager.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
RtlSectionHook		equ	0x3
RtlWriteHex		equ	0x5
RtlFileAdjust		equ	0x35
RtlErrorSlot		equ	0x4A
RtlSaveVectors		equ	0xCF
RtlSetHandler		equ	0xF4
RtlAfterFiles		equ	0x1C9
RtlBeforeClose		equ	0x224
RtlFindFile		equ	0x2FD
RtlExePath		equ	0x443
MscStartup		equ	0x4CA
%include "lib/rtlink/overlay_manager.asm"
