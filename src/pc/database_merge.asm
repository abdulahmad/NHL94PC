; Imports league databases and rebuilds them (LP.OVL)

;-----------------------------------------------------------------------------
; TradePlayersTail                                           2CB7:0000  94 PC
; The rest of TradePlayers, which runs on into this module.
;
; Far routine (retf).
;-----------------------------------------------------------------------------
TradePlayersTail:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeTeamRecDelta                                          2CB7:0004  94 PC
; Adds a team record's changes.
;
; Takes 5 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
MergeTeamRecDelta:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov dx, [bp + 0x6]
        mov di, [bp + 0x8]
        mov si, [bp + 0xa]
        mov al, [di + 0x28]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub al, [bx + 0x28]
        add [si + 0x28], al
        mov al, [di + 0x29]
        sub al, [bx + 0x29]
        add [si + 0x29], al
        mov al, [di + 0x2a]
        sub al, [bx + 0x2a]
        add [si + 0x2a], al
        mov al, [di + 0x2b]
        sub al, [bx + 0x2b]
        add [si + 0x2b], al
        mov ax, [di + 0x2c]
        sub ax, [bx + 0x2c]
        add [si + 0x2c], ax
        mov ax, [di + 0x2e]
        sub ax, [bx + 0x2e]
        add [si + 0x2e], ax
        mov ax, [di + 0x30]
        sub ax, [bx + 0x30]
        add [si + 0x30], ax
        mov ax, [di + 0x32]
        sub ax, [bx + 0x32]
        add [si + 0x32], ax
        mov ax, [di + 0x34]
        sub ax, [bx + 0x34]
        add [si + 0x34], ax
        mov ax, [di + 0x36]
        sub ax, [bx + 0x36]
        add [si + 0x36], ax
        mov ax, [di + 0x38]
        sub ax, [bx + 0x38]
        add [si + 0x38], ax
        mov al, [di + 0x3a]
        sub al, [bx + 0x3a]
        add [si + 0x3a], al
        mov al, [di + 0x3b]
        sub al, [bx + 0x3b]
        add [si + 0x3b], al
        mov al, [di + 0x3c]
        sub al, [bx + 0x3c]
        add [si + 0x3c], al
        mov al, [di + 0x3d]
        sub al, [bx + 0x3d]
        add [si + 0x3d], al
        mov ax, [di + 0x3e]
        sub ax, [bx + 0x3e]
        add [si + 0x3e], ax
        mov ax, [di + 0x40]
        sub ax, [bx + 0x40]
        add [si + 0x40], ax
        mov ax, [di + 0x42]
        sub ax, [bx + 0x42]
        add [si + 0x42], ax
        mov ax, [di + 0x44]
        sub ax, [bx + 0x44]
        add [si + 0x44], ax
        mov ax, [di + 0x46]
        sub ax, [bx + 0x46]
        add [si + 0x46], ax
        mov ax, [di + 0x48]
        sub ax, [bx + 0x48]
        add [si + 0x48], ax
        mov ax, [di + 0x4a]
        sub ax, [bx + 0x4a]
        add [si + 0x4a], ax
        mov ax, [bp + 0xc]
        cmp [bp + 0xe], ax
        jnz short .1
        lea si, [si + 0xbc]
        lea di, [di + 0xbc]
        xchg si, di
        mov ax, ds
        mov es, ax
        mov cx, 0x18
        rep movsw
.1:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeSeasonRecDelta                                        2CB7:00FA  94 PC
; Adds a skater record's changes.
;
; Takes 5 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
MergeSeasonRecDelta:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov dx, [bp + 0x6]
        mov di, [bp + 0x8]
        mov si, [bp + 0xa]
        mov ax, [di]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, [bx]
        add [si], ax
        mov ax, [di + 0x2]
        sub ax, [bx + 0x2]
        add [si + 0x2], ax
        mov ax, [di + 0x4]
        sub ax, [bx + 0x4]
        add [si + 0x4], ax
        mov ax, [di + 0x6]
        sub ax, [bx + 0x6]
        add [si + 0x6], ax
        mov ax, [di + 0x8]
        sub ax, [bx + 0x8]
        add [si + 0x8], ax
        mov ax, [di + 0xa]
        sub ax, [bx + 0xa]
        add [si + 0xa], ax
        mov ax, [di + 0xc]
        sub ax, [bx + 0xc]
        add [si + 0xc], ax
        mov ax, [di + 0xe]
        sub ax, [bx + 0xe]
        add [si + 0xe], ax
        mov ax, [di + 0x10]
        sub ax, [bx + 0x10]
        add [si + 0x10], ax
        mov ax, [di + 0x12]
        sub ax, [bx + 0x12]
        add [si + 0x12], ax
        mov ax, [di + 0x14]
        sub ax, [bx + 0x14]
        add [si + 0x14], ax
        mov ax, [di + 0x16]
        sub ax, [bx + 0x16]
        add [si + 0x16], ax
        mov ax, [di + 0x18]
        sub ax, [bx + 0x18]
        add [si + 0x18], ax
        mov ax, [di + 0x1a]
        sub ax, [bx + 0x1a]
        add [si + 0x1a], ax
        mov ax, [di + 0x1c]
        sub ax, [bx + 0x1c]
        add [si + 0x1c], ax
        mov ax, [di + 0x1e]
        sub ax, [bx + 0x1e]
        add [si + 0x1e], ax
        mov ax, [di + 0x20]
        sub ax, [bx + 0x20]
        add [si + 0x20], ax
        mov ax, [di + 0x22]
        sub ax, [bx + 0x22]
        add [si + 0x22], ax
        mov ax, [bp + 0xc]
        cmp [bp + 0xe], ax
        jnz short .1
        mov al, [di + 0x24]
        mov [si + 0x24], al
        mov al, [di + 0x25]
        mov [si + 0x25], al
        mov al, [di + 0x26]
        mov [si + 0x26], al
        mov al, [di + 0x27]
        mov [si + 0x27], al
