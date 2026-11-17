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
section db_files follows=rtl_relocs align=16 vstart=0
%include "data/far/db_files.asm"
section spare_1 follows=db_files align=16 vstart=0
%include "data/far/spare_1.asm"
section number_words follows=spare_1 align=16 vstart=0
%include "data/far/number_words.asm"
section menu_text follows=number_words align=16 vstart=0
%include "data/far/menu_text.asm"
section save_messages follows=menu_text align=16 vstart=0
%include "data/far/save_messages.asm"
section spare_2 follows=save_messages align=16 vstart=0
%include "data/far/spare_2.asm"
section save_dialog_rects follows=spare_2 align=16 vstart=0
%include "data/far/save_dialog_rects.asm"
section hilight_messages follows=save_dialog_rects align=16 vstart=0
%include "data/far/hilight_messages.asm"
section credits follows=hilight_messages align=16 vstart=0
%include "data/far/credits.asm"
section char_table follows=credits align=16 vstart=0
%include "data/far/char_table.asm"
section dialog_rects follows=char_table align=16 vstart=0
%include "data/far/dialog_rects.asm"
section playoff_dialog_rects follows=dialog_rects align=16 vstart=0
%include "data/far/playoff_dialog_rects.asm"
section playoff_messages follows=playoff_dialog_rects align=16 vstart=0
%include "data/far/playoff_messages.asm"
section return_messages follows=playoff_messages align=16 vstart=0
%include "data/far/return_messages.asm"
section team_choice_text follows=return_messages align=16 vstart=0
%include "data/far/team_choice_text.asm"
section import_messages follows=team_choice_text align=16 vstart=0
%include "data/far/import_messages.asm"
section schedule_messages follows=import_messages align=16 vstart=0
%include "data/far/schedule_messages.asm"
section trade_messages follows=schedule_messages align=16 vstart=0
%include "data/far/trade_messages.asm"
section merge_messages follows=trade_messages align=16 vstart=0
%include "data/far/merge_messages.asm"
section season_titles follows=merge_messages align=16 vstart=0
%include "data/far/season_titles.asm"
section object_table follows=season_titles align=16 vstart=0
%include "data/far/object_table.asm"
section lines_menu_text follows=object_table align=16 vstart=0
%include "data/far/lines_menu_text.asm"
section line_names follows=lines_menu_text align=16 vstart=0
%include "data/far/line_names.asm"
section stat_names follows=line_names align=16 vstart=0
%include "data/far/stat_names.asm"
section hilight_save_messages follows=stat_names align=16 vstart=0
%include "data/far/hilight_save_messages.asm"
section anim_sequences follows=hilight_save_messages align=16 vstart=0
%include "data/far/anim_sequences.asm"
section palette_flags follows=anim_sequences align=16 vstart=0
%include "data/far/palette_flags.asm"
section runtime_state follows=palette_flags align=16 vstart=0
%include "data/far/runtime_state.asm"
section font_table follows=runtime_state align=16 vstart=0
%include "data/far/font_table.asm"
section work_buffer follows=font_table align=16 vstart=0
%include "data/far/work_buffer.asm"
section dgroup follows=work_buffer align=16 vstart=0
%include "data/dgroup.asm"
exe_end:
section dgroup_bss nobits vfollows=dgroup valign=1
%include "data/dgroup_bss.asm"
