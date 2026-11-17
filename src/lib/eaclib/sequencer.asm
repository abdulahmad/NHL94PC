; EA sound library sequencer: song setup (in memory or EMS), start, stop, tempo and volume, and the
; helpers the timer side uses.
        db 0x47, 0x0A
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SetupSongTracks                                            16F2:0008  EACLIB
; Walks a song's track table and fills the slot pointers.
;-----------------------------------------------------------------------------
SetupSongTracks:
        enter 0x10, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, strict word 0x4
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, strict word 0x6
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        add ax, [bp + 0x6]
        adc dx, 0x0
        mov cx, 0xc
        shl dx, cl
        add dx, [bp + 0x8]
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl ax, byte 0x3
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, strict word 0x6
        db 0x13, 0xD2                           ; insn: adc dx, dx
        add ax, [bp + 0x6]
        adc dx, 0x0
        shl dx, cl
        add dx, [bp + 0x8]
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        db 0x33, 0xF6                           ; insn: xor si, si
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, strict word 0x6
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
.1:
        les bx, [bp - 0x4]
        cmp [es:bx], si
        jna short .4
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        les bx, [bp - 0x8]
        cmp [es:bx], ax
        jnz short .2
        cmp [es:bx + 0x2], dx
        jz short .3
.2:
        inc si
        add word [bp - 0x8], 0x4
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add [bp - 0x6], ax
        jmp short .1
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x2
        call 0x0000:__aFlshl
        add ax, [bp - 0xc]
        adc dx, 0x0
        mov cx, 0xc
        shl dx, cl
        add dx, [bp - 0xa]
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        add ax, [bp - 0x10]
        adc dx, 0x0
        shl dx, cl
        add dx, [bp - 0xe]
        jmp short .5
.4:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.5:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; SetupSongTracksEms                                         16F2:00EC  EACLIB
; SetupSongTracks for a song held in EMS.
;-----------------------------------------------------------------------------
SetupSongTracksEms:
        enter 0x10, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xF2                           ; insn: mov si, dx
        add ax, strict word 0x4
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov es, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [es:di]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, byte 0x2
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, strict word 0x6
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x03, 0xC3                           ; insn: add ax, bx
        adc dx, 0x0
        mov cx, 0xc
        shl dx, cl
        db 0x03, 0xD6                           ; insn: add dx, si
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x3
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call 0x0000:__aFlshl
        add ax, [bp + 0x6]
        adc dx, [bp + 0x8]
        add ax, strict word 0x6
        adc dx, 0x0
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x33, 0xF6                           ; insn: xor si, si
        db 0x8B, 0xCF                           ; insn: mov cx, di
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        add ax, strict word 0x6
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
.1:
        les bx, [bp - 0x8]
        cmp [es:bx], si
        jna short .4
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        les bx, [bp - 0x4]
        cmp [es:bx], ax
        jnz short .2
        cmp [es:bx + 0x2], dx
        jz short .3
.2:
        inc si
        add word [bp - 0x4], 0x4
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        and ax, 0x1000
        add [bp - 0x2], ax
        jmp short .1
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x2
        call 0x0000:__aFlshl
        add ax, [bp - 0xc]
        adc dx, 0x0
        mov cx, 0xc
        shl dx, cl
        add dx, [bp - 0xa]
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        add ax, [bp - 0x10]
        adc dx, [bp - 0xe]
        jmp short .5
.4:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.5:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetSequencer                                             16F2:01DE  EACLIB
; Clears the 24 track slots and 32 voice records.
;-----------------------------------------------------------------------------
ResetSequencer:
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xF6                           ; insn: xor si, si
.1:
        imul di, si, 0x58
        les bx, [TrackSlots]
        mov byte [es:bx + di + 0x56], 0x0
        les bx, [TrackSlots]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + di + 0x2], ax
        mov [es:bx + di], ax
        les bx, [TrackSlots]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:bx + di + 0x8], al
        inc si
        cmp si, 0x18
        jl short .1
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov es, [VoicesSeg]
.2:
        imul si, bx, 0xc
        add si, [Voices]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x2], ax
        mov [es:si], ax
        inc bx
        cmp bx, 0x20
        jl short .2
        db 0x33, 0xDB                           ; insn: xor bx, bx
.3:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x2
        mov [si + SongSeqsSeg], ax
        mov [si + SongSeqs], ax
        mov [si + SongPartsSeg], ax
        mov [si + SongParts], ax
        inc bx
        cmp bx, 0xa
        jl short .3
        db 0x33, 0xDB                           ; insn: xor bx, bx
.4:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x2
        mov [si + LoadedSongsSeg], ax
        mov [si + LoadedSongs], ax
        inc bx
        cmp bx, 0xa
        jl short .4
        db 0x33, 0xDB                           ; insn: xor bx, bx
.5:
        mov byte [bx + ChannelUsed], 0x0
        inc bx
        cmp bx, 0x10
        jl short .5
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [PatchBankSeg], ax
        mov [PatchBank], ax
        mov [DriverCount], ax
        mov byte [DriverServiceIdx], 0xff
        pop ds
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; InitSequencer                                              16F2:0280  EACLIB
; Allocates the slot, voice and queue tables and hooks the timer.
;-----------------------------------------------------------------------------
InitSequencer:
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push 0x0
        push word 0x840
        push word str_Track
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [TrackSlots], ax
        mov [TrackSlotsSeg], dx
        push 0x0
        push 0x0
        push word 0x180
        push word str_Parts
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [Voices], ax
        mov [VoicesSeg], dx
        push 0x0
        push 0x0
        push word 0x240
        push word str_Seqdat
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [SeqTimerSlot], ax
        mov [SeqTimerSlotSeg], dx
        mov ax, [TrackSlotsSeg]
        or ax, [TrackSlots]
        jz short .1
        mov ax, [VoicesSeg]
        or ax, [Voices]
        jz short .1
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [SeqTimerSlot]
        jz short .1
        call 0x16F2:ResetSequencer
        push word 0x1630
        push strict word 0x8
        call 0x03A3:AllocSlot
        add sp, 0x4
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        retf
.1:
        mov ax, 0xffff
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ShutdownSequencer                                          16F2:0308  EACLIB
; Frees the timer slot, shuts every driver down and frees the tables.
;-----------------------------------------------------------------------------
ShutdownSequencer:
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word 0x1630
        push strict word 0x8
        call 0x03A3:FreeSlot
        add sp, 0x4
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .2
.1:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        push ax
        call 0x1844:DrvShutdown
        pop bx
        inc si
