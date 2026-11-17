; Builds FADES.OVL on its own: the outside labels it uses (from tools/make_stubs.py), then the overlay.
bits 16
%include "ovl/fades_syms.inc"
%include "ovl/fades.asm"
