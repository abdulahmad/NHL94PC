; The VGA graphics library: canvases and clipping, lines and rectangles, RLE and block shapes,
; palettes, retrace waits and the screen pages.

; Fields of the font header at offset 0 of the font segment (CharSeg); the text routines address them
; through ds. FontCharTable is the table of glyph offsets, one word per character.
FontInk		equ	0x00
FontPaper	equ	0x02
FontLeft	equ	0x04
FontRight	equ	0x06
FontX		equ	0x08
FontY		equ	0x0A
FontRowBytes	equ	0x0C
FontHeight	equ	0x0E
FontAdvance	equ	0x10
FontLineStep	equ	0x12
FontProportional equ	0x14
FontCharTable	equ	0x16

        call 0x0FEF:DrawText
        add sp, 0x6
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; DrawLine                                                    0FEF:000C  94 PC
; Bresenham steps over the row table of the current canvas.
;-----------------------------------------------------------------------------
DrawLine:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x1c
        mov ax, [bp + 0xe]
        lea bx, [bp - 0x1c]
        mov [bx + 0x10], ax
        push bx
        push word [bp + 0xc]
        push word [bp + 0xa]
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:LineClip
        add sp, 0xa
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        lea bx, [bp - 0x1c]
        cmp word [bx + 0xe], 0x0
        jng short .1
        push bx
        call 0x0FEF:DrawLineClipped
        add sp, 0x2
.1:
        leave
        retf

;-----------------------------------------------------------------------------
; SetCanvas                                                   0FEF:0048  94 PC
; Copies a 0x1E-byte canvas record into CurCanvas.
;-----------------------------------------------------------------------------
SetCanvas:
        db 0x8B, 0xD7                           ; insn: mov dx, di
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        lds si, [bx + 0x4]
        mov bx, ss
        mov es, bx
        mov di, 0x74e2
        mov cx, 0xf
        rep movsw
        db 0x8B, 0xFA                           ; insn: mov di, dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov ds, bx
        retf

;-----------------------------------------------------------------------------
; SetClipRect                                                 0FEF:0064  94 PC
; Stores left/right/top/bottom into the CurCanvas clip fields.
;-----------------------------------------------------------------------------
SetClipRect:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [bx + 0x4]
        mov dx, [bx + 0x6]
        mov cx, [bx + 0x8]
        mov bx, [bx + 0xa]
        mov [ClipLeftX], ax
        mov [ClipRightX], dx
        mov [ClipTopY], cx
        mov [ClipBottomY], bx
        shr ax, byte 0x2
        shr dx, byte 0x2
        mov [ClipLeftPlane], ax
        mov [ClipRightPlane], dx
        retf

;-----------------------------------------------------------------------------
; SetClipRectRegs                                             0FEF:008F  94 PC
; Same as SetClipRect, arguments in registers.
;-----------------------------------------------------------------------------
SetClipRectRegs:
        mov [ClipTopY], bx
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov bx, [bx + 0x4]
        mov [ClipBottomY], bx
        mov [ClipLeftX], ax
        mov [ClipRightX], dx
        shr ax, byte 0x2
        shr dx, byte 0x2
        mov [ClipLeftPlane], ax
        mov [ClipRightPlane], dx
        retf 0x2
        db 0x00

;-----------------------------------------------------------------------------
; ClearClipRect                                               0FEF:00B4  94 PC
; Fills the clip rectangle with colour 0.
;-----------------------------------------------------------------------------
ClearClipRect:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [bx + 0x4]

ClearClipRectColor:
        push ax
        mov dx, [ClipBottomY]
        mov bx, [ClipTopY]
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        jng short .1
        mov ax, [ClipRightX]
        mov cx, [ClipLeftX]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        jng short .1
        push dx
        push ax
        push bx
        push cx
        call 0x0FEF:FillRect
        add sp, 0xa
.1:
        retf

;-----------------------------------------------------------------------------
; FillRectClip                                                0FEF:00DE  94 PC
; Fills a rectangle clipped to the canvas.
;-----------------------------------------------------------------------------
FillRectClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x2
        push si
        push di
        mov dx, [ClipLeftX]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        sub ax, [bp + 0x6]
        jng short .1
        mov [bp + 0x6], dx
        sub [bp + 0xa], ax
        jng short .4
.1:
        mov ax, [bp + 0x6]
        add ax, [bp + 0xa]
        sub ax, [ClipRightX]
        jng short .2
        sub [bp + 0xa], ax
        jng short .4
.2:
        mov ax, [ClipTopY]
        sub ax, [bp + 0x8]
        jng short .3
        sub [bp + 0xc], ax
        jng short .4
        mov ax, [ClipTopY]
        mov [bp + 0x8], ax
.3:
        mov ax, [bp + 0x8]
        add ax, [bp + 0xc]
        mov bx, [ClipBottomY]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short FillRect.1
        sub [bp + 0xc], ax
        jng short .4
        jmp short FillRect.1
.4:
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; FillRect                                                    0FEF:0136  94 PC
; Fills a rectangle without clipping.
;-----------------------------------------------------------------------------
FillRect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x2
        push si
        push di
.1:
        cld
        cmp word [bp + 0xa], 0x0
        jng short FillRectClip.4
        cmp word [bp + 0xc], 0x0
        jng short FillRectClip.4
        mov ax, [CanvasSeg]
        cmp ax, 0xa000
        jnz short .3
        mov es, ax
        mov dx, 0x3c4
        mov bx, [bp + 0x8]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [CanvasRows]
        mov [bp - 0x2], bx
.2:
        mov cx, [bp + 0xa]
        mov bx, [bp + 0x6]
        mov si, [bp + 0xe]
        mov di, [bp - 0x2]
        mov di, [di]
        call FillSpanVga
        add word [bp - 0x2], 0x2
        dec word [bp + 0xc]
        jg short .2
        pop di
        pop si
        leave
        retf
.3:
        mov si, [bp + 0x8]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov ax, [bp + 0xe]
.4:
        mov cx, [bp + 0xa]
        mov bx, [bp + 0x6]
        mov di, [si]
        call FillSpanLinear
        add si, 0x2
        dec word [bp + 0xc]
        jg short .4
        pop di
        pop si
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; UseCurrentPage                                              0FEF:01A6  94 PC
; Points CurCanvas at the page in CurPage.
;-----------------------------------------------------------------------------
UseCurrentPage:
        mov bx, [CurPage]
        mov [DrawPage], bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov ax, [bx + PageTableSeg]
        push ax
        mov ax, [bx + PageTable]
        push ax
        call 0x0FEF:SetCanvas
        add sp, 0x4
        retf
        db 0x00

;-----------------------------------------------------------------------------
; DrawText                                                    0FEF:01C6  94 PC
; Draws a string with the 1-bpp font.
;-----------------------------------------------------------------------------
DrawText:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push ds
        push si
        push di
        mov ds, [CharSeg]
        mov ax, [bp + 0x8]
        mov [FontX], ax
        mov ax, [bp + 0xa]
        mov [FontY], ax
        jmp short DrawTextAt.1

;-----------------------------------------------------------------------------
; DrawTextAt                                                  0FEF:01E1  94 PC
; DrawText entry taking x,y.
;-----------------------------------------------------------------------------
DrawTextAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push ds
        push si
        push di
        mov ds, [CharSeg]
.1:
        cld
        mov es, [ss:CanvasSeg]
.2:
        mov si, [bp + 0x6]
        mov bl, [ss:si]
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jz short .4
        db 0x8A, 0xC3                           ; insn: mov al, bl
        inc word [bp + 0x6]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, FontCharTable
        mov si, [bx]
        cmp si, 0x0
        jnz short .5
        cmp al, 0xd
        jz short .3
        cmp al, 0xa
        jnz short .2
.3:
        mov ax, [FontLeft]
        mov [FontX], ax
        mov ax, [FontLineStep]
        add [FontY], ax
        jmp short .2
.4:
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        mov ax, [FontX]
        mov [bp - 0x2], ax
        cmp byte [FontProportional], 0x0
        jz short .6
        mov al, [si]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        inc si
        mov [FontAdvance], ax
        add ax, 0x7
        shr ax, 1
        shr ax, 1
        shr ax, 1
        mov [FontRowBytes], al
.6:
        mov [bp - 0xc], si
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        mov [bp - 0x6], ax
        and bx, 0x3
        mov ax, es
        cmp ax, 0xa000
        jz short .7
        jmp near .17
.7:
        mov ah, [ss:bx + FontBits]
        mov [bp - 0x9], ah
        mov word [bp - 0x8], 0x8008
.8:
        mov si, [bp - 0xc]
        mov dx, 0x3c4
        mov al, 0x2
        out dx, ax
        mov dx, [bp - 0x8]
        mov al, [FontInk]
        mov ah, [FontPaper]
        mov cx, [FontHeight]
        mov [bp - 0x4], cx
        mov bx, [FontY]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [ss:CanvasRows]
.9:
        mov di, [ss:bx]
        add di, [bp - 0x6]
        mov cl, [FontRowBytes]
.10:
        mov ch, [si]
        inc si
        test dh, ch
        jz short .15
        stosb
        test dl, ch
        jz short .16
.11:
        stosb
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .10
.12:
        add bx, 0x2
        dec word [bp - 0x4]
        jg short .9
        shr dx, 1
        jc short .14
        mov [bp - 0x8], dx
        mov ah, [bp - 0x9]
        rol ah, 1
        jnc short .13
        inc word [bp - 0x6]
.13:
        mov [bp - 0x9], ah
        jmp short .8
.14:
        mov ax, [FontAdvance]
        add [FontX], ax
        jmp near .2
.15:
        inc di
        test dl, ch
        jnz short .11
.16:
        inc di
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .10
        jmp short .12
.17:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov es, [ss:bx + CanvasSeg]
        mov [bp - 0xe], bx
        mov dx, 0x8008
.18:
        mov si, [bp - 0xc]
        mov al, [FontInk]
        mov ah, [FontPaper]
        mov cx, [FontHeight]
        mov [bp - 0x4], cx
        mov bx, [FontY]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [ss:CanvasRows]
.19:
        mov di, [ss:bx]
        add di, [bp - 0x6]
        mov cl, [FontRowBytes]
.20:
        mov ch, [si]
        inc si
        test dh, ch
        jz short .25
        stosb
        test dl, ch
        jz short .26
.21:
        stosb
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .20
.22:
        add bx, 0x2
        dec word [bp - 0x4]
        jg short .19
        shr dx, 1
        jc short .24
        mov bx, [bp - 0xe]
        add bx, 0x2
        test bx, 0x8
        jz short .23
        inc word [bp - 0x6]
        and bx, 0x3
.23:
        mov es, [ss:bx + CanvasSeg]
        mov [bp - 0xe], bx
        jmp short .18
.24:
        jmp near .14
.25:
        inc di
        test dl, ch
        jnz short .21
.26:
        inc di
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .20
        jmp short .22

;-----------------------------------------------------------------------------
; GetPaletteFar                                               0FEF:0366  94 PC
; Reads DAC registers through port 3C7h/3C9h into a far buffer.
;-----------------------------------------------------------------------------
GetPaletteFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        les di, [bp + 0xa]
        mov dx, 0x3c7
        mov ax, [bp + 0x6]
        out dx, al
        mov bx, [bp + 0x8]
        mov dx, 0x3c9
        cmp word [ss:Cpu286], 0x0
        jz short .2
.1:
        mov cx, 0x3
        rep insb
        dec bx
        jg short .1
        pop di
        leave
        retf
.2:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x03, 0xCB                           ; insn: add cx, bx
        db 0x03, 0xCB                           ; insn: add cx, bx
.3:
        in al, dx
        stosb
        loop .3
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; InitGraphics                                                0FEF:039A  94 PC
; Sets mode 13h and unchains it.
;-----------------------------------------------------------------------------
InitGraphics:
        push di
        push bp
        mov word [WantText], 0x6
        call 0x03A3:SaveMode
        mov ax, 0x40
        mov es, ax
        mov ax, [es:BiosEquipment]
        and ax, -0x31
        or ax, 0x10
        mov [es:BiosEquipment], ax
        mov ah, 0xb
        mov bx, 0x0
        int 0x10
        mov ax, 0x13
        int 0x10
        call 0x0FEF:UnchainVga
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov bx, 0x2
        mov cx, 0xc8
        mov dx, 0x140
        push ax
        push bx
        push ax
        push cx
        push dx
        push cx
        push dx
        call 0x0FEF:AllocCanvases
        add sp, 0xe
        call 0x0FEF:UseCurrentPage
        pop bp
        pop di
        retf
        db 0x00

;-----------------------------------------------------------------------------
; LoadAsset0                                                  0FEF:03EE  94 PC
; LoadAssetMode with mode 0.
;-----------------------------------------------------------------------------
LoadAsset0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp short LoadAsset.1

;-----------------------------------------------------------------------------
; LoadAsset                                                   0FEF:03F5  94 PC
; LoadAssetMode with mode 1.
;-----------------------------------------------------------------------------
LoadAsset:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x1
.1:
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x15A6:LoadAssetMode
        add sp, 0x6
        leave
        retf

;-----------------------------------------------------------------------------
; LoadAssetHeader                                             0FEF:040C  94 PC
; LoadAssetMode mode 1, returns the first dword.
;-----------------------------------------------------------------------------
LoadAssetHeader:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x1
        jmp short LoadAssetHeaderMode.1

;-----------------------------------------------------------------------------
; LoadAssetHeader0                                            0FEF:0414  94 PC
; LoadAssetMode mode 0, returns the first dword.
;-----------------------------------------------------------------------------
LoadAssetHeader0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp short LoadAssetHeaderMode.1

;-----------------------------------------------------------------------------
; LoadAssetHeaderMode                                         0FEF:041B  94 PC
; LoadAssetMode with explicit mode, returns the first dword.
;-----------------------------------------------------------------------------
LoadAssetHeaderMode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0xa]
.1:
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x15A6:LoadAssetMode
        add sp, 0x6
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jz short .2
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, [es:bx]
        mov dx, [es:bx + 0x2]
.2:
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; SetRemapTable                                               0FEF:0442  94 PC
; Copies 256 bytes into the remap table.
;-----------------------------------------------------------------------------
SetRemapTable:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        mov ax, ds
        mov es, ax
        mov di, RemapTable
        lds si, [bp + 0x6]
        cld
        mov cx, 0x80
        rep movsw
        pop di
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; GetRemapTable                                               0FEF:045D  94 PC
; Copies the remap table out.
;-----------------------------------------------------------------------------
GetRemapTable:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        les di, [bp + 0x6]
        mov si, RemapTable
        cld
        mov cx, 0x80
        rep movsw
        pop di
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SetRemapRange                                               0FEF:0474  94 PC
; Writes a range of remap entries.
;-----------------------------------------------------------------------------
SetRemapRange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        mov cx, [bp + 0x8]
        lds si, [bp + 0xa]
        mov ax, ss
        mov es, ax
        mov di, RemapTable
        add di, [bp + 0x6]
        cld
        rep movsb
        pop di
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; PutBlock                                                    0FEF:0492  94 PC
; Raw block copy to the canvas, hotspot entry.
;-----------------------------------------------------------------------------
PutBlock:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short PutBlockBody.1

;-----------------------------------------------------------------------------
; PutBlockAt                                                  0FEF:04B5  94 PC
; PutBlock at x,y.
;-----------------------------------------------------------------------------
PutBlockAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short PutBlockBody.1

;-----------------------------------------------------------------------------
; PutBlockBody                                                0FEF:04D2  94 PC
; PutBlock body.
;-----------------------------------------------------------------------------
PutBlockBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        mov byte [bp - 0x25], 0x0
        mov bx, [bp - 0xa]
        mov cx, [si + 0x2]
        lea di, [si + 0x10]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc byte [bp - 0x25]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        inc byte [bp - 0x25]
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [si]
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x18], di
        mov [bp - 0x10], cx
        mov [bp - 0xa], bx
        mov cx, [si]
        mov [bp - 0x6], cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov [bp - 0x22], dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .8
        inc byte [bp - 0x25]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .8
.5:
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
.6:
        jng short .2
        inc byte [bp - 0x25]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x2B, 0xF8                           ; insn: sub di, ax
        mov [bp - 0x22], di
        shr di, 1
        shr di, 1
        add [bp - 0x18], di
        mov di, [ss:ClipRightX]
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jng short .6
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .7
        db 0x8B, 0xC7                           ; insn: mov ax, di
.7:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.8:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .6
        mov [bp - 0x8], dx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov [bp - 0x12], ax
        cmp byte [bp - 0x25], 0x0
        jnz short .9
        jmp near DrawRawBody.1
.9:
        cld
        mov ax, [si]
        mul word [si + 0x2]
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov dl, [si + 0xf]
        shr dl, 1
        shr dl, 1
        shr dl, 1
        shr dl, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov [bp - 0x1c], ax
        and word [bp - 0x22], 0x3
        mov ax, [bp - 0x22]
        neg ax
        mov [bp - 0x20], ax
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        mov [bp - 0xc], di
        and bx, 0x3
        mov [bp - 0x1e], bx
        add bx, [bp - 0x20]
        and bx, 0x3
        mov word [bp - 0x1a], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .10
        jmp near .14
.10:
        mov es, ax
        mov ah, [ss:bx + PutBlockMasks]
        mov [bp - 0x13], ah
        mov [bp - 0x14], bl
.11:
        mov ah, [bp - 0x13]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov ah, [bp - 0x14]
        mov al, 0x4
        mov dx, 0x3ce
        out dx, ax
        mov di, [bp - 0xc]
        mov dx, [bp - 0x20]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .13
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        add ax, [bp - 0x22]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x18]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0x10]
.12:
        mov cx, [bp - 0x4]
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x03, 0xF2                           ; insn: add si, dx
        dec ax
        jg short .12
.13:
        inc word [bp - 0x20]
        mov ax, [bp - 0x1c]
        add [bp - 0x18], ax
        inc byte [bp - 0x14]
        and byte [bp - 0x14], 0x3
        rol byte [bp - 0x13], 1
        dec word [bp - 0x1a]
        jg short .11
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x24], bx
.15:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xc]
        mov dx, [bp - 0x20]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .17
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        add ax, [bp - 0x22]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x18]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0x10]
.16:
        mov cx, [bp - 0x4]
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x03, 0xF2                           ; insn: add si, dx
        dec ax
        jg short .16