.2:
        cmp [DriverCount], si
        ja short .1
        call 0x16F2:ResetSequencer
        push word [TrackSlotsSeg]
        push word [TrackSlots]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [VoicesSeg]
        push word [Voices]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [SeqTimerSlotSeg]
        push word [SeqTimerSlot]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SeqStubLong0                                               16F2:036C  EACLIB
; Returns 0 in DX:AX.
;-----------------------------------------------------------------------------
SeqStubLong0:
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SeqStubWord0                                               16F2:0378  EACLIB
; Returns 0.
;-----------------------------------------------------------------------------
SeqStubWord0:
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; LoadBankNumber                                             16F2:0382  EACLIB
; Formats "bank%d.pat" and loads it.
;-----------------------------------------------------------------------------
LoadBankNumber:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0x6]
        push str_BankDPat
        push word PatchFileName
        call 0x0000:_sprintf
        add sp, 0x6
        push word PatchFileName
        call 0x16F2:LoadPatchBank
        pop bx
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; LoadPatchBank                                              16F2:03A8  EACLIB
; Loads a patch bank file and keeps its pointer.
;-----------------------------------------------------------------------------
LoadPatchBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push word [bp + 0x6]
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [PatchBank], ax
        mov [PatchBankSeg], dx
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; FreeSongData                                               16F2:03C8  EACLIB
; Unlinks a song record, returns 0.
;-----------------------------------------------------------------------------
FreeSongData:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SendPatches                                                16F2:03E4  EACLIB
; Sends every patch of the bank to the driver.
;-----------------------------------------------------------------------------
SendPatches:
        enter 0x6, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [PatchBankSeg]
        or ax, [PatchBank]
        jnz short .1
        jmp near .14
.1:
        inc word [SeqLock]
        mov word [bp - 0x6], 0x0
.2:
        mov al, [bp - 0x6]
        push ax
        call 0x16F2:GetPatch
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
        mov byte [PatchMsg], 0x80
        mov es, dx
        mov al, [es:di]
        mov [PatchMsg1], al
        mov byte [PatchMsg2], 0x0
        mov al, [es:di + 0x1]
        mov [PatchMsg3], al
        test byte [es:di + 0xf], 0x80
        jnz short .5
        cmp byte [es:di + 0xf], 0x3
        jnz short .5
        db 0x33, 0xDB                           ; insn: xor bx, bx
.3:
        cmp [DriverCount], bx
        jng short .5
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x2
        cmp byte [si + DriverTypes], 0x3
        jz short .4
        inc bx
        jmp short .3
.4:
        or bl, 0x80
        mov es, [bp - 0x2]
        mov [es:di + 0xf], bl
.5:
        db 0x33, 0xF6                           ; insn: xor si, si
.6:
        cmp si, 0xa
        jnl short .12
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        mov ax, [bx + LoadedSongsSeg]
        or ax, [bx + LoadedSongs]
        jz short .7
        push word [PatchMsg2]
        push word [PatchMsg]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        push word [bx + LoadedSongsSeg]
        push word [bx + LoadedSongs]
        call 0x16F2:SetupSongTracks
        add sp, 0x8
        mov es, [bp - 0x2]
        mov [es:di + 0x10], ax
        mov [es:di + 0x12], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        or ax, [es:di + 0x10]
        jnz short .8
.7:
        inc si
        jmp short .6
.8:
        mov es, [bp - 0x2]
        test byte [es:di + 0xf], 0x80
        jnz short .12
        db 0x33, 0xF6                           ; insn: xor si, si
.9:
        cmp [DriverCount], si
        jng short .11
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        mov al, [bx + DriverTypes]
        cmp [es:di + 0xf], al
        jz short .10
        inc si
        jmp short .9
.10:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        or al, 0x80
        mov [es:di + 0xf], al
.11:
        mov es, [bp - 0x2]
.12:
        inc word [bp - 0x6]
        cmp word [bp - 0x6], 0x100
        jnl short .13
        jmp near .2
.13:
        dec word [SeqLock]
.14:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; AddLoadedSong                                              16F2:04EA  EACLIB
; Stores a song pointer in the first free of 10 entries.
;-----------------------------------------------------------------------------
AddLoadedSong:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xDB                           ; insn: xor bx, bx
.1:
        cmp bx, 0xa
        jnl short .3
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x2
        mov ax, [si + LoadedSongsSeg]
        or ax, [si + LoadedSongs]
        jz short .2
        inc bx
        jmp short .1
.2:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        shl bx, byte 0x2
        mov [bx + LoadedSongs], ax
        mov [bx + LoadedSongsSeg], dx
.3:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; LoadSongMode                                               16F2:0522  EACLIB
; Loads a song file (track, parts, seqdat) with its bank and timbres.
;-----------------------------------------------------------------------------
LoadSongMode:
        enter 0x18, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov cx, [bp + 0xc]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnz short .1
        push word [bp + 0x6]
        push str_TimbDTim
        push word SongFileName
        call 0x0000:_sprintf
        add sp, 0x6
        jmp short .2
.1:
        push cx
        push word SongFileName
        call 0x0000:_strcpy
        add sp, 0x4
.2:
        mov ax, [bp + 0xa]
        or ax, [bp + 0x8]
        jnz short .3
        push 0x0
        push word SongFileName
        call 0x149D:LoadRawHeader
        add sp, 0x4
        jmp short .4
.3:
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word SongFileName
        call 0x1B28:LoadFileCached
        add sp, 0x6
.4:
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .5
        jmp near .17
.5:
        push word [bp - 0x12]
        push ax
        call 0x16F2:AddLoadedSong
        add sp, 0x4
        push word 0x6769
        push word MouseRatioShift
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x16F2:SetupSongTracks
        add sp, 0x8
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .6
        jmp near .16
.6:
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .8
.7:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, [bp - 0x8]
        db 0x13, 0xD2                           ; insn: adc dx, dx
        shl dx, cl
        add dx, [bp - 0x6]
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [es:bx]
        mov [si + SongFileName], al
        inc si
