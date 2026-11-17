; Saving the game: the save routine and the dialog that asks for the save name.
; The first bytes finish WaitButtonTimed from the file before.

;-----------------------------------------------------------------------------
; WaitButtonTimedTail                                         0C22:0000  94 PC
; End of WaitButtonTimed, which starts in the file before.
;-----------------------------------------------------------------------------
WaitButtonTimedTail:
        db 0x8B, 0xC7                           ; insn: mov ax, di
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; SaveGame                                                    0C22:0006  94 PC
; Writes game.sav (the database record, sizes, three 12-byte records) or
; copies the .db files to .sav.
;-----------------------------------------------------------------------------
SaveGame:
        enter 0x2a, 0x0
        push di
        push si
        cmp word [DbSaveMode], 0x0
        jz short .1
        jmp near .9
.1:
        lea ax, [bp - 0x26]
        push ax
        push cs
        call SaveGameNameDialog
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        mov es, [DbFilesSeg]
        or byte [es:0x55], 0x80
        or byte [AnnouncerFlags], 0x80
        push es
        push strict word 0x0
        call 0x1B35:WriteModeStateThunk
        add sp, 0x4
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x26]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x902
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0x62
        push -0x1
        push -0x1
        push word 0x3415                        ; segment of the db files far data
        push strict word 0x0
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        push word 0x905
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0x0
        push word 0x908
        call 0x149D:LoadRawHeader
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        push word 0x914
        call 0x03A3:FileSizeMsg
        add sp, 0x2
        push dx
        push ax
        push -0x1
        push -0x1
        push word [bp - 0x2]
        push si
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xe
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x920
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        mov ax, [bp - 0x2]
        push ax
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0xc
        push -0x1
        push -0x1
        push ds
        push word 0xb0b6
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0x923
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push word 0xb0aa
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        push word 0x926
        call 0x0F4A:FatalError
        add sp, 0x2
.7:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push word 0xb09e
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        push word 0x929
        call 0x0F4A:FatalError
        add sp, 0x2
.8:
        push word [bp - 0x6]
        call 0x1B35:SaveGameStateThunk
        add sp, 0x2
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        pop si
        pop di
        leave
        retf
        db 0x90
.9:
        mov ax, 0xc8
        cwd
        call 0x03A3:SetDeadline.regs
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        mov ax, 0xe53
        mov cx, 0x3701                          ; segment of the team choice text far data
        mov [bp - 0x2a], ax
        mov [bp - 0x28], cx
        push cx
        push ax
        lea ax, [bp - 0x26]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov di, 0x92c
        lea si, [bp - 0x26]
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        mov di, str_GameSav
        lea si, [bp - 0x26]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x26]
        push ax
        call 0x0CD1:CreateFileNormal
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        push word 0x937
        call 0x0F4A:FatalError
        add sp, 0x2
.10:
        cmp word [DbSaveMode], 0x2
        jnz short .11
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x35e8                        ; segment of the save messages far data
        push strict word 0x2b
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov es, [DbFilesSeg2]
        or byte [es:0x119], 0x80
        or byte [AnnouncerFlags], 0x80
        push es
        push word 0xc4
        call 0x1B35:WriteModeStateThunk
        add sp, 0x4
        push word [bp - 0x6]
        call 0x1B35:SaveLeagueGameRefThunk
        add sp, 0x2
        jmp short .12
.11:
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x35e8                        ; segment of the save messages far data
        push strict word 0x33
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov es, [DbFilesSeg3]
        or byte [es:0xb7], 0x80
        or byte [AnnouncerFlags], 0x80
        push es
        push strict word 0x62
        call 0x1B35:WriteModeStateThunk
        add sp, 0x4
.12:
        push word [bp - 0x6]
        call 0x1B35:SaveGameStateThunk
        add sp, 0x2
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        push word [bp - 0x28]
        push word [bp - 0x2a]
        push word [bp - 0x28]
        push word [bp - 0x2a]
        push ds
        push str_Sav
        push ds
        push str_Db
        push ds
        push word 0x943
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .13
        push word 0x94c
        call 0x0F4A:FatalError
        add sp, 0x2
