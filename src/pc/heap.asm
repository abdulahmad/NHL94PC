; BlankBit reads port 3DAh. MakeChain allocates a DOS block and links 24h-byte records in it. SetBuf stores
; the count and the near buffer MakeChain checks. The file before ends on the retf of WaitBlank; BlankBit, the
; first routine here, is reached through that file's segment base too.

; DGROUP words this segment uses. The bytes live in the near data, not here.

;-----------------------------------------------------------------------------
; BlankBit                                                    06E1:0000  94 PC
; Bit 0 of the video status port. AX is 0 or 1.
;-----------------------------------------------------------------------------
BlankBit:
        mov dx, 0x3da
        in al, dx
        and ax, 1
        retf

;-----------------------------------------------------------------------------
; MakeChain                                                   06E1:0008  94 PC
; Cap LargestFree at the dword at [bp+8], align it down to 16, and AllocBytes. The dword at [bp+0Ch], shifted
; down by 4, is subtracted from BlockEnd. BufCount below CCh calls FatalError.
;
; Four 24h-byte records are named from near pointers, then [bp+6] more are linked through offset 1Ch.
;
; The near call stores its far result at ChainPtr.
;-----------------------------------------------------------------------------
MakeChain:
        enter 6, 0
        push di
        push si
        call 0x3A3:LargestFree
        mov word [bp - 2], dx
        cmp dx, word [bp + 0xa]
        jl short .2
        jg short .1
        cmp ax, word [bp + 8]
        jbe short .2
.1:
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word [bp - 2], dx
.2:
        and al, 0xf0
        call 0x3A3:AllocBytes
        mov ax, word [bp + 0xc]
        mov dx, word [bp + 0xe]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sub word [BlockEnd], ax
        cmp word [BufPtr], 0
        jne short .3
        mov word [BufPtr], 0x6528
.3:
        cmp word [BufCount], 0xcc
        jge short .4
        push 0x26c
        call 0xF4A:FatalError
        add sp, 2
.4:
        mov ax, word [BufCount]
        shl ax, 1
        add ax, word [BufPtr]
        mov word [ChainIdx], ax
        mov ax, word [BufCount]
        dec ax
        dec ax
        mov bx, word [BufPtr]
        mov word [bx], ax
        mov bx, word [BufPtr]
        mov word [bx + 2], 0
        mov ax, word [BlockEnd+2]
        mov dx, word [BlockSeg]
        mov word [ChainPtr+0xc], ax
        mov word [ChainPtr+0xe], dx
        add ax, strict word 0x24
        mov word [ChainPtr+8], ax
        mov word [ChainPtr+0xa], dx
        mov ax, word [ChainPtr+0xc]
        imul cx, word [bp + 6], 0x24
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, strict word 0x48
        push dx
        push ax
        call 0x3A3:RoundSeg
        add sp, 4
        les bx, [ChainPtr+0xc]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        push 0xc
        push 0x297
        mov ax, word [ChainPtr+0xc]
        mov dx, word [ChainPtr+0xe]
        add ax, strict word 4
        push dx
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        les bx, [ChainPtr+0xc]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 0x16], ax
        mov word es:[bx + 0x14], ax
        les bx, [ChainPtr+0xc]
        mov word es:[bx + 0x12], ax
        mov word es:[bx + 0x10], ax
        mov ax, word [ChainPtr+8]
        mov dx, word [ChainPtr+0xa]
        les bx, [ChainPtr+0xc]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        les bx, [ChainPtr+0xc]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 0x22], ax
        mov word es:[bx + 0x20], ax
        les bx, [ChainPtr+0xc]
        mov word es:[bx + 0x18], ax
        push 0xc
        push 0x29f
        mov ax, word [ChainPtr+8]
        mov dx, word [ChainPtr+0xa]
        add ax, strict word 4
        push dx
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        mov ax, word [BlockEnd-2]
        mov dx, word [BlockEnd]
        les bx, [ChainPtr+8]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        les bx, [ChainPtr+8]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 0x16], ax
        mov word es:[bx + 0x14], ax
        les bx, [ChainPtr+8]
        mov word es:[bx + 0x12], ax
        mov word es:[bx + 0x10], ax
        les bx, [ChainPtr+8]
        mov word es:[bx + 0x1e], ax
        mov word es:[bx + 0x1c], ax
        mov ax, word [ChainPtr+0xc]
        mov dx, word [ChainPtr+0xe]
        les bx, [ChainPtr+8]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        les bx, [ChainPtr+8]
        mov word es:[bx + 0x18], 0x20
        mov ax, word [ChainPtr+8]
        mov dx, word [ChainPtr+0xa]
        add ax, strict word 0x24
        mov word [ChainPtr+4], ax
        mov word [ChainPtr+6], dx
        add ax, strict word 0x24
        mov word [EmsOutPtr], ax
        mov word [EmsOutPtr+2], dx
        les bx, [ChainPtr+4]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 2], ax
        mov word es:[bx], ax
        push 0xc
        push 0x2a8
        mov ax, word [ChainPtr+4]
        mov dx, word [ChainPtr+6]
        add ax, strict word 4
        push dx
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        les bx, [ChainPtr+4]
        mov word es:[bx + 0x14], 0x10
        mov word es:[bx + 0x16], 0
        les bx, [ChainPtr+4]
        mov word es:[bx + 0x10], 0x10
        mov word es:[bx + 0x12], 0
        mov ax, word [EmsOutPtr]
        mov dx, word [EmsOutPtr+2]
        les bx, [ChainPtr+4]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        les bx, [ChainPtr+4]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 0x22], ax
        mov word es:[bx + 0x20], ax
        les bx, [ChainPtr+4]
        mov word es:[bx + 0x18], 0x80
        push 0xc
        push 0x2b0
        mov ax, word [EmsOutPtr]
        mov dx, word [EmsOutPtr+2]
        add ax, strict word 4
        push dx
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        les bx, [EmsOutPtr]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[bx + 2], ax
        mov word es:[bx], ax
        les bx, [EmsOutPtr]
        mov word es:[bx + 0x16], ax
        mov word es:[bx + 0x14], ax
        les bx, [EmsOutPtr]
        mov word es:[bx + 0x12], ax
        mov word es:[bx + 0x10], ax
        les bx, [EmsOutPtr]
        mov word es:[bx + 0x1e], ax
        mov word es:[bx + 0x1c], ax
        mov ax, word [ChainPtr+4]
        mov dx, word [ChainPtr+6]
        les bx, [EmsOutPtr]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        les bx, [EmsOutPtr]
        mov word es:[bx + 0x18], 0xa0
        mov ax, word [EmsOutPtr]
        mov dx, word [EmsOutPtr+2]
        add ax, strict word 0x24
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], dx
        mov word [ChainPtr+0x10], ax
        mov word [ChainPtr+0x12], dx
        mov ax, word [bp + 6]
        dec ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jle short .6
        mov bx, word [bp + 6]
        dec bx
        mov es, dx