.8:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, [bp - 0x8]
        db 0x13, 0xD2                           ; insn: adc dx, dx
        mov cx, 0xc
        shl dx, cl
        add dx, [bp - 0x6]
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [es:bx], 0x0
        jnz short .7
        mov byte [si + SongFileName], 0x0
        push 0x80
        push word SongFileName
        call 0x149D:LoadRaw
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov bl, [SongCount]
        inc byte [SongCount]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov [bx + SongPtrs], ax
        mov [bx + SongPtrsSeg], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .9
        jmp near .16
.9:
        push word [bp - 0x2]
        push word [bp - 0x4]
        call 0x06E1:RawBase
        add sp, 0x4
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        add ax, strict word 0x4
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [es:bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x18], ax
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        add ax, strict word 0x6
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        and cx, 0x1000
        db 0x03, 0xD1                           ; insn: add dx, cx
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x33, 0xFF                           ; insn: xor di, di
.10:
        cmp [bp - 0x18], di
        ja short .11
        jmp near .16
.11:
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .14
.12:
        les bx, [bp - 0x8]
        add word [bp - 0x8], 0x1
        jnc short .13
        add word [bp - 0x6], 0x1000
.13:
        mov al, [es:bx]
        mov [si + SongFileNameEnd], al
        inc si
.14:
        cmp si, 0x4
        jc short .12
        mov byte [si + SongFileNameEnd], 0x0
        push word [SongBankNum]
        push word [SongFileNameEnd]
        push word [bp - 0x12]
        push word [bp - 0x14]
        call 0x16F2:SetupSongTracks
        add sp, 0x8
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp byte [es:bx], 0x6
        jnz short .15
        push word [es:bx + 0x4]
        push word [es:bx + 0x2]
        push word [bp - 0xe]
        push word [bp - 0x10]
        call 0x16F2:SetupSongTracksEms
        add sp, 0x8
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .15
        les bx, [bp - 0x4]
        mov word [es:bx + 0xa], 0x80
        mov ax, [bp - 0xc]
        mov dx, [bp - 0xa]
        mov [es:bx + 0xc], ax
        mov [es:bx + 0xe], dx
        db 0x32, 0xC0                           ; insn: xor al, al
        mov [es:bx + 0x10], al
        mov [es:bx + 0x11], al
        mov word [es:bx + 0x12], 0x2b11
.15:
        inc di
        jmp near .10
.16:
        call 0x16F2:SendPatches
.17:
        mov ax, [bp - 0x14]
        mov dx, [bp - 0x12]
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadSongDrvBuf                                             16F2:071C  EACLIB
; Driver bank call, then LoadSongMode with a buffer.
;-----------------------------------------------------------------------------
LoadSongDrvBuf:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word 0xff
        push 0x0
        call 0x1844:DrvLoadBank
        add sp, 0x8
        push 0x0
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x16F2:LoadSongMode
        add sp, 0x8
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; LoadSongDrv                                                16F2:074E  EACLIB
; Driver bank call, then LoadSongMode.
;-----------------------------------------------------------------------------
LoadSongDrv:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word 0xff
        push 0x0
        call 0x1844:DrvLoadBank
        add sp, 0x8
        push 0x0
        push 0x0
        push 0x0
        push word [bp + 0x6]
        call 0x16F2:LoadSongMode
        add sp, 0x8
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; LoadSong                                                   16F2:077E  EACLIB
; LoadSongMode by number.
;-----------------------------------------------------------------------------
LoadSong:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push 0x0
        push 0x0
        push word [bp + 0x6]
        call 0x16F2:LoadSongMode
        add sp, 0x8
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadSongBuf                                                16F2:079C  EACLIB
; LoadSongMode by number into a buffer.
;-----------------------------------------------------------------------------
LoadSongBuf:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x16F2:LoadSongMode
        add sp, 0x8
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RemoveLoadedSong                                           16F2:07BC  EACLIB
; Clears a song pointer from the 10 entries.
;-----------------------------------------------------------------------------
RemoveLoadedSong:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov cx, [bp + 0x6]
.1:
        cmp bx, 0xa
        jnl short .4
        mov ax, [bp + 0x8]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, byte 0x2
        cmp [si + LoadedSongs], cx
        jnz short .2
        cmp [si + LoadedSongsSeg], ax
        jz short .3
.2:
        inc bx
        jmp short .1
.3:
        shl bx, byte 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bx + LoadedSongsSeg], ax
        mov [bx + LoadedSongs], ax
        jmp short .5
.4:
        mov ax, 0xffff
.5:
        pop ds
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; UnloadSong                                                 16F2:07FE  EACLIB
; Removes and frees a song and its parts.
;-----------------------------------------------------------------------------
UnloadSong:
        enter 0x6, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        mov ax, [bp + 0x8]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x16F2:RemoveLoadedSong
        add sp, 0x4
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov byte [bp - 0x1], 0x0
        jmp short .3
.1:
        mov bl, [bp - 0x1]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x2
        mov ax, [bx + SongPtrs]
        mov dx, [bx + SongPtrsSeg]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov [bp - 0x4], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .2
        push word [bp - 0x4]
        push cx
        call 0x06E1:UnlinkRec
        add sp, 0x4
.2:
        inc byte [bp - 0x1]
.3:
        mov al, [SongCount]
        cmp [bp - 0x1], al
        jc short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [SongCount], al
        pop ds
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SeqStubLong1                                               16F2:0866  EACLIB
; Returns 0 in DX:AX.
;-----------------------------------------------------------------------------
SeqStubLong1:
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SeqStubWord1                                               16F2:0872  EACLIB
; Returns 0.
;-----------------------------------------------------------------------------
SeqStubWord1:
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; GetPatch                                                   16F2:087C  EACLIB
; Address of a 20-byte patch record in the bank.
;-----------------------------------------------------------------------------
GetPatch:
        enter 0x4, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [PatchBank]
        mov dx, [PatchBankSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .1
        mov al, 0x14
        mov di, [bp + 0x6]
        and di, 0xff
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov es, [bp - 0x2]
        mul byte [es:bx + di + 0x2]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov dx, es
        add ax, 0x102
        jmp short .2
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.2:
        pop ds
        pop si
        pop di
        leave
        retf 0x2
        db 0x90

;-----------------------------------------------------------------------------
; GetPatchData                                               16F2:08BE  EACLIB
; The data pointer of a patch record.
;-----------------------------------------------------------------------------
GetPatchData:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [PatchBankSeg]
        or ax, [PatchBank]
        jnz short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        jmp short .2
.1:
        mov al, [bp + 0x6]
        push ax
        call 0x16F2:GetPatch
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx + 0x10]
        mov dx, [es:bx + 0x12]
