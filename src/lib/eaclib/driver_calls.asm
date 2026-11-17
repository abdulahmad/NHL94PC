; EA sound library: loads the sound driver file and calls its entry points (init, play, stop and the
; other numbered functions). The first bytes finish CopyEventBytes from the file before.

;-----------------------------------------------------------------------------
; CopyEventBytesTail                                         1844:0000  EACLIB
; End of CopyEventBytes.
;-----------------------------------------------------------------------------
CopyEventBytesTail:
        mov es, [bp + 0xc]
        mov al, [es:si]
        mov [di], al
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadSoundDriver                                            1844:000E  EACLIB
; Loads a driver from the game folder or c:\eaclib, "Couldn't resolve sound
; driver".
;-----------------------------------------------------------------------------
LoadSoundDriver:
        enter 0x8, 0x0
        push di
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        push 0x0
        push word [bp + 0x6]
        call 0x14B8:LoadPackedHeader0
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .2
        push word [bp + 0x6]
        push str_CEaclibS
        push word 0x9046
        call 0x0000:_sprintf
        add sp, 0x6
        push 0x0
        push word 0x9046
        call 0x14B8:LoadPackedHeader0
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .2
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        jmp near .5
.2:
        push word [bp - 0x6]
        push si
        imul ax, [DriverCount], 0x38
        add ax, 0x8fd6
        push ax
        call 0x1880:LinkDriver
        add sp, 0x6
        imul bx, [DriverCount], 0x38
        call far [bx + DrvTableInit]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        push dx
        push ax
        imul bx, [DriverCount], 0x38
        call far [bx + DrvTableCall04]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        push word [bp - 0x6]
        push si
        call 0x06E1:FindUnlink
        add sp, 0x4
        jmp short .1
.3:
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word 0x16f2
        push word str_Bru_9
        push word 0x16f2
        push word 0x87c
        imul bx, [DriverCount], 0x38
        call far [bx + DrvTableCall08]
        mov bx, [DriverCount]
        shl bx, byte 0x2
        mov ax, [bp - 0x6]
        mov [bx + DrvTableName], si
        mov [bx + DrvTableSeg], ax
        push 0x3
        imul bx, [DriverCount], 0x38
        call far [bx + DrvTableNeedsService]
        mov bx, [DriverCount]
        shl bx, byte 0x2
        mov [bx + DriverTypes], ax
        mov [bx + DriverEntrySeg], dx
        push 0x7
        imul bx, [DriverCount], 0x38
        call far [bx + DrvTableNeedsService]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        cmp di, 0x64
        jnc short .4
        mov al, [DriverCount]
        mov [DriverServiceIdx], al
        mov [DriverName], di
.4:
        inc word [DriverCount]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, [bp - 0x6]
.5:
        pop ds
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrvStub1                                                   1844:0110  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub1:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvInit                                                    1844:0118  EACLIB
; Driver table entry +0.
;-----------------------------------------------------------------------------
DrvInit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableInit]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvCall04                                                  1844:0130  EACLIB
; Driver table entry +4.
;-----------------------------------------------------------------------------
DrvCall04:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableCall04]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvCall08                                                  1844:014E  EACLIB
; Driver table entry +8.
;-----------------------------------------------------------------------------
DrvCall08:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0x12]
        push word [bp + 0x10]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableCall08]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvShutdown                                                1844:0178  EACLIB
; Driver table entry +0Ch, used at shutdown.
;-----------------------------------------------------------------------------
DrvShutdown:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableShutdown]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvCall10                                                  1844:0190  EACLIB
; Driver table entry +10h.
;-----------------------------------------------------------------------------
DrvCall10:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableCall10]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvService                                                 1844:01A8  EACLIB
; Driver table entry +14h, called from SeqService.
;-----------------------------------------------------------------------------
DrvService:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableService]
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvNeedsService                                            1844:01C0  EACLIB
; Driver table entry +18h, asked before DrvService.
;-----------------------------------------------------------------------------
DrvNeedsService:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0x8]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableNeedsService]
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrvLoadBank                                                1844:01DC  EACLIB
; Driver table entry +1Ch, called before loading a song.
;-----------------------------------------------------------------------------
DrvLoadBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0x8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableLoadBank]
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrvStub2                                                   1844:01FE  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub2:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvStub3                                                   1844:0206  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub3:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvStub4                                                   1844:020E  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub4:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvStub5                                                   1844:0216  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub5:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvStub6                                                   1844:021E  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub6:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvStub7                                                   1844:0226  EACLIB
; Empty driver call.
;-----------------------------------------------------------------------------
DrvStub7:
        push ds
        mov ax, DGROUP
        mov ds, ax
        pop ds
        retf

