;	Segment build for seg/seg056.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py seg056).
	bits	16
	org	0x0
; seg058 is still incbin, so those far targets are equates. MscStartup is a label in the
; full build (seg000); this equate is only for building seg056 on its own.
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
