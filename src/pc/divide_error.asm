; The divide-error (INT 0) hook: installs and removes the handler that keeps a bad divide from
; ending the game. The first bytes finish VectorToDir8.
        db 0x08
;-----------------------------------------------------------------------------
; VectorToDir8Tail                                            0D6B:0001  94 PC
; End of VectorToDir8, which starts in the file before.
;-----------------------------------------------------------------------------
VectorToDir8Tail:
        mov al, [bx + Dir8Table]
        cbw
        leave
        retf
        db 0x00, 0x00

;-----------------------------------------------------------------------------
; HookDivideError                                             0D6B:000A  94 PC
; Saves INT 0, points it at DivideHandler, registers UnhookDivideError.
;-----------------------------------------------------------------------------
HookDivideError:
        cmp word [OldInt0Seg], 0x0
        jnz short .1
        cmp word [OldInt0Off], 0x0
        jnz short .1
        mov ah, 0x35
        mov al, 0x0
        int 0x21
        mov [OldInt0Seg], es
        mov [OldInt0Off], bx
.1:
        mov dx, cs
        mov ds, dx
        mov dx, 0x5c
        mov ah, 0x25
        mov al, 0x0
        int 0x21
        mov ax, ss
        mov ds, ax
        mov ax, ds
        mov [cs:0x8], ax
        push cs
        mov ax, 0x4b
        push ax
        call 0x03A3:OnexitThunk
        add sp, 0x4
        retf

;-----------------------------------------------------------------------------
; UnhookDivideError                                           0D6B:004B  94 PC
; Restores INT 0.
;-----------------------------------------------------------------------------
UnhookDivideError:
        push ds
        mov dx, [OldInt0Off]
        mov ds, [OldInt0Seg]
        mov ah, 0x25
        mov al, 0x0
        int 0x21
        pop ds
        retf

;-----------------------------------------------------------------------------
; DivideHandler                                               0D6B:005C  94 PC
; INT 0 handler: steps the return address over the faulting divide.
;-----------------------------------------------------------------------------
DivideHandler:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push es
        push di
        push dx
        push cx
        mov ds, [cs:0x8]
        mov ax, [bp + 0x4]
        mov es, ax
        mov ax, [bp + 0x2]
        inc ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        inc ax
        mov dx, [es:di]
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        and dx, 0xc0
        jnz short .1
        and cx, 0x7
        sub cx, 0x6
        jnz short .2
        inc ax
.1:
        inc ax
.2:
        mov [bp + 0x2], ax
        db 0xC6, 0x06, 0xC4
