; The previous segment ends in the middle of a near call. These four
; bytes are the last byte of that call, then leave / retf, and a nop.
        db 0xFE
        leave
        retf
        nop

; Startup calls these two. Each is only a far return.
NullStartup4:
        retf
        nop
NullStartup6:
        retf
        nop

; _main: the far call from MscStartup lands here. It is not a lone retf. It compares two long results with
; fixed limits, prints the shortfall in 1024-byte units and exits if either is low, then calls the other
; segments. 320 and 200 are passed through as a pair.
;
; Paragraph 0x3415 is the one the overlay startup preloads. The last bytes are the start of a far call that
; finishes in the next segment.
_main:
        enter 0x24, 0
        push di
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        push 0x12c
        call 0x14DB:InitHeap
        add sp, 2
        mov word [bp-4], ax
        mov word [bp-2], dx
        cmp dx, 3
        jg short .2
        jl short .1
        cmp ax, 0x2c00
        jae short .2
.1:
        push si
        push 0x400
        mov ax, 0x2fff
        mov dx, 3
        sub ax, word [bp-4]
        sbb dx, word [bp-2]
        push dx
        push ax
        call 0x0000:__aFldiv
        push dx
        push ax
        push 0x42e
        call 0x0000:_printf
        add sp, 6
        mov si, 1
.2:
        push 0x40
        push 0
        call 0x03A3:EmsInit
        add sp, 4
        mov word [bp-4], ax
        mov word [bp-2], dx
        cmp dx, 0x1f
        jg short .4
        jl short .3
        cmp ax, 0xfc00
        jae short .4
.3:
        push 0
        push 0x400
        mov ax, 0xffff
        mov dx, 0x1f
        sub ax, word [bp-4]
        sbb dx, word [bp-2]
        push dx
        push ax
        call 0x0000:__aFldiv
        push dx
        push ax
        push 0x47e
        call 0x0000:_printf
        add sp, 6
        mov si, 1
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        je short .5
        call 0x0000:_exit