.17:
        inc word [bp - 0x20]
        mov ax, [bp - 0x1c]
        add [bp - 0x18], ax
        mov bx, [bp - 0x24]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x24], bx
        dec word [bp - 0x1a]
        jg short .15
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; DrawRaw                                                     0FEF:071A  94 PC
; Raw planar shape, hotspot entry.
;-----------------------------------------------------------------------------
DrawRaw:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short DrawRawBody.1

;-----------------------------------------------------------------------------
; DrawRawAt                                                   0FEF:073D  94 PC
; DrawRaw at x,y.
;-----------------------------------------------------------------------------
DrawRawAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short DrawRawBody.1

;-----------------------------------------------------------------------------
; DrawRawBody                                                 0FEF:075A  94 PC
; DrawRaw body.
;-----------------------------------------------------------------------------
DrawRawBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x26
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        cld
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, [si + 0xf]
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        mov [bp - 0x1c], ax
        mov ax, [si + 0x2]
        mov [bp - 0x10], ax
        mov ax, [si]
        mov [bp - 0x4], ax
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        mov [bp - 0x12], bx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        mov [bp - 0x2], ax
        and bx, 0x3
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .5
        mov es, ax
        mov ah, [ss:bx + DrawRawMasks]
        mov [bp - 0x13], ah
        mov [bp - 0x14], bl
        add si, 0x10
        mov word [bp - 0x1a], 0x4
.2:
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov ah, [bp - 0x14]
        mov al, 0x4
        mov dx, 0x3ce
        out dx, ax
        mov bx, [bp - 0xa]
        shl bx, 1
        add bx, [ss:CanvasRows]
        mov di, [ss:bx]
        add di, [bp - 0x2]
        mov dx, [bp - 0x10]
        mov bx, [bp - 0x12]
.3:
        mov cx, [bp - 0x4]
        rep movsb
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .3
        inc byte [bp - 0x14]
        mov ah, [bp - 0x13]
        rol ah, 1
        jnc short .4
        inc word [bp - 0x2]
        and byte [bp - 0x14], 0x3
.4:
        mov [bp - 0x13], ah
        dec word [bp - 0x1a]
        jg short .2
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        db 0x03, 0xDB                           ; insn: add bx, bx
        add si, 0x10
        mov word [bp - 0x1a], 0x4
.6:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        add di, [bp - 0x2]
        mov ax, [bp - 0x10]
        mov dx, [bp - 0x12]
.7:
        mov cx, [bp - 0x4]
        rep movsb
        db 0x03, 0xFA                           ; insn: add di, dx
        dec ax
        jg short .7
        add bx, 0x2
        and bx, 0x6
        jnz short .8
        inc word [bp - 0x2]
.8:
        add si, [bp - 0x1c]
        dec word [bp - 0x1a]
        jg short .6
        pop di
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; DrawRle                                                     0FEF:085C  94 PC
; RLE shape (runs, literals, 0 ends plane), clipped.
;-----------------------------------------------------------------------------
DrawRle:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleBody.1

;-----------------------------------------------------------------------------
; DrawRleAt                                                   0FEF:087F  94 PC
; DrawRle at x,y.
;-----------------------------------------------------------------------------
DrawRleAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleBody.1

;-----------------------------------------------------------------------------
; DrawRleBody                                                 0FEF:089C  94 PC
; DrawRle body.
;-----------------------------------------------------------------------------
DrawRleBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        mov word [bp - 0x10], 0x4
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x4]
        mov cx, [si + 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc di
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        inc di
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x1c], cx
        mov [bp - 0x4], bx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        mov [bp - 0x16], dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, [bp - 0x6]
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .7
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        inc di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .7
.5:
        inc di
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x2B, 0xF0                           ; insn: sub si, ax
        add [bp - 0x16], si
        mov si, [ss:ClipRightX]
        db 0x2B, 0xF3                           ; insn: sub si, bx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jl short .6
        db 0x8B, 0xC6                           ; insn: mov ax, si
.6:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.7:
        mov [bp - 0x14], dx
        mov [bp - 0x2], bx
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        jmp 0x0FEF:DrawRleFastBody
.8:
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        add ax, [ss:di]
        mov [bp - 0xe], ax
        and bx, 0x3
        mov [bp - 0x20], bx
        mov ax, [bp - 0x16]
        neg ax
        mov [bp - 0x22], ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        and bx, 0x3
        mov word [bp - 0x10], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .9
        jmp near .32
.9:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x12], bx
.10:
        mov bx, [bp - 0x12]
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .12
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .15
.11:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .13
        jl short .14
        jmp short .17
.12:
        jmp near .29
.13:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .15
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .20
.14:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .15
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .25
.15:
        mov dx, [bp - 0x1a]
.16:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .24
.17:
        inc word [bp - 0x22]
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x12], bx
        dec word [bp - 0x10]
        jng short .18
        jmp near .10
.18:
        pop di
        pop si
        pop ds
        leave
        retf
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.20:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
        rep stosb
        jmp short .16
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .29
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .16
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .16
.22:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.23:
        jmp near .11
.24:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.25:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .26
        rep movsb
        jmp short .16
.26:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        dec word [bp - 0x8]
        jng short .28
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .22
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .26
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .27
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
.27:
        jmp near .16
.28:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.29:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .30
        jl short .31
        jmp near .17
.30:
        inc si
        jmp short .29
.31:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .29
.32:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleMasks]
        mov [bp - 0x17], ah
.33:
        mov ah, [bp - 0x17]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .35
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .38
.34:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .36
        jl short .37
        jmp short .40
.35:
        jmp near .52
.36:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .34
        jz short .38
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .43
.37:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .34
        jz short .38
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .48
.38:
        mov dx, [bp - 0x1a]
.39:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .42
        jl short .47
.40:
        inc word [bp - 0x22]
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jng short .41
        jmp near .33
.41:
        pop di
        pop si
        pop ds
        leave
        retf
.42:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.43:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .44
        rep stosb
        jmp short .39
.44:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .52
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .46
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .44
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .39
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .39
.45:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.46:
        jmp near .34
.47:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.48:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .49
        rep movsb
        jmp short .39
.49:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        dec word [bp - 0x8]
        jng short .51
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .45
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .49
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .50
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
.50:
        jmp near .39
.51:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.52:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .53
        jl short .54
        jmp near .40
.53:
        inc si
        jmp short .52
.54:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .52

;-----------------------------------------------------------------------------
; DrawRleFast                                                 0FEF:0C22  94 PC
; RLE shape without clipping.
;-----------------------------------------------------------------------------
DrawRleFast:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleFastHere.1

;-----------------------------------------------------------------------------
; DrawRleFastAt                                               0FEF:0C45  94 PC
; DrawRleFast at x,y.
;-----------------------------------------------------------------------------
DrawRleFastAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleFastHere.1

;-----------------------------------------------------------------------------
; DrawRleFastHere                                             0FEF:0C62  94 PC
; DrawRleFast at the shape's own +8/+0A position.
;-----------------------------------------------------------------------------
DrawRleFastHere:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        mov [bp - 0x8], ax
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        mov word [bp - 0x10], 0x4

DrawRleFastBody:
        mov ax, [bp - 0x6]
        mov dx, [ss:CanvasRowBytes]
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        mov [bp - 0xc], dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        sar dx, 1
        sar dx, 1
        mov [bp - 0x2], dx
        and bx, 0x3
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        add ax, [ss:di]
        mov [bp - 0xe], ax
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .1
        cmp word [bp - 0xc], 0x0
        jz short .3
        jmp short .8
.1:
        cmp word [bp - 0xc], 0x0
        jz short .2
        jmp near .22
.2:
        jmp near .16
.3:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
.4:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.5:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .6
        jl short .7
        add bx, 0x2
        dec word [bp - 0x10]
        jg short .4
        pop di
        pop si
        pop ds
        leave
        retf
.6:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        rep stosb
        jmp short .5
.7:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        rep movsb
        jmp short .5
.8:
        mov si, [bp - 0xa]
        mov dx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
.9:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.10:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .12
        jl short .14
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        jnz short .11
        inc word [bp - 0xe]
.11:
        dec word [bp - 0x10]
        jg short .9
        pop di
        pop si
        pop ds
        leave
        retf
.12:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .13
        rep stosb
        jmp short .10
.13:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .13
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .10
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .10
.14:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .15
        rep movsb
        jmp short .10
.15:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .15
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .10
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        jmp short .10
.16:
        mov si, [bp - 0xa]
        mov es, [ss:CanvasSeg]
        mov dx, 0x3c4
        mov byte [bp - 0x17], 0x1
.17:
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
.18:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .20
        jl short .21
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jg short .17
.19:
        pop di
        pop si
        pop ds
        leave
        retf
.20:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        rep stosb
        jmp short .18
.21:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        rep movsb
        jmp short .18
.22:
        mov si, [bp - 0xa]
        mov es, [ss:CanvasSeg]
        mov ah, [ss:bx + DrawRleFastMasks]
        mov [bp - 0x17], ah
.23:
        mov dx, 0x3c4
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x6]
.24:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .26
        jl short .28
        rol byte [bp - 0x17], 1
        jnc short .25
        inc word [bp - 0xe]
.25:
        dec word [bp - 0x10]
        jg short .23
        jmp short .19
.26:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .27
        rep stosb
        jmp short .24
.27:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .27
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .24
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .24
.28:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .29
        rep movsb
        jmp short .24
.29:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .29
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .24
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        jmp short .24

;-----------------------------------------------------------------------------
; DrawText2                                                   0FEF:0E5E  94 PC
; Second font text routine.
;-----------------------------------------------------------------------------
DrawText2:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x10
        push ds
        push si
        push di
        mov ax, [bp + 0x6]
        mov [Text2Color], al
        mov ax, 0x7438
        mov [bp + 0x6], ax
        mov ds, [CharSeg]
        mov ax, [bp + 0x8]
        mov [FontX], ax
        mov ax, [bp + 0xa]
        mov [FontY], ax
        jmp short DrawChar.1

;-----------------------------------------------------------------------------
; DrawChar                                                    0FEF:0E85  94 PC
; Single character for DrawText2.
;-----------------------------------------------------------------------------
DrawChar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x10
        push ds
        push si
        push di
        mov ds, [CharSeg]
        mov ax, [bp + 0x8]
        mov [FontX], ax
        mov ax, [bp + 0xa]
        mov [FontY], ax
        jmp short .1
LeftMasks:                                      ; byte masks with the top 0 to 8 bits set; the DrawChar body
                                                ; indexes it by the width of the glyph's last byte
        db 0x00, 0x80, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC, 0xFE, 0xFF
;-----------------------------------------------------------------------------
; DrawCharSame                                                0FEF:0EA9  94 PC
; The DrawChar prologue again, then the shared body. Not called in the EXE.
;-----------------------------------------------------------------------------
DrawCharSame:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x10
        push ds
        push si
        push di
        mov ds, [CharSeg]
DrawChar.1:
        cld
        mov es, [ss:CanvasSeg]
.2:
        mov si, [bp + 0x6]
        mov bl, [ss:si]
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jz short .4
        db 0x8A, 0xC3                           ; insn: mov al, bl
        inc word [bp + 0x6]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, FontCharTable
        mov si, [bx]
        cmp si, 0x0
        jnz short .5
        cmp al, 0xd
        jz short .3
        cmp al, 0xa
        jnz short .2
.3:
        mov ax, [FontLeft]
        mov [FontX], ax
        mov ax, [FontLineStep]
        add [FontY], ax
        jmp short .2
.4:
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        mov ax, [FontX]
        mov [bp - 0x2], ax
        cmp byte [FontProportional], 0x0
        jz short .6
        mov al, [si]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        inc si
        mov [FontAdvance], ax
        add ax, 0x7
        shr ax, 1
        shr ax, 1
        shr ax, 1
        mov [FontRowBytes], al
.6:
        mov [bp - 0xc], si
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        mov [bp - 0x6], ax
        and bx, 0x3
        mov ax, es
        cmp ax, 0xa000
        jz short .7
        jmp near .20
.7:
        mov ah, [ss:bx + DrawCharMasks]
        mov [bp - 0x9], ah
        mov word [bp - 0x8], 0x8008
.8:
        mov si, [bp - 0xc]
        mov dx, 0x3c4
        mov al, 0x2
        out dx, ax
        mov dx, [bp - 0x8]
        mov al, [FontInk]
        mov ah, [FontPaper]
        mov cx, [FontHeight]
        mov [bp - 0x4], cx
        mov bx, [FontY]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [ss:CanvasRows]
.9:
        mov di, [ss:bx]
        add di, [bp - 0x6]
        mov cl, [FontRowBytes]
.10:
        push bx
        mov bx, 0x8
        cmp cl, 0x1
        jnz short .11
        mov bx, [FontAdvance]
        dec bx
        and bx, 0x7
        inc bx
.11:
        mov bl, [cs:bx + LeftMasks]
        mov [bp - 0xf], bl
        pop bx
        mov ch, [si]
        inc si
        test dh, ch
        jz short .17
        stosb
        test dl, ch
        jz short .18
.12:
        stosb
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .10
.13:
        add bx, 0x2
        dec word [bp - 0x4]
        jg short .9
        shr dx, 1
        jc short .15
        mov [bp - 0x8], dx
        mov ah, [bp - 0x9]
        rol ah, 1
        jnc short .14
        inc word [bp - 0x6]
.14:
        mov [bp - 0x9], ah
        jmp short .8
.15:
        mov ax, [FontAdvance]
        add [FontX], ax
        jmp near .2
.16:
        add di, 0x2
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .10
        jmp short .13
.17:
        test [bp - 0xf], dh
        jz short .16
        mov [es:di], ah
        inc di
        test dl, ch
        jnz short .12
.18:
        test [bp - 0xf], dl
        jz short .19
        mov [es:di], ah
.19:
        inc di
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .10
        jmp short .13
.20:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov es, [ss:bx + CanvasSeg]
        mov [bp - 0xe], bx
        mov dx, 0x8008
.21:
        mov si, [bp - 0xc]
        mov al, [FontInk]
        mov ah, [FontPaper]
        mov cx, [FontHeight]
        mov [bp - 0x4], cx
        mov bx, [FontY]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [ss:CanvasRows]
.22:
        mov di, [ss:bx]
        add di, [bp - 0x6]
        mov cl, [FontRowBytes]
.23:
        push bx
        mov bx, 0x8
        cmp cl, 0x1
        jnz short .24
        mov bx, [FontAdvance]
        dec bx
        and bx, 0x7
        inc bx
.24:
        mov bl, [cs:bx + LeftMasks]
        mov [bp - 0xf], bl
        pop bx
        mov ch, [si]
        inc si
        test dh, ch
        jz short .30
        stosb
        test dl, ch
        jz short .31
.25:
        stosb
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .23
.26:
        add bx, 0x2
        dec word [bp - 0x4]
        jg short .22
        shr dx, 1
        jc short .28
        mov bx, [bp - 0xe]
        add bx, 0x2
        test bx, 0x8
        jz short .27
        and bx, 0x6
        inc word [bp - 0x6]
.27:
        mov es, [ss:bx + CanvasSeg]
        mov [bp - 0xe], bx
        jmp short .21
.28:
        jmp near .15
.29:
        add di, 0x2
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .23
        jmp short .26
.30:
        test [bp - 0xf], dh
        jz short .29
        mov [es:di], ah
        inc di
        test dl, ch
        jnz short .25
.31:
        test [bp - 0xf], dl
        jz short .32
        mov [es:di], ah
.32:
        inc di
        db 0x32, 0xED                           ; insn: xor ch, ch
        loop .23
        jmp short .26

;-----------------------------------------------------------------------------
; CopyPlaneA                                                  0FEF:1096  94 PC
; CopyPlane entry.
;-----------------------------------------------------------------------------
CopyPlaneA:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [CurPage]
        jmp short CopyPlane.2

;-----------------------------------------------------------------------------
; CopyPlaneB                                                  0FEF:109F  94 PC
; CopyPlane entry.
;-----------------------------------------------------------------------------
CopyPlaneB:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [bp + 0x6]
        jmp short CopyPlane.1

;-----------------------------------------------------------------------------
; CopyPlane                                                   0FEF:10A7  94 PC
; Copies one VGA plane between buffers.
;-----------------------------------------------------------------------------
CopyPlane:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, [CurPage]
        and bx, 0x1
        xor bx, 0x1
.1:
        mov [CurPage], bx
.2:
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov es, [bx + PageTableSeg]
        mov bx, [bx + PageTable]
        cmp byte [CopyActive], 0x0
        jnz short .4
        mov bx, [es:bx]
        db 0x8A, 0xE7                           ; insn: mov ah, bh
.3:
        mov al, 0xc
        mov dx, 0x40
        mov es, dx
        mov dx, [es:BiosCrtcPort]
        out dx, ax
        mov [es:BiosPageStart], bx
        mov byte [CopyActive], 0x0
        mov word [HoldWord], 0x0
        leave
        retf
.4:
        mov ax, [CopyCount]
        mov dl, [CopyMask]
        add ax, [es:bx]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp al, [CopySrcPage]
        jnz short .5
        cmp dl, [CopyDstPage]
        jz short .3
.5:
        mov [CopySrcPage], al
        mov dx, 0x40
        mov es, dx
        mov [es:BiosPageStart], bx
        mov dx, [es:BiosCrtcPort]
        add dl, 0x6
        cmp word [CopyOffset], 0x0
        jnz short .11
        db 0x33, 0xC9                           ; insn: xor cx, cx
.6:
        in al, dx
        test al, 0x8
        jz short .6
.7:
        in al, dx
        test al, 0x8
        jnz short .7
.8:
        inc cx
        jz short .10
        in al, dx
        test al, 0x8
        jz short .8
.9:
        inc cx
        jz short .10
        in al, dx
        test al, 0x8
        jnz short .9
.10:
        shr cx, 1
        mov [CopyOffset], cx
.11:
        in al, dx
        test al, 0x8
        jz short .11
        mov cx, [CopyOffset]
.12:
        in al, dx
        dec cx
        jz short .13
        test al, 0x8
        jmp short .12
.13:
        sub dl, 0x6
        cli
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        mov al, 0xc
        out dx, ax
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        inc al
        out dx, ax
        mov cl, [CopyMask]
        cmp cl, [CopyDstPage]
        jz short .15
        mov [CopyDstPage], cl
        add dl, 0x6
