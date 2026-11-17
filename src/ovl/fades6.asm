; FADES6.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 7 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades6_relocs start=0
        dw 0x0117, 0x3358, 0x007E, 0x3358, 0x0009, 0x3358, 0x0140, 0x3358
        dw 0x00A7, 0x3358, 0x0151, 0x3358, 0x00B8, 0x3358
section slide_strips follows=fades6_relocs align=16 vstart=0x0
%include "front/fade/slide_strips.asm"
