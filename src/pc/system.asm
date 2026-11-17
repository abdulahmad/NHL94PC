; EMS maps, far copies, the INT 24h hook, file length, a file-head count, find-first paths, the DOS memory
; block, a 4-byte lookup, far-pointer lookup, a counted copy, multiply and divide, file writes, character
; widths, the INT 8 handler, the game port, the keyboard hook, the monochrome console, the CallCount waits,
;
; line clipping, file reads, a CPU probe, a polygon fill, and the video-mode save.
;
; The first bytes finish the C runtime routine that ends on this paragraph.

; DGROUP words this segment uses. The bytes live in the near data, not here.
GamePort	equ	0x201

; The previous segment ends on the first byte of test bx, 8.
; These bytes finish that test, then pop bp / ret 0xe.
        db 0xC3, 0x08, 0x00                     ; insn: test bx, 8
        jne short SpillRet
        mov ax, 1
SpillRet:
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        pop bp
        ret 0xe


;-----------------------------------------------------------------------------
; EmsMap                                                      03A3:000E  94 PC
; Map CX logical pages starting at BX onto physical pages starting at AL. INT 67h AH=44h, handle at EmsHandle.
; Skips the call when the cache already matches. Carry set on failure. Near.
;-----------------------------------------------------------------------------
EmsMap:
        db 0x32, 0xE4                           ; insn: xor ah, ah
        db 0x8B, 0xF0                           ; insn: mov si, ax
        cmp si, 4
        jae short .2
        db 0x03, 0xF6                           ; insn: add si, si
        and word [si + EmsMapCache], 0x7fff
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        and dx, 0x8000
        or word [si + EmsMapCache], dx
        cmp word [si + EmsMapCache], bx
        je short .1
        cmp bx, 0
        jl short .1
        mov word [si + EmsMapCache], bx
        mov dx, word [EmsHandle]
        mov ah, 0x44
        int 0x67
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jne short .2
.1:
        inc al
        inc bx
        loop EmsMap
        clc
        ret
.2:
        stc
        ret

;-----------------------------------------------------------------------------
; EmsMapRange                                                 03A3:004D  94 PC
; map the byte range (long at [bp+6], length at [bp+0Ah]) into a
; free physical window and return DX:AX inside the page frame. Zero if none fit.
;-----------------------------------------------------------------------------
EmsMapRange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push si
        mov ax, word [bp + 6]
        and ax, 0x3fff
        add ax, word [bp + 0xa]
        dec ax
        shr ax, 0xe
        inc ax
        mov word [bp - 4], ax
        mov dx, word [bp + 8]
        mov ax, word [bp + 6]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        mov word [bp - 2], dx
        mov word [bp - 6], 0
.1:
        mov bx, word [bp - 6]
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov dx, word [bp - 4]
        mov ax, word [bp - 2]
.2:
        cmp word [bx + EmsMapCache], 0
        jl short .3
        cmp word [bx + EmsMapCache], ax
        jne short .4
.3:
        dec dx
        jle short .6
        inc ax
        add bx, 2
        cmp bx, 8
        jl short .2
.4:
        inc word [bp - 6]
        cmp word [bp - 6], 4
        jl short .1
.5:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x33, 0xD2                           ; insn: xor dx, dx
        pop si
        leave
        retf
.6:
        mov ax, word [bp - 6]
        mov bx, word [bp - 2]
        mov cx, word [bp - 4]
        call EmsMap
        jb short .5
        mov ax, word [bp + 6]
        and ax, 0x3fff
        mov bx, word [bp - 6]
        db 0x03, 0xDB                           ; insn: add bx, bx
        add ax, word [bx + EmsWindowOff]
        mov dx, word [EmsFrame]
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EmsMarkStale                                                03A3:00D3  94 PC
; set the high bit of the four cached logical pages so the next map misses.
;-----------------------------------------------------------------------------
EmsMarkStale:
        mov ax, 0x8000
        or word [EmsMapCache], ax
        or word [EmsMapCache+2], ax
        or word [EmsMapCache+4], ax
        or word [EmsMapCache+6], ax
        retf

;-----------------------------------------------------------------------------
; EmsInit                                                     03A3:00E7  94 PC
; If no handle yet, check the INT 67h device name against EmmName, read the page frame, and allocate the
; smaller of the free page count and four times the long argument.
;
; The allocated count divided by 4 is stored through the far pointer at EmsOutPtr. EmsFree is registered with
; _onexit. Then calls LargestFreeBlock.
;
; Returns that call, or zero.
;-----------------------------------------------------------------------------
EmsInit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        push si
        push di
        cmp word [EmsHandle], -1
        jne short .3
        mov ax, 0x3567
        int 0x21
        mov di, 0xa
        mov si, EmmName
        mov cx, 4
        repe cmpsw
        jne short .4
        mov ah, 0x41
        int 0x67
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jne short .4
        mov word [EmsFrame], bx
        mov ax, word [bp + 6]
        mov dx, word [bp + 8]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .1
        inc dx
.1:
        mov word [bp - 2], dx
        mov ah, 0x42
        int 0x67
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jne short .4
        cmp bx, word [bp - 2]
        jb short .2
        mov bx, word [bp - 2]
.2:
        mov ah, 0x43
        int 0x67
        db 0x0A, 0xE4                           ; insn: or ah, ah
        jne short .4
        mov word [EmsHandle], dx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        les bx, [EmsOutPtr]
        mov word [es:bx], ax
        mov word [es:bx+2], dx
        push strict word 0x3A3
        push strict word EmsFree
        call 0x03A3:OnexitThunk
        add sp, 4
.3:
        call 0x148B:LargestFreeBlock
        pop di
        pop si
        leave
        retf
.4:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x33, 0xD2                           ; insn: xor dx, dx
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EmsFree                                                     03A3:017C  94 PC
; deallocate the EMS handle (INT 67h AH=45h) and store -1. _onexit calls this.
;-----------------------------------------------------------------------------
EmsFree:
        cmp word [EmsHandle], -1
        je short .1
        mov ah, 0x45
        mov dx, word [EmsHandle]
        int 0x67
        mov word [EmsHandle], 0xffff
.1:
        retf

;-----------------------------------------------------------------------------
; EmsMapFrame                                                 03A3:0192  94 PC
; map four physical pages at the 16K page of the long argument and
; return DX:AX (page frame, offset within the page).
;-----------------------------------------------------------------------------
EmsMapFrame:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        mov bx, word [bp + 8]
        mov ax, word [bp + 6]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xDB                           ; insn: adc bx, bx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xDB                           ; insn: adc bx, bx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, 4
        call EmsMap
        mov ax, word [bp + 6]
        and ax, 0x3fff
        mov dx, word [EmsFrame]
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; EmsSaveMap                                                  03A3:01B9  94 PC
; copy the four cached logical-page words to the near buffer in [bp+6].
;-----------------------------------------------------------------------------
EmsSaveMap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, EmsMapCache
        mov di, word [bp + 6]
        mov ax, ds
        mov es, ax
        mov cx, 4
        rep movsw
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; EmsRestoreMap                                               03A3:01D1  94 PC
; map the four logical pages in the near buffer back onto physical pages 0-3.
;-----------------------------------------------------------------------------
EmsRestoreMap:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov di, word [bp + 6]
        mov bx, word [di]
        mov al, 0
        mov cx, 1
        call EmsMap
        mov bx, word [di + 2]
        mov al, 1
        mov cx, 1
        call EmsMap
        mov bx, word [di + 4]
        mov al, 2
        mov cx, 1
        call EmsMap
        mov bx, word [di + 6]
        mov al, 3
        mov cx, 1
        call EmsMap
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ReadEndPtr                                                  03A3:0208  94 PC
; return the far pointer at TickTotal in DX:AX.
;-----------------------------------------------------------------------------
ReadEndPtr:
        les ax, [TickTotal]
        mov dx, es
        retf

;-----------------------------------------------------------------------------
; SetEndMark                                                  03A3:020F  94 PC
; store TickTotal plus the long argument at EndMark.
;-----------------------------------------------------------------------------
SetEndMark:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        les ax, [TickTotal]
        mov dx, es
        add ax, word [bp + 6]
        adc dx, word [bp + 8]
        mov word [EndMark], ax
        mov word [EndMark+2], dx
        leave
        retf

;-----------------------------------------------------------------------------
; WaitEnd                                                     03A3:0227  94 PC
; spin until TickTotal is at or past EndMark.
;-----------------------------------------------------------------------------
WaitEnd:
        les ax, [TickTotal]
        mov dx, es
        cmp dx, word [EndMark+2]
        jb short WaitEnd
        cmp ax, word [EndMark]
        jb short WaitEnd
        retf

;-----------------------------------------------------------------------------
; EndReached                                                  03A3:023A  94 PC
; AX is 1 when TickTotal is at or past EndMark, else 0.
;-----------------------------------------------------------------------------
EndReached:
        push cs
        call ReadEndPtr
        db 0x33, 0xC9                           ; insn: xor cx, cx
        cmp dx, word [EndMark+2]
        jb short .1
        cmp ax, word [EndMark]
        jb short .1
        inc cx
.1:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        retf

;-----------------------------------------------------------------------------
; WaitAdd                                                     03A3:0250  94 PC
; add the long argument to TickTotal, then spin until TickTotal reaches that sum.
;-----------------------------------------------------------------------------
WaitAdd:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push cs
        call ReadEndPtr
        add ax, word [bp + 6]
        adc dx, word [bp + 8]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.1:
        push cs
        call ReadEndPtr
        cmp dx, word [bp - 2]
        jb short .1
        cmp ax, word [bp - 4]
        jb short .1
        leave
        retf

;-----------------------------------------------------------------------------
; CopyFar                                                     03A3:0276  94 PC
; Copy the long byte count at [bp+0Eh] from the far pointer at [bp+6] to the far pointer at [bp+0Ah]. Offsets
; are kept under 16, then the copy moves 32K at a time. Word moves, or dword moves when Cpu386 is not zero.
;-----------------------------------------------------------------------------
CopyFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        lds si, [bp + 6]
        les di, [bp + 0xa]
        call NormDsSi
        call NormEsDi
        mov cx, word [bp + 0xe]
        mov dx, word [bp + 0x10]
        cld
        jmp short .2
.1:
        sub cx, 1
        sbb dx, 0
        jb short .5
        movsb
.2:
        test di, 0xf
        jne short .1
        cmp word [ss:Cpu386], 0
        jne short .6
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x13, 0xD2                           ; insn: adc dx, dx
        jmp short .4
.3:
        mov cx, 0x4000
        rep movsw
        sub si, 0x8000
        mov ax, ds
        add ax, 0x800
        mov ds, ax
        sub di, 0x8000
        mov ax, es
        add ax, 0x800
        mov es, ax
.4:
        dec dx
        jns short .3
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 0x7fff
        shr cx, 1
        rep movsw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep movsb
.5:
        pop di
        pop si
        pop ds
        leave
        retf
.6:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x66, 0x33, 0xC9                     ; insn: xor ecx, ecx
        and edi, 0xffff
        jmp short .8
.7:
        mov cx, 0x2000
        db 0xF3, 0x66, 0xA5                     ; insn: rep movsd
        sub si, 0x8000
        mov ax, ds
        add ax, 0x800
        mov ds, ax
        sub di, 0x8000
        mov ax, es
        add ax, 0x800
        mov es, ax
.8:
        dec dx
        jns short .7
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 0x7fff
        shr cx, 1
        shr cx, 1
        db 0xF3, 0x66, 0xA5                     ; insn: rep movsd
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 3
        rep movsb
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; CopyParas                                                   03A3:032C  94 PC
; copy BX paragraphs from the segment at [bp+6] to the segment at [bp+8].
;-----------------------------------------------------------------------------
CopyParas:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        cld
        mov ds, word [bp + 6]
        mov es, word [bp + 8]
        mov bx, word [bp + 0xa]
.1:
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je short .3
        mov cx, 0x8000
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        sub bx, 0x1000
        jae short .2
        add bx, 0x1000
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x33, 0xDB                           ; insn: xor bx, bx
.2:
        db 0x33, 0xF6                           ; insn: xor si, si
        db 0x33, 0xFF                           ; insn: xor di, di
        rep movsw
        mov ax, ds
        add ax, 0x1000
        mov ds, ax
        mov ax, es
        add ax, 0x1000
        mov es, ax
        jmp short .1
.3:
        pop di
        pop si
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; CopyParasDown                                               03A3:0374  94 PC
; the same copy, starting at the top so an overlap moves down safely.
;-----------------------------------------------------------------------------
CopyParasDown:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        std
        mov bx, word [bp + 0xa]
        mov ax, word [bp + 6]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov ds, ax
        mov ax, word [bp + 8]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov es, ax
.1:
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je short .3
        mov cx, 0x1000
        sub bx, 0x1000
        jae short .2
        add bx, 0x1000
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        db 0x33, 0xDB                           ; insn: xor bx, bx
.2:
        mov ax, ds
.4:
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov ds, ax
        mov ax, es
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov es, ax
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x03, 0xC0                           ; insn: add ax, ax
        dec ax
        dec ax
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        rep movsw
        jmp short .1
.3:
        cld
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; CritHandler                                                 03A3:03C8  94 PC
; INT 24h. Far-calls the routine whose address HookCrit stored.
;-----------------------------------------------------------------------------
CritHandler:
        push bx
        push dx
        push cx
        push si
        push di
        push ds
        push es
        push bp
        push ax
        mov ax, ss
        mov ds, ax
        mov bx, CritRoutine
        pop ax
        call far [bx]
        pop bp
        pop es
        pop ds
        pop di
        pop si
        pop cx
        pop dx
        pop bx
        iret

;-----------------------------------------------------------------------------
; HookCrit                                                    03A3:03E4  94 PC
; register CritRestore with _onexit, store the caller's far routine,
; save the old INT 24h vector, and point INT 24h at CritHandler.
;-----------------------------------------------------------------------------
HookCrit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push cs
        mov ax, CritRestore
        push ax
        call 0x03A3:OnexitThunk
        add sp, 4
        mov ax, word [bp + 6]
        mov word [CritRoutine], ax
        mov ax, word [bp + 8]
        mov word [CritRoutine+2], ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov bx, 4*0x24
        mov ax, word [es:bx]
        mov word [CritOld], ax
        mov ax, word [es:bx+2]
        mov word [CritOld+2], ax
        mov dx, CritHandler
        mov ax, cs
        mov ds, ax
        mov al, 0x24
        mov ah, 0x25
        int 0x21
        pop ds
        leave
        retf

;-----------------------------------------------------------------------------
; CritRestore                                                 03A3:0425  94 PC
; point INT 24h back at the saved vector, unless that vector's
; segment word equals its offset word.
;-----------------------------------------------------------------------------
CritRestore:
        push ds
        mov ax, word [CritOld+2]
        sub ax, word [CritOld]
        je short .1
        mov dx, word [CritOld]
        mov ds, word [CritOld+2]
        mov al, 0x24
        mov ah, 0x25
        int 0x21
.1:
        pop ds
        retf
        db 0x00


;-----------------------------------------------------------------------------
; PassFlag1                                                   03A3:0440  94 PC
; These four set SI and one flag byte, then ArgSetup stores the arguments and jumps to FillPoly. Nothing in
; the EXE far-calls them. PassFlag1 and PassFlag0 take the word at [bp+0Eh].
;
; AddrFlag0 and AddrFlag1 take its address. The flag is the byte at [bp-9]. ScanFn is set to 3ABBh.
;-----------------------------------------------------------------------------
PassFlag1:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov si, word [bp+0xe]
        mov byte [bp-9], 1
        jmp short ArgSetup

;-----------------------------------------------------------------------------
; PassFlag0                                                   03A3:0452  94 PC
; Sets SI from [bp+0Eh] and the flag byte to 0, then falls into ArgSetup.
;-----------------------------------------------------------------------------
PassFlag0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov si, word [bp+0xe]
        mov byte [bp-9], 0

ArgSetup:
        mov ax, word [bp+6]
        mov word [ScaleColor], ax
        mov ax, word [bp+0xa]
        mov word [ScaleMode], ax
        mov ax, word [bp+8]
        mov word [bp+6], ax
        mov ax, word [bp+0xc]
        mov word [bp+8], ax
        mov ax, 0x3abb
        mov word [ScanFn], ax
        mov ax, 0xc
        mov word [LineFn], ax
        jmp near FillPoly

;-----------------------------------------------------------------------------
; AddrFlag0                                                   03A3:0489  94 PC
; Sets SI to the address of [bp+0Eh] and the flag byte to 0, then jumps to
; ArgSetup.
;-----------------------------------------------------------------------------
AddrFlag0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        lea si, [bp+0xe]
        mov byte [bp-9], 0
        jmp short ArgSetup

;-----------------------------------------------------------------------------
; AddrFlag1                                                   03A3:049B  94 PC
; Sets SI to the address of [bp+0Eh] and the flag byte to 1, then jumps to
; ArgSetup.
;-----------------------------------------------------------------------------
AddrFlag1:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        lea si, [bp+0xe]
        mov byte [bp-9], 1
        jmp short ArgSetup

        db 0

;-----------------------------------------------------------------------------
; OnexitThunk                                                 03A3:04AE  94 PC
; Tail call. The far return from _onexit goes to this caller's caller.
;-----------------------------------------------------------------------------
OnexitThunk:
        jmp 0:_onexit

;-----------------------------------------------------------------------------
; ExitSavedSp                                                 03A3:04B3  94 PC
; If SavedSp is nonzero, SS becomes DGROUP and SP becomes that word. Then _exit(0).
;-----------------------------------------------------------------------------
ExitSavedSp:
        mov ax, DGROUP
        mov ds, ax
        cmp word [SavedSp], 0
        je short .1
        mov ss, ax
        mov sp, word [SavedSp]
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        call 0:_exit

        db 0

;-----------------------------------------------------------------------------
; FileSizeArg                                                 03A3:04CE  94 PC
; File length. Opens the path at [bp+6] for reading, seeks to the end, closes, and returns the length in
; DX:AX. The word at [bp-4] is nonzero to report a failed open through FatalError; zero returns AX 0 instead.
;
; FileSizeArg takes that word from the caller. FileSize forces zero. FileSizeMsg forces one.
;-----------------------------------------------------------------------------
FileSizeArg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push ds
        push si
        push di
        mov ax, word [bp+8]
        mov word [bp-4], ax
        jmp short FileSizeBody

;-----------------------------------------------------------------------------
; FileSize                                                    03A3:04DF  94 PC
; File length. A failed open returns 0.
;-----------------------------------------------------------------------------
FileSize:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push ds
        push si
        push di
        mov word [bp-4], 0
        jmp short FileSizeBody

;-----------------------------------------------------------------------------
; FileSizeMsg                                                 03A3:04EF  94 PC
; File length. A failed open calls FatalError. This is the far entry.
;-----------------------------------------------------------------------------
FileSizeMsg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push ds
        push si
        push di
        mov word [bp-4], 1

FileSizeBody:
        mov dx, word [bp+6]
        mov ah, 0x3d
        db 0x32, 0xC0                           ; insn: xor al, al
        int 0x21
        jae short .1
        cmp word [bp-4], 0
        jne short .2
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop di
        pop si
        pop ds
        leave
        retf
.2:
        mov ax, 0x6302
        mov bx, ss
        mov ds, bx
        push word [bp+6]
        push ax
        call 0xF4A:FatalError
.1:
        mov word [bp-2], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x2B, 0xC9                           ; insn: sub cx, cx
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov ax, 0x4202
        int 0x21
        push dx
        push ax
        mov bx, word [bp-2]
        mov ah, 0x3e
        int 0x21
        pop ax
        pop dx
        pop di
        pop si
        pop ds
        leave
        retf


;-----------------------------------------------------------------------------
; FileHeadArg                                                 03A3:0543  94 PC
; Open the path at [bp+6] and read four bytes. Bytes 1, 2 and 3 are a 24-bit count; byte 0 is unused. The
; result is that count divided by 16, plus 1 when the low nibble was set.
;
; The word at [bp-8] selects the failure path, same as FileSize. FileHeadArg takes it from the caller.
; FileHead forces 0 (return AX 0).
;
; FileHeadMsg forces 1 (call FatalError). That call is not followed by a return here: the next instruction is
; FindPath.
;-----------------------------------------------------------------------------
FileHeadArg:
        push bp
        db 0x8B, 0xEC
        add sp, -8
        push ds
        push si
        push di
        mov ax, word [bp+8]
        mov word [bp-8], ax
        jmp short FileHeadBody
;-----------------------------------------------------------------------------
; FileHead                                                    03A3:0554  94 PC
; Same as FileHeadArg with the failure flag forced to 0.
;-----------------------------------------------------------------------------
FileHead:
        push bp
        db 0x8B, 0xEC
        add sp, -8
        push ds
        push si
        push di
        mov word [bp-8], 0
        jmp short FileHeadBody
;-----------------------------------------------------------------------------
; FileHeadMsg                                                 03A3:0564  94 PC
; Same as FileHeadArg with the failure flag forced to 1. The FatalError call
; returns into FindPath.
;-----------------------------------------------------------------------------
FileHeadMsg:
        push bp
        db 0x8B, 0xEC
        add sp, -8
        push ds
        push si
        push di
        mov word [bp-8], 1
FileHeadBody:
        mov dx, word [bp+6]
        mov dx, word [bp+6]
        mov ah, 0x3d
        db 0x32, 0xC0
        int 0x21
        jae short .1
        jmp short .3
.1:
        mov word [bp-2], ax
        mov bx, word [bp-2]
        lea dx, [bp-6]
        mov cx, 4
        mov ah, 0x3f
        int 0x21
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jne short .2
        mov bx, word [bp-2]
        mov ah, 0x3e
        int 0x21
        mov ax, word [bp-5]
        mov dx, word [bp-3]
        db 0x32, 0xF6
        db 0x33, 0xDB
        test ax, 0xf
        je short .4
        mov bx, 1
.4:
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        db 0x03, 0xC3
        pop di
        pop si
        pop ds
        leave
        retf
.2:
        mov bx, word [bp-2]
        mov ah, 0x3e
        int 0x21
.3:
        cmp word [bp-8], 0
        jne short .5
        db 0x33, 0xC0
        pop di
        pop si
        pop ds
        leave
        retf
