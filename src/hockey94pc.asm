; NHL Hockey (NHL '94) for DOS, HOCKEY.EXE.
; The whole file in order: the MZ header and relocation table, the load image one MZ segment (paragraph-aligned
; section, offsets from 0) after another, then the RTLink/Plus overlay area. A segment starts as an incbin of its
; bytes and becomes source as it is disassembled; build.sh checks every byte against the retail EXE.

	bits	16

section header start=0
%include "header/mz_header.asm"

section seg000 follows=header align=16 vstart=0
%include "seg/seg000.asm"
section seg001 follows=seg000 align=16 vstart=0
%include "seg/seg001.asm"
section seg002 follows=seg001 align=16 vstart=0
%include "seg/seg002.asm"
section seg003 follows=seg002 align=16 vstart=0
%include "seg/seg003.asm"
section seg004 follows=seg003 align=16 vstart=0
%include "seg/seg004.asm"
section seg005 follows=seg004 align=16 vstart=0
%include "seg/seg005.asm"
section seg006 follows=seg005 align=16 vstart=0
%include "seg/seg006.asm"
section seg007 follows=seg006 align=16 vstart=0
%include "seg/seg007.asm"
section seg008 follows=seg007 align=16 vstart=0
%include "seg/seg008.asm"
section seg009 follows=seg008 align=16 vstart=0
%include "seg/seg009.asm"
section seg010 follows=seg009 align=16 vstart=0
%include "seg/seg010.asm"
section seg011 follows=seg010 align=16 vstart=0
%include "seg/seg011.asm"
section seg012 follows=seg011 align=16 vstart=0
%include "seg/seg012.asm"
section seg013 follows=seg012 align=16 vstart=0
%include "seg/seg013.asm"
section seg014 follows=seg013 align=16 vstart=0
%include "seg/seg014.asm"
section seg015 follows=seg014 align=16 vstart=0
%include "seg/seg015.asm"
section seg016 follows=seg015 align=16 vstart=0
%include "seg/seg016.asm"
section seg017 follows=seg016 align=16 vstart=0
%include "seg/seg017.asm"
section seg018 follows=seg017 align=16 vstart=0
%include "seg/seg018.asm"
section seg019 follows=seg018 align=16 vstart=0
%include "seg/seg019.asm"
section seg020 follows=seg019 align=16 vstart=0
%include "seg/seg020.asm"
section seg021 follows=seg020 align=16 vstart=0
%include "seg/seg021.asm"
section seg022 follows=seg021 align=16 vstart=0
%include "seg/seg022.asm"
section seg023 follows=seg022 align=16 vstart=0
%include "seg/seg023.asm"
section seg024 follows=seg023 align=16 vstart=0
%include "seg/seg024.asm"
section seg025 follows=seg024 align=16 vstart=0
%include "seg/seg025.asm"
section seg026 follows=seg025 align=16 vstart=0
%include "seg/seg026.asm"
section seg027 follows=seg026 align=16 vstart=0
%include "seg/seg027.asm"
section seg028 follows=seg027 align=16 vstart=0
%include "seg/seg028.asm"
section seg029 follows=seg028 align=16 vstart=0
%include "seg/seg029.asm"
section seg030 follows=seg029 align=16 vstart=0
%include "seg/seg030.asm"
section seg031 follows=seg030 align=16 vstart=0
%include "seg/seg031.asm"
section seg032 follows=seg031 align=16 vstart=0
%include "seg/seg032.asm"
section seg033 follows=seg032 align=16 vstart=0
%include "seg/seg033.asm"
section seg034 follows=seg033 align=16 vstart=0
%include "seg/seg034.asm"
section seg035 follows=seg034 align=16 vstart=0
%include "seg/seg035.asm"
section seg036 follows=seg035 align=16 vstart=0
%include "seg/seg036.asm"
section seg037 follows=seg036 align=16 vstart=0
%include "seg/seg037.asm"
section seg038 follows=seg037 align=16 vstart=0
%include "seg/seg038.asm"
section seg039 follows=seg038 align=16 vstart=0
%include "seg/seg039.asm"
section seg040 follows=seg039 align=16 vstart=0
%include "seg/seg040.asm"
section seg041 follows=seg040 align=16 vstart=0
%include "seg/seg041.asm"
section seg042 follows=seg041 align=16 vstart=0
%include "seg/seg042.asm"
section seg043 follows=seg042 align=16 vstart=0
%include "seg/seg043.asm"
section seg044 follows=seg043 align=16 vstart=0
%include "seg/seg044.asm"
section seg045 follows=seg044 align=16 vstart=0
%include "seg/seg045.asm"
section seg046 follows=seg045 align=16 vstart=0
%include "seg/seg046.asm"
section seg047 follows=seg046 align=16 vstart=0
%include "seg/seg047.asm"
section seg048 follows=seg047 align=16 vstart=0
%include "seg/seg048.asm"
section seg049 follows=seg048 align=16 vstart=0
%include "seg/seg049.asm"
section seg050 follows=seg049 align=16 vstart=0
%include "seg/seg050.asm"
section seg051 follows=seg050 align=16 vstart=0
%include "seg/seg051.asm"
section seg052 follows=seg051 align=16 vstart=0
%include "seg/seg052.asm"
section seg053 follows=seg052 align=16 vstart=0
%include "seg/seg053.asm"
section seg054 follows=seg053 align=16 vstart=0
%include "seg/seg054.asm"
section seg055 follows=seg054 align=16 vstart=0
%include "seg/seg055.asm"
section seg056 follows=seg055 align=16 vstart=0
%include "seg/seg056.asm"
section seg058 follows=seg056 align=16 vstart=0
%include "seg/seg058.asm"

section overlay follows=seg058 align=1
%include "overlay/ovl_00000.asm"
%include "overlay/ovl_01000.asm"
%include "overlay/ovl_02000.asm"
%include "overlay/ovl_03000.asm"
%include "overlay/ovl_04000.asm"
%include "overlay/ovl_05000.asm"
%include "overlay/ovl_06000.asm"
%include "overlay/ovl_07000.asm"
%include "overlay/ovl_08000.asm"
%include "overlay/ovl_09000.asm"
%include "overlay/ovl_0A000.asm"
%include "overlay/ovl_0B000.asm"
%include "overlay/ovl_0C000.asm"
%include "overlay/ovl_0D000.asm"
%include "overlay/ovl_0E000.asm"
%include "overlay/ovl_0F000.asm"
%include "overlay/ovl_10000.asm"
%include "overlay/ovl_11000.asm"
%include "overlay/ovl_12000.asm"
%include "overlay/ovl_13000.asm"
%include "overlay/ovl_14000.asm"
%include "overlay/ovl_15000.asm"
%include "overlay/ovl_16000.asm"
%include "overlay/ovl_17000.asm"
%include "overlay/ovl_18000.asm"
%include "overlay/ovl_19000.asm"
%include "overlay/ovl_1A000.asm"
%include "overlay/ovl_1B000.asm"