.14:
        in al, dx
        test al, 0x8
        jz short .14
        cli
        mov dl, 0xc0
        mov al, 0x33
        out dx, al
        db 0x8A, 0xC1                           ; insn: mov al, cl
        out dx, al
.15:
        sti
        mov word [HoldWord], 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; UseOtherPage                                                0FEF:118C  94 PC
; Points CurCanvas at the page not shown.
;-----------------------------------------------------------------------------
UseOtherPage:
        mov bx, [CurPage]
        and bx, 0x1
        xor bx, 0x1
        mov [DrawPage], bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov ax, [bx + PageTable]
        mov dx, [bx + PageTableSeg]
        push dx
        push ax
        call 0x0FEF:SetCanvas
        add sp, 0x4
        retf

;-----------------------------------------------------------------------------
; GetPage                                                     0FEF:11B1  94 PC
; Returns CurPage.
;-----------------------------------------------------------------------------
GetPage:
        mov ax, [CurPage]
        retf

;-----------------------------------------------------------------------------
; GetOtherPage                                                0FEF:11B5  94 PC
; Returns the other page index.
;-----------------------------------------------------------------------------
GetOtherPage:
        mov ax, [DrawPage]
        retf
        db 0x00

;-----------------------------------------------------------------------------
; GetBlock                                                    0FEF:11BA  94 PC
; Reads a block from the canvas, hotspot entry.
;-----------------------------------------------------------------------------
GetBlock:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov di, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [di + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [di + 0x6]
        mov [bp - 0x4], ax
        jmp short GetBlockBody.1

;-----------------------------------------------------------------------------
; GetBlockAt                                                  0FEF:11DD  94 PC
; GetBlock at x,y.
;-----------------------------------------------------------------------------
GetBlockAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov di, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov [di + 0x8], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        mov [di + 0xa], ax
        jmp short GetBlockBody.1

;-----------------------------------------------------------------------------
; GetBlockBody                                                0FEF:1200  94 PC
; GetBlock body.
;-----------------------------------------------------------------------------
GetBlockBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov di, [bp + 0x6]
        mov ax, [di + 0x8]
        mov [bp - 0x2], ax
        mov ax, [di + 0xa]
        mov [bp - 0x4], ax
.1:
        mov ax, [di]
        mov [bp - 0x8], ax
        mov ax, [di + 0x2]
        mov [bp - 0xa], ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, [di + 0xf]
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        mov [bp - 0xc], ax
        mov bx, [bp - 0x4]
        shl bx, 1
        add bx, [ss:CanvasRows]
        mov [bp - 0x6], bx
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .4
        mov ds, ax
        mov es, [bp + 0x8]
        add di, 0x10
        cld
        mov word [bp - 0xe], 0x4
.2:
        mov dx, 0x3ce
        mov bx, [bp - 0x2]
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        and ah, 0x3
        mov al, 0x4
        out dx, ax
        shr bx, 1
        shr bx, 1
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, [bp - 0xa]
        mov bx, [bp - 0x6]
.3:
        mov si, [ss:bx]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov cx, [bp - 0x8]
        rep movsb
        add bx, 0x2
        dec dx
        jg short .3
        add di, [bp - 0xc]
        inc word [bp - 0x2]
        dec word [bp - 0xe]
        jg short .2
        pop di
        pop si
        pop ds
        leave
        retf
.4:
        mov es, [bp + 0x8]
        add di, 0x10
        cld
        mov word [bp - 0xe], 0x4
.5:
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov ds, [ss:bx + CanvasSeg]
        shr ax, 1
        shr ax, 1
        mov dx, [bp - 0xa]
        mov bx, [bp - 0x6]
.6:
        mov si, [ss:bx]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov cx, [bp - 0x8]
        rep movsb
        add bx, 0x2
        dec dx
        jg short .6
        add di, [bp - 0xc]
        inc word [bp - 0x2]
        dec word [bp - 0xe]
        jg short .5
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; GetPixel                                                    0FEF:12DA  94 PC
; Reads one pixel through the read map register.
;-----------------------------------------------------------------------------
GetPixel:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov ax, [CanvasSeg]
        cmp ax, 0xa000
        jnz short .2
        mov es, ax
        mov bx, [bp + 0x6]
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        and ah, 0x3
        mov al, 0x4
        mov dx, 0x3ce
        out dx, ax
.1:
        shr bx, 1
        shr bx, 1
        mov si, [bp + 0x8]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        add bx, [si]
        mov al, [es:bx]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        pop di
        pop si
        leave
        retf
.2:
        mov bx, [bp + 0x6]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        and si, 0x3
        db 0x03, 0xF6                           ; insn: add si, si
        mov es, [si + CanvasSeg]
        jmp short .1
        db 0x00

;-----------------------------------------------------------------------------
; SetStartPage                                                0FEF:1320  94 PC
; Writes the CRTC start address for a page.
;-----------------------------------------------------------------------------
SetStartPage:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov [PageBase], ax
        mov ax, 0x40
        mov es, ax
        mov dx, [es:BiosCrtcPort]
        mov ax, [bp + 0x6]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x8A, 0xFC                           ; insn: mov bh, ah
        db 0x8A, 0xDF                           ; insn: mov bl, bh
        and bx, 0x201
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x02, 0xFF                           ; insn: add bh, bh
        db 0x8A, 0xE0                           ; insn: mov ah, al
        mov al, 0x18
        out dx, ax
        mov al, 0x7
        out dx, al
        inc dx
        in al, dx
        dec dx
        db 0x8A, 0xE0                           ; insn: mov ah, al
        and ah, 0xef
        db 0x0A, 0xE3                           ; insn: or ah, bl
        mov al, 0x7
        out dx, ax
        mov al, 0x9
        out dx, al
        inc dx
        in al, dx
        dec dx
        db 0x8A, 0xE0                           ; insn: mov ah, al
        and ah, 0xbf
        db 0x0A, 0xE7                           ; insn: or ah, bh
        mov al, 0x9
        out dx, ax
        mov dx, 0x3da
        in al, dx
        mov dx, 0x3c0
        mov al, 0x30
        out dx, al
        mov al, 0x61
        out dx, al
        leave
        retf

;-----------------------------------------------------------------------------
; UseOffscreenCanvas                                          0FEF:137E  94 PC
; Points CurCanvas at the off-screen buffer.
;-----------------------------------------------------------------------------
UseOffscreenCanvas:
        mov ax, [OffscreenOff]
        mov dx, [OffscreenSeg]
        push dx
        push ax
        call 0x0FEF:SetCanvas
        add sp, 0x4
        retf

;-----------------------------------------------------------------------------
; DrawRawTrans                                                0FEF:1390  94 PC
; Raw shape, colour FF transparent, hotspot entry.
;-----------------------------------------------------------------------------
DrawRawTrans:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short DrawRawTransBody.1

;-----------------------------------------------------------------------------
; DrawRawTransAt                                              0FEF:13B0  94 PC
; DrawRawTrans at x,y.
;-----------------------------------------------------------------------------
DrawRawTransAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short DrawRawTransBody.1

;-----------------------------------------------------------------------------
; DrawRawTransBody                                            0FEF:13CA  94 PC
; DrawRawTrans body.
;-----------------------------------------------------------------------------
DrawRawTransBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        mov byte [bp - 0x23], 0x0
        mov bx, [bp - 0xa]
        mov cx, [si + 0x2]
        lea di, [si + 0x10]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc byte [bp - 0x23]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        inc byte [bp - 0x23]
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [si]
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x14], di
        mov [bp - 0xe], cx
        mov [bp - 0xa], bx
        mov cx, [si]
        mov [bp - 0x6], cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov [bp - 0x1e], dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .8
        inc byte [bp - 0x23]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .8
.5:
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
.6:
        jng short .2
        inc byte [bp - 0x23]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x2B, 0xF8                           ; insn: sub di, ax
        mov [bp - 0x1e], di
        shr di, 1
        shr di, 1
        add [bp - 0x14], di
        mov di, [ss:ClipRightX]
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jng short .6
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .7
        db 0x8B, 0xC7                           ; insn: mov ax, di
.7:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.8:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .6
        mov [bp - 0x8], dx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov [bp - 0x10], ax
        cmp byte [bp - 0x23], 0x0
        jnz short .9
        jmp near DrawRawFastBody.1
.9:
        cld
        mov ax, [si]
        mul word [si + 0x2]
        push dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov dl, [si + 0xf]
        shr dl, 1
        shr dl, 1
        shr dl, 1
        shr dl, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        pop dx
        mov [bp - 0x18], ax
        and word [bp - 0x1e], 0x3
        mov ax, [bp - 0x1e]
        neg ax
        mov [bp - 0x1c], ax
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        mov [bp - 0xc], di
        and bx, 0x3
        mov [bp - 0x1a], bx
        add bx, [bp - 0x1c]
        and bx, 0x3
        mov word [bp - 0x16], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .10
        jmp near .17
.10:
        mov es, ax
        mov ah, [ss:bx + DrawRawTransMasks]
        mov [bp - 0x11], ah
.11:
        mov al, 0x2
        mov ah, [bp - 0x11]
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xc]
        mov dx, [bp - 0x1c]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1a]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .15
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x14]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
.12:
        mov cx, [bp - 0x4]
.13:
        lodsb
        cmp al, 0xff
        jz short .16
        stosb
        loop .13
.14:
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x03, 0xF2                           ; insn: add si, dx
        dec word [bp - 0x22]
        jg short .12
.15:
        inc word [bp - 0x1c]
        mov ax, [bp - 0x18]
        add [bp - 0x14], ax
        rol byte [bp - 0x11], 1
        dec word [bp - 0x16]
        jg short .11
        pop di
        pop si
        pop ds
        leave
        retf
.16:
        inc di
        loop .13
        jmp short .14
.17:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x20], bx
.18:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xc]
        mov dx, [bp - 0x1c]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1a]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .22
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x14]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
.19:
        mov cx, [bp - 0x4]
.20:
        lodsb
        cmp al, 0xff
        jz short .23
        stosb
        loop .20
.21:
        db 0x03, 0xFB                           ; insn: add di, bx
        db 0x03, 0xF2                           ; insn: add si, dx
        dec word [bp - 0x22]
        jg short .19
.22:
        inc word [bp - 0x1c]
        mov ax, [bp - 0x18]
        add [bp - 0x14], ax
        mov bx, [bp - 0x20]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x20], bx
        dec word [bp - 0x16]
        jg short .18
        pop di
        pop si
        pop ds
        leave
        retf
.23:
        inc di
        loop .20
        jmp short .21
        db 0x00

;-----------------------------------------------------------------------------
; DrawRleFlip                                                 0FEF:1612  94 PC
; Mirrored RLE shape.
;-----------------------------------------------------------------------------
DrawRleFlip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si]
        add ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipHere.1

;-----------------------------------------------------------------------------
; DrawRleFlipAt                                               0FEF:1637  94 PC
; DrawRleFlip at x,y.
;-----------------------------------------------------------------------------
DrawRleFlipAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipHere.1

;-----------------------------------------------------------------------------
; DrawRleFlipHere                                             0FEF:1654  94 PC
; DrawRleFlip at the shape's own position.
;-----------------------------------------------------------------------------
DrawRleFlipHere:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        mov [bp - 0x8], ax
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax

DrawRleFlipBody:
        std
        mov word [bp - 0x10], 0x4
        mov dx, [ss:CanvasRowBytes]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        mov [bp - 0xc], dx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [bp - 0x2]
        dec bx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        sar dx, 1
        sar dx, 1
        mov [bp - 0x2], dx
        and bx, 0x3
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        add ax, [ss:di]
        mov [bp - 0xe], ax
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .1
        jmp near .15
.1:
        mov si, [bp - 0xa]
        mov dx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
.2:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.3:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .5
        jl short .9
        mov bx, [bp - 0x12]
        sub bx, 0x2
        jnl short .4
        dec word [bp - 0xe]
        and bx, 0x6
.4:
        dec word [bp - 0x10]
        jg short .2
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
        cmp al, 0xff
        jz short .7
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .6
        rep stosb
        jmp short .3
.6:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .6
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .3
.7:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .8
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .3
.8:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .8
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .3
.9:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .12
.10:
        mov al, [si]
        inc si
        stosb
        loop .10
.11:
        jmp short .3
.12:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.13:
        mov al, [si]
        inc si
        stosb
        loop .13
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .12
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .11
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.14:
        mov al, [si]
        inc si
        stosb
        loop .14
        jmp near .3
.15:
        mov si, [bp - 0xa]
        mov es, [ss:CanvasSeg]
        mov ah, [ss:bx + DrawRleFlipMasks]
        mov [bp - 0x17], ah
.16:
        mov dx, 0x3c4
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x6]
.17:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .23
        ror byte [bp - 0x17], 1
        jnc short .18
        dec word [bp - 0xe]
.18:
        dec word [bp - 0x10]
        jg short .16
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
        cmp al, 0xff
        jz short .21
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .20
        rep stosb
        jmp short .17
.20:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .20
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .17
.21:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .22
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .17
.22:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .22
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .17
.23:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .26
.24:
        mov al, [si]
        inc si
        stosb
        loop .24
.25:
        jmp short .17
.26:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.27:
        mov al, [si]
        inc si
        stosb
        loop .27
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .26
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .25
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.28:
        mov al, [si]
        inc si
        stosb
        loop .28
        jmp near .17

;-----------------------------------------------------------------------------
; DrawRleTrans                                                0FEF:1834  94 PC
; RLE shape, run byte FF transparent, clipped.
;-----------------------------------------------------------------------------
DrawRleTrans:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleTransBody.1

;-----------------------------------------------------------------------------
; DrawRleTransAt                                              0FEF:1857  94 PC
; DrawRleTrans at x,y.
;-----------------------------------------------------------------------------
DrawRleTransAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleTransBody.1

;-----------------------------------------------------------------------------
; DrawRleTransBody                                            0FEF:1874  94 PC
; DrawRleTrans body.
;-----------------------------------------------------------------------------
DrawRleTransBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x4]
        mov cx, [si + 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc di
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        inc di
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x1c], cx
        mov [bp - 0x4], bx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        mov [bp - 0x16], dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, [bp - 0x6]
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .7
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        inc di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .7
.5:
        inc di
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x2B, 0xF0                           ; insn: sub si, ax
        add [bp - 0x16], si
        mov si, [ss:ClipRightX]
        db 0x2B, 0xF3                           ; insn: sub si, bx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jl short .6
        db 0x8B, 0xC6                           ; insn: mov ax, si
.6:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.7:
        mov [bp - 0x14], dx
        mov [bp - 0x2], bx
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        jmp 0x0FEF:DrawRleTransFastBody
.8:
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        add ax, [ss:di]
        mov [bp - 0xe], ax
        and bx, 0x3
        mov [bp - 0x20], bx
        mov ax, [bp - 0x16]
        neg ax
        mov [bp - 0x22], ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        and bx, 0x3
        mov word [bp - 0x10], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .9
        jmp near .35
.9:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x12], bx
.10:
        mov bx, [bp - 0x12]
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .14
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .17
.11:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .15
        jl short .16
.12:
        inc word [bp - 0x22]
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x12], bx
        dec word [bp - 0x10]
        jng short .13
        jmp short .10
.13:
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        jmp near .32
.15:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .20
.16:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .28
.17:
        mov dx, [bp - 0x1a]
.18:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .27
        jmp short .12
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.20:
        cmp al, 0xff
        jz short .24
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
        rep stosb
        jmp short .18
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .26
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .18
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .18
.22:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.23:
        jmp near .11
.24:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .25
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .18
.25:
        db 0x03, 0xFB                           ; insn: add di, bx
        dec word [bp - 0x8]
.26:
        jng short .32
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .25
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .18
.27:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.28:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .29
        rep movsb
        jmp short .18
.29:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        dec word [bp - 0x8]
        jng short .31
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .22
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .29
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .30
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
.30:
        jmp near .18
.31:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.32:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .33
        jl short .34
        jmp near .12
.33:
        inc si
        jmp short .32
.34:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .32
.35:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleTransMasks]
        mov [bp - 0x17], ah
.36:
        mov ah, [bp - 0x17]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .38
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .41
.37:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .39
        jl short .40
        jmp short .43
.38:
        jmp near .58
.39:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .37
        jz short .41
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .46
.40:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .37
        jz short .41
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp near .54
.41:
        mov dx, [bp - 0x1a]
.42:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .45
        jl short .53
.43:
        inc word [bp - 0x22]
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jng short .44
        jmp near .36
.44:
        pop di
        pop si
        pop ds
        leave
        retf
.45:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.46:
        cmp al, 0xff
        jz short .50
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .47
        rep stosb
        jmp short .42
.47:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .52
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .49
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .47
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .42
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .42
.48:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.49:
        jmp near .37
.50:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .51
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .42
.51:
        db 0x03, 0xFB                           ; insn: add di, bx
        dec word [bp - 0x8]
.52:
        jng short .58
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .49
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .51
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .42
.53:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.54:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .55
        rep movsb
        jmp near .42
.55:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        dec word [bp - 0x8]
        jng short .57
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .48
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .55
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .56
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
.56:
        jmp near .42
.57:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.58:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .59
        jl short .60
        jmp near .43
.59:
        inc si
        jmp short .58
.60:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .58

;-----------------------------------------------------------------------------
; DrawRleTransFast                                            0FEF:1C4E  94 PC
; Transparent RLE without clipping.
;-----------------------------------------------------------------------------
DrawRleTransFast:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleTransFastHere.1

;-----------------------------------------------------------------------------
; DrawRleTransFastAt                                          0FEF:1C71  94 PC
; DrawRleTransFast at x,y.
;-----------------------------------------------------------------------------
DrawRleTransFastAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleTransFastHere.1

;-----------------------------------------------------------------------------
; DrawRleTransFastHere                                        0FEF:1C8E  94 PC
; DrawRleTransFast at the shape's own position.
;-----------------------------------------------------------------------------
DrawRleTransFastHere:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax

