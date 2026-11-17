; Frees the game's memory after a game (INIT.OVL)
; The first bytes finish the last routine of team_names.asm.
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FreeGameMemory                                             256C:0004  94 PC
; Frees everything the game loaded.
;
; Calls CrowdNoiseOff, GameOverThunk, FindUnlink, FreeArenaJingles, FreePlayerFrames,
; UnhookDivideError, joyq_flushThunk, UseCharSeg. Far routine (retf).
;-----------------------------------------------------------------------------
FreeGameMemory:
        call 0x0EDC:CrowdNoiseOff
        call 0x1B35:GameOverThunk
        cmp word [ovlseq], -0x1
        jz short .1
        push word [g_D62E]
        push word [g_D62C]
        call 0x06E1:FindUnlink
        add sp, 0x4
.1:
        call 0x2137:FreeArenaJingles
        push cs
        call FreePlayerFrames
        push word [g_C25E]
        push word [g_C25C]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_D6D6]
        push word [g_D6D4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [RinkTilesSeg]
        push word [RinkTilesPtr]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [RinkTilesSeg], ax
        mov [RinkTilesPtr], ax
        push word [g_C25A]
        push word [g_C258]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [g_DAD0]
        push word [g_DACE]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, [g_CFFE]
        or ax, [g_CFFC]
        jz short .2
        push word [g_CFFE]
        push word [g_CFFC]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [g_CFFE], ax
        mov [g_CFFC], ax
.2:
        call 0x0D6B:UnhookDivideError
        mov word [PadRepeatOn], 0x0
        call 0x1B35:joyq_flushThunk
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x3d5
        out dx, al
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov word [PlayoffDlgY], 0x50
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FreePPVFiles                                               256C:00E8  94 PC
; Frees the three PPV files.
;
; Calls FindUnlink. Far routine (retf).
;-----------------------------------------------------------------------------
FreePPVFiles:
        push word [photobankf_w2]
        push word [photobankf]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [photobankf_w6]
        push word [photobankf_w4]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [photobankf_wA]
        push word [photobankf_w8]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [photobankf_wA], ax
        mov [photobankf_w8], ax
        mov [photobankf_w6], ax
        mov [photobankf_w4], ax
        mov [photobankf_w2], ax
        mov [photobankf], ax
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FreePlayerFrames                                           256C:012E  94 PC
; Frees PPV files and the frame table.
;
; Calls FreePPVFiles, UnlinkRec.
;-----------------------------------------------------------------------------
FreePlayerFrames:
        push di
        push si
        push cs
        call FreePPVFiles
        mov di, 0x11
        mov si, 0x9184
.1:
        mov ax, [si + 0x2]
        or ax, [si]
        jz short FreePlayerFramesTail + 0x150
        push word [si + 0x2]
        push word [si]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
