; RTLink/Plus runtime: overlay load hooks, its error messages and hex output, and the interrupt
; vectors it saves and restores.
        db 0x23, 0x05, 0x00

;-----------------------------------------------------------------------------
; RtlSectionHook                                             1DE4:0003  RTLink
; Default section hook: sets carry and returns.
;-----------------------------------------------------------------------------
RtlSectionHook:
        stc
        retf

;-----------------------------------------------------------------------------
; RtlWriteHex                                                1DE4:0005  RTLink
; Writes CX as four hex digits at DS:DX (error codes in the eov messages).
;-----------------------------------------------------------------------------
RtlWriteHex:
        push ax
        push di
        push es
        mov ax, ds
        mov es, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call RtlHexWord
        pop es
        pop di
        pop ax
        retf

;-----------------------------------------------------------------------------
; RtlHexWord                                                 1DE4:0017  RTLink
; Writes AX as four hex digits at ES:DI.
;-----------------------------------------------------------------------------
RtlHexWord:
        push ax
        db 0x8A, 0xC4                           ; insn: mov al, ah
        call RtlHexByte
        pop ax

RtlHexByte:
        push ax
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        call RtlHexDigit
        pop ax

RtlHexDigit:
        and al, 0xf
        add al, 0x90
        daa
        adc al, 0x40
        daa
        stosb
        ret

RtlFileAdjust:                                  ; a far pointer target in  used by the overlay file code; used
                                                ; by ExeFileName
        db 0x00, 0x00, 0x00, 0x00

;-----------------------------------------------------------------------------
; RtlSwapErrorSlot                                           1DE4:0039  RTLink
; Exchanges SI and DS with the saved error handler pointer.
;-----------------------------------------------------------------------------
RtlSwapErrorSlot:
        push ax
        xchg si, [cs:0x4a]
        mov ax, ds
        xchg ax, [cs:0x4c]
        mov ds, ax
        pop ax
        retf

RtlErrorSlot:                                   ; far pointer to the fatal error routine, swapped by
                                                ; RtlSwapErrorSlot; used by SetupErrorText
        db 0x54, 0x00, 0xE4, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

;-----------------------------------------------------------------------------
; RtlFatalError                                              1DE4:0054  RTLink
; Prints "Fatal Error" and the message to stderr, waits for a key in text
; mode, exits with 1.
;-----------------------------------------------------------------------------
RtlFatalError:
        push bx
        mov bx, 0x2
        mov cx, 0x1
        mov ah, 0x46
        int 0x21
        pop bx
        push ds
        mov ax, cs
        mov ds, ax
        mov dx, [0x231]
        mov ah, 0x9
        int 0x21
        pop ds
.1:
        mov si, [bx]
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
.2:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .3
        db 0x8A, 0xD0                           ; insn: mov dl, al
        mov ah, 0x2
        int 0x21
        jmp short .2
.3:
        add bx, 0x2
        jmp short .1
.4:
        mov ax, cs
        mov ds, ax
        mov ah, 0xf
        int 0x10
        cmp al, 0x3
        jna short .5
        cmp al, 0x7
        jz short .5
        mov dx, [0x233]
        mov ah, 0x9
        int 0x21
        mov ah, 0x7
        int 0x21
.5:
        mov ax, 0x4c01
        int 0x21
        push ax
        push es
        mov al, 0x1
        call RtlCallHandlers
        mov es, [cs:0x52]
        cli
        mov ax, [cs:0x4e]
        mov [es:0xa], ax
        mov ax, [cs:0x50]
        mov [es:0xc], ax
        mov word [cs:0x107], 0x0
        sti
        pop es
        pop ax
        retf

;-----------------------------------------------------------------------------
; RtlSaveVectors                                             1DE4:00CF  RTLink
; Saves the PSP terminate vector once.
;-----------------------------------------------------------------------------
RtlSaveVectors:
        push ax
        mov [cs:0x52], es
        mov ax, [cs:0x4e]
        or ax, [cs:0x50]
        jnz short .1
        cli
        mov ax, [es:0xa]
        mov [cs:0x4e], ax
        mov ax, [es:0xc]
        mov [cs:0x50], ax
        sti