.2:
        pop ds
        leave
        retf 0x2
        db 0x90

;-----------------------------------------------------------------------------
; InitVoiceLists                                             16F2:08F0  EACLIB
; Links the voice records into lists.
;-----------------------------------------------------------------------------
InitVoiceLists:
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xDB                           ; insn: xor bx, bx
.1:
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jng short .2
        imul ax, bx, 0xe
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, SeqTimerSlotSeg
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [si + VoiceListPrev], ax
        mov [si + VoiceListPrevSeg], ds
        jmp short .3
.2:
        imul si, bx, 0xe
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + VoiceListPrevSeg], ax
        mov [si + VoiceListPrev], ax
.3:
        cmp bx, 0x9
        jnl short .4
        imul ax, bx, 0xe
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, VoiceListId + 1
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov [si + VoiceListNext], ax
        mov [si + VoiceListNextSeg], ds
        jmp short .5
.4:
        imul si, bx, 0xe
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [si + VoiceListNextSeg], ax
        mov [si + VoiceListNext], ax
.5:
        imul si, bx, 0xe
        mov [si + VoiceListId], bl
        inc bx
        cmp bx, 0xa
        jl short .1
        db 0x33, 0xDB                           ; insn: xor bx, bx
.6:
        mov byte [bx + VoiceListFlags], 0x0
        inc bx
        cmp bx, 0x32
        jl short .6
        mov word [VoiceListEnd], VoiceListNext
        mov [VoiceListEndSeg], ds
        mov word [VoiceFreeList], VoiceListId + 0x71
        mov [VoiceFreeListSeg], ds
        pop ds
        pop si
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ScanSongParts                                              16F2:0976  EACLIB
; Scans the parts tables of the loaded songs.
;-----------------------------------------------------------------------------
ScanSongParts:
        enter 0xc, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xFF                           ; insn: xor di, di
.1:
        cmp di, 0xa
        jnc short .5
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, byte 0x2
        les bx, [bx + SongParts]
        mov al, [es:bx + 0x1]
        mov [bp - 0x1], al
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .3
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        shl ax, byte 0x2
        db 0x8B, 0xDF                           ; insn: mov bx, di
        shl bx, byte 0x2
        les bx, [bx + SongParts]
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        add bx, 0x4
        db 0x03, 0xD8                           ; insn: add bx, ax
        imul ax, [es:bx], word 0x404
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov dx, es
        mov [bp - 0x6], dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bp + 0x6]
        cmp [es:bx + 0x2], ax
        jz short .4
        inc si
.3:
        mov al, [bp - 0x1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        ja short .2
        inc di
        jmp short .1
.4:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, [bp - 0x6]
        jmp short .6
.5:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.6:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ScanSongSeqs                                               16F2:09E6  EACLIB
; Scans the sequence tables of the loaded songs.
;-----------------------------------------------------------------------------
ScanSongSeqs:
        enter 0xa, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xF6                           ; insn: xor si, si
.1:
        cmp si, 0xa
        jnc short .5
        db 0x8B, 0xDE                           ; insn: mov bx, si
        shl bx, byte 0x2
        les bx, [bx + SongSeqs]
        mov al, [es:bx + 0x1]
        mov [bp - 0x3], al
        db 0x33, 0xFF                           ; insn: xor di, di
        mov [bp - 0x6], si
        db 0x8B, 0xF7                           ; insn: mov si, di
        jmp short .3
.2:
        mov ax, [bp + 0x6]
        imul cx, si, word 0x108
        mov di, [bp - 0x6]
        shl di, byte 0x2
        les di, [di + SongSeqs]
        db 0x03, 0xF9                           ; insn: add di, cx
        inc di
        inc di
        db 0x8B, 0xDF                           ; insn: mov bx, di
        cmp [es:di + 0x2], ax
        jz short .4
        inc si
.3:
        mov al, [bp - 0x3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        ja short .2
        mov si, [bp - 0x6]
        inc si
        jmp short .1
.4:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, es
        jmp short .6
.5:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.6:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PrepareSong                                                16F2:0A4E  EACLIB
; Resolves a song's parts and sequences before it starts.
;-----------------------------------------------------------------------------
PrepareSong:
        enter 0x4, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov di, [bp + 0x6]
        cmp byte [di + VoiceListFlags], 0x0
        jnz short .1
        les bx, [VoiceFreeList]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp - 0x2], es
        cmp byte [es:bx + 0xc], 0x0
        jz short .2
        mov bl, [es:si + 0xc]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        mov [bx + VoiceListFlags], bh
        push di
        call 0x16F2:ScanSongParts
        pop bx
        les bx, [bp + 0x8]
        mov [es:bx + 0x4], ax
        mov [es:bx + 0x6], dx
        push di
        call 0x16F2:ScanSongSeqs
        pop bx
        les bx, [bp + 0x8]
        mov [es:bx + 0x8], ax
        mov [es:bx + 0xa], dx
        jmp short .2
.1:
        push 0x18
        mov al, [di + VoiceListFlags]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0xe
        add bx, VoiceListNext
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov [bp - 0x2], ds
        push word [bx + 0xa]
        push word [bx + 0x8]
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x0000:_fmemcpy
        add sp, 0xa
.2:
        les bx, [VoiceFreeList]
        mov al, [es:bx + 0xd]
        mov [di + VoiceListFlags], al
        mov ax, [bp - 0x2]
        cmp si, [VoiceListEnd]
        jnz short .3
        cmp ax, [VoiceListEndSeg]
        jz short .6
.3:
        cmp si, [VoiceFreeList]
        jnz short .4
        cmp ax, [VoiceFreeListSeg]
        jz short .5
.4:
        mov es, ax
        mov ax, [es:si + 0x4]
        mov dx, [es:si + 0x6]
        les bx, [es:si]
        mov [es:bx + 0x4], ax
        mov [es:bx + 0x6], dx
.5:
        mov es, [bp - 0x2]
        mov ax, [es:si]
        mov dx, [es:si + 0x2]
        mov cx, es
        les bx, [es:si + 0x4]
        mov [es:bx], ax
        mov [es:bx + 0x2], dx
        mov es, cx
        mov ax, [VoiceListEnd]
        mov dx, [VoiceListEndSeg]
        mov [es:si], ax
        mov [es:si + 0x2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x6], ax
        mov [es:si + 0x4], ax
        mov [VoiceListEnd], si
        mov [VoiceListEndSeg], cx
        mov ax, [es:si + 0x4]
        mov dx, [es:si + 0x6]
        mov [VoiceFreeList], ax
        mov [VoiceFreeListSeg], dx
.6:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FindFreeChannel                                            16F2:0B58  EACLIB
; First of 16 MIDI channels allowed by the mask and unused.
;-----------------------------------------------------------------------------
FindFreeChannel:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov cx, [bp + 0x6]
.1:
        cmp bx, 0x10
        jnl short .4
        db 0x8B, 0xF3                           ; insn: mov si, bx
        shl si, 1
        test [si + ChannelMasks], cx
        jz short .2
        cmp byte [bx + ChannelUsed], 0x0
        jz short .3
.2:
        inc bx
        jmp short .1
.3:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        jmp short .5
.4:
        mov ax, 0xffff
.5:
        pop ds
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FindFreeTrackSlot                                          16F2:0B8C  EACLIB
; First unused of the 24 track slots.
;-----------------------------------------------------------------------------
FindFreeTrackSlot:
        enter 0x4, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov ds, dx
.1:
        cmp bx, 0x18
        jnl short .3
        cmp byte [si + 0x56], 0x0
        jz short .2
        add si, 0x58
        inc bx
        jmp short .1
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0x2]
        jmp short .4