.1:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeGoalieRecDelta                                        2CB7:01CE  94 PC
; Adds a goalie record's changes.
;
; Takes 5 words of stack arguments. Calls __aFldiv. Far routine (retf).
;-----------------------------------------------------------------------------
MergeGoalieRecDelta:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov di, [bp + 0x8]
        mov dx, [bp + 0x6]
        mov si, [bp + 0xa]
        mov ax, [di]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        sub ax, [bx]
        add [si], ax
        mov ax, [di + 0x2]
        sub ax, [bx + 0x2]
        add [si + 0x2], ax
        mov ax, [di + 0x4]
        sub ax, [bx + 0x4]
        add [si + 0x4], ax
        mov ax, [di + 0x6]
        sub ax, [bx + 0x6]
        add [si + 0x6], ax
        mov ax, [di + 0x8]
        sub ax, [bx + 0x8]
        add [si + 0x8], ax
        mov ax, [di + 0xa]
        sub ax, [bx + 0xa]
        add [si + 0xa], ax
        mov ax, [di + 0xc]
        sub ax, [bx + 0xc]
        add [si + 0xc], ax
        mov ax, [di + 0xe]
        sub ax, [bx + 0xe]
        add [si + 0xe], ax
        mov ax, [di + 0x12]
        sub ax, [bx + 0x12]
        add [si + 0x12], ax
        mov ax, [di + 0x14]
        sub ax, [bx + 0x14]
        add [si + 0x14], ax
        mov ax, [di + 0x16]
        sub ax, [bx + 0x16]
        add [si + 0x16], ax
        mov ax, [di + 0x18]
        sub ax, [bx + 0x18]
        add [si + 0x18], ax
        mov ax, [di + 0x1a]
        sub ax, [bx + 0x1a]
        add [si + 0x1a], ax
        mov ax, [di + 0x1c]
        sub ax, [bx + 0x1c]
        add [si + 0x1c], ax
        mov ax, [di + 0x1e]
        sub ax, [bx + 0x1e]
        add [si + 0x1e], ax
        mov ax, [di + 0x20]
        sub ax, [bx + 0x20]
        add [si + 0x20], ax
        mov ax, [di + 0x22]
        sub ax, [bx + 0x22]
        add [si + 0x22], ax
        mov ax, [di + 0x24]
        sub ax, [bx + 0x24]
        add [si + 0x24], ax
        mov ax, [di + 0x28]
        sub ax, [bx + 0x28]
        add [si + 0x28], ax
        mov ax, [di + 0x2a]
        sub ax, [bx + 0x2a]
        add [si + 0x2a], ax
        cmp word [si], 0x0
        jz short .1
        push 0x0
        push word [si]
        mov ax, 0x64
        mul word [si + 0xe]
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [si + 0x10], ax
        jmp short .2
.1:
        mov word [si + 0x10], 0x0
.2:
        cmp word [si + 0x16], 0x0
        jz short .3
        push 0x0
        push word [si + 0x16]
        mov ax, 0x64
        mul word [si + 0x24]
        push dx
        push ax
        call 0x0000:__aFldiv
        mov [si + 0x26], ax
        jmp short .4
.3:
        mov word [si + 0x26], 0x0
.4:
        mov ax, [bp + 0xc]
        cmp [bp + 0xe], ax
        jnz short .5
        mov al, [di + 0x2c]
        mov [si + 0x2c], al
        mov al, [di + 0x2d]
        mov [si + 0x2d], al
        mov al, [di + 0x2e]
        mov [si + 0x2e], al
        mov al, [di + 0x2f]
        mov [si + 0x2f], al
.5:
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeTeamDbs                                               2CB7:02F6  94 PC
; Merges a team db copy into the league.
;
; Takes 11 words of stack arguments. Calls BuildPathFar, OpenReadShared, OpenReadWriteShared,
; ReadEntry744, MergeTeamRecDelta, WriteTeamRec, ReadRecord52, ReadRecord48 and others. Far routine
; (retf).
;-----------------------------------------------------------------------------
MergeTeamDbs:
        enter 0xa5e, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        mov ax, 0xffff
        mov [bp - 0x18], ax
        mov [bp - 0x16], ax
        mov [bp - 0x14], ax
        mov [bp - 0x12], ax
        mov [bp - 0x10], ax
        mov [bp - 0xc], ax
        mov [bp - 0xe], ax
        mov ax, str_Db_2
        mov cx, 0x3701
        mov [bp - 0xa5a], ax
        mov [bp - 0xa58], cx
        push cx
        push ax
        mov bx, 0xb7c
        mov es, [segTeamChoiceText43]
        mov [bp - 0xa5e], bx
        mov [bp - 0xa5c], es
        push word [es:bx + 0x2]
        push word [es:bx]
        push word [bp + 0x8]
        push di
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x14]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .1
        push word [bp + 0x14]
        push word [bp + 0x12]
        les bx, [bp - 0xa5e]
        push word [es:bx + 0x2]
        push word [es:bx]
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x18]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.1:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        push word [bp + 0x18]
        push word [bp + 0x16]
        les bx, [bp - 0xa5e]
        push word [es:bx + 0x2]
        push word [es:bx]
        push word [bp + 0x10]
        push word [bp + 0xe]
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x16]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .3
        push word [bp - 0xa58]
        push word [bp - 0xa5a]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x2]
        push word [es:DbFileNameList]
        push word [bp + 0x8]
        push di
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x12]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        push word [bp - 0xa58]
        push word [bp - 0xa5a]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x16]
        push word [es:DbFileNameList + 0x14]
        mov ax, [bp + 0x8]
        push ax
        push di
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xe]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        push word [bp + 0x14]
        push word [bp + 0x12]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x16]
        push word [es:DbFileNameList + 0x14]
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x10]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .6
        push word [bp + 0x18]
        push word [bp + 0x16]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x16]
        push word [es:DbFileNameList + 0x14]
        push word [bp + 0x10]
        push word [bp + 0xe]
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xc]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.6:
        db 0x2B, 0xFF                           ; insn: sub di, di