.1:
        pop ax
        retf

;-----------------------------------------------------------------------------
; RtlSetHandler                                              1DE4:00F4  RTLink
; Registers a far callback with a flag mask (up to 12) and hooks the
; terminate vector.
;-----------------------------------------------------------------------------
RtlSetHandler:
        push bx
        push ax
        mov bx, 0x14c
.1:
        mov ax, [cs:bx]
        or ax, [cs:bx + 0x2]
        jz short .2
        add bx, 0x6
        jmp short .1
        db 0x00, 0x00
.2:
        test word [cs:0x107], 0xff
        jnz short .3
        pop ax
        push ax
        test al, 0x2
        jz short .3
        mov word [cs:0x107], 0xff
        push es
        mov es, [cs:0x52]
        cli
        mov word [es:0xa], 0x1d7
        mov [es:0xc], cs
        sti
        pop es
.3:
        cmp bx, 0x194
        jz short .4
        mov [cs:bx], dx
        mov [cs:bx + 0x2], ds
        pop ax
        mov [cs:bx + 0x4], al
        pop bx
        retf
.4:
        push cs
        call RtlInternalError
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al
        add [bx + si], al

RtlInternalError:
        mov ax, cs
        mov ds, ax
        mov bx, [0x235]
        mov [cs:0x1c3], bx
        mov bx, [0x237]
        mov [cs:0x1c5], bx
        mov word [cs:0x1c7], 0x0
        mov bx, 0x1c3
        mov ah, 0x6
        mov al, 0x1
        db 0x33, 0xC9                           ; insn: xor cx, cx
        jmp far [cs:0x4a]
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

;-----------------------------------------------------------------------------
; RtlAfterFiles                                              1DE4:01C9  RTLink
; Runs the callbacks with flag 4.
;-----------------------------------------------------------------------------
RtlAfterFiles:
        push ax
        push es
        mov al, 0x4
        call RtlCallHandlers
        pop es
        pop ax
        retf

;-----------------------------------------------------------------------------
; RtlCallHandlersFar                                         1DE4:01D3  RTLink
; Far entry to RtlCallHandlers.
;-----------------------------------------------------------------------------
RtlCallHandlersFar:
        call RtlCallHandlers
        retf

;-----------------------------------------------------------------------------
; RtlTerminate                                               1DE4:01D7  RTLink
; Terminate hook: runs flag 2 callbacks, restores the vector and chains.
;-----------------------------------------------------------------------------
RtlTerminate:
        push ax
        push es
        mov al, 0x2
        call RtlCallHandlers
        mov es, [cs:0x52]
        cli
        mov ax, [cs:0x4e]
        mov [es:0xa], ax
        mov ax, [cs:0x50]
        mov [es:0xc], ax
        mov word [cs:0x107], 0x0
        sti
        pop es
        pop ax
        jmp far [cs:0x4e]

;-----------------------------------------------------------------------------
; RtlCallHandlers                                            1DE4:0203  RTLink
; Calls every registered callback whose mask matches AL.
;-----------------------------------------------------------------------------
RtlCallHandlers:
        push bx
        push dx
        mov bx, 0x14c
.1:
        mov dx, [cs:bx]
        or dx, [cs:bx + 0x2]
        jz short .3
        test [cs:bx + 0x4], al
        jz short .2
        pushf
        call far [cs:bx]
        popf
.2:
        add bx, 0x6
        jmp short .1
.3:
        pop dx
        pop bx
        ret

;-----------------------------------------------------------------------------
; RtlBeforeClose                                             1DE4:0224  RTLink
; Stub returning -1.
;-----------------------------------------------------------------------------
RtlBeforeClose:
        mov ax, 0xffff
        retf

;-----------------------------------------------------------------------------
; RtlStubCx                                                  1DE4:0228  RTLink
; Returns CX = -1.
;-----------------------------------------------------------------------------
RtlStubCx:
        mov cx, 0xffff
        retf

