; Builds FADES7.OVL on its own: the outside labels it uses (written by tools/make_stubs.py), then the overlay.
        bits 16
%include "ovl/fades7_syms.inc"
%include "ovl/fades7.asm"