.7:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .8
        push di
        lea ax, [bp - 0x486]
        push ss
        push ax
        push word [bp - 0x14]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.8:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .9
        push di
        lea ax, [bp - 0x76e]
        push ss
        push ax
        push word [bp - 0x18]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.9:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .10
        push di
        lea ax, [bp - 0xa56]
        push ss
        push ax
        push word [bp - 0x16]
        call 0x0CD1:ReadEntry744
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.10:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .11
        push di
        push word [bp + 0x1a]
        lea ax, [bp - 0xa56]
        push ax
        lea cx, [bp - 0x76e]
        push cx
        lea cx, [bp - 0x486]
        push cx
        push cs
        call MergeTeamRecDelta
        add sp, 0xa
        push di
        lea ax, [bp - 0xa56]
        push ss
        push ax
        push word [bp - 0x16]
        call 0x20E6:WriteTeamRec
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
.11:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .12
        jmp near .30
.12:
        mov [bp - 0xa], di
        lea dx, [bp - 0x722]
        mov [bp - 0x6], dx
        db 0x8B, 0xFA                           ; insn: mov di, dx
.13:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .14
        jmp near .20
.14:
        mov ax, [di]
        mov dx, [di + 0x2]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        cmp ax, strict word 0xffff
        jnz short .15
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jnz short .15
        jmp near .19
.15:
        push dx
        push ax
        lea ax, [bp - 0xfc]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .16
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x68]
        push ss
        push ax
        push word [bp - 0xe]
        call 0x0CD1:ReadRecord48
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.16:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .17
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x98]
        push ss
        push ax
        push word [bp - 0x10]
        call 0x0CD1:ReadRecord48
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.17:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .18
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0xc8]
        push ss
        push ax
        push word [bp - 0xc]
        call 0x0CD1:ReadRecord48
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.18:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .19
        push word [bp - 0xa]
        push word [bp + 0x1a]
        lea ax, [bp - 0xc8]
        push ax
        lea cx, [bp - 0x98]
        push cx
        lea cx, [bp - 0x68]
        push cx
        push cs
        call MergeSeasonRecDelta
        add sp, 0xa
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0xc8]
        push ss
        push ax
        push word [bp - 0xc]
        call 0x20E6:WriteSeasonRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.19:
        add di, 0x4
        lea ax, [bp - 0x6be]
        db 0x3B, 0xF8                           ; insn: cmp di, ax
        jnc short .20
        jmp near .13
.20:
        lea di, [bp - 0x6be]
.21:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .23
.22:
        mov di, [bp - 0xa]
        jmp near .30
        db 0x90
.23:
        mov ax, [di]
        mov dx, [di + 0x2]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        cmp ax, strict word 0xffff
        jnz short .24
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jnz short .24
        jmp near .28
.24:
        push dx
        push ax
        lea ax, [bp - 0xfc]
        push ss
        push ax
        push word [bp - 0x12]
        call 0x0CD1:ReadRecord52
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .25
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x132]
        push ss
        push ax
        push word [bp - 0xe]
        call 0x20E6:ReadGoalieSeasonRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.25:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .26
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x168]
        push ss
        push ax
        push word [bp - 0x10]
        call 0x20E6:ReadGoalieSeasonRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.26:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .27
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x19e]
        push ss
        push ax
        push word [bp - 0xc]
        call 0x20E6:ReadGoalieSeasonRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.27:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .28
        push word [bp - 0xa]
        push word [bp + 0x1a]
        lea ax, [bp - 0x19e]
        push ax
        lea cx, [bp - 0x168]
        push cx
        lea cx, [bp - 0x132]
        push cx
        push cs
        call MergeGoalieRecDelta
        add sp, 0xa
        push word [bp - 0xce]
        push word [bp - 0xd0]
        lea ax, [bp - 0x19e]
        push ss
        push ax
        push word [bp - 0xc]
        call 0x20E6:WriteGoalieSeasonRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.28:
        add di, 0x4
        lea ax, [bp - 0x6b2]
        db 0x3B, 0xF8                           ; insn: cmp di, ax
        jnc short .29
        jmp near .21
.29:
        jmp near .22
        db 0x90