;-----------------------------------------------------------------------------
; RtlStubZero                                                1DE4:022C  RTLink
; Returns 0 in DX:AX.
;-----------------------------------------------------------------------------
RtlStubZero:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        retf
        db 0x39, 0x02, 0x46, 0x02, 0x64, 0x02, 0x6E, 0x02, 'Fatal Error $'
        db 0x0D, 0x0A, 'Press any key to terminate.$ege0001: '
        db 0x00, 'Internal error in .RTLink(R)/Plus run-time code.'
        db 0x0D, 0x0A, 0x00

;-----------------------------------------------------------------------------
; RtlGetEnv                                                  1DE4:02A1  RTLink
; Finds a variable in the environment block.
;-----------------------------------------------------------------------------
RtlGetEnv:
        push ax
        push cx
        push di
        push si
        push ds
        push es
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov es, ax
        mov cx, [es:PspEnvSeg]
        jcxz .7
        mov es, cx
        db 0x33, 0xFF                           ; insn: xor di, di
.1:
        mov al, [es:di]
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .7
        mov si, [bp + 0x6]
.2:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jnz short .3
        cmp byte [es:di], 0x3d
        jz short .5
        jmp short .4
.3:
        mov ah, [es:di]
        inc di
        db 0x3A, 0xC4                           ; insn: cmp al, ah
        jz short .2
.4:
        db 0x32, 0xC0                           ; insn: xor al, al
        mov cx, 0xffff
        repne scasb
        jmp short .1
.5:
        mov ax, es
        mov ds, ax
        db 0x8B, 0xF7                           ; insn: mov si, di
        inc si
        mov es, [bp + 0x2]
        mov di, [bp + 0x8]
.6:
        lodsb
        stosb
        db 0x0A, 0xC0                           ; insn: or al, al
        jnz short .6
        jmp short .8
.7:
        stc
.8:
        pop bp
        pop es
        pop ds
        pop si
        pop di
        pop cx
        pop ax
        retf

;-----------------------------------------------------------------------------
; RtlFindFile                                                1DE4:02FD  RTLink
; Tries a file by a search spec of letters C, E, P and A (current dir, EXE
; dir, PATH, as given).
;-----------------------------------------------------------------------------
RtlFindFile:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push bp
        push ds
        push es
        db 0x8B, 0xEC                           ; insn: mov bp, sp
.1:
        lodsb
        push si
        mov bx, 0x332
        push bx
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short RtlFindFileStep.3
        cmp al, 0x43
        jnz short .2
        jmp short RtlFindFileStep.5
.2:
        cmp al, 0x45
        jnz short .3
        jmp short RtlFindFileStep.6
.3:
        cmp al, 0x50
        jnz short .4
        jmp near RtlFindFileStep.15
.4:
        cmp al, 0x41
        jnz short .5
        jmp near RtlFindFileStep.19
.5:
        add sp, 0x2
        pop si
        jmp short .1

;-----------------------------------------------------------------------------
; RtlFindFileStep                                            1DE4:0332  RTLink
; One RtlFindFile try.
;-----------------------------------------------------------------------------
RtlFindFileStep:
        pop si
        jc short .1
        mov [bp + 0x10], ax
        test byte [cs:0x4fc], 0xff
        jmp short .4
.1:
        mov ds, [bp + 0x2]
.2:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .3
        cmp al, 0x2c
        jz short RtlFindFile.1
        jmp short .2
.3:
        stc
.4:
        pop es
        pop ds
        pop bp
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        retf
.5:
        mov es, [bp + 0xc]
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x32, 0xC0                           ; insn: xor al, al
        call RtlCurrentDir
        call RtlOpenCandidate
        ret
.6:
        push si
.7:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .8
        cmp al, 0x2c
        jnz short .7
.8:
        db 0x8B, 0xFE                           ; insn: mov di, si
        dec di
        mov byte [di], 0x0
        pop si
        push ax
        push di
        mov es, [bp + 0xc]
        mov di, 0x50
        mov ax, [bp + 0x10]
        push cs
        call RtlGetEnv
        pop bx
        pop ax
        mov [bx], al
        jnc short .9
        ret
