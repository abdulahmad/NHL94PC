; FADES10.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 8 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades10_relocs start=0
        dw 0x01B0, 0x3358, 0x00F0, 0x3358, 0x01A0, 0x3358, 0x0079, 0x3358
        dw 0x0189, 0x3358, 0x021E, 0x3358, 0x01CE, 0x3358, 0x0067, 0x3358
section box_grow follows=fades10_relocs align=16 vstart=0x0
%include "front/fade/box_grow.asm"
