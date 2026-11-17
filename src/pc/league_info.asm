; Reads the league info and team names; reloads the sound configuration (LP.OVL)

;-----------------------------------------------------------------------------
; ReadLeagueInfo                                             22D3:0000  94 PC
; PINFO.DB of the league.
;
; Takes 16 words of stack arguments. Calls BuildPathFar, FindPath, _fstrcpy, _fstrcspn,
; SetDialogColors, MouseRead, MessageBox, OpenReadShared and others. Far routine (retf).
;-----------------------------------------------------------------------------
ReadLeagueInfo:
        enter 0x36, 0x0
        push di
        push si
        mov word [bp - 0x2], 0xffff
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x36]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x36]
        push ax
        call 0x03A3:FindPath
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .2
.1:
        mov si, 0x1
        push word 0x3701
        push strict word f_3701_0E53
        lea ax, [bp - 0x16]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word f_3701_0BF4
        lea ax, [bp - 0x16]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov byte [bp + di - 0x16], 0x0
        lea ax, [bp - 0x16]
        mov es, [g_8BC2]
        mov [es:0x105], ax
        mov [es:0x107], ss
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3701
        push strict word msgCanNotReadDatabasesIn
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
.2:
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x36]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        push 0x2
        push si
        push si
        push word [bp + 0x18]
        push word [bp + 0x16]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        push 0x2
        push si
        push 0x2
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        push 0x2
        push si
        push 0x4
        push word [bp + 0x20]
        push word [bp + 0x1e]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        push 0xd
        push si
        push 0x6
        push word [bp + 0x24]
        push word [bp + 0x22]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        push 0x2
        push si
        push 0x13
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.7:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .8
        push 0xb
        push si
        push 0x15
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.8:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .9
        push word 0x2d0
        push si
        push 0x20
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp - 0x2]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.9:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        push ds
        push strict word str_Sav_3
        push ds
        push strict word str_Game_3
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x36]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x36]
        push ax
        call 0x0CD1:FileExists
        add sp, 0x2
        les bx, [bp + 0x1e]
        mov [es:bx], ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadTeamNames                                              22D3:01E2  94 PC
; Team names from TEAMS.DB.
;
; Takes 4 words of stack arguments. Calls OpenReadShared, ReadAtOffset, CloseHandlePtr. Far routine
; (retf).
;-----------------------------------------------------------------------------
ReadTeamNames:
        enter 0xa, 0x0
        push di
        push si
        mov word [bp - 0x6], 0xffff
        lea ax, [bp - 0x6]
        push ax
        push word [bp + 0x6]
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x4], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .4
        mov si, 0x5
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x8], dx
.1:
        cmp word [bp - 0x4], 0x0
        jnz short .4
        cmp word [bp + 0xc], 0x0
        jz short .2
        push 0x15
        push 0x0
        push si
        jmp short .3
.2:
        push 0xd
        lea ax, [si + 0x15]
        push 0x0
        push ax
.3:
        push word [bp - 0x8]
        push di
        push word [bp - 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x4], ax
        add di, 0x15
        mov ax, [bp - 0x8]
        add si, 0x2e8
        cmp si, 0x45c5
        jl short .1
.4:
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0x4]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReloadSoundConfig                                          22D3:0262  94 PC
; Rereads the sound .CFG and restarts the sequencer.
;
; Calls BuildPathFar, OpenReadShared, ReadAtOffset, CloseHandlePtr, SetPaletteFar, OnexitThunk,
; MouseMove, SetDialogColors.
;-----------------------------------------------------------------------------
ReloadSoundConfig:
        enter 0x14, 0x0
        push di
        push si
        mov word [bp - 0x6], 0xffff
        push ds
        push strict word str_Cfg_2
        push ds
        push strict word str_Snd
        push 0x0
        push 0x0
        lea ax, [bp - 0x14]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x14]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        push 0x1
        push ax
        push ax
        lea ax, [bp - 0x1]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov bl, [bp - 0x1]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        mov di, [bx + g_1070]
        jmp short .2
        db 0x90
.1:
        mov di, 0x10
.2:
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x4], di
.3:
        mov al, [si + g_1826]
        mov [bp - 0x14], al
        mov [bp - 0x13], al
        mov [bp - 0x12], al
        lea ax, [bp - 0x14]
        push ss
        push ax
        push 0x1
        push si
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        inc si
        cmp si, 0x4
        jl short .3
        push word 0x16f2
        push strict word ShutdownSequencer
        call 0x03A3:OnexitThunk
        add sp, 0x4
        push 0x0
        push 0x0
        call 0x03A3:MouseMove
        add sp, 0x4
        push 0x0
        push 0x3
        push 0x1
        push 0x3
        push 0x2
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push di
