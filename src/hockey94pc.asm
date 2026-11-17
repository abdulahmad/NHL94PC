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

section rtl_relocs follows=seg058 align=1 vstart=0
%include "data/rtl_relocs.asm"
section far3415 follows=rtl_relocs align=16 vstart=0
%include "data/far/far3415.asm"
section far342E follows=far3415 align=16 vstart=0
%include "data/far/far342E.asm"
section far342F follows=far342E align=16 vstart=0
%include "data/far/far342F.asm"
section far3448 follows=far342F align=16 vstart=0
%include "data/far/far3448.asm"
section far35E8 follows=far3448 align=16 vstart=0
%include "data/far/far35E8.asm"
section far35EC follows=far35E8 align=16 vstart=0
%include "data/far/far35EC.asm"
section far35EE follows=far35EC align=16 vstart=0
%include "data/far/far35EE.asm"
section far35F3 follows=far35EE align=16 vstart=0
%include "data/far/far35F3.asm"
section far3608 follows=far35F3 align=16 vstart=0
%include "data/far/far3608.asm"
section far3680 follows=far3608 align=16 vstart=0
%include "data/far/far3680.asm"
section far369A follows=far3680 align=16 vstart=0
%include "data/far/far369A.asm"
section far36A8 follows=far369A align=16 vstart=0
%include "data/far/far36A8.asm"
section far36B8 follows=far36A8 align=16 vstart=0
%include "data/far/far36B8.asm"
section far36F5 follows=far36B8 align=16 vstart=0
%include "data/far/far36F5.asm"
section far3701 follows=far36F5 align=16 vstart=0
%include "data/far/far3701.asm"
section far3821 follows=far3701 align=16 vstart=0
%include "data/far/far3821.asm"
section far3827 follows=far3821 align=16 vstart=0
%include "data/far/far3827.asm"
section far382B follows=far3827 align=16 vstart=0
%include "data/far/far382B.asm"
section far3836 follows=far382B align=16 vstart=0
%include "data/far/far3836.asm"
section far384B follows=far3836 align=16 vstart=0
%include "data/far/far384B.asm"
section far3863 follows=far384B align=16 vstart=0
%include "data/far/far3863.asm"
section far38AF follows=far3863 align=16 vstart=0
%include "data/far/far38AF.asm"
section far38BD follows=far38AF align=16 vstart=0
%include "data/far/far38BD.asm"
section far38EB follows=far38BD align=16 vstart=0
%include "data/far/far38EB.asm"
section far38F0 follows=far38EB align=16 vstart=0
%include "data/far/far38F0.asm"
section far38F6 follows=far38F0 align=16 vstart=0
%include "data/far/far38F6.asm"
section far3976 follows=far38F6 align=16 vstart=0
%include "data/far/far3976.asm"
section far3996 follows=far3976 align=16 vstart=0
%include "data/far/far3996.asm"
section far39AD follows=far3996 align=16 vstart=0
%include "data/far/far39AD.asm"
section far3A0B follows=far39AD align=16 vstart=0
%include "data/far/far3A0B.asm"
section dgroup follows=far3A0B align=16 vstart=0
%include "data/dgroup.asm"
exe_end:
section dgroup_bss nobits vfollows=dgroup valign=1
%include "data/dgroup_bss.asm"
