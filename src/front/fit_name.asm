; FitNameToWidth: shortens a name until it fits a pixel width.
        db 0xE5
        call 0x0000:_exit
        leave
        retf

;-----------------------------------------------------------------------------
; FitNameToWidth                                              0F89:0008  94 PC
; "first last", else "F. last", then cut until it fits the width.
;-----------------------------------------------------------------------------
FitNameToWidth:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0xa]
        mov ax, [bp + 0xc]
        db 0x0B, 0xC7                           ; insn: or ax, di
        jz short .1
        mov si, [bp + 0x6]
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701                        ; segment of the team choice text far data
        push word 0xba6
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcat
        add sp, 0x8
        push word [bp + 0x8]
        push si
        call 0x0D39:TextWidthFar
        add sp, 0x4
        cmp ax, [bp + 0x12]
        jng short .3
        mov es, [bp + 0xc]
        mov al, [es:di]
        mov es, [bp + 0x8]
        mov [es:si], al
        mov byte [es:si + 0x1], 0x2e
        mov byte [es:si + 0x2], 0x20
        mov byte [es:si + 0x3], 0x0
        push word [bp + 0x10]
        push word [bp + 0xe]
        push es
        push si
        call 0x0000:_fstrcat
        jmp short .2
        db 0x90
.1:
        mov si, [bp + 0x6]
        push word [bp + 0x10]
        push word [bp + 0xe]
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrcpy
.2:
        add sp, 0x8
.3:
        push word [bp + 0x8]
        push si
        call 0x0D39:TextWidthFar
        add sp, 0x4
        cmp ax, [bp + 0x12]
        jng short .5
        mov di, [bp + 0x12]
.4:
        push word [bp + 0x8]
        push si
        call 0x0000:_fstrlen
        add sp, 0x4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [bp + 0x8]
        db 0x03, 0xDE                           ; insn: add bx, si
        mov es, ax
        mov byte [es:bx - 0x1], 0x0
        push ax
        push si
        call 0x0D39:TextWidthFar
        add sp, 0x4
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jg short .4
.5:
        pop si
        pop di
        leave
        retf
        db 0x90
