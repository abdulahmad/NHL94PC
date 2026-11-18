; Builds INIT.OVL on its own: the outside labels it uses (from tools/make_stubs.py), then the overlay.
bits 16
%include "spa94.inc"
%include "ovl/init_syms.inc"
%include "ovl/init.asm"
