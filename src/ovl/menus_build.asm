; Builds MENUS.OVL on its own: the outside labels it uses (from tools/make_ovl_syms.py), then the overlay.
bits 16
%include "spa94.inc"
%include "structs94.inc"
%include "ovl/menus_syms.inc"
%include "ovl/menus.asm"
