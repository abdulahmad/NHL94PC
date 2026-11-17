; Asset loading: builds shape banks and loads an asset file by mode. The first bytes finish
; ShowPausedBox from the file before.

;-----------------------------------------------------------------------------
; ShowPausedBoxTail                                           15A6:0000  94 PC
; End of ShowPausedBox.
;-----------------------------------------------------------------------------
ShowPausedBoxTail:
        db 0xE8, 0xE3, 0xFC                     ; insn: call 0xfce6
        retf

;-----------------------------------------------------------------------------
; BuildShapeBank                                              15A6:0004  94 PC
; Sizes a shape table (LargestShapeSize, ShapeBankSize) and copies it to one
; block.
;-----------------------------------------------------------------------------
BuildShapeBank:
        enter 0x1a, 0x0
        push di
        push si
        mov di, [bp + 0x6]
        push 0x0
        push word [bp + 0x8]
        push di
        call 0x15FF:LargestShapeSize
        add sp, 0x4
        push dx
        push ax
        push word 0x76d6
        call 0x14DB:AllocRecData0
        add sp, 0x8
        mov [bp - 0x12], ax
        mov [bp - 0x10], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jnz short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp near .10
.1:
        push word [bp + 0x8]
        push di
        call 0x03A3:TableCount
        add sp, 0x4
        mov [bp - 0x16], ax
        db 0x33, 0xF6                           ; insn: xor si, si
        mov [bp - 0x14], si
        db 0x8B, 0xFE                           ; insn: mov di, si
        jmp near .8
.2:
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:TableAt
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xc], dx
        lea ax, [bp - 0x1a]
        push ax
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:TableStore
        add sp, 0x8
        mov es, [bp - 0xc]
        mov ax, [es:si + 0x2]
        sar word [es:si], byte 0x2
        mov cx, [es:si]
        imul cx
        mov [bp - 0x6], ax
        mov word [es:si + 0xe], 0x0
        mov ax, [bp - 0x12]
        mov dx, [bp - 0x10]
        mov [bp - 0xa], ax
        mov [bp - 0x8], dx
        cmp byte [bp - 0x1a], 0x21
        jz short .7
        mov [bp - 0x14], di
        mov [bp - 0xe], si
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov es, dx
        jmp short .6
.3:
        mov ax, [bp - 0xe]
        mov dx, [bp - 0xc]
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, strict word 0x10
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ds, dx
        mov word [bp - 0x2], 0x0
        mov [bp - 0x4], cx
        mov cx, [bp - 0x2]
        mov si, [bp - 0xa]
        jmp short .5
.4:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        add di, 0x4
        mov al, [bx]
        mov [es:si], al
        inc si
        inc cx
.5:
        cmp [bp - 0x6], cx
        ja short .4
        mov [bp - 0xa], si
        mov cx, [bp - 0x4]
        inc cx
.6:
        cmp cx, 0x4
        jc short .3
        push ss
        pop ds
        mov ax, [bp - 0x6]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov cl, 0x2
        call 0x0000:__aFlshl
        push dx
        push ax
        mov ax, [bp - 0xe]
        mov dx, [bp - 0xc]
        add ax, strict word 0x10
        push dx
        push ax
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x03A3:CopyFar
        add sp, 0xc
        mov di, [bp - 0x14]
.7:
        inc di
.8:
        cmp [bp - 0x16], di
        jna short .9
        jmp near .2
.9:
        push word [bp - 0x10]
        push word [bp - 0x12]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov ax, 0x1
.10:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LoadAssetMode                                               15A6:0134  94 PC
; Finds the file by trying the extension list, then loads it packed or raw by
; extension.
;-----------------------------------------------------------------------------
LoadAssetMode:
        enter 0x82, 0x0
        push di
        push si
        push word [bp + 0x6]
        lea ax, [bp - 0x7e]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        lea si, [bp - 0x7e]
        jmp short .2
.1:
        cmp byte [si], 0x2e
        jz short .3
        inc si
.2:
        cmp byte [si], 0x0
        jnz short .1
.3:
        cmp byte [si], 0x0
        jnz short .8
        db 0x33, 0xFF                           ; insn: xor di, di
        mov [bp - 0x2], si
        jmp short .6
.4:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        push word [bx + di + AssetExtList]
        push si
        call 0x0000:_strcpy
        add sp, 0x4
        lea ax, [bp - 0x7e]
        push ax
        call 0x06E1:CopyByName
        pop bx
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .5
        db 0xE9, 0xE9, 0x02                     ; insn: jmp 0x474
.5:
        inc di
.6:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov bx, [bx + di + AssetExtList]
        cmp byte [bx], 0x0
        jnz short .4
        db 0x33, 0xFF                           ; insn: xor di, di
.7:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        mov bx, [bx + di + AssetExtList]
        cmp byte [bx], 0x0
        jz short .9
        db 0x8B, 0xDF                           ; insn: mov bx, di
        push word [bx + di + AssetExtList]
        push si
        call 0x0000:_strcpy
        add sp, 0x4
        lea ax, [bp - 0x7e]
        push ax
        call 0x15ED:FileCanOpen
        pop bx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .9
        inc di
        jmp short .7