.5:
        mov ax, 0x6302
        mov bx, ss
        mov ds, bx
        push word [bp+6]
        push ax
        call 0xF4A:FatalError


; Find first file. Sets the DTA, searches with attribute 6, copies the
; directory part of the path (through the last ":" or "\") into PathBuf,
; then appends the 13-byte name from the DTA. Returns PathBuf, or 0.
FindPath:
        push bp
        db 0x8B, 0xEC
        push ds
        push si
        push di
        mov dx, FindDta
        mov ah, 0x1a
        int 0x21
        mov dx, word [bp+6]
        mov cl, 6
        mov ah, 0x4e
        int 0x21
        jb short FindNone
        mov di, PathBuf
        mov word [PathCut], di
        mov si, word [bp+6]
        mov cx, 0x57
        mov ax, ds
        mov es, ax
.1:
        lodsb
        stosb
        cmp al, 0
        je short FindCopyName
        cmp al, 0x3a
        je short .2
        cmp al, 0x5c
        jne short .3
.2:
        mov word [PathCut], di
.3:
        loop .1
FindCopyName:
        mov ax, ds
        mov es, ax
        mov si, FindDta+0x1e
        mov di, word [PathCut]
        mov cx, 0xd
        cld
        rep movsb
        mov ax, PathBuf
FindExit:
        pop di
        pop si
        pop ds
        leave
        retf
FindNone:                                       ; returns AX 0 through FindPath's epilogue; used by
                                                ; FileHeadMsg, FindNextPath
        db 0x33, 0xC0
        jmp short FindExit


;-----------------------------------------------------------------------------
; FindNextPath                                                03A3:0644  94 PC
; Find next file and append that DTA name at the same cut. Returns PathBuf, or 0.
;-----------------------------------------------------------------------------
FindNextPath:
        push bp
        db 0x8B, 0xEC
        push ds
        push si
        push di
        mov dx, FindDta
        mov ah, 0x1a
        int 0x21
        mov ah, 0x4f
        int 0x21
        jb short FindNone
        jmp short FindCopyName
        db 0


;-----------------------------------------------------------------------------
; LargestFree                                                 03A3:065A  94 PC
; INT 21h AH=48h with BX=FFFFh. That fails and leaves the largest free
; block in BX. Returns that size in bytes (paragraphs shifted up by 4).
;-----------------------------------------------------------------------------
LargestFree:
        push si
        push di
        mov bx, 0xffff
        mov ah, 0x48
        int 0x21
        db 0x8B, 0xC3
        db 0x33, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; AllocBytes                                                  03A3:067A  94 PC
; DX:AX is a byte size, not a stack argument. Rounds it up to paragraphs and allocates that. If the alloc
; fails, the second AH=48h uses the largest block DOS reported in BX.
;
; Stores CS, DS, SP, the block segment and the paragraph past the block. Returns the allocated size in bytes.
;-----------------------------------------------------------------------------
AllocBytes:
        push si
        push di
        mov word [SavedCs], cs
        mov word [SavedDs], ds
        mov word [SavedSp], sp
        add ax, 0xf
        adc dx, 0
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        shr dx, 1
        rcr ax, 1
        db 0x8B, 0xD8
        mov ah, 0x48
        int 0x21
        jae short .1
        mov ah, 0x48
        int 0x21
.1:
        mov word [BlockSeg], ax
        db 0x03, 0xC3
        mov word [BlockEnd], ax
        db 0x8B, 0xC3
        db 0x33, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        db 0x03, 0xC0
        db 0x13, 0xD2
        pop di
        pop si
        retf

        db 0

;-----------------------------------------------------------------------------
; FoldScale                                                   03A3:06CA  94 PC
; Call Atan2 with the two words, take the absolute value, and fold it: at or above 100h it becomes 200h minus
; the value.
;
; Above 80h the result comes from SinLookup and the first word; otherwise from CosLookup and the second word.
; The dividend is the absolute word shifted left 14, then divided by that result.
;-----------------------------------------------------------------------------
FoldScale:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push word [bp+8]
        push word [bp+6]
        call 0x03A3:Atan2
        add sp, 4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jge short .1
        neg ax
.1:
        cmp ax, 0x100
        jl short .2
        sub ax, 0x200
        neg ax
.2:
        cmp ax, 0x80
        jg short .4
        push ax
        call 0x03A3:CosLookup
        add sp, 2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov dx, word [bp+8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jge short .3
        neg dx
.3:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        div bx
        leave
        retf
.4:
        push ax
        call 0x03A3:SinLookup
        add sp, 2
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov dx, word [bp+6]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jge short .5
        neg dx
.5:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sar dx, 1
        rcr ax, 1
        sar dx, 1
        rcr ax, 1
        div bx
        leave
        retf

;-----------------------------------------------------------------------------
; RetZero                                                     03A3:0734  94 PC
; Xor ax, ax / retf.
;-----------------------------------------------------------------------------
RetZero:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf

        db 0

;-----------------------------------------------------------------------------
; MapEsBx                                                     03A3:0738  94 PC
; Near. Mark the EMS map stale, map the long at [bp+4], and return it in ES:BX.
;-----------------------------------------------------------------------------
MapEsBx:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        call 0x03A3:EmsMarkStale
        mov ax, word [bp+6]
        push ax
        mov ax, word [bp+4]
        push ax
        call 0x03A3:EmsMapFrame
        add sp, 4
        mov es, dx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        leave
        ret

;-----------------------------------------------------------------------------
; PadSpace4                                                   03A3:0756  94 PC
; Near. Walk at most four bytes at SI. After a 0, fill the rest of the four with spaces.
;-----------------------------------------------------------------------------
PadSpace4:
        cld
        mov cx, 4
.1:
        cmp byte [si], 0
        je short .2
        inc si
        loop .1
        ret
.2:
        mov byte [si], 0x20
        inc si
        loop .2
        ret

;-----------------------------------------------------------------------------
; LookupArg                                                   03A3:076A  94 PC
; Look up a 4-byte key at [bp+0Ah] in the block addressed by the long at [bp+6]. The word at [bp-2] is the
; failure flag: LookupArg takes it from the caller, Lookup forces 0, LookupMsg forces 1. A hit returns a long.
;
; A miss returns 0, or calls FatalError when the flag is 1.
;-----------------------------------------------------------------------------
LookupArg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        push si
        push di
        mov ax, word [bp+0xc]
        mov word [bp-2], ax
        jmp short LookupBody
;-----------------------------------------------------------------------------
; Lookup                                                      03A3:077A  94 PC
; Same lookup with the failure flag forced to 0.
;-----------------------------------------------------------------------------
Lookup:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        push si
        push di
        mov word [bp-2], 0
        jmp short LookupBody
;-----------------------------------------------------------------------------
; LookupMsg                                                   03A3:0789  94 PC
; Same lookup with the failure flag forced to 1, which calls FatalError.
;-----------------------------------------------------------------------------
LookupMsg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        push si
        push di
        mov word [bp-2], 1
LookupBody:
        mov ax, word [bp+6]
        mov dx, word [bp+8]
        db 0x0B, 0xC2                           ; insn: or ax, dx
        je short .miss
        mov ax, 8
        push ax
        push word [bp+8]
        push word [bp+6]
        call MapEsBx
        add sp, 6
        mov ax, word [es:bx+4]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        add ax, 8
        push ax
        push word [bp+8]
        push word [bp+6]
        call MapEsBx
        add sp, 6
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov si, word [bp+0xa]
        call PadSpace4
        mov dx, word [es:di+4]
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je short .none
        add di, 6
        db 0x8B, 0xDF                           ; insn: mov bx, di
.rec:
        db 0x8B, 0xFB                           ; insn: mov di, bx
        mov si, word [bp+0xa]
        mov cx, 4
.cmp:
        cmpsb
        jne short .ne
        loop .cmp
        jmp short .hit
.ne:
        cmp byte [es:di-1], 0
        jne short .next
        cmp byte [si-1], 0x20
        je short .hit
.next:
        add bx, 4
        dec ax
        jge short .rec
.none:
        cmp word [bp-2], 1
        jne short .miss
        mov dx, 0x6430
        push word [bp+0xa]
        push dx
        call 0xF4A:FatalError
.miss:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        pop di
        pop si
        leave
        retf
.hit:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        add ax, 6
        add ax, word [bp+6]
        mov dx, word [bp+8]
        adc dx, 0
        add ax, word [es:bx]
        adc dx, word [es:bx+2]
        pop di
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; FindFar                                                     03A3:083E  94 PC
; Look up the long at the near pointer [bp+8] in the far table at [bp+4]. Records start at offset 6 and are
; four bytes. A miss with BX nonzero calls FatalError.
;
; A hit returns the far pointer stored after the keys, added to DS. FindFar passes no message. FindFarAlt
; passes the sound-not-found message, FindFarMsg the shape-not-found message.
;-----------------------------------------------------------------------------
FindFar:
        db 0x33, 0xDB                           ; insn: xor bx, bx
        jmp short FindFarBody
;-----------------------------------------------------------------------------
; FindFarAlt                                                  03A3:0842  94 PC
; Same lookup. On a miss calls FatalError with the sound-not-found message.
;-----------------------------------------------------------------------------
FindFarAlt:
        mov bx, str_Locatesound44sSoundNot
        jmp short FindFarBody
;-----------------------------------------------------------------------------
; FindFarMsg                                                  03A3:0847  94 PC
; Same lookup. On a miss calls FatalError with the shape-not-found message. _main calls
; this.
;-----------------------------------------------------------------------------
FindFarMsg:
        mov bx, str_Locateshape44sShapeNot
FindFarBody:
        db 0x8B, 0xC4                           ; insn: mov ax, sp
        push bp
        push si
        push ds
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        mov si, word [bp+8]
        mov ax, word [si]
        mov dx, word [si+2]
        lds si, [bp+4]
        mov cx, word [si+4]
        add si, 6
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jne short .scan
.miss:
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je short .zero
        mov ax, ss
        mov ds, ax
        push word [bp+8]
        push bx
        call 0xF4A:FatalError
.zero:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp short .leave
.jcx:
        jcxz .miss
.next:
        add si, 4
.scan:
        cmp dx, word [si+2]
        loopne .next
        jne short .miss
        cmp ax, word [si]
        jne short .jcx
        mov bx, word [bp+4]
        mov ax, word [bx+4]
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xF0                           ; insn: add si, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        add ax, 6
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov dx, word [si]
        and dx, 0xf
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov dx, word [si]
        mov cx, word [si+2]
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        mov cx, ds
        db 0x03, 0xD1                           ; insn: add dx, cx
.leave:
        pop ds
        pop si
        pop bp
        retf

;-----------------------------------------------------------------------------
; FindFarList                                                 03A3:08C4  94 PC
; Walk keys at [bp+8] until a 0 byte. Each call of FindFarMsg stores DX:AX at DI.
;-----------------------------------------------------------------------------
FindFarList:
        db 0x8B, 0xC4                           ; insn: mov ax, sp
        push si
        push di
        push bp
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        mov si, word [bp+8]
        mov di, word [bp+0xa]
        push si
        push word [bp+6]
        push word [bp+4]
        jmp short .2
.1:
        mov word [bp-8], si
        call 0x03A3:FindFarMsg
        mov word [di], ax
        mov word [di+2], dx
        add di, 4
        add si, 4
.2:
        cmp byte [si], 0
        jne short .1
        add sp, 6
        pop bp
        pop di
        pop si
        retf

;-----------------------------------------------------------------------------
; FindFarQuiet                                                03A3:08F9  94 PC
; The same walk, calling FindFar so a miss stays quiet.
;-----------------------------------------------------------------------------
FindFarQuiet:
        db 0x8B, 0xC4                           ; insn: mov ax, sp
        push si
        push di
        push bp
        db 0x8B, 0xE8                           ; insn: mov bp, ax
        mov si, word [bp+8]
        mov di, word [bp+0xa]
        push si
        push word [bp+6]
        push word [bp+4]
        jmp short .2
.1:
        mov word [bp-8], si
        call 0x03A3:FindFar
        mov word [di], ax
        mov word [di+2], dx
        add di, 4
        add si, 4
.2:
        cmp byte [si], 0
        jne short .1
        add sp, 6
        pop bp
        pop di
        pop si
        retf

;-----------------------------------------------------------------------------
; FarToLinear                                                 03A3:092E  94 PC
; Far pointer on the stack to a 20-bit address in DX:AX.
;-----------------------------------------------------------------------------
FarToLinear:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+6]
        rol ax, 4
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        and ax, 0xfff0
        and dx, 0xf
        add ax, word [bx+4]
        adc dx, 0
        retf

;-----------------------------------------------------------------------------
; LinearToFar                                                 03A3:0945  94 PC
; 20-bit address on the stack back to a far pointer with offset under 16.
;-----------------------------------------------------------------------------
LinearToFar:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+4]
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        and ax, 0xf
        and dx, 0xfff0
        or dx, word [bx+6]
        ror dx, 4
        retf

;-----------------------------------------------------------------------------
; LinearToFarRegs                                             03A3:0959  94 PC
; Same conversion with the low word in AX and the high word in DX.
;-----------------------------------------------------------------------------
LinearToFarRegs:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        and ax, 0xf
        and bx, 0xfff0
        db 0x0B, 0xD3                           ; insn: or dx, bx
        ror dx, 4
        retf

        db 0

;-----------------------------------------------------------------------------
; CopyBytes                                                   03A3:0968  94 PC
; Copy the word count at [bp+0Eh] from the far pointer at [bp+0Ah]
; to the far pointer at [bp+6]. The high half of the count is zero.
;-----------------------------------------------------------------------------
CopyBytes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        push word [bp+0xe]
        push word [bp+8]
        push word [bp+6]
        push word [bp+0xc]
        push word [bp+0xa]
        call 0x03A3:CopyFar
        add sp, 0xc
        leave
        retf

        db 0

;-----------------------------------------------------------------------------
; FormatCall                                                  03A3:0988  94 PC
; Pops the far return address and two words. Calls _sprintf with FmtBuf, then calls the VGA library with those
; two words and FmtBuf, then far-returns through the saved address.
;
; No far call in the EXE lands on this entry.
;-----------------------------------------------------------------------------
FormatCall:
        pop ax
        mov word [FmtSave], ax
        pop ax
        mov word [FmtSave+2], ax
        pop ax
        mov word [FmtSave+4], ax
        pop ax
        mov word [FmtSave+6], ax
        mov ax, FmtBuf
        push ax
        call 0:_sprintf
        add sp, 2
        push word [FmtSave+6]
        push word [FmtSave+4]
        mov ax, FmtBuf
        push ax
        call 0xFEF:DrawChar
        add sp, 2
        push word [FmtSave+2]
        push word [FmtSave]
        retf

        db 0

;-----------------------------------------------------------------------------
; ImulWords                                                   03A3:09C2  94 PC
; Signed product of the two stack words, in DX:AX.
;-----------------------------------------------------------------------------
ImulWords:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+4]
        mov dx, word [bx+6]
ImulRegs:
        imul dx
        retf

;-----------------------------------------------------------------------------
; MulWords                                                    03A3:09CD  94 PC
; Unsigned product of the two stack words, in DX:AX.
;-----------------------------------------------------------------------------
MulWords:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+4]
        mov dx, word [bx+6]
MulRegs:
        mul dx
        retf

;-----------------------------------------------------------------------------
; IdivWords                                                   03A3:09D8  94 PC
; Signed DX:AX divided by the third stack word.
;-----------------------------------------------------------------------------
IdivWords:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+4]
        mov dx, word [bx+6]
        mov bx, word [bx+8]
.regs:                                          ; entry with DX:AX and BX already loaded
        idiv bx
        retf

;-----------------------------------------------------------------------------
; DivWords                                                    03A3:09E6  94 PC
; Unsigned DX:AX divided by the third stack word.
;-----------------------------------------------------------------------------
DivWords:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx+4]
        mov dx, word [bx+6]
        mov bx, word [bx+8]
.regs:                                          ; entry with DX:AX and BX already loaded
        div bx
        retf

;-----------------------------------------------------------------------------
; Idiv32                                                      03A3:09F4  94 PC
; Signed DX:AX divided by BX. Quotient comes back in DX:AX.
;-----------------------------------------------------------------------------
Idiv32:
        shl edx, 0x10
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        db 0x66, 0x8B, 0xC2                     ; insn: mov eax, edx
        movzx ecx, bx
        db 0x66, 0x33, 0xD2                     ; insn: xor edx, edx
        idiv ecx
        db 0x66, 0x8B, 0xD0                     ; insn: mov edx, eax
        shr edx, 0x10
        retf

;-----------------------------------------------------------------------------
; IdivDword                                                   03A3:0A0F  94 PC
; Stack dword divided by the stack word. The high half is cleared first.
; Quotient comes back in DX:AX.
;-----------------------------------------------------------------------------
IdivDword:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        db 0x66, 0x33, 0xD2                     ; insn: xor edx, edx
        mov eax, dword [bx+4]
        movzx ebx, word [bx+8]
        idiv ebx
        db 0x66, 0x8B, 0xD0                     ; insn: mov edx, eax
        shr edx, 0x10
        retf

;-----------------------------------------------------------------------------
; WriteFile                                                   03A3:0A28  94 PC
; Create the path at [bp+6] and write the far buffer at [bp+8]. The long at [bp+0Ch] is the byte count, moved
; 16K at a time. A short write or a DOS error deletes the file.
;
; This entry then calls FatalError and returns 0.
;-----------------------------------------------------------------------------
WriteFile:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        push si
        push di
        mov word [bp - 4], 0
        jmp short WriteFileBody


;-----------------------------------------------------------------------------
; WriteFileCode                                               03A3:0A38  94 PC
; The same write. Returns the DOS error, or 1 when a write was short.
;-----------------------------------------------------------------------------
WriteFileCode:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        push si
        push di
        mov word [bp - 4], 1

WriteFileBody:
        mov dx, word [bp + 6]
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov ah, 0x3c
        int 0x21
        jb short .A9D
        mov word [bp - 2], ax
.A54:
        cmp word [bp + 0xc], 0
        jne short .A60
        cmp word [bp + 0xe], 0
        je short .ACB
.A60:
        mov cx, 0x4000
        mov ax, word [bp + 0xc]
        sub word [bp + 0xc], cx
        sbb word [bp + 0xe], 0
        jae short .A80
        mov cx, word [bp + 0xc]
        mov word [bp + 0xc], 0
        mov word [bp + 0xe], 0
        add cx, 0x4000
.A80:
        mov ds, word [bp + 0xa]
        mov dx, word [bp + 8]
        mov bx, word [bp - 2]
        mov ah, 0x40
        int 0x21
        jb short .A9D
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jne short .A9A
        add word [bp + 0xa], 0x400
        jmp short .A54
.A9A:
        mov ax, 1
.A9D:
        mov word [bp - 6], ax
        mov bx, word [bp - 2]
        mov ah, 0x3e
        int 0x21
        mov ax, ss
        mov ds, ax
        mov dx, word [bp + 6]
        mov ah, 0x41
        int 0x21
        mov ax, word [bp - 6]
        cmp word [bp - 4], 0
        jne short .AD4
        mov ax, ss
        mov ds, ax
        mov ax, 0x6d3e
        push word [bp + 6]
        push ax
        call 0xF4A:FatalError
.ACB:
        mov bx, word [bp - 2]
        mov ah, 0x3e
        int 0x21
        db 0x33, 0xC0                           ; insn: xor ax, ax
.AD4:
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00


;-----------------------------------------------------------------------------
; RoundSeg                                                    03A3:0ADA  94 PC
; Add (offset+15)/16 to the segment. AX is 0.
;-----------------------------------------------------------------------------
RoundSeg:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov dx, word [bx + 4]
        add dx, 0xf
        shr dx, 4
        add dx, word [bx + 6]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf
        db 0x00


;-----------------------------------------------------------------------------
; TableCount                                                  03A3:0AEC  94 PC
; Return the word at offset 4 of the far structure.
;-----------------------------------------------------------------------------
TableCount:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        les bx, [bx + 4]
        mov ax, word es:[bx + 4]
        retf


;-----------------------------------------------------------------------------
; TableAt                                                     03A3:0AF6  94 PC
; Far pointer for the entry index, or 0 when the index is past the count.
; The pointer is normalized the same way FindFar normalizes a hit.
;-----------------------------------------------------------------------------
TableAt:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov dx, word [bx + 8]
        les bx, [bx + 4]
        mov ax, word es:[bx + 4]
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jae short .B3F
        db 0x03, 0xD0                           ; insn: add dx, ax
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xD2                           ; insn: add dx, dx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC3                           ; insn: add ax, bx
        add ax, 6
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov dx, word es:[bx + 6]
        and dx, 0xf
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov dx, word es:[bx + 6]
        mov cx, word es:[bx + 8]
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        shr cx, 1
        rcr dx, 1
        mov cx, es
        db 0x03, 0xD1                           ; insn: add dx, cx
        retf
.B3F:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        retf


;-----------------------------------------------------------------------------
; TableStore                                                  03A3:0B44  94 PC
; Store that entry's dword through the near pointer, or store 0.
;-----------------------------------------------------------------------------
TableStore:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 8]
        mov cx, word [bx + 0xa]
        les bx, [bx + 4]
        cmp ax, word es:[bx + 4]
        jae short .B6B
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov ax, word es:[bx + 6]
        mov dx, word es:[bx + 8]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov word [bx], ax
        mov word [bx + 2], dx
        retf
.B6B:
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        mov word [bx], 0
        mov word [bx + 2], 0
        retf
        db 0x00


;-----------------------------------------------------------------------------
; PathTail                                                    03A3:0B78  94 PC
; DX:AX points just past the last colon, at-sign, slash, or backslash.
; PathTail reads a near string. PathTailFar reads a far string.
;-----------------------------------------------------------------------------
PathTail:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        mov si, word [bp + 6]
        jmp short PathTailBody

;-----------------------------------------------------------------------------
; PathTailFar                                                 03A3:0B82  94 PC
; Same scan of a far string.
;-----------------------------------------------------------------------------
PathTailFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        lds si, [bp + 6]

PathTailBody:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        cld
.B8D:
        lodsb
        db 0x0A, 0xC0                           ; insn: or al, al
        je short .BA6
        cmp al, 0x3a
        je short .BA2
        cmp al, 0x40
        je short .BA2
        cmp al, 0x2f
        je short .BA2
        cmp al, 0x5c
        jne short .B8D
