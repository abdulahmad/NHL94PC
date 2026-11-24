; Builds FADES7.OVL on its own: the outside labels it uses (from tools/make_ovl_syms.py), then the overlay.
bits 16
%include "spa94.inc"
%include "structs94.inc"
%include "ovl/fades7_syms.inc"
%include "ovl/fades7.asm"
