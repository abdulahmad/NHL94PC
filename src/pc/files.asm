; File helpers: does a file exist, path building, deleting matching files and directory trees, and
; shared-mode opens.
        mov al, [bp + 0x6]
        push ax
        call 0x1630:QueueMidiBytes
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FileExists                                                  0CD1:000C  94 PC
; Open for reading succeeds.
;-----------------------------------------------------------------------------
FileExists:
        enter 0x2, 0x0
        push si
        mov word [bp - 0x2], 0xffff
        db 0x2B, 0xF6                           ; insn: sub si, si
        lea ax, [bp - 0x2]
        push ax
        push word [bp + 0x6]
        push cs
        call OpenReadShared
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        mov si, 0x1
.1:
        lea ax, [bp - 0x2]
        push ax
        push cs
        call CloseHandlePtr
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; BuildPathFar                                                0CD1:003E  94 PC
; Directory, backslash, name and extension into a far buffer.
;-----------------------------------------------------------------------------
BuildPathFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0xa]
        mov ax, [bp + 0xc]
        db 0x0B, 0xC7                           ; insn: or ax, di
        jz short .1
        mov es, [bp + 0xc]
        cmp byte [es:di], 0x0
        jz short .1
        mov si, [bp + 0x6]
        mov ax, es
        push ax
        push di
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Backslash
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        jmp short .2
        db 0x90
.1:
        mov si, [bp + 0x6]
        mov es, [bp + 0x8]
        mov byte [es:si], 0x0
.2:
        mov ax, [bp + 0x10]
        or ax, [bp + 0xe]
        jz short .3
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
.3:
        mov ax, [bp + 0x14]
        or ax, [bp + 0x12]
        jz short .4
        push word [bp + 0x14]
        push word [bp + 0x12]
        mov ax, [bp + 0x8]
        push ax
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
.4:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DeleteMatching                                              0CD1:00C2  94 PC
; Finds every file of a pattern in a directory and unlinks it.
;-----------------------------------------------------------------------------
DeleteMatching:
        enter 0x52, 0x0
        push di
        push si
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x6]
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
        mov ax, str_Backslash
        mov cx, 0x3701                          ; segment of the team choice text far data
        mov [bp - 0x52], ax
        mov [bp - 0x50], cx
        push cx
        push ax
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x8]
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
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Dot
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0xa]
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
        lea ax, [bp - 0x4e]
        push ax
        push 0x0
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .4
.1:
        push ds
        push word [bp + 0x6]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea di, [bp - 0x30]
        lea si, [bp - 0x22]
        push ss
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
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
.2:
        lea ax, [bp - 0x4e]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x6]
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
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea di, [bp - 0x30]
        lea si, [bp - 0x22]
        push ss
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
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
.3:
        cmp word [bp - 0x2], 0x0
        jz short .2
.4:
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RemoveDirTree                                               0CD1:0258  94 PC
; Unlinks every file in a directory, then rmdir.
;-----------------------------------------------------------------------------
RemoveDirTree:
        enter 0x52, 0x0
        push di
        push si
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x6]
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
        mov ax, str_Backslash
        mov cx, 0x3701                          ; segment of the team choice text far data
        mov [bp - 0x52], ax
        mov [bp - 0x50], cx
        push cx
        push ax
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Star
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Dot
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Star
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea ax, [bp - 0x4e]
        push ax
        push 0x0
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_dos_findfirst
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .4
.1:
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x6]
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
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea di, [bp - 0x30]
        lea si, [bp - 0x22]
        push ss
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
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
.2:
        lea ax, [bp - 0x4e]
        push ax
        call 0x0000:_dos_findnext
        add sp, 0x2
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .3
        lea si, [bp - 0x22]
        push ds
        pop es
        mov di, [bp + 0x6]
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
        push word [bp - 0x50]
        push word [bp - 0x52]
        lea ax, [bp - 0x22]
        push ss
        push ax
        call 0x0000:_fstrcat
        add sp, 0x8
        lea di, [bp - 0x30]
        lea si, [bp - 0x22]
        push ss
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
        lea ax, [bp - 0x22]
        push ax
        call 0x0000:_unlink
        add sp, 0x2
.3:
        cmp word [bp - 0x2], 0x0
        jz short .2
.4:
        push word [bp + 0x6]
        call 0x0000:_rmdir
        add sp, 0x2
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; OpenReadShared                                              0CD1:03D6  94 PC
; _dos_open mode 40h (read, deny none).
;-----------------------------------------------------------------------------
OpenReadShared:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x8]
        push 0x40
        push word [bp + 0x6]
        call 0x0000:_dos_open
        leave
        retf

;-----------------------------------------------------------------------------
; OpenWriteShared                                             0CD1:03E8  94 PC
; _dos_open mode 41h.
;-----------------------------------------------------------------------------
OpenWriteShared:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x8]
        push 0x41
        push word [bp + 0x6]
        call 0x0000:_dos_open
        leave
        retf

;-----------------------------------------------------------------------------
; OpenReadWriteShared                                         0CD1:03FA  94 PC
; _dos_open mode 42h.
;-----------------------------------------------------------------------------
OpenReadWriteShared:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x8]
        push 0x42
        push word [bp + 0x6]
        call 0x0000:_dos_open
        leave
        retf