.3:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
.4:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; StartSong                                                  16F2:0BC6  EACLIB
; Starts a song in free slots, returns a new handle.
;-----------------------------------------------------------------------------
StartSong:
        enter 0x1c, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov si, [bp + 0x6]
        add word [SongHandleLo], 0x1
        adc word [SongHandleHi], 0x0
        mov ax, [SongHandleLo]
        mov dx, [SongHandleHi]
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        mov es, [bp + 0x8]
        mov ax, [es:si + 0x4]
        mov dx, [es:si + 0x6]
        mov [bp - 0x14], ax
        mov [bp - 0x12], dx
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        mov cx, [es:si + 0x8]
        mov bx, [es:si + 0xa]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov [bp - 0x8], bx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cl, [es:bx + 0x1]
        mov [bp - 0xc], cl
        mov cl, [es:bx + 0x6]
        mov [bp - 0x6], cl
        inc word [SeqLock]
        mov byte [bp - 0x5], 0x0
.1:
        cmp byte [bp - 0x6], 0x0
        jnz short .2
        jmp near .7
.2:
        call 0x16F2:FindFreeTrackSlot
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .3
        jmp near .6
.3:
        mov es, [bp - 0x2]
        mov al, [es:si + 0x8]
        mov [bp - 0xb], al
        push 0x58
        push 0x0
        push es
        push si
        call 0x0000:_fmemset
        add sp, 0x8
        mov al, [bp - 0xb]
        mov es, [bp - 0x2]
        mov [es:si + 0x8], al
        mov word [es:si + 0x4e], 0x0
        mov ax, 0x7d00
        mov cl, [bp - 0xc]
        db 0x2A, 0xED                           ; insn: sub ch, ch
        cwd
        idiv cx
        mov [es:si + 0x50], ax
        mov ax, [bp - 0x10]
        mov dx, [bp - 0xe]
        mov [es:si], ax
        mov [es:si + 0x2], dx
        mov bl, [bp - 0x5]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        mov es, [bp - 0x12]
        add bx, [bp - 0x14]
        mov ax, [es:bx + 0x8]
        add ax, [bp - 0x18]
        mov dx, [bp - 0x16]
        mov es, [bp - 0x2]
        mov [es:si + 0xa], ax
        mov [es:si + 0xc], dx
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov [es:si + 0x4], ax
        mov [es:si + 0x6], dx
        db 0x32, 0xC0                           ; insn: xor al, al
        mov [es:si + 0x30], al
        mov [es:si + 0x31], al
        mov [es:si + 0x4a], al
        mov ax, [es:si + 0xa]
        mov dx, [es:si + 0xc]
        mov [es:si + 0x32], ax
        mov [es:si + 0x34], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x10], ax
        mov [es:si + 0xe], ax
        mov [es:si + 0x54], ax
        mov [es:si + 0x52], ax
        mov ax, [bp - 0x8]
        db 0x0B, 0xC7                           ; insn: or ax, di
        jnz short .4
        jmp near .5
.4:
        mov bl, [bp - 0x5]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, byte 0x4
        db 0x03, 0xDF                           ; insn: add bx, di
        mov es, [bp - 0x8]
        push word [es:bx + 0x8]
        mov [bp - 0x1c], bx
        mov [bp - 0x1a], es
        call 0x16F2:FindFreeChannel
        pop bx
        mov es, [bp - 0x2]
        mov [es:si + 0x4c], al
        les bx, [bp - 0x1c]
        mov al, [es:bx + 0x14]
        push ax
        call 0x16F2:GetPatch
        mov es, [bp - 0x2]
        mov byte [es:si + 0x4d], 0x0
        les bx, [bp - 0x1c]
        push word [es:bx + 0xc]
        push word [es:bx + 0xa]
        mov es, [bp - 0x2]
        mov al, [es:si + 0x4c]
        push ax
        push 0x0
        call 0x1844:DrvStub1
        add sp, 0x8
        les bx, [bp - 0x1c]
        mov al, [es:bx + 0x14]
        push ax
        mov es, [bp - 0x2]
        mov al, [es:si + 0x4c]
        push ax
        mov al, [es:si + 0x4d]
        push ax
        call 0x1630:SendProgramChange
        add sp, 0x6
        push 0x0
        push 0x1
        push word [bp - 0x2]
        push si
        call 0x1630:SendController
        add sp, 0x8
        les bx, [bp - 0x1c]
        mov al, [es:bx + 0xe]
        push ax
        push 0x7
        push word [bp - 0x2]
        push si
        call 0x1630:SendController
        add sp, 0x8
        les bx, [bp - 0x1c]
        mov al, [es:bx + 0xe]
        push ax
        push 0xa
        push word [bp - 0x2]
        push si
        call 0x1630:SendController
        add sp, 0x8
        push word 0x4000
        push word [bp - 0x2]
        push si
        call 0x1630:SendPitchBend
        add sp, 0x6
.5:
        mov es, [bp - 0x2]
        mov byte [es:si + 0x56], 0x1
        dec byte [bp - 0x6]
        inc byte [bp - 0x5]
        jmp near .1
