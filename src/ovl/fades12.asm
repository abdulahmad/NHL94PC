; FADES12.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 7 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades12_relocs start=0
        dw 0x0120, 0x3358, 0x0025, 0x3358, 0x0169, 0x3358, 0x0157, 0x3358
        dw 0x0140, 0x3358, 0x012C, 0x3358, 0x0171, 0x3358
section zoom_rect follows=fades12_relocs align=16 vstart=0x0
%include "front/fade/zoom_rect.asm"
