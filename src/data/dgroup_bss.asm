; DGROUP uninitialized data (BSS): no bytes in the file; the startup code clears it. Variables follow
; dgroup.asm in the same group.
%include "data/dgroup_bss/modules.asm"
%include "data/dgroup_bss/game_records.asm"
%include "data/dgroup_bss/front_end.asm"
%include "data/dgroup_bss/teams.asm"
%include "data/dgroup_bss/objects.asm"
%include "data/dgroup_bss/front_screens.asm"
%include "data/dgroup_bss/game_state.asm"
%include "data/dgroup_bss/sound_driver.asm"
%include "data/dgroup_bss/stack.asm"