.30:
        inc di
        cmp di, 0x18
        jnl short .31
        jmp near .7
.31:
        lea ax, [bp - 0xc]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x10]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0xe]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x12]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x18]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x14]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeScheduleDb                                            2CB7:0778  94 PC
; Merges the schedule.
;
; Takes 10 words of stack arguments. Calls BuildPathFar, OpenReadShared, OpenReadWriteShared,
; ReadAtOffset, WriteAtOffset, ReadEntry6, WriteSchedGame, CloseHandlePtr. Far routine (retf).
;-----------------------------------------------------------------------------
MergeScheduleDb:
        enter 0x30, 0x0
        push di
        push si
        mov ax, 0xffff
        mov [bp - 0x6], ax
        mov [bp - 0x8], ax
        push word [bp + 0x10]
        push word [bp + 0xe]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x30]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x30]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .1
        push word [bp + 0x14]
        push word [bp + 0x12]
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x30]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x30]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF8                           ; insn: mov di, ax
.1:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .2
        push 0x2
        push di
        push di
        lea ax, [bp - 0x4]
        push ss
        push ax
        push word [bp - 0x8]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF8                           ; insn: mov di, ax
.2:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .3
        push 0x2
        push di
        push di
        lea ax, [bp - 0xa]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF8                           ; insn: mov di, ax
.3:
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .4
        mov si, [bp + 0x18]
        mov ax, [bp - 0xa]
        mov [si], ax
        mov ax, [bp - 0x4]
        cmp [bp - 0xa], ax
        jnl short .4
        mov [si], ax
        push 0x2
        push di
        push di
        lea ax, [bp - 0x4]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        db 0x8B, 0xF8                           ; insn: mov di, ax
.4:
        mov [bp - 0x2], di
        cmp word [bp - 0x4], 0x3f0
        jl short .5
        mov word [bp - 0x4], 0x459
.5:
        db 0x2B, 0xF6                           ; insn: sub si, si
        cmp [bp - 0x4], si
        jng short .9
        mov di, [bp + 0x16]
.6:
        cmp word [bp - 0x2], 0x0
        jnz short .9
        push si
        lea ax, [bp - 0x10]
        push ss
        push ax
        push word [bp - 0x8]
        call 0x0CD1:ReadEntry6
        add sp, 0x8
        mov [bp - 0x2], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .8
        mov al, [bp - 0xe]
        db 0x2A, 0xE4                           ; insn: sub ah, ah
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jz short .7
        mov al, [bp - 0xd]
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jnz short .8
.7:
        push si
        lea ax, [bp - 0x10]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x20E6:WriteSchedGame
        add sp, 0x8
        mov [bp - 0x2], ax
.8:
        inc si
        cmp [bp - 0x4], si
        jg short .6
.9:
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LocateTeamDbCopy                                           2CB7:08DE  94 PC
; Finds the team's db copy.
;
; Takes 12 words of stack arguments. Calls WaitLeagueFloppy, GetLeagueId, MouseRead, MessageBox. Far
; routine (retf).
;-----------------------------------------------------------------------------
LocateTeamDbCopy:
        enter 0x8, 0x0
        push di
        push si
        les si, [bp + 0x6]
        mov di, [bp + 0xa]
        mov word [bp - 0x2], 0x0
        imul bx, di, 0x1e
        db 0x03, 0xDE                           ; insn: add bx, si
        cmp byte [es:bx + 0x18], 0x1
        jnz short .1
        jmp near .6
.1:
        imul bx, di, 0x1e
        db 0x03, 0xDE                           ; insn: add bx, si
        cmp byte [es:bx + 0x16], 0x1
        jnz short .2
        jmp near .6
.2:
        mov ax, [bp + 0x14]
        mov dx, [bp + 0x16]
        mov bx, [bp + 0x18]
        mov [bx], ax
        mov [bx + 0x2], dx
        push 0x0
        imul cx, di, 0x1e
        db 0x03, 0xCE                           ; insn: add cx, si
        mov bx, [bp + 0x8]
        push bx
        push cx
        push word [bp + 0xe]
        push word [bp + 0xc]
        call 0x20F8:WaitLeagueFloppy
        add sp, 0xa
        mov [bp - 0x2], ax
        push word [bp + 0x1c]
        push word [bp + 0x1a]
        push word [bp + 0x16]
        push word [bp + 0x14]
        call 0x2305:GetLeagueId
        add sp, 0x8
        cmp word [bp - 0x2], 0x4
        jnz short .3
        jmp near .7
.3:
        les bx, [bp + 0x1a]
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
        imul bx, di, 0x1e
        db 0x03, 0xDE                           ; insn: add bx, si
        mov es, [bp + 0x8]
        cmp [es:bx + 0x1c], dx
        jnc short .4
        jmp near .7
.4:
        ja short .5
        cmp [es:bx + 0x1a], ax
        jna short .7
.5:
        mov ax, [bp + 0xc]
        mov dx, [bp + 0xe]
        mov es, [segTeamChoiceText44]
        mov [es:msgThatFloppyDiskHasAn + 0x8], ax
        mov [es:msgThatFloppyDiskHasAn + 0xA], dx
        lea ax, [bp - 0x4]
        push ax
        lea cx, [bp - 0x6]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x4]
        push ax
        lea ax, [bp - 0x6]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgThatFloppyDiskHasAn
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov word [bp - 0x2], 0xffff
        jmp short .7