.6:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        jmp short .8
.7:
        dec word [SeqLock]
        mov ax, [bp - 0x10]
        mov dx, [bp - 0xe]
.8:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RestartSong                                                16F2:0DD6  EACLIB
; StartSong and copies settings to its slots.
;-----------------------------------------------------------------------------
RestartSong:
        enter 0xa, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        inc word [SeqLock]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x16F2:StartSong
        add sp, 0x4
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov cx, [bp - 0x2]
        jmp short .3
.1:
        mov ax, [bp - 0x6]
        mov dx, [bp - 0x4]
        mov es, [bp - 0x8]
        cmp [es:si], ax
        jnz short .2
        cmp [es:si + 0x2], dx
        jnz short .2
        or byte [es:si + 0x56], 0x8
        les bx, [es:si + 0x4]
        mov word [es:bx + 0xe], 0xffff
        mov es, [bp - 0x8]
        les bx, [es:si + 0x4]
        mov al, [es:bx + 0x11]
        mov [es:bx + 0x10], al
.2:
        add si, 0x58
        inc cx
.3:
        cmp cx, 0x18
        jl short .1
        dec word [SeqLock]
        mov ax, [bp - 0x6]
        mov dx, [bp - 0x4]
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; SeqStubLong2                                               16F2:0E58  EACLIB
; Returns 0 in DX:AX.
;-----------------------------------------------------------------------------
SeqStubLong2:
        push ds
        mov ax, DGROUP
        mov ds, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayPatchNote                                              16F2:0E64  EACLIB
; Plays a sound effect patch (id below 100h) on a free voice.
;-----------------------------------------------------------------------------
PlayPatchNote:
        enter 0x6, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        cmp word [bp + 0x6], 0x100
        jc short .1
        jmp near .8
.1:
        cmp word [SfxEnabled], 0x0
        jnz short .2
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp near .9
.2:
        mov al, [bp + 0x6]
        push ax
        call 0x16F2:GetPatch
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        mov ax, [bp + 0xa]
        or ax, [bp + 0x8]
        jnz short .5
        mov es, dx
        cmp byte [es:si + 0xe], 0x0
        jz short .3
        mov al, 0x6
        mul byte [es:si + 0xe]
        jmp short .4
.3:
        mov ax, 0xa0
.4:
        cwd
        mov [bp + 0x8], ax
        mov [bp + 0xa], dx
.5:
        cmp word [bp + 0x6], 0x80
        jc short .7
        mov byte [SfxMsg], 0xb9
        mov byte [SfxMsg1], 0x7
        mov byte [SfxMsg2], 0x7f
        push 0x3
        push word SfxMsg
        mov es, [bp - 0x2]
        mov al, [es:si + 0xf]
        and al, 0x7f
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        push 0x0
        push word 0xff
        push word 0xff
        mov es, [bp - 0x2]
        mov al, [es:si + 0xf]
        and al, 0x7f
        push ax
        push 0x9
        push word [bp + 0xa]
        push word [bp + 0x8]
        push 0x7f
        mov al, [bp + 0x6]
        sub al, 0x74
        push ax
.6:
        call 0x1630:AllocVoice
        add sp, 0x12
        jmp near .9
.7:
        mov di, [SfxChannel]
        add di, 0xc
        mov al, [SfxChannel]
        inc al
        and ax, strict word 0x3
        mov [SfxChannel], ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xCF                           ; insn: mov cx, di
        or al, 0xc0
        mov [SfxMsg], al
        mov al, [bp + 0x6]
        mov [SfxMsg1], al
        mov byte [SfxMsg2], 0x0
        push 0x2
        push word SfxMsg
        mov es, [bp - 0x2]
        mov al, [es:si + 0xf]
        and al, 0x7f
        push ax
        mov [bp - 0x6], cx
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        mov al, [bp - 0x6]
        or al, 0xb0
        mov [SfxMsg], al
        mov byte [SfxMsg1], 0x7
        mov byte [SfxMsg2], 0x7f
        push 0x3
        push word SfxMsg
        mov es, [bp - 0x2]
        mov al, [es:si + 0xf]
        and al, 0x7f
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        mov al, [bp - 0x6]
        or al, 0x90
        mov [SfxMsg], al
        mov byte [SfxMsg1], 0x24
        mov byte [SfxMsg2], 0x7f
        push 0x0
        push word 0xff
        push word 0xff
        mov es, [bp - 0x2]
        mov al, [es:si + 0xf]
        and al, 0x7f
        push ax
        db 0x8B, 0xC7                           ; insn: mov ax, di
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push 0x7f
        push 0x24
        jmp near .6
.8:
        mov ax, 0xffff
.9:
        cwd
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayPatch                                                  16F2:0FB8  EACLIB
; PlayPatchNote with default note.
;-----------------------------------------------------------------------------
PlayPatch:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push 0x0
        push word [bp + 0x6]
        call 0x16F2:PlayPatchNote
        add sp, 0x6
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlaySound                                                  16F2:0FD4  EACLIB
; Id below 100h plays a patch, otherwise prepares and starts a song.
;-----------------------------------------------------------------------------
PlaySound:
        enter 0x4, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov di, [bp + 0x6]
        cmp di, 0x100
        jnc short .1
        push 0x0
        push di
        call 0x16F2:PlayPatch
        jmp short .4
.1:
        call 0x16F2:SeqStubLong2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .3
.2:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        jmp short .5
.3:
        push word [bp - 0x2]
        push si
        push di
        call 0x16F2:PrepareSong
        add sp, 0x6
        inc ax
        jz short .2
        push word [bp - 0x2]
        push si
        call 0x16F2:StartSong
.4:
        add sp, 0x4
.5:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReleaseAllVoices                                           16F2:1028  EACLIB
; Marks every active voice for release.
;-----------------------------------------------------------------------------
ReleaseAllVoices:
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        inc word [SeqLock]
        cmp word [SfxEnabled], 0x0
        jz short .3
        db 0x33, 0xDB                           ; insn: xor bx, bx
.1:
        imul si, bx, 0xc
        mov es, [VoicesSeg]
        add si, [Voices]
        mov ax, [es:si + 0x2]
        or ax, [es:si]
        jz short .2
        imul si, bx, 0xc
        add si, [Voices]
        mov word [es:si + 0x8], 0x1
        mov word [es:si + 0xa], 0x0
.2:
        inc bx
        cmp bx, 0x20
        jl short .1
