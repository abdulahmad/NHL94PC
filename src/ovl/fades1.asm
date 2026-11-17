; FADES1.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 8 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades1_relocs start=0
        dw 0x00F8, 0x3358, 0x004B, 0x3358, 0x0009, 0x3358, 0x0079, 0x3358
        dw 0x0015, 0x3358, 0x01A5, 0x3358, 0x0087, 0x3358, 0x0196, 0x3358
section venetian follows=fades1_relocs align=16 vstart=0x0
%include "front/fade/venetian.asm"
