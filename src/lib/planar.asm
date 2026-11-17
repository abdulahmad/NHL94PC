; Planar to linear conversion of movie blocks (MOVIE.OVL)

;-----------------------------------------------------------------------------
; PlanarToLinear                                             3349:0000  94 PC
; Interleaves the four planes of a block into a linear buffer.
;
; Takes 4 words of stack arguments. Far routine (retf).
;-----------------------------------------------------------------------------
PlanarToLinear:
        enter 0xe, 0x0
        les bx, [bp + 0x6]
        mov ax, [es:bx]
        sar ax, byte 0x2
        imul word [es:bx + 0x2]
        mov [bp - 0xa], ax
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        add ax, strict word 0x10
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov word [bp - 0x2], 0x0
        jmp short .4
.1:
        inc word [bp - 0x8]
.2:
        mov ax, [bp - 0xa]
        cmp [bp - 0x8], ax
        jnc short .3
        les bx, [bp - 0xe]
        add word [bp - 0xe], 0x4
        mov al, [es:bx]
        les bx, [bp - 0x6]
        inc word [bp - 0x6]
        mov [es:bx], al
        jmp short .1
.3:
        inc word [bp - 0x2]
.4:
        cmp word [bp - 0x2], 0x4
        jnc short .5
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, [bp - 0x2]
        add ax, strict word 0x10
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        mov word [bp - 0x8], 0x0
        jmp short .2
.5:
        leave
        retf

;-----------------------------------------------------------------------------
; PlanarToLinearKey                                          3349:006E  94 PC
; Same, turning the key colour into 0xFF.
;
; Takes 6 words of stack arguments.
;-----------------------------------------------------------------------------
PlanarToLinearKey:
        enter 0xe, 0x0
        les bx, [bp + 0x6]
        mov ax, [es:bx]
        sar ax, byte 0x2
        imul word [es:bx + 0x2]
        mov [bp - 0xa], ax
        mov ax, [bp + 0xa]
        mov dx, [bp + 0xc]
        add ax, strict word 0x10
        mov [bp - 0x6], ax
        mov [bp - 0x4], dx
        mov word [bp - 0x2], 0x0
        jmp short .5
.1:
        mov al, [es:bx]
.2:
        les bx, [bp - 0x6]
        inc word [bp - 0x6]
        mov [es:bx], al
        add word [bp - 0xe], 0x4
        inc word [bp - 0x8]
.3:
        mov ax, [bp - 0xa]
        cmp [bp - 0x8], ax
        jnc short .4
        mov al, [bp + 0xe]
        les bx, [bp - 0xe]
        cmp [es:bx], al
        jnz short .1
        mov al, 0xff
        jmp short .2
.4:
        inc word [bp - 0x2]
.5:
        cmp word [bp - 0x2], 0x4
        jnc short PlanarToLinearKeyTail.1 + 0xE0
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        add ax, [bp - 0x2]
        add ax, strict word 0x10
        mov [bp - 0xe], ax
        mov [bp - 0xc], dx
        mov word [bp - 0x8], 0x0