.6:
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        mov bx, [bp + 0x18]
        mov [bx], ax
        mov [bx + 0x2], dx
        imul bx, di, 0x1e
        add bx, [bp + 0x6]
        mov es, [bp + 0x8]
        mov ax, [es:bx + 0x1a]
        mov dx, [es:bx + 0x1c]
        les bx, [bp + 0x1a]
        mov [es:bx], ax
        mov [es:bx + 0x2], dx
.7:
        mov ax, [bp - 0x2]
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; UpdateTeamDbs                                              2CB7:09FA  94 PC
; Update after an import.
;
; Calls SetDialogColors, LeagueCheckStub, ReadLeagueInfo, _fstrcpy, _fstrcspn, MouseRead, MessageBox,
; BuildPathFar and others. Far routine (retf).
;-----------------------------------------------------------------------------
UpdateTeamDbs:
        enter 0x3c, 0x0
        push di
        push si
        mov word [bp - 0x6], 0xffff
        db 0x2B, 0xFF                           ; insn: sub di, di
        push di
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x2
        mov ax, CurLeagueName
        mov cx, 0x3701
        mov [bp - 0x3c], ax
        mov [bp - 0x3a], cx
        push cx
        push ax
        call 0x2305:LeagueCheckStub
        add sp, 0x6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .8
.1:
        push word 0x3a0b
        push strict word leagueinfo_tail
        push word 0x3a0b
        push strict word leagueinfo_w6
        push word 0x3a0b
        push strict word leagueinfo_w4
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word 0x3a0b
        push strict word leagueinfo
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x18]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lea ax, [bp - 0x18]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov byte [bx], 0x0
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .2
        mov es, [segWorkBuffer35]
        cmp [es:leagueinfo_w6], si
        jz short .2
        mov es, [segTeamChoiceText45]
        mov [es:msgThereIsASavedGame + 0x4], ax
        mov [es:msgThereIsASavedGame + 0x6], ss
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgThereIsASavedGame
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        mov di, 0xffff
.2:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .3
        jmp near .8
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        lea ax, [bp - 0x38]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x6]
        push ax
        lea ax, [bp - 0x38]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        push 0x2
        push si
        push 0x13
        lea ax, [bp - 0xa]
        push ss
        push ax
        push word [bp - 0x6]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        lea ax, [bp - 0x6]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .7
        test byte [bp - 0xa], 0x4
        jz short .6
        push -0x1
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x3a]
        push word [bp - 0x3c]
        call 0x2305:CopyHumanTeamDBs
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        jmp short .7
        db 0x90
.6:
        lea ax, [bp - 0x18]
        mov es, [segTeamChoiceText46]
        mov [es:msgTheLeague3 + 0x4], ax
        mov [es:msgTheLeague3 + 0x6], ss
        mov word [es:msgTheLeague3 + 0x8], str_HasNotBeenMerged
        mov word [es:msgTheLeague3 + 0xA], 0x3701
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgTheLeague3
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.7:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .8
        lea ax, [bp - 0x2]
        push ax
        lea cx, [bp - 0x4]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x2]
        push ax
        lea ax, [bp - 0x4]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3836
        push strict word msgErrorWhileUpdatingPlayersDatabases
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.8:
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
        add sp, 0xa
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; MergeLeagueFiles                                           2CB7:0C28  94 PC
; Merges every returned team.
;
; Calls SetDialogColors, LeagueCheckStub, ReadLeagueInfo, BuildPathFar, FileExists, _fstrcpy,
; _fstrcspn, MouseRead and others. Far routine (retf).
;-----------------------------------------------------------------------------
MergeLeagueFiles:
        enter 0x52, 0x0
        push si
        mov ax, 0xffff
        mov [bp - 0x3a], ax
        mov [bp - 0x50], ax
        mov [bp - 0xa], ax
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        push 0x2
        push word 0x3701
        push strict word CurLeagueName
        call 0x2305:LeagueCheckStub
        add sp, 0x6
        mov [bp - 0x52], ax
        mov byte [lgflags], 0x0
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .34
.1:
        push word 0x3a0b
        push strict word leagueinfo_tail
        push word 0x3a0b
        push strict word leagueinfo_w6
        push word 0x3a0b
        push strict word leagueinfo_w4
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word 0x3a0b
        push strict word leagueinfo
        push word 0x3a0b
        push strict word leagueinfo_password
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word 0x3701
        push strict word CurLeagueName
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        mov [bp - 0x52], ax
        push word 0x3701
        push strict word str_Id
        push word 0x3701
        push strict word str_Player
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:FileExists
        add sp, 0x2
        mov [mergestate], ax
        cmp word [bp - 0x52], 0x0
        jz short .2
        jmp near .34
.2:
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x4e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x3701
        push strict word str_Dot
        lea ax, [bp - 0x4e]
        push ss
        push ax
        call 0x0000:_fstrcspn
        add sp, 0x8
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], si
        mov byte [bp + si - 0x4e], 0x0
        mov es, [segWorkBuffer35]
        cmp word [es:leagueinfo_w6], 0x0
        jz short .3
        lea ax, [bp - 0x4e]
        mov es, [segTeamChoiceText45]
        mov [es:msgThereIsASavedGame + 0x4], ax
        mov [es:msgThereIsASavedGame + 0x6], ss
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x38]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgThereIsASavedGame
        jmp near .33
