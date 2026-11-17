; Game summary log: deferred calls, records and event lines (AI.OVL)
; The first bytes and SetTeamGoalieTail finish SetTeamGoalie from hud.asm.
        push ax
        call 0x2E42:setpersonel
        add sp, 0x2
SetTeamGoalieTail:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; QueueDeferredCall                                          2352:000E  94 PC
; Stores a far routine and 7 argument words in an 18-byte queue entry.
;
; Takes 9 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
QueueDeferredCall:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        imul bx, [defercount], 0x12
        mov [bx + defertab_fn], ax
        mov [bx + defertab_seg], dx
        mov ax, [bp + 0xa]
        mov [bx + defertab_a1], ax
        mov ax, [bp + 0xc]
        mov [bx + defertab_a2], ax
        mov ax, [bp + 0xe]
        mov [bx + defertab_a3], ax
        mov ax, [bp + 0x10]
        mov [bx + defertab_a4], ax
        mov ax, [bp + 0x12]
        mov [bx + defertab_a5], ax
        mov ax, [bp + 0x14]
        mov [bx + defertab_a6], ax
        mov ax, [bp + 0x16]
        mov [bx + defertab_a7], ax
        inc word [defercount]
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RunDeferredCalls                                           2352:005C  94 PC
; Calls each queued far routine with its arguments, empties the queue.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
RunDeferredCalls:
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [defercount], di
        jng short .2
        mov si, 0xdc38
.1:
        push word [si - 0x2]
        push word [si - 0x4]
        push word [si - 0x6]
        push word [si - 0x8]
        push word [si - 0xa]
        push word [si - 0xc]
        push word [si - 0xe]
        call far [si]
        add sp, 0xe
        add si, 0x12
        inc di
        cmp [defercount], di
        jg short .1
.2:
        mov word [defercount], 0x0
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; AppendGSumRecord                                           2352:0096  94 PC
; Bumps the game summary count, rewrites the header, appends the record.
;
; Takes 1 word of stack arguments. Calls OpenReadWriteShared, FatalError, _lseek, WriteAtOffset,
; CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
AppendGSumRecord:
        enter 0x2, 0x0
        inc word [gsumcount]
        lea ax, [bp - 0x2]
        push ax
        push word 0xae70
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x5776
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push 0x0
        push 0x0
        push 0x0
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .2
        push word 0x5779
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x577c
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0x2
        push -0x1
        push -0xc
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .4
        push word 0x577f
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push word [bp + 0x6]
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x5782
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .6
        push word 0x5785
        call 0x0F4A:FatalError
        add sp, 0x2
.6:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FlushGSumQueue                                             2352:0174  94 PC
; AppendGSumRecord for each queued 12-byte record, then clears the count.
;
; Calls AppendGSumRecord. Far routine (retf).
;-----------------------------------------------------------------------------
FlushGSumQueue:
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        cmp [gsumqcount], di
        jng short .2
        mov si, 0xdc72
.1:
        push si
        push cs
        call AppendGSumRecord
        add sp, 0x2
        add si, 0xc
        inc di
        cmp [gsumqcount], di
        jg short .1
.2:
        mov word [gsumqcount], 0x0
        pop si
        pop di
        retf

;-----------------------------------------------------------------------------
; PutGSumHeader                                              2352:019C  94 PC
; Opens the game summary file and writes the 12-byte header at the start.
;
; Calls OpenReadWriteShared, FatalError, WriteAtOffset, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
PutGSumHeader:
        enter 0x2, 0x0
        lea ax, [bp - 0x2]
        push ax
        push word 0xae70
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x5788
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        push word 0x578b
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PutGSumTail                                                2352:01EE  94 PC
; Seeks to end - 12 and writes the 12-byte tail record.
;
; Calls OpenReadWriteShared, FatalError, _lseek, WriteAtOffset, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
PutGSumTail:
        enter 0x2, 0x0
        lea ax, [bp - 0x2]
        push ax
        push word 0xae70
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x578e
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push 0x2
        push -0x1
        push -0xc
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .2
        push word 0x5791
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x5794
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; WriteGSumHeader                                            2352:0260  94 PC
; Bumps the record count, writes the header at 0 and the tail at the end.
;
; Calls OpenReadWriteShared, FatalError, _lseek, WriteAtOffset, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
WriteGSumHeader:
        enter 0x2, 0x0
        inc word [gsumcount]
        lea ax, [bp - 0x2]
        push ax
        push word 0xae70
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push word 0x5797
        call 0x0F4A:FatalError
        add sp, 0x2