.BA2:
        db 0x8B, 0xDE                           ; insn: mov bx, si
        jmp short .B8D
.BA6:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, ds
        pop si
        pop ds
        leave
        retf


;-----------------------------------------------------------------------------
; CopyStrN                                                    03A3:0BAE  94 PC
; Copy bytes, including the null, and stop at the null or at the count.
; CopyStrN reads a near string. CopyStrNFar reads a far string. The destination is far.
;-----------------------------------------------------------------------------
CopyStrN:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        mov si, word [bp + 0xa]
        mov cx, word [bp + 0xc]
        jmp short CopyStrNBody

;-----------------------------------------------------------------------------
; CopyStrNFar                                                 03A3:0BBC  94 PC
; Same copy from a far string.
;-----------------------------------------------------------------------------
CopyStrNFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        lds si, [bp + 0xa]
        mov cx, word [bp + 0xe]

CopyStrNBody:
        les di, [bp + 6]
        cld
.BCC:
        lodsb
        stosb
        db 0x0A, 0xC0                           ; insn: or al, al
        loopne .BCC
        pop di
        pop si
        pop ds
        leave
        retf


;-----------------------------------------------------------------------------
; StrnDiff                                                    03A3:0BD7  94 PC
; Compare up to the count. AX is 0 when the bytes match through a null, else 1.
;-----------------------------------------------------------------------------
StrnDiff:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push si
        push di
        lds si, [bp + 0xa]
        les di, [bp + 6]
        mov cx, word [bp + 0xe]
        cld
        mov ax, 1
.BEA:
        cmpsb
        jne short .BF4
        cmp byte [si - 1], ah
        loopne .BEA
        db 0x33, 0xC0                           ; insn: xor ax, ax
.BF4:
        pop di
        pop si
        pop ds
        leave
        retf
        db 0x00

