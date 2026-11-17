; Builds FADES9.OVL on its own: the outside labels it uses (written by tools/make_stubs.py), then the overlay.
bits 16
%include "ovl/fades9_syms.inc"
%include "ovl/fades9.asm"
