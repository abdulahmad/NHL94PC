; FADES3.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 3 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades3_relocs start=0
        dw 0x0098, 0x3358, 0x0009, 0x3358, 0x01BD, 0x3358
section plane_bands follows=fades3_relocs align=16 vstart=0x0
%include "front/fade/plane_bands.asm"