.3:
        mov es, [segWorkBuffer36]
        imul bx, [es:leagueinfo], 0x1e
        mov es, [segWorkBuffer37]
        cmp byte [es:bx + leagueinfo_teams + 0x16], 0x2
        jnz short .4
        lea ax, [bp - 0x4e]
        mov es, [segMergeMessages1]
        mov [es:msgTheMasterControllerForThe + 0x4], ax
        mov [es:msgTheMasterControllerForThe + 0x6], ss
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x38]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3836
        push strict word msgTheMasterControllerForThe
        jmp near .33
        db 0x90
.4:
        cmp word [mergestate], 0x0
        jz short .5
        lea ax, [bp - 0x4e]
        mov es, [segMergeMessages1]
        mov [es:msgTheDatabasesCanOnlyBe + 0x8], ax
        mov [es:msgTheDatabasesCanOnlyBe + 0xA], ss
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x38]
        push cx
        lea dx, [bp - 0x8]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3836
        push strict word msgTheDatabasesCanOnlyBe
        jmp near .33
.5:
        mov es, [segWorkBuffer38]
        test byte [es:leagueinfo_w4], 0x4
        jz short .6
        jmp near .32
.6:
        cmp word [bp - 0x52], 0x0
        jnz short .7
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x3a]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x52], ax
.7:
        cmp word [bp - 0x52], 0x0
        jnz short .8
        mov es, [segWorkBuffer36]
        push word [es:leagueinfo]
        push strict word str_02d_2
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x2e]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x32]
        push ss
        push ax
        lea ax, [bp - 0x4]
        push ax
        push word 0x3701
        push strict word str_DriveColon
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word CurLeagueName
        mov es, [segWorkBuffer36]
        push word [es:leagueinfo]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push cs
        call LocateTeamDbCopy
        add sp, 0x18
        mov [bp - 0x52], ax
.8:
        cmp word [bp - 0x52], 0x0
        jnz short .9
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgMergingPlayersToMasterDatabase
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.9:
        mov word [bp - 0x40], 0x0
.10:
        cmp word [bp - 0x52], 0x0
        jz short .11
        jmp near .22
.11:
        mov es, [segWorkBuffer37]
        imul bx, [bp - 0x40], 0x1e
        cmp byte [es:bx + leagueinfo_teams + 0x17], 0x1
        jz short .12
        jmp near .21
.12:
        test byte [es:bx + leagueinfo_teams + 0x16], 0x4
        jz short .13
        jmp near .21
.13:
        push word [bp - 0x40]
        push strict word str_02d
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x2e]
        push ss
        push ax
        push word 0x3701
        push strict word str_Xx_2
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x32]
        push ss
        push ax
        lea ax, [bp - 0x36]
        push ax
        push word 0x3701
        push strict word str_DriveColon
        push word 0x3701
        push strict word CurLeagueName
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x40]
        push word 0x3a0b
        push strict word leagueinfo_teams
        push cs
        call LocateTeamDbCopy
        add sp, 0x18
        mov [bp - 0x52], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .15
        mov ax, [SaveUnderSeg]
        or ax, [SaveUnderOff]
        jnz short .14
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgMergingPlayersToMasterDatabase
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.14:
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp - 0x34]
        push word [bp - 0x36]
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x50]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        mov [bp - 0x52], ax
.15:
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .16
        mov ax, [bp - 0x40]
        mov es, [segWorkBuffer36]
        cmp [es:leagueinfo], ax
        jz short .16
        push ax
        push word 0x3701
        push strict word str_Xx
        push word 0x3701
        push strict word str_Xx_2
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0x34]
        push word [bp - 0x36]
        push word 0x3701
        push strict word CurLeagueName
        push cs
        call MergeTeamDbs
        add sp, 0x16
        mov [bp - 0x52], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .16
        lea ax, [bp - 0x3c]
        push ax
        push word [bp - 0x40]
        push word 0x3701
        push strict word str_Xx
        push word 0x3701
        push strict word str_Xx_2
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x34]
        push word [bp - 0x36]
        push cs
        call MergeScheduleDb
        add sp, 0x14
        mov [bp - 0x52], ax
.16:
        cmp word [bp - 0x52], 0x0
        jnz short .17
        mov ax, [bp - 0x32]
        mov dx, [bp - 0x30]
        mov es, [segWorkBuffer37]
        imul bx, [bp - 0x40], 0x1e
        mov [es:bx + leagueinfo_teams + 0x1a], ax
        mov [es:bx + leagueinfo_teams + 0x1c], dx
        or byte [es:bx + leagueinfo_teams + 0x16], 0x4
        push word [bp - 0x40]
        add bx, leagueinfo_teams
        push es
        push bx
        push word [bp - 0x3a]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0x52], ax
.17:
        cmp word [bp - 0x52], 0x0
        jnz short .18
        push word [bp - 0x40]
        imul ax, [bp - 0x40], 0x1e
        add ax, leagueinfo_teams
        push word 0x3a0b
        push ax
        push word [bp - 0x50]
        call 0x20E6:WriteLeagueTeamEntry
        add sp, 0x8
        mov [bp - 0x52], ax
.18:
        cmp word [bp - 0x52], 0x0
        jnz short .20
        mov ax, CurLeagueName
        mov cx, 0x3701
        cmp ax, [bp - 0x36]
        jnz short .19
        cmp cx, [bp - 0x34]
        jz short .20
