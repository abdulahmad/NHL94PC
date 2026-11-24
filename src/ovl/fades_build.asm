; Builds FADES.OVL on its own: the outside labels it uses (from tools/make_ovl_syms.py), then the overlay.
bits 16
%include "spa94.inc"
%include "structs94.inc"
%include "ovl/fades_syms.inc"
%include "ovl/fades.asm"