.3:
        dec word [SeqLock]
        pop ds
        pop si
        retf

;-----------------------------------------------------------------------------
; StopSound                                                  16F2:1070  EACLIB
; Stops a sound by handle and silences its voices.
;-----------------------------------------------------------------------------
StopSound:
        enter 0xc, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        cmp word [bp + 0x6], -0x1
        jnz short .1
        cmp word [bp + 0x8], 0x0
        jnz short .1
        mov ax, 0xffff
        jmp near .12
.1:
        mov ax, [Voices]
        mov dx, [VoicesSeg]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        inc word [SeqLock]
        cmp word [bp + 0x8], 0x0
        jnz short .4
        cmp word [bp + 0x6], 0x100
        jnc short .4
        cmp word [SfxEnabled], 0x0
        jnz short .2
        jmp near .11
.2:
        imul si, [bp + 0x6], 0xc
        les bx, [Voices]
        mov ax, [es:bx + si + 0xa]
        or ax, [es:bx + si + 0x8]
        jnz short .3
        jmp near .10
.3:
        imul si, [bp + 0x6], 0xc
        mov word [es:bx + si + 0x8], 0x1
        mov word [es:bx + si + 0xa], 0x0
        jmp near .10
.4:
        db 0x33, 0xF6                           ; insn: xor si, si
.5:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov es, [bp - 0x6]
        cmp [es:di], ax
        jnz short .6
        cmp [es:di + 0x2], dx
        jnz short .6
        push es
        push di
        call 0x1630:SendVoiceNoteOff
        add sp, 0x4
.6:
        add di, 0xc
        inc si
        cmp si, 0x20
        jl short .5
        db 0x33, 0xFF                           ; insn: xor di, di
        mov si, [bp - 0x4]
        jmp short .9
.7:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .8
        cmp [es:si + 0x2], dx
        jnz short .8
        mov al, [es:si + 0x4c]
        or al, 0xb0
        mov [bp - 0xc], al
        mov byte [bp - 0xb], 0x7b
        push 0x3
        lea ax, [bp - 0xc]
        push ax
        db 0x32, 0xC9                           ; insn: xor cl, cl
        mov [bp - 0xa], cl
        push cx
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        mov es, [bp - 0x2]
        mov al, [es:si + 0x4c]
        or al, 0xb0
        mov [bp - 0xc], al
        mov byte [bp - 0xb], 0x7
        push 0x3
        lea ax, [bp - 0xc]
        push ax
        db 0x32, 0xC0                           ; insn: xor al, al
        mov [bp - 0xa], al
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        mov es, [bp - 0x2]
        mov byte [es:si + 0x56], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:si + 0x2], ax
        mov [es:si], ax
.8:
        add si, 0x58
        inc di
.9:
        cmp di, 0x18
        jl short .7
        mov byte [bp - 0xc], 0xb9
        mov byte [bp - 0xb], 0x7
        mov byte [bp - 0xa], 0x64
        push 0x3
        lea ax, [bp - 0xc]
        push ax
        push 0x0
        call 0x1630:QueueMidiBytes
        add sp, 0x6
        call 0x1630:SeqService
.10:
        dec word [SeqLock]
.11:
        db 0x33, 0xC0                           ; insn: xor ax, ax
.12:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; StopSong                                                   16F2:11BA  EACLIB
; Flags the song's slots to stop.
;-----------------------------------------------------------------------------
StopSong:
        enter 0x4, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        inc word [SeqLock]
        db 0x33, 0xC9                           ; insn: xor cx, cx
.1:
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        mov es, [bp - 0x2]
        cmp [es:si], ax
        jnz short .2
        cmp [es:si + 0x2], dx
        jnz short .2
        cmp byte [es:si + 0x56], 0x0
        jz short .2
        or byte [es:si + 0x56], 0x8
        les bx, [es:si + 0x4]
        mov ax, [es:bx + 0xc]
        dec ax
        mov [es:bx + 0xe], ax
        mov es, [bp - 0x2]
        les bx, [es:si + 0x4]
        mov al, [es:bx + 0x11]
        mov [es:bx + 0x10], al
.2:
        add si, 0x58
        inc cx
        cmp cx, 0x18
        jl short .1
        dec word [SeqLock]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; SongFinished                                               16F2:1226  EACLIB
; 1 when no slot plays the song.
;-----------------------------------------------------------------------------
SongFinished:
        enter 0x4, 0x0
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ds, dx
.1:
        cmp cx, 0x18
        jnl short .4
        mov ax, [bx]
        mov dx, [bx + 0x2]
        cmp [bp + 0x6], ax
        jnz short .2
        cmp [bp + 0x8], dx
        jnz short .2
        cmp byte [bx + 0x56], 0x0
        jnz short .3
.2:
        add bx, 0x58
        inc cx
        jmp short .1
.3:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        leave
        retf
.4:
        mov ax, 0x1
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SongStopped                                                16F2:1268  EACLIB
; 1 when no slot of the song is still stopping.
;-----------------------------------------------------------------------------
SongStopped:
        enter 0x4, 0x0
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ds, dx
.1:
        cmp cx, 0x18
        jnl short .4
        mov ax, [bx]
        mov dx, [bx + 0x2]
        cmp [bp + 0x6], ax
        jnz short .2
        cmp [bp + 0x8], dx
        jnz short .2
        test byte [bx + 0x56], 0x8
        jnz short .3
.2:
        add bx, 0x58
        inc cx
        jmp short .1
.3:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop ds
        leave
        retf
.4:
        mov ax, 0x1
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SongChannelValue                                           16F2:12AA  EACLIB
; A per-channel value of a playing song.
;-----------------------------------------------------------------------------
SongChannelValue:
        enter 0x4, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ds, dx
.1:
        cmp cx, 0x18
        jnl short .4
        mov ax, [si]
        mov dx, [si + 0x2]
        cmp [bp + 0x6], ax
        jnz short .2
        cmp [bp + 0x8], dx
        jnz short .2
        mov al, [bp + 0xa]
        cmp [si + 0x4c], al
        jnz short .2
        jz short .3
.2:
        add si, 0x58
        inc cx
        jmp short .1
.3:
        mov al, [si + 0x4a]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        jmp short .5
.4:
        mov ax, 0xffff