.1:
        push 0x0
        push 0x0
        push 0x0
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .2
        push word 0x579a
        call 0x0F4A:FatalError
        add sp, 0x2
.2:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumheader
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        push word 0x579d
        call 0x0F4A:FatalError
        add sp, 0x2
.3:
        push 0x2
        push 0x0
        push 0x0
        push word [bp - 0x2]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .4
        push word 0x57a0
        call 0x0F4A:FatalError
        add sp, 0x2
.4:
        push 0xc
        push -0x1
        push -0x1
        push ds
        push strict word gsumtail
        push word [bp - 0x2]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .5
        push word 0x57a3
        call 0x0F4A:FatalError
        add sp, 0x2
.5:
        lea ax, [bp - 0x2]
        push ax
        call 0x0CD1:CloseHandlePtr
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FormatPlayerName                                           2352:031A  94 PC
; '%s#%d %s %s%s' roster names.
;
; Takes 6 words of stack arguments. Calls UseCharSeg, _sprintf, TextWidthAll. Far routine (retf).
;-----------------------------------------------------------------------------
FormatPlayerName:
        enter 0x18, 0x0
        push di
        push si
        mov si, [bp + 0xc]
        push word [MemBlock2Seg]
        push word [MemBlock2Off]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        mov word [bp - 0x4], 0x7c
        push word [bp + 0x10]
        push word [bp + 0xe]
        push si
        push word [bp + 0xa]
        push word [bp + 0x8]
        push strict word str_SDSSS
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0xe
        push word [bp + 0x6]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cmp ax, strict word 0x7c
        jg short .1
        jmp near .6
.1:
        push word [bp + 0x10]
        push word [bp + 0xe]
        mov al, [si]
        cbw
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push strict word str_SDCSS
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0xe
        push word [bp + 0x6]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cmp ax, strict word 0x7c
        jg short .2
        jmp near .6
.2:
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push strict word str_SDSS_2
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0xc
        push word [bp + 0x6]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cmp ax, strict word 0x7c
        jg short .3
        jmp near .6
.3:
        push word [bp + 0x10]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push strict word str_SDS
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0xa
        push word [bp + 0x6]
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, strict word 0x7c
        neg ax
        mov [bp - 0x4], ax
        lea si, [bp - 0x18]
        push ds
        pop es
        mov di, [bp + 0xe]
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        xchg di, si
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        lea di, [bp - 0x18]
        push ss
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        dec cx
        mov [bp - 0x2], cx
        lea ax, [bp - 0x18]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        cmp ax, [bp - 0x4]
        jng short .5
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
.4:
        dec si
        mov byte [bp + si - 0x18], 0x0
        lea ax, [bp - 0x18]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jg short .4
.5:
        push word [bp + 0x10]
        lea ax, [bp - 0x18]
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push strict word str_SDSS
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0xc
.6:
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; BuildEventLines                                            2352:0478  94 PC
; Goal / penalty / injury event text.
;
; Calls _sprintf, FormatPlayerName. Far routine (retf).
;-----------------------------------------------------------------------------
BuildEventLines:
        enter 0x14, 0x0
        push di
        push si
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [textline5], al
        mov [textline4], al
        mov [textline2], al
        mov [textline1], al
        mov [textline3], al
        cmp byte [curevent], 0x1
        jz short .1
        jmp near .9