.19:
        mov es, [segWorkBuffer38]
        mov word [es:leagueinfo_w4], 0x4
        push 0x2
        push 0x0
        push 0x13
        push es
        push word leagueinfo_w4
        push word [bp - 0x50]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x52], ax
.20:
        lea ax, [bp - 0x50]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x52], 0x0
        jnz short .21
        mov es, [segWorkBuffer38]
        mov word [es:leagueinfo_w4], 0x8
        push 0x2
        push 0x0
        push 0x13
        push es
        push word leagueinfo_w4
        push word [bp - 0x3a]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x52], ax
.21:
        inc word [bp - 0x40]
        cmp word [bp - 0x40], 0x18
        jnl short .22
        jmp near .10
.22:
        cmp word [bp - 0x52], 0x0
        jnz short .23
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x12]
        push word [es:DbFileNameList + 0x10]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x52], ax
.23:
        cmp word [bp - 0x52], 0x0
        jnz short .24
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x16]
        push word [es:DbFileNameList + 0x14]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x52], ax
.24:
        cmp word [bp - 0x52], 0x0
        jnz short .25
        push word 0x3701
        push strict word CurLeagueName
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Xx
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        call 0x0CD1:CopyFileByName
        add sp, 0x14
        mov [bp - 0x52], ax
.25:
        call 0x0D90:RestoreUnderBox
        cmp word [bp - 0x52], 0x0
        jnz short .26
        push word 0x3701
        push strict word str_Db_2
        mov es, [segTeamChoiceText43]
        push word [es:DbFileNameList + 0x1A]
        push word [es:DbFileNameList + 0x18]
        push word 0x3701
        push strict word CurLeagueName
        lea ax, [bp - 0x2a]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0x2a]
        push ax
        call 0x0CD1:OpenReadShared
        add sp, 0x4
        mov [bp - 0x52], ax
.26:
        cmp word [bp - 0x52], 0x0
        jnz short .27
        push 0x2
        push 0x0
        push 0x0
        lea ax, [bp - 0x3c]
        push ss
        push ax
        push word [bp - 0xa]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        mov [bp - 0x52], ax
.27:
        lea ax, [bp - 0xa]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        cmp word [bp - 0x52], 0x0
        jnz short .28
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3701
        push strict word msgUpdatingSchedule
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
        push 0x7
        push -0x1
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x3c]
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word CurLeagueName
        call 0x28CD:UpdateSeasonSchedule
        add sp, 0x12
        mov [bp - 0x52], ax
.28:
        cmp word [bp - 0x52], 0x0
        jnz short .29
        mov es, [segWorkBuffer38]
        mov word [es:leagueinfo_w4], 0x4
        push 0x2
        push 0x0
        push 0x13
        push es
        push word leagueinfo_w4
        push word [bp - 0x3a]
        call 0x0CD1:WriteAtOffset
        add sp, 0xc
        mov [bp - 0x52], ax
.29:
        call 0x0D90:RestoreUnderBox
        lea ax, [bp - 0x3a]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x38]
        push cx
        lea dx, [bp - 0x40]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        cmp word [bp - 0x52], 0x4
        jnz short .31
        mov es, [segWorkBuffer38]
        cmp word [es:leagueinfo_w4], 0x8
        jz short .30
        jmp near .34
.30:
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3836
        push strict word msgWarningMergeNotCompletedLeague
        jmp short .33
        db 0x90
.31:
        cmp word [bp - 0x52], 0x0
        jz short .34
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x1
        push word 0x3836
        push strict word msgErrorWhileMergingDatabases
        jmp short .33
.32:
        lea ax, [bp - 0x4e]
        mov es, [segTeamChoiceText46]
        mov [es:msgTheLeague3 + 0x4], ax
        mov [es:msgTheLeague3 + 0x6], ss
        mov word [es:msgTheLeague3 + 0x8], str_IsAlreadyMerged
        mov word [es:msgTheLeague3 + 0xA], 0x3701
        lea ax, [bp - 0x3e]
        push ax
        lea cx, [bp - 0x38]
        push cx
        lea dx, [bp - 0x40]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0x3e]
        push ax
        lea ax, [bp - 0x38]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x3
        push word 0x3701
        push strict word msgTheLeague3
.33:
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.34:
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
        add sp, 0xa
        mov al, [lgflags]
        cbw
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MergeUpdateDbs                                             2CB7:134E  94 PC
; Menu item: merge.
;
; Calls MergeLeagueFiles, ClearClipRect, SetPaletteFar, UpdateTeamDbs. Far routine (retf).
;-----------------------------------------------------------------------------
MergeUpdateDbs:
        enter 0x4, 0x0
        push si
        push cs
        call MergeLeagueFiles
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov es, [segWorkBuffer35]
        cmp word [es:leagueinfo_w6], 0x0
        jz short .1
        jmp near .5
.1:
        mov es, [segWorkBuffer36]
        imul bx, [es:leagueinfo], 0x1e
        mov es, [segWorkBuffer37]
        cmp byte [es:bx + leagueinfo_teams + 0x16], 0x2
        jnz short .2
        jmp near .5
.2:
        cmp word [mergestate], 0x0
        jz short .3
        jmp near .5