;-----------------------------------------------------------------------------
; TextWidth                                                   03A3:0BFA  94 PC
; Sum per-character values from the table in CharSeg. [bp+8] is how many characters to read; zero returns 0.
; The word at ES:10h is the value used when the flag byte at ES:14h is set.
;
; Otherwise the word at ES:(char*2+16h).
;-----------------------------------------------------------------------------
TextWidth:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov dx, word [bp + 8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jne short TextWidthBody
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp short TextWidthBody.3


;-----------------------------------------------------------------------------
; TextWidthAll                                                03A3:0C0A  94 PC
; The same sum through the terminating 0.
;-----------------------------------------------------------------------------
TextWidthAll:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        db 0x33, 0xD2                           ; insn: xor dx, dx

TextWidthBody:
        mov es, word [CharSeg]
        mov si, word [bp + 6]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cl, byte es:[0x14]
        mov di, word es:[0x10]
.1:
        mov bl, byte [si]
        db 0x0A, 0xDB                           ; insn: or bl, bl
        je short .3
        inc si
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov bx, word es:[bx + 0x16]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je short .1
        db 0x0A, 0xC9                           ; insn: or cl, cl
        je short .2
        mov bl, byte es:[bx]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x8B, 0xFB                           ; insn: mov di, bx
.2:
        db 0x03, 0xC7                           ; insn: add ax, di
        dec dx
        je short .3
        jmp short .1
.3:
        pop di
        pop si
        leave
        retf
        db 0x00


;-----------------------------------------------------------------------------
; SetCharPtr                                                  03A3:0C4E  94 PC
; Store the far pointer at the start of the CharSeg block.
;-----------------------------------------------------------------------------
SetCharPtr:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
.regs:
        mov es, word [CharSeg]
        mov word es:[0], ax
        mov word es:[2], dx
        retf


;-----------------------------------------------------------------------------
; SetCharPtr2                                                 03A3:0C64  94 PC
; Store the far pointer at offset 8 of the CharSeg block.
;-----------------------------------------------------------------------------
SetCharPtr2:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
        mov es, word [CharSeg]
        mov word es:[8], ax
        mov word es:[0xa], dx
        retf


;-----------------------------------------------------------------------------
; SaveCharTab                                                 03A3:0C7A  94 PC
; Copy 11 words from the start of CharSeg into the near buffer, and
; store CharSeg at offset 16h of that buffer.
;-----------------------------------------------------------------------------
SaveCharTab:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        push di
        push si
        db 0x33, 0xF6                           ; insn: xor si, si
        mov di, word [bp + 6]
        mov ax, ds
        mov es, ax
        mov ds, word [CharSeg]
        cld
        mov word es:[di + 0x16], ds
        mov cx, 0xb
        rep movsw
        pop si
        pop di
        pop ds
        leave
        retf


;-----------------------------------------------------------------------------
; LoadCharTab                                                 03A3:0C9C  94 PC
; The reverse. The segment word at offset 16h of the buffer becomes CharSeg.
;-----------------------------------------------------------------------------
LoadCharTab:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, word [bp + 6]
        mov ax, word [si + 0x16]
        mov word [CharSeg], ax
        mov es, ax
        db 0x33, 0xFF                           ; insn: xor di, di
        cld
        mov cx, 0xb
        rep movsw
        pop si
        pop di
        leave
        retf


;-----------------------------------------------------------------------------
; UseCharSeg                                                  03A3:0CB8  94 PC
; Normalize the far pointer and store its segment as CharSeg.
;-----------------------------------------------------------------------------
UseCharSeg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        les di, [bp + 6]
        call NormEsDi
        mov word [CharSeg], es
        pop di
        leave
        retf
        db 0x00


;-----------------------------------------------------------------------------
; HookInt8                                                    03A3:0CCA  94 PC
; Write 0B6h to port 43h, mask IRQ 0 and IRQ 1, point INT 8 at Int8Handler if that is not already the vector,
; unmask, and write 2E9Ch to port 40h. Registers UnhookInt8 with _onexit. _main calls this.
;-----------------------------------------------------------------------------
HookInt8:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov dx, 0x2e9c
        mov word [TickStep], 0x2e9b
        cli
        mov word [TickFrac], 0
        mov word [TickGate], 1
        mov word [SlotTab], 0
        mov word [TickSkipCount], 0
        mov word [cs:Int8Ds], ds
        sti
        mov al, 0xb6
        out 0x43, al
        in al, 0x21
        or al, 3
        out 0x21, al
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        cli
        mov ax, word es:[0x20]
        cmp ax, Int8Handler
        je short .1
        mov word [OldInt8Off], ax
.1:
        mov ax, word es:[0x22]
        mov bx, cs
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        je short .2
        mov word [OldInt8Seg], ax
        mov word [es:0x20], Int8Handler
        mov word es:[0x22], cs
        mov word [TickHookOff], EmptyRet
        mov word [TickHookSeg], cs
.2:
        in al, 0x21
        and al, 0xfc
        out 0x21, al
        sti
        db 0x8A, 0xC2                           ; insn: mov al, dl
        out 0x40, al
        db 0x8A, 0xC6                           ; insn: mov al, dh
        out 0x40, al
        push cs
        mov ax, UnhookInt8
        push ax
        call 0x03A3:OnexitThunk
        add sp, 4
        leave
        retf


;-----------------------------------------------------------------------------
; UnhookInt8                                                  03A3:0D51  94 PC
; If INT 8 still points at Int8Handler, mask IRQ 0 and IRQ 1, restore the
; saved vector, unmask, and write 0 to port 40h twice.
;-----------------------------------------------------------------------------
UnhookInt8:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov ax, word es:[0x22]
        mov dx, cs
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        je short .1
        retf
.1:
        mov ax, word es:[0x20]
        cmp ax, Int8Handler
        je short .2
        retf
.2:
        in al, 0x21
        or al, 3
        out 0x21, al
        cli
        mov ax, word [OldInt8Off]
        mov word es:[0x20], ax
        mov ax, word [OldInt8Seg]
        mov word es:[0x22], ax
        in al, 0x21
        and al, 0xfc
        out 0x21, al
        sti
        db 0x32, 0xC0                           ; insn: xor al, al
        out 0x40, al
        out 0x40, al


; Find a free pair in the eight pairs of SlotTab and store the two arguments.
; Calls FatalError when every pair is in use. _main calls this.
AllocSlot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov cx, 8
        mov bx, 0x6db4
.1:
        cmp word [bx + 2], 0
        je short .2
        add bx, 4
        loop .1
        mov ax, 0x6ddc
        push ax
        call 0xF4A:FatalError
.2:
        mov ax, word [bp + 6]
        mov word [bx], ax
        mov word [bx + 2], 0
        mov ax, word [bp + 8]
        mov word [bx + 2], ax
        mov word [bx + 6], 0
        leave
        retf

;-----------------------------------------------------------------------------
; FreeSlot                                                    03A3:0DC0  94 PC
; Remove the pair at SlotTab that matches the two arguments, and slide the
; later pairs down. The last pair is cleared.
;-----------------------------------------------------------------------------
FreeSlot:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov cx, 8
        mov bx, SlotTab
        mov ax, word [bp + 6]
        mov dx, word [bp + 8]
.1:
        cmp word [bx], ax
        jne short .2
        cmp word [bx + 2], dx
        je short .3
.2:
        add bx, 4
        loop .1
        leave
        retf
.3:
        cli
        dec cx
        je short .5
.4:
        mov ax, word [bx + 4]
        mov word [bx], ax
        mov ax, word [bx + 6]
        mov word [bx + 2], ax
        add bx, 4
        loop .4
.5:
        mov word [bx], 0
        mov word [bx + 2], 0
        sti
        leave
        retf


;-----------------------------------------------------------------------------
; CountSlots                                                  03A3:0DFF  94 PC
; AX is how many SlotTab pairs have a nonzero second word.
;-----------------------------------------------------------------------------
CountSlots:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov bx, SlotTab
.1:
        cmp word [bx + 2], 0
        je short .2
        add bx, 4
        inc ax
        jmp short .1
.2:
        retf


;-----------------------------------------------------------------------------
; SsIsDs                                                      03A3:0E11  94 PC
; AX is 1 when SS equals DS, else 0.
;-----------------------------------------------------------------------------
SsIsDs:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov bx, ss
        mov dx, ds
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jne short .1
        inc ax
.1:
        retf


;-----------------------------------------------------------------------------
; EmptyRet                                                    03A3:0E1D  94 PC
; A far return. HookInt8 stores this address next to the old INT 8 vector.
;-----------------------------------------------------------------------------
EmptyRet:
        retf
Int8Ds:                                         ; word in the code segment. HookInt8 stores DS here and
                                                ; Int8Handler loads it; used by HookInt8
        dw 0


;-----------------------------------------------------------------------------
; Int8Handler                                                 03A3:0E20  94 PC
; INT 8. Loads DS from Int8Ds. Sends EOI unless SkipEoi is set. When TickGate drops to 0 and TickSkip is
; clear, switches to the stack at Int8Sp and far-calls every SlotTab pair whose second word is nonzero.
;
; Adds TickStep into TickFrac.
;
; On carry, bumps TickTotal and the BIOS tick at 0:046Ch, rolls that tick over at midnight, and turns the
; floppy motors off when the BIOS motor count reaches 0.
;-----------------------------------------------------------------------------
Int8Handler:
        push ds
        push ax
        mov ds, word cs:[0xe1e]
        cmp word [SkipEoi], 0
        jne short .1
        mov al, 0x20
        out 0x20, al
.1:
        sti
        push bx
        dec word [TickGate]
        jne short .4
        cmp byte [TickSkip], 0
        jne short .4
        push cx
        push dx
        push si
        push es
        mov ax, ss
        mov word [Int8Sp], sp
        mov word [Int8Ss], ax
        mov ax, ds
        mov ss, ax
        mov sp, 0x6f04
        mov si, SlotTab
        cld
        inc word [CallCount]
        jne short .3
        inc word [0x6da2]
        jmp short .3
.2:
        db 0xFF, 0x1C                           ; insn: lcall [si]
        add si, 4
.3:
        cmp word [si + 2], 0
        jne short .2
        mov ax, word [Int8Ss]
        mov ss, ax
        mov sp, word [Int8Sp]
        pop es
        pop si
        pop dx
        pop cx
.4:
        inc word [TickGate]
        mov ax, word [TickStep]
        add word [TickFrac], ax
        jae short .8
        inc word [TickTotal]
        jne short .5
        inc word [TickCountAll]
.5:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov ds, ax
        mov bx, 0x46c
        inc word [bx]
        jne short .6
        inc word [bx + 2]
.6:
        cmp word [bx + 2], 0x18
        jb short .7
        cmp word [bx], 0xb0
        jb short .7
        mov word [bx], ax
        mov word [bx + 2], ax
        mov byte [bx + 4], 1
.7:
        dec byte [0x440]
        jne short .8
        push dx
        mov dx, 0x3f2
        mov al, 0xf
        out dx, al
        pop dx
        and byte [0x43f], 0xf0
.8:
        pop bx
        pop ax
        pop ds
        iret


;-----------------------------------------------------------------------------
; ResetText                                                   03A3:0ECE  94 PC
; If WantText is nonzero, clears it, calls the VGA library, forces the BIOS equipment
; word to 80-column color, and sets video mode 3 with background 0.
;-----------------------------------------------------------------------------
ResetText:
        cmp word [WantText], 0
        je short .1
        mov word [WantText], 0
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        call 0xFEF:ClearScreenColor
        add sp, 2
        mov ax, 0x40
        mov es, ax
        mov ax, word es:[0x10]
        and ax, 0xffcf
        or ax, 0x10
        mov word es:[0x10], ax
        db 0x32, 0xE4                           ; insn: xor ah, ah
        mov al, 3
        int 0x10
        mov ah, 0xb
        mov bx, 0
        int 0x10
.1:
        retf

        db 0x00


;-----------------------------------------------------------------------------
; PollJoy                                                     03A3:0F08  94 PC
; If bit 0 of JoyOn is clear, return JoyBits. Otherwise read port 201h. Bits 4 and 5 are the buttons. Bits 0
; and 1 are timed until they drop, or until the count reaches 0FA0h.
;
; The counts are kept against running limits, and JoyBits gains a bit when a count falls outside the inner
; range.
;-----------------------------------------------------------------------------
PollJoy:
        mov byte [JoyBits], 0
        test byte [JoyOn], 1
        jne short .1
        jmp near .26
.1:
        mov dx, GamePort
        in al, dx
        and al, 0x30
        mov byte [JoyBtn], al
        mov bl, 3
        mov word [JoyX], 0x50
        mov word [JoyY], 0x50
        cli
        out dx, al
        mov cx, 0x14
        db 0xE2, 0xFE                           ; insn: loop 0xf33
        db 0x33, 0xC9                           ; insn: xor cx, cx
.2:
        in al, dx
        db 0x22, 0xC3                           ; insn: and al, bl
        db 0x32, 0xC3                           ; insn: xor al, bl
        jne short .3
        inc cx
        cmp cx, 0xfa0
        jl short .2
        jmp short .6
.3:
        test al, 1
        jne short .5
.4:
        test al, 2
        je short .2
        mov word [JoyY], cx
        and bl, 1
        jne short .2
        jmp short .6
.5:
        mov word [JoyX], cx
        and bl, 2
        jne short .4
.6:
        sti
        mov ax, word [JoyX]
        cmp ax, word [0x6fff]
        jge short .10
        dec word [0x7007]
        jle short .7
        cmp ax, word [0x7001]
        jl short .13
        mov word [0x7001], ax
        jmp short .13
.7:
        mov bx, word [0x7001]
        mov word [0x6fff], bx
        mov bx, word [0x7003]
.8:
        sub bx, word [0x6fff]
        jle short .9
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [0x701b], ax
.9:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [0x6fff]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [0x700b], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [0x7009], ax
        mov ax, word [JoyX]
        jmp short .12
.10:
        cmp ax, word [0x7003]
        jle short .12
        dec word [0x7007]
        jle short .11
        cmp ax, word [0x7005]
        jge short .13
        mov word [0x7005], ax
        jmp short .13
.11:
        mov bx, word [0x7005]
        mov word [0x7003], bx
        jmp short .8
.12:
        mov word [0x7007], 0x14
        mov word [0x7005], 0x4e20
        mov word [0x7001], 0
.13:
        cmp ax, word [0x7009]
        jl short .18
        cmp ax, word [0x700b]
        jl short .14
        or byte [JoyBits], 4
.14:
        mov ax, word [JoyY]
        cmp ax, word [0x700d]
        jae short .19
        dec word [0x7015]
        jle short .15
        cmp ax, word [0x700f]
        jl short .22
        mov word [0x700f], ax
        jmp short .22
.15:
        mov bx, word [0x700f]
        mov word [0x700d], bx
        mov bx, word [0x7011]
.16:
        sub bx, word [0x700d]
        jle short .17
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [0x701d], ax
.17:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [0x700d]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [0x7019], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [0x7017], ax
        mov ax, word [JoyY]
        jmp short .21
.18:
        or byte [JoyBits], 8
        jmp short .14
.19:
        cmp ax, word [0x7011]
        jle short .21
        dec word [0x7015]
        je short .20
        cmp ax, word [0x7013]
        jge short .22
        mov word [0x7013], ax
        jmp short .22
.20:
        mov bx, word [0x7013]
        mov word [0x7011], bx
        jmp short .16
.21:
        mov word [0x7015], 0x14
        mov word [0x7013], 0x4e20
        mov word [0x700f], 0
.22:
        cmp ax, word [0x7017]
        jb short .27
        cmp ax, word [0x7019]
        jb short .23
        or byte [JoyBits], 2
.23:
        in al, dx
        and al, 0x30
        cmp al, byte [JoyBtn]
        je short .24
        mov al, byte [0x6ffc]
        jmp short .25
.24:
        xor al, 0x30
        mov byte [0x6ffc], al
.25:
        or byte [JoyBits], al
.26:
        mov al, byte [JoyBits]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        retf
.27:
        or byte [JoyBits], 1
        jmp short .23


;-----------------------------------------------------------------------------
; InitJoy                                                     03A3:10C3  94 PC
; Set bit 0 of JoyOn and the initial axis limits.
;-----------------------------------------------------------------------------
InitJoy:
        mov byte [JoyOn], 1
        mov word [0x6fff], 0x50
        mov word [0x7003], 0
        mov word [0x700d], 0x50
        mov word [0x7011], 0
        retf


;-----------------------------------------------------------------------------
; JoyNibble                                                   03A3:10E1  94 PC
; The low nibble of the argument indexes the 16 bytes of JoyNibbleTable.
;-----------------------------------------------------------------------------
JoyNibble:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, word [bp + 6]
        and bx, 0xf
        mov al, byte [bx + JoyNibbleTable]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        leave
        retf


;-----------------------------------------------------------------------------
; JoyScaleX                                                   03A3:10F2  94 PC
; (JoyX minus the low limit) times the X scale. The high word of that product, minus 1Fh, is the result. A
; reading under the limit returns the scale of zero, then the same subtract.
;-----------------------------------------------------------------------------
JoyScaleX:
        mov ax, word [JoyX]
        sub ax, word [0x6fff]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [0x701b]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf


;-----------------------------------------------------------------------------
; JoyScaleY                                                   03A3:1109  94 PC
; The same scale for JoyY.
;-----------------------------------------------------------------------------
JoyScaleY:
        mov ax, word [JoyY]
        sub ax, word [0x700d]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [0x701d]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf

;-----------------------------------------------------------------------------
; PollSticks                                                  03A3:1120  94 PC
; If JoyOn is 0, return 0. Otherwise time up to four axes on port 201h. The axis mask comes from the byte at
; JoyOn in StickDirTable. Bit 0 of JoyOn calibrates the first pair into Stick1Bits.
;
; Bit 1 calibrates the second pair into Stick2Bits. AL is Stick1Bits and AH is Stick2Bits.
;-----------------------------------------------------------------------------
PollSticks:
        mov bl, byte [JoyOn]
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jne short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf
.1:
        mov byte [Stick1Bits], 0
        mov byte [Stick2Bits], 0
        mov dx, GamePort
        in al, dx
        mov byte [StickRaw], al
        db 0x32, 0xFF                           ; insn: xor bh, bh
        mov bl, byte [bx + StickDirTable]
        mov ax, 0x50
        mov word [Stick1X], ax
        mov word [Stick1Y], ax
        mov word [Stick2X], ax
        mov word [Stick2Y], ax
        cli
        out dx, al
        mov cx, 0x14
        db 0xE2, 0xFE                           ; insn: loop 0x1156
        db 0x33, 0xC9                           ; insn: xor cx, cx
.2:
        in al, dx
        db 0x22, 0xC3                           ; insn: and al, bl
        db 0x32, 0xC3                           ; insn: xor al, bl
        jne short .3
        inc cx
        cmp cx, 0xfa0
        jl short .2
        jmp short .10
.3:
        test al, 1
        jne short .7
.4:
        test al, 2
        jne short .8
.5:
        test al, 4
        jne short .9
.6:
        test al, 8
        je short .2
        mov word [Stick2Y], cx
        and bl, 7
        jne short .2
        jmp short .10
.7:
        mov word [Stick1X], cx
        and bl, 0xe
        jne short .4
        jmp short .10
.8:
        mov word [Stick1Y], cx
        and bl, 0xd
        jne short .5
        jmp short .10
.9:
        mov word [Stick2X], cx
        and bl, 0xb
        jne short .6
.10:
        sti
        test byte [JoyOn], 1
        jne short .11
        jmp near .28
.11:
        mov bx, word [Stick1X]
        cmp bx, word [Stick1XMin]
        jge short .14
        mov word [Stick1XMin], bx
        mov bx, word [Stick1XMax]
.12:
        sub bx, word [Stick1XMin]
        jle short .13
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [Stick1XScale], ax
.13:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [Stick1XMin]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [Stick1XHigh], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [Stick1XLow], ax
        mov bx, word [Stick1X]
        jmp short .16
.14:
        cmp bx, word [Stick1XMax]
        jle short .16
        dec word [Stick1XSettle]
        je short .15
        cmp bx, word [Stick1XLast]
        jge short .17
        mov word [Stick1XLast], bx
        jmp short .17
.15:
        mov bx, word [Stick1XLast]
        mov word [Stick1XMax], bx
        jmp short .12
.16:
        mov word [Stick1XSettle], 8
        mov word [Stick1XLast], 0x4e20
.17:
        cmp bx, word [Stick1XLow]
        jl short .21
        cmp bx, word [Stick1XHigh]
        jl short .18
        or byte [Stick1Bits], 4
.18:
        mov bx, word [Stick1Y]
        cmp bx, word [Stick1YMin]
        jae short .22
        mov word [Stick1YMin], bx
        mov bx, word [Stick1YMax]
.19:
        sub bx, word [Stick1YMin]
        jle short .20
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [Stick1YScale], ax
.20:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [Stick1YMin]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [Stick1YHigh], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [Stick1YLow], ax
        mov bx, word [Stick1Y]
        jmp short .24
.21:
        or byte [Stick1Bits], 8
        jmp short .18
.22:
        cmp bx, word [Stick1YMax]
        jle short .24
        dec word [Stick1YSettle]
        je short .23
        cmp bx, word [Stick1YLast]
        jge short .25
        mov word [Stick1YLast], bx
        jmp short .25
.23:
        mov bx, word [Stick1YLast]
        mov word [Stick1YMax], bx
        jmp short .19
.24:
        mov word [Stick1YSettle], 8
        mov word [Stick1YLast], 0x4e20
.25:
        cmp bx, word [Stick1YLow]
        jb short .27
        cmp bx, word [Stick1YHigh]
        jb short .26
        or byte [Stick1Bits], 2
.26:
        in al, dx
        and al, byte [StickRaw]
        and al, 0x30
        xor al, 0x30
        or byte [Stick1Bits], al
        jmp short .28
.27:
        or byte [Stick1Bits], 1
        jmp short .26
.28:
        test byte [JoyOn], 2
        jne short .29
        jmp near .45
.29:
        mov bx, word [Stick2X]
        cmp bx, word [Stick2XMin]
        jge short .32
        mov word [Stick2XMin], bx
        mov bx, word [Stick2XMax]
.30:
        sub bx, word [Stick2XMin]
        jle short .31
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [Stick2XScale], ax
.31:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [Stick2XMin]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [Stick2XHigh], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [Stick2XLow], ax
        mov bx, word [Stick2X]
        jmp short .34
.32:
        cmp bx, word [Stick2XMax]
        jle short .34
        dec word [Stick2XSettle]
        je short .33
        cmp bx, word [Stick2XLast]
        jge short .35
        mov word [Stick2XLast], bx
        jmp short .35
.33:
        mov bx, word [Stick2XLast]
        mov word [Stick2XMax], bx
        jmp short .30
.34:
        mov word [Stick2XSettle], 8
        mov word [Stick2XLast], 0x4e20
.35:
        cmp bx, word [Stick2XLow]
        jl short .39
        cmp bx, word [Stick2XHigh]
        jl short .36
        or byte [Stick2Bits], 4
.36:
        mov bx, word [Stick2Y]
        cmp bx, word [Stick2YMin]
        jae short .40
        mov word [Stick2YMin], bx
        mov bx, word [Stick2YMax]
.37:
        sub bx, word [Stick2YMin]
        jle short .38
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, 0x4000
        div bx
        mov word [Stick2YScale], ax
.38:
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov dx, GamePort
        shr ax, 1
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shr bx, 1
        add ax, word [Stick2YMin]
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [Stick2YHigh], ax
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        mov word [Stick2YLow], ax
        mov bx, word [Stick2Y]
        jmp short .42
.39:
        or byte [Stick2Bits], 8
        jmp short .36
.40:
        cmp bx, word [Stick2YMax]
        jle short .42
        dec word [Stick2YSettle]
        je short .41
        cmp bx, word [Stick2YLast]
        jge short .43
        mov word [Stick2YLast], bx
        jmp short .43
.41:
        mov bx, word [Stick2YLast]
        mov word [Stick2YMax], bx
        jmp short .37
.42:
        mov word [Stick2YSettle], 8
        mov word [Stick2YLast], 0x4e20
.43:
        cmp bx, word [Stick2YLow]
        jb short .46
        cmp bx, word [Stick2YHigh]
        jb short .44
        or byte [Stick2Bits], 2
.44:
        in al, dx
        and al, byte [StickRaw]
        and al, 0xc0
        xor al, 0xc0
        shr al, 1
        shr al, 1
        or byte [Stick2Bits], al
.45:
        mov al, byte [Stick1Bits]
        mov ah, byte [Stick2Bits]
        retf
.46:
        or byte [Stick2Bits], 1
        jmp short .44


;-----------------------------------------------------------------------------
; InitStick1                                                  03A3:1405  94 PC
; Set JoyOn bit 0 and the initial limits for the first pair. _main calls this.
;-----------------------------------------------------------------------------
InitStick1:
        or byte [JoyOn], 1
        mov word [Stick1XMin], 0x50
        mov word [Stick1XMax], 0
        mov word [Stick1YMin], 0x50
        mov word [Stick1YMax], 0
        retf


;-----------------------------------------------------------------------------
; InitStick2                                                  03A3:1423  94 PC
; Set JoyOn bit 1 and the initial limits for the second pair. _main calls this.
;-----------------------------------------------------------------------------
InitStick2:
        or byte [JoyOn], 2
        mov word [Stick2XMin], 0x50
        mov word [Stick2XMax], 0
        mov word [Stick2YMin], 0x50
        mov word [Stick2YMax], 0
        retf


;-----------------------------------------------------------------------------
; ScaleStick1X                                                03A3:1441  94 PC
; (Stick1X minus its low limit) times the X scale. High word of the product minus 1Fh.
;-----------------------------------------------------------------------------
ScaleStick1X:
        mov ax, word [Stick1X]
        sub ax, word [Stick1XMin]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [Stick1XScale]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf


;-----------------------------------------------------------------------------
; ScaleStick1Y                                                03A3:1458  94 PC
; The same scale for Stick1Y.
;-----------------------------------------------------------------------------
ScaleStick1Y:
        mov ax, word [Stick1Y]
        sub ax, word [Stick1YMin]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [Stick1YScale]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf


;-----------------------------------------------------------------------------
; ScaleStick2X                                                03A3:146F  94 PC
; The same scale for Stick2X.
;-----------------------------------------------------------------------------
ScaleStick2X:
        mov ax, word [Stick2X]
        sub ax, word [Stick2XMin]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [Stick2XScale]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf


;-----------------------------------------------------------------------------
; ScaleStick2Y                                                03A3:1486  94 PC
; The same scale for Stick2Y.
;-----------------------------------------------------------------------------
ScaleStick2Y:
        mov ax, word [Stick2Y]
        sub ax, word [Stick2YMin]
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        mul word [Stick2YScale]
        db 0x8A, 0xC4                           ; insn: mov al, ah
        db 0x8A, 0xE2                           ; insn: mov ah, dl
        sub ax, 0x1f
        retf

        db 0x00


;-----------------------------------------------------------------------------
; HookKbd                                                     03A3:149E  94 PC
; Save DS at KbdDs. If INT 9 is not already KbdIrq, save INT 9, INT 16h, and INT 23h, and point them at
; KbdIrq, Int16Hook, and BreakIrq.
;
; Point KeyPtr at KeyService, clear the key-state bytes, and register UnhookKbd.
;-----------------------------------------------------------------------------
HookKbd:
        push di
        mov word [cs:KbdDs], ds
        in al, 0x21
        db 0x8A, 0xE0                           ; insn: mov ah, al
        or al, 3
        out 0x21, al
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov es, bx
        mov bx, word es:[0x24]
        cmp bx, KbdIrq
        je short .1
        mov word [OldInt9Off], bx
        mov bx, word es:[0x26]
        mov word [OldInt9Seg], bx
        mov word [es:0x24], KbdIrq
        mov word es:[0x26], cs
        mov bx, word es:[0x58]
        mov word [OldInt16Off], bx
        mov bx, word es:[0x5a]
        mov word [OldInt16Seg], bx
        mov word [es:0x58], Int16Hook
        mov word es:[0x5a], cs
        mov bx, word es:[0x8c]
        mov word [OldInt23Off], bx
        mov bx, word es:[0x8e]
        mov word [OldInt23Seg], bx
        mov word [es:0x8c], BreakIrq
        mov word es:[0x8e], cs
        mov bx, KeyService
        mov word [KeyPtr], bx
.1:
        db 0x8A, 0xC4                           ; insn: mov al, ah
        out 0x21, al
        mov ax, ds
        mov es, ax
        mov di, KeyState
        mov cx, 0x5a
        db 0x33, 0xC0                           ; insn: xor ax, ax
        rep stosb
        push cs
        mov ax, UnhookKbd
        push ax
        call 0x03A3:OnexitThunk
        add sp, 4
        pop di
        retf


;-----------------------------------------------------------------------------
; UnhookKbd                                                   03A3:1538  94 PC
; Restore those three vectors when a previous INT 9 offset was saved.
; Point KeyPtr at BiosKey and clear the BIOS shift flags.
;-----------------------------------------------------------------------------
UnhookKbd:
        in al, 0x21
        db 0x8A, 0xE0                           ; insn: mov ah, al
        or al, 3
        out 0x21, al
        db 0x33, 0xDB                           ; insn: xor bx, bx
        mov es, bx
        mov bx, word [OldInt9Off]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je short .2
        mov word es:[0x24], bx
        mov bx, word [OldInt9Seg]
        mov word es:[0x26], bx
        mov bx, word [OldInt16Off]
        mov word es:[0x58], bx
        mov bx, word [OldInt16Seg]
        mov word es:[0x5a], bx
        mov bx, word [OldInt23Off]
.1:
        mov word es:[0x8c], bx
        mov bx, word [OldInt23Seg]
        mov word es:[0x8e], bx
        mov bx, BiosKey
        mov word [KeyPtr], bx
        mov al, byte es:[0x417]
        and al, 0xf0
        mov byte es:[0x417], al
.2:
        db 0x8A, 0xC4                           ; insn: mov al, ah
        out 0x21, al
        retf
KbdDs:                                          ; DS saved by HookKbd and loaded by KbdIrq and Int16Hook; used
                                                ; by HookKbd, KbdIrq, Int16Hook
        dw 0


;-----------------------------------------------------------------------------
; KbdIrq                                                      03A3:1596  94 PC
; INT 9. Acknowledges the keyboard, reads the scan code, and sends EOI. A break code clears the key-state
; byte.
;
; A make code sets it and, unless a translation flag sends it elsewhere, queues the byte from the table at
; 713Ah. One flag path stores 1234h at 0:0472h and jumps to FFFF:0000h.
;-----------------------------------------------------------------------------
KbdIrq:
        sti
        push ax
        push bx
        push ds
        in al, 0x61
        db 0x8A, 0xE0                           ; insn: mov ah, al
        or al, 0x80
        out 0x61, al
        db 0x8A, 0xC4                           ; insn: mov al, ah
        out 0x61, al
        db 0x33, 0xC0                           ; insn: xor ax, ax
        in al, 0x60
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov al, 0x20
        out 0x20, al
        mov ds, word [cs:KbdDs]
        db 0x0A, 0xDB                           ; insn: or bl, bl
        jns short .1
        mov byte [bx + 0x702e], 0
        pop ds
        pop bx
        pop ax
        iret
.1:
        mov byte [bx + KeyState], 1
        test byte [0x70e6], 1
        jne short .8
        test byte [0x70cb], 1
        jne short .7
        test byte [0x70d8], 1
        jne short .6
        test byte [0x70e4], 1
        jne short .6
        test byte [0x70e8], 1
        jne short .10
        mov al, byte [bx + 0x713a]
.2:
        db 0x0A, 0xC0                           ; insn: or al, al
        js short .5
.3:
        mov bx, word [KeyHead]
        mov word [bx + KeyBuf], ax
        add bx, 2
        and bx, word [KeyMask]
        cmp word [KeyTail], bx
        je short .4
        mov word [KeyHead], bx
.4:
        pop ds
        pop bx
        pop ax
        iret
.5:
        db 0x8A, 0xE0                           ; insn: mov ah, al
        db 0x32, 0xC0                           ; insn: xor al, al
        cmp ah, 0x90
        jb short .3
        and ah, 0x7f
        jmp short .3
.6:
        mov al, byte [bx + 0x7195]
        jmp short .2
.7:
        mov al, byte [bx + 0x724b]
        cmp bx, 1
        jne short .2
        call 0xF4A:NullFar5
.8:
        test byte [0x70cb], 1
        jne short .11
.9:
        mov al, byte [bx + 0x72a6]
        jmp short .2
.10:
        mov al, byte [bx + 0x71f0]
        jmp short .2
.11:
        test byte [0x7101], 1
        je short .9
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov ax, 0x1234
        mov word es:[0x472], ax
        jmp 0xFFFF:0x0


;-----------------------------------------------------------------------------
; BreakIrq                                                    03A3:165B  94 PC
; INT 23h. Saves the registers, calls AskExitToDos, and returns from the interrupt.
;-----------------------------------------------------------------------------
BreakIrq:
        push bp
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es
        call 0x1570:AskExitToDos
        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        pop bp
        iret


;-----------------------------------------------------------------------------
; Int16Hook                                                   03A3:1673  94 PC
; INT 16h. Loads DS from KbdDs, calls KeyService, and returns with retf 2.
;-----------------------------------------------------------------------------
Int16Hook:
        push bx
        push ds
        mov ds, word [cs:KbdDs]
        call KeyService
        pop ds
        pop bx
        retf 0x2


;-----------------------------------------------------------------------------
; KeyService                                                  03A3:1682  94 PC
; AH 0 reads a queued key. AH 1 reports one without removing it.
; Any other AH returns the two flag bytes ORed together.
;-----------------------------------------------------------------------------
KeyService:
        cmp ah, 1
        jb short .1
        ja short .2
        mov bx, word [KeyTail]
        cmp bx, word [KeyHead]
        je short .3
        mov ax, word [bx + KeyBuf]
        ret
.1:
        mov bx, word [KeyTail]
        cmp bx, word [KeyHead]
        je short .3
        mov ax, word [bx + KeyBuf]
        add bx, 2
        and bx, word [KeyMask]
        mov word [KeyTail], bx
        db 0x0B, 0xC0                           ; insn: or ax, ax
        ret
.2:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov al, byte [0x70d8]
        or al, byte [0x70e4]
        ret
.3:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        ret


;-----------------------------------------------------------------------------
; KeyDown                                                     03A3:16C1  94 PC
; The key-state byte for the scan code argument.
;-----------------------------------------------------------------------------
KeyDown:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, word [bp + 6]
        mov al, byte [bx + KeyState]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        leave
        retf
        db 0x00


;-----------------------------------------------------------------------------
; BiosKey                                                     03A3:16D0  94 PC
; INT 16h, then a near return. KeyPtr points here while the hook is removed.
;-----------------------------------------------------------------------------
BiosKey:
        int 0x16
        ret


;-----------------------------------------------------------------------------
; ReadKey                                                     03A3:16D3  94 PC
; Ask KeyPtr whether a key is waiting, then read it.
;-----------------------------------------------------------------------------
ReadKey:
        mov ah, 1
        call word [KeyPtr]
        jne short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf
.1:
        db 0x32, 0xE4                           ; insn: xor ah, ah
        call word [KeyPtr]
        db 0x0A, 0xC0                           ; insn: or al, al
        je short .2
        db 0x32, 0xE4                           ; insn: xor ah, ah
.2:
        retf


;-----------------------------------------------------------------------------
; KeyJump                                                     03A3:16EB  94 PC
; Far jump through KeyHook.
;-----------------------------------------------------------------------------
KeyJump:
        jmp far [KeyHook]


;-----------------------------------------------------------------------------
; ReadKeyNz                                                   03A3:16EF  94 PC
; Like ReadKey, but a zero low byte stays zero instead of being read again.
;-----------------------------------------------------------------------------
ReadKeyNz:
        mov ah, 1
        call word [KeyPtr]
        jne short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf
.1:
        db 0x0A, 0xC0                           ; insn: or al, al
        je short .2
        db 0x32, 0xE4                           ; insn: xor ah, ah
.2:
        retf


;-----------------------------------------------------------------------------
; SetKeyHook                                                  03A3:1701  94 PC
; Store the far pointer argument at KeyHook.
;-----------------------------------------------------------------------------
SetKeyHook:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, word [bp + 6]
        mov word [KeyHook], ax
        mov ax, word [bp + 8]
        mov word [0x7304], ax
        leave
        retf


;-----------------------------------------------------------------------------
; GetKeyHook                                                  03A3:1712  94 PC
; Return that far pointer.
;-----------------------------------------------------------------------------
GetKeyHook:
        mov ax, word [KeyHook]
        mov dx, word [0x7304]
        retf


;-----------------------------------------------------------------------------
; WaitKey                                                     03A3:171A  94 PC
; Call KeyJump until it returns nonzero.
;-----------------------------------------------------------------------------
WaitKey:
        push cs
        call KeyJump
        cmp ax, 0
        je short WaitKey
        retf


;-----------------------------------------------------------------------------
; FlushKeys                                                   03A3:1724  94 PC
; Call ReadKey until it returns zero.
;-----------------------------------------------------------------------------
FlushKeys:
        push cs
        call ReadKey
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short FlushKeys
        retf


;-----------------------------------------------------------------------------
; WaitKeyUntil                                                03A3:172D  94 PC
; Call KeyJump until it returns nonzero or ReadCallCount passes Deadline.
;-----------------------------------------------------------------------------
WaitKeyUntil:
        push cs
        call KeyJump
        cmp ax, 0
        jne short .2
        call 0x03A3:ReadCallCount
        cmp dx, word [DeadlineHi]
        jb short WaitKeyUntil
        ja short .1
        cmp ax, word [Deadline]
        jb short WaitKeyUntil
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
.2:
        retf

;-----------------------------------------------------------------------------
; WaitKeyAdd                                                  03A3:174C  94 PC
; Add the long argument to ReadCallCount, then wait for a key or until
; that sum is reached. A key returns in AX. The time path returns 0.
;-----------------------------------------------------------------------------
WaitKeyAdd:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        call 0x03A3:ReadCallCount
        add ax, word [bp + 6]
        adc dx, word [bp + 8]
        mov word [bp - 4], ax
        mov word [bp - 2], dx
.1:
        push cs
        call KeyJump
        cmp ax, 0
        jne short .3
        call 0x03A3:ReadCallCount
        cmp dx, word [bp - 2]
        jb short .1
        ja short .2
        cmp ax, word [bp - 4]
        jb short .1
.2:
        db 0x33, 0xC0                           ; insn: xor ax, ax
.3:
        leave
        retf
        db 0x00


;-----------------------------------------------------------------------------
; ClearMono                                                   03A3:1782  94 PC
; Fill the monochrome text buffer at B000h with zeros.
;-----------------------------------------------------------------------------
ClearMono:
        push di
        push es
        mov ax, 0xb000
        mov es, ax
        db 0x33, 0xFF                           ; insn: xor di, di
        mov cx, 0x7d0
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cld
        rep stosw
        pop es
        pop di
        retf


;-----------------------------------------------------------------------------
; RetFar                                                      03A3:1796  94 PC
; A single retf.
;-----------------------------------------------------------------------------
RetFar:
        retf


;-----------------------------------------------------------------------------
; ScrollMono                                                  03A3:1797  94 PC
; Scroll the monochrome buffer up one row from TextRow and clear the last row.
;-----------------------------------------------------------------------------
ScrollMono:
        push si
        push di
        push ds
        mov al, byte [TextRow]
        mov bl, 0xa0
        mul bl
        db 0x8B, 0xF0                           ; insn: mov si, ax
        db 0x8B, 0xFE                           ; insn: mov di, si
        add si, 0xa0
        mov ax, 0x18
        sub al, byte [TextRow]
        mov bl, 0x50
        mul bl
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, es
        mov ds, ax
        cld
        rep movsw
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, 0x50
        rep stosw
        pop ds
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; ConFlush                                                    03A3:17C8  94 PC
; Write the string already at ConBuf. ConPrint formats into that buffer first.
;-----------------------------------------------------------------------------
ConFlush:
        jmp short ConOut

;-----------------------------------------------------------------------------
; ConPrint                                                    03A3:17CA  94 PC
; Formats through _sprintf into ConBuf, then writes it to B000h.
;-----------------------------------------------------------------------------
ConPrint:
        pop ax
        mov word [ConCursorX], ax
        pop ax
        mov word [ConCursorY], ax
        mov ax, ConBuf
        push ax
        call 0:_sprintf
        add sp, 2
        mov byte [ConKeep], 1
        mov ax, word [TextMark]
        mov word [TextPos], ax
.1:
        mov ax, word [ConCursorY]
        push ax
        mov ax, word [ConCursorX]
        push ax

ConOut:
        push si
        mov ax, 0xb000
        mov es, ax
        mov si, ConBuf
        mov dh, byte [TextAttr]
.1:
        mov dl, byte [si]
        inc si
        db 0x0A, 0xD2                           ; insn: or dl, dl
        je short .3
        cmp dl, 0x20
        jb short .5
        mov bx, word [TextPos]
        cmp bx, 0xfa0
        jl short .2
        push cs
        call ScrollMono
        mov bx, 0xf00
        mov word [TextPos], bx
.2:
        mov word es:[bx], dx
        add word [TextPos], 2
        jmp short .1
.3:
        cmp byte [ConKeep], 0
        je short .4
        mov ax, word [TextPos]
        mov word [TextMark], ax
.4:
        pop si
        retf
.5:
        cmp dl, 0xa
        jne short .6
        mov ax, word [TextPos]
        mov bx, 0xa0
        div bl
        db 0x32, 0xE4                           ; insn: xor ah, ah
        inc al
        mul bl
        mov word [TextPos], ax
        cmp word [TextPos], 0xfa0
        jl short .1
        push cs
        call ScrollMono
        mov word [TextPos], 0xf00
        jmp short .1
.6:
        cmp dl, 8
        jne short .7
        cmp word [TextPos], 0
        je short .1
        sub word [TextPos], 2
        jmp short .1
.7:
        cmp dl, 0xc
        jne short .8
        push cs
        call ClearMono
        mov al, byte [TextRow]
        mov bl, 0xa0
        mul bl
        mov word [TextPos], ax
        jmp near .1
.8:
        cmp dl, 0xb
        jne short .9
        mov word [TextPos], 0
        jmp near .1
.9:
        cmp dl, 9
        jne short .10
        add word [TextPos], 0x10
        and word [TextPos], 0xfff0
.10:
        jmp near .1


;-----------------------------------------------------------------------------
; ConPrintAt                                                  03A3:18AB  94 PC
; Set the cursor from a row and column, format into ConBuf, and write it.
;-----------------------------------------------------------------------------
ConPrintAt:
        pop ax
        mov word [ConCursorX], ax
        pop ax
        mov word [ConCursorY], ax
        pop bx
        pop ax
        mov dl, 0xa0
        mul dl
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xC3                           ; insn: add ax, bx
        mov word [TextPos], ax
        mov ax, ConBuf
        push ax
        call 0:_sprintf
        add sp, 2
        sub sp, 4
        mov byte [ConKeep], 0
        jmp near ConPrint.1


;-----------------------------------------------------------------------------
; SetTextRow                                                  03A3:18D7  94 PC
; Clamp the argument into 0..24 and store it as TextRow.
;-----------------------------------------------------------------------------
SetTextRow:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, word [bp + 6]
        cmp ax, 0
        jge short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
.1:
        cmp ax, 0x18
        jle short .2
        mov ax, 0x18
.2:
        mov byte [TextRow], al
        leave
        retf


;-----------------------------------------------------------------------------
; SetTextAttr                                                 03A3:18F1  94 PC
; Store the low byte as the attribute used with each character.
;-----------------------------------------------------------------------------
SetTextAttr:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov byte [TextAttr], al
        retf


;-----------------------------------------------------------------------------
; WriteHex                                                    03A3:18FA  94 PC
; Write the argument as two hex digits at the remembered cursor.
;-----------------------------------------------------------------------------
WriteHex:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push es
        mov byte [ConKeep], 1
        mov dx, word [bp + 6]
        mov ax, word [TextMark]
        mov word [TextPos], ax
        jmp short WriteHexAt.1


;-----------------------------------------------------------------------------
; WriteHexAt                                                  03A3:1912  94 PC
; Write two hex digits at the row and column arguments.
;-----------------------------------------------------------------------------
WriteHexAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push es
        mov dx, word [bp + 6]
        mov ax, word [bp + 8]
        mov bx, 0xa0
        mul bl
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov word [TextPos], ax
        mov byte [ConKeep], 0
        mov dx, word [bp + 0xa]
.1:
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        and bx, 0xf
        mov al, byte [bx + 0x74c8]
        mov byte [0x7451], al
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        shr bx, 1
        shr bx, 1
        shr bx, 1
        shr bx, 1
        and bx, 0xf
        mov al, byte [bx + 0x74c8]
        mov byte [ConBuf], al
        mov byte [0x7452], 0
        push cs
        call ConFlush
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        leave
        retf


;-----------------------------------------------------------------------------
; WriteChar                                                   03A3:1964  94 PC
; Write the low byte at the remembered cursor.
;-----------------------------------------------------------------------------
WriteChar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push es
        mov byte [ConKeep], 1
        mov ax, word [TextMark]
        mov word [TextPos], ax
        mov dx, word [bp + 6]
        jmp short WriteCharAt.1


;-----------------------------------------------------------------------------
; WriteCharAt                                                 03A3:197C  94 PC
; Write the low byte at the row and column arguments.
;-----------------------------------------------------------------------------
WriteCharAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push es
        mov dx, word [bp + 6]
        mov ax, word [bp + 8]
        mov bx, 0xa0
        mul bl
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov word [TextPos], ax
        mov byte [ConKeep], 0
        mov dx, word [bp + 0xa]
.1:
        mov byte [ConBuf], dl
        mov byte [0x7451], 0
        push cs
        call ConFlush
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        leave
        retf


;-----------------------------------------------------------------------------
; SaveTextState                                               03A3:19B2  94 PC
; Copy 15 words from 74E2h and 15 words from the block selected by CurPage
; into the near buffer.
;-----------------------------------------------------------------------------
SaveTextState:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, 0x74e2
        mov di, word [bp + 6]
        mov ax, ds
        mov es, ax
        mov cx, 0xf
        rep movsw
        mov bx, word [CurPage]
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov si, word [bx + PageTable]
        mov ds, word [bx + PageTableSeg]
        mov cx, 0xf
        rep movsw
        mov ds, ax
        pop si
        pop di
        leave
        retf


;-----------------------------------------------------------------------------
; LoadTextState                                               03A3:19E1  94 PC
; Copy those words back from the near buffer.
;-----------------------------------------------------------------------------
LoadTextState:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        push si
        mov si, word [bp + 6]
        mov ax, ds
        mov es, ax
        mov di, 0x74e2
        mov cx, 0xf
        rep movsw
        mov bx, word [CurPage]
        db 0x03, 0xDB                           ; insn: add bx, bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov di, word [bx + PageTable]
        mov es, word [bx + PageTableSeg]
        mov cx, 0xf
        rep movsw
        pop si
        pop di
        leave
        retf


;-----------------------------------------------------------------------------
; ReadCallCount                                               03A3:1A0E  94 PC
; Return CallCount in DX:AX. Int8Handler increments that dword.
;-----------------------------------------------------------------------------
ReadCallCount:
        les ax, [CallCount]
        mov dx, es
        retf


;-----------------------------------------------------------------------------
; CallCountDiff                                               03A3:1A15  94 PC
; Return CallCount minus the long argument.
;-----------------------------------------------------------------------------
CallCountDiff:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        les ax, [CallCount]
        mov dx, es
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x1B, 0xD1                           ; insn: sbb dx, cx
        retf


;-----------------------------------------------------------------------------
; CallCountStep                                               03A3:1A2C  94 PC
; Return CallCount minus the previous sample, and store the new sample.
;-----------------------------------------------------------------------------
CallCountStep:
        mov bx, word [LastCount]
        mov cx, word [0x7524]
        les ax, [CallCount]
        mov dx, es
        mov word [LastCount], ax
        mov word [0x7524], dx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        db 0x1B, 0xD1                           ; insn: sbb dx, cx
        retf


;-----------------------------------------------------------------------------
; ClearCallCount                                              03A3:1A46  94 PC
; Zero CallCount.
;-----------------------------------------------------------------------------
ClearCallCount:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov word [CallCount], ax
        mov word [0x6da2], ax
        retf


;-----------------------------------------------------------------------------
; HaltSpin                                                    03A3:1A4F  94 PC
; Store FBEAh just under SP and hlt until that word changes or the count expires.
;-----------------------------------------------------------------------------
HaltSpin:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        sub bx, 2
        mov cx, 0x2710
        mov ax, 0xfbea
        mov word [bx], ax
.1:
        hlt
        cmp word [bx], ax
        loope .1
        mov word [bx], 0
        retf


;-----------------------------------------------------------------------------
; SetDeadline                                                 03A3:1A66  94 PC
; Store CallCount plus the long argument at Deadline. WaitKeyUntil compares it.
;-----------------------------------------------------------------------------
SetDeadline:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
.regs:
        les bx, [CallCount]
        mov cx, es
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x13, 0xD1                           ; insn: adc dx, cx
        mov word [Deadline], ax
        mov word [DeadlineHi], dx
        retf

;-----------------------------------------------------------------------------
; WaitDeadline                                                03A3:1A80  94 PC
; Specific EOI for IRQ 0, then hlt until CallCount reaches Deadline.
; If the low word of CallCount does not change, start over.
;-----------------------------------------------------------------------------
WaitDeadline:
        mov al, 0x60
        out 0x20, al
WaitDeadlineNoEoi:
        db 0x33, 0xC9                           ; insn: xor cx, cx
        mov bx, word [CallCount]
        jmp short .2
.1:
        hlt
.2:
        les ax, [CallCount]
        mov dx, es
        sub ax, word [Deadline]
        sbb dx, word [DeadlineHi]
        jns short .3
        loop .1
        cmp word [CallCount], bx
        jne short WaitDeadlineNoEoi
        jmp short WaitDeadline
.3:
        retf


;-----------------------------------------------------------------------------
; DeadlineReached                                             03A3:1AA8  94 PC
; AX is 1 when CallCount is at or past Deadline.
;-----------------------------------------------------------------------------
DeadlineReached:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        les bx, [CallCount]
        mov dx, es
        sub bx, word [Deadline]
        sbb dx, word [DeadlineHi]
        adc ax, -2
        not ax
        retf


;-----------------------------------------------------------------------------
; WaitCount                                                   03A3:1ABE  94 PC
; Spin until CallCount reaches its current value plus the long argument.
;-----------------------------------------------------------------------------
WaitCount:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
        les bx, [CallCount]
        mov cx, es
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x13, 0xD1                           ; insn: adc dx, cx
.1:
        les bx, [CallCount]
        mov cx, es
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        db 0x1B, 0xCA                           ; insn: sbb cx, dx
        js short .1
        retf
        db 0x00

;-----------------------------------------------------------------------------
; MouseRatio                                                  03A3:1ADE  94 PC
; If a mouse is present, INT 33h AX=0Fh. The two arguments are shifted
; right by MouseRatioShift and become the mickey counts.
;-----------------------------------------------------------------------------
MouseRatio:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        cmp word [MouseOn], 0
        je short .1
        mov ax, 0xf
        mov bx, word [bp + 6]
        mov dx, word [bp + 8]
        mov cx, word [MouseRatioShift]
        shr bx, cl
        shr dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
.1:
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseMove                                                   03A3:1B03  94 PC
; If a mouse is present, store the arguments and INT 33h AX=4.
; X is shifted by MouseXShift and Y by MouseYShift.
;-----------------------------------------------------------------------------
MouseMove:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        cmp word [MouseOn], 0
        je short .1
        mov ax, 4
        mov cx, word [MouseXShift]
        mov bx, word [bp + 6]
        mov word [MouseX], bx
        shl bx, cl
        mov cx, word [MouseYShift]
        mov dx, word [bp + 8]
        mov word [MouseY], dx
        shl dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
.1:
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseRead                                                   03A3:1B34  94 PC
; INT 33h AX=3. Store buttons, X, and Y through the three near pointers.
; X and Y are shifted back down. _main calls this. Nothing is stored when MouseOn is 0.
;-----------------------------------------------------------------------------
MouseRead:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp word [MouseOn], 1
        jb short .3
        je short .1
        mov ax, 3
        int 0x33
        and ax, 1
        and bx, 2
        db 0x0B, 0xD8                           ; insn: or bx, ax
        jmp short .2
.1:
        mov ax, 3
        int 0x33
.2:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov cx, word [MouseXShift]
        shr ax, cl
        mov cx, word [MouseYShift]
        shr dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        mov bx, word [bp + 6]
        mov word [bx], cx
        mov bx, word [bp + 8]
        mov word [bx], ax
        mov bx, word [bp + 0xa]
        mov word [bx], dx
.3:
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseXRange                                                 03A3:1B7B  94 PC
; INT 33h AX=7, or AX=10h when MouseOn is above 1. The limits are shifted up.
;-----------------------------------------------------------------------------
MouseXRange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov ax, 7
        cmp word [MouseOn], 1
        jb short .2
        je short .1
        mov ax, 0x10
.1:
        mov cx, word [MouseXShift]
        mov bx, word [bp + 6]
        mov dx, word [bp + 8]
        shl bx, cl
        shl dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
.2:
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseYRange                                                 03A3:1BA5  94 PC
; INT 33h AX=8, or AX=11h when MouseOn is not 1. The limits are shifted up.
;-----------------------------------------------------------------------------
MouseYRange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov ax, 8
        cmp word [MouseOn], 1
        je short .1
        mov ax, 0x11
.1:
        mov cx, word [MouseYShift]
        mov bx, word [bp + 6]
        mov dx, word [bp + 8]
        shl bx, cl
        shl dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseRange                                                  03A3:1BCD  94 PC
; Set both ranges. X limits are the first and third words, Y the second and fourth.
;-----------------------------------------------------------------------------
MouseRange:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov ax, 7
        cmp word [MouseOn], 1
        jb short .3
        je short .1
        mov ax, 0x10
.1:
        mov cx, word [MouseXShift]
        mov bx, word [bp + 6]
        mov dx, word [bp + 0xa]
        shl bx, cl
        shl dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
        mov ax, 8
        cmp word [MouseOn], 1
        je short .2
        mov ax, 0x11
.2:
        mov cx, word [MouseYShift]
        mov bx, word [bp + 8]
        mov dx, word [bp + 0xc]
        shl bx, cl
        shl dx, cl
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        int 0x33
.3:
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseButtons                                                03A3:1C16  94 PC
; INT 33h AX=3. Return the button word, with bits masked when MouseOn is above 1.
;-----------------------------------------------------------------------------
MouseButtons:
        push si
        push di
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp word [MouseOn], 1
        jb short .2
        ja short .1
        mov ax, 3
        int 0x33
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        pop di
        pop si
        retf
.1:
        mov ax, 3
        int 0x33
        and ax, 1
        and bx, 2
        db 0x0B, 0xC3                           ; insn: or ax, bx
.2:
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; MouseSample                                                 03A3:1C3D  94 PC
; INT 33h AX=3. Store the scaled position and the buttons.
;-----------------------------------------------------------------------------
MouseSample:
        push si
        push di
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp word [MouseOn], 1
        jb short .3
        je short .1
        mov ax, 3
        int 0x33
        and ax, 1
        and bx, 2
        db 0x0B, 0xD8                           ; insn: or bx, ax
        jmp short .2
.1:
        mov ax, 3
        int 0x33
.2:
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov cx, word [MouseXShift]
        shr ax, cl
        mov cx, word [MouseYShift]
        shr dx, cl
        mov word [MouseX], ax
        mov word [MouseY], dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
.3:
        mov word [MouseBtn], ax
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; MouseOpen                                                   03A3:1C7B  94 PC
; Reset the mouse with INT 33h AX=0. Return 0 when no driver answers. Width at most 320 sets MouseXShift.
;
; The box is the size minus one, the pointer starts at one quarter of the size, and the mickey count is 16.
; _main calls this. Registers MouseHide with _onexit.
;-----------------------------------------------------------------------------
MouseOpen:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push si
        push di
        mov word [MouseOn], 0
        mov word [MouseRatioShift], 0
        db 0x33, 0xC0                           ; insn: xor ax, ax
        int 0x33
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .1
        jmp near .4
.1:
        inc word [MouseOn]
        mov word [MouseYShift], 0
        cmp word [MouseActive], 0
        je short .2
        mov word [MouseRatioShift], 2
        inc word [MouseYShift]
        mov ax, 3
        int 0x33
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .2
        mov word [MouseOn], 2
.2:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        cmp word [bp + 6], 0x140
        jg short .3
        inc ax
.3:
        mov word [MouseXShift], ax
        mov ax, word [bp + 8]
        dec ax
        push ax
        mov ax, word [bp + 6]
        dec ax
        push ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        push ax
        push cs
        call MouseRange
        mov ax, word [bp + 8]
        shr ax, 1
        shr ax, 1
        push ax
        mov ax, word [bp + 6]
        shr ax, 1
        shr ax, 1
        push ax
        push cs
        call MouseMove
        mov ax, 0x10
        push ax
        push ax
        push cs
        call MouseRatio
        mov ax, cs
        mov word [MouseShowFn], 0x1d56
        mov word [MouseShowFnSeg], ax
        mov word [MouseHideFn], 0x1d56
        mov word [MouseHideFnSeg], ax
        mov word [MouseReadFn], 0x1d37
        mov word [MouseReadFnSeg], ax
        mov word [MousePosFn], 0x1c3d
        mov word [MousePosFnSeg], ax
        push ax
        push word [MouseHideFn]
        call 0x03A3:OnexitThunk
        add sp, 0x14
.4:
        mov ax, word [MouseOn]
        pop di
        pop si
        leave
        retf


;-----------------------------------------------------------------------------
; MouseShow                                                   03A3:1D37  94 PC
; Increment the show count. INT 33h AX=1 once it becomes positive.
;-----------------------------------------------------------------------------
MouseShow:
        push si
        push di
        inc word [MouseLevel]
        cmp word [MouseLevel], 1
        jl short .1
        mov ax, 1
        mov word [MouseLevel], ax
        cmp word [MouseOn], 0
        je short .1
        int 0x33
.1:
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; MouseHide                                                   03A3:1D56  94 PC
; Decrement the show count. INT 33h AX=2 when it reaches 0.
;-----------------------------------------------------------------------------
MouseHide:
        push si
        push di
        dec word [MouseLevel]
        cmp word [MouseLevel], 0
        jne short .1
        cmp word [MouseOn], 0
        je short .1
        mov ax, 2
        int 0x33
.1:
        pop di
        pop si
        retf


;-----------------------------------------------------------------------------
; ReadPots                                                    03A3:1D72  94 PC
; Time four bits on port 201h. The mask is the PotButtons byte. Store the four counts and the button nibble.
; On a timeout, store the bits still set and retry. _main calls this.
;-----------------------------------------------------------------------------
ReadPots:
        push bp
        push si
        push di
        mov ah, byte [PotButtons]
        mov cx, 0x2710
        mov dx, GamePort
        db 0x33, 0xDB                           ; insn: xor bx, bx
        db 0x8B, 0xEB                           ; insn: mov bp, bx
        db 0x8B, 0xF3                           ; insn: mov si, bx
        db 0x8B, 0xFB                           ; insn: mov di, bx
        cli
        out dx, al
        jmp short .2
.1:
        shr al, 1
        adc bp, 0
        shr al, 1
        adc si, 0
        shr al, 1
        adc di, 0
        shr al, 1
        adc bx, 0
.2:
        in al, dx
        test ah, al
        loopne .1
        sti
        jcxz .4
.3:
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        mov byte [PotBits], al
        mov word [Pot1X], bp
        mov word [Pot1Y], si
        mov word [Pot2X], di
        mov word [Pot2Y], bx
        pop di
        pop si
        pop bp
        retf
.4:
        db 0x8A, 0xE0                           ; insn: mov ah, al
        not ah
        and ah, 0xf
        mov byte [PotButtons], ah
        jmp short .3
        db 0x00



;-----------------------------------------------------------------------------
; Atan2                                                       03A3:1DD4  94 PC
; Two signed words. The byte table at AtanByte is indexed by the ratio of the smaller absolute value to the
; larger. The flags in DI record the signs and which value was larger.
;
; The word table then negates the result and adds or subtracts 100h or 200h, so a full turn is 100h. FoldScale
; calls this.
;-----------------------------------------------------------------------------
Atan2:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        db 0x33, 0xFF                           ; insn: xor di, di
        mov dx, word [bp+6]
        mov cx, word [bp+8]
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jge short .dxpos
        or di, 8
        neg dx
.dxpos:
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jge short .cxpos
        or di, 4
        neg cx
.cxpos:
        db 0x3B, 0xD1                           ; insn: cmp dx, cx
        jl short .ratio
        je short .half
        db 0x87, 0xD1                           ; insn: xchg cx, dx
        or di, 2
.ratio:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        div cx
        db 0x8A, 0xDC                           ; insn: mov bl, ah
        db 0x32, 0xFF                           ; insn: xor bh, bh
        add al, 0x80
        adc bx, 0
        mov al, byte [bx+AtanByte]
        db 0x32, 0xE4                           ; insn: xor ah, ah
        jmp word [cs:di+AtanTab]
.half:
        mov ax, 0x80
        jmp word [cs:di+AtanTab]

AtanTab:                                        ; eight words. The sign and swap flags select which adjustment
                                                ; runs; used by Atan2
        dw AtanDone
        dw AtanNegInc
        dw AtanNegTwo
        dw AtanInc
        dw AtanNeg
        dw AtanDec
        dw AtanDecTwo
        dw AtanIncNeg

;-----------------------------------------------------------------------------
; AtanNegInc                                                  03A3:1E2D  94 PC
; Neg ax, then add 100h.
;-----------------------------------------------------------------------------
AtanNegInc:
        neg ax
        add ah, 1
AtanDone:
        pop di
        leave
        retf
;-----------------------------------------------------------------------------
; AtanInc                                                     03A3:1E35  94 PC
; Add 100h.
;-----------------------------------------------------------------------------
AtanInc:
        add ah, 1
        jmp short AtanDone
;-----------------------------------------------------------------------------
; AtanNegTwo                                                  03A3:1E3A  94 PC
; Neg ax, then add 200h.
;-----------------------------------------------------------------------------
AtanNegTwo:
        neg ax
        add ah, 2
        jmp short AtanDone
;-----------------------------------------------------------------------------
; AtanNeg                                                     03A3:1E41  94 PC
; Neg ax.
;-----------------------------------------------------------------------------
AtanNeg:
        neg ax
        jmp short AtanDone
;-----------------------------------------------------------------------------
; AtanDec                                                     03A3:1E45  94 PC
; Subtract 100h.
;-----------------------------------------------------------------------------
AtanDec:
        sub ah, 1
        jmp short AtanDone
;-----------------------------------------------------------------------------
; AtanIncNeg                                                  03A3:1E4A  94 PC
; Add 100h, then neg ax.
;-----------------------------------------------------------------------------
AtanIncNeg:
        add ah, 1
        neg ax
        jmp short AtanDone
;-----------------------------------------------------------------------------
; AtanDecTwo                                                  03A3:1E51  94 PC
; Subtract 200h.
;-----------------------------------------------------------------------------
AtanDecTwo:
        sub ah, 2
        jmp short AtanDone

; Fill the far buffer with the byte argument. The count is the long at [bp+0Ah].
; Offsets stay under 16, then the fill moves 32K at a time. Word stores, or dword
; stores when Cpu386 is nonzero. FillFarZero uses a zero byte.

;-----------------------------------------------------------------------------
; FillFar                                                     03A3:1E56  94 PC
; Fills a far buffer with the byte argument. Long count. Same 32K window as
; CopyFar.
;-----------------------------------------------------------------------------
FillFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        mov ax, word [bp + 0xe]
        jmp short FillFarBody

;-----------------------------------------------------------------------------
; FillFarZero                                                 03A3:1E5F  94 PC
; Same fill with a zero byte.
;-----------------------------------------------------------------------------
FillFarZero:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push di
        db 0x33, 0xC0                           ; insn: xor ax, ax

FillFarBody:
        db 0x8A, 0xE0                           ; insn: mov ah, al
        les di, [bp + 6]
        call NormEsDi
        mov cx, word [bp + 0xa]
        mov dx, word [bp + 0xc]
        cld
        jmp short .2
.1:
        sub cx, 1
        sbb dx, 0
        jb short .5
        stosb
.2:
        test di, 0xf
        jne short .1
        cmp word ss:[Cpu386], 0
        jne short .6
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x13, 0xD2                           ; insn: adc dx, dx
        jmp short .4
.3:
        mov cx, 0x4000
        rep stosw
        sub di, 0x8000
        mov cx, es
        add cx, 0x800
        mov es, cx
.4:
        dec dx
        jns short .3
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 0x7fff
        shr cx, 1
        rep stosw
        db 0x13, 0xC9                           ; insn: adc cx, cx
        rep stosb
.5:
        pop di
        leave
        retf
.6:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl eax, 0x10
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x66, 0x33, 0xC9                     ; insn: xor ecx, ecx
        and edi, 0xffff
        db 0x03, 0xC9                           ; insn: add cx, cx
        db 0x13, 0xD2                           ; insn: adc dx, dx
        jmp short .8
.7:
        mov cx, 0x2000
        db 0xF3, 0x66, 0xAB                     ; insn: rep stosd
        sub di, 0x8000
        mov cx, es
        add cx, 0x800
        mov es, cx
.8:
        dec dx
        jns short .7
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 0x7fff
        shr cx, 2
        db 0xF3, 0x66, 0xAB                     ; insn: rep stosd
        db 0x8B, 0xCB                           ; insn: mov cx, bx
        and cx, 3
        rep stosb
        pop di
        leave
        retf
        db 0x00

; Order two points into the record at [bp+0Eh]. LineOpen skips the box test. LineClip rejects a line when both
; ends share an outcode against the box at ClipTopY/ClipBottomY and ClipLeftX/ClipRightX, and otherwise stores
; a direction byte. The equal-Y path is LineFlat and the overflow path is LineOverflow.
;
; A line with no clip bits returns 0 from LineOk.

;-----------------------------------------------------------------------------
; LineOpen                                                    03A3:1F00  94 PC
; Orders two points into the record at bp+0Eh and stores a direction byte.
; Skips the box test.
;-----------------------------------------------------------------------------
LineOpen:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push si
        push di
        mov byte [bp - 3], 1
        jmp short LineBody

;-----------------------------------------------------------------------------
; LineClip                                                    03A3:1F0E  94 PC
; Same setup after a box test. Both ends outside one edge is a reject.
;-----------------------------------------------------------------------------
LineClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -4
        push si
        push di
        mov byte [bp - 3], 0

LineBody:
        mov si, word [bp + 0xe]
        mov word [si + 0x12], 0xff
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov word [si], ax
        mov word [si + 4], ax
        mov word [si + 0x14], ax
        mov word [si + 0x16], ax
        mov word [si + 0x18], ax
        mov word [si + 0x1a], ax
        mov ax, word [bp + 8]
        mov bx, word [bp + 0xc]
        mov cx, word [bp + 6]
        mov dx, word [bp + 0xa]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jg short .1
        mov word [si + 2], cx
        mov word [si + 6], ax
        mov word [si + 8], dx
        mov word [si + 0xa], bx
        jmp short .2
.1:
        mov word [si + 2], dx
        mov word [si + 6], bx
        mov word [si + 8], cx
        mov word [si + 0xa], ax
.2:
        jne short .3
        jmp near LineFlat
.3:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        cmp byte [bp - 3], 0
        jne short .12
        mov ax, word [si + 6]
        mov bx, word [ClipTopY]
        mov cx, word [ClipBottomY]
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jl short .4
        mov dl, 8
        jmp near LineReject
.4:
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .5
        or dh, 4
.5:
        mov ax, word [si + 0xa]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .6
        mov dl, 4
        jmp near LineReject
.6:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jl short .7
        or dl, 8
.7:
        mov bx, word [ClipLeftX]
        mov cx, word [ClipRightX]
        mov ax, word [si + 2]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .8
        or dh, 2
.8:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jl short .9
        or dh, 1
.9:
        mov ax, word [si + 8]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .10
        or dl, 2
.10:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jl short .11
        or dl, 1
.11:
        test dh, dl
        je short .12
        db 0x22, 0xD6                           ; insn: and dl, dh
        jmp near LineReject
.12:
        db 0x0A, 0xD6                           ; insn: or dl, dh
        db 0x32, 0xF6                           ; insn: xor dh, dh
        mov word [bp - 2], dx
        mov cx, word [si + 0xa]
        sub cx, word [si + 6]
        jno short .14
.13:
        jmp near LineOverflow
.14:
        mov dx, word [si + 8]
        sub dx, word [si + 2]
        jo short .13
        jne short .15
        inc cx
        mov word [si + 0xe], cx
        mov byte [si + 0x12], 2
        jmp short .26
.15:
        jl short .22
        db 0x3B, 0xD1                           ; insn: cmp dx, cx
        jb short .20
        je short .21
        mov byte [si + 0x12], 8
.16:
        db 0x87, 0xCA                           ; insn: xchg dx, cx
.17:
        cmp cx, word [LineStepLimit]
        jge short .18
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        db 0x03, 0xDB                           ; insn: add bx, bx
        mov bx, word [bx + LineStepTable]
        db 0x03, 0xDA                           ; insn: add bx, dx
        db 0x03, 0xDA                           ; insn: add bx, dx
        mov ax, word [bx]
        jmp short .19
.18:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        div cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        shr bx, 1
        db 0x2B, 0xDA                           ; insn: sub bx, dx
        adc ax, 0
.19:
        mov word [si + 0xc], ax
        inc cx
        jo short .13
        mov word [si + 0xe], cx
        jmp short .26
.20:
        mov byte [si + 0x12], 6
        jmp short .17
.21:
        mov byte [si + 0x12], 4
        jmp short .25
.22:
        neg dx
        jo short .13
        db 0x3B, 0xD1                           ; insn: cmp dx, cx
        jb short .23
        je short .24
        mov byte [si + 0x12], 7
        jmp short .16
.23:
        mov byte [si + 0x12], 5
        jmp short .17
.24:
        mov byte [si + 0x12], 3
.25:
        inc cx
        mov word [si + 0xe], cx
.26:
        mov bx, word [bp - 2]
        db 0x03, 0xDB                           ; insn: add bx, bx
        je short LineOk
        jmp word [cs:bx+LineTab]
LineTab:                                        ; sixteen words. The outcode selects ClipRight, ClipLeft,
                                                ; ClipTop, ClipBottom, or LineOk; used by LineClip
        dw LineOk
        dw ClipRight
        dw ClipLeft
        dw ClipLeft
        dw ClipTop
        dw ClipTop
        dw ClipTop
        dw ClipTop
        dw ClipBottom
        dw ClipBottom
        dw ClipBottom
        dw ClipBottom
        dw ClipTop
        dw ClipTop
        dw ClipTop
        dw ClipTop

;-----------------------------------------------------------------------------
; LineOk                                                      03A3:2085  94 PC
; Xor ax, ax and the epilogue. Taken when the outcode is 0.
;-----------------------------------------------------------------------------
LineOk:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        pop di
        pop si
        leave
        retf

; Slide an endpoint onto one edge of the box. ClipTop uses the top, ClipBottom the bottom, and ClipLeft the
; left. The direction byte picks how X or Y moves with that edge. Each case then jumps to AfterTop,
; AfterBottom, or AfterLeft. ClipRet returns with AH 0.


;-----------------------------------------------------------------------------
; ClipTop                                                     03A3:208B  94 PC
; Pulls the line onto the top of the box. The direction byte selects how X
; moves.
;-----------------------------------------------------------------------------
ClipTop:
        mov ax, word [si + 6]
        mov cx, word [ClipTopY]
        mov word [si + 6], cx
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov bl, byte [si + 0x12]
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp word [cs:bx+TopTab]
TopTab:                                         ; nine words, one per direction. 0 and 1 are unused; used by
                                                ; ClipTop
        dw 0
        dw 0
        dw .1
        dw .2
        dw .3
        dw .4
        dw .5
        dw .6
        dw .8
.1:
        sub word [si + 0xe], cx
        jmp near AfterTop
.2:
        sub word [si + 2], cx
        sub word [si + 0xe], cx
        jmp near AfterTop
.3:
        add word [si + 2], cx
        sub word [si + 0xe], cx
        jmp near AfterTop
.4:
        mov ax, word [si + 0xc]
        mul cx
        sub word [si], ax
        sbb word [si + 2], dx
        sub word [si + 0xe], cx
        jmp near AfterTop
.5:
        mov ax, word [si + 0xc]
        mul cx
        add word [si], ax
        adc word [si + 2], dx
        sub word [si + 0xe], cx
        jmp near AfterTop
.6:
        mov word [si + 6], ax
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        sub word [si + 2], ax
        sub word [si + 0xe], ax
        jle short .7
        mul word [si + 0xc]
        add word [si + 4], ax
        adc word [si + 6], dx
        jmp near AfterTop
.7:
        mov word [si + 0xe], 1
        mov ax, word [ClipTopY]
        mov word [si + 6], ax
        mov ax, word [si + 8]
        mov word [si + 2], ax
        jmp near AfterTop
.8:
        mov word [si + 6], ax
        db 0x8B, 0xD1                           ; insn: mov dx, cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        add word [si + 2], ax
        sub word [si + 0xe], ax
        jle short .7
        mul word [si + 0xc]
        add word [si + 4], ax
        adc word [si + 6], dx
        jmp near AfterTop

;-----------------------------------------------------------------------------
; ClipBottom                                                  03A3:214D  94 PC
; Pulls the line onto the bottom of the box.
;-----------------------------------------------------------------------------
ClipBottom:
        mov cx, word [si + 0xa]
        mov dx, word [ClipBottomY]
        dec dx
        mov word [si + 0xa], dx
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        mov bl, byte [si + 0x12]
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp word [cs:bx+BotTab]
BotTab:                                         ; direction table for the bottom edge; used by ClipBottom
        dw 0
        dw 0
        dw .1
        dw .2
        dw .3
        dw .4
        dw .5
        dw .6
        dw .9
.1:
        sub word [si + 0xe], cx
        jmp near AfterBottom
.2:
        add word [si + 8], cx
        sub word [si + 0xe], cx
        jmp near AfterBottom
.3:
        sub word [si + 8], cx
        sub word [si + 0xe], cx
        jmp near AfterBottom
.4:
        mov dx, word [si + 0xe]
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        mov word [si + 0xe], dx
        dec dx
        mov ax, word [si + 0xc]
        mul dx
        mov bx, word [si]
        mov cx, word [si + 2]
        db 0x2B, 0xD8                           ; insn: sub bx, ax
        db 0x1B, 0xCA                           ; insn: sbb cx, dx
        add bx, 0x8000
        adc cx, 0
        mov word [si + 8], cx
        jmp near AfterBottom
.5:
        mov dx, word [si + 0xe]
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        mov word [si + 0xe], dx
        dec dx
        mov ax, word [si + 0xc]
        mul dx
        add ax, word [si]
        adc dx, word [si + 2]
        add ax, 0x8000
        adc dx, 0
        mov word [si + 8], dx
        jmp near AfterBottom
.6:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub ax, word [si + 4]
        sbb dx, word [si + 6]
        jl short .8
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
.7:
        mov dx, word [si + 2]
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        mov word [si + 8], dx
        inc ax
        mov word [si + 0xe], ax
        jmp near AfterBottom
.8:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        jmp short .7
.9:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub ax, word [si + 4]
        sbb dx, word [si + 6]
        jl short .8
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        mov dx, word [si + 2]
        db 0x03, 0xD0                           ; insn: add dx, ax
        mov word [si + 8], dx
        inc ax
        mov word [si + 0xe], ax
        jmp near AfterBottom

;-----------------------------------------------------------------------------
; ClipLeft                                                    03A3:221F  94 PC
; Pulls the line onto the left of the box.
;-----------------------------------------------------------------------------
ClipLeft:
        mov bl, byte [si + 0x12]
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp word [cs:bx+LeftTab]
LeftTab:                                        ; direction table for the left edge; used by ClipLeft
        dw 0
        dw 0
        dw .10
        dw .1
        dw .2
        dw .3
        dw .6
        dw .8
        dw .9
.1:
        mov cx, word [ClipLeftX]
        mov ax, word [si + 8]
        mov word [si + 8], cx
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        add word [si + 0x16], cx
        sub word [si + 0xe], cx
        sub word [si + 0xa], cx
        jmp near AfterLeft
.2:
        mov ax, word [si + 2]
        mov cx, word [ClipLeftX]
        mov word [si + 2], cx
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        add word [si + 0x14], cx
        add word [si + 6], cx
        sub word [si + 0xe], cx
        jmp near AfterLeft
.3:
        mov ax, word [si]
        mov dx, word [si + 2]
        mov cx, word [ClipLeftX]
        mov word [si + 8], cx
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        jl short .5
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        inc ax
.4:
        mov cx, word [si + 0xe]
        mov word [si + 0xe], ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        add word [si + 0x16], cx
        dec ax
        add ax, word [si + 6]
        mov word [si + 0xa], ax
        jmp near AfterLeft
.5:
        mov ax, 1
        jmp short .4
.6:
        mov dx, word [ClipLeftX]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub ax, word [si]
        sbb dx, word [si + 2]
        jl short .7
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        add word [si + 6], ax
        add word [si + 0x14], ax
        sub word [si + 0xe], ax
        jle short .10
        mul word [si + 0xc]
        add word [si], ax
        adc word [si + 2], dx
        jmp near AfterLeft
.7:
        jmp short .10
.8:
        mov ax, word [si + 2]
        mov dx, word [ClipLeftX]
        mov word [si + 8], dx
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        inc cx
        mov word [si + 0xe], cx
        mul word [si + 0xc]
        add ax, word [si + 4]
        adc dx, word [si + 6]
        add ax, 0x8000
        adc dx, 0
        mov ax, word [si + 0xa]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov word [si + 0xa], dx
        add word [si + 0x16], ax
        jmp near AfterLeft
.9:
        mov cx, word [si + 2]
        mov ax, word [ClipLeftX]
        mov word [si + 2], ax
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        sub word [si + 0xe], ax
        mul word [si + 0xc]
        mov bx, word [si + 4]
        mov cx, word [si + 6]
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x13, 0xD1                           ; insn: adc dx, cx
        mov word [si + 4], ax
        mov word [si + 6], dx
        add bx, 0x8000
        adc cx, 0
        add ax, 0x8000
        adc dx, 0
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        add word [si + 0x14], dx
        jmp near AfterLeft
.10:
        mov dx, 2
LineReject:
        mov byte [si + 0x13], dl
        mov word [si + 0xe], 0
        mov al, byte [si + 0x13]
        test al, 4
        je short .1
        mov bx, word [ClipTopY]
        mov word [si + 6], bx
        mov word [si + 4], 0
        dec bx
        mov word [si + 0xa], bx
        jmp short ClipRet
.1:
        test al, 8
        je short .2
        mov bx, word [ClipBottomY]
        mov word [si + 6], bx
        mov word [si + 4], 0
        jmp short ClipRet
.2:
        mov cx, word [si + 0xa]
        cmp cx, word [ClipBottomY]
        jl short .3
        mov cx, word [ClipBottomY]
        dec cx
.3:
        mov dx, word [si + 6]
        mov bx, word [si + 4]
        add bx, 0x8000
        adc dx, 0
        cmp dx, word [ClipTopY]
        jge short .4
        mov dx, word [ClipTopY]
.4:
        mov word [si + 6], dx
        mov word [si + 4], 0
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        dec dx
        inc cx
        mov word [si + 0xa], dx
        test al, 2
        je short .5
        add word [si + 0x16], cx
        jmp short ClipRet
.5:
        add word [si + 0x1a], cx

ClipRet:
        db 0x32, 0xE4                           ; insn: xor ah, ah
        pop di
        pop si
        leave
        retf


; ClipRight pulls the line onto the right edge. Directions 0 and 1 are unused. Direction 2 rejects the line.
; The other cases move an endpoint onto that edge. AfterTop runs ClipBottom when the bottom outcode is still
; set.
;
; AfterBottom rebuilds the left and right outcodes: both ends on one side is LineReject, and a side bit that
; remains goes back through LineTab. AfterLeft runs ClipRight when the right outcode is still set. LineFlat is
; the equal-Y path. LineOverflow shifts an endpoint that sits far outside the box.

;-----------------------------------------------------------------------------
; ClipRight                                                   03A3:23B4  94 PC
; Pulls the line onto the right of the box. LineTab outcode 1.
;-----------------------------------------------------------------------------
ClipRight:
        mov bl, byte [si + 0x12]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp word [cs:bx+RightTab]
RightTab:                                       ; direction table for the right edge. 0 and 1 are unused; used
                                                ; by ClipRight
        dw 0
        dw 0
        dw .1
        dw .2
        dw .3
        dw .4
        dw .5
        dw .6
        dw .7
.1:
        mov dx, 1
        jmp near LineReject
.2:
        mov cx, word [si + 2]
        mov ax, word [ClipRightX]
        dec ax
        mov word [si + 2], ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        add word [si + 6], cx
        sub word [si + 0xe], cx
        add word [si + 0x18], cx
        jmp near LineOk
.3:
        mov cx, word [ClipRightX]
        dec cx
        mov ax, word [si + 8]
        mov word [si + 8], cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        add word [si + 0x1a], ax
        sub word [si + 0xe], ax
        sub word [si + 0xa], ax
        jmp near LineOk
.4:
        mov ax, word [si]
        mov dx, word [si + 2]
        sub dx, word [ClipRightX]
        inc dx
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        sub word [si + 0xe], ax
        jle short .1
        add word [si + 6], ax
        add word [si + 0x18], ax
        mul word [si + 0xc]
        sub word [si], ax
        sbb word [si + 2], dx
        jmp near LineOk
.5:
        mov dx, word [ClipRightX]
        dec dx
        mov word [si + 8], dx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        sub ax, word [si]
        sbb dx, word [si + 2]
        jl short .1
        mov cx, word [si + 0xc]
        div cx
        shr cx, 1
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        adc ax, 0
        inc ax
        mov cx, word [si + 0xe]
        mov word [si + 0xe], ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        add word [si + 0x1a], cx
        dec ax
        add ax, word [si + 6]
        mov word [si + 0xa], ax
        jmp near LineOk
.6:
        mov ax, word [si + 2]
        mov cx, word [ClipRightX]
        dec cx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov word [si + 2], cx
        sub word [si + 0xe], ax
        mul word [si + 0xc]
        mov bx, word [si + 4]
        mov cx, word [si + 6]
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x13, 0xD1                           ; insn: adc dx, cx
        mov word [si + 4], ax
        mov word [si + 6], dx
        add bx, 0x8000
        adc cx, 0
        add ax, 0x8000
        adc dx, 0
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        add word [si + 0x18], dx
        jmp near LineOk
.7:
        mov ax, word [ClipRightX]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        dec cx
        mov word [si + 8], cx
        sub ax, word [si + 2]
        mov word [si + 0xe], ax
        dec ax
        mul word [si + 0xc]
        add ax, word [si + 4]
        adc dx, word [si + 6]
        add ax, 0x8000
        adc dx, 0
        mov ax, word [si + 0xa]
        db 0x2B, 0xC2                           ; insn: sub ax, dx
        mov word [si + 0xa], dx
        add word [si + 0x1a], ax
        jmp near LineOk
;-----------------------------------------------------------------------------
; AfterTop                                                    03A3:24CD  94 PC
; After a top clip, runs ClipBottom when that outcode is still set.
;-----------------------------------------------------------------------------
AfterTop:
        test word [bp - 2], 8
        je short AfterBottom
        jmp near ClipBottom
;-----------------------------------------------------------------------------
; AfterBottom                                                 03A3:24D7  94 PC
; Rebuilds the left and right outcodes. A shared side bit rejects the line.
;-----------------------------------------------------------------------------
AfterBottom:
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ax, word [si + 2]
        cmp ax, word [ClipLeftX]
        jge short .1
        or dh, 2
.1:
        mov bx, word [si]
        add bx, 0x8000
        adc ax, 0
        cmp ax, word [ClipRightX]
        jl short .2
        or dh, 1
.2:
        mov ax, word [si + 8]
        cmp ax, word [ClipLeftX]
        jge short .3
        or dl, 2
.3:
        cmp ax, word [ClipRightX]
        jl short .4
        or dl, 1
.4:
        test dh, dl
        je short .5
        db 0x22, 0xD6                           ; insn: and dl, dh
        jmp near LineReject
.5:
        db 0x0A, 0xD6                           ; insn: or dl, dh
        je short AfterLeft.1
        db 0x32, 0xF6                           ; insn: xor dh, dh
        mov word [bp - 2], dx
        jmp near LineBody.26
;-----------------------------------------------------------------------------
; AfterLeft                                                   03A3:2521  94 PC
; After a left clip, runs ClipRight when that outcode is still set.
;-----------------------------------------------------------------------------
AfterLeft:
        test word [bp - 2], 1
        je short .1
        jmp near ClipRight
.1:
        jmp near LineOk
;-----------------------------------------------------------------------------
; LineFlat                                                    03A3:252E  94 PC
; Equal-Y path. Clamps the horizontal line to the box unless the open flag is
; set.
;-----------------------------------------------------------------------------
LineFlat:
        mov byte [si + 0x12], 1
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jne short .1
        mov byte [si + 0x12], 9
.1:
        jle short .2
        mov byte [si + 0x12], 0
        mov word [si + 2], dx
        mov word [si + 8], cx
        db 0x87, 0xCA                           ; insn: xchg dx, cx
.2:
        cmp byte [bp - 3], 0
        jne short .4
        mov bx, word [ClipTopY]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .5
        mov al, 4
        mov word [si + 6], bx
        mov word [si + 0xa], bx
.3:
        mov byte [si + 0x13], al
        mov word [si + 0xe], 0
        db 0x32, 0xE4                           ; insn: xor ah, ah
        pop di
        pop si
        leave
        retf
.4:
        db 0x2B, 0xD1                           ; insn: sub dx, cx
        inc dx
        mov word [si + 0xe], dx
        jmp near LineOk
.5:
        mov bx, word [ClipBottomY]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jl short .6
        mov al, 8
        mov word [si + 6], bx
        mov word [si + 0xa], bx
        jmp short .3
.6:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        inc ax
        mov word [si + 0xe], ax
        cmp dx, word [ClipLeftX]
        jge short .7
        dec word [si + 0xa]
        mov word [si + 0x16], 1
        mov al, 2
        jmp short .3
.7:
        cmp cx, word [ClipRightX]
        jl short .8
        dec word [si + 0xa]
        mov word [si + 0x1a], 1
        mov al, 1
        jmp short .3
.8:
        mov ax, word [ClipLeftX]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        jle short .9
        mov word [si + 2], bx
        sub word [si + 0xe], ax
.9:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov bx, word [ClipRightX]
        dec bx
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jle short .10
        sub word [si + 0xe], ax
        mov word [si + 8], bx
.10:
        jmp near LineOk
;-----------------------------------------------------------------------------
; LineOverflow                                                03A3:25D6  94 PC
; Arithmetic-shifts an endpoint far outside the box, then clips again.
;-----------------------------------------------------------------------------
LineOverflow:
        mov cx, word [si + 0xa]
        sar cx, 1
        mov ax, word [si + 6]
        sar ax, 1
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        sar cx, 1
        mov dx, word [si + 8]
        sar dx, 1
        mov ax, word [si + 2]
        sar ax, 1
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        sar dx, 1
.1:
        cmp word [si + 6], 0xc180
        jg short .7
.2:
        mov ax, word [si + 6]
        db 0x03, 0xC1                           ; insn: add ax, cx
        mov word [si + 6], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        sub ax, word [ClipTopY]
        jle short .6
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jle short .3
        db 0x8B, 0xC1                           ; insn: mov ax, cx
.3:
        sub bx, word [ClipBottomY]
        jle short .4
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jle short .6
.4:
        mov bx, word [si + 2]
        cmp bx, word [ClipLeftX]
        jge short .5
        add word [si + 0x14], ax
        jmp short .6
.5:
        add word [si + 0x18], ax
.6:
        add word [si + 2], dx
        jmp short .1
.7:
        cmp word [si + 0xa], 0x3e80
        jge short .8
        cmp word [si + 2], 0xc180
        jle short .2
        cmp word [si + 2], 0x3e80
        jge short .2
        cmp word [si + 8], 0xc180
        jle short .8
        cmp word [si + 8], 0x3e80
        jge short .8
        jmp near LineBody.3
.8:
        mov ax, word [si + 0xa]
        db 0x2B, 0xC1                           ; insn: sub ax, cx
        mov word [si + 0xa], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        sub ax, word [ClipBottomY]
        inc ax
        jge short .12
        neg ax
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jle short .9
        db 0x8B, 0xC1                           ; insn: mov ax, cx
.9:
        sub bx, word [ClipTopY]
        inc bx
        jge short .10
        db 0x03, 0xC3                           ; insn: add ax, bx
        jle short .12
.10:
        mov bx, word [si + 8]
        cmp bx, word [ClipLeftX]
        jge short .11
        add word [si + 0x16], ax
        jmp short .12
.11:
        add word [si + 0x1a], ax
.12:
        sub word [si + 8], dx
        jmp short .7
        db 0

; Open the path at [bp+6] for reading. The handle is written through [bp+8], the length through [bp+0Ch], and
; the position after a seek to the start through [bp+0Ah]. FileOpenArg takes the failure word from the caller.
; FileOpen forces 0. FileOpenMsg forces 1. Zero clears those three results.
;
; One reports the path through FatalError. A failed open whose AltPath byte is set reads 400h bytes from that
; path and calls the far routine at AltCall. FileClose closes the handle at [bp+6], and skips the DOS call
; when it is 0.
;
; ReadAt seeks to the dword at [bp+8], then reads [bp+0Ch] bytes in 4000h chunks into the far buffer at
; [bp+10h]. ReadClose reads until a short read and then closes the handle. Both return that far pointer, or
; zero when the flag is 0. A flag of 1 reports the handle through FatalError.

;-----------------------------------------------------------------------------
; FileOpenArg                                                 03A3:2690  94 PC
; Opens a path and writes the handle, length, and start position. Failure
; word from the caller.
;-----------------------------------------------------------------------------
FileOpenArg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        mov ax, word [bp + 0xe]
        mov word [bp - 2], ax
        jmp short FileOpenBody
;-----------------------------------------------------------------------------
; FileOpen                                                    03A3:269E  94 PC
; Same open with the failure word forced to 0.
;-----------------------------------------------------------------------------
FileOpen:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        mov word [bp - 2], 0
        jmp short FileOpenBody
;-----------------------------------------------------------------------------
; FileOpenMsg                                                 03A3:26AB  94 PC
; Same open with the failure word forced to 1.
;-----------------------------------------------------------------------------
FileOpenMsg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -2
        mov word [bp - 2], 1
FileOpenBody:
        mov dx, word [bp + 6]
        db 0x32, 0xC0                           ; insn: xor al, al
        mov ah, 0x3d
        int 0x21
        jb short FileOpenAlt
        mov bx, word [bp + 8]
        mov word [bx], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, 0x4202
        db 0x33, 0xC9                           ; insn: xor cx, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        int 0x21
        jb short FileOpenAlt
        mov bx, word [bp + 0xc]
        mov word [bx], ax
        mov word [bx + 2], dx
        mov bx, word [bp + 8]
        mov bx, word [bx]
        mov ax, 0x4200
        db 0x33, 0xC9                           ; insn: xor cx, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        int 0x21
        jb short FileOpenAlt
        mov bx, word [bp + 0xa]
        mov word [bx], ax
        mov word [bx + 2], ax                   ; both words from AX
        leave
        retf
;-----------------------------------------------------------------------------
; FileOpenAlt                                                 03A3:26F5  94 PC
; Second try of a failed open: open AltPath when one is set and read its first 400h
; bytes into AltBuf. Falls into FileOpenFail when there is none or it fails too.
;-----------------------------------------------------------------------------
FileOpenAlt:
        cmp byte [AltPath], 0
        je short FileOpenFail
        mov dx, AltPath
        db 0x32, 0xC0                           ; insn: xor al, al
        mov ah, 0x3d
        int 0x21
        jb short FileOpenFail
        mov bx, word [bp + 8]
        mov word [bx], ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        lds dx, [AltBuf]
        mov cx, 0x400
        mov ah, 0x3f
        int 0x21
        mov ax, ss
        mov ds, ax
        jb short FileOpenFail
        push word [bp + 6]
        push word [AltBuf+2]
        push word [AltBuf]
        call far [AltCall]
        add sp, 6
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jne short .1
        db 0x0B, 0xD2                           ; insn: or dx, dx
        je short FileOpenFail
.1:
        mov bx, word [bp + 0xa]
        mov word [bx], ax
        mov word [bx + 2], dx
        mov bx, word [AltSize]
        mov cx, word [bx]
        mov ax, word [bx + 2]
        mov bx, word [bp + 0xc]
        mov word [bx], cx
        mov word [bx + 2], ax
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x4200
        mov bx, word [bp + 8]
        mov bx, word [bx]
        int 0x21
        jb short FileOpenFail
        leave
        retf
;-----------------------------------------------------------------------------
; FileOpenFail                                                03A3:2762  94 PC
; Clean-up after a failed open: close the handle stored through the argument pointer
; and clear the caller's result words; a fatal error when the caller asked for one.
;-----------------------------------------------------------------------------
FileOpenFail:
        mov bx, word [bp + 8]
        mov ax, word [bx]
        mov word [bx], 0
        push ax
        push cs
        call FileClose
        add sp, 2
        cmp word [bp - 2], 0
        jne short .1
        mov bx, word [bp + 0xc]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov word [bx], ax
        mov word [bx + 2], ax
        mov bx, word [bp + 0xa]
        mov word [bx], ax
        mov word [bx + 2], ax
        leave
        retf
.1:
        mov ax, ss
        mov ds, ax
        mov ax, 0x75e2
        push word [bp + 6]
        push ax
        call 0xF4A:FatalError
FileClose:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov bx, word [bp + 6]
        cmp bx, 0
        je short .1
        mov ah, 0x3e
        int 0x21
.1:
        leave
        retf
;-----------------------------------------------------------------------------
; ReadAtArg                                                   03A3:27AE  94 PC
; Seeks, then reads a count in 4000h chunks into a far buffer.
;-----------------------------------------------------------------------------
ReadAtArg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov ax, word [bp + 0x14]
        mov word [bp - 6], ax
        jmp short ReadAtBody
;-----------------------------------------------------------------------------
; ReadAt                                                      03A3:27BD  94 PC
; Same read with the failure word forced to 0.
;-----------------------------------------------------------------------------
ReadAt:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov word [bp - 6], 0
        jmp short ReadAtBody
;-----------------------------------------------------------------------------
; ReadAtMsg                                                   03A3:27CB  94 PC
; Same read with the failure word forced to 1.
;-----------------------------------------------------------------------------
ReadAtMsg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov word [bp - 6], 1
ReadAtBody:
        mov ax, word [bp + 0x10]
        mov word [bp - 2], ax
        mov ax, word [bp + 0x12]
        mov word [bp - 4], ax
        mov bx, word [bp + 6]
        mov ax, 0x4200
        mov cx, word [bp + 0xa]
        mov dx, word [bp + 8]
        int 0x21
        jb short ReadAtFail
.1:
        mov ds, word [bp - 4]
        mov dx, word [bp - 2]
        mov cx, 0x4000
        sub word [bp + 0xc], cx
        sbb word [bp + 0xe], 0
        jge short .2
        add cx, word [bp + 0xc]
        jle short .3
.2:
        mov bx, word [bp + 6]
        mov ah, 0x3f
        int 0x21
        jb short ReadAtFail
        add word [bp - 4], 0x400
        jmp short .1
.3:
        mov ax, word [bp + 0x10]
        mov dx, word [bp + 0x12]
        pop ds
        leave
        retf
;-----------------------------------------------------------------------------
; ReadAtFail                                                  03A3:2823  94 PC
; Error exit of the read-at routine above: return DX:AX 0, or a fatal error with the
; file name when the caller asked for one.
;-----------------------------------------------------------------------------
ReadAtFail:
        cmp word [bp - 6], 0
        jne short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x33, 0xD2                           ; insn: xor dx, dx
        pop ds
        leave
        retf
.1:
        mov ax, 0x75f1
        mov bx, ss
        mov ds, bx
        push word [bp + 6]
        push ax
        call 0xF4A:FatalError
ReadCloseArg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov ax, word [bp + 0xc]
        mov word [bp - 6], ax
        jmp short ReadCloseBody
;-----------------------------------------------------------------------------
; ReadClose                                                   03A3:284F  94 PC
; Same read with the failure word forced to 0.
;-----------------------------------------------------------------------------
ReadClose:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov word [bp - 6], 0
        jmp short ReadCloseBody
;-----------------------------------------------------------------------------
; ReadCloseMsg                                                03A3:285D  94 PC
; Same read with the failure word forced to 1.
;-----------------------------------------------------------------------------
ReadCloseMsg:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -6
        push ds
        mov word [bp - 6], 1
ReadCloseBody:
        mov ax, word [bp + 8]
        mov word [bp - 2], ax
        mov ax, word [bp + 0xa]
        mov word [bp - 4], ax
.1:
        mov ds, word [bp - 4]
        mov dx, word [bp - 2]
        mov cx, 0x4000
        mov bx, word [bp + 6]
        mov ah, 0x3f
        int 0x21
        jb short ReadCloseFail
        add word [bp - 4], 0x400
        cmp ax, 0x4000
        je short .1
        mov bx, word [bp + 6]
        mov ah, 0x3e
        int 0x21
        mov ax, word [bp + 8]
        mov dx, word [bp + 0xa]
        pop ds
        leave
        retf
;-----------------------------------------------------------------------------
; ReadCloseFail                                               03A3:28A1  94 PC
; Error exit of the read-and-close routine above: return DX:AX 0, or a fatal error with
; the file name when the caller asked for one.
;-----------------------------------------------------------------------------
ReadCloseFail:
        cmp word [bp - 6], 0
        jne short .1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x33, 0xD2                           ; insn: xor dx, dx
        pop ds
        leave
        retf
.1:
        mov ax, 0x75f1
        mov bx, ss
        mov ds, bx
        push word [bp + 6]
        push ax
        call 0xF4A:FatalError

; (arg1 * arg2 + 1FFFh) >> 14, returned in AX. The two words sit above the far return address. CpuProbe
; records the processor. A 286 or later pushes SP before decrementing it, so the compare falls through and
; Cpu286 is set. Flag bits 12-14 stick on a 386 or later, which sets Cpu386.
;
; CopyFar and FillFar test that word before a dword move. CpuPe is the PE bit from smsw. Cpu486 is set when
; the alignment flag can be flipped. An 8086 leaves all four words clear. NormFar returns the caller's pointer
; with the offset under 16. NormDsSi and NormEsDi do that for DS:SI and ES:DI. FarZero returns AX 0.

Mul16k:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
.regs:
        imul dx
        add ax, 0x1fff
        adc dx, 0
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x13, 0xD2                           ; insn: adc dx, dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        retf
        db 0
;-----------------------------------------------------------------------------
; CpuProbe                                                    03A3:28DA  94 PC
; Sets Cpu286, Cpu386, Cpu486, and CpuPe. Cpu386 selects dword moves.
;-----------------------------------------------------------------------------
CpuProbe:
        pushf
        push sp
        pop bx
        db 0x3B, 0xDC                           ; insn: cmp bx, sp
        jne short CpuProbeDone
        mov word [Cpu286], 1
        pushf
        pop bx
        or bx, 0x7000
        push bx
        popf
        pushf
        pop bx
        and bx, 0x7000
        je short CpuProbeDone
        mov word [Cpu386], 1
        movzx esp, sp
        smsw ax
        and ax, 1
        mov word [CpuPe], ax
        and esp, 0xffff
        db 0x66, 0x8B, 0xD4                     ; insn: mov edx, esp
        and esp, 0xfffffffc
        pushfd
        pop eax
        db 0x66, 0x8B, 0xC8                     ; insn: mov ecx, eax
        xor eax, 0x40000
        push eax
        popfd
        pushfd
        pop eax
        db 0x66, 0x33, 0xC1                     ; insn: xor eax, ecx
        shr eax, 0x12
        and ax, 1
        mov word [Cpu486], ax
        db 0x66, 0x8B, 0xE2                     ; insn: mov esp, edx
CpuProbeDone:
        popf
        retf
        db 0
;-----------------------------------------------------------------------------
; NormFar                                                     03A3:2940  94 PC
; Returns the caller's far pointer with the offset under 16.
;-----------------------------------------------------------------------------
NormFar:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        mov dx, word [bx + 6]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        and ax, 0xf
        shr bx, 4
        db 0x03, 0xD3                           ; insn: add dx, bx
        retf
;-----------------------------------------------------------------------------
; NormDsSi                                                    03A3:2953  94 PC
; Folds DS:SI so SI is under 16. CopyFar calls this.
;-----------------------------------------------------------------------------
NormDsSi:
        push ax
        push si
        shr si, 4
        mov ax, ds
        db 0x03, 0xC6                           ; insn: add ax, si
        mov ds, ax
        pop si
        and si, 0xf
        pop ax
        ret
;-----------------------------------------------------------------------------
; NormEsDi                                                    03A3:2964  94 PC
; Folds ES:DI so DI is under 16. CopyFar and FillFar call this.
;-----------------------------------------------------------------------------
NormEsDi:
        push ax
        push di
        shr di, 4
        mov ax, es
        db 0x03, 0xC7                           ; insn: add ax, di
        mov es, ax
        pop di
        and di, 0xf
        pop ax
        ret
        db 0
;-----------------------------------------------------------------------------
; FarZero                                                     03A3:2976  94 PC
; Xor ax, ax and retf.
;-----------------------------------------------------------------------------
FarZero:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        retf
        db 0

; Another four entries into FillPoly. SI comes from [bp+0Ah], or from the address of that argument. ScanFn is
; 48D2h instead of the 3ABBh ArgSetup stores. The byte at [bp-9] selects which direction table SpanBack uses.
; FillPoly walks a list of X,Y points. [bp+8] is the count. A list that misses the box returns.
;
; A flat list calls LineFn. Each rising edge goes through LineClip or LineOpen, and ScanFn is called once per
; scanline with the two edge tables built on the stack.

;-----------------------------------------------------------------------------
; FillFlag1                                                   03A3:297A  94 PC
; Enters FillPoly with SI from [bp+0Ah] and the flag byte 1. ScanFn is 48D2h.
;-----------------------------------------------------------------------------
FillFlag1:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 1
        jmp short FillArg
;-----------------------------------------------------------------------------
; FillFlag0                                                   03A3:2989  94 PC
; Same entry with the flag byte 0.
;-----------------------------------------------------------------------------
FillFlag0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 0
FillArg:
        mov ax, 0x48d2
        mov word [ScanFn], ax
        mov ax, 0xc
        mov word [LineFn], ax
        mov si, word [bp + 0xa]
        jmp short FillPoly
;-----------------------------------------------------------------------------
; FillAddr1                                                   03A3:29A7  94 PC
; Enters FillPoly with SI the address of [bp+0Ah] and the flag byte 1.
;-----------------------------------------------------------------------------
FillAddr1:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 1
        jmp short FillAddr
;-----------------------------------------------------------------------------
; FillAddr0                                                   03A3:29B6  94 PC
; Same entry with the flag byte 0.
;-----------------------------------------------------------------------------
FillAddr0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 0
FillAddr:
        mov ax, 0x48d2
        mov word [ScanFn], ax
        mov ax, 0xc
        mov word [LineFn], ax
        lea si, [bp + 0xa]
FillPoly:
        mov word [bp - 6], si
        mov cx, word [bp + 8]
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        dec ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC6                           ; insn: add ax, si
        mov word [bp - 8], ax
        cld
        mov ax, ss
        mov es, ax
        lea ax, [bp - 0x796]
        mov word [bp - 0x16], ax
        mov ax, word [ClipLeftX]
        mov word [bp - 2], ax
        mov ax, word [ClipRightX]
        dec ax
        mov word [bp - 4], ax
        mov ax, word [si + 2]
        mov word [bp - 0xc], ax
        mov word [bp - 0x10], ax
        mov bx, word [si]
        db 0x8B, 0xD3                           ; insn: mov dx, bx
        mov word [bp - 0xe], si
        mov word [bp - 0x12], si
        add si, 4
        dec cx
        jne short .1
        push word [bp + 6]
        mov si, word [bp - 6]
        push word [si + 2]
        push word [si]
        push word [si + 2]
        push word [si]
        call far [LineFn]
        add sp, 0xa
        pop di
        pop si
        leave
        retf
.1:
        mov ax, word [si + 2]
        cmp ax, word [bp - 0xc]
        jg short .2
        mov word [bp - 0xc], ax
        mov word [bp - 0xe], si
.2:
        cmp ax, word [bp - 0x10]
        jle short .3
        mov word [bp - 0x10], ax
        mov word [bp - 0x12], si
.3:
        mov ax, word [si]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .4
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.4:
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jle short .5
        db 0x8B, 0xD0                           ; insn: mov dx, ax
.5:
        add si, 4
        loop .1
        cmp dx, word [bp - 2]
        jl short .9
        cmp bx, word [bp - 4]
        jge short .9
        mov ax, word [bp - 0x10]
        cmp ax, word [ClipTopY]
        jl short .9
        mov cx, word [bp - 0xc]
        cmp cx, word [ClipBottomY]
        jge short .9
        mov byte [bp - 0xa], 0
        cmp dx, word [bp - 4]
        jg short .6
        cmp bx, word [bp - 2]
        jl short .6
        cmp ax, word [ClipBottomY]
        jge short .6
        cmp cx, word [ClipTopY]
        jge short .7
.6:
        mov byte [bp - 0xa], 1
.7:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        je short .8
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jne short .10
.8:
        push word [bp + 6]
        mov si, word [bp - 6]
        push ax
        push dx
        push cx
        push bx
        call far [LineFn]
        add sp, 0xa
.9:
        pop di
        pop si
        leave
        retf
.10:
        lea si, [bp - 0x7ce]
        mov di, word [bp - 0xe]
.11:
        mov ax, word [di + 2]
        mov cx, word [di]
        add di, 4
        cmp di, word [bp - 8]
        jbe short .12
        mov di, word [bp - 6]
.12:
        mov dx, word [di + 2]
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jle short .15
        push si
        push dx
        push word [di]
        push ax
        push cx
        cmp byte [bp - 0xa], 0
        je short .13
        call 0x03A3:LineClip
        mov word [bp - 0x14], di
        call SpanMargin
        jmp short .14
.13:
        call 0x03A3:LineOpen
        mov word [bp - 0x14], di
        call SpanFill
.14:
        mov di, word [bp - 0x14]
        add sp, 0xa
.15:
        cmp di, word [bp - 0x12]
        jne short .11
        mov di, word [bp - 0xe]
.16:
        mov ax, word [di + 2]
        mov cx, word [di]
        sub di, 4
        cmp di, word [bp - 6]
        jae short .17
        mov di, word [bp - 8]
.17:
        mov dx, word [di + 2]
        db 0x3B, 0xD0                           ; insn: cmp dx, ax
        jle short .20
        push si
        push dx
        push word [di]
        push ax
        push cx
        cmp byte [bp - 0xa], 0
        je short .18
        call 0x03A3:LineClip
        jmp short .19
.18:
        call 0x03A3:LineOpen
.19:
        mov word [bp - 0x14], di
        call SpanBack
        mov di, word [bp - 0x14]
        add sp, 0xa
.20:
        cmp di, word [bp - 0x12]
        jne short .16
        mov ax, word [bp - 0x10]
        cmp ax, word [ClipBottomY]
        jl short .21
        mov ax, word [ClipBottomY]
        dec ax
.21:
        mov bx, word [bp - 0xc]
        cmp bx, word [ClipTopY]
        jge short .22
        mov bx, word [ClipTopY]
.22:
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jle short .23
        inc ax
        push word [bp + 6]
        push ax
        push bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        lea ax, [bp - 0x3d6]
        db 0x03, 0xC3                           ; insn: add ax, bx
        push ax
        lea ax, [bp - 0x796]
        db 0x03, 0xC3                           ; insn: add ax, bx
        push ax
        call far [ScanFn]
        add sp, 0xa
.23:
        pop di
        pop si
        leave
        retf

; Write one clipped edge into the two scanline tables. They sit 3C0h bytes apart, one word per row. SpanMargin
; fills the rows the clipper counted with the left or right side of the box. SpanFill and SpanBack walk the
; edge. The direction byte selects the case.
;
; SpanBack uses SpanTab3 when the byte at [bp-9] is 0, and SpanTab2 otherwise. Directions 0, 1, and 9 return.

;-----------------------------------------------------------------------------
; SpanMargin                                                  03A3:2B83  94 PC
; Fills the clipped-off scanline rows with the left or right side of the box.
;-----------------------------------------------------------------------------
SpanMargin:
        mov cx, word [si + 0x14]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .1
        mov di, word [si + 6]
        mov dx, word [si + 4]
        add dx, 0x8000
        adc di, 0
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipLeftX]
        push cx
        push di
        rep stosw
        pop di
        pop cx
        add di, 0x3c0
        dec ax
        rep stosw
