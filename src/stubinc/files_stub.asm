;	Segment build for pc/files.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
_lseek		equ	0x7CC
QueueMidiBytes		equ	0x934
_rmdir		equ	0x104E
_unlink		equ	0x1076
_dos_close		equ	0x1084
_dos_creat		equ	0x1099
_dos_findnext		equ	0x10BC
_dos_findfirst		equ	0x10C7
_dos_open		equ	0x10FA
_dos_read		equ	0x1112
_dos_write		equ	0x1119
_fstrcpy		equ	0x13DA
_fstrcat		equ	0x1410
%include "pc/files.asm"