.9:
        mov ax, es
        mov ds, ax
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov es, [bp + 0xc]
.10:
        db 0x33, 0xFF                           ; insn: xor di, di
.11:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .12
        cmp al, 0x3b
        jz short .12
        stosb
        db 0x8A, 0xE0                           ; insn: mov ah, al
        jmp short .11
.12:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .14
        db 0x8A, 0xD8                           ; insn: mov bl, al
        cmp ah, 0x5c
        jz short .13
        cmp ah, 0x3a
        jz short .13
        mov al, 0x5c
        stosb
.13:
        call RtlOpenCandidate
        jc short .14
        clc
        ret
.14:
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jnz short .10
        stc
        ret
.15:
        mov ax, 0x3000
        int 0x21
        cmp al, 0x3
        jnc short .17
        stc
.16:
        ret
        db 'PATH', 0x00
.17:
        mov ax, [bp + 0x10]
        push cs
        call RtlExePath
        jc short .16
        cmp bx, -0x1
        jnz short .18
        stc
        jmp short .16
.18:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        mov es, [bp + 0xc]
        db 0x33, 0xFF                           ; insn: xor di, di
        rep movsb
        call RtlOpenCandidate
        ret
.19:
        call RtlShowMessage
        jnc short .20
        ret
.20:
        call RtlOpenCandidate
        jc short .19
        ret

;-----------------------------------------------------------------------------
; RtlCurrentDir                                              1DE4:0405  RTLink
; Builds "D:\path\" for the current drive and directory.
;-----------------------------------------------------------------------------
RtlCurrentDir:
        push ax
        push cx
        push dx
        push si
        push ds
        db 0x0A, 0xC0                           ; insn: or al, al
        jnz short .1
        mov ah, 0x19
        int 0x21
        inc al
.1:
        db 0x8A, 0xD0                           ; insn: mov dl, al
        add al, 0x40
        stosb
        mov ax, 0x5c3a
        stosw
        db 0x8B, 0xF7                           ; insn: mov si, di
        mov ax, es
        mov ds, ax
        mov ah, 0x47
        int 0x21
        db 0x32, 0xC0                           ; insn: xor al, al
        mov cx, 0x40
        repne scasb
        dec di
        cmp byte [es:di - 0x1], 0x5c
        jz short .2
        mov al, 0x5c
        stosb
.2:
        mov byte [es:di], 0x0
        pop ds
        pop si
        pop dx
        pop cx
        pop ax
        ret

;-----------------------------------------------------------------------------
; RtlExePath                                                 1DE4:0443  RTLink
; The full path of the running EXE from the environment (DOS 3 or later).
;-----------------------------------------------------------------------------
RtlExePath:
        push ax
        push bx
        push cx
        push dx
        push di
        push es
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, 0x3000
        int 0x21
        cmp al, 0x3
        jnc short .3
.1:
        stc
.2:
        pop bp
        pop es
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        retf
.3:
        mov es, di
        mov cx, [es:PspEnvSeg]
        jcxz .1
        mov es, cx
        mov cx, 0x8000
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x32, 0xC0                           ; insn: xor al, al
.4:
        cmp byte [es:di], 0x0
        jz short .5
        repne scasb
        jmp short .4
.5:
        inc di
        cmp word [es:di], 0x1
        jnz short .1
        add di, 0x2
        db 0x8B, 0xD7                           ; insn: mov dx, di
        mov bx, 0xffff
.6:
        mov al, [es:di]
        inc di
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .8
        cmp al, 0x5c
        jz short .7
        cmp al, 0x3a
        jnz short .6
.7:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        jmp short .6
.8:
        mov ax, es
        mov ds, ax
        mov [bp + 0x6], dx
        mov [bp + 0xa], bx
        clc
        jmp short .2

