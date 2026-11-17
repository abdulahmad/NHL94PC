; Text drawing: string width, text colours, and shadowed text (plain, centred, buffered).

;-----------------------------------------------------------------------------
; NullFar3                                                    0D39:0000  94 PC
; A lone retf.
;-----------------------------------------------------------------------------
NullFar3:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; TextWidthFar                                                0D39:0002  94 PC
; Copies a far string and returns TextWidthAll of it.
;-----------------------------------------------------------------------------
TextWidthFar:
        enter 0x52, 0x0
        push word [bp + 0x8]
        push word [bp + 0x6]
        lea ax, [bp - 0x52]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x52]
        push ax
        call 0x03A3:TextWidthAll
        leave
        retf

;-----------------------------------------------------------------------------
; SetTextColors                                               0D39:0024  94 PC
; Text colour and shadow colour.
;-----------------------------------------------------------------------------
SetTextColors:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov [TextColor], ax
        mov ax, [bp + 0x8]
        mov [ShadowColor], ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawShadowTextBuffered                                      0D39:0036  94 PC
; Draws a shadowed string into an off-screen block 64-pixel aligned, then
; blits it.
;-----------------------------------------------------------------------------
DrawShadowTextBuffered:
        enter 0x92, 0x0
        push di
        push si
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x92]
        push ss
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        lea ax, [bp - 0x92]
        push ax
        call 0x03A3:TextWidthAll
        add sp, 0x2
        db 0x8B, 0xF8                           ; insn: mov di, ax
        and di, -0x40
        add di, 0x40
        db 0x8B, 0xC7                           ; insn: mov ax, di
        les bx, [FontPtr]
        mov dx, [es:bx + 0xe]
        inc dx
        db 0x2B, 0xDB                           ; insn: sub bx, bx
        call 0x152D:AllocCanvas
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0x2], dx
        lea ax, [bp - 0x40]
        push ax
        call 0x03A3:SaveTextState
        add sp, 0x2
        mov ax, [bp - 0x2]
        push ax
        push si
        db 0x8B, 0xF8                           ; insn: mov di, ax
        call 0x0FEF:SetCanvas
        add sp, 0x4
        push word 0xff
        call 0x0FEF:ClearClipRect
        add sp, 0x2
        push word [bp + 0xc]
        push word [bp + 0xa]
        push 0x0
        push 0x0
        push cs
        call DrawShadowText
        add sp, 0x8
        lea ax, [bp - 0x40]
        push ax
        call 0x03A3:LoadTextState
        add sp, 0x2
        push word [bp + 0x8]
        push word [bp + 0x6]
        mov es, di
        push word [es:si + 0x2]
        push word [es:si]
        call 0x0FEF:DrawRawTransAt
        add sp, 0x8
        push di
        push si
        call 0x14ED:FreeCanvas
        add sp, 0x4
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawShadowTextCentered                                      0D39:00E4  94 PC
; X = (320 - width) / 2; shadow at +1,+1 then the text.
;-----------------------------------------------------------------------------
DrawShadowTextCentered:
        enter 0x56, 0x0
        push di
        push si
        mov di, [bp + 0x8]
        mov ax, [bp + 0xa]
        push ax
        push di
        lea cx, [bp - 0x52]
        push ss
        push cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        db 0x8B, 0xC7                           ; insn: mov ax, di
        db 0x8B, 0xD6                           ; insn: mov dx, si
        lea cx, [bp - 0x52]
        push cx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        call 0x03A3:TextWidthAll
        add sp, 0x2
        sub ax, 0x140
        neg ax
        cwd
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ax, [ShadowColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        push di
        push cx
        mov ax, [bp + 0x6]
        inc ax
        push ax
        lea ax, [si + 0x1]
        push ax
        mov [bp - 0x56], cx
        mov [bp - 0x54], di
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        mov ax, [TextColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        push word [bp - 0x54]
        push word [bp - 0x56]
        push word [bp + 0x6]
        push si
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawShadowText                                              0D39:0166  94 PC
; Shadow at +1,+1 in the shadow colour, then the text.
;-----------------------------------------------------------------------------
DrawShadowText:
        enter 0x4, 0x0
        push di
        push si
        mov di, [bp + 0x8]
        mov si, [bp + 0xa]
        mov ax, [ShadowColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        mov ax, [bp + 0xc]
        push ax
        push si
        lea cx, [di + 0x1]
        push cx
        mov cx, [bp + 0x6]
        inc cx
        push cx
        mov [bp - 0x4], si
        mov [bp - 0x2], ax
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        mov ax, [TextColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        push word [bp - 0x2]
        push word [bp - 0x4]
        push di
        push word [bp + 0x6]
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawOutlineText                                             0D39:01B8  94 PC
; The string at the four outline offsets in the shadow colour, then the text.
;-----------------------------------------------------------------------------
DrawOutlineText:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov ax, [ShadowColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov di, [bp + 0xa]
.1:
        push word [bp + 0xc]
        push di
        mov ax, [si + OutlineDy]
        add ax, [bp + 0x8]
        push ax
        mov ax, [si + OutlineDx]
        add ax, [bp + 0x6]
        push ax
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        inc si
        inc si
        cmp si, 0x8
        jl short .1
        mov ax, [TextColor]
        les bx, [FontPtr]
        mov [es:bx], ax
        push word [bp + 0xc]
        push di
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x0FA0:DrawTextFar
        add sp, 0x8
        pop si
        pop di
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawShadowTextF                                             0D39:0210  94 PC
; _sprintf with one argument, then DrawShadowText.
;-----------------------------------------------------------------------------
DrawShadowTextF:
        enter 0x52, 0x0
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x52]
        push ax
        call 0x0000:_sprintf
        add sp, 0x6
        lea ax, [bp - 0x52]
        push ss
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call DrawShadowText
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DrawShadowTextF2                                            0D39:0238  94 PC
; _sprintf with two arguments, then DrawShadowText.
;-----------------------------------------------------------------------------
DrawShadowTextF2:
        enter 0x52, 0x0
        push word [bp + 0xe]
        push word [bp + 0xc]
        push word [bp + 0xa]
        lea ax, [bp - 0x52]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x52]
        push ss
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call DrawShadowText
