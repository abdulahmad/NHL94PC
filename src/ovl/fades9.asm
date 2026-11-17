; FADES9.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 2 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades9_relocs start=0
        dw 0x00EB, 0x3358, 0x00D7, 0x3358
section dissolve follows=fades9_relocs align=16 vstart=0x0
%include "front/fade/dissolve.asm"
