; Builds GAME.OVL on its own: the outside labels it uses (written by tools/make_stubs.py), then the overlay.
bits 16
%include "ovl/game_syms.inc"
%include "ovl/game.asm"
