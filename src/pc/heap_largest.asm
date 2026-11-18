; LargestFreeBlock: the biggest free DOS block. The first bytes finish DrawFrameClipped.
;-----------------------------------------------------------------------------
; DrawFrameTail                                               148B:0000  94 PC
; End of DrawFrameClipped, which starts in the file before.
;-----------------------------------------------------------------------------
DrawFrameTail:
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; LargestFreeBlock                                            148B:0004  94 PC
; Walks the far heap list and returns the largest gap.
;-----------------------------------------------------------------------------
LargestFreeBlock:
        enter 0xc, 0x0
        push di
        les bx, [ss:HeapList]
        mov ax, [es:bx + 0x1c]
        mov dx, [es:bx + 0x1e]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xa], ax
        mov [bp - 0xc], ax
        mov ds, dx
.1:
        mov ax, [di]
        mov dx, [di + 0x2]
        sub ax, [es:bx + 0x10]
        sbb dx, [es:bx + 0x12]
        sub ax, [es:bx]
        sbb dx, [es:bx + 0x2]
        cmp dx, [bp - 0xa]
        jl short .3
        jg short .2
        cmp ax, [bp - 0xc]
        jna short .3
.2:
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        push ds
        pop es
        lds di, [es:di + 0x1c]
        mov ax, ds
        db 0x0B, 0xC7                           ; insn: or ax, di
        jnz short .1
        push ss
        pop ds
        mov ax, [bp - 0xc]
        mov dx, [bp - 0xa]
        pop di
        leave
