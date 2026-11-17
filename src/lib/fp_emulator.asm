; Microsoft C floating-point emulator: the INT 34h-3Dh handlers that run 8087 instructions in
; software, or patch them to real ones when a coprocessor is present.
EmuDataSeg:                                     ; paragraph of the emulator's data (runtime_state); every
                                                ; entry loads DS from here
        dw 0x3996
        times 14 db 0
FpSignature:                                    ; 'MSEM87' and a version word, the emulator's signature
        db 'MSEM87'
        dw 6
        db 'gfw...GW'
FpFuncTable:                                    ; word; FpMath's function table, by index 0-12
        dw FpInit
        dw FpReset
        dw FpTerm
        dw FpSetHandler
        dw FpLoadCw
        dw FpGetCw
        dw FpRoundInt
        dw FpToLong
        dw FpGetStatus
        dw FpReset.clear
        dw FpStackDepth
        dw FpHave87
        dw FpSetMode

;-----------------------------------------------------------------------------
; FpMath                                                        18B9:003A  MSC
; Far entry: calls the function whose index is in BX through FpFuncTable,
; with DS set to the emulator's data.
;-----------------------------------------------------------------------------
FpMath:
        cmp bx, 0xc
        ja short FpMathBadIndex
        shl bx, 1
        push ds
        mov ds, [cs:EmuDataSeg]
        call [cs:bx + FpFuncTable]
        pop ds
.1:
        retf

;-----------------------------------------------------------------------------
; FpMathBadIndex                                                18B9:004E  MSC
; FpMath with an index above 12 returns -1.
;-----------------------------------------------------------------------------
FpMathBadIndex:
        or ax, strict word 0xffff
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short FpMath.1

FpNo87Env:                                      ; "NO87=", the environment variable that turns the coprocessor
                                                ; off; FpInit prints the text after it
        db 'NO87='
FpCrLf:                                         ; CR LF printed after the NO87= message
        db 0x0D, 0x0A

;-----------------------------------------------------------------------------
; FpInit                                                        18B9:005C  MSC
; Function 0: reads NO87= from the environment, detects an 8087, hooks the
; vectors.
;-----------------------------------------------------------------------------
FpInit:
        push ss
        push ds
        mov ax, FpSavedSs
        push ax
        call 0x0000:StoreWord
        push ds
        mov ax, FpMachineMode
        push ax
        call 0x0000:StoreZero
        push ds
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
        mov es, si
        push cs
        pop ds
        db 0x33, 0xFF                           ; insn: xor di, di
        cld
.1:
        cmp byte [es:di], 0x0
        jz short .4
        mov cx, 0x5
        mov si, FpNo87Env
        repe cmpsb
        jz short .2
        mov cx, 0x7fff
        db 0x32, 0xC0                           ; insn: xor al, al
        repne scasb
        jz short .1
        jmp short .4
.2:
        mov cx, 0x7fff
        mov al, 0x20
        repe scasb
        dec di
        mov dl, [es:di]
        db 0x0A, 0xD2                           ; insn: or dl, dl
        jz short .3
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, 0x7fff
        db 0x8B, 0xDF                           ; insn: mov bx, di
        repne scasb
        dec di
        db 0x2B, 0xFB                           ; insn: sub di, bx
        db 0x8B, 0xCF                           ; insn: mov cx, di
        db 0x8B, 0xFB                           ; insn: mov di, bx
        push ax
        db 0x8B, 0xC4                           ; insn: mov ax, sp
        mov bx, 0x1
        push bx
        push es
        push di
        push cx
        push ss
        push ax
        call 0x0000:WriteFar
        db 0x8B, 0xC4                           ; insn: mov ax, sp
        mov bx, 0x1
        push bx
        push cs
        mov di, FpCrLf
        push di
        mov bx, 0x2
        push bx
        push ss
        push ax
        call 0x0000:WriteFar
        pop bx
.3:
        pop ds
        mov byte [Fp87Present], 0x0
        jmp short .13
        db 0x90
.4:
        pop ds
        cmp word [FpMachineMode], 0x0
        jnz short .10
        fninit
        push cx
        mov cx, 0x14
.5:
        loop .5
        pop cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [FpProbeWord], ax
        fnstcw [FpProbeWord]
        push cx
        mov cx, 0x14
.6:
        loop .6
        pop cx
        and word [FpProbeWord], 0xf3f
        cmp word [FpProbeWord], 0x33f
        jnz short .8
        fnstsw [FpProbeWord]
        push cx
        mov cx, 0x14
.7:
        loop .7
        pop cx
        inc ax
        test word [FpProbeWord], 0xb8bf
.8:
        jz short .9
        db 0x33, 0xC0                           ; insn: xor ax, ax
.9:
        mov [Fp87Present], al
        jmp short .11
.10:
        push ds
        push strict word Fp87Present
        push 0x3
        push 0x0
        call 0x0000:StoreOne
.11:
        cmp byte [Fp87Present], 0x0
        jz short .13
        cmp word [FpMachineMode], 0x0
        jnz short .12
        call FpHookNmi
        jnc short .13
        mov ax, 0xfffe
        stc
        ret
.12:
        push 0x10
        push cs
        push word Fp87Exception
        push ds
        push strict word FpSavedVectors + 4
        call 0x0000:RetPop10
.13:
        cmp word [FpMachineMode], 0x0
        jnz short .14
        call FpHookVectors
        jmp short .15
.14:
        cmp byte [Fp87Present], 0x0
        jnz short .15
        push 0x7
        push cs
        push word FpEmuSegIntAlt
        push ds
        push strict word FpSavedVectors
        call 0x0000:RetPop10
.15:
        call FpReset
        mov ax, 0x1332
        call FpLoadCw
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [FpErrHandler], ax
        mov [FpErrHandler + 2], ax
        mov ax, FpEmuChain
        cmp word [FpMachineMode], 0x0
        jz short .16
        mov ax, FpEmuChainEsc
.16:
        mov [FpExitVector], ax
        mov al, [Fp87Present]
        cbw
        ret

;-----------------------------------------------------------------------------
; FpTerm                                                        18B9:01AE  MSC
; Function 2: restores the interrupt vectors.
;-----------------------------------------------------------------------------
FpTerm:
        cmp word [FpMachineMode], 0x0
        jnz short .2
        call FpUnhookVectors
        cmp byte [Fp87Present], 0x0
        jz short .1
        fninit
        call FpUnhookNmi
.1:
        ret
.2:
        push word [FpSavedSs]
        call 0x0000:RetPop2
        ret

;-----------------------------------------------------------------------------
; FpReset                                                       18B9:01CF  MSC
; Function 1: resets the emulated stack and clears exceptions; .clear is
; function 9, which only clears the exceptions.
;-----------------------------------------------------------------------------
FpReset:
        cmp byte [Fp87Present], 0x0
        jz short .1
        fninit
.1:
        mov ax, [FpStackBase]
        mov [FpStackTop], ax
.clear:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp al, [Fp87Present]
        jz short .2
        wait
        fnclex
.2:
        mov [FpEmuStatus], ax
        mov [FpUserStatus], ax
        ret

;-----------------------------------------------------------------------------
; FpSetHandler                                                  18B9:01F0  MSC
; Function 3: stores the far error handler.
;-----------------------------------------------------------------------------
FpSetHandler:
        mov [FpErrHandler], ax
        mov [FpErrHandler + 2], dx
        ret

;-----------------------------------------------------------------------------
; FpHookVectors                                                 18B9:01F8  MSC
; Saves INT 34h-3Eh and points them at the emulator or the patch handlers.
;-----------------------------------------------------------------------------
FpHookVectors:
        mov cx, 0xb
        mov ax, 0x3534
        mov di, FpSavedVectors
.1:
        int 0x21
        inc ax
        mov [di], bx
        mov [di + 0x2], es
        add di, 0x4
        loop .1
        mov dx, FpEmulate
        mov si, FpEmuSegInt
        mov di, FpEmuWaitInt
        cmp byte [Fp87Present], 0x0
        jz short .2
        mov dx, FpPatchInt
        mov si, FpPatchSegInt
        mov di, FpPatchWaitInt
.2:
        push ds
        push cs
        pop ds
        mov ax, 0x2534
        mov cx, 0x8
.3:
        int 0x21
        inc ax
        loop .3
        db 0x8B, 0xD6                           ; insn: mov dx, si
        int 0x21
        inc ax
        db 0x8B, 0xD7                           ; insn: mov dx, di
        int 0x21
        pop ds
        ret

;-----------------------------------------------------------------------------
; FpUnhookVectors                                               18B9:0240  MSC
; Restores the saved INT 34h-3Eh vectors.
;-----------------------------------------------------------------------------
FpUnhookVectors:
        mov cx, 0xb
        mov ax, 0x2534
        mov di, FpSavedVectors
.1:
        push ds
        lds dx, [di]
        int 0x21
        pop ds
        inc ax
        add di, 0x4
        loop .1
        ret

;-----------------------------------------------------------------------------
; FpStackDepth                                                  18B9:0256  MSC
; Function 10: number of used stack registers.
;-----------------------------------------------------------------------------
FpStackDepth:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        cmp byte [Fp87Present], 0x0
        jz short .3
        sub sp, 0xe
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        wait
        fnstenv [ss:bx]
        wait
        fldcw [ss:bx]
        mov ax, [ss:bx + 0x4]
        add sp, 0xe
        mov cx, 0x8
.1:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        and bx, 0x3
        cmp bx, 0x3
        jz short .2
        inc dx
.2:
        loop .1
.3:
        mov ax, [FpStackTop]
        sub ax, [FpStackBase]
        mov bl, 0xc
        div bl
        db 0x03, 0xC2                           ; insn: add ax, dx
        ret

;-----------------------------------------------------------------------------
; FpHave87                                                      18B9:0295  MSC
; Function 11: 1 when an 8087 is present.
;-----------------------------------------------------------------------------
FpHave87:
        mov al, [Fp87Present]
        cbw
        ret

;-----------------------------------------------------------------------------
; FpSetMode                                                     18B9:029A  MSC
; Function 12: stores a mode word.
;-----------------------------------------------------------------------------
FpSetMode:
        mov [FpSignalMode], ax
        ret

;-----------------------------------------------------------------------------
; FpSetC1                                                       18B9:029E  MSC
; Sets status bit C1.
;-----------------------------------------------------------------------------
FpSetC1:
        or byte [FpOpStatus + 1], 0x2
        cmp byte [Fp87Present], 0x0
        jz short .1
        or ah, 0x2
.1:
        ret

;-----------------------------------------------------------------------------
; FpSetC2                                                       18B9:02AE  MSC
; Sets status bit C2.
;-----------------------------------------------------------------------------
FpSetC2:
        or byte [FpOpStatus + 1], 0x4
        ret

;-----------------------------------------------------------------------------
; FpIret                                                        18B9:02B4  MSC
; A lone iret.
;-----------------------------------------------------------------------------
FpIret:
        iret

;-----------------------------------------------------------------------------
; Fp87ExceptionNext                                             18B9:02B5  MSC
; Fp87Exception for the following instruction.
;-----------------------------------------------------------------------------
Fp87ExceptionNext:
        inc bx
        jmp short Fp87Exception.1

;-----------------------------------------------------------------------------
; Fp87Exception                                                 18B9:02B8  MSC
; Coprocessor exception entry: saves the environment and enters FpException.
;-----------------------------------------------------------------------------
Fp87Exception:
        push ax
        push bp
        sub sp, 0x1c
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        wait
        fnstenv [bp + 0x0]
        mov ax, FpIret
        xchg ax, [bp + 0x20]
        mov [bp + 0x2], ax
        push bx
        push ds
        lds bx, [bp + 0x6]
.1:
        mov ax, [bx]
        add al, 0x28
        jnc short Fp87ExceptionNext
        xchg al, ah
        mov [bp + 0x8], ax
        jmp short FpException.1

;-----------------------------------------------------------------------------
; FpException                                                   18B9:02DE  MSC
; Classifies a pending exception, fixes the result or calls the error
; handler.
;-----------------------------------------------------------------------------
FpException:
        push ax
        push bp
        sub sp, 0x1c
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        fnstenv [bp + 0x0]
        wait
        fnclex
        sti
        push bx
        push ds
.1:
        mov ds, [cs:EmuDataSeg]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, [bp + 0x2]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        cmp word [FpSignalMode], 0x0
        jnz short .2
        or bh, 0x1
.2:
        test bh, 0x1
        jnz short .3
        test al, 0x1
        jz short .3
        or bh, 0x1
        jmp near .11
.3:
        test al, 0x2
        jz short .4
        jmp near FpSkipEmptyRegs.3
.4:
        test bh, 0x4
        jnz short .5
        test al, 0x4
        jz short .5
        or bh, 0x4
        call FpSignalOnce
        jmp short .2
.5:
        test bh, 0x8
        jnz short .6
        test al, 0x8
        jz short .6
        or bh, 0x8
        jmp near FpCheckPrecision
.6:
        mov bl, [FpUserCw]
        or bl, 0xc0
        and bl, 0xfd
        not bl
        db 0x22, 0xC3                           ; insn: and al, bl
        test al, 0x1
        jz short .8
        push ax
        mov ax, [bp + 0x8]
        and ah, 0x7
        cmp ax, 0x1fa
        jnz short .7
        pop ax
        or al, 0x80
        jmp short .8
.7:
        mov ax, [bp + 0x8]
        and ax, 0x338
        cmp ax, 0x100
        pop ax
        jnz short .8
        xor al, 0x1
.8:
        wait
        fnclex
        wait
        fldcw [bp + 0x0]
.9:
        or [FpUserStatus], ax
        pop ds
        pop bx
        add sp, 0x1c
        pop bp
        test ax, 0xbfff
        jnz short .10
        pop ax
        ret
.10:
        push ax
        push bx
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [ss:bx + 0x4]
        mov [ss:bx + 0x6], ax
        pop bx
        pop ax
        add sp, 0x2
        jmp near FpSignal.4
.11:
        push si
        push bx
        push cx
        push dx
        push di
        mov bx, [bp + 0x4]
        mov cx, [bp + 0x2]
        not bx
        db 0x8A, 0xCD                           ; insn: mov cl, ch
        and cl, 0x38
        shr cl, 1
        shr cl, 1
        ror bx, cl
        test bh, 0xc0
        jz short .16
        mov dx, [bp + 0x8]
        xor dx, 0x1e0
        test dl, 0xc0
        jnz short .13
        test dx, 0x120
        jnz short .16
        test dl, 0x10
        jnz short .12
        test dl, 0x8
        jnz short .14
        jmp short .16
        db 0x90
.12:
        cmp dl, 0x12
        jz short .14
        cmp dl, 0x14
        jz short .14
        jmp short .16
        db 0x90
.13:
        test dx, 0x110
        jnz short .16
.14:
        and bh, 0x3f
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .15
        call FpSetC1
.15:
        add si, 0xc
        mov [FpStackTop], si
        wait
        fdecstp
        wait
        fstp tword [si]
        jmp near FpSkipEmptyRegs.2
.16:
        test bl, 0x3
        jz short .17
        jmp short .22
        db 0x90
.17:
        mov dx, [bp + 0x8]
        xor dx, 0x1e0
        test dl, 0xc0
        jz short .18
        test dx, 0x110
        jnz short .18
        jmp short .22
        db 0x90
.18:
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jz short .19
        call FpSkipEmptyRegs
        jmp short .22
        db 0x90
.19:
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .20
        jmp near FpSkipEmptyRegs.1
.20:
        or bl, 0x3
        wait
        fincstp
        wait
        fld tword [si]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .21
        call FpSetC2
.21:
        sub si, 0xc
        mov [FpStackTop], si
.22:
        test bl, 0xc
        jnz short .25
        db 0x8B, 0xF3                           ; insn: mov si, bx
        and si, -0x10
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .23
        wait
        fstp tword [FpTemp0]
        shr bx, 1
        shr bx, 1
        call FpSkipEmptyRegs
        wait
        fld tword [FpTemp0]
        shl bx, 1
        shl bx, 1
        or bl, 0x3
        jmp short .25
