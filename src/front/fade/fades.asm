; Shared fade helpers: palette set and rectangle copy (FADES.OVL)

;-----------------------------------------------------------------------------
; SetPaletteVsync                                            3349:0000  94 PC
; Waits for retrace and sets the palette in halves.
;
; Takes 2 words of stack arguments. Calls WaitRetrace, SetPaletteFar. Far routine (retf).
;-----------------------------------------------------------------------------
SetPaletteVsync:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        db 0x2B, 0xFF                           ; insn: sub di, di
        db 0x8B, 0xF7                           ; insn: mov si, di
.1:
        call 0x0FEF:WaitRetrace
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        db 0x03, 0xC7                           ; insn: add ax, di
        push dx
        push ax
        push word 0x80
        push si
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        add di, 0x180
        add si, 0x80
        cmp si, 0x100
        jl short .1
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; RandLfsrByte                                               3349:0036  94 PC
; 8-bit LFSR step (taps 0xB8)
;
; Takes 1 word of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
RandLfsrByte:
        enter 0x2, 0x0
        push si
        mov si, [bp + 0x6]
        cmp byte [si], 0x0
        jnz short .1
        mov byte [si], 0x2b
.1:
        mov al, [si]
        and al, 0x1
        mov [bp - 0x1], al
        shr byte [si], 1
        cmp byte [bp - 0x1], 0x0
        jz short .2
        xor byte [si], 0xb8
.2:
        mov al, [si]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; CopyFadeRect                                               3349:005E  94 PC
; Copies a rectangle of the new page clipped to the fade area.
;
; Takes 4 words of stack arguments. Calls UseCurrentPage, CopyPageRect. Far routine (retf).
;-----------------------------------------------------------------------------
CopyFadeRect:
        enter 0x2, 0x0
        push di
        push si
        mov dx, [bp + 0x6]
        mov di, [bp + 0x8]
        mov cx, [bp + 0xa]
        db 0x03, 0xCA                           ; insn: add cx, dx
        mov si, [bp + 0xc]
        db 0x03, 0xF7                           ; insn: add si, di
        cmp [fadey], dx
        jng short .5
        cmp [fadeh], di
        jng short .5
        cmp [fadex], cx
        jg short .5
        cmp [fadew], si
        jg short .5
        cmp [fadex], dx
        jng short .1
        mov ax, [fadex]
        mov [bp + 0x6], ax
.1:
        cmp [fadew], di
        jng short .2
        mov di, [fadew]
.2:
        mov [bp - 0x2], cx
        cmp [fadey], cx
        jnl short .3
        mov ax, [fadey]
        mov [bp - 0x2], ax
.3:
        cmp [fadeh], si
        jnl short .4
        mov si, [fadeh]
.4:
        call 0x0FEF:UseCurrentPage
        push 0x0
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x2B, 0xC7                           ; insn: sub ax, di
        push ax
        mov ax, [bp - 0x2]
        sub ax, [bp + 0x6]
        push ax
        push di
        push word [bp + 0x6]
        cmp word [CurPage], 0x1
        db 0x1B, 0xC0                           ; insn: sbb ax, ax
        neg ax
        push ax
        call 0x0FEF:CopyPageRect
        add sp, 0xc
.5:
        pop si
        pop di
        leave
        retf