.1:
        mov cx, word [si + 0x18]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .2
        mov di, word [si + 6]
        mov dx, word [si + 4]
        add dx, 0x8000
        adc di, 0
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipRightX]
        push cx
        push di
        rep stosw
        pop di
        pop cx
        add di, 0x3c0
        dec ax
        rep stosw
.2:
        mov cx, word [si + 0x16]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .3
        mov di, word [si + 0xa]
        inc di
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipLeftX]
        push cx
        push di
        rep stosw
        pop di
        pop cx
        add di, 0x3c0
        dec ax
        rep stosw
.3:
        mov cx, word [si + 0x1a]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short SpanFill
        mov di, word [si + 0xa]
        inc di
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipRightX]
        push cx
        push di
        rep stosw
        pop di
        pop cx
        add di, 0x3c0
        dec ax
        rep stosw
SpanFill:
        mov cx, word [si + 0xe]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short SpanTab.3
        mov di, word [si + 6]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov bl, byte [si + 0x12]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        jmp word [cs:bx+SpanTab]
SpanTab:                                        ; ten words, one per direction. 0, 1, and 9 return; used by
                                                ; SpanMargin, SpanBack
        dw .3
        dw .3
        dw .1
        dw .4
        dw .6
        dw .8
        dw .10
        dw .12
        dw .16
        dw .3