.5:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        db 0x8B, 0xFE                           ; insn: mov di, si
        add ax, strict word 0x24
        mov word es:[di + 0x1c], ax
        mov word es:[di + 0x1e], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], dx
        dec bx
        jne short .5
.6:
        mov es, word [bp - 2]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word es:[si + 0x1e], ax
        mov word es:[si + 0x1c], ax
        push cs
        call LargestGap
        mov word [ChainPtr], ax
        mov word [ChainPtr+2], dx
        pop si
        pop di
        leave
        retf
        nop
; Store the near buffer and the count MakeChain reads.
SetBuf:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, word [bp + 6]
        mov word [BufPtr], ax
        mov ax, word [bp + 8]
        mov word [BufCount], ax
        leave
        retf
        nop

; Insert a 24h-byte record into the chain. PathTail keeps the name. The dword at [bp+8] is rounded up to 16.
; Bits in [bp+0Ch] pick the walk: 20h uses one chain, 80h another, and anything else above that calls
; FatalError. A gap that fits is linked in and returned in DX:AX.

InsertRec:
        enter 0x1a, 0
        push si
        push word [bp + 6]
        call 0x3A3:PathTail
        add sp, 2
        mov word [bp + 6], ax
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        add ax, strict word 0xf
        adc dx, 0
        and al, 0xf0
        mov word [bp - 0xc], ax
        mov word [bp - 0xa], dx
        test word [bp + 0xc], 0xff80
        je short .1
        jmp near .32
.1:
        test byte [bp + 0xc], 0x20
        je short .2
        jmp near .16
.2:
        test byte [bp + 0xc], 0x10
        jne short .3
        push cs
        call SlideDown
.3:
        les bx, [ChainPtr+0xc]
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
.4:
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0x14], ax
        mov word [bp - 0x16], ax
.5:
        les bx, [bp - 8]
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        cmp dx, word [bp - 2]
        jl short .10
        jg short .6
        cmp ax, word [bp - 4]
        jbe short .10
.6:
        les bx, [bp - 8]
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        sub ax, word [bp - 4]
        sbb dx, word [bp - 2]
        mov word [bp - 0x16], ax
        mov word [bp - 0x14], dx
.7:
        mov ax, word [bp - 6]
        or ax, word [bp - 8]
        jne short .11
        push cs
        call AxClear
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .8
        jmp near .2
.8:
        cmp word [bp + 0xe], ax
        jne short .9
        jmp near .47
.9:
        push cs
        call LargestGap
        push dx
        push ax
        push word [bp + 0xa]
        push word [bp + 8]
        push 0x2c0
        jmp near .46
.10:
        les bx, [bp - 8]
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        les bx, [bp - 8]
        add ax, word es:[bx + 0x10]
        adc dx, word es:[bx + 0x12]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .7
        jmp near .5
.11:
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        cmp word [bp - 0x14], dx
        jge short .12
        jmp near .15
.12:
        jg short .13
        cmp word [bp - 0x16], ax
        jae short .13
        jmp near .15
.13:
        push cs
        call AllocRec
        mov word [bp - 0x1a], ax
        mov word [bp - 0x18], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bp + 0xc]
        mov word es:[bx + 0x18], ax
        mov ax, word [RecSeq]
        mov word es:[bx + 0x1a], ax
        inc word [RecSeq]
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word es:[bx + 0x14], ax
        mov word es:[bx + 0x16], dx
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        mov word es:[bx + 0x10], ax
        mov word es:[bx + 0x12], dx
        push 0xc
        push word [bp + 6]
        lea ax, [bx + 4]
        push es
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        call 0x3A3:LinearToFarRegs
        les bx, [bp - 0x1a]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        les si, [bp - 8]
        mov ax, word es:[si + 0x20]
        mov dx, word es:[si + 0x22]
        les bx, [bp - 0x1a]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x26, 0xC4, 0x77, 0x20               ; insn: les si, ptr es:[bx + 0x20]
        mov ax, word [bp - 0x1a]
        mov dx, word [bp - 0x18]
        mov word es:[si + 0x1c], ax
        mov word es:[si + 0x1e], dx
        les bx, [bp - 8]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
.14:
        call NoteLow
        mov ax, word [bp - 0x1a]
        mov dx, word [bp - 0x18]
        pop si
        leave
        retf
.15:
        les bx, [bp - 8]
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        les bx, [bp - 8]
        add ax, word es:[bx + 0x10]
        adc dx, word es:[bx + 0x12]
        jmp near .4
.16:
        mov word [bp - 0xe], 0
        test byte [bp + 0xc], 0x10
        jne short .17
        push cs
        call SlideUp
.17:
        cmp word [bp - 0xe], 0
        je short .18
        push cs
        call SlideDown
.18:
        les bx, [ChainPtr+8]
        mov ax, word es:[bx + 0x20]
        mov dx, word es:[bx + 0x22]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
.19:
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0x14], ax
        mov word [bp - 0x16], ax
.20:
        les bx, [bp - 8]
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        les bx, [bp - 8]
        add ax, word es:[bx + 0x10]
        adc dx, word es:[bx + 0x12]
        cmp dx, word [bp - 2]
        jg short .24
        jl short .21
        cmp ax, word [bp - 4]
        jae short .24
.21:
        mov cx, word [bp - 4]
        mov bx, word [bp - 2]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        db 0x1B, 0xDA                           ; insn: sbb bx, dx
        mov word [bp - 0x16], cx
        mov word [bp - 0x14], bx
.22:
        mov ax, word [bp - 6]
        or ax, word [bp - 8]
        jne short .25
        cmp word [bp - 0xe], 0
        je short .23
        jmp near .29
.23:
        mov word [bp - 0xe], 1
        jmp near .17
.24:
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        les bx, [bp - 8]
        mov ax, word es:[bx + 0x20]
        mov dx, word es:[bx + 0x22]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .22
        jmp short .20
