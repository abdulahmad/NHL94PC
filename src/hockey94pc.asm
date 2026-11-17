; NHL Hockey (NHL '94) for DOS, HOCKEY.EXE.
; The whole file in order: the MZ header and relocation table, the load image one MZ segment (paragraph-aligned
; section, offsets from 0) after another, then the RTLink/Plus overlay area. A segment starts as an incbin of its
; bytes and becomes source as it is disassembled; build.sh checks every byte against the retail EXE.

bits	16

section header start=0
%include "header/mz_header.asm"

section msc_runtime follows=header align=16 vstart=0
%include "lib/msc_runtime.asm"
section system follows=msc_runtime align=16 vstart=0
%include "pc/system.asm"
section heap follows=system align=16 vstart=0
%include "pc/heap.asm"
section rec_flag follows=heap align=16 vstart=0
%include "pc/rec_flag.asm"
section type_id follows=rec_flag align=16 vstart=0
%include "pc/type_id.asm"
section main follows=type_id align=16 vstart=0
%include "front/main.asm"
section poll follows=main align=16 vstart=0
%include "pc/input/poll.asm"
section pad follows=poll align=16 vstart=0
%include "pc/input/pad.asm"
section speech follows=pad align=16 vstart=0
%include "pc/sound/speech.asm"
section init follows=speech align=16 vstart=0
%include "pc/input/init.asm"
section random follows=init align=16 vstart=0
%include "pc/random.asm"
section null_far2 follows=random align=16 vstart=0
%include "pc/null_far2.asm"
section wait_button follows=null_far2 align=16 vstart=0
%include "pc/input/wait_button.asm"
section save_game follows=wait_button align=16 vstart=0
%include "front/save_game.asm"
section midi follows=save_game align=16 vstart=0
%include "pc/sound/midi.asm"
section files follows=midi align=16 vstart=0
%include "pc/files.asm"
section text follows=files align=16 vstart=0
%include "pc/video/text.asm"
section math follows=text align=16 vstart=0
%include "pc/math.asm"
section divide_error follows=math align=16 vstart=0
%include "pc/divide_error.asm"
section team_palettes follows=divide_error align=16 vstart=0
%include "front/team_palettes.asm"
section dialogs follows=team_palettes align=16 vstart=0
%include "front/dialogs.asm"
section crowd follows=dialogs align=16 vstart=0
%include "front/crowd.asm"
section save_planes follows=crowd align=16 vstart=0
%include "pc/video/save_planes.asm"
section fit_name follows=save_planes align=16 vstart=0
%include "front/fit_name.asm"
section db_descriptor follows=fit_name align=16 vstart=0
%include "front/db_descriptor.asm"
section events follows=db_descriptor align=16 vstart=0
%include "pc/input/events.asm"
section menus follows=events align=16 vstart=0
%include "front/menus.asm"
section window_text follows=menus align=16 vstart=0
%include "front/window_text.asm"
section vga follows=window_text align=16 vstart=0
%include "pc/video/vga.asm"
section draw_frame follows=vga align=16 vstart=0
%include "pc/video/draw_frame.asm"
section heap_largest follows=draw_frame align=16 vstart=0
%include "pc/heap_largest.asm"
section thick_line follows=heap_largest align=16 vstart=0
%include "pc/video/thick_line.asm"
section load_raw follows=thick_line align=16 vstart=0
%include "pc/assets/load_raw.asm"
section load_packed follows=load_raw align=16 vstart=0
%include "pc/assets/load_packed.asm"
section heap_wrappers follows=load_packed align=16 vstart=0
%include "pc/heap_wrappers.asm"
section canvas_free follows=heap_wrappers align=16 vstart=0
%include "pc/video/canvas_free.asm"
section xor_frame follows=canvas_free align=16 vstart=0
%include "pc/video/xor_frame.asm"
section calibrate_stick follows=xor_frame align=16 vstart=0
%include "front/calibrate_stick.asm"
section canvas_alloc follows=calibrate_stick align=16 vstart=0
%include "pc/video/canvas_alloc.asm"
section text_center follows=canvas_alloc align=16 vstart=0
%include "pc/video/text_center.asm"
section retrace follows=text_center align=16 vstart=0
%include "pc/video/retrace.asm"
section pause_exit follows=retrace align=16 vstart=0
%include "front/pause_exit.asm"
section load_asset follows=pause_exit align=16 vstart=0
%include "pc/assets/load_asset.asm"
section file_can_open follows=load_asset align=16 vstart=0
%include "pc/assets/file_can_open.asm"
section nearest_color follows=file_can_open align=16 vstart=0
%include "pc/video/nearest_color.asm"
section shape_size follows=nearest_color align=16 vstart=0
%include "pc/assets/shape_size.asm"
section shape_bank_size follows=shape_size align=16 vstart=0
%include "pc/assets/shape_bank_size.asm"
section copy_bytes follows=shape_bank_size align=16 vstart=0
%include "pc/copy_bytes.asm"
section shade_table follows=copy_bytes align=16 vstart=0
%include "pc/video/shade_table.asm"
section seq_events follows=shade_table align=16 vstart=0
%include "lib/eaclib/seq_events.asm"
section sequencer follows=seq_events align=16 vstart=0
%include "lib/eaclib/sequencer.asm"
section driver_calls follows=sequencer align=16 vstart=0
%include "lib/eaclib/driver_calls.asm"
section driver_link follows=driver_calls align=16 vstart=0
%include "lib/eaclib/driver_link.asm"
section mz_relocate follows=driver_link align=16 vstart=0
%include "lib/eaclib/mz_relocate.asm"
section fp_emulator follows=mz_relocate align=16 vstart=0
%include "lib/fp_emulator.asm"
section load_cached follows=fp_emulator align=16 vstart=0
%include "pc/assets/load_cached.asm"
section overlay_manager follows=load_cached align=16 vstart=0
%include "lib/rtlink/overlay_manager.asm"
section rtl_runtime follows=overlay_manager align=16 vstart=0
%include "lib/rtlink/rtl_runtime.asm"

section rtl_relocs follows=rtl_runtime align=1 vstart=0
%include "data/rtl_relocs.asm"
section db_files follows=rtl_relocs align=16 vstart=0
%include "data/far/db_files.asm"
section input_event_data follows=db_files align=16 vstart=0
%include "data/far/input_event_data.asm"
section number_words follows=input_event_data align=16 vstart=0
%include "data/far/number_words.asm"
section menu_text follows=number_words align=16 vstart=0
%include "data/far/menu_text.asm"
section save_messages follows=menu_text align=16 vstart=0
%include "data/far/save_messages.asm"
section list_dialog_data follows=save_messages align=16 vstart=0
%include "data/far/list_dialog_data.asm"
section save_dialog_rects follows=list_dialog_data align=16 vstart=0
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
