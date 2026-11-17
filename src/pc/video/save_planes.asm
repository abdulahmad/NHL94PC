; Saves and restores the four VGA planes, and FatalError, which shows a message and quits.

PlayArenaJingleTail:                            ; end of PlayArenaJingle in; not used in the EXE (overlays may
                                                ; use it)
        db 0x08, 0x5E, 0xC9                     ; db 0x08
        retf

;-----------------------------------------------------------------------------
; SaveVgaPlanes                                               0F4A:0004  94 PC
; Copies the four VGA planes (plane0..plane3 blocks) through the read map.
;-----------------------------------------------------------------------------
SaveVgaPlanes:
        enter 0x6, 0x0
        push si
        push 0x80
        push 0x0
        push word 0xb00
        push word 0xa1e
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave0Off], ax
        mov [VgaSave0Seg], dx
        push 0x80
        push 0x0
        push word 0xb00
        push word 0xa26
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave1Off], ax
        mov [VgaSave1Seg], dx
        push 0x80
        push 0x0
        push word 0xb00
        push word 0xa2e
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave2Off], ax
        mov [VgaSave2Seg], dx
        push 0x80
        push 0x0
        push word 0xb00
        push word 0xa36
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [VgaSave3Off], ax
        mov [VgaSave3Seg], dx
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xf0
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xfc
        out dx, al
        push word 0xb00
        push word 0xa000
        push 0x0
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        db 0x8B, 0xC6                           ; insn: mov ax, si
        inc ax
        mov dx, 0x3cf
        out dx, al
        push word 0xb00
        push word 0xa000
        push 0x0
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x2]
        mov dx, 0x3cf
        out dx, al
        push word 0xb00
        push word 0xa000
        push 0x0
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        lea ax, [si + 0x3]
        mov dx, 0x3cf
        out dx, al
        push word 0xb00
        push word 0xa000
        push 0x0
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        call 0x0000:_fmemcpy
        add sp, 0xa
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x2]
        cbw
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x4
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x1]
        cbw
        mov dx, 0x3cf
        out dx, al
        mov ax, 0xd
        mov dx, 0x3d4
        out dx, al
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov dx, 0x3d5
        out dx, al
        mov ax, 0x33
        mov dx, 0x3c0
        out dx, al
        in al, dx
        and ax, 0xf0
        out dx, al
        push word 0xc7
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, 0x7570
        mov es, [DgroupSegB]
        mov [bp - 0x6], bx
        mov [bp - 0x4], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .1
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.1:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xc8
        push word 0x140
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        push word 0xc8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        call 0x0FEF:UseCurrentPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:UseOtherPage
        push 0x0
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        call 0x0FEF:CopyPlane
.2:
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; RestoreVgaPlanes                                            0F4A:0224  94 PC
; Writes the four planes back through the map mask.
;-----------------------------------------------------------------------------
RestoreVgaPlanes:
        enter 0x6, 0x0
        push si
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov dx, 0x3c5
        in al, dx
        mov [bp - 0x1], al
        and ax, 0xf0
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov dx, 0x3cf
        in al, dx
        mov [bp - 0x2], al
        and ax, 0xfc
        out dx, al
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        inc ax
        mov dx, 0x3c5
        out dx, al
        push word 0xb00
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word 0xa000
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave0Seg]
        push word [VgaSave0Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x2]
        mov dx, 0x3c5
        out dx, al
        push word 0xb00
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word 0xa000
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave1Seg]
        push word [VgaSave1Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x4]
        mov dx, 0x3c5
        out dx, al
        push word 0xb00
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word 0xa000
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave2Seg]
        push word [VgaSave2Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        lea ax, [si + 0x8]
        mov dx, 0x3c5
        out dx, al
        push word 0xb00
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:RawBase
        add sp, 0x4
        push dx
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push dx
        push ax
        push word 0xa000
        push 0x0
        call 0x0000:_fmemcpy
        add sp, 0xa
        push word [VgaSave3Seg]
        push word [VgaSave3Off]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        mov ax, 0x2
        mov dx, 0x3c4
        out dx, al
        mov al, [bp - 0x1]
        cbw
        mov dx, 0x3c5
        out dx, al
        mov ax, 0x5
        mov dx, 0x3ce
        out dx, al
        mov al, [bp - 0x2]
        cbw
        mov dx, 0x3cf
        out dx, al
        push word 0xa8
        call 0x0FEF:SetStartPage
        add sp, 0x2
        mov bx, 0x7570
        mov es, [DgroupSegB]
        mov [bp - 0x6], bx
        mov [bp - 0x4], es
        mov ax, [es:bx + 0x2]
        or ax, [es:bx]
        jz short .1
        push word [es:bx + 0x2]
        push word [es:bx]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [bp - 0x6]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2], ax
        mov [es:bx], ax
.1:
        push 0x0
        push 0x2
        push 0x4
        push word 0xc8
        push word 0x140
        push word 0xb0
        push word 0x148
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        call 0x0FEF:GetPage
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        call 0x0FEF:CopyPlane
.2:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; NullFar5                                                    0F4A:03E2  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar5:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FatalError                                                  0F4A:03E4  94 PC
; Prints the message with ConPrint and exits.
;-----------------------------------------------------------------------------
FatalError:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0x6]
        call 0x03A3:ConPrint
        db 0x8B
