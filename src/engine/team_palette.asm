; Loads the team palettes for a game (GAME.OVL)
; The first bytes finish the last routine of cup_final.asm.
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadTeamPalette                                            1E64:0002  94 PC
; HOMEPALS.BIN and AWAYPALS.BIN into TeamPalette1/2 plus RINKPAL.
;
; Takes 5 words of stack arguments. Calls LoadRawHeader, FindUnlink, BuildPathFar, LoadPackedHeader,
; FindFarMsg.
;-----------------------------------------------------------------------------
LoadTeamPalette:
        enter 0x20, 0x0
        push di
        push si
        push 0x0
        push strict word str_HomepalsBin_2
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        imul cx, [bp + 0x6], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x8], dx
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov cx, [bp + 0xa]
        mov [bp - 0xa], di
        mov es, dx
.1:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov ds, [bp + 0xc]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bx + 0x180], al
        inc si
        cmp si, 0xc0
        jl short .1
        mov ax, DGROUP
        mov ds, ax
        add di, 0xc0
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0xa], di
.2:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov [si + TeamPalette2], al
        inc si
        cmp si, 0x100
        jl short .2
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push 0x0
        push strict word str_AwaypalsBin_2
        call 0x149D:LoadRawHeader
        add sp, 0x4
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        imul cx, [bp + 0x8], word 0x1c0
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0xa], si
        mov si, [bp - 0x2]
        les di, [bp - 0xa]
        mov cx, [bp + 0xa]
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [es:bx]
        mov ds, [bp + 0xc]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [bx + 0x240], al
        inc si
        cmp si, 0xc0
        jl short .3
        mov ax, DGROUP
        mov ds, ax
        add di, 0xc0
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0xa], di
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
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word 0x3701
        push strict word str_Qpp
        push ds
        push strict word str_Rinkpal_2
        push 0x0
        push 0x0
        lea ax, [bp - 0x1c]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        push strict word str_Pal_12
        push 0x0
        lea ax, [bp - 0x1c]
        push ax
        call 0x14B8:LoadPackedHeader
        add sp, 0x4
        mov [bp - 0x20], ax
        mov [bp - 0x1e], dx
        push dx
        push ax
        call 0x03A3:FindFarMsg
        add sp, 0x6
        add ax, strict word 0x10
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x8], dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0xa], si
        mov si, [bp - 0x2]
        lds di, [bp - 0xa]
        mov cx, [bp + 0xa]
        mov es, [bp + 0xc]
.6:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
        inc si
        cmp si, 0x180
        jl short .6
        mov si, 0x2f1
        mov es, [bp + 0xc]
.7:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        db 0x03, 0xDE                           ; insn: add bx, si
        mov al, [bx]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDE                           ; insn: add bx, si
        mov [es:bx], al
        inc si
        cmp si, 0x300
        jl short .7
        mov ax, DGROUP
        mov ds, ax
        push word [bp - 0x1e]
        push word [bp - 0x20]
        call 0x06E1:FindUnlink
        add sp, 0x4
        pop si