.23:
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jz short .25
        or bl, 0xc
        wait
        fincstp
        wait
        fincstp
        wait
        fld tword [si]
        wait
        fdecstp
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .24
        call FpSetC2
.24:
        sub si, 0xc
        mov [FpStackTop], si
.25:
        mov dx, [bp + 0x8]
        xor dx, 0x1e0
        test dl, 0xc0
        jnz short .26
        test dx, 0x120
        jnz short .28
        test dl, 0x10
        jnz short .27
.26:
        jmp short FpSkipEmptyRegs.2
        db 0x90
.27:
        db 0x8A, 0xCA                           ; insn: mov cl, dl
        and cl, 0xf
        mov dx, 0x50c4
        shl dx, cl
        jns short .26
        test bl, 0xc
        jnz short .26
.28:
        and dx, 0x7
        shl dl, 1
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        ror dx, cl
        test dl, 0x3
        jnz short FpSkipEmptyRegs.2
        jmp short FpSkipEmptyRegs.1
        db 0x90

;-----------------------------------------------------------------------------
; FpSkipEmptyRegs                                               18B9:04EA  MSC
; Steps past empty stack registers.
;-----------------------------------------------------------------------------
FpSkipEmptyRegs:
        ror bx, 1
        ror bx, 1
        wait
        fincstp
        test bx, 0x3
        jz short FpSkipEmptyRegs
        ret
.1:
        or ah, 0x4
        mov byte [bp + 0x2], 0x0
        wait
        fldenv [bp + 0x0]
        pop di
        pop dx
        pop cx
        pop bx
        pop si
        jmp near FpException.9
.2:
        and al, 0xfe
        call FpSignalOnce
        pop di
        pop dx
        pop cx
        pop bx
        pop si
        jmp near FpException.2
.3:
        or byte [FpUserStatus], 0x2
        push cx
        mov cx, [bp + 0x8]
        and cl, 0xc0
        cmp cl, 0xc0
        jz short .8
        mov cx, [bp + 0x8]
        and cx, 0x338
        cmp cx, 0x8
        jz short .4
        cmp cx, 0x10
        jz short .4
        and cl, 0x30
        cmp cx, 0x30
        jnz short .8
.4:
        test bh, 0xc0
        jz short .6
        and bh, 0x3f
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .5
        call FpSetC1
.5:
        add si, 0xc
        mov [FpStackTop], si
        wait
        fdecstp
        wait
        fstp tword [si]
.6:
        mov cx, [bp + 0x8]
        push cx
        and cx, 0x400
        add cx, 0x104
        mov [bp + 0x8], cx
        call FpSignal
        call FpFixDenormal
        pop cx
        and cx, 0x38
        cmp cl, 0x8
        jz short .7
        cmp cl, 0x10
        jz short .10
        xor cl, 0x8
.7:
        or cx, 0x6c1
        mov [bp + 0x8], cx
        call FpSignalOnce
        jmp short .11
.8:
        mov cx, [bp + 0x8]
        and cx, 0x738
        cmp cx, 0x328
        jz short .9
        and cx, 0x138
        cmp cx, 0x100
        jz short .9
        call FpSignalOnce
.9:
        call FpFixDenormal
        jmp short .11
.10:
        or ah, 0x40
        wait
        fnclex
        wait
        fxch st1
        wait
        fcom st1
        wait
        fxch st1
        wait
        fstp st0
        wait
        fnstsw [FpOpStatus]
        wait
        or al, [FpOpStatus]
.11:
        pop cx
        and al, 0xfd
        jmp near FpException.2

;-----------------------------------------------------------------------------
; FpFixDenormal                                                 18B9:05D7  MSC
; Renormalises a temporary real on the stack frame.
;-----------------------------------------------------------------------------
FpFixDenormal:
        wait
        fstp tword [bp + 0x12]
        wait
        mov cx, [bp + 0x1a]
        test cx, 0x7fff
        jz short .3
        test byte [bp + 0x19], 0x80
        jnz short .1
        wait
        fild qword [bp + 0x12]
        wait
        fstp tword [bp + 0x12]
        wait
        cmp word [bp + 0x1a], 0x0
        jz short .3
        sub cx, 0x403e
        add [bp + 0x1a], cx
.1:
        wait
        db 0xDB, 0x6E
.2:
        db 0x12, 0xC3                           ; insn: adc al, bl
.3:
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov [bp + 0x12], cx
        mov [bp + 0x14], cx
        mov [bp + 0x16], cx
        mov [bp + 0x18], cx
        mov [bp + 0x1a], cx
        jmp short .1

;-----------------------------------------------------------------------------
; FpCheckPrecision                                              18B9:0619  MSC
; Precision exception check before FpException continues.
;-----------------------------------------------------------------------------
FpCheckPrecision:
        push ax
        mov ax, [bp + 0x8]
        and ax, 0x1c0
        xor ah, 0x1
        cmp ax, 0xc0
        pop ax
        jnc short .1
        call FpSignalOnce
.1:
        jmp near FpException.2

;-----------------------------------------------------------------------------
; FpSignalOnce                                                  18B9:062F  MSC
; Marks the exception and calls FpSignal once.
;-----------------------------------------------------------------------------
FpSignalOnce:
        test ah, 0x40
        jnz short FpSignal.3
        or ah, 0x40

FpSignal:
        push ds
        push di
        push si
        push cx
        push bx
        wait
        fnclex
        mov di, ss
        cmp word [FpMachineMode], 0x0
        jz short .1
        mov di, [FpSavedSs]
.1:
        mov cx, [bp + 0x8]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and ch, 0x7
        or ch, 0xd8
        and bl, 0xc0
        xor bl, 0xc0
        jz short .2
        and cl, 0x38
        or cl, 0x4
        lds si, [bp + 0xa]
.2:
        xchg ch, cl
        mov [bp + 0x14], di
        lea di, [bp + 0x16]
        mov [bp + 0x12], di
        mov byte [bp + 0x16], 0x9b
        mov [bp + 0x17], cx
        mov byte [bp + 0x19], 0xcb
        call far [bp + 0x12]
        pop bx
        pop cx
        pop si
        pop di
        pop ds
        wait
        fnstsw [FpOpStatus]
        wait
        or al, [FpOpStatus]
.3:
        ret
.4:
        push ds
        push bx
        mov bl, 0x8b
        test ah, 0x4
        jnz short .5
        mov bl, 0x8a
        test ah, 0x2
        jnz short .5
        mov bl, 0x88
        test al, 0x80
        jnz short .5
        mov bl, 0x89
        test ah, 0x1
        jnz short .5
        mov bl, 0x81
        test al, 0x1
        jnz short .5
        mov bl, 0x83
        test al, 0x4
        jnz short .5
        mov bl, 0x84
        test al, 0x8
        jnz short .5
        mov bl, 0x85
        test al, 0x10
        jnz short .5
        mov bl, 0x86
        test al, 0x20
        jnz short .5
        mov bl, 0x87
        test al, 0x40
        jnz short .5
.5:
        mov ds, [cs:EmuDataSeg]
        mov ax, [FpErrHandler]
        or ax, [FpErrHandler + 2]
        jnz short .6
        xchg ax, bx
        mov ah, 0x4c
        int 0x21
.6:
        xchg ax, bx
        pop bx
        call far [FpErrHandler]
        pop ds
        pop ax
        iret

;-----------------------------------------------------------------------------
; FpLoadCw                                                      18B9:06EE  MSC
; Function 4: sets the control word.
;-----------------------------------------------------------------------------
FpLoadCw:
        mov [FpUserCw], ax
        and ax, 0xff3c
        cmp byte [Fp87Present], 0x0
        jz short .1
        mov [FpTemp], ax
        wait
        fldcw [FpTemp]
.1:
        mov [FpEmuCw], ax
        ret

;-----------------------------------------------------------------------------
; FpGetCw                                                       18B9:0707  MSC
; Function 5: returns the control word.
;-----------------------------------------------------------------------------
FpGetCw:
        mov ax, [FpUserCw]
        ret

;-----------------------------------------------------------------------------
; FpGetStatus                                                   18B9:070B  MSC
; Function 8: returns and accumulates the status word.
;-----------------------------------------------------------------------------
FpGetStatus:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp al, [Fp87Present]
        jz short .1
        wait
        fnstsw [FpOpStatus]
        wait
        mov al, [FpOpStatus]
        and al, 0x3f
.1:
        or ax, [FpUserStatus]
        and ax, 0x1fff
        mov [FpUserStatus], ax
        ret

;-----------------------------------------------------------------------------
; FpRoundInt                                                    18B9:0729  MSC
; Function 6: rounds ST to an integer value (frndint).
;-----------------------------------------------------------------------------
FpRoundInt:
        and ax, 0xc00
        cmp byte [Fp87Present], 0x0
        jz short .1
        wait
        fnstcw [FpEmuCw]
        wait
        mov cx, [FpEmuCw]
        and ch, 0xf3
        db 0x0B, 0xC1                           ; insn: or ax, cx
        mov [FpTemp], ax
        wait
        fldcw [FpTemp]
        wait
        frndint
        wait
        fldcw [FpEmuCw]
        ret
.1:
        mov cx, [FpEmuCw]
        push cx
        and ch, 0xf3
        db 0x0A, 0xE5                           ; insn: or ah, ch
        mov [FpEmuCw + 1], ah
        push bp
        call FpRndint
        pop bp
        pop word [FpEmuCw]
        call FpCheckPending
        ret

;-----------------------------------------------------------------------------
; FpToLong                                                      18B9:076E  MSC
; Function 7: converts ST to a long (fistp).
;-----------------------------------------------------------------------------
FpToLong:
        and ax, 0xc00
        cmp byte [Fp87Present], 0x0
        jz short .1
        wait
        fnstcw [FpEmuCw]
        wait
        mov cx, [FpEmuCw]
        and ch, 0xf3
        db 0x0B, 0xC1                           ; insn: or ax, cx
        mov [FpTemp], ax
        wait
        fldcw [FpTemp]
        wait
        fistp dword [FpTemp]
        wait
        fldcw [FpEmuCw]
        mov ax, [FpTemp]
        mov dx, [FpTemp + 2]
        ret
.1:
        mov cx, [FpEmuCw]
        push cx
        and ch, 0xf3
        db 0x0A, 0xE5                           ; insn: or ah, ch
        mov [FpEmuCw + 1], ah
        push bp
        call FpToInt32
        pop bp
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        call FpCheckPending
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .2
        call FpSetC2
.2:
        sub si, 0xc
        mov [FpStackTop], si
        pop word [FpEmuCw]
.3:
        ret

;-----------------------------------------------------------------------------
; FpCheckPending                                                18B9:07D4  MSC
; Raises unmasked exceptions after a conversion.
;-----------------------------------------------------------------------------
FpCheckPending:
        mov cx, [FpOpStatus]
        or [FpUserStatus], cx
        or [FpEmuStatus], cl
        not cl
        mov ch, [FpUserCw]
        or ch, 0xc2
        and ch, 0x3f
        db 0x0A, 0xCD                           ; insn: or cl, ch
        not cl
        mov ch, [FpOpStatus + 1]
        test cx, 0xdfff
        jz short FpToLong.3
        xchg ax, cx
        jmp near FpSignal.4

;-----------------------------------------------------------------------------
; FpPatchSegInt                                                 18B9:07FE  MSC
; INT 3Ch with an 8087: patches a segment-override sequence into real code.
;-----------------------------------------------------------------------------
FpPatchSegInt:
        sti
        wait
        push ax
        push bp
        push ds
        push si
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds si, [bp + 0x8]
        mov al, [si]
        or byte [si], 0xc0
        dec si
        dec si
        mov [bp + 0x8], si
        shr al, 1
        shr al, 1
        shr al, 1
        not al
        and al, 0x18
        or al, 0x26
        xchg al, ah
        mov al, 0x9b
        mov [si], ax
        push bx
        mov bx, 0x1
        jmp short FpPatchInt.2

;-----------------------------------------------------------------------------
; FpPatchWaitInt                                                18B9:082B  MSC
; INT 3Dh with an 8087: patches into nop, fwait.
;-----------------------------------------------------------------------------
FpPatchWaitInt:
        sti
        wait
        push ax
        mov ax, 0xa23d
        jmp short FpPatchInt.1

;-----------------------------------------------------------------------------
; FpPatchInt                                                    18B9:0833  MSC
; INT 34h-3Bh with an 8087: patches the INT into fwait plus the ESC opcode
; and reruns it.
;-----------------------------------------------------------------------------
FpPatchInt:
        sti
        wait
        push ax
        mov ax, 0x5c32
.1:
        push bp
        push ds
        push si
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds si, [bp + 0x8]
        dec si
        dec si
        mov [bp + 0x8], si
        sub [si], ax
        push bx
        db 0x33, 0xDB                           ; insn: xor bx, bx
.2:
        push sp
        pop ax
        db 0x3B, 0xC4                           ; insn: cmp ax, sp
        jnz short .4
        mov ax, [bx + si + 0x1]
        and ax, 0x30fb
        cmp ax, 0x30d9
        jnz short .3
        mov al, [bx + si + 0x2]
        cmp al, 0xf0
        jc short .4
.3:
        mov ax, [bx + si + 0x1]
        and ax, 0xfeff
        cmp ax, 0xe2db
        jz short .4
        mov ax, [bx + si + 0x1]
        cmp ax, 0xe0df
        jz short .4
        mov byte [si], 0x90
.4:
        pop bx
        pop si
        pop ds
        pop bp
        pop ax
        iret
        db 0x90
FpOpcodeTable:                                  ; word; FpEmulate's handlers by ESC opcode and MOD field
        dw FpEmulate.23
        dw FpEmulate.7
        dw FpEmulate.15
        dw FpEmulate.27
        dw FpEmulate.22
        dw FpEmulate.8
        dw FpEmulate.16
        dw FpEmulate.27
        dw FpEmulate.21
        dw FpEmulate.6
        dw FpEmulate.14
        dw FpEmulate.27
        dw FpEmulate.20
        dw FpEmulate.5
        dw FpEmulate.13
        dw FpEmulate.27
        dw FpEmulate.25
        dw FpEmulate.11
        dw FpEmulate.19
        dw FpEmulate.27
        dw FpEmulate.3
        dw FpEmulate.10
        dw FpEmulate.18
        dw FpEmulate.27
        dw FpEmulate.24
        dw FpEmulate.4
        dw FpEmulate.12
        dw FpEmulate.27
        dw FpEmulate.2
        dw FpEmulate.9
        dw FpEmulate.17
        dw FpEmulate.27
FpArithTable:                                   ; word; fadd, fmul, fcom, fcomp, fsub, fsubr, fdiv, fdivr
        dw FpAdd
        dw FpMul
        dw FpShiftRight.38
        dw FpShiftRight.37
        dw FpSub
        dw FpSetStackFault.1
        dw FpDivRev
        dw FpDiv
FpOddEscMemTable:                               ; word; memory forms of ESC 1, 3, 5 and 7 by REG field
        dw FpEmuChainEsc.4
        dw FpSetStackFault
        dw FpEmuChainEsc.5
        dw FpEmuChainEsc.6
        dw FpSetStackFault
        dw FpEmuChainEsc.9
        dw FpSetStackFault
        dw FpEmuChainEsc.10
FpOddEscRegTable:                               ; word; register forms of ESC 1, 3, 5 and 7 by REG field
        dw FpEmuChainEsc.11
        dw FpEmuChainEsc.23
        dw FpEmuChainEsc.25
        dw FpEmuChainEsc.24
        dw FpEmuChainEsc.13
        dw FpEmuChainEsc.20
        dw FpEmuChainEsc.21
        dw FpEmuChainEsc.22
FpLoadFormatTable:                              ; word; loads a float, int32, double or int16 operand
        dw FpDivMantissa.40
        dw FpDivMantissa.109
        dw FpDivMantissa.69
        dw FpDivMantissa.99
FpStoreFormatTable:                             ; word; stores ST as a float, int32, double or int16
        dw FpDivMantissa.52
        dw FpDivMantissa.114
        dw FpDivMantissa.82
        dw FpDivMantissa.104
FpRegField5Table:                               ; word; REG 5: fldcw, fld temp real, (reserved), fild int64
        dw FpShiftRight.28
        dw FpShiftRight.11
        dw FpSetStackFault
        dw FpToInt32.6
