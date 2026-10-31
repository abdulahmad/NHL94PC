;	Segment build for seg/seg056.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg056).
	bits	16
	org	0x0
; seg000 and seg058 are still incbin, so the far targets in this segment are equates.
MscStartup	equ	0x04CA			; seg000, Microsoft C startup
RtlSectionHook	equ	3			; seg058
RtlWriteText	equ	5			; seg058
RtlSaveVectors	equ	0xCF			; seg058
RtlSetHandler	equ	0xF4			; seg058
RtlAfterFiles	equ	0x1C9			; seg058
RtlBeforeClose	equ	0x224			; seg058
RtlFindFile	equ	0x2FD			; seg058
RtlExePath	equ	0x443			; seg058
RtlFileAdjust	equ	0x35			; seg058
RtlErrorSlot	equ	0x4A			; seg058
%include "seg/seg056.asm"