.5:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; MuteAllTracks                                              16F2:12F4  EACLIB
; Sends volume 0 on every active track.
;-----------------------------------------------------------------------------
MuteAllTracks:
        enter 0x8, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
        mov word [TracksMuted], 0x1
        db 0x33, 0xF6                           ; insn: xor si, si
        mov [bp - 0x4], di
        jmp short .3
.1:
        mov es, [bp - 0x2]
        cmp byte [es:di + 0x56], 0x0
        jz short .2
        mov al, [es:di + 0x4c]
        or al, 0xb0
        mov [bp - 0x8], al
        mov byte [bp - 0x7], 0x7
        push 0x3
        lea ax, [bp - 0x8]
        push ax
        db 0x32, 0xC0                           ; insn: xor al, al
        mov [bp - 0x6], al
        push ax
        call 0x1630:QueueMidiBytes
        add sp, 0x6
.2:
        inc si
.3:
        cmp si, 0x18
        jl short .1
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RestoreTrackVolumes                                        16F2:1350  EACLIB
; Sends each active track's volume again.
;-----------------------------------------------------------------------------
RestoreTrackVolumes:
        enter 0x4, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [TrackSlots]
        mov dx, [TrackSlotsSeg]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x2], dx
        db 0x33, 0xF6                           ; insn: xor si, si
        jmp short .3
.1:
        mov es, [bp - 0x2]
        cmp byte [es:di + 0x56], 0x0
        jz short .2
        mov al, [es:di + 0x4c]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x7
        mov es, [WorkBufferSeg3]
        mov al, [es:bx + ChannelSetup]
        push ax
        push 0x7
        push word [bp - 0x2]
        push di
        call 0x1630:SendController
        add sp, 0x8
.2:
        inc si
.3:
        cmp si, 0x18
        jl short .1
        mov word [TracksMuted], 0x0
        pop ds
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SfxOn                                                      16F2:13A8  EACLIB
; Sets the effects flag.
;-----------------------------------------------------------------------------
SfxOn:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov word [SfxEnabled], 0x1
        pop ds
        retf

;-----------------------------------------------------------------------------
; SfxOff                                                     16F2:13B6  EACLIB
; Clears the effects flag.
;-----------------------------------------------------------------------------
SfxOff:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov word [SfxEnabled], 0x0
        pop ds
        retf

;-----------------------------------------------------------------------------
; ToggleSfx                                                  16F2:13C4  EACLIB
; Flips the effects flag and returns it.
;-----------------------------------------------------------------------------
ToggleSfx:
        push ds
        mov ax, DGROUP
        mov ds, ax
        cmp word [SfxEnabled], 0x0
        jz short .1
        call 0x16F2:SfxOff
        jmp short .2
.1:
        call 0x16F2:SfxOn
.2:
        mov ax, [SfxEnabled]
        pop ds
        retf

;-----------------------------------------------------------------------------
; GetSfx                                                     16F2:13E2  EACLIB
; Returns the effects flag.
;-----------------------------------------------------------------------------
GetSfx:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [SfxEnabled]
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MusicOn                                                    16F2:13EE  EACLIB
; Sets the second sound flag.
;-----------------------------------------------------------------------------
MusicOn:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov word [MusicEnabled], 0x1
        pop ds
        retf

;-----------------------------------------------------------------------------
; MusicOff                                                   16F2:13FC  EACLIB
; Clears the second sound flag.
;-----------------------------------------------------------------------------
MusicOff:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov word [MusicEnabled], 0x0
        pop ds
        retf

;-----------------------------------------------------------------------------
; ToggleMusic                                                16F2:140A  EACLIB
; Flips the second sound flag and returns it.
;-----------------------------------------------------------------------------
ToggleMusic:
        push ds
        mov ax, DGROUP
        mov ds, ax
        cmp word [MusicEnabled], 0x0
        jz short .1
        call 0x16F2:MusicOn
        jmp short .2
.1:
        call 0x16F2:MusicOff
.2:
        mov ax, [MusicEnabled]
        pop ds
        retf

;-----------------------------------------------------------------------------
; GetMusic                                                   16F2:1428  EACLIB
; Returns the second sound flag.
;-----------------------------------------------------------------------------
GetMusic:
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [MusicEnabled]
        pop ds
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadFarDword                                               16F2:1434  EACLIB
; Returns the dword at a far pointer.
;-----------------------------------------------------------------------------
ReadFarDword:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        les bx, [bp + 0x6]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; ReadFarWord                                                16F2:144A  EACLIB
; Returns the word at a far pointer.
;-----------------------------------------------------------------------------
ReadFarWord:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        les bx, [bp + 0x6]
        mov ax, [es:bx]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; StoreDwordBE                                               16F2:145C  EACLIB
; Writes a dword high byte first.
;-----------------------------------------------------------------------------
StoreDwordBE:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        lea di, [bp + 0xd]
        mov al, [di]
        mov [si], al
        lea di, [bp + 0xc]
        mov al, [di]
        inc si
        mov [si], al
        lea di, [bp + 0xb]
        mov al, [di]
        db 0x8B, 0xCE                           ; insn: mov cx, si
        inc cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov [bx], al
        mov al, [bp + 0xa]
        inc cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov [bx], al
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadDwordBE                                                16F2:1496  EACLIB
; Reads a dword stored high byte first.
;-----------------------------------------------------------------------------
ReadDwordBE:
        enter 0x4, 0x0
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov ah, [bx]
        shl ah, byte 0x10
        db 0x2A, 0xC0                           ; insn: sub al, al
        cwd
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [bx]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        shl ax, byte 0x10
        cwd
        add [bp - 0x4], ax
        adc [bp - 0x2], dx
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov ah, [bx]
        db 0x2A, 0xC0                           ; insn: sub al, al
        cwd
        add [bp - 0x4], ax
        adc [bp - 0x2], dx
        mov al, [si]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        add ax, [bp - 0x4]
        adc dx, [bp - 0x2]
        pop ds
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CopyEventBytes                                             16F2:14E8  EACLIB
; Copies bytes of an event record.
;-----------------------------------------------------------------------------
CopyEventBytes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ds, [bp + 0x8]
        mov di, [bp + 0x6]
        mov si, [bp + 0xa]
        mov es, [bp + 0xc]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di], al
        inc di
        mov es, [bp + 0xc]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di], al
        inc di
        mov es, [bp + 0xc]
        db 0x8B, 0xDE                           ; insn: mov bx, si
        inc si
        mov al, [es:bx]
        mov [di], al
        inc di