DrawRleTransFastBody:
        mov dx, [ss:CanvasRowBytes]
        sub dx, [bp - 0x6]
        mov [bp - 0xc], dx
        mov word [bp - 0x10], 0x4
        mov bx, [bp - 0x2]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        sar dx, 1
        sar dx, 1
        mov [bp - 0x2], dx
        and bx, 0x3
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        add ax, [ss:di]
        mov [bp - 0xe], ax
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .1
        cmp word [bp - 0xc], 0x0
        jz short .3
        jmp short .9
.1:
        cmp word [bp - 0xc], 0x0
        jz short .2
        jmp near .26
.2:
        jmp near .19
.3:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
.4:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.5:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .6
        jl short .8
        add bx, 0x2
        dec word [bp - 0x10]
        jg short .4
        pop di
        pop si
        pop ds
        leave
        retf
.6:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .7
        rep stosb
        jmp short .5
.7:
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .5
.8:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        rep movsb
        jmp short .5
.9:
        mov si, [bp - 0xa]
        mov dx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
.10:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.11:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .13
        jl short .17
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        jnz short .12
        inc word [bp - 0xe]
.12:
        dec word [bp - 0x10]
        jg short .10
        pop di
        pop si
        pop ds
        leave
        retf
.13:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .15
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .14
        rep stosb
        jmp short .11
.14:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .14
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .11
.15:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .16
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .11
.16:
        db 0x03, 0xFB                           ; insn: add di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .16
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .11
.17:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .18
        rep movsb
        jmp short .11
.18:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .18
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        jmp near .11
.19:
        mov si, [bp - 0xa]
        mov es, ax
        mov dx, 0x3c4
        mov byte [bp - 0x17], 0x1
.20:
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
.21:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .23
        jl short .25
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jg short .20
.22:
        pop di
        pop si
        pop ds
        leave
        retf
.23:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .24
        rep stosb
        jmp short .21
.24:
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .21
.25:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        rep movsb
        jmp short .21
.26:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleTransFastMasks]
        mov [bp - 0x17], ah
.27:
        mov dx, 0x3c4
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x6]
.28:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .30
        jl short .34
        rol byte [bp - 0x17], 1
        jnc short .29
        inc word [bp - 0xe]
.29:
        dec word [bp - 0x10]
        jg short .27
        jmp short .22
.30:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .32
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .31
        rep stosb
        jmp short .28
.31:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .31
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .28
.32:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .33
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .28
.33:
        db 0x03, 0xFB                           ; insn: add di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .33
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .28
.34:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .35
        rep movsb
        jmp short .28
.35:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .35
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep movsb
        jmp near .28

;-----------------------------------------------------------------------------
; DrawRawTransRemap                                           0FEF:1EC6  94 PC
; Transparent raw shape through the remap table.
;-----------------------------------------------------------------------------
DrawRawTransRemap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short DrawRawTransRemapBody.1

;-----------------------------------------------------------------------------
; DrawRawTransRemapAt                                         0FEF:1EE9  94 PC
; DrawRawTransRemap at x,y.
;-----------------------------------------------------------------------------
DrawRawTransRemapAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short DrawRawTransRemapBody.1

;-----------------------------------------------------------------------------
; DrawRawTransRemapBody                                       0FEF:1F06  94 PC
; DrawRawTransRemap body.
;-----------------------------------------------------------------------------
DrawRawTransRemapBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        mov byte [bp - 0x23], 0x0
        mov bx, [bp - 0xa]
        mov cx, [si + 0x2]
        lea di, [si + 0x10]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc byte [bp - 0x23]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        inc byte [bp - 0x23]
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [si]
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x14], di
        mov [bp - 0xe], cx
        mov [bp - 0xa], bx
        mov cx, [si]
        mov [bp - 0x6], cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov [bp - 0x1e], dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .8
        inc byte [bp - 0x23]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .8
.5:
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
.6:
        jng short .2
        inc byte [bp - 0x23]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        db 0x2B, 0xF8                           ; insn: sub di, ax
        mov [bp - 0x1e], di
        shr di, 1
        shr di, 1
        add [bp - 0x14], di
        mov di, [ss:ClipRightX]
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jng short .6
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jl short .7
        db 0x8B, 0xC7                           ; insn: mov ax, di
.7:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.8:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jng short .6
        mov [bp - 0x8], dx
        cmp byte [bp - 0x23], 0x0
        jnz short .9
        jmp near DrawRawTransFastBody.1
.9:
        cld
        mov ax, [si]
        mul word [si + 0x2]
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov dl, [si + 0xf]
        shr dl, 1
        shr dl, 1
        shr dl, 1
        shr dl, 1
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov [bp - 0x18], ax
        and word [bp - 0x1e], 0x3
        mov ax, [bp - 0x1e]
        neg ax
        mov [bp - 0x1c], ax
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        mov [bp - 0xc], di
        and bx, 0x3
        mov [bp - 0x1a], bx
        add bx, [bp - 0x1c]
        and bx, 0x3
        mov word [bp - 0x16], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .10
        jmp near .17
.10:
        mov es, ax
        mov ah, [ss:bx + DrawRawTransRemapMasks]
        mov [bp - 0x11], ah
.11:
        mov al, 0x2
        mov ah, [bp - 0x11]
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xc]
        mov dx, [bp - 0x1c]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1a]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .15
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        mov [bp - 0x10], bx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x14]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
        db 0x32, 0xFF                           ; insn: xor bh, bh
.12:
        mov cx, [bp - 0x4]
.13:
        lodsb
        cmp al, 0xff
        jz short .16
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .13
.14:
        add di, [bp - 0x10]
        db 0x03, 0xF2                           ; insn: add si, dx
        dec word [bp - 0x22]
        jg short .12
.15:
        inc word [bp - 0x1c]
        mov ax, [bp - 0x18]
        add [bp - 0x14], ax
        rol byte [bp - 0x11], 1
        dec word [bp - 0x16]
        jg short .11
        pop di
        pop si
        pop ds
        leave
        retf
.16:
        inc di
        loop .13
        jmp short .14
.17:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x20], bx
.18:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xc]
        mov dx, [bp - 0x1c]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x1a]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add dx, [bp - 0x8]
        shr dx, 1
        shr dx, 1
        mov cx, [bp - 0x6]
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jng short .22
        mov [bp - 0x4], cx
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD9                           ; insn: sub bx, cx
        mov [bp - 0x10], bx
        add ax, [bp - 0x1e]
        shr ax, 1
        shr ax, 1
        mov si, [bp - 0x14]
        db 0x03, 0xF0                           ; insn: add si, ax
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
        db 0x32, 0xFF                           ; insn: xor bh, bh
.19:
        mov cx, [bp - 0x4]
.20:
        lodsb
        cmp al, 0xff
        jz short .23
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .20
.21:
        add di, [bp - 0x10]
        db 0x03, 0xF2                           ; insn: add si, dx
        dec word [bp - 0x22]
        jg short .19
.22:
        inc word [bp - 0x1c]
        mov ax, [bp - 0x18]
        add [bp - 0x14], ax
        mov bx, [bp - 0x20]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x20], bx
        dec word [bp - 0x16]
        jg short .18
        pop di
        pop si
        pop ds
        leave
        retf
.23:
        inc di
        loop .20
        jmp short .21
        db 0x00

;-----------------------------------------------------------------------------
; DrawRleTransRemap                                           0FEF:2160  94 PC
; Transparent RLE through the remap table, clipped.
;-----------------------------------------------------------------------------
DrawRleTransRemap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleTransRemapHere.1

;-----------------------------------------------------------------------------
; DrawRleTransRemapAt                                         0FEF:2183  94 PC
; DrawRleTransRemap at x,y.
;-----------------------------------------------------------------------------
DrawRleTransRemapAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleTransRemapHere.1

;-----------------------------------------------------------------------------
; DrawRleTransRemapHere                                       0FEF:21A0  94 PC
; DrawRleTransRemap at the shape's own position.
;-----------------------------------------------------------------------------
DrawRleTransRemapHere:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax

DrawRleTransRemapBody:
        mov dx, [ss:CanvasRowBytes]
        sub dx, [bp - 0x6]
        mov [bp - 0xc], dx
        mov word [bp - 0x10], 0x4
        mov bx, [bp - 0x2]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        sar dx, 1
        sar dx, 1
        mov [bp - 0x2], dx
        and bx, 0x3
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        add ax, [ss:di]
        mov [bp - 0xe], ax
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jz short .1
        cmp word [bp - 0xc], 0x0
        jz short .3
        jmp short .10
.1:
        cmp word [bp - 0xc], 0x0
        jz short .2
        jmp near .32
.2:
        jmp near .24
.3:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
.4:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        db 0x32, 0xFF                           ; insn: xor bh, bh
.5:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .6
        jl short .8
        mov bx, [bp - 0x12]
        add bx, 0x2
        dec word [bp - 0x10]
        jg short .4
        pop di
        pop si
        pop ds
        leave
        retf
.6:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .7
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        rep stosb
        jmp short .5
.7:
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .5
.8:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.9:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .9
        jmp short .5
.10:
        mov si, [bp - 0xa]
        mov dx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
.11:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.12:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .14
        jl short .18
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        jnz short .13
        inc word [bp - 0xe]
.13:
        dec word [bp - 0x10]
        jg short .11
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .16
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .15
        rep stosb
        jmp short .12
.15:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .15
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .12
.16:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .17
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .12
.17:
        db 0x03, 0xFB                           ; insn: add di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .17
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .12
.18:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
.19:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .19
.20:
        jmp near .12
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.22:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .22
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .20
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.23:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .23
        jmp near .12
.24:
        mov si, [bp - 0xa]
        mov es, ax
        mov dx, 0x3c4
        mov byte [bp - 0x17], 0x1
        db 0x32, 0xFF                           ; insn: xor bh, bh
.25:
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
.26:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .28
        jl short .30
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jg short .25
.27:
        pop di
        pop si
        pop ds
        leave
        retf
.28:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .29
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        rep stosb
        jmp short .26
.29:
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .26
.30:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.31:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .31
        jmp short .26
.32:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleTransRemapMasks]
        mov [bp - 0x17], ah
.33:
        mov dx, 0x3c4
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x6]
.34:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .36
        jl short .40
        rol byte [bp - 0x17], 1
        jnc short .35
        inc word [bp - 0xe]
.35:
        dec word [bp - 0x10]
        jg short .33
        jmp short .27
.36:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        cmp al, 0xff
        jz short .38
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .37
        rep stosb
        jmp short .34
.37:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .37
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .34
.38:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .39
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .34
.39:
        db 0x03, 0xFB                           ; insn: add di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .39
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .34
.40:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .43
.41:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .41
.42:
        jmp short .34
.43:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.44:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .44
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .43
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .42
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.45:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .45
        jmp near .34
        db 0x00

;-----------------------------------------------------------------------------
; DrawRleFlipTrans                                            0FEF:245C  94 PC
; Mirrored transparent RLE.
;-----------------------------------------------------------------------------
DrawRleFlipTrans:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si]
        add ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipTransBody.1

;-----------------------------------------------------------------------------
; DrawRleFlipTransAt                                          0FEF:2481  94 PC
; DrawRleFlipTrans at x,y.
;-----------------------------------------------------------------------------
DrawRleFlipTransAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipTransBody.1

;-----------------------------------------------------------------------------
; DrawRleFlipTransBody                                        0FEF:249E  94 PC
; DrawRleFlipTrans body.
;-----------------------------------------------------------------------------
DrawRleFlipTransBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x4]
        mov cx, [si + 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc di
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        inc di
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x1c], cx
        mov [bp - 0x4], bx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        mov [bp - 0x16], dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, [bp - 0x6]
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .7
        add [bp - 0x16], ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        inc di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .7
.5:
        inc di
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x2B, 0xF0                           ; insn: sub si, ax
        mov si, [ss:ClipRightX]
        db 0x2B, 0xF3                           ; insn: sub si, bx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jl short .6
        db 0x8B, 0xC6                           ; insn: mov ax, si
.6:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.7:
        mov [bp - 0x14], dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        jmp 0x0FEF:DrawRleFlipBody
.8:
        std
        db 0x03, 0xD9                           ; insn: add bx, cx
        dec bx
        mov [bp - 0x2], bx
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        add ax, [ss:di]
        mov [bp - 0xe], ax
        and bx, 0x3
        mov [bp - 0x20], bx
        mov ax, [bp - 0x16]
        neg ax
        mov [bp - 0x22], ax
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        and bx, 0x3
        mov word [bp - 0x10], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .9
        jmp near .38
.9:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x12], bx
.10:
        mov bx, [bp - 0x12]
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        mov ax, [bp - 0x20]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .14
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .17
.11:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .15
        jl short .16
.12:
        inc word [bp - 0x22]
        mov bx, [bp - 0x12]
        sub bx, 0x2
        and bx, 0x6
        mov [bp - 0x12], bx
        dec word [bp - 0x10]
        jng short .13
        jmp short .10
.13:
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        jmp near .35
.15:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .20
.16:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .28
.17:
        mov dx, [bp - 0x1a]
.18:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .27
        jmp short .12
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
.20:
        cmp al, 0xff
        jz short .24
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
        rep stosb
        jmp short .18
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .26
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .18
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .18
.22:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.23:
        jmp near .11
.24:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .25
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .18
.25:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        dec word [bp - 0x8]
.26:
        jng short .35
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .25
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .18
.27:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.28:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .30
.29:
        mov al, [si]
        inc si
        stosb
        loop .29
        jmp near .18
.30:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.31:
        mov al, [si]
        inc si
        stosb
        loop .31
        dec word [bp - 0x8]
        jng short .34
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .22
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .30
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .33
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.32:
        mov al, [si]
        inc si
        stosb
        loop .32
.33:
        jmp near .18
.34:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.35:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .36
        jl short .37
        jmp near .12
.36:
        inc si
        jmp short .35
.37:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .35
.38:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleFlipTransMasks]
        mov [bp - 0x17], ah
.39:
        mov ah, [bp - 0x17]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        mov ax, [bp - 0x20]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .41
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .44
.40:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .42
        jl short .43
        jmp short .46
.41:
        jmp near .64
.42:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .44
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .49
.43:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .44
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp near .57
.44:
        mov dx, [bp - 0x1a]
.45:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .48
        jl short .56
.46:
        inc word [bp - 0x22]
        ror byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jng short .47
        jmp near .39
.47:
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.48:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov al, [si]
        inc si
.49:
        cmp al, 0xff
        jz short .53
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .50
        rep stosb
        jmp short .45
.50:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .55
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .50
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .45
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .45
.51:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.52:
        jmp near .40
.53:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .54
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .45
.54:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        dec word [bp - 0x8]
.55:
        jng short .64
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .54
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp near .45
.56:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.57:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .59
.58:
        mov al, [si]
        inc si
        stosb
        loop .58
        jmp near .45
.59:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.60:
        mov al, [si]
        inc si
        stosb
        loop .60
        dec word [bp - 0x8]
        jng short .63
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .51
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .59
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .62
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.61:
        mov al, [si]
        inc si
        stosb
        loop .61
.62:
        jmp near .45
.63:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.64:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .65
        jl short .66
        jmp near .46
.65:
        inc si
        jmp short .64
.66:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .64

;-----------------------------------------------------------------------------
; DrawRleFlipTransRemap                                       0FEF:28A8  94 PC
; Mirrored transparent RLE through the remap table.
;-----------------------------------------------------------------------------
DrawRleFlipTransRemap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov dx, [si]
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        add ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipTransRemapBody.1

;-----------------------------------------------------------------------------
; DrawRleFlipTransRemapAt                                     0FEF:28D3  94 PC
; DrawRleFlipTransRemap at x,y.
;-----------------------------------------------------------------------------
DrawRleFlipTransRemapAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipTransRemapBody.1

;-----------------------------------------------------------------------------
; DrawRleFlipTransRemapBody                                   0FEF:28F0  94 PC
; DrawRleFlipTransRemap body.
;-----------------------------------------------------------------------------
DrawRleFlipTransRemapBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x4]
        mov cx, [si + 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc di
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        inc di
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x1c], cx
        mov [bp - 0x4], bx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        mov [bp - 0x16], dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, [bp - 0x6]
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .7
        add [bp - 0x16], ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        inc di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .7
.5:
        inc di
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x2B, 0xF0                           ; insn: sub si, ax
        mov si, [ss:ClipRightX]
        db 0x2B, 0xF3                           ; insn: sub si, bx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jl short .6
        db 0x8B, 0xC6                           ; insn: mov ax, si
.6:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.7:
        mov [bp - 0x14], dx
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        jmp 0x0FEF:DrawRleFlipRemapBody
.8:
        std
        db 0x03, 0xD9                           ; insn: add bx, cx
        dec bx
        mov [bp - 0x2], bx
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        add ax, [ss:di]
        mov [bp - 0xe], ax
        and bx, 0x3
        mov [bp - 0x20], bx
        mov ax, [bp - 0x16]
        neg ax
        mov [bp - 0x22], ax
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        and bx, 0x3
        mov word [bp - 0x10], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .9
        jmp near .38
.9:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x12], bx
.10:
        mov bx, [bp - 0x12]
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        mov ax, [bp - 0x20]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .14
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .17
.11:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .15
        jl short .16
.12:
        inc word [bp - 0x22]
        mov bx, [bp - 0x12]
        sub bx, 0x2
        and bx, 0x6
        mov [bp - 0x12], bx
        dec word [bp - 0x10]
        jng short .13
        jmp short .10
.13:
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        jmp near .35
.15:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov bl, [si]
        inc si
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .20
.16:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp near .28
.17:
        mov dx, [bp - 0x1a]
.18:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .27
        jmp short .12
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov bl, [si]
        inc si
.20:
        cmp bl, 0xff
        jz short .24
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
        rep stosb
        jmp short .18
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .26
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .18
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .18
.22:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.23:
        jmp near .11
.24:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .25
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .18
.25:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        dec word [bp - 0x8]
.26:
        jng short .35
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .25
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .18
.27:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.28:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .30
.29:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .29
        jmp near .18
.30:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.31:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .31
        dec word [bp - 0x8]
        jng short .34
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .22
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .30
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .33
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.32:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .32
.33:
        jmp near .18
.34:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.35:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .36
        jl short .37
        jmp near .12
.36:
        inc si
        jmp short .35
.37:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .35
.38:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleFlipTransRemapMasks]
        mov [bp - 0x17], ah
.39:
        mov ah, [bp - 0x17]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        mov ax, [bp - 0x20]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .43
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .46
.40:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .44
        jl short .45
