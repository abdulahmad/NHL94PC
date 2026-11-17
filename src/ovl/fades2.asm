; FADES2.OVL: RTLink overlay, loaded at paragraph 3358h. Files: docs/cleanup/files_94pc_ovl.txt.
; 2 relocation entries (offset, segment paragraph), zero fill to the next paragraph, then the image.
section fades2_relocs start=0
        dw 0x00E0, 0x3358, 0x003B, 0x3358
section wipe follows=fades2_relocs align=16 vstart=0x0
%include "front/fade/wipe.asm"