.25:
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        cmp word [bp - 0x14], dx
        jge short .26
        jmp near .28
.26:
        jg short .27
        cmp word [bp - 0x16], ax
        jae short .27
        jmp near .28
.27:
        push cs
        call AllocRec
        mov word [bp - 0x1a], ax
        mov word [bp - 0x18], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bp + 0xc]
        mov word es:[bx + 0x18], ax
        mov ax, word [RecSeq]
        mov word es:[bx + 0x1a], ax
        inc word [RecSeq]
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word es:[bx + 0x14], ax
        mov word es:[bx + 0x16], dx
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        mov word es:[bx + 0x10], ax
        mov word es:[bx + 0x12], dx
        push 0xc
        push word [bp + 6]
        lea cx, [bx + 4]
        push es
        push cx
        call 0x3A3:CopyStrN
        add sp, 8
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        sub ax, word [bp - 0xc]
        sbb dx, word [bp - 0xa]
        call 0x3A3:LinearToFarRegs
        les bx, [bp - 0x1a]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        les si, [bp - 0x1a]
        mov word es:[si + 0x1c], ax
        mov word es:[si + 0x1e], dx
        les bx, [bp - 8]
        db 0x26, 0xC4, 0x77, 0x1C               ; insn: les si, ptr es:[bx + 0x1c]
        mov ax, word [bp - 0x1a]
        mov dx, word [bp - 0x18]
        mov word es:[si + 0x20], ax
        mov word es:[si + 0x22], dx
        les bx, [bp - 8]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        jmp near .14
        nop
.28:
        les bx, [bp - 8]
        jmp near .19
.29:
        push cs
        call AxClear
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .30
        jmp near .17
.30:
        cmp word [bp + 0xe], ax
        jne short .31
        jmp near .47
.31:
        push cs
        call LargestGap
        push dx
        push ax
        push word [bp + 0xa]
        push word [bp + 8]
        push 0x2fa
        jmp near .46
        nop
.32:
        mov ax, word [bp + 0xc]
        and al, 0x80
        cmp ax, 0x80
        je short .33
        jmp near .47
.33:
        les bx, [ChainPtr+4]
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
.34:
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        add ax, word es:[bx]
        adc dx, word es:[bx + 2]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.35:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0x14], ax
        mov word [bp - 0x16], ax
.36:
        test byte [bp + 0xc], 0x40
        je short .37
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        add ax, 0x3fff
        adc dx, 0
        and ax, 0xc000
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.37:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        les bx, [bp - 8]
        cmp word es:[bx + 2], dx
        jl short .40
        jg short .38
        cmp word es:[bx], ax
        jbe short .40
.38:
        mov cx, word es:[bx]
        mov si, word es:[bx + 2]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        db 0x1B, 0xF2                           ; insn: sbb si, dx
        mov word [bp - 0x16], cx
        mov word [bp - 0x14], si
.39:
        mov ax, word [bp - 6]
        or ax, word [bp - 8]
        jne short .41
        mov al, byte [bp + 0xc]
        and ax, strict word 7
        push ax
        push cs
        call DropOldest
        add sp, 2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .35
        jmp near .45
        nop
.40:
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        add ax, word es:[bx]
        adc dx, word es:[bx + 2]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .39
        jmp near .36
.41:
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        cmp word [bp - 0x14], dx
        jge short .42
        jmp near .44
.42:
        jg short .43
        cmp word [bp - 0x16], ax
        jae short .43
        jmp near .44
.43:
        push cs
        call AllocRec
        mov word [bp - 0x1a], ax
        mov word [bp - 0x18], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bp + 0xc]
        mov word es:[bx + 0x18], ax
        mov ax, word [RecSeq]
        mov word es:[bx + 0x1a], ax
        inc word [RecSeq]
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        mov word es:[bx + 0x14], ax
        mov word es:[bx + 0x16], dx
        mov ax, word [bp - 0xc]
        mov dx, word [bp - 0xa]
        mov word es:[bx + 0x10], ax
        mov word es:[bx + 0x12], dx
        push 0xc
        push word [bp + 6]
        lea ax, [bx + 4]
        push es
        push ax
        call 0x3A3:CopyStrN
        add sp, 8
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        les bx, [bp - 0x1a]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        les si, [bp - 8]
        mov ax, word es:[si + 0x20]
        mov dx, word es:[si + 0x22]
        les bx, [bp - 0x1a]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x26, 0xC4, 0x77, 0x20               ; insn: les si, ptr es:[bx + 0x20]
        mov ax, word [bp - 0x1a]
        mov dx, word [bp - 0x18]
        mov word es:[si + 0x1c], ax
        mov word es:[si + 0x1e], dx
        les bx, [bp - 8]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        pop si
        leave
        retf
.44:
        les bx, [bp - 8]
        jmp near .34
.45:
        cmp word [bp + 0xe], ax
        je short .47
        call 0x148B:LargestFreeBlock
        push dx
        push ax
        push word [bp + 0xa]
        push word [bp + 8]
        push 0x334
.46:
        call 0xF4A:FatalError
        add sp, 0xa
.47:
        cmp word [bp + 0xe], 0
        je short .48
        push word [bp + 0xc]
        push 0x36b
        call 0xF4A:FatalError
        add sp, 4
.48:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        db 0x99                                 ; insn: cdq
        pop si
        leave
        retf
        nop

; ResizeRec grows the record when the next one leaves room. A nonzero word at [bp+0Eh] reports a short gap
; through FatalError. FindRec walks the chain for the far base that matches the argument. UnlinkRec splices a
; record out. FindUnlink and FindTrim find first.
;
; TrimAfter drops the following records whose flag byte lacks bit 20h. DropOldest unlinks the oldest record of
; the requested class.

ResizeRec:
        enter 0xc, 0
        push di
        push si
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        les bx, [bp + 6]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov word [bp - 2], es
        cmp word es:[bx + 0x12], dx
        jl short .2
        jg short .1
        cmp word es:[bx + 0x10], ax
        jbe short .2
.1:
        mov es, word [bp - 2]
        mov word es:[si + 0x14], ax
        mov word es:[si + 0x16], dx
        add ax, strict word 0xf
        adc dx, 0
        and al, 0xf0
        mov word es:[si + 0x10], ax
        mov word es:[si + 0x12], dx
        jmp near .7