.3:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .4
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        mov al, 0x17
        mov [bp - 0x4], al
        mov [bp - 0x3], al
        mov [bp - 0x2], al
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x2a
        mov [bp - 0x4], al
        mov [bp - 0x3], al
        mov [bp - 0x2], al
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        mov al, 0x3f
        mov [bp - 0x4], al
        mov [bp - 0x3], al
        mov [bp - 0x2], al
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.4:
        push cs
        call UpdateTeamDbs
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .5
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        db 0x2A, 0xC0                           ; insn: sub al, al
        mov [bp - 0x4], al
        mov [bp - 0x3], al
        mov [bp - 0x2], al
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0x5
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0xb
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
        lea ax, [bp - 0x4]
        push ss
        push ax
        push 0x1
        push 0x11
        call 0x0FEF:SetPaletteFar
        add sp, 0x8
.5:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; RebuildLeagueDbs                                           2CB7:1442  94 PC
; Rebuilds the league dbs.
;
; Calls SetDialogColors, LeagueCheckStub, ReadLeagueInfo, AskTeamPassword, AskMasterPassword,
; BuildPathFar, OpenReadWriteShared, ReadAtOffset and others.
;-----------------------------------------------------------------------------
RebuildLeagueDbs:
        enter 0x36, 0x0
        push di
        push si
        mov word [bp - 0x8], 0xffff
        push 0x0
        push 0x11
        push 0x5
        push 0x11
        push 0xb
        call 0x0D90:SetDialogColors
        add sp, 0xa
        mov si, [bp - 0x2]
        push 0x2
        mov ax, CurLeagueName
        mov cx, 0x3701
        mov [bp - 0x32], ax
        mov [bp - 0x30], cx
        push cx
        push ax
        call 0x2305:LeagueCheckStub
        add sp, 0x6
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .1
        jmp near .5
.1:
        push word 0x3a0b
        push strict word leagueinfo_tail
        push word 0x3a0b
        push strict word leagueinfo_w6
        push word 0x3a0b
        push strict word leagueinfo_w4
        push word 0x3a0b
        push strict word leagueinfo_w2
        push word 0x3a0b
        push strict word leagueinfo
        push word 0x3a0b
        push strict word leagueinfo_password
        mov ax, leagueinfo_teams
        mov cx, 0x3a0b
        mov [bp - 0x36], ax
        mov [bp - 0x34], cx
        push cx
        push ax
        push word [bp - 0x30]
        push word [bp - 0x32]
        call 0x22D3:ReadLeagueInfo
        add sp, 0x20
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov [bp - 0x6], si
        mov [bp - 0x4], di
.2:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .4
        mov es, [segWorkBuffer37]
        imul bx, [bp - 0x6], 0x1e
        cmp byte [es:bx + leagueinfo_teams + 0x17], 0x1
        jnz short .3
        push word [bp - 0x34]
        push word [bp - 0x36]
        push word [bp - 0x6]
        call 0x28A8:AskTeamPassword
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
.3:
        inc word [bp - 0x6]
        cmp word [bp - 0x6], 0x18
        jl short .2
.4:
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .5
        push word 0x3a0b
        push strict word leagueinfo_password
        push word [bp - 0x34]
        push word [bp - 0x36]
        mov es, [segWorkBuffer36]
        push word [es:leagueinfo]
        call 0x28A8:AskMasterPassword
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.5:
        db 0x0B, 0xFF                           ; insn: or di, di
        jz short .6
        jmp near .10
.6:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .7
        jmp near .10
.7:
        push word 0x3701
        push strict word str_Db_2
        push word 0x3701
        push strict word str_Pinfo
        push word [bp - 0x30]
        push word [bp - 0x32]
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0CD1:BuildPathFar
        add sp, 0x10
        lea ax, [bp - 0x8]
        push ax
        lea ax, [bp - 0x2e]
        push ax
        call 0x0CD1:OpenReadWriteShared
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .8
        push 0x2
        push si
        push 0x13
        lea ax, [bp - 0xe]
        push ss
        push ax
        push word [bp - 0x8]
        call 0x0CD1:ReadAtOffset
        add sp, 0xc
        db 0x8B, 0xF0                           ; insn: mov si, ax
.8:
        lea ax, [bp - 0x8]
        push ax
        call 0x0CD1:CloseHandlePtr
        add sp, 0x2
        db 0x0B, 0xF6                           ; insn: or si, si
        jnz short .9
        push word [bp - 0x30]
        push word [bp - 0x32]
        lea ax, [bp - 0x2e]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        push strict word str_Sav_6
        push strict word str_Game_7
        lea ax, [bp - 0x2e]
        push ax
        call 0x0CD1:DeleteMatching
        add sp, 0x6
        push -0x1
        push word 0x3a0b
        push strict word leagueinfo_teams
        push word [bp - 0x30]
        push word [bp - 0x32]
        call 0x2305:CopyHumanTeamDBs
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
.9:
        db 0x0B, 0xF6                           ; insn: or si, si
        jz short .10
        lea ax, [bp - 0xa]
        push ax
        lea cx, [bp - 0xc]
        push cx
        lea dx, [bp - 0x6]
        push dx
        call 0x03A3:MouseRead
        add sp, 0x6
        push -0x1
        lea ax, [bp - 0xa]
        push ax
        lea ax, [bp - 0xc]
        push ax
        push 0x0
        push 0x0
        push 0x0
        push 0x2
        push word 0x3836
        push strict word msgErrorWhileUpdatingPlayersDatabases
        push -0x1
        push -0x1
        call 0x0D90:MessageBox
        add sp, 0x16
.10:
        push 0x0
        push 0x3f
        push 0x17
        push 0x3f
        push 0x2a
        call 0x0D90:SetDialogColors