FpRegField7Table:                               ; word; REG 7: fstcw, fstp temp real, fstsw, fistp int64
        dw FpShiftRight.29
        dw FpShiftRight.24
        dw FpShiftRight.30
        dw FpToInt32.11
FpLoadConstTable:                               ; word; fld1, fldl2t, fldl2e, fldpi, fldlg2, fldln2, fldz
        dw FpShiftRight.64
        dw FpShiftRight.59
        dw FpShiftRight.60
        dw FpShiftRight.58
        dw FpShiftRight.61
        dw FpShiftRight.62
        dw FpShiftRight.63
        dw FpSetStackFault
FpTranscTable:                                  ; word; f2xm1, fyl2x, fptan, fpatan
        dw FpAtanCore.3
        dw FpSeriesB.1
        dw FpPolyRatio.3
        dw FpSeriesA.1
        dw FpSetStackFault
        dw FpSetStackFault
        dw FpSetStackFault
        dw FpSetStackFault
FpMiscOpTable:                                  ; word; fprem, fyl2xp1, fsqrt, frndint, fscale (D9 F8-FF)
        dw FpShiftRight.83
        dw FpLog2Core.5
        dw FpSubMantissa.1
        dw FpSetStackFault
        dw FpRndint
        dw FpShiftRight.31
        dw FpSetStackFault
        dw FpSetStackFault
FpCompareTagTable:                              ; word; compare handlers by the two operands' tags
        dw FpShiftRight.41
        dw FpShiftRight.48
        dw FpShiftRight.46
        dw FpShiftRight.49
        dw FpShiftRight.50
        dw FpShiftRight.43
        dw FpShiftRight.46
        dw FpShiftRight.49
        dw FpShiftRight.46
        dw FpShiftRight.46
        dw FpShiftRight.46
        dw FpShiftRight.46
        dw FpShiftRight.47
        dw FpShiftRight.47
        dw FpShiftRight.46
        dw FpShiftRight.51
FpTestTagTable:                                 ; word; ftst handlers by tag
        dw FpShiftRight.48
        dw FpShiftRight.43
        dw FpShiftRight.46
        dw FpShiftRight.47
FpAddTagTable:                                  ; word; add handlers by the two operands' tags
        dw FpCopyReg.5
        dw FpAdd.3
        dw FpAdd.7
        dw FpAdd.4
        dw FpAdd.4
        dw FpAdd.3
        dw FpAdd.7
        dw FpAdd.4
        dw FpAdd.6
        dw FpAdd.6
        dw FpCopyReg.3
        dw FpAdd.6
        dw FpAdd.3
        dw FpAdd.3
        dw FpAdd.7
        dw FpCopyReg.2
FpMulTagTable:                                  ; word; multiply handlers by the two operands' tags
        dw FpCopyReg.23
        dw FpAdd.8
        dw FpAdd.7
        dw FpAdd.11
        dw FpAdd.8
        dw FpAdd.8
        dw FpAdd.7
        dw FpAdd.13
        dw FpAdd.6
        dw FpAdd.6
        dw FpCopyReg.3
        dw FpAdd.6
        dw FpAdd.11
        dw FpAdd.13
        dw FpAdd.7
        dw FpAdd.11
FpDivTagTable:                                  ; word; divide handlers by the two operands' tags
        dw FpCopyReg.40
        dw FpAdd.8
        dw FpAdd.7
        dw FpAdd.11
        dw FpAdd.10
        dw FpAdd.12
        dw FpAdd.5
        dw FpAdd.10
        dw FpAdd.6
        dw FpAdd.6
        dw FpCopyReg.3
        dw FpAdd.6
        dw FpAdd.8
        dw FpAdd.8
        dw FpAdd.7
        dw FpAdd.13
FpExamineCodes:                                 ; fxam condition codes (C3, C2, C1, C0) by tag and sign
        db 0x04, 0x06, 0x40, 0x42, 0x01, 0x03, 0x05, 0x07
FpRegZero:                                      ; +0 as an emulator register
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xC0, 0x00, 0x01
FpRegInfinity:                                  ; +infinity as an emulator register
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x03
FpRegIndefinite:                                ; the indefinite NaN as an emulator register
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0x00, 0x40, 0x80, 0x02
FpRegMax:                                       ; the largest temp real as an emulator register
        db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F, 0x00, 0x00
FpSingleInf:                                    ; float +infinity
        dw 0x0000, 0x7F80
FpSingleMax:                                    ; the largest float
        dw 0xFFFF, 0x7F7F
FpDoubleInf:                                    ; double +infinity
        dw 0x0000, 0x0000, 0x0000, 0x7FF0
FpDoubleMax:                                    ; the largest double
        dw 0xFFFF, 0xFFFF, 0xFFFF, 0x7FEF
FpConstZero:                                    ; 0.0 (fldz)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0xC0, 0x00, 0x01
FpConstOne:                                     ; 1.0 (fld1)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
FpConstTan15:                                   ; 2 - sqrt 3, the tangent of 15 degrees
        db 0x8A, 0xB1, 0x6A, 0xF6, 0xF4, 0xA2, 0x30, 0x89, 0xFE, 0xFF, 0x00, 0x00
FpConstSqrt3:                                   ; sqrt 3
        db 0x9E, 0x53, 0x65, 0xC2, 0x42, 0xD7, 0xB3, 0xDD, 0x00, 0x00, 0x00, 0x00
FpConstPiOver6:                                 ; pi / 6
        db 0x23, 0x2C, 0x9B, 0x6B, 0xC1, 0x91, 0x0A, 0x86, 0xFF, 0xFF, 0x00, 0x00
FpConstSqrt2:                                   ; sqrt 2
        db 0x84, 0x64, 0xDE, 0xF9, 0x33, 0xF3, 0x04, 0xB5, 0x00, 0x00, 0x00, 0x00
FpConstTwo:                                     ; 2.0
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
FpConstPi:                                      ; pi (fldpi)
        db 0x35, 0xC2, 0x68, 0x21, 0xA2, 0xDA, 0x0F, 0xC9, 0x01, 0x00, 0x00, 0x00
FpConstL2T:                                     ; log2 10 (fldl2t)
        db 0xFE, 0x8A, 0x1B, 0xCD, 0x4B, 0x78, 0x9A, 0xD4, 0x01, 0x00, 0x00, 0x00
FpConstL2E:                                     ; log2 e (fldl2e)
        db 0xBC, 0xF0, 0x17, 0x5C, 0x29, 0x3B, 0xAA, 0xB8, 0x00, 0x00, 0x00, 0x00
FpConstLg2:                                     ; log10 2 (fldlg2)
        db 0x99, 0xF7, 0xCF, 0xFB, 0x84, 0x9A, 0x20, 0x9A, 0xFE, 0xFF, 0x00, 0x00
FpConstLn2:                                     ; ln 2 (fldln2)
        db 0xAC, 0x79, 0xCF, 0xD1, 0xF7, 0x17, 0x72, 0xB1, 0xFF, 0xFF, 0x00, 0x00
FpSeriesANum:                                   ; FpSeriesA numerator: degree word, then coefficients
        dw 3
        db 0xD4, 0x7B, 0x5A, 0xD8, 0x3E, 0x5C, 0x69, 0x8F, 0x05, 0x00, 0x80, 0x00
        db 0x37, 0x4D, 0xD7, 0x2C, 0xF8, 0xD0, 0xD4, 0xD6, 0x0C, 0x00, 0x00, 0x00
        db 0xD3, 0xDC, 0x17, 0x66, 0xEE, 0xBB, 0xBA, 0x82, 0x12, 0x00, 0x80, 0x00
        db 0xCB, 0x91, 0x58, 0x5E, 0x8B, 0x86, 0x06, 0xF5, 0x14, 0x00, 0x00, 0x00
FpSeriesADen:                                   ; FpSeriesA denominator
        dw 3
        db 0xE5, 0x86, 0x20, 0x01, 0x02, 0x05, 0x79, 0x9C, 0x09, 0x00, 0x80, 0x00
        db 0x63, 0x66, 0xCF, 0x88, 0x70, 0xB2, 0x39, 0xC9, 0x0F, 0x00, 0x00, 0x00
        db 0x96, 0xFA, 0x46, 0xC7, 0xFE, 0x0C, 0xB7, 0xE4, 0x13, 0x00, 0x80, 0x00
        db 0xCB, 0x91, 0x58, 0x5E, 0x8B, 0x86, 0x06, 0xF5, 0x14, 0x00, 0x00, 0x00
FpAtanNum:                                      ; FpAtanCore numerator: degree word, then coefficients
        dw 4
        db 0x32, 0x5B, 0x08, 0xCF, 0xC9, 0xA4, 0x50, 0xA6, 0xFD, 0xFF, 0x00, 0x00
        db 0xCE, 0xD1, 0xCA, 0xD5, 0x4B, 0xA8, 0xF0, 0xD0, 0x02, 0x00, 0x00, 0x00
        db 0x9F, 0x89, 0x2B, 0xE2, 0xA8, 0x52, 0x4A, 0x9C, 0x05, 0x00, 0x00, 0x00
        db 0x65, 0x42, 0x50, 0x55, 0xCF, 0xE9, 0xEF, 0x90, 0x06, 0x00, 0x00, 0x00
        db 0x90, 0x4B, 0xAD, 0x24, 0xE6, 0xE5, 0x43, 0xA4, 0x05, 0x00, 0x00, 0x00
FpAtanDen:                                      ; FpAtanCore denominator
        dw 3
        db 0x10, 0x83, 0x38, 0x56, 0x0A, 0x4F, 0x62, 0xF0, 0x03, 0x00, 0x00, 0x00
        db 0xE7, 0xB4, 0x1E, 0x6D, 0x90, 0x51, 0x50, 0xEE, 0x05, 0x00, 0x00, 0x00
        db 0x3B, 0x24, 0x6D, 0x5B, 0x20, 0x90, 0x50, 0xAC, 0x06, 0x00, 0x00, 0x00
        db 0x90, 0x4B, 0xAD, 0x24, 0xE6, 0xE5, 0x43, 0xA4, 0x05, 0x00, 0x00, 0x00
FpSeriesBNum:                                   ; FpSeriesB numerator: degree word, then coefficients
        dw 2
        db 0x98, 0x18, 0x05, 0xF4, 0xFC, 0x06, 0x74, 0xF2, 0x05, 0x00, 0x00, 0x00
        db 0x08, 0xAD, 0xE1, 0x14, 0x54, 0x3D, 0x9B, 0xEC, 0x0E, 0x00, 0x00, 0x00
        db 0xAF, 0x5F, 0xA3, 0xC3, 0x4A, 0xD8, 0xF0, 0xFD, 0x14, 0x00, 0x00, 0x00
FpSeriesBDen:                                   ; FpSeriesB denominator
        dw 2
        db 0x6F, 0x77, 0x7B, 0x38, 0x8B, 0x10, 0xA7, 0xDA, 0x0A, 0x00, 0x00, 0x00
        db 0x5D, 0xE8, 0x7B, 0x9B, 0x82, 0xB1, 0x03, 0xA0, 0x12, 0x00, 0x00, 0x00
        db 0x7E, 0x83, 0x09, 0xE7, 0x14, 0xF8, 0x2D, 0xB7, 0x16, 0x00, 0x00, 0x00
FpLogNum:                                       ; FpLogSeries numerator: degree word, then coefficients
        dw 3
        db 0x04, 0x77, 0x99, 0xC2, 0xE2, 0x57, 0x71, 0x9B, 0xFE, 0xFF, 0x00, 0x00
        db 0x9C, 0x4F, 0x31, 0xF6, 0x35, 0x5E, 0x91, 0xDE, 0x04, 0x00, 0x80, 0x00
        db 0x8A, 0x4B, 0xEA, 0x7A, 0xED, 0xC9, 0xD3, 0xB2, 0x08, 0x00, 0x00, 0x00
        db 0xC9, 0x28, 0x09, 0x1D, 0x2F, 0xE4, 0xC4, 0x8A, 0x0A, 0x00, 0x80, 0x00
FpLogDen:                                       ; FpLogSeries denominator
        dw 2
        db 0xBB, 0x76, 0x70, 0x3E, 0x5B, 0x02, 0xAC, 0x8E, 0x05, 0x00, 0x80, 0x00
        db 0x60, 0xEF, 0x33, 0xA9, 0xD0, 0x1F, 0x04, 0x9C, 0x08, 0x00, 0x00, 0x00
        db 0x96, 0xBB, 0x83, 0x6C, 0xE0, 0xF4, 0x5F, 0xC0, 0x09, 0x00, 0x80, 0x00
FpSegEscTable:                                  ; word; FpEmuSegInt handlers by segment bits of the ESC byte
        dw FpEmuSegInt.1
        dw FpEmuSegInt.4
        dw FpEmuSegInt.2
        dw FpEmuSegInt.3

;-----------------------------------------------------------------------------
; FpEmuWaitInt                                                  18B9:0C28  MSC
; INT 3Dh without an 8087: patches into mov ax,ax.
;-----------------------------------------------------------------------------
FpEmuWaitInt:
        push bp
        push ds
        push si
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds si, [bp + 0x6]
        dec si
        dec si
        mov [bp + 0x6], si
        mov word [si], 0xc089
        pop si
        pop ds
        pop bp
        iret
FpSegModrmTable:                                ; word; FpEmuSegInt handlers by segment bits of the next byte
        dw FpEmuSegInt.1
        dw FpEmuSegInt.3
        dw FpEmuSegInt.2
        dw FpEmuSegInt.4

;-----------------------------------------------------------------------------
; FpEmuSegInt                                                   18B9:0C45  MSC
; INT 3Ch without an 8087: emulates an instruction with a segment override.
;-----------------------------------------------------------------------------
FpEmuSegInt:
        sti
        push ax
        push es
        push ds
        push di
        push si
        push dx
        push cx
        push bx
        sub sp, 0x2
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cld
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xC7                           ; insn: mov ax, di
        lds di, [bp + 0x14]
        inc di
        inc di
        mov cx, [di - 0x2]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        rol bl, 1
        rol bl, 1
        and bx, 0x3
        rol bx, 1
        jmp [cs:bx + FpSegModrmTable]
.1:
        mov es, [bp + 0xe]
        jmp short .4
.2:
        mov bx, ds
        mov es, bx
        jmp short .4
.3:
        mov bx, ss
        mov es, bx
.4:
        mov [bp + 0x2], es
        jmp short FpEmulate.1

;-----------------------------------------------------------------------------
; FpEmuSegDecode                                                18B9:0C85  MSC
; Operand segment decode for FpEmuSegInt.
;-----------------------------------------------------------------------------
FpEmuSegDecode:
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8A, 0xD9                           ; insn: mov bl, cl
        shr bl, byte 0x2
        and bx, 0x6
        inc di
        mov cx, [di - 0x2]
        jmp [cs:bx + FpSegEscTable]

;-----------------------------------------------------------------------------
; FpEmuSegIntAlt                                                18B9:0C98  MSC
; Second segment-override emulation entry.
;-----------------------------------------------------------------------------
FpEmuSegIntAlt:
        cld
        push ax
        push es
        push ds
        push di
        push si
        push dx
        push cx
        push bx
        push ss
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov dx, ds
        db 0x8B, 0xC7                           ; insn: mov ax, di
        lds di, [bp + 0x14]
        mov cx, [di]
        add di, 0x2
        add cl, 0x28
        jnc short FpEmuSegDecode
        mov es, dx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        jmp short FpEmulate.1

;-----------------------------------------------------------------------------
; FpEmulate                                                     18B9:0CBC  MSC
; INT 34h-3Bh without an 8087: decodes and emulates one coprocessor
; instruction.
;-----------------------------------------------------------------------------
FpEmulate:
        sti
        push ax
        push es
        push ds
        push di
        push si
        push dx
        push cx
        push bx
        push ss
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, ds
        mov es, ax
        cld
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xC7                           ; insn: mov ax, di
        lds di, [bp + 0x14]
        inc di
        mov cx, [di - 0x2]
        sub cl, 0x34