.13:
        call 0x03A3:WaitDeadlineNoEoi
        call 0x0D90:RestoreUnderBox
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SaveGameNameDialog                                          0C22:02E2  94 PC
; Asks for the save name (file list, text entry) before SaveGame.
;-----------------------------------------------------------------------------
SaveGameNameDialog:
        enter 0x62, 0x0
        push di
        push si
        push 0x0
        les bx, [DialogData]
        mov ax, [es:bx]
        inc ax
        inc ax
        imul word [es:bx + 0x2]
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x2c], ax
        cwd
        push dx
        push ax
        push word 0x94f
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov ax, [DialogData]
        mov dx, [DialogDataSeg]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0xc]
        mov cx, 0x9
        rep movsw
        pop ds
        call 0x0FEF:UseCurrentPage
        lea ax, [bp - 0x24]
        push ax
        lea cx, [bp - 0x22]
        push cx
        lea dx, [bp - 0x2c]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        mov ax, [bp - 0x22]
        mov [bp - 0x8], ax
        mov ax, [bp - 0x24]
        mov [bp - 0xe], ax
        call 0x0FEF:UseCurrentPage
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word 0xbd0
        push ds
        push str_Savegame
        push 0x0
        push 0x0
        lea ax, [bp - 0x1c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push str_Prmt
        push 0x0
        lea ax, [bp - 0x1c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x60], ax
        mov [bp - 0x5e], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x5c], ax
        mov [bp - 0x5a], dx
        push 0x0
        les bx, [bp - 0x5c]
        mov ax, [es:bx]
        inc ax
        inc ax
        imul word [es:bx + 0x2]
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x2c], ax
        cwd
        push dx
        push ax
        push word 0x965
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov ax, [bp - 0x5c]
        mov dx, [bp - 0x5a]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x6]
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, 0x50
        sub cx, [es:bx]
        shl cx, 1
        mov [bp - 0x26], cx
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push word [bp - 0x5a]
        push word [bp - 0x5c]
        call 0x0FEF:DrawRleFastAt
        add sp, 0x8
        mov ax, 0x11
        mov dx, 0x5
        call 0x03A3:SetCharPtr.regs
        les bx, [bp - 0x5c]
        mov ax, [es:bx + 0x4]
        add [bp - 0x26], ax
        mov ax, [es:bx + 0x6]
        add [bp - 0x2a], ax
        mov bx, [bp + 0x6]
        mov byte [bx], 0x0
        push 0x1
        push 0x0
        push 0x0
        push word 0x3a3
        push word 0x734
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push 0x36
        push 0x8
        push bx
        call 0x1B35:EditTextFieldThunk
        add sp, 0x14
        mov di, str_Nhl
        push ds
        pop es
        mov si, [bp + 0x6]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
.1:
        mov bx, [bp + 0x6]
        cmp byte [bx], 0x2e
        jz short .2
        lea ax, [bp - 0x58]
        push ax
        push 0x0
        push bx
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .22
.2:
        mov bx, [bp + 0x6]
        cmp byte [bx], 0x2e
        jnz short .3
        jmp near .18
.3:
        les bx, [bp - 0x5c]
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        push ax
        mov ax, 0x50
        sub ax, [es:bx]
        shl ax, 1
        push ax
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push str_Err1
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x5c], ax
        mov [bp - 0x5a], dx
        push 0x0
        les bx, [bp - 0x5c]
        mov ax, [es:bx]
        inc ax
        inc ax
        imul word [es:bx + 0x2]
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x2c], ax
        cwd
        push dx
        push ax
        push word 0x976
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov ax, [bp - 0x5c]
        mov dx, [bp - 0x5a]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x6]
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, 0x50
        sub cx, [es:bx]
        shl cx, 1
        mov [bp - 0x26], cx
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push word [bp - 0x5a]
        push word [bp - 0x5c]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        les bx, [bp - 0x5c]
        mov ax, [es:bx + 0x4]
        add [bp - 0x26], ax
        mov ax, [es:bx + 0x6]
        add [bp - 0x2a], ax
        mov word [bp - 0x28], 0x0
        jmp short .5
.4:
        inc word [bp - 0x28]
.5:
        mov bx, [bp - 0x28]
        mov si, [bp + 0x6]
        cmp byte [bx + si], 0x2e
        jnz short .4
        mov byte [bx + si], 0x0
        mov ax, 0x11
        mov dx, 0xb
        call 0x03A3:SetCharPtr.regs
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push si
        call 0x0FEF:DrawChar
        add sp, 0x6
        push 0x6c
        push word 0xbf
        call 0x03A3:MouseMove
        add sp, 0x4
        call 0x0F99:FlushInputEvents
        push 0x6c
        push word 0xc0
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push 0x6c
        push word 0xc0
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransFastAt
        add sp, 0x8
        mov ax, 0xc0
        mov [bp - 0x8], ax
        mov [bp - 0x22], ax
        mov ax, 0x6c
        mov [bp - 0xe], ax
        mov [bp - 0x24], ax
        mov word [bp - 0x62], 0x0
.6:
        mov word [bp - 0x62], 0x0
.7:
        call 0x0F99:GetInputEvent
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .8
        lea cx, [bp - 0xe]
        push cx
        lea cx, [bp - 0x8]
        push cx
        push ax
        call far [HotKeyFn]
        add sp, 0x6
        mov [bp - 0x62], ax
        test al, 0x2
        jz short .7
.8:
        test byte [bp - 0x62], 0x2
        jnz short .10
        mov ax, [bp - 0x22]
        cmp [bp - 0x8], ax
        jnz short .9
        mov ax, [bp - 0x24]
        cmp [bp - 0xe], ax
        jz short .6