.41:
        inc word [bp - 0x22]
        ror byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jng short .42
        jmp short .39
.42:
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.43:
        jmp near .64
.44:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov bl, [si]
        inc si
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .46
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .49
.45:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .46
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp near .57
.46:
        mov dx, [bp - 0x1a]
.47:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .48
        jl short .56
        jmp short .41
.48:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov bl, [si]
        inc si
.49:
        cmp bl, 0xff
        jz short .53
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .50
        rep stosb
        jmp short .47
.50:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .55
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .50
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .47
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .47
.51:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.52:
        jmp near .40
.53:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .54
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .47
.54:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        dec word [bp - 0x8]
.55:
        jng short .64
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .54
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .47
.56:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.57:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .59
.58:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .58
        jmp near .47
.59:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.60:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .60
        dec word [bp - 0x8]
        jng short .63
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .51
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .59
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .62
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.61:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .61
.62:
        jmp near .47
.63:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.64:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .65
        jl short .66
        jmp near .41
.65:
        inc si
        jmp short .64
.66:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .64
        db 0x00

;-----------------------------------------------------------------------------
; DrawRleFlipRemap                                            0FEF:2D34  94 PC
; Mirrored RLE through the remap table.
;-----------------------------------------------------------------------------
DrawRleFlipRemap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov dx, [si]
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        add ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipRemapHere.1

;-----------------------------------------------------------------------------
; DrawRleFlipRemapAt                                          0FEF:2D5F  94 PC
; DrawRleFlipRemap at x,y.
;-----------------------------------------------------------------------------
DrawRleFlipRemapAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleFlipRemapHere.1

;-----------------------------------------------------------------------------
; DrawRleFlipRemapHere                                        0FEF:2D7C  94 PC
; DrawRleFlipRemap at the shape's own position.
;-----------------------------------------------------------------------------
DrawRleFlipRemapHere:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        mov [bp - 0x8], ax
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax

DrawRleFlipRemapBody:
        std
        mov word [bp - 0x10], 0x4
        mov dx, [ss:CanvasRowBytes]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        mov [bp - 0xc], dx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [bp - 0x2]
        dec bx
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        sar dx, 1
        sar dx, 1
        mov [bp - 0x2], dx
        and bx, 0x3
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        add ax, [ss:di]
        mov [bp - 0xe], ax
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .1
        jmp near .15
.1:
        mov si, [bp - 0xa]
        mov dx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
.2:
        mov [bp - 0x12], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
.3:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .5
        jl short .9
        mov bx, [bp - 0x12]
        sub bx, 0x2
        jnl short .4
        dec word [bp - 0xe]
        and bx, 0x6
.4:
        dec word [bp - 0x10]
        jg short .2
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov bl, [si]
        inc si
        cmp bl, 0xff
        jz short .7
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .6
        rep stosb
        jmp short .3
.6:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .6
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .3
.7:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .8
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .3
.8:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .8
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .3
.9:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .12
.10:
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov bl, [si]
        inc si
        mov al, [ss:bx + RemapTable]
        stosb
        loop .10
.11:
        jmp near .3
.12:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.13:
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov bl, [si]
        inc si
        mov al, [ss:bx + RemapTable]
        stosb
        loop .13
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .12
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .11
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.14:
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov bl, [si]
        inc si
        mov al, [ss:bx + RemapTable]
        stosb
        loop .14
        jmp near .3
.15:
        mov si, [bp - 0xa]
        mov es, [ss:CanvasSeg]
        mov ah, [ss:bx + DrawRleFlipRemapMasks]
        mov [bp - 0x17], ah
.16:
        mov dx, 0x3c4
        mov al, 0x2
        mov ah, [bp - 0x17]
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x6]
.17:
        mov al, [si]
        inc si
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .23
        ror byte [bp - 0x17], 1
        jnc short .18
        dec word [bp - 0xe]
.18:
        dec word [bp - 0x10]
        jg short .16
        cld
        pop di
        pop si
        pop ds
        leave
        retf
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov bl, [si]
        inc si
        cmp bl, 0xff
        jz short .21
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .20
        rep stosb
        jmp short .17
.20:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .20
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .17
.21:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .22
        db 0x2B, 0xF9                           ; insn: sub di, cx
        jmp short .17
.22:
        db 0x2B, 0xFB                           ; insn: sub di, bx
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .22
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x2B, 0xFB                           ; insn: sub di, bx
        jmp short .17
.23:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .26
.24:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .24
.25:
        jmp near .17
.26:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.27:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .27
        add di, [bp - 0xc]
        mov bx, [bp - 0x6]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .26
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .25
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.28:
        mov bl, [si]
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .28
        jmp near .17

;-----------------------------------------------------------------------------
; DrawRleTransRemapFast                                       0FEF:2F98  94 PC
; Transparent remapped RLE without clipping.
;-----------------------------------------------------------------------------
DrawRleTransRemapFast:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0x4], ax
        jmp short DrawRleTransRemapFastBody.1

;-----------------------------------------------------------------------------
; DrawRleTransRemapFastAt                                     0FEF:2FBB  94 PC
; DrawRleTransRemapFast at x,y.
;-----------------------------------------------------------------------------
DrawRleTransRemapFastAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0x4], ax
        jmp short DrawRleTransRemapFastBody.1

;-----------------------------------------------------------------------------
; DrawRleTransRemapFastBody                                   0FEF:2FD8  94 PC
; DrawRleTransRemapFast body.
;-----------------------------------------------------------------------------
DrawRleTransRemapFastBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x22
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0x4], ax
.1:
        cld
        lea ax, [si + 0x10]
        mov [bp - 0xa], ax
        mov ax, [si]
        mov [bp - 0x6], ax
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x4]
        mov cx, [si + 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        cmp ax, [ss:ClipTopY]
        jl short .3
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        inc di
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .4
.2:
        pop di
        pop si
        pop ds
        leave
        retf
.3:
        inc di
        mov bx, [ss:ClipTopY]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        xchg ax, cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mul word [bp - 0x6]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipBottomY]
        jng short .4
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
.4:
        mov [bp - 0x1c], cx
        mov [bp - 0x4], bx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        mov [bp - 0x16], dx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov cx, [bp - 0x6]
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        cmp ax, [ss:ClipLeftX]
        jl short .5
        db 0x03, 0xC1                           ; insn: add ax, cx
        sub ax, [ss:ClipRightX]
        jng short .7
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jng short .2
        inc di
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        jmp short .7
.5:
        inc di
        mov bx, [ss:ClipLeftX]
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short .2
        db 0x8B, 0xF1                           ; insn: mov si, cx
        db 0x2B, 0xF0                           ; insn: sub si, ax
        add [bp - 0x16], si
        mov si, [ss:ClipRightX]
        db 0x2B, 0xF3                           ; insn: sub si, bx
        db 0x3B, 0xC6                           ; insn: cmp ax, si
        jl short .6
        db 0x8B, 0xC6                           ; insn: mov ax, si
.6:
        xchg cx, dx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x03, 0xC8                           ; insn: add cx, ax
.7:
        mov [bp - 0x14], dx
        mov [bp - 0x2], bx
        db 0x0B, 0xFF                           ; insn: or di, di
        jnz short .8
        jmp 0x0FEF:DrawRleTransRemapBody
.8:
        mov di, [bp - 0x4]
        shl di, 1
        add di, [ss:CanvasRows]
        mov ax, [bp - 0x2]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr ax, 1
        shr ax, 1
        add ax, [ss:di]
        mov [bp - 0xe], ax
        and bx, 0x3
        mov [bp - 0x20], bx
        mov ax, [bp - 0x16]
        neg ax
        mov [bp - 0x22], ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        and bx, 0x3
        mov word [bp - 0x10], 0x4
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .9
        jmp near .38
.9:
        mov si, [bp - 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov [bp - 0x12], bx
.10:
        mov bx, [bp - 0x12]
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .14
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .17
.11:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .15
        jl short .16
.12:
        inc word [bp - 0x22]
        mov bx, [bp - 0x12]
        add bx, 0x2
        and bx, 0x6
        mov [bp - 0x12], bx
        dec word [bp - 0x10]
        jng short .13
        jmp short .10
.13:
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        jmp near .35
.15:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .20
.16:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .11
        jz short .17
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .28
.17:
        mov dx, [bp - 0x1a]
.18:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .19
        jl short .27
        jmp short .12
.19:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.20:
        cmp al, 0xff
        jz short .24
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .21
        rep stosb
        jmp short .18
.21:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .26
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .21
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .18
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .18
.22:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.23:
        jmp near .11
.24:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .25
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .18
.25:
        db 0x03, 0xFB                           ; insn: add di, bx
        dec word [bp - 0x8]
.26:
        jng short .35
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .23
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .25
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .18
.27:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.28:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .30
.29:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .29
        jmp near .18
.30:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.31:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .31
        dec word [bp - 0x8]
        jng short .34
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .22
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .30
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .33
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.32:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .32
.33:
        jmp near .18
.34:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.35:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .36
        jl short .37
        jmp near .12
.36:
        inc si
        jmp short .35
.37:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .35
.38:
        mov si, [bp - 0xa]
        mov es, ax
        mov ah, [ss:bx + DrawRleTransRemapFastMasks]
        mov [bp - 0x17], ah
.39:
        mov ah, [bp - 0x17]
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov di, [bp - 0xe]
        mov dx, [bp - 0x22]
        and dx, 0x3
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x20]
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [bp - 0x14]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x1e], ax
        mov bx, [bp - 0x6]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        jng short .43
        mov [bp - 0x1a], bx
        mov ax, [ss:CanvasRowBytes]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov [bp - 0xc], ax
        mov ax, [bp - 0x1c]
        mov [bp - 0x8], ax
        add dx, [bp - 0x16]
        shr dx, 1
        shr dx, 1
        jz short .46
.40:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .44
        jl short .45
.41:
        inc word [bp - 0x22]
        rol byte [bp - 0x17], 1
        dec word [bp - 0x10]
        jng short .42
        jmp short .39
.42:
        pop di
        pop si
        pop ds
        leave
        retf
.43:
        jmp near .64
.44:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .46
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .49
.45:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        db 0x03, 0xF1                           ; insn: add si, cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jg short .40
        jz short .46
        db 0x03, 0xF2                           ; insn: add si, dx
        neg dx
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov dx, [bp - 0x1a]
        jmp short .57
.46:
        mov dx, [bp - 0x1a]
.47:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .48
        jl short .56
        jmp short .41
.48:
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
        lodsb
.49:
        cmp al, 0xff
        jz short .53
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .50
        rep stosb
        jmp short .47
.50:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        dec word [bp - 0x8]
        jng short .55
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .50
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .47
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        rep stosb
        jmp short .47
.51:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.52:
        jmp near .40
.53:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .54
        db 0x03, 0xF9                           ; insn: add di, cx
        jmp short .47
.54:
        db 0x03, 0xFB                           ; insn: add di, bx
        dec word [bp - 0x8]
.55:
        jng short .64
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .52
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .54
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        db 0x03, 0xFB                           ; insn: add di, bx
        jmp short .47
.56:
        neg al
        db 0x8A, 0xC8                           ; insn: mov cl, al
        db 0x32, 0xED                           ; insn: xor ch, ch
.57:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jng short .59
.58:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .58
        jmp near .47
.59:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.60:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .60
        dec word [bp - 0x8]
        jng short .63
        add di, [bp - 0xc]
        mov bx, [bp - 0x1e]
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xD3                           ; insn: add dx, bx
        jg short .51
        mov bx, [bp - 0x1a]
        db 0x03, 0xD3                           ; insn: add dx, bx
        jng short .59
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        jng short .62
        db 0x8B, 0xCB                           ; insn: mov cx, bx
.61:
        lodsb
        db 0x8A, 0xD8                           ; insn: mov bl, al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov al, [ss:bx + RemapTable]
        stosb
        loop .61
.62:
        jmp near .47
.63:
        db 0x2B, 0xF2                           ; insn: sub si, dx
.64:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        jg short .65
        jl short .66
        jmp near .41
.65:
        inc si
        jmp short .64
.66:
        neg al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x03, 0xF0                           ; insn: add si, ax
        jmp short .64
        db 0x00

;-----------------------------------------------------------------------------
; WaitRetraceCount                                            0FEF:3406  94 PC
; Waits for N vertical retraces.
;-----------------------------------------------------------------------------
WaitRetraceCount:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [bx + 0x4]

WaitRetraceCountRegs:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov dx, 0x3da
.1:
        in al, dx
        and ax, 0x1
        jz short .1
.2:
        in al, dx
        and al, 0x1
        loopne .2
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        retf

;-----------------------------------------------------------------------------
; WaitRetraceFar                                              0FEF:341E  94 PC
; Far jump to WaitRetrace.
;-----------------------------------------------------------------------------
WaitRetraceFar:
        jmp 0x0FEF:WaitRetrace

;-----------------------------------------------------------------------------
; WaitTimerRetrace                                            0FEF:3423  94 PC
; Waits on the timer tick or the retrace bit of 3DAh.
;-----------------------------------------------------------------------------
WaitTimerRetrace:
        cmp word [MouseActive], 0x0
        jnz short WaitRetraceFar
        call 0x156A:CalibrateRetrace
.calibrated:                                    ; entry after the mouse test and calibration
        mov bx, [RetraceWait]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        jz short WaitTimerRetrace
.1:
        mov dx, 0x3da
        in al, dx
        and ax, 0x1
        jnz short .1
.2:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        push cs
        call WaitRetraceCountRegs
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        retf
        db 0x00

;-----------------------------------------------------------------------------
; SetPaletteFar                                               0FEF:344C  94 PC
; Writes DAC registers from a far buffer.
;-----------------------------------------------------------------------------
SetPaletteFar:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        push ds
        mov dx, 0x3c8
        mov ax, [bx + 0x4]
        out dx, al
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov cx, [bx + 0x6]
        lds si, [bx + 0x8]
        inc dx
        cmp word [ss:PaletteMode], 0x2
        jz short .2
        db 0x8B, 0xD9                           ; insn: mov bx, cx
.1:
        mov cx, 0x3
        rep outsb
        dec bx
        jg short .1
        db 0x8B, 0xF0                           ; insn: mov si, ax
        pop ds
        retf
.2:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xCB                           ; insn: add cx, bx
        rep outsb
        db 0x8B, 0xF0                           ; insn: mov si, ax
        pop ds
        retf
        db 0x00

;-----------------------------------------------------------------------------
; WaitRetraceEnd                                              0FEF:3482  94 PC
; Polls 3DAh bit 3 until clear.
;-----------------------------------------------------------------------------
WaitRetraceEnd:
        mov dx, 0x3da
        cmp word [HoldWord], 0x1
        jg short .3
        jz short .2
.1:
        in al, dx
        test al, 0x8
        jnz short .1
.2:
        in al, dx
        test al, 0x8
        jz short .2
.3:
        retf

;-----------------------------------------------------------------------------
; WaitRetraceStart                                            0FEF:3499  94 PC
; Polls 3DAh bit 3 until set.
;-----------------------------------------------------------------------------
WaitRetraceStart:
        mov dx, 0x3da
.1:
        in al, dx
        test al, 0x8
        jnz short .1
.2:
        in al, dx
        test al, 0x8
        jz short .2
        retf

;-----------------------------------------------------------------------------
; WaitRetrace                                                 0FEF:34A7  94 PC
; Waits for the end then the start of a vertical retrace.
;-----------------------------------------------------------------------------
WaitRetrace:
        mov dx, 0x3da
.1:
        in al, dx
        test al, 0x8
        jz short .1
.2:
        in al, dx
        test al, 0x8
        jnz short .2
        retf

;-----------------------------------------------------------------------------
; InRetrace                                                   0FEF:34B5  94 PC
; Returns 3DAh bit 3.
;-----------------------------------------------------------------------------
InRetrace:
        mov dx, 0x3da
        in al, dx
        and ax, 0x8
        retf
        db 0x00

;-----------------------------------------------------------------------------
; PutPixel                                                    0FEF:34BE  94 PC
; Writes one pixel through the map mask.
;-----------------------------------------------------------------------------
PutPixel:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [bx + 0x4]
        mov dx, [bx + 0x6]
        mov bx, [bx + 0x8]
        jmp short PutPixelAt.1

;-----------------------------------------------------------------------------
; PutPixelAt                                                  0FEF:34CB  94 PC
; PutPixel entry.
;-----------------------------------------------------------------------------
PutPixelAt:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, [bx + 0x4]
        mov dx, [bx + 0x6]
        mov bx, [bx + 0x8]
        cmp ax, [ClipLeftX]
        jl short .3
        cmp ax, [ClipRightX]
        jnl short .3
        cmp dx, [ClipTopY]
        jl short .3
        cmp dx, [ClipBottomY]
        jnl short .3
.1:
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [CanvasRows]
        shr dx, byte 0x2
        add dx, [bx]
        and ax, 0x3
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        cmp word [CanvasSeg], 0xa000
        jnz short .2
        mov es, [CanvasSeg]
        mov ah, [bx + PixelMasks]
        mov al, 0x2
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov dx, 0x3c4
        out dx, ax
        mov [es:bx], cl
        retf
.2:
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov es, [bx + CanvasSeg]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        mov [es:bx], cl
.3:
        retf

;-----------------------------------------------------------------------------
; XorRect                                                     0FEF:352C  94 PC
; XORs a rectangle via RectSpanPlanes.
;-----------------------------------------------------------------------------
XorRect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x2
        push si
        push di
        mov dx, [ClipLeftX]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        sub ax, [bp + 0x6]
        jng short .1
        mov [bp + 0x6], dx
        sub [bp + 0xa], ax
        jng short .4
.1:
        mov ax, [bp + 0x6]
        add ax, [bp + 0xa]
        sub ax, [ClipRightX]
        jng short .2
        sub [bp + 0xa], ax
        jng short .4
.2:
        mov ax, [ClipTopY]
        sub ax, [bp + 0x8]
        jng short .3
        sub [bp + 0xc], ax
        jng short .4
        mov ax, [ClipTopY]
        mov [bp + 0x8], ax
.3:
        mov ax, [bp + 0x8]
        add ax, [bp + 0xc]
        mov bx, [ClipBottomY]
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jng short XorRectRegs.1
        sub [bp + 0xc], ax
        jng short .4
        jmp short XorRectRegs.1