.1:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.2:
        mov word [di + 0x3c0], ax
        stosw
        loop .2
.3:
        ret
.4:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.5:
        mov word [di + 0x3c0], ax
        stosw
        dec ax
        loop .5
        ret
.6:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.7:
        mov word [di + 0x3c0], ax
        stosw
        inc ax
        loop .7
        ret
.8:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.9:
        mov word [di + 0x3c0], ax
        stosw
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .9
        ret
.10:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.11:
        mov word [di + 0x3c0], ax
        stosw
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .11
        ret
.12:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .13
        add di, 2
.13:
        mov word [di + 0x3c0], ax
.14:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .15
        stosw
        dec ax
        loop .13
        sub di, 2
        ret
.15:
        dec ax
        loop .14
        inc ax
        mov word [di], ax
        ret
.16:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .17
        add di, 2
.17:
        mov word [di], ax
.18:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .19
        mov word [di + 0x3c0], ax
        add di, 2
        inc ax
        loop .17
        sub di, 2
        ret
.19:
        inc ax
        loop .18
        dec ax
        mov word [di + 0x3c0], ax
        ret
;-----------------------------------------------------------------------------
; SpanBack                                                    03A3:2D10  94 PC
; Same edge walk. The flag byte at bp-9 selects SpanTab2 or SpanTab3.
;-----------------------------------------------------------------------------
SpanBack:
        mov cx, word [si + 0xe]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short SpanTab2.3
        mov di, word [si + 6]
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov bl, byte [si + 0x12]
        db 0x32, 0xFF                           ; insn: xor bh, bh
        db 0x03, 0xDB                           ; insn: add bx, bx
        cmp byte [bp - 9], 0
        jne short .1
        jmp word [cs:bx+SpanTab3]