.2:
        mov es, word [bp - 2]
        test byte es:[si + 0x18], 0x80
        jne short .3
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 2]
        les bx, es:[si + 0x1c]
        push word es:[bx + 2]
        push word es:[bx]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0xc], di
        mov word [bp - 0xa], dx
        call 0x3A3:FarToLinear
        add sp, 4
        sub ax, word [bp - 0xc]
        sbb dx, word [bp - 0xa]
        mov word [bp - 8], ax
        jmp short .4
.3:
        mov ax, es
        les bx, es:[si + 0x1c]
        mov cx, word es:[bx]
        mov dx, word es:[bx + 2]
        mov es, ax
        sub cx, word es:[si]
        sbb dx, word es:[si + 2]
        mov word [bp - 8], cx
.4:
        mov word [bp - 6], dx
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        cmp word [bp - 6], dx
        jl short .6
        jle short .5
        jmp near .1
.5:
        cmp word [bp - 8], ax
        jbe short .6
        jmp near .1
.6:
        cmp word [bp + 0xe], 0
        je short .8
        push 0x393
        call 0xF4A:FatalError
        add sp, 2
.7:
        mov ax, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        pop si
        pop di
        leave
        retf
        nop
.8:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        pop di
        leave
        retf
        nop
FindRec:
        enter 4, 0
        push si
        les si, [ChainPtr+0xc]
        mov ax, word es:[si + 0x1c]
        mov dx, word es:[si + 0x1e]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov cx, word [bp + 6]
        mov ds, dx
.1:
        mov ax, word [bp + 8]
        cmp word [bx], cx
        jne short .2
        cmp word [bx + 2], ax
        je short .3
.2:
        lds bx, [bx + 0x1c]
        mov ax, ds
        db 0x0B, 0xC3                           ; insn: or ax, bx
        jne short .1
        mov ax, DGROUP
        mov ds, ax
        jmp short .4
.3:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, ds
        mov cx, DGROUP
        mov ds, cx
        pop si
        leave
        retf
.4:
        push word [bp + 8]
        push cx
        push 0x3b7
        call 0xF4A:FatalError
        add sp, 6
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        leave
        retf
        nop
FindUnlink:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call FindRec
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push dx
        push ax
        push cs
        call UnlinkRec
        leave
        retf
        nop
UnlinkRec:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, word [bp + 6]
        mov es, word [bp + 8]
        mov ax, es
        les bx, es:[si + 0x20]
        mov cx, es
        mov es, ax
        mov dx, word es:[si + 0x1c]
        mov di, word es:[si + 0x1e]
        mov es, cx
        mov word es:[bx + 0x1c], dx
        mov word es:[bx + 0x1e], di
        mov es, ax
        mov cx, word es:[si + 0x20]
        mov dx, word es:[si + 0x22]
        les bx, es:[si + 0x1c]
        mov word es:[bx + 0x20], cx
        mov word es:[bx + 0x22], dx
        push ax
        push si
        push cs
        call FreeRec
        add sp, 4
        pop si
        pop di
        leave
        retf
;-----------------------------------------------------------------------------
; FindTrim                                                    06E1:09FC  94 PC
; FindRec, then TrimAfter.
;-----------------------------------------------------------------------------
FindTrim:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call FindRec
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push dx
        push ax
        push cs
        call TrimAfter
        leave
        retf
        nop
TrimAfter:
        enter 8, 0
        push di
        push si
        les bx, [bp + 6]
        les bx, es:[bx + 0x1c]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov word [bp - 2], es
        test byte es:[bx + 0x18], 0x20
        jne short .2
.1:
        mov es, word [bp - 2]
        les bx, es:[si + 0x1c]
        db 0x8B, 0xF3                           ; insn: mov si, bx
        mov word [bp - 2], es
        push word es:[bx + 0x22]
        push word es:[bx + 0x20]
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov word [bp - 8], di
        mov word [bp - 6], es
        push cs
        call UnlinkRec
        add sp, 4
        les bx, [bp - 8]
        test byte es:[bx + 0x18], 0x20
        je short .1
.2:
        pop si
        pop di
        leave
        retf
;-----------------------------------------------------------------------------
; DropOldest                                                  06E1:0A5E  94 PC
; Unlinks the oldest record of the requested class and returns 1, or 0.
;-----------------------------------------------------------------------------
DropOldest:
        enter 0x12, 0
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 0xe], ax
        mov word [bp - 0x10], ax
        mov ax, word [bp + 6]
        mov word [bp - 6], ax
        mov word [bp - 8], 0
        les si, [ChainPtr+4]
        mov ax, word es:[si + 0x1c]
        mov dx, word es:[si + 0x1e]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ds, dx
.1:
        test byte [bx + 0x18], 8
        je short .3
        mov al, byte [bx + 0x18]
        and ax, strict word 7
        mov word [bp - 0x12], ax
        cmp ax, word [bp - 6]
        ja short .2
        mov ax, word [bp - 6]
        cmp word [bp - 0x12], ax
        jne short .3
        mov ax, word ss:[RecSeq]
        sub ax, word [bx + 0x1a]
        cmp ax, word [bp - 8]
        jl short .3
.2:
        mov word [bp - 0x10], bx
        mov word [bp - 0xe], ds
        mov ax, word [bp - 0x12]
        mov word [bp - 6], ax
        mov ax, word ss:[RecSeq]
        sub ax, word [bx + 0x1a]
        mov word [bp - 8], ax
.3:
        lds bx, [bx + 0x1c]
        mov ax, ds
        db 0x0B, 0xC3                           ; insn: or ax, bx
        jne short .1
        mov ax, DGROUP
        mov ds, ax
        mov cx, word [bp - 0x10]
        mov ax, word [bp - 0xe]
        db 0x0B, 0xC1                           ; insn: or ax, cx
        je short .4
        mov ax, word [bp - 0xe]
        push ax
        push cx
        push cs
        call UnlinkRec
        add sp, 4
        mov ax, 1
        pop si
        leave
        retf
.4:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        nop

; MoveFound and MoveFlag find the record first. MovePtr passes the caller's pointer. All three enter MoveRec.
; Flag 81h is the fixed value. MoveRec copies the 12-byte name, asks InsertRec for a new record, and copies
; the bytes across in pieces no larger than C000h. A failed insert tries DropOldest and asks again.

MoveFound:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x81
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call FindRec
        add sp, 4
        push dx
        push ax
        push cs
        call MoveRec
        leave
        retf
        nop