;-----------------------------------------------------------------------------
; DrvSendMidi                                                1844:022E  EACLIB
; Driver table entry +2Ch, note messages get a transpose of 18h.
;-----------------------------------------------------------------------------
DrvSendMidi:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov al, [DriverCount]
        cmp [bp + 0x6], al
        ja short .3
        mov si, [bp + 0xa]
        mov es, [bp + 0xc]
        mov al, [es:si]
        and al, 0xf0
        cmp al, 0x80
        jz short .1
        mov al, [es:si]
        and al, 0xf0
        cmp al, 0x90
        jnz short .2
.1:
        add byte [es:si + 0x1], 0x18
.2:
        push word [bp + 0x8]
        push word [bp + 0xc]
        push si
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTableSendMidi]
.3:
        pop ds
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; DrvLinearToFar                                             1844:0274  EACLIB
; Callback for drivers: LinearToFarRegs.
;-----------------------------------------------------------------------------
DrvLinearToFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        mov ax, [bp + 0x8]
        mov dx, [bp + 0xa]
        call 0x03A3:LinearToFarRegs
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrvEmsMap                                                  1844:028C  EACLIB
; Callback for drivers: EmsMapFrame.
;-----------------------------------------------------------------------------
DrvEmsMap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrvPlaySample                                              1844:02A6  EACLIB
; Starts a digital sample (EMS or conventional) through the driver.
;-----------------------------------------------------------------------------
DrvPlaySample:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        test byte [bp + 0xe], 0x80
        jz short .1
        push word [bp + 0x8]
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        add ax, [bp + 0xa]
        adc dx, [bp + 0xc]
        push dx
        push ax
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x1a]
        push word [bp + 0x18]
        push word [bp + 0x1e]
        push word [bp + 0x1c]
        push word 0x1844
        push word 0x28c
        jmp short .2
.1:
        push word [bp + 0x8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        call 0x03A3:FarToLinear
        add sp, 0x4
        add ax, [bp + 0x10]
        adc dx, [bp + 0x12]
        push dx
        push ax
        push word [bp + 0x16]
        push word [bp + 0x14]
        push word [bp + 0x1a]
        push word [bp + 0x18]
        push word [bp + 0x1e]
        push word [bp + 0x1c]
        push word 0x1844
        push word 0x274
.2:
        push word [bp + 0x20]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTablePlaySample]
        pop ds
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrvPlayRecSample                                           1844:0324  EACLIB
; DrvPlaySample for a heap record.
;-----------------------------------------------------------------------------
DrvPlayRecSample:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        mov ax, DGROUP
        mov ds, ax
        push word [bp + 0xc]
        push word [bp + 0xa]
        call 0x06E1:RecFlag + 0x1560            ; RecFlag (0837:0000), through heap's paragraph
        add sp, 0x4
        test al, 0x80
        jz short .1
        push word [bp + 0x8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        call 0x06E1:RawBase
        add sp, 0x4
        add ax, [bp + 0xe]
        adc dx, [bp + 0x10]
        push dx
        push ax
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x18]
        push word [bp + 0x16]
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word 0x1844
        push word 0x28c
        jmp short .2
.1:
        push word [bp + 0x8]
        push word [bp + 0xc]
        push word [bp + 0xa]
        call 0x06E1:RecBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:FarToLinear
        add sp, 0x4
        add ax, [bp + 0xe]
        adc dx, [bp + 0x10]
        push dx
        push ax
        push word [bp + 0x14]
        push word [bp + 0x12]
        push word [bp + 0x18]
        push word [bp + 0x16]
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word 0x1844
        push word 0x274
.2:
        push word [bp + 0x1e]
        mov al, [bp + 0x6]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        imul bx, ax, 0x38
        call far [bx + DrvTablePlaySample]
        pop ds
        leave
        retf
        db 0x90