.1:
        jmp word [cs:bx+SpanTab2]
SpanTab2:                                       ; direction table used when the FillPoly flag byte is set;
                                                ; used by SpanBack
        dw SpanTab.3
        dw SpanTab.3
        dw .1
        dw .6
        dw .10
        dw .14
        dw .18
        dw .22
        dw .28
        dw SpanTab.3
.1:
        mov ax, word [si + 2]
.2:
        cmp word [di + 0x3c0], ax
        jl short .4
        cmp word [di], ax
        jle short .5
        stosw
        loop .2
.3:
        jmp near SpanTab3.45
.4:
        mov word [di + 0x3c0], ax
.5:
        add di, 2
        loop .2
        jmp near SpanTab3.45
.6:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.7:
        cmp word [di + 0x3c0], ax
        jl short .8
        cmp word [di], ax
        jle short .9
        stosw
        dec ax
        loop .7
        jmp near SpanTab3.45
.8:
        mov word [di + 0x3c0], ax
.9:
        add di, 2
        dec ax
        loop .7
        jmp near SpanTab3.45
.10:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.11:
        cmp word [di + 0x3c0], ax
        jl short .12
        cmp word [di], ax
        jle short .13
        stosw
        inc ax
        loop .11
        jmp near SpanTab3.45
.12:
        mov word [di + 0x3c0], ax