.9:
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x8]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0xe]
        push word [bp - 0x8]
        push word [DialogDataSeg]
        push word [DialogData]
        call 0x0FEF:DrawRleTransAt
        add sp, 0x8
        mov ax, [bp - 0x8]
        mov [bp - 0x22], ax
        mov ax, [bp - 0xe]
        mov [bp - 0x24], ax
        jmp near .6
        db 0x90
.10:
        cmp word [bp - 0xe], 0x70
        jnl short .9
        cmp word [bp - 0xe], 0x68
        jl short .9
        cmp word [bp - 0x8], 0x6d
        jg short .11
        jmp near .14
.11:
        cmp word [bp - 0x8], 0x84
        jl short .12
        jmp near .14
.12:
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, 0x50
        les bx, [bp - 0x5c]
        sub ax, [es:bx]
        shl ax, 1
        mov [bp - 0x26], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov di, str_Nhl_2
        push ds
        pop es
        mov si, [bp + 0x6]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
.13:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.14:
        cmp word [bp - 0x8], 0x8a
        jng short .15
        cmp word [bp - 0x8], 0xa8
        jnl short .15
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, 0x50
        les bx, [bp - 0x5c]
        sub ax, [es:bx]
        shl ax, 1
        mov [bp - 0x26], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
.15:
        cmp word [bp - 0x8], 0xae
        jg short .16
        jmp near .9
.16:
        cmp word [bp - 0x8], 0xd0
        jl short .17
        jmp near .9
.17:
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        les bx, [bp - 0x5c]
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        push ax
        mov ax, 0x50
        sub ax, [es:bx]
        shl ax, 1
        push ax
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push str_Prmt_2
        push word [bp - 0x5e]
        push word [bp - 0x60]
        call 0x03A3:FindFarMsg
        add sp, 0x6
        mov [bp - 0x5c], ax
        mov [bp - 0x5a], dx
        push 0x0
        les bx, [bp - 0x5c]
        mov ax, [es:bx]
        inc ax
        inc ax
        imul word [es:bx + 0x2]
        shl ax, byte 0x2
        add ax, strict word 0x12
        mov [bp - 0x2c], ax
        cwd
        push dx
        push ax
        push word 0x987
        call 0x14DB:AllocRecData
        add sp, 0x8
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov ax, [bp - 0x5c]
        mov dx, [bp - 0x5a]
        push ds
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, dx
        les di, [bp - 0x6]
        mov cx, 0x9
        rep movsw
        pop ds
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, 0x50
        sub cx, [es:bx]
        shl cx, 1
        mov [bp - 0x26], cx
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push word [bp - 0x5a]
        push word [bp - 0x5c]
        call 0x0FEF:DrawRleFastAt
        add sp, 0x8
        les bx, [bp - 0x5c]
        mov ax, [es:bx + 0x4]
        add [bp - 0x26], ax
        mov ax, [es:bx + 0x6]
        add [bp - 0x2a], ax
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:GetBlockAt
        add sp, 0x8
.18:
        mov word [bp - 0x28], 0x0
        jmp short .20
        db 0x90
.19:
        inc word [bp - 0x28]
.20:
        mov bx, [bp - 0x28]
        mov si, [bp + 0x6]
        cmp byte [bx + si], 0x2e
        jz short .21
        cmp byte [bx + si], 0x0
        jnz short .19
.21:
        push bx
        push word 0x98e
        call 0x03A3:ConPrint
        add sp, 0x4
        mov bx, [bp - 0x28]
        mov si, [bp + 0x6]
        mov byte [bx + si], 0x0
        mov ax, 0x11
        mov dx, 0x5
        call 0x03A3:SetCharPtr.regs
        push 0x1
        push 0x0
        push 0x0
        push word 0x3a3
        push word 0x734
        push word [bp - 0x2a]
        push word [bp - 0x26]
        push 0x36
        push 0x8
        push si
        call 0x1B35:EditTextFieldThunk
        add sp, 0x14
        mov di, str_Nhl_3
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        xchg di, si
        mov cx, 0xffff
        repne scasb
        dec di
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        jmp near .1
        db 0x90
.22:
        push word [bp - 0x24]
        push word [bp - 0x22]
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x0FEF:PutBlockAt
        add sp, 0x8
        mov ax, 0x50
        les bx, [bp - 0x5c]
        sub ax, [es:bx]
        shl ax, 1
        mov [bp - 0x26], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [es:bx + 0x2]
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sub ax, strict word 0x64
        neg ax
        mov [bp - 0x2a], ax
        push ax
        push cx
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x0FEF:DrawRawAt
        add sp, 0x8
        push word [bp - 0x4]
        push word [bp - 0x6]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0xa]
        push word [bp - 0xc]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [bp - 0x5e]
        push word [bp - 0x60]
        db 0x9A
