; FADES7.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 3 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades7_relocs start=0
        dw 0x001A, 0x3358, 0x01F4, 0x3358, 0x010A, 0x3358
section split_center follows=fades7_relocs align=16 vstart=0x0
%include "front/fade/split_center.asm"
