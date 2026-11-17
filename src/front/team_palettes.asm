; LoadTeamPalettes: loads the two teams' colour sets into the palette.
; The first bytes finish DivideHandler from the file before.

;-----------------------------------------------------------------------------
; DivideHandlerTail                                           0D74:0000  94 PC
; The end of DivideHandler (iret) in the next paragraph.
;-----------------------------------------------------------------------------
DivideHandlerTail:
        or [bx + di], ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop cx
        pop dx
        pop di
        pop es
        pop ds
        pop bp
        iret
        db 0x00

;-----------------------------------------------------------------------------
; LoadTeamPalettes                                            0D74:000C  94 PC
; Home and away palette parts (1C0h bytes a team) and the arena palette, then
; SetPaletteFar.
;-----------------------------------------------------------------------------
LoadTeamPalettes:
        enter 0x28, 0x0
        push di
        push si
        mov ax, TeamPalette768
        mov cx, 0x3a0b                          ; segment of the work buffer far data
        mov [bp - 0xa], ax
        mov [bp - 0x8], cx
        push 0x0
        push word str_HomepalsBin
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x28], ax
        mov [bp - 0x26], dx
        imul cx, [bp + 0x6], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], dx
        mov word [bp - 0x2], 0x0
        mov si, [bp - 0x2]
        mov [bp - 0x12], di
        mov ax, 0x3a0b                          ; segment of the work buffer far data
        mov ds, ax
        mov es, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette768 + 0x180], al
        inc si
        cmp si, 0xc0
        jl short .1
        mov ax, DGROUP
        mov ds, ax
        add di, 0xc0
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x12], di
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette2], al
        inc si
        cmp si, 0x100
        jl short .2
        push word [bp - 0x26]
        push word [bp - 0x28]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push word str_AwaypalsBin
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x28], ax
        mov [bp - 0x26], dx
        imul cx, [bp + 0x8], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x12], si
        mov si, [bp - 0x2]
        les di, [bp - 0x12]
        mov ax, 0x3a0b                          ; segment of the work buffer far data
        mov ds, ax
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette768 + 0x240], al
        inc si
        cmp si, 0xc0
        jl short .3
        mov ax, DGROUP
        mov ds, ax
        add di, 0xc0
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x12], di
.4:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette1], al
        inc si
        cmp si, 0x90
        jl short .4
        mov si, 0x90
.5:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        add al, 0x40
        mov [si + TeamPalette1], al
        inc si
        cmp si, 0x100
        jl short .5
        push word [bp - 0x26]
        push word [bp - 0x28]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0x3701                        ; segment of the team choice text far data
        push word str_Qpp
        push ds
        push str_Rinkpal
        push 0x0
        push 0x0
        lea ax, [bp - 0x24]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push str_Pal
        push 0x0
        lea ax, [bp - 0x24]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x28], ax
        mov [bp - 0x26], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x10], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x12], si
        mov si, [bp - 0x2]
        les di, [bp - 0x12]
        mov ax, 0x3a0b                          ; segment of the work buffer far data
        mov ds, ax
.6:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette768], al
        inc si
        cmp si, 0x180
        jl short .6
        mov si, 0x2f1
.7:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette768], al
        inc si
        cmp si, 0x300
        jl short .7
        mov ax, DGROUP
        mov ds, ax
        push word [bp - 0x26]
        push word [bp - 0x28]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0x3a0b                        ; segment of the work buffer far data
        push word TeamPalette768
        push word 0x100
        push 0x0
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf
