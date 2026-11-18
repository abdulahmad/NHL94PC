; The SPA number (word offset in the SPA table) of a sequence label of src/data/dgroup.asm. Overlay builds get SPAlist and the labels from their syms equates.
%define SPAno(name) (((name) - SPAlist) >> 1)