;-----------------------------------------------------------------------------
; RtlOpenCandidate                                           1DE4:04AC  RTLink
; Builds the candidate path and opens it.
;-----------------------------------------------------------------------------
RtlOpenCandidate:
        call RtlAppendName
        push dx
        push ds
        mov ds, [bp + 0xc]
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov al, [bp + 0xe]
        mov ah, 0x3d
        int 0x21
        pop ds
        pop dx
        ret

;-----------------------------------------------------------------------------
; RtlAppendName                                              1DE4:04C0  RTLink
; Appends the file name and notes a .exe extension.
;-----------------------------------------------------------------------------
RtlAppendName:
        push ax
        push si
        push ds
        push es
        mov es, [bp + 0xc]
        mov ds, [bp + 0x0]
        mov si, [bp + 0x8]
.1:
        lodsb
        stosb
        db 0x0A, 0xC0                           ; insn: or al, al
        jnz short .1
        mov byte [cs:0x4fc], 0x0
        mov ax, [es:di - 0x5]
        or ah, 0x20
        cmp ax, 0x652e
        jnz short .2
        mov ax, [es:di - 0x3]
        or ax, 0x2020
        cmp ax, 0x6578
        jnz short .2
        mov byte [cs:0x4fc], 0x1
.2:
        pop es
        pop ds
        pop si
        pop ax
        ret
        db 0x00

;-----------------------------------------------------------------------------
; RtlShowMessage                                             1DE4:04FD  RTLink
; Duplicates stdout/stderr handles and prints a $-terminated message.
;-----------------------------------------------------------------------------
RtlShowMessage:
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov ah, 0x45
        int 0x21
        push ax
        mov bx, 0x1
        mov ah, 0x45
        int 0x21
        push ax
        mov bx, 0x2
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ah, 0x46
        int 0x21
        mov bx, 0x2
        mov cx, 0x1
        mov ah, 0x46
        int 0x21
        mov bx, cs
        mov ds, bx
        mov dx, [0x5d5]
        mov ah, 0x9
        int 0x21
        db 0x33, 0xFF                           ; insn: xor di, di
        call RtlAppendName
        mov al, 0x24
        mov es, [bp + 0xc]
        stosb
        mov ds, [bp + 0xc]
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ah, 0x9
        int 0x21
        mov ds, bx
        mov dx, [0x5d7]
        mov ah, 0x9
        int 0x21
        mov ds, [bp + 0xc]
        mov dx, 0x50
        mov byte [0x50], 0xfe
        mov ah, 0xa
        int 0x21
        mov cl, [0x51]
        mov ds, bx
        mov dx, [0x5d9]
        mov ah, 0x9
        int 0x21
        db 0x32, 0xED                           ; insn: xor ch, ch
        stc
        jcxz .6
        mov ds, [bp + 0xc]
        mov si, 0x52
        mov es, [bp + 0xc]
        db 0x33, 0xFF                           ; insn: xor di, di
        cmp byte [si + 0x1], 0x3a
        jnz short .1
        cmp byte [si + 0x2], 0x5c
        jz short .4
        mov al, [si]
        add si, 0x2
        sub cx, 0x2
        and al, 0xdf
        sub al, 0x40
        jmp short .3
.1:
        cmp byte [si], 0x5c
        jnz short .2
        mov ah, 0x19
        int 0x21
        add al, 0x41
        mov ah, 0x3a
        stosw
        jmp short .4
.2:
        db 0x32, 0xC0                           ; insn: xor al, al
.3:
        call RtlCurrentDir
.4:
        rep movsb
        mov al, [es:di - 0x1]
        cmp al, 0x5c
        jz short .5
        cmp al, 0x3a
        jz short .5
        mov al, 0x5c
        stosb
.5:
        clc
.6:
        lahf
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        pop bx
        mov cx, 0x1
        mov ah, 0x46
        int 0x21
        mov ah, 0x3e
        int 0x21
        pop bx
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ah, 0x46
        int 0x21
        mov ah, 0x3e
        int 0x21
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        sahf
        ret
        db 0xDB, 0x05, 0xF0, 0x05, 0x04, 0x06, 'Enter directory for $ (Enter to quit) : $'
        db 0x0D, 0x0A, 0x24