.1:
        rol ch, 1
        rol ch, 1
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        and bx, 0x1f
        shl bx, 1
        jmp [cs:bx + FpOpcodeTable]
.2:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        jmp short .25
.3:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .25
.4:
        mov si, [bp + 0x0]
        mov es, [bp + 0x2]
        mov al, [di]
        cbw
        inc di
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .25
.5:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        add si, [bp + 0x0]
        mov es, [bp + 0x2]
        mov al, [di]
        cbw
        inc di
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .25
.7:
        db 0x8B, 0xC6                           ; insn: mov ax, si
.8:
        db 0x03, 0xD0                           ; insn: add dx, ax
.9:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
.10:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.11:
        mov al, [di]
        cbw
        inc di
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .25
.12:
        mov si, [bp + 0x0]
        mov es, [bp + 0x2]
        add si, [di]
        add di, 0x2
        jmp short .25
        db 0x90
.13:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.14:
        add si, [bp + 0x0]
        mov es, [bp + 0x2]
        add si, [di]
        add di, 0x2
        jmp short .25
        db 0x90
.15:
        db 0x8B, 0xC6                           ; insn: mov ax, si
.16:
        db 0x03, 0xD0                           ; insn: add dx, ax
.17:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
.18:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.19:
        add si, [di]
        add di, 0x2
        jmp short .25
        db 0x90
.20:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.21:
        add si, [bp + 0x0]
        mov es, [bp + 0x2]
        jmp short .25
.22:
        db 0x8B, 0xF0                           ; insn: mov si, ax
.23:
        db 0x03, 0xF2                           ; insn: add si, dx
        jmp short .25
.24:
        mov si, [di]
        inc di
        inc di
.25:
        mov [bp + 0x14], di
        mov bl, [di]
        mov ds, [cs:EmuDataSeg]
        mov [FpNextByte], bl
        mov word [FpOpStatus], 0x2000
        shr ch, 1
        shr ch, 1
        shr ch, 1
        shr ch, 1
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        and bx, 0xe
        test cl, 0x1
        jz short .26
        mov ax, FpEmuExit.1
        push ax
        jmp [cs:bx + FpOddEscMemTable]
        db 0x90
.26:
        push bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        call [cs:bx + FpLoadFormatTable]
        pop bx
        mov ax, ds
        mov es, ax
        mov si, [FpStackTop]
        db 0x8B, 0xFE                           ; insn: mov di, si
        sub di, 0xc
        mov [FpResultPtr], di
        jmp short .31
        db 0x90
.27:
        mov [bp + 0x14], di
        mov bl, [di]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov di, [cs:EmuDataSeg]
        mov ds, di
        mov es, di
        mov [FpNextByte], bl
        mov [FpOpStatus], ax
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        shr bl, 1
        shr bl, 1
        shr bl, 1
        shr bl, 1
        and bx, 0xe
        test cl, 0x1
        jz short .28
        call [cs:bx + FpOddEscRegTable]
        jmp near FpEmuExit.1
        db 0x90
.28:
        call FpStackRoom
        jc short .35
        mov [FpResultPtr], si
        test cl, 0x4
        jz short .29
        mov [FpResultPtr], di
.29:
        test bl, 0x8
        jz short .30
        xor bl, 0x2
.30:
        test cl, 0x2
        jz short .34
.31:
        call [cs:bx + FpArithTable]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jz short .33
.32:
        sub si, 0xc
        mov [FpStackTop], si
        jmp short FpEmuExit.1
.33:
        call FpSetC2
        jmp short .32
.34:
        mov ax, FpEmuExit.1
        push ax
        jmp [cs:bx + FpArithTable]
.35:
        call FpSetC2
        or word [FpOpStatus], 0x1
        jmp short FpEmuExit.1

;-----------------------------------------------------------------------------
; FpStackRoom                                                   18B9:0E35  MSC
; Checks room on the emulated register stack.
;-----------------------------------------------------------------------------
FpStackRoom:
        mov si, [FpStackTop]
        db 0x8B, 0xFE                           ; insn: mov di, si
        db 0x8A, 0xD5                           ; insn: mov dl, ch
        and dl, 0x1c
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        shl dh, 1
        db 0x02, 0xD6                           ; insn: add dl, dh
        db 0x32, 0xF6                           ; insn: xor dh, dh
        db 0x2B, 0xFA                           ; insn: sub di, dx
        cmp di, [FpStackBase]
        clc
        jg short .1
        cmc
.1:
        ret

;-----------------------------------------------------------------------------
; FpEmuSignal                                                   18B9:0E53  MSC
; Leaves the emulator through FpSignal.
;-----------------------------------------------------------------------------
FpEmuSignal:
        call FpSetStackFault
        jmp short FpEmuExit.1
        db 0x90
.1:
        pop bp
        add sp, 0x2
        pop bx
        pop cx
        pop dx
        pop si
        pop di
        pop ds
        pop es
        jmp near FpSignal.4

;-----------------------------------------------------------------------------
; FpEmuExit                                                     18B9:0E67  MSC
; Restores registers and returns from the emulator interrupt.
;-----------------------------------------------------------------------------
FpEmuExit:
        pop bp
        add sp, 0x2
        pop bx
        pop cx
        pop dx
        pop si
        pop di
        pop ds
        pop es
        pop ax
        iret
.1:
        mov ax, [FpOpStatus]
        or [FpUserStatus], ax
        or [FpEmuStatus], al
        not al
        mov bh, [FpUserCw]
        or bh, 0xc2
        and bh, 0x3f
        db 0x0A, 0xC7                           ; insn: or al, bh
        not al
        test ax, 0xdfff
        jnz short FpEmuSignal.1
        jmp [FpExitVector]

;-----------------------------------------------------------------------------
; FpEmuChain                                                    18B9:0E98  MSC
; Emulates the next instruction too when it is another INT 34h-3Bh.
;-----------------------------------------------------------------------------
FpEmuChain:
        cmp byte [FpNextByte], 0xcd
        jnz short FpEmuExit
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds di, [bp + 0x14]
        add di, 0x3
        mov cx, [di - 0x2]
        sub cl, 0x34
        cmp cl, 0x7
        ja short FpEmuExit
        mov ax, [bp + 0xc]
        mov dx, [bp + 0x4]
        mov si, [bp + 0xa]
        mov es, [bp + 0xe]
        mov [bp + 0x2], ss
        rol ch, 1
        rol ch, 1
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        and bx, 0x1f
        shl bx, 1
        jmp [cs:bx + FpOpcodeTable]

;-----------------------------------------------------------------------------
; FpEmuChainEsc                                                 18B9:0ED1  MSC
; Emulates the next instruction when it is a real ESC opcode.
;-----------------------------------------------------------------------------
FpEmuChainEsc:
        mov cl, [FpNextByte]
        cmp cl, 0x9b
        jz short .2
        cmp cl, 0x90
        jz short .2
        xor cl, 0x20
        cmp cl, 0xf8
.1:
        jc short FpEmuExit
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds di, [bp + 0x14]
        jmp short .3
.2:
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        lds di, [bp + 0x14]
        inc di
        mov cl, [di]
        xor cl, 0x20
        cmp cl, 0xf8
        jc short .1
.3:
        mov ch, [di + 0x1]
        add di, 0x2
        add cl, 0x8
        mov ax, [bp + 0xc]
        mov dx, [bp + 0x4]
        mov si, [bp + 0xa]
        mov es, [bp + 0xe]
        mov [bp + 0x2], ss
        rol ch, 1
        rol ch, 1
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        and bx, 0x1f
        shl bx, 1
        jmp [cs:bx + FpOpcodeTable]
.4:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        jmp [cs:bx + FpLoadFormatTable]
.5:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        jmp [cs:bx + FpStoreFormatTable]
.6:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        call [cs:bx + FpStoreFormatTable]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jna short .8
.7:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.8:
        call FpSetC2
        jmp short .7
.9:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        jmp [cs:bx + FpRegField5Table]
.10:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and bx, 0x6
        jmp [cs:bx + FpRegField7Table]
.11:
        test cx, 0x6
        jnz short .12
        jmp near FpShiftRight.75
.12:
        jmp near FpShiftRight.67
.13:
        test cx, 0x806
        jz short .16
        xor cx, 0x203
        test cx, 0x603
        jnz short .15
        cmp cx, 0x8104
        jz short .14
        mov word [FpEmuStatus], 0x0
        ret
.14:
        push sp
        pop ax
        db 0x3B, 0xC4                           ; insn: cmp ax, sp
.15:
        jnz short FpSetStackFault
        mov ax, [FpEmuStatus]
        mov [bp + 0x12], ax
        ret
.16:
        test cx, 0x1000
        jz short .18
        test cx, 0x400
        jnz short .17
        jmp near FpShiftRight.57
.17:
        jmp near FpShiftRight.55
.18:
        test cx, 0x400
        jnz short .19
        jmp near FpShiftRight.27
.19:
        jmp near FpShiftRight.26
.20:
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        shr bl, 1
        and bx, 0xe
        jmp [cs:bx + FpLoadConstTable]
.21:
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        shr bl, 1
        and bx, 0xe
        jmp [cs:bx + FpTranscTable]
.22:
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        shr bl, 1
        and bx, 0xe
        jmp [cs:bx + FpMiscOpTable]
.23:
        test cx, 0x6
        jnz short FpSetStackFault
        jmp near FpShiftRight.71
.24:
        xor cl, 0x4
        test cx, 0x6
        jnz short FpSetStackFault
        mov ax, 0x1
        jmp near FpShiftRight.78
.25:
        test cl, 0x6
        jz short FpSetStackFault
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp near FpShiftRight.78

;-----------------------------------------------------------------------------
; FpSetStackFault                                               18B9:1009  MSC
; Sets status bit 40h (stack fault).
;-----------------------------------------------------------------------------
FpSetStackFault:
        or word [FpOpStatus], 0x40
        ret
        db 0x90
.1:
        mov dx, 0x8000
        jmp short FpAdd.1
        db 0x90

;-----------------------------------------------------------------------------
; FpSub                                                         18B9:1016  MSC
; FpAdd with the sign of the source flipped.
;-----------------------------------------------------------------------------
FpSub:
        mov dx, 0x80
        jmp short FpAdd.1
        db 0x90

;-----------------------------------------------------------------------------
; FpMul                                                         18B9:101C  MSC
; Arithmetic dispatch through the multiply table by operand types.
;-----------------------------------------------------------------------------
FpMul:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, FpMulTagTable
        jmp short FpAdd.2
        db 0x90

;-----------------------------------------------------------------------------
; FpDivRev                                                      18B9:1024  MSC
; FpDiv with the operands swapped.
;-----------------------------------------------------------------------------
FpDivRev:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        xchg si, di
        mov bx, FpDivTagTable
        jmp short FpAdd.2
        db 0x90

;-----------------------------------------------------------------------------
; FpDiv                                                         18B9:102E  MSC
; Arithmetic dispatch through the divide table by operand types.
;-----------------------------------------------------------------------------
FpDiv:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, FpDivTagTable
        jmp short FpAdd.2
        db 0x90

;-----------------------------------------------------------------------------
; FpAdd                                                         18B9:1036  MSC
; Arithmetic dispatch through the add table by operand types.
;-----------------------------------------------------------------------------
FpAdd:
        db 0x33, 0xD2                           ; insn: xor dx, dx
.1:
        mov bx, FpAddTagTable
.2:
        mov al, [di + 0xb]
        shl al, 1
        shl al, 1
        or al, [si + 0xb]
        cbw
        shl ax, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        xor dh, [di + 0xa]
        xor dl, [si + 0xa]
        mov cx, [di + 0x8]
        mov ax, [si + 0x8]
        jmp [cs:bx]
.3:
        db 0x8B, 0xF7                           ; insn: mov si, di
        db 0x8A, 0xD6                           ; insn: mov dl, dh
.4:
        call FpCopyToTemp
        mov [di + 0xa], dl
        ret
.5:
        or word [FpOpStatus], 0x4
        jmp short .7
.6:
        db 0x8B, 0xF7                           ; insn: mov si, di
.7:
        or word [FpOpStatus], 0x1
        jmp short FpCopyToTemp
.8:
        mov si, FpRegZero
.9:
        db 0x32, 0xF2                           ; insn: xor dh, dl
        and dh, 0x80
        call FpCopyConstToTemp
        or [di + 0xa], dh
        ret
.10:
        or word [FpOpStatus], 0x4
.11:
        mov si, FpRegInfinity
        jmp short .9
.12:
        or word [FpOpStatus], 0x4
.13:
        mov si, FpRegIndefinite
        or word [FpOpStatus], 0x1

FpCopyConstToTemp:
        mov di, [FpResultPtr]

FpCopyConst:
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        sub di, 0xc
        sub si, 0xc
        ret

;-----------------------------------------------------------------------------
; FpCopyToTemp                                                  18B9:10B1  MSC
; FpCopyReg into the temporary at [96h].
;-----------------------------------------------------------------------------
FpCopyToTemp:
        mov di, [FpResultPtr]
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jz short FpCopyReg.1

FpCopyReg:
        movsw
        movsw
        movsw
        movsw
        movsw
        movsw
        sub di, 0xc
        sub si, 0xc
.1:
        ret
.2:
        test byte [FpEmuCw + 1], 0x10
        jz short FpAdd.13
        db 0x32, 0xD6                           ; insn: xor dl, dh
        js short FpAdd.13
        jmp short FpAdd.3
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDF                           ; insn: mov bx, di
        add si, 0x6
        add di, 0x6
        mov cx, 0x4
        std
        repe cmpsw
        cld
        jc short .4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short FpAdd.7
.4:
        db 0x8B, 0xF3                           ; insn: mov si, bx
        jmp near FpAdd.7
.5:
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        jl short .6
        xchg si, di
        xchg dh, dl
        db 0x03, 0xC8                           ; insn: add cx, ax
        neg ax
.6:
        neg ax
        cmp ax, strict word 0x43
        jng short .9
        push bp
        push dx
        mov si, [di + 0x8]
        mov bp, 0x1
        db 0x32, 0xD6                           ; insn: xor dl, dh
        jns short .7
        neg bp
.7:
        mov dx, [di]
        mov cx, [di + 0x2]
        mov bx, [di + 0x4]
        mov di, [di + 0x6]
        db 0x0B, 0xED                           ; insn: or bp, bp
        js short .8
        jmp near FpDivMantissa.22
.8:
        sub dx, 0x1
        sbb cx, 0x0
        sbb bx, 0x0
        sbb di, 0x0
        jmp near FpDivMantissa.9
.9:
        push bp
        push dx
        push cx
        db 0x32, 0xD6                           ; insn: xor dl, dh
        pushf
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        lodsw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        lodsw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        lodsw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lodsw
        db 0x33, 0xF6                           ; insn: xor si, si
        xchg bp, si
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .17
.10:
        cmp si, 0xe
        jl short .12
        db 0x0B, 0xED                           ; insn: or bp, bp
        jz short .11
        or dx, 0x1
.11:
        db 0x8B, 0xEA                           ; insn: mov bp, dx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub si, 0x10
        ja short .10
        jz short .17
        jc short .14
.12:
        cmp si, 0x6
        jl short .15
        xchg ax, bp
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .13
        or ah, 0x1
.13:
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        xchg ax, bp
        db 0x8A, 0xD6                           ; insn: mov dl, dh
        db 0x8A, 0xF1                           ; insn: mov dh, cl
        db 0x8A, 0xCD                           ; insn: mov cl, ch
        db 0x8A, 0xEB                           ; insn: mov ch, bl
        db 0x8A, 0xDF                           ; insn: mov bl, bh
        db 0x8A, 0xF8                           ; insn: mov bh, al
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x32, 0xE4                           ; insn: xor ah, ah
        sub si, 0x8
        ja short .15
        jz short .17
.14:
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        rcl ax, 1
        inc si
        jnz short .14
        jmp short .17
.15:
        xchg cx, si
        test bp, 0x3f
        jz short .16
        or bp, 0x20
.16:
        shr ax, 1
        rcr bx, 1
        rcr si, 1
        rcr dx, 1
        rcr bp, 1
        loop .16
        db 0x8B, 0xCE                           ; insn: mov cx, si