MovePtr:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push 0x81
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call MoveRec
        leave
        retf
;-----------------------------------------------------------------------------
; MoveFlag                                                    06E1:0B22  94 PC
; FindRec, then MoveRec with the caller's flag word.
;-----------------------------------------------------------------------------
MoveFlag:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 0xa]
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call FindRec
        add sp, 4
        push dx
        push ax
        push cs
        call MoveRec
        leave
        retf
        nop
MoveRec:
        enter 0x32, 0
        push di
        push si
        mov ax, word [bp + 6]
        mov dx, word [bp + 8]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x1a], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        pop di
        leave
        retf
.1:
        mov dx, word [bp - 0x1a]
        add ax, strict word 4
        push dx
        push ax
        push cs
        call FindName
        add sp, 4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .2
        mov ax, word [bp - 2]
        push ax
        push si
        push cs
        call UnlinkRec
        add sp, 4
.2:
        db 0x2B, 0xF6                           ; insn: sub si, si
        mov word [bp - 0x1c], di
        mov es, word [bp - 0x1a]
.3:
        db 0x8B, 0xDF                           ; insn: mov bx, di
        add bx, 4
        mov al, byte es:[bx + si]
        mov byte [bp + si - 0x32], al
        inc si
        cmp si, 0xc
        jl short .3
        mov byte [bp - 0x26], 0
.4:
        push 0
        mov es, word [bp - 0x1a]
        mov ax, word es:[di + 0x18]
        or al, 0x88
        push ax
        push word es:[di + 0x16]
        push word es:[di + 0x14]
        lea ax, [bp - 0x32]
        push ax
        push cs
        call InsertRec
        add sp, 0xa
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x1e], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .5
        push word [bp + 0xa]
        push cs
        call DropOldest
        add sp, 2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .4
.5:
        mov ax, word [bp - 0x1e]
        db 0x0B, 0xC6                           ; insn: or ax, si
        jne short .6
        jmp near .13
.6:
        mov es, word [bp - 0x1e]
        mov ax, word es:[si + 0x14]
        mov dx, word es:[si + 0x16]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov cx, word es:[si]
        mov bx, word es:[si + 2]
        mov word [bp - 8], cx
        mov word [bp - 6], bx
        mov es, word [bp - 0x1a]
        mov cx, word es:[di]
        mov bx, word es:[di + 2]
        mov word [bp - 0x24], cx
        mov word [bp - 0x22], bx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .7
        jmp near .13
.7:
        mov word [bp - 0x20], si
.8:
        cmp word [bp - 2], 0
        jl short .10
        jg short .9
        cmp word [bp - 4], 0xc000
        jbe short .10
.9:
        mov si, 0xc000
        jmp short .11
        nop
.10:
        mov si, word [bp - 4]
.11:
        push word [bp - 6]
        push word [bp - 8]
        call 0x3A3:EmsMapFrame
        add sp, 4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0xe], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .12
        push si
        push word [bp - 0x22]
        push word [bp - 0x24]
        mov ax, word [bp - 0xe]
        push ax
        push di
        call 0x3A3:CopyBytes
        add sp, 0xa
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        add word [bp - 8], si
        adc word [bp - 6], cx
        push word [bp - 0x22]
        push word [bp - 0x24]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        call 0x3A3:FarToLinear
        add sp, 4
        db 0x03, 0xC6                           ; insn: add ax, si
        db 0x13, 0xD7                           ; insn: adc dx, di
        call 0x3A3:LinearToFarRegs
        mov word [bp - 0x24], ax
        mov word [bp - 0x22], dx
        sub word [bp - 4], si
        sbb word [bp - 2], di
        mov ax, word [bp - 2]
        or ax, word [bp - 4]
        jne short .8
        mov si, word [bp - 0x20]
        jmp short .13
.12:
        mov si, word [bp - 0x20]
        push word [bp - 0x1e]
        push si
        push cs
        call UnlinkRec
        add sp, 4
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x1e], dx
.13:
        push word [bp - 0x1a]
        push word [bp - 0x1c]
        push cs
        call UnlinkRec
        add sp, 4
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, word [bp - 0x1e]
        pop si
        pop di
        leave
        retf

; FindName keeps the tail of the far string and walks the chain at
; ChainPtr+4. A 12-byte name match returns that record. A miss returns
; AX 0. AxClear is the retf that returns AX 0.

;-----------------------------------------------------------------------------
; FindName                                                    06E1:0CBC  94 PC
; Walks the chain for a 12-byte name. The far string is reduced to its tail
; first.
;-----------------------------------------------------------------------------
FindName:
        enter 0xc, 0
        push di
        push si
        push word [bp + 8]
        push word [bp + 6]
        call 0x3A3:PathTailFar
        add sp, 4
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0xa], dx
        mov ax, word [ChainPtr+4]
        mov dx, word [ChainPtr+6]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .3
.1:
        push 0xc
        mov dx, word [bp - 6]
        add ax, strict word 4
        push dx
        push ax
        push word [bp - 0xa]
        push di
        call 0x3A3:StrnDiff
        add sp, 0xa
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .2
        mov es, word [bp - 6]
        mov ax, word es:[si + 0x1c]
        mov dx, word es:[si + 0x1e]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 6], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        jmp short .3
        nop
.2:
        db 0x8B, 0xC6                           ; insn: mov ax, si
        mov dx, word [bp - 6]
        pop si
        pop di
        leave
        retf
        nop
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        pop di
        leave
        retf
        nop
AxClear:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        nop

; NameBase looks the near name up and returns the record base.
; CopyByName finds that record, inserts another with the same size,
; and copies the bytes across in pieces no larger than C000h.

NameBase:
        enter 4, 0
        push si
        push word [bp + 6]
        push cs
        call CopyByName
        add sp, 2
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 2], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .1
        mov es, word [bp - 2]
        mov ax, word es:[si]
        mov dx, word es:[si + 2]
        pop si
        leave
        retf
        nop
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        leave
        retf