.8:
        mov [bp - 0x2], si
        lea ax, [bp - 0x7e]
        push ax
        call 0x06E1:CopyByName
        pop bx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .9
        db 0xE9, 0x97, 0x02                     ; insn: jmp 0x474
.9:
        push word [bp - 0x2]
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_strcpy
        add sp, 0x4
        mov ax, [bp + 0x8]
        and al, 0x7f
        mov [bp - 0xa], ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0x10], ax
        push str_Qns
        lea cx, [bp - 0x1a]
        push cx
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .10
        push str_Pns
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .11
.10:
        jmp near .21
.11:
        push str_Qvs
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .12
        push str_Pvs
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .13
.12:
        jmp near .20
.13:
        push str_Qes
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .14
        jmp near .19
.14:
        push str_Pes
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .19
        push str_Esh
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .16
        push word [bp + 0xa]
        mov ax, [bp + 0x8]
        not ax
        and ax, strict word 0x20
        push ax
        lea ax, [bp - 0x7e]
        push ax
        call 0x149D:LoadRawMode
.15:
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        mov ax, 0x1
        mov [bp - 0x4], ax
        mov [bp - 0x10], ax
        jmp near .23
.16:
        push str_Vsh
        lea ax, [bp - 0x1a]
        push ax
        call 0x0000:_stricmp
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .18
        push word [bp + 0xa]
        push word [bp - 0xa]
        lea ax, [bp - 0x7e]
        push ax
        call 0x149D:LoadRawMode
.17:
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
        mov word [bp - 0x10], 0x1
        jmp short .23
.18:
        push word [bp + 0xa]
        push word [bp - 0xa]
        lea ax, [bp - 0x7e]
        push ax
        call 0x149D:LoadRawMode
        jmp short .22
.19:
        push word [bp + 0xa]
        mov ax, [bp + 0x8]
        not ax
        and ax, strict word 0x20
        push ax
        lea ax, [bp - 0x7e]
        push ax
        call 0x14B8:LoadPackedMode
        jmp short .15
.20:
        push word [bp + 0xa]
        push word [bp - 0xa]
        lea ax, [bp - 0x7e]
        push ax
        call 0x14B8:LoadPackedMode
        jmp short .17
.21:
        push word [bp + 0xa]
        push word [bp - 0xa]
        lea ax, [bp - 0x7e]
        push ax
        call 0x14B8:LoadPackedMode
.22:
        add sp, 0x6
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
.23:
        cmp word [bp - 0x4], 0x0
        jnz short .24
        jmp near .27
.24:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x0B, 0xC6                           ; insn: or ax, si
        jnz short .25
        jmp near .27
.25:
        mov es, dx
        push word [es:si + 0x2]
        push word [es:si]
        call 0x1606:ShapeBankSize
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        push str_Mga
        mov es, [bp - 0x6]
        push word [es:si + 0x2]
        push word [es:si]
        call 0x03A3:FindFar
        add sp, 0x6
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jz short .26
        mov dx, [bp - 0xc]
        add ax, strict word 0x10
        push dx
        push ax
        call 0x160C:CopyBytesFar
        add sp, 0x4
.26:
        push word [bp + 0xa]
        push word [bp - 0xa]
        push word [bp - 0x2]
        push word [bp - 0x4]
        lea ax, [bp - 0x7e]
        push ax
        call 0x06E1:InsertRec
        add sp, 0xa
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, es
        les di, [es:bx]
        mov cx, [bp - 0x4]
        mov dx, [bp - 0x2]
        mov [es:di], cx
        mov [es:di + 0x2], dx
        mov es, ax
        push word [es:bx + 0x2]
        push word [es:bx]
        mov es, [bp - 0x6]
        push word [es:si + 0x2]
        push word [es:si]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x82], bx
        mov [bp - 0x80], di
        call 0x0FEF:ConvertShapeBank
        add sp, 0x8
        push word [bp - 0x6]
        push si
        call 0x06E1:UnlinkRec
        add sp, 0x4
        push word 0x76f2
        les bx, [bp - 0x82]
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x0FEF:RemapShapeBank
        add sp, 0x6
        mov ax, [bp - 0x82]
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x6], dx
.27:
        cmp word [bp - 0x10], 0x0
        jz short .29
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x0B, 0xC6                           ; insn: or ax, si
        jz short .29
        mov es, dx
        push word [es:si + 0x2]
        push word [es:si]
        call 0x15A6:BuildShapeBank
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .29
        cmp [bp + 0xa], ax
        jz short .28
        push word 0x775d
        call 0x0F4A:FatalError
        pop bx
.28:
        push word 0x7788
        call 0x03A3:ConPrint
        pop bx
        push word [bp - 0x6]
        push si
        call 0x06E1:UnlinkRec
        add sp, 0x4
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cwd
        db 0xEB, 0x23                           ; insn: jmp short 0x477
.29:
        mov ax, [bp - 0x6]
        db 0x0B, 0xC6                           ; insn: or ax, si
        db 0x74, 0x17                           ; insn: jz 0x472
        test byte [bp + 0x8], 0x80
        db 0x74, 0x11                           ; insn: jz 0x472
        push word [bp - 0x6]
        push si
        call 0x06E1:MovePtr
        add sp, 0x4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x89
