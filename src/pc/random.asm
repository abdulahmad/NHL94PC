; randomd0: the random number generator. The first bytes finish the input routine before it.

;-----------------------------------------------------------------------------
; InputTail                                                   0C11:0000  94 PC
; Sub ah, ah / retf at the start of the paragraph (end of the routine
; before).
;-----------------------------------------------------------------------------
InputTail:
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; randomd0                                         0C11:0006  94G middle94.asm
; Same generator: seed*BB40E62Dh+1, result scaled to the range.
;-----------------------------------------------------------------------------
randomd0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        mov ax, [seed + 2]
        mov dx, 0xe62d
        call 0x03A3:MulRegs
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [seed]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov dx, 0xbb40
        call 0x03A3:MulRegs
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov dx, 0xe62d
        call 0x03A3:MulRegs
        db 0x03, 0xD3                           ; insn: add dx, bx
        add ax, strict word 0x1
        adc dx, 0x0
        mov [seed], ax
        mov [seed + 2], dx
        db 0x8A                                 ; insn: mov al, ah: the last byte is in the next segment