;-----------------------------------------------------------------------------
; CopyByName                                                  06E1:0D58  94 PC
; Finds a named record, inserts another of the same size, and copies the
; bytes.
;-----------------------------------------------------------------------------
CopyByName:
        enter 0x1c, 0
        push di
        push si
        mov di, word [bp + 6]
        push ds
        push di
        push cs
        call FindName
        add sp, 4
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0xa], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        jmp near .9
.1:
        push 0
        mov es, word [bp - 0xa]
        mov ax, word es:[si + 0x18]
        and al, 0x77
        push ax
        push word es:[si + 0x16]
        push word es:[si + 0x14]
        push di
        push cs
        call InsertRec
        add sp, 0xa
        mov word [bp - 0x14], ax
        mov word [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .2
        jmp near .9
.2:
        mov es, word [bp - 0xa]
        mov ax, word es:[si + 0x14]
        mov dx, word es:[si + 0x16]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov cx, word es:[si]
        mov bx, word es:[si + 2]
        mov word [bp - 8], cx
        mov word [bp - 6], bx
        db 0xC4, 0x5E, 0xEC                     ; insn: les bx, ptr [bp - 0x14]
        mov cx, word es:[bx]
        mov si, word es:[bx + 2]
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov word [bp - 0x16], si
        db 0x0B, 0xD0                           ; insn: or dx, ax
        je short .8
.3:
        cmp word [bp - 2], 0
        jl short .6
        jg short .5
        cmp word [bp - 4], 0xc000
        jbe short .6
.5:
        mov si, 0xc000
        jmp short .7
.6:
        mov si, word [bp - 4]
.7:
        push si
        push word [bp - 6]
        push word [bp - 8]
        call 0x3A3:EmsMapFrame
        add sp, 4
        push dx
        push ax
        push word [bp - 0x16]
        push di
        call 0x3A3:CopyBytes
        add sp, 0xa
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        add word [bp - 8], si
        adc word [bp - 6], cx
        push word [bp - 0x16]
        push di
        mov word [bp - 0x1c], si
        mov word [bp - 0x1a], cx
        call 0x3A3:FarToLinear
        add sp, 4
        add ax, word [bp - 0x1c]
        adc dx, word [bp - 0x1a]
        call 0x3A3:LinearToFarRegs
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x16], dx
        mov ax, word [bp - 0x1c]
        mov dx, word [bp - 0x1a]
        sub word [bp - 4], ax
        sbb word [bp - 2], dx
        mov ax, word [bp - 2]
        or ax, word [bp - 4]
        jne short CopyByName.3
.8:
        mov ax, word [bp - 0x14]
        mov dx, word [bp - 0x12]
        pop si
        pop di
        leave
        retf
.9:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        pop di
        leave
        retf
        nop

; Slide a record whose flag word is 10h down into the gap below it.
; The move is CopyParasDown, then the next and previous links are rewritten.

SlideDown:
        enter 0x2c, 0
        push di
        push si
        les bx, [ChainPtr+8]
        mov ax, word es:[bx + 0x20]
        mov dx, word es:[bx + 0x22]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x16], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x12], dx
.1:
        push word es:[bx + 2]
        push word es:[bx]
.2:
        call 0x3A3:FarToLinear
        add sp, 4
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 6], ax
        mov word [bp - 8], ax
.3:
        mov es, word [bp - 0x16]
        push word es:[di + 2]
        push word es:[di]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0x16]
        add ax, word es:[di + 0x10]
        adc dx, word es:[di + 0x12]
        cmp dx, word [bp - 2]
        jl short .5
        jg short .4
        cmp ax, word [bp - 4]
        jb short .5
.4:
        push word es:[di + 2]
        push word es:[di]
        call 0x3A3:FarToLinear
        add sp, 4
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov es, word [bp - 0x16]
        mov ax, word es:[di + 0x20]
        mov dx, word es:[di + 0x22]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x16], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .3
        jmp short .6
        nop
.5:
        push word es:[di + 2]
        push word es:[di]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0x16]
        add ax, word es:[di + 0x10]
        adc dx, word es:[di + 0x12]
        mov cx, word [bp - 4]
        mov bx, word [bp - 2]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        db 0x1B, 0xDA                           ; insn: sbb bx, dx
        mov word [bp - 8], cx
        mov word [bp - 6], bx
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.6:
        mov ax, word [bp - 6]
        or ax, word [bp - 8]
        jne short .7
        jmp near .14
.7:
        mov es, word [bp - 0x12]
        cmp word es:[si + 0x18], 0x10
        jne short .8
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        cmp dx, word [bp - 2]
        jl short .9
        jg short .8
        cmp ax, word [bp - 4]
        jbe short .9
.8:
        mov es, word [bp - 0x12]
        mov ax, word es:[si + 0x20]
        mov dx, word es:[si + 0x22]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .7
        pop si
        pop di
        leave
        retf
.9:
        mov es, word [bp - 0x12]
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0x12]
        add ax, word es:[si + 0x10]
        adc dx, word es:[si + 0x12]
        cmp ax, word [bp - 4]
        jne short .10
        cmp dx, word [bp - 2]
        jne short .10
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        sub ax, word es:[si + 0x10]
        sbb dx, word es:[si + 0x12]
        add ax, word [bp - 4]
        adc dx, word [bp - 2]
        mov word [bp - 0x28], si
        mov word [bp - 0x26], es
        call 0x3A3:LinearToFarRegs
        mov word [bp - 0x1c], ax
        mov word [bp - 0x1a], dx
        les bx, [bp - 0x28]
        mov dx, word es:[bx + 2]
        mov word [bp - 0x1e], dx
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1e]
        call 0x3A3:CopyParasDown
        add sp, 6
        mov ax, word [bp - 0x1c]
        mov dx, word [bp - 0x1a]
        les bx, [bp - 0x28]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        push dx
        push ax
        jmp near .2
.10:
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        cmp word es:[si + 0x12], dx
        jle short .11
        jmp near .13
.11:
        jl short .12
        cmp word es:[si + 0x10], ax
        jbe short .12
        jmp near .13
