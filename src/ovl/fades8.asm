; FADES8.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 10 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades8_relocs start=0
        dw 0x017A, 0x3358, 0x00DD, 0x3358, 0x0017, 0x3358, 0x01DA, 0x3358
        dw 0x009E, 0x3358, 0x01ED, 0x3358, 0x00BE, 0x3358, 0x00AA, 0x3358
        dw 0x018A, 0x3358, 0x017F, 0x3358
section random_blocks follows=fades8_relocs align=16 vstart=0x0
%include "front/fade/random_blocks.asm"