.17:
        db 0x8B, 0xF7                           ; insn: mov si, di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        test bp, 0x3fff
        jz short .18
        or bp, 0x1
.18:
        popf
        pop ax
        js short .21
        add dx, [si]
        adc cx, [si + 0x2]
        adc bx, [si + 0x4]
        adc di, [si + 0x6]
        jnc short .20
        rcr di, 1
        rcr bx, 1
        rcr cx, 1
        rcr dx, 1
        rcr bp, 1
        jnc short .19
        or bp, 0x1
.19:
        inc ax
.20:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp near FpDivMantissa.22
.21:
        sub dx, [si]
        sbb cx, [si + 0x2]
        sbb bx, [si + 0x4]
        sbb di, [si + 0x6]
        jnc short .22
        db 0x33, 0xF6                           ; insn: xor si, si
        not di
        not bx
        not cx
        not dx
        neg bp
        cmc
        db 0x13, 0xD6                           ; insn: adc dx, si
        db 0x13, 0xCE                           ; insn: adc cx, si
        db 0x13, 0xDE                           ; insn: adc bx, si
        db 0x13, 0xFE                           ; insn: adc di, si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp near FpDivMantissa.9
.22:
        db 0x8B, 0xF0                           ; insn: mov si, ax
        pop ax
        xor ah, 0x80
        push ax
        jmp near FpDivMantissa.9