.12:
        sub ax, word es:[si + 0x10]
        sbb dx, word es:[si + 0x12]
        add ax, word [bp - 4]
        adc dx, word [bp - 2]
        mov word [bp - 0x2c], si
        mov word [bp - 0x2a], es
        call 0x3A3:LinearToFarRegs
        mov word [bp - 0x1c], ax
        mov word [bp - 0x1a], dx
        les bx, [bp - 0x2c]
        mov dx, word es:[bx + 2]
        mov word [bp - 0x1e], dx
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1e]
        call 0x3A3:CopyParasDown
        add sp, 6
        mov ax, word [bp - 0x1c]
        mov dx, word [bp - 0x1a]
        les bx, [bp - 0x2c]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        les bx, es:[bx + 0x20]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        les bx, [bp - 0x2c]
        mov ax, word es:[bx + 0x20]
        mov dx, word es:[bx + 0x22]
        les bx, es:[bx + 0x1c]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov es, word [bp - 0x16]
        mov ax, word es:[di + 0x1c]
        mov dx, word es:[di + 0x1e]
        mov cx, es
        les bx, [bp - 0x2c]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        mov word es:[bx + 0x20], di
        mov word es:[bx + 0x22], cx
        mov es, cx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        les bx, es:[di + 0x1c]
        mov cx, word [bp - 0x2c]
        mov dx, word [bp - 0x2a]
        mov word es:[bx + 0x20], cx
        mov word es:[bx + 0x22], dx
        mov es, ax
        mov word es:[di + 0x1c], cx
        mov word es:[di + 0x1e], dx
        mov es, dx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        jmp near .1
.13:
        mov es, word [bp - 0x16]
        push word es:[di + 2]
        push word es:[di]
        jmp near .2
        nop
.14:
        pop si
        pop di
        leave
        retf

; SlideUp is the other direction: CopyParas moves a flag-10h record up into a gap. NoteLow keeps the lowest
; free address at ChainPtr. LargestGap is the biggest hole after a SlideDown. GapParas is that size in
; paragraphs. SumUsed adds the sizes of records whose flag byte lacks bit 10h.
;
; FreeRec and AllocRec are the free list. RecSize, RecBase, RawBase, RecSpan, and NamePtr read one field.

;-----------------------------------------------------------------------------
; SlideUp                                                     06E1:10EA  94 PC
; Slides a record with flag word 10h up into a gap. The move is CopyParas.
;-----------------------------------------------------------------------------
SlideUp:
        enter 0x2c, 0
        push di
        push si
        les bx, [ChainPtr+0xc]
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x12], dx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x16], dx
        push word es:[bx + 2]
        push word es:[bx]
        call 0x3A3:FarToLinear
        add sp, 4
.1:
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.2:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 6], ax
        mov word [bp - 8], ax
.3:
        mov es, word [bp - 0x16]
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        cmp dx, word [bp - 2]
        jg short .5
        jl short .4
        cmp ax, word [bp - 4]
        ja short .5
.4:
        mov es, word [bp - 0x16]
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0x16]
        add ax, word es:[si + 0x10]
        adc dx, word es:[si + 0x12]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov ax, word es:[si + 0x1c]
        mov dx, word es:[si + 0x1e]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0x16], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .3
        jmp short .6
        nop
.5:
        mov es, word [bp - 0x16]
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        sub ax, word [bp - 4]
        sbb dx, word [bp - 2]
        mov word [bp - 8], ax
        mov word [bp - 6], dx
.6:
        mov ax, word [bp - 6]
        or ax, word [bp - 8]
        jne short .7
        jmp near .15
.7:
        mov es, word [bp - 0x12]
        cmp word es:[di + 0x18], 0x10
        jne short .8
        push word es:[di + 2]
        push word es:[di]
        call 0x3A3:FarToLinear
        add sp, 4
        cmp dx, word [bp - 2]
        jg short .9
        jl short .8
        cmp ax, word [bp - 4]
        jae short .9
.8:
        mov es, word [bp - 0x12]
        mov ax, word es:[di + 0x1c]
        mov dx, word es:[di + 0x1e]
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov word [bp - 0x12], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .7
        pop si
        pop di
        leave
        retf
.9:
        mov ax, word [bp - 0x16]
        mov cx, word [bp - 0x12]
        db 0x3B, 0xF7                           ; insn: cmp si, di
        jne short .11
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jne short .11
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        call 0x3A3:LinearToFarRegs
        mov word [bp - 0x1c], ax
        mov word [bp - 0x1a], dx
        mov es, word [bp - 0x12]
        mov dx, word es:[di + 2]
        mov word [bp - 0x1e], dx
        mov ax, word es:[di + 0x10]
        mov dx, word es:[di + 0x12]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1e]
        mov word [bp - 0x28], di
        mov word [bp - 0x26], es
        call 0x3A3:CopyParas
        add sp, 6
        mov ax, word [bp - 0x1c]
        mov dx, word [bp - 0x1a]
        les bx, [bp - 0x28]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
.10:
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        add word [bp - 4], ax
        adc word [bp - 2], dx
        jmp near .2
        nop
.11:
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        mov es, cx
        cmp word es:[di + 0x12], dx
        jle short .12
        jmp near .14
.12:
        jl short .13
        cmp word es:[di + 0x10], ax
        jbe short .13
        jmp near .14
.13:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        call 0x3A3:LinearToFarRegs
        mov word [bp - 0x1c], ax
        mov word [bp - 0x1a], dx
        mov es, word [bp - 0x12]
        mov dx, word es:[di + 2]
        mov word [bp - 0x1e], dx
        mov ax, word es:[di + 0x10]
        mov dx, word es:[di + 0x12]
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        push ax
        push word [bp - 0x1a]
        push word [bp - 0x1e]
        mov word [bp - 0x2c], di
        mov word [bp - 0x2a], es
        call 0x3A3:CopyParas
        add sp, 6
        mov ax, word [bp - 0x1c]
        mov dx, word [bp - 0x1a]
        les bx, [bp - 0x2c]
        mov word es:[bx], ax
        mov word es:[bx + 2], dx
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        les bx, es:[bx + 0x20]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        les bx, [bp - 0x2c]
        mov ax, word es:[bx + 0x20]
        mov dx, word es:[bx + 0x22]
        les bx, es:[bx + 0x1c]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov ax, word [bp - 0x16]
        les bx, [bp - 0x2c]
        mov word es:[bx + 0x1c], si
        mov word es:[bx + 0x1e], ax
        mov es, ax
        mov ax, word es:[si + 0x20]
        mov dx, word es:[si + 0x22]
        mov cx, es
        les bx, [bp - 0x2c]
        mov word es:[bx + 0x20], ax
        mov word es:[bx + 0x22], dx
        mov es, cx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        les bx, es:[si + 0x20]
        mov cx, word [bp - 0x2c]
        mov dx, word [bp - 0x2a]
        mov word es:[bx + 0x1c], cx
        mov word es:[bx + 0x1e], dx
        mov es, ax
        mov word es:[si + 0x20], cx
        mov word es:[si + 0x22], dx
        mov es, dx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        jmp near .10
        nop