.5:
        call 0x0FEF:InitGraphics
        call 0x03A3:HookInt8
        mov word [PadRepeatOn], 0
        push 0x969
        push 0x3fe
        call 0x03A3:AllocSlot
        add sp, 4
        push 0
        call 0x0FEF:SetStartPage
        add sp, 2
        mov bx, 0x7570
        mov es, word [DgroupSegA]
        mov word [bp-0x24], bx
        mov word [bp-0x22], es
        mov ax, word [es:bx+2]
        or ax, word [es:bx]
        je short .6
        push word [es:bx+2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 4
        les bx, [bp-0x24]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [es:bx+2], ax
        mov word [es:bx], ax
.6:
        push 0
        push 2
        push 4
        push 0xc8
        push 0x140
        push 0xc8
        push 0x140
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        push 0xc8
        call 0x0FEF:SetStartPage
        add sp, 2
        or byte [InputFlags], 8
        push 0xc8
        push 0x140
        call 0x03A3:MouseOpen
        add sp, 4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .7
        or byte [InputFlags], 1
.7:
        call 0x03A3:ReadPots
        mov word [bp-6], ax
        test byte [PotButtons], 3
        je short .9
        cmp word [Pot1X], 0
        jne short .8
        cmp word [Pot1Y], 0
        je short .9
.8:
        or byte [InputFlags], 2
        call 0x03A3:InitStick1
        call 0x1508:CalibrateLeftStick
        mov word [StickPresent], 1
.9:
        test byte [PotButtons], 0xc
        je short .11
        cmp word [Pot2X], 0
        jne short .10
        cmp word [Pot2Y], 0
        je short .11
.10:
        or byte [InputFlags], 4
        call 0x03A3:InitStick2
        call 0x1508:CalibrateRightStick
        mov word [StickPresent2], 1
.11:
        call 0x0BFE:InputInit
        lea ax, [bp-6]
        push ax
        push ax
        push ax
        call 0x03A3:MouseRead
        add sp, 6
        push 0xd90
        push 0x14b8
        call 0x03A3:HookCrit
        add sp, 4
        push 0x3701                             ; segment of the team choice text far data
        push 0xbd0
        push ds
        push 0x4be
        push 0
        push 0
        lea ax, [bp-0x20]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push 0
        lea ax, [bp-0x20]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 4
        mov word [MemBlock1Off], ax
        mov word [MemBlock1Seg], dx
        push 0x4c7
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 6
        mov word [DialogData], ax
        mov word [DialogDataSeg], dx
        push 0
        push 0x4cc
        call 0x149D:LoadRawHeader
        add sp, 4
        mov word [HeapSizeLo], ax
        mov word [HeapSizeHi], dx
        push 0
        push 0x4d9
        call 0x149D:LoadRawHeader
        add sp, 4
        mov word [MemBlock2Off], ax
        mov word [MemBlock2Seg], dx
        push 0
        push 0x4e4
        call 0x149D:LoadRawHeader
        add sp, 4
        mov word [MemBlock3Off], ax
        mov word [MemBlock3Seg], dx
        push word [HeapSizeHi]
        push word [HeapSizeLo]
        call 0x03A3:UseCharSeg
        add sp, 4
        lea ax, [bp-8]
        push ax
        push 0x4ef
        call 0x0CD1:OpenReadShared
        add sp, 4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .14
        push 0x62
        push -1
        push -1
        push 0x3415                             ; segment of the db files far data
        db 0x68, 0x00, 0x00                     ; insn: push 0
        push word [bp-8]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .12
        push 0x4f8
        call 0x0F4A:FatalError
        add sp, 2
.12:
        lea ax, [bp-8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .13
        jmp near .22
.13:
        push 0x4fb
        call 0x0F4A:FatalError
        add sp, 2
        jmp near .22
.14:
        test byte [InputFlags], 2
        je short .15
        mov ax, 0x3415                          ; segment of the db files far data
        mov es, ax
        mov word [es:exhstate + 0x5A], 2
        jmp short .19
        nop
.15:
        test byte [InputFlags], 4
        je short .16
        mov ax, 0x3415                          ; segment of the db files far data
        mov es, ax
        mov word [es:exhstate + 0x5A], 4
        jmp short .19
        nop
.16:
        test byte [InputFlags], 8
        je short .17
        mov ax, 0x3415                          ; segment of the db files far data
        mov es, ax
        mov word [es:exhstate + 0x5A], 8
        jmp short .19
        nop
.17:
        test byte [InputFlags], 1
        je short .18
        mov ax, 0x3415                          ; segment of the db files far data
        mov es, ax
        mov word [es:exhstate + 0x5A], 1
        jmp short .19
        nop
.18:
        mov ax, 0x3415                          ; segment of the db files far data
        mov es, ax
        mov word [es:exhstate + 0x5A], 0x10
.19:
        mov word [es:exhstate + 0x5C], 0x10
        mov word [es:exhstate + 0x5E], 0
        mov word [es:exhstate + 0x60], 1
        cmp word [es:exhstate + 0x5A], 0x10
        je short .20
        mov ax, 9
        jmp short .21
.20:
        mov ax, 0xffff
.21:
        mov word [es:exhstate + 0x56], ax
        mov word [es:exhstate + 0x58], 0xfffe
.22:
        push 0x3415                             ; segment of the db files far data
        db 0x68, 0x00, 0x00                     ; insn: push 0
        call 0x1B35:LoadModeStateThunk
        add sp, 4
        call 0x1B35:ReloadSoundConfigThunk
        call 0x1B35:TitleScreenThunk
        push 0
        push 0
        push 0x300
        push 0x4fe
        call 0x14DB:AllocRecData
        add sp, 8
        mov word [bp-2], dx
        push dx
        push ax
        push 0x100
        push 0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x0FEF:GetPaletteFar
        add sp, 8
        push 0x10
        push di
        push si
        push 1
        call 0x1B35:FadePaletteInThunk
        add sp, 8
        push di
        push si
        call 0x06E1:FindUnlink
        add sp, 4
        lea ax, [bp-0xc]
        push ax
        call 0x0000:_dos_gettime
        add sp, 2
        mov al, byte [bp-9]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        push ax
        call 0x0000:_srand
        add sp, 2
        call 0x1B35:MainDeskLoopThunk
        push 0
        push 0
        push 0x300
        push 0x503
        call 0x14DB:AllocRecData
        add sp, 8
        push dx
        push ax
        push 0x100
        push 0
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x0FEF:GetPaletteFar
        add sp, 8
        push 0x10
        push di
        push si
        push 1
        call 0x1B35:FadePaletteInThunk
        add sp, 8
        call 0x0BFE:InputInit
        call 0x1B35:GoodnightScreenThunk
        push di
        push si
        push 0x100
        push 0
        call 0x0FEF:GetPaletteFar
        add sp, 8
        push 0x10
        push di
        push si
        push 1
        call 0x1B35:FadePaletteInThunk
        add sp, 8
        call 0x0837:NullFar

; The far call continues in the next segment. Those bytes complete it as
; a call to _exit.
        db 0x9A, 0x87