.23:
        push bp
        db 0x8A, 0xFE                           ; insn: mov bh, dh
        db 0x32, 0xF2                           ; insn: xor dh, dl
        push dx
        db 0x03, 0xC1                           ; insn: add ax, cx
        inc ax
        push ax
        db 0x22, 0xFA                           ; insn: and bh, dl
        db 0x33, 0xDB                           ; insn: xor bx, bx
        db 0x8B, 0xEB                           ; insn: mov bp, bx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov ax, [si]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .24
        mov dx, [di]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .24
        mul dx
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        db 0x8B, 0xCA                           ; insn: mov cx, dx
.24:
        push bp
        db 0x33, 0xED                           ; insn: xor bp, bp
        mov ax, [si]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .25
        mov dx, [di + 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .25
        mul dx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        adc bp, 0x0
.25:
        mov ax, [si + 0x2]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .26
        mov dx, [di]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .26
        mul dx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        adc bp, 0x0
.26:
        pop ax
        db 0x0B, 0xC1                           ; insn: or ax, cx
        push ax
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ax, [si]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .27
        mov dx, [di + 0x4]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .27
        mul dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
        adc cx, 0x0
.27:
        mov ax, [si + 0x2]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .28
        mov dx, [di + 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .28
        mul dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
        adc cx, 0x0
.28:
        mov ax, [si + 0x4]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .29
        mov dx, [di]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .29
        mul dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
        adc cx, 0x0
.29:
        pop ax
        db 0x0B, 0xC3                           ; insn: or ax, bx
        push ax
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov ax, [si]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .30
        mul word [di + 0x6]
        db 0x03, 0xE8                           ; insn: add bp, ax
        db 0x13, 0xCA                           ; insn: adc cx, dx
        adc bx, 0x0
.30:
        mov ax, [si + 0x2]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .31
        mov dx, [di + 0x4]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .31
        mul dx
        db 0x03, 0xE8                           ; insn: add bp, ax
        db 0x13, 0xCA                           ; insn: adc cx, dx
        adc bx, 0x0
.31:
        mov ax, [si + 0x4]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .32
        mov dx, [di + 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .32
        mul dx
        db 0x03, 0xE8                           ; insn: add bp, ax
        db 0x13, 0xCA                           ; insn: adc cx, dx
        adc bx, 0x0
.32:
        mov ax, [si + 0x6]
        mov dx, [di]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .33
        mul dx
        db 0x03, 0xE8                           ; insn: add bp, ax
        db 0x13, 0xCA                           ; insn: adc cx, dx
        adc bx, 0x0
.33:
        db 0x8B, 0xD5                           ; insn: mov dx, bp
        and bp, 0x3fff
        pop ax
        db 0x0B, 0xC5                           ; insn: or ax, bp
        push ax
        db 0x33, 0xED                           ; insn: xor bp, bp
        push dx
        mov ax, [si + 0x2]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .34
        mul word [di + 0x6]
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        adc bp, 0x0
.34:
        mov ax, [si + 0x4]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .35
        mov dx, [di + 0x4]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .35
        mul dx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        adc bp, 0x0
.35:
        mov ax, [si + 0x6]
        mov dx, [di + 0x2]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .36
        mul dx
        db 0x03, 0xC8                           ; insn: add cx, ax
        db 0x13, 0xDA                           ; insn: adc bx, dx
        adc bp, 0x0
.36:
        push cx
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ax, [si + 0x4]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .37
        mul word [di + 0x6]
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
        adc cx, 0x0
.37:
        mov ax, [si + 0x6]
        mov dx, [di + 0x4]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .38
        mul dx
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
        adc cx, 0x0
.38:
        mov ax, [si + 0x6]
        mul word [di + 0x6]
        db 0x03, 0xC5                           ; insn: add ax, bp
        db 0x13, 0xD1                           ; insn: adc dx, cx
        pop cx
        pop bp
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        pop ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .39
        or bp, 0x1
.39:
        pop si
        jmp near FpDivMantissa.21
.40:
        stc
        db 0x1B, 0xC1                           ; insn: sbb ax, cx
        db 0x32, 0xF2                           ; insn: xor dh, dl
        push bp
        push dx
        push si
        push di
        add si, 0x6
        add di, 0x6
        mov cx, 0x4
        std
        repe cmpsw
        cld
        pop di
        pop si
        pushf
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        lodsw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        lodsw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lodsw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        lodsw
        xchg ax, dx
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov di, FpDivisor
        movsw
        movsw
        movsw
        movsw
        db 0x33, 0xFF                           ; insn: xor di, di
        popf
        jc short .41
        shr dx, 1
        rcr ax, 1
        rcr bx, 1
        rcr cx, 1
        rcr di, 1
        inc bp
.41:
        push bp
        mov [FpTemp], di
        call FpDivMantissa
        push di
        mov word [FpTemp], 0x0
        call FpDivMantissa
        push di
        call FpDivMantissa
        push di
        call FpDivMantissa
        mov bp, 0x8001
        shl cx, 1
        rcl bx, 1
        rcl ax, 1
        rcl dx, 1
        jc short .43
        mov si, FpDivisor
        cmp dx, [si + 0x6]
        jnz short .42
        cmp ax, [si + 0x4]
        jnz short .42
        cmp bx, [si + 0x2]
        jnz short .42
        cmp cx, [si]
.42:
        jnc short .43
        db 0x0B, 0xC2                           ; insn: or ax, dx
        db 0x0B, 0xC1                           ; insn: or ax, cx
        db 0x0B, 0xC3                           ; insn: or ax, bx
        db 0x0A, 0xC4                           ; insn: or al, ah
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x8B, 0xE8                           ; insn: mov bp, ax
.43:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        pop cx
        pop bx
        pop di
        pop si
        jmp near FpDivMantissa.22

;-----------------------------------------------------------------------------
; FpDivMantissa                                                 18B9:1431  MSC
; Long division of two mantissas.
;-----------------------------------------------------------------------------
FpDivMantissa:
        mov si, [FpDivisor + 6]
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x3B, 0xD6                           ; insn: cmp dx, si
        jnc short .8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .1
        db 0x3B, 0xF0                           ; insn: cmp si, ax
        ja short .5
.1:
        div si
        push dx
        push bx
        xchg ax, di
        db 0x33, 0xED                           ; insn: xor bp, bp
        db 0x8B, 0xF5                           ; insn: mov si, bp
        mov ax, [FpDivisor]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        mul di
        db 0x8B, 0xF2                           ; insn: mov si, dx
.2:
        push ax
        mov ax, [FpDivisor + 2]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .3
        mul di
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x13, 0xEA                           ; insn: adc bp, dx
.3:
        mov ax, [FpDivisor + 4]
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        mul di
        db 0x03, 0xE8                           ; insn: add bp, ax
        adc dx, 0x0
        xchg ax, dx
.4:
        mov dx, [FpTemp]
        pop bx
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        db 0x1B, 0xCE                           ; insn: sbb cx, si
        pop bx
        db 0x1B, 0xDD                           ; insn: sbb bx, bp
        pop bp
        db 0x1B, 0xE8                           ; insn: sbb bp, ax
        xchg ax, bp
.5:
        xchg ax, dx
        xchg ax, cx
        xchg ax, bx
        jnc short .7
.6:
        dec di
        add cx, [FpDivisor]
        adc bx, [FpDivisor + 2]
        adc ax, [FpDivisor + 4]
        adc dx, [FpDivisor + 6]
        jnc short .6
.7:
        ret
.8:
        dec di
        sub cx, [FpDivisor]
        sbb bx, [FpDivisor + 2]
        sbb ax, [FpDivisor + 4]
        add cx, [FpDivisor + 2]
        adc bx, [FpDivisor + 4]
        db 0x13, 0xC2                           ; insn: adc ax, dx
        mov dx, [FpDivisor]
        cmc
        jmp short .5
        db 0x90
.9:
        mov al, 0x4
.10:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .12
        sub si, 0x10
        dec al
        jz short .11
        db 0x8B, 0xFB                           ; insn: mov di, bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        db 0x8B, 0xD5                           ; insn: mov dx, bp
        db 0x33, 0xED                           ; insn: xor bp, bp
        jmp short .10
.11:
        mov si, FpRegZero
        mov di, [FpResultPtr]
        pop ax
        pop bp
        jmp near FpCopyConst
        db 0x90
.12:
        test di, 0xff00
        jnz short .13
        sub si, 0x8
        xchg ax, di
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x8A, 0xC7                           ; insn: mov al, bh
        db 0x8A, 0xFB                           ; insn: mov bh, bl
        db 0x8A, 0xDD                           ; insn: mov bl, ch
        db 0x8A, 0xE9                           ; insn: mov ch, cl
        db 0x8A, 0xCE                           ; insn: mov cl, dh
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        xchg ax, di
        xchg ax, bp
        db 0x8A, 0xD4                           ; insn: mov dl, ah
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x32, 0xC0                           ; insn: xor al, al
        xchg ax, bp
        nop
.13:
        test di, 0x8000
        jnz short .22
.14:
        dec si
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        rcl di, 1
        test di, 0x8000
        jz short .14
        jmp short .22
.15:
        db 0x0B, 0xD5                           ; insn: or dx, bp
        db 0x0B, 0xCA                           ; insn: or cx, dx
        db 0x0A, 0xCD                           ; insn: or cl, ch
        db 0x8A, 0xEB                           ; insn: mov ch, bl
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jz short .20
        or word [FpOpStatus], 0x20
        shr al, 1
        jc short .17
        shr al, 1
        jc short .16
        cmp cx, 0x8000
        ja short .18
        jc short .19
        test bh, 0x1
        jz short .19
        jmp short .18
.16:
        pop ax
        push ax
        shl ah, 1
        jc short .19
        jmp short .18
.17:
        shr al, 1
        jc short .19
        pop ax
        push ax
        shl ah, 1
        jc short .18
        jmp short .19
.18:
        add bh, 0x1
        adc di, 0x0
        jnc short .19
        mov di, 0x8000
        inc si
.19:
        db 0x33, 0xED                           ; insn: xor bp, bp
        db 0x8B, 0xD5                           ; insn: mov dx, bp
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        db 0x8A, 0xD9                           ; insn: mov bl, cl
.20:
        jmp short .24
        db 0x90
.21:
        test di, 0x8000
        jnz short .22
        dec si
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        rcl di, 1
        nop
.22:
        mov al, [FpEmuCw + 1]
        shr al, 1
        jnc short .29
        shr al, 1
        db 0x0B, 0xED                           ; insn: or bp, bp
        jz short .24
        or word [FpOpStatus], 0x20
        shr al, 1
        jc short .27
        shr al, 1
        jc short .26
        cmp bp, 0x8000
        ja short .23
        jc short .24
        test dl, 0x1
        jz short .24
.23:
        db 0x33, 0xED                           ; insn: xor bp, bp
        add dx, 0x1
        db 0x13, 0xCD                           ; insn: adc cx, bp
        db 0x13, 0xDD                           ; insn: adc bx, bp
        db 0x13, 0xFD                           ; insn: adc di, bp
        jnc short .24
        mov di, 0x8000
        inc si
.24:
        mov ax, [FpResultPtr]
        xchg ax, di
        mov [di], dx
        mov [di + 0x2], cx
        mov [di + 0x4], bx
        mov [di + 0x6], ax
        pop ax
        pop bp
        and ah, 0x80
        mov [di + 0xa], ah
        cmp si, 0x4000
        jnl short .25
        cmp si, 0xc001
        jng short .30
        mov [di + 0x8], si
        mov byte [di + 0xb], 0x0
        ret
.25:
        jmp near .35
.26:
        pop ax
        push ax
        shl ah, 1
        jc short .24
        jmp short .23
.27:
        shr al, 1
        jc short .24
        pop ax
        push ax
        shl ah, 1
        jc short .23
        jmp short .24
.28:
        jmp near .15
.29:
        shr al, 1
        jnc short .28
        xchg ax, bp
        db 0x0A, 0xC4                           ; insn: or al, ah
        db 0x0A, 0xC2                           ; insn: or al, dl
        db 0x8A, 0xE6                           ; insn: mov ah, dh
        and ah, 0x7
        and dh, 0xf8
        xchg ax, bp
        db 0x0B, 0xED                           ; insn: or bp, bp
        jz short .24
        or word [FpOpStatus], 0x20
        shr al, 1
        jc short .32
        shr al, 1
        jc short .31
        cmp bp, 0x400
        ja short .33
        jc short .34
        test dh, 0x8
        jz short .34
        jmp short .33
.30:
        mov si, FpRegZero
        call FpCopyConst
        mov [di + 0xa], ah
        ret
.31:
        pop ax
        push ax
        shl ah, 1
        jc short .34
        jmp short .33
.32:
        shr al, 1
        jc short .34
        pop ax
        push ax
        shl ah, 1
        jc short .33
        jmp short .34
.33:
        db 0x33, 0xED                           ; insn: xor bp, bp
        add dh, 0x8
        db 0x13, 0xCD                           ; insn: adc cx, bp
        db 0x13, 0xDD                           ; insn: adc bx, bp
        db 0x13, 0xFD                           ; insn: adc di, bp
        jnc short .34
        mov di, 0x8000
        inc si
.34:
        db 0x33, 0xED                           ; insn: xor bp, bp
        db 0x32, 0xD2                           ; insn: xor dl, dl
        jmp near .24
.35:
        or word [FpOpStatus], 0x8
        mov al, [FpEmuCw + 1]
        shr al, 1
        shr al, 1
        shr al, 1
        jc short .37
        shr al, 1
        jc short .39
.36:
        mov si, FpRegInfinity
        call FpCopyConst
        mov [di + 0xa], ah
        ret
.37:
        shr al, 1
        jc short .38
        or word [FpOpStatus], 0x20
        test ah, 0x80
        jnz short .36
.38:
        mov si, FpRegMax
        call FpCopyConst
        mov [di + 0xa], ah
        ret
.39:
        or word [FpOpStatus], 0x20
        test ah, 0x80
        jz short .36
        jmp short .38
.40:
        es lodsw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        es lodsw
        db 0x8A, 0xD0                           ; insn: mov dl, al
        rol ax, 1
        and al, 0x1
        ror al, 1
        xchg al, ah
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .41
        call FpSetC1
.41:
        add si, 0xc
        mov [FpStackTop], si
        or dl, 0x80
        db 0x32, 0xF6                           ; insn: xor dh, dh
        cmp al, 0xff
        jz short .43
        cmp al, 0x0
        jz short .44
        mov [si + 0xa], ah
        sub al, 0x7f
        cbw
.42:
        mov [si + 0x8], ax
        mov [si + 0xb], dh
        mov [si + 0x7], dl
        mov [si + 0x5], di
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [si + 0x4], al
        mov [si + 0x2], ax
        mov [si], ax
        ret
.43:
        mov [si + 0xa], ah
        mov ax, 0x4000
        mov dh, 0x2
        cmp dl, 0x80
        jnz short .42
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .42
        or dh, 0x1
        jmp short .42
.44:
        mov [si + 0xa], ah
        cmp dl, 0x80
        jnz short .45
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .45
        mov ax, 0xc001
        or dh, 0x1
        jmp short .42
.45:
        or word [FpOpStatus], 0x2
        sub al, 0x7f
        cbw
        inc ax
.46:
        dec ax
        shl di, 1
        rcl dl, 1
        db 0x0A, 0xD2                           ; insn: or dl, dl
        jns short .46
        jmp short .42
.47:
        test cl, 0x2
        jnz short .48
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp near .55
.48:
        test cl, 0x1
        jnz short .49
        mov bx, [si + 0x5]
        mov al, [si + 0x7]
        mov ah, [si + 0xa]
        shl ax, 1
        mov ah, 0xff
        rcr ax, 1
        jmp near .55
.49:
        mov ah, [si + 0xa]
        jmp near .60
.50:
        jmp near .59
.51:
        jmp near .64
.52:
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, [FpStackTop]
        mov ax, [si + 0xa]
        mov cl, [si + 0xb]
        db 0x0A, 0xC9                           ; insn: or cl, cl
        jnz short .47
        mov cl, [si + 0xa]
        mov ax, [si + 0x8]
        cmp ax, 0x80
        jnl short .50
        cmp ax, strict word 0xff81
        jng short .51
        add al, 0x7f
        mov ah, [si + 0x7]
        xchg ah, al
        shl al, 1
        shl cl, 1
        rcr ax, 1
        mov dx, [si]
        or dx, [si + 0x2]
        db 0x0A, 0xD6                           ; insn: or dl, dh
        db 0x32, 0xF6                           ; insn: xor dh, dh
        mov bx, [si + 0x5]
        or dx, [si + 0x3]
        jz short .55
        or word [FpOpStatus], 0x20
.53:
        mov cl, [FpEmuCw + 1]
        shr cl, 1
        shr cl, 1
        shr cl, 1
        jc short .57
        shr cl, 1
        jc short .58
        cmp dx, 0x8000
        jc short .55
        ja short .54
        test bl, 0x1
        jz short .55
.54:
        db 0x8A, 0xD0                           ; insn: mov dl, al
        add bx, 0x1
        adc ax, strict word 0x0
        db 0x32, 0xD0                           ; insn: xor dl, al
        jns short .55
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        shl dx, 1
        cmp dh, 0xff
        jz short .59
.55:
        xchg ax, bx
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
.56:
        ret
.57:
        shr cl, 1
        jc short .55
        db 0x0A, 0xE4                           ; insn: or ah, ah
        js short .54
        jmp short .55
.58:
        db 0x0A, 0xE4                           ; insn: or ah, ah
        js short .55
        jmp short .54
.59:
        or word [FpOpStatus], 0x28
        mov cl, [FpEmuCw + 1]
        shr cl, 1
        shr cl, 1
        shr cl, 1
        jc short .61
        shr cl, 1
        jc short .63
.60:
        mov bx, [cs:FpSingleInf + 2]
        and ah, 0x80
        db 0x0A, 0xFC                           ; insn: or bh, ah
        mov ax, [cs:FpSingleInf]
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        jmp short .56
.61:
        shr cl, 1
        jc short .62
        test ah, 0x80
        jnz short .60
.62:
        mov bx, [cs:FpSingleMax + 2]
        and ah, 0x80
        db 0x0A, 0xE7                           ; insn: or ah, bh
        db 0x8A, 0xC3                           ; insn: mov al, bl
        stosw
        mov ax, [cs:FpSingleMax]
        stosw
        jmp short .56
.63:
        test ah, 0x80
        jz short .60
        jmp short .62
.64:
        or word [FpOpStatus], 0x30
        neg ax
        add ax, strict word 0xff82
        cmp ax, strict word 0x18
        jnl short .67
        xchg ax, cx
        mov dx, [si]
        or dx, [si + 0x2]
        db 0x8A, 0xC2                           ; insn: mov al, dl
        db 0x0A, 0xC6                           ; insn: or al, dh
        mov dx, [si + 0x4]
        mov bx, [si + 0x6]
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .65
        or dl, 0x1
.65:
        shr bx, 1
        rcr dx, 1
        jnc short .66
        or dl, 0x1
.66:
        loop .65
        xchg ah, ch
        mov ah, [si + 0xa]
        and ah, 0x80
        db 0x8A, 0xC7                           ; insn: mov al, bh
        db 0x8A, 0xFB                           ; insn: mov bh, bl
        db 0x8A, 0xDE                           ; insn: mov bl, dh
        db 0x8A, 0xF2                           ; insn: mov dh, dl
        db 0x32, 0xD2                           ; insn: xor dl, dl
        jmp near .53
.67:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        jmp near .55
.68:
        xchg di, si
        call FpSetC1
        xchg di, si
        jmp short .70
.69:
        mov di, [FpStackTop]
        cmp di, [FpStackLimit]
        jnc short .68
.70:
        add di, 0xc
        mov [FpStackTop], di
        es lodsw
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        es lodsw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        es lodsw
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        es lodsw
        db 0x8B, 0xF7                           ; insn: mov si, di
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        or bl, 0x80
        mov [si + 0x7], bl
        mov [si + 0x5], cx
        mov [si + 0x3], dx
        mov [si + 0x1], bp
        db 0x0B, 0xCD                           ; insn: or cx, bp
        db 0x0B, 0xCA                           ; insn: or cx, dx
        db 0x8A, 0xF4                           ; insn: mov dh, ah
        and dh, 0x80
        mov [si + 0xa], dh
        db 0x32, 0xF6                           ; insn: xor dh, dh
        mov [si], dh
        and ah, 0x7f
        shr ax, 1
        shr ax, 1
        shr ax, 1
        shr ax, 1
        cmp ax, 0x7ff
        jz short .72
        cmp ax, strict word 0x0
        jz short .73
        sub ax, 0x3ff
.71:
        mov [si + 0x8], ax
        mov [si + 0xb], dh
        ret
.72:
        mov ax, 0x4000
        mov dh, 0x2
        cmp bl, 0x80
        jnz short .71
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnz short .71
        or dh, 0x1
        jmp short .71
.73:
        cmp bl, 0x80
        jnz short .74
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jnz short .74
        mov ax, 0xc001
        mov dh, 0x1
        jmp short .71
.74:
        or word [FpOpStatus], 0x2
        sub ax, 0x3ff
        mov bp, [si]
        mov dx, [si + 0x2]
        mov cx, [si + 0x4]
        mov bx, [si + 0x6]
        inc ax
.75:
        dec ax
        shl bp, 1
        rcl dx, 1
        rcl cx, 1
        rcl bx, 1
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jns short .75
        mov [si], bp
        mov [si + 0x2], dx
        mov [si + 0x4], cx
        mov [si + 0x6], bx
        db 0x32, 0xF6                           ; insn: xor dh, dh
        jmp short .71
.76:
        test cl, 0x2
        jnz short .77
        db 0x33, 0xC0                           ; insn: xor ax, ax
        stosw
        stosw
        stosw
        stosw
        jmp near .89
.77:
        test cl, 0x1
        jnz short .78
        mov dx, [si + 0x1]
        mov bx, [si + 0x3]
        mov ax, [si + 0x5]
        mov cl, [si + 0x7]
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        xchg ax, dx
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        mov bh, [si + 0xa]
        and bh, 0x80
        mov ax, 0x7ff0
        db 0x0A, 0xE7                           ; insn: or ah, bh
        db 0x0A, 0xC1                           ; insn: or al, cl
        stosw
        jmp near .89
.78:
        mov bl, [si + 0xa]
        and bl, 0x80
        jmp near .92
.79:
        jmp near .91
.80:
        jmp near .97
.81:
        jmp short .76
        db 0x90
.82:
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, [FpStackTop]
        mov cl, [si + 0xb]
        db 0x0A, 0xC9                           ; insn: or cl, cl
        jnz short .81
        mov cl, [si + 0xa]
        mov bp, [si + 0x8]
        cmp bp, 0x400
        jnl short .79
        cmp bp, 0xfc01
        jng short .80
        mov al, [si]
        mov dx, [si + 0x1]
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .83
        or dl, 0x1
.83:
        test dl, 0x7
        jz short .87
        or word [FpOpStatus], 0x20
        mov al, [FpEmuCw + 1]
        shr al, 1
        shr al, 1
        shr al, 1
        jc short .86
        shr al, 1
        jc short .85
        test dl, 0x4
        jz short .87
        test dl, 0xb
        jz short .87
.84:
        mov bx, [si + 0x3]
        mov ax, [si + 0x5]
        mov cl, [si + 0x7]
        and cl, 0x7f
        add dx, 0x8
        adc bx, 0x0
        adc ax, strict word 0x0
        adc cl, 0x0
        jns short .88
        and cl, 0x7f
        inc bp
        cmp bp, 0x400
        jl short .88
        jmp short .90
.85:
        shl cl, 1
        jnc short .84
        jmp short .87
.86:
        shr al, 1
        jc short .87
        shl cl, 1
        jc short .84
.87:
        mov bx, [si + 0x3]
        mov ax, [si + 0x5]
        mov cl, [si + 0x7]
        and cl, 0x7f
.88:
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        shr cl, 1
        rcr ax, 1
        rcr bx, 1
        rcr dx, 1
        xchg ax, dx
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        db 0x8B, 0xC5                           ; insn: mov ax, bp
        add ax, 0x3ff
        shl ax, 1
        shl ax, 1
        shl ax, 1
        shl ax, 1
        db 0x0A, 0xC1                           ; insn: or al, cl
        mov cl, [si + 0xa]
        and cl, 0x80
        db 0x0A, 0xE1                           ; insn: or ah, cl
        stosw
.89:
        ret
.90:
        sub di, 0x6
.91:
        or word [FpOpStatus], 0x28
        mov bl, [si + 0xa]
        and bl, 0x80
        mov cl, [FpEmuCw + 1]
        shr cl, 1
        shr cl, 1
        shr cl, 1
        jc short .94
        shr cl, 1
        jc short .96
.92:
        mov si, FpDoubleInf
.93:
        cs movsw
        cs movsw
        cs movsw
        cs lodsw
        db 0x0A, 0xE3                           ; insn: or ah, bl
        stosw
        jmp short .89
.94:
        shr cl, 1
        jc short .95
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jnz short .92
.95:
        mov si, FpDoubleMax
        jmp short .93
.96:
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jz short .92
        jmp short .95
.97:
        or word [FpOpStatus], 0x30
        add bp, 0x3ff
        neg bp
        db 0x8B, 0xCD                           ; insn: mov cx, bp
        add cx, 0x4
        mov dh, [si + 0xa]
        and dh, 0x80
        mov dl, [si + 0x7]
        mov bx, [si + 0x5]
        mov bp, [si + 0x3]
        mov ax, [si + 0x1]
.98:
        shr dl, 1
        rcr bx, 1
        rcr bp, 1
        rcr ax, 1
        loop .98
        stosw
        db 0x8B, 0xC5                           ; insn: mov ax, bp
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        jmp short .89
.99:
        es lodsw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .102
        db 0x33, 0xED                           ; insn: xor bp, bp
        db 0x8B, 0xDD                           ; insn: mov bx, bp
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov ax, 0xf
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .100
        call FpSetC1
.100:
        add si, 0xc
        mov [FpStackTop], si
        db 0x32, 0xC9                           ; insn: xor cl, cl
        mov [si + 0xb], cl
        db 0x8B, 0xCF                           ; insn: mov cx, di
        and ch, 0x80
        jns short .101
        neg di
.101:
        mov [si + 0xa], ch
        jmp near FpNormalize
.102:
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .103
        call FpSetC1
.103:
        add si, 0xc
        mov [FpStackTop], si
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [si], ax
        mov [si + 0x2], ax
        mov [si + 0x4], ax
        mov [si + 0x6], ax
        mov word [si + 0x8], 0xc001
        mov [si + 0xa], ah
        mov ah, 0x1
        mov [si + 0xb], ah
        ret
.104:
        push si
        mov si, [FpStackTop]
        test byte [si + 0xb], 0x2
        jnz short .108
        test byte [si + 0xb], 0x1
        jnz short .107
        mov cx, [si + 0x8]
        cmp cx, 0xf
        jg short .108
        mov bp, [si + 0x4]
        mov di, [si + 0x6]
        mov dx, [si]
        mov bx, [si + 0x2]
        call FpShiftRight
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jnz short .108
        mov ah, [si + 0xa]
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jns short .105
        neg dx
        jz short .106
.105:
        db 0x33, 0xC2                           ; insn: xor ax, dx
        js short .108
.106:
        pop di
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        ret
.107:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        jmp short .106
.108:
        or word [FpOpStatus], 0x1
        mov dx, 0x8000
        jmp short .106
.109:
        es lodsw
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        es lodsw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xC5                           ; insn: or ax, bp
        jz short .112
        db 0x33, 0xDB                           ; insn: xor bx, bx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov ax, 0x1f
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .110
        call FpSetC1
.110:
        add si, 0xc
        mov [FpStackTop], si
        db 0x32, 0xC9                           ; insn: xor cl, cl
        mov [si + 0xb], cl
        db 0x8B, 0xCF                           ; insn: mov cx, di
        and ch, 0x80
        jns short .111
        xor di, -0x1
        xor bp, -0x1
        add bp, 0x1
        adc di, 0x0
.111:
        mov [si + 0xa], ch
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .113
        jmp near FpNormalize
.112:
        jmp near .102
.113:
        db 0x8B, 0xFD                           ; insn: mov di, bp
        db 0x33, 0xED                           ; insn: xor bp, bp
        sub ax, strict word 0x10
        jmp near FpNormalize
.114:
        push si
        call FpToInt32
        pop di
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        ret

;-----------------------------------------------------------------------------
; FpToInt32                                                     18B9:1C17  MSC
; Converts ST to a 32-bit integer.
;-----------------------------------------------------------------------------
FpToInt32:
        mov si, [FpStackTop]
        test byte [si + 0xb], 0x2
        jnz short .5
        test byte [si + 0xb], 0x1
        jnz short .3
        mov cx, [si + 0x8]
        cmp cx, 0x1f
        jg short .5
        mov bp, [si + 0x4]
        mov di, [si + 0x6]
        mov dx, [si]
        mov bx, [si + 0x2]
        call FpShiftRight
        db 0x0B, 0xED                           ; insn: or bp, bp
        jnz short .5
        mov ah, [si + 0xa]
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jns short .1
        xor bx, -0x1
        xor dx, -0x1
        add dx, 0x1
        adc bx, 0x0
.1:
        db 0x33, 0xC3                           ; insn: xor ax, bx
        js short .4
.2:
        ret
.3:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        ret
.4:
        db 0x0B, 0xDA                           ; insn: or bx, dx
        jz short .2
.5:
        or word [FpOpStatus], 0x1
        mov bx, 0x8000
        db 0x33, 0xD2                           ; insn: xor dx, dx
        ret
.6:
        es lodsw
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        es lodsw
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        es lodsw
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        es lodsw
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xC5                           ; insn: or ax, bp
        db 0x0B, 0xC3                           ; insn: or ax, bx
        db 0x0B, 0xC2                           ; insn: or ax, dx
        jz short .10
        mov ax, 0x3f
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .7
        call FpSetC1
.7:
        add si, 0xc
        mov [FpStackTop], si
        db 0x32, 0xC9                           ; insn: xor cl, cl
        mov [si + 0xb], cl
        db 0x8B, 0xCF                           ; insn: mov cx, di
        and ch, 0x80
        jns short .8
        call FpNegate64
.8:
        mov [si + 0xa], ch
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .9
        db 0x0B, 0xED                           ; insn: or bp, bp
        jnz short .9
        db 0x8B, 0xFB                           ; insn: mov di, bx
        db 0x8B, 0xEA                           ; insn: mov bp, dx
        db 0x33, 0xDB                           ; insn: xor bx, bx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        sub ax, strict word 0x20
.9:
        jmp near FpNormalize
.10:
        jmp near FpDivMantissa.102
.11:
        push si
        call FpToInt64
        xchg ax, di
        xchg ax, dx
        pop di
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        db 0x8B, 0xC5                           ; insn: mov ax, bp
        stosw
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        ret

;-----------------------------------------------------------------------------
; FpToInt64                                                     18B9:1CD9  MSC
; Converts ST to a 64-bit integer.
;-----------------------------------------------------------------------------
FpToInt64:
        mov si, [FpStackTop]
        test byte [si + 0xb], 0x2
        jnz short .7
        test byte [si + 0xb], 0x1
        jnz short .4
        mov cx, [si + 0x8]
        cmp cx, 0x3f
        jg short .7
        mov bp, [si + 0x4]
        mov di, [si + 0x6]
        mov dx, [si]
        mov bx, [si + 0x2]
        call FpShiftRight
        mov ah, [si + 0xa]
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jns short .1
        call FpNegate64
.1:
        db 0x33, 0xC7                           ; insn: xor ax, di
        js short .6
.2:
        cmp si, [FpStackBase]
        jnz short .3
        call FpSetC2
.3:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.4:
        db 0x33, 0xFF                           ; insn: xor di, di
.5:
        db 0x33, 0xED                           ; insn: xor bp, bp
        db 0x8B, 0xDD                           ; insn: mov bx, bp
        db 0x8B, 0xD5                           ; insn: mov dx, bp
        jmp short .2
.6:
        db 0x0B, 0xFD                           ; insn: or di, bp
        db 0x0B, 0xFB                           ; insn: or di, bx
        db 0x0B, 0xFA                           ; insn: or di, dx
        jnz short .7
        jmp short .2
.7:
        or word [FpOpStatus], 0x1
        mov di, 0x8000
        jmp short .5

;-----------------------------------------------------------------------------
; FpNegate64                                                    18B9:1D3C  MSC
; Negates a 64-bit value in DI:BP:BX:DX.
;-----------------------------------------------------------------------------
FpNegate64:
        not di
        not bp
        not bx
        neg dx
        cmc
        adc bx, 0x0
        adc bp, 0x0
        adc di, 0x0
        ret

;-----------------------------------------------------------------------------
; FpRndint                                                      18B9:1D4F  MSC
; Frndint.
;-----------------------------------------------------------------------------
FpRndint:
        mov si, [FpStackTop]
        mov cx, [si + 0x8]
        cmp cx, 0x3f
        jnl short .1
        mov bp, [si + 0x4]
        mov di, [si + 0x6]
        mov dx, [si]
        mov bx, [si + 0x2]
        call FpShiftRight
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x0B, 0xC7                           ; insn: or ax, di
        db 0x0B, 0xC5                           ; insn: or ax, bp
        db 0x0B, 0xC3                           ; insn: or ax, bx
        db 0x0B, 0xC2                           ; insn: or ax, dx
        jz short .2
        mov ax, 0x3f
        call FpNormalize
.1:
        ret
.2:
        mov word [si + 0x8], 0xc001
        mov [si], ax
        mov [si + 0x2], ax
        mov [si + 0x4], ax
        mov [si + 0x6], ax
        mov byte [si + 0xb], 0x1
        jmp short .1

;-----------------------------------------------------------------------------
; FpNormalize                                                   18B9:1D92  MSC
; Shifts the mantissa left until the top bit is set and adjusts the exponent.
;-----------------------------------------------------------------------------
FpNormalize:
        db 0x33, 0xC9                           ; insn: xor cx, cx
.1:
        shl dx, 1
        rcl bx, 1
        rcl bp, 1
        rcl di, 1
        jc short .2
        loop .1
.2:
        rcr di, 1
        rcr bp, 1
        rcr bx, 1
        rcr dx, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov [si + 0x8], ax
        mov [si], dx
        mov [si + 0x2], bx
        mov [si + 0x4], bp
        mov [si + 0x6], di
        ret

;-----------------------------------------------------------------------------
; FpShiftRight                                                  18B9:1DB9  MSC
; Shifts a mantissa right for a given exponent.
;-----------------------------------------------------------------------------
FpShiftRight:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub cx, 0x3f
        neg cx
        dec cx
        jl short .7
        jz short .4
        cmp cx, 0x40
        jnl short .8
        cmp cx, 0x30
        jng short .2
        db 0x0B, 0xD3                           ; insn: or dx, bx
        db 0x0B, 0xD5                           ; insn: or dx, bp
        jz short .1
        or al, 0x1
.1:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x8B, 0xEF                           ; insn: mov bp, di
        db 0x8B, 0xDF                           ; insn: mov bx, di
        sub cx, 0x30
.2:
        shr di, 1
        rcr bp, 1
        rcr bx, 1
        rcr dx, 1
        jnc short .3
        rcl al, 1
.3:
        loop .2
.4:
        shr di, 1
        rcr bp, 1
        rcr bx, 1
        rcr dx, 1
        rcl ah, 1
.5:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .7
        or word [FpOpStatus], 0x20
        test byte [FpEmuCw + 1], 0x4
        jnz short .9
        test byte [FpEmuCw + 1], 0x8
        jnz short .10
        db 0x0A, 0xC2                           ; insn: or al, dl
        db 0x22, 0xE0                           ; insn: and ah, al
        shr ah, 1
        jnc short .7
.6:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        add dx, 0x1
        db 0x13, 0xD8                           ; insn: adc bx, ax
        db 0x13, 0xE8                           ; insn: adc bp, ax
        db 0x13, 0xF8                           ; insn: adc di, ax
.7:
        ret
.8:
        mov al, 0x1
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x8B, 0xEF                           ; insn: mov bp, di
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x8B, 0xD7                           ; insn: mov dx, di
        jmp short .5
.9:
        test byte [FpEmuCw + 1], 0x8
        jnz short .7
        test byte [si + 0xa], 0x80
        jnz short .6
        jmp short .7
.10:
        test byte [si + 0xa], 0x80
        jnz short .7
        jmp short .6
.11:
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .12
        call FpSetC1
.12:
        add si, 0xc
        mov [FpStackTop], si
        xchg di, si
        mov ax, es
        mov dx, ds
        mov es, dx
        mov ds, ax
        movsw
        movsw
        movsw
        movsw
        mov ax, es
        mov dx, ds
        mov es, dx
        mov ds, ax
        es lodsw
        sub di, 0x8
        xchg si, di
        db 0x8A, 0xF4                           ; insn: mov dh, ah
        and dh, 0x80
        mov [si + 0xa], dh
        and ah, 0x7f
        db 0x32, 0xF6                           ; insn: xor dh, dh
        cmp ax, 0x7fff
        jz short .14
        cmp ax, strict word 0x0
        jz short .15
        sub ax, 0x3fff
.13:
        mov [si + 0x8], ax
        mov [si + 0xb], dh
        ret
.14:
        mov ax, 0x4000
        mov dh, 0x2
        cmp word [si + 0x6], 0x8000
        jnz short .13
        mov bp, [si + 0x4]
        or bp, [si + 0x2]
        or bp, [si]
        jnz short .13
        or dh, 0x1
        jmp short .13
.15:
        mov bp, [si + 0x6]
        or bp, [si + 0x4]
        or bp, [si + 0x2]
        or bp, [si]
        jnz short .17
.16:
        mov ax, 0xc001
        mov dh, 0x1
        jmp short .13
.17:
        or word [FpOpStatus], 0x30
        db 0x33, 0xED                           ; insn: xor bp, bp
        mov [si], bp
        mov [si + 0x2], bp
        mov [si + 0x4], bp
        mov [si + 0x6], bp
        jmp short .16
.18:
        test bh, 0x1
        jnz short .20
        movsw
        movsw
        movsw
        movsw
        mov ax, 0x7fff
        db 0x0A, 0xE6                           ; insn: or ah, dh
        stosw
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .19
        call FpSetC2
.19:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.20:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        stosw
        stosw
        stosw
        mov ax, 0x8000
        stosw
        mov ax, 0x7fff
        db 0x0A, 0xE6                           ; insn: or ah, dh
        stosw
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .21
        call FpSetC2
.21:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.22:
        test bh, 0x2
        jnz short .18
        db 0x33, 0xC0                           ; insn: xor ax, ax
        stosw
        stosw
        stosw
        stosw
        stosw
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .23
        call FpSetC2
.23:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.24:
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, [FpStackTop]
        mov ax, [si + 0x8]
        add ax, 0x3fff
        mov dh, [si + 0xa]
        and dh, 0x80
        db 0x0A, 0xE6                           ; insn: or ah, dh
        mov bh, [si + 0xb]
        db 0x0A, 0xFF                           ; insn: or bh, bh
        jnz short .22
        movsw
        movsw
        movsw
        movsw
        stosw
        sub si, 0x8
        cmp si, [FpStackBase]
        jnz short .25
        call FpSetC2
.25:
        sub si, 0xc
        mov [FpStackTop], si
        ret
.26:
        mov si, [FpStackTop]
        and byte [si + 0xa], 0x7f
        ret
.27:
        mov si, [FpStackTop]
        xor byte [si + 0xa], 0x80
        ret
.28:
        es lodsw
        mov [FpEmuCw], ax
        mov [FpUserCw], ax
        ret
.29:
        mov ax, [FpUserCw]
        db 0x8B, 0xFE                           ; insn: mov di, si
        stosw
        ret
.30:
        mov ax, [FpEmuStatus]
        db 0x8B, 0xFE                           ; insn: mov di, si
        stosw
        ret
.31:
        mov si, [FpStackTop]
        db 0x8B, 0xFE                           ; insn: mov di, si
        sub di, 0xc
        mov cl, 0xf
        mov al, [di + 0x8]
        and al, 0xf
        db 0x2A, 0xC8                           ; insn: sub cl, al
        mov ax, [di + 0x6]
        shr ax, cl
        mov cl, [di + 0xa]
        db 0x0A, 0xC9                           ; insn: or cl, cl
        jns short .32
        neg ax
.32:
        add ax, [si + 0x8]
        jo short .34
        cmp ax, 0x4000
        jnl short .35
        cmp ax, 0xc001
        jng short .36
.33:
        mov [si + 0x8], ax
        ret
.34:
        jns short .36
.35:
        mov ax, 0x4000
        mov byte [si + 0xb], 0x3
        jmp short .33
.36:
        mov ax, 0xc001
        mov byte [si + 0xb], 0x1
        jmp short .33
.37:
        mov dx, 0x1
        jmp short .39
.38:
        db 0x33, 0xD2                           ; insn: xor dx, dx
.39:
        test word [FpOpStatus], 0x2000
        jz short .40
        xchg si, di
.40:
        mov al, [si + 0xa]
        mov ah, [di + 0xa]
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov bl, [si + 0xb]
        shl bl, 1
        shl bl, 1
        or bl, [di + 0xb]
        shl bl, 1
        jmp [cs:bx + FpCompareTagTable]
.41:
        db 0x32, 0xE0                           ; insn: xor ah, al
        js short .48
        db 0x0A, 0xC0                           ; insn: or al, al
        jns short .42
        xchg si, di
        xchg bl, bh
.42:
        mov ax, [si + 0x8]
        cmp ax, [di + 0x8]
        jl short .44
        jg short .45
        mov cx, 0x4
        add si, 0x6
        add di, 0x6
        std
        repe cmpsw
        cld
        jc short .44
        ja short .45
.43:
        mov byte [FpEmuStatus + 1], 0x40
        jmp short .52
.44:
        mov byte [FpEmuStatus + 1], 0x1
        jmp short .52
.45:
        mov byte [FpEmuStatus + 1], 0x0
        jmp short .52
.46:
        mov byte [FpEmuStatus + 1], 0x41
        jmp short .52
.47:
        test byte [FpEmuCw + 1], 0x10
        jz short .46
.48:
        and al, 0x80
        js short .44
        jmp short .45
.49:
        test byte [FpEmuCw + 1], 0x10
        jz short .46
.50:
        and ah, 0x80
        js short .45
        jmp short .44
.51:
        test byte [FpEmuCw + 1], 0x10
        jz short .46
        db 0x32, 0xE0                           ; insn: xor ah, al
        and ah, 0x80
        jz short .43
        jmp short .48
.52:
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .54
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .53
        call FpSetC2
.53:
        sub si, 0xc
        mov [FpStackTop], si
.54:
        ret
.55:
        mov si, [FpStackTop]
        mov al, 0x41
        cmp si, [FpStackBase]
        jz short .56
        mov ax, [si + 0xa]
        xchg al, ah
        rol ax, 1
        and al, 0x7
        mov bx, FpExamineCodes
        cs xlatb
.56:
        mov [FpEmuStatus + 1], al
        ret
.57:
        mov si, [FpStackTop]
        mov al, [si + 0xa]
        and al, 0x80
        db 0x33, 0xDB                           ; insn: xor bx, bx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov bl, [si + 0xb]
        shl bx, 1
        jmp [cs:bx + FpTestTagTable]
.58:
        mov bx, FpConstPi
        jmp short .65
.59:
        mov bx, FpConstL2T
        jmp short .65
.60:
        mov bx, FpConstL2E
        jmp short .65
.61:
        mov bx, FpConstLg2
        jmp short .65
.62:
        mov bx, FpConstLn2
        jmp short .65
.63:
        mov bx, FpConstZero
        jmp short .65
.64:
        mov bx, FpConstOne
.65:
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .66
        call FpSetC1
.66:
        add si, 0xc
        mov [FpStackTop], si
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov di, [FpStackTop]
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        ret
.67:
        call FpStackRoom
        jnc short .68
        pop dx
        jmp near FpEmulate.35
.68:
        db 0x8B, 0xF7                           ; insn: mov si, di
.69:
        add si, 0xc
        cmp si, [FpStackTop]
        jg short .70
        call FpCopyReg
        add di, 0xc
        jmp short .69
.70:
        sub di, 0xc
        mov [FpStackTop], di
        ret
.71:
        test cx, 0x1c00
        jz short .74
        mov ax, ds
        mov es, ax
        call FpStackRoom
        jnc short .72
        pop dx
        jmp near FpEmulate.35
.72:
        mov cx, 0x6
.73:
        mov ax, [si]
        mov bx, [di]
        stosw
        mov [si], bx
        inc si
        inc si
        loop .73
.74:
        ret
.75:
        call FpStackRoom
        jnc short .76
        pop dx
        jmp near FpEmulate.35
.76:
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .77
        call FpSetC1
.77:
        add si, 0xc
        mov [FpStackTop], si
        mov ax, ds
        mov es, ax
        xchg si, di
        call FpCopyReg
        ret
.78:
        test cx, 0x1c0
        jz short .80
        call FpStackRoom
        jnc short .79
        pop dx
        jmp near FpEmulate.35
.79:
        mov dx, ds
        mov es, dx
        call FpCopyReg
.80:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .82
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .81
        call FpSetC2
.81:
        sub si, 0xc
        mov [FpStackTop], si
.82:
        ret
.83:
        push bp
        mov di, [FpStackTop]
        mov [FpResultPtr], di
        db 0x33, 0xED                           ; insn: xor bp, bp
        mov word [FpRemFlag], 0x0
        db 0x8B, 0xF7                           ; insn: mov si, di
        sub si, 0xc
        mov ax, [di + 0x8]
        sub ax, [si + 0x8]
        mov [FpRemExp], ax
        mov dx, [di]
        mov cx, [di + 0x2]
        mov bx, [di + 0x4]
        mov ax, [di + 0x6]
        jnl short .84
        mov si, [di + 0x8]
        jmp short .88
        db 0x90
.84:
        cmp ax, [si + 0x6]
        jc short .86
        ja short .85
        cmp bx, [si + 0x4]
        jc short .86
        ja short .85
        cmp cx, [si + 0x2]
        jc short .86
        ja short .85
        cmp dx, [si]
        jc short .86
.85:
        call FpSubMantissa
        cmp word [FpRemExp], 0x0
        jz short .87
        call FpNormLoop
        jnz short .84
        jmp short .87
.86:
        cmp word [FpRemExp], 0x0
        jz short .87
        call FpShiftLeft1
        call FpSubMantissa
        call FpNormLoop
        jnz short .84
        jmp short .87
.87:
        mov si, [si + 0x8]
.88:
        mov di, [di + 0xa]
        xchg ax, di
        db 0x8A, 0xE0                           ; insn: mov ah, al
        push ax
        db 0x8B, 0xC5                           ; insn: mov ax, bp
        and bp, -0x4
        or bp, [FpRemFlag]
        mov ah, [FpEmuStatus + 1]
        and ah, 0xfb
        test al, 0x1
        jnz short .89
        and ah, 0xfd
        jmp short .90
.89:
        or ah, 0x2
.90:
        test al, 0x2
        jnz short .91
        db 0x0B, 0xED                           ; insn: or bp, bp
        jz short .95
        and ah, 0xbf
        jmp short .92
.91:
        or ah, 0x40
.92:
        test al, 0x4
        jnz short .93
        db 0x0B, 0xED                           ; insn: or bp, bp
        jz short .97
        and ah, 0xfe
        jmp short .94
.93:
        or ah, 0x1
.94:
        mov [FpEmuStatus + 1], ah
        db 0x33, 0xED                           ; insn: xor bp, bp
        jmp near FpDivMantissa.9
.95:
        mov al, [FpEmuStatus + 1]
        test al, 0x2
        jnz short .96
        and ah, 0xbf
        jmp short .97
.96:
        or ah, 0x40
.97:
        mov al, [FpEmuStatus + 1]
        test al, 0x40
        jnz short .98
        and ah, 0xfe
        jmp short .94
.98:
        or ah, 0x1
        jmp short .94

;-----------------------------------------------------------------------------
; FpNormLoop                                                    18B9:2297  MSC
; Repeats FpShiftLeft1 while needed.
;-----------------------------------------------------------------------------
FpNormLoop:
        test ah, 0x80
        jnz short .1
        cmp word [FpRemExp], 0x0
        jz short .1
        call FpShiftLeft1
        jmp short FpNormLoop
.1:
        ret

;-----------------------------------------------------------------------------
; FpShiftLeft1                                                  18B9:22A9  MSC
; Shifts a mantissa left one bit.
;-----------------------------------------------------------------------------
FpShiftLeft1:
        shl dx, 1
        rcl cx, 1
        rcl bx, 1
        rcl ax, 1
        dec word [FpRemExp]
        shl bp, 1
        jc short .1
        ret
.1:
        mov word [FpRemFlag], 0x1
        ret

;-----------------------------------------------------------------------------
; FpSubMantissa                                                 18B9:22C1  MSC
; Subtracts mantissas; also the fsqrt entry.
;-----------------------------------------------------------------------------
FpSubMantissa:
        sub dx, [si]
        sbb cx, [si + 0x2]
        sbb bx, [si + 0x4]
        sbb ax, [si + 0x6]
        inc bp
        ret
.1:
        mov si, [FpStackTop]
        call FpSqrtCore
        ret
.2:
        rcr ah, 1
        jnc short .5
        rcl al, 1
        jc short .4
        mov al, [FpEmuCw + 1]
        test al, 0x10
        jnz short .6
        jmp short .4
.3:
        test ah, 0x2
        jnz short .2
        rcr ah, 1
        jc short .6
.4:
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, FpRegIndefinite
        call FpCopyConst
        db 0x8B, 0xF7                           ; insn: mov si, di
.5:
        or word [FpOpStatus], 0x81
.6:
        ret

;-----------------------------------------------------------------------------
; FpSqrtCore                                                    18B9:2301  MSC
; Square root of ST (halves the exponent).
;-----------------------------------------------------------------------------
FpSqrtCore:
        mov ax, [si + 0xa]
        test ax, 0x380
        jnz short FpSubMantissa.3
        push si
        mov di, FpTemp0
        mov word [di + 0xa], 0x0
        mov ax, [si + 0x8]
        dec ax
        mov bx, [si + 0x6]
        mov cx, [si + 0x4]
        mov dx, [si + 0x2]
        test al, 0x1
        jz short .1
        inc ax
        shr bx, 1
        rcr cx, 1
        rcr dx, 1
.1:
        sar ax, 1
        mov [di + 0x8], ax
        cmp bx, -0x2
        jc short .2
        stc
        jmp short .4
.2:
        push dx
        mov ax, 0xb075
        mul bx
        mov bp, 0x57d8
        db 0x03, 0xEA                           ; insn: add bp, dx
        jnc short .3
        mov bp, 0xffff
.3:
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        div bp
        db 0x03, 0xE8                           ; insn: add bp, ax
        rcr bp, 1
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        div bp
        stc
        db 0x13, 0xE8                           ; insn: adc bp, ax
        rcr bp, 1
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        div bp
        db 0x8B, 0xF0                           ; insn: mov si, ax
        pop ax
        div bp
        db 0x8B, 0xDD                           ; insn: mov bx, bp
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add cx, 0x1
        db 0x13, 0xDE                           ; insn: adc bx, si
.4:
        rcr bx, 1
        rcr cx, 1
        mov [di + 0x6], bx
        mov [di + 0x4], cx
        mov word [di + 0x2], 0x0
        mov word [di], 0x0
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop di
        mov [FpResultPtr], di
        call FpDivRev
        mov si, FpTemp0
        call FpAdd
        dec word [di + 0x8]
        db 0x8B, 0xF7                           ; insn: mov si, di
        ret

;-----------------------------------------------------------------------------
; FpLoadConst                                                   18B9:2399  MSC
; Copies a constant into the work temporary at 8Ah.
;-----------------------------------------------------------------------------
FpLoadConst:
        push di
        mov di, FpTemp5
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        cs movsw
        mov si, FpTemp5
        pop di
        ret
.1:
        db 0x3A, 0xED                           ; insn: cmp ch, ch
        jmp short FpCompare.2

;-----------------------------------------------------------------------------
; FpCompare                                                     18B9:23B2  MSC
; Compares two temporary reals.
;-----------------------------------------------------------------------------
FpCompare:
        mov cx, cs
        mov ds, cx
        mov cx, [si + 0xa]
        and cl, 0x80
        mov dx, [es:di + 0xa]
        and dl, 0x80
        db 0x3A, 0xD1                           ; insn: cmp dl, cl
        jnz short .3
        push es
        push si
        push di
        db 0x0A, 0xC9                           ; insn: or cl, cl
        jns short .1
        push ds
        push es
        pop ds
        pop es
        xchg si, di
        xchg cx, dx
.1:
        and ch, 0x1
        and dh, 0x1
        db 0x3A, 0xF5                           ; insn: cmp dh, ch
        jnz short .2
        db 0x0A, 0xED                           ; insn: or ch, ch
        ja short FpLoadConst.1
        mov cx, [si + 0x8]
        add cx, 0x3fff
        mov dx, [es:di + 0x8]
        add dx, 0x3fff
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jnz short .2
        add si, 0x6
        add di, 0x6
        std
        cmpsw
        jnz short .2
        cmpsw
        jnz short .2
        cmpsw
        jnz short .2
        cmpsw
.2:
        cld
        pop di
        pop si
        pop es
.3:
        mov cx, es
        mov ds, cx
        ret

;-----------------------------------------------------------------------------
; FpPolyRatio                                                   18B9:2411  MSC
; Evaluates a polynomial ratio from a coefficient table in BX; also the fptan
; entry.
;-----------------------------------------------------------------------------
FpPolyRatio:
        mov di, FpTemp4
        call FpCopyReg
        push di
        push si
        push bx
        mov di, FpTemp3
        call FpCopyReg
        mov [FpResultPtr], di
        call FpMul
        pop si
        cs lodsw
        xchg ax, cx
        pop di
        call FpCopyConst
        mov [FpResultPtr], di
.1:
        push cx
        push si
        mov si, FpTemp3
        call FpMul
        pop si
        add si, 0xc
        push si
        call FpLoadConst
        call FpAdd
        pop si
        pop cx
        loop .1
        db 0x8B, 0xDE                           ; insn: mov bx, si
        pop si
        push si
        push bx
        call FpMul
        pop si
        add si, 0xc
        cs lodsw
        xchg ax, cx
        pop bx
        push di
        db 0x8B, 0xFB                           ; insn: mov di, bx
        call FpCopyConst
        push cx
        push si
        mov si, FpTemp3
        mov [FpResultPtr], di
        call FpAdd
        pop si
        pop cx
.2:
        push cx
        add si, 0xc
        push si
        mov si, FpTemp3
        call FpMul
        pop si
        push si
        call FpLoadConst
        call FpAdd
        pop si
        pop cx
        loop .2
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop di
        ret
.3:
        mov si, [FpStackTop]
        call FpSeriesA
        push si
        mov si, [FpStackTop]
        cmp si, [FpStackLimit]
        jnz short .4
        call FpSetC1
.4:
        add si, 0xc
        mov [FpStackTop], si
        mov di, [FpStackTop]
        pop si
        call FpCopyReg
        ret

;-----------------------------------------------------------------------------
; FpSeriesA                                                     18B9:24AE  MSC
; FpPolyRatio with the first table; also the fpatan entry.
;-----------------------------------------------------------------------------
FpSeriesA:
        mov bx, FpSeriesANum
        call FpPolyRatio
        ret
.1:
        mov di, [FpStackTop]
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov ax, [si + 0xa]
        sub di, 0xc
        call FpAtanCore
        mov si, [FpStackTop]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .2
        call FpSetC2
.2:
        sub si, 0xc
        mov [FpStackTop], si
        ret

;-----------------------------------------------------------------------------
; FpAtanCore                                                    18B9:24DD  MSC
; Arctangent work for fpatan; also the f2xm1 entry.
;-----------------------------------------------------------------------------
FpAtanCore:
        mov [FpResultPtr], di
        call FpDivRev
        mov al, 0x0
        mov si, FpConstTan15
        call FpCompare
        jnc short .1
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov di, FpTemp0
        call FpCopyReg
        push si
        mov si, FpConstSqrt3
        call FpLoadConst
        mov [FpResultPtr], di
        call FpMul
        mov si, FpConstOne
        call FpLoadConst
        call FpSub
        pop si
        push di
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov si, FpConstSqrt3
        call FpLoadConst
        mov [FpResultPtr], di
        call FpAdd
        pop si
        call FpDiv
        mov al, 0x1
.1:
        push ax
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov bx, FpAtanNum
        call FpPolyRatio
        mov [FpResultPtr], di
        call FpDivRev
        pop ax
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .2
        mov si, FpConstPiOver6
        call FpLoadConst
        call FpAdd
.2:
        ret
.3:
        mov si, [FpStackTop]
        call FpSeriesB
        ret

;-----------------------------------------------------------------------------
; FpSeriesB                                                     18B9:254B  MSC
; FpPolyRatio with the second table; also the fyl2x entry.
;-----------------------------------------------------------------------------
FpSeriesB:
        mov bx, FpSeriesBNum
        call FpPolyRatio
        push di
        xchg si, di
        mov [FpResultPtr], di
        call FpSub
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop di
        mov [FpResultPtr], di
        call FpDivRev
        inc word [di + 0x8]
        db 0x8B, 0xF7                           ; insn: mov si, di
        ret
.1:
        mov di, [FpStackTop]
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov ax, [si + 0xa]
        sub di, 0xc
        call FpLog2Core
        mov si, [FpStackTop]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .2
        call FpSetC2
.2:
        sub si, 0xc
        mov [FpStackTop], si
        ret

;-----------------------------------------------------------------------------
; FpLog2Core                                                    18B9:2593  MSC
; Base-2 logarithm work; also the fyl2xp1 entry.
;-----------------------------------------------------------------------------
FpLog2Core:
        push si
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov di, FpTemp1
        call FpCopyReg
        db 0x8B, 0xFE                           ; insn: mov di, si
        pop si
        push di
        mov di, FpTemp2
        call FpCopyReg
        mov bx, [di + 0x8]
        mov word [di + 0x8], 0x0
        mov si, FpConstSqrt2
        call FpCompare
        ja short .1
        dec word [di + 0x8]
        inc bx
.1:
        push bx
        mov si, FpConstOne
        call FpLoadConst
        mov [FpResultPtr], di
        call FpSub
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop bx
        pop di
        push bx
        call FpLogSeries
        pop bx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jz short .4
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jns short .2
        mov dl, 0x80
        neg bx
.2:
        mov cx, 0x10
.3:
        dec cx
        shl bx, 1
        jnc short .3
        push di
        rcr bx, 1
        mov di, FpTemp2
        stosw
        stosw
        stosw
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        stosw
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        stosw
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        mov di, FpTemp1
        mov si, FpTemp2
        mov [FpResultPtr], di
        call FpMul
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop di
        mov [FpResultPtr], di
        call FpAdd
.4:
        ret
.5:
        mov di, [FpStackTop]
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov ax, [si + 0xa]
        sub di, 0xc
        call FpLogSeries
        mov si, [FpStackTop]
        mov si, [FpStackTop]
        cmp si, [FpStackBase]
        jnz short .6
        call FpSetC2
.6:
        sub si, 0xc
        mov [FpStackTop], si
        ret

;-----------------------------------------------------------------------------
; FpLogSeries                                                   18B9:2639  MSC
; Logarithm series step.
;-----------------------------------------------------------------------------
FpLogSeries:
        push di
        mov di, FpTemp0
        call FpCopyReg
        push si
        mov si, FpConstTwo
        call FpLoadConst
        mov [FpResultPtr], di
        call FpAdd
        pop si
        call FpDiv
        inc word [di + 0x8]
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov bx, FpLogNum
        call FpPolyRatio
        mov [FpResultPtr], di
        call FpDivRev
        db 0x8B, 0xF7                           ; insn: mov si, di
        pop di
        mov [FpResultPtr], di
        call FpMul
        ret
        db 0x00
FpNmiStatus:                                    ; word; the 8087 status word FpNmiHandler reads
        dw 0
FpOldNmi:                                       ; dword; the INT 2 (NMI) vector before FpHookNmi
        dd 0
FpOldCtrlBreak:                                 ; dword; the INT 23h (Ctrl-Break) vector before FpHookNmi
        dd 0

;-----------------------------------------------------------------------------
; FpHookNmi                                                     18B9:267A  MSC
; Hooks INT 2 (coprocessor NMI) and INT 23h.
;-----------------------------------------------------------------------------
FpHookNmi:
        push ds
        push cs
        pop ds
        mov ax, 0x3502
        int 0x21
        mov [FpOldNmi], bx
        mov [FpOldNmi + 2], es
        mov dx, FpNmiHandler
        mov ax, 0x2502
        int 0x21
        mov ax, 0x3523
        int 0x21
        mov [FpOldCtrlBreak], bx
        mov [FpOldCtrlBreak + 2], es
        mov dx, FpCtrlBreak
        mov ax, 0x2523
        int 0x21
        pop ds
        ret

;-----------------------------------------------------------------------------
; FpUnhookNmi                                                   18B9:26A9  MSC
; Restores INT 2.
;-----------------------------------------------------------------------------
FpUnhookNmi:
        push ds
        push ax
        push dx
        mov ax, 0x2502
        lds dx, [cs:FpOldNmi]
        int 0x21
        pop dx
        pop ax
        pop ds
        ret

;-----------------------------------------------------------------------------
; FpCtrlBreak                                                   18B9:26BA  MSC
; INT 23h handler: restores INT 2 and chains to the old handler.
;-----------------------------------------------------------------------------
FpCtrlBreak:
        push ax
        push dx
        push ds
        call FpUnhookNmi
        lds dx, [cs:FpOldCtrlBreak]
        mov ax, 0x2523
        int 0x21
        pop ds
        pop dx
        pop ax
        jmp far [cs:FpOldCtrlBreak]

;-----------------------------------------------------------------------------
; FpNmiHandler                                                  18B9:26D2  MSC
; INT 2 handler: an 8087 exception goes to FpException, anything else chains.
;-----------------------------------------------------------------------------
FpNmiHandler:
        nop
        fnstsw [cs:FpNmiStatus]
        push cx
        mov cx, 0x3
.1:
        loop .1
        pop cx
        test byte [cs:FpNmiStatus], 0x80
        jz short .2
        call FpException
        iret
.2:
        jmp far [cs:FpOldNmi]