.1:
        mov al, [curevent_b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF8                           ; insn: mov di, ax
        imul ax, di, word 0x2e8
        add ax, 0x9f9a
        push ax
        mov al, [curevent_b8]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [curevent_b7]
        push ax
        push strict word str_02d02dS
        push word 0xd4b8
        call 0x0000:_sprintf
        add sp, 0xa
        mov al, [curevent_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [curevent_b5]
        mov [bp - 0x8], ax
        test al, 0x2
        jz short .2
        mov ax, str_Sh
        jmp short .4
.2:
        test byte [bp - 0x8], 0x4
        jz short .3
        mov ax, str_Pp
        jmp short .4
        db 0x90
.3:
        mov ax, 0x57f7
.4:
        push ax
        push word 0x57f8
        lea ax, [bp - 0x12]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        mov [bp - 0x6], ax
        cmp word [DbSaveMode], 0x0
        jz short .5
        test byte [gmode], 0x10
        jnz short .5
        cmp si, 0x19
        jnl short .5
        mov es, [segWorkBuffer58]
        imul bx, di, 0x19
        db 0x03, 0xDE                           ; insn: add bx, si
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, byte 0x3
        mov cx, [bx + plstatsoff3]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, byte 0x4
        add cx, [es:bx + HomePlStats]
        push cx
        push strict word str_D_2
        mov ax, [bp - 0x6]
        lea cx, [bp - 0x12]
        db 0x03, 0xC1                           ; insn: add ax, cx
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
.5:
        lea ax, [bp - 0x12]
        push ax
        imul ax, di, 0x1c
        mov [bp - 0x14], ax
        db 0x03, 0xC6                           ; insn: add ax, si
        imul ax, ax, 0x28
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xa568
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xa558
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x5801
        push word 0xd506
        push cs
        call FormatPlayerName
        add sp, 0xc
        mov al, [curevent_b3]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp si, 0xff
        jnz short .6
        push strict word str_Unassisted
        push word 0xd542
        call 0x0000:_sprintf
        add sp, 0x4
        jmp short .7
        db 0x90
.6:
        push strict word str_Assists
        push word 0xd542
        call 0x0000:_sprintf
        add sp, 0x4
        push word 0x5816
        add si, [bp - 0x14]
        imul ax, si, 0x28
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xa568
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xa558
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x5817
        push word 0xd57e
        push cs
        call FormatPlayerName
        add sp, 0xc
.7:
        mov al, [curevent_b4]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp si, 0xff
        jnz short .8
        jmp near .15
.8:
        push word 0x5818
        add si, [bp - 0x14]
        imul ax, si, 0x28
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xa568
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xa558
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x5819
        push word 0xd5ba
        push cs
        call FormatPlayerName
        add sp, 0xc
        pop si
        pop di
        leave
        retf
.9:
        cmp byte [curevent], 0x2
        jz short .10
        jmp near .12
.10:
        mov al, [curevent_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x4], ax
        mov al, [curevent_b1]
        mov [bp - 0x2], ax
        imul ax, ax, word 0x2e8
        add ax, 0x9f80
        push ax
        mov al, [curevent_b7]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [curevent_b6]
        push ax
        push strict word str_02d02dSPenalty
        push word 0xd4b8
        call 0x0000:_sprintf
        add sp, 0xa
        push word 0x582f
        imul ax, [bp - 0x2], 0x1c
        add ax, [bp - 0x4]
        imul ax, ax, 0x28
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xa568
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xa558
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x5830
        push word 0xd506
        push cs
        call FormatPlayerName
        add sp, 0xc
        mov bl, [curevent_b3]
        db 0x2A, 0xFF                           ; insn: sub bh, bh
        shl bx, 1
        mov si, [bx + EventFmtPtrs]
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, 0xd542
        push ds
        pop es
        mov cx, 0xffff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        repne scasb
        not cx
        db 0x2B, 0xF9                           ; insn: sub di, cx
        xchg di, si
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        mov al, [curevent_b4]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        mov [bp - 0x6], ax
        cmp ax, 0xff
        jnz short .11
        mov ax, 0xd57e
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov si, str_GameMisconduct
        mov cx, 0x8
        rep movsw
        pop si
        pop di
        leave
        retf
.11:
        push ax
        push strict word str_DMinutes
        push word 0xd57e
        call 0x0000:_sprintf
        add sp, 0x6
        pop si
        pop di
        leave
        retf
        db 0x90
.12:
        cmp byte [curevent], 0x3
        jnz short .15
        mov al, [curevent_b2]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [curevent_b3]
        cbw
        mov [bp - 0x6], ax
        mov al, [curevent_b1]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x8B, 0xF8                           ; insn: mov di, ax
        imul ax, di, word 0x2e8
        add ax, 0x9f80
        push ax
        mov al, [curevent_b6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        mov al, [curevent_b5]
        push ax
        push strict word str_02d02dSInjury
        push word 0xd4b8
        call 0x0000:_sprintf
        add sp, 0xa
        push word 0x5860
        imul ax, di, 0x1c
        db 0x03, 0xC6                           ; insn: add ax, si
        imul ax, ax, 0x28
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, 0xa568
        push ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        add cx, 0xa558
        push cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        push word 0x5861
        push word 0xd506
        push cs
        call FormatPlayerName
        add sp, 0xc
        cmp word [bp - 0x6], 0x0
        jng short .13
        push strict word str_GoneForTheGame
        jmp short .14
        db 0x90
.13:
        push strict word str_GoneFor1Period
.14:
        push word 0xd542
        call 0x0000:_sprintf
        add sp, 0x4
.15:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PostGoalEvent                                              2352:0750  94 PC
; Event type 1.
;
; Takes 7 words of stack arguments. Calls LoadTeamPPV, BuildEventLines, CloseTextOverlay. Far routine
; (retf).
;-----------------------------------------------------------------------------
PostGoalEvent:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov byte [curevent], 0x1
        mov al, [bp + 0x6]
        mov [curevent_b1], al
        mov al, [bp + 0x8]
        mov [curevent_b2], al
        mov al, [bp + 0xa]
        mov [curevent_b3], al
        mov al, [bp + 0xc]
        mov [curevent_b4], al
        mov al, [bp + 0xe]
        mov [curevent_b5], al
        mov al, [curperiod]
        mov [curevent_b6], al
        mov al, [bp + 0x10]
        mov [curevent_b7], al
        mov al, [bp + 0x12]
        mov [curevent_b8], al
        imul bx, [bp + 0x6], word 0xd6
        mov si, [bx + hmtmgoalie]
        and si, 0x1
        mov bx, [bx + hmtmlines]
        mov al, [bx + si + 0x24]
        mov [curevent_b9], al
        cmp word [bp + 0x6], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        imul bx, ax, word 0xd6
        mov si, [bx + hmtmgoalie]
        and si, 0x1
        mov bx, [bx + hmtmlines]
        mov al, [bx + si + 0x24]
        mov [curevent_b10], al
        test byte [gmode], 0x10
        jnz short .3
        mov bx, [gsumqcount]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        lea di, [bx + gsumqueue]
        mov si, 0xb06c
        mov ax, ds
        mov es, ax
        mov cx, 0x6
        rep movsw
        inc word [gsumqcount]
        cmp word [gsumqcount], 0x8
        jl short .1
        dec word [gsumqcount]
.1:
        cmp word [bp + 0x6], 0x0
        jz short .2
        inc byte [gsumtail_goals2]
        jmp short .3
.2:
        inc byte [gsumtail_goals1]
.3:
        cmp word [bp + 0x6], 0x0
        jnz short .4
        push 0x1
        call 0x226F:LoadTeamPPV
        add sp, 0x2
.4:
        push cs
        call BuildEventLines
        call 0x226F:CloseTextOverlay
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        mov ax, 0xb078
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov si, 0xb06c
        push ds
        pop es
        mov cx, 0x6
        rep movsw
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; PostPenaltyEvent                                           2352:083E  94 PC
; Event type 2.
;
; Takes 7 words of stack arguments. Calls BuildEventLines, CloseTextOverlay, AnnouncePenalty. Far
; routine (retf).
;-----------------------------------------------------------------------------
PostPenaltyEvent:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [gmode], 0x10
        jz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.1:
        mov byte [curevent], 0x2
        mov al, [bp + 0x6]
        mov [curevent_b1], al
        mov al, [bp + 0x8]
        mov [curevent_b2], al
        mov al, [bp + 0xa]
        mov [curevent_b3], al
        mov al, [bp + 0xc]
        mov [curevent_b4], al
        mov al, [curperiod]
        mov [curevent_b5], al
        mov al, [bp + 0xe]
        mov [curevent_b6], al
        mov al, [bp + 0x10]
        mov [curevent_b7], al
        mov bx, [gsumqcount]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        lea di, [bx + gsumqueue]
        mov si, 0xb06c
        mov ax, ds
        mov es, ax
        mov cx, 0x6
        rep movsw
        inc word [gsumqcount]
        cmp word [gsumqcount], 0x8
        jl short .2
        dec word [gsumqcount]
.2:
        push cs
        call BuildEventLines
        call 0x226F:CloseTextOverlay
        mov ax, [PadRepeatOn]
        mov [gameframe], ax
        mov word [PadRepeatOn], 0x0
        cmp word [CrowdSound], 0x190
        jng short .3
        mov word [CrowdSound], 0x190
.3:
        cmp word [bp + 0x6], 0x0
        jz short .4
        mov si, [VisTeamNum]
        jmp short .5
.4:
        mov si, [HomeTeamNum]
.5:
        cmp si, 0x18
        jl short .6
        inc si
        inc si
.6:
        push word [bp + 0x12]
        push word [bp + 0x10]
        push word [bp + 0xe]
        mov bx, [bp + 0xa]
        shl bx, 1
        push word [bx + PenaltyNamePtrs]
        push word [bp + 0xc]
        imul ax, [bp + 0x6], 0x1c
        add ax, [bp + 0x8]
        imul bx, ax, 0x28
        mov al, [bx + hmrosterjersey]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        shl si, 1
        push word [si + TeamNameClips]
        call 0x0EDC:AnnouncePenalty
        add sp, 0xe
        mov ax, [gameframe]
        mov [PadRepeatOn], ax
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PostInjuryEvent                                            2352:0924  94 PC
; Event type 3.
;
; Takes 5 words of stack arguments. Calls BuildEventLines, CloseTextOverlay. Far routine (retf).
;-----------------------------------------------------------------------------
PostInjuryEvent:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        test byte [gmode], 0x10
        jz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.1:
        mov byte [curevent], 0x3
        mov al, [bp + 0x6]
        mov [curevent_b1], al
        mov al, [bp + 0x8]
        mov [curevent_b2], al
        mov al, [bp + 0xa]
        mov [curevent_b3], al
        mov al, [curperiod]
        mov [curevent_b4], al
        mov al, [bp + 0xc]
        mov [curevent_b5], al
        mov al, [bp + 0xe]
        mov [curevent_b6], al
        mov bx, [gsumqcount]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        lea di, [bx + gsumqueue]
        mov si, 0xb06c
        mov ax, ds
        mov es, ax
        mov cx, 0x6
        rep movsw
        inc word [gsumqcount]
        cmp word [gsumqcount], 0x8
        jl short .2
        dec word [gsumqcount]
.2:
        push cs
        call BuildEventLines
        call 0x226F:CloseTextOverlay
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; NullCallback0C                                             2352:0998  94 PC
; A lone retf between PostInjuryEvent and ChkScorerMilestone.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
NullCallback0C:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ChkScorerMilestone                                         2352:099A  94 PC
; Scorer season / game totals after a goal.
;
; Calls QueueDeferredCall. Far routine (retf).
;-----------------------------------------------------------------------------
ChkScorerMilestone:
        enter 0xe, 0x0
        push di
        push si
        mov bx, [pucky]
        cmp word [bx], 0x0
        jnl short .1
        mov ax, 0x1
        jmp short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
.2:
        mov cl, [gmode]
        and cl, 0x2
        cmp cl, 0x1
        db 0x1B, 0xC9                           ; insn: sbb cx, cx
        inc cx
        db 0x33, 0xC8                           ; insn: xor cx, ax
        mov [bp - 0x2], cx
        test byte [CrowdState], 0x20
        jnz short .3
        jmp near .29
.3:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        shl bx, 1
        cmp byte [bx + scorerflags], 0x0
        jz short .4
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        shl bx, 1
        cmp byte [bx + scorerflags2], 0x0
        jz short .4
        jmp near .29
.4:
        mov word [bp - 0x6], 0x0
        imul bx, cx, word 0xd6
        mov [bp - 0x8], bx
        mov di, [bx + hmtmtouch1]
        and di, 0xff
        cmp di, 0x19
        jl short .5
        mov si, [bp - 0x4]
        mov ax, 0x3a0b
        mov es, ax
        jmp near .16
        db 0x90
.5:
        mov ax, 0x3a0b
        mov es, ax
        imul si, cx, 0x19
        mov [bp - 0xc], si
        db 0x03, 0xF7                           ; insn: add si, di
        mov [bp - 0xa], si
        shl si, byte 0x4
        mov bx, [es:si + HomePlStats]
        mov ax, [es:si + HomePlStats_w2]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov [bp - 0x4], ax
        cmp word [es:si + HomePlStats], 0x3
        jnz short .8
        mov word [bp - 0x6], 0x1
.6:
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov [bp - 0x4], dx
.7:
        mov si, [bp - 0x4]
        jmp near .16
.8:
        cmp word [DbSaveMode], 0x0
        jz short .7
        test byte [AnnouncerFlags], 0x2
        jnz short .9
        jmp near .14
.9:
        mov si, [bp - 0xa]
        shl si, byte 0x3
        mov [bp - 0xe], si
        mov ax, [si + plstatsoff3]
        add ax, [si + plstatsoff]
        db 0x03, 0xC3                           ; insn: add ax, bx
        dec ax
        jnz short .10
        mov word [bp - 0x6], 0x6
        mov si, 0x1
        jmp near .16
.10:
        add bx, [si + plstatsoff3]
        cmp bx, 0x32
        jl short .11
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, 0x32
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .11
        mov word [bp - 0x6], 0x2
        jmp short .6
.11:
        mov ax, [si + plstatsrecs]
        add [bp - 0x4], ax
        cmp word [bp - 0x4], 0x64
        jl short .12
        mov ax, [bp - 0x4]
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .12
        mov word [bp - 0x6], 0x4
        jmp short .7
        db 0x90
.12:
        add bx, [si + plstatsoff]
        cmp bx, 0x64
        jl short .13
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .13
        mov word [bp - 0x6], 0x3
        jmp near .6
        db 0x90
.13:
        mov si, [bp - 0x4]
        mov bx, [bp - 0xe]
        add si, [bx + plstatsoff2]
        cmp si, 0x64
        jl short .16
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .16
        mov word [bp - 0x6], 0x5
        jmp short .16
.14:
        mov si, [bp - 0xa]
        shl si, byte 0x3
        mov [bp - 0xe], si
        add bx, [si + plstatsoff3]
        cmp bx, 0xa
        jl short .15
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, 0xa
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .15
        mov word [bp - 0x6], 0x7
        jmp near .6
.15:
        mov si, [bp - 0x4]
        mov bx, [bp - 0xe]
        add si, [bx + plstatsrecs]
        cmp si, 0x14
        jl short .16
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x14
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .16
        mov word [bp - 0x6], 0x8
.16:
        cmp word [DbSaveMode], 0x0
        jnz short .17
        jmp near .28
.17:
        cmp word [bp - 0x6], 0x0
        jz short .18
        jmp near .28
.18:
        mov bx, [bp - 0x8]
        mov di, [bx + hmtmtouch2]
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .19
        jmp near .28
.19:
        cmp di, 0x19
        jl short .20
        jmp near .28
.20:
        imul bx, [bp - 0x2], 0x19
        mov [bp - 0xc], bx
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bp - 0xa], bx
        shl bx, byte 0x4
        mov si, [es:bx + HomePlStats_w2]
        add si, [es:bx + HomePlStats]
        mov al, [AnnouncerFlags]
        and al, 0x2
        jz short .22
        mov bx, [bp - 0xa]
        shl bx, byte 0x3
        mov [bp - 0xe], bx
        add si, [bx + plstatsrecs]
        cmp si, 0x64
        jl short .21
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .21
        mov word [bp - 0x6], 0x4
        jmp short .23
.21:
        add si, [bx + plstatsoff2]
        cmp si, 0x64
        jl short .23
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .23
        mov word [bp - 0x6], 0x5
        jmp short .23
.22:
        mov bx, [bp - 0xa]
        shl bx, byte 0x3
        add si, [bx + plstatsrecs]
        cmp si, 0x14
        jl short .23
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x14
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .23
        mov word [bp - 0x6], 0x8
.23:
        cmp word [bp - 0x6], 0x0
        jz short .24
        jmp near .28
.24:
        mov bx, [bp - 0x8]
        mov di, [bx + hmtmtouch3]
        db 0x0B, 0xFF                           ; insn: or di, di
        jnl short .25
        jmp near .28
.25:
        cmp di, 0x19
        jnl short .28
        mov bx, [bp - 0xc]
        db 0x03, 0xDF                           ; insn: add bx, di
        mov [bp - 0xa], bx
        shl bx, byte 0x4
        mov si, [es:bx + HomePlStats_w2]
        add si, [es:bx + HomePlStats]
        mov al, [AnnouncerFlags]
        and al, 0x2
        jz short .27
        mov bx, [bp - 0xa]
        shl bx, byte 0x3
        mov [bp - 0xe], bx
        add si, [bx + plstatsrecs]
        cmp si, 0x64
        jl short .26
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .26
        mov word [bp - 0x6], 0x4
        jmp short .28
        db 0x90
.26:
        add si, [bx + plstatsoff2]
        cmp si, 0x64
        jl short .28
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x64
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .28
        mov word [bp - 0x6], 0x5
        jmp short .28
.27:
        mov bx, [bp - 0xa]
        shl bx, byte 0x3
        add si, [bx + plstatsrecs]
        cmp si, 0x14
        jl short .28
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, 0x14
        cwd
        idiv cx
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .28
        mov word [bp - 0x6], 0x8
.28:
        cmp word [bp - 0x6], 0x0
        jz short .29
        push 0x0
        push 0x0
        push 0x0
        push si
        push word [bp - 0x6]
        push di
        push word [bp - 0x2]
        push word 0x1b35
        push strict word ReturnZeroInit2Thunk
        push cs
        call QueueDeferredCall
        add sp, 0x12
        mov word [deferpending], 0x1
        mov word [ovltimer], 0xffff
.29:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; QueueGoalieNote                                            2352:0CB0  94 PC
; Once per goalie, queues a deferred note for the goalie of the penalised player's team.
;
; Calls QueueDeferredCall. Far routine (retf).
;-----------------------------------------------------------------------------
QueueGoalieNote:
        enter 0x2, 0x0
        push di
        push si
        test byte [CrowdState], 0x20
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
        db 0x90
.2:
        cmp word [goalienotebits], 0x3f
        jz short .1
        cmp word [penaltysc], 0x0
        jl short .1
        mov si, [penaltysc]
        shl si, byte 0x7
        add si, 0xb50e
        mov al, [si + 0x44]
        and al, 0x40
        cmp al, 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        inc ax
        mov [bp - 0x2], ax
        mov bx, [si + 0x60]
        mov cl, [bx + 0x24]
        mov di, 0x1
        shl di, cl
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        shl di, byte 0x3
.3:
        test [goalienotebits], di
        jnz short .1
        or [goalienotebits], di
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        mov al, [si + 0x47]
        cbw
        push ax
        push word [bp - 0x2]
        push word 0x1b35
        push strict word ReturnZeroInitThunk
        push cs
        call QueueDeferredCall
        add sp, 0x12
        mov ax, 0x1
        mov [deferpending], ax
        pop si
        pop di
        leave
        retf
        db 0x90