.4:
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; XorRectRegs                                                 0FEF:3584  94 PC
; XorRect entry.
;-----------------------------------------------------------------------------
XorRectRegs:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x2
        push si
        push di
.1:
        cld
        cmp word [bp + 0xa], 0x0
        jng short XorRect.4
        cmp word [bp + 0xc], 0x0
        jng short XorRect.4
        mov ax, [CanvasSeg]
        cmp ax, 0xa000
        jnz short .3
        mov es, ax
        mov dx, 0x3ce
        mov ax, 0x1803
        out dx, ax
        mov dx, 0x3c4
        mov bx, [bp + 0x8]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [CanvasRows]
        mov [bp - 0x2], bx
.2:
        mov cx, [bp + 0xa]
        mov bx, [bp + 0x6]
        mov si, [bp + 0xe]
        mov di, [bp - 0x2]
        mov di, [di]
        call RectSpanPlanes
        add word [bp - 0x2], 0x2
        dec word [bp + 0xc]
        jg short .2
        mov dx, 0x3ce
        mov ax, 0x3
        out dx, ax
        pop di
        pop si
        leave
        retf
.3:
        mov si, [bp + 0x8]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov ax, [bp + 0xe]
.4:
        mov cx, [bp + 0xa]
        mov bx, [bp + 0x6]
        mov di, [si]
        call XorSpan
        add si, 0x2
        dec word [bp + 0xc]
        jg short .4
        pop di
        pop si
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; CopyPageToPage                                              0FEF:3602  94 PC
; Page copy using a plane jump table.
;-----------------------------------------------------------------------------
CopyPageToPage:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xc
        push si
        push di
        push ds
        cld
        mov ax, [bp + 0x6]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x2], ax
        mov ax, [bp + 0xa]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x4], ax
        mov bx, [bp + 0x8]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [CanvasRows]
        mov di, [bx]
        add di, [bp - 0x2]
        mov ax, [bp + 0xe]
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        mov bx, [bp + 0x8]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov si, [CurPage]
        db 0x03, 0xF6                           ; insn: add si, si
        db 0x03, 0xF6                           ; insn: add si, si
        mov es, [si + PageTableSeg]
        mov si, [si + PageTable]
        add bx, [es:si + 0xa]
        mov si, [bx]
        add si, [bp - 0x2]
        mov ax, [CanvasRowBytes]
        sub ax, [bp - 0x4]
        mov [bp - 0x6], ax
        mov ax, 0xa000
        mov es, ax
        mov ds, ax
        mov bx, [bp + 0xe]
        and bx, 0x3
        jz short CopyPageToPageJumpTable.1
        mov [bp - 0x8], si
        mov [bp - 0xa], di
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp [cs:bx + CopyPageToPageJumpTable]
CopyPageToPageJumpTable:                        ; word; used by CopyPageToPage
        dw .1
        dw .3
        dw .8
        dw .9
.1:
        mov dx, 0x3c4
        mov ax, 0xf02
        out dx, ax
        mov dx, 0x3ce
        mov ax, 0x8
        out dx, ax
        mov dx, [bp + 0xc]
        mov bx, [bp - 0x6]
        mov ax, [bp - 0x4]
.2:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        rep movsb
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .2
        mov dx, 0x3ce
        mov ax, 0xff08
        out dx, ax
        pop ds
        pop di
        pop si
        leave
        retf
.3:
        mov bx, 0x2200
.4:
        mov [bp - 0xc], bx
.5:
        mov dx, 0x3c4
        mov al, 0x2
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        out dx, ax
        mov dx, 0x3ce
        mov al, 0x4
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        out dx, ax
        mov dx, [bp + 0xc]
        mov bx, [bp - 0x6]
        mov ax, [bp - 0x4]
        mov si, [bp - 0x8]
        mov di, [bp - 0xa]
.6:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        rep movsb
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .6
        mov bx, [bp - 0xc]
        rol bh, 1
        jnc short .7
        inc word [bp - 0xa]
.7:
        inc bl
        mov [bp - 0xc], bx
        cmp bl, 0x4
        jl short .5
        pop ds
        pop di
        pop si
        leave
        retf
.8:
        mov bx, 0x4400
        jmp short .4
.9:
        mov bx, 0x8800
        jmp short .4
        db 0x00