.13:
        add di, 2
        inc ax
        loop .11
        jmp near SpanTab3.45
.14:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.15:
        cmp word [di + 0x3c0], ax
        jl short .16
        cmp word [di], ax
        jle short .17
        stosw
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .15
        jmp near SpanTab3.45
.16:
        mov word [di + 0x3c0], ax
.17:
        add di, 2
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .15
        jmp near SpanTab3.45
.18:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.19:
        cmp word [di + 0x3c0], ax
        jl short .20
        cmp word [di], ax
        jle short .21
        stosw
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .19
        jmp near SpanTab3.45
.20:
        mov word [di + 0x3c0], ax
.21:
        add di, 2
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .19
        jmp near SpanTab3.45
.22:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .23
        add di, 2
.23:
        cmp word [di + 0x3c0], ax
        jge short .24
        mov word [di + 0x3c0], ax
.24:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .26
        cmp word [di], ax
        jle short .25
        mov word [di], ax
.25:
        add di, 2
        dec ax
        loop .23
        sub di, 2
        jmp near SpanTab3.45
.26:
        dec ax
        loop .24
        inc ax
        cmp word [di], ax
        jle short .27
        mov word [di], ax
.27:
        jmp near SpanTab3.45
.28:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .29
        add di, 2
.29:
        cmp word [di], ax
        jle short .30
        mov word [di], ax
.30:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .32
        cmp word [di + 0x3c0], ax
        jge short .31
        mov word [di + 0x3c0], ax
.31:
        add di, 2
        inc ax
        loop .29
        sub di, 2
        jmp near SpanTab3.45
.32:
        inc ax
        loop .30
        dec ax
        cmp word [di + 0x3c0], ax
        jge short .27
        mov word [di + 0x3c0], ax
        jmp near SpanTab3.45
SpanTab3:                                       ; direction table used when the FillPoly flag byte is clear;
                                                ; used by SpanBack
        dw SpanTab.3
        dw SpanTab.3
        dw .1
        dw .5
        dw .10
        dw .15
        dw .20
        dw .25
        dw .35
        dw SpanTab.3
.1:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.2:
        cmp word [di], ax
        jg short .3
        cmp word [di + 0x3c0], ax
        jl short .4
        add di, 2
        loop .2
        jmp near .45
.3:
        rep stosw
        jmp near .45
.4:
        add di, 0x3c0
        rep stosw
        jmp near .45
.5:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.6:
        cmp word [di], ax
        jg short .7
        cmp word [di + 0x3c0], ax
        jl short .8
        add di, 2
        dec ax
        loop .6
        jmp near .45
.7:
        stosw
        dec ax
        loop .7
        jmp near .45
.8:
        add di, 0x3c0
.9:
        stosw
        dec ax
        loop .9
        jmp near .45
.10:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
.11:
        cmp word [di], ax
        jg short .12
        cmp word [di + 0x3c0], ax
        jl short .13
        add di, 2
        inc ax
        loop .11
        jmp near .45
.12:
        stosw
        inc ax
        loop .12
        jmp near .45
.13:
        add di, 0x3c0
.14:
        stosw
        inc ax
        loop .14
        jmp near .45
.15:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.16:
        cmp word [di], ax
        jg short .17
        cmp word [di + 0x3c0], ax
        jl short .18
        add di, 2
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .16
        jmp near .45
.17:
        stosw
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .17
        jmp near .45
.18:
        add di, 0x3c0
.19:
        stosw
        db 0x2B, 0xD3                           ; insn: sub dx, bx
        sbb ax, 0
        loop .19
        jmp near .45
.20:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov dx, word [si]
        add dx, 0x8000
        adc ax, 0
        mov bx, word [si + 0xc]
.21:
        cmp word [di], ax
        jg short .22
        cmp word [di + 0x3c0], ax
        jl short .23
        add di, 2
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .21
        jmp near .45
.22:
        stosw
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .22
        jmp near .45
.23:
        add di, 0x3c0
.24:
        stosw
        db 0x03, 0xD3                           ; insn: add dx, bx
        adc ax, 0
        loop .24
        jmp near .45
.25:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .26
        add di, 2
.26:
        cmp word [di + 0x3c0], ax
        jl short .28
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .27
        cmp word [di], ax
        jg short .33
        add di, 2
.27:
        dec ax
        loop .26
        jmp short .45
.28:
        add di, 0x3c0
.29:
        stosw
.30:
        dec ax
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .31
        loop .29
        jmp short .45
.31:
        loop .30
        jmp short .45
.32:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .34
.33:
        stosw
        dec ax
        loop .32
        jmp short .45
.34:
        dec ax
        loop .32
        inc ax
        mov word [di], ax
        jmp short .45
.35:
        mov cx, word [si + 0xe]
        mov ax, word [si + 2]
        mov bx, word [si + 0xc]
        mov dx, word [si + 4]
        add dx, 0x8000
        jae short .36
        add di, 2
.36:
        cmp word [di], ax
        jg short .43
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .37
        cmp word [di + 0x3c0], ax
        jl short .38
        add di, 2
.37:
        inc ax
        loop .36
        jmp short .45
.38:
        add di, 0x3c0
.39:
        mov word [di], ax
.40:
        inc ax
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .41
        add di, 2
        loop .39
        dec ax
        mov word [di], ax
        jmp short .45
.41:
        loop .40
        add di, 2
        dec ax
        mov word [di], ax
        jmp short .45
.42:
        db 0x03, 0xD3                           ; insn: add dx, bx
        jae short .44
.43:
        stosw
.44:
        inc ax
        loop .42
        jmp short .45
.45:
        cmp byte [bp - 0xa], 0
        jne short .46
        ret
.46:
        mov cx, word [si + 0x14]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .47
        mov di, word [si + 6]
        mov dx, word [si + 4]
        add dx, 0x8000
        adc di, 0
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipLeftX]
        rep stosw
.47:
        mov cx, word [si + 0x18]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .48
        mov di, word [si + 6]
        mov dx, word [si + 4]
        add dx, 0x8000
        adc di, 0
        db 0x2B, 0xF9                           ; insn: sub di, cx
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        add di, 0x3c0
        mov ax, word [ClipRightX]
        dec ax
        rep stosw
.48:
        mov cx, word [si + 0x16]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .49
        mov di, word [si + 0xa]
        inc di
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        mov ax, word [ClipLeftX]
        rep stosw
.49:
        mov cx, word [si + 0x1a]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        jle short .50
        mov di, word [si + 0xa]
        inc di
        db 0x03, 0xFF                           ; insn: add di, di
        add di, word [bp - 0x16]
        add di, 0x3c0
        mov ax, word [ClipRightX]
        dec ax
        rep stosw
.50:
        ret

; FillRec1 and FillRec0 walk a list of pointers to line records. The flag byte selects the span table, as in
; FillPoly. LineFn is 3C9Ah. SinLookup and CosLookup read a quadrant of the word table. CosLookup increments
; AH first. SaveMode records the BIOS mode, equipment byte, columns, and rows, and registers RestoreMode.
;
; WaitBlank waits through one pulse of status port 3DAh bit 0.

;-----------------------------------------------------------------------------
; FillRec1                                                    03A3:30DE  94 PC
; Walks a list of pointers to line records. The flag byte is 1. LineFn is
; 3C9Ah.
;-----------------------------------------------------------------------------
FillRec1:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 1
        mov ax, 0x48d2
        mov word [ScanFn], ax
        mov ax, 0x3c9a
        mov word [LineFn], ax
        jmp short FillRec
;-----------------------------------------------------------------------------
; FillRec0                                                    03A3:30F9  94 PC
; Same walk with the flag byte 0.
;-----------------------------------------------------------------------------
FillRec0:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        add sp, -0x7ce
        push si
        push di
        mov byte [bp - 9], 0
        mov ax, 0x48d2
        mov word [ScanFn], ax
        mov ax, 0x3c9a
        mov word [LineFn], ax
FillRec:
        lea si, [bp + 0xa]
        mov word [bp - 6], si
        mov cx, word [bp + 8]
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        dec ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x03, 0xC6                           ; insn: add ax, si
        mov word [bp - 8], ax
        cld
        mov ax, ss
        mov es, ax
        lea ax, [bp - 0x796]
        mov word [bp - 0x16], ax
        mov ax, word [ClipLeftX]
        mov word [bp - 2], ax
        mov ax, word [ClipRightX]
        dec ax
        mov word [bp - 4], ax
        mov di, word [si]
        mov ax, word [di + 6]
        sub ax, word [di + 0x14]
        sub ax, word [di + 0x18]
        mov word [bp - 0xc], ax
        mov ax, word [di + 0xa]
        add ax, word [di + 0x16]
        add ax, word [di + 0x1a]
        mov word [bp - 0x10], ax
        mov word [bp - 0x7ce], 3
        mov bx, word [di + 2]
        mov dx, word [di + 8]
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jle short .1
        db 0x87, 0xDA                           ; insn: xchg dx, bx
.1:
        mov word [bp - 0xe], si
        mov word [bp - 0x12], si
        add si, 2
        dec cx
        jne short .2
        mov ax, word [bp + 6]
        mov word [bp + di + 6], ax
        push di
        call far [LineFn]
        add sp, 2
        pop di
        pop si
        leave
        retf
.2:
        mov di, word [si]
        mov ax, word [di + 6]
        sub ax, word [di + 0x14]
        sub ax, word [di + 0x18]
        cmp ax, word [bp - 0xc]
        jg short .4
        jne short .3
        test word [bp - 0x7ce], 1
        je short .5
.3:
        mov word [bp - 0xc], ax
        mov word [bp - 0xe], si
        or word [bp - 0x7ce], 1
        jmp short .5
.4:
        and word [bp - 0x7ce], 2
.5:
        mov ax, word [di + 0xa]
        add ax, word [di + 0x16]
        add ax, word [di + 0x1a]
        cmp ax, word [bp - 0x10]
        jl short .7
        jne short .6
        test word [bp - 0x7ce], 2
        jne short .8
.6:
        mov word [bp - 0x10], ax
        mov word [bp - 0x12], si
        or word [bp - 0x7ce], 2
        jmp short .8
.7:
        and word [bp - 0x7ce], 1
.8:
        mov ax, word [di + 2]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .9
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.9:
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jle short .10
        db 0x8B, 0xD0                           ; insn: mov dx, ax
.10:
        mov ax, word [di + 8]
        db 0x3B, 0xC3                           ; insn: cmp ax, bx
        jge short .11
        db 0x8B, 0xD8                           ; insn: mov bx, ax
.11:
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        jle short .12
        db 0x8B, 0xD0                           ; insn: mov dx, ax
.12:
        add si, 2
        loop .2
        cmp dx, word [bp - 2]
        jl short .16
        cmp bx, word [bp - 4]
        jge short .16
        mov ax, word [bp - 0x10]
        cmp ax, word [ClipTopY]
        jl short .16
        mov cx, word [bp - 0xc]
        cmp cx, word [ClipBottomY]
        jge short .16
        mov byte [bp - 0xa], 0
        cmp dx, word [bp - 4]
        jg short .13
        cmp bx, word [bp - 2]
        jl short .13
        cmp ax, word [ClipBottomY]
        jge short .13
        cmp cx, word [ClipTopY]
        jge short .14
.13:
        mov byte [bp - 0xa], 1
.14:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        je short .15
        db 0x3B, 0xD3                           ; insn: cmp dx, bx
        jne short .17
.15:
        mov si, word [bp - 6]
        mov di, word [si]
        push di
        call far [LineFn]
        add sp, 2
.16:
        pop di
        pop si
        leave
        retf
.17:
        mov di, word [bp - 0xe]
.18:
        mov si, word [di]
        cmp byte [si + 0x12], 2
        jl short .21
        mov word [bp - 0x14], di
        cmp byte [bp - 0xa], 0
        je short .19
        call SpanMargin
        jmp short .20
.19:
        call SpanFill
.20:
        mov di, word [bp - 0x14]
.21:
        cmp di, word [bp - 0x12]
        je short .22
        add di, 2
        cmp di, word [bp - 8]
        jbe short .18
        mov di, word [bp - 6]
        jmp short .18
.22:
        mov di, word [bp - 0xe]
.23:
        sub di, 2
        cmp di, word [bp - 6]
        jae short .24
        mov di, word [bp - 8]
.24:
        cmp di, word [bp - 0x12]
        je short .25
        mov si, word [di]
        cmp byte [si + 0x12], 2
        jl short .23
        mov word [bp - 0x14], di
        call SpanBack
        mov di, word [bp - 0x14]
        jmp short .23
.25:
        mov ax, word [bp - 0x10]
        cmp ax, word [ClipBottomY]
        jl short .26
        mov ax, word [ClipBottomY]
        dec ax
.26:
        mov bx, word [bp - 0xc]
        cmp bx, word [ClipTopY]
        jge short .27
        mov bx, word [ClipTopY]
.27:
        db 0x2B, 0xC3                           ; insn: sub ax, bx
        jle short .28
        inc ax
        push word [bp + 6]
        push ax
        push bx
        db 0x03, 0xDB                           ; insn: add bx, bx
        lea ax, [bp - 0x3d6]
        db 0x03, 0xC3                           ; insn: add ax, bx
        push ax
        lea ax, [bp - 0x796]
        db 0x03, 0xC3                           ; insn: add ax, bx
        push ax
        call far [ScanFn]
        add sp, 0xa
.28:
        pop di
        pop si
        leave
        retf
;-----------------------------------------------------------------------------
; SinLookup                                                   03A3:32EA  94 PC
; Word from one of four tables, selected by the high byte of the angle.
; FoldScale uses this above 80h.
;-----------------------------------------------------------------------------
SinLookup:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
        jmp short AngleTab
;-----------------------------------------------------------------------------
; CosLookup                                                   03A3:32F1  94 PC
; Same lookup after incrementing AH. FoldScale uses this at 80h and below.
;-----------------------------------------------------------------------------
CosLookup:
        db 0x8B, 0xDC                           ; insn: mov bx, sp
        mov ax, word [bx + 4]
.regs:
        inc ah
AngleTab:
        and ah, 3
        jnp short .1
        jne short .3
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bx + Sin0]
        retf
.1:
        dec ah
        jne short .2
        neg ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bx + Sin1]
        retf
.2:
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bx + Sin2]
        neg ax
        retf
.3:
        neg ax
        db 0x03, 0xC0                           ; insn: add ax, ax
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ax, word [bx + Sin3]
        neg ax
        retf
        db 0
;-----------------------------------------------------------------------------
; ClearHold                                                   03A3:3330  94 PC
; Stores 0 at HoldWord and returns.
;-----------------------------------------------------------------------------
ClearHold:
        mov word [HoldWord], 0
        retf
        db 0
;-----------------------------------------------------------------------------
; SaveMode                                                    03A3:3338  94 PC
; Records the BIOS video mode, equipment byte, columns, and rows, and
; registers RestoreMode.
;-----------------------------------------------------------------------------
SaveMode:
        cmp byte [VidMode], 0
        jne short .1
        mov ah, 0xf
        int 0x10
        mov byte [VidMode], al
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov al, byte es:[0x410]
        mov byte [VidEquip], al
        mov ax, word es:[0x44a]
        mov word [VidCols], ax
        mov al, byte es:[0x484]
        mov byte [VidRows], al
        mov ax, 0x336d
        push cs
        push ax
        call 0x03A3:OnexitThunk
        add sp, 4
.1:
        retf
;-----------------------------------------------------------------------------
; RestoreMode                                                 03A3:336D  94 PC
; Restores that mode. An 80-column mode 3 with a tall row count selects the
; 8x8 font.
;-----------------------------------------------------------------------------
RestoreMode:
        cmp byte [VidMode], 0
        je short .3
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov al, byte [VidEquip]
        mov byte es:[0x410], al
        db 0x32, 0xE4                           ; insn: xor ah, ah
        mov al, byte [VidMode]
        int 0x10
        cmp byte [VidMode], 3
        jne short .1
        cmp word [VidCols], 0x50
        jne short .1
        cmp byte [VidRows], 0x2a
        jb short .1
        cmp byte [VidRows], 0x32
        ja short .1
        mov ax, 0x1112
        db 0x33, 0xDB                           ; insn: xor bx, bx
        int 0x10
.1:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov es, ax
        mov al, byte [VidEquip]
        mov byte es:[0x410], al
        and al, 0x30
        cmp al, 0x30
        jne short .2
        db 0x33, 0xC0                           ; insn: xor ax, ax
        push ax
        call 0xFEF:ClearScreenColor
        add sp, 2
.2:
        mov ah, 0xb
        mov bx, 0
        int 0x10
        mov byte [VidMode], 0
.3:
        retf
;-----------------------------------------------------------------------------
; WaitBlank                                                   03A3:33D2  94 PC
; Waits through one pulse of status port 3DAh bit 0.
;-----------------------------------------------------------------------------
WaitBlank:
        mov dx, 0x3da
.1:
        in al, dx
        test al, 1
        je short .1
.2:
        in al, dx
        test al, 1
        jne short .2
        retf