;-----------------------------------------------------------------------------
; CreateFileNormal                                            0CD1:040C  94 PC
; _dos_creat attribute 0.
;-----------------------------------------------------------------------------
CreateFileNormal:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x8]
        push 0x0
        push word [bp + 0x6]
        call 0x0000:_dos_creat
        leave
        retf

;-----------------------------------------------------------------------------
; CloseHandlePtr                                              0CD1:041E  94 PC
; Closes the handle a pointer holds and stores -1.
;-----------------------------------------------------------------------------
CloseHandlePtr:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x6]
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp [di], si
        jl short .1
        push word [di]
        call 0x0000:_dos_close
        add sp, 0x2
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        mov word [di], 0xffff
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; ReadAtOffset                                                0CD1:0442  94 PC
; Seek to a long offset then read; returns 0 or an error.
;-----------------------------------------------------------------------------
ReadAtOffset:
        enter 0x2, 0x0
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp [bp + 0xe], si
        jl short .1
        push si
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0x6]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .1
        mov si, 0xffff
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        lea ax, [bp - 0x2]
        push ax
        push word [bp + 0x10]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0000:_dos_read
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        mov ax, [bp + 0x10]
        cmp [bp - 0x2], ax
        jz short .3
        mov si, 0x1
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; WriteAtOffset                                               0CD1:0496  94 PC
; Seek to a long offset then write; returns 0 or an error.
;-----------------------------------------------------------------------------
WriteAtOffset:
        enter 0x2, 0x0
        push si
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp [bp + 0xe], si
        jl short .1
        push si
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0x6]
        call 0x0000:_lseek
        add sp, 0x8
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnl short .1
        mov si, 0xffff
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        lea ax, [bp - 0x2]
        push ax
        push word [bp + 0x10]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0000:_dos_write
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        mov ax, [bp + 0x10]
        cmp [bp - 0x2], ax
        jz short .3
        mov si, 0x1
.3:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadRecord52                                                0CD1:04EA  94 PC
; ReadAtOffset of 34h bytes.
;-----------------------------------------------------------------------------
ReadRecord52:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x34
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call ReadAtOffset
        leave
        retf

;-----------------------------------------------------------------------------
; WriteRecord52                                               0CD1:0504  94 PC
; WriteAtOffset of 34h bytes.
;-----------------------------------------------------------------------------
WriteRecord52:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x34
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call WriteAtOffset
        leave
        retf

;-----------------------------------------------------------------------------
; CopyFileByName                                              0CD1:051E  94 PC
; Opens the source, creates the target, copies in 1 KB pieces.
;-----------------------------------------------------------------------------
CopyFileByName:
        enter 0x448, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, 0xffff
        mov [bp - 0x6], ax
        mov [bp - 0x4], ax
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push di
        push word [bp + 0x14]
        push word [bp + 0x12]
        lea ax, [bp - 0x28]
        push ss
        push ax
        push cs
        call BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x28]
        push ax
        push cs
        call OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push word [bp + 0x10]
        push word [bp + 0xe]
        mov ax, [bp + 0x8]
        push ax
        push di
        push word [bp + 0x18]
        push word [bp + 0x16]
        lea ax, [bp - 0x48]
        push ss
        push ax
        push cs
        call BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x48]
        push ax
        push cs
        call CreateFileNormal
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
.2:
        lea ax, [bp - 0x2]
        push ax
        push word 0x400
        lea ax, [bp - 0x448]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0000:_dos_read
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        cmp [bp - 0x2], si
        jng short .3
        lea ax, [bp - 0x8]
        push ax
        push word [bp - 0x2]
        lea cx, [bp - 0x448]
        push ss
        push cx
        push word [bp - 0x4]
        call 0x0000:_dos_write
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [bp - 0x2]
        cmp [bp - 0x8], ax
        jz short .3
        mov si, 0x1
.3:
        cmp word [bp - 0x2], 0x0
        jng short .4
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .2
.4:
        lea ax, [bp - 0x4]
        push ax
        push cs
        call CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x6]
        push ax
        push cs
        call CloseHandlePtr
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadRecord48                                                0CD1:0602  94 PC
; ReadAtOffset of 30h bytes.
;-----------------------------------------------------------------------------
ReadRecord48:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x30
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call ReadAtOffset
        leave
        retf

;-----------------------------------------------------------------------------
; ReadEntry6                                                  0CD1:061C  94 PC
; 6-byte entry n at 2 + 6n.
;-----------------------------------------------------------------------------
ReadEntry6:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x6
        mov ax, [bp + 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, 1
        inc ax
        inc ax
        cwd
        push dx
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call ReadAtOffset
        leave
        retf

;-----------------------------------------------------------------------------
; ReadEntry744                                                0CD1:0640  94 PC
; 2E8h-byte entry n.
;-----------------------------------------------------------------------------
ReadEntry744:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word 0x2e8
        imul ax, [bp + 0xc], word 0x2e8
        push 0x0
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call ReadAtOffset
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ReadEntry12                                                 0CD1:065E  94 PC
; 12-byte entry n.
;-----------------------------------------------------------------------------
ReadEntry12:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0xc
        mov ax, [bp + 0xc]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        cwd
        push dx
        push ax
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call ReadAtOffset
        leave
