; The SPA number (word offset in the SPA table) of a sequence label of src/data/dgroup.asm. Overlay and segment builds get SPAlist and the labels from their syms/stub equates.
%define SPAno(name) (((name) - SPAlist) >> 1)