;-----------------------------------------------------------------------------
; CopyPageRect                                                0FEF:3704  94 PC
; Rectangle page copy using a plane jump table.
;-----------------------------------------------------------------------------
CopyPageRect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xc
        push si
        push di
        push ds
        cld
        mov ax, [bp + 0x8]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        shr ax, 1
        shr ax, 1
        mov [bp - 0x4], ax
        mov bx, [bp + 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, [CanvasRows]
        mov di, [bx]
        add di, [bp - 0x2]
        mov ax, [bp + 0x10]
        sar ax, 1
        sar ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        mov bx, [bp + 0xa]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov si, [bp + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        db 0x03, 0xF6                           ; insn: add si, si
        mov es, [si + PageTableSeg]
        mov si, [si + PageTable]
        add bx, [es:si + 0xa]
        mov si, [bx]
        add si, [bp - 0x2]
        mov ax, [CanvasRowBytes]
        sub ax, [bp - 0x4]
        mov [bp - 0x6], ax
        mov ax, 0xa000
        mov es, ax
        mov ds, ax
        mov bx, [bp + 0x10]
        and bx, 0x3
        jz short CopyPageRectJumpTable.1
        mov [bp - 0x8], si
        mov [bp - 0xa], di
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp [cs:bx + CopyPageRectJumpTable]
CopyPageRectJumpTable:                          ; word; used by CopyPageRect
        dw .1
        dw .3
        dw .8
        dw .9
.1:
        mov dx, 0x3c4
        mov ax, 0xf02
        out dx, ax
        mov dx, 0x3ce
        mov ax, 0x8
        out dx, ax
        mov dx, [bp + 0xe]
        mov bx, [bp - 0x6]
        mov ax, [bp - 0x4]
.2:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        rep movsb
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .2
        mov dx, 0x3ce
        mov ax, 0xff08
        out dx, ax
        pop ds
        pop di
        pop si
        leave
        retf
.3:
        mov bx, 0x2200
.4:
        mov [bp - 0xc], bx
.5:
        mov dx, 0x3c4
        mov al, 0x2
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        out dx, ax
        mov dx, 0x3ce
        mov al, 0x4
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        out dx, ax
        mov dx, [bp + 0xe]
        mov bx, [bp - 0x6]
        mov ax, [bp - 0x4]
        mov si, [bp - 0x8]
        mov di, [bp - 0xa]
.6:
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        rep movsb
        db 0x03, 0xF3                           ; insn: add si, bx
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .6
        mov bx, [bp - 0xc]
        rol bh, 1
        jnc short .7
        inc word [bp - 0xa]
.7:
        inc bl
        mov [bp - 0xc], bx
        cmp bl, 0x4
        jl short .5
        pop ds
        pop di
        pop si
        leave
        retf
.8:
        mov bx, 0x4400
        jmp short .4
.9:
        mov bx, 0x8800
        jmp short .4

;-----------------------------------------------------------------------------
; AllocCanvases                                               0FEF:3804  94 PC
; Allocates the page and off-screen buffers and fills the canvas records.
;-----------------------------------------------------------------------------
AllocCanvases:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        mov ax, [bp + 0xc]
        sub ax, [PageBase]
        mov [bp - 0xc], ax
        mul word [bp + 0x6]
        shr ax, 1
        shr ax, 1
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .1
        db 0x32, 0xC0                           ; insn: xor al, al
        inc ah
.1:
        mov [bp - 0x4], ax
        mov ax, [bp + 0x10]
        cmp ax, 0x4
        jng short .2
        jmp near .15
.2:
        mov word [bp - 0x6], 0x0
        mov bx, [BufPtr]
        cmp word [bp - 0xc], 0x0
        jz short .4
        mov ax, [bp + 0x8]
        cmp ax, 0xc8
        jnl short .3
        mov ax, 0xc8
.3:
        mov [bp - 0xc], ax
.4:
        mov [bp - 0xa], bx
        mov ax, [bp + 0x8]
        db 0x03, 0xC0                           ; insn: add ax, ax
        add ax, 0x4
        mul word [bp + 0x10]
        mov dx, [ChainIdx]
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        jl short .5
        mov cx, [bp - 0xc]
        db 0x03, 0xC9                           ; insn: add cx, cx
        jz short .6
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, 0x4
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        sub dx, 0x4
        jnl short .6
.5:
        jmp near .16
.6:
        shr dx, 1
        sub dx, 0x2
        jl short .7
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov [bx], dx
        mov word [bx + 0x2], 0x0
.7:
        mov ax, 0x0
        push ax
        mov ax, 0x1e
        mov dx, [bp + 0x10]
        cmp word [bp - 0xc], 0x0
        jz short .8
        inc dx
.8:
        mul dx
        push dx
        push ax
        mov ax, str_VideoWindowoutOfRowTable
        push ax
        call 0x14DB:AllocRecData
        add sp, 0x6
        mov es, dx
        mov [bp - 0x2], ax
        mov ax, [bp + 0x6]
        mov [bp - 0xe], ax
.9:
        mov bx, [bp - 0x6]
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov ax, [bp - 0x2]
        mov [bx + PageTable], ax
        mov [bx + PageTableSeg], es
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        add ax, 0x1e
        mov [bp - 0x2], ax
        mov ax, [bp - 0x4]
        mov [es:bx], ax
        mov ax, 0xa000
        mov [es:bx + 0x2], ax
        mov [es:bx + 0x4], ax
        mov [es:bx + 0x6], ax
        mov [es:bx + 0x8], ax
        mov ax, [bp - 0xa]
        add ax, 0x4
        mov [es:bx + 0xa], ax
        mov word [es:bx + 0xc], 0x0
        mov word [es:bx + 0x1a], 0x0
        mov ax, [bp - 0xe]
        test ax, 0x3
        jz short .10
        add ax, 0x4
        and ax, -0x4
.10:
        mov [es:bx + 0x18], ax
        mov [es:bx + 0x1c], ax
        shr ax, 1
        shr ax, 1
        mov [es:bx + 0xe], ax
        mov [es:bx + 0x14], ax
        mov [CanvasCount], ax
        mov word [es:bx + 0x10], 0x0
        mov ax, [bp + 0x8]
        mov [es:bx + 0x12], ax
        mov word [es:bx + 0x16], 0x0
        mov cx, [bp + 0x8]
        mov dx, [es:bx + 0x14]
        mov bx, [bp - 0xa]
        mov [bx], cx
        mov word [bx + 0x2], 0x1
        add bx, 0x4
        mov ax, [bp - 0x4]
.11:
        mov [bx], ax
        add bx, 0x2
        db 0x03, 0xC2                           ; insn: add ax, dx
        loop .11
        db 0x0A, 0xC0                           ; insn: or al, al
        jz short .12
        db 0x32, 0xC0                           ; insn: xor al, al
        inc ah
.12:
        mov [bp - 0x4], ax
        mov [bp - 0xa], bx
        inc word [bp - 0x6]
        dec word [bp + 0x10]
        jng short .13
        jmp near .9
.13:
        cmp word [bp - 0x6], 0x4
        jg short .14
        cmp word [bp - 0xc], 0x0
        jz short .14
        mov word [bp - 0x4], 0x0
        mov word [bp - 0x6], 0x4
        mov ax, [bp - 0xc]
        mov [bp + 0x8], ax
        mov ax, [bp + 0x6]
        mov [bp - 0xe], ax
        jmp near .9
.14:
        mov ax, 0x40
        mov es, ax
        mov ax, [bp + 0x6]
        shr ax, 1
        shr ax, 1
        shr ax, 1
        db 0x8A, 0xE0                           ; insn: mov ah, al
        mov al, 0x13
        mov dx, [es:BiosCrtcPort]
        out dx, ax
        mov byte [CopyActive], 0x1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        call 0x0FEF:CopyPlaneB
        add sp, 0x2
        call 0x0FEF:UseCurrentPage
        leave
        retf
.15:
        mov ax, str_TooManyVideoPages
        push ax
        call 0x0F4A:FatalError
.16:
        mov ax, 0x75a7
        push ax
        call 0x0F4A:FatalError
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        cmp [ss:CanvasSeg], ax
        jnz short .17
        mov ax, [bp + 0xa]
        mov [si + 0xc], ax
        mov [ss:ClipLeftPlane], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [si + 0x1a], ax
        mov [ss:ClipLeftX], ax
        mov ax, [bp + 0xc]
        mov [si + 0xe], ax
        mov [ss:ClipRightPlane], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [si + 0x1c], ax
        mov [ss:ClipRightX], ax
        mov ax, [bp + 0xe]
        mov [si + 0x10], ax
        mov [ss:ClipTopY], ax
        mov ax, [bp + 0x10]
        mov [si + 0x12], ax
        mov [ss:ClipBottomY], ax
        pop si
        pop ds
        leave
        retf
.17:
        mov ax, [bp + 0xa]
        mov [si + 0xc], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [si + 0x1a], ax
        mov ax, [bp + 0xc]
        mov [si + 0xe], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [si + 0x1c], ax
        mov ax, [bp + 0xe]
        mov [si + 0x10], ax
        mov ax, [bp + 0x10]
        mov [si + 0x12], ax
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; SetClipRectPlanes                                           0FEF:3A59  94 PC
; Sets the clip rectangle in plane units.
;-----------------------------------------------------------------------------
SetClipRectPlanes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, [bp + 0x6]
        mov [ClipLeftPlane], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [ClipLeftX], ax
        mov ax, [bp + 0x8]
        mov [ClipRightPlane], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [ClipRightX], ax
        mov ax, [bp + 0xa]
        mov [ClipTopY], ax
        mov ax, [bp + 0xc]
        mov [ClipBottomY], ax
        leave
        retf

;-----------------------------------------------------------------------------
; ClearScreenColor                                            0FEF:3A84  94 PC
; Fills video memory with a colour.
;-----------------------------------------------------------------------------
ClearScreenColor:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov ax, 0xf02
        mov dx, 0x3c4
        out dx, ax
        mov ax, 0xa000
        mov es, ax
        mov ax, [bp + 0x6]
        db 0x8A, 0xE0                           ; insn: mov ah, al
        mov di, [CanvasRows]
        mov di, [di]
        mov cx, 0x8000
        rep stosw
        pop di
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; DrawScaledColor                                             0FEF:3AA8  94 PC
; Sets ScaleColor/ScaleMode then enters DrawScaled.
;-----------------------------------------------------------------------------
DrawScaledColor:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov ax, [bp + 0x12]
        mov [ScaleColor], ax
        mov ax, [bp + 0x10]
        mov [ScaleMode], al
        jmp short DrawScaled.1

;-----------------------------------------------------------------------------
; DrawScaled                                                  0FEF:3ABB  94 PC
; Pattern or scaled draw.
;-----------------------------------------------------------------------------
DrawScaled:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
.1:
        cld
        mov si, [bp + 0xa]
        test si, 0x1
        jnz short .2
        mov ax, [ScaleColor]
        xchg ah, al
        mov [ScaleColor], ax
.2:
        mov si, [bp + 0xa]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov ax, [CanvasSeg]
        cmp ax, 0xa000
        jz short .3
        jmp near .11
.3:
        mov es, ax
        mov bl, [ScaleColor]
        and bx, 0xf
        mov al, [bx + ScaleLeftMasks]
        mov [ScaleColor], al
        mov bl, [ScaleColorHi]
        and bl, 0xf
        mov al, [bx + ScaleLeftMasks]
        mov [ScaleColorHi], al
        mov dx, 0x3c4
.4:
        mov bx, [bp + 0x8]
        mov cx, [bx]
        mov bx, [bp + 0x6]
        mov bx, [bx]
        db 0x2B, 0xCB                           ; insn: sub cx, bx
        inc cx
        jng short .5
        mov di, [si]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        and bx, 0x3
        mov al, [bx + ScaleRightMasks]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .7
        jz short .6
        mov ah, [bx + ScaleMasks]
        add cx, 0x3
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and ah, [bx + ScaleEdgeMasks]
        db 0x8A, 0xFC                           ; insn: mov bh, ah
        mov bl, [ScaleColor]
        db 0x22, 0xE3                           ; insn: and ah, bl
        mov al, 0x2
        out dx, ax
        mov ah, [ScaleMode]
        mov [es:di], ah
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        not bl
        db 0x22, 0xE3                           ; insn: and ah, bl
        out dx, ax
        mov ah, [bp + 0xe]
        mov [es:di], ah
.5:
        jmp near .9
.6:
        mov ah, [ss:bx + ScaleMasks]
        db 0x8A, 0xFC                           ; insn: mov bh, ah
        mov bl, [ScaleColor]
        db 0x22, 0xE3                           ; insn: and ah, bl
        mov al, 0x2
        out dx, ax
        mov ah, [ScaleMode]
        mov [es:di], ah
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        not bl
        db 0x22, 0xE3                           ; insn: and ah, bl
        out dx, ax
        mov ah, [bp + 0xe]
        mov [es:di], ah
        jmp short .9
.7:
        mov ah, [ss:bx + ScaleMasks]
        db 0x8A, 0xFC                           ; insn: mov bh, ah
        mov bl, [ScaleColor]
        db 0x22, 0xE3                           ; insn: and ah, bl
        mov al, 0x2
        out dx, ax
        mov ah, [ScaleMode]
        mov [es:di], ah
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        not bl
        db 0x22, 0xE3                           ; insn: and ah, bl
        out dx, ax
        mov ah, [bp + 0xe]
        mov [es:di], ah
        inc di
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        not ah
        db 0x8A, 0xD9                           ; insn: mov bl, cl
        shr cx, 1
        shr cx, 1
        jz short .8
        mov al, 0x2
        out dx, ax
        mov al, [ScaleMode]
        push di
        push cx
        rep stosb
        pop cx
        pop di
        not ah
        mov al, 0x2
        out dx, ax
        mov al, [bp + 0xe]
        rep stosb
        not ah
.8:
        and bx, 0x3
        jz short .9
        db 0x8A, 0xEC                           ; insn: mov ch, ah
        mov ah, [ss:bx + ScaleMasks2]
        db 0x8A, 0xFC                           ; insn: mov bh, ah
        db 0x22, 0xE5                           ; insn: and ah, ch
        mov al, 0x2
        out dx, ax
        mov bl, [ScaleMode]
        mov [es:di], bl
        db 0x8A, 0xE7                           ; insn: mov ah, bh
        not ch
        db 0x22, 0xE5                           ; insn: and ah, ch
        out dx, ax
        mov bl, [bp + 0xe]
        mov [es:di], bl
.9:
        add word [bp + 0x8], 0x2
        add word [bp + 0x6], 0x2
        add si, 0x2
        mov ax, [ScaleColor]
        xchg ah, al
        mov [ScaleColor], ax
        dec word [bp + 0xc]
        jg short .10
        pop di
        pop si
        leave
        retf
.10:
        jmp near .4
.11:
        mov ax, [ScaleColor]
        and ax, 0xf0f
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        or [ScaleColor], ax
        mov al, [bp + 0xe]
        mov ah, [ScaleMode]
.12:
        mov bx, [bp + 0x8]
        mov cx, [bx]
        mov bx, [bp + 0x6]
        mov bx, [bx]
        db 0x2B, 0xCB                           ; insn: sub cx, bx
        inc cx
        jng short DrawScaledJumpTable.7
        mov di, [si]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        shr dx, 1
        shr dx, 1
        db 0x03, 0xFA                           ; insn: add di, dx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov dx, [ScaleColor]
        jmp [cs:bx + DrawScaledJumpTable]
DrawScaledJumpTable:                            ; word; used by DrawScaled
        dw .4
        dw .3
        dw .2
        dw .1
.1:
        rol dl, 1
.2:
        rol dl, 1
.3:
        rol dl, 1
.4:
        mov es, [bx + CanvasSeg]
        rol dl, 1
        jc short .8
        mov [es:di], al
.5:
        add bx, 0x2
        and bx, 0x6
        jnz short .6
        inc di
.6:
        loop .4
.7:
        add word [bp + 0x8], 0x2
        add word [bp + 0x6], 0x2
        add si, 0x2
        mov bx, [ScaleColor]
        xchg bh, bl
        mov [ScaleColor], bx
        dec word [bp + 0xc]
        jg short DrawScaled.12
        pop di
        pop si
        leave
        retf
.8:
        mov [es:di], ah
        jmp short .5

;-----------------------------------------------------------------------------
; DrawLineClipped                                             0FEF:3C9A  94 PC
; Line clipped to the canvas.
;-----------------------------------------------------------------------------
DrawLineClipped:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xe
        push si
        push di
        mov si, [bp + 0x6]
        mov ax, [si]
        mov dx, [si + 0x2]
        add ax, 0x8000
        adc dx, 0x0
        mov [bp - 0x2], ax
        mov [bp - 0x4], dx
        mov ax, [si + 0x4]
        mov dx, [si + 0x6]
        add ax, 0x8000
        adc dx, 0x0
        mov [bp - 0x6], ax
        mov [bp - 0x8], dx
        mov al, [si + 0x10]
        mov [bp - 0xd], al
        mov ax, [si + 0xc]
        mov [bp - 0xa], ax
        mov ax, [CanvasSeg]
        cmp ax, 0xa000
        jz short .1
        jmp near DrawLineClippedJumpTable.34
.1:
        mov es, ax
        mov dx, 0x3c4
        mov bx, [si + 0x12]
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp [cs:bx + DrawLineClippedJumpTable]
DrawLineClippedJumpTable:                       ; word; used by DrawLineClipped
        dw .1
        dw .1
        dw .4
        dw .6
        dw .9
        dw .12
        dw .16
        dw .20
        dw .27
        dw .3
.1:
        mov cx, [si + 0xe]
        mov al, [bp - 0xd]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
        mov bx, [bp - 0x4]
        call FillSpanVga
.2:
        pop di
        pop si
        leave
        retf
.3:
        mov al, [bp - 0xd]
        push ax
        push word [bp - 0x8]
        push word [bp - 0x4]
        call 0x0FEF:PutPixel
        add sp, 0x6
        jmp short .2
.4:
        mov di, [bp - 0x4]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        and di, 0x3
        mov ah, [di + LineMasks]
        mov al, 0x2
        out dx, ax
        shr bx, 1
        shr bx, 1
        mov cx, [si + 0xe]
        mov al, [bp - 0xd]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
.5:
        mov di, [si]
        mov [es:bx + di], al
        add si, 0x2
        loop .5
        jmp short .2
.6:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        shr bx, 1
        shr bx, 1
        mov ah, [di + LineMasks]
.7:
        mov al, 0x2
        out dx, ax
        mov di, [si]
        mov al, [bp - 0xd]
        mov [es:bx + di], al
        ror ah, 1
        jnc short .8
        dec bx
.8:
        add si, 0x2
        loop .7
        jmp short .2
.9:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        shr bx, 1
        shr bx, 1
        mov ah, [di + LineMasks]
.10:
        mov al, 0x2
        out dx, ax
        mov di, [si]
        mov al, [bp - 0xd]
        mov [es:bx + di], al
        rol ah, 1
        jnc short .11
        inc bx
.11:
        add si, 0x2
        loop .10
        jmp near .2
.12:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        mov ah, [di + LineMasks]
        mov al, 0x2
        out dx, ax
        shr bx, 1
        shr bx, 1
        mov dx, [bp - 0xa]
        mov al, [bp - 0xd]
.13:
        mov di, [si]
        mov [es:bx + di], al
        add si, 0x2
        sub [bp - 0x2], dx
        jnc short .15
        ror ah, 1
        jnc short .14
        dec bx
.14:
        mov dx, 0x3c4
        mov al, 0x2
        out dx, ax
        mov al, [bp - 0xd]
        mov dx, [bp - 0xa]
.15:
        loop .13
        jmp near .2
.16:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        mov ah, [di + LineMasks]
        mov al, 0x2
        out dx, ax
        shr bx, 1
        shr bx, 1
        mov dx, [bp - 0xa]
        mov al, [bp - 0xd]
.17:
        mov di, [si]
        mov [es:bx + di], al
        add si, 0x2
        add [bp - 0x2], dx
        jnc short .19
        rol ah, 1
        jnc short .18
        inc bx
.18:
        mov dx, 0x3c4
        mov al, 0x2
        out dx, ax
        mov al, [bp - 0xd]
        mov dx, [bp - 0xa]
.19:
        loop .17
        jmp near .2
.20:
        mov cx, [si + 0xe]
        mov [bp - 0xc], cx
        mov cl, [bp - 0xd]
        mov si, [bp - 0xa]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        mov ah, [di + LineMasks]
        db 0x8A, 0xEC                           ; insn: mov ch, ah
        mov al, 0x2
        shr bx, 1
        shr bx, 1
.21:
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
.22:
        add [bp - 0x6], si
        jnc short .25
        inc word [bp - 0x8]
        out dx, ax
        mov [es:bx + di], cl
        ror ch, 1
        jnc short .24
.23:
        dec bx
.24:
        db 0x8A, 0xE5                           ; insn: mov ah, ch
        dec word [bp - 0xc]
        jg short .21
        jmp near .2
.25:
        ror ch, 1
        jc short .26
        db 0x0A, 0xE5                           ; insn: or ah, ch
        dec word [bp - 0xc]
        jg short .22
        db 0x32, 0xE5                           ; insn: xor ah, ch
        out dx, ax
        mov [es:bx + di], cl
        jmp near .2
.26:
        out dx, ax
        mov [es:bx + di], cl
        jmp short .23
.27:
        mov cx, [si + 0xe]
        mov [bp - 0xc], cx
        mov cl, [bp - 0xd]
        mov si, [bp - 0xa]
        mov bx, [bp - 0x4]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        and di, 0x3
        mov ah, [di + LineMasks]
        db 0x8A, 0xEC                           ; insn: mov ch, ah
        mov al, 0x2
        shr bx, 1
        shr bx, 1
.28:
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
.29:
        add [bp - 0x6], si
        jnc short .32
        inc word [bp - 0x8]
        out dx, ax
        mov [es:bx + di], cl
        rol ch, 1
        jnc short .31
.30:
        inc bx
.31:
        db 0x8A, 0xE5                           ; insn: mov ah, ch
        dec word [bp - 0xc]
        jg short .28
        jmp near .2
.32:
        rol ch, 1
        jc short .33
        db 0x0A, 0xE5                           ; insn: or ah, ch
        dec word [bp - 0xc]
        jg short .29
        db 0x32, 0xE5                           ; insn: xor ah, ch
        out dx, ax
        mov [es:bx + di], cl
        jmp near .2
.33:
        out dx, ax
        mov [es:bx + di], cl
        jmp short .30
.34:
        mov bx, [si + 0x12]
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp [cs:bx + DrawLineClippedJumpTable2]
DrawLineClippedJumpTable2:                      ; word; not used in the EXE (overlays may use it)
        dw .1
        dw .1
        dw .3
        dw .5
        dw .8
        dw .11
        dw .15
        dw .19
        dw .24
        dw DrawLineClippedJumpTable.3
.1:
        mov cx, [si + 0xe]
        mov al, [bp - 0xd]
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
        mov bx, [bp - 0x4]
        call FillSpanLinear
.2:
        pop di
        pop si
        leave
        retf
.3:
        mov di, [bp - 0x4]
        db 0x8B, 0xDF                           ; insn: mov bx, di
        and di, 0x3
        db 0x03, 0xFF                           ; insn: add di, di
        mov es, [di + CanvasSeg]
        shr bx, 1
        shr bx, 1
        mov cx, [si + 0xe]
        mov al, [bp - 0xd]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
.4:
        mov di, [si]
        mov [es:bx + di], al
        add si, 0x2
        loop .4
        jmp short .2
.5:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
        mov al, [bp - 0xd]
.6:
        mov es, [bx + CanvasSeg]
        mov di, [si]
        db 0x03, 0xFA                           ; insn: add di, dx
        mov [es:di], al
        sub bx, 0x2
        jnl short .7
        dec dx
        mov bx, 0x6
.7:
        add si, 0x2
        loop .6
        jmp short .2
.8:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
        mov al, [bp - 0xd]
.9:
        mov es, [bx + CanvasSeg]
        mov di, [si]
        db 0x03, 0xFA                           ; insn: add di, dx
        mov [es:di], al
        add bx, 0x2
        test bx, 0x8
        jz short .10
        inc dx
        and bx, 0x6
.10:
        add si, 0x2
        loop .9
        jmp near .2
.11:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
        mov [bp - 0x4], dx
        mov dx, [bp - 0xa]
        mov al, [bp - 0xd]
        mov es, [bx + CanvasSeg]
.12:
        mov di, [si]
        add di, [bp - 0x4]
        mov [es:di], al
        add si, 0x2
        sub [bp - 0x2], dx
        jnc short .14
        sub bx, 0x2
        jnl short .13
        mov bx, 0x6
        dec word [bp - 0x4]
.13:
        mov es, [bx + CanvasSeg]
.14:
        loop .12
        jmp near .2
.15:
        mov cx, [si + 0xe]
        mov si, [si + 0x6]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
        mov [bp - 0x4], dx
        mov dx, [bp - 0xa]
        mov al, [bp - 0xd]
        mov es, [bx + CanvasSeg]
.16:
        mov di, [si]
        add di, [bp - 0x4]
        mov [es:di], al
        add si, 0x2
        add [bp - 0x2], dx
        jnc short .18
        add bx, 0x2
        test bx, 0x8
        jz short .17
        and bx, 0x6
        inc word [bp - 0x4]
.17:
        mov es, [bx + CanvasSeg]
.18:
        loop .16
        jmp near .2
.19:
        mov cx, [si + 0xe]
        mov [bp - 0xc], cx
        mov cl, [bp - 0xd]
        mov si, [bp - 0xa]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
.20:
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
        db 0x03, 0xFA                           ; insn: add di, dx
.21:
        mov es, [bx + CanvasSeg]
        mov [es:di], cl
        sub bx, 0x2
        jnl short .22
        mov bx, 0x6
        dec di
        dec dx
.22:
        add [bp - 0x6], si
        jnc short .23
        inc word [bp - 0x8]
        dec word [bp - 0xc]
        jg short .20
        jmp near .2
.23:
        dec word [bp - 0xc]
        jg short .21
        jmp near .2
.24:
        mov cx, [si + 0xe]
        mov [bp - 0xc], cx
        mov cl, [bp - 0xd]
        mov si, [bp - 0xa]
        mov bx, [bp - 0x4]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
        shr dx, 1
        shr dx, 1
.25:
        mov di, [bp - 0x8]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, [CanvasRows]
        mov di, [di]
        db 0x03, 0xFA                           ; insn: add di, dx
.26:
        mov es, [bx + CanvasSeg]
        mov [es:di], cl
        add bx, 0x2
        test bx, 0x8
        jz short .27
        db 0x33, 0xDB                           ; insn: xor bx, bx
        inc di
        inc dx
.27:
        add [bp - 0x6], si
        jnc short .28
        inc word [bp - 0x8]
        dec word [bp - 0xc]
        jg short .25
        jmp near .2
.28:
        dec word [bp - 0xc]
        jg short .26
        jmp near .2

;-----------------------------------------------------------------------------
; FillSpanLinear                                              0FEF:4130  94 PC
; Fills a span in linear mode 13h.
;-----------------------------------------------------------------------------
FillSpanLinear:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jg short .1
        ret
.1:
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        shr dx, 1
        shr dx, 1
        db 0x03, 0xFA                           ; insn: add di, dx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
.2:
        mov es, [ss:bx + CanvasSeg]
        mov [es:di], al
        add bx, 0x2
        and bx, 0x6
        jnz short .3
        inc di
.3:
        loop .2
        ret

;-----------------------------------------------------------------------------
; FillSpanVga                                                 0FEF:4156  94 PC
; Fills a span in unchained mode with edge masks.
;-----------------------------------------------------------------------------
FillSpanVga:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jg short .1
        ret
.1:
        push ax
        push di
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        and bx, 0x3
        mov al, [ss:bx + SpanRightMasks]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .3
        jz short .2
        mov ah, [ss:bx + SpanMasks]
        add cx, 0x3
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and ah, [ss:bx + SpanLeftMasks2]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:di], al
        pop di
        pop ax
        ret
.2:
        mov ah, [ss:bx + SpanMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:di], al
        pop di
        pop ax
        ret
.3:
        mov ah, [ss:bx + SpanMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:di], al
        inc di
        db 0x8A, 0xD9                           ; insn: mov bl, cl
        shr cx, 1
        shr cx, 1
        jz short .4
        mov ax, 0xf02
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        rep stosb
.4:
        and bx, 0x3
        jz short .5
        mov ah, [ss:bx + SpanLeftMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov [es:di], al
.5:
        pop di
        pop ax
        ret

;-----------------------------------------------------------------------------
; RectSpanPlanes                                              0FEF:41D2  94 PC
; Splits a span into planar edges using the mask table RectRightMasks.
;-----------------------------------------------------------------------------
RectSpanPlanes:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jg short .1
        ret
.1:
        push ax
        push di
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        db 0x03, 0xF8                           ; insn: add di, ax
        and bx, 0x3
        mov al, [ss:bx + RectRightMasks]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        jg short .3
        jz short .2
        mov ah, [ss:bx + RectMasks]
        add cx, 0x3
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        and ah, [ss:bx + RectLeftMasks2]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov ah, [es:di]
        mov [es:di], al
        pop di
        pop ax
        ret
.2:
        mov ah, [ss:bx + RectMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov ah, [es:di]
        mov [es:di], al
        pop di
        pop ax
        ret
.3:
        mov ah, [ss:bx + RectMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov ah, [es:di]
        mov [es:di], al
        inc di
        db 0x8A, 0xD9                           ; insn: mov bl, cl
        shr cx, 1
        shr cx, 1
        jz short .5
        mov ax, 0xf02
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
.4:
        mov ah, [es:di]
        mov [es:di], al
        inc di
        loop .4
.5:
        and bx, 0x3
        jz short .6
        mov ah, [ss:bx + RectLeftMasks]
        mov al, 0x2
        out dx, ax
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov ah, [es:di]
        mov [es:di], al
.6:
        pop di
        pop ax
        ret
        db 0x00

;-----------------------------------------------------------------------------
; CopyPlanesRect                                              0FEF:4262  94 PC
; Copies a rectangle plane by plane with the read map.
;-----------------------------------------------------------------------------
CopyPlanesRect:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0xa
        push ds
        push si
        push di
        mov ax, [bp + 0xe]
        sar ax, 1
        sar ax, 1
        mov [bp - 0xa], ax
        mov ax, [bp + 0x6]
        sar ax, 1
        sar ax, 1
        mov [bp + 0x6], ax
        mov ax, [bp + 0xa]
        sar ax, 1
        sar ax, 1
        mov [bp + 0xa], ax
        mov bx, [bp + 0x8]
        shl bx, 1
        mov si, [CurPage]
        db 0x03, 0xF6                           ; insn: add si, si
        db 0x03, 0xF6                           ; insn: add si, si
        mov es, [si + PageTableSeg]
        mov si, [si + PageTable]
        add bx, [es:si + 0xa]
        mov ax, [bx]
        add ax, [bp + 0x6]
        mov [bp - 0x2], ax
        mov ax, [es:si + 0x14]
        sub ax, [bp - 0xa]
        mov [bp - 0x6], ax
        mov bx, [bp + 0xc]
        shl bx, 1
        add bx, [CanvasRows]
        mov ax, [bx]
        add ax, [bp + 0xa]
        mov [bp - 0x4], ax
        mov ax, [CanvasRowBytes]
        sub ax, [bp - 0xa]
        mov [bp - 0x8], ax
        mov ax, 0xa000
        mov ds, ax
        cld
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .2
        mov es, ax
        mov dx, 0x3c4
        mov ax, 0xf02
        out dx, ax
        mov dx, 0x3ce
        mov ax, 0x8
        out dx, ax
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
        mov dx, [bp + 0x10]
.1:
        mov cx, [bp - 0xa]
        rep movsb
        add si, [bp - 0x6]
        add di, [bp - 0x8]
        dec dx
        jg short .1
        mov dx, 0x3ce
        mov ax, 0xff08
        out dx, ax
        pop di
        pop si
        pop ds
        leave
        retf
.2:
        db 0x33, 0xDB                           ; insn: xor bx, bx
.3:
        db 0x8A, 0xE3                           ; insn: mov ah, bl
        shr ah, 1
        mov dx, 0x3ce
        mov al, 0x4
        out dx, ax
        mov es, [ss:bx + CanvasSeg]
        mov si, [bp - 0x2]
        mov di, [bp - 0x4]
        mov dx, [bp + 0x10]
.4:
        mov cx, [bp - 0xa]
        rep movsb
        add si, [bp - 0x6]
        add di, [bp - 0x8]
        dec dx
        jg short .4
        add bx, 0x2
        cmp bx, 0x8
        jl short .3
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; DrawRawFast                                                 0FEF:4346  94 PC
; Fast raw shape, hotspot entry.
;-----------------------------------------------------------------------------
DrawRawFast:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short DrawRawFastBody.1

;-----------------------------------------------------------------------------
; DrawRawFastAt                                               0FEF:4366  94 PC
; DrawRawFast at x,y.
;-----------------------------------------------------------------------------
DrawRawFastAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short DrawRawFastBody.1

;-----------------------------------------------------------------------------
; DrawRawFastBody                                             0FEF:4380  94 PC
; DrawRawFast body.
;-----------------------------------------------------------------------------
DrawRawFastBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        lds si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        cld
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, [si + 0xf]
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        mov [bp - 0x18], ax
        mov ax, [si + 0x2]
        mov [bp - 0xe], ax
        mov ax, [si]
        mov [bp - 0x4], ax
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        mov [bp - 0x10], bx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        mov [bp - 0x2], ax
        and bx, 0x3
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .8
        mov es, ax
        mov ah, [ss:bx + DrawRawFastMasks]
        mov [bp - 0x11], ah
        add si, 0x10
        mov word [bp - 0x16], 0x4
.2:
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov bx, [bp - 0xa]
        shl bx, 1
        add bx, [ss:CanvasRows]
        mov di, [ss:bx]
        add di, [bp - 0x2]
        mov dx, [bp - 0xe]
        mov bx, [bp - 0x10]
.3:
        mov cx, [bp - 0x4]
.4:
        lodsb
        cmp al, 0xff
        jz short .7
        stosb
        loop .4
.5:
        db 0x03, 0xFB                           ; insn: add di, bx
        dec dx
        jg short .3
        mov ah, [bp - 0x11]
        rol ah, 1
        jnc short .6
        inc word [bp - 0x2]
.6:
        mov [bp - 0x11], ah
        dec word [bp - 0x16]
        jg short .2
        pop di
        pop si
        pop ds
        leave
        retf
.7:
        inc di
        loop .4
        jmp short .5
.8:
        db 0x03, 0xDB                           ; insn: add bx, bx
        add si, 0x10
        mov word [bp - 0x16], 0x4
.9:
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        add di, [bp - 0x2]
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
        mov dx, [bp - 0x10]
.10:
        mov cx, [bp - 0x4]
.11:
        lodsb
        cmp al, 0xff
        jz short .14
        stosb
        loop .11
.12:
        db 0x03, 0xFA                           ; insn: add di, dx
        dec word [bp - 0x22]
        jg short .10
        add bx, 0x2
        and bx, 0x6
        jnz short .13
        inc word [bp - 0x2]
.13:
        add si, [bp - 0x18]
        dec word [bp - 0x16]
        jg short .9
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        inc di
        loop .11
        jmp short .12
        db 0x00

;-----------------------------------------------------------------------------
; DrawRawTransFast                                            0FEF:4488  94 PC
; Fast transparent raw shape, hotspot entry.
;-----------------------------------------------------------------------------
DrawRawTransFast:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        sub ax, [si + 0x4]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        sub ax, [si + 0x6]
        mov [bp - 0xa], ax
        jmp short DrawRawTransFastBody.1

;-----------------------------------------------------------------------------
; DrawRawTransFastAt                                          0FEF:44AB  94 PC
; DrawRawTransFast at x,y.
;-----------------------------------------------------------------------------
DrawRawTransFastAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [bp + 0xa]
        mov [bp - 0x2], ax
        mov ax, [bp + 0xc]
        mov [bp - 0xa], ax
        jmp short DrawRawTransFastBody.1

;-----------------------------------------------------------------------------
; DrawRawTransFastBody                                        0FEF:44C8  94 PC
; DrawRawTransFast body.
;-----------------------------------------------------------------------------
DrawRawTransFastBody:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x24
        push ds
        push si
        push di
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x8]
        mov [bp - 0x2], ax
        mov ax, [si + 0xa]
        mov [bp - 0xa], ax
.1:
        cld
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, [si + 0xf]
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        mov [bp - 0x18], ax
        mov ax, [si + 0x2]
        mov [bp - 0xe], ax
        mov ax, [si]
        mov [bp - 0x4], ax
        mov bx, [ss:CanvasRowBytes]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        mov [bp - 0x10], bx
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shr ax, 1
        shr ax, 1
        mov [bp - 0x2], ax
        and bx, 0x3
        mov ax, [ss:CanvasSeg]
        cmp ax, 0xa000
        jnz short .8
        mov es, ax
        mov ah, [ss:bx + DrawRawTransFastMasks]
        mov [bp - 0x11], ah
        add si, 0x10
        mov word [bp - 0x16], 0x4
.2:
        mov al, 0x2
        mov dx, 0x3c4
        out dx, ax
        mov bx, [bp - 0xa]
        shl bx, 1
        add bx, [ss:CanvasRows]
        mov di, [ss:bx]
        add di, [bp - 0x2]
        mov dx, [bp - 0xe]
        db 0x32, 0xFF                           ; insn: xor bh, bh
.3:
        mov cx, [bp - 0x4]
.4:
        lodsb
        cmp al, 0xff
        jz short .7
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .4
.5:
        add di, [bp - 0x10]
        dec dx
        jg short .3
        mov ah, [bp - 0x11]
        rol ah, 1
        jnc short .6
        inc word [bp - 0x2]
.6:
        mov [bp - 0x11], ah
        dec word [bp - 0x16]
        jg short .2
        pop di
        pop si
        pop ds
        leave
        retf
.7:
        inc di
        loop .4
        jmp short .5
.8:
        db 0x03, 0xDB                           ; insn: add bx, bx
        add si, 0x10
        mov word [bp - 0x16], 0x4
.9:
        mov [bp - 0x20], bx
        mov es, [ss:bx + CanvasSeg]
        mov di, [bp - 0xa]
        shl di, 1
        add di, [ss:CanvasRows]
        mov di, [ss:di]
        add di, [bp - 0x2]
        mov ax, [bp - 0xe]
        mov [bp - 0x22], ax
        mov dx, [bp - 0x10]
        db 0x32, 0xFF                           ; insn: xor bh, bh
.10:
        mov cx, [bp - 0x4]
.11:
        lodsb
        cmp al, 0xff
        jz short .14
        db 0x8A, 0xD8                           ; insn: mov bl, al
        mov al, [ss:bx + RemapTable]
        stosb
        loop .11
.12:
        db 0x03, 0xFA                           ; insn: add di, dx
        dec word [bp - 0x22]
        jg short .10
        mov bx, [bp - 0x20]
        add bx, 0x2
        and bx, 0x6
        jnz short .13
        inc word [bp - 0x2]
.13:
        add si, [bp - 0x18]
        dec word [bp - 0x16]
        jg short .9
        pop di
        pop si
        pop ds
        leave
        retf
.14:
        inc di
        loop .11
        jmp short .12

;-----------------------------------------------------------------------------
; UnchainVga                                                  0FEF:45E8  94 PC
; Clears chain-4 in the sequencer and CRTC.
;-----------------------------------------------------------------------------
UnchainVga:
        mov dx, 0x3c4
        mov al, 0x4
        out dx, al
        inc dx
        in al, dx
        and al, 0xf7
        or al, 0x4
        out dx, al
        mov dx, 0x3ce
        mov al, 0x5
        out dx, al
        inc dx
        in al, dx
        and al, 0xef
        out dx, al
        dec dx
        mov al, 0x6
        out dx, al
        inc dx
        in al, dx
        and al, 0xfd
        out dx, al
        mov dx, 0x3c4
        mov ax, 0xf02
        out dx, ax
        mov ax, [CanvasSeg]
        mov es, ax
        db 0x33, 0xFF                           ; insn: xor di, di
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, 0x8000
        cld
        rep stosw
        mov dx, 0x3d4
        mov al, 0x14
        out dx, al
        inc dx
        in al, dx
        and al, 0xbf
        out dx, al
        dec dx
        mov al, 0x17
        out dx, al
        inc dx
        in al, dx
        or al, 0x40
        out dx, al
        retf

;-----------------------------------------------------------------------------
; SetMaxScanLine                                              0FEF:4634  94 PC
; Writes CRTC register 9.
;-----------------------------------------------------------------------------
SetMaxScanLine:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov dx, 0x3d4
        mov al, 0x9
        out dx, al
        inc dx
        in al, dx
        and al, 0xe0
        or ax, [bp + 0x6]
        out dx, al
        leave
        retf

;-----------------------------------------------------------------------------
; SetMode13Linear                                             0FEF:4647  94 PC
; Sets mode 13h, chained.
;-----------------------------------------------------------------------------
SetMode13Linear:
        mov ax, 0xd
        int 0x10
        mov ax, 0x13
        int 0x10
        mov dx, 0x3d4
        mov al, 0x14
        out dx, al
        inc dx
        in al, dx
        and al, 0xbf
        dec dx
        mov al, 0x17
        out dx, al
        inc dx
        in al, dx
        and al, 0xbf
        out dx, al
        retf

;-----------------------------------------------------------------------------
; SetModeX                                                    0FEF:4665  94 PC
; Sets the unchained mode.
;-----------------------------------------------------------------------------
SetModeX:
        mov dx, 0x3c4
        mov al, 0x4
        out dx, al
        inc dx
        mov al, 0xe
        out dx, al
        mov dx, 0x3d4
        mov al, 0x14
        out dx, al
        inc dx
        mov al, 0x40
        out dx, al
        dec dx
        mov al, 0x17
        out dx, al
        inc dx
        mov al, 0xa3
        out dx, al
        retf

;-----------------------------------------------------------------------------
; XorSpan                                                     0FEF:4682  94 PC
; XORs one span.
;-----------------------------------------------------------------------------
XorSpan:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jg short .1
        ret
.1:
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        shr dx, 1
        shr dx, 1
        db 0x03, 0xFA                           ; insn: add di, dx
        and bx, 0x3
        db 0x03, 0xDB                           ; insn: add bx, bx
.2:
        mov es, [ss:bx + CanvasSeg]
        xor [es:di], al
        add bx, 0x2
        and bx, 0x6
        jnz short .3
        inc di
.3:
        loop .2
        ret

;-----------------------------------------------------------------------------
; SetCanvasClip                                               0FEF:46A8  94 PC
; Sets a canvas record's clip rectangle.
;-----------------------------------------------------------------------------
SetCanvasClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov ax, [si + 0x2]
        cmp [ss:CanvasSeg], ax
        jnz short .1
        mov ax, [bp + 0xa]
        mov [si + 0x1a], ax
        mov [ss:ClipLeftX], ax
        shr ax, 1
        shr ax, 1
        mov [si + 0xc], ax
        mov [ss:ClipLeftPlane], ax
        mov ax, [bp + 0xc]
        mov [si + 0x1c], ax
        mov [ss:ClipRightX], ax
        shr ax, 1
        shr ax, 1
        mov [si + 0xe], ax
        mov [ss:ClipRightPlane], ax
        mov ax, [bp + 0xe]
        mov [si + 0x10], ax
        mov [ss:ClipTopY], ax
        mov ax, [bp + 0x10]
        mov [si + 0x12], ax
        mov [ss:ClipBottomY], ax
        pop si
        pop ds
        leave
        retf
.1:
        mov ax, [bp + 0xa]
        mov [si + 0x1a], ax
        shr ax, 1
        shr ax, 1
        mov [si + 0xc], ax
        mov ax, [bp + 0xc]
        mov [si + 0x1c], ax
        shr ax, 1
        shr ax, 1
        mov [si + 0xe], ax
        mov ax, [bp + 0xe]
        mov [si + 0x10], ax
        mov ax, [bp + 0x10]
        mov [si + 0x12], ax
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; RemapShapeBank                                              0FEF:472A  94 PC
; Remaps every shape in a bank through a table.
;-----------------------------------------------------------------------------
RemapShapeBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x4
        push di
        push si
        mov es, [bp + 0x8]
        mov di, [bp + 0x6]
        mov si, [bp + 0xa]
        mov cx, [es:di + 0x4]
        mov [bp - 0x2], cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [bp - 0x4], ax
.1:
        mov ax, [bp - 0x4]
        cmp ax, [bp - 0x2]
        jl short .2
        pop si
        pop di
        leave
        retf
.2:
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:TableAt
        add sp, 0x6
        mov es, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [es:di]
        mul word [es:di + 0x2]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add di, 0x10
        db 0x33, 0xDB                           ; insn: xor bx, bx
.3:
        mov bl, [es:di]
        mov al, [bx + si]
        stosb
        loop .3
        inc word [bp - 0x4]
        jmp short .1
        db 0x00

;-----------------------------------------------------------------------------
; ConvertShapeBank                                            0FEF:4782  94 PC
; Converts the shapes of a bank in place.
;-----------------------------------------------------------------------------
ConvertShapeBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x10
        push di
        push si
        push ds
        mov ds, [bp + 0x8]
        mov si, [bp + 0x6]
        mov es, [bp + 0xc]
        mov di, [bp + 0xa]
        mov cx, [si + 0x4]
        mov [bp - 0x2], cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        add cx, 0x1
        add si, 0x4
        add di, 0x4
        rep movsw
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov [bp - 0x4], ax
        mov [bp - 0x6], di
        mov [es:di], ax
        mov [es:di + 0x2], ax
.1:
        mov ax, [bp - 0x4]
        cmp ax, [bp - 0x2]
        jl short .2
        pop ds
        pop si
        pop di
        leave
        retf
.2:
        push ax
        push word [bp + 0x8]
        push word [bp + 0x6]
        mov ax, ss
        mov ds, ax
        call 0x03A3:TableAt
        add sp, 0x6
        mov ds, dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov [bp - 0xa], dx
        mov [bp - 0xc], ax
        mov es, [bp + 0xc]
        mov di, [bp - 0x6]
        mov bx, [es:di]
        mov cx, [es:di + 0x2]
        add di, 0x4
        mov [bp - 0x6], di
        mov ax, [si]
        mul word [si + 0x2]
        mov [bp - 0xe], ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        add ax, 0x10
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x13, 0xD1                           ; insn: adc dx, cx
        mov bx, [bp - 0x4]
        inc bx
        cmp bx, [bp - 0x2]
        jnl short .3
        mov [es:di], ax
        mov [es:di + 0x2], dx
        jmp short .4
.3:
        mov bx, [bp - 0x2]
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        add bx, 0x6
        db 0x03, 0xC3                           ; insn: add ax, bx
        adc dx, 0x0
        mov di, [bp + 0xa]
        mov [es:di], ax
        mov [es:di + 0x2], dx
.4:
        push word [bp - 0x4]
        push word [bp + 0xc]
        push word [bp + 0xa]
        mov ax, ss
        mov ds, ax
        call 0x03A3:TableAt
        add sp, 0x6
        mov es, dx
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov [bp - 0x10], ax
        mov ds, [bp - 0xa]
        mov cx, 0x6
        rep movsw
        mov si, [bp - 0xc]
        mov di, [bp - 0x10]
        mov ax, [si]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        mov [es:di], ax
        mov al, [si + 0xd]
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        db 0x8A, 0xE0                           ; insn: mov ah, al
        add di, 0x10
        mov cx, [bp - 0xe]
        cmp cx, 0x0
        jng short .9
        cmp cx, 0x1f40
        jg short .9
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        rep stosw
        add si, 0x10
        mov [bp - 0x8], si
        db 0x33, 0xDB                           ; insn: xor bx, bx
.5:
        mov si, [bp - 0xc]
        mov ah, [bx + si + 0xc]
        and ah, 0xf
        jz short .9
        mov di, [bp - 0x10]
        add di, 0x10
        mov si, [bp - 0x8]
        mov dx, [bp - 0xe]
.6:
        lodsb
        mov cx, 0x8
.7:
        db 0x02, 0xC0                           ; insn: add al, al
        jnc short .8
        or [es:di], ah
.8:
        inc di
        loop .7
        dec dx
        jg short .6
        mov [bp - 0x8], si
        db 0x02, 0xE4                           ; insn: add ah, ah
        inc bx
        cmp bx, 0x4
        jl short .5
.9:
        inc word [bp - 0x4]
        jmp near .1

;-----------------------------------------------------------------------------
; FillPolySpans                                               0FEF:48D2  94 PC
; Fills a list of spans.
;-----------------------------------------------------------------------------
FillPolySpans:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x2
        push si
        push di
        cld
        mov si, [bp + 0xa]
        db 0x03, 0xF6                           ; insn: add si, si
        add si, [CanvasRows]
        mov [bp - 0x2], si
        mov ax, [CanvasSeg]
        mov es, ax
        cmp ax, 0xa000
        jnz short .3
        mov dx, 0x3c4
.1:
        mov bx, [bp + 0x8]
        mov cx, [bx]
        mov bx, [bp + 0x6]
        mov bx, [bx]
        db 0x2B, 0xCB                           ; insn: sub cx, bx
        inc cx
        jng short .2
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov si, [bp - 0x2]
        mov di, [si]
        mov si, [bp + 0xe]
        call FillSpanVga
.2:
        add word [bp - 0x2], 0x2
        add word [bp + 0x6], 0x2
        add word [bp + 0x8], 0x2
        dec word [bp + 0xc]
        jg short .1
        pop di
        pop si
        leave
        retf
.3:
        mov ax, [bp + 0xe]
.4:
        mov bx, [bp + 0x8]
        mov cx, [bx]
        mov bx, [bp + 0x6]
        mov bx, [bx]
        db 0x2B, 0xCB                           ; insn: sub cx, bx
        inc cx
        jng short .5
        mov si, [bp - 0x2]
        mov di, [si]
        call FillSpanLinear
.5:
        add word [bp - 0x2], 0x2
        add word [bp + 0x6], 0x2
        add word [bp + 0x8], 0x2
        dec word [bp + 0xc]
        jg short .4