.14:
        mov es, word [bp - 0x16]
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0x16]
        add ax, word es:[si + 0x10]
        adc dx, word es:[si + 0x12]
        jmp near .1
.15:
        pop si
        pop di
        leave
        retf
;-----------------------------------------------------------------------------
; NoteLow                                                     06E1:1366  94 PC
; If the largest gap starts below ChainPtr, store that address there.
;-----------------------------------------------------------------------------
NoteLow:
        enter 4, 0
        push cs
        call LargestGap
        mov word [bp - 4], ax
        mov word [bp - 2], dx
        mov ax, word [ChainPtr]
        mov dx, word [ChainPtr+2]
        cmp word [bp - 2], dx
        jg short .2
        jl short .1
        cmp word [bp - 4], ax
        jae short .2
.1:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        mov word [ChainPtr], ax
        mov word [ChainPtr+2], dx
.2:
        leave
        ret
;-----------------------------------------------------------------------------
; LargestGap                                                  06E1:1396  94 PC
; After SlideDown, the biggest hole between a record and the next one.
;-----------------------------------------------------------------------------
LargestGap:
        enter 0x14, 0
        push di
        push si
        push cs
        call SlideDown
        les bx, [ChainPtr+0xc]
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov word [bp - 0xa], es
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0xe], dx
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 6], ax
        mov word [bp - 8], ax
.1:
        push word es:[di + 2]
        push word es:[di]
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0xe]
        push word es:[si + 2]
        push word es:[si]
        mov word [bp - 0x14], ax
        mov word [bp - 0x12], dx
        call 0x3A3:FarToLinear
        add sp, 4
        mov es, word [bp - 0xa]
        sub ax, word es:[di + 0x10]
        sbb dx, word es:[di + 0x12]
        sub ax, word [bp - 0x14]
        sbb dx, word [bp - 0x12]
        cmp dx, word [bp - 6]
        jl short .3
        jg short .2
        cmp ax, word [bp - 8]
        jbe short .3
.2:
        mov word [bp - 8], ax
        mov word [bp - 6], dx
.3:
        mov ax, word [bp - 0xe]
        db 0x8B, 0xCE                           ; insn: mov cx, si
        db 0x8B, 0xF9                           ; insn: mov di, cx
        mov word [bp - 0xa], ax
        mov es, ax
        db 0x8B, 0xDE                           ; insn: mov bx, si
        mov ax, word es:[bx + 0x1c]
        mov dx, word es:[bx + 0x1e]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [bp - 0xe], dx
        db 0x0B, 0xD0                           ; insn: or dx, ax
        jne short .1
        mov ax, word [bp - 8]
        mov dx, word [bp - 6]
        pop si
        pop di
        leave
        retf
        nop
GapParas:
        push cs
        call LargestGap
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        retf
        nop
SumUsed:
        enter 4, 0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov word [bp - 2], ax
        mov word [bp - 4], ax
        les bx, [ChainPtr+0xc]
        mov ax, es
        db 0x0B, 0xC3                           ; insn: or ax, bx
        je short .3
.1:
        test byte es:[bx + 0x18], 0x10
        jne short .2
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        add word [bp - 4], ax
        adc word [bp - 2], dx
.2:
        les bx, es:[bx + 0x1c]
        mov ax, es
        db 0x0B, 0xC3                           ; insn: or ax, bx
        jne short .1
.3:
        mov ax, word [bp - 4]
        mov dx, word [bp - 2]
        leave
        retf
        nop
FreeRec:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, word [bp + 6]
        mov ax, word [ChainPtr+0x10]
        mov dx, word [ChainPtr+0x12]
        mov es, word [bp + 8]
        mov word es:[bx + 0x1c], ax
        mov word es:[bx + 0x1e], dx
        mov word [ChainPtr+0x10], bx
        mov word [ChainPtr+0x12], es
        leave
        retf
;-----------------------------------------------------------------------------
; AllocRec                                                    06E1:14A8  94 PC
; Pops a record off the free list. An empty list calls FatalError.
;-----------------------------------------------------------------------------
AllocRec:
        enter 4, 0
        push si
        mov ax, word [ChainPtr+0x12]
        or ax, word [ChainPtr+0x10]
        je short .1
        mov ax, word [ChainPtr+0x10]
        mov dx, word [ChainPtr+0x12]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov word [bp - 2], dx
        les si, [ChainPtr+0x10]
        mov ax, word es:[si + 0x1c]
        mov dx, word es:[si + 0x1e]
        mov word [ChainPtr+0x10], ax
        mov word [ChainPtr+0x12], dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, word [bp - 2]
        pop si
        leave
        retf
        nop
.1:
        push 0x3dd
        call 0xF4A:FatalError
        add sp, 2
        pop si
        leave
        retf
;-----------------------------------------------------------------------------
; RecSize                                                     06E1:14EC  94 PC
; FindRec, then the size dword at offset 10h.
;-----------------------------------------------------------------------------
RecSize:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp + 8]
        push word [bp + 6]
        push cs
        call FindRec
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word es:[bx + 0x10]
        mov dx, word es:[bx + 0x12]
        leave
        retf
        nop
RecBase:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        les si, [bp + 6]
        test byte es:[si + 0x18], 0x80
        je short .1
        push word es:[si + 2]
        push word es:[si]
        call 0x3A3:EmsMapFrame
        add sp, 4
        pop si
        leave
        retf
.1:
        mov ax, word es:[si]
        mov dx, word es:[si + 2]
        pop si
        leave
        retf
;-----------------------------------------------------------------------------
; RawBase                                                     06E1:1532  94 PC
; The far pointer stored at the start of the record.
;-----------------------------------------------------------------------------
RawBase:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        les bx, [bp + 6]
        mov ax, word es:[bx]
        mov dx, word es:[bx + 2]
        leave
        retf
        nop
RecSpan:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        les bx, [bp + 6]
        mov ax, word es:[bx + 0x14]
        mov dx, word es:[bx + 0x16]
        leave
        retf
;-----------------------------------------------------------------------------
; NamePtr                                                     06E1:1552  94 PC
; The caller's far pointer plus 4, the name field.
;-----------------------------------------------------------------------------
NamePtr:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, word [bp + 6]
        mov dx, word [bp + 8]
        add ax, strict word 4
        leave
        retf
