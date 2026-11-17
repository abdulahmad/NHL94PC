; Builds FADES12.OVL on its own: the outside labels it uses (written by tools/make_stubs.py), then the overlay.
bits 16
%include "ovl/fades12_syms.inc"
%include "ovl/fades12.asm"